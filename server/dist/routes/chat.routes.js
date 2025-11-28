"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const prisma_1 = require("../lib/prisma");
const auth_middleware_1 = require("../middleware/auth.middleware");
const chat_gateway_1 = require("../services/chat.gateway");
const router = (0, express_1.Router)();
const sessionSchema = zod_1.z.object({
    doctorId: zod_1.z.string().min(1).optional(),
    subject: zod_1.z.string().min(1).max(120).optional(),
});
const messageSchema = zod_1.z.object({
    content: zod_1.z.string().min(1).max(1000),
});
router.use(auth_middleware_1.authenticate);
router.get("/sessions", async (req, res, next) => {
    try {
        const sessions = await prisma_1.prisma.chatSession.findMany({
            where: { userAccountId: req.user.sub },
            orderBy: { updatedAt: "desc" },
            include: { doctor: { include: { clinic: true } } },
        });
        return res.json({ data: sessions });
    }
    catch (error) {
        return next(error);
    }
});
router.post("/sessions", async (req, res, next) => {
    try {
        const payload = sessionSchema.parse(req.body);
        const session = await prisma_1.prisma.chatSession.create({
            data: {
                userAccountId: req.user.sub,
                doctorId: payload.doctorId,
                subject: payload.subject ?? "방문 진료 상담",
            },
            include: { doctor: { include: { clinic: true } } },
        });
        // 기본 안내 메시지
        const initialMessage = await prisma_1.prisma.chatMessage.create({
            data: {
                sessionId: session.id,
                sender: "doctor",
                content: "상담 요청이 접수되었습니다. 곧 답변드리겠습니다.",
            },
        });
        chat_gateway_1.chatGateway.broadcastMessage(session.id, initialMessage);
        return res.status(201).json({ data: session });
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
async function ensureSession(req, sessionId) {
    const session = await prisma_1.prisma.chatSession.findUnique({
        where: { id: sessionId },
        include: { doctor: { include: { clinic: true } } },
    });
    if (!session || session.userAccountId !== req.user.sub) {
        return null;
    }
    return session;
}
router.get("/sessions/:id/messages", async (req, res, next) => {
    try {
        const session = await ensureSession(req, req.params.id);
        if (!session) {
            return res.status(404).json({ message: "채팅 세션을 찾을 수 없습니다." });
        }
        const messages = await prisma_1.prisma.chatMessage.findMany({
            where: { sessionId: session.id },
            orderBy: { createdAt: "asc" },
        });
        return res.json({ data: { session, messages } });
    }
    catch (error) {
        return next(error);
    }
});
router.post("/sessions/:id/messages", async (req, res, next) => {
    try {
        const session = await ensureSession(req, req.params.id);
        if (!session) {
            return res.status(404).json({ message: "채팅 세션을 찾을 수 없습니다." });
        }
        const payload = messageSchema.parse(req.body);
        const message = await prisma_1.prisma.chatMessage.create({
            data: {
                sessionId: session.id,
                sender: "user",
                content: payload.content.trim(),
            },
        });
        chat_gateway_1.chatGateway.broadcastMessage(session.id, message);
        await prisma_1.prisma.chatSession.update({
            where: { id: session.id },
            data: { updatedAt: new Date() },
        });
        // 간단한 자동 응답
        const autoReply = await prisma_1.prisma.chatMessage.create({
            data: {
                sessionId: session.id,
                sender: "doctor",
                content: "메시지를 확인하고 있습니다. 잠시만 기다려 주세요.",
            },
        });
        chat_gateway_1.chatGateway.broadcastMessage(session.id, autoReply);
        return res.status(201).json({ data: message });
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
