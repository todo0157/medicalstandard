import cors from 'cors';
import express from 'express';
import helmet from 'helmet';
import morgan from 'morgan';
import { env } from './config';
import router from './routes';

const app = express();

app.set('trust proxy', true);
app.use(helmet());
app.use(
  cors({
    origin: env.ALLOW_ORIGIN ?? '*'
  })
);
app.use(express.json());
app.use(morgan(env.LOG_LEVEL === 'debug' ? 'dev' : 'combined'));

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    environment: env.NODE_ENV,
    timestamp: new Date().toISOString()
  });
});

app.use('/api', router);

// eslint-disable-next-line @typescript-eslint/no-unused-vars
app.use((err: Error, req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error(err);
  res.status(500).json({
    message: '서버에서 오류가 발생했습니다.',
    detail: env.NODE_ENV === 'development' ? err.message : undefined
  });
});

const port = env.PORT;

app.listen(port, () => {
  console.log(`🚀 API server running on port ${port} (${env.NODE_ENV})`);
});
