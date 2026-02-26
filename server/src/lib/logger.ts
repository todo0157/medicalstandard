import { env } from "../config";

/**
 * Minimal structured logger that respects the LOG_LEVEL config.
 *
 * Levels (lowest → highest): debug → info → warn → error
 * Only messages at or above the configured level are emitted.
 *
 * Usage:
 *   import { logger } from '../lib/logger';
 *   logger.debug('[Module]', 'some detail');
 *   logger.info('[Module]', 'operation completed');
 *   logger.warn('[Module]', 'something suspicious');
 *   logger.error('[Module]', 'something broke', error);
 */

const LEVELS = { debug: 0, info: 1, warn: 2, error: 3 } as const;
type Level = keyof typeof LEVELS;

const threshold = LEVELS[(env.LOG_LEVEL as Level) ?? "info"] ?? LEVELS.info;

function timestamp(): string {
  return new Date().toISOString();
}

function shouldLog(level: Level): boolean {
  return LEVELS[level] >= threshold;
}

export const logger = {
  debug(...args: unknown[]) {
    if (shouldLog("debug")) {
      console.debug(`[${timestamp()}] [DEBUG]`, ...args);
    }
  },

  info(...args: unknown[]) {
    if (shouldLog("info")) {
      console.info(`[${timestamp()}] [INFO]`, ...args);
    }
  },

  warn(...args: unknown[]) {
    if (shouldLog("warn")) {
      console.warn(`[${timestamp()}] [WARN]`, ...args);
    }
  },

  error(...args: unknown[]) {
    if (shouldLog("error")) {
      console.error(`[${timestamp()}] [ERROR]`, ...args);
    }
  },
};
