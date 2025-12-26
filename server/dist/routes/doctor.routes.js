"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const prisma_1 = require("../lib/prisma");
const auth_middleware_1 = require("../middleware/auth.middleware");
const chat_gateway_1 = require("../services/chat.gateway");
const fcm_1 = require("../lib/fcm");
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
                isVerified: true,
                OR: [
                    { name: { contains: query } },
                    { specialty: { contains: query } },
                    { clinic: { name: { contains: query } } },
                ],
            }
            : {
                isVerified: true,
            };
        // 모든 Doctor 조회 (디버깅용 로그 추가)
        const doctors = await prisma_1.prisma.doctor.findMany({
            where,
            include: { clinic: true },
        });
        console.log(`[Doctor API] Found ${doctors.length} doctor(s)`, {
            query: query || '(no query)',
            hasCoords,
            doctorNames: doctors.map(d => d.name),
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
        console.log(`[Doctor API] Returning ${sliced.length} doctor(s) (total: ${enriched.length}, offset: ${offset}, limit: ${limit})`);
        res.setHeader('Cache-Control', 'no-store');
        return res.status(200).json({ data: sliced, total: enriched.length, limit, offset });
    }
    catch (error) {
        console.error('[Doctor API] Error:', error);
        return next(error);
    }
});
// 한의사가 자신의 Doctor 정보를 가져오는 엔드포인트
router.get("/my", auth_middleware_1.authenticate, async (req, res, next) => {
    try {
        const profileId = req.user?.profileId;
        if (!profileId) {
            return res.status(401).json({ message: "인증 정보가 없습니다." });
        }
        // 프로필에서 이름 가져오기
        const profile = await prisma_1.prisma.userProfile.findUnique({
            where: { id: profileId },
            select: { name: true, isPractitioner: true },
        });
        if (!profile || !profile.isPractitioner) {
            return res.status(403).json({ message: "한의사 인증이 필요합니다." });
        }
        // 이름으로 Doctor 찾기
        const doctor = await prisma_1.prisma.doctor.findFirst({
            where: { name: profile.name },
            include: { clinic: true },
        });
        if (!doctor) {
            return res.status(404).json({ message: "한의사 정보를 찾을 수 없습니다." });
        }
        return res.json({ data: doctor });
    }
    catch (error) {
        return next(error);
    }
});
// 한의사가 자신의 Slot 목록을 가져오는 엔드포인트
router.get("/my/slots", auth_middleware_1.authenticate, async (req, res, next) => {
    try {
        const profileId = req.user?.profileId;
        if (!profileId) {
            return res.status(401).json({ message: "인증 정보가 없습니다." });
        }
        const profile = await prisma_1.prisma.userProfile.findUnique({
            where: { id: profileId },
            select: { name: true, isPractitioner: true },
        });
        if (!profile || !profile.isPractitioner) {
            return res.status(403).json({ message: "한의사 인증이 필요합니다." });
        }
        const doctor = await prisma_1.prisma.doctor.findFirst({
            where: { name: profile.name },
        });
        if (!doctor) {
            return res.status(404).json({ message: "한의사 정보를 찾을 수 없습니다." });
        }
        const slots = await prisma_1.prisma.slot.findMany({
            where: { doctorId: doctor.id },
            orderBy: { startsAt: "asc" },
        });
        return res.json({ data: slots });
    }
    catch (error) {
        return next(error);
    }
});
// 한의사가 자신의 Slot을 생성하는 엔드포인트
router.post("/my/slots", auth_middleware_1.authenticate, async (req, res, next) => {
    try {
        const profileId = req.user?.profileId;
        if (!profileId) {
            return res.status(401).json({ message: "인증 정보가 없습니다." });
        }
        const profile = await prisma_1.prisma.userProfile.findUnique({
            where: { id: profileId },
            select: { name: true, isPractitioner: true },
        });
        if (!profile || !profile.isPractitioner) {
            return res.status(403).json({ message: "한의사 인증이 필요합니다." });
        }
        const doctor = await prisma_1.prisma.doctor.findFirst({
            where: { name: profile.name },
        });
        if (!doctor) {
            return res.status(404).json({ message: "한의사 정보를 찾을 수 없습니다." });
        }
        const schema = zod_1.z.object({
            startsAt: zod_1.z.string().datetime(),
            endsAt: zod_1.z.string().datetime(),
        });
        const payload = schema.parse(req.body);
        const startsAt = new Date(payload.startsAt);
        const endsAt = new Date(payload.endsAt);
        if (endsAt <= startsAt) {
            return res.status(400).json({ message: "종료 시간은 시작 시간보다 늦어야 합니다." });
        }
        const slot = await prisma_1.prisma.slot.create({
            data: {
                doctorId: doctor.id,
                startsAt,
                endsAt,
                isBooked: false,
            },
        });
        return res.status(201).json({ data: slot });
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
// 한의사가 자신의 Slot을 삭제하는 엔드포인트
router.delete("/my/slots/:slotId", auth_middleware_1.authenticate, async (req, res, next) => {
    try {
        const profileId = req.user?.profileId;
        if (!profileId) {
            return res.status(401).json({ message: "인증 정보가 없습니다." });
        }
        const profile = await prisma_1.prisma.userProfile.findUnique({
            where: { id: profileId },
            select: { name: true, isPractitioner: true },
        });
        if (!profile || !profile.isPractitioner) {
            return res.status(403).json({ message: "한의사 인증이 필요합니다." });
        }
        const doctor = await prisma_1.prisma.doctor.findFirst({
            where: { name: profile.name },
        });
        if (!doctor) {
            return res.status(404).json({ message: "한의사 정보를 찾을 수 없습니다." });
        }
        const slot = await prisma_1.prisma.slot.findUnique({
            where: { id: req.params.slotId },
        });
        if (!slot || slot.doctorId !== doctor.id) {
            return res.status(404).json({ message: "슬롯을 찾을 수 없습니다." });
        }
        if (slot.isBooked) {
            return res.status(400).json({ message: "예약된 슬롯은 삭제할 수 없습니다." });
        }
        await prisma_1.prisma.slot.delete({
            where: { id: req.params.slotId },
        });
        return res.status(204).send();
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
            appointmentTime: zod_1.z.string().datetime().optional(), // 사용자가 선택한 정확한 시간대
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
                appointmentTime: payload.appointmentTime ? new Date(payload.appointmentTime) : null,
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
        // --- 자동 채팅방 생성 및 메시지 전송 로직 추가 ---
        try {
            // 1. 기존 채팅방이 있는지 확인 (사용자 ID와 한의사 ID 기준)
            let chatSession = await prisma_1.prisma.chatSession.findFirst({
                where: {
                    userAccountId: req.user.sub,
                    doctorId: payload.doctorId,
                },
            });
            // 2. 채팅방이 없으면 생성
            if (!chatSession) {
                chatSession = await prisma_1.prisma.chatSession.create({
                    data: {
                        userAccountId: req.user.sub,
                        doctorId: payload.doctorId,
                        subject: `${appointment.doctor.name} 한의사님과의 상담`,
                    },
                });
            }
            // 3. 증상 및 요청사항 메시지 전송 (환자가 보낸 것으로 설정)
            const chatContent = payload.notes
                ? `[신규 진료 예약]\n${payload.notes}`
                : "[신규 진료 예약] 증상 및 요청사항 없이 예약되었습니다.";
            const chatMessage = await prisma_1.prisma.chatMessage.create({
                data: {
                    sessionId: chatSession.id,
                    sender: "user",
                    content: chatContent,
                },
            });
            // 실시간 알림 전송
            chat_gateway_1.chatGateway.broadcastMessage(chatSession.id, chatMessage);
            // 세션 업데이트 시간 갱신
            await prisma_1.prisma.chatSession.update({
                where: { id: chatSession.id },
                data: {
                    updatedAt: new Date(),
                    lastMessageAt: new Date()
                },
            });
        }
        catch (chatError) {
            console.error("[Doctor API] Failed to create chat session/message:", chatError);
            // 예약 자체는 성공했으므로 오류를 던지지는 않음
        }
        // ---------------------------------------------
        // 예약 생성 완료 후 알림 로직 (채팅방 생성 이후)
        // 한의사에게 알림 전송 (예약 접수)
        try {
            // 한의사 계정 찾기 (이름으로 매칭)
            const doctorAccount = await prisma_1.prisma.userAccount.findFirst({
                where: {
                    profile: {
                        name: appointment.doctor.name,
                        isPractitioner: true,
                    }
                }
            });
            if (doctorAccount) {
                const tokens = await prisma_1.prisma.userDeviceToken.findMany({
                    where: { userAccountId: doctorAccount.id },
                    select: { token: true },
                });
                if (tokens.length > 0) {
                    const userName = req.user?.sub ? '환자' : '예약자'; // 사용자 이름 조회 필요하지만 일단 '환자'로 표시
                    // 실제 사용자 이름 조회
                    const userProfile = await prisma_1.prisma.userProfile.findFirst({
                        where: { account: { id: req.user.sub } }
                    });
                    const senderName = userProfile?.name || '환자';
                    // 한의사에게 알림
                    const tokenList = tokens.map(t => t.token);
                    // FCM 다중 전송 함수 필요하지만 일단 단일 전송 루프 (또는 sendMulticastNotification import 필요)
                    // 상단에 sendMulticastNotification import 추가 필요 (현재 sendPushNotification만 있음)
                    // 간단하게 반복문으로 처리
                    for (const t of tokenList) {
                        await (0, fcm_1.sendPushNotification)(t, {
                            title: '새로운 진료 예약',
                            body: `${senderName}님이 진료를 예약했습니다.`,
                            data: {
                                type: 'appointment',
                                appointmentId: appointment.id,
                            },
                        });
                    }
                }
            }
        }
        catch (notiError) {
            console.error('[Doctor API] Failed to send appointment notification:', notiError);
        }
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
            slotId: zod_1.z.string().min(1).optional(), // 예약 시간 변경 시 새 슬롯 ID
            appointmentTime: zod_1.z.string().datetime().optional(), // 선택한 정확한 시간대
            notes: zod_1.z.string().max(500).optional(),
        });
        const payload = schema.parse(req.body);
        const appointment = await prisma_1.prisma.appointment.findUnique({
            where: { id: req.params.id },
            include: { slot: true },
        });
        if (!appointment || appointment.userAccountId !== req.user.sub) {
            return res.status(404).json({ message: "예약을 찾을 수 없습니다." });
        }
        // 슬롯 변경 시 기존 슬롯 해제 및 새 슬롯 예약
        if (payload.slotId && payload.slotId !== appointment.slotId) {
            // 새 슬롯 확인
            const newSlot = await prisma_1.prisma.slot.findUnique({ where: { id: payload.slotId } });
            if (!newSlot || newSlot.isBooked || newSlot.doctorId !== appointment.doctorId) {
                return res.status(400).json({ message: "유효하지 않은 슬롯입니다." });
            }
            // 기존 슬롯 해제
            await prisma_1.prisma.slot.update({
                where: { id: appointment.slotId },
                data: { isBooked: false },
            });
            // 새 슬롯 예약
            await prisma_1.prisma.slot.update({
                where: { id: payload.slotId },
                data: { isBooked: true },
            });
        }
        const updateData = {
            ...(payload.status && { status: payload.status }),
            ...(payload.slotId && { slotId: payload.slotId }),
            ...(payload.appointmentTime && { appointmentTime: new Date(payload.appointmentTime) }),
            ...(payload.notes !== undefined && { notes: payload.notes }),
        };
        const updated = await prisma_1.prisma.appointment.update({
            where: { id: req.params.id },
            data: updateData,
            include: {
                slot: true,
                doctor: { include: { clinic: true } },
            },
        });
        // --- 예약 수정 시 채팅방 처리 로직 추가 ---
        try {
            // 한의사가 변경되었는지 확인
            if (payload.slotId && payload.slotId !== appointment.slotId) {
                // 실제 한의사가 변경되었는지 체크 (슬롯의 doctorId 비교)
                const newSlot = await prisma_1.prisma.slot.findUnique({ where: { id: payload.slotId } });
                if (newSlot && newSlot.doctorId !== appointment.doctorId) {
                    // 한의사가 변경됨 -> 이전 한의사와의 채팅방 삭제
                    const oldChatSession = await prisma_1.prisma.chatSession.findFirst({
                        where: {
                            userAccountId: req.user.sub,
                            doctorId: appointment.doctorId,
                        },
                    });
                    if (oldChatSession) {
                        await prisma_1.prisma.chatMessage.deleteMany({ where: { sessionId: oldChatSession.id } });
                        await prisma_1.prisma.chatSession.delete({ where: { id: oldChatSession.id } });
                        console.log(`[Doctor API] Deleted old chat session ${oldChatSession.id} due to doctor change`);
                    }
                    // 새 한의사와의 채팅방 생성 및 메시지 전송
                    let newChatSession = await prisma_1.prisma.chatSession.findFirst({
                        where: {
                            userAccountId: req.user.sub,
                            doctorId: newSlot.doctorId,
                        },
                    });
                    if (!newChatSession) {
                        newChatSession = await prisma_1.prisma.chatSession.create({
                            data: {
                                userAccountId: req.user.sub,
                                doctorId: newSlot.doctorId,
                                subject: `${updated.doctor.name} 한의사님과의 상담`,
                            },
                        });
                    }
                    const chatContent = payload.notes
                        ? `[신규 진료 예약]\n${payload.notes}`
                        : "[신규 진료 예약] 증상 및 요청사항 없이 예약되었습니다.";
                    const chatMessage = await prisma_1.prisma.chatMessage.create({
                        data: {
                            sessionId: newChatSession.id,
                            sender: "user",
                            content: chatContent,
                        },
                    });
                    chat_gateway_1.chatGateway.broadcastMessage(newChatSession.id, chatMessage);
                }
                else {
                    // 한의사는 그대로이고 시간/내용만 변경된 경우
                    const chatSession = await prisma_1.prisma.chatSession.findFirst({
                        where: {
                            userAccountId: req.user.sub,
                            doctorId: appointment.doctorId,
                        },
                    });
                    if (chatSession) {
                        const chatContent = payload.notes
                            ? `[진료 예약 수정]\n${payload.notes}`
                            : "[진료 예약 수정] 시간 또는 내용이 변경되었습니다.";
                        const chatMessage = await prisma_1.prisma.chatMessage.create({
                            data: {
                                sessionId: chatSession.id,
                                sender: "user",
                                content: chatContent,
                            },
                        });
                        chat_gateway_1.chatGateway.broadcastMessage(chatSession.id, chatMessage);
                        await prisma_1.prisma.chatSession.update({
                            where: { id: chatSession.id },
                            data: {
                                updatedAt: new Date(),
                                lastMessageAt: new Date()
                            },
                        });
                    }
                }
            }
            else if (payload.notes !== undefined && payload.notes !== appointment.notes) {
                // 한의사/슬롯은 그대로인데 요청사항(notes)만 변경된 경우
                const chatSession = await prisma_1.prisma.chatSession.findFirst({
                    where: {
                        userAccountId: req.user.sub,
                        doctorId: appointment.doctorId,
                    },
                });
                if (chatSession) {
                    const chatMessage = await prisma_1.prisma.chatMessage.create({
                        data: {
                            sessionId: chatSession.id,
                            sender: "user",
                            content: `[진료 예약 수정]\n${payload.notes}`,
                        },
                    });
                    chat_gateway_1.chatGateway.broadcastMessage(chatSession.id, chatMessage);
                }
            }
        }
        catch (chatError) {
            console.error("[Doctor API] Failed to handle chat session on update:", chatError);
        }
        // ------------------------------------------
        // 취소 시 슬롯을 다시 개방
        if (payload.status === "cancelled") {
            await prisma_1.prisma.slot.update({
                where: { id: updated.slotId },
                data: { isBooked: false },
            });
        }
        // 예약 상태 변경 알림 (확인/취소 등)
        try {
            if (payload.status) {
                // 환자에게 알림 전송
                const tokens = await prisma_1.prisma.userDeviceToken.findMany({
                    where: { userAccountId: appointment.userAccountId },
                    select: { token: true },
                });
                if (tokens.length > 0) {
                    let title = '진료 예약 알림';
                    let body = '';
                    if (payload.status === 'confirmed') {
                        title = '진료 예약 확정';
                        body = `${updated.doctor.name} 한의사님이 예약을 확정했습니다.`;
                    }
                    else if (payload.status === 'cancelled') {
                        title = '진료 예약 취소';
                        body = '진료 예약이 취소되었습니다.';
                    }
                    else if (payload.status === 'completed') {
                        title = '진료 완료';
                        body = '진료가 완료되었습니다.';
                    }
                    if (body) {
                        for (const t of tokens) {
                            await (0, fcm_1.sendPushNotification)(t.token, {
                                title,
                                body,
                                data: {
                                    type: 'appointment',
                                    appointmentId: updated.id,
                                },
                            });
                        }
                    }
                }
            }
        }
        catch (notiError) {
            console.error('[Doctor API] Failed to send status change notification:', notiError);
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
