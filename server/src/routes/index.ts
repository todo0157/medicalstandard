import { Router } from 'express';
import authRoutes from './auth.routes';
import profileRoutes from './profile.routes';
import doctorRoutes from './doctor.routes';

const router = Router();

router.use('/auth', authRoutes);
router.use('/profiles', profileRoutes);
router.use('/doctors', doctorRoutes);

export default router;
