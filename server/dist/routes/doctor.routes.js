"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const prisma_1 = require("../lib/prisma");
const auth_middleware_1 = require("../middleware/auth.middleware");
const router = (0, express_1.Router)();
const querySchema = zod_1.z.object({
    query: zod_1.z.string().optional(),
    limit: zod_1.z.coerce.number().int().min(1).max(50).optional().default(20),
    offset: zod_1.z.coerce.number().int().min(0).optional().default(0),
    lat: zod_1.z.coerce.number().optional(),
    lng: zod_1.z.coerce.number().optional(),
    radiusKm: zod_1.z.coerce.number().min(0.5).max(100).optional().default(20),
});
function haversineKm(lat1, lon1, lat2, lon2) {
    const toRad = (deg) => (deg * Math.PI) / 180;
    const R = 6371; // km
    const dLat = toRad(lat2 - lat1);
    const dLon = toRad(lon2 - lon1);
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
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
        const doctors = await prisma_1.prisma.doctor.findMany({
            where,
            include: { clinic: true },
        });
        let enriched = doctors.map((doc) => {
            const clinic = doc.clinic;
            let distanceKm;
            if (hasCoords && clinic?.lat != null && clinic?.lng != null) {
                distanceKm = haversineKm(lat, lng, clinic.lat, clinic.lng);
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
                if (a.distanceKm == null)
                    return 1;
                if (b.distanceKm == null)
                    return -1;
                return a.distanceKm - b.distanceKm;
            });
        }
        else {
            enriched = enriched.sort((a, b) => a.name.localeCompare(b.name));
        }
        const sliced = enriched.slice(offset, offset + limit);
        res.setHeader('Cache-Control', 'no-store');
        return res.status(200).json({ data: sliced, total: enriched.length, limit, offset });
    }
    catch (error) {
        return next(error);
    }
});
router.get("/:id/slots", async (req, res, next) => {
    try {
        const slots = await prisma_1.prisma.slot.findMany({
            where: { doctorId: req.params.id, isBooked: false },
            orderBy: { startsAt: "asc" },
        });
        return res.json({ data: slots });
    }
    catch (error) {
        return next(error);
    }
});
router.post("/appointments", auth_middleware_1.authenticate, async (req, res, next) => {
    try {
        const schema = zod_1.z.object({
            doctorId: zod_1.z.string().min(1),
            slotId: zod_1.z.string().min(1),
            notes: zod_1.z.string().max(500).optional(),
        });
        const payload = schema.parse(req.body);
        // slot 체크
        const slot = await prisma_1.prisma.slot.findUnique({ where: { id: payload.slotId } });
        if (!slot || slot.isBooked || slot.doctorId !== payload.doctorId) {
            return res.status(400).json({ message: "유효하지 않은 슬롯입니다." });
        }
        const appointment = await prisma_1.prisma.appointment.create({
            data: {
                userAccountId: req.user.sub,
                doctorId: payload.doctorId,
                slotId: payload.slotId,
                notes: payload.notes,
            },
            include: {
                slot: true,
                doctor: { include: { clinic: true } },
            },
        });
        await prisma_1.prisma.slot.update({
            where: { id: payload.slotId },
            data: { isBooked: true },
        });
        return res.status(201).json({ data: appointment });
    }
    catch (error) {
        if (error instanceof zod_1.z.ZodError) {
            return res.status(400).json({
                message: "입력값이 올바르지 않습니다.",
                issues: error.flatten().fieldErrors,
            });
        }
        return next(error);
    }
});
router.patch("/appointments/:id", auth_middleware_1.authenticate, async (req, res, next) => {
    try {
        const schema = zod_1.z.object({
            status: zod_1.z.enum(["confirmed", "cancelled", "completed"]).optional(),
            notes: zod_1.z.string().max(500).optional(),
        });
        const payload = schema.parse(req.body);
        const appointment = await prisma_1.prisma.appointment.findUnique({
            where: { id: req.params.id },
        });
        if (!appointment || appointment.userAccountId !== req.user.sub) {
            return res.status(404).json({ message: "예약을 찾을 수 없습니다." });
        }
        const updated = await prisma_1.prisma.appointment.update({
            where: { id: req.params.id },
            data: payload,
            include: {
                slot: true,
                doctor: { include: { clinic: true } },
            },
        });
        // 취소 시 슬롯을 다시 개방
        if (payload.status === "cancelled") {
            await prisma_1.prisma.slot.update({
                where: { id: appointment.slotId },
                data: { isBooked: false },
            });
        }
        return res.json({ data: updated });
    }
    catch (error) {
        if (error instanceof zod_1.z.ZodError) {
            return res.status(400).json({
                message: "입력값이 올바르지 않습니다.",
                issues: error.flatten().fieldErrors,
            });
        }
        return next(error);
    }
});
router.get("/appointments", auth_middleware_1.authenticate, async (req, res, next) => {
    try {
        const appointments = await prisma_1.prisma.appointment.findMany({
            where: { userAccountId: req.user.sub },
            orderBy: { createdAt: "desc" },
            include: {
                slot: true,
                doctor: { include: { clinic: true } },
            },
        });
        return res.json({ data: appointments });
    }
    catch (error) {
        return next(error);
    }
});
router.delete("/appointments/:id", auth_middleware_1.authenticate, async (req, res, next) => {
    try {
        const appointment = await prisma_1.prisma.appointment.findUnique({
            where: { id: req.params.id },
        });
        if (!appointment || appointment.userAccountId !== req.user.sub) {
            return res.status(404).json({ message: "예약을 찾을 수 없습니다." });
        }
        await prisma_1.prisma.appointment.delete({ where: { id: req.params.id } });
        await prisma_1.prisma.slot.update({
            where: { id: appointment.slotId },
            data: { isBooked: false },
        });
        return res.status(204).send();
    }
    catch (error) {
        return next(error);
    }
});
exports.default = router;
