# 관리자 웹 대시보드 구현 계획

## 📋 개요

별도의 관리자 웹 대시보드를 구축하여 한의사 인증 승인/거부를 관리합니다.

---

## 🎯 목표

1. **관리자 전용 웹 대시보드** 구축
2. **인증 신청 목록 조회** 기능
3. **인증 상세 정보 및 이미지 확인** 기능
4. **승인/거부** 기능
5. **간단하고 직관적인 UI/UX**

---

## 🛠 기술 스택

### 옵션 A: React + Vite (권장) ⭐

**장점:**
- 빠른 개발 환경 (Vite)
- 현대적인 React 개발 경험
- 좋은 확장성
- 컴포넌트 재사용 용이

**단점:**
- Node.js 의존성
- 빌드 과정 필요

**예상 개발 시간:** 3-4일

### 옵션 B: 순수 HTML + JavaScript + Tailwind CSS

**장점:**
- 즉시 시작 가능
- 빌드 과정 없음
- 빠른 구현 (1-2일)
- 서버에 바로 통합 가능

**단점:**
- 확장성 낮음
- 코드 관리가 어려울 수 있음

**예상 개발 시간:** 1-2일

### 옵션 C: Next.js

**장점:**
- SSR 지원
- 배포 용이
- 좋은 성능

**단점:**
- 더 복잡한 설정
- 오버엔지니어링 가능

**예상 개발 시간:** 4-5일

---

## 📁 프로젝트 구조

### 옵션 A (React + Vite) 구조:

```
medicalstandard/
├── admin-dashboard/          # 새 폴더
│   ├── public/
│   │   └── index.html
│   ├── src/
│   │   ├── components/
│   │   │   ├── LoginForm.tsx
│   │   │   ├── CertificationList.tsx
│   │   │   ├── CertificationDetail.tsx
│   │   │   └── ImageViewer.tsx
│   │   ├── services/
│   │   │   └── api.ts
│   │   ├── hooks/
│   │   │   └── useAuth.ts
│   │   ├── App.tsx
│   │   └── main.tsx
│   ├── package.json
│   ├── vite.config.ts
│   └── tsconfig.json
└── server/
    └── src/
        └── server.ts          # 정적 파일 서빙 추가
```

### 옵션 B (순수 HTML) 구조:

```
medicalstandard/
└── server/
    └── public/
        └── admin/
            ├── index.html
            ├── login.html
            ├── dashboard.html
            ├── detail.html
            ├── css/
            │   └── style.css
            ├── js/
            │   ├── api.js
            │   ├── auth.js
            │   └── app.js
            └── assets/
```

---

## 🚀 구현 단계

### Phase 1: 프로젝트 설정 (1일)

#### 1.1 프로젝트 생성
- React + Vite 프로젝트 생성 또는 HTML 구조 생성
- 필요한 의존성 설치

#### 1.2 서버 설정
- Express 서버에 정적 파일 서빙 추가
- 관리자 대시보드 라우트 설정
- CORS 설정 확인

#### 1.3 기본 구조
- 폴더 구조 생성
- 기본 컴포넌트/페이지 생성

---

### Phase 2: 인증 시스템 (0.5일)

#### 2.1 로그인 화면
- 이메일/비밀번호 입력 폼
- 로그인 API 연동
- 토큰 저장 (localStorage)

#### 2.2 인증 상태 관리
- 토큰 검증
- 자동 로그아웃 (토큰 만료 시)
- 보호된 라우트

---

### Phase 3: 인증 신청 목록 (1일)

#### 3.1 목록 화면
- 인증 신청 목록 표시
- 상태 필터링 (pending, verified, all)
- 페이지네이션
- 검색 기능 (선택)

#### 3.2 API 연동
- `GET /api/admin/certifications` 연동
- 상태별 필터링
- 페이지네이션 처리

---

### Phase 4: 상세 조회 및 이미지 확인 (1일)

#### 4.1 상세 화면
- 프로필 정보 표시
- 자격증 번호, 클리닉 이름
- 신청 일시

#### 4.2 이미지 뷰어
- 자격증 이미지 표시
- 신분증 이미지 표시 (있는 경우)
- 이미지 확대/축소 기능
- 모바일 반응형

---

### Phase 5: 승인/거부 기능 (0.5일)

#### 5.1 승인 기능
- 승인 버튼
- 승인 메모 입력 (선택)
- 승인 API 호출
- 성공/실패 피드백

#### 5.2 거부 기능
- 거부 버튼
- 거부 사유 입력 (필수)
- 거부 메모 입력 (선택)
- 거부 API 호출
- 성공/실패 피드백

---

### Phase 6: UI/UX 개선 (0.5일)

#### 6.1 스타일링
- 깔끔한 디자인
- 반응형 레이아웃
- 로딩 상태 표시
- 에러 처리

#### 6.2 사용자 경험
- 성공/실패 알림
- 확인 다이얼로그
- 자동 새로고침 (선택)

---

## 🔧 기술적 세부사항

### API 엔드포인트

1. **로그인**
   - `POST /api/auth/login`
   - Body: `{ email, password }`
   - Response: `{ data: { token, refreshToken } }`

2. **인증 신청 목록**
   - `GET /api/admin/certifications?status=pending&page=1&limit=20`
   - Headers: `Authorization: Bearer {token}`
   - Response: `{ data: [...], pagination: {...} }`

3. **인증 상세 조회**
   - `GET /api/admin/certifications/:profileId`
   - Headers: `Authorization: Bearer {token}`
   - Response: `{ data: {...} }`

4. **승인**
   - `POST /api/admin/certifications/:profileId/approve`
   - Headers: `Authorization: Bearer {token}`
   - Body: `{ notes?: string }`

5. **거부**
   - `POST /api/admin/certifications/:profileId/reject`
   - Headers: `Authorization: Bearer {token}`
   - Body: `{ reason: string, notes?: string }`

---

### 서버 설정

#### Express 정적 파일 서빙 추가

```typescript
// server/src/server.ts
import path from 'path';

// 관리자 대시보드 정적 파일 서빙
if (env.NODE_ENV === 'production') {
  app.use('/admin', express.static(path.join(__dirname, '../../admin-dashboard/dist')));
} else {
  // 개발 환경에서는 Vite dev server 사용 또는 프록시
}
```

---

### 보안 고려사항

1. **인증 토큰 관리**
   - localStorage에 저장 (XSS 주의)
   - 토큰 만료 시 자동 로그아웃
   - HTTPS 필수 (프로덕션)

2. **관리자 권한 확인**
   - 서버에서 이미 구현됨 (`requireAdmin` 미들웨어)
   - 클라이언트에서는 UI만 숨김 처리

3. **CORS 설정**
   - 관리자 대시보드 도메인만 허용
   - 개발 환경에서는 localhost 허용

---

## 📦 배포 방법

### 개발 환경

1. **React + Vite:**
   ```bash
   cd admin-dashboard
   npm run dev
   # Vite dev server가 별도 포트에서 실행
   ```

2. **순수 HTML:**
   - 서버의 `public/admin/` 폴더에 배치
   - `http://localhost:8080/admin/` 접근

### 프로덕션 환경

1. **빌드**
   ```bash
   cd admin-dashboard
   npm run build
   ```

2. **서버에 배치**
   - 빌드된 파일을 서버의 `public/admin/` 또는 `dist/` 폴더에 복사
   - Express에서 정적 파일로 서빙

3. **도메인 설정**
   - `https://admin.yourdomain.com` (서브도메인)
   - 또는 `https://yourdomain.com/admin` (경로)

---

## 🎨 UI 디자인 컨셉

### 색상
- **Primary**: 진한 파란색 (#1e40af)
- **Success**: 초록색 (#10b981)
- **Warning**: 노란색 (#f59e0b)
- **Danger**: 빨간색 (#ef4444)
- **Background**: 밝은 회색 (#f9fafb)

### 레이아웃
- **헤더**: 로고, 사용자 정보, 로그아웃 버튼
- **사이드바**: 메뉴 (선택)
- **메인 콘텐츠**: 인증 신청 목록/상세
- **푸터**: 간단한 정보

---

## ✅ 체크리스트

### 필수 기능
- [ ] 로그인 화면
- [ ] 인증 신청 목록 조회
- [ ] 인증 상세 조회
- [ ] 자격증 이미지 확인
- [ ] 승인 기능
- [ ] 거부 기능
- [ ] 상태 필터링
- [ ] 페이지네이션

### 선택 기능
- [ ] 검색 기능
- [ ] 정렬 기능
- [ ] 일괄 처리
- [ ] 통계 대시보드
- [ ] 알림 기능

---

## 📝 다음 단계

1. **기술 스택 선택** (React + Vite vs 순수 HTML)
2. **프로젝트 생성 및 기본 설정**
3. **단계별 구현 시작**

---

## 💡 추천

**MVP를 빠르게 출시하려면:** 옵션 B (순수 HTML + JavaScript)
**장기적으로 확장 가능한 솔루션:** 옵션 A (React + Vite)

어떤 옵션으로 진행할지 결정해주시면 바로 구현을 시작하겠습니다!


