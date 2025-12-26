import { Router } from 'express';
import authRoutes from './auth.routes';
import profileRoutes from './profile.routes';
import doctorRoutes from './doctor.routes';
import chatRoutes from './chat.routes';
import recordRoutes from './records.routes';
import addressRoutes from './address.routes';
import adminRoutes from './admin.routes';
import notificationRoutes from './notification.routes';
import contentRoutes from './content.routes';
import healthLogRoutes from './healthLog.routes';

const router = Router();

router.use('/auth', authRoutes);
router.use('/profiles', profileRoutes);
router.use('/doctors', doctorRoutes);
router.use('/chat', chatRoutes);
router.use('/records', recordRoutes);
router.use('/addresses', addressRoutes);
// /admin API 라우트는 /api/admin으로만 접근 가능하도록 설정
router.use('/admin', adminRoutes);
router.use('/notifications', notificationRoutes);
router.use('/contents', contentRoutes);
router.use('/health-logs', healthLogRoutes);

export default router;
