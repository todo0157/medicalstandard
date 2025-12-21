# 관리자 API 테스트 가이드 (상세)

## 📋 사전 준비

### 1. 관리자 이메일 설정 확인

`server/.env` 파일에 관리자 이메일이 설정되어 있는지 확인하세요:

```env
ADMIN_EMAILS=your-admin-email@example.com
```

### 2. 서버 실행 확인

서버가 `http://localhost:8080`에서 실행 중인지 확인하세요.

---

## 🚀 테스트 방법 (PowerShell)

**중요**: 명령어는 **아무 터미널에서나** 실행할 수 있습니다. `server` 디렉토리에 있을 필요는 없습니다.

### 단계 1: 관리자 계정으로 로그인하여 토큰 받기

**PowerShell 터미널에서 실행:**

```powershell
# 1. 로그인 요청
$loginBody = @{
    email = "your-admin-email@example.com"  # .env에 설정한 관리자 이메일
    password = "your-password"               # 관리자 계정 비밀번호
} | ConvertTo-Json

# 2. 로그인 API 호출
$loginResponse = Invoke-RestMethod `
    -Uri "http://localhost:8080/api/auth/login" `
    -Method POST `
    -Body $loginBody `
    -ContentType "application/json"

# 3. 토큰 추출
$token = $loginResponse.data.accessToken

# 4. 토큰 확인 (선택사항)
Write-Host "로그인 성공! 토큰: $token"
```

**예상 응답:**
```json
{
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "...",
    "profile": { ... }
  }
}
```

**에러가 발생하면:**
- 이메일/비밀번호가 올바른지 확인
- 관리자 이메일이 `.env`의 `ADMIN_EMAILS`에 포함되어 있는지 확인
- 서버가 실행 중인지 확인 (`netstat -ano | findstr :8080`)

---

### 단계 2: 인증 신청 목록 조회

**PowerShell 터미널에서 실행:**

```powershell
# 1. 헤더 설정 (토큰 포함)
$headers = @{
    Authorization = "Bearer $token"
}

# 2. 대기 중인 인증 신청 목록 조회
$certifications = Invoke-RestMethod `
    -Uri "http://localhost:8080/api/admin/certifications?status=pending" `
    -Method GET `
    -Headers $headers

# 3. 결과 확인
$certifications.data | Format-Table -AutoSize
$certifications.data | Select-Object id, name, email, certificationStatus, licenseNumber, clinicName
```

**예상 응답:**
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
      "clinicName": "한방 건강 클리닉"
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

**프로필 ID 확인:**
```powershell
# 프로필 ID 저장 (승인/거부 시 사용)
$profileId = $certifications.data[0].id
Write-Host "프로필 ID: $profileId"
```

---

### 단계 3: 인증 신청 상세 조회 (선택사항)

**PowerShell 터미널에서 실행:**

```powershell
# 특정 프로필의 상세 정보 조회
$profileId = "profile_123"  # 위에서 받은 프로필 ID

$detail = Invoke-RestMethod `
    -Uri "http://localhost:8080/api/admin/certifications/$profileId" `
    -Method GET `
    -Headers $headers

# 결과 확인
$detail.data | Format-List
```

**예상 응답:**
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
    "licenseNumber": "한의-12345",
    "clinicName": "한방 건강 클리닉",
    "profileImageUrl": "data:image/jpeg;base64,..."  // 자격증 이미지
  }
}
```

---

### 단계 4: 인증 승인

**PowerShell 터미널에서 실행:**

```powershell
# 1. 승인할 프로필 ID 설정
$profileId = "profile_123"  # 위에서 받은 프로필 ID

# 2. 승인 요청 본문 (선택사항: 메모 추가 가능)
$approveBody = @{
    notes = "자격증 확인 완료"
} | ConvertTo-Json

# 3. 승인 API 호출
$approveResponse = Invoke-RestMethod `
    -Uri "http://localhost:8080/api/admin/certifications/$profileId/approve" `
    -Method POST `
    -Headers $headers `
    -Body $approveBody `
    -ContentType "application/json"

# 4. 결과 확인
Write-Host "승인 완료!"
$approveResponse.data | Select-Object id, name, certificationStatus, isPractitioner
```

**예상 응답:**
```json
{
  "data": {
    "id": "profile_123",
    "name": "홍길동",
    "certificationStatus": "verified",
    "isPractitioner": true,
    ...
  },
  "message": "인증이 승인되었습니다."
}
```

**승인 후 확인:**
- `certificationStatus`가 `verified`로 변경됨
- `isPractitioner`가 `true`로 변경됨
- 앱에서 프로필 화면을 새로고침하면 "인증 완료"로 표시됨

---

### 단계 5: 인증 거부 (필요한 경우)

**PowerShell 터미널에서 실행:**

```powershell
# 1. 거부할 프로필 ID 설정
$profileId = "profile_123"

# 2. 거부 요청 본문 (거부 사유 필수)
$rejectBody = @{
    reason = "자격증 번호가 일치하지 않습니다."
    notes = "추가 메모 (선택사항)"
} | ConvertTo-Json

# 3. 거부 API 호출
$rejectResponse = Invoke-RestMethod `
    -Uri "http://localhost:8080/api/admin/certifications/$profileId/reject" `
    -Method POST `
    -Headers $headers `
    -Body $rejectBody `
    -ContentType "application/json"

# 4. 결과 확인
Write-Host "거부 완료!"
$rejectResponse.data | Select-Object id, name, certificationStatus, isPractitioner
```

**예상 응답:**
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

---

## 📝 전체 스크립트 (한 번에 실행)

**PowerShell 터미널에서 복사해서 실행:**

```powershell
# ============================================
# 관리자 API 테스트 스크립트
# ============================================

# 설정
$adminEmail = "your-admin-email@example.com"  # 관리자 이메일
$adminPassword = "your-password"              # 관리자 비밀번호
$baseUrl = "http://localhost:8080"

Write-Host "=== 1. 관리자 로그인 ===" -ForegroundColor Cyan

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
} catch {
    Write-Host "✗ 로그인 실패: $_" -ForegroundColor Red
    exit
}

# 헤더 설정
$headers = @{
    Authorization = "Bearer $token"
}

Write-Host "`n=== 2. 인증 신청 목록 조회 ===" -ForegroundColor Cyan

# 인증 신청 목록 조회
try {
    $certifications = Invoke-RestMethod `
        -Uri "$baseUrl/api/admin/certifications?status=pending" `
        -Method GET `
        -Headers $headers
    
    if ($certifications.data.Count -eq 0) {
        Write-Host "대기 중인 인증 신청이 없습니다." -ForegroundColor Yellow
        exit
    }
    
    Write-Host "✓ 인증 신청 ${($certifications.data.Count)}건 발견" -ForegroundColor Green
    $certifications.data | Format-Table id, name, email, certificationStatus, licenseNumber -AutoSize
    
    # 첫 번째 신청의 프로필 ID 저장
    $profileId = $certifications.data[0].id
    Write-Host "`n처리할 프로필 ID: $profileId" -ForegroundColor Yellow
    
} catch {
    Write-Host "✗ 목록 조회 실패: $_" -ForegroundColor Red
    Write-Host "응답: $($_.Exception.Response)" -ForegroundColor Red
    exit
}

Write-Host "`n=== 3. 인증 승인 ===" -ForegroundColor Cyan

# 승인 여부 확인
$approve = Read-Host "인증을 승인하시겠습니까? (y/n)"
if ($approve -ne "y") {
    Write-Host "취소되었습니다." -ForegroundColor Yellow
    exit
}

# 인증 승인
try {
    $approveBody = @{
        notes = "관리자 승인"
    } | ConvertTo-Json
    
    $approveResponse = Invoke-RestMethod `
        -Uri "$baseUrl/api/admin/certifications/$profileId/approve" `
        -Method POST `
        -Headers $headers `
        -Body $approveBody `
        -ContentType "application/json"
    
    Write-Host "✓ 인증 승인 완료!" -ForegroundColor Green
    Write-Host "상태: $($approveResponse.data.certificationStatus)" -ForegroundColor Green
    Write-Host "한의사 여부: $($approveResponse.data.isPractitioner)" -ForegroundColor Green
    
} catch {
    Write-Host "✗ 승인 실패: $_" -ForegroundColor Red
    Write-Host "응답: $($_.Exception.Response)" -ForegroundColor Red
}

Write-Host "`n=== 완료 ===" -ForegroundColor Cyan
```

---

## 🔍 문제 해결

### 오류 1: "관리자 권한이 필요합니다" (403)

**원인**: 현재 로그인한 이메일이 `ADMIN_EMAILS`에 없음

**해결**:
1. `server/.env` 파일 확인
2. `ADMIN_EMAILS`에 현재 이메일이 포함되어 있는지 확인
3. 서버 재시작

### 오류 2: "인증이 필요합니다" (401)

**원인**: 토큰이 없거나 만료됨

**해결**:
1. 다시 로그인하여 새 토큰 받기
2. 토큰이 올바르게 헤더에 포함되었는지 확인

### 오류 3: "프로필을 찾을 수 없습니다" (404)

**원인**: 잘못된 프로필 ID 사용

**해결**:
1. 인증 신청 목록을 다시 조회하여 올바른 프로필 ID 확인
2. 프로필 ID가 정확한지 확인

### 오류 4: "인증 상태가 'pending'이 아닙니다" (400)

**원인**: 이미 승인/거부된 인증 신청

**해결**:
1. 인증 신청 목록에서 `status=pending`인 항목만 조회
2. 다른 프로필 ID 선택

---

## 💡 팁

1. **토큰 저장**: 여러 번 사용할 경우 변수에 저장해두세요
   ```powershell
   $token = "your-token-here"
   $headers = @{ Authorization = "Bearer $token" }
   ```

2. **결과 확인**: `Format-Table` 또는 `Format-List`로 결과를 보기 좋게 표시
   ```powershell
   $result | Format-Table -AutoSize
   $result | Format-List
   ```

3. **에러 처리**: `try-catch`로 에러를 처리하면 더 안전합니다

4. **Postman 사용**: GUI 도구를 선호한다면 Postman이나 Insomnia 사용 가능

---

## 📌 요약

- **명령어 실행 위치**: 아무 터미널에서나 가능 (서버 디렉토리 불필요)
- **필수 사항**: 서버가 실행 중이어야 함 (`http://localhost:8080`)
- **필수 설정**: `server/.env`에 `ADMIN_EMAILS` 설정
- **순서**: 로그인 → 목록 조회 → 승인/거부


