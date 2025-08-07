# PowerShell script to generate SSL certificates using mkcert
# This script will install mkcert (if not already installed) and generate certificates

Write-Host "Setting up HTTPS certificates using mkcert..." -ForegroundColor Green

# Check if mkcert is installed
$mkcertPath = Get-Command mkcert -ErrorAction SilentlyContinue

if (-not $mkcertPath) {
    Write-Host "mkcert not found. Installing via Chocolatey..." -ForegroundColor Yellow

    # Check if Chocolatey is installed
    $chocoPath = Get-Command choco -ErrorAction SilentlyContinue

    if (-not $chocoPath) {
        Write-Host "Chocolatey not found. Please install Chocolatey first:" -ForegroundColor Red
        Write-Host "Run this command in an admin PowerShell:"
        Write-Host "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
        Write-Host ""
        Write-Host "Alternative: Download mkcert manually from https://github.com/FiloSottile/mkcert/releases"
        exit 1
    }

    Write-Host "Installing mkcert..."
    choco install mkcert -y

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to install mkcert via Chocolatey. Please install manually from https://github.com/FiloSottile/mkcert/releases" -ForegroundColor Red
        exit 1
    }
}

# Create certs directory if it doesn't exist
$certsDir = ".\certs"
if (-not (Test-Path $certsDir)) {
    New-Item -ItemType Directory -Path $certsDir | Out-Null
    Write-Host "Created certs directory"
}

# Install the local CA (this creates the root certificate)
Write-Host "Installing local CA..."
mkcert -install

# Generate certificates for localhost and 127.0.0.1
Write-Host "Generating SSL certificates..."
Set-Location $certsDir
mkcert localhost 127.0.0.1
Set-Location ..

# Rename the generated files to standard names
$certFiles = Get-ChildItem -Path $certsDir -Name "localhost+1*.pem"
if ($certFiles.Count -ge 2) {
    $certFile = $certFiles | Where-Object { $_ -like "*localhost+1.pem" -and $_ -notlike "*-key.pem" } | Select-Object -First 1
    $keyFile = $certFiles | Where-Object { $_ -like "*localhost+1-key.pem" } | Select-Object -First 1

    if ($certFile) {
        Rename-Item -Path ".\certs\$certFile" -NewName "localhost.pem"
        Write-Host "Renamed certificate file to localhost.pem"
    }

    if ($keyFile) {
        Rename-Item -Path ".\certs\$keyFile" -NewName "localhost-key.pem"
        Write-Host "Renamed key file to localhost-key.pem"
    }
}

Write-Host ""
Write-Host "SSL certificates generated successfully!" -ForegroundColor Green
Write-Host "Certificate files are located in the ./certs directory"
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Run 'docker-compose up --build' to start the HTTPS-enabled server"
Write-Host "2. Access your site at https://localhost:1443"
