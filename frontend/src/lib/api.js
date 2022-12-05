export async function deposit(amount){ const res= await fetch('/api/stake/deposit',{method:'POST',headers:{'Content-Type':'application/json'}, body: JSON.stringify({amount})}); return res.json(); }
export async function withdraw(amount){ const res= await fetch('/api/stake/withdraw',{method:'POST',headers:{'Content-Type':'application/json'}, body: JSON.stringify({amount})}); return res.json(); }
