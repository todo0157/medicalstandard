import { Router } from "express";
import { z } from "zod";
import { prisma } from "../lib/prisma";
import { authenticate, AuthenticatedRequest } from "../middleware/auth.middleware";

const router = Router();

const querySchema = z.object({
  query: z.string().optional(),
  limit: z.coerce.number().int().min(1).max(50).optional().default(20),
  offset: z.coerce.number().int().min(0).optional().default(0),
  lat: z.coerce.number().optional(),
  lng: z.coerce.number().optional(),
  radiusKm: z.coerce.number().min(0.5).max(100).optional().default(20),
});

function haversineKm(lat1: number, lon1: number, lat2: number, lon2: number) {
  const toRad = (deg: number) => (deg * Math.PI) / 180;
  const R = 6371; // km
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) *
      Math.cos(toRad(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

router.get("/", async (req, res, next) => {
  try {
    const { query, limit, offset, lat, lng, radiusKm } = querySchema.parse(req.query);
    const hasCoords = typeof lat === "number" && typeof lng === "number";

    const where = query
      ? {
          OR: [
            { name: { contains: query } },
            { specialty: { contains: query } },
            { clinic: { name: { contains: query } } },
          ],
        }
      : {};

    // 모든 Doctor 조회 (디버깅용 로그 추가)
    const doctors = await prisma.doctor.findMany({
      where,
      include: { clinic: true },
    });

    console.log(`[Doctor API] Found ${doctors.length} doctor(s)`, {
      query: query || '(no query)',
      hasCoords,
      doctorNames: doctors.map(d => d.name),
    });

    let enriched = doctors.map((doc) => {
      const clinic = doc.clinic as any;
      let distanceKm: number | undefined;
      if (hasCoords && clinic?.lat != null && clinic?.lng != null) {
        distanceKm = haversineKm(lat!, lng!, clinic.lat, clinic.lng);
      }
      return {
        ...doc,
        distanceKm,
      };
    });

    if (hasCoords) {
      enriched = enriched
        .filter((d) => d.distanceKm == null || d.distanceKm <= radiusKm)
        .sort((a, b) => {
          if (a.distanceKm == null) return 1;
          if (b.distanceKm == null) return -1;
          return a.distanceKm - b.distanceKm;
        });
    } else {
      enriched = enriched.sort((a, b) => a.name.localeCompare(b.name));
    }

    const sliced = enriched.slice(offset, offset + limit);
    
    console.log(`[Doctor API] Returning ${sliced.length} doctor(s) (total: ${enriched.length}, offset: ${offset}, limit: ${limit})`);
    
    res.setHeader('Cache-Control', 'no-store');
    return res.status(200).json({ data: sliced, total: enriched.length, limit, offset });
  } catch (error) {
    console.error('[Doctor API] Error:', error);
    return next(error);
  }
});

// 한의사가 자신의 Doctor 정보를 가져오는 엔드포인트
router.get("/my", authenticate, async (req: AuthenticatedRequest, res, next) => {
  try {
    const profileId = req.user?.profileId;
    if (!profileId) {
      return res.status(401).json({ message: "인증 정보가 없습니다." });
    }

    // 프로필에서 이름 가져오기
    const profile = await prisma.userProfile.findUnique({
      where: { id: profileId },
      select: { name: true, isPractitioner: true },
    });

    if (!profile || !profile.isPractitioner) {
      return res.status(403).json({ message: "한의사 인증이 필요합니다." });
    }

    // 이름으로 Doctor 찾기
    const doctor = await prisma.doctor.findFirst({
      where: { name: profile.name },
      include: { clinic: true },
    });

    if (!doctor) {
      return res.status(404).json({ message: "한의사 정보를 찾을 수 없습니다." });
    }

    return res.json({ data: doctor });
  } catch (error) {
    return next(error);
  }
});

// 한의사가 자신의 Slot 목록을 가져오는 엔드포인트
router.get("/my/slots", authenticate, async (req: AuthenticatedRequest, res, next) => {
  try {
    const profileId = req.user?.profileId;
    if (!profileId) {
      return res.status(401).json({ message: "인증 정보가 없습니다." });
    }

    const profile = await prisma.userProfile.findUnique({
      where: { id: profileId },
      select: { name: true, isPractitioner: true },
    });

    if (!profile || !profile.isPractitioner) {
      return res.status(403).json({ message: "한의사 인증이 필요합니다." });
    }

    const doctor = await prisma.doctor.findFirst({
      where: { name: profile.name },
    });

    if (!doctor) {
      return res.status(404).json({ message: "한의사 정보를 찾을 수 없습니다." });
    }

    const slots = await prisma.slot.findMany({
      where: { doctorId: doctor.id },
      orderBy: { startsAt: "asc" },
    });

    return res.json({ data: slots });
  } catch (error) {
    return next(error);
  }
});

// 한의사가 자신의 Slot을 생성하는 엔드포인트
router.post("/my/slots", authenticate, async (req: AuthenticatedRequest, res, next) => {
  try {
    const profileId = req.user?.profileId;
    if (!profileId) {
      return res.status(401).json({ message: "인증 정보가 없습니다." });
    }

    const profile = await prisma.userProfile.findUnique({
      where: { id: profileId },
      select: { name: true, isPractitioner: true },
    });

    if (!profile || !profile.isPractitioner) {
      return res.status(403).json({ message: "한의사 인증이 필요합니다." });
    }

    const doctor = await prisma.doctor.findFirst({
      where: { name: profile.name },
    });

    if (!doctor) {
      return res.status(404).json({ message: "한의사 정보를 찾을 수 없습니다." });
    }

    const schema = z.object({
      startsAt: z.string().datetime(),
      endsAt: z.string().datetime(),
    });

    const payload = schema.parse(req.body);
    const startsAt = new Date(payload.startsAt);
    const endsAt = new Date(payload.endsAt);

    if (endsAt <= startsAt) {
      return res.status(400).json({ message: "종료 시간은 시작 시간보다 늦어야 합니다." });
    }

    const slot = await prisma.slot.create({
      data: {
        doctorId: doctor.id,
        startsAt,
        endsAt,
        isBooked: false,
      },
    });

    return res.status(201).json({ data: slot });
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

// 한의사가 자신의 Slot을 삭제하는 엔드포인트
router.delete("/my/slots/:slotId", authenticate, async (req: AuthenticatedRequest, res, next) => {
  try {
    const profileId = req.user?.profileId;
    if (!profileId) {
      return res.status(401).json({ message: "인증 정보가 없습니다." });
    }

    const profile = await prisma.userProfile.findUnique({
      where: { id: profileId },
      select: { name: true, isPractitioner: true },
    });

    if (!profile || !profile.isPractitioner) {
      return res.status(403).json({ message: "한의사 인증이 필요합니다." });
    }

    const doctor = await prisma.doctor.findFirst({
      where: { name: profile.name },
    });

    if (!doctor) {
      return res.status(404).json({ message: "한의사 정보를 찾을 수 없습니다." });
    }

    const slot = await prisma.slot.findUnique({
      where: { id: req.params.slotId },
    });

    if (!slot || slot.doctorId !== doctor.id) {
      return res.status(404).json({ message: "슬롯을 찾을 수 없습니다." });
    }

    if (slot.isBooked) {
      return res.status(400).json({ message: "예약된 슬롯은 삭제할 수 없습니다." });
    }

    await prisma.slot.delete({
      where: { id: req.params.slotId },
    });

    return res.status(204).send();
  } catch (error) {
    return next(error);
  }
});

router.get("/:id/slots", async (req, res, next) => {
  try {
    const slots = await prisma.slot.findMany({
      where: { doctorId: req.params.id, isBooked: false },
      orderBy: { startsAt: "asc" },
    });
    return res.json({ data: slots });
  } catch (error) {
    return next(error);
  }
});

router.post(
  "/appointments",
  authenticate,
  async (req: AuthenticatedRequest, res, next) => {
    try {
      const schema = z.object({
        doctorId: z.string().min(1),
        slotId: z.string().min(1),
        appointmentTime: z.string().datetime().optional(), // 사용자가 선택한 정확한 시간대
        notes: z.string().max(500).optional(),
      });
      const payload = schema.parse(req.body);

      // slot 체크
      const slot = await prisma.slot.findUnique({ where: { id: payload.slotId } });
      if (!slot || slot.isBooked || slot.doctorId !== payload.doctorId) {
        return res.status(400).json({ message: "유효하지 않은 슬롯입니다." });
      }

      const appointment = await prisma.appointment.create({
        data: {
          userAccountId: req.user!.sub,
          doctorId: payload.doctorId,
          slotId: payload.slotId,
          appointmentTime: payload.appointmentTime ? new Date(payload.appointmentTime) : null,
          notes: payload.notes,
        },
        include: {
          slot: true,
          doctor: { include: { clinic: true } },
        },
      });

      await prisma.slot.update({
        where: { id: payload.slotId },
        data: { isBooked: true },
      });

      return res.status(201).json({ data: appointment });
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({
          message: "입력값이 올바르지 않습니다.",
          issues: error.flatten().fieldErrors,
        });
      }
      return next(error);
    }
  },
);

router.patch(
  "/appointments/:id",
  authenticate,
  async (req: AuthenticatedRequest, res, next) => {
    try {
      const schema = z.object({
        status: z.enum(["confirmed", "cancelled", "completed"]).optional(),
        slotId: z.string().min(1).optional(), // 예약 시간 변경 시 새 슬롯 ID
        appointmentTime: z.string().datetime().optional(), // 선택한 정확한 시간대
        notes: z.string().max(500).optional(),
      });
      const payload = schema.parse(req.body);

      const appointment = await prisma.appointment.findUnique({
        where: { id: req.params.id },
        include: { slot: true },
      });
      if (!appointment || appointment.userAccountId !== req.user!.sub) {
        return res.status(404).json({ message: "예약을 찾을 수 없습니다." });
      }

      // 슬롯 변경 시 기존 슬롯 해제 및 새 슬롯 예약
      if (payload.slotId && payload.slotId !== appointment.slotId) {
        // 새 슬롯 확인
        const newSlot = await prisma.slot.findUnique({ where: { id: payload.slotId } });
        if (!newSlot || newSlot.isBooked || newSlot.doctorId !== appointment.doctorId) {
          return res.status(400).json({ message: "유효하지 않은 슬롯입니다." });
        }

        // 기존 슬롯 해제
        await prisma.slot.update({
          where: { id: appointment.slotId },
          data: { isBooked: false },
        });

        // 새 슬롯 예약
        await prisma.slot.update({
          where: { id: payload.slotId },
          data: { isBooked: true },
        });
      }

      const updateData: any = {
        ...(payload.status && { status: payload.status }),
        ...(payload.slotId && { slotId: payload.slotId }),
        ...(payload.appointmentTime && { appointmentTime: new Date(payload.appointmentTime) }),
        ...(payload.notes !== undefined && { notes: payload.notes }),
      };

      const updated = await prisma.appointment.update({
        where: { id: req.params.id },
        data: updateData,
        include: {
          slot: true,
          doctor: { include: { clinic: true } },
        },
      });

      // 취소 시 슬롯을 다시 개방
      if (payload.status === "cancelled") {
        await prisma.slot.update({
          where: { id: updated.slotId },
          data: { isBooked: false },
        });
      }

      return res.json({ data: updated });
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({
          message: "입력값이 올바르지 않습니다.",
          issues: error.flatten().fieldErrors,
        });
      }
      return next(error);
    }
  },
);

router.get(
  "/appointments",
  authenticate,
  async (req: AuthenticatedRequest, res, next) => {
    try {
      const appointments = await prisma.appointment.findMany({
        where: { userAccountId: req.user!.sub },
        orderBy: { createdAt: "desc" },
        include: {
          slot: true,
          doctor: { include: { clinic: true } },
        },
      });
      return res.json({ data: appointments });
    } catch (error) {
      return next(error);
    }
  },
);

router.delete(
  "/appointments/:id",
  authenticate,
  async (req: AuthenticatedRequest, res, next) => {
    try {
      const appointment = await prisma.appointment.findUnique({
        where: { id: req.params.id },
      });
      if (!appointment || appointment.userAccountId !== req.user!.sub) {
        return res.status(404).json({ message: "예약을 찾을 수 없습니다." });
      }

      await prisma.appointment.delete({ where: { id: req.params.id } });
      await prisma.slot.update({
        where: { id: appointment.slotId },
        data: { isBooked: false },
      });

      return res.status(204).send();
    } catch (error) {
      return next(error);
    }
  },
);

export default router;
