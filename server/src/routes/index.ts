import { Router } from 'express';
import authRoutes from './auth.routes';
import profileRoutes from './profile.routes';
import doctorRoutes from './doctor.routes';
import chatRoutes from './chat.routes';
import recordRoutes from './records.routes';

const router = Router();

router.use('/auth', authRoutes);
router.use('/profiles', profileRoutes);
router.use('/doctors', doctorRoutes);
router.use('/chat', chatRoutes);
router.use('/records', recordRoutes);

export default router;
