import { prisma } from '../lib/prisma';
import { addMinutes } from 'date-fns';
import { randomBytes } from 'crypto';

const RESET_TTL_MIN = 30;
const VERIFY_TTL_MIN = 60;
const PRE_VERIFY_TTL_MIN = 30;

function generateToken(lengthBytes = 48) {
  return randomBytes(lengthBytes).toString('hex');
}

export async function issuePasswordResetToken(userAccountId: string) {
  const token = generateToken();
  const expiresAt = addMinutes(new Date(), RESET_TTL_MIN);
  await prisma.passwordResetToken.create({
    data: { token, userAccountId, expiresAt },
  });
  return { token, expiresAt };
}

export async function consumePasswordResetToken(token: string) {
  const record = await prisma.passwordResetToken.findUnique({
    where: { token },
  });
  if (!record || record.used || record.expiresAt < new Date()) {
    return null;
  }
  await prisma.passwordResetToken.update({
    where: { id: record.id },
    data: { used: true },
  });
  return record.userAccountId;
}

export async function issueEmailVerificationToken(userAccountId: string) {
  const token = generateToken();
  const expiresAt = addMinutes(new Date(), VERIFY_TTL_MIN);
  await prisma.emailVerificationToken.create({
    data: { token, userAccountId, expiresAt },
  });
  return { token, expiresAt };
}

export async function consumeEmailVerificationToken(token: string) {
  const record = await prisma.emailVerificationToken.findUnique({
    where: { token },
  });
  if (!record || record.used || record.expiresAt < new Date()) {
    return null;
  }
  await prisma.emailVerificationToken.update({
    where: { id: record.id },
    data: { used: true },
  });
  return record.userAccountId;
}

export async function issuePreSignupVerificationToken(email: string) {
  const token = generateToken();
  const expiresAt = addMinutes(new Date(), PRE_VERIFY_TTL_MIN);
  await prisma.preSignupEmailToken.create({
    data: { token, email, expiresAt },
  });
  return { token, expiresAt };
}

export async function consumePreSignupVerificationToken(token: string) {
  const record = await prisma.preSignupEmailToken.findUnique({
    where: { token },
  });
  if (!record || record.used || record.expiresAt < new Date()) {
    return null;
  }
  await prisma.preSignupEmailToken.update({
    where: { id: record.id },
    data: { used: true },
  });
  return record.email;
}
