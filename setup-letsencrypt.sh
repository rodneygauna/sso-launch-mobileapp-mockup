#!/bin/bash
# Let's Encrypt SSL certificate setup script for Ubuntu/Linux
# This script will install Certbot and generate real SSL certificates

echo "Setting up Let's Encrypt SSL certificates..."

# Check if domain is provided
DOMAIN="dev.rodney.codes"
EMAIL="rodneygauna@gmail.com"  # Change this to your email

echo "Domain: $DOMAIN"
echo "Email: $EMAIL"

# Detect the distribution and install Certbot
if command -v apt-get &> /dev/null; then
    # Ubuntu/Debian
    echo "Detected Ubuntu/Debian. Installing Certbot..."

    # Update package list
    sudo apt-get update

    # Install snapd if not already installed
    sudo apt-get install -y snapd

    # Install certbot via snap (recommended method)
    sudo snap install core; sudo snap refresh core
    sudo snap install --classic certbot

    # Create symlink
    sudo ln -sf /snap/bin/certbot /usr/bin/certbot

elif command -v yum &> /dev/null; then
    # RHEL/CentOS/Fedora
    echo "Detected RHEL/CentOS/Fedora. Installing Certbot..."

    # Install EPEL repository if needed
    sudo yum install -y epel-release
    sudo yum install -y certbot

elif command -v pacman &> /dev/null; then
    # Arch Linux
    echo "Detected Arch Linux. Installing Certbot..."
    sudo pacman -S certbot

else
    echo "Unsupported distribution. Please install Certbot manually:"
    echo "Visit: https://certbot.eff.org/instructions"
    exit 1
fi

# Verify Certbot installation
if ! command -v certbot &> /dev/null; then
    echo "Failed to install Certbot. Please install manually."
    exit 1
fi

echo "Certbot installed successfully!"

# Create certs directory if it doesn't exist
CERTS_DIR="./certs"
if [ ! -d "$CERTS_DIR" ]; then
    mkdir -p "$CERTS_DIR"
    echo "Created certs directory"
fi

# Ensure proper permissions on certs directory
chmod 755 "$CERTS_DIR"

echo ""
echo "=== IMPORTANT: DNS Setup Required ==="
echo "Before proceeding, ensure that:"
echo "1. Your domain '$DOMAIN' points to this server's public IP address"
echo "2. Port 80 is accessible from the internet (for HTTP challenge)"
echo "3. Your firewall allows incoming connections on port 80"
echo ""
echo "You can check your DNS with: nslookup $DOMAIN"
echo "You can check your public IP with: curl ifconfig.me"
echo ""
read -p "Press Enter when DNS is configured and port 80 is accessible..."

# Stop any running containers that might be using port 80
echo "Stopping any running containers..."
sudo docker compose down 2>/dev/null || true

# Generate certificate using standalone method
echo "Generating Let's Encrypt certificate for $DOMAIN..."
sudo certbot certonly \
    --standalone \
    --non-interactive \
    --agree-tos \
    --email "$EMAIL" \
    -d "$DOMAIN"

# Check if certificate was generated successfully
CERT_PATH="/etc/letsencrypt/live/$DOMAIN"
if [ -f "$CERT_PATH/fullchain.pem" ] && [ -f "$CERT_PATH/privkey.pem" ]; then
    echo "Certificate generated successfully!"

    # Copy certificates to our certs directory with proper permissions
    sudo cp "$CERT_PATH/fullchain.pem" "$CERTS_DIR/localhost.pem"
    sudo cp "$CERT_PATH/privkey.pem" "$CERTS_DIR/localhost-key.pem"

    # Set proper ownership and permissions
    sudo chown $USER:$USER "$CERTS_DIR/localhost.pem" "$CERTS_DIR/localhost-key.pem"
    chmod 644 "$CERTS_DIR/localhost.pem"
    chmod 600 "$CERTS_DIR/localhost-key.pem"

    echo "Certificates copied to $CERTS_DIR/"
    echo "Certificate: $CERTS_DIR/localhost.pem"
    echo "Private key: $CERTS_DIR/localhost-key.pem"
else
    echo "ERROR: Failed to generate Let's Encrypt certificate"
    echo "Common issues:"
    echo "1. Domain doesn't point to this server"
    echo "2. Port 80 is not accessible from internet"
    echo "3. Firewall blocking connections"
    echo "4. Another service is using port 80"
    exit 1
fi

# Set up automatic renewal
echo "Setting up automatic certificate renewal..."
echo "0 12 * * * /usr/bin/certbot renew --quiet --post-hook 'sudo docker compose restart'" | sudo crontab -

echo ""
echo "=== Setup Complete! ==="
echo "✅ Let's Encrypt certificate generated for $DOMAIN"
echo "✅ Automatic renewal configured (daily check at 12:00)"
echo "✅ Certificates copied to ./certs directory"
echo ""
echo "Next steps:"
echo "1. Run 'sudo docker compose up --build' to start the HTTPS server"
echo "2. Access your site at https://$DOMAIN"
echo ""
echo "Certificate details:"
echo "- Valid for: $DOMAIN"
echo "- Expires: $(sudo certbot certificates 2>/dev/null | grep "Expiry Date" | head -1 || echo 'Run: sudo certbot certificates')"
echo "- Auto-renewal: Enabled via cron"
