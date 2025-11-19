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
