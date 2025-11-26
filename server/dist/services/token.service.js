"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.issuePasswordResetToken = issuePasswordResetToken;
exports.consumePasswordResetToken = consumePasswordResetToken;
exports.issueEmailVerificationToken = issueEmailVerificationToken;
exports.consumeEmailVerificationToken = consumeEmailVerificationToken;
exports.issuePreSignupVerificationToken = issuePreSignupVerificationToken;
exports.consumePreSignupVerificationToken = consumePreSignupVerificationToken;
const prisma_1 = require("../lib/prisma");
const date_fns_1 = require("date-fns");
const crypto_1 = require("crypto");
const RESET_TTL_MIN = 30;
const VERIFY_TTL_MIN = 60;
const PRE_VERIFY_TTL_MIN = 30;
function generateToken(lengthBytes = 48) {
    return (0, crypto_1.randomBytes)(lengthBytes).toString('hex');
}
async function issuePasswordResetToken(userAccountId) {
    const token = generateToken();
    const expiresAt = (0, date_fns_1.addMinutes)(new Date(), RESET_TTL_MIN);
    await prisma_1.prisma.passwordResetToken.create({
        data: { token, userAccountId, expiresAt },
    });
    return { token, expiresAt };
}
async function consumePasswordResetToken(token) {
    const record = await prisma_1.prisma.passwordResetToken.findUnique({
        where: { token },
    });
    if (!record || record.used || record.expiresAt < new Date()) {
        return null;
    }
    await prisma_1.prisma.passwordResetToken.update({
        where: { id: record.id },
        data: { used: true },
    });
    return record.userAccountId;
}
async function issueEmailVerificationToken(userAccountId) {
    const token = generateToken();
    const expiresAt = (0, date_fns_1.addMinutes)(new Date(), VERIFY_TTL_MIN);
    await prisma_1.prisma.emailVerificationToken.create({
        data: { token, userAccountId, expiresAt },
    });
    return { token, expiresAt };
}
async function consumeEmailVerificationToken(token) {
    const record = await prisma_1.prisma.emailVerificationToken.findUnique({
        where: { token },
    });
    if (!record || record.used || record.expiresAt < new Date()) {
        return null;
    }
    await prisma_1.prisma.emailVerificationToken.update({
        where: { id: record.id },
        data: { used: true },
    });
    return record.userAccountId;
}
async function issuePreSignupVerificationToken(email) {
    const token = generateToken();
    const expiresAt = (0, date_fns_1.addMinutes)(new Date(), PRE_VERIFY_TTL_MIN);
    await prisma_1.prisma.preSignupEmailToken.create({
        data: { token, email, expiresAt },
    });
    return { token, expiresAt };
}
async function consumePreSignupVerificationToken(token) {
    const record = await prisma_1.prisma.preSignupEmailToken.findUnique({
        where: { token },
    });
    if (!record || record.used || record.expiresAt < new Date()) {
        return null;
    }
    await prisma_1.prisma.preSignupEmailToken.update({
        where: { id: record.id },
        data: { used: true },
    });
    return record.email;
}
