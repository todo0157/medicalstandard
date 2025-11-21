import { Router } from 'express';
import { z } from 'zod';
import { env } from '../config';
import { ProfileService } from '../services/profile.service';

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

router.get('/me', async (req, res, next) => {
  try {
    const profile = await profileService.getCurrentUserProfile();
    return res.json({ data: profile });
  } catch (error) {
    return next(error);
  }
});

router.put('/me', async (req, res, next) => {
  try {
    const payload = profileUpdateSchema.parse(req.body);
    const updated = await profileService.updateProfile(env.DEFAULT_PROFILE_ID, payload);
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

router.put('/:id', async (req, res, next) => {
  try {
    const payload = profileUpdateSchema.parse(req.body);
    const updated = await profileService.updateProfile(req.params.id, payload);
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
