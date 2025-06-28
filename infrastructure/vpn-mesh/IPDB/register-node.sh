#!/bin/bash
# ChaseWhiteRabbit Mesh Network - Node Registration
# This script registers a new node in the IPDB database

# ======================================================================
# CONFIGURATION
# ======================================================================
IPDB_DIR="$(dirname "$(readlink -f "$0")")"
IPDB_FILE="$IPDB_DIR/ipdb.json"
IPDB_BACKUP_DIR="$IPDB_DIR/backups"
REGIONS_FILE="$IPDB_DIR/regions.json"
NODE_CONFIG_TEMPLATE="/media/parrot/Ventoy/ChaseWhiteRabbit/SystemAdmin/Network/node_config_templates/mesh-node.conf"
MESH_NETWORK_CIDR="10.66.0.0/16"  # Our mesh network range
REGISTRATION_LOG="$IPDB_DIR/registration.log"

# ======================================================================
# DISPLAY FUNCTIONS
# ======================================================================
# Colors for output
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
BOLD="\033[1m"
RESET="\033[0m"

# Display section header
section() {
    echo ""
    echo -e "${BOLD}${CYAN}=== $1 ===${RESET}"
    echo ""
}

# Display step info
step() {
    echo -e "${BLUE}➤ $1${RESET}"
}

# Display success message
success() {
    echo -e "${GREEN}✓ $1${RESET}"
}

# Display warning message
warning() {
    echo -e "${YELLOW}⚠ $1${RESET}"
}

# Display error message and exit
error() {
    echo -e "${RED}✗ $1${RESET}" >&2
    exit 1
}

# Log a message
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$REGISTRATION_LOG"
}

# ======================================================================
# VALIDATION FUNCTIONS
# ======================================================================
# Validate IP address format
validate_ip() {
    local ip=$1
    if [[ ! $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        return 1
    fi
    
    IFS='.' read -r -a octets <<< "$ip"
    for octet in "${octets[@]}"; do
        if [[ $octet -gt 255 ]]; then
            return 1
        fi
    done
    
    return 0
}

# Check if IP is in our mesh network range
is_in_mesh_range() {
    local ip=$1
    local network=${MESH_NETWORK_CIDR%/*}
    local cidr=${MESH_NETWORK_CIDR#*/}
    
    # Convert IP to decimal
    IFS='.' read -r i1 i2 i3 i4 <<< "$ip"
    ip_dec=$(( (i1<<24) + (i2<<16) + (i3<<8) + i4 ))
    
    # Convert network to decimal
    IFS='.' read -r n1 n2 n3 n4 <<< "$network"
    network_dec=$(( (n1<<24) + (n2<<16) + (n3<<8) + n4 ))
    
    # Create mask
    mask=$(( 0xFFFFFFFF << (32-cidr) ))
    
    # Check if IP is in range
    if (( (ip_dec & mask) == (network_dec & mask) )); then
        return 0
    else
        return 1
    fi
}

# Check if IP is already in use
is_ip_used() {
    local ip=$1
    if [ ! -f "$IPDB_FILE" ]; then
        return 1  # File doesn't exist, so IP is not used
    fi
    
    if grep -q "\"ip_address\": \"$ip\"" "$IPDB_FILE"; then
        return 0  # IP is used
    else
        return 1  # IP is not used
    fi
}

# Validate email address format
validate_email() {
    local email=$1
    if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Validate phone number (simple validation, adjust for Indonesia as needed)
validate_phone() {
    local phone=$1
    # Indonesian numbers typically start with +62 or 0
    if [[ "$phone" =~ ^(\+62|62|0)[0-9]{9,12}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Validate GPS coordinates
validate_gps() {
    local lat=$1
    local lon=$2
    
    # Latitude must be between -90 and 90
    if (( $(echo "$lat < -90" | bc -l) || $(echo "$lat > 90" | bc -l) )); then
        return 1
    fi
    
    # Longitude must be between -180 and 180
    if (( $(echo "$lon < -180" | bc -l) || $(echo "$lon > 180" | bc -l) )); then
        return 1
    fi
    
    return 0
}

# ======================================================================
# IP ASSIGNMENT FUNCTIONS
# ======================================================================
# Generate a suggestion for the next available IP in the range
suggest_next_ip() {
    local region_code=$1
    local subnet_base
    
    # Map region codes to subnet bases
    case "$region_code" in
        "ID-JK") subnet_base="10.66.1" ;;  # Jakarta
        "ID-SU") subnet_base="10.66.2" ;;  # Sumatra
        "ID-JA") subnet_base="10.66.3" ;;  # Java (outside Jakarta)
        "ID-KA") subnet_base="10.66.4" ;;  # Kalimantan
        "ID-SL") subnet_base="10.66.5" ;;  # Sulawesi
        "ID-ML") subnet_base="10.66.6" ;;  # Maluku
        "ID-PP") subnet_base="10.66.7" ;;  # Papua
        "ID-BA") subnet_base="10.66.8" ;;  # Bali
        "ID-NT") subnet_base="10.66.9" ;;  # Nusa Tenggara
        *) subnet_base="10.66.0" ;;        # Default/Other
    esac
    
    # Find the next available IP in the subnet
    if [ ! -f "$IPDB_FILE" ]; then
        echo "${subnet_base}.1"  # First IP if no database exists
        return
    fi
    
    # Find all IPs in this subnet
    local used_ips=$(grep -o "\"ip_address\": \"${subnet_base}\.[0-9]\+\"" "$IPDB_FILE" | grep -o "${subnet_base}\.[0-9]\+")
    
    # If no IPs in this subnet, suggest the first one
    if [ -z "$used_ips" ]; then
        echo "${subnet_base}.1"
        return
    fi
    
    # Find the highest last octet in use
    local highest_octet=0
    while read -r ip; do
        local octet=${ip##*.}
        if [ "$octet" -gt "$highest_octet" ]; then
            highest_octet=$octet
        fi
    done <<< "$used_ips"
    
    # Suggest the next IP
    echo "${subnet_base}.$((highest_octet + 1))"
}

# ======================================================================
# DATABASE FUNCTIONS
# ======================================================================
# Initialize IPDB if it doesn't exist
initialize_ipdb() {
    if [ ! -f "$IPDB_FILE" ]; then
        mkdir -p "$IPDB_DIR"
        echo '{
  "nodes": [],
  "last_updated": "'"$(date -u +"%Y-%m-%dT%H:%M:%SZ")"'",
  "version": "1.0"
}' > "$IPDB_FILE"
        success "Initialized new IPDB database"
    fi
    
    # Create backup directory if it doesn't exist
    mkdir -p "$IPDB_BACKUP_DIR"
}

# Backup the current IPDB before making changes
backup_ipdb() {
    if [ -f "$IPDB_FILE" ]; then
        local backup_file="$IPDB_BACKUP_DIR/ipdb_$(date +%Y%m%d_%H%M%S).json"
        cp "$IPDB_FILE" "$backup_file"
        success "Created IPDB backup: $(basename "$backup_file")"
    fi
}

# Add node to IPDB
add_node_to_ipdb() {
    local node_id=$1
    local node_name=$2
    local ip_address=$3
    local node_type=$4
    local region=$5
    local location_lat=$6
    local location_lon=$7
    local admin_contact=$8
    local admin_phone=$9
    local node_description=${10}
    
    # Create a timestamp
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Create node entry in JSON format
    local node_entry='{
    "node_id": "'"$node_id"'",
    "node_name": "'"$node_name"'",
    "ip_address": "'"$ip_address"'",
    "node_type": "'"$node_type"'",
    "region": "'"$region"'",
    "location": {
      "latitude": '"$location_lat"',
      "longitude": '"$location_lon"'
    },
    "admin_contact": "'"$admin_contact"'",
    "admin_phone": "'"$admin_phone"'",
    "description": "'"$node_description"'",
    "status": "active",
    "registration_date": "'"$timestamp"'",
    "last_seen": "'"$timestamp"'"
  }'
    
    # Add the node to the IPDB
    # Using temporary files to avoid issues with in-place editing
    local temp_file=$(mktemp)
    
    # Use jq if available for proper JSON manipulation
    if command -v jq >/dev/null 2>&1; then
        jq --argjson new_node "$node_entry" '.nodes += [$new_node] | .last_updated = "'"$timestamp"'"' "$IPDB_FILE" > "$temp_file"
    else
        # Fallback method if jq is not available
        # This is less robust but works for basic cases
        sed 's/"nodes": \[/"nodes": \['"$node_entry"',/' "$IPDB_FILE" | 
            sed 's/"last_updated": "[^"]*"/"last_updated": "'"$timestamp"'"/' > "$temp_file"
    fi
    
    # Replace the original file with the updated one
    mv "$temp_file" "$IPDB_FILE"
    
    success "Added node '$node_name' to IPDB database"
    log_message "Added node: $node_id, $node_name, $ip_address, $region"
}

# Generate configuration for the node
generate_node_config() {
    local node_id=$1
    local node_name=$2
    local ip_address=$3
    local node_type=$4
    local region=$5
    local location_lat=$6
    local location_lon=$7
    local admin_contact=$8
    
    local config_dir="$IPDB_DIR/node_configs"
    mkdir -p "$config_dir"
    
    local config_file="$config_dir/${node_id}.conf"
    
    # Create a basic configuration file based on the template
    if [ -f "$NODE_CONFIG_TEMPLATE" ]; then
        # Copy template and substitute values
        cat "$NODE_CONFIG_TEMPLATE" | 
            sed "s/node-ID-LOCATION-XX/$node_name/g" |
            sed "s/standard/$node_type/g" |
            sed "s/ID-JAKARTA/$region/g" |
            sed "s/-6.2088/$location_lat/g" |
            sed "s/106.8456/$location_lon/g" |
            sed "s/admin@chasewhiterabbit.org/$admin_contact/g" > "$config_file"
        
        success "Generated node configuration: $(basename "$config_file")"
    else
        warning "Node configuration template not found. Skipping configuration generation."
    fi
    
    # Return the path to the generated config
    echo "$config_file"
}

# ======================================================================
# MAIN SCRIPT
# ======================================================================
clear
echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${CYAN}║        ChaseWhiteRabbit Mesh Network                  ║${RESET}"
echo -e "${BOLD}${CYAN}║               Node Registration                       ║${RESET}"
echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════╝${RESET}"
echo
echo -e "Welcome to the node registration process! This script will collect"
echo -e "information about your node and add it to the IPDB database."
echo

# Initialize and backup database
initialize_ipdb
backup_ipdb

# ======================================================================
# COLLECT NODE INFORMATION
# ======================================================================
section "Node Information"

# Node ID (automatically generated)
node_id="node-$(date +%Y%m%d)-$(openssl rand -hex 4)"
step "Assigned Node ID: $node_id"

# Node Name
while true; do
    read -p "Enter node name (e.g., node-ID-JAKARTA-01): " node_name
    
    if [ -z "$node_name" ]; then
        warning "Node name cannot be empty. Please try again."
    elif grep -q "\"node_name\": \"$node_name\"" "$IPDB_FILE" 2>/dev/null; then
        warning "A node with this name already exists. Please choose another name."
    else
        success "Node name accepted: $node_name"
        break
    fi
done

# Node Type
echo
step "Select node type:"
echo "  1) gateway - Internet-connected node with reliable power"
echo "  2) relay - Intermediate node that extends the mesh"
echo "  3) standard - Edge node serving end users"
read -p "Enter your choice [1-3] (default: 3): " node_type_choice

case "$node_type_choice" in
    1) node_type="gateway" ;;
    2) node_type="relay" ;;
    *) node_type="standard" ;;
esac

success "Node type selected: $node_type"

# Region Selection
echo
section "Region Selection"
step "Select your region in Indonesia:"
echo "  1) ID-JK - Jakarta"
echo "  2) ID-SU - Sumatra"
echo "  3) ID-JA - Java (outside Jakarta)"
echo "  4) ID-KA - Kalimantan"
echo "  5) ID-SL - Sulawesi"
echo "  6) ID-ML - Maluku"
echo "  7) ID-PP - Papua"
echo "  8) ID-BA - Bali"
echo "  9) ID-NT - Nusa Tenggara"
echo "  0) Other/Unknown"

read -p "Enter your choice [0-9] (default: 1): " region_choice

case "$region_choice" in
    2) region="ID-SU" ;;
    3) region="ID-JA" ;;
    4) region="ID-KA" ;;
    5) region="ID-SL" ;;
    6) region="ID-ML" ;;
    7) region="ID-PP" ;;
    8) region="ID-BA" ;;
    9) region="ID-NT" ;;
    0) 
        read -p "Specify your region code: " region
        ;;
    *) region="ID-JK" ;;  # Default to Jakarta
esac

success "Region selected: $region"

# ======================================================================
# LOCATION INFORMATION
# ======================================================================
section "Location Information"

step "Enter the geographical coordinates of your node"
echo "This helps with network topology planning and visualization."
echo "Tip: You can use a GPS app or maps service to find your coordinates."

# Default coordinates for each region if user doesn't know
default_lat=""
default_lon=""
case "$region" in
    "ID-JK") default_lat="-6.2088"; default_lon="106.8456" ;;  # Jakarta
    "ID-SU") default_lat="3.5952"; default_lon="98.6722" ;;    # Medan, Sumatra
    "ID-JA") default_lat="-7.2575"; default_lon="112.7521" ;;  # Surabaya, Java
    "ID-KA") default_lat="-0.0236"; default_lon="109.3425" ;;  # Pontianak, Kalimantan
    "ID-SL") default_lat="-5.1477"; default_lon="119.4327" ;;  # Makassar, Sulawesi
    "ID-ML") default_lat="-3.7057"; default_lon="128.1823" ;;  # Ambon, Maluku
    "ID-PP") default_lat="-2.5916"; default_lon="140.6690" ;;  # Jayapura, Papua
    "ID-BA") default_lat="-8.6705"; default_lon="115.2126" ;;  # Denpasar, Bali
    "ID-NT") default_lat="-8.5833"; default_lon="116.1167" ;;  # Mataram, Nusa Tenggara
    *) default_lat="-6.2088"; default_lon="106.8456" ;;        # Default to Jakarta
esac

while true; do
    # Prompt with default values for the region
    read -p "Enter latitude ($default_lat): " location_lat
    location_lat=${location_lat:-$default_lat}
    
    read -p "Enter longitude ($default_lon): " location_lon
    location_lon=${location_lon:-$default_lon}
    
    # Validate coordinates
    if validate_gps "$location_lat" "$location_lon"; then
        success "Location coordinates accepted: $location_lat, $location_lon"
        break
    else
        warning "Invalid coordinates. Latitude must be between -90 and 90, longitude between -180 and 180."
    fi
done

# ======================================================================
# CONTACT INFORMATION
# ======================================================================
section "Contact Information"

step "Enter administrator contact information"
echo "This information is used for network management communications."

# Admin email
while true; do
    read -p "Admin email address: " admin_contact
    
    if [ -z "$admin_contact" ]; then
        warning "Email address cannot be empty. Please try again."
    elif ! validate_email "$admin_contact"; then
        warning "Invalid email format. Please try again."
    else
        success "Email address accepted: $admin_contact"
        break
    fi
done

# Admin phone
while true; do
    read -p "Admin phone number (e.g., +628123456789): " admin_phone
    
    if [ -z "$admin_phone" ]; then
        warning "Phone number cannot be empty. Please try again."
    elif ! validate_phone "$admin_phone"; then
        warning "Invalid phone format. Please enter a valid Indonesian phone number."
        echo "Format examples: +628123456789, 08123456789, 628123456789"
    else
        success "Phone number accepted: $admin_phone"
        break
    fi
done

# Node description
echo
step "Enter a brief description of this node"
read -p "Description: " node_description
node_description=${node_description:-"Mesh network node"}

# ======================================================================
# IP ADDRESS ASSIGNMENT
# ======================================================================
section "IP Address Assignment"

# Suggest IP based on region
suggested_ip=$(suggest_next_ip "$region")
step "Based on your region, the suggested IP address is: $suggested_ip"

# Let user choose to accept or specify a different IP
echo "Options:"
echo "  1) Use suggested IP ($suggested_ip)"
echo "  2) Specify a different IP address"

read -p "Your choice [1-2] (default: 1): " ip_choice

if [ "$ip_choice" = "2" ]; then
    # User wants to specify their own IP
    while true; do
        read -p "Enter IP address (must be in $MESH_NETWORK_CIDR range): " ip_address
        
        # Validate the IP format
        if ! validate_ip "$ip_address"; then
            warning "Invalid IP address format. Please try again."
            continue
        fi
        
        # Check if it's in our mesh network range
        if ! is_in_mesh_range "$ip_address"; then
            warning "IP address must be in the $MESH_NETWORK_CIDR range. Please try again."
            continue
        fi
        
        # Check if the IP is already used
        if is_ip_used "$ip_address"; then
            warning "IP address is already assigned to another node. Please try again."
            continue
        fi
        
        success "IP address accepted: $ip_address"
        break
    done
else
    # Use suggested IP
    ip_address="$suggested_ip"
    success "Using suggested IP address: $ip_address"
fi

# ======================================================================
# REGISTRATION CONFIRMATION
# ======================================================================
section "Registration Confirmation"

echo -e "${BOLD}Please review your node information:${RESET}"
echo
echo -e "${CYAN}Node ID:${RESET}        $node_id"
echo -e "${CYAN}Node Name:${RESET}      $node_name"
echo -e "${CYAN}Node Type:${RESET}      $node_type"
echo -e "${CYAN}Region:${RESET}         $region"
echo -e "${CYAN}Location:${RESET}       $location_lat, $location_lon"
echo -e "${CYAN}IP Address:${RESET}     $ip_address"
echo -e "${CYAN}Admin Contact:${RESET}  $admin_contact"
echo -e "${CYAN}Admin Phone:${RESET}    $admin_phone"
echo -e "${CYAN}Description:${RESET}    $node_description"
echo

read -p "Is this information correct? (y/n): " confirm

if [[ ! "$confirm" =~ ^[Yy] ]]; then
    echo
    warning "Registration canceled. Please run the script again to restart."
    exit 0
fi

# ======================================================================
# FINALIZE REGISTRATION
# ======================================================================
section "Processing Registration"

step "Adding node to IPDB database..."
add_node_to_ipdb "$node_id" "$node_name" "$ip_address" "$node_type" "$region" \
    "$location_lat" "$location_lon" "$admin_contact" "$admin_phone" "$node_description"

step "Generating node configuration..."
config_file=$(generate_node_config "$node_id" "$node_name" "$ip_address" "$node_type" \
    "$region" "$location_lat" "$location_lon" "$admin_contact")

# ======================================================================
# COMPLETION
# ======================================================================
section "Registration Complete!"

echo -e "${GREEN}Your node has been successfully registered in the IPDB database.${RESET}"
echo
echo -e "${BOLD}Node Information Summary:${RESET}"
echo -e "  Node ID: ${CYAN}$node_id${RESET}"
echo -e "  IP Address: ${CYAN}$ip_address${RESET}"
echo -e "  Configuration File: ${CYAN}$(basename "$config_file")${RESET}"
echo

echo -e "${BOLD}Next Steps:${RESET}"
echo -e "1. Copy your configuration file from:"
echo -e "   ${CYAN}$config_file${RESET}"
echo -e "2. Install it on your node at: ${CYAN}/etc/mesh-network/node.conf${RESET}"
echo -e "3. Start your mesh network service with:"
echo -e "   ${CYAN}sudo systemctl restart mesh-network${RESET}"
echo
echo -e "${YELLOW}Note:${RESET} Your node will not appear in the network map until"
echo -e "it connects to the mesh network for the first time."
echo

echo -e "${MAGENTA}Thank you for joining the ChaseWhiteRabbit mesh network!${RESET}"
echo -e "${MAGENTA}Together, we're building connections across Indonesia.${RESET}"
echo

exit 0

