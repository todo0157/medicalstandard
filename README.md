# Hanbang App

Flutter + Node/Prisma stack for the 한방 방문 진료 MVP.

## What changed in ver1.3.9.1
- **배포 환경 우편번호 검색 지원**: Docker 및 배포 환경에서 우편번호 검색 기능이 정상 작동하도록 개선
- **Dockerfile 최적화**: 프로젝트 루트를 build context로 설정하여 Git LFS 파일 자동 다운로드
- **PostalCodeService 경로 개선**: Docker 환경(`/app/search_number`) 경로 추가 및 경로 탐색 로직 개선
- **배포 문서 업데이트**: Render/EC2 배포 시 Git LFS 사용 안내 추가

## What changed in ver1.3.9
- **우편번호 검색 기능**: 로컬 우편번호 DB 통합으로 우편번호 검색 기능 추가
- **PostalCodeService 구현**: TSV 형식 우편번호 파일 파싱 및 검색 서비스 구현
- **타임아웃 설정 최적화**: 우편번호 검색용 30초 타임아웃 추가 (기본 12초)
- **세부 주소 입력**: 주소 선택 후 상세 주소(동/호수 등) 입력 기능 추가
- **에러 처리 개선**: 상세한 에러 로깅 및 디바운싱 로직 개선
- **API 엔드포인트 추가**: `/api/addresses/geocode` 엔드포인트 추가 (주소 문자열로 좌표 조회)

## What changed in ver1.3.8
- **네이버 지도 API 통합**: 주소 검색(Geocoding) 및 역지오코딩(Reverse Geocoding) 기능 추가
- **주소 검색 UI**: 실시간 주소 검색 화면 구현, 디바운싱 및 최소 검색어 길이 제한 적용
- **예약 화면 통합**: 예약 화면에서 주소 선택 및 변경 기능 추가
- **서버 API 엔드포인트**: `/api/addresses/search`, `/api/addresses/reverse` 엔드포인트 구현
- **공식 문서 기준 수정**: 네이버 지도 API 공식 문서에 맞춰 엔드포인트 URL, 헤더, 응답 파싱 수정
- **에러 처리 개선**: API 키 및 Application 설정 관련 상세한 에러 메시지 및 트러블슈팅 가이드 제공

## What changed in ver1.3.7
- Appointment booking 화면이 실제 Doctor/Slot API와 연동되어 동일한 데이터 모델을 사용합니다.
- 실시간 채팅용 WebSocket 게이트웨이(`/ws/chat`)를 추가하고 Flutter 채팅 화면에서 수신 스트림을 사용합니다.
- 프로필 사진 업로드·인증 상태 갱신 API가 추가되었고, 의료진만 진료 기록을 생성할 수 있도록 서버 권한 검증을 강화했습니다.
- 앱/서버 공통 환경 개선: WS URL 자동 추론, Mock 프로필 fallback 제거, 버전 `ver1.3.7`.
- **프로필 저장 버그 수정**: `/profiles/me` 엔드포인트 사용 및 서버 스키마에 맞는 데이터 전송으로 프로필 업데이트가 정상 작동하도록 수정.

## What changed in ver1.3.6
- Added pre-signup email verification flow (precheck token required before signup).
- Added password-reset link from login screen; email links open the reset page.
- Hooked Flutter routes for `/verify-pre`, `/verify-email`, `/reset-password`.
- SendGrid wiring documented; server env keys aligned for local Flutter web.

## Quick start

### Server (Node/Prisma)
```bash
cd server
npm install
npm run db:migrate
npm run build
npm start    # runs on http://localhost:8080
```

**Note**: 우편번호 검색 기능을 사용하려면 `search_number/` 폴더의 우편번호 DB 파일이 필요합니다. 이 파일들은 Git LFS로 관리되므로:

**로컬 개발 환경:**
```bash
git lfs install
git lfs pull
```

**배포 환경:**
- Docker를 사용하는 경우: Dockerfile에 Git LFS 설치 및 pull이 포함되어 있습니다.
- 직접 배포하는 경우: 배포 전에 `git lfs pull`을 실행하여 우편번호 DB 파일을 다운로드하세요.
- 또는 `npm run setup` 명령어를 실행하세요 (자동으로 Git LFS 설치 및 파일 다운로드).

Set `server/.env` (copy from `.env.example`):
- `SENDGRID_API_KEY`, `MAIL_FROM`, `MAIL_FROM_NAME`
- `RESET_LINK_BASE`, `VERIFY_LINK_BASE`, `VERIFY_PRE_LINK_BASE`  
  e.g. for local Flutter web: `http://localhost:5173/reset-password`, `http://localhost:5173/verify-email`, `http://localhost:5173/verify-pre`

### Flutter web
```bash
flutter pub get
flutter run -d chrome --web-port 5173 \
  --dart-define API_BASE_URL=http://localhost:8080/api \
  --dart-define APP_ENV=development \
  --dart-define ENABLE_HTTP_LOGGING=true
```

## Email flows (local)
- **Pre-signup verify:** Login screen “인증” button → `/auth/verify-email/precheck` sends email → click link (opens `/verify-pre?...`) → signup allowed only for that verified email.
- **Post-signup verify resend:** `/auth/verify-email` always sends (even if already verified).
- **Password reset:** Login screen “비밀번호 재설정하기” → `/auth/forgot` email → link opens `/reset-password?...` → submit new password → `/auth/reset`.

## Notes
- Prisma DB stored at `server/prisma/dev.db` by default (SQLite). Update `DATABASE_URL` for Postgres when ready.
- Protects signup server-side: `/auth/signup` returns 400 if the email has not completed precheck.
- Routes for reset/verify/pre-verify are allowed without auth; other app routes still require the token guard.

## ver1.3.7 작업 참고 사항
1. `AppointmentBookingScreen`은 가장 최근 등록된 한의사/슬롯 데이터를 순차로 노출합니다. 지도 기반 탐색이 필요한 경우 `FindDoctorScreen`을 유지하면서 동일 서비스/노티파이어를 공유하도록 확장하세요.
2. 실시간 채팅은 WebSocket 수신 기반입니다. 메시지 송신은 기존 REST API를 사용하며, 서버가 저장하는 즉시 WebSocket으로 push 됩니다.
3. 프로필 사진 업로드는 임시로 Data URL을 DB에 저장합니다. 파일 스토리지 혹은 CDN을 붙일 경우 `profile.routes.ts` 내 업로드 로직을 교체하면 됩니다.
4. **프로필 저장 버그 수정**: `/profiles/me` 엔드포인트 사용 및 서버 스키마에 맞는 데이터 전송으로 프로필 업데이트가 정상 작동하도록 수정.

## 📊 코드베이스 분석 및 개선 계획
상세한 분석과 개선 계획은 [ver1.3.9.1_analysis_and_improvements.md](docs/ver1.3.9.1_analysis_and_improvements.md)를 참고하세요.

## 📱 Android & iOS 환경 배포 계획

### 🎯 MVP 출시 목표

다음 4가지 핵심 기능을 MVP 수준으로 구현하여 Google Play Store와 App Store에 출시:

1. **회원가입 및 한의사 인증**
   - 현재 상태: 기본 회원가입/로그인 완료, 한의사 인증 프로세스 미구현
   - 출시 전 필요 작업: 한의사 인증 신청 UI 및 프로세스 구현

2. **한의사 찾기 및 예약 기능**
   - 현재 상태: ✅ 구현 완료
   - 기능: 위치 기반 검색, 주소 검색, 우편번호 검색, 예약 생성/취소

3. **채팅 화면**
   - 현재 상태: ✅ 구현 완료
   - 기능: WebSocket 기반 실시간 채팅, 메시지 전송/수신

4. **프로필 내 진료 기록 확인 기능**
   - 현재 상태: ✅ 구현 완료
   - 기능: 진료 기록 조회, 진료 기록 생성 (한의사만)

---

### 📋 Android 배포 준비

#### 1. 앱 정보 설정

**필수 변경 사항:**
```kotlin
// android/app/build.gradle.kts
defaultConfig {
    applicationId = "com.medicalstandard.hanbang"  // 실제 패키지명으로 변경
    versionCode = 1  // 첫 출시는 1
    versionName = "1.0.0"
    minSdk = 21  // Android 5.0 이상
    targetSdk = 34  // 최신 Android 버전
}
```

**앱 아이콘 및 스플래시 화면:**
- `android/app/src/main/res/` 폴더에 아이콘 리소스 추가
- 다양한 해상도 지원 (mipmap-hdpi, mipmap-xhdpi, mipmap-xxhdpi, mipmap-xxxhdpi)

#### 2. 서명 키 생성 및 설정

```bash
# 키스토어 생성
keytool -genkey -v -keystore ~/hanbang-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias hanbang

# key.properties 파일 생성 (android/key.properties)
storePassword=<키스토어 비밀번호>
keyPassword=<키 비밀번호>
keyAlias=hanbang
storeFile=<키스토어 파일 경로>
```

**build.gradle.kts 수정:**
```kotlin
// android/app/build.gradle.kts
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

#### 3. 권한 설정

**AndroidManifest.xml 확인:**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

#### 4. 프로덕션 빌드

```bash
# AAB (Android App Bundle) 빌드 (권장)
flutter build appbundle \
  --dart-define APP_ENV=production \
  --dart-define API_BASE_URL=https://api.medicalstandard.dev/api \
  --release

# 또는 APK 빌드
flutter build apk \
  --dart-define APP_ENV=production \
  --dart-define API_BASE_URL=https://api.medicalstandard.dev/api \
  --release \
  --split-per-abi
```

#### 5. Google Play Console 등록

**필수 준비물:**
- Google Play Developer 계정 ($25 일회성 등록비)
- 앱 아이콘 (512x512px)
- 스크린샷 (최소 2개, 권장 8개)
- 앱 설명 (한국어, 영어)
- 개인정보처리방침 URL
- 연락처 정보

**등록 절차:**
1. [Google Play Console](https://play.google.com/console) 접속
2. 새 앱 생성
3. 앱 정보 입력 (이름, 설명, 카테고리 등)
4. 콘텐츠 등급 설정
5. AAB 파일 업로드
6. 스토어 등록 정보 입력
7. 검토 제출

---

### 🍎 iOS 배포 준비

#### 1. 앱 정보 설정

**필수 변경 사항:**
```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleIdentifier</key>
<string>com.medicalstandard.hanbang</string>  <!-- 실제 번들 ID로 변경 -->
<key>CFBundleName</key>
<string>한방</string>
<key>CFBundleDisplayName</key>
<string>한방</string>
```

**Xcode 프로젝트 설정:**
- `ios/Runner.xcodeproj` 열기
- General 탭에서 Bundle Identifier 변경
- Version 및 Build 번호 설정

#### 2. Apple Developer 계정 및 인증서

**필수 준비물:**
- Apple Developer Program 가입 ($99/년)
- App Store Connect 계정 생성
- 인증서 및 프로비저닝 프로파일 생성

**인증서 생성:**
1. [Apple Developer Portal](https://developer.apple.com) 접속
2. Certificates, Identifiers & Profiles 메뉴
3. App ID 생성 (Bundle Identifier와 일치)
4. Distribution Certificate 생성
5. App Store Connect에서 App 생성
6. Provisioning Profile 생성

#### 3. 권한 설정

**Info.plist 권한 설명 추가:**
```xml
<!-- ios/Runner/Info.plist -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>한의사를 찾기 위해 위치 정보가 필요합니다.</string>
<key>NSCameraUsageDescription</key>
<string>프로필 사진을 업로드하기 위해 카메라 접근이 필요합니다.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>프로필 사진을 선택하기 위해 사진 라이브러리 접근이 필요합니다.</string>
```

#### 4. 프로덕션 빌드

```bash
# iOS 빌드 (Xcode 필요)
flutter build ios \
  --dart-define APP_ENV=production \
  --dart-define API_BASE_URL=https://api.medicalstandard.dev/api \
  --release

# Xcode에서 아카이브 및 업로드
# 1. Xcode에서 ios/Runner.xcworkspace 열기
# 2. Product > Archive
# 3. Organizer에서 Distribute App 선택
# 4. App Store Connect 선택
# 5. 업로드 완료
```

**또는 명령줄에서:**
```bash
# IPA 파일 생성 (fastlane 사용 권장)
fastlane ios build
fastlane ios upload
```

#### 5. App Store Connect 등록

**필수 준비물:**
- 앱 아이콘 (1024x1024px, 투명 배경 없음)
- 스크린샷 (iPhone 6.7", 6.5", 5.5" 등 다양한 크기)
- 앱 설명 (한국어, 영어)
- 개인정보처리방침 URL
- 연락처 정보
- 연령 등급 정보

**등록 절차:**
1. [App Store Connect](https://appstoreconnect.apple.com) 접속
2. 새 앱 생성
3. 앱 정보 입력
4. 빌드 선택 (업로드된 빌드)
5. 스토어 등록 정보 입력
6. 검토 제출

---

### ✅ MVP 출시 전 체크리스트

#### 필수 기능 완성도 확인

- [ ] **회원가입 및 한의사 인증**
  - [ ] 기본 회원가입/로그인 테스트 완료
  - [ ] 한의사 인증 신청 UI 구현
  - [ ] 한의사 인증 프로세스 구현 (최소한 기본 워크플로우)
  - [ ] 인증 상태 표시 UI

- [ ] **한의사 찾기 및 예약 기능**
  - [ ] 위치 기반 검색 테스트
  - [ ] 주소 검색 테스트
  - [ ] 예약 생성/취소 테스트
  - [ ] 예약 목록 조회 테스트

- [ ] **채팅 화면**
  - [ ] 실시간 메시지 전송/수신 테스트
  - [ ] WebSocket 연결 안정성 확인
  - [ ] 오프라인 상태 처리

- [ ] **진료 기록 확인 기능**
  - [ ] 진료 기록 조회 테스트
  - [ ] 한의사 진료 기록 생성 테스트
  - [ ] 권한 검증 확인

#### 기술적 준비사항

- [ ] 프로덕션 서버 배포 완료
- [ ] API 엔드포인트 프로덕션 URL 설정
- [ ] 환경 변수 설정 (`APP_ENV=production`)
- [ ] 디버그 로그 비활성화
- [ ] 에러 리포팅 설정 (Sentry, Firebase Crashlytics 등)
- [ ] 분석 도구 연동 (Firebase Analytics, Google Analytics 등)

#### 보안 및 법적 준비사항

- [ ] 개인정보처리방침 작성 및 게시
- [ ] 이용약관 작성 및 게시
- [ ] 서비스 약관 작성
- [ ] API 키 보안 확인 (클라이언트에 노출되지 않도록)
- [ ] 데이터 암호화 확인

#### 스토어 등록 준비사항

- [ ] 앱 아이콘 제작 (Android: 512x512px, iOS: 1024x1024px)
- [ ] 스크린샷 제작 (최소 2개, 권장 8개 이상)
- [ ] 앱 설명 작성 (한국어, 영어)
- [ ] 앱 이름 결정
- [ ] 카테고리 선택
- [ ] 연령 등급 설정
- [ ] 연락처 정보 준비

---

### 🔄 업데이트 계획

#### 버전 관리 전략

**버전 번호 형식:** `MAJOR.MINOR.PATCH+BUILD`
- **MAJOR**: 큰 기능 변경 또는 API 변경
- **MINOR**: 새로운 기능 추가
- **PATCH**: 버그 수정
- **BUILD**: 빌드 번호 (자동 증가)

**예시:**
- 첫 출시: `1.0.0+1`
- 버그 수정: `1.0.1+2`
- 기능 추가: `1.1.0+3`
- 큰 변경: `2.0.0+4`

#### 업데이트 주기 계획

**Phase 1: MVP 출시 (v1.0.0)**
- 목표: 4가지 핵심 기능 완성
- 예상 기간: 2-3주
- 주요 작업: 한의사 인증 프로세스 구현

**Phase 2: 안정화 (v1.0.x)**
- 목표: 버그 수정 및 사용자 피드백 반영
- 예상 기간: 2-4주
- 업데이트 주기: 1-2주마다

**Phase 3: 기능 확장 (v1.1.0+)**
- 목표: 추가 기능 구현
  - 알림 시스템
  - 리뷰 및 평점
  - 예약 관리 강화
- 예상 기간: 4-6주
- 업데이트 주기: 2-3주마다

**Phase 4: 최적화 (v1.2.0+)**
- 목표: 성능 최적화 및 UX 개선
- 예상 기간: 2-3주
- 업데이트 주기: 필요시

#### 업데이트 프로세스

1. **개발 및 테스트**
   ```bash
   # 개발 환경에서 테스트
   flutter run --dart-define APP_ENV=staging
   
   # 스테이징 서버에서 테스트
   flutter run --dart-define APP_ENV=staging \
     --dart-define API_BASE_URL=https://staging.api.medicalstandard.dev/api
   ```

2. **프로덕션 빌드**
   ```bash
   # Android
   flutter build appbundle --dart-define APP_ENV=production
   
   # iOS
   flutter build ios --dart-define APP_ENV=production
   ```

3. **스토어 업로드**
   - Android: Google Play Console에서 AAB 업로드
   - iOS: App Store Connect에서 빌드 업로드

4. **검토 대기**
   - Android: 보통 1-3일
   - iOS: 보통 1-7일

5. **출시**
   - 단계적 출시 (10% → 50% → 100%) 권장
   - 문제 발견 시 즉시 롤백 가능

---

### 📝 참고 자료

- [Flutter 공식 배포 가이드](https://docs.flutter.dev/deployment)
- [Google Play Console 가이드](https://support.google.com/googleplay/android-developer)
- [App Store Connect 가이드](https://developer.apple.com/app-store-connect/)
- [Android 서명 가이드](https://docs.flutter.dev/deployment/android#signing-the-app)
- [iOS 배포 가이드](https://docs.flutter.dev/deployment/ios)

---

### ⚠️ 주의사항

1. **패키지명/번들 ID 변경**: 현재 `com.example.hanbang_app`는 예시용이므로 실제 배포 전 반드시 변경 필요
2. **API 키 보안**: 클라이언트에 노출되는 API 키는 최소화하고, 가능한 한 서버를 통해 프록시
3. **개인정보 보호**: 위치 정보, 프로필 사진 등 개인정보 처리 시 개인정보처리방침에 명시
4. **테스트**: 실제 기기에서 충분한 테스트 후 출시
5. **백업 계획**: 서버 장애 시 대응 방안 마련

---

**목표 출시일**: MVP 기능 완성 후 2-3주 내 (스토어 검토 기간 포함)
