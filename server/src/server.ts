import { createServer } from 'http';
import cors, { CorsOptions } from 'cors';
import express from 'express';
import helmet from 'helmet';
import morgan from 'morgan';
import path from 'path';
import { env } from './config';
import router from './routes';
import { setupChatGateway } from './services/chat.gateway';
import { initFirebase } from './lib/fcm';

const app = express();

// FCM 초기화
initFirebase();

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
// 이미지 업로드를 위해 body 크기 제한 증가 (10MB)
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(morgan(env.LOG_LEVEL === 'debug' ? 'dev' : 'combined'));

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    environment: env.NODE_ENV,
    timestamp: new Date().toISOString()
  });
});

// 관리자 대시보드 정적 파일 서빙 (API 라우트보다 먼저 처리)
// /admin/* 경로는 정적 파일로 처리하고, /api/admin/* 경로만 API로 처리
const adminPath = path.join(__dirname, '../public/admin');
console.log('[Server] Admin dashboard path:', adminPath);

// /admin 경로에 대한 명시적인 GET 라우트 (라우터보다 먼저 처리)
// 이렇게 하면 /admin/* 경로는 정적 파일로만 처리되고, /api/admin/* 경로만 API로 처리됨
app.get('/admin', (req, res, next) => {
  res.sendFile(path.join(adminPath, 'index.html'));
});

app.get('/admin/*', (req, res, next) => {
  const filePath = path.join(adminPath, req.path.replace('/admin/', ''));
  if (filePath.endsWith('.html') || filePath.endsWith('.js') || filePath.endsWith('.css')) {
    res.sendFile(filePath, (err) => {
      if (err) {
        console.error('[Server] Error serving admin file:', err);
        res.status(404).send('File not found');
      }
    });
  } else {
    next();
  }
});

// 정적 파일 서빙 (fallback)
app.use('/admin', express.static(adminPath, {
  index: 'index.html',
  extensions: ['html', 'js', 'css'],
}));

// API 라우트는 /api로 시작하는 경로만 처리
app.use('/api', router);

// 나머지 라우트는 /admin을 제외한 경로만 처리
// /admin은 이미 위에서 정적 파일로 처리되므로 여기서는 처리되지 않음
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
