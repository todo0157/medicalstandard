import { prisma } from "../lib/prisma";
import { logger } from "../lib/logger";
import { sendPushNotification, sendMulticastNotification } from "../lib/fcm";
import type { NotificationPayload } from "../lib/fcm";

/**
 * Centralised notification service.
 * All push-notification logic should go through this service
 * so it stays out of route handlers.
 */

/** Truncate text to a max length and append ellipsis. */
function truncate(text: string, max: number): string {
  return text.length > max ? text.substring(0, max) + "..." : text;
}

/** Fetch all FCM tokens for a given userAccountId. */
async function getDeviceTokens(userAccountId: string): Promise<string[]> {
  const rows = await prisma.userDeviceToken.findMany({
    where: { userAccountId },
    select: { token: true },
  });
  return rows.map((r) => r.token);
}

/**
 * Send a notification to a user account (all registered devices).
 */
export async function notifyUser(
  userAccountId: string,
  payload: NotificationPayload,
): Promise<void> {
  const tokens = await getDeviceTokens(userAccountId);
  if (tokens.length === 0) return;

  try {
    await sendMulticastNotification(tokens, payload);
  } catch {
    // Push failures are non-critical; swallow so callers don't break.
  }
}

/**
 * Notify the practitioner (doctor) about a new appointment.
 */
export async function notifyDoctorNewAppointment(
  doctorName: string,
  patientName: string,
  appointmentId: string,
): Promise<void> {
  const doctorAccount = await prisma.userAccount.findFirst({
    where: {
      profile: { name: doctorName, isPractitioner: true },
    },
  });
  if (!doctorAccount) return;

  await notifyUser(doctorAccount.id, {
    title: "새로운 진료 예약",
    body: `${patientName}님이 진료를 예약했습니다.`,
    data: { type: "appointment", appointmentId },
  });
}

/**
 * Notify the patient about an appointment status change.
 */
export async function notifyAppointmentStatusChange(
  userAccountId: string,
  appointmentId: string,
  status: string,
  doctorName: string,
): Promise<void> {
  const statusMessages: Record<string, { title: string; body: string }> = {
    confirmed: {
      title: "진료 예약 확정",
      body: `${doctorName} 한의사님이 예약을 확정했습니다.`,
    },
    cancelled: {
      title: "진료 예약 취소",
      body: "진료 예약이 취소되었습니다.",
    },
    completed: {
      title: "진료 완료",
      body: "진료가 완료되었습니다.",
    },
  };

  const msg = statusMessages[status];
  if (!msg) return;

  await notifyUser(userAccountId, {
    ...msg,
    data: { type: "appointment", appointmentId },
  });
}

/**
 * Notify a chat message recipient (push notification for offline users).
 */
export async function notifyChatMessage(
  sessionId: string,
  sender: "user" | "doctor",
  content: string,
): Promise<void> {
  const session = await prisma.chatSession.findUnique({
    where: { id: sessionId },
    include: { doctor: { select: { id: true, name: true } } },
  });
  if (!session) return;

  let recipientAccountId: string | null = null;
  let title = "";

  if (sender === "user") {
    // Patient → Doctor
    if (session.doctor?.name) {
      const doctorAccount = await prisma.userAccount.findFirst({
        where: {
          profile: { name: session.doctor.name, isPractitioner: true },
        },
      });
      recipientAccountId = doctorAccount?.id ?? null;
      title = "새로운 환자 메시지";
    }
  } else {
    // Doctor → Patient
    recipientAccountId = session.userAccountId;
    title = session.doctor?.name
      ? `${session.doctor.name} 한의사`
      : "새로운 메시지";
  }

  if (!recipientAccountId) return;

  await notifyUser(recipientAccountId, {
    title,
    body: truncate(content, 50),
    data: { type: "chat", sessionId },
  });
}
