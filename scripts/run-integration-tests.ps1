
$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$Python = Join-Path $ProjectRoot ".venv/Scripts/python.exe"

Set-Location $ProjectRoot

$TestsPassed = $true

# Ensure reports directory exists
New-Item -ItemType Directory -Force -Path "reports" | Out-Null

try {
    # PHASE 1: NORMAL TESTS
    Write-Host "`n===== PHASE 1: NORMAL TESTS =====" -ForegroundColor Cyan

    & $Python -m pytest `
        tests/integration/test_nginx.py `
        tests/integration/test_backend_recovery.py `
        --html=reports/normal-tests.html `
        --self-contained-html

    if ($LASTEXITCODE -ne 0) {
        throw "Normal integration tests failed."
    }

    # PHASE 2: STOP BACKEND
    Write-Host "`n===== PHASE 2: STOP BACKEND =====" -ForegroundColor Cyan

    docker compose stop backend

    if ($LASTEXITCODE -ne 0) {
        throw "Could not stop backend."
    }

    # PHASE 3: FAILURE TESTS
    Write-Host "`n===== PHASE 3: FAILURE TESTS =====" -ForegroundColor Cyan

    & $Python -m pytest `
        tests/integration/test_backend_failure.py `
        --html=reports/backend-failure-tests.html `
        --self-contained-html

    if ($LASTEXITCODE -ne 0) {
        throw "Backend failure tests failed."
    }
}
catch {
    Write-Host "`nERROR: $_" -ForegroundColor Red
    $TestsPassed = $false
}
finally {
    # PHASE 4: RESTORE BACKEND
    Write-Host "`n===== PHASE 4: RESTORING BACKEND =====" -ForegroundColor Cyan

    docker compose start backend

    if ($LASTEXITCODE -ne 0) {
        Write-Host "WARNING: Backend restart command failed." -ForegroundColor Red
        $TestsPassed = $false
    }
    else {
        Write-Host "`nWaiting for backend readiness..." -ForegroundColor Cyan

        $BackendReady = $false

        for ($i = 1; $i -le 30; $i++) {
            try {
                $Response = Invoke-RestMethod `
                    -Uri "http://localhost/api/health" `
                    -TimeoutSec 3

                if ($Response.status -eq "UP") {
                    $BackendReady = $true
                    break
                }
            }
            catch {
                # Backend is still starting.
            }

            Start-Sleep -Seconds 2
        }

        if ($BackendReady) {
            Write-Host "Backend recovered successfully." -ForegroundColor Green
        }
        else {
            Write-Host "Backend did not become healthy within 60 seconds." -ForegroundColor Red
            $TestsPassed = $false
        }
    }
}

# FINAL RESULT
if ($TestsPassed) {
    Write-Host "`nALL INTEGRATION TEST PHASES PASSED." -ForegroundColor Green
    exit 0
}
else {
    Write-Host "`nINTEGRATION TEST EXECUTION FAILED." -ForegroundColor Red
    exit 1
}
