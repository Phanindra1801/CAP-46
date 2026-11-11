
param(
    [string]$ExpectedConfig = "candidate-v1"
)

$BaseUrl = "http://localhost"
$Failed = $false

Write-Host "`nStarting CAP-46 smoke tests..." -ForegroundColor Cyan

# Test 1: Frontend availability
try {
    $Frontend = Invoke-WebRequest `
        -Uri "$BaseUrl/" `
        -TimeoutSec 10 `
        -UseBasicParsing

    if ($Frontend.StatusCode -eq 200) {
        Write-Host "[PASS] Frontend is accessible." -ForegroundColor Green
    } else {
        throw "Unexpected frontend status."
    }

    # Verify deployed configuration identifier
    $ConfigHeader = $Frontend.Headers["X-CAP46-Config"]

    if ($ConfigHeader -eq $ExpectedConfig) {
        Write-Host "[PASS] Expected configuration is active." -ForegroundColor Green
    } else {
        throw "Expected $ExpectedConfig but received $ConfigHeader"
    }
}
catch {
    Write-Host "[FAIL] Frontend/configuration test: $_" -ForegroundColor Red
    $Failed = $true
}

# Test 2: Backend health
try {
    $Health = Invoke-RestMethod `
        -Uri "$BaseUrl/api/health" `
        -TimeoutSec 10

    if ($Health.status -eq "UP") {
        Write-Host "[PASS] Backend health is UP." -ForegroundColor Green
    } else {
        throw "Backend did not report UP."
    }
}
catch {
    Write-Host "[FAIL] Backend health test: $_" -ForegroundColor Red
    $Failed = $true
}

# Test 3: Deployment events API
try {
    $Events = Invoke-WebRequest `
        -Uri "$BaseUrl/api/deployment-events" `
        -TimeoutSec 10 `
        -UseBasicParsing

    if ($Events.StatusCode -eq 200) {
        Write-Host "[PASS] Deployment events API is accessible." -ForegroundColor Green
    } else {
        throw "Unexpected API status."
    }
}
catch {
    Write-Host "[FAIL] Deployment events test: $_" -ForegroundColor Red
    $Failed = $true
}

# Final result
if ($Failed) {
    Write-Host "`nSMOKE TESTS FAILED." -ForegroundColor Red
    exit 1
}

Write-Host "`nALL SMOKE TESTS PASSED." -ForegroundColor Green
exit 0
