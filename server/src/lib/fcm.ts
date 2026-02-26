import * as admin from 'firebase-admin';
import path from 'path';
import { logger } from './logger';

// 서비스 계정 키 파일 경로
// .gitignore에 추가된 파일이어야 함
const SERVICE_ACCOUNT_PATH = path.join(__dirname, '../../firebase-service-account.json');

let isInitialized = false;

export function initFirebase() {
  if (isInitialized) return;

  try {
    // 이미 초기화되었는지 확인 (중복 초기화 방지)
    if (admin.apps.length > 0) {
      isInitialized = true;
      return;
    }

    // 서비스 계정 파일이 존재하는지 확인
    // 실제 배포 환경에서는 환경변수로 처리하거나 파일 존재 여부를 체크해야 함
    // 여기서는 로컬 개발 환경을 가정하고 파일 로드 시도
    const serviceAccount = require(SERVICE_ACCOUNT_PATH);

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });

    isInitialized = true;
    logger.info('[FCM] Firebase Admin Initialized successfully.');
  } catch (error) {
    logger.error('[FCM] Firebase initialization failed:', error);
    // 파일이 없거나 키가 잘못된 경우 등 초기화 실패 시 알림 기능만 비활성화됨
  }
}

export type NotificationPayload = {
  title: string;
  body: string;
  data?: { [key: string]: string }; // 추가 데이터 (화면 이동 정보 등)
};

/**
 * 단일 기기로 알림 전송
 */
export async function sendPushNotification(token: string, payload: NotificationPayload) {
  if (!isInitialized) {
    logger.warn('[FCM] Firebase not initialized. Skipping notification.');
    return;
  }

  try {
    const message: admin.messaging.Message = {
      token: token,
      notification: {
        title: payload.title,
        body: payload.body,
      },
      data: payload.data,
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          channelId: 'high_importance_channel', // 앱에서 설정한 채널 ID와 일치해야 함
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            contentAvailable: true,
          },
        },
      },
    };

    const response = await admin.messaging().send(message);
    logger.info('[FCM] Successfully sent message:', response);
    return response;
  } catch (error) {
    logger.error('[FCM] Error sending message:', error);
    // 유효하지 않은 토큰일 경우 처리 필요 (DB에서 삭제 등)
    if ((error as any).code === 'messaging/registration-token-not-registered') {
      logger.warn('[FCM] Token is no longer valid:', token);
      // TODO: 호출부에서 토큰 삭제 처리 콜백 등을 고려할 수 있음
    }
    throw error;
  }
}

/**
 * 여러 기기로 알림 전송 (Multicast)
 */
export async function sendMulticastNotification(tokens: string[], payload: NotificationPayload) {
  if (!isInitialized) {
    logger.warn('[FCM] Firebase not initialized. Skipping notification.');
    return;
  }

  if (tokens.length === 0) return;

  try {
    const message: admin.messaging.MulticastMessage = {
      tokens: tokens,
      notification: {
        title: payload.title,
        body: payload.body,
      },
      data: payload.data,
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          channelId: 'high_importance_channel',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            contentAvailable: true,
          },
        },
      },
    };

    const response = await admin.messaging().sendEachForMulticast(message);
    logger.info(`[FCM] Sent ${response.successCount} messages, ${response.failureCount} failed.`);

    // 실패한 토큰 처리 (유효하지 않은 토큰 제거용)
    const failedTokens: string[] = [];
    if (response.failureCount > 0) {
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          const errCode = resp.error?.code;
          if (errCode === 'messaging/registration-token-not-registered' || errCode === 'messaging/invalid-argument') {
            failedTokens.push(tokens[idx]);
          }
        }
      });
    }

    return { successCount: response.successCount, failedTokens };
  } catch (error) {
    logger.error('[FCM] Error sending multicast message:', error);
    throw error;
  }
}

