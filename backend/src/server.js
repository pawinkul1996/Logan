import express from 'express';
import cors from 'cors';
import stakeRouter from './routes/stake.js';
const app = express(); app.use(cors()); app.use(express.json()); app.use('/api/stake', stakeRouter);
const PORT = process.env.PORT || 3001; app.listen(PORT, ()=> console.log('Backend running on', PORT));
\n// touch 0
\n// touch 6
\n// touch 12
\n// touch 18
\n// touch 24
\n// touch 30
\n// touch 36
\n// touch 42
\n// touch 48
\n// touch 54
\n// touch 60
\n// touch 66
\n// touch 72
\n// touch 78
\n// touch 84
\n// touch 90
\n// touch 96
\n// touch 102
\n// touch 108
\n// touch 114
