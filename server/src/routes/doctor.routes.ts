import { Router } from "express";
import { z } from "zod";
import { prisma } from "../lib/prisma";
import { authenticate, AuthenticatedRequest } from "../middleware/auth.middleware";

const router = Router();

const querySchema = z.object({
  query: z.string().optional(),
  limit: z.coerce.number().int().min(1).max(50).optional().default(20),
  offset: z.coerce.number().int().min(0).optional().default(0),
});

router.get("/", async (req, res, next) => {
  try {
    const { query, limit, offset } = querySchema.parse(req.query);
    const where = query
      ? {
          OR: [
            { name: { contains: query } },
            { specialty: { contains: query } },
            { clinic: { name: { contains: query } } },
          ],
        }
      : {};

    const [items, total] = await Promise.all([
      prisma.doctor.findMany({
        where,
        include: { clinic: true },
        skip: offset,
        take: limit,
        orderBy: { name: "asc" },
      }),
      prisma.doctor.count({ where }),
    ]);

    return res.json({ data: items, total, limit, offset });
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
        notes: z.string().max(500).optional(),
      });
      const payload = schema.parse(req.body);

      const appointment = await prisma.appointment.findUnique({
        where: { id: req.params.id },
      });
      if (!appointment || appointment.userAccountId !== req.user!.sub) {
        return res.status(404).json({ message: "예약을 찾을 수 없습니다." });
      }

      const updated = await prisma.appointment.update({
        where: { id: req.params.id },
        data: payload,
        include: {
          slot: true,
          doctor: { include: { clinic: true } },
        },
      });

      // 취소 시 슬롯을 다시 개방
      if (payload.status === "cancelled") {
        await prisma.slot.update({
          where: { id: appointment.slotId },
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
