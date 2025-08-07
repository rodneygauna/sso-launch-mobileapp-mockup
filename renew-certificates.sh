#!/bin/bash
# Let's Encrypt certificate renewal script
# This script renews certificates and updates the Docker container

DOMAIN="dev.rodney.codes"
CERTS_DIR="./certs"

echo "Renewing Let's Encrypt certificate for $DOMAIN..."

# Renew the certificate
sudo certbot renew --quiet

# Check if renewal was successful and update local certificates
CERT_PATH="/etc/letsencrypt/live/$DOMAIN"
if [ -f "$CERT_PATH/fullchain.pem" ] && [ -f "$CERT_PATH/privkey.pem" ]; then
    # Copy updated certificates
    sudo cp "$CERT_PATH/fullchain.pem" "$CERTS_DIR/localhost.pem"
    sudo cp "$CERT_PATH/privkey.pem" "$CERTS_DIR/localhost-key.pem"

    # Set proper ownership and permissions
    sudo chown $USER:$USER "$CERTS_DIR/localhost.pem" "$CERTS_DIR/localhost-key.pem"
    chmod 644 "$CERTS_DIR/localhost.pem"
    chmod 600 "$CERTS_DIR/localhost-key.pem"

    # Restart Docker container to use new certificates
    docker-compose restart

    echo "Certificate renewed and container restarted successfully!"
else
    echo "Certificate renewal failed or certificates not found"
    exit 1
fi
