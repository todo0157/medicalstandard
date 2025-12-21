# 관리자 계정 생성 가이드

## 📌 중요 설명

**관리자 계정은 별도로 만드는 것이 아닙니다!**

관리자 기능은 다음과 같이 작동합니다:
1. **일반 회원가입**으로 계정을 만듭니다
2. 그 계정의 **이메일 주소**를 `server/.env` 파일의 `ADMIN_EMAILS`에 추가합니다
3. 그 계정으로 로그인하면 **자동으로 관리자 권한**이 부여됩니다

---

## 🚀 관리자 계정 생성 방법

### 방법 1: 앱에서 회원가입 (권장)

1. **Flutter 앱 실행**
2. **회원가입 화면**으로 이동
3. **관리자로 사용할 이메일과 비밀번호**로 회원가입
   - 이메일: `admin@example.com` (원하는 관리자 이메일)
   - 비밀번호: **8자 이상** (예: `admin1234`)
   - 이름, 나이 등 기본 정보 입력
4. 회원가입 완료

### 방법 2: API로 직접 회원가입

**PowerShell 터미널에서 실행:**

```powershell
# 1. 회원가입 전 이메일 인증 요청
$preVerifyBody = @{
    email = "admin@example.com"  # 관리자로 사용할 이메일
} | ConvertTo-Json

$preVerifyResponse = Invoke-RestMethod `
    -Uri "http://localhost:8080/api/auth/verify-pre" `
    -Method POST `
    -Body $preVerifyBody `
    -ContentType "application/json"

Write-Host "이메일 인증 토큰이 발급되었습니다." -ForegroundColor Green
Write-Host "토큰: $($preVerifyResponse.data.token)" -ForegroundColor Yellow

# 2. 이메일 인증 완료 (토큰 사용)
$verifyToken = $preVerifyResponse.data.token  # 위에서 받은 토큰

$verifyBody = @{
    token = $verifyToken
} | ConvertTo-Json

$verifyResponse = Invoke-RestMethod `
    -Uri "http://localhost:8080/api/auth/verify-pre/confirm" `
    -Method POST `
    -Body $verifyBody `
    -ContentType "application/json"

Write-Host "이메일 인증 완료!" -ForegroundColor Green

# 3. 회원가입
$signupBody = @{
    email = "admin@example.com"
    password = "admin1234"  # 8자 이상
    name = "관리자"
    age = 30
    gender = "male"
    address = "서울시"
} | ConvertTo-Json

$signupResponse = Invoke-RestMethod `
    -Uri "http://localhost:8080/api/auth/signup" `
    -Method POST `
    -Body $signupBody `
    -ContentType "application/json"

Write-Host "회원가입 완료!" -ForegroundColor Green
Write-Host "이메일: admin@example.com" -ForegroundColor Yellow
Write-Host "비밀번호: admin1234" -ForegroundColor Yellow
```

---

## ⚙️ 관리자 권한 부여

회원가입이 완료되면, 해당 이메일을 관리자로 지정해야 합니다.

### 1. `.env` 파일 수정

`server/.env` 파일을 열고 다음을 추가하세요:

```env
ADMIN_EMAILS=admin@example.com
```

여러 관리자가 있는 경우:

```env
ADMIN_EMAILS=admin1@example.com,admin2@example.com
```

### 2. 서버 재시작

```powershell
# 서버 중지 (서버 터미널에서 Ctrl+C)
# 또는
Get-Process -Name node -ErrorAction SilentlyContinue | Stop-Process -Force

# 서버 재시작
cd C:\Users\thf56\Documents\medicalstandard\server
npm start
```

---

## ✅ 확인 방법

관리자 계정으로 로그인하여 권한이 부여되었는지 확인:

```powershell
# 로그인
$loginBody = @{
    email = "admin@example.com"
    password = "admin1234"  # 회원가입 시 설정한 비밀번호
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod `
    -Uri "http://localhost:8080/api/auth/login" `
    -Method POST `
    -Body $loginBody `
    -ContentType "application/json"

$token = $loginResponse.data.accessToken
Write-Host "로그인 성공!" -ForegroundColor Green

# 관리자 API 테스트
$headers = @{
    Authorization = "Bearer $token"
}

try {
    $certifications = Invoke-RestMethod `
        -Uri "http://localhost:8080/api/admin/certifications" `
        -Method GET `
        -Headers $headers
    
    Write-Host "✓ 관리자 권한 확인됨!" -ForegroundColor Green
} catch {
    Write-Host "✗ 관리자 권한 없음: $_" -ForegroundColor Red
}
```

---

## 🔧 문제 해결

### 문제 1: "이메일 인증을 먼저 완료해 주세요"

**원인**: 회원가입 전에 이메일 인증이 필요합니다.

**해결**: 위의 "방법 2"에서 1-2단계를 먼저 실행하세요.

### 문제 2: "이미 가입된 이메일입니다"

**원인**: 해당 이메일로 이미 계정이 존재합니다.

**해결**: 
- 다른 이메일 사용
- 또는 기존 계정의 비밀번호를 알고 있다면 그대로 사용

### 문제 3: "관리자 권한이 필요합니다" (403)

**원인**: `.env` 파일에 이메일이 추가되지 않았거나 서버가 재시작되지 않았습니다.

**해결**:
1. `server/.env` 파일 확인
2. `ADMIN_EMAILS`에 정확한 이메일 주소가 있는지 확인 (대소문자 구분 없음)
3. 서버 재시작

---

## 💡 요약

1. **회원가입**: 일반 회원가입으로 계정 생성 (비밀번호 8자 이상)
2. **이메일 확인**: 회원가입한 이메일 주소 확인
3. **`.env` 수정**: `ADMIN_EMAILS=your-email@example.com` 추가
4. **서버 재시작**: 변경사항 적용
5. **테스트**: 관리자 API로 권한 확인

**비밀번호는 회원가입 시 설정한 비밀번호를 사용하면 됩니다!**


