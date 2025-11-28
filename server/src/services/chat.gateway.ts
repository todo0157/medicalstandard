import type { Server as HttpServer } from 'http';
import type { WebSocket } from 'ws';
import { WebSocketServer } from 'ws';

import { prisma } from '../lib/prisma';
import { AuthService } from './auth.service';

interface ClientMeta {
  sessionId: string;
  accountId: string;
}

interface ChatMessageLike {
  id: string;
  sessionId: string;
  sender: string;
  content: string;
  createdAt: Date;
}

export class ChatGateway {
  private wss?: WebSocketServer;
  private readonly clients = new Map<WebSocket, ClientMeta>();
  private readonly rooms = new Map<string, Set<WebSocket>>();
  private readonly authService = new AuthService();

  attach(server: HttpServer) {
    if (this.wss) return;

    this.wss = new WebSocketServer({ server, path: '/ws/chat' });
    this.wss.on('connection', (socket, request) => {
      void this.handleConnection(socket, request.url ?? '');
    });
  }

  broadcastMessage(sessionId: string, payload: ChatMessageLike) {
    const room = this.rooms.get(sessionId);
    if (!room) return;
    const message = JSON.stringify({
      type: 'message',
      data: this.serializeMessage(payload),
    });
    for (const client of room) {
      try {
        client.send(message);
      } catch (_) {
        // ignore send failures
      }
    }
  }

  serializeMessage(record: ChatMessageLike) {
    return {
      id: record.id,
      sessionId: record.sessionId,
      sender: record.sender,
      content: record.content,
      createdAt: record.createdAt.toISOString(),
    };
  }

  private async handleConnection(socket: WebSocket, rawUrl: string) {
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

      const session = await prisma.chatSession.findUnique({
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
    } catch (_) {
      socket.close(1011, '서버 오류가 발생했습니다.');
    }
  }

  private parseQuery(url: string) {
    const [, query = ''] = url.split('?');
    return new URLSearchParams(query);
  }

  private registerClient(socket: WebSocket, meta: ClientMeta) {
    this.clients.set(socket, meta);
    if (!this.rooms.has(meta.sessionId)) {
      this.rooms.set(meta.sessionId, new Set());
    }
    this.rooms.get(meta.sessionId)!.add(socket);
  }

  private unregisterClient(socket: WebSocket) {
    const meta = this.clients.get(socket);
    if (!meta) return;
    this.clients.delete(socket);
    const room = this.rooms.get(meta.sessionId);
    room?.delete(socket);
    if (room && room.size === 0) {
      this.rooms.delete(meta.sessionId);
    }
  }

  private async handleMessage(socket: WebSocket, rawData: string) {
    const meta = this.clients.get(socket);
    if (!meta) return;
    try {
      const payload = JSON.parse(rawData) as {
        type?: string;
        content?: string;
      };
      if (payload.type !== 'message') return;
      const content = payload.content?.trim();
      if (!content) return;

      const message = await prisma.chatMessage.create({
        data: {
          sessionId: meta.sessionId,
          sender: 'user',
          content,
        },
      });

      await prisma.chatSession.update({
        where: { id: meta.sessionId },
        data: { updatedAt: new Date() },
      });

      this.broadcastMessage(meta.sessionId, message);
    } catch (_) {
      // ignore malformed events
    }
  }
}

export const chatGateway = new ChatGateway();

export function setupChatGateway(server: HttpServer) {
  chatGateway.attach(server);
}



