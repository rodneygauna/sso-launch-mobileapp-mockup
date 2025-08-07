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

# Install the local CA (this creates the root certificate)
echo "Installing local CA..."
mkcert -install

# Generate certificates for localhost and 127.0.0.1
echo "Generating SSL certificates..."
cd "$CERTS_DIR"
mkcert localhost 127.0.0.1
cd ..

# Rename the generated files to standard names
CERT_FILES=(./certs/localhost+1*.pem)
if [ ${#CERT_FILES[@]} -ge 2 ]; then
    # Find the certificate file (not the key)
    for file in "${CERT_FILES[@]}"; do
        if [[ "$file" == *"localhost+1.pem" && "$file" != *"-key.pem" ]]; then
            mv "$file" "./certs/localhost.pem"
            echo "Renamed certificate file to localhost.pem"
        elif [[ "$file" == *"localhost+1-key.pem" ]]; then
            mv "$file" "./certs/localhost-key.pem"
            echo "Renamed key file to localhost-key.pem"
        fi
    done
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
