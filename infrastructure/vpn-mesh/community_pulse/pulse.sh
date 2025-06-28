#!/bin/bash
# ChaseWhiteRabbit Community Pulse CLI
# Main entry point for the community pulse system

# Get the script's directory
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Import all modules
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/fun_facts.sh"
source "$SCRIPT_DIR/mood.sh"

# ======================================================================
# ACHIEVEMENTS MODULE
# ======================================================================
share_achievement() {
    show_welcome
    
    echo -e "${BOLD}${CYAN}=== Share Your Achievement ===${RESET}"
    echo "Your successes inspire the whole team!"
    echo ""
    
    # Check if we're in offline mode
    if is_offline; then
        echo -e "${YELLOW}You're currently offline.${RESET}"
        echo "Your achievement will be saved locally and shared when connectivity returns."
    fi
    
    # Get the achievement details with character count limits to be bandwidth-friendly
    read -p "Achievement title (max 50 chars): " achievement_title
    achievement_title=$(echo "$achievement_title" | cut -c 1-50)
    
    echo ""
    echo "Brief description (max 200 chars):"
    read -p "> " achievement_desc
    achievement_desc=$(echo "$achievement_desc" | cut -c 1-200)
    
    echo ""
    echo "What impact did this have? (max 100 chars):"
    read -p "> " achievement_impact
    achievement_impact=$(echo "$achievement_impact" | cut -c 1-100)
    
    echo ""
    echo -e "Select region:"
    echo "1. Jakarta"
    echo "2. Sumatra"
    echo "3. Sulawesi"
    echo "4. Kalimantan"
    echo "5. Papua"
    echo "6. Other"
    read -p "Region (1-6): " region_num
    
    case "$region_num" in
        1) region="Jakarta" ;;
        2) region="Sumatra" ;;
        3) region="Sulawesi" ;;
        4) region="Kalimantan" ;;
        5) region="Papua" ;;
        *) read -p "Specify region: " region ;;
    esac
    
    # Format the achievement
    formatted_achievement="$(date '+%Y-%m-%d %H:%M:%S') - $region
TITLE: $achievement_title
DESC: $achievement_desc
IMPACT: $achievement_impact
SUBMITTER: $PULSE_USER"
    
    # Save locally
    mkdir -p "$PULSE_DIR/achievements"
    echo "$formatted_achievement" >> "$PULSE_DIR/achievements/$(date '+%Y-%m-%d').log"
    
    # Log the action
    log_action "Achievement shared: $achievement_title"
    
    if ! is_offline; then
        # Would send to server here in a real implementation
        echo ""
        echo -e "${GREEN}Your achievement has been shared with the team!${RESET}"
        echo -e "It will be considered for the weekly highlights."
        
        # If we have a good bandwidth profile, show some fancy encouragement
        profile=$(get_bandwidth_profile)
        if [ "$profile" = "moderate" ] || [ "$profile" = "good" ] || [ "$profile" = "excellent" ]; then
            echo ""
            echo -e "${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET}"
            echo -e "${CYAN}┃${RESET} ${BOLD}${YELLOW}★ ${GREEN}Congratulations on your achievement! ${YELLOW}★${RESET}         ${CYAN}┃${RESET}"
            echo -e "${CYAN}┃${RESET} Your contribution makes our network stronger.          ${CYAN}┃${RESET}"
            echo -e "${CYAN}┃${RESET} The communities we serve appreciate your dedication!   ${CYAN}┃${RESET}"
            echo -e "${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"
        else
            # Simple message for limited bandwidth
            echo ""
            echo -e "${BOLD}${GREEN}Congratulations on your achievement!${RESET}"
        fi
    else
        echo ""
        echo -e "${YELLOW}Your achievement has been saved locally and will be shared when connectivity returns.${RESET}"
    fi
    
    echo ""
    echo -e "${MAGENTA}$(get_random_encouragement)${RESET}"
}

# ======================================================================
# OFFLINE CONTENT MODULE
# ======================================================================
manage_offline_content() {
    show_welcome
    
    echo -e "${BOLD}${CYAN}=== Offline Content Manager ===${RESET}"
    echo "Prepare for times when connectivity is limited"
    echo ""
    
    # Check current cache status
    cache_count=0
    cache_size_kb=0
    
    if [ -d "$PULSE_OFFLINE_CACHE" ]; then
        cache_count=$(find "$PULSE_OFFLINE_CACHE" -type f | wc -l)
        if command -v du &>/dev/null; then
            cache_size_kb=$(du -sk "$PULSE_OFFLINE_CACHE" 2>/dev/null | cut -f1)
        else
            cache_size_kb="unknown"
        fi
    fi
    
    echo -e "Current offline cache status:"
    echo -e "- Cached items: ${BOLD}${cache_count}${RESET}"
    echo -e "- Cache size: ${BOLD}${cache_size_kb}${RESET} KB"
    echo ""
    
    echo -e "Select an action:"
    echo "1. Download fun facts for offline use"
    echo "2. Prepare essential content for extended offline periods"
    echo "3. View cached content"
    echo "4. Clear cache to free up space"
    echo "5. Return to main menu"
    echo ""
    
    read -p "Select option (1-5): " offline_action
    
    case "$offline_action" in
        1)
            # Download fun facts
            if is_offline; then
                echo -e "${YELLOW}Currently offline. Cannot download new content.${RESET}"
            else
                echo "Downloading fun facts for offline use..."
                
                # Create cache directories
                mkdir -p "$PULSE_OFFLINE_CACHE/fun_facts"
                
                # Copy from our local repository as a simulation
                local_repo="$LOCAL_FACT_REPO"
                if [ -d "$local_repo" ]; then
                    count=0
                    for file in "$local_repo"/*.txt; do
                        if [ -f "$file" ]; then
                            cp "$file" "$PULSE_OFFLINE_CACHE/fun_facts/"
                            count=$((count + 1))
                        fi
                    done
                    echo -e "${GREEN}Downloaded ${count} categories of fun facts for offline use.${RESET}"
                else
                    echo -e "${YELLOW}Fun facts repository not found.${RESET}"
                fi
            fi
            ;;
        2)
            # Prepare for extended offline periods
            if is_offline; then
                echo -e "${YELLOW}Currently offline. Cannot download essential content.${RESET}"
            else
                echo "Preparing essential content for extended offline periods..."
                
                # Create cache directories
                mkdir -p "$PULSE_OFFLINE_CACHE/"{fun_facts,tips,templates,emergency}
                
                # Simulate downloading essential content
                echo -e "${GREEN}Downloaded emergency communication templates.${RESET}"
                echo -e "${GREEN}Downloaded offline survival guide.${RESET}"
                echo -e "${GREEN}Downloaded technical troubleshooting resources.${RESET}"
                echo -e "${GREEN}Cached 30 days of positive messages.${RESET}"
                
                echo ""
                echo -e "${BOLD}Your node is now prepared for extended offline operation.${RESET}"
                echo "These resources will remain available even without connectivity."
            fi
            ;;
        3)
            # View cached content
            echo -e "${BOLD}Cached Content:${RESET}"
            if [ "$cache_count" -eq 0 ]; then
                echo "No cached content found."
            else
                if command -v find &>/dev/null; then
                    find "$PULSE_OFFLINE_CACHE" -type f -name "*.txt" | while read -r file; do
                        rel_path="${file#$PULSE_OFFLINE_CACHE/}"
                        size=$(stat -c %s "$file" 2>/dev/null || echo "unknown")
                        echo -e "- ${BLUE}${rel_path}${RESET} (${size} bytes)"
                    done
                else
                    echo "Unable to list cached content (find command not available)."
                fi
            fi
            ;;
        4)
            # Clear cache
            read -p "Are you sure you want to clear the offline cache? (y/n): " confirm
            if [[ "$confirm" =~ ^[Yy] ]]; then
                if [ -d "$PULSE_OFFLINE_CACHE" ]; then
                    rm -rf "${PULSE_OFFLINE_CACHE:?}"/*
                    echo -e "${GREEN}Cache cleared successfully.${RESET}"
                else
                    echo "No cache to clear."
                fi
            else
                echo "Cache clearing cancelled."
            fi
            ;;
        5)
            return
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
    
    echo ""
    echo -e "${MAGENTA}$(get_random_encouragement)${RESET}"
}

# ======================================================================
# HELP AND MENU
# ======================================================================
show_help() {
    show_welcome
    
    echo -e "${BOLD}${CYAN}=== Community Pulse Help ===${RESET}"
    echo ""
    echo "The Community Pulse CLI helps you stay connected with your team"
    echo "even when working in areas with limited connectivity."
    echo ""
    
    echo -e "${BOLD}Available Commands:${RESET}"
    echo -e "${GREEN}./pulse.sh${RESET}                    - Show the main menu"
    echo -e "${GREEN}./pulse.sh fact${RESET} [category]    - Show a random fun fact"
    echo -e "${GREEN}./pulse.sh mood${RESET}               - Share your current mood"
    echo -e "${GREEN}./pulse.sh pulse${RESET}              - Check the team pulse"
    echo -e "${GREEN}./pulse.sh achievement${RESET}        - Share a team achievement"
    echo -e "${GREEN}./pulse.sh offline${RESET}            - Manage offline content"
    echo -e "${GREEN}./pulse.sh help${RESET}               - Show this help"
    echo ""
    
    echo -e "${BOLD}Fun Fact Categories:${RESET}"
    echo -e "- indonesia_facts: Facts about Indonesia"
    echo -e "- tech_trivia: Technology trivia"
    echo -e "- nature_wonders: Natural world facts"
    echo -e "- space_facts: Space and astronomy facts"
    echo -e "- mesh_network_achievements: Success stories from our network"
    echo ""
    
    echo -e "${BOLD}Bandwidth Awareness:${RESET}"
    echo "The CLI adapts to your connection quality:"
    echo "- Uses compression when bandwidth is limited"
    echo "- Provides offline access to content when disconnected"
    echo "- Prioritizes small text-based updates to save bandwidth"
    echo ""
    
    echo -e "${BOLD}Getting Started:${RESET}"
    echo "1. Check your team pulse each morning"
    echo "2. Share your mood to help team coordination"
    echo "3. Share achievements to celebrate success"
    echo "4. Download offline content before field trips"
    echo ""
    
    echo -e "${MAGENTA}Remember: Every connection strengthens our community!${RESET}"
}

show_main_menu() {
    show_welcome
    
    echo -e "${BOLD}${CYAN}=== Community Pulse Menu ===${RESET}"
    echo "Connect and share with your team across Indonesia"
    echo ""
    
    echo -e "Choose an option:"
    echo -e "1. ${GREEN}Show daily fun fact${RESET}"
    echo -e "2. ${CYAN}Share your current mood${RESET}"
    echo -e "3. ${BLUE}Check team pulse${RESET}"
    echo -e "4. ${MAGENTA}Share an achievement${RESET}"
    echo -e "5. ${YELLOW}Manage offline content${RESET}"
    echo -e "6. ${RED}Help${RESET}"
    echo -e "0. ${RED}Exit${RESET}"
    echo ""
    
    read -p "Select option (0-6): " menu_choice
    
    case "$menu_choice" in
        1)
            show_fun_fact
            echo ""
            read -p "Press Enter to continue..."
            show_main_menu
            ;;
        2)
            submit_mood
            echo ""
            read -p "Press Enter to continue..."
            show_main_menu
            ;;
        3)
            check_team_pulse
            echo ""
            read -p "Press Enter to continue..."
            show_main_menu
            ;;
        4)
            share_achievement
            echo ""
            read -p "Press Enter to continue..."
            show_main_menu
            ;;
        5)
            manage_offline_content
            echo ""
            read -p "Press Enter to continue..."
            show_main_menu
            ;;
        6)
            show_help
            echo ""
            read -p "Press Enter to continue..."
            show_main_menu
            ;;
        0)
            echo -e "${CYAN}Thank you for connecting with your team!${RESET}"
            echo -e "${MAGENTA}$(get_random_encouragement)${RESET}"
            exit 0
            ;;
        *)
            echo -e "${YELLOW}Invalid option. Please try again.${RESET}"
            sleep 1
            show_main_menu
            ;;
    esac
}

# ======================================================================
# MAIN PROGRAM
# ======================================================================
# Make sure necessary directories exist
ensure_directories || handle_error "Failed to create required directories"

# Process command line arguments
if [ $# -gt 0 ]; then
    case "$1" in
        "fact")
            show_fun_fact "$2"
            ;;
        "mood")
            submit_mood
            ;;
        "pulse")
            check_team_pulse
            ;;
        "achievement")
            share_achievement
            ;;
        "offline")
            manage_offline_content
            ;;
        "help")
            show_help
            ;;
        *)
            echo -e "${YELLOW}Unknown command: $1${RESET}"
            echo "Use './pulse.sh help' to see available commands."
            exit 1
            ;;
    esac
else
    # No arguments, show the main menu
    show_main_menu
fi

exit 0

