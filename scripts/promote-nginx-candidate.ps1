
param(
    [Parameter(Mandatory = $true)]
    [string]$Candidate
)

$ProjectRoot = Split-Path -Parent $PSScriptRoot

$CandidatePath = Join-Path $ProjectRoot "nginx/candidates/$Candidate"
$ActivePath = Join-Path $ProjectRoot "nginx/active/default.conf"
$BackupDirectory = Join-Path $ProjectRoot "nginx/backups"

$ExpectedConfig = [System.IO.Path]::GetFileNameWithoutExtension($Candidate)

# Check candidate existence
if (-not (Test-Path $CandidatePath)) {
    Write-Host "ERROR: Candidate not found." -ForegroundColor Red
    exit 1
}

# Validate candidate before promotion
Write-Host "Validating candidate..." -ForegroundColor Cyan

& "$PSScriptRoot/validate-nginx-candidate.ps1" -Candidate $Candidate

if ($LASTEXITCODE -ne 0) {
    Write-Host "Candidate validation failed. Deployment cancelled." -ForegroundColor Red
    exit 1
}

# Create timestamped backup
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$BackupPath = Join-Path $BackupDirectory "default-$Timestamp.conf"

Copy-Item $ActivePath $BackupPath -Force

Write-Host "Backup created: $BackupPath" -ForegroundColor Cyan

# Promote candidate
Copy-Item $CandidatePath $ActivePath -Force

Write-Host "Candidate promoted. Checking active configuration..."

docker compose exec -T nginx nginx -t

if ($LASTEXITCODE -ne 0) {
    Write-Host "Active configuration invalid. Rolling back..." -ForegroundColor Red
    Copy-Item $BackupPath $ActivePath -Force
    docker compose exec -T nginx nginx -t
    exit 1
}

# Graceful reload
docker compose exec -T nginx nginx -s reload

if ($LASTEXITCODE -ne 0) {
    Write-Host "Nginx reload failed. Rolling back..." -ForegroundColor Red
    Copy-Item $BackupPath $ActivePath -Force
    docker compose exec -T nginx nginx -s reload
    exit 1
}

# Run functional smoke tests
Write-Host "Running functional smoke tests..." -ForegroundColor Cyan

$ExpectedConfig = [System.IO.Path]::GetFileNameWithoutExtension($Candidate)

powershell.exe -NoProfile -ExecutionPolicy Bypass `
    -File "$PSScriptRoot/test-nginx-smoke.ps1" `
    -ExpectedConfig $ExpectedConfig

if ($LASTEXITCODE -ne 0) {
    Write-Host "SMOKE TESTS FAILED. Starting automatic rollback..." -ForegroundColor Red

    Copy-Item $BackupPath $ActivePath -Force

    docker compose exec -T nginx nginx -t

    if ($LASTEXITCODE -ne 0) {
        Write-Host "CRITICAL: Restored configuration failed validation." -ForegroundColor Red
        exit 2
    }

    docker compose exec -T nginx nginx -s reload

    if ($LASTEXITCODE -ne 0) {
        Write-Host "CRITICAL: Nginx reload failed during rollback." -ForegroundColor Red
        exit 2
    }

    Write-Host "ROLLBACK COMPLETED. Previous configuration restored." -ForegroundColor Yellow
    exit 1
}

Write-Host "DEPLOYMENT SUCCESSFUL. All smoke tests passed." -ForegroundColor Green
Write-Host "Backup retained at: $BackupPath"
