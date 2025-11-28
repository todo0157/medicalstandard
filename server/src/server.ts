import { createServer } from 'http';
import cors, { CorsOptions } from 'cors';
import express from 'express';
import helmet from 'helmet';
import morgan from 'morgan';
import { env } from './config';
import router from './routes';
import { setupChatGateway } from './services/chat.gateway';

const app = express();

const allowedOrigins = (env.ALLOW_ORIGIN ?? '')
  .split(',')
  .map((origin) => origin.trim())
  .filter((origin) => origin.length > 0);

const allowAllOrigins =
  env.NODE_ENV === 'development' || allowedOrigins.includes('*');

const corsOptions: CorsOptions = allowAllOrigins
  ? { origin: true }
  : {
      origin: (origin, callback) => {
        if (!origin || allowedOrigins.includes(origin)) {
          return callback(null, true);
        }
        return callback(new Error(`Origin ${origin} not allowed by CORS`));
      }
    };

app.set('trust proxy', true);
app.disable('etag');
app.disable('x-powered-by');
app.use(helmet());
app.use(cors(corsOptions));
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
app.use('/', router);

// eslint-disable-next-line @typescript-eslint/no-unused-vars
app.use((err: Error, req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error(err);
  res.status(500).json({
    message: '서버에서 오류가 발생했습니다.',
    detail: env.NODE_ENV === 'development' ? err.message : undefined
  });
});

const port = env.PORT;
const server = createServer(app);
setupChatGateway(server);

server.listen(port, () => {
  console.log(`🚀 API server running on port ${port} (${env.NODE_ENV})`);
});
