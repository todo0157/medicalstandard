"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const http_1 = require("http");
const cors_1 = __importDefault(require("cors"));
const express_1 = __importDefault(require("express"));
const helmet_1 = __importDefault(require("helmet"));
const morgan_1 = __importDefault(require("morgan"));
const path_1 = __importDefault(require("path"));
const config_1 = require("./config");
const routes_1 = __importDefault(require("./routes"));
const chat_gateway_1 = require("./services/chat.gateway");
const app = (0, express_1.default)();
const allowedOrigins = (config_1.env.ALLOW_ORIGIN ?? '')
    .split(',')
    .map((origin) => origin.trim())
    .filter((origin) => origin.length > 0);
const allowAllOrigins = config_1.env.NODE_ENV === 'development' || allowedOrigins.includes('*');
const corsOptions = allowAllOrigins
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
app.use((0, helmet_1.default)());
app.use((0, cors_1.default)(corsOptions));
// 이미지 업로드를 위해 body 크기 제한 증가 (10MB)
app.use(express_1.default.json({ limit: '10mb' }));
app.use(express_1.default.urlencoded({ extended: true, limit: '10mb' }));
app.use((0, morgan_1.default)(config_1.env.LOG_LEVEL === 'debug' ? 'dev' : 'combined'));
app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        environment: config_1.env.NODE_ENV,
        timestamp: new Date().toISOString()
    });
});
// 관리자 대시보드 정적 파일 서빙 (API 라우트보다 먼저 처리)
// /admin/* 경로는 정적 파일로 처리하고, /api/admin/* 경로만 API로 처리
const adminPath = path_1.default.join(__dirname, '../public/admin');
console.log('[Server] Admin dashboard path:', adminPath);
// /admin 경로에 대한 명시적인 GET 라우트 (라우터보다 먼저 처리)
// 이렇게 하면 /admin/* 경로는 정적 파일로만 처리되고, /api/admin/* 경로만 API로 처리됨
app.get('/admin', (req, res, next) => {
    res.sendFile(path_1.default.join(adminPath, 'index.html'));
});
app.get('/admin/*', (req, res, next) => {
    const filePath = path_1.default.join(adminPath, req.path.replace('/admin/', ''));
    if (filePath.endsWith('.html') || filePath.endsWith('.js') || filePath.endsWith('.css')) {
        res.sendFile(filePath, (err) => {
            if (err) {
                console.error('[Server] Error serving admin file:', err);
                res.status(404).send('File not found');
            }
        });
    }
    else {
        next();
    }
});
// 정적 파일 서빙 (fallback)
app.use('/admin', express_1.default.static(adminPath, {
    index: 'index.html',
    extensions: ['html', 'js', 'css'],
}));
// API 라우트는 /api로 시작하는 경로만 처리
app.use('/api', routes_1.default);
// 나머지 라우트는 /admin을 제외한 경로만 처리
// /admin은 이미 위에서 정적 파일로 처리되므로 여기서는 처리되지 않음
app.use('/', routes_1.default);
// eslint-disable-next-line @typescript-eslint/no-unused-vars
app.use((err, req, res, _next) => {
    console.error(err);
    res.status(500).json({
        message: '서버에서 오류가 발생했습니다.',
        detail: config_1.env.NODE_ENV === 'development' ? err.message : undefined
    });
});
const port = config_1.env.PORT;
const server = (0, http_1.createServer)(app);
(0, chat_gateway_1.setupChatGateway)(server);
server.listen(port, () => {
    console.log(`🚀 API server running on port ${port} (${config_1.env.NODE_ENV})`);
});
