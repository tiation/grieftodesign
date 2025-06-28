#!/bin/bash
# ChaseWhiteRabbit Mesh Network - IPDB Installation Script
# This script sets up the IP Database system for the mesh network

# ======================================================================
# CONFIGURATION
# ======================================================================
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
IPDB_DIR="$SCRIPT_DIR"
IPDB_FILE="$IPDB_DIR/ipdb.json"
IPDB_BACKUP_DIR="$IPDB_DIR/backups"
NODE_CONFIG_DIR="$IPDB_DIR/node_configs"
REGIONS_FILE="$IPDB_DIR/regions.json"
LOG_DIR="$IPDB_DIR/logs"
INSTALLATION_LOG="$LOG_DIR/installation.log"

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
    echo "[ERROR] $1" >> "$INSTALLATION_LOG" 2>/dev/null
    exit 1
}

# Log a message
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$INSTALLATION_LOG" 2>/dev/null
}

# ======================================================================
# INSTALLATION FUNCTIONS
# ======================================================================
# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check and install dependencies
check_dependencies() {
    section "Checking Dependencies"
    
    dependencies=("bc" "jq")
    missing_deps=()
    
    for dep in "${dependencies[@]}"; do
        if command_exists "$dep"; then
            success "$dep is already installed"
        else
            warning "$dep is not installed"
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        step "Installing missing dependencies..."
        
        # Check if we're root
        if [ "$EUID" -ne 0 ]; then
            warning "Not running as root. Some dependencies may not be installed."
            warning "Run 'sudo apt-get install ${missing_deps[*]}' to install them manually."
        else
            # Try to install the missing dependencies
            apt-get update -qq
            for dep in "${missing_deps[@]}"; do
                if apt-get install -y "$dep"; then
                    success "Installed $dep"
                    log_message "Installed dependency: $dep"
                else
                    warning "Failed to install $dep. Some functions may not work properly."
                    log_message "Failed to install dependency: $dep"
                fi
            done
        fi
    fi
    
    # Fallback for bc - warn if it's still missing
    if ! command_exists "bc"; then
        warning "bc is required for distance calculations. Some features may not work correctly."
    fi
    
    # Fallback for jq - warn that we'll use simpler JSON handling
    if ! command_exists "jq"; then
        warning "jq is recommended for JSON handling. Will use fallback methods."
    fi
    
    success "Dependency check completed"
}

# Create directory structure
create_directory_structure() {
    section "Creating Directory Structure"
    
    # Create main directories
    directories=(
        "$IPDB_DIR"
        "$IPDB_BACKUP_DIR"
        "$NODE_CONFIG_DIR"
        "$LOG_DIR"
    )
    
    for dir in "${directories[@]}"; do
        if [ -d "$dir" ]; then
            step "$dir already exists"
        else
            mkdir -p "$dir"
            success "Created $dir"
            log_message "Created directory: $dir"
        fi
    done
    
    success "Directory structure created"
}

# Initialize the IPDB database
initialize_ipdb() {
    section "Initializing IPDB Database"
    
    # Check if the database already exists
    if [ -f "$IPDB_FILE" ]; then
        step "IPDB database already exists"
        read -p "Overwrite existing database? (y/n): " overwrite
        if [[ ! "$overwrite" =~ ^[Yy] ]]; then
            success "Keeping existing database"
            return
        fi
        
        # Backup the existing database
        backup_file="$IPDB_BACKUP_DIR/ipdb_$(date +%Y%m%d_%H%M%S).json"
        cp "$IPDB_FILE" "$backup_file"
        success "Backed up existing database to $(basename "$backup_file")"
        log_message "Backed up database to: $backup_file"
    fi
    
    # Create a new empty database
    step "Creating new IPDB database"
    
    echo '{
  "nodes": [],
  "last_updated": "'"$(date -u +"%Y-%m-%dT%H:%M:%SZ")"'",
  "version": "1.0"
}' > "$IPDB_FILE"
    
    success "Initialized IPDB database"
    log_message "Initialized IPDB database"
}

# Initialize the regions file
initialize_regions() {
    section "Initializing Regions"
    
    # Check if the regions file already exists
    if [ -f "$REGIONS_FILE" ]; then
        step "Regions file already exists"
        read -p "Overwrite existing regions file? (y/n): " overwrite
        if [[ ! "$overwrite" =~ ^[Yy] ]]; then
            success "Keeping existing regions file"
            return
        fi
    fi
    
    # Create a new regions file
    step "Creating regions file with Indonesian regions"
    
    echo '{
  "regions": [
    {
      "code": "ID-JK",
      "name": "Jakarta",
      "subnet": "10.66.1.0/24",
      "coordinates": {
        "latitude": -6.2088,
        "longitude": 106.8456
      }
    },
    {
      "code": "ID-SU",
      "name": "Sumatra",
      "subnet": "10.66.2.0/24",
      "coordinates": {
        "latitude": 3.5952,
        "longitude": 98.6722
      }
    },
    {
      "code": "ID-JA",
      "name": "Java (outside Jakarta)",
      "subnet": "10.66.3.0/24",
      "coordinates": {
        "latitude": -7.2575,
        "longitude": 112.7521
      }
    },
    {
      "code": "ID-KA",
      "name": "Kalimantan",
      "subnet": "10.66.4.0/24",
      "coordinates": {
        "latitude": -0.0236,
        "longitude": 109.3425
      }
    },
    {
      "code": "ID-SL",
      "name": "Sulawesi",
      "subnet": "10.66.5.0/24",
      "coordinates": {
        "latitude": -5.1477,
        "longitude": 119.4327
      }
    },
    {
      "code": "ID-ML",
      "name": "Maluku",
      "subnet": "10.66.6.0/24",
      "coordinates": {
        "latitude": -3.7057,
        "longitude": 128.1823
      }
    },
    {
      "code": "ID-PP",
      "name": "Papua",
      "subnet": "10.66.7.0/24",
      "coordinates": {
        "latitude": -2.5916,
        "longitude": 140.6690
      }
    },
    {
      "code": "ID-BA",
      "name": "Bali",
      "subnet": "10.66.8.0/24",
      "coordinates": {
        "latitude": -8.6705,
        "longitude": 115.2126
      }
    },
    {
      "code": "ID-NT",
      "name": "Nusa Tenggara",
      "subnet": "10.66.9.0/24",
      "coordinates": {
        "latitude": -8.5833,
        "longitude": 116.1167
      }
    }
  ]
}' > "$REGIONS_FILE"
    
    success "Initialized regions file"
    log_message "Initialized regions file"
}

# Set up script permissions
setup_permissions() {
    section "Setting Up Permissions"
    
    # Make the scripts executable
    step "Making scripts executable"
    
    # Main scripts
    chmod +x "$IPDB_DIR/register-node.sh" "$IPDB_DIR/node-status.sh" "$IPDB_DIR/install-ipdb.sh"
    success "Made main scripts executable"
    log_message "Set executable permissions on scripts"
    
    # Set appropriate permissions for the data files
    step "Setting appropriate permissions for data files"
    
    # Ensure the IPDB is writable
    chmod 644 "$IPDB_FILE" 2>/dev/null
    chmod 755 "$IPDB_DIR" "$IPDB_BACKUP_DIR" "$NODE_CONFIG_DIR" "$LOG_DIR" 2>/dev/null
    
    success "Set permissions on data files"
    log_message "Set file permissions on data directories"
}

# Create symlinks for easier access
create_symlinks() {
    section "Creating Symlinks"
    
    # Check if user bin directory exists
    user_bin="$HOME/bin"
    if [ -d "$user_bin" ]; then
        step "Creating symlinks in $user_bin"
        
        # Create symlinks
        ln -sf "$IPDB_DIR/register-node.sh" "$user_bin/register-node"
        ln -sf "$IPDB_DIR/node-status.sh" "$user_bin/node-status"
        
        success "Created symlinks in $user_bin"
        log_message "Created symlinks in user bin directory"
    else
        # If user bin doesn't exist, try ~/.local/bin
        user_local_bin="$HOME/.local/bin"
        if [ -d "$user_local_bin" ]; then
            step "Creating symlinks in $user_local_bin"
            
            # Create symlinks
            ln -sf "$IPDB_DIR/register-node.sh" "$user_local_bin/register-node"
            ln -sf "$IPDB_DIR/node-status.sh" "$user_local_bin/node-status"
            
            success "Created symlinks in $user_local_bin"
            log_message "Created symlinks in user local bin directory"
        else
            warning "No suitable bin directory found for symlinks"
            warning "You can access the scripts directly from $IPDB_DIR"
            log_message "No suitable bin directory found for symlinks"
        fi
    fi
}

# ======================================================================
# MAIN INSTALLATION
# ======================================================================
clear
echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${CYAN}║        ChaseWhiteRabbit Mesh Network                  ║${RESET}"
echo -e "${BOLD}${CYAN}║               IPDB Installation                       ║${RESET}"
echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════╝${RESET}"
echo
echo -e "This script will set up the IP Database (IPDB) system for the"
echo -e "ChaseWhiteRabbit mesh network. It will create the necessary"
echo -e "directory structure, initialize the database, and set up"
echo -e "the required permissions."
echo

# Create log directory first
mkdir -p "$LOG_DIR" 2>/dev/null

# Start installation log
log_message "Starting IPDB installation"

# Ask for confirmation
read -p "Continue with installation? (y/n): " confirm
if [[ ! "$confirm" =~ ^[Yy] ]]; then
    echo "Installation cancelled."
    log_message "Installation cancelled by user"
    exit 0
fi

# Run installation steps
check_dependencies
create_directory_structure
initialize_ipdb
initialize_regions
setup_permissions
create_symlinks

# ======================================================================
# COMPLETION
# ======================================================================
section "Installation Complete!"

echo -e "${GREEN}The IPDB system has been successfully installed!${RESET}"
echo
echo -e "${BOLD}Available Commands:${RESET}"
echo -e "  ${CYAN}./register-node.sh${RESET}    - Register a new node in the IPDB"
echo -e "  ${CYAN}./node-status.sh${RESET}      - Check node status and manage nodes"
echo

if [ -d "$HOME/bin" ] || [ -d "$HOME/.local/bin" ]; then
    echo -e "${BOLD}Symlinks:${RESET}"
    echo -e "  You can now use the following commands from anywhere:"
    echo -e "  ${CYAN}register-node${RESET}     - Register a new node"
    echo -e "  ${CYAN}node-status${RESET}       - Check node status"
    echo
fi

echo -e "${BOLD}Next Steps:${RESET}"
echo -e "1. Register your first node with: ${CYAN}./register-node.sh${RESET}"
echo -e "2. Check the node status with: ${CYAN}./node-status.sh${RESET}"
echo
echo -e "${YELLOW}Note:${RESET} Make sure to run register-node.sh for each node in your mesh network."
echo

log_message "Installation completed successfully"
echo -e "${MAGENTA}Thank you for setting up the ChaseWhiteRabbit mesh network!${RESET}"
echo -e "${MAGENTA}Together, we're building connections across Indonesia.${RESET}"
echo

exit 0

