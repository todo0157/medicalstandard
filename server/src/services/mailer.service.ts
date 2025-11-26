import sgMail from '@sendgrid/mail';
import { env } from '../config';

const apiKey = env.SENDGRID_API_KEY;
const mailFrom = env.MAIL_FROM;
const mailFromName = env.MAIL_FROM_NAME || 'Hanbang App';

if (apiKey && mailFrom) {
  sgMail.setApiKey(apiKey);
}

export async function sendMail(params: {
  to: string;
  subject: string;
  html: string;
  text?: string;
}) {
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
    await sgMail.send(msg);
    console.info('[Mailer] sent to', params.to, 'subject:', params.subject);
  } catch (error) {
    console.error('[Mailer] failed to send', params.to, 'reason:', error);
    throw error;
  }
}
