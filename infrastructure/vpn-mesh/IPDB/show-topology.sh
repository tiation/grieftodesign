#!/bin/bash
# ChaseWhiteRabbit Mesh Network - Network Topology Visualization
# This script generates a visual representation of the mesh network

# ======================================================================
# CONFIGURATION
# ======================================================================
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
IPDB_FILE="$SCRIPT_DIR/ipdb.json"
REGIONS_FILE="$SCRIPT_DIR/regions.json"
MAX_WIDTH=80  # Maximum width for display
MAX_HEIGHT=30  # Maximum height for display (approximately)
PING_TIMEOUT=1  # Timeout for ping in seconds
CONNECTION_TEST=true  # Set to false to skip connectivity testing (faster)

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

# Display error and exit
error() {
    echo -e "${RED}Error: $1${RESET}" >&2
    exit 1
}

# Check if IPDB exists
check_ipdb() {
    if [ ! -f "$IPDB_FILE" ]; then
        error "IPDB database not found at $IPDB_FILE. Please run install-ipdb.sh first."
    fi
}

# Count nodes in IPDB
count_nodes() {
    if command -v jq >/dev/null 2>&1; then
        jq '.nodes | length' "$IPDB_FILE"
    else
        grep -o '"node_id"' "$IPDB_FILE" | wc -l
    fi
}

# Extract nodes from IPDB
extract_nodes() {
    if command -v jq >/dev/null 2>&1; then
        jq -c '.nodes[]' "$IPDB_FILE"
    else
        # Simplified extraction without jq
        node_lines=$(grep -n '"node_id"' "$IPDB_FILE" | cut -d: -f1)
        prev_line=0
        for line in $node_lines; do
            if [ $prev_line -ne 0 ]; then
                # Extract node block between the previous node_id and this one
                sed -n "$prev_line,$((line-1))p" "$IPDB_FILE" | tr -d '\n' | sed 's/,$//'
                echo
            fi
            prev_line=$line
        done
        # Extract the last node
        if [ $prev_line -ne 0 ]; then
            sed -n "$prev_line,$(grep -n ']' "$IPDB_FILE" | head -1 | cut -d: -f1)p" "$IPDB_FILE" | tr -d '\n' | sed 's/,$//'
        fi
                # Display different markers based on distance and connectivity
                if [ "$connectivity" = "unreachable" ]; then
                    printf " ${RED}✕${RESET}%-3s |" ""
                elif (( $(echo "$distance > 50" | bc -l) )); then
                    printf " ${YELLOW}~${RESET}%-3s |" ""
                else
                    printf " ${GREEN}⬤${RESET}%-3s |" ""
                fi
            fi
        done
        echo
        
        # Separator line
        if [ $i -lt $(( ${#all_nodes[@]} - 1 )) ]; then
            echo "├───────┼$(printf '──────┼%.0s' $(seq 1 ${#all_nodes[@]}))"
        fi
    done
    echo "└───────┴$(printf '──────┴%.0s' $(seq 1 ${#all_nodes[@]}))"
    echo
    

# Show network statistics
show_network_stats() {
    local node_count=$(count_nodes)
    
    if [ "$node_count" -eq 0 ]; then
        echo -e "${YELLOW}No nodes found in the IPDB. Use register-node.sh to add nodes.${RESET}"
        return
    fi
    
    echo -e "${BOLD}${CYAN}ChaseWhiteRabbit Mesh Network Statistics${RESET}"
    echo "==============================================="
    echo
    
    # Count nodes by type and region
    local gateway_count=0
    local relay_count=0
    local standard_count=0
    local active_count=0
    local inactive_count=0
    local error_count=0
    declare -A region_counts
    
    while read -r node_data; do
        local node_type=$(extract_field "$node_data" "node_type")
        local status=$(extract_field "$node_data" "status")
        local region=$(extract_field "$node_data" "region")
        
        # Count by type
        if [ "$node_type" = "gateway" ]; then
            gateway_count=$((gateway_count + 1))
        elif [ "$node_type" = "relay" ]; then
            relay_count=$((relay_count + 1))
        else
            standard_count=$((standard_count + 1))
        fi
        
        # Count by status
        if [ "$status" = "active" ]; then
            active_count=$((active_count + 1))
        elif [ "$status" = "inactive" ]; then
            inactive_count=$((inactive_count + 1))
        elif [ "$status" = "error" ]; then
            error_count=$((error_count + 1))
        fi
        
        # Count by region
        if [ -n "$region" ]; then
            if [ -z "${region_counts[$region]}" ]; then
                region_counts["$region"]=1
            else
                region_counts["$region"]=$((region_counts["$region"] + 1))
            fi
        fi
    done < <(extract_nodes)
    
    # Display node type statistics
    echo -e "${BOLD}Node Types:${RESET}"
    echo "  Gateways: $gateway_count"
    echo "  Relays: $relay_count"
    echo "  Standard Nodes: $standard_count"
    echo
    
    # Display node status statistics
    echo -e "${BOLD}Node Status:${RESET}"
    echo -e "  ${GREEN}Active: $active_count${RESET}"
    echo -e "  ${YELLOW}Inactive: $inactive_count${RESET}"
    echo -e "  ${RED}Error: $error_count${RESET}"
    echo
    
    # Display region statistics
    echo -e "${BOLD}Nodes by Region:${RESET}"
    for region in "${!region_counts[@]}"; do
        echo "  $region: ${region_counts[$region]}"
    done
    echo
    
    # Display connectivity statistics if connectivity testing is enabled
    if [ "$CONNECTION_TEST" = "true" ]; then
        echo -e "${BOLD}Testing node connectivity...${RESET}"
        
        local total_connections=0
        local successful_connections=0
        
        # Extract all nodes
        local all_nodes=()
        while read -r node_data; do
            all_nodes+=("$node_data")
        done < <(extract_nodes)
        
        # Test connections between nodes
        for i in "${!all_nodes[@]}"; do
            local node_data="${all_nodes[$i]}"
            local ip_address=$(extract_field "$node_data" "ip_address")
            
            for j in "${!all_nodes[@]}"; do
                if [ $i -ne $j ]; then
                    local other_node="${all_nodes[$j]}"
                    local other_ip=$(extract_field "$other_node" "ip_address")
                    
                    total_connections=$((total_connections + 1))
                    if [ "$(test_connectivity "$other_ip")" = "connected" ]; then
                        successful_connections=$((successful_connections + 1))
                    fi
                fi
            done
        done
        
        # Calculate connectivity percentage
        local connectivity_percentage=0
        if [ $total_connections -gt 0 ]; then
            connectivity_percentage=$(echo "scale=1; $successful_connections * 100 / $total_connections" | bc)
        fi
        
        echo "  Total possible connections: $total_connections"
        echo "  Successful connections: $successful_connections"
        echo -e "  Connectivity rate: ${BOLD}${connectivity_percentage}%${RESET}"
        echo
    fi
}

# Show help text
show_help() {
    echo -e "${BOLD}${CYAN}ChaseWhiteRabbit Mesh Network - Topology Viewer${RESET}"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help            Show this help message"
    echo "  -c, --compact         Show compact view (matrix representation)"
    echo "  -s, --stats           Show network statistics"
    echo "  -n, --no-test         Skip connectivity testing (faster)"
    echo "  -r, --region REGION   Show only nodes in the specified region"
    echo
    echo "Examples:"
    echo "  $0                    Show normal topology view"
    echo "  $0 --compact          Show compact matrix view"
    echo "  $0 --stats            Show network statistics"
    echo "  $0 --no-test          Show topology without testing connectivity"
    echo "  $0 --region ID-JK     Show only nodes in Jakarta region"
    echo
}

# ======================================================================
# MAIN PROGRAM
# ======================================================================
# Check if IPDB exists
check_ipdb

# Default values
VIEW_MODE="normal"
SHOW_STATS=false
FILTER_REGION=""

# Process command line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -c|--compact)
            VIEW_MODE="compact"
            shift
            ;;
        -s|--stats)
            SHOW_STATS=true
            shift
            ;;
        -n|--no-test)
            CONNECTION_TEST=false
            shift
            ;;
        -r|--region)
            if [ -n "$2" ]; then
                FILTER_REGION="$2"
                shift 2
            else
                error "Region code must be specified with --region option"
            fi
            ;;
        *)
            error "Unknown option: $1"
            ;;
    esac
done

# Display the appropriate view
if [ "$SHOW_STATS" = "true" ]; then
    show_network_stats
else
    if [ "$VIEW_MODE" = "compact" ]; then
        generate_compact_view
    else
        generate_topology
    fi
fi
exit 0
    fi
}

# Extract field from node data
extract_field() {
    local node_data="$1"
    local field="$2"
    
    if echo "$node_data" | grep -q "\"$field\""; then
        echo "$node_data" | sed -n "s/.*\"$field\"[[:space:]]*:[[:space:]]*\"\([^\"]*\).*/\1/p"
    else
        echo ""
    fi
}

# Extract numeric field from node data
extract_numeric_field() {
    local node_data="$1"
    local field="$2"
    
    if echo "$node_data" | grep -q "\"$field\""; then
        echo "$node_data" | sed -n "s/.*\"$field\"[[:space:]]*:[[:space:]]*\([0-9.-]*\).*/\1/p"
    else
        echo "0"
    fi
}

# Test connectivity between nodes
test_connectivity() {
    local ip_address="$1"
    
    if [ "$CONNECTION_TEST" = "true" ]; then
        if ping -c 1 -W $PING_TIMEOUT "$ip_address" >/dev/null 2>&1; then
            echo "connected"
        else
            echo "unreachable"
        fi
    else
        # Skip actual testing, assume connected
        echo "connected"
    fi
}

# Calculate distance between nodes
calculate_distance() {
    local lat1="$1"
    local lon1="$2"
    local lat2="$3"
    local lon2="$4"
    
    if command -v bc >/dev/null 2>&1; then
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
        local distance=$(echo "scale=1; 6371 * $c" | bc -l)  # Earth radius = 6371 km
        
        echo "$distance"
    else
        # Simplified distance calculation without bc (less accurate)
        local dlat=$(echo "$lat2 - $lat1" | awk '{print ($1 < 0) ? -$1 : $1}')
        local dlon=$(echo "$lon2 - $lon1" | awk '{print ($1 < 0) ? -$1 : $1}')
        local approx_distance=$(echo "$dlat $dlon" | awk '{print sqrt($1*$1 + $2*$2) * 111}')  # 1 degree ≈ 111 km
        printf "%.1f" $approx_distance
    fi
}

# Display connection quality marker
connection_marker() {
    local distance="$1"
    local status="$2"
    
    if [ "$status" = "unreachable" ]; then
        echo -e "${RED}✕${RESET}"  # Unreachable
    elif (( $(echo "$distance > 50" | bc -l) )); then
        echo -e "${YELLOW}~${RESET}"  # Long distance
    else
        echo -e "${GREEN}⬤${RESET}"  # Good connection
    fi
}

# Get node type symbol
node_type_symbol() {
    local node_type="$1"
    local status="$2"
    
    # Choose color based on status
    local color="$GREEN"
    if [ "$status" = "inactive" ]; then
        color="$YELLOW"
    elif [ "$status" = "error" ]; then
        color="$RED"
    fi
    
    # Choose symbol based on node type
    if [ "$node_type" = "gateway" ]; then
        echo -e "${color}[G]${RESET}"  # Gateway
    elif [ "$node_type" = "relay" ]; then
        echo -e "${color}[R]${RESET}"  # Relay
    else
        echo -e "${color}[N]${RESET}"  # Standard node
    fi
}

# ======================================================================
# VISUALIZATION FUNCTIONS
# ======================================================================
# Generate a simple network topology diagram
generate_topology() {
    local node_count=$(count_nodes)
    
    if [ "$node_count" -eq 0 ]; then
        echo -e "${YELLOW}No nodes found in the IPDB. Use register-node.sh to add nodes.${RESET}"
        return
    fi
    
    echo -e "${BOLD}${CYAN}ChaseWhiteRabbit Mesh Network Topology${RESET}"
    echo -e "${CYAN}Total nodes: $node_count${RESET}"
    echo
    
    # Group nodes by region
    declare -A regions
    while read -r node_data; do
        local region=$(extract_field "$node_data" "region")
        if [ -n "$region" ]; then
            regions["$region"]=1
        fi
    done < <(extract_nodes)
    
    # Display nodes by region
    for region in "${!regions[@]}"; do
        echo -e "${BOLD}Region: $region${RESET}"
        echo "----------------------------------------"
        
        # Get all nodes in this region
        local region_nodes=()
        while read -r node_data; do
            local node_region=$(extract_field "$node_data" "region")
            if [ "$node_region" = "$region" ]; then
                region_nodes+=("$node_data")
            fi
        done < <(extract_nodes)
        
        # Display nodes with connections
        for node_data in "${region_nodes[@]}"; do
            local node_id=$(extract_field "$node_data" "node_id")
            local node_name=$(extract_field "$node_data" "node_name")
            local ip_address=$(extract_field "$node_data" "ip_address")
            local node_type=$(extract_field "$node_data" "node_type")
            local status=$(extract_field "$node_data" "status")
            local latitude=$(extract_numeric_field "$node_data" "latitude")
            local longitude=$(extract_numeric_field "$node_data" "longitude")
            
            # Show node info
            local type_symbol=$(node_type_symbol "$node_type" "$status")
            echo -e "$type_symbol $node_name ($ip_address)"
            
            # Show connections to other nodes in the region
            for other_node in "${region_nodes[@]}"; do
                local other_id=$(extract_field "$other_node" "node_id")
                
                # Skip self-connections
                if [ "$other_id" = "$node_id" ]; then
                    continue
                fi
                
                local other_name=$(extract_field "$other_node" "node_name")
                local other_ip=$(extract_field "$other_node" "ip_address")
                local other_lat=$(extract_numeric_field "$other_node" "latitude")
                local other_lon=$(extract_numeric_field "$other_node" "longitude")
                
                # Calculate distance and test connectivity
                local distance=$(calculate_distance "$latitude" "$longitude" "$other_lat" "$other_lon")
                local connectivity=$(test_connectivity "$other_ip")
                local marker=$(connection_marker "$distance" "$connectivity")
                
                # Only show connection once (lower ID to higher ID)
                if [[ "$node_id" < "$other_id" ]]; then
                    echo -e "  ├── $marker ${BLUE}${distance}km${RESET} → $other_name"
                fi
            done
        done
        echo
    done
}

# Generate a more compact visual representation
generate_compact_view() {
    local node_count=$(count_nodes)
    
    if [ "$node_count" -eq 0 ]; then
        echo -e "${YELLOW}No nodes found in the IPDB. Use register-node.sh to add nodes.${RESET}"
        return
    fi
    
    echo -e "${BOLD}${CYAN}ChaseWhiteRabbit Mesh Network - Compact View${RESET}"
    echo -e "${CYAN}Total nodes: $node_count${RESET}"
    echo
    
    echo -e "${BOLD}Legend:${RESET} ${GREEN}[G]${RESET}=Gateway ${BLUE}[R]${RESET}=Relay ${CYAN}[N]${RESET}=Node"
    echo -e "         ${GREEN}⬤${RESET}=Good connection ${YELLOW}~${RESET}=Long distance ${RED}✕${RESET}=Unreachable"
    echo
    
    # Extract all nodes
    local all_nodes=()
    while read -r node_data; do
        all_nodes+=("$node_data")
    done < <(extract_nodes)
    
    # Display connectivity matrix
    echo -e "${BOLD}Node Connectivity Matrix:${RESET}"
    echo "┌────────────────────────────┐"
    echo "│ FROM → TO ↓                │"
    echo "├────────────────────────────┤"
    
    # Header row with node IDs
    echo -n "│       │"
    local node_ids=()
    for node_data in "${all_nodes[@]}"; do
        local short_id=$(extract_field "$node_data" "node_id" | cut -d'-' -f3)
        node_ids+=("$short_id")
        printf " %-4s |" "$short_id"
    done
    echo
    echo "├───────┼$(printf '──────┼%.0s' $(seq 1 ${#all_nodes[@]}))"
    
    # Matrix rows
    for i in "${!all_nodes[@]}"; do
        local node_data="${all_nodes[$i]}"
        local node_id=$(extract_field "$node_data" "node_id")
        local short_id="${node_ids[$i]}"
        local node_type=$(extract_field "$node_data" "node_type")
        local status=$(extract_field "$node_data" "status")
        local ip_address=$(extract_field "$node_data" "ip_address")
        local latitude=$(extract_numeric_field "$node_data" "latitude")
        local longitude=$(extract_numeric_field "$node_data" "longitude")
        
        # Type symbol
        local type_symbol=""
        if [ "$node_type" = "gateway" ]; then
            type_symbol="${GREEN}G${RESET}"
        elif [ "$node_type" = "relay" ]; then
            type_symbol="${BLUE}R${RESET}"
        else
            type_symbol="${CYAN}N${RESET}"
        fi
        
        # Row header
        printf "│ %s %-3s │" "$type_symbol" "$short_id"
        
        # Connection cells
        for j in "${!all_nodes[@]}"; do
            if [ $i -eq $j ]; then
                # Self connection
                printf " %-4s |" "—"
            else
                local other_node="${all_nodes[$j]}"
                local other_ip=$(extract_field "$other_node" "ip_address")
                local other_lat=$(extract_numeric_field "$other_node" "latitude")
                local other_lon=$(extract_numeric_field "$other_node" "longitude")
                
                # Calculate distance and check connectivity
                local distance=$(calculate_distance "$latitude" "$longitude" "$other_lat" "$other_lon")
                local connectivity=$(test_connectivity "$other_ip")
                
                # Display different markers based on distance and connectivity
                if [ "$connectivity" = "unreachable" ]; then
                    printf " ${RED}✕${RESET}%-3s |" ""
                elif (( $(echo "$distance > 50" | bc -l) )); then
                    printf " ${YELLOW}~${RESET}%-3s |" ""
                else
                    printf " ${GREEN}⬤${RESET}%-3s |" ""
                fi
            fi
        done
        echo
        
        # Add separator line between rows
        if [ $i -lt $(( ${#all_nodes[@]} - 1 )) ]; then
            echo "├───────┼$(printf '──────┼%.0s' $(seq 1 ${#all_nodes[@]}))"
        fi
    done
    echo "└───────┴$(printf '──────┴%.0s' $(seq 1 ${#all_nodes[@]}))"
    
    # Show node details table
    echo
    echo -e "${BOLD}Node Details:${RESET}"
    echo "┌───────────────────────────────────────────────────────────┐"
    printf "│ %-5s | %-20s | %-15s | %-15s │\n" "ID" "Name" "IP Address" "Type/Status"
    echo "├───────┼──────────────────────┼─────────────────┼─────────────────┤"
    
    for i in "${!all_nodes[@]}"; do
        local node_data="${all_nodes[$i]}"
        local short_id="${node_ids[$i]}"
        local node_name=$(extract_field "$node_data" "node_name")
        local ip_address=$(extract_field "$node_data" "ip_address")
        local node_type=$(extract_field "$node_data" "node_type")
        local status=$(extract_field "$node_data" "status")
        
        # Truncate long names
        if [ ${#node_name} -gt 20 ]; then
            node_name="${node_name:0:17}..."
        fi
        
        # Status color
        local status_color="$GREEN"
        if [ "$status" = "inactive" ]; then
            status_color="$YELLOW"
        elif [ "$status" = "error" ]; then
            status_color="$RED"
        fi
        
        printf "│ %-5s | %-20s | %-15s | %s%-15s${RESET} │\n" "$short_id" "$node_name" "$ip_address" "$status_color" "$node_type/$status"
    done
    echo "└───────┴──────────────────────┴─────────────────┴─────────────────┘"
    
    # Show legend
    echo
    echo -e "${BOLD}Node Types:${RESET}"
    echo -e "  ${GREEN}G${RESET} = Gateway"
    echo -e "  ${BLUE}R${RESET} = Relay"
    echo -e "  ${CYAN}N${RESET} = Standard Node"
    echo
    echo -e "${BOLD}Connection Types:${RESET}"
    echo -e "  ${GREEN}⬤${RESET} = Good connection (distance ≤ 50km)"
    echo -e "  ${YELLOW}~${RESET} = Long distance (> 50km)"
    echo -e "  ${RED}✕${RESET} = Unreachable"
    echo
}
