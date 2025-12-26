"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.chatGateway = exports.ChatGateway = void 0;
exports.setupChatGateway = setupChatGateway;
const ws_1 = require("ws");
const prisma_1 = require("../lib/prisma");
const auth_service_1 = require("./auth.service");
const fcm_1 = require("../lib/fcm");
class ChatGateway {
    constructor() {
        this.clients = new Map();
        this.rooms = new Map();
        this.authService = new auth_service_1.AuthService();
    }
    attach(server) {
        if (this.wss)
            return;
        this.wss = new ws_1.WebSocketServer({ server, path: '/ws/chat' });
        this.wss.on('connection', (socket, request) => {
            void this.handleConnection(socket, request.url ?? '');
        });
    }
    // 메시지 브로드캐스트 + 푸시 알림
    async broadcastMessage(sessionId, payload) {
        // 1. WebSocket 전송
        const room = this.rooms.get(sessionId);
        if (room) {
            const message = JSON.stringify({
                type: 'message',
                data: this.serializeMessage(payload),
            });
            for (const client of room) {
                try {
                    client.send(message);
                }
                catch (_) {
                    // ignore send failures
                }
            }
        }
        // 2. 푸시 알림 전송 (상대방에게)
        try {
            // 현재 메시지를 보낸 사람이 아닌, 채팅방의 다른 참여자 찾기
            const session = await prisma_1.prisma.chatSession.findUnique({
                where: { id: sessionId },
                include: {
                    doctor: { select: { id: true, name: true } }
                },
            });
            if (!session)
                return;
            let recipientUserId = null;
            let notificationTitle = '';
            if (payload.sender === 'user') {
                // 보낸이: 환자 -> 수신자: 한의사
                if (session.doctor?.name) {
                    // 한의사 이름으로 계정 찾기 (임시 로직: 이름 매칭)
                    const doctorAccount = await prisma_1.prisma.userAccount.findFirst({
                        where: {
                            profile: {
                                name: session.doctor.name,
                                isPractitioner: true,
                            }
                        }
                    });
                    recipientUserId = doctorAccount?.id || null;
                    notificationTitle = '새로운 환자 메시지';
                }
            }
            else {
                // 보낸이: 한의사 -> 수신자: 환자
                recipientUserId = session.userAccountId;
                notificationTitle = session.doctor?.name ? `${session.doctor.name} 한의사` : '새로운 메시지';
            }
            if (recipientUserId) {
                const tokens = await prisma_1.prisma.userDeviceToken.findMany({
                    where: { userAccountId: recipientUserId },
                    select: { token: true },
                });
                if (tokens.length > 0) {
                    const tokenList = tokens.map(t => t.token);
                    await (0, fcm_1.sendMulticastNotification)(tokenList, {
                        title: notificationTitle,
                        body: payload.content.length > 50 ? payload.content.substring(0, 50) + '...' : payload.content,
                        data: {
                            type: 'chat',
                            sessionId: sessionId,
                        },
                    });
                }
            }
        }
        catch (error) {
            console.error('[ChatGateway] Failed to send push notification:', error);
        }
    }
    serializeMessage(record) {
        return {
            id: record.id,
            sessionId: record.sessionId,
            sender: record.sender,
            content: record.content,
            createdAt: record.createdAt.toISOString(),
        };
    }
    async handleConnection(socket, rawUrl) {
        try {
            const params = this.parseQuery(rawUrl);
            const token = params.get('token') ?? '';
            const sessionId = params.get('sessionId') ?? '';
            if (!token || !sessionId) {
                socket.close(1008, '인증 정보를 확인할 수 없습니다.');
                return;
            }
            const payload = this.authService.decodeToken(token);
            const accountId = payload.sub;
            if (!accountId) {
                socket.close(1008, '유효하지 않은 토큰입니다.');
                return;
            }
            const session = await prisma_1.prisma.chatSession.findUnique({
                where: { id: sessionId },
                include: { doctor: true },
            });
            if (!session) {
                socket.close(1008, '채팅 세션을 찾을 수 없습니다.');
                return;
            }
            // 세션 접근 권한 확인 로직 (기존과 동일)
            if (session.userAccountId === accountId) {
                // 환자는 접근 가능
            }
            else if (session.doctorId) {
                // 한의사인지 확인
                const account = await prisma_1.prisma.userAccount.findUnique({
                    where: { id: accountId },
                    select: { profileId: true },
                });
                if (account) {
                    const profile = await prisma_1.prisma.userProfile.findUnique({
                        where: { id: account.profileId },
                        select: { name: true, isPractitioner: true },
                    });
                    if (profile?.isPractitioner && session.doctor && session.doctor.name === profile.name) {
                        // 한의사는 접근 가능
                    }
                    else {
                        socket.close(1008, '채팅 세션에 접근할 수 없습니다.');
                        return;
                    }
                }
                else {
                    socket.close(1008, '채팅 세션에 접근할 수 없습니다.');
                    return;
                }
            }
            else {
                socket.close(1008, '채팅 세션에 접근할 수 없습니다.');
                return;
            }
            this.registerClient(socket, { accountId, sessionId });
            socket.on('message', (event) => {
                void this.handleMessage(socket, event.toString());
            });
            socket.on('close', () => this.unregisterClient(socket));
            socket.on('error', () => this.unregisterClient(socket));
        }
        catch (_) {
            socket.close(1011, '서버 오류가 발생했습니다.');
        }
    }
    parseQuery(url) {
        const [, query = ''] = url.split('?');
        return new URLSearchParams(query);
    }
    registerClient(socket, meta) {
        this.clients.set(socket, meta);
        if (!this.rooms.has(meta.sessionId)) {
            this.rooms.set(meta.sessionId, new Set());
        }
        this.rooms.get(meta.sessionId).add(socket);
    }
    unregisterClient(socket) {
        const meta = this.clients.get(socket);
        if (!meta)
            return;
        this.clients.delete(socket);
        const room = this.rooms.get(meta.sessionId);
        room?.delete(socket);
        if (room && room.size === 0) {
            this.rooms.delete(meta.sessionId);
        }
    }
    async handleMessage(socket, rawData) {
        const meta = this.clients.get(socket);
        if (!meta)
            return;
        try {
            const payload = JSON.parse(rawData);
            if (payload.type !== 'message')
                return;
            const content = payload.content?.trim();
            if (!content)
                return;
            // sender 결정 로직 (기존과 동일)
            const session = await prisma_1.prisma.chatSession.findUnique({
                where: { id: meta.sessionId },
                include: { doctor: true },
            });
            if (!session)
                return;
            const isSessionOwner = session.userAccountId === meta.accountId;
            let sender = 'user';
            if (isSessionOwner) {
                sender = 'user';
            }
            else {
                const account = await prisma_1.prisma.userAccount.findUnique({
                    where: { id: meta.accountId },
                    select: { profileId: true },
                });
                if (account) {
                    const profile = await prisma_1.prisma.userProfile.findUnique({
                        where: { id: account.profileId },
                        select: { name: true, isPractitioner: true },
                    });
                    if (profile?.isPractitioner && session.doctorId && session.doctor && session.doctor.name === profile.name) {
                        sender = 'doctor';
                    }
                }
            }
            const message = await prisma_1.prisma.chatMessage.create({
                data: {
                    sessionId: meta.sessionId,
                    sender: sender,
                    content,
                },
            });
            await prisma_1.prisma.chatSession.update({
                where: { id: meta.sessionId },
                data: { updatedAt: new Date() },
            });
            await this.broadcastMessage(meta.sessionId, message);
        }
        catch (_) {
            // ignore malformed events
        }
    }
}
exports.ChatGateway = ChatGateway;
exports.chatGateway = new ChatGateway();
function setupChatGateway(server) {
    exports.chatGateway.attach(server);
}
