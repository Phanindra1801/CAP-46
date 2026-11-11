
param(
    [Parameter(Mandatory = $true)]
    [string]$Candidate
)

# Find the project root
$ProjectRoot = Split-Path -Parent $PSScriptRoot

# Define file paths
$CandidatePath = Join-Path $ProjectRoot "nginx/candidates/$Candidate"
$TemporaryPath = Join-Path $ProjectRoot "nginx/candidates/candidate-under-test.conf"

# Check candidate existence
if (-not (Test-Path $CandidatePath)) {
    Write-Host "ERROR: Candidate configuration not found." -ForegroundColor Red
    exit 1
}

Write-Host "Starting Nginx candidate validation..." -ForegroundColor Cyan

try {
    # Copy candidate to temporary validation filename
    Copy-Item $CandidatePath $TemporaryPath -Force

    Write-Host "Candidate copied successfully."

    # Validate using isolated Nginx configuration
    docker compose exec -T nginx nginx -t -c /etc/nginx/validation/nginx.conf

    $ValidationExitCode = $LASTEXITCODE

    if ($ValidationExitCode -ne 0) {
        Write-Host "VALIDATION FAILED. Candidate rejected." -ForegroundColor Red
        exit 1
    }

    Write-Host "VALIDATION SUCCESSFUL. Candidate is valid." -ForegroundColor Green
}
finally {
    # Always remove temporary candidate file
    if (Test-Path $TemporaryPath) {
        Remove-Item $TemporaryPath -Force
        Write-Host "Temporary validation file removed."
    }
}
