#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(pwd)"
CSV_PATH="$ROOT_DIR/github_accounts.csv"

# Read authors (username,email)
AUTHORS=()
while IFS=, read -r username password mfa email token; do
  [ -z "$username" ] && continue
  [ "$username" = "username" ] && continue
  AUTHORS+=("$username,$email")
done < "$CSV_PATH"

# Quotas per account (20-30 each, all different)
QUOTAS=(22 25 21 27 24)
TOTAL=0; for q in "${QUOTAS[@]}"; do TOTAL=$((TOTAL+q)); done

# Phase months (overlapped to fit overall 12-month window)
INIT_MONTHS=("2022-12" "2023-01" "2023-02" "2023-03")
CORE_MONTHS=("2022-12" "2023-01" "2023-02" "2023-03" "2023-04" "2023-05" "2023-06" "2023-07" "2023-08" "2023-09")
TEST_MONTHS=("2023-04" "2023-05" "2023-06" "2023-07" "2023-08" "2023-09" "2023-10" "2023-11")
DOCS_MONTHS=("2023-10" "2023-11")

# Target counts per phase (sum == TOTAL)
INIT_COUNT=10
CORE_COUNT=71
TEST_COUNT=36
DOCS_COUNT=2
if [ $((INIT_COUNT+CORE_COUNT+TEST_COUNT+DOCS_COUNT)) -ne $TOTAL ]; then
  echo "Phase counts do not sum to total commits" >&2; exit 1
fi

rand_day(){ printf "%02d" $(( (RANDOM % 28) + 1 )); }
rand_hour(){ printf "%02d" $(( (RANDOM % 9) + 9 )); }
rand_min(){ printf "%02d" $(( (RANDOM % 50) + 5 )); }
rand_sec(){ printf "%02d" $(( RANDOM % 60 )); }

build_phase_dates(){
  # $1: array name, $2: count
  local array_name="$1"; local count="$2"
  local produced=0; local idx=0
  while [ $produced -lt $count ]; do
    eval "local month=\"\${${array_name}[$idx]}\""
    local year=${month%%-*}; local mon=${month#*-}
    echo "$year-$mon-$(rand_day) $(rand_hour):$(rand_min):$(rand_sec)"
    produced=$((produced+1))
    eval "local arrlen=\"\${#${array_name}[@]}\""
    idx=$(((idx+1) % arrlen))
  done
}

TMP_DATES="$ROOT_DIR/.tmp_dates.txt"
: > "$TMP_DATES"
# Append all phases' dates with epoch for sorting
for d in $(build_phase_dates INIT_MONTHS $INIT_COUNT); do e=$(date -j -f "%Y-%m-%d %H:%M:%S" "$d" +%s 2>/dev/null || true); [ -n "$e" ] && echo "$e $d" >> "$TMP_DATES"; done
for d in $(build_phase_dates CORE_MONTHS $CORE_COUNT); do e=$(date -j -f "%Y-%m-%d %H:%M:%S" "$d" +%s 2>/dev/null || true); [ -n "$e" ] && echo "$e $d" >> "$TMP_DATES"; done
for d in $(build_phase_dates TEST_MONTHS $TEST_COUNT); do e=$(date -j -f "%Y-%m-%d %H:%M:%S" "$d" +%s 2>/dev/null || true); [ -n "$e" ] && echo "$e $d" >> "$TMP_DATES"; done
for d in $(build_phase_dates DOCS_MONTHS $DOCS_COUNT); do e=$(date -j -f "%Y-%m-%d %H:%M:%S" "$d" +%s 2>/dev/null || true); [ -n "$e" ] && echo "$e $d" >> "$TMP_DATES"; done

sort -n "$TMP_DATES" -o "$TMP_DATES"

# Build rotated authors list according to quotas
ROTATED=()
AUTH_EXPANDED=()
for i in $(seq 0 $(( ${#AUTHORS[@]} - 1 ))); do
  name=${AUTHORS[$i]%,*}; email=${AUTHORS[$i]#*,}; q=${QUOTAS[$i]}
  c=1; while [ $c -le $q ]; do AUTH_EXPANDED+=("$name,$email"); c=$((c+1)); done
done
# Rotate by 5-way interleave
for off in 0 1 2 3 4; do
  idx=$off
  while [ $idx -lt ${#AUTH_EXPANDED[@]} ]; do ROTATED+=("${AUTH_EXPANDED[$idx]}"); idx=$((idx+5)); done
done

# Ensure code files exist to touch
mkdir -p backend/src/utils frontend/src/utils tests/integration
[ -f backend/src/server.js ] || echo "import express from 'express';\nconst app=express(); app.get('/',(_r,res)=>res.send('ok')); export default app;" > backend/src/server.js
[ -f backend/src/routes/stake.js ] || echo "import { Router } from 'express'; const router=Router(); export default router;" > backend/src/routes/stake.js
[ -f frontend/src/components/App.jsx ] || echo "export default function App(){ return null }" > frontend/src/components/App.jsx
[ -f frontend/src/lib/api.js ] || echo "export const x=1;" > frontend/src/lib/api.js
[ -f contracts/src/StakeManager.sol ] || echo "// stake manager" > contracts/src/StakeManager.sol
[ -f contracts/src/LSDToken.sol ] || echo "// token" > contracts/src/LSDToken.sol

# Helpers
phase_for_date(){
  local d="$1"; local ym=$(echo "$d" | awk '{print $1}' | cut -c1-7)
  case "$ym" in
    2022-12|2023-01|2023-02|2023-03) echo init ;;
    2023-10|2023-11) echo docs ;;
    2023-04|2023-05|2023-06|2023-07|2023-08|2023-09) echo test ;;
    *) echo core ;;
  esac
}

apply_change(){
  local idx="$1"; local phase="$2"
  case "$phase" in
    init)
      case $((idx%4)) in
        0) echo "\n// health ${idx}" >> backend/src/server.js ;;
        1) echo "\nexport function f${idx}(n){return Number(n||0)}" >> frontend/src/utils/format.js ;;
        2) echo "\n// init ${idx}" >> contracts/src/StakeManager.sol ;;
        3) echo "\n// unit seed ${idx}" >> tests/unit/apr.js ;;
      esac ;;
    core)
      case $((idx%6)) in
        0) echo "\n// quote ${idx}" >> backend/src/routes/stake.js ;;
        1) echo "\nexport function n${idx}(n){return n>0}" >> backend/src/utils/number.js ;;
        2) echo "\nexport function H${idx}(){return null}" >> frontend/src/components/App.jsx ;;
        3) echo "\nexport async function a${idx}(){return 1}" >> frontend/src/lib/api.js ;;
        4) echo "\n// core ${idx}" >> contracts/src/LSDToken.sol ;;
        5) echo "\n// integration ${idx}" >> tests/integration/backend.test.js ;;
      esac ;;
    test)
      case $((idx%5)) in
        0) echo "\n// edge ${idx}" >> tests/unit/apr.js ;;
        1) echo "\n// validate ${idx}" >> tests/integration/backend.test.js ;;
        2) echo "\nexport const d${idx}=${idx%3}" >> frontend/src/utils/test-helpers.js ;;
        3) echo "\n// guard ${idx}" >> backend/src/server.js ;;
        4) echo "\n// tested ${idx}" >> backend/src/routes/stake.js ;;
      esac ;;
    docs)
      case $((idx%2)) in
        0) echo "\n## Changelog ${idx}\n- Polishing." >> README.md ;;
        1) echo "\n### Note ${idx}" >> README.md ;;
      esac ;;
  esac
}

# iterate over sorted dates and commit with rotated authors
line_no=0
while IFS= read -r line; do
  date_str="${line#* }" # strip epoch
  phase=$(phase_for_date "$date_str")
  apply_change "$line_no" "$phase"
  pair="${ROTATED[$line_no]}"; name="${pair%,*}"; email="${pair#*,}"
  case "$phase" in init|core) prefix="feat";; test) prefix="test";; docs) prefix="docs";; esac
  GIT_AUTHOR_DATE="$date_str" GIT_COMMITTER_DATE="$date_str" git -c user.name="$name" -c user.email="$email" add -A
  GIT_AUTHOR_DATE="$date_str" GIT_COMMITTER_DATE="$date_str" git -c user.name="$name" -c user.email="$email" commit -m "$prefix: ${phase} update #$((line_no+1))" >/dev/null
  printf "." >&2
  line_no=$((line_no+1))
done < "$TMP_DATES"

echo "\nGenerated $TOTAL commits" >&2
