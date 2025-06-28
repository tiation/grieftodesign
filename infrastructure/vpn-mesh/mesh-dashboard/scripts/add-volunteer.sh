#!/bin/bash
#
# Mesh Network Volunteer Node Registration Script
# This script registers a volunteer node (relay or gateway) with the mesh network admin server.
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
CONFIG_FILE="${INSTALL_DIR}/volunteer-config.json"
LOG_FILE="${INSTALL_DIR}/volunteer-registration.log"

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
    
    # Check for curl
    if ! command -v curl &> /dev/null; then
        warn "curl not found. Attempting to install..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y curl
        elif command -v yum &> /dev/null; then
            sudo yum install -y curl
        else
            error "curl is required but could not be installed automatically. Please install it manually."
        fi
    fi
    
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
    
    # Check network interfaces
    IFACE_COUNT=$(ip link | grep -c "state UP")
    if [ "$IFACE_COUNT" -lt 2 ]; then
        warn "Less than 2 active network interfaces detected. Volunteer nodes typically require multiple interfaces."
        read -p "Continue anyway? [y/n]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            error "Registration aborted. Please ensure multiple network interfaces are available."
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
    CPU_INFO=$(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^[ \t]*//')
    MEM_TOTAL=$(free -m | grep Mem | awk '{print $2}')
    DISK_TOTAL=$(df -h / | awk 'NR==2{print $2}')
    
    # Prompt for node details
    echo -e "${BOLD}Volunteer Node Registration${NC}"
    echo "Please provide the following information:"
    
    read -p "Node ID [${HOSTNAME}]: " NODE_ID
    NODE_ID=${NODE_ID:-${HOSTNAME}}
    
    echo "Node type:"
    echo "  1) Relay Node (extends network coverage)"
    echo "  2) Gateway Node (provides internet connectivity)"
    read -p "Select node type [1]: " NODE_TYPE_SELECTION
    NODE_TYPE_SELECTION=${NODE_TYPE_SELECTION:-1}
    
    if [ "$NODE_TYPE_SELECTION" -eq 1 ]; then
        NODE_TYPE="relay"
    else
        NODE_TYPE="gateway"
        
        # For gateway nodes, additional info is needed
        read -p "Internet bandwidth available for the mesh (Mbps): " BANDWIDTH
        read -p "Is this internet connection reliable? [y/n]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            CONNECTION_RELIABILITY="reliable"
        else
            CONNECTION_RELIABILITY="intermittent"
        fi
    fi
    
    read -p "Location description: " LOCATION
    if [ -z "${LOCATION}" ]; then
        warn "Location is required. Please specify a location."
        read -p "Location description: " LOCATION
        if [ -z "${LOCATION}" ]; then
            error "Location is required for registration."
        fi
    fi
    
    read -p "GPS coordinates (lat,long) if available: " GPS_COORDS
    
    read -p "Contact person name: " CONTACT_NAME
    read -p "Contact email: " CONTACT_EMAIL
    read -p "Contact phone: " CONTACT_PHONE
    
    read -p "IP Address [${IP_ADDRESS}]: " INPUT_IP
    IP_ADDRESS=${INPUT_IP:-${IP_ADDRESS}}
    
    read -p "Commitment level (hours/week available for maintenance): " COMMITMENT
    
    read -p "Additional details (optional): " DETAILS
    
    # Create JSON configuration
    if [ "$NODE_TYPE" = "gateway" ]; then
        # Gateway node JSON
        cat > "${CONFIG_FILE}" << EOL
{
  "node_id": "${NODE_ID}",
  "node_type": "${NODE_TYPE}",
  "location": "${LOCATION}",
  "ip_address": "${IP_ADDRESS}",
  "details": {
    "mac_address": "${MAC_ADDRESS}",
    "cpu_info": "${CPU_INFO}",
    "memory_total": "${MEM_TOTAL} MB",
    "disk_total": "${DISK_TOTAL}",
    "contact_name": "${CONTACT_NAME}",
    "contact_email": "${CONTACT_EMAIL}",
    "contact_phone": "${CONTACT_PHONE}",
    "gps_coordinates": "${GPS_COORDS}",
    "bandwidth_available": "${BANDWIDTH} Mbps",
    "connection_reliability": "${CONNECTION_RELIABILITY}",
    "commitment_level": "${COMMITMENT} hours/week",
    "additional_info": "${DETAILS}",
    "registration_date": "$(date '+%Y-%m-%d %H:%M:%S')"
  }
}
EOL
    else
        # Relay node JSON
        cat > "${CONFIG_FILE}" << EOL
{
  "node_id": "${NODE_ID}",
  "node_type": "${NODE_TYPE}",
  "location": "${LOCATION}",
  "ip_address": "${IP_ADDRESS}",
  "details": {
    "mac_address": "${MAC_ADDRESS}",
    "cpu_info": "${CPU_INFO}",
    "memory_total": "${MEM_TOTAL} MB",
    "disk_total": "${DISK_TOTAL}",
    "contact_name": "${CONTACT_NAME}",
    "contact_email": "${CONTACT_EMAIL}",
    "contact_phone": "${CONTACT_PHONE}",
    "gps_coordinates": "${GPS_COORDS}",
    "commitment_level": "${COMMITMENT} hours/week",
    "additional_info": "${DETAILS}",
    "registration_date": "$(date '+%Y-%m-%d %H:%M:%S')"
  }
}
EOL
    fi
    
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
    
    # Volunteer nodes often require approval
    echo -e "${YELLOW}NOTE:${NC} Volunteer nodes may require admin approval before becoming active on the network."
    
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
    HEARTBEAT_SCRIPT="${INSTALL_DIR}/send-volunteer-heartbeat.sh"
    
    # For gateway nodes, we need additional metrics in the heartbeat
    NODE_TYPE=$(jq -r '.node_type' "${CONFIG_FILE}")
    
    if [ "${NODE_TYPE}" = "gateway" ]; then
        # Gateway heartbeat script with internet connectivity monitoring
        cat > "${HEARTBEAT_SCRIPT}" << EOL
#!/bin/bash
# Gateway Node Heartbeat Script

NODE_ID=\$(jq -r '.node_id' ${CONFIG_FILE})
ADMIN_SERVER="${ADMIN_SERVER}"

# Gather current status info
UPTIME=\$(uptime -p)
CPU_LOAD=\$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - \$1}')
RAM_USAGE=\$(free -m | awk 'NR==2{printf "%.1f%%", \$3*100/\$2}')
DISK_USAGE=\$(df -h / | awk 'NR==2{print \$5}')
CONNECTED_NODES=\$(ip -j addr | jq '.[].addr_info | length')
INTERNET_LATENCY=\$(ping -c 3 8.8.8.8 2>/dev/null | grep rtt | cut -d'/' -f5)
INTERNET_STATUS="OK"

# Check internet connectivity
ping -c 1 8.8.8.8 >/dev/null 2>&1
if [ \$? -ne 0 ]; then
    INTERNET_STATUS="FAIL"
    INTERNET_LATENCY="N/A"
fi

# Measure internet bandwidth (if speedtest-cli is available)
if command -v speedtest-cli &> /dev/null; then
    BANDWIDTH_TEST=\$(speedtest-cli --simple 2>/dev/null)
    DOWNLOAD_SPEED=\$(echo "\$BANDWIDTH_TEST" | grep "Download" | awk '{print \$2}')
    UPLOAD_SPEED=\$(echo "\$BANDWIDTH_TEST" | grep "Upload" | awk '{print \$2}')
else
    DOWNLOAD_SPEED="N/A"
    UPLOAD_SPEED="N/A"
fi

# Create JSON payload
PAYLOAD="{
  \"node_id\": \"\${NODE_ID}\",
  \"status\": \"\${INTERNET_STATUS}\",
  \"details\": {
    \"uptime\": \"\${UPTIME}\",
    \"cpu_load\": \"\${CPU_LOAD}%\",
    \"ram_usage\": \"\${RAM_USAGE}\",
    \"disk_usage\": \"\${DISK_USAGE}\",
    \"connected_nodes\": \"\${CONNECTED_NODES}\",
    \"internet_latency\": \"\${INTERNET_LATENCY}\",
    \"download_speed\": \"\${DOWNLOAD_SPEED}\",
    \"upload_speed\": \"\${UPLOAD_SPEED}\",
    \"timestamp\": \"\$(date '+%Y-%m-%d %H:%M:%S')\"
  }
}"

# Send the heartbeat
curl -s -X POST "\${ADMIN_SERVER}/api/node-heartbeat" \\
  -H "Content-Type: application/json" \\
  -d "\${PAYLOAD}" > /dev/null
EOL
    else
        # Relay heartbeat script
        cat > "${HEARTBEAT_SCRIPT}" << EOL
#!/bin/bash
# Relay Node Heartbeat Script

NODE_ID=\$(jq -r '.node_id' ${CONFIG_FILE})
ADMIN_SERVER="${ADMIN_SERVER}"

# Gather current status info
UPTIME=\$(uptime -p)
CPU_LOAD=\$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - \$1}')
RAM_USAGE=\$(free -m | awk 'NR==2{printf "%.1f%%", \$3*100/\$2}')
DISK_USAGE=\$(df -h / | awk 'NR==2{print \$5}')
CONNECTED_NODES=\$(ip -j addr | jq '.[].addr_info | length')
MESH_STATUS="OK"

# Check mesh connectivity to gateway nodes
ping -c 1 10.0.0.1 >/dev/null 2>&1
if [ \$? -ne 0 ]; then
    # Try backup gateway
    ping -c 1 10.0.0.2 >/dev/null 2>&1
    if [ \$? -ne 0 ]; then
        MESH_STATUS="DISCONNECTED"
    else
        MESH_STATUS="DEGRADED"
    fi
fi

# Create JSON payload
PAYLOAD="{
  \"node_id\": \"\${NODE_ID}\",
  \"status\": \"\${MESH_STATUS}\",
  \"details\": {
    \"uptime\": \"\${UPTIME}\",
    \"cpu_load\": \"\${CPU_LOAD}%\",
    \"ram_usage\": \"\${RAM_USAGE}\",
    \"disk_usage\": \"\${DISK_USAGE}\",
    \"connected_nodes\": \"\${CONNECTED_NODES}\",
    \"timestamp\": \"\$(date '+%Y-%m-%d %H:%M:%S')\"
  }
}"

# Send the heartbeat
curl -s -X POST "\${ADMIN_SERVER}/api/node-heartbeat" \\
  -H "Content-Type: application/json" \\
  -d "\${PAYLOAD}" > /dev/null
EOL
    fi
    
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
    echo -e "${GREEN}====== Volunteer Node Registration Complete ======${NC}"
    echo
    echo "Your volunteer node has been registered with the mesh network."
    echo
    echo "Node ID: $(jq -r '.node_id' ${CONFIG_FILE})"
    echo "Type: $(jq -r '.node_type' ${CONFIG_FILE} | sed 's/^\(.\)/\U\1/')"
    echo "Location: $(jq -r '.location' ${CONFIG_FILE})"
    echo
    echo "Configuration saved to: ${CONFIG_FILE}"
    echo "Heartbeat script: ${HEARTBEAT_SCRIPT}"
    echo
    
    # Show different messages based on node type
    if [ "$(jq -r '.node_type' ${CONFIG_FILE})" = "gateway" ]; then
        echo -e "${YELLOW}IMPORTANT FOR GATEWAY NODES:${NC}"
        echo "  1. Configure proper network routing for client access"
        echo "  2. Set up appropriate firewall rules for network protection"
        echo "  3. Monitor bandwidth usage to ensure fair allocation"
    else
        echo -e "${YELLOW}IMPORTANT FOR RELAY NODES:${NC}"
        echo "  1. Verify line-of-sight to other mesh nodes"
        echo "  2. Optimize antenna positioning for best coverage"
        echo "  3. Configure power management for reliability"
    fi
    
    echo
    echo "For detailed instructions, see ${INSTALL_DIR}/docs/VOLUNTEER_GUIDE.md"
    echo
}

# Main execution
clear
echo -e "${BOLD}Mesh Network Volunteer Node Registration${NC}"
echo "============================================="
echo

# Initialize log file
mkdir -p "$(dirname "${LOG_FILE}")"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting volunteer node registration" > "${LOG_FILE}"

check_dependencies
gather_node_info
register_with_admin
show_completion_message

exit 0

