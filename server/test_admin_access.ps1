# 관리자 권한 테스트 스크립트

$adminEmail = "thf5662@gmail.com"
$adminPassword = "qwer^^1234"
$baseUrl = "http://localhost:8080"

Write-Host "=== 1. 관리자 로그인 ===" -ForegroundColor Cyan

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
    Write-Host "토큰: $($token.Substring(0, 30))..." -ForegroundColor Yellow
    
    Write-Host "`n=== 2. 관리자 권한 테스트 ===" -ForegroundColor Cyan
    
    $headers = @{
        Authorization = "Bearer $token"
    }
    
    # 대기 중인 인증 신청 조회
    try {
        $certifications = Invoke-RestMethod `
            -Uri "$baseUrl/api/admin/certifications?status=pending" `
            -Method GET `
            -Headers $headers
        
        Write-Host "관리자 권한 확인됨!" -ForegroundColor Green
        
        # 응답 구조 확인
        if ($certifications.data) {
            $count = $certifications.data.Count
        } elseif ($certifications -is [array]) {
            $count = $certifications.Count
        } else {
            $count = 0
        }
        
        Write-Host "대기 중인 인증 신청: $count건" -ForegroundColor Green
    
        $certList = if ($certifications.data) { $certifications.data } else { $certifications }
        
        if ($count -gt 0) {
            Write-Host "`n인증 신청 목록:" -ForegroundColor Cyan
            $certList | Format-Table id, name, email, certificationStatus, licenseNumber -AutoSize
            
            # 첫 번째 인증 신청 상세 조회
            $firstCert = $certList[0]
            Write-Host "`n=== 3. 인증 신청 상세 조회 ===" -ForegroundColor Cyan
            $detail = Invoke-RestMethod `
                -Uri "$baseUrl/api/admin/certifications/$($firstCert.id)" `
                -Method GET `
                -Headers $headers
            
            Write-Host "상세 정보:" -ForegroundColor Yellow
            $detailData = if ($detail.data) { $detail.data } else { $detail }
            $detailData | ConvertTo-Json -Depth 3
        } else {
            Write-Host "`n대기 중인 인증 신청이 없습니다." -ForegroundColor Yellow
        }
        
        # 모든 인증 신청 조회 (상태별)
        Write-Host "`n=== 4. 전체 인증 신청 조회 ===" -ForegroundColor Cyan
        $allCertifications = Invoke-RestMethod `
            -Uri "$baseUrl/api/admin/certifications" `
            -Method GET `
            -Headers $headers
        
        $allList = if ($allCertifications.data) { $allCertifications.data } else { $allCertifications }
        $allCount = if ($allList) { $allList.Count } else { 0 }
        
        Write-Host "전체 인증 신청: $allCount건" -ForegroundColor Green
        if ($allCount -gt 0) {
            $allList | Group-Object certificationStatus | Format-Table Name, Count -AutoSize
        }
    } catch {
        Write-Host "관리자 API 호출 실패" -ForegroundColor Red
        Write-Host "오류: $_" -ForegroundColor Red
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode.value__
            Write-Host "상태 코드: $statusCode" -ForegroundColor Yellow
            
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "응답: $responseBody" -ForegroundColor Yellow
        }
    }
    
} catch {
    Write-Host "오류 발생" -ForegroundColor Red
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "상태 코드: $statusCode" -ForegroundColor Yellow
        
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "응답: $responseBody" -ForegroundColor Yellow
        
        if ($statusCode -eq 403) {
            Write-Host "`n관리자 권한이 없습니다!" -ForegroundColor Red
            Write-Host "서버의 .env 파일에 ADMIN_EMAILS=thf5662@gmail.com 이 설정되어 있는지 확인하세요." -ForegroundColor Yellow
            Write-Host "설정 후 서버를 재시작해야 합니다." -ForegroundColor Yellow
        } elseif ($statusCode -eq 401) {
            Write-Host "`n인증 실패: 이메일 또는 비밀번호가 올바르지 않습니다." -ForegroundColor Red
        }
    } else {
        Write-Host "오류 메시지: $_" -ForegroundColor Red
    }
}

Write-Host "`n=== 완료 ===" -ForegroundColor Cyan

