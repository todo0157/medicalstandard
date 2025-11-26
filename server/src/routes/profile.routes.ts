import { Router } from 'express';
import { z } from 'zod';
import { ProfileService } from '../services/profile.service';
import { authenticate, AuthenticatedRequest } from '../middleware/auth.middleware';

const router = Router();
const profileService = new ProfileService();

const profileUpdateSchema = z.object({
  name: z.string().min(1).max(50),
  age: z.coerce.number().int().min(0).max(120),
  gender: z.enum(['male', 'female']),
  address: z.string().min(1).max(120),
  profileImageUrl: z
    .union([z.string().url().min(1), z.literal('')])
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  phoneNumber: z
    .union([
      z
        .string()
        .regex(/^[0-9+\-]{7,20}$/)
        .min(7)
        .max(20),
      z.literal('')
    ])
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  appointmentCount: z.coerce.number().int().min(0).optional(),
  treatmentCount: z.coerce.number().int().min(0).optional(),
  isPractitioner: z.coerce.boolean().optional(),
  certificationStatus: z.enum(['none', 'pending', 'verified']).optional()
});

router.use(authenticate);

router.get('/me', async (req: AuthenticatedRequest, res, next) => {
  try {
    const profileId = req.user?.profileId;
    if (!profileId) {
      return res.status(401).json({ message: '인증 정보가 없습니다.' });
    }
    const profile = await profileService.getCurrentUserProfile(profileId);
    return res.json({ data: profile });
  } catch (error) {
    return next(error);
  }
});

router.put('/me', async (req: AuthenticatedRequest, res, next) => {
  try {
    const profileId = req.user?.profileId;
    if (!profileId) {
      return res.status(401).json({ message: '인증 정보가 없습니다.' });
    }
    const payload = profileUpdateSchema.parse(req.body);
    const updated = await profileService.updateProfile(profileId, payload);
    return res.json({ data: updated });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        message: '입력값이 올바르지 않습니다.',
        issues: error.flatten().fieldErrors
      });
    }
    return next(error);
  }
});

router.put('/:id', async (req: AuthenticatedRequest, res, next) => {
  try {
    const profileId = req.user?.profileId;
    if (!profileId) {
      return res.status(401).json({ message: '인증 정보가 없습니다.' });
    }
    if (req.params.id !== profileId) {
      return res.status(403).json({ message: '자신의 프로필만 수정할 수 있습니다.' });
    }
    const payload = profileUpdateSchema.parse(req.body);
    const updated = await profileService.updateProfile(profileId, payload);
    return res.json({ data: updated });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        message: '입력값이 올바르지 않습니다.',
        issues: error.flatten().fieldErrors
      });
    }
    return next(error);
  }
});

export default router;
