import { Router } from 'express';
import { ethers } from 'ethers';
const router = Router();
const RPC_URL = process.env.RPC_URL || 'http://127.0.0.1:8545';
const STAKE_MANAGER_ADDRESS = process.env.STAKE_MANAGER_ADDRESS || '';
function provider(){ return new ethers.JsonRpcProvider(RPC_URL); }
function sm(){ if(!STAKE_MANAGER_ADDRESS) throw new Error('STAKE_MANAGER_ADDRESS not set'); return new ethers.Contract(STAKE_MANAGER_ADDRESS, JSON.parse(process.env.STAKE_MANAGER_ABI||'[]'), provider()); }
router.get('/preview-deposit', async (req,res)=>{ try{ const amt=BigInt(req.query.amount||'0'); if(amt<=0n) return res.status(400).json({error:'Invalid amount'}); const shares=await sm().previewDeposit(amt); res.json({amount: amt.toString(), shares: shares.toString()}); }catch(e){ res.status(500).json({error: String(e.message||e)});} });
router.get('/preview-withdraw', async (req,res)=>{ try{ const sh=BigInt(req.query.shares||'0'); if(sh<=0n) return res.status(400).json({error:'Invalid shares'}); const amt=await sm().previewWithdraw(sh); res.json({shares: sh.toString(), amount: amt.toString()}); }catch(e){ res.status(500).json({error: String(e.message||e)});} });
export default router;
