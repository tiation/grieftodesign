
#!/bin/bash
# ChaseWhiteRabbit Community Pulse - Utility Functions
# Contains helper functions used by other modules

# Import configuration
source "$(dirname "$0")/config.sh"

# ======================================================================
# BANDWIDTH DETECTION
# ======================================================================
get_bandwidth_profile() {
    # If we can read the bandwidth profile directly, use it
    if [ -f "$BANDWIDTH_PROFILE_FILE" ]; then
        grep -q "profile.extremely_limited" "$BANDWIDTH_PROFILE_FILE" && echo "extremely_limited" && return
        grep -q "profile.very_limited" "$BANDWIDTH_PROFILE_FILE" && echo "very_limited" && return
        grep -q "profile.limited" "$BANDWIDTH_PROFILE_FILE" && echo "limited" && return
        grep -q "profile.moderate" "$BANDWIDTH_PROFILE_FILE" && echo "moderate" && return
        grep -q "profile.good" "$BANDWIDTH_PROFILE_FILE" && echo "good" && return
        grep -q "profile.excellent" "$BANDWIDTH_PROFILE_FILE" && echo "excellent" && return
    fi
    
    # Otherwise, do a simple connectivity check
    if ping -c 1 -W 1 $PULSE_SERVER >/dev/null 2>&1; then
        echo "limited"  # Default to conservative estimate
    else
        echo "offline"
    fi
}

# Check if we're in offline mode
is_offline() {
    [ "$(get_bandwidth_profile)" = "offline" ]
}

# Should we use compression?
should_compress() {
    profile=$(get_bandwidth_profile)
    [ "$profile" = "extremely_limited" ] || [ "$profile" = "very_limited" ] || [ "$profile" = "limited" ]
}

# ======================================================================
# HELPER FUNCTIONS
# ======================================================================
log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $PULSE_USER: $1" >> "$PULSE_LOG"
}

show_welcome() {
    clear
    echo -e "${BOLD}${CYAN}=== ChaseWhiteRabbit Community Pulse ===${RESET}"
    echo -e "${CYAN}Connecting our team across the archipelago${RESET}"
    echo -e "${YELLOW}Current bandwidth profile:${RESET} $(get_bandwidth_profile)"
    echo ""
    
    # Show different messages based on bandwidth availability
    profile=$(get_bandwidth_profile)
    if [ "$profile" = "offline" ]; then
        echo -e "${YELLOW}You're currently offline - using cached content${RESET}"
    elif [ "$profile" = "extremely_limited" ]; then
        echo -e "${YELLOW}Limited connectivity - conserving bandwidth mode${RESET}"
    else
        echo -e "${GREEN}Connected to the mesh network! :)${RESET}"
    fi
    echo ""
}

get_random_encouragement() {
    encouragements=(
        "You're making a difference!"
        "Your work connects communities!"
        "Every node matters - thank you!"
        "Together across distances!"
        "Building bridges, byte by byte!"
        "Your efforts ripple outward!"
        "Technology with heart and purpose!"
        "The archipelago's unsung heroes!"
        "Keeping Indonesia connected!"
        "Small packets, big impact!"
    )
    echo "${encouragements[$RANDOM % ${#encouragements[@]}]}"
}

ensure_directories() {
    mkdir -p "$PULSE_DIR" "$PULSE_OFFLINE_CACHE" "$(dirname "$PULSE_LOG")"
    # Only try to create if permissions allow
    touch "$PULSE_LOG" 2>/dev/null || true
}

# Error handling function
handle_error() {
    local error_message="$1"
    echo -e "${RED}Error: ${error_message}${RESET}" >&2
    log_action "ERROR: $error_message"
    exit 1
}

