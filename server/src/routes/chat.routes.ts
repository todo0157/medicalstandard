import { Router } from "express";
import { z } from "zod";

import { prisma } from "../lib/prisma";
import { authenticate, type AuthenticatedRequest } from "../middleware/auth.middleware";
import { asyncHandler } from "../middleware/async-handler";
import { validateBody } from "../middleware/validate";
import {
  authorizeSession,
  resolveSender,
  sendMessage,
} from "../services/chat.service";
import { notifyChatMessage } from "../services/notification.service";

const router = Router();

// ─── Schemas ─────────────────────────────────────────────────────

const sessionCreateSchema = z.object({
  doctorId: z.string().min(1).optional(),
  subject: z.string().min(1).max(120).optional(),
});

const messageCreateSchema = z.object({
  content: z.string().min(1).max(1000),
  isPractitionerMode: z.boolean().optional(),
});

router.use(authenticate);

// ─── Sessions ────────────────────────────────────────────────────

router.get(
  "/sessions",
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const uiMode = req.query.uiMode as string | undefined;
    const isPractitionerMode = uiMode === "practitioner";

    const account = await prisma.userAccount.findUnique({
      where: { id: req.user!.sub },
      select: { profileId: true },
    });

    let sessions: any[] = [];

    if (account) {
      const profile = await prisma.userProfile.findUnique({
        where: { id: account.profileId },
        select: { name: true, isPractitioner: true },
      });

      if (isPractitionerMode && profile?.isPractitioner) {
        const doctor = await prisma.doctor.findFirst({
          where: { name: profile.name },
          select: { id: true },
        });

        sessions = doctor
          ? await prisma.chatSession.findMany({
              where: { doctorId: doctor.id },
              orderBy: { updatedAt: "desc" },
              include: { doctor: { include: { clinic: true } } },
            })
          : [];
      } else {
        sessions = await prisma.chatSession.findMany({
          where: { userAccountId: req.user!.sub },
          orderBy: { updatedAt: "desc" },
          include: { doctor: { include: { clinic: true } } },
        });
      }
    }

    // Enrich with last message time and unread count
    const enriched = await Promise.all(
      sessions.map(async (session) => {
        const lastMessage = await prisma.chatMessage.findFirst({
          where: { sessionId: session.id },
          orderBy: { createdAt: "desc" },
        });

        const unreadCount = await prisma.chatMessage.count({
          where: {
            sessionId: session.id,
            sender: isPractitionerMode ? "user" : "doctor",
            readAt: null,
          },
        });

        return {
          id: session.id,
          userAccountId: session.userAccountId,
          doctorId: session.doctorId,
          subject: session.subject,
          createdAt: session.createdAt.toISOString(),
          updatedAt: session.updatedAt.toISOString(),
          lastMessageAt: (lastMessage?.createdAt || session.updatedAt).toISOString(),
          unreadCount,
          doctor: session.doctor,
        };
      }),
    );

    return res.json({ data: enriched });
  }),
);

router.post(
  "/sessions",
  validateBody(sessionCreateSchema),
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const session = await prisma.chatSession.create({
      data: {
        userAccountId: req.user!.sub,
        doctorId: req.body.doctorId,
        subject: req.body.subject ?? "방문 진료 상담",
      },
      include: { doctor: { include: { clinic: true } } },
    });
    return res.status(201).json({ data: session });
  }),
);

// ─── Messages ────────────────────────────────────────────────────

router.get(
  "/sessions/:id/messages",
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const session = await authorizeSession(req.user!.sub, req.params.id);
    if (!session) {
      return res.status(404).json({ message: "채팅 세션을 찾을 수 없습니다." });
    }

    const uiMode = req.query.uiMode as string | undefined;
    const isPractitionerMode = uiMode === "practitioner";

    const messages = await prisma.chatMessage.findMany({
      where: { sessionId: session.id },
      orderBy: { createdAt: "asc" },
    });

    // Mark unread messages as read
    const senderToMark = isPractitionerMode ? "user" : "doctor";
    await prisma.chatMessage.updateMany({
      where: { sessionId: session.id, sender: senderToMark, readAt: null },
      data: { readAt: new Date() },
    });

    return res.json({ data: { session, messages } });
  }),
);

router.post(
  "/sessions/:id/messages",
  validateBody(messageCreateSchema),
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const session = await authorizeSession(req.user!.sub, req.params.id);
    if (!session) {
      return res.status(404).json({ message: "채팅 세션을 찾을 수 없습니다." });
    }

    // Determine sender
    let sender: "user" | "doctor";
    if (req.body.isPractitionerMode === true) {
      sender = await resolveSender(req.user!.sub, session);
    } else {
      sender = session.userAccountId === req.user!.sub
        ? "user"
        : await resolveSender(req.user!.sub, session);
    }

    const message = await sendMessage(session.id, sender, req.body.content.trim());

    // Push notification (non-critical)
    notifyChatMessage(session.id, sender, req.body.content).catch(() => {});

    return res.status(201).json({ data: message });
  }),
);

// ─── Delete Session ──────────────────────────────────────────────

router.delete(
  "/sessions/:id",
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const session = await authorizeSession(req.user!.sub, req.params.id);
    if (!session) {
      return res.status(404).json({ message: "채팅 세션을 찾을 수 없습니다." });
    }

    await prisma.chatMessage.deleteMany({ where: { sessionId: session.id } });
    await prisma.chatSession.delete({ where: { id: session.id } });
    return res.json({ message: "채팅 세션이 삭제되었습니다." });
  }),
);

export default router;
