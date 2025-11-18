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
