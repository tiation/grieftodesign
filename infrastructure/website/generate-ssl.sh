#!/bin/bash

# SSL Certificate Generation for GriefToDesign Website
# For local development - use Let's Encrypt for production

set -e

# Configuration
DOMAIN="grieftodesign.local"
SSL_DIR="./ssl"
DAYS=365

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Generating SSL certificates for GriefToDesign...${NC}"

# Create SSL directory if it doesn't exist
mkdir -p $SSL_DIR

# Check if certificates already exist
if [[ -f "$SSL_DIR/grieftodesign.crt" && -f "$SSL_DIR/grieftodesign.key" ]]; then
    echo -e "${YELLOW}SSL certificates already exist. Regenerating...${NC}"
    rm -f $SSL_DIR/grieftodesign.crt $SSL_DIR/grieftodesign.key
fi

# Generate private key
echo -e "${YELLOW}Generating private key...${NC}"
openssl genrsa -out $SSL_DIR/grieftodesign.key 2048

# Create certificate configuration
echo -e "${YELLOW}Creating certificate configuration...${NC}"
cat > $SSL_DIR/grieftodesign.conf <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = v3_req

[dn]
C=AU
ST=New South Wales
L=Sydney
O=GriefToDesign
OU=Research Division
CN=$DOMAIN

[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = $DOMAIN
DNS.2 = www.$DOMAIN
DNS.3 = grieftodesign.org
DNS.4 = www.grieftodesign.org
DNS.5 = localhost
IP.1 = 127.0.0.1
IP.2 = ::1
EOF

# Generate certificate signing request
echo -e "${YELLOW}Generating certificate signing request...${NC}"
openssl req -new -key $SSL_DIR/grieftodesign.key -out $SSL_DIR/grieftodesign.csr -config $SSL_DIR/grieftodesign.conf

# Generate self-signed certificate
echo -e "${YELLOW}Generating self-signed certificate...${NC}"
openssl x509 -req -in $SSL_DIR/grieftodesign.csr -signkey $SSL_DIR/grieftodesign.key -out $SSL_DIR/grieftodesign.crt -days $DAYS -extensions v3_req -extfile $SSL_DIR/grieftodesign.conf

# Set appropriate permissions
chmod 600 $SSL_DIR/grieftodesign.key
chmod 644 $SSL_DIR/grieftodesign.crt

# Clean up
rm $SSL_DIR/grieftodesign.csr $SSL_DIR/grieftodesign.conf

# Verify certificate
echo -e "${YELLOW}Verifying certificate...${NC}"
openssl x509 -in $SSL_DIR/grieftodesign.crt -text -noout | grep -E "(Subject:|Issuer:|Not Before:|Not After :|DNS:|IP Address:)"

echo -e "${GREEN}SSL certificates generated successfully!${NC}"
echo -e "${YELLOW}Certificate: $SSL_DIR/grieftodesign.crt${NC}"
echo -e "${YELLOW}Private Key: $SSL_DIR/grieftodesign.key${NC}"
echo -e "${YELLOW}Valid for: $DAYS days${NC}"

echo -e "\n${YELLOW}For local development, add this to your /etc/hosts file:${NC}"
echo -e "127.0.0.1    $DOMAIN"
echo -e "127.0.0.1    www.$DOMAIN"

echo -e "\n${YELLOW}For production, replace with Let's Encrypt certificates:${NC}"
echo -e "certbot certonly --webroot --webroot-path=/var/www/html --email your@email.com --agree-tos --no-eff-email -d your-domain.com"

echo -e "\n${GREEN}Certificate information:${NC}"
openssl x509 -in $SSL_DIR/grieftodesign.crt -noout -dates -subject -issuer
