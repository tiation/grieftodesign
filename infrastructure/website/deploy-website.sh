#!/bin/bash

# Grieftodesign Website Deployment Script
# Sets up LEMP stack on uncommon ports with SSL

set -e

# Configuration
DOMAIN="grieftodesign.local"  # Change to your actual domain
NGINX_PORT="8443"  # Uncommon HTTPS port
HTTP_PORT="8080"   # Uncommon HTTP port
MYSQL_PORT="3307"  # Uncommon MySQL port
PHP_PORT="9001"    # PHP-FPM port

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting grieftodesign website deployment...${NC}"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}This script should not be run as root${NC}" 
   exit 1
fi

# Create project directories
echo -e "${YELLOW}Creating project directories...${NC}"
mkdir -p ~/grieftodesign-web/{nginx,ssl,logs,html,php,mysql}
cd ~/grieftodesign-web

# Install dependencies (assuming Ubuntu/Debian)
echo -e "${YELLOW}Installing LEMP stack components...${NC}"
sudo apt update
sudo apt install -y nginx mysql-server php8.1-fpm php8.1-mysql php8.1-curl php8.1-json php8.1-mbstring php8.1-xml php8.1-zip php8.1-gd openssl

# Configure MySQL on custom port
echo -e "${YELLOW}Configuring MySQL on port ${MYSQL_PORT}...${NC}"
sudo tee /etc/mysql/mysql.conf.d/grieftodesign.cnf > /dev/null <<EOF
[mysqld]
port = ${MYSQL_PORT}
bind-address = 127.0.0.1
EOF

sudo systemctl restart mysql

# Create MySQL database and user
echo -e "${YELLOW}Setting up database...${NC}"
sudo mysql -P ${MYSQL_PORT} -e "CREATE DATABASE IF NOT EXISTS grieftodesign;"
sudo mysql -P ${MYSQL_PORT} -e "CREATE USER IF NOT EXISTS 'griefweb'@'localhost' IDENTIFIED BY 'secure_password_2024!';"
sudo mysql -P ${MYSQL_PORT} -e "GRANT ALL PRIVILEGES ON grieftodesign.* TO 'griefweb'@'localhost';"
sudo mysql -P ${MYSQL_PORT} -e "FLUSH PRIVILEGES;"

# Generate SSL certificate (self-signed for development)
echo -e "${YELLOW}Generating SSL certificate...${NC}"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ssl/grieftodesign.key \
    -out ssl/grieftodesign.crt \
    -subj "/C=AU/ST=NSW/L=Sydney/O=Grieftodesign/OU=Web/CN=${DOMAIN}"

# Configure PHP-FPM
echo -e "${YELLOW}Configuring PHP-FPM...${NC}"
sudo tee /etc/php/8.1/fpm/pool.d/grieftodesign.conf > /dev/null <<EOF
[grieftodesign]
user = www-data
group = www-data
listen = 127.0.0.1:${PHP_PORT}
listen.owner = www-data
listen.group = www-data
pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35
pm.process_idle_timeout = 10s
pm.max_requests = 500
php_admin_value[disable_functions] = exec,passthru,shell_exec,system
php_admin_flag[allow_url_fopen] = off
EOF

sudo systemctl restart php8.1-fpm

# Create Nginx configuration
echo -e "${YELLOW}Configuring Nginx...${NC}"
sudo tee /etc/nginx/sites-available/grieftodesign > /dev/null <<EOF
server {
    listen ${HTTP_PORT};
    server_name ${DOMAIN} www.${DOMAIN};
    return 301 https://\$server_name:${NGINX_PORT}\$request_uri;
}

server {
    listen ${NGINX_PORT} ssl http2;
    server_name ${DOMAIN} www.${DOMAIN};
    
    root $(pwd)/html;
    index index.php index.html index.htm;
    
    # SSL Configuration
    ssl_certificate $(pwd)/ssl/grieftodesign.crt;
    ssl_certificate_key $(pwd)/ssl/grieftodesign.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate max-age=0;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
    
    # Rate limiting
    limit_req_zone \$binary_remote_addr zone=grieftodesign:10m rate=10r/m;
    limit_req zone=grieftodesign burst=20 nodelay;
    
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    
    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:${PHP_PORT};
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
        
        # Security
        fastcgi_hide_header X-Powered-By;
        fastcgi_read_timeout 300;
    }
    
    # Deny access to sensitive files
    location ~ /\. {
        deny all;
    }
    
    location ~ /(vendor|storage|bootstrap/cache|config|database|resources|routes|tests)/ {
        deny all;
    }
    
    # Cache static files
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Logs
    access_log $(pwd)/logs/access.log;
    error_log $(pwd)/logs/error.log;
}
EOF

# Enable the site
sudo ln -sf /etc/nginx/sites-available/grieftodesign /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

echo -e "${GREEN}LEMP stack configured successfully!${NC}"
echo -e "${YELLOW}Ports configured:${NC}"
echo -e "  HTTPS: ${NGINX_PORT}"
echo -e "  HTTP: ${HTTP_PORT} (redirects to HTTPS)"
echo -e "  MySQL: ${MYSQL_PORT}"
echo -e "  PHP-FPM: ${PHP_PORT}"

echo -e "${GREEN}Next steps:${NC}"
echo -e "1. Copy your website files to: $(pwd)/html"
echo -e "2. Update your DNS or hosts file to point ${DOMAIN} to this server"
echo -e "3. Access your site at: https://${DOMAIN}:${NGINX_PORT}"
echo -e "4. For production, replace self-signed SSL with proper certificate"

# Make the script executable
chmod +x ~/grieftodesign-web/deploy-website.sh
