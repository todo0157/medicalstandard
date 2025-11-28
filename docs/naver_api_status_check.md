# 네이버 지도 API 등록/구독 상태 확인 (터미널)

## 🧪 방법 1: API 호출로 구독 상태 확인 (가장 간단)

네이버 지도 API를 직접 호출하여 구독 상태를 확인할 수 있습니다.

### PowerShell에서 확인

```powershell
# .env 파일에서 API 키 읽기 (PowerShell)
$envContent = Get-Content C:\Users\thf56\Documents\medicalstandard\server\.env
$clientId = ($envContent | Select-String "NAVER_MAP_CLIENT_ID=").ToString().Split('=')[1]
$clientSecret = ($envContent | Select-String "NAVER_MAP_CLIENT_SECRET=").ToString().Split('=')[1]

# API 호출 테스트
$headers = @{
    'X-NCP-APIGW-API-KEY-ID' = $clientId
    'X-NCP-APIGW-API-KEY' = $clientSecret
}

$response = Invoke-WebRequest -Uri 'https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=서울' -Headers $headers -Method GET

# 응답 확인
$response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10
```

### 간단한 테스트 스크립트

`check_naver_api.ps1` 파일을 생성:

```powershell
# check_naver_api.ps1
$envFile = "C:\Users\thf56\Documents\medicalstandard\server\.env"

if (-not (Test-Path $envFile)) {
    Write-Host "❌ .env 파일을 찾을 수 없습니다: $envFile" -ForegroundColor Red
    exit 1
}

# .env 파일에서 API 키 읽기
$clientId = $null
$clientSecret = $null

Get-Content $envFile | ForEach-Object {
    if ($_ -match "^NAVER_MAP_CLIENT_ID=(.+)$") {
        $clientId = $matches[1].Trim()
    }
    if ($_ -match "^NAVER_MAP_CLIENT_SECRET=(.+)$") {
        $clientSecret = $matches[1].Trim()
    }
}

if (-not $clientId -or -not $clientSecret) {
    Write-Host "❌ API 키를 찾을 수 없습니다." -ForegroundColor Red
    Write-Host "   NAVER_MAP_CLIENT_ID와 NAVER_MAP_CLIENT_SECRET을 확인하세요." -ForegroundColor Yellow
    exit 1
}

Write-Host "🔍 네이버 지도 API 상태 확인 중..." -ForegroundColor Cyan
Write-Host "   Client ID: $($clientId.Substring(0, 4))..." -ForegroundColor Gray

# API 호출 테스트
$headers = @{
    'X-NCP-APIGW-API-KEY-ID' = $clientId
    'X-NCP-APIGW-API-KEY' = $clientSecret
}

try {
    $response = Invoke-WebRequest -Uri 'https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=서울' -Headers $headers -Method GET -ErrorAction Stop
    
    $json = $response.Content | ConvertFrom-Json
    
    if ($json.status.code -eq 0) {
        Write-Host "✅ 구독 상태: 정상" -ForegroundColor Green
        Write-Host "   응답: $($json.status.message)" -ForegroundColor Gray
        Write-Host "   검색 결과: $($json.addresses.Count)개" -ForegroundColor Gray
    } else {
        Write-Host "⚠️  구독 상태: 문제 있음" -ForegroundColor Yellow
        Write-Host "   에러 코드: $($json.status.code)" -ForegroundColor Yellow
        Write-Host "   메시지: $($json.status.message)" -ForegroundColor Yellow
    }
} catch {
    $errorResponse = $_.ErrorDetails.Message | ConvertFrom-Json
    
    if ($errorResponse.error.errorCode -eq "210") {
        Write-Host "❌ 구독 상태: 구독 필요" -ForegroundColor Red
        Write-Host "   에러 코드: $($errorResponse.error.errorCode)" -ForegroundColor Red
        Write-Host "   메시지: $($errorResponse.error.message)" -ForegroundColor Red
        Write-Host "   상세: $($errorResponse.error.details)" -ForegroundColor Red
    } elseif ($errorResponse.error.errorCode -eq "200") {
        Write-Host "❌ 인증 상태: 인증 실패" -ForegroundColor Red
        Write-Host "   에러 코드: $($errorResponse.error.errorCode)" -ForegroundColor Red
        Write-Host "   메시지: $($errorResponse.error.message)" -ForegroundColor Red
        Write-Host "   상세: API 키가 올바르지 않거나 등록되지 않았습니다." -ForegroundColor Red
    } else {
        Write-Host "❌ 오류 발생" -ForegroundColor Red
        Write-Host "   에러: $($errorResponse | ConvertTo-Json)" -ForegroundColor Red
    }
}
```

### 스크립트 실행 방법

```powershell
# 스크립트 실행
cd C:\Users\thf56\Documents\medicalstandard
.\check_naver_api.ps1
```

---

## 🧪 방법 2: curl을 사용한 간단한 확인

### PowerShell에서 curl.exe 사용

```powershell
# .env 파일에서 API 키 읽기
$envContent = Get-Content C:\Users\thf56\Documents\medicalstandard\server\.env
$clientId = ($envContent | Select-String "NAVER_MAP_CLIENT_ID=").ToString().Split('=')[1]
$clientSecret = ($envContent | Select-String "NAVER_MAP_CLIENT_SECRET=").ToString().Split('=')[1]

# curl로 테스트
curl.exe -H "X-NCP-APIGW-API-KEY-ID: $clientId" -H "X-NCP-APIGW-API-KEY: $clientSecret" "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=서울"
```

---

## 📊 응답 해석

### ✅ 구독 정상 (200 OK):
```json
{
  "status": {
    "code": 0,
    "name": "ok",
    "message": "정상"
  },
  "addresses": [...]
}
```
**의미**: 구독이 정상적으로 되어 있고 API가 작동합니다.

### ❌ 구독 필요 (401 - errorCode 210):
```json
{
  "error": {
    "errorCode": "210",
    "message": "Permission Denied",
    "details": "A subscription to the API is required."
  }
}
```
**의미**: 구독이 필요합니다. 네이버 클라우드 플랫폼 콘솔에서 구독하세요.

### ❌ 인증 실패 (401 - errorCode 200):
```json
{
  "error": {
    "errorCode": "200",
    "message": "Authentication Failed",
    "details": "Authentication information are missing."
  }
}
```
**의미**: API 키가 올바르지 않거나 등록되지 않았습니다.

---

## 🔧 빠른 확인 명령어 (한 줄)

PowerShell에서 한 줄로 확인:

```powershell
$env=Get-Content C:\Users\thf56\Documents\medicalstandard\server\.env;$cid=($env|Select-String "NAVER_MAP_CLIENT_ID=").ToString().Split('=')[1];$csec=($env|Select-String "NAVER_MAP_CLIENT_SECRET=").ToString().Split('=')[1];try{$r=Invoke-WebRequest -Uri 'https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=서울' -Headers @{'X-NCP-APIGW-API-KEY-ID'=$cid;'X-NCP-APIGW-API-KEY'=$csec} -Method GET;$j=$r.Content|ConvertFrom-Json;if($j.status.code -eq 0){Write-Host "✅ 구독 정상" -ForegroundColor Green}else{Write-Host "⚠️ 문제: $($j.status.message)" -ForegroundColor Yellow}}catch{$e=$_.ErrorDetails.Message|ConvertFrom-Json;if($e.error.errorCode -eq "210"){Write-Host "❌ 구독 필요" -ForegroundColor Red}else{Write-Host "❌ 인증 실패" -ForegroundColor Red}}
```

---

## 📝 체크리스트

- [ ] .env 파일에 NAVER_MAP_CLIENT_ID가 설정되어 있는가?
- [ ] .env 파일에 NAVER_MAP_CLIENT_SECRET이 설정되어 있는가?
- [ ] API 호출 시 정상 응답(200 OK)을 받는가?
- [ ] 에러 코드 210이 나오면 구독 필요
- [ ] 에러 코드 200이 나오면 인증 실패 (API 키 확인)

---

**가장 간단한 방법은 위의 PowerShell 스크립트를 사용하는 것입니다!** 🚀


