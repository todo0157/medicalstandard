"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const prisma_1 = require("../lib/prisma");
const auth_middleware_1 = require("../middleware/auth.middleware");
const router = (0, express_1.Router)();
const recordSchema = zod_1.z.object({
    doctorId: zod_1.z.string().min(1),
    appointmentId: zod_1.z.string().min(1).optional(),
    title: zod_1.z.string().min(1).max(120),
    summary: zod_1.z.string().max(1000).optional(),
    prescriptions: zod_1.z.string().max(1000).optional(),
});
router.use(auth_middleware_1.authenticate);
router.get("/", async (req, res, next) => {
    try {
        const records = await prisma_1.prisma.medicalRecord.findMany({
            where: { userAccountId: req.user.sub },
            orderBy: { createdAt: "desc" },
            include: {
                doctor: { include: { clinic: true } },
                appointment: true,
            },
        });
        return res.json({ data: records });
    }
    catch (error) {
        return next(error);
    }
});
router.get("/:id", async (req, res, next) => {
    try {
        const record = await prisma_1.prisma.medicalRecord.findUnique({
            where: { id: req.params.id },
            include: {
                doctor: { include: { clinic: true } },
                appointment: true,
            },
        });
        if (!record || record.userAccountId !== req.user.sub) {
            return res.status(404).json({ message: "진료 기록을 찾을 수 없습니다." });
        }
        return res.json({ data: record });
    }
    catch (error) {
        return next(error);
    }
});
router.post("/", async (req, res, next) => {
    try {
        const payload = recordSchema.parse(req.body);
        const created = await prisma_1.prisma.medicalRecord.create({
            data: {
                userAccountId: req.user.sub,
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
exports.default = router;
