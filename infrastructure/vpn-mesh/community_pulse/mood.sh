
#!/bin/bash
# ChaseWhiteRabbit Community Pulse - Mood Module
# Handles sharing and displaying team mood information

# Import configuration and utilities
source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/utils.sh"

# Submit your current mood
submit_mood() {
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

# Show team pulse visualization
check_team_pulse() {
    show_welcome
    
    echo -e "${BOLD}${CYAN}=== Team Pulse ===${RESET}"
    echo -e "${CYAN}How is our team feeling today?${RESET}"
    echo ""
    
    if is_offline; then
        # In offline mode, show the last cached team pulse
        if [ -f "$PULSE_OFFLINE_CACHE/team_pulse.txt" ]; then
            cat "$PULSE_OFFLINE_CACHE/team_pulse.txt"
            echo ""
            echo -e "${YELLOW}(Cached data - last updated $(stat -c %

