import { prisma } from "../lib/prisma";
import { chatGateway } from "./chat.gateway";
import { findPractitionerDoctor } from "../middleware/practitioner.middleware";

/**
 * Centralised chat service.
 * Extracts chat session / message logic that was previously duplicated across
 * doctor.routes.ts, chat.routes.ts, and chat.gateway.ts.
 */

/** Find or create a chat session between a patient and a doctor. */
export async function findOrCreateSession(
  userAccountId: string,
  doctorId: string,
  subject?: string,
) {
  let session = await prisma.chatSession.findFirst({
    where: { userAccountId, doctorId },
  });

  if (!session) {
    session = await prisma.chatSession.create({
      data: {
        userAccountId,
        doctorId,
        subject: subject ?? "방문 진료 상담",
      },
    });
  }

  return session;
}

/** Send a chat message and broadcast it in real-time. */
export async function sendMessage(
  sessionId: string,
  sender: "user" | "doctor" | "system",
  content: string,
) {
  const message = await prisma.chatMessage.create({
    data: { sessionId, sender, content },
  });

  await prisma.chatSession.update({
    where: { id: sessionId },
    data: {
      updatedAt: new Date(),
      lastMessageAt: new Date(),
    },
  });

  chatGateway.broadcastMessage(sessionId, message);
  return message;
}

/**
 * Determine the sender role ("user" | "doctor") for a given account in a session.
 *
 * Logic:
 *   1. If the account owns the session → "user"
 *   2. If the account is a practitioner whose Doctor matches the session's doctor → "doctor"
 *   3. Fallback → "user"
 */
export async function resolveSender(
  accountId: string,
  session: { userAccountId: string; doctorId: string | null; doctor?: { name: string } | null },
): Promise<"user" | "doctor"> {
  if (session.userAccountId === accountId) {
    return "user";
  }

  if (session.doctorId) {
    const doctor = await findPractitionerDoctor(accountId);
    if (doctor && session.doctor && doctor.name === session.doctor.name) {
      return "doctor";
    }
  }

  return "user";
}

/**
 * Check if an account has access to a chat session.
 * Returns the session (with doctor included) or null.
 */
export async function authorizeSession(accountId: string, sessionId: string) {
  const session = await prisma.chatSession.findUnique({
    where: { id: sessionId },
    include: { doctor: { include: { clinic: true } } },
  });
  if (!session) return null;

  // Session owner (patient)
  if (session.userAccountId === accountId) {
    return session;
  }

  // Practitioner
  if (session.doctorId) {
    const doctor = await findPractitionerDoctor(accountId);
    if (doctor && session.doctor && doctor.name === session.doctor.name) {
      return session;
    }
  }

  return null;
}
