import { Router } from "express";
import { z } from "zod";

import { prisma } from "../lib/prisma";
import { authenticate, type AuthenticatedRequest } from "../middleware/auth.middleware";
import { asyncHandler } from "../middleware/async-handler";
import { validateBody, validateQuery } from "../middleware/validate";
import {
  resolvePractitionerDoctor,
  type PractitionerRequest,
} from "../middleware/practitioner.middleware";
import {
  createAppointment,
  updateAppointment,
  deleteAppointment,
  AppointmentError,
} from "../services/appointment.service";

const router = Router();

// ─── Schemas ─────────────────────────────────────────────────────

const doctorQuerySchema = z.object({
  query: z.string().optional(),
  limit: z.coerce.number().int().min(1).max(50).optional().default(20),
  offset: z.coerce.number().int().min(0).optional().default(0),
  lat: z.coerce.number().optional(),
  lng: z.coerce.number().optional(),
  radiusKm: z.coerce.number().min(0.5).max(100).optional().default(20),
});

const slotCreateSchema = z.object({
  startsAt: z.string().datetime(),
  endsAt: z.string().datetime(),
});

const appointmentCreateSchema = z.object({
  doctorId: z.string().min(1),
  slotId: z.string().min(1),
  appointmentTime: z.string().datetime().optional(),
  notes: z.string().max(500).optional(),
});

const appointmentUpdateSchema = z.object({
  status: z.enum(["confirmed", "cancelled", "completed"]).optional(),
  slotId: z.string().min(1).optional(),
  appointmentTime: z.string().datetime().optional(),
  notes: z.string().max(500).optional(),
});

// ─── Helpers ─────────────────────────────────────────────────────

function haversineKm(lat1: number, lon1: number, lat2: number, lon2: number) {
  const toRad = (deg: number) => (deg * Math.PI) / 180;
  const R = 6371;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

// ─── Public: List Doctors ────────────────────────────────────────

router.get(
  "/",
  validateQuery(doctorQuerySchema),
  asyncHandler(async (req, res) => {
    const { query, limit, offset, lat, lng, radiusKm } = (req as any).validatedQuery;
    const hasCoords = typeof lat === "number" && typeof lng === "number";

    const where: any = { isVerified: true };
    if (query) {
      where.OR = [
        { name: { contains: query } },
        { specialty: { contains: query } },
        { clinic: { name: { contains: query } } },
      ];
    }

    const doctors = await prisma.doctor.findMany({
      where,
      include: { clinic: true },
    });

    let enriched = doctors.map((doc) => {
      const clinic = doc.clinic as any;
      let distanceKm: number | undefined;
      if (hasCoords && clinic?.lat != null && clinic?.lng != null) {
        distanceKm = haversineKm(lat!, lng!, clinic.lat, clinic.lng);
      }
      return { ...doc, distanceKm };
    });

    if (hasCoords) {
      enriched = enriched
        .filter((d) => d.distanceKm == null || d.distanceKm <= radiusKm)
        .sort((a, b) => (a.distanceKm ?? Infinity) - (b.distanceKm ?? Infinity));
    } else {
      enriched.sort((a, b) => a.name.localeCompare(b.name));
    }

    const sliced = enriched.slice(offset, offset + limit);

    res.setHeader("Cache-Control", "no-store");
    return res.json({ data: sliced, total: enriched.length, limit, offset });
  }),
);

// ─── Practitioner: My Info ───────────────────────────────────────

router.get(
  "/my",
  authenticate,
  resolvePractitionerDoctor,
  asyncHandler(async (req, res) => {
    const doctor = (req as PractitionerRequest).practitionerDoctor;
    const full = await prisma.doctor.findUnique({
      where: { id: doctor.id },
      include: { clinic: true },
    });
    return res.json({ data: full });
  }),
);

// ─── Practitioner: Slots ─────────────────────────────────────────

router.get(
  "/my/slots",
  authenticate,
  resolvePractitionerDoctor,
  asyncHandler(async (req, res) => {
    const doctor = (req as PractitionerRequest).practitionerDoctor;
    const slots = await prisma.slot.findMany({
      where: { doctorId: doctor.id },
      orderBy: { startsAt: "asc" },
    });
    return res.json({ data: slots });
  }),
);

router.post(
  "/my/slots",
  authenticate,
  resolvePractitionerDoctor,
  validateBody(slotCreateSchema),
  asyncHandler(async (req, res) => {
    const doctor = (req as PractitionerRequest).practitionerDoctor;
    const { startsAt, endsAt } = req.body;
    const start = new Date(startsAt);
    const end = new Date(endsAt);

    if (end <= start) {
      return res.status(400).json({ message: "종료 시간은 시작 시간보다 늦어야 합니다." });
    }

    const slot = await prisma.slot.create({
      data: { doctorId: doctor.id, startsAt: start, endsAt: end, isBooked: false },
    });
    return res.status(201).json({ data: slot });
  }),
);

router.delete(
  "/my/slots/:slotId",
  authenticate,
  resolvePractitionerDoctor,
  asyncHandler(async (req, res) => {
    const doctor = (req as PractitionerRequest).practitionerDoctor;
    const slot = await prisma.slot.findUnique({ where: { id: req.params.slotId } });

    if (!slot || slot.doctorId !== doctor.id) {
      return res.status(404).json({ message: "슬롯을 찾을 수 없습니다." });
    }
    if (slot.isBooked) {
      return res.status(400).json({ message: "예약된 슬롯은 삭제할 수 없습니다." });
    }

    await prisma.slot.delete({ where: { id: req.params.slotId } });
    return res.status(204).send();
  }),
);

// ─── Public: Doctor Slots ────────────────────────────────────────

router.get(
  "/:id/slots",
  asyncHandler(async (req, res) => {
    const slots = await prisma.slot.findMany({
      where: { doctorId: req.params.id, isBooked: false },
      orderBy: { startsAt: "asc" },
    });
    return res.json({ data: slots });
  }),
);

// ─── Appointments ────────────────────────────────────────────────

router.post(
  "/appointments",
  authenticate,
  validateBody(appointmentCreateSchema),
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    try {
      const appointment = await createAppointment({
        userAccountId: req.user!.sub,
        ...req.body,
      });
      return res.status(201).json({ data: appointment });
    } catch (err) {
      if (err instanceof AppointmentError) {
        const status = err.code === "NOT_FOUND" ? 404 : 400;
        return res.status(status).json({ message: err.message });
      }
      throw err;
    }
  }),
);

router.patch(
  "/appointments/:id",
  authenticate,
  validateBody(appointmentUpdateSchema),
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    try {
      const updated = await updateAppointment(req.params.id, req.user!.sub, req.body);
      return res.json({ data: updated });
    } catch (err) {
      if (err instanceof AppointmentError) {
        const status = err.code === "NOT_FOUND" ? 404 : 400;
        return res.status(status).json({ message: err.message });
      }
      throw err;
    }
  }),
);

router.get(
  "/appointments",
  authenticate,
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const appointments = await prisma.appointment.findMany({
      where: { userAccountId: req.user!.sub },
      orderBy: { createdAt: "desc" },
      include: { slot: true, doctor: { include: { clinic: true } } },
    });
    return res.json({ data: appointments });
  }),
);

router.delete(
  "/appointments/:id",
  authenticate,
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    try {
      await deleteAppointment(req.params.id, req.user!.sub);
      return res.status(204).send();
    } catch (err) {
      if (err instanceof AppointmentError) {
        return res.status(404).json({ message: err.message });
      }
      throw err;
    }
  }),
);

export default router;
