#!/bin/bash
# ChaseWhiteRabbit Community Pulse - Configuration
# Contains all configuration settings for the pulse system

# ======================================================================
# SYSTEM CONFIGURATION
# ======================================================================
PULSE_VERSION="1.0.0"
PULSE_DIR="/var/cache/mesh-network/community_pulse"
PULSE_CONFIG="/etc/mesh-network/community_pulse/pulse-config.yaml"
PULSE_SERVER="pulse.mesh.local"
PULSE_USER="$USER"
PULSE_LOG="/var/log/mesh-network/community_pulse.log"
PULSE_OFFLINE_CACHE="$PULSE_DIR/offline_cache"
BANDWIDTH_PROFILE_FILE="/etc/mesh-network/bandwidth.conf"

# ======================================================================
# APPEARANCE SETTINGS
# ======================================================================
# Text colors and formatting
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
BOLD="\033[1m"
ITALIC="\033[3m"
RESET="\033[0m"

# Repository paths
LOCAL_FACT_REPO="/media/parrot/Ventoy/ChaseWhiteRabbit/SystemAdmin/Network/community_pulse/data/fun_facts"

