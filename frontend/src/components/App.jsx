import React, { useEffect, useState } from 'react';
import { deposit, withdraw } from './lib/api.js';
export default function App(){
  const [amount, setAmount] = useState('');
  const [resp, setResp] = useState(null);
  const [account, setAccount] = useState('');
  const [preview, setPreview] = useState(null);
  async function connect(){ if(!window.ethereum){ alert('MetaMask not found'); return; } const [addr]= await window.ethereum.request({method:'eth_requestAccounts'}); setAccount(addr); }
  async function previewDeposit(){ const v=Number(amount); if(!v||v<=0) return; const wei= BigInt(Math.floor(v*1e18)); const r= await fetch(`/api/stake/preview-deposit?amount=${wei}`); setPreview(await r.json()); }
  useEffect(()=>{ if(amount) previewDeposit(); },[amount]);
  return (
    <div style={{padding:20,fontFamily:'sans-serif'}}>
      <h1>LSD Demo</h1>
      <div style={{marginBottom:8}}><button onClick={connect}>{account? `Connected: ${account.slice(0,6)}...`:'Connect Wallet'}</button></div>
      <input value={amount} onChange={e=>setAmount(e.target.value)} placeholder="Amount (ETH)"/>
      <button onClick={async()=>setResp(await deposit(Number(amount)))}>Deposit (mock)</button>
      <button onClick={async()=>setResp(await withdraw(Number(amount)))}>Withdraw (mock)</button>
      {preview && <div style={{marginTop:8}}>Preview shares: {preview.shares}</div>}
      <pre>{resp? JSON.stringify(resp,null,2): 'No action yet'}</pre>
    </div>
  );
}
