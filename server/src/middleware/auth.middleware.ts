import type { NextFunction, Request, Response } from "express";

import { env } from "../config";
import { logger } from "../lib/logger";
import { AuthService } from "../services/auth.service";
import type { AuthTokenPayload } from "../types/auth";

export type AuthenticatedRequest = Request & {
  user?: AuthTokenPayload;
};

const authService = new AuthService();

export function authenticate(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith("Bearer ")) {
    return res.status(401).json({ message: "인증 토큰이 없습니다." });
  }

  const token = header.replace("Bearer ", "").trim();
  try {
    const payload = authService.decodeToken(token);
    req.user = payload;
    return next();
  } catch (error) {
    if (env.NODE_ENV === "development") {
      logger.debug("[Auth] JWT verification failed", error);
    }
    return res.status(401).json({ message: "인증에 실패했습니다." });
  }
}
