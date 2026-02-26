import type { Request, Response, NextFunction } from "express";
import { z } from "zod";

/**
 * Express middleware that validates `req.body` against a Zod schema.
 *
 * On success, replaces `req.body` with the parsed (and potentially transformed) value.
 * On failure, responds with 400 and a standardised error shape.
 *
 * Usage:
 *   router.post('/path', validateBody(mySchema), asyncHandler(async (req, res) => { ... }));
 */
export function validateBody<T extends z.ZodTypeAny>(schema: T) {
  return (req: Request, res: Response, next: NextFunction) => {
    const result = schema.safeParse(req.body);
    if (!result.success) {
      return res.status(400).json({
        message: "입력값이 올바르지 않습니다.",
        issues: result.error.flatten().fieldErrors,
      });
    }
    req.body = result.data;
    return next();
  };
}

/**
 * Express middleware that validates `req.query` against a Zod schema.
 *
 * Useful for GET endpoints with validated query params.
 */
export function validateQuery<T extends z.ZodTypeAny>(schema: T) {
  return (req: Request, res: Response, next: NextFunction) => {
    const result = schema.safeParse(req.query);
    if (!result.success) {
      return res.status(400).json({
        message: "입력값이 올바르지 않습니다.",
        issues: result.error.flatten().fieldErrors,
      });
    }
    // Attach parsed query to a well-known property so handlers can read typed values.
    (req as any).validatedQuery = result.data;
    return next();
  };
}
