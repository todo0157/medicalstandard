import { Router } from "express";
import { z } from "zod";

import { prisma } from "../lib/prisma";
import { authenticate, type AuthenticatedRequest } from "../middleware/auth.middleware";
import { asyncHandler } from "../middleware/async-handler";
import { validateBody } from "../middleware/validate";

const router = Router();

const recordSchema = z.object({
  doctorId: z.string().min(1),
  appointmentId: z.string().min(1).optional(),
  title: z.string().min(1).max(120),
  summary: z.string().max(1000).optional(),
  prescriptions: z.string().max(1000).optional(),
});

router.use(authenticate);

router.get(
  "/",
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const records = await prisma.medicalRecord.findMany({
      where: { userAccountId: req.user!.sub },
      orderBy: { createdAt: "desc" },
      include: {
        doctor: { include: { clinic: true } },
        appointment: true,
      },
    });
    return res.json({ data: records });
  }),
);

router.get(
  "/:id",
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const record = await prisma.medicalRecord.findUnique({
      where: { id: req.params.id },
      include: {
        doctor: { include: { clinic: true } },
        appointment: true,
      },
    });
    if (!record || record.userAccountId !== req.user!.sub) {
      return res.status(404).json({ message: "진료 기록을 찾을 수 없습니다." });
    }
    return res.json({ data: record });
  }),
);

router.post(
  "/",
  validateBody(recordSchema),
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const profileId = req.user?.profileId;
    if (!profileId) {
      return res.status(401).json({ message: "인증 정보가 없습니다." });
    }
    const profile = await prisma.userProfile.findUnique({ where: { id: profileId } });
    if (!profile?.isPractitioner) {
      return res.status(403).json({ message: "진료 기록은 인증된 한의사만 등록할 수 있습니다." });
    }

    const created = await prisma.medicalRecord.create({
      data: {
        userAccountId: req.user!.sub,
        doctorId: req.body.doctorId,
        appointmentId: req.body.appointmentId,
        title: req.body.title,
        summary: req.body.summary,
        prescriptions: req.body.prescriptions,
      },
      include: {
        doctor: { include: { clinic: true } },
        appointment: true,
      },
    });
    return res.status(201).json({ data: created });
  }),
);

export default router;
