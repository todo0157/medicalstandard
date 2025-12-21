# ============================================
# 관리자 계정 회원가입 완전 스크립트
# ============================================

$adminEmail = "thf5662@gmail.com"
$adminPassword = "admin123456"  # 8자 이상
$baseUrl = "http://localhost:8080"

Write-Host "`n=== 회원가입 ===" -ForegroundColor Cyan

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
    
    Write-Host "`n=== 로그인 테스트 ===" -ForegroundColor Cyan
    
    # 로그인
    $loginBody = @{
        email = $adminEmail
        password = $adminPassword
    } | ConvertTo-Json
    
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
        -Uri "$baseUrl/api/admin/certifications?status=pending" `
        -Method GET `
        -Headers $headers
    
    Write-Host "✓ 관리자 권한 확인됨!" -ForegroundColor Green
    Write-Host "대기 중인 인증 신청: $($certifications.data.Count)건" -ForegroundColor Green
    
} catch {
    Write-Host "✗ 오류: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "응답: $responseBody" -ForegroundColor Red
        
        if ($responseBody -like "*이미 가입된*") {
            Write-Host "`n이미 가입된 계정입니다. 기존 비밀번호로 로그인하세요." -ForegroundColor Yellow
        }
    }
}

Write-Host "`n=== 완료 ===" -ForegroundColor Cyan


