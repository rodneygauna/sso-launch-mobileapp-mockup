#!/bin/bash
# Fallback script to generate self-signed certificates if Let's Encrypt fails
# This creates certificates that will work but show browser warnings

echo "Generating self-signed SSL certificates for testing..."

DOMAIN="dev.rodney.codes"
CERTS_DIR="./certs"

# Create certs directory if it doesn't exist
if [ ! -d "$CERTS_DIR" ]; then
    mkdir -p "$CERTS_DIR"
    echo "Created certs directory"
fi

# Generate self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$CERTS_DIR/localhost-key.pem" \
    -out "$CERTS_DIR/localhost.pem" \
    -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=$DOMAIN"

# Set proper permissions
chmod 644 "$CERTS_DIR/localhost.pem"
chmod 600 "$CERTS_DIR/localhost-key.pem"

echo ""
echo "Self-signed certificates generated successfully!"
echo "Certificate: $CERTS_DIR/localhost.pem"
echo "Private key: $CERTS_DIR/localhost-key.pem"
echo ""
echo "⚠️  Note: These are self-signed certificates and will show browser warnings"
echo "⚠️  For production, use Let's Encrypt with: ./setup-letsencrypt.sh"
echo ""
echo "Next steps:"
echo "1. Run 'docker-compose up --build' to start the server"
echo "2. Access your site at https://$DOMAIN (accept the browser warning)"
