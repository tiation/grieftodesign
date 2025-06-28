#!/bin/bash
#
# Mesh Dashboard Admin Server Setup Script
# This script automates the installation and configuration of the mesh network admin server.
#

set -e  # Exit immediately if a command exits with a non-zero status

# ANSI color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Configuration variables
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_DIR="${INSTALL_DIR}/venv"
CONFIG_FILE="${INSTALL_DIR}/admin/config.py"
LOG_FILE="${INSTALL_DIR}/setup_admin.log"

# Helper functions
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1" >> "${LOG_FILE}"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARN] $1" >> "${LOG_FILE}"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1" >> "${LOG_FILE}"
}

check_dependencies() {
    log "Checking dependencies..."
    
    # Check for Python 3.8+
    if ! command -v python3 &> /dev/null; then
        error "Python 3 is not installed. Please install Python 3.8 or higher."
        exit 1
    fi
    
    PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
    if (( $(echo "${PYTHON_VERSION} < 3.8" | bc -l) )); then
        error "Python version ${PYTHON_VERSION} is too old. Please install Python 3.8 or higher."
        exit 1
    fi
    
    log "Python version ${PYTHON_VERSION} found."
    
    # Check for pip
    if ! command -v pip3 &> /dev/null; then
        warn "pip3 not found. Attempting to install..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y python3-pip
        elif command -v yum &> /dev/null; then
            sudo yum install -y python3-pip
        else
            error "Could not install pip3. Please install it manually."
            exit 1
        fi
    fi
    
    # Check for virtualenv
    if ! command -v python3 -m venv &> /dev/null; then
        warn "venv module not found. Attempting to install..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y python3-venv
        elif command -v yum &> /dev/null; then
            sudo yum install -y python3-venv
        else
            error "Could not install venv module. Please install it manually."
            exit 1
        fi
    fi
    
    log "All dependencies checked and satisfied."
}

setup_virtualenv() {
    log "Setting up virtual environment..."
    
    if [ ! -d "${VENV_DIR}" ]; then
        python3 -m venv "${VENV_DIR}"
        log "Virtual environment created at ${VENV_DIR}"
    else
        warn "Virtual environment already exists. Using existing environment."
    fi
    
    source "${VENV_DIR}/bin/activate"
    pip install --upgrade pip
    
    log "Installing required packages..."
    if [ -f "${INSTALL_DIR}/requirements.txt" ]; then
        pip install -r "${INSTALL_DIR}/requirements.txt"
    else
        # Install core dependencies if requirements.txt doesn't exist
        pip install flask flask-cors gunicorn sqlite3-api
    fi
    
    log "Virtual environment setup completed."
}

configure_admin_server() {
    log "Configuring admin server..."
    
    # Create admin directory if it doesn't exist
    mkdir -p "${INSTALL_DIR}/admin"
    
    # Create templates directory for dashboard
    mkdir -p "${INSTALL_DIR}/admin/templates"
    
    # Check if config file exists
    if [ -f "${CONFIG_FILE}" ]; then
        read -p "Configuration file already exists. Overwrite? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log "Using existing configuration file."
            return
        fi
    fi
    
    # Prompt for admin settings
    echo -e "${BOLD}Admin Server Configuration${NC}"
    read -p "Server port [5000]: " SERVER_PORT
    SERVER_PORT=${SERVER_PORT:-5000}
    
    read -p "Admin username [admin]: " ADMIN_USER
    ADMIN_USER=${ADMIN_USER:-admin}
    
    # Generate a random password if user doesn't provide one
    read -s -p "Admin password [auto-generate]: " ADMIN_PASS
    echo
    if [ -z "${ADMIN_PASS}" ]; then
        ADMIN_PASS=$(LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*' </dev/urandom | head -c 16)
        echo "Auto-generated password: ${ADMIN_PASS}"
    fi
    
    read -p "Database path [admin.db]: " DB_PATH
    DB_PATH=${DB_PATH:-admin.db}
    
    read -p "Enable HTTPS (requires certificates) [y/n]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        REQUIRE_HTTPS="True"
    else
        REQUIRE_HTTPS="False"
    fi
    
    # Create config file
    cat > "${CONFIG_FILE}" << EOL
"""
Admin server configuration settings.
Modify these settings according to your deployment environment.
"""

ADMIN_CONFIG = {
    # Server configuration
    'host': '0.0.0.0',  # Listen on all interfaces
    'port': ${SERVER_PORT},
    'debug': False,     # Debug mode (set to False in production)
    
    # Database settings
    'database_path': '${DB_PATH}',
    
    # Default admin user (created on first run)
    'default_username': '${ADMIN_USER}',
    'default_password': '${ADMIN_PASS}',
    
    # Security settings
    'session_timeout': 30,  # Session timeout in minutes
    'require_https': ${REQUIRE_HTTPS},
    
    # Network settings
    'allowed_ips': [],      # Empty list allows all IPs, add specific IPs to restrict access
    'mesh_node_port': 80,   # Port used by mesh nodes for the main application
    
    # Notification settings
    'enable_email': False,
    'smtp_server': 'smtp.example.com',
    'smtp_port': 587,
    'smtp_user': 'alerts@example.com',
    'smtp_password': '',
    'notification_emails': ['admin@example.com'],
    
    # Logging
    'log_level': 'INFO',
    'log_file': 'admin_server.log',
}

# Advanced configuration options
ADVANCED_CONFIG = {
    # Node registration
    'require_approval': True,     # Require admin approval for new nodes
    'auto_assign_ip': True,       # Automatically assign IPs to new nodes
    'ip_range': '10.0.0.0/24',    # IP range for mesh network
    
    # Monitoring
    'heartbeat_interval': 300,    # Expected heartbeat interval in seconds
    'offline_threshold': 900,     # Consider node offline after this many seconds
    
    # Performance
    'connection_pooling': True,   # Use connection pooling for database
    'max_connections': 20,        # Maximum database connections
    
    # Features
    'enable_metrics': True,       # Enable collection of performance metrics
    'enable_map_view': True,      # Enable geographic map of nodes
    'enable_bandwidth_monitoring': True,  # Monitor bandwidth usage
}
EOL
    
    log "Admin server configuration completed."
}

create_startup_script() {
    local SERVICE_FILE="/etc/systemd/system/mesh-admin.service"
    
    log "Creating startup service..."
    
    # Create systemd service file
    cat > /tmp/mesh-admin.service << EOL
[Unit]
Description=Mesh Network Admin Dashboard
After=network.target

[Service]
User=$(whoami)
WorkingDirectory=${INSTALL_DIR}/admin
ExecStart=${VENV_DIR}/bin/python ${INSTALL_DIR}/admin/server.py
Restart=on-failure
Environment=PATH=${VENV_DIR}/bin:/usr/local/bin:/usr/bin:/bin
Environment=PYTHONPATH=${INSTALL_DIR}

[Install]
WantedBy=multi-user.target
EOL
    
    # Ask for permission to install system service
    read -p "Install as system service? (requires sudo) [y/n]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if sudo mv /tmp/mesh-admin.service "${SERVICE_FILE}"; then
            sudo systemctl daemon-reload
            sudo systemctl enable mesh-admin.service
            log "System service installed. You can start it with: sudo systemctl start mesh-admin"
        else
            error "Failed to install system service. You can manually copy /tmp/mesh-admin.service to ${SERVICE_FILE}"
        fi
    else
        log "System service not installed. Service file created at /tmp/mesh-admin.service for manual installation."
    fi
    
    # Create a simple start script
    cat > "${INSTALL_DIR}/start-admin.sh" << EOL
#!/bin/bash
source "${VENV_DIR}/bin/activate"
cd "${INSTALL_DIR}/admin"
python server.py
EOL
    
    chmod +x "${INSTALL_DIR}/start-admin.sh"
    log "Created start script at ${INSTALL_DIR}/start-admin.sh"
}

start_admin_server() {
    # Ask if user wants to start the server now
    read -p "Start the admin server now? [y/n]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "Starting admin server..."
        # If installed as a system service
        if [ -f "/etc/systemd/system/mesh-admin.service" ]; then
            if sudo systemctl start mesh-admin.service; then
                log "Admin server started as a system service. Check status with: sudo systemctl status mesh-admin"
            else
                error "Failed to start admin server as a system service."
            fi
        else
            # Start manually
            log "Starting admin server manually..."
            source "${VENV_DIR}/bin/activate"
            cd "${INSTALL_DIR}/admin"
            python server.py &
            log "Admin server started. Access it at http://localhost:${SERVER_PORT:-5000}"
        fi
    else
        log "Admin server not started. You can start it later with '${INSTALL_DIR}/start-admin.sh' or via systemd if installed."
    fi
}

show_completion_message() {
    echo
    echo -e "${GREEN}====== Mesh Network Admin Server Setup Complete ======${NC}"
    echo
    echo "Admin server has been installed and configured."
    echo
    echo "Access your admin interface at:"
    echo "  http://localhost:${SERVER_PORT:-5000}"
    echo
    echo "Login with:"
    echo "  Username: ${ADMIN_USER:-admin}"
    echo "  Password: ${ADMIN_PASS:-<as configured>}"
    echo
    echo -e "${YELLOW}IMPORTANT:${NC} For production use, make sure to:"
    echo "  1. Set up HTTPS with proper certificates"
    echo "  2. Configure firewall rules to restrict access"
    echo "  3. Regularly backup the database"
    echo
    echo "For more information, see ${INSTALL_DIR}/docs/ADMIN_GUIDE.md"
    echo
}

# Main execution
clear
echo -e "${BOLD}Mesh Network Admin Server Setup${NC}"
echo "======================================="
echo

# Initialize log file
mkdir -p "$(dirname "${LOG_FILE}")"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting admin server setup" > "${LOG_FILE}"

check_dependencies
setup_virtualenv
configure_admin_server
create_startup_script
start_admin_server
show_completion_message

exit 0

