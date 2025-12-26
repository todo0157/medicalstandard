import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { v4 as uuidv4 } from 'uuid';

// 환경 변수 검증
const AWS_ACCESS_KEY_ID = process.env.AWS_ACCESS_KEY_ID;
const AWS_SECRET_ACCESS_KEY = process.env.AWS_SECRET_ACCESS_KEY;
const AWS_REGION = process.env.AWS_REGION;
const AWS_BUCKET_NAME = process.env.AWS_BUCKET_NAME;

if (!AWS_ACCESS_KEY_ID || !AWS_SECRET_ACCESS_KEY || !AWS_REGION || !AWS_BUCKET_NAME) {
  console.warn('⚠️ AWS S3 configuration is missing. Image upload will fail.');
}

// S3 클라이언트 초기화
const s3Client = new S3Client({
  region: AWS_REGION,
  credentials: {
    accessKeyId: AWS_ACCESS_KEY_ID || '',
    secretAccessKey: AWS_SECRET_ACCESS_KEY || '',
  },
});

/**
 * Base64 이미지 데이터를 S3에 업로드하고 Public URL을 반환합니다.
 * @param base64Data Base64 인코딩된 이미지 문자열 (Data URL 형식 포함 가능)
 * @param folderPath S3 내 저장할 폴더 경로 (예: 'profiles', 'certifications')
 * @returns 업로드된 이미지의 Public URL
 */
export async function uploadImageToS3(base64Data: string, folderPath: string = 'images'): Promise<string> {
  try {
    // 1. Data URL 헤더 제거 및 Buffer 변환
    // 예: "data:image/png;base64,iVBORw0KGgo..." -> "iVBORw0KGgo..."
    const matches = base64Data.match(/^data:image\/([a-zA-Z0-9]+);base64,(.+)$/);
    
    let buffer: Buffer;
    let contentType: string;
    let extension: string;

    if (matches && matches.length === 3) {
      // Data URL 형식이 맞는 경우
      const type = matches[1];
      const data = matches[2];
      
      contentType = `image/${type}`;
      extension = type === 'jpeg' ? 'jpg' : type;
      buffer = Buffer.from(data, 'base64');
    } else {
      // 순수 Base64 문자열인 경우 (기본값 png로 가정하거나 헤더 탐지 필요하지만 여기선 간단히 처리)
      // 기존 코드들이 png 위주이므로 png로 가정
      contentType = 'image/png';
      extension = 'png';
      // 혹시 모를 헤더 제거 시도
      const cleanBase64 = base64Data.replace(/^data:image\/\w+;base64,/, '');
      buffer = Buffer.from(cleanBase64, 'base64');
    }

    // 2. 고유 파일명 생성
    const fileName = `${uuidv4()}.${extension}`;
    const key = `${folderPath}/${fileName}`;

    // 3. S3 업로드
    const command = new PutObjectCommand({
      Bucket: AWS_BUCKET_NAME,
      Key: key,
      Body: buffer,
      ContentType: contentType,
      // ACL: 'public-read', // 버킷 정책으로 public read를 허용했으므로 ACL은 생략 가능 (오히려 ACL 비활성화된 버킷에선 에러 유발)
    });

    await s3Client.send(command);

    // 4. URL 생성
    const url = `https://${AWS_BUCKET_NAME}.s3.${AWS_REGION}.amazonaws.com/${key}`;
    console.log(`[S3 Upload] Success: ${url}`);
    
    return url;
  } catch (error) {
    console.error('[S3 Upload] Error:', error);
    throw new Error('Failed to upload image to storage');
  }
}

/**
 * URL이 S3 URL인지 확인합니다.
 */
export function isS3Url(url: string): boolean {
  return url.includes('.s3.') && url.includes('.amazonaws.com');
}
