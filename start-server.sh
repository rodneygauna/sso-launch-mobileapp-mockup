#!/bin/bash
# Script to ensure certificates exist before starting Docker

CERTS_DIR="./certs"
CERT_FILE="$CERTS_DIR/localhost.pem"
KEY_FILE="$CERTS_DIR/localhost-key.pem"

echo "Checking certificates before starting Docker..."

# Check if certificate files exist
if [ ! -f "$CERT_FILE" ] || [ ! -f "$KEY_FILE" ]; then
    echo "❌ Certificate files missing. Generating them now..."
    ./fix-certs.sh
fi

# Verify files are valid
if [ -f "$CERT_FILE" ] && [ -f "$KEY_FILE" ]; then
    echo "✅ Certificate files exist"
    echo "✅ Starting Docker..."
    docker-compose up --build
else
    echo "❌ Failed to create certificate files"
    echo "Run './fix-certs.sh' manually and try again"
    exit 1
fi
