import { config as loadEnv } from "dotenv";
import { z } from "zod";

// Load .env file
loadEnv();

// Define schema
const envSchema = z.object({
  NODE_ENV: z
    .enum(["development", "staging", "production"])
    .default("development"),

  PORT: z.coerce.number().default(8080),

  LOG_LEVEL: z
    .enum(["debug", "info", "warn", "error"])
    .default("info"),

  ALLOW_ORIGIN: z.string().optional(),

  DATABASE_URL: z.string().optional(),

  API_DOMAIN: z.string().url().optional(), // URL 형식, Render에서는 optional로 두는 게 안전
  DEFAULT_PROFILE_ID: z.string().default('user_123'),

  JWT_SECRET: z
    .string()
    .min(16, "JWT_SECRET must be at least 16 characters")
    .default("dev-secret-change-me"),
  JWT_EXPIRES_IN: z.string().default("7d"),

  SENDGRID_API_KEY: z.string().optional(),
  MAIL_FROM: z.string().email().optional(),
  MAIL_FROM_NAME: z.string().optional(),
  RESET_LINK_BASE: z.string().url().optional(),
  VERIFY_LINK_BASE: z.string().url().optional(),
  VERIFY_PRE_LINK_BASE: z.string().url().optional(),

  KAKAO_REST_API_KEY: z.string().optional(),
  KAKAO_CLIENT_SECRET: z.string().optional(),
  KAKAO_REDIRECT_URI: z.string().optional(),
});

// Safe parsing
const parsed = envSchema.safeParse(process.env);

// Validation error
if (!parsed.success) {
  console.error(
    "❌ Invalid environment configuration:",
    parsed.error.flatten().fieldErrors
  );
  process.exit(1);
}

// Export env with proper typing
export const env: z.infer<typeof envSchema> = parsed.data;
