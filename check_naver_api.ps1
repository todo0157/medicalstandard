# Naver Map API Status Check Script
$envFile = "C:\Users\thf56\Documents\medicalstandard\server\.env"

if (-not (Test-Path $envFile)) {
    Write-Host "ERROR: .env file not found: $envFile" -ForegroundColor Red
    exit 1
}

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
    Write-Host "ERROR: API keys not found in .env file" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Checking Naver Map API status..." -ForegroundColor Cyan
Write-Host "Client ID: $($clientId.Substring(0, 4))..." -ForegroundColor Gray
Write-Host ""

$headers = @{
    'X-NCP-APIGW-API-KEY-ID' = $clientId
    'X-NCP-APIGW-API-KEY' = $clientSecret
}

try {
    $response = Invoke-WebRequest -Uri 'https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=서울' -Headers $headers -Method GET -ErrorAction Stop
    $json = $response.Content | ConvertFrom-Json
    
    if ($json.status.code -eq 0) {
        Write-Host "SUCCESS: Subscription is active" -ForegroundColor Green
        Write-Host "Response: $($json.status.message)" -ForegroundColor Gray
        Write-Host "Search results: $($json.addresses.Count) addresses" -ForegroundColor Gray
        Write-Host ""
        Write-Host "API Registration: OK" -ForegroundColor Green
        Write-Host "API Subscription: OK" -ForegroundColor Green
    } else {
        Write-Host "WARNING: Subscription issue" -ForegroundColor Yellow
        Write-Host "Error code: $($json.status.code)" -ForegroundColor Yellow
        Write-Host "Message: $($json.status.message)" -ForegroundColor Yellow
    }
} catch {
    $errorResponse = $null
    try {
        $errorResponse = $_.ErrorDetails.Message | ConvertFrom-Json
    } catch {
        Write-Host "ERROR: Cannot parse response" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
    
    if ($errorResponse.error.errorCode -eq "210") {
        Write-Host "ERROR: Subscription required" -ForegroundColor Red
        Write-Host "Error code: $($errorResponse.error.errorCode)" -ForegroundColor Red
        Write-Host "Message: $($errorResponse.error.message)" -ForegroundColor Red
        Write-Host "Details: $($errorResponse.error.details)" -ForegroundColor Red
        Write-Host ""
        Write-Host "API Registration: OK (API key is valid)" -ForegroundColor Green
        Write-Host "API Subscription: NOT SUBSCRIBED (Subscription required)" -ForegroundColor Red
        Write-Host ""
        Write-Host "Solution:" -ForegroundColor Yellow
        Write-Host "1. Go to Naver Cloud Platform Console" -ForegroundColor Yellow
        Write-Host "2. Maps -> Application -> hanbang -> Subscription Services" -ForegroundColor Yellow
        Write-Host "3. Subscribe to Geocoding and Reverse Geocoding" -ForegroundColor Yellow
    } elseif ($errorResponse.error.errorCode -eq "200") {
        Write-Host "ERROR: Authentication failed" -ForegroundColor Red
        Write-Host "Error code: $($errorResponse.error.errorCode)" -ForegroundColor Red
        Write-Host "Message: $($errorResponse.error.message)" -ForegroundColor Red
        Write-Host "Details: $($errorResponse.error.details)" -ForegroundColor Red
        Write-Host ""
        Write-Host "API Registration: FAILED (API key is invalid or not registered)" -ForegroundColor Red
        Write-Host "API Subscription: CANNOT CHECK" -ForegroundColor Red
        Write-Host ""
        Write-Host "Solution:" -ForegroundColor Yellow
        Write-Host "1. Check API keys in Naver Cloud Platform Console" -ForegroundColor Yellow
        Write-Host "2. Verify NAVER_MAP_CLIENT_ID and NAVER_MAP_CLIENT_SECRET in .env file" -ForegroundColor Yellow
        Write-Host "3. Ensure API keys belong to the correct Application" -ForegroundColor Yellow
    } else {
        Write-Host "ERROR: Unknown error" -ForegroundColor Red
        Write-Host "Error code: $($errorResponse.error.errorCode)" -ForegroundColor Red
        Write-Host "Message: $($errorResponse.error.message)" -ForegroundColor Red
    }
}

Write-Host ""
