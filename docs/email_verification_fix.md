# 이메일 인증 문제 해결 가이드

## 문제 상황

이메일 인증 링크를 클릭했는데 `localhost:5173`에 연결할 수 없다는 오류가 발생했습니다.

**원인**: Flutter 웹 앱이 `localhost:5173`에서 실행되지 않았거나, 다른 포트에서 실행 중입니다.

## 해결 방법

### 방법 1: API로 직접 인증 완료 (가장 빠름)

이메일 링크에서 토큰을 추출하여 API를 직접 호출합니다.

**PowerShell 터미널에서 실행:**

```powershell
# 이메일 링크에서 토큰 추출
# 링크: http://localhost:5173/verify-pre?token=33cd8a86e2e6fb126c2ebaac6b4dd6710f3441aae5e8a174f21642ae3e490a251377efa84427d1df48e4773d6596754c

$token = "33cd8a86e2e6fb126c2ebaac6b4dd6710f3441aae5e8a174f21642ae3e490a251377efa84427d1df48e4773d6596754c"
$baseUrl = "http://localhost:8080"

Write-Host "=== 이메일 인증 완료 ===" -ForegroundColor Cyan

# 이메일 인증 완료 API 호출
$verifyBody = @{
    token = $token
} | ConvertTo-Json

try {
    $verifyResponse = Invoke-RestMethod `
        -Uri "$baseUrl/api/auth/verify-email/precheck/confirm" `
        -Method POST `
        -Body $verifyBody `
        -ContentType "application/json"
    
    Write-Host "✓ 이메일 인증 완료!" -ForegroundColor Green
    Write-Host "인증된 이메일: $($verifyResponse.email)" -ForegroundColor Green
    
    Write-Host "`n이제 회원가입을 진행할 수 있습니다!" -ForegroundColor Yellow
    
} catch {
    Write-Host "✗ 인증 실패: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "응답: $responseBody" -ForegroundColor Red
        
        if ($responseBody -like "*만료*" -or $responseBody -like "*유효하지*") {
            Write-Host "`n토큰이 만료되었거나 이미 사용되었습니다." -ForegroundColor Yellow
            Write-Host "다시 이메일 인증을 요청하세요." -ForegroundColor Yellow
        }
    }
}
```

### 방법 2: Flutter 웹 앱을 올바른 포트에서 실행

Flutter 웹 앱을 `localhost:5173`에서 실행하거나, 링크의 포트를 현재 실행 중인 포트로 변경합니다.

**Flutter 웹 앱 실행:**

```powershell
# Flutter 웹 앱을 포트 5173에서 실행
flutter run -d chrome --web-port=5173 --dart-define=API_BASE_URL=http://localhost:8080 --dart-define=APP_ENV=development
```

그 후 이메일 링크를 다시 클릭하세요.

### 방법 3: 링크의 포트 변경

현재 Flutter 웹 앱이 `localhost:8081`에서 실행 중이라면:

1. 이메일 링크를 복사
2. `5173`을 `8081`로 변경
3. 브라우저에서 수정된 링크 접속

예: `http://localhost:8081/verify-pre?token=33cd8a86e2e6fb126c2ebaac6b4dd6710f3441aae5e8a174f21642ae3e490a251377efa84427d1df48e4773d6596754c`

---

## 인증 완료 후 회원가입

이메일 인증이 완료되면 회원가입을 진행하세요:

```powershell
$adminEmail = "thf5662@gmail.com"
$adminPassword = "admin123456"  # 8자 이상
$baseUrl = "http://localhost:8080"

# 회원가입
$signupBody = @{
    email = $adminEmail
    password = $adminPassword
    name = "관리자"
    age = 30
    gender = "male"
    address = "서울시"
} | ConvertTo-Json

$signupResponse = Invoke-RestMethod `
    -Uri "$baseUrl/api/auth/signup" `
    -Method POST `
    -Body $signupBody `
    -ContentType "application/json"

Write-Host "✓ 회원가입 완료!" -ForegroundColor Green
```

---

## 전체 프로세스 (한 번에 실행)

```powershell
# ============================================
# 이메일 인증 및 회원가입 완전 스크립트
# ============================================

$token = "33cd8a86e2e6fb126c2ebaac6b4dd6710f3441aae5e8a174f21642ae3e490a251377efa84427d1df48e4773d6596754c"
$adminEmail = "thf5662@gmail.com"
$adminPassword = "admin123456"  # 8자 이상
$baseUrl = "http://localhost:8080"

Write-Host "=== 1. 이메일 인증 완료 ===" -ForegroundColor Cyan

$verifyBody = @{ token = $token } | ConvertTo-Json

try {
    $verifyResponse = Invoke-RestMethod `
        -Uri "$baseUrl/api/auth/verify-email/precheck/confirm" `
        -Method POST `
        -Body $verifyBody `
        -ContentType "application/json"
    
    Write-Host "✓ 이메일 인증 완료!" -ForegroundColor Green
} catch {
    Write-Host "✗ 인증 실패: $_" -ForegroundColor Red
    exit
}

Write-Host "`n=== 2. 회원가입 ===" -ForegroundColor Cyan

$signupBody = @{
    email = $adminEmail
    password = $adminPassword
    name = "관리자"
    age = 30
    gender = "male"
    address = "서울시"
} | ConvertTo-Json

try {
    $signupResponse = Invoke-RestMethod `
        -Uri "$baseUrl/api/auth/signup" `
        -Method POST `
        -Body $signupBody `
        -ContentType "application/json"
    
    Write-Host "✓ 회원가입 완료!" -ForegroundColor Green
    Write-Host "이메일: $adminEmail" -ForegroundColor Yellow
    Write-Host "비밀번호: $adminPassword" -ForegroundColor Yellow
} catch {
    Write-Host "✗ 회원가입 실패: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "응답: $responseBody" -ForegroundColor Red
    }
}

Write-Host "`n=== 완료 ===" -ForegroundColor Cyan
```


