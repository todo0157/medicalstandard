import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma';
import { authenticate, AuthenticatedRequest } from '../middleware/auth.middleware';

const router = Router();

router.use(authenticate);

/**
 * GET /api/health-logs
 * 사용자의 건강 기록 조회 (최근 30일)
 */
router.get('/', async (req: AuthenticatedRequest, res, next) => {
  try {
    const userAccountId = req.user!.sub;
    
    const logs = await prisma.healthLog.findMany({
      where: { userAccountId },
      orderBy: { date: 'desc' },
      take: 30,
    });
    
    return res.json({ data: logs });
  } catch (error) {
    return next(error);
  }
});

/**
 * POST /api/health-logs
 * 오늘의 건강 기록 작성/수정
 */
const logSchema = z.object({
  mood: z.enum(['GOOD', 'SOSO', 'BAD']),
  note: z.string().max(200).optional(),
});

router.post('/', async (req: AuthenticatedRequest, res, next) => {
  try {
    const userAccountId = req.user!.sub;
    const { mood, note } = logSchema.parse(req.body);
    
    // 오늘의 시작 시간 계산
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(today.getDate() + 1);

    // 오늘 이미 기록이 있는지 확인
    const existingLog = await prisma.healthLog.findFirst({
      where: {
        userAccountId,
        date: {
          gte: today,
          lt: tomorrow,
        }
      }
    });

    let log;
    if (existingLog) {
      // 수정
      log = await prisma.healthLog.update({
        where: { id: existingLog.id },
        data: { mood, note },
      });
    } else {
      // 생성
      log = await prisma.healthLog.create({
        data: {
          userAccountId,
          mood,
          note,
          date: new Date(), // 현재 시간 저장
        },
      });
    }
    
    return res.json({ data: log });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ message: '입력값이 올바르지 않습니다.', issues: error.flatten().fieldErrors });
    }
    return next(error);
  }
});

export default router;
