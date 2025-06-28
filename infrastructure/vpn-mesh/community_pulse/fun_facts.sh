
#!/bin/bash
# ChaseWhiteRabbit Community Pulse - Fun Facts Module
# Handles displaying fun facts to users

# Import configuration and utilities
source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/utils.sh"

# Show a fun fact from the specified category (or random)
show_fun_fact() {
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
            # Get list of fact files
            fact_files=("$PULSE_OFFLINE_CACHE"/fun_facts/*.txt)
            # Pick a random file
            fact_file="${fact_files[$RANDOM % ${#fact_files[@]}]}"
        else
            fact_file="$PULSE_OFFLINE_CACHE/fun_facts/${category}.txt"
        fi
        
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
        local repos_dir="$LOCAL_FACT_REPO"
        
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

