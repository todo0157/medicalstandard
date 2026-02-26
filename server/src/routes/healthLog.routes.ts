import { Router } from "express";
import { z } from "zod";

import { prisma } from "../lib/prisma";
import { authenticate, type AuthenticatedRequest } from "../middleware/auth.middleware";
import { asyncHandler } from "../middleware/async-handler";
import { validateBody } from "../middleware/validate";

const router = Router();

const logSchema = z.object({
  mood: z.enum(["GOOD", "SOSO", "BAD"]),
  note: z.string().max(200).optional(),
});

router.use(authenticate);

router.get(
  "/",
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const logs = await prisma.healthLog.findMany({
      where: { userAccountId: req.user!.sub },
      orderBy: { date: "desc" },
      take: 30,
    });
    return res.json({ data: logs });
  }),
);

router.post(
  "/",
  validateBody(logSchema),
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const userAccountId = req.user!.sub;
    const { mood, note } = req.body;

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(today.getDate() + 1);

    const existing = await prisma.healthLog.findFirst({
      where: { userAccountId, date: { gte: today, lt: tomorrow } },
    });

    const log = existing
      ? await prisma.healthLog.update({
          where: { id: existing.id },
          data: { mood, note },
        })
      : await prisma.healthLog.create({
          data: { userAccountId, mood, note, date: new Date() },
        });

    return res.json({ data: log });
  }),
);

export default router;
