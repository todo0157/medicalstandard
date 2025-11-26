"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.env = void 0;
const dotenv_1 = require("dotenv");
const zod_1 = require("zod");
// Load .env file
(0, dotenv_1.config)();
// Define schema
const envSchema = zod_1.z.object({
    NODE_ENV: zod_1.z
        .enum(["development", "staging", "production"])
        .default("development"),
    PORT: zod_1.z.coerce.number().default(8080),
    LOG_LEVEL: zod_1.z
        .enum(["debug", "info", "warn", "error"])
        .default("info"),
    ALLOW_ORIGIN: zod_1.z.string().optional(),
    DATABASE_URL: zod_1.z.string().optional(),
    API_DOMAIN: zod_1.z.string().url().optional(), // URL 형식, Render에서는 optional로 두는 게 안전
    DEFAULT_PROFILE_ID: zod_1.z.string().default('user_123'),
    JWT_SECRET: zod_1.z
        .string()
        .min(16, "JWT_SECRET must be at least 16 characters")
        .default("dev-secret-change-me"),
    JWT_EXPIRES_IN: zod_1.z.string().default("7d"),
    SENDGRID_API_KEY: zod_1.z.string().optional(),
    MAIL_FROM: zod_1.z.string().email().optional(),
    MAIL_FROM_NAME: zod_1.z.string().optional(),
    RESET_LINK_BASE: zod_1.z.string().url().optional(),
    VERIFY_LINK_BASE: zod_1.z.string().url().optional(),
    VERIFY_PRE_LINK_BASE: zod_1.z.string().url().optional(),
    KAKAO_REST_API_KEY: zod_1.z.string().optional(),
    KAKAO_CLIENT_SECRET: zod_1.z.string().optional(),
    KAKAO_REDIRECT_URI: zod_1.z.string().optional(),
});
// Safe parsing
const parsed = envSchema.safeParse(process.env);
// Validation error
if (!parsed.success) {
    console.error("❌ Invalid environment configuration:", parsed.error.flatten().fieldErrors);
    process.exit(1);
}
// Export env with proper typing
exports.env = parsed.data;
