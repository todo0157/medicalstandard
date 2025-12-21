# 관리자 계정 빠른 설정 가이드

## 현재 상태

✅ 관리자 이메일 설정 완료: `thf5662@gmail.com`
✅ 이메일 인증 요청 완료

## 다음 단계: 이메일 인증 완료 및 회원가입

### 방법 1: 이메일에서 토큰 확인 (권장)

1. **이메일 확인**: `thf5662@gmail.com`으로 발송된 인증 메일 확인
2. **인증 링크 클릭** 또는 토큰 복사
3. **아래 스크립트 실행**하여 회원가입 완료

### 방법 2: 개발 환경에서 토큰 직접 조회

개발 환경에서는 데이터베이스에서 토큰을 직접 조회할 수 있습니다.

---

## 완전한 회원가입 스크립트

**PowerShell 터미널에서 실행:**

```powershell
# ============================================
# 관리자 계정 생성 완전 스크립트
# ============================================

$adminEmail = "thf5662@gmail.com"
$adminPassword = "admin123456"  # 8자 이상 비밀번호
$baseUrl = "http://localhost:8080"

Write-Host "=== 1. 이메일 인증 토큰 조회 (개발용) ===" -ForegroundColor Cyan

# 개발 환경: 데이터베이스에서 최신 토큰 조회
# 또는 이메일에서 받은 토큰 사용
$token = Read-Host "이메일 인증 토큰을 입력하세요 (또는 Enter로 건너뛰기)"

if ([string]::IsNullOrWhiteSpace($token)) {
    Write-Host "토큰이 없습니다. 이메일을 확인하거나 아래 방법을 사용하세요:" -ForegroundColor Yellow
    Write-Host "1. 이메일에서 인증 링크 클릭" -ForegroundColor Yellow
    Write-Host "2. 또는 데이터베이스에서 토큰 조회" -ForegroundColor Yellow
    exit
}

Write-Host "`n=== 2. 이메일 인증 완료 ===" -ForegroundColor Cyan

# 이메일 인증 완료
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
    
} catch {
    Write-Host "✗ 이메일 인증 실패: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "응답: $responseBody" -ForegroundColor Red
    }
    exit
}

Write-Host "`n=== 3. 회원가입 ===" -ForegroundColor Cyan

# 회원가입
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
        
        if ($responseBody -like "*이미 가입된*") {
            Write-Host "`n이미 가입된 계정입니다. 기존 비밀번호로 로그인하세요." -ForegroundColor Yellow
        }
    }
    exit
}

Write-Host "`n=== 4. 관리자 권한 확인 ===" -ForegroundColor Cyan

# 로그인
$loginBody = @{
    email = $adminEmail
    password = $adminPassword
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod `
        -Uri "$baseUrl/api/auth/login" `
        -Method POST `
        -Body $loginBody `
        -ContentType "application/json"
    
    $token = $loginResponse.data.accessToken
    Write-Host "✓ 로그인 성공!" -ForegroundColor Green
    
    # 관리자 권한 테스트
    $headers = @{
        Authorization = "Bearer $token"
    }
    
    $certifications = Invoke-RestMethod `
        -Uri "$baseUrl/api/admin/certifications" `
        -Method GET `
        -Headers $headers
    
    Write-Host "✓ 관리자 권한 확인됨!" -ForegroundColor Green
    Write-Host "대기 중인 인증 신청: $($certifications.data.Count)건" -ForegroundColor Green
    
} catch {
    Write-Host "✗ 관리자 권한 확인 실패: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "응답: $responseBody" -ForegroundColor Red
    }
}

Write-Host "`n=== 완료 ===" -ForegroundColor Cyan
```

---

## 간단한 방법: 이미 가입된 계정 사용

만약 `thf5662@gmail.com`으로 이미 가입한 계정이 있다면:

1. **기존 비밀번호로 로그인**
2. **관리자 권한 테스트**

```powershell
# 로그인
$adminEmail = "thf5662@gmail.com"
$adminPassword = "your-existing-password"  # 기존 비밀번호

$loginBody = @{
    email = $adminEmail
    password = $adminPassword
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod `
    -Uri "http://localhost:8080/api/auth/login" `
    -Method POST `
    -Body $loginBody `
    -ContentType "application/json"

$token = $loginResponse.data.accessToken
Write-Host "✓ 로그인 성공!" -ForegroundColor Green

# 관리자 권한 테스트
$headers = @{
    Authorization = "Bearer $token"
}

$certifications = Invoke-RestMethod `
    -Uri "http://localhost:8080/api/admin/certifications" `
    -Method GET `
    -Headers $headers

Write-Host "✓ 관리자 권한 확인됨!" -ForegroundColor Green
```

---

## 데이터베이스에서 토큰 직접 조회 (개발용)

개발 환경에서 이메일을 확인할 수 없는 경우:

```powershell
# SQLite 데이터베이스에서 최신 토큰 조회
cd C:\Users\thf56\Documents\medicalstandard\server

# Prisma Studio 실행 (GUI)
npx prisma studio

# 또는 직접 쿼리
# (PowerShell에서는 SQLite 쿼리가 복잡하므로 Prisma Studio 권장)
```

Prisma Studio에서:
1. `PreSignupEmailToken` 테이블 열기
2. `thf5662@gmail.com`으로 필터링
3. 가장 최근 토큰 복사
4. 위 스크립트의 `$token` 변수에 입력


