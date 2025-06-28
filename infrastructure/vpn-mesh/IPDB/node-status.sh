#!/bin/bash
# ChaseWhiteRabbit Mesh Network - Node Status Management
# This script allows users to check and update their node information in IPDB

# ======================================================================
# CONFIGURATION
# ======================================================================
IPDB_DIR="$(dirname "$(readlink -f "$0")")"
IPDB_FILE="$IPDB_DIR/ipdb.json"
IPDB_BACKUP_DIR="$IPDB_DIR/backups"
NODE_CONFIG_DIR="$IPDB_DIR/node_configs"
MESH_NETWORK_CIDR="10.66.0.0/16"
STATUS_LOG="$IPDB_DIR/status.log"

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
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$STATUS_LOG"
}

# ======================================================================
# DATABASE FUNCTIONS
# ======================================================================
# Check if IPDB exists
check_ipdb() {
    if [ ! -f "$IPDB_FILE" ]; then
        error "IPDB database not found. Please run register-node.sh first."
    fi
}

# Backup the current IPDB before making changes
backup_ipdb() {
    if [ -f "$IPDB_FILE" ]; then
        local backup_file="$IPDB_BACKUP_DIR/ipdb_$(date +%Y%m%d_%H%M%S).json"
        cp "$IPDB_FILE" "$backup_file"
        success "Created IPDB backup: $(basename "$backup_file")"
    fi
}

# Extract node information from IPDB by ID
get_node_by_id() {
    local node_id="$1"
    
    if [ ! -f "$IPDB_FILE" ]; then
        return 1
    fi
    
    # Use grep to check if the node exists first
    if ! grep -q "\"node_id\": \"$node_id\"" "$IPDB_FILE"; then
        return 1
    fi
    
    # Extract the node information
    # This is a simplified version; jq would be better for proper JSON parsing
    local start_line=$(grep -n "\"node_id\": \"$node_id\"" "$IPDB_FILE" | cut -d: -f1)
    start_line=$((start_line - 1))  # Get the line with the opening brace
    
    # Count braces to find the matching closing brace
    local line_num=$start_line
    local brace_count=0
    local node_json=""
    
    while IFS= read -r line && [ $line_num -le $(wc -l < "$IPDB_FILE") ]; do
        if [ $line_num -ge $start_line ]; then
            node_json+="$line"$'\n'
            if [[ "$line" == *"{"* ]]; then
                brace_count=$((brace_count + 1))
            fi
            if [[ "$line" == *"}"* ]]; then
                brace_count=$((brace_count - 1))
                if [ $brace_count -eq 0 ]; then
                    break
                fi
            fi
        fi
        line_num=$((line_num + 1))
    done < <(cat "$IPDB_FILE")
    
    echo "$node_json"
    return 0
}

# Extract node information from IPDB by IP address
get_node_by_ip() {
    local ip_address="$1"
    
    if [ ! -f "$IPDB_FILE" ]; then
        return 1
    fi
    
    # Check if the IP exists in the database
    if ! grep -q "\"ip_address\": \"$ip_address\"" "$IPDB_FILE"; then
        return 1
    fi
    
    # Extract node ID first
    local node_id=$(grep -B 5 "\"ip_address\": \"$ip_address\"" "$IPDB_FILE" | 
                    grep "\"node_id\"" | 
                    sed 's/.*"node_id": "\([^"]*\)".*/\1/')
    
    # Get the full node data
    get_node_by_id "$node_id"
    return $?
}

# Extract node information from IPDB by name
get_node_by_name() {
    local node_name="$1"
    
    if [ ! -f "$IPDB_FILE" ]; then
        return 1
    fi
    
    # Check if the name exists in the database
    if ! grep -q "\"node_name\": \"$node_name\"" "$IPDB_FILE"; then
        return 1
    fi
    
    # Extract node ID first
    local node_id=$(grep -B 2 "\"node_name\": \"$node_name\"" "$IPDB_FILE" | 
                    grep "\"node_id\"" | 
                    sed 's/.*"node_id": "\([^"]*\)".*/\1/')
    
    # Get the full node data
    get_node_by_id "$node_id"
    return $?
}

# Get the local IP address
get_local_ip() {
    # Try to get the IP from the local network interface
    local ip=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v "127.0.0.1" | head -n 1)
    
    # If no IP found, try to get it from hostname
    if [ -z "$ip" ]; then
        ip=$(hostname -I | awk '{print $1}')
    fi
    
    echo "$ip"
}

# Find node ID from local info
get_local_node_id() {
    # Try to get node ID from hostname
    local hostname=$(hostname)
    if [[ "$hostname" == node-* ]]; then
        # Check if this hostname exists in the database
        if grep -q "\"node_name\": \"$hostname\"" "$IPDB_FILE" 2>/dev/null; then
            local node_id=$(grep -B 2 "\"node_name\": \"$hostname\"" "$IPDB_FILE" | 
                           grep "\"node_id\"" | 
                           sed 's/.*"node_id": "\([^"]*\)".*/\1/')
            echo "$node_id"
            return 0
        fi
    fi
    
    # Try to find by IP address
    local ip=$(get_local_ip)
    if [ -n "$ip" ]; then
        local node_json=$(get_node_by_ip "$ip")
        if [ $? -eq 0 ]; then
            local node_id=$(echo "$node_json" | grep "\"node_id\"" | 
                           sed 's/.*"node_id": "\([^"]*\)".*/\1/')
            echo "$node_id"
            return 0
        fi
    fi
    
    # Not found
    return 1
}

# Find nodes in the same region
get_nodes_in_region() {
    local region="$1"
    
    if [ ! -f "$IPDB_FILE" ]; then
        return 1
    fi
    
    # Simple grep approach - would be more robust with proper JSON parser
    grep -B 10 -A 20 "\"region\": \"$region\"" "$IPDB_FILE" | 
        grep -E "\"node_id\"|\"node_name\"|\"ip_address\"|\"node_type\"|\"region\"|\"latitude\"|\"longitude\""
}

# Update node contact information
update_node_contact() {
    local node_id="$1"
    local admin_contact="$2"
    local admin_phone="$3"
    
    # Backup first
    backup_ipdb
    
    # Create timestamp
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Create a temporary file
    local temp_file=$(mktemp)
    
    # Use sed to update the contact information
    # This approach is not ideal for JSON manipulation but works in a simple case
    cat "$IPDB_FILE" | 
sed "s/\"admin_contact\": \"[^\"]*\"/\"admin_contact\": \"$admin_contact\"/g" | 
        sed "s/\"admin_phone\": \"[^\"]*\"/\"admin_phone\": \"$admin_phone\"/g" | 
        sed "s/\"last_updated\": \"[^\"]*\"/\"last_updated\": \"$timestamp\"/g" > "$temp_file"
    
    # Replace the original file
    mv "$temp_file" "$IPDB_FILE"
    
    success "Updated contact information for node $node_id"
    log_message "Updated contact for node: $node_id, Email: $admin_contact, Phone: $admin_phone"
}

# ======================================================================
# NETWORK STATUS FUNCTIONS
# ======================================================================
# Test connectivity to a node
test_connectivity() {
    local ip_address="$1"
    local result=""
    
    # Try ping
    if ping -c 3 -W 2 "$ip_address" > /dev/null 2>&1; then
        result="${GREEN}Connected${RESET} (ping successful)"
    else
        result="${RED}Unreachable${RESET} (ping failed)"
    fi
    
    echo "$result"
}

# Calculate distance between two nodes
calculate_distance() {
    local lat1="$1"
    local lon1="$2"
    local lat2="$3"
    local lon2="$4"
    
    # Convert to radians
    lat1=$(echo "$lat1 * 0.0174532925" | bc -l)
    lon1=$(echo "$lon1 * 0.0174532925" | bc -l)
    lat2=$(echo "$lat2 * 0.0174532925" | bc -l)
    lon2=$(echo "$lon2 * 0.0174532925" | bc -l)
    
    # Haversine formula
    local dlat=$(echo "$lat2 - $lat1" | bc -l)
    local dlon=$(echo "$lon2 - $lon1" | bc -l)
    
    local a=$(echo "s=$dlat/2; scale=10; (s(s))" | bc -l)
    a=$(echo "scale=10; $a + c($lat1) * c($lat2) * s($dlon/2) * s($dlon/2)" | bc -l)
    local c=$(echo "scale=10; 2 * a(sqrt($a)/sqrt(1-$a))" | bc -l)
    local distance=$(echo "scale=2; 6371 * $c" | bc -l)  # Earth radius = 6371 km
    
    echo "$distance"
}

# Display node information
    local node_json="$1"
    
    # Extract fields
    local node_id=$(echo "$node_json" | grep "\"node_id\"" | 
                   sed 's/.*"node_id": "\([^"]*\)".*/\1/')
    local node_name=$(echo "$node_json" | grep "\"node_name\"" | 
                     sed 's/.*"node_name": "\([^"]*\)".*/\1/')
    local ip_address=$(echo "$node_json" | grep "\"ip_address\"" | 
                      sed 's/.*"ip_address": "\([^"]*\)".*/\1/')
    local node_type=$(echo "$node_json" | grep "\"node_type\"" | 
                     sed 's/.*"node_type": "\([^"]*\)".*/\1/')
    local region=$(echo "$node_json" | grep "\"region\"" | 
                  sed 's/.*"region": "\([^"]*\)".*/\1/')
    local latitude=$(echo "$node_json" | grep "\"latitude\"" | 
                    sed 's/.*"latitude": \([^,}]*\).*/\1/')
    local longitude=$(echo "$node_json" | grep "\"longitude\"" | 
                     sed 's/.*"longitude": \([^,}]*\).*/\1/')
    local admin_contact=$(echo "$node_json" | grep "\"admin_contact\"" | 
                         sed 's/.*"admin_contact": "\([^"]*\)".*/\1/')
    local admin_phone=$(echo "$node_json" | grep "\"admin_phone\"" | 
                       sed 's/.*"admin_phone": "\([^"]*\)".*/\1/')
    local status=$(echo "$node_json" | grep "\"status\"" | 
                  sed 's/.*"status": "\([^"]*\)".*/\1/')
    local registration_date=$(echo "$node_json" | grep "\"registration_date\"" | 
                             sed 's/.*"registration_date": "\([^"]*\)".*/\1/')
    local last_seen=$(echo "$node_json" | grep "\"last_seen\"" | 
                     sed 's/.*"last_seen": "\([^"]*\)".*/\1/')
    local description=$(echo "$node_json" | grep "\"description\"" | 
                       sed 's/.*"description": "\([^"]*\)".*/\1/')
    
    # Format status with color
    local status_display=""
    case "$status" in
        "active")   status_display="${GREEN}Active${RESET}" ;;
        "inactive") status_display="${YELLOW}Inactive${RESET}" ;;
        "error")    status_display="${RED}Error${RESET}" ;;
        *)          status_display="${YELLOW}Unknown${RESET}" ;;
    esac
    
    # Test connectivity
    local connectivity=$(test_connectivity "$ip_address")
    
    # Display node information
    echo -e "${BOLD}${CYAN}Node Information:${RESET}"
    echo -e "${CYAN}Node ID:${RESET}        $node_id"
    echo -e "${CYAN}Node Name:${RESET}      $node_name"
    echo -e "${CYAN}Node Type:${RESET}      $node_type"
    echo -e "${CYAN}Region:${RESET}         $region"
    echo -e "${CYAN}IP Address:${RESET}     $ip_address"
    echo -e "${CYAN}Status:${RESET}         $status_display"
    echo -e "${CYAN}Connectivity:${RESET}   $connectivity"
    echo -e "${CYAN}Location:${RESET}       $latitude, $longitude"
    echo -e "${CYAN}Admin Contact:${RESET}  $admin_contact"
    echo -e "${CYAN}Admin Phone:${RESET}    $admin_phone"
    echo -e "${CYAN}Description:${RESET}    $description"
    echo -e "${CYAN}Registered:${RESET}     $registration_date"
    echo -e "${CYAN}Last Seen:${RESET}      $last_seen"
    echo
    
    # Return the region for potential further use
    echo "$region"
}

# Display nearby nodes in the same region
display_nearby_nodes() {
    local node_json="$1"
    local current_node_id=$(echo "$node_json" | grep "\"node_id\"" | 
                           sed 's/.*"node_id": "\([^"]*\)".*/\1/')
    local region=$(echo "$node_json" | grep "\"region\"" | 
                  sed 's/.*"region": "\([^"]*\)".*/\1/')
    local lat1=$(echo "$node_json" | grep "\"latitude\"" | 
                sed 's/.*"latitude": \([^,}]*\).*/\1/')
    local lon1=$(echo "$node_json" | grep "\"longitude\"" | 
                sed 's/.*"longitude": \([^,}]*\).*/\1/')
    
    echo -e "${BOLD}${CYAN}Nearby Nodes in $region:${RESET}"
    echo
    
    # Check if region information is available
    if [ -z "$region" ]; then
        warning "Region information not available for this node."
        return
    fi
    
    # Get all nodes in the region
    local region_data=$(get_nodes_in_region "$region")
    if [ -z "$region_data" ]; then
        warning "No other nodes found in this region."
        return
    fi
    
    # Process and display each node
    local current_node=""
    local in_node=0
    local node_count=0
    local nodes_info=()
    
    # Parse the region data - a simple approach that's not fully robust
    while IFS= read -r line; do
        if [[ "$line" == *"node_id"* ]]; then
            if [ $in_node -eq 1 ]; then
                # Store the previous node
                nodes_info+=("$current_node")
                current_node=""
                in_node=0
            fi
            in_node=1
            current_node="$line"
        elif [ $in_node -eq 1 ]; then
            current_node+="$line"
        fi
    done <<< "$region_data"
    
    # Add the last node if any
    if [ -n "$current_node" ]; then
        nodes_info+=("$current_node")
    fi
    
    # Display each node with distance
    echo -e "${BOLD}ID                 Name                 Type       IP Address         Distance${RESET}"
    echo -e "${BOLD}------------------------------------------------------------------------------------${RESET}"
    
    for node_info in "${nodes_info[@]}"; do
        # Extract node details
        local node_id=$(echo "$node_info" | grep "\"node_id\"" | 
                       sed 's/.*"node_id": "\([^"]*\)".*/\1/')
        
        # Skip current node
        if [ "$node_id" = "$current_node_id" ]; then
            continue
        fi
        
        local node_name=$(echo "$node_info" | grep "\"node_name\"" | 
                         sed 's/.*"node_name": "\([^"]*\)".*/\1/')
        local node_type=$(echo "$node_info" | grep "\"node_type\"" | 
                         sed 's/.*"node_type": "\([^"]*\)".*/\1/')
        local ip_address=$(echo "$node_info" | grep "\"ip_address\"" | 
                          sed 's/.*"ip_address": "\([^"]*\)".*/\1/')
        local lat2=$(echo "$node_info" | grep "\"latitude\"" | 
                    sed 's/.*"latitude": \([^,}]*\).*/\1/')
        local lon2=$(echo "$node_info" | grep "\"longitude\"" | 
                    sed 's/.*"longitude": \([^,}]*\).*/\1/')
        
        # Calculate distance if coordinates available
        local distance="Unknown"
        if [ -n "$lat1" ] && [ -n "$lon1" ] && [ -n "$lat2" ] && [ -n "$lon2" ]; then
            distance=$(calculate_distance "$lat1" "$lon1" "$lat2" "$lon2")
            distance="${distance} km"
        fi
        
        # Format display with fixed widths
        printf "%-20s %-20s %-10s %-18s %-10s\n" "$node_id" "$node_name" "$node_type" "$ip_address" "$distance"
        node_count=$((node_count + 1))
    done
    
    if [ $node_count -eq 0 ]; then
        echo "No other nodes found in this region."
    else
        echo
        echo -e "Found $node_count other node(s) in the $region region."
    fi
    echo
}

# Function to update node contact information
update_contact_info() {
    local node_id="$1"
    
    section "Update Contact Information"
    
    # Get current information
    local node_json=$(get_node_by_id "$node_id")
    if [ $? -ne 0 ]; then
        error "Failed to retrieve node information."
    fi
    
    local admin_contact=$(echo "$node_json" | grep "\"admin_contact\"" | 
                         sed 's/.*"admin_contact": "\([^"]*\)".*/\1/')
    local admin_phone=$(echo "$node_json" | grep "\"admin_phone\"" | 
                       sed 's/.*"admin_phone": "\([^"]*\)".*/\1/')
    
    echo -e "Current contact information:"
    echo -e "${CYAN}Admin Email:${RESET} $admin_contact"
    echo -e "${CYAN}Admin Phone:${RESET} $admin_phone"
    echo
    
    # Get new information
    echo "Enter new contact information (leave blank to keep current):"
    read -p "Admin Email: " new_email
    read -p "Admin Phone: " new_phone
    
    # Use existing values if not provided
    new_email=${new_email:-$admin_contact}
    new_phone=${new_phone:-$admin_phone}
    
    # Validate new email
    if ! [[ "$new_email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        error "Invalid email format. Update cancelled."
    fi
    
    # Validate new phone (simplified for example)
    if ! [[ "$new_phone" =~ ^(\+62|62|0)[0-9]{9,12}$ ]]; then
        warning "Phone format looks unusual. Make sure it's a valid Indonesian number."
        read -p "Continue with this phone number? (y/n): " confirm
        if [[ ! "$confirm" =~ ^[Yy] ]]; then
            echo "Update cancelled."
            return
        fi
    fi
    
    # Confirm update
    echo
    echo -e "New contact information:"
    echo -e "${CYAN}Admin Email:${RESET} $new_email"
    echo -e "${CYAN}Admin Phone:${RESET} $new_phone"
    echo
    
    read -p "Update this information? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy] ]]; then
        echo "Update cancelled."
        return
    fi
    
    # Perform the update
    update_node_contact "$node_id" "$new_email" "$new_phone"
}

# Show help text
show_help() {
    echo -e "${BOLD}${CYAN}ChaseWhiteRabbit Mesh Network - Node Status Tool${RESET}"
    echo
    echo -e "Usage: $0 [OPTION] [PARAMETER]"
    echo
    echo -e "${BOLD}Options:${RESET}"
    echo -e "  ${CYAN}status [node_id|ip|name]${RESET}    Display status of a specific node"
    echo -e "  ${CYAN}nearby [node_id|ip|name]${RESET}    Show nearby nodes in the same region"
    echo -e "  ${CYAN}update [node_id|ip|name]${RESET}    Update contact information for a node"
    echo -e "  ${CYAN}help${RESET}                        Display this help text"
    echo
    echo -e "${BOLD}Examples:${RESET}"
    echo -e "  $0                         # Interactive menu for local node"
    echo -e "  $0 status                  # Show status of local node"
    echo -e "  $0 status node-20250415-abcd  # Show status of specific node by ID"
    echo -e "  $0 status 10.66.1.5        # Show status of node with specific IP"
    echo -e "  $0 nearby                  # Show nodes near local node"
    echo -e "  $0 update                  # Update contact info for local node"
    echo
    echo -e "${BOLD}Note:${RESET} If no node is specified, the script will attempt to"
    echo -e "detect the local node based on hostname or IP address."
    echo
}

# Main menu for interactive mode
show_main_menu() {
    clear
    echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${CYAN}║        ChaseWhiteRabbit Mesh Network                  ║${RESET}"
    echo -e "${BOLD}${CYAN}║               Node Status Manager                     ║${RESET}"
    echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════╝${RESET}"
    echo
    
    # Try to get local node information
    local node_id=$(get_local_node_id)
    if [ $? -eq 0 ]; then
        echo -e "Local node detected: ${CYAN}$node_id${RESET}"
    else
        echo -e "${YELLOW}No local node detected. You can still check other nodes.${RESET}"
    fi
    echo
    
    echo -e "${BOLD}Options:${RESET}"
    echo -e "  ${CYAN}1)${RESET} View node status"
    echo -e "  ${CYAN}2)${RESET} View nearby nodes"
    echo -e "  ${CYAN}3)${RESET} Update contact information"
    echo -e "  ${CYAN}4)${RESET} Check specific node by ID"
    echo -e "  ${CYAN}5)${RESET} Check specific node by IP"
    echo -e "  ${CYAN}6)${RESET} Check specific node by name"
    echo -e "  ${CYAN}7)${RESET} Show help"
    echo -e "  ${CYAN}0)${RESET} Exit"
    echo
    
    read -p "Select an option [0-7]: " choice
    
    case "$choice" in
        1) # View node status
            if [ -n "$node_id" ]; then
                clear
                local node_json=$(get_node_by_id "$node_id")
                display_node_info "$node_json"
            else
                clear
                read -p "Enter node ID, IP, or name: " node_identifier
                process_node_status "$node_identifier"
            fi
            read -p "Press Enter to continue..."
            show_main_menu
            ;;
        2) # View nearby nodes
            if [ -n "$node_id" ]; then
                clear
                local node_json=$(get_node_by_id "$node_id")
                display_node_info "$node_json" > /dev/null
                display_nearby_nodes "$node_json"
            else
                clear
                read -p "Enter node ID, IP, or name to find nearby nodes: " node_identifier
                process_nearby_nodes "$node_identifier"
            fi
            read -p "Press Enter to continue..."
            show_main_menu
            ;;
        3) # Update contact information
            if [ -n "$node_id" ]; then
                clear
                update_contact_info "$node_id"
            else
                clear
                read -p "Enter node ID, IP, or name to update: " node_identifier
                process_update_contact "$node_identifier"
            fi
            read -p "Press Enter to continue..."
            show_main_menu
            ;;
        4) # Check specific node by ID
            clear
            read -p "Enter node ID: " node_id
            process_node_status "$node_id"
            read -p "Press Enter to continue..."
            show_main_menu
            ;;
        5) # Check specific node by IP
            clear
            read -p "Enter node IP address: " node_ip
            process_node_status "$node_ip"
            read -p "Press Enter to continue..."
            show_main_menu
            ;;
        6) # Check specific node by name
            clear
            read -p "Enter node name: " node_name
            process_node_status "$node_name"
            read -p "Press Enter to continue..."
            show_main_menu
            ;;
        7) # Show help
            clear
            show_help
            read -p "Press Enter to continue..."
            show_main_menu
            ;;
        0) # Exit
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo -e "${YELLOW}Invalid option. Please try again.${RESET}"
            sleep 1
            show_main_menu
            ;;
    esac
}
# Process node status request
process_node_status() {
    local identifier="$1"
    local node_json=""
    
    if [[ "$identifier" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        # This looks like an IP address
        node_json=$(get_node_by_ip "$identifier")
        if [ $? -ne 0 ]; then
            echo -e "${YELLOW}No node found with IP address: $identifier${RESET}"
            return 1
        fi
    elif [[ "$identifier" == node-* ]]; then
        # This looks like a node ID
        node_json=$(get_node_by_id "$identifier")
        if [ $? -ne 0 ]; then
            echo -e "${YELLOW}No node found with ID: $identifier${RESET}"
            return 1
        fi
    else
        # Try as a node name
        node_json=$(get_node_by_name "$identifier")
        if [ $? -ne 0 ]; then
            echo -e "${YELLOW}No node found with name: $identifier${RESET}"
            return 1
        fi
    fi
    
    # Display the node information
    display_node_info "$node_json"
    return 0
}

# Process nearby nodes request
process_nearby_nodes() {
    local identifier="$1"
    local node_json=""
    
    if [[ "$identifier" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        # This looks like an IP address
        node_json=$(get_node_by_ip "$identifier")
        if [ $? -ne 0 ]; then
            echo -e "${YELLOW}No node found with IP address: $identifier${RESET}"
            return 1
        fi
    elif [[ "$identifier" == node-* ]]; then
        # This looks like a node ID
        node_json=$(get_node_by_id "$identifier")
        if [ $? -ne 0 ]; then
            echo -e "${YELLOW}No node found with ID: $identifier${RESET}"
            return 1
        fi
    else
        # Try as a node name
        node_json=$(get_node_by_name "$identifier")
        if [ $? -ne 0 ]; then
            echo -e "${YELLOW}No node found with name: $identifier${RESET}"
            return 1
        fi
    fi
    
    # Display the nearby nodes
    local region=$(display_node_info "$node_json")
    display_nearby_nodes "$node_json"
    return 0
}

# Process update contact request
process_update_contact() {
    local identifier="$1"
    local node_id=""
    
    if [[ "$identifier" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        # This looks like an IP address
        local node_json=$(get_node_by_ip "$identifier")
        if [ $? -ne 0 ]; then
            echo -e "${YELLOW}No node found with IP address: $identifier${RESET}"
            return 1
        fi
        node_id=$(echo "$node_json" | grep "\"node_id\"" | 
                 sed 's/.*"node_id": "\([^"]*\)".*/\1/')
    elif [[ "$identifier" == node-* ]]; then
        # This looks like a node ID
        local node_json=$(get_node_by_id "$identifier")
        if [ $? -ne 0 ]; then
            echo -e "${YELLOW}No node found with ID: $identifier${RESET}"
            return 1
        fi
        node_id="$identifier"
    else
        # Try as a node name
        local node_json=$(get_node_by_name "$identifier")
        if [ $? -ne 0 ]; then
            echo -e "${YELLOW}No node found with name: $identifier${RESET}"
            return 1
        fi
        node_id=$(echo "$node_json" | grep "\"node_id\"" | 
                 sed 's/.*"node_id": "\([^"]*\)".*/\1/')
    fi
    
    # Update the contact information
    update_contact_info "$node_id"
    return 0
}

# ======================================================================
# MAIN PROGRAM
# ======================================================================
# Ensure IPDB exists
check_ipdb

# Process command line arguments
if [ $# -gt 0 ]; then
    case "$1" in
        "status")
            if [ $# -gt 1 ]; then
                process_node_status "$2"
            else
                # Try to get local node information
                local_node_id=$(get_local_node_id)
                if [ $? -eq 0 ]; then
                    process_node_status "$local_node_id"
                else
                    echo -e "${YELLOW}No local node detected. Please specify a node ID, IP, or name.${RESET}"
                    exit 1
                fi
            fi
            ;;
        "nearby")
            if [ $# -gt 1 ]; then
                process_nearby_nodes "$2"
            else
                # Try to get local node information
                local_node_id=$(get_local_node_id)
                if [ $? -eq 0 ]; then
                    process_nearby_nodes "$local_node_id"
                else
                    echo -e "${YELLOW}No local node detected. Please specify a node ID, IP, or name.${RESET}"
                    exit 1
                fi
            fi
            ;;
        "update")
            if [ $# -gt 1 ]; then
                process_update_contact "$2"
            else
                # Try to get local node information
                local_node_id=$(get_local_node_id)
                if [ $? -eq 0 ]; then
                    process_update_contact "$local_node_id"
                else
                    echo -e "${YELLOW}No local node detected. Please specify a node ID, IP, or name.${RESET}"
                    exit 1
                fi
            fi
            ;;
        "help")
            show_help
            ;;
        *)
            echo -e "${YELLOW}Unknown command: $1${RESET}"
            show_help
            exit 1
            ;;
    esac
else
    # No arguments, show the main menu
    show_main_menu
fi

exit 0
