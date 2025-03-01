#!/bin/bash

# Moon Buggy Game in Bash

# Initialize variables
jump_off=0    # turn on jump
jump_delay=0   # reset delay
# buggy_image="^"
key=0
buggy_pos=20
buggy_height=13 # ground is 15, 14 is down and car is 2 high
old_buggy_pos=$buggy_pos #for destructor
old_buggy_height=$buggy_height #for destructor
old_obstacle_pos=80 #for destructor
obstacle_pos=80
score=0
game_over=0

echo -e "\033[?25l" #turn off cursor 
stty -echo #turn off echo key presses
clear

xyprint() { # x,y,"string"
echo -e "\033[40m" # back ground color 40 black
echo -e '\033[37m' # fore ground color 37 white	
echo -ne "\033[${2};${1}H${3}"
}

put_car() { #needs x,y,color values
# testing solid
#echo -e ${1} " " ${2}
echo -e "\033[4${3}m" # back ground color 41 red
echo -e '\033[30m' # fore ground color 30 black
echo -e "\033[${2};${1}H   " # print chars " " at x,y top 3 chars
echo -e "\033[$(( ${2} + 1 ));$(( ${1} - 1 ))H  " # print chars at x,y trunk
echo -e '\033[30m' # fore ground color 30 black tires
echo -e "\033[$(( ${2} + 1 ));$(( ${1} + 0 ))HO  o "  # print chars at x,y door
}
 
put_bullet(){
echo -e '\033[45m' # back ground color 45 purple
echo -e '\033[35m' # fore ground color 35 purple
echo -e "\033[${2};${1}Hx" # print 1 block at x,y 
}
 
put_rock(){
echo -e "\033[4${3}m" # back ground color 43 yellow
 # echo -e '\033[33m' # fore ground color 33 yellow, they have pee on them, yes yellow
echo -e "\033[${2};${1}H " # print 1 block at x,y 
}

put_hole(){
echo -e '\033[40m' # back ground color 40 black
echo -e '\033[30m' # fore ground color 30 black
echo -e "\033[${2};${1}Ho" # print 1 block at x,y 
}

put_ground(){ # needs nothing, static for now, like I don't know ... like the ground!!
echo -e '\033[43m' # back ground color 43 yellow
echo -e '\033[33m' # fore ground color 33 yellow
echo -e "\033[15;0Hxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}
# put_rock 80 14
# put_car 7 13
# put_bullet 20 14
# put_ground  #testing only
# put_hole 79 15
# 
# Function to draw the game screen
draw_screen() {
    # read -t 0.01 #clear key buffer
    # sleep .5 # slow down for testing
    # read -t 0.01 #clear key buffer
    # echo -e "$(tput lines)\n"  #gets screen size to use later or not
    # echo -e "$(tput cols)\n"
    xyprint 5 5 "Score: $score"
    xyprint 5 6 "Use arrows to move, q to quit"
    # echo
    # no need for loops, just put it x and y
    
    put_rock $old_obstacle_pos 14 0 # remove old rock 0 black
    put_rock $obstacle_pos 14 3
    old_obstacle_pos=$obstacle_pos 
    
    put_car $old_buggy_pos $old_buggy_height 0 # remove old car
    put_car $buggy_pos $buggy_height 1
    old_buggy_pos=$buggy_pos 
    old_buggy_height=$buggy_height
    

    ##### old #### need to draw buggy, rock and spaces in one loop otherwise it would erase others
    ###### old #### first loop for top level
    ##### old ####for ((i=0; i<=20; i++)); do 
     ##### old ####   if [[ $i -eq $buggy_pos && buggy_height -eq 1 ]]; then
      ##### old ####      echo -n "^"
      ##### old ####  else
      ##### old ####      echo -n " "
      ##### old ####  fi
    ##### old ####   done
    ##### old #### echo -e "\r" # start new line
    ###### old #### loop for main level
    ##### old #### for ((i=0; i<=20; i++)); do
       ##### old #### if [[ $i -eq $buggy_pos && buggy_height -eq 0 ]]; then
       ##### old ####     echo -n "$buggy_image"
       ##### old #### elif [[ $i -eq $obstacle_pos ]]; then
       ##### old ####     echo -n "O"
      ##### old #### else
       ##### old ####     echo -n " "
      ##### old ####  fi
    ##### old #### done
    put_ground # new call for color, old down in note
    ###### old ####  echo -e "\n______________________________" # print the floor...NICE TILE!!!
   # sleep 20 #testing only
   # reset     #testing only
   # exit      #testing only
    # read -t 0.01 #clear key buffer
}
read_keys(){
 key=0 # reset key for no repeat
 # Read the first character (escape sequence starts with \x1b)
        read -rsn1 -t 0.05 input #read -r -s -N1 -t '0.1'

        # Check if the input is the escape character (\x1b)
        if [[ "$input" == $'\x1b' ]]; then
            # Read the next two characters
            read -rsn2 -t 0.1 input2  # -t 0.2 sets a timeout to avoid blocking
            input+="$input2" # input is now 3 chars in lenght
            # Determine the arrow key
            case "$input" in
                $'\x1b[A')  key=1 ;; # Up arrow j for jump
                $'\x1b[B')  key=2 ;; # Down arrow
                $'\x1b[C')  key=3 ;; # Right arrow
                $'\x1b[D')  key=4 ;; # Left arrow
                
            esac
       else 
            # Handle other keys (e.g., 'q' to quit)
           case "$input" in  # left as case for future expansion, input is only one char
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
 # reset colors
 echo -e "\033[40m" # back ground color 40 black
 clear
 echo -e '\033[37m' # fore ground color 37 white
 echo -e "Game Over! \r"
 echo -e  "Exiting...Final score is: $score \r"
 echo -e '\033[32m' # fore ground color 32 green
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
           buggy_height=13 # down to earth, gravity sucks
    elif [[ jump_delay -eq 1 ]]; then 
  # we are up for first frame
           # should be off already jump_off=1    # shut off jump, no hold the jump key
           jump_delay=2  # no short jump, we try 1 frame delay, jump_delay=2
    elif [[ jump_off -eq 0 && jump_delay -eq 0 ]]; then 
   # we are down and can jump, but did we jump
    	   if [[ $key -eq 1 ]]; then # yes of course they are jumping, typical, ok
    	   	buggy_height=12 # up and away...weeee
    	   	jump_off=1    # shut off jump, no hold the jump key
           	jump_delay=1  # no short jump, we try 1 frame delay, jump_delay=1
    	   fi
    fi
          
    case $key in
        4) (( buggy_pos-- )) ;;
        3) (( buggy_pos++ )) ;;
    esac
  
    # echo "$buggy_pos" debugging
    # Ensure buggy stays within bounds
    if [[ $buggy_pos -lt 4 ]]; then # car is bigger now, 4 to keep on screen
        buggy_pos=4
    elif [[ $buggy_pos -ge 80 ]]; then
        buggy_pos=80
    fi
}

# Function to move the obstacle
move_obstacle() {
    ((obstacle_pos--))
    if [[ $obstacle_pos -lt 0 ]]; then
        obstacle_pos=80
        ((score++))
    fi
}

# Function to check for collision
check_collision() {
    if [[ $(( $buggy_pos + 3 )) -eq $obstacle_pos && $buggy_height -eq 13 ]]; then
       # Detination
        our_exit
    fi
    # stop cheating no going through boulders, only one case, right key with bolder in front and down
    next_pos=$(( obstacle_pos - 1 ))
    # xyprint 5 7  "$next_pos  $buggy_pos   $buggy_height   $key"
    if [[ $(( $buggy_pos + 3 )) -eq $next_pos && $buggy_height -eq 13 && $key -eq 3 ]]; then
        #echo "$next_pos  $buggy_pos   $buggy_height   $key"; exit # debug
        # Detination  #collision
        our_exit 
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


# cmd="move_obstacle" #fun test of function call of evaluated string variable cmd

 
# Main game loop
while true ; do
    draw_screen
    read_keys
    check_collision
    move_buggy
    move_obstacle  
    # sleep 0.1 # delay is in read key if more delay needed add it in read
done



