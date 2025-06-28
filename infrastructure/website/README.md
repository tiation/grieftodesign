# GriefToDesign Website Deployment Guide

## Overview

This directory contains the complete infrastructure for deploying the GriefToDesign website on a LEMP stack (Linux, Nginx, MySQL, PHP) with SSL encryption using uncommon ports to avoid conflicts with existing services.

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Nginx       │    │     PHP-FPM     │    │     MySQL       │
│   Port 8443     │◄──►│   Port 9001     │◄──►│   Port 3307     │
│   (HTTPS/SSL)   │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         ▲
         │
┌─────────────────┐
│   Port 8080     │
│   (HTTP→HTTPS)  │
└─────────────────┘
```

## Port Configuration

- **HTTPS**: 8443 (SSL/TLS encrypted)
- **HTTP**: 8080 (redirects to HTTPS)
- **MySQL**: 3307 (custom to avoid conflicts)
- **PHP-FPM**: 9001 (internal communication)

## Quick Start with Docker

### Prerequisites
- Docker and Docker Compose installed
- Git repository cloned

### 1. Clone and Navigate
```bash
cd infrastructure/website
```

### 2. Generate SSL Certificates
```bash
chmod +x generate-ssl.sh
./generate-ssl.sh
```

### 3. Create Required Directories
```bash
mkdir -p logs mysql/init php nginx/sites
```

### 4. Copy Website Content
```bash
# Copy your research documents to html/research/
cp -r ../../drug-policy/ html/research/
cp -r ../../research/ html/research/
cp -r ../../drug-policy/campaigns/ html/campaigns/
```

### 5. Start Services
```bash
docker-compose up -d
```

### 6. Access Website
- **HTTPS**: https://grieftodesign.local:8443
- **HTTP**: http://grieftodesign.local:8080 (redirects to HTTPS)

## Manual LEMP Stack Setup

### Prerequisites
- Ubuntu/Debian server
- Root or sudo access

### 1. Run Deployment Script
```bash
chmod +x deploy-website.sh
./deploy-website.sh
```

### 2. Update Configuration
Edit the domain and ports in the script before running:
```bash
DOMAIN="your-domain.com"  # Change to your actual domain
NGINX_PORT="8443"         # HTTPS port
HTTP_PORT="8080"          # HTTP port (redirects)
MYSQL_PORT="3307"         # MySQL port
```

## Security Features

### SSL/TLS Configuration
- **TLS 1.2 and 1.3** support only
- **Strong cipher suites** with perfect forward secrecy
- **HSTS headers** for forced HTTPS
- **HTTP/2** support for performance

### Security Headers
- `X-Frame-Options: SAMEORIGIN`
- `X-XSS-Protection: 1; mode=block`
- `X-Content-Type-Options: nosniff`
- `Referrer-Policy: no-referrer-when-downgrade`
- `Content-Security-Policy` configured
- `Permissions-Policy` for privacy protection

### Access Controls
- **Rate limiting**: 10 requests/minute per IP
- **File access restrictions**: Hidden dot files, vendor directories
- **Attack pattern blocking**: SQL injection, code execution attempts
- **Directory traversal protection**

### Database Security
- **Custom port** (3307) to avoid automated attacks
- **Restricted user permissions**
- **Local binding only** (127.0.0.1)
- **Secure password requirements**

## File Structure

```
infrastructure/website/
├── docker-compose.yml          # Docker container orchestration
├── deploy-website.sh           # Manual LEMP stack setup
├── generate-ssl.sh            # SSL certificate generation
├── README.md                  # This file
├── html/                      # Website content
│   ├── index.php             # Main website
│   ├── research/             # Research documentation
│   ├── campaigns/            # Email campaign templates
│   └── errors/               # Custom error pages
├── nginx/                    # Nginx configuration
│   └── sites/
│       └── grieftodesign.conf
├── ssl/                      # SSL certificates
│   ├── grieftodesign.crt
│   └── grieftodesign.key
├── logs/                     # Web server logs
├── mysql/                    # MySQL initialization
└── php/                      # PHP configuration
```

## Database Schema

The website automatically creates the following tables:

### newsletter_signups
```sql
CREATE TABLE newsletter_signups (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    signup_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    user_agent TEXT
);
```

## Content Management

### Adding Research Documents
1. Place Markdown files in `html/research/`
2. Update navigation in `index.php` if needed
3. Files are automatically accessible via `/research/` URL

### Email Campaign Templates
1. Add templates to `html/campaigns/`
2. Accessible via `/action-templates/` URL
3. Supports autoindex for easy browsing

### Newsletter Management
- Signups stored in MySQL database
- View signups: `SELECT * FROM newsletter_signups;`
- Export: `SELECT email FROM newsletter_signups;`

## Performance Optimization

### Gzip Compression
- **Enabled** for text files, CSS, JavaScript, JSON
- **Minimum size**: 1024 bytes
- **Vary header** for proxy caching

### Static File Caching
- **1 year expiry** for images, fonts, CSS, JS
- **Immutable cache** headers
- **No-cache** for dynamic content

### Database Optimization
- **Connection pooling** via PHP-FPM
- **Query optimization** with prepared statements
- **Index optimization** for frequent queries

## Monitoring and Logs

### Access Logs
```bash
# Real-time monitoring
tail -f logs/grieftodesign_access.log

# Analysis
grep "404" logs/grieftodesign_access.log
grep "POST" logs/grieftodesign_access.log
```

### Error Logs
```bash
# Check for errors
tail -f logs/grieftodesign_error.log

# PHP errors
tail -f logs/php_errors.log
```

### Database Logs
```bash
# MySQL logs
docker logs grieftodesign-mysql

# Connection monitoring
SHOW PROCESSLIST;
```

## Maintenance

### SSL Certificate Renewal
```bash
# For Let's Encrypt (production)
certbot renew --dry-run

# For self-signed (development)
./generate-ssl.sh
docker-compose restart nginx
```

### Database Backup
```bash
# Create backup
docker exec grieftodesign-mysql mysqldump -u griefweb -p grieftodesign > backup.sql

# Restore backup
docker exec -i grieftodesign-mysql mysql -u griefweb -p grieftodesign < backup.sql
```

### Update Website Content
```bash
# Pull latest changes
git pull origin main

# Copy updated files
cp -r ../../drug-policy/ html/research/
cp -r ../../research/ html/research/

# Restart services if needed
docker-compose restart php
```

## Production Deployment

### Domain Setup
1. **Purchase domain** (grieftodesign.org recommended)
2. **Configure DNS** to point to your server
3. **Update configuration** with actual domain name

### Let's Encrypt SSL
```bash
# Stop containers
docker-compose down

# Get certificate
certbot certonly --standalone --email your@email.com --agree-tos -d grieftodesign.org -d www.grieftodesign.org

# Update nginx configuration
# Point to /etc/letsencrypt/live/grieftodesign.org/

# Restart
docker-compose up -d
```

### Firewall Configuration
```bash
# Allow HTTP and HTTPS on custom ports
ufw allow 8080/tcp
ufw allow 8443/tcp

# Deny MySQL from external access
ufw deny 3307/tcp
```

### Backup Strategy
```bash
# Daily database backup
0 2 * * * /usr/local/bin/backup-database.sh

# Weekly file backup
0 3 * * 0 /usr/local/bin/backup-files.sh

# Monitor disk space
0 1 * * * /usr/local/bin/check-disk-space.sh
```

## Troubleshooting

### Common Issues

#### SSL Certificate Errors
```bash
# Check certificate validity
openssl x509 -in ssl/grieftodesign.crt -text -noout

# Regenerate if needed
./generate-ssl.sh
docker-compose restart nginx
```

#### Database Connection Issues
```bash
# Check MySQL status
docker logs grieftodesign-mysql

# Test connection
docker exec -it grieftodesign-mysql mysql -u griefweb -p grieftodesign

# Reset password if needed
docker exec -it grieftodesign-mysql mysql -u root -p
ALTER USER 'griefweb'@'localhost' IDENTIFIED BY 'new_password';
```

#### Permission Issues
```bash
# Fix file permissions
sudo chown -R www-data:www-data html/
sudo chmod -R 755 html/
sudo chmod -R 644 html/*.php

# Fix SSL permissions
chmod 600 ssl/grieftodesign.key
chmod 644 ssl/grieftodesign.crt
```

#### Port Conflicts
```bash
# Check port usage
netstat -tlnp | grep :8443
netstat -tlnp | grep :8080
netstat -tlnp | grep :3307

# Change ports in docker-compose.yml if needed
```

### Log Analysis

#### High Traffic
```bash
# Top IP addresses
awk '{print $1}' logs/grieftodesign_access.log | sort | uniq -c | sort -nr | head -10

# Most requested pages
awk '{print $7}' logs/grieftodesign_access.log | sort | uniq -c | sort -nr | head -10
```

#### Security Monitoring
```bash
# Failed login attempts
grep "401\|403" logs/grieftodesign_access.log

# Suspicious requests
grep -E "(union|select|script|base64)" logs/grieftodesign_access.log
```

## Security Checklist

- [ ] SSL certificate installed and valid
- [ ] HTTP redirects to HTTPS
- [ ] Security headers configured
- [ ] Rate limiting enabled
- [ ] Database on non-standard port
- [ ] File permissions properly set
- [ ] Directory listing disabled for sensitive areas
- [ ] Backup strategy implemented
- [ ] Monitoring and logging configured
- [ ] Firewall rules applied

## Support and Contributing

### Getting Help
- Check logs first: `docker-compose logs`
- Review this README thoroughly
- Open GitHub issue with relevant logs

### Contributing
- Follow existing code style
- Test changes locally first
- Update documentation as needed
- Submit pull requests for review

## License

This infrastructure is part of the GriefToDesign project, licensed under Creative Commons Attribution 4.0 (CC BY 4.0).

---

**Transforming loss into systemic change through evidence-based advocacy and secure digital infrastructure.**
