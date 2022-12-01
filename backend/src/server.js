import express from 'express';
import cors from 'cors';
import stakeRouter from './routes/stake.js';
const app = express(); app.use(cors()); app.use(express.json()); app.use('/api/stake', stakeRouter);
const PORT = process.env.PORT || 3001; app.listen(PORT, ()=> console.log('Backend running on', PORT));
\n// touch 0
