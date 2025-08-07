# sso-launch-mobileapp-mockup

A mockup application for testing SSO launch functionality with HTTPS support.

## Prerequisites

- Docker and Docker Compose
- PowerShell (Windows)
- Internet connection (for downloading mkcert)

## HTTPS Setup

This project uses [mkcert](https://github.com/FiloSottile/mkcert) to generate locally trusted SSL certificates for development.

### First-time setup

1. **Generate SSL certificates** (run as Administrator if using Chocolatey):

   ```powershell
   .\generate-certs.ps1
   ```

   This script will:
   - Install mkcert via Chocolatey (if not already installed)
   - Create a local Certificate Authority
   - Generate SSL certificates for localhost
   - Place certificates in the `./certs` directory

2. **Start the application**:

   ```powershell
   docker-compose up --build
   ```

### Access the application

- **HTTPS (recommended)**: <https://localhost:1443/launch-sso.html>
- **HTTP (redirects to HTTPS)**: <http://localhost:1030/launch-sso.html>

## Manual Certificate Installation (Alternative)

If you prefer not to use the automated script:

1. Install mkcert manually from: <https://github.com/FiloSottile/mkcert/releases>
2. Run these commands:

   ```powershell
   mkdir certs
   cd certs
   mkcert -install
   mkcert localhost 127.0.0.1
   # Rename the generated files to localhost.pem and localhost-key.pem
   cd ..
   docker-compose up --build
   ```

## Security Features

The HTTPS configuration includes:

- TLS 1.2 and 1.3 support
- Modern cipher suites
- Security headers (HSTS, X-Frame-Options, etc.)
- HTTP to HTTPS redirection

## Troubleshooting

- **Certificate not trusted**: Make sure you ran `mkcert -install` as Administrator
- **Port conflicts**: Ensure ports 1030 and 1443 are not in use by other applications
- **Certificate files not found**: Check that the `./certs` directory contains `localhost.pem` and `localhost-key.pem`
