import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma';
import { authenticate, AuthenticatedRequest } from '../middleware/auth.middleware';
import { requireAdmin } from '../middleware/admin.middleware';

const router = Router();

/**
 * GET /api/contents/tips
 * 건강 팁 목록 조회
 */
router.get('/tips', async (req, res, next) => {
  try {
    const { category, limit = '20' } = req.query;
    const limitNum = parseInt(limit as string, 10);
    
    const where: any = category ? { category: category as string } : {};
    
    const tips = await prisma.healthTip.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      take: limitNum,
    });
    
    return res.json({ data: tips });
  } catch (error) {
    return next(error);
  }
});

/**
 * GET /api/contents/tips/:id
 * 건강 팁 상세 조회
 */
router.get('/tips/:id', async (req, res, next) => {
  try {
    const tip = await prisma.healthTip.update({
      where: { id: req.params.id },
      data: { viewCount: { increment: 1 } },
    });
    
    return res.json({ data: tip });
  } catch (error) {
    return next(error);
  }
});

/**
 * POST /api/contents/tips (Admin 전용)
 * 건강 팁 생성
 */
const createTipSchema = z.object({
  title: z.string().min(1),
  content: z.string().min(1),
  category: z.string().optional(),
  imageUrl: z.string().optional(),
  isVisible: z.boolean().optional().default(true),
});

router.post('/tips', authenticate, requireAdmin, async (req: AuthenticatedRequest, res, next) => {
  try {
    const payload = createTipSchema.parse(req.body);
    const tip = await prisma.healthTip.create({
      data: {
        title: payload.title,
        content: payload.content,
        category: payload.category ?? "general",
        imageUrl: payload.imageUrl,
        isVisible: payload.isVisible,
      },
    });
    return res.status(201).json({ data: tip });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ message: '입력값이 올바르지 않습니다.', issues: error.flatten().fieldErrors });
    }
    return next(error);
  }
});

/**
 * PUT /api/contents/tips/:id (Admin 전용)
 * 건강 팁 수정
 */
const updateTipSchema = z.object({
  title: z.string().min(1).optional(),
  content: z.string().min(1).optional(),
  category: z.string().optional(),
  imageUrl: z.string().optional(),
  isVisible: z.boolean().optional(),
});

router.put('/tips/:id', authenticate, requireAdmin, async (req: AuthenticatedRequest, res, next) => {
  try {
    const payload = updateTipSchema.parse(req.body);
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
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ message: '입력값이 올바르지 않습니다.', issues: error.flatten().fieldErrors });
    }
    return next(error);
  }
});

/**
 * DELETE /api/contents/tips/:id (Admin 전용)
 * 건강 팁 삭제
 */
router.delete('/tips/:id', authenticate, requireAdmin, async (req: AuthenticatedRequest, res, next) => {
  try {
    await prisma.healthTip.delete({
      where: { id: req.params.id },
    });
    return res.status(204).send();
  } catch (error) {
    return next(error);
  }
});

export default router;
