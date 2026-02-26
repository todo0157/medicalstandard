import { prisma } from "../lib/prisma";
import { logger } from "../lib/logger";
import * as chatService from "./chat.service";
import * as notificationService from "./notification.service";

/**
 * Centralised appointment service.
 * Extracts business logic from doctor.routes.ts.
 */

interface CreateAppointmentInput {
  userAccountId: string;
  doctorId: string;
  slotId: string;
  appointmentTime?: string;
  notes?: string;
}

interface UpdateAppointmentInput {
  status?: "confirmed" | "cancelled" | "completed";
  slotId?: string;
  appointmentTime?: string;
  notes?: string;
}

/**
 * Create a new appointment:
 *   1. Validate slot availability
 *   2. Create appointment record
 *   3. Mark slot as booked
 *   4. Auto-create chat session + send initial message
 *   5. Notify the doctor
 */
export async function createAppointment(input: CreateAppointmentInput) {
  // Validate slot
  const slot = await prisma.slot.findUnique({ where: { id: input.slotId } });
  if (!slot || slot.isBooked || slot.doctorId !== input.doctorId) {
    throw new AppointmentError("INVALID_SLOT", "유효하지 않은 슬롯입니다.");
  }

  // Create appointment
  const appointment = await prisma.appointment.create({
    data: {
      userAccountId: input.userAccountId,
      doctorId: input.doctorId,
      slotId: input.slotId,
      appointmentTime: input.appointmentTime ? new Date(input.appointmentTime) : null,
      notes: input.notes,
    },
    include: {
      slot: true,
      doctor: { include: { clinic: true } },
    },
  });

  // Mark slot as booked
  await prisma.slot.update({
    where: { id: input.slotId },
    data: { isBooked: true },
  });

  // Auto-create chat session + send message (non-critical)
  try {
    const session = await chatService.findOrCreateSession(
      input.userAccountId,
      input.doctorId,
      `${appointment.doctor.name} 한의사님과의 상담`,
    );

    const chatContent = input.notes
      ? `[신규 진료 예약]\n${input.notes}`
      : "[신규 진료 예약] 증상 및 요청사항 없이 예약되었습니다.";

    await chatService.sendMessage(session.id, "user", chatContent);
  } catch (err) {
    logger.error("[AppointmentService] Failed to create chat session/message:", err);
  }

  // Notify doctor (non-critical)
  try {
    const patient = await prisma.userProfile.findFirst({
      where: { account: { id: input.userAccountId } },
    });
    await notificationService.notifyDoctorNewAppointment(
      appointment.doctor.name,
      patient?.name ?? "환자",
      appointment.id,
    );
  } catch (err) {
    logger.error("[AppointmentService] Failed to send notification:", err);
  }

  return appointment;
}

/**
 * Update an existing appointment:
 *   1. Validate ownership
 *   2. Handle slot changes (release old, book new)
 *   3. Update appointment record
 *   4. Send chat messages for changes
 *   5. Handle cancellation (release slot)
 *   6. Notify about status changes
 */
export async function updateAppointment(
  appointmentId: string,
  userAccountId: string,
  input: UpdateAppointmentInput,
) {
  const appointment = await prisma.appointment.findUnique({
    where: { id: appointmentId },
    include: { slot: true, doctor: { include: { clinic: true } } },
  });
  if (!appointment || appointment.userAccountId !== userAccountId) {
    throw new AppointmentError("NOT_FOUND", "예약을 찾을 수 없습니다.");
  }

  // Handle slot change
  if (input.slotId && input.slotId !== appointment.slotId) {
    const newSlot = await prisma.slot.findUnique({ where: { id: input.slotId } });
    if (!newSlot || newSlot.isBooked || newSlot.doctorId !== appointment.doctorId) {
      throw new AppointmentError("INVALID_SLOT", "유효하지 않은 슬롯입니다.");
    }

    await prisma.slot.update({ where: { id: appointment.slotId }, data: { isBooked: false } });
    await prisma.slot.update({ where: { id: input.slotId }, data: { isBooked: true } });
  }

  // Build update payload
  const updateData: Record<string, any> = {};
  if (input.status) updateData.status = input.status;
  if (input.slotId) updateData.slotId = input.slotId;
  if (input.appointmentTime) updateData.appointmentTime = new Date(input.appointmentTime);
  if (input.notes !== undefined) updateData.notes = input.notes;

  const updated = await prisma.appointment.update({
    where: { id: appointmentId },
    data: updateData,
    include: { slot: true, doctor: { include: { clinic: true } } },
  });

  // Chat messages for changes (non-critical)
  try {
    await sendChangeChat(appointment, updated, input, userAccountId);
  } catch (err) {
    logger.error("[AppointmentService] Failed to send chat for update:", err);
  }

  // Handle cancellation → release slot
  if (input.status === "cancelled") {
    await prisma.slot.update({
      where: { id: updated.slotId },
      data: { isBooked: false },
    });
  }

  // Status change notification (non-critical)
  if (input.status) {
    try {
      await notificationService.notifyAppointmentStatusChange(
        appointment.userAccountId,
        updated.id,
        input.status,
        updated.doctor.name,
      );
    } catch (err) {
      logger.error("[AppointmentService] Failed to send status notification:", err);
    }
  }

  return updated;
}

/** Delete appointment and release its slot. */
export async function deleteAppointment(appointmentId: string, userAccountId: string) {
  const appointment = await prisma.appointment.findUnique({
    where: { id: appointmentId },
  });
  if (!appointment || appointment.userAccountId !== userAccountId) {
    throw new AppointmentError("NOT_FOUND", "예약을 찾을 수 없습니다.");
  }

  await prisma.appointment.delete({ where: { id: appointmentId } });
  await prisma.slot.update({
    where: { id: appointment.slotId },
    data: { isBooked: false },
  });
}

// ─── Helpers ──────────────────────────────────────────────────────

async function sendChangeChat(
  old: any,
  updated: any,
  input: UpdateAppointmentInput,
  userAccountId: string,
) {
  if (input.slotId && input.slotId !== old.slotId) {
    // Slot changed — check if doctor also changed
    const newSlot = await prisma.slot.findUnique({ where: { id: input.slotId } });

    if (newSlot && newSlot.doctorId !== old.doctorId) {
      // Doctor changed → delete old chat, create new
      const oldChat = await prisma.chatSession.findFirst({
        where: { userAccountId, doctorId: old.doctorId },
      });
      if (oldChat) {
        await prisma.chatMessage.deleteMany({ where: { sessionId: oldChat.id } });
        await prisma.chatSession.delete({ where: { id: oldChat.id } });
      }

      const newSession = await chatService.findOrCreateSession(
        userAccountId,
        newSlot.doctorId,
        `${updated.doctor.name} 한의사님과의 상담`,
      );
      const content = input.notes
        ? `[신규 진료 예약]\n${input.notes}`
        : "[신규 진료 예약] 증상 및 요청사항 없이 예약되었습니다.";
      await chatService.sendMessage(newSession.id, "user", content);
    } else {
      // Same doctor, slot changed
      const chat = await prisma.chatSession.findFirst({
        where: { userAccountId, doctorId: old.doctorId },
      });
      if (chat) {
        const content = input.notes
          ? `[진료 예약 수정]\n${input.notes}`
          : "[진료 예약 수정] 시간 또는 내용이 변경되었습니다.";
        await chatService.sendMessage(chat.id, "user", content);
      }
    }
  } else if (input.notes !== undefined && input.notes !== old.notes) {
    // Only notes changed
    const chat = await prisma.chatSession.findFirst({
      where: { userAccountId, doctorId: old.doctorId },
    });
    if (chat) {
      await chatService.sendMessage(
        chat.id,
        "user",
        `[진료 예약 수정]\n${input.notes}`,
      );
    }
  }
}

// ─── Error Type ───────────────────────────────────────────────────

export class AppointmentError extends Error {
  constructor(
    public readonly code: string,
    message: string,
  ) {
    super(message);
    this.name = "AppointmentError";
  }
}
