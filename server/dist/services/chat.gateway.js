"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.chatGateway = exports.ChatGateway = void 0;
exports.setupChatGateway = setupChatGateway;
const ws_1 = require("ws");
const prisma_1 = require("../lib/prisma");
const auth_service_1 = require("./auth.service");
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
    broadcastMessage(sessionId, payload) {
        const room = this.rooms.get(sessionId);
        if (!room)
            return;
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
            // 세션 소유자(환자)인지 확인
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
                    // 한의사이고, 세션의 한의사 이름과 일치하는지 확인
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
            // sender 결정 로직:
            // 1. 세션 소유자(환자)인 경우 → sender: 'user' (우선순위 1)
            // 2. 세션 소유자가 아니지만 한의사인 경우 → sender: 'doctor' (우선순위 2)
            const session = await prisma_1.prisma.chatSession.findUnique({
                where: { id: meta.sessionId },
                include: { doctor: true },
            });
            if (!session) {
                return; // 세션을 찾을 수 없으면 무시
            }
            const isSessionOwner = session.userAccountId === meta.accountId;
            let sender = 'user'; // 기본값은 'user'
            let userProfileName = null;
            let userIsPractitioner = false;
            if (isSessionOwner) {
                // 세션 소유자(환자)인 경우, 무조건 'user'
                sender = 'user';
            }
            else {
                // 세션 소유자가 아닌 경우, 한의사인지 확인
                const account = await prisma_1.prisma.userAccount.findUnique({
                    where: { id: meta.accountId },
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
                        sender = 'doctor';
                    }
                    else {
                        // 한의사가 아니거나 세션의 한의사와 일치하지 않으면 환자
                        sender = 'user';
                    }
                }
            }
            console.log(`[Chat Gateway] WebSocket message`);
            console.log(`  - Current user ID: ${meta.accountId}`);
            console.log(`  - Session owner ID: ${session.userAccountId}`);
            console.log(`  - Session doctor ID: ${session.doctorId || 'none'}`);
            console.log(`  - Session doctor name: ${session.doctor?.name || 'none'}`);
            console.log(`  - Is session owner: ${isSessionOwner}`);
            console.log(`  - User profile name: ${userProfileName || 'none'}`);
            console.log(`  - User is practitioner: ${userIsPractitioner}`);
            console.log(`  - Determined sender: ${sender}`);
            console.log(`  - Message content: ${content.substring(0, 50)}...`);
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
            this.broadcastMessage(meta.sessionId, message);
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
