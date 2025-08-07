#!/bin/bash
# Certificate diagnostic script

echo "=== SSL Certificate Diagnostics ==="
echo ""

CERTS_DIR="./certs"
CERT_FILE="$CERTS_DIR/localhost.pem"
KEY_FILE="$CERTS_DIR/localhost-key.pem"

echo "1. Checking certificate directory..."
if [ -d "$CERTS_DIR" ]; then
    echo "✅ Certs directory exists"
    ls -la "$CERTS_DIR"
else
    echo "❌ Certs directory does not exist"
    echo "Run: mkdir -p $CERTS_DIR"
    exit 1
fi

echo ""
echo "2. Checking certificate file..."
if [ -f "$CERT_FILE" ]; then
    echo "✅ Certificate file exists"
    echo "File size: $(du -h "$CERT_FILE" | cut -f1)"
    echo "File type: $(file "$CERT_FILE")"
    echo "First 5 lines:"
    head -5 "$CERT_FILE"
    echo ""

    # Check if it's a valid certificate
    if openssl x509 -in "$CERT_FILE" -text -noout > /dev/null 2>&1; then
        echo "✅ Certificate file is valid"
        echo "Certificate details:"
        openssl x509 -in "$CERT_FILE" -subject -dates -noout
    else
        echo "❌ Certificate file is invalid or corrupted"
        echo "Certificate file content:"
        cat "$CERT_FILE"
    fi
else
    echo "❌ Certificate file does not exist: $CERT_FILE"
fi

echo ""
echo "3. Checking private key file..."
if [ -f "$KEY_FILE" ]; then
    echo "✅ Private key file exists"
    echo "File size: $(du -h "$KEY_FILE" | cut -f1)"
    echo "File type: $(file "$KEY_FILE")"
    echo "First 5 lines:"
    head -5 "$KEY_FILE"
    echo ""

    # Check if it's a valid private key
    if openssl rsa -in "$KEY_FILE" -check -noout > /dev/null 2>&1; then
        echo "✅ Private key file is valid"
    else
        echo "❌ Private key file is invalid or corrupted"
        echo "Private key file content:"
        cat "$KEY_FILE"
    fi
else
    echo "❌ Private key file does not exist: $KEY_FILE"
fi

echo ""
echo "4. Recommendations:"
if [ ! -f "$CERT_FILE" ] || [ ! -f "$KEY_FILE" ]; then
    echo "❌ Missing certificate files. Run one of these:"
    echo "   - For self-signed: ./generate-selfsigned-certs.sh"
    echo "   - For Let's Encrypt: ./setup-letsencrypt.sh"
elif ! openssl x509 -in "$CERT_FILE" -text -noout > /dev/null 2>&1; then
    echo "❌ Invalid certificate. Regenerate with:"
    echo "   - For self-signed: ./generate-selfsigned-certs.sh"
    echo "   - For Let's Encrypt: ./setup-letsencrypt.sh"
elif ! openssl rsa -in "$KEY_FILE" -check -noout > /dev/null 2>&1; then
    echo "❌ Invalid private key. Regenerate with:"
    echo "   - For self-signed: ./generate-selfsigned-certs.sh"
    echo "   - For Let's Encrypt: ./setup-letsencrypt.sh"
else
    echo "✅ Certificates look good! Docker should work."
    echo "If still having issues, check Docker volume mounts in docker-compose.yml"
fi

echo ""
echo "=== End Diagnostics ==="
