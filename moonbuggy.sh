#!/bin/bash

# Moon Buggy Game in Bash

# Initialize variables
jump_off=0    # turn on jump
jump_delay=0   # reset delay
buggy_height=0 # down to earth, gravity sucks
buggy_image="^"
key=0
buggy_pos=5
buggy_height=0
obstacle_pos=20
score=0
game_over=0

echo -e "\033[?25l" #turn off cursor [?12l 
stty -echo #turn off echo key presses

put_car() { #needs x,y values
# teseting solid
echo -e ${1} " " ${2}
echo -e '\033[41m' # back ground color 41 red
echo -e '\033[31m' # fore ground color 31 red
echo -e "\033[${2};${1}H   " # print chars [] at x,y top 3 chars
echo -e "\033[$(( ${2} + 1 ));$(( ${1} - 1 ))H  " # print chars [] at x,y trunck
echo -e '\033[30m' # fore ground color 30 black tires
echo -e "\033[$(( ${2} + 1 ));$(( ${1} + 0 ))Ho  o "  # print chars [] at x,y door
#echo -e '\033[31m' # fore ground color 31 red
#echo -e "\033[$(( ${2} + 1 ));$(( ${1} + 3 ))H  " # print chars [] at x,y hood
 sleep 20 #testing only
 reset
 }
put_car 7 11
exit #testing
# Function to draw the game screen
draw_screen() {
    clear
    # echo -e "$(tput lines)\n"  #gets screen size to use later or not
    # echo -e "$(tput cols)\n"
    echo "Score: $score"
    echo "Use arrows to move, q to quit"
    echo
    #need to draw buggy, rock and spaces in one loop otherwise it would erase others
    # first loop for top level
        for ((i=0; i<=20; i++)); do 
        if [[ $i -eq $buggy_pos && buggy_height -eq 1 ]]; then
            echo -n "^"
        else
            echo -n " "
        fi
    done
    echo -e "\r" # start new line
    #loop for main level
    for ((i=0; i<=20; i++)); do
        if [[ $i -eq $buggy_pos && buggy_height -eq 0 ]]; then
            echo -n "$buggy_image"
        elif [[ $i -eq $obstacle_pos ]]; then
            echo -n "O"
        else
            echo -n " "
        fi
    done
    echo -e "\n______________________________" # print the floor...NICE TILE!!!
}
read_keys(){
 key=0 # reset key for no repeat
 # Read the first character (escape sequence starts with \x1b)
        read -rsn1 -t 0.2 input #read -r -s -N1 -t '0.1'

        # Check if the input is the escape character (\x1b)
        if [[ "$input" == $'\x1b' ]]; then
            # Read the next two characters
            read -rsn2 -t 0.1 input2  # -t 0.2 sets a timeout to avoid blocking
            input+="$input2"

            # Determine the arrow key
            case "$input" in
                $'\x1b[A')  key=1 ;; # Up arrow j for jump
                $'\x1b[B')  key=2 ;; # Down arrow
                $'\x1b[C')  key=3 ;; # Right arrow
                $'\x1b[D')  key=4 ;; # Left arrow
                esac
        else
            # Handle other keys (e.g., 'q' to quit)
            case "$input" in
                q) our_exit ;;
                #*) key=5 ;; # echo -e  "You pressed: $input\r" ;;
            esac
        fi
}

# Function for our exit
our_exit() {
 # now done in detonation    draw_screen # needed or the game ends without showing collision
 echo -e "\033[?25h" # show cursor
 stty echo # echo key presses
 echo -e "Game Over! \r"
 echo -e  "Exiting...Final score is: $score \r"
 exit
}

# Function to move the buggy
move_buggy() {
  # need gravity, control buggy jump, all aspects, feels like micro managing, micro gravity
    if [[ jump_delay -eq 2 ]]; then 
  # we are up second frame, come down, reset
           # no re-jump before landing, reset toggles
           jump_off=0    # turn on jump
           jump_delay=0   # reset delay
           buggy_height=0 # down to earth, gravity sucks
    elif [[ jump_delay -eq 1 ]]; then 
  # we are up for first frame
           # should be off already jump_off=1    # shut off jump, no hold the jump key
           jump_delay=2  # no short jump, we try 1 frame delay, jump_delay=2
    elif [[ jump_off -eq 0 && jump_delay -eq 0 ]]; then 
   # we are down and can jump, but did we jump
    	   if [[ $key -eq 1 ]]; then # yes of course they are jumping, typical, ok
    	   	buggy_height=1 # up and away...weeee
    	   	jump_off=1    # shut off jump, no hold the jump key
           	jump_delay=1  # no short jump, we try 1 frame delay, jump_delay=1
    	   fi
    fi
          
    case $key in
        4) ((buggy_pos--)) ;;
        3) ((buggy_pos++)) ;;
    esac
  
    # echo "$buggy_pos" debugging
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
    if [[ $buggy_pos -eq $obstacle_pos && $buggy_height -eq 0 ]]; then
        Detination
        our_exit
    fi
    # stop cheating no going through boulders, only one case, right key with bolder in front and down
    next_pos=$(( obstacle_pos-1 ))
    #echo "$next_pos  $buggy_pos   $buggy_height   $key"
    if [[ $buggy_pos -eq $next_pos && $buggy_height -eq 0 && $key -eq 3 ]]; then
        #echo "$next_pos  $buggy_pos   $buggy_height   $key"; exit # debug
        Detination
        our_exit #collision
    fi
}

Detination(){
# lets start small, $buggy_pos plus rand chars, use draw_screen?
 buggy_image=" >&^$%"
 draw_screen
 sleep .3
 buggy_image=" ->.$&^^&*^"
 draw_screen
 sleep .3
 buggy_image=" .:<=!%$&@%*&^(&%"
 draw_screen
 sleep .3
 buggy_image=" .,.:@ $ $%(=@$%&*^%^$%^@%&$%&*^&*" #what a mess, i'm not cleaning that up
 draw_screen
 our_exit
}


cmd="move_obstacle" #fun test of function call of evaluated string variable cmd

 
# Main game loop
while true ; do
    draw_screen
    read_keys
    check_collision
    move_buggy
    ${cmd}  #fun test of function call of evaluated string variable cmd 100% working
    # sleep 0.1 # delay is in read key if more delay needed add it in read
done



