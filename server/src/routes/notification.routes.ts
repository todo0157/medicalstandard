import { Router } from "express";
import { z } from "zod";

import { prisma } from "../lib/prisma";
import { authenticate, type AuthenticatedRequest } from "../middleware/auth.middleware";
import { asyncHandler } from "../middleware/async-handler";
import { validateBody } from "../middleware/validate";

const router = Router();

const registerSchema = z.object({
  token: z.string().min(1),
  platform: z.enum(["android", "ios", "web"]).optional(),
});

const unregisterSchema = z.object({
  token: z.string(),
});

router.use(authenticate);

router.post(
  "/register",
  validateBody(registerSchema),
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const deviceToken = await prisma.userDeviceToken.upsert({
      where: { token: req.body.token },
      update: {
        userAccountId: req.user!.sub,
        platform: req.body.platform,
        lastUsedAt: new Date(),
      },
      create: {
        userAccountId: req.user!.sub,
        token: req.body.token,
        platform: req.body.platform,
      },
    });
    return res.json({ data: deviceToken });
  }),
);

router.post(
  "/unregister",
  validateBody(unregisterSchema),
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    await prisma.userDeviceToken.deleteMany({ where: { token: req.body.token } });
    return res.status(204).send();
  }),
);

export default router;
