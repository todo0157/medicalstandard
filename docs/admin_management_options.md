# MVP 출시 후 관리자 인증 승인/거부 방법

## 현재 상태

✅ **관리자 API**: 서버 측 API는 완전히 구현됨
❌ **관리자 UI**: Flutter 앱에 관리자 화면이 없음
⚠️ **현재 방법**: PowerShell 스크립트로만 테스트 가능 (개발 환경용)

---

## 실제 출시 시 옵션

### 옵션 1: Flutter 앱 내 관리자 화면 추가 (권장) ⭐

**장점:**
- 관리자가 모바일 앱에서 바로 승인/거부 가능
- 사용자 친화적 UI/UX
- 이미지 확인, 상세 정보 조회 등 모든 기능을 앱에서 처리
- 오프라인 지원 가능 (나중에)

**구현 필요 사항:**
1. 관리자 권한 체크 로직 (서버에서 사용자 이메일 확인)
2. 관리자 전용 화면 (`AdminDashboardScreen`)
3. 인증 신청 목록 화면
4. 인증 상세 조회 및 이미지 확인 화면
5. 승인/거부 기능

**예상 개발 시간:** 2-3일

---

### 옵션 2: 별도의 관리자 웹 대시보드 구축

**장점:**
- PC에서 더 편리하게 작업 가능
- 대량 처리에 유리
- 더 복잡한 관리 기능 추가 용이

**단점:**
- 별도 웹 앱 개발 필요
- 모바일 앱과 별도로 배포/관리 필요

**구현 필요 사항:**
1. React/Vue 등으로 웹 대시보드 구축
2. 관리자 로그인 화면
3. 인증 신청 목록 및 상세 화면
4. 승인/거부 기능

**예상 개발 시간:** 3-5일

---

### 옵션 3: Postman/Insomnia 등 API 클라이언트 사용 (임시)

**장점:**
- 즉시 사용 가능
- 추가 개발 불필요

**단점:**
- 기술적 지식 필요
- 사용자 친화적이지 않음
- 이미지 확인이 불편함
- 프로덕션 환경에 부적합

**사용 방법:**
1. Postman에 관리자 API 엔드포인트 등록
2. 로그인하여 토큰 획득
3. 인증 신청 목록 조회
4. 승인/거부 API 호출

---

### 옵션 4: 간단한 관리자 웹 페이지 (최소 구현)

**장점:**
- 빠른 구현 가능 (1-2일)
- 모바일/PC 모두 접근 가능
- 이미지 확인 용이

**구현 방법:**
- HTML + JavaScript로 간단한 관리자 페이지
- 서버의 정적 파일로 제공하거나 별도 호스팅

---

## 추천 방안: 옵션 1 (Flutter 앱 내 관리자 화면)

MVP 출시를 위해서는 **옵션 1**을 추천합니다.

### 구현 계획

#### 1단계: 관리자 권한 체크

```dart
// lib/core/services/admin_service.dart
class AdminService {
  Future<bool> checkIsAdmin() async {
    // 서버에서 현재 사용자가 관리자인지 확인
    // 또는 로컬에서 이메일 확인
  }
}
```

#### 2단계: 관리자 화면 추가

```
lib/features/admin/
  ├── screens/
  │   ├── admin_dashboard_screen.dart      # 관리자 대시보드
  │   ├── certification_list_screen.dart   # 인증 신청 목록
  │   └── certification_detail_screen.dart # 인증 상세 조회
  ├── providers/
  │   └── admin_providers.dart
  └── services/
      └── admin_service.dart
```

#### 3단계: 프로필 화면에 관리자 메뉴 추가

관리자 계정으로 로그인 시 프로필 화면에 "관리자 대시보드" 메뉴 표시

---

## 즉시 사용 가능한 방법 (임시)

출시 전까지는 다음 방법을 사용할 수 있습니다:

### 방법 A: Postman Collection 사용

1. Postman 설치
2. 다음 API 엔드포인트를 Collection으로 등록:
   - `POST /api/auth/login` (로그인)
   - `GET /api/admin/certifications?status=pending` (목록 조회)
   - `GET /api/admin/certifications/:profileId` (상세 조회)
   - `POST /api/admin/certifications/:profileId/approve` (승인)
   - `POST /api/admin/certifications/:profileId/reject` (거부)

### 방법 B: 간단한 HTML 페이지

서버에 정적 HTML 파일을 추가하여 간단한 관리자 인터페이스 제공

---

## 다음 단계

1. **즉시 필요**: 옵션 3 또는 4로 임시 관리 도구 구축
2. **MVP 출시 전**: 옵션 1 (Flutter 앱 내 관리자 화면) 구현
3. **장기 계획**: 옵션 2 (전문 관리자 웹 대시보드) 고려

---

## 참고 문서

- [관리자 API 가이드](./admin_api_guide.md)
- [관리자 API 테스트 가이드](./admin_api_test_guide.md)


