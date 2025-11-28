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
                select: { id: true, userAccountId: true },
            });
            if (!session || session.userAccountId !== accountId) {
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
            const message = await prisma_1.prisma.chatMessage.create({
                data: {
                    sessionId: meta.sessionId,
                    sender: 'user',
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
