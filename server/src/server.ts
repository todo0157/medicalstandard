import { createServer } from "http";
import cors, { type CorsOptions } from "cors";
import express from "express";
import helmet from "helmet";
import morgan from "morgan";
import path from "path";

import { env } from "./config";
import { logger } from "./lib/logger";
import { AppError } from "./lib/app-error";
import router from "./routes";
import { setupChatGateway } from "./services/chat.gateway";
import { initFirebase } from "./lib/fcm";

const app = express();

// ─── Firebase ────────────────────────────────────────────────────
initFirebase();

// ─── CORS ────────────────────────────────────────────────────────
const allowedOrigins = (env.ALLOW_ORIGIN ?? "")
  .split(",")
  .map((o) => o.trim())
  .filter((o) => o.length > 0);

const allowAllOrigins =
  env.NODE_ENV === "development" || allowedOrigins.includes("*");

const corsOptions: CorsOptions = allowAllOrigins
  ? { origin: true }
  : {
      origin: (origin, callback) => {
        if (!origin || allowedOrigins.includes(origin)) {
          return callback(null, true);
        }
        return callback(new Error(`Origin ${origin} not allowed by CORS`));
      },
    };

// ─── Middleware ───────────────────────────────────────────────────
app.set("trust proxy", true);
app.disable("etag");
app.disable("x-powered-by");
app.use(helmet());
app.use(cors(corsOptions));
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));
app.use(morgan(env.LOG_LEVEL === "debug" ? "dev" : "combined"));

// ─── Health Check ────────────────────────────────────────────────
app.get("/health", (_req, res) => {
  res.json({
    status: "ok",
    environment: env.NODE_ENV,
    timestamp: new Date().toISOString(),
  });
});

// ─── Admin Dashboard (static) ────────────────────────────────────
const adminPath = path.join(__dirname, "../public/admin");
app.use(
  "/admin",
  express.static(adminPath, { index: "index.html", extensions: ["html", "js", "css"] }),
);

// ─── API Routes ──────────────────────────────────────────────────
// Routes are mounted ONLY under /api to avoid ambiguity.
app.use("/api", router);

// ─── Global Error Handler ────────────────────────────────────────
// eslint-disable-next-line @typescript-eslint/no-unused-vars
app.use(
  (
    err: Error,
    _req: express.Request,
    res: express.Response,
    _next: express.NextFunction,
  ) => {
    // AppError: intentional, structured error
    if (err instanceof AppError) {
      return res.status(err.status).json({
        message: err.message,
        code: err.code,
      });
    }

    // Unexpected error
    logger.error("[Server] Unhandled error:", err);
    res.status(500).json({
      message: "서버에서 오류가 발생했습니다.",
      detail: env.NODE_ENV === "development" ? err.message : undefined,
    });
  },
);

// ─── Start Server ────────────────────────────────────────────────
const port = env.PORT;
const server = createServer(app);
setupChatGateway(server);

server.listen(port, () => {
  logger.info(`API server running on port ${port} (${env.NODE_ENV})`);
});
