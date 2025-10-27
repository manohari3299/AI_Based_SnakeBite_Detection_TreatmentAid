# PowerShell script to start the FastAPI backend server
# Run this before testing the mobile app

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SnakeBite AI - Backend Server Setup  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to Integrate_detect directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# Check if Python is installed
Write-Host "Checking Python installation..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    Write-Host "✓ Found: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Python not found! Please install Python 3.11 or higher." -ForegroundColor Red
    exit 1
}

# Check if virtual environment exists
if (Test-Path ".\.venv\Scripts\Activate.ps1") {
    Write-Host "✓ Virtual environment found" -ForegroundColor Green
    Write-Host "Activating virtual environment..." -ForegroundColor Yellow
    & .\.venv\Scripts\Activate.ps1
} else {
    Write-Host "Creating virtual environment..." -ForegroundColor Yellow
    python -m venv .venv
    & .\.venv\Scripts\Activate.ps1
    
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    Write-Host "(This may take several minutes...)" -ForegroundColor Gray
    pip install --upgrade pip
    pip install -r requirements.txt
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Getting Network Configuration        " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get local IP address
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254.*"} | Select-Object -First 1).IPAddress

if ($ipAddress) {
    Write-Host "Your computer's IP address: $ipAddress" -ForegroundColor Green
    Write-Host ""
    Write-Host "IMPORTANT: Update your Flutter app's API configuration:" -ForegroundColor Yellow
    Write-Host "  File: lib/services/api_service.dart" -ForegroundColor White
    Write-Host "  Change: static const String _baseUrl = 'http://10.0.2.2:8000';" -ForegroundColor White
    Write-Host "  To:     static const String _baseUrl = 'http://${ipAddress}:8000';" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host "Could not detect IP address. Using localhost..." -ForegroundColor Yellow
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Starting Backend Server               " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Server will be available at:" -ForegroundColor Yellow
Write-Host "  • Local:   http://localhost:8000" -ForegroundColor White
Write-Host "  • Network: http://${ipAddress}:8000" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Gray
Write-Host ""

# Set environment variables
$env:SKIP_MODEL_LOADING = "0"
$env:API_KEY = "changeme"
$env:ALLOWED_ORIGINS = "*"

# Start the server
uvicorn app:app --host 0.0.0.0 --port 8000 --reload
