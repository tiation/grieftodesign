# Mesh Network Admin Server Guide

This comprehensive guide covers the setup, configuration, and management of the Mesh Network Admin Server, which serves as the central management platform for your mesh network infrastructure.

## Table of Contents

1. [Introduction and Overview](#introduction-and-overview)
2. [Server Requirements](#server-requirements)
   - [Hardware Specifications](#hardware-specifications)
   - [Software Prerequisites](#software-prerequisites)
   - [Network Requirements](#network-requirements)
3. [Installation](#installation)
   - [Automated Installation](#automated-installation)
   - [Manual Installation](#manual-installation)
   - [Database Configuration](#database-configuration)
   - [Web Interface Setup](#web-interface-setup)
   - [Security Configuration](#security-configuration)
4. [Configuration](#configuration)
   - [Admin Server Settings](#admin-server-settings)
   - [Network Parameters](#network-parameters)
   - [API Configuration](#api-configuration)
   - [Email Notifications](#email-notifications)
5. [Management Interface](#management-interface)
   - [Dashboard Overview](#dashboard-overview)
   - [Node Management](#node-management)
   - [User Administration](#user-administration)
   - [System Monitoring](#system-monitoring)
6. [Security Guidelines](#security-guidelines)
   - [Access Control](#access-control)
   - [SSL/TLS Setup](#ssltls-setup)
   - [Firewall Configuration](#firewall-configuration)
   - [Security Best Practices](#security-best-practices)
7. [Monitoring and Maintenance](#monitoring-and-maintenance)
   - [System Health Checks](#system-health-checks)
   - [Backup Procedures](#backup-procedures)
   - [Update Management](#update-management)
   - [Troubleshooting](#troubleshooting)
8. [API Reference](#api-reference)
9. [Appendices](#appendices)

## Introduction and Overview

The Mesh Network Admin Server is the central management system for your mesh network infrastructure. It provides the following core functionality:

- **Real-time monitoring** of all mesh nodes
- **User management** with role-based access control
- **Node registration and configuration** management
- **Performance analytics and reporting**
- **Centralized logging** and event tracking
- **API endpoints** for automation and integration

This guide will help you set up, configure, and maintain the admin server for optimal operation of your mesh network. Whether you're managing a small community network or a large-scale deployment, the admin server provides the tools needed for effective oversight and management.

## Server Requirements

### Hardware Specifications

The admin server hardware requirements depend on the size of your mesh network:

| Network Size | CPU | RAM | Storage | Example Hardware |
|--------------|-----|-----|---------|-----------------|
| Small (<20 nodes) | 2 cores, 2GHz+ | 2GB | 20GB | Raspberry Pi 4 (4GB) |
| Medium (20-50 nodes) | 4 cores, 2.5GHz+ | 4GB | 50GB | Intel NUC or small server |
| Large (50+ nodes) | 8+ cores, 3GHz+ | 8GB+ | 100GB+ | Dedicated server |

For production deployments, consider:
- Redundant power supply
- RAID storage for data protection
- Hardware watchdog capability
- Remote management interface (IPMI)

### Software Prerequisites

The admin server requires:

1. **Operating System**:
   - Ubuntu 20.04 LTS or newer (recommended)
   - Debian 11 or newer
   - CentOS/RHEL 8 or newer

2. **Core Dependencies**:
   - Python 3.8+
   - SQLite3 (default) or PostgreSQL
   - Nginx or Apache web server
   - Node.js 14+ (for advanced reporting)

3. **Python Packages**:
   - Flask (web framework)
   - SQLAlchemy (database ORM)
   - Gunicorn (WSGI server)
   - Flask-RESTful (API framework)
   - Cryptography (security functions)

### Network Requirements

1. **Connectivity**:
   - Static IP address
   - Reliable internet connection
   - Minimum 10Mbps upload/download (100Mbps+ recommended for large networks)
   - Low latency connection to mesh network

2. **Network Configuration**:
   - Dedicated subdomain (e.g., admin.meshnetwork.org)
   - Open ports:
     - TCP 80/443 (HTTP/HTTPS)
     - TCP 5000 (Admin API - internal only)
     - TCP 8080 (WebSocket - optional)
   - VPN or secured connection to mesh nodes

3. **DNS Configuration**:
   - A record for the admin server
   - HTTPS certificate (Let's Encrypt recommended)

## Installation

### Automated Installation

For quick setup, we provide an installation script that automates most of the process:

1. **Download the installation script**:
   ```bash
   wget https://meshnetwork.org/downloads/setup-admin.sh
   chmod +x setup-admin.sh
   ```

2. **Run the installation script**:
   ```bash
   ./setup-admin.sh
   ```

   The script will:
   - Check and install dependencies
   - Set up the database
   - Configure the web server
   - Create initial admin credentials
   - Set up SSL certificates (if requested)

3. **Alternatively, use our provided setup script**:
   ```bash
   cd /opt/mesh-dashboard
   ./scripts/setup-admin.sh
   ```

### Manual Installation

If you prefer a manual installation, follow these steps:

1. **Install system dependencies**:
   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt install -y python3 python3-pip python3-venv nginx sqlite3 git

   # CentOS/RHEL
   sudo dnf install -y python38 python38-pip nginx sqlite git
   ```

2. **Clone the repository**:
   ```bash
   git clone https://github.com/meshnetwork/mesh-dashboard.git
   cd mesh-dashboard
   ```

3. **Create a Python virtual environment**:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install --upgrade pip
   pip install -r requirements.txt
   ```

4. **Initialize the application**:
   ```bash
   python3 setup.py
   ```

### Database Configuration

The default installation uses SQLite, which is suitable for small to medium deployments. For larger networks, consider using PostgreSQL:

1. **Install PostgreSQL** (optional, for large deployments):
   ```bash
   sudo apt install -y postgresql postgresql-contrib
   ```

2. **Create the database and user**:
   ```bash
   sudo -u postgres psql
   ```

   ```sql
   CREATE DATABASE mesh_admin;
   CREATE USER mesh WITH ENCRYPTED PASSWORD 'your_secure_password';
   GRANT ALL PRIVILEGES ON DATABASE mesh_admin TO mesh;
   \q
   ```

3. **Update the configuration to use PostgreSQL**:
   ```bash
   nano admin/config.py
   ```

   Change the database settings:
   ```python
   # Change from SQLite
   'database_path': 'admin.db'
   
   # To PostgreSQL
   'database_uri': 'postgresql://mesh:your_secure_password@localhost/mesh_admin'
   ```

### Web Interface Setup

1. **Configure Nginx as a reverse proxy**:
   ```bash
   sudo nano /etc/nginx/sites-available/mesh-admin
   ```

   Add the following configuration:
   ```nginx
   server {
       listen 80;
       server_name your-admin-server.com;

       location / {
           proxy_pass http://127.0.0.1:5000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }

       location /static {
           alias /path/to/mesh-dashboard/static;
       }
   }
   ```

2. **Enable the site and restart Nginx**:
   ```bash
   sudo ln -s /etc/nginx/sites-available/mesh-admin /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl restart nginx
   ```

3. **Set up the application to run with systemd**:
   ```bash
   sudo nano /etc/systemd/system/mesh-admin.service
   ```

   Add the following:
   ```ini
   [Unit]
   Description=Mesh Network Admin Server
   After=network.target

   [Service]
   User=www-data
   WorkingDirectory=/path/to/mesh-dashboard
   ExecStart=/path/to/mesh-dashboard/venv/bin/gunicorn --workers 3 --bind 127.0.0.1:5000 admin.server:app
   Restart=always

   [Install]
   WantedBy=multi-user.target
   ```

4. **Enable and start the service**:
   ```bash
   sudo systemctl enable mesh-admin.service
   sudo systemctl start mesh-admin.service
   ```

### Security Configuration

1. **Set up SSL/TLS with Let's Encrypt**:
   ```bash
   sudo apt install -y certbot python3-certbot-nginx
   sudo certbot --nginx -d your-admin-server.com
   ```

2. **Configure firewall rules**:
   ```bash
   sudo apt install -y ufw
   sudo ufw allow ssh
   sudo ufw allow 'Nginx Full'
   sudo ufw enable
   ```

3. **Create a strong admin password**:
   ```bash
   cd /path/to/mesh-dashboard
   source venv/bin/activate
   python3 -c "from werkzeug.security import generate_password_hash; print(generate_password_hash('your-secure-password'))"
   ```

   Then update the password in the database:
   ```bash
   sqlite3 admin.db
   UPDATE users SET password_hash='generated_hash' WHERE username='admin';
   .quit
   ```

## Configuration

### Admin Server Settings

The primary configuration file is `admin/config.py`. Key settings include:

1. **Server Configuration**:
   ```python
   'host': '0.0.0.0',  # Listen on all interfaces
   'port': 5000,       # Admin server port
   'debug': False,     # Debug mode (set to False in production)
   ```

2. **Database Settings**:
   ```python
   'database_path': 'admin.db',  # SQLite database file
   # OR for PostgreSQL
   'database_uri': 'postgresql://user:password@localhost/dbname'
   ```

3. **Security Settings**:
   ```python
   'session_timeout': 30,  # Session timeout in minutes
   'require_https': True,  # Require HTTPS for admin access
   'allowed_ips': [],      # Empty list allows all IPs
   ```

4. **Advanced Configuration**:
   ```python
   ADVANCED_CONFIG = {
       'require_approval': True,     # Require admin approval for new nodes
       'auto_assign_ip': True,       # Automatically assign IPs to new nodes
       'ip_range': '10.0.0.0/24',    # IP range for mesh network
       'heartbeat_interval': 300,    # Expected heartbeat interval in seconds
       'offline_threshold': 900,     # Consider node offline after this many seconds
   }
   ```

### Network Parameters

Configure network-specific settings in `admin/network_config.py`:

1. **Mesh Network Configuration**:
   ```python
   MESH_CONFIG = {
       'name': 'MeshNetwork',
       'protocol': 'batman-adv',
       'default_channel': 6,
       'encryption': 'wpa2',
       'default_ssid': 'MeshNet-{node_id}'
   }
   ```

2. **IP Allocation**:
   ```python
   IP_CONFIG = {
       'mesh_subnet': '10.0.0.0/16',
       'client_subnet': '192.168.0.0/16',
       'reserved_ranges': [
           '10.0.0.1/32',  # Admin server
           '10.0.0.2-10.0.0.10',  # Gateway nodes
       ]
   }
   ```

### API Configuration

1. **API Access Control**:
   ```python
   API_CONFIG = {
       'require_authentication': True,
       'token_expiry': 86400,  # 24 hours
       'rate_limit': 100,  # Requests per minute
       'allowed_origins': ['*']  # CORS settings
   }
   ```

2. **Create API tokens** for external integrations:
   ```bash
   cd /path/to/mesh-dashboard
   source venv/bin/activate
   python3 -c "import secrets; print(secrets.token_hex(32))"
   ```

   Then store the token in the database.

### Email Notifications

Configure email notifications for important events:

```python
NOTIFICATION_CONFIG = {
    'enable_email': True,
    'smtp_server': 'smtp.example.com',
    'smtp_port': 587,
    'smtp_user': 'alerts@example.com',
    'smtp_password': 'your-smtp-password',
    'from_email': 'mesh-admin@example.com',
    'admin_emails': ['admin@example.com'],
    'notification_level': 'warning',  # 'info', 'warning', 'error'
}
```

## Management Interface

### Dashboard Overview

The admin dashboard provides a centralized view of your entire mesh network:

1. **Main Dashboard Features**:
   - Network health summary
   - Active/inactive node counts
   - Recent events and alerts
   - System resource usage
   - Quick access to management sections

2. **Navigation**:
   - Dashboard (home)
   - Nodes management
   - User administration
   - Reports and analytics
   - System settings

3. **Real-time Updates**:
   - The dashboard uses WebSockets for live updates
   - Node status changes appear immediately
   - Alert notifications display in real-time

### Node Management

The node management section provides tools for managing all mesh nodes:

1. **Node List View**:
   - Displays all nodes with status indicators
   - Filtering by type, status, and location
   - Quick access to node details
   - Batch operations for multiple nodes

2. **Node Detail View**:
   - Complete node information
   - Performance metrics and history
   - Configuration settings
   - Connection logs
   - Remote management options

3. **Node Operations**:
   - Add new nodes manually
   - Approve pending node registrations
   - Edit node configuration
   - Restart node services
   - Update node software
   - Remove nodes from network

4. **Node Groups**:
   - Create logical groupings
   - Apply configuration to groups
   - Monitor group performance
   - Set policies by group

### User Administration

Manage admin server users with these tools:

1. **User Management**:
   - Create, edit, and deactivate users
   - Set user roles and permissions
   - Reset passwords
   - View user activity logs

2. **Role-based Access Control**:
   - **Administrator**: Full access to all features
   - **Operator**: Can manage nodes but not users
   - **Viewer**: Read-only access to dashboard and reports

3. **User Settings**:
   - Password policies
   - Two-factor authentication
   - Session timeout configuration
   - API token management

### System Monitoring

Monitor the health and performance of both the admin server and mesh nodes:

1. **Performance Dashboards**:
   - CPU, memory, and disk usage
   - Network bandwidth utilization
   - Database size and performance
   - Request handling metrics

2. **Alerting System**:
   - Configure alert thresholds
   - Alert notification methods (email, SMS, webhook)
   - Alert acknowledgment and resolution tracking
   - Historical alert data

3. **Reporting Tools**

# Mesh Network Admin Server Guide

This comprehensive guide covers the setup, configuration, and management of the Mesh Network Admin Server, which serves as the central management platform for your mesh network infrastructure.

## Table of Contents

1. [Introduction](#introduction)
2. [System Requirements](#system-requirements)
3. [Installation](#installation)
    - [Automated Installation](#automated-installation)
    - [Manual Installation](#manual-installation)
4. [Configuration](#configuration)
    - [Basic Configuration](#basic-configuration)
    - [Advanced Configuration](#advanced-configuration)
    - [Security Settings](#security-settings)
5. [Dashboard Management](#dashboard-management)
    - [User Interface Overview](#user-interface-overview)
    - [Node Management](#node-management)
    - [User Management](#user-management)
    - [Monitoring Tools](#monitoring-tools)
6. [API Reference](#api-reference)
7. [Backup and Recovery](#backup-and-recovery)
8. [Troubleshooting](#troubleshooting)
9. [Upgrading](#upgrading)

## Introduction

The Mesh Network Admin Server provides centralized management for your entire mesh network. Key features include:

- Real-time monitoring of all network nodes
- User management with role-based access control
- Node registration and configuration management
- Performance analytics and reporting
- RESTful API for automation and integration

This guide will help you set up, configure, and maintain the admin server for optimal operation of your mesh network.

## System Requirements

### Minimum

# Mesh Dashboard Admin Server Guide

This guide provides comprehensive instructions for setting up, configuring, and managing the Mesh Dashboard Admin Server, which serves as the central management point for your mesh network.

## Table of Contents

1. [Overview](#overview)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [User Management](#user-management)
5. [Node Management](#node-management)
6. [Security Considerations](#security-considerations)
7. [API Reference](#api-reference)
8. [Troubleshooting](#troubleshooting)

## Overview

The Mesh Dashboard Admin Server provides the following functionality:

- **Centralized Node Management**: Register, monitor, and manage all nodes in your mesh network
- **User Administration**: Create and manage admin users with different permission levels
- **Status Monitoring**: Track the health and status of your entire mesh network
- **Configuration Management**: Distribute configuration updates to nodes
- **Performance Analytics**: Monitor network performance and identify bottlenecks

## Installation

### Prerequisites

- Python 3.8 or higher
- Flask and required dependencies
- SQLite3
- Secure HTTPS certificate (for production)

### Manual Installation

1. **Create a virtual environment**:
   ```bash
   cd mesh-dashboard
   python3 -m venv venv
   source venv/bin/activate
   ```

2. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Initialize the admin server**:
   ```bash
   cd admin
   python server.py
   ```

4. **Verify installation**:
   - Open a web browser and navigate to `http://localhost:5000`
   - Log in with the default credentials (username: `admin`, password: `changeme`)
   - **IMPORTANT**: Change the default password immediately

### Automated Installation

For a streamlined setup, use the provided installation script:

```bash
cd mesh-dashboard
./scripts/setup-admin.sh
```

The script will guide you through the setup process and create a secure configuration.

## Configuration

### Basic Configuration

The admin server configuration is stored in `admin/config.py`. The key settings you should review include:

- **Server host and port**: Where the admin server will listen
- **Database path**: Location of the SQLite database
- **Security settings**: HTTPS requirements, session timeout
- **Default credentials**: Change these immediately in production

Example configuration changes:

```python
ADMIN_CONFIG = {
    'host': '0.0.0.0',  # Change to specific IP if needed
    'port': 5000,       # Change if port conflict exists
    'debug': False,     # Never enable in production
    'database_path': '/path/to/secured/admin.db',
    'default_username': 'admin',
    'default_password': 'your-secure-password',
    'require_https': True,
}
```

### Advanced Configuration

For production deployments, additional configuration is recommended:

- **Set up a reverse proxy** (Nginx, Apache) to handle HTTPS
- **Configure automatic backups** of the database
- **Set up monitoring** and alerts for the admin server
- **Configure email notifications** for critical events

## User Management

### Adding Admin Users

1. Log in with an existing admin account
2. Navigate to the "Users" section
3. Click "Add User"
4. Provide username, password, and role
5. Click "Create User"

### User Roles and Permissions

- **admin**: Full access to all features
- **operator**: Can manage nodes but not users
- **viewer**: Read-only access to dashboard

### Password Management

Best practices for account security:

- Use strong, unique passwords
- Enable password rotation policies
- Consider implementing two-factor authentication
- Audit account access regularly

## Node Management

### Adding Nodes

There are three ways to add nodes to your network:

1. **Manual Registration**: Through the admin interface
2. **API-based Registration**: Using the `/api/register-node` endpoint
3. **Script-based Registration**: Using the provided scripts

#### Manual Registration Steps:

1. In the admin dashboard, go to "Nodes"
2. Click "Add Node"
3. Fill in the required details:
   - Node ID (unique identifier)
   - Node Type (client, relay, gateway)
   - Location
   - IP Address
4. Click "Register Node"

### Monitoring Node Status

The dashboard provides real-time monitoring of all nodes:

- Green status: Node is online and healthy
- Yellow status: Node is experiencing issues
- Red status: Node is offline or critical
- Gray status: Unknown state

Click on any node to view detailed information including:
- Connection history
- Performance metrics
- Configuration details
- Logs and events

### Node Management Operations

From the node detail page, you can perform the following actions:

- **Update Configuration**: Push new settings to the node
- **Restart Services**: Restart specific services remotely
- **Run Diagnostics**: Perform remote troubleshooting
- **Remove Node**: Deregister a node from the network

## Security Considerations

### Securing the Admin Server

1. **Always use HTTPS** in production
2. **Restrict access** by IP address where possible
3. **Use strong passwords** and change defaults
4. **Keep the server updated** with security patches
5. **Implement proper firewall rules**

### API Security

The Admin Server API uses token-based authentication. To generate an API token:

1. Log in to the admin dashboard
2. Go to "API Tokens"
3. Click "Generate New Token"
4. Save the token securely

Include the token in API requests:

```bash
curl -X POST https://admin-server/api/register-node \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"node_id": "example-node", "node_type": "client", "location": "Jakarta"}'
```

## API Reference

### Authentication

```
POST /api/login
```

Request:
```json
{
  "username": "admin",
  "password": "your-password"
}
```

Response:
```json
{
  "token": "your-jwt-token",
  "expires_at": "2025-05-28T12:33:34.809499492+10:00"
}
```

### Node Registration

```
POST /api/register-node
```

Request:
```json
{
  "node_id": "jakarta-01",
  "node_type": "client",
  "location": "Jakarta Office",
  "ip_address": "192.168.1.100"
}
```

### Heartbeat Updates

```
POST /api/node-heartbeat
```

Request:
```json
{
  "node_id": "jakarta-01",
  "status": "OK",
  "details": {
    "uptime": "4 days",
    "cpu_load": "0.2",
    "ram_usage": "30%",
    "storage": "40%",
    "bandwidth": "2.5Mbps"
  }
}
```

## Troubleshooting

### Common Issues

#### Server Won't Start

```bash
# Check for port conflicts
netstat -tuln | grep 5000

# Check log file for errors
tail -n 50 admin_server.log

# Verify database permissions
ls -la admin.db
```

#### Authentication Failures

```bash
# Reset admin password (use with caution)
sqlite3 admin.db "UPDATE users SET password_hash='new_hash' WHERE username='admin';"
```

#### Database Corruption

```bash
# Backup existing database
cp admin.db admin.db.backup

# Create new database
rm admin.db
python server.py
```

### Getting Help

If you encounter issues not covered in this guide:

1. Check the project wiki
2. Review the GitHub issues
3. Contact the maintainers at support@meshnetwork.org

---

Remember: The security of your mesh network relies on properly securing the admin server. Always follow security best practices and keep your server updated.

