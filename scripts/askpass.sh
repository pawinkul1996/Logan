#!/usr/bin/env bash
P="$1"
if echo "$P" | grep -qi username; then echo "pawinkul1996"; exit 0; fi
if echo "$P" | grep -qi password; then awk -F',' 'NR==6{print $5}' "$(pwd)/github_accounts.csv"; exit 0; fi
echo ""; exit 0
