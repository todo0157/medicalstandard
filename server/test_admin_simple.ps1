$adminEmail = "thf5662@gmail.com"
$adminPassword = "qwer^^1234"
$baseUrl = "http://localhost:8080"

Write-Host "=== Step 1: Login ===" -ForegroundColor Cyan

$loginBody = @{
    email = $adminEmail
    password = $adminPassword
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod `
    -Uri "$baseUrl/api/auth/login" `
    -Method POST `
    -Body $loginBody `
    -ContentType "application/json"

Write-Host "Login response structure:" -ForegroundColor Yellow
$loginResponse | ConvertTo-Json -Depth 3

# Try different possible response structures
if ($loginResponse.data) {
    if ($loginResponse.data.accessToken) {
        $token = $loginResponse.data.accessToken
    } elseif ($loginResponse.data.token) {
        $token = $loginResponse.data.token
    } else {
        $token = $loginResponse.data
    }
} elseif ($loginResponse.accessToken) {
    $token = $loginResponse.accessToken
} elseif ($loginResponse.token) {
    $token = $loginResponse.token
} else {
    Write-Host "ERROR: Could not find token in response" -ForegroundColor Red
    exit
}

Write-Host "Login successful!" -ForegroundColor Green
if ($token) {
    $tokenPreview = if ($token.Length -gt 30) { $token.Substring(0, 30) } else { $token }
    Write-Host "Token: $tokenPreview..." -ForegroundColor Yellow
}

Write-Host "`n=== Step 2: Test Admin Access ===" -ForegroundColor Cyan

$headers = @{
    Authorization = "Bearer $token"
}

try {
    $response = Invoke-RestMethod `
        -Uri "$baseUrl/api/admin/certifications?status=pending" `
        -Method GET `
        -Headers $headers
    
    Write-Host "Admin access confirmed!" -ForegroundColor Green
    
    # Check response structure
    Write-Host "`nResponse structure:" -ForegroundColor Yellow
    $response | ConvertTo-Json -Depth 3
    
    if ($response.data) {
        $count = $response.data.Count
        Write-Host "`nPending certifications: $count" -ForegroundColor Green
        
        if ($count -gt 0) {
            Write-Host "`nCertification list:" -ForegroundColor Cyan
            $response.data | Format-Table -AutoSize
        }
    }
    
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "Status code: $statusCode" -ForegroundColor Yellow
        
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Yellow
    }
}

