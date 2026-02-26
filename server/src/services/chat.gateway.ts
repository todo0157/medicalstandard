import type { Server as HttpServer } from "http";
import type { WebSocket } from "ws";
import { WebSocketServer } from "ws";

import { prisma } from "../lib/prisma";
import { AuthService } from "./auth.service";
import { findPractitionerDoctor } from "../middleware/practitioner.middleware";
import { notifyChatMessage } from "./notification.service";

// ─── Types ───────────────────────────────────────────────────────

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

// ─── Gateway ─────────────────────────────────────────────────────

export class ChatGateway {
  private wss?: WebSocketServer;
  private readonly clients = new Map<WebSocket, ClientMeta>();
  private readonly rooms = new Map<string, Set<WebSocket>>();
  private readonly authService = new AuthService();

  attach(server: HttpServer) {
    if (this.wss) return;

    this.wss = new WebSocketServer({ server, path: "/ws/chat" });
    this.wss.on("connection", (socket, request) => {
      void this.handleConnection(socket, request.url ?? "");
    });
  }

  /** Broadcast a message to all WebSocket clients in a session + send push. */
  async broadcastMessage(sessionId: string, payload: ChatMessageLike) {
    // 1. WebSocket broadcast
    const room = this.rooms.get(sessionId);
    if (room) {
      const data = JSON.stringify({
        type: "message",
        data: this.serializeMessage(payload),
      });
      for (const client of room) {
        try {
          client.send(data);
        } catch {
          // Ignore send failures for disconnected clients
        }
      }
    }

    // 2. Push notification (non-critical)
    const sender = payload.sender as "user" | "doctor";
    notifyChatMessage(sessionId, sender, payload.content).catch(() => {});
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

  // ─── Private ─────────────────────────────────────────────────

  private async handleConnection(socket: WebSocket, rawUrl: string) {
    try {
      const params = new URLSearchParams(rawUrl.split("?")[1] ?? "");
      const token = params.get("token") ?? "";
      const sessionId = params.get("sessionId") ?? "";

      if (!token || !sessionId) {
        socket.close(1008, "인증 정보를 확인할 수 없습니다.");
        return;
      }

      const payload = this.authService.decodeToken(token);
      const accountId = payload.sub;
      if (!accountId) {
        socket.close(1008, "유효하지 않은 토큰입니다.");
        return;
      }

      // Verify session access
      const session = await prisma.chatSession.findUnique({
        where: { id: sessionId },
        include: { doctor: true },
      });
      if (!session) {
        socket.close(1008, "채팅 세션을 찾을 수 없습니다.");
        return;
      }

      const hasAccess = await this.checkAccess(accountId, session);
      if (!hasAccess) {
        socket.close(1008, "채팅 세션에 접근할 수 없습니다.");
        return;
      }

      this.registerClient(socket, { accountId, sessionId });
      socket.on("message", (event) => {
        void this.handleMessage(socket, event.toString());
      });
      socket.on("close", () => this.unregisterClient(socket));
      socket.on("error", () => this.unregisterClient(socket));
    } catch {
      socket.close(1011, "서버 오류가 발생했습니다.");
    }
  }

  private async checkAccess(
    accountId: string,
    session: { userAccountId: string; doctorId: string | null; doctor?: any },
  ): Promise<boolean> {
    if (session.userAccountId === accountId) return true;

    if (session.doctorId) {
      const doctor = await findPractitionerDoctor(accountId);
      if (doctor && session.doctor && doctor.name === session.doctor.name) {
        return true;
      }
    }

    return false;
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
      const payload = JSON.parse(rawData) as { type?: string; content?: string };
      if (payload.type !== "message") return;
      const content = payload.content?.trim();
      if (!content) return;

      // Determine sender
      const session = await prisma.chatSession.findUnique({
        where: { id: meta.sessionId },
        include: { doctor: true },
      });
      if (!session) return;

      let sender: "user" | "doctor" = "user";
      if (session.userAccountId !== meta.accountId && session.doctorId) {
        const doctor = await findPractitionerDoctor(meta.accountId);
        if (doctor && session.doctor && doctor.name === session.doctor.name) {
          sender = "doctor";
        }
      }

      const message = await prisma.chatMessage.create({
        data: { sessionId: meta.sessionId, sender, content },
      });

      await prisma.chatSession.update({
        where: { id: meta.sessionId },
        data: { updatedAt: new Date() },
      });

      await this.broadcastMessage(meta.sessionId, message);
    } catch {
      // Ignore malformed WebSocket events
    }
  }
}

export const chatGateway = new ChatGateway();

export function setupChatGateway(server: HttpServer) {
  chatGateway.attach(server);
}
