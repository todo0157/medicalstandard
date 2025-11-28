# 네이버 지도 API Web 서비스 URL 설정 가이드

## 🔍 Web 서비스 URL이란?

네이버 클라우드 플랫폼의 Maps API Application 설정에서 **"Web 서비스 URL"**은:
- **클라이언트(브라우저/앱)에서 접근하는 URL**을 의미합니다
- 네이버 API 서버가 아닌, **당신의 서버 주소**를 입력해야 합니다

---

## 🏗️ 우리의 아키텍처

```
[Flutter 앱 / 웹 앱]
    ↓ (API 요청)
[서버 (localhost:8080)]
    ↓ (네이버 API 호출)
[네이버 지도 API 서버]
```

**중요**: 클라이언트는 네이버 API를 직접 호출하지 않고, **서버를 통해** 호출합니다.

---

## ✅ 올바른 Web 서비스 URL 설정

### 개발 환경 (Development)

**서버 주소를 입력해야 합니다:**

```
http://localhost:8080
```

또는

```
http://localhost:5173
```

**어느 것을 사용해야 할까요?**

#### 경우 1: Flutter 앱만 사용하는 경우
- **서버 주소**: `http://localhost:8080`
- 이유: Flutter 앱이 서버 API를 호출하므로

#### 경우 2: 웹 앱도 사용하는 경우
- **웹 앱 주소**: `http://localhost:5173`
- 이유: 웹 브라우저에서 접근하는 URL이므로

#### 경우 3: 둘 다 사용하는 경우
- **둘 다 입력 가능한 경우**: 둘 다 입력
- **하나만 입력 가능한 경우**: 서버 주소(`http://localhost:8080`) 우선

---

### 프로덕션 환경 (Production)

**실제 도메인을 입력해야 합니다:**

```
https://yourdomain.com
```

또는

```
https://api.yourdomain.com
```

---

## 📋 설정 방법

### Step 1: 네이버 클라우드 플랫폼 콘솔 접속

1. [네이버 클라우드 플랫폼 콘솔](https://console.ncloud.com/) 접속
2. **"Services"** → **"Maps"** → **"Application"** → **"hanbang"** 클릭

### Step 2: 서비스 환경 탭으로 이동

1. **"서비스 환경"** 또는 **"Service Environment"** 탭 클릭

### Step 3: Web 서비스 URL 입력

#### 개발 환경:
```
http://localhost:8080
```

또는 (웹 앱도 사용하는 경우)
```
http://localhost:5173
```

#### 프로덕션 환경:
```
https://yourdomain.com
```

### Step 4: 저장

1. **"저장"** 또는 **"Save"** 버튼 클릭
2. 변경 사항 적용 확인

---

## ⚠️ 주의사항

### 1. 서버 주소 vs 클라이언트 주소

**잘못된 이해**:
- ❌ 네이버 API 서버 주소 (`https://naveropenapi.apigw.ntruss.com`)
- ❌ 클라이언트가 직접 네이버 API를 호출하는 경우가 아님

**올바른 이해**:
- ✅ **서버 주소** (`http://localhost:8080`) - 서버에서 네이버 API를 호출하므로
- ✅ 또는 **웹 앱 주소** (`http://localhost:5173`) - 웹 브라우저에서 접근하는 경우

### 2. 프로토콜 (http vs https)

- **개발 환경**: `http://` 사용 가능
- **프로덕션 환경**: `https://` 사용 권장 (보안)

### 3. 포트 번호

- 서버가 `8080` 포트에서 실행 중이면 `:8080` 포함
- 웹 앱이 `5173` 포트에서 실행 중이면 `:5173` 포함

---

## 🔍 현재 설정 확인

현재 설정을 확인하려면:

1. 네이버 클라우드 플랫폼 콘솔 → Maps → Application → "hanbang"
2. **"서비스 환경"** 탭 클릭
3. **"Web 서비스 URL"** 필드 확인

---

## 🧪 테스트

Web 서비스 URL을 설정한 후:

1. **서버 재시작** (선택사항):
   ```powershell
   cd C:\Users\thf56\Documents\medicalstandard\server
   npm start
   ```

2. **구독 상태 확인**:
   ```powershell
   cd C:\Users\thf56\Documents\medicalstandard
   .\check_naver_api.ps1
   ```

3. **주소 검색 테스트**:
   - 앱에서 주소 검색 시도
   - 서버 로그에서 정상 응답 확인

---

## 📊 요약

### 개발 환경:
- **서버 주소**: `http://localhost:8080` ✅ (권장)
- **웹 앱 주소**: `http://localhost:5173` (웹 앱도 사용하는 경우)

### 프로덕션 환경:
- **실제 도메인**: `https://yourdomain.com` ✅

---

## 🆘 문제 해결

### 문제 1: Web 서비스 URL이 비어있음

**해결**: 개발 환경에서는 `http://localhost:8080` 입력

### 문제 2: Web 서비스 URL이 잘못 설정됨

**해결**: 
1. 서버가 실행 중인 포트 확인
2. 올바른 URL로 수정
3. 저장

### 문제 3: 프로덕션에서 작동하지 않음

**해결**:
1. 실제 도메인 확인
2. HTTPS 사용 확인
3. 포트 번호 확인 (일반적으로 443 또는 생략)

---

**개발 환경에서는 서버 주소(`http://localhost:8080`)를 사용하는 것을 권장합니다!** 🚀


