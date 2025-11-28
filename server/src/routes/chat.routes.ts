import { Router } from "express";
import { z } from "zod";

import { prisma } from "../lib/prisma";
import { authenticate, AuthenticatedRequest } from "../middleware/auth.middleware";
import { chatGateway } from "../services/chat.gateway";

const router = Router();

const sessionSchema = z.object({
  doctorId: z.string().min(1).optional(),
  subject: z.string().min(1).max(120).optional(),
});

const messageSchema = z.object({
  content: z.string().min(1).max(1000),
});

router.use(authenticate);

router.get("/sessions", async (req: AuthenticatedRequest, res, next) => {
  try {
    const sessions = await prisma.chatSession.findMany({
      where: { userAccountId: req.user!.sub },
      orderBy: { updatedAt: "desc" },
      include: { doctor: { include: { clinic: true } } },
    });
    return res.json({ data: sessions });
  } catch (error) {
    return next(error);
  }
});

router.post("/sessions", async (req: AuthenticatedRequest, res, next) => {
  try {
    const payload = sessionSchema.parse(req.body);
    const session = await prisma.chatSession.create({
      data: {
        userAccountId: req.user!.sub,
        doctorId: payload.doctorId,
        subject: payload.subject ?? "방문 진료 상담",
      },
      include: { doctor: { include: { clinic: true } } },
    });

    // 기본 안내 메시지
    const initialMessage = await prisma.chatMessage.create({
      data: {
        sessionId: session.id,
        sender: "doctor",
        content: "상담 요청이 접수되었습니다. 곧 답변드리겠습니다.",
      },
    });
    chatGateway.broadcastMessage(session.id, initialMessage);

    return res.status(201).json({ data: session });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        message: "입력값이 올바르지 않습니다.",
        issues: error.flatten().fieldErrors,
      });
    }
    return next(error);
  }
});

async function ensureSession(req: AuthenticatedRequest, sessionId: string) {
  const session = await prisma.chatSession.findUnique({
    where: { id: sessionId },
    include: { doctor: { include: { clinic: true } } },
  });
  if (!session || session.userAccountId !== req.user!.sub) {
    return null;
  }
  return session;
}

router.get(
  "/sessions/:id/messages",
  async (req: AuthenticatedRequest, res, next) => {
    try {
      const session = await ensureSession(req, req.params.id);
      if (!session) {
        return res.status(404).json({ message: "채팅 세션을 찾을 수 없습니다." });
      }
      const messages = await prisma.chatMessage.findMany({
        where: { sessionId: session.id },
        orderBy: { createdAt: "asc" },
      });
      return res.json({ data: { session, messages } });
    } catch (error) {
      return next(error);
    }
  },
);

router.post(
  "/sessions/:id/messages",
  async (req: AuthenticatedRequest, res, next) => {
    try {
      const session = await ensureSession(req, req.params.id);
      if (!session) {
        return res.status(404).json({ message: "채팅 세션을 찾을 수 없습니다." });
      }
      const payload = messageSchema.parse(req.body);

      const message = await prisma.chatMessage.create({
        data: {
          sessionId: session.id,
          sender: "user",
          content: payload.content.trim(),
        },
      });
      chatGateway.broadcastMessage(session.id, message);

      await prisma.chatSession.update({
        where: { id: session.id },
        data: { updatedAt: new Date() },
      });

      // 간단한 자동 응답
      const autoReply = await prisma.chatMessage.create({
        data: {
          sessionId: session.id,
          sender: "doctor",
          content: "메시지를 확인하고 있습니다. 잠시만 기다려 주세요.",
        },
      });
      chatGateway.broadcastMessage(session.id, autoReply);

      return res.status(201).json({ data: message });
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({
          message: "입력값이 올바르지 않습니다.",
          issues: error.flatten().fieldErrors,
        });
      }
      return next(error);
    }
  },
);

export default router;
