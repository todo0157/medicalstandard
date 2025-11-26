"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const cors_1 = __importDefault(require("cors"));
const express_1 = __importDefault(require("express"));
const helmet_1 = __importDefault(require("helmet"));
const morgan_1 = __importDefault(require("morgan"));
const config_1 = require("./config");
const routes_1 = __importDefault(require("./routes"));
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
app.use(express_1.default.json());
app.use((0, morgan_1.default)(config_1.env.LOG_LEVEL === 'debug' ? 'dev' : 'combined'));
app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        environment: config_1.env.NODE_ENV,
        timestamp: new Date().toISOString()
    });
});
app.use('/api', routes_1.default);
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
app.listen(port, () => {
    console.log(`🚀 API server running on port ${port} (${config_1.env.NODE_ENV})`);
});
