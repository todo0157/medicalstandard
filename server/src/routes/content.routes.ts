import { Router } from "express";
import { z } from "zod";

import { prisma } from "../lib/prisma";
import { authenticate, type AuthenticatedRequest } from "../middleware/auth.middleware";
import { requireAdmin } from "../middleware/admin.middleware";
import { asyncHandler } from "../middleware/async-handler";
import { validateBody } from "../middleware/validate";

const router = Router();

// ─── Schemas ─────────────────────────────────────────────────────

const createTipSchema = z.object({
  title: z.string().min(1),
  content: z.string().min(1),
  category: z.string().optional(),
  imageUrl: z.string().optional(),
  isVisible: z.boolean().optional().default(true),
});

const updateTipSchema = z.object({
  title: z.string().min(1).optional(),
  content: z.string().min(1).optional(),
  category: z.string().optional(),
  imageUrl: z.string().optional(),
  isVisible: z.boolean().optional(),
});

// ─── Public ──────────────────────────────────────────────────────

router.get(
  "/tips",
  asyncHandler(async (req, res) => {
    const { category, limit = "20" } = req.query;
    const limitNum = parseInt(limit as string, 10);
    const where: any = category ? { category: category as string } : {};

    const tips = await prisma.healthTip.findMany({
      where,
      orderBy: { createdAt: "desc" },
      take: limitNum,
    });
    return res.json({ data: tips });
  }),
);

router.get(
  "/tips/:id",
  asyncHandler(async (req, res) => {
    const tip = await prisma.healthTip.update({
      where: { id: req.params.id },
      data: { viewCount: { increment: 1 } },
    });
    return res.json({ data: tip });
  }),
);

// ─── Admin ───────────────────────────────────────────────────────

router.post(
  "/tips",
  authenticate,
  requireAdmin,
  validateBody(createTipSchema),
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const tip = await prisma.healthTip.create({
      data: {
        title: req.body.title,
        content: req.body.content,
        category: req.body.category ?? "general",
        imageUrl: req.body.imageUrl,
        isVisible: req.body.isVisible,
      },
    });
    return res.status(201).json({ data: tip });
  }),
);

router.put(
  "/tips/:id",
  authenticate,
  requireAdmin,
  validateBody(updateTipSchema),
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const payload = req.body;
    const tip = await prisma.healthTip.update({
      where: { id: req.params.id },
      data: {
        ...(payload.title && { title: payload.title }),
        ...(payload.content && { content: payload.content }),
        ...(payload.category && { category: payload.category }),
        ...(payload.imageUrl !== undefined && { imageUrl: payload.imageUrl }),
        ...(payload.isVisible !== undefined && { isVisible: payload.isVisible }),
      },
    });
    return res.json({ data: tip });
  }),
);

router.delete(
  "/tips/:id",
  authenticate,
  requireAdmin,
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    await prisma.healthTip.delete({ where: { id: req.params.id } });
    return res.status(204).send();
  }),
);

export default router;
