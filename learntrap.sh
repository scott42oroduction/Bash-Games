#!/bin/bash

# Function to print terminal dimensions
print_dimensions() {
    rows=$(tput lines)
    cols=$(tput cols)
    echo "Terminal dimensions: Rows: $rows, Columns: $cols"
}

catch_ctrl_c() {
	echo -e "\rCaught ctrl c, SIGTERM, ERR....exiting"
	exit
}

# Print initial dimensions
print_dimensions

# Trap SIGWINCH (window resize signal)
trap print_dimensions SIGWINCH

trap catch_ctrl_c SIGINT SIGTERM ERR

# Keep the script running to catch resize events
while true; do
    sleep 1
done
