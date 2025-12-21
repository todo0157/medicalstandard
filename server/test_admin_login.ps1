$adminEmail = "thf5662@gmail.com"
$adminPassword = "admin123456"
$baseUrl = "http://localhost:8080"

Write-Host "=== 로그인 시도 ===" -ForegroundColor Cyan

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
    Write-Host "로그인 성공!" -ForegroundColor Green
    
    Write-Host "`n=== 관리자 권한 테스트 ===" -ForegroundColor Cyan
    
    $headers = @{
        Authorization = "Bearer $token"
    }
    
    $certifications = Invoke-RestMethod `
        -Uri "$baseUrl/api/admin/certifications?status=pending" `
        -Method GET `
        -Headers $headers
    
    Write-Host "관리자 권한 확인됨!" -ForegroundColor Green
    Write-Host "대기 중인 인증 신청: $($certifications.data.Count)건" -ForegroundColor Green
    
} catch {
    Write-Host "로그인 실패" -ForegroundColor Red
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "상태 코드: $statusCode" -ForegroundColor Yellow
        
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "응답: $responseBody" -ForegroundColor Yellow
    } else {
        Write-Host "오류: $_" -ForegroundColor Red
    }
}


