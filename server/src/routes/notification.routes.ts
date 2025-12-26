import { Router } from 'express';
import { z } from 'zod';
import { authenticate, AuthenticatedRequest } from '../middleware/auth.middleware';
import { prisma } from '../lib/prisma';

const router = Router();

router.use(authenticate);

const registerTokenSchema = z.object({
  token: z.string().min(1),
  platform: z.enum(['android', 'ios', 'web']).optional(),
});

/**
 * POST /api/notifications/register
 * FCM 토큰 등록 (앱 실행/로그인 시 호출)
 */
router.post('/register', async (req: AuthenticatedRequest, res, next) => {
  try {
    const userAccountId = req.user!.sub;
    const { token, platform } = registerTokenSchema.parse(req.body);

    // 기존 토큰이 있으면 업데이트, 없으면 생성
    // (upsert를 사용하여 중복 방지)
    const deviceToken = await prisma.userDeviceToken.upsert({
      where: { token },
      update: {
        userAccountId, // 사용자가 바뀌었을 수도 있으므로 업데이트
        platform,
        lastUsedAt: new Date(),
      },
      create: {
        userAccountId,
        token,
        platform,
      },
    });

    return res.json({ data: deviceToken });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        message: '입력값이 올바르지 않습니다.',
        issues: error.flatten().fieldErrors,
      });
    }
    return next(error);
  }
});

/**
 * POST /api/notifications/unregister
 * FCM 토큰 삭제 (로그아웃 시 호출)
 */
router.post('/unregister', async (req: AuthenticatedRequest, res, next) => {
  try {
    const { token } = z.object({ token: z.string() }).parse(req.body);

    await prisma.userDeviceToken.deleteMany({
      where: { token },
    });

    return res.status(204).send();
  } catch (error) {
    return next(error);
  }
});

export default router;

