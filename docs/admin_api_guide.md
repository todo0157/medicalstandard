# 관리자 API 사용 가이드

## 개요

한의사 인증 승인/거부를 위한 관리자 전용 API입니다.

## 설정 방법

### 1. 환경변수 설정

`server/.env` 파일에 관리자 이메일을 추가하세요:

```env
ADMIN_EMAILS=admin@example.com,admin2@example.com
```

여러 관리자가 있는 경우 쉼표로 구분합니다.

### 2. 서버 재시작

환경변수를 변경한 후 서버를 재시작하세요:

```bash
cd server
npm start
```

## API 엔드포인트

모든 관리자 API는 `/api/admin` 경로로 시작하며, 인증 토큰과 관리자 권한이 필요합니다.

### 1. 인증 신청 목록 조회

**GET** `/api/admin/certifications`

대기 중인 한의사 인증 신청 목록을 조회합니다.

**Query Parameters:**
- `status` (optional): `pending`, `verified`, `all` (기본값: `pending`)
- `page` (optional): 페이지 번호 (기본값: `1`)
- `limit` (optional): 페이지당 항목 수 (기본값: `20`)

**예시:**
```bash
curl -X GET "http://localhost:8080/api/admin/certifications?status=pending" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

**응답:**
```json
{
  "data": [
    {
      "id": "profile_123",
      "name": "홍길동",
      "email": "hong@example.com",
      "certificationStatus": "pending",
      "isPractitioner": false,
      "licenseNumber": "한의-12345",
      "clinicName": "한방 건강 클리닉",
      "createdAt": "2025-12-19T01:00:00.000Z",
      "updatedAt": "2025-12-19T01:00:00.000Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 1,
    "totalPages": 1
  }
}
```

### 2. 인증 신청 상세 조회

**GET** `/api/admin/certifications/:profileId`

특정 프로필의 인증 정보를 상세 조회합니다.

**예시:**
```bash
curl -X GET "http://localhost:8080/api/admin/certifications/profile_123" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

**응답:**
```json
{
  "data": {
    "id": "profile_123",
    "name": "홍길동",
    "email": "hong@example.com",
    "age": 35,
    "gender": "male",
    "address": "서울시 강남구",
    "phoneNumber": "010-1234-5678",
    "certificationStatus": "pending",
    "isPractitioner": false,
    "licenseNumber": "한의-12345",
    "clinicName": "한방 건강 클리닉",
    "profileImageUrl": "data:image/jpeg;base64,...", // 자격증 이미지
    "createdAt": "2025-12-19T01:00:00.000Z",
    "updatedAt": "2025-12-19T01:00:00.000Z"
  }
}
```

### 3. 인증 승인

**POST** `/api/admin/certifications/:profileId/approve`

한의사 인증을 승인합니다.

**Request Body:**
```json
{
  "notes": "자격증 확인 완료" // 선택사항
}
```

**예시:**
```bash
curl -X POST "http://localhost:8080/api/admin/certifications/profile_123/approve" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"notes": "자격증 확인 완료"}'
```

**응답:**
```json
{
  "data": {
    "id": "profile_123",
    "certificationStatus": "verified",
    "isPractitioner": true,
    ...
  },
  "message": "인증이 승인되었습니다."
}
```

**동작:**
- `certificationStatus`를 `verified`로 변경
- `isPractitioner`를 `true`로 설정

### 4. 인증 거부

**POST** `/api/admin/certifications/:profileId/reject`

한의사 인증을 거부합니다.

**Request Body:**
```json
{
  "reason": "자격증 번호가 일치하지 않습니다.", // 필수
  "notes": "추가 메모" // 선택사항
}
```

**예시:**
```bash
curl -X POST "http://localhost:8080/api/admin/certifications/profile_123/reject" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"reason": "자격증 번호가 일치하지 않습니다."}'
```

**응답:**
```json
{
  "data": {
    "id": "profile_123",
    "certificationStatus": "none",
    "isPractitioner": false,
    ...
  },
  "message": "인증이 거부되었습니다.",
  "reason": "자격증 번호가 일치하지 않습니다."
}
```

**동작:**
- `certificationStatus`를 `none`으로 변경
- `isPractitioner`를 `false`로 유지

## 테스트 방법

### 1. 관리자 계정으로 로그인

관리자 이메일로 로그인하여 토큰을 받습니다:

```bash
curl -X POST "http://localhost:8080/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@example.com", "password": "your_password"}'
```

### 2. 인증 신청 목록 확인

```bash
curl -X GET "http://localhost:8080/api/admin/certifications" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

### 3. 인증 승인

```bash
curl -X POST "http://localhost:8080/api/admin/certifications/PROFILE_ID/approve" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{}'
```

## 주의사항

1. **관리자 이메일 설정 필수**: `ADMIN_EMAILS` 환경변수가 설정되지 않으면 관리자 API를 사용할 수 없습니다.

2. **인증 토큰 필요**: 모든 API 요청에 `Authorization: Bearer TOKEN` 헤더가 필요합니다.

3. **관리자 권한 확인**: 관리자 이메일 목록에 포함된 사용자만 접근 가능합니다.

4. **상태 확인**: 승인/거부는 `pending` 상태의 인증 신청에만 가능합니다.

## 향후 개선 사항

- 관리자 대시보드 UI 구현
- 알림 시스템 연동 (승인/거부 시 사용자에게 알림)
- 거부 사유를 사용자에게 전달하는 기능
- 인증 이력 조회 기능


