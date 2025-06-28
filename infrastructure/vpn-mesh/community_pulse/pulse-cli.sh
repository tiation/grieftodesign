#!/bin/bash
# ChaseWhiteRabbit Community Pulse CLI
# A lightweight interface for the community pulse system
# Optimized for limited bandwidth environments

# ======================================================================
# CONFIGURATION
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

# ======================================================================
# COMMAND IMPLEMENTATIONS
# ======================================================================
cmd_show_fun_fact() {
    local category="${1:-random}"
    local fact_file
    local today_date=$(date '+%Y-%m-%d')
    
    echo -e "${BOLD}${CYAN}=== Today's Fun Fact ===${RESET}"
    echo -e "${CYAN}${today_date}${RESET}"
    echo ""
    
    # Try to get the fact of the day
    if is_offline; then
        # In offline mode, pick a random fact from the cache
        if [ "$category" = "random" ]; then
            local width=$((count * max_width / total_team))
            
            printf "${color}%-12s${RESET} [" "$name"
            for i in $(seq 1 $width); do
                printf "${color}#${RESET}"
            done
            for i in $(seq $((width + 1)) $max_width)); do
                printf " "
            done
            printf "] ${color}%2d${RESET} (%2d%%)\n" "$count" "$percent"
        }
                printf " "
            done
            printf "] ${color}%2d${RESET} (%2d%%)\n" "$count" "$percent"
        }
        
        echo "Total team members reporting: $total_team"
        echo ""
        show_bar "Energized" $energized "🌟" "$GREEN"
        show_bar "Focused" $focused "🎯" "$CYAN"
        show_bar "Determined" $determined "💪" "$BLUE"
        show_bar "Learning" $learning "📚" "$MAGENTA"
        show_bar "Challenged" $challenged "🧩" "$YELLOW"
        show_bar "Tired" $tired "😴" "$RED"
        show_bar "Need help" $need_help "🆘" "${BOLD}${RED}"
        
        # Calculate team energy level
        energy_level=$((
            (energized * 100 + 
             focused * 80 + 
             determined * 75 + 
             learning * 65 + 
             challenged * 50 + 
             tired * 30 + 
             need_help * 20) / total_team
        ))
        
        echo ""
        echo -e "Team energy level: ${BOLD}${energy_level}%${RESET}"
        
        # Determine most common mood
        max_count=$energized
        most_common="Energized! 🌟"
        
        if [ $focused -gt $max_count ]; then
            max_count=$focused
            most_common="Focused 🎯"
        fi
        if [ $determined -gt $max_count ]; then
            max_count=$determined
            most_common="Determined 💪"
        fi
        if [ $learning -gt $max_count ]; then
            max_count=$learning
            most_common="Learning 📚"
        fi
        if [ $challenged -gt $max_count ]; then
            max_count=$challenged
            most_common="Challenged 🧩"
        fi
        if [ $tired -gt $max_count ]; then
            max_count=$tired
            most_common="Tired 😴"
        fi
        
        echo -e "Most common mood: ${BOLD}\"$most_common\"${RESET}"
        
        if [ $need_help -gt 0 ]; then
            echo -e "${RED}$need_help team members need assistance${RESET}"
        fi
        
        # Generate a daily tip based on team mood
        echo ""
        echo -e "${BOLD}${CYAN}Today's Team Tip:${RESET}"
        if [ $energy_level -gt 75 ]; then
            echo -e "Team energy is high! Great time to tackle challenging projects."
        elif [ $energy_level -gt 50 ]; then
            echo -e "Good team energy today. Focus on collaborative tasks to maintain momentum."
        elif [ $energy_level -gt 30 ]; then
            echo -e "Team energy is moderate. Consider short, focused sprints with breaks."
        else
            echo -e "Team energy is low today. Be gentle with each other and focus on essential tasks."
        fi
        
        # Cache the output for offline access
        mkdir -p "$PULSE_OFFLINE_CACHE"
        team_pulse_file="$PULSE_OFFLINE_CACHE/team_pulse.txt"
        (
            echo "Total team members reporting: $total_team"
            echo ""
            echo "Energized!   : $energized ($((energized * 100 / total_team))%)"
            echo "Focused      : $focused ($((focused * 100 / total_team))%)"
            echo "Determined   : $determined ($((determined * 100 / total_team))%)"
            echo "Learning     : $learning ($((learning * 100 / total_team))%)"
            echo "Challenged   : $challenged ($((challenged * 100 / total_team))%)"
            echo "Tired        : $tired ($((tired * 100 / total_team))%)"
            echo "Need help    : $need_help ($((need_help * 100 / total_team))%)"
            echo ""
            echo "Team energy level: ${energy_level}%"
            echo "Most common mood: \"$most_common\""
            if [ $need_help -gt 0 ]; then
                echo "$need_help team members need assistance"
            fi
            echo ""
            echo "Today's Team Tip:"
            if [ $energy_level -gt 75 ]; then
                echo "Team energy is high! Great time to tackle challenging projects."
            elif [ $energy_level -gt 50 ]; then
                echo "Good team energy today. Focus on collaborative tasks to maintain momentum."
            elif [ $energy_level -gt 30 ]; then
                echo "Team energy is moderate. Consider short, focused sprints with breaks."
            else
                echo "Team energy is low today. Be gentle with each other and focus on essential tasks."
            fi
        ) > "$team_pulse_file"
    fi
    
    echo ""
    echo -e "${MAGENTA}$(get_random_encouragement)${RESET}"
}

cmd_share_achievement() {
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

cmd_manage_offline_content() {
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
                local_repo="/media/parrot/Ventoy/ChaseWhiteRabbit/SystemAdmin/Network/community_pulse/data/fun_facts"
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
# MAIN PROGRAM
# ======================================================================
# Make sure necessary directories exist
ensure_directories

# Process command line arguments
if [ $# -gt 0 ]; then
    case "$1" in
        "fact")
            cmd_show_fun_fact "$2"
        
        if [ -f "$fact_file" ]; then
            # Get line count
            line_count=$(wc -l < "$fact_file")
            # Pick a random line number
            random_line=$((RANDOM % line_count + 1))
            # Get the fact
            fact=$(sed -n "${random_line}p" "$fact_file")
            echo -e "${BOLD}${fact}${RESET}"
        else
            echo -e "${YELLOW}No fun facts available offline for this category.${RESET}"
            echo "Try selecting another category or connecting to the network."
        fi
    else
        # Online mode - we would fetch from server
        # For now, use the local repository as a simulation
        local repos_dir="/media/parrot/Ventoy/ChaseWhiteRabbit/SystemAdmin/Network/community_pulse/data/fun_facts"
        
        if [ "$category" = "random" ]; then
            # Get a list of categories
            categories=()
            for file in "$repos_dir"/*.txt; do
                if [ -f "$file" ]; then
                    categories+=("$(basename "$file" .txt)")
                fi
            done
            
            # Choose a random category
            if [ ${#categories[@]} -gt 0 ]; then
                category="${categories[$RANDOM % ${#categories[@]}]}"
            else
                echo -e "${YELLOW}No fun fact categories available.${RESET}"
                return
            fi
        fi
        
        fact_file="$repos_dir/${category}.txt"
        
        if [ -f "$fact_file" ]; then
            # Get line count
            line_count=$(wc -l < "$fact_file")
            # Adjust for empty lines
            line_count=$((line_count - $(grep -c "^$" "$fact_file")))
            # Pick a random line number and get non-empty line
            random_line=1
            max_attempts=10
            attempt=0
            fact=""
            
            while [ -z "$fact" ] && [ $attempt -lt $max_attempts ]; do
                random_line=$((RANDOM % line_count + 1))
                fact=$(sed -n "${random_line}p" "$fact_file" | tr -d '\r' | tr -d '\n')
                attempt=$((attempt + 1))
            done
            
            if [ -n "$fact" ]; then
                # Display with category emoji
                case "$category" in
                    "indonesia_facts") emoji="🇮🇩" ;;
                    "tech_trivia") emoji="💻" ;;
                    "nature_wonders") emoji="🌿" ;;
                    "space_facts") emoji="🌌" ;;
                    "mesh_network_achievements") emoji="🌐" ;;
                    *) emoji="ℹ️" ;;
                esac
                
                echo -e "${emoji} ${BOLD}${BLUE}${category}${RESET}"
                echo -e "${BOLD}${fact}${RESET}"
                echo ""
                echo -e "${ITALIC}(This fact used only $(echo -n "$fact" | wc -c) bytes to transmit)${RESET}"
            else
                echo -e "${YELLOW}Couldn't find a good fun fact. Try again!${RESET}"
            fi
        else
            echo -e "${YELLOW}No fun facts available for category: ${category}${RESET}"
            echo "Available categories: indonesia_facts, tech_trivia, nature_wonders, space_facts"
        fi
    fi
    
    echo ""
    echo -e "${MAGENTA}$(get_random_encouragement)${RESET}"
}

cmd_submit_mood() {
    show_welcome
    
    echo -e "${BOLD}${CYAN}=== Share Your Mood ===${RESET}"
    echo "Your mood helps team leads provide better support!"
    echo ""
    
    echo -e "How are you feeling today? (1-7)"
    echo -e "1: ${GREEN}Energized! 🌟${RESET}"
    echo -e "2: ${CYAN}Focused 🎯${RESET}"
    echo -e "3: ${BLUE}Determined 💪${RESET}"
    echo -e "4: ${MAGENTA}Learning 📚${RESET}"
    echo -e "5: ${YELLOW}Challenged 🧩${RESET}"
    echo -e "6: ${RED}Tired 😴${RESET}"
    echo -e "7: ${BOLD}${RED}Need help 🆘${RESET}"
    echo ""
    
    read -p "Enter your mood (1-7): " mood_num
    
    # Validate input
    if [[ ! "$mood_num" =~ ^[1-7]$ ]]; then
        echo -e "${YELLOW}Please enter a number between 1 and 7.${RESET}"
        return 1
    fi
    
    # Get the mood text
    case "$mood_num" in
        1) mood_text="Energized! 🌟" ;;
        2) mood_text="Focused 🎯" ;;
        3) mood_text="Determined 💪" ;;
        4) mood_text="Learning 📚" ;;
        5) mood_text="Challenged 🧩" ;;
        6) mood_text="Tired 😴" ;;
        7) mood_text="Need help 🆘" ;;
    esac
    
    if [ "$mood_num" -eq 7 ]; then
        read -p "Would you like someone to reach out to you? (y/n): " need_help
        
        if [[ "$need_help" =~ ^[Yy] ]]; then
            read -p "What kind of assistance do you need? " help_text
            mood_text="${mood_text} - ${help_text}"
        fi
    fi
    
    # Log the mood locally
    log_action "Mood: $mood_text"
    mkdir -p "$PULSE_DIR/moods/"
    echo "$(date '+%Y-%m-%d %H:%M:%S') $mood_text" >> "$PULSE_DIR/moods/$(date '+%Y-%m-%d').log"
    
    if ! is_offline; then
        # Would send to server here in a real implementation
        echo -e "${GREEN}Your mood has been shared with the team.${RESET}"
        
        # Show encouraging message based on mood
        case "$mood_num" in
            1) echo -e "${GREEN}Fantastic! Your energy inspires others!${RESET}" ;;
            2) echo -e "${CYAN}Great! Your focus helps us achieve our goals!${RESET}" ;;
            3) echo -e "${BLUE}Excellent! Your determination keeps us moving forward!${RESET}" ;;
            4) echo -e "${MAGENTA}Wonderful! Learning is how we grow together!${RESET}" ;;
            5) echo -e "${YELLOW}Good on you! Challenges make us stronger!${RESET}" ;;
            6) echo -e "${RED}Thank you for sharing. Remember to rest when needed!${RESET}" ;;
            7) echo -e "${BOLD}${RED}Thank you for reaching out. Support is what teams are for!${RESET}" ;;
        esac
    else
        echo -e "${YELLOW}You're offline. Your mood will be shared when connectivity returns.${RESET}"
    fi
    
    echo ""
    echo -e "${MAGENTA}$(get_random_encouragement)${RESET}"
}

cmd_check_team_pulse() {
    show_welcome
    
    echo -e "${BOLD}${CYAN}=== Team Pulse ===${RESET}"
    echo -e "${CYAN}How is our team feeling today?${RESET}"
    echo ""
    
    if is_offline; then
        # In offline mode, show the last cached team pulse
        if [ -f "$PULSE_OFFLINE_CACHE/team_pulse.txt" ]; then
            cat "$PULSE_OFFLINE_CACHE/team_pulse.txt"
            echo ""
            echo -e "${YELLOW}(Cached data - last updated $(stat -c %y "$PULSE_OFFLINE_CACHE/team_pulse.txt" | cut -d. -f1))${RESET}"
        else
            echo -e "${YELLOW}No team pulse data available offline.${RESET}"
            echo "Team pulse will be available when you connect to the network."
        fi
    else
        # Online mode - we would fetch from server
        # For now, generate a simulated pulse as a demonstration
        
        # Generate a random distribution of moods
        total_team=23  # Random team size
        energized=$((RANDOM % 8 + 3))
        focused=$((RANDOM % 8 + 5))
        determined=$((RANDOM % 6 + 2))
        learning=$((RANDOM % 5 + 2))
        challenged=$((RANDOM % 5 + 2))
        tired=$((RANDOM % 4 + 1))
        need_help=$((RANDOM % 3))
        
        # Ensure the total matches
        sum=$((energized + focused + determined + learning + challenged + tired + need_help))
        if [ $sum -ne $total_team ]; then
            # Adjust focused (the largest group) to make the numbers add up
            focused=$((focused + (total_team - sum)))
        fi
        
        # Generate ASCII bar chart
        max_width=40
        
        function show_bar() {
            local name="$1"
            local count="$2"
            local emoji="$3"
            local color="$4"
            local percent=$((count * 100 / total_team))
            local width=$((count * max_width / total_team))
            
            printf "${color}%-12s${RESET} [" "$name"
            for i in $(seq 1 $width); do
                printf "${color}#${RESET}"
            done
            for i in $(seq $((width + 

