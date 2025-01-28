#!/bin/bash

# Function to read arrow keys
read_arrow_keys() {
    while true; do
        # Read the first character (escape sequence starts with \x1b)
        read -rsn1 input

        # Check if the input is the escape character (\x1b)
        if [[ "$input" == $'\x1b' ]]; then
            # Read the next two characters
            read -rsn2 -t 0.1 input2  # -t 0.1 sets a timeout to avoid blocking
            input+="$input2"

            # Determine the arrow key
            case "$input" in
                $'\x1b[A') echo -e "Up arrow\r" ;;
                $'\x1b[B') echo -e "Down arrow\r" ;;
                $'\x1b[C') echo -e "Right arrow\r" ;;
                $'\x1b[D') echo -e "Left arrow\r" ;;
                *) echo -e "Unknown key: $(echo -n "$input" | xxd -ps)\r"  ;; #not handlled due to \ and printf in raw stty mode
            esac
        else
            # Handle other keys (e.g., 'q' to quit)
            case "$input" in
                q) echo -e  "Exiting...\r"; break ;;
                *) echo -e  "You pressed: $input\r" ;;
            esac
        fi
    done
}

# Save current terminal settings
original_stty=$(stty -g)

# Set terminal to raw mode
stty raw -echo

# Call the function to read arrow keys
clear
read_arrow_keys

# Restore terminal settings
stty "$original_stty"
clear
exit
