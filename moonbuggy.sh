#!/bin/bash

# Moon Buggy Game in Bash

# Initialize variables
buggy_pos=5
obstacle_pos=20
score=0
game_over=0



# Function to draw the game screen
draw_screen() {
    clear
    # echo -e "$(tput lines)\n"  #gets screen size to use later or not
    # echo -e "$(tput cols)\n"
    echo "Score: $score"
    echo "Use a and d to move, w to jump"
    echo
    #need to draw buggy, rock and spaces in one loop otherwise it would erase others
    for ((i=0; i<=20; i++)); do
        if [[ $i -eq $buggy_pos ]]; then
            echo -n "^"
        elif [[ $i -eq $obstacle_pos ]]; then
            echo -n "O"
        else
            echo -n " "
        fi
    done
    echo
}
read_keys(){
key=" " # reset key for no repeat
 # Read the first character (escape sequence starts with \x1b)
        read -rsn1 input

        # Check if the input is the escape character (\x1b)
        if [[ "$input" == $'\x1b' ]]; then
            # Read the next two characters
            read -rsn2 -t 0.1 input2  # -t 0.1 sets a timeout to avoid blocking
            input+="$input2"

            # Determine the arrow key
            case "$input" in
                $'\x1b[A')  key="j" ;;# Up arrow
                $'\x1b[B')  key=" " ;; # Down arrow
                $'\x1b[C')  key="d" ;; # Right arrow
                $'\x1b[D')  key="a" ;; # Left arrow
                esac
        else
            # Handle other keys (e.g., 'q' to quit)
            case "$input" in
                q) echo -e  "Exiting...\r"; exit ;;
                #*) key=" " ;; #echo -e  "You pressed: $input\r" ;;
            esac
        fi
}

# Function to move the buggy
move_buggy() {
   # read -s -n 1 key
    case $key in
        a) ((buggy_pos--)) ;;
        d) ((buggy_pos++)) ;;
        q) game_over=1 ;;
    esac
    echo "$buggy_pos"
    # Ensure buggy stays within bounds
    if [[ $buggy_pos -lt 0 ]]; then
        buggy_pos=0
    elif [[ $buggy_pos -ge 20 ]]; then
        buggy_pos=19
    fi
}

# Function to move the obstacle
move_obstacle() {
    ((obstacle_pos--))
    if [[ $obstacle_pos -lt 0 ]]; then
        obstacle_pos=19
        ((score++))
    fi
}

# Function to check for collision
check_collision() {
    if [[ $buggy_pos -eq $obstacle_pos ]]; then
        game_over=1
    fi
}

# Main game loop
while [[ $game_over -eq 0 ]]; do
    draw_screen
    move_buggy
    move_obstacle
    check_collision
    read_keys
    sleep 0.1
done

# Game over screen
clear
echo "Game Over!"
echo "Final Score: $score"






