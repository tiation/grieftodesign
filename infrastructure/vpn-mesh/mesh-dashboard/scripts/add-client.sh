#!/bin/bash
#
# Mesh Network Client Node Registration Script
# This script registers a client node with the mesh network admin server.
#

set -e  # Exit immediately if a command exits with a non-zero status

# ANSI color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Configuration variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONFIG_FILE="${INSTALL_DIR}/client-config.json"
LOG_FILE="${INSTALL_DIR}/client-registration.log"

# Default values
DEFAULT_ADMIN_SERVER="http://localhost:5000"

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
    exit 1
}

check_dependencies() {
    log "Checking dependencies..."
    
    # Check for jq (JSON processor)
    if ! command -v jq &> /dev/null; then
        warn "jq not found. Attempting to install..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y jq
        elif command -v yum &> /dev/null; then
            sudo yum install -y jq
        else
            error "jq is required but could not be installed automatically. Please install it manually."
        fi
    fi
    
    log "All dependencies checked and satisfied."
}

gather_node_info() {
    log "Gathering node information..."
    
    # Get system information
    HOSTNAME=$(hostname)
    IP_ADDRESS=$(hostname -I | awk '{print $1}')
    MAC_ADDRESS=$(ip link | grep -A 1 eth0 | grep link | awk '{print $2}')
    
    # Prompt for node details
    echo -e "${BOLD}Client Node Registration${NC}"
    echo "Please provide the following information:"
    
    read -p "Node ID [${HOSTNAME}]: " NODE_ID
    NODE_ID=${NODE_ID:-${HOSTNAME}}
    
    read -p "Location description: " LOCATION
    if [ -z "${LOCATION}" ]; then
        warn "Location is required. Please specify a location."
        read -p "Location description: " LOCATION
        if [ -z "${LOCATION}" ]; then
            error "Location is required for registration."
        fi
    fi
    
    read -p "Contact person name: " CONTACT_NAME
    read -p "Contact email: " CONTACT_EMAIL
    
    read -p "IP Address [${IP_ADDRESS}]: " INPUT_IP
    IP_ADDRESS=${INPUT_IP:-${IP_ADDRESS}}
    
    read -p "Additional details (optional): " DETAILS
    
    # Create JSON configuration
    cat > "${CONFIG_FILE}" << EOL
{
  "node_id": "${NODE_ID}",
  "node_type": "client",
  "location": "${LOCATION}",
  "ip_address": "${IP_ADDRESS}",
  "details": {
    "mac_address": "${MAC_ADDRESS}",
    "contact_name": "${CONTACT_NAME}",
    "contact_email": "${CONTACT_EMAIL}",
    "additional_info": "${DETAILS}",
    "registration_date": "$(date '+%Y-%m-%d %H:%M:%S')"
  }
}
EOL
    
    log "Node information gathered and saved to ${CONFIG_FILE}"
}

register_with_admin() {
    log "Registering with admin server..."
    
    # Prompt for admin server details
    read -p "Admin server URL [${DEFAULT_ADMIN_SERVER}]: " ADMIN_SERVER
    ADMIN_SERVER=${ADMIN_SERVER:-${DEFAULT_ADMIN_SERVER}}
    
    # Check if admin server requires authentication
    read -p "Does the admin server require authentication? [y/n]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "API Token: " API_TOKEN
        AUTH_HEADER="-H \"Authorization: Bearer ${API_TOKEN}\""
    else
        AUTH_HEADER=""
    fi
    
    # Register the node
    log "Sending registration request to ${ADMIN_SERVER}/api/register-node"
    
    RESPONSE=$(curl -s -X POST "${ADMIN_SERVER}/api/register-node" \
        ${AUTH_HEADER} \
        -H "Content-Type: application/json" \
        -d @"${CONFIG_FILE}" \
        -w "\n%{http_code}")
    
    HTTP_CODE=$(echo "${RESPONSE}" | tail -n1)
    RESPONSE_BODY=$(echo "${RESPONSE}" | sed '$d')
    
    if [ "${HTTP_CODE}" -eq 201 ] || [ "${HTTP_CODE}" -eq 200 ]; then
        log "Registration successful!"
        echo -e "${GREEN}Node registered successfully!${NC}"
        echo "Response from server: ${RESPONSE_BODY}"
        
        # Save registration confirmation
        echo "${RESPONSE_BODY}" > "${INSTALL_DIR}/registration_confirmation.json"
        
        # Set up the heartbeat cron job
        setup_heartbeat_cron "${ADMIN_SERVER}"
    else
        error "Registration failed with HTTP code ${HTTP_CODE}: ${RESPONSE_BODY}"
    fi
}

setup_heartbeat_cron() {
    local ADMIN_SERVER=$1
    
    log "Setting up heartbeat cron job..."
    
    # Create the heartbeat script
    HEARTBEAT_SCRIPT="${INSTALL_DIR}/send-heartbeat.sh"
    
    cat > "${HEARTBEAT_SCRIPT}" << EOL
#!/bin/bash
# Heartbeat sender script

NODE_ID=\$(jq -r '.node_id' ${CONFIG_FILE})
ADMIN_SERVER="${ADMIN_SERVER}"

# Gather current status info
UPTIME=\$(uptime -p)
CPU_LOAD=\$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - \$1}')
RAM_USAGE=\$(free -m | awk 'NR==2{printf "%.1f%%", \$3*100/\$2}')
DISK_USAGE=\$(df -h / | awk 'NR==2{print \$5}')
CONNECTED_CLIENTS=\$(iw dev wlan1 station dump 2>/dev/null | grep Station | wc -l)

# Create JSON payload
PAYLOAD="{
  \"node_id\": \"\${NODE_ID}\",
  \"status\": \"OK\",
  \"details\": {
    \"uptime\": \"\${UPTIME}\",
    \"cpu_load\": \"\${CPU_LOAD}%\",
    \"ram_usage\": \"\${RAM_USAGE}\",
    \"disk_usage\": \"\${DISK_USAGE}\",
    \"connected_clients\": \"\${CONNECTED_CLIENTS}\",
    \"timestamp\": \"\$(date '+%Y-%m-%d %H:%M:%S')\"
  }
}"

# Send the heartbeat
curl -s -X POST "\${ADMIN_SERVER}/api/node-heartbeat" \\
  -H "Content-Type: application/json" \\
  -d "\${PAYLOAD}" > /dev/null
EOL
    
    chmod +x "${HEARTBEAT_SCRIPT}"
    
    # Add to crontab
    read -p "Set up automatic heartbeat every 5 minutes? [y/n]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Check if entry already exists
        if crontab -l 2>/dev/null | grep -q "${HEARTBEAT_SCRIPT}"; then
            warn "Heartbeat cron job already exists."
        else
            (crontab -l 2>/dev/null; echo "*/5 * * * * ${HEARTBEAT_SCRIPT}") | crontab -
            log "Heartbeat cron job added. The node will send status updates every 5 minutes."
        fi
    else
        log "Heartbeat cron job not set up. You can manually run ${HEARTBEAT_SCRIPT} to send updates."
    fi
}

show_completion_message() {
    echo
    echo -e "${GREEN}====== Client Node Registration Complete ======${NC}"
    echo
    echo "Your client node has been registered with the mesh network."
    echo
    echo "Node ID: $(jq -r '.node_id' ${CONFIG_FILE})"
    echo "Type: Client Node"
    echo "Location: $(jq -r '.location' ${CONFIG_FILE})"
    echo
    echo "Configuration saved to: ${CONFIG_FILE}"
    echo "Heartbeat script: ${INSTALL_DIR}/send-heartbeat.sh"
    echo
    echo -e "${YELLOW}IMPORTANT:${NC} For proper operation:"
    echo "  1. Ensure your node can reach the admin server"
    echo "  2. Configure your network interfaces as per the DEPLOYMENT.md guide"
    echo "  3. Test connectivity with other mesh nodes"
    echo
    echo "For more information, see ${INSTALL_DIR}/docs/CLIENT_SETUP.md"
    echo
}

# Main execution
clear
echo -e "${BOLD}Mesh Network Client Node Registration${NC}"
echo "=========================================="
echo

# Initialize log file
mkdir -p "$(dirname "${LOG_FILE}")"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting client node registration" > "${LOG_FILE}"

check_dependencies
gather_node_info
register_with_admin
show_completion_message

exit 0

