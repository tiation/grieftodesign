#!/bin/bash
# ChaseWhiteRabbit Community Pulse - Installation Script
# Sets up the Community Pulse system for local use

# Get the script's directory
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
cd "$SCRIPT_DIR" || { echo "Failed to change to script directory"; exit 1; }

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

# Display error message
error() {
    echo -e "${RED}✗ $1${RESET}" >&2
}

# Show a progress animation
progress() {
    local message="$1"
    local pid=$!
    local spin='-\|/'
    local i=0
    
    echo -ne "${BLUE}➤ ${message}... ${RESET}"
    
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 4 ))
        echo -ne "\b${spin:$i:1}"
        sleep .1
    done
    
    echo -ne "\b${GREEN}✓${RESET}\n"
}

# ======================================================================
# WELCOME MESSAGE
# ======================================================================
clear
echo -e "${BOLD}${CYAN}
╔═══════════════════════════════════════════════════╗
║             ChaseWhiteRabbit Project              ║
║           Community Pulse Installation            ║
╚═══════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "Welcome to the Community Pulse installation process!"
echo -e "This script will set up the Community Pulse system to help"
echo -e "connect your team across Indonesia, even with limited connectivity."
echo ""
echo -e "${YELLOW}This will install Community Pulse in:${RESET}"
echo -e "${BOLD}$SCRIPT_DIR${RESET}"

# Ask for confirmation
read -p "Continue with installation? (y/n): " confirm
if [[ ! "$confirm" =~ ^[Yy] ]]; then
    echo "Installation cancelled."
    exit 0
fi

# ======================================================================
# SETUP DIRECTORIES
# ======================================================================
section "Setting Up Directories"

step "Creating system directories"
# Main directories
directories=(
    "/var/cache/mesh-network/community_pulse"
    "/var/cache/mesh-network/community_pulse/offline_cache"
    "/var/log/mesh-network"
    "/etc/mesh-network/community_pulse"
)

# Check if we have permission, otherwise use local directories
has_root=false
if [ "$EUID" -eq 0 ]; then
    has_root=true
else
    warning "Not running as root. Will use local directories instead."
    # Use local directories instead
    directories=(
        "$HOME/.cache/mesh-network/community_pulse"
        "$HOME/.cache/mesh-network/community_pulse/offline_cache"
        "$HOME/.local/share/mesh-network/logs"
        "$HOME/.config/mesh-network/community_pulse"
    )
fi

# Create directories
for dir in "${directories[@]}"; do
    if [ -d "$dir" ]; then
        echo "  - $dir (already exists)"
    else
        mkdir -p "$dir" && echo "  - $dir (created)" || warning "Failed to create $dir"
    fi
done

# ======================================================================
# MAKE SCRIPTS EXECUTABLE
# ======================================================================
section "Setting Up Scripts"

step "Making scripts executable"
scripts=(
    "pulse.sh"
    "config.sh"
    "utils.sh"
    "fun_facts.sh"
    "mood.sh"
)

for script in "${scripts[@]}"; do
    if [ -f "$script" ]; then
        chmod +x "$script" && echo "  - $script" || warning "Failed to make $script executable"
    else
        warning "Script not found: $script"
    fi
done

# ======================================================================
# CONFIGURE SYSTEM
# ======================================================================
section "Creating Configuration"

step "Updating configuration settings"
if ! $has_root; then
    # Update config.sh to use local directories
    sed -i "s|/var/cache/mesh-network/community_pulse|$HOME/.cache/mesh-network/community_pulse|g" config.sh
    sed -i "s|/var/log/mesh-network/community_pulse.log|$HOME/.local/share/mesh-network/logs/community_pulse.log|g" config.sh
    sed -i "s|/etc/mesh-network/community_pulse|$HOME/.config/mesh-network/community_pulse|g" config.sh
    success "Updated configuration to use local directories"
else
    success "Using system directories for configuration"
fi

# Create a mock bandwidth profile for testing
step "Creating mock bandwidth profile"
if $has_root; then
    profile_file="/etc/mesh-network/bandwidth.conf"
else
    profile_file="$HOME/.config/mesh-network/bandwidth.conf"
fi

cat > "$profile_file" << EOF
# Mock bandwidth profile for testing
profile.limited = true
bandwidth_limit = 1024
EOF
success "Created mock bandwidth profile for testing"

# ======================================================================
# PREPARE CONTENT
# ======================================================================
section "Setting Up Content"

step "Ensuring data directories exist"
mkdir -p "data/fun_facts" || warning "Failed to create fun facts directory"

step "Checking fun facts data"
if [ -d "data/fun_facts" ] && [ "$(ls -A data/fun_facts/*.txt 2>/dev/null | wc -l)" -gt 0 ]; then
    success "Fun facts data is already present"
else
    warning "No fun facts found. Creating sample data..."
    
    # Create sample fun facts if they don't exist
    mkdir -p "data/fun_facts"
    
    # Create indonesia_facts.txt if it doesn't exist
    if [ ! -f "data/fun_facts/indonesia_facts.txt" ]; then
        cat > "data/fun_facts/indonesia_facts.txt" << EOF
Indonesia is the world's largest archipelago with over 17,000 islands!
The Komodo dragon, the world's largest lizard, is native only to Indonesia.
Indonesia has the second longest coastline in the world after Canada.
Batik, a traditional Indonesian textile art, is recognized by UNESCO as a Masterpiece of Cultural Heritage.
EOF
        success "Created sample Indonesia facts"
    fi
    
    # Create tech_trivia.txt if it doesn't exist
    if [ ! -f "data/fun_facts/tech_trivia.txt" ]; then
        cat > "data/fun_facts/tech_trivia.txt" << EOF
The first computer bug was an actual insect - a moth found in a Harvard Mark II computer in 1947!
The average person types about 40 words per minute, but the world record is 216 words per minute.
Wi-Fi doesn't actually stand for anything - it's just a trademark meaning wireless fidelity.
The first website ever created is still online: http://info.cern.ch/
EOF
        success "Created sample tech trivia"
    fi
    
    success "Sample fun facts created successfully"
fi

# Create offline directory structure
step "Setting up offline content structure"
if $has_root; then
    cache_dir="/var/cache/mesh-network/community_pulse/offline_cache"
else
    cache_dir="$HOME/.cache/mesh-network/community_pulse/offline_cache"
fi

mkdir -p "$cache_dir"/{fun_facts,tips,templates,emergency} || warning "Failed to create offline cache directories"
success "Offline content structure prepared"

# Pre-populate offline cache with some fun facts
if [ -d "data/fun_facts" ]; then
    cp data/fun_facts/*.txt "$cache_dir/fun_facts/" 2>/dev/null
    success "Copied fun facts to offline cache"
fi

# ======================================================================
# CREATE SYMLINKS
# ======================================================================
section "Creating Easy Access"

# Create a symlink in user's bin directory
if [ -d "$HOME/bin" ]; then
    step "Creating a symlink in your bin directory"
    ln -sf "$SCRIPT_DIR/pulse.sh" "$HOME/bin/pulse" && \
    success "Created symlink at $HOME/bin/pulse" || \
    warning "Failed to create symlink in $HOME/bin"
elif [ -d "$HOME/.local/bin" ]; then
    step "Creating a symlink in your .local/bin directory"
    ln -sf "$SCRIPT_DIR/pulse.sh" "$HOME/.local/bin/pulse" && \
    success "Created symlink at $HOME/.local/bin/pulse" || \
    warning "Failed to create symlink in $HOME/.local/bin"
else
    warning "No suitable bin directory found for symlink creation"
fi

# ======================================================================
# INSTALLATION COMPLETED
# ======================================================================
section "Installation Complete!"

echo -e "${GREEN}Community Pulse has been successfully installed!${RESET}"
echo ""
echo -e "${BOLD}Quick Start:${RESET}"
echo -e "1. Run ${CYAN}./pulse.sh${RESET} to open the main menu"
echo -e "2. Or try a direct command: ${CYAN}./pulse.sh fact${RESET}"
echo ""
echo -e "${BOLD}Available Commands:${RESET}"
echo -e "${CYAN}./pulse.sh${RESET}                    - Show the main menu"
echo -e "${CYAN}./pulse.sh fact${RESET} [category]    - Show a random fun fact"
echo -e "${CYAN}./pulse.sh mood${RESET}               - Share your current mood"
echo -e "${CYAN}./pulse.sh pulse${RESET}              - Check the team pulse"
echo -e "${CYAN}./pulse.sh achievement${RESET}        - Share a team achievement"
echo -e "${CYAN}./pulse.sh offline${RESET}            - Manage offline content"
echo -e "${CYAN}./pulse.sh help${RESET}               - Show help information"
echo ""

if [ -L "$HOME/bin/pulse" ]; then
    echo -e "${YELLOW}TIP:${RESET} You can now simply type ${CYAN}pulse${RESET} from anywhere to access Community Pulse!"
elif [ -L "$HOME/.local/bin/pulse" ]; then
    echo -e "${YELLOW}TIP:${RESET} You can now simply type ${CYAN}pulse${RESET} from anywhere to access Community Pulse!"
else 
    echo -e "${YELLOW}TIP:${RESET} For easier access, consider adding this directory to your PATH,"
    echo -e "      or manually create a symlink to pulse.sh in a directory in your PATH."
fi

echo ""
echo -e "${MAGENTA}Thank you for installing Community Pulse!${RESET}"
echo -e "${MAGENTA}Together, we're building connections across the archipelago.${RESET}"
echo ""

