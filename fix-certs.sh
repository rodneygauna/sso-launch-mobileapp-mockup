#!/bin/bash
# Emergency certificate fix - generates working self-signed certificates

echo "=== Emergency Certificate Fix ==="
echo "This will create working self-signed certificates for immediate use"
echo ""

DOMAIN="dev.rodney.codes"
CERTS_DIR="./certs"

# Remove any existing broken certificates
echo "Cleaning up existing certificates..."
rm -rf "$CERTS_DIR"
mkdir -p "$CERTS_DIR"

echo "Generating new self-signed certificates..."

# Create a config file for the certificate
cat > "$CERTS_DIR/cert.conf" << EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = v3_req

[dn]
C=US
ST=State
L=City
O=Organization
OU=OrganizationUnit
CN=$DOMAIN

[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = $DOMAIN
DNS.2 = localhost
DNS.3 = *.rodney.codes
IP.1 = 127.0.0.1
EOF

# Generate the certificate and key
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$CERTS_DIR/localhost-key.pem" \
    -out "$CERTS_DIR/localhost.pem" \
    -config "$CERTS_DIR/cert.conf" \
    -extensions v3_req

# Set proper permissions
chmod 644 "$CERTS_DIR/localhost.pem"
chmod 600 "$CERTS_DIR/localhost-key.pem"

# Verify the certificates were created correctly
if openssl x509 -in "$CERTS_DIR/localhost.pem" -text -noout > /dev/null 2>&1; then
    echo "✅ Certificate created successfully!"
    echo "✅ Certificate is valid"

    echo ""
    echo "Certificate details:"
    openssl x509 -in "$CERTS_DIR/localhost.pem" -subject -dates -noout

    echo ""
    echo "Certificate file: $CERTS_DIR/localhost.pem"
    echo "Private key file: $CERTS_DIR/localhost-key.pem"

    echo ""
    echo "Next steps:"
    echo "1. Run: docker-compose up --build"
    echo "2. Access: https://$DOMAIN (accept browser warning for self-signed cert)"

else
    echo "❌ Failed to create valid certificate"
    exit 1
fi

# Clean up config file
rm "$CERTS_DIR/cert.conf"

echo ""
echo "=== Certificate Fix Complete ==="
