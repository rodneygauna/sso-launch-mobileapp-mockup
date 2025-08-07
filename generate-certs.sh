#!/bin/bash
# Bash script to generate SSL certificates using mkcert on Ubuntu/Linux
# This script will install mkcert (if not already installed) and generate certificates

echo "Setting up HTTPS certificates using mkcert..."

# Check if mkcert is installed
if ! command -v mkcert &> /dev/null; then
    echo "mkcert not found. Installing..."

    # Detect the distribution and install accordingly
    if command -v apt-get &> /dev/null; then
        # Ubuntu/Debian
        echo "Detected Ubuntu/Debian. Installing mkcert..."

        # Update package list
        sudo apt-get update

        # Install required dependencies
        sudo apt-get install -y wget libnss3-tools

        # Download and install mkcert
        MKCERT_VERSION="v1.4.4"
        wget -O mkcert "https://github.com/FiloSottile/mkcert/releases/download/${MKCERT_VERSION}/mkcert-${MKCERT_VERSION}-linux-amd64"
        chmod +x mkcert
        sudo mv mkcert /usr/local/bin/

    elif command -v yum &> /dev/null; then
        # RHEL/CentOS/Fedora
        echo "Detected RHEL/CentOS/Fedora. Installing mkcert..."

        # Install required dependencies
        sudo yum install -y wget nss-tools

        # Download and install mkcert
        MKCERT_VERSION="v1.4.4"
        wget -O mkcert "https://github.com/FiloSottile/mkcert/releases/download/${MKCERT_VERSION}/mkcert-${MKCERT_VERSION}-linux-amd64"
        chmod +x mkcert
        sudo mv mkcert /usr/local/bin/

    elif command -v pacman &> /dev/null; then
        # Arch Linux
        echo "Detected Arch Linux. Installing mkcert..."
        sudo pacman -S mkcert

    else
        echo "Unsupported distribution. Please install mkcert manually:"
        echo "1. Download from: https://github.com/FiloSottile/mkcert/releases"
        echo "2. Make it executable and move to /usr/local/bin/"
        exit 1
    fi

    # Verify installation
    if ! command -v mkcert &> /dev/null; then
        echo "Failed to install mkcert. Please install manually."
        exit 1
    fi

    echo "mkcert installed successfully!"
fi

# Create certs directory if it doesn't exist
CERTS_DIR="./certs"
if [ ! -d "$CERTS_DIR" ]; then
    mkdir -p "$CERTS_DIR"
    echo "Created certs directory"
fi

# Ensure proper permissions on certs directory
chmod 755 "$CERTS_DIR"

# Install the local CA (this creates the root certificate)
echo "Installing local CA..."
mkcert -install

# Generate certificates for localhost and 127.0.0.1
echo "Generating SSL certificates..."
# Generate certificates in the current directory first, then move them
mkcert -cert-file "$CERTS_DIR/localhost.pem" -key-file "$CERTS_DIR/localhost-key.pem" localhost 127.0.0.1 dev.rodney.codes

# Check if certificates were created successfully
if [ -f "$CERTS_DIR/localhost.pem" ] && [ -f "$CERTS_DIR/localhost-key.pem" ]; then
    echo "Certificates generated successfully!"
    echo "Certificate: $CERTS_DIR/localhost.pem"
    echo "Private key: $CERTS_DIR/localhost-key.pem"
else
    echo "ERROR: Failed to generate certificates. Trying alternative method..."

    # Alternative method: generate in temp location and copy
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    mkcert localhost 127.0.0.1 dev.rodney.codes

    # Find and copy the generated files
    CERT_FILE=$(find . -name "*localhost+1.pem" ! -name "*-key.pem" | head -1)
    KEY_FILE=$(find . -name "*localhost+1-key.pem" | head -1)

    if [ -n "$CERT_FILE" ] && [ -n "$KEY_FILE" ]; then
        cp "$CERT_FILE" "$(dirname "$0")/$CERTS_DIR/localhost.pem"
        cp "$KEY_FILE" "$(dirname "$0")/$CERTS_DIR/localhost-key.pem"
        echo "Certificates copied successfully!"
    else
        echo "ERROR: Could not generate certificates"
        exit 1
    fi

    cd "$(dirname "$0")"
    rm -rf "$TEMP_DIR"
fi

echo ""
echo "SSL certificates generated successfully!"
echo "Certificate files are located in the ./certs directory"
echo ""
echo "Next steps:"
echo "1. Run 'docker-compose up --build' to start the HTTPS-enabled server"
echo "2. Access your site at https://localhost:1443"
echo ""
echo "Note: On Ubuntu, you may need to install the CA certificate in your browser:"
echo "- The CA certificate is usually located at: \$(mkcert -CAROOT)/rootCA.pem"
echo "- For Firefox: Import the certificate in Settings > Privacy & Security > Certificates"
echo "- For Chrome: The certificate should be automatically trusted if installed correctly"
