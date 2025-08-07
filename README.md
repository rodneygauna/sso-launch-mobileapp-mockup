# sso-launch-mobileapp-mockup

A mockup application for testing SSO launch functionality with HTTPS support.

## Prerequisites

- Docker and Docker Compose
- PowerShell (Windows) or Bash (Ubuntu/Linux)
- Internet connection (for downloading mkcert)

## HTTPS Setup

This project supports two SSL certificate options:

### Option 1: Let's Encrypt (Recommended for Production)

For production use with real, trusted SSL certificates:

#### Prerequisites for Let's Encrypt

- Your domain must point to the server's public IP address
- Port 80 must be accessible from the internet
- Port 443 must be accessible from the internet

#### Setup

1. **Edit the domain in the script**:
   - Open `setup-letsencrypt.sh`
   - Change `DOMAIN="dev.rodney.codes"` to your domain
   - Change `EMAIL="rodney@rodney.codes"` to your email

2. **Run the Let's Encrypt setup**:

   ```bash
   chmod +x setup-letsencrypt.sh
   ./setup-letsencrypt.sh
   ```

3. **Start the application**:

   ```bash
   docker-compose up --build
   ```

4. **Access your site**:
   - **HTTPS**: <https://yourdomain.com>
   - **HTTP** (redirects): <http://yourdomain.com>

### Option 2: mkcert (For Local Development)

For local development with self-signed certificates:

### First-time setup

#### Windows

1. **Generate SSL certificates** (run as Administrator if using Chocolatey):

   ```powershell
   .\generate-certs.ps1
   ```

#### Ubuntu/Linux

1. **Make the script executable and generate SSL certificates**:

   ```bash
   chmod +x generate-certs.sh
   ./generate-certs.sh
   ```

Both scripts will:

- Install mkcert (if not already installed)
- Create a local Certificate Authority
- Generate SSL certificates for localhost
- Place certificates in the `./certs` directory

1. **Start the application**:

   ```bash
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
