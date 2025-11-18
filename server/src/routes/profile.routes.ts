import { Router } from 'express';
import { ProfileService } from '../services/profile.service';

const router = Router();
const profileService = new ProfileService();

router.get('/me', async (req, res, next) => {
  try {
    const profile = await profileService.getCurrentUserProfile();
    return res.json({ data: profile });
  } catch (error) {
    return next(error);
  }
});

export default router;
