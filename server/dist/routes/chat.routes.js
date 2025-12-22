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
    isPractitionerMode: zod_1.z.boolean().optional(), // 클라이언트에서 전달하는 UI 모드
});
router.use(auth_middleware_1.authenticate);
router.get("/sessions", async (req, res, next) => {
    try {
        // 클라이언트에서 전달한 UI 모드 확인 (쿼리 파라미터)
        const uiMode = req.query.uiMode;
        const isPractitionerMode = uiMode === 'practitioner';
        console.log(`[Chat Sessions] UI Mode: ${uiMode}, isPractitionerMode: ${isPractitionerMode}`);
        // 현재 사용자 정보 확인
        const account = await prisma_1.prisma.userAccount.findUnique({
            where: { id: req.user.sub },
            select: { profileId: true },
        });
        let sessions;
        if (account) {
            const profile = await prisma_1.prisma.userProfile.findUnique({
                where: { id: account.profileId },
                select: { name: true, isPractitioner: true },
            });
            // UI 모드에 따라 세션 조회 방식 결정
            if (isPractitionerMode && profile?.isPractitioner) {
                // 한의사 모드: 자신의 이름과 일치하는 doctorId를 가진 세션만 조회
                const doctor = await prisma_1.prisma.doctor.findFirst({
                    where: { name: profile.name },
                    select: { id: true },
                });
                if (doctor) {
                    sessions = await prisma_1.prisma.chatSession.findMany({
                        where: { doctorId: doctor.id },
                        orderBy: { updatedAt: "desc" },
                        include: { doctor: { include: { clinic: true } } },
                    });
                }
                else {
                    sessions = [];
                }
            }
            else {
                // 환자 모드: 자신이 생성한 세션만 조회
                sessions = await prisma_1.prisma.chatSession.findMany({
                    where: { userAccountId: req.user.sub },
                    orderBy: { updatedAt: "desc" },
                    include: { doctor: { include: { clinic: true } } },
                });
            }
        }
        else {
            // 프로필이 없으면 빈 배열 반환
            sessions = [];
        }
        // 각 세션에 대해 마지막 메시지 시간과 읽지 않은 메시지 수 계산
        const sessionsWithMetadata = await Promise.all(sessions.map(async (session) => {
            // 마지막 메시지 조회
            const lastMessage = await prisma_1.prisma.chatMessage.findFirst({
                where: { sessionId: session.id },
                orderBy: { createdAt: "desc" },
            });
            // 읽지 않은 메시지 수 계산 (UI 모드에 따라)
            // 환자 모드: sender가 'doctor'이고 readAt이 null인 메시지 수
            // 한의사 모드: sender가 'user'이고 readAt이 null인 메시지 수
            const unreadCount = await prisma_1.prisma.chatMessage.count({
                where: {
                    sessionId: session.id,
                    sender: isPractitionerMode ? "user" : "doctor",
                    readAt: null,
                },
            });
            const lastMessageAt = lastMessage?.createdAt || session.updatedAt;
            // 디버깅 로그
            console.log(`[Chat Sessions] Session ${session.id}:`);
            console.log(`  - uiMode: ${uiMode}`);
            console.log(`  - lastMessageAt: ${lastMessageAt.toISOString()}`);
            console.log(`  - unreadCount: ${unreadCount}`);
            return {
                id: session.id,
                userAccountId: session.userAccountId,
                doctorId: session.doctorId,
                subject: session.subject,
                createdAt: session.createdAt.toISOString(),
                updatedAt: session.updatedAt.toISOString(),
                lastMessageAt: lastMessageAt.toISOString(),
                unreadCount,
                doctor: session.doctor,
            };
        }));
        return res.json({ data: sessionsWithMetadata });
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
        // 기본 안내 메시지는 제거됨 (사용자의 요청에 따라 예약 정보 등으로 대체되거나 수동 전송됨)
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
    if (!session) {
        return null;
    }
    // 세션 소유자(환자)인지 확인
    if (session.userAccountId === req.user.sub) {
        return session;
    }
    // 한의사인지 확인: 세션의 doctorId가 있고, 현재 사용자가 해당 한의사인지 확인
    if (session.doctorId) {
        // 현재 사용자의 프로필 정보 가져오기
        const account = await prisma_1.prisma.userAccount.findUnique({
            where: { id: req.user.sub },
            select: { profileId: true },
        });
        if (account) {
            const profile = await prisma_1.prisma.userProfile.findUnique({
                where: { id: account.profileId },
                select: { name: true, isPractitioner: true },
            });
            // 한의사이고, 세션의 한의사 이름과 일치하는지 확인
            if (profile?.isPractitioner && session.doctor && session.doctor.name === profile.name) {
                return session;
            }
        }
    }
    // 접근 권한이 없음
    return null;
}
router.get("/sessions/:id/messages", async (req, res, next) => {
    try {
        const session = await ensureSession(req, req.params.id);
        if (!session) {
            return res.status(404).json({ message: "채팅 세션을 찾을 수 없습니다." });
        }
        // 클라이언트에서 전달한 UI 모드 확인 (쿼리 파라미터)
        const uiMode = req.query.uiMode;
        const isPractitionerMode = uiMode === 'practitioner';
        console.log(`[Chat Messages] Fetching messages for session ${session.id}`);
        console.log(`  - UI Mode: ${uiMode}, isPractitionerMode: ${isPractitionerMode}`);
        const messages = await prisma_1.prisma.chatMessage.findMany({
            where: { sessionId: session.id },
            orderBy: { createdAt: "asc" },
        });
        // 읽지 않은 메시지를 읽음 처리 (UI 모드에 따라)
        // 환자 모드: sender가 'doctor'인 메시지를 읽음 처리
        // 한의사 모드: sender가 'user'인 메시지를 읽음 처리
        const senderToMarkAsRead = isPractitionerMode ? "user" : "doctor";
        const updatedCount = await prisma_1.prisma.chatMessage.updateMany({
            where: {
                sessionId: session.id,
                sender: senderToMarkAsRead,
                readAt: null,
            },
            data: {
                readAt: new Date(),
            },
        });
        console.log(`  - Marked ${updatedCount.count} messages as read (sender: ${senderToMarkAsRead})`);
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
        // sender 결정 로직:
        // 1. 클라이언트에서 전달한 isPractitionerMode가 true이면 → sender: 'doctor'
        // 2. 그렇지 않으면 → sender: 'user'
        // 단, 세션 소유자가 아니면서 한의사인 경우도 'doctor'로 설정
        const isSessionOwner = session.userAccountId === req.user.sub;
        let sender = "user"; // 기본값은 'user'
        let userProfileName = null;
        let userIsPractitioner = false;
        // 클라이언트에서 한의사 모드로 전송한 경우
        if (payload.isPractitionerMode === true) {
            // 한의사 모드로 전송한 경우, 한의사인지 확인
            const account = await prisma_1.prisma.userAccount.findUnique({
                where: { id: req.user.sub },
                select: { profileId: true },
            });
            if (account) {
                const profile = await prisma_1.prisma.userProfile.findUnique({
                    where: { id: account.profileId },
                    select: { name: true, isPractitioner: true },
                });
                userProfileName = profile?.name || null;
                userIsPractitioner = profile?.isPractitioner || false;
                // 한의사이고, 세션의 doctorId가 있고, 세션의 한의사 이름과 일치하는지 확인
                if (profile?.isPractitioner && session.doctorId && session.doctor && session.doctor.name === profile.name) {
                    sender = "doctor";
                }
                else {
                    // 한의사가 아니거나 세션의 한의사와 일치하지 않으면 환자
                    sender = "user";
                }
            }
        }
        else {
            // 환자 모드로 전송한 경우 또는 isPractitionerMode가 없으면
            if (isSessionOwner) {
                // 세션 소유자(환자)인 경우
                sender = "user";
            }
            else {
                // 세션 소유자가 아닌 경우, 한의사인지 확인
                const account = await prisma_1.prisma.userAccount.findUnique({
                    where: { id: req.user.sub },
                    select: { profileId: true },
                });
                if (account) {
                    const profile = await prisma_1.prisma.userProfile.findUnique({
                        where: { id: account.profileId },
                        select: { name: true, isPractitioner: true },
                    });
                    userProfileName = profile?.name || null;
                    userIsPractitioner = profile?.isPractitioner || false;
                    // 한의사이고, 세션의 doctorId가 있고, 세션의 한의사 이름과 일치하는지 확인
                    if (profile?.isPractitioner && session.doctorId && session.doctor && session.doctor.name === profile.name) {
                        sender = "doctor";
                    }
                    else {
                        // 한의사가 아니거나 세션의 한의사와 일치하지 않으면 환자
                        sender = "user";
                    }
                }
            }
        }
        console.log(`[Chat API] POST /sessions/${req.params.id}/messages`);
        console.log(`  - Current user ID: ${req.user.sub}`);
        console.log(`  - Session owner ID: ${session.userAccountId}`);
        console.log(`  - Session doctor ID: ${session.doctorId || 'none'}`);
        console.log(`  - Session doctor name: ${session.doctor?.name || 'none'}`);
        console.log(`  - Is session owner: ${isSessionOwner}`);
        console.log(`  - Client isPractitionerMode: ${payload.isPractitionerMode ?? 'not provided'}`);
        console.log(`  - User profile name: ${userProfileName || 'none'}`);
        console.log(`  - User is practitioner: ${userIsPractitioner}`);
        console.log(`  - Determined sender: ${sender}`);
        console.log(`  - Message content: ${payload.content.substring(0, 50)}...`);
        const message = await prisma_1.prisma.chatMessage.create({
            data: {
                sessionId: session.id,
                sender: sender,
                content: payload.content.trim(),
            },
        });
        chat_gateway_1.chatGateway.broadcastMessage(session.id, message);
        // 세션의 lastMessageAt과 updatedAt 업데이트
        await prisma_1.prisma.chatSession.update({
            where: { id: session.id },
            data: {
                updatedAt: new Date(),
                lastMessageAt: new Date(),
            },
        });
        // 자동 응답 메시지 제거됨
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
router.delete("/sessions/:id", async (req, res, next) => {
    try {
        const session = await ensureSession(req, req.params.id);
        if (!session) {
            return res.status(404).json({ message: "채팅 세션을 찾을 수 없습니다." });
        }
        // 세션과 관련된 모든 메시지 삭제
        await prisma_1.prisma.chatMessage.deleteMany({
            where: { sessionId: session.id },
        });
        // 세션 삭제
        await prisma_1.prisma.chatSession.delete({
            where: { id: session.id },
        });
        return res.json({ message: "채팅 세션이 삭제되었습니다." });
    }
    catch (error) {
        return next(error);
    }
});
exports.default = router;
