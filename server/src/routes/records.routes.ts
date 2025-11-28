import { Router } from "express";
import { z } from "zod";

import { prisma } from "../lib/prisma";
import { authenticate, AuthenticatedRequest } from "../middleware/auth.middleware";

const router = Router();

const recordSchema = z.object({
  doctorId: z.string().min(1),
  appointmentId: z.string().min(1).optional(),
  title: z.string().min(1).max(120),
  summary: z.string().max(1000).optional(),
  prescriptions: z.string().max(1000).optional(),
});

router.use(authenticate);

router.get("/", async (req: AuthenticatedRequest, res, next) => {
  try {
    const records = await prisma.medicalRecord.findMany({
      where: { userAccountId: req.user!.sub },
      orderBy: { createdAt: "desc" },
      include: {
        doctor: { include: { clinic: true } },
        appointment: true,
      },
    });
    return res.json({ data: records });
  } catch (error) {
    return next(error);
  }
});

router.get("/:id", async (req: AuthenticatedRequest, res, next) => {
  try {
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
  } catch (error) {
    return next(error);
  }
});

router.post("/", async (req: AuthenticatedRequest, res, next) => {
  try {
    const payload = recordSchema.parse(req.body);
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
        doctorId: payload.doctorId,
        appointmentId: payload.appointmentId,
        title: payload.title,
        summary: payload.summary,
        prescriptions: payload.prescriptions,
      },
      include: {
        doctor: { include: { clinic: true } },
        appointment: true,
      },
    });
    return res.status(201).json({ data: created });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        message: "입력값이 올바르지 않습니다.",
        issues: error.flatten().fieldErrors,
      });
    }
    return next(error);
  }
});

export default router;
