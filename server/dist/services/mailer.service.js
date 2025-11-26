"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendMail = sendMail;
const mail_1 = __importDefault(require("@sendgrid/mail"));
const config_1 = require("../config");
const apiKey = config_1.env.SENDGRID_API_KEY;
const mailFrom = config_1.env.MAIL_FROM;
const mailFromName = config_1.env.MAIL_FROM_NAME || 'Hanbang App';
if (apiKey && mailFrom) {
    mail_1.default.setApiKey(apiKey);
}
async function sendMail(params) {
    if (!apiKey || !mailFrom) {
        throw new Error('Email service not configured');
    }
    const msg = {
        to: params.to,
        from: { email: mailFrom, name: mailFromName },
        subject: params.subject,
        text: params.text ?? '',
        html: params.html,
    };
    try {
        await mail_1.default.send(msg);
        console.info('[Mailer] sent to', params.to, 'subject:', params.subject);
    }
    catch (error) {
        console.error('[Mailer] failed to send', params.to, 'reason:', error);
        throw error;
    }
}
