#!/bin/bash --noprofile
#extra strict flags
set -euo  pipefail

# Moon Buggy Game in Bash by Scott McGilligan

init(){
original_stty=$(stty -g) # save terminal state to restore in ending, somehow gets right type
trap our_exit SIGTERM  # catch errors and exit
trap our_exit ERR  
trap ' ' SIGINT # ignore, it sucks but works exiting causes no echo dispite many stty calls
trap ' ' SIGTSTP # ignore, resets and clears all fail
# Set terminal to raw mode
stty raw -echo  #turn off echo key presses
printf '\033c' #clear screen
echo -en "\033[?25l" #turn off cursor 
# Initialize variables
jump_off=0    # turn on jump
jump_delay=0   # reset delay
key=0 # key read user input var
input=""
input2=""
buggy_pos=20 # start x position of car
buggy_height=13 # ground is 15, 14 is down and car is 2 high
obstacle_pos=80 # rock start x pos
old_buggy_pos=$buggy_pos #for destructor
old_buggy_height=$buggy_height #for destructor
old_obstacle_pos=$obstacle_pos #for destructor
score=0
scorestring=" "
}

xyprint() { # x,y,"string"
echo -e "\033[40m" # back ground color 40 black
echo -e '\033[37m' # fore ground color 37 white	
echo -ne "\033[${2};${1}H${3}"
}

put_car() { #needs x,y,color values
echo -e "\033[4${3}m" # back ground color 41 red
echo -e '\033[30m' # fore ground color 30 black
echo -e "\033[${2};${1}H   " # print chars " " at x,y top 3 chars
echo -e "\033[$(( ${2} + 1 ));$(( ${1} - 1 ))H  " # print chars at x,y trunk
echo -e '\033[30m' # fore ground color 30 black tires
echo -e "\033[$(( ${2} + 1 ));$(( ${1} + 0 ))HO  o "  # print chars at x,y door
}
 
put_bullet(){ # future addition
echo -e '\033[45m' # back ground color 45 purple
echo -e '\033[35m' # fore ground color 35 purple
echo -e "\033[${2};${1}Hx" # print 1 block at x,y 
}
 
put_rock(){
echo -e "\033[4${3}m" # back ground color 43 yellow
echo -e "\033[${2};${1}H " # print 1 block at x,y 
}

put_hole(){
echo -e '\033[40m' # back ground color 40 black
echo -e '\033[30m' # fore ground color 30 black
echo -e "\033[${2};${1}Ho" # print 1 block at x,y 
}

put_ground(){ # needs nothing, static for now, like I don't know ... like the ground!!
echo -e '\033[43m' # back ground color 43 yellow
#echo -e '\033[33m' # fore ground color 33 yellow
echo -e "\033[15;0H                                                                                           "
}

# Function to draw the game screen
draw_screen() {
    xyprint 5 5 "Score: $score"  # function call x,y,string
    xyprint 5 6 "Use arrows to move, q to quit"
    # no need for loops, just put it x and y
    # put rock first to not destroy our car on redraw, ugly but works
    # remove old rock 0 black
    put_rock $old_obstacle_pos 14 0
    put_rock $obstacle_pos 14 3
    old_obstacle_pos=$obstacle_pos 
    
    put_car $old_buggy_pos $old_buggy_height 0 # remove old car 0 black
    put_car $buggy_pos $buggy_height 1 # 1 is red, fact: red cars are faster than non red cars
    old_buggy_pos=$buggy_pos 
    old_buggy_height=$buggy_height
    
    put_ground # new call for color
    ###### old ####  echo -e "\n______________________________" # print the floor...NICE TILE!!!
}

read_keys(){  
 key=0 # reset key for no repeat
 # Read the first character (escape sequence starts with \x1b)
       if read -r -s -N1 -t '0.1' input #read -r -s -N1 -t '0.1'
       then
             # Check if the input is the escape character (\x1b)
            if [[ "$input" == $'\x1b' ]]; then
                    # Read the next two characters
                    if read -r -s -N2 -t '0.1' input2  # -t 0.2 sets a timeout to avoid blocking
                    then
                      input+="$input2" # input is now 3 chars in lenght
                       # Determine the arrow key
                       case "$input" in
                           #$'\x1b') our_exit;; #esc key hit solo
                           $'\x1b[B')  key=2 ;; # Down arrow
                           $'\x1b[C')  key=3 ;; # Right arrow
                           $'\x1b[D')  key=4 ;; # Left arrow 
                           $'\x1b[A')  key=1 ;; # Up arrow j for jump
                       esac
                    else 
                       our_exit #esc key hit solo
                    fi   
            else 
                      # Handle other keys (e.g., 'q' to quit)
                      case "$input" in  # left as case for future expansion, input is only one char
                        q) our_exit ;;
                        *) key=5 ;; # echo -e  "You pressed: $input\r" ;;
                      esac
            fi
        fi     
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
 
    # Ensure buggy stays within bounds
    if [[ $buggy_pos -lt 2 ]]; then # car is bigger now, 3 to keep on screen
        buggy_pos=2
    elif [[ $buggy_pos -ge 75 ]]; then
        buggy_pos=75
    fi
}

# Function to move the obstacle
move_obstacle() {
    ((obstacle_pos--))
    if [[ $obstacle_pos -eq 1 ]]; then
        obstacle_pos=$((80 - RANDOM % 3)) # rand removes bouncing repeat wins by holding key up, down
        ((score=$score+1))
    fi
}

# Function to check for collision
check_collision() {
    if [[ $(( $buggy_pos + 3 )) -eq $obstacle_pos && $buggy_height -eq 13 ]]; then
        Detination
        our_exit
    fi
    # stop cheating no going through boulders, only one case, right key with bolder in front and down
   next_pos=$(( obstacle_pos - 1 ))
    
    if [[ $(( $buggy_pos + 3 )) -eq $next_pos && $buggy_height -eq 13 && $key -eq 3 ]]; then
        Detination  #collision
    fi
}

Detination(){
# lets start small, $buggy_pos plus rand chars, use draw_screen?
#what a mess, I'm not cleaning this up, the code not the crash, just exit
put_car $old_buggy_pos $old_buggy_height 0 # remove old car
echo -e "\033[41m" # back ground color 41 red
echo -e '\033[30m' # fore ground color 30 black
echo -e "\033[14;$(( ${buggy_pos} + 3 ))H#o&0*" # print chars " " at x,y top crash chars
echo -e "\033[13;$(( ${buggy_pos} + 3 ))H ^" # print chars " " at x,y one up top crash chars
 sleep .3
echo -e "\033[41m" # back ground color 41 red
echo -e '\033[30m' # fore ground color 30 black
echo -e "\033[14;$(( ${buggy_pos} + 3 ))H @%o^&  *" # print chars " " at x,y top crash chars
echo -e "\033[12;$(( ${buggy_pos} + 5 ))H& " # print chars " " at x,y two up top crash chars
echo -e "\033[12;$(( ${buggy_pos} + 7))H " # print chars " " at x,y two up top crash chars
 sleep .3
echo -e "\033[41m" # back ground color 41 red
echo -e '\033[30m' # fore ground color 30 black
echo -e "\033[14;$(( ${buggy_pos} + 3 ))H @  %  ^ O &  *" # print chars " " at x,y top crash chars
echo -e "\033[12;$(( ${buggy_pos} + 5 ))H& " # print chars " " at x,y two up top crash chars
echo -e "\033[11;$(( ${buggy_pos} + 7 ))H ," # print chars " " at x,y three up top crash chars
echo -e "\033[12;$(( ${buggy_pos} + 9 ))H " # print chars " " at x,y three up top crash chars
 sleep .3
 our_exit
}

# Function for our exit
our_exit() {
 # turn on echo key presses
 stty echo 
 stty sane
 # reset colors
 echo -e "\033[40m" # back ground color 40 black
 echo -e '\033[37m' # fore ground color 37 white
 printf '\033c' #clear screen
 echo -e "Game Over! \r"
 echo -e  "Exiting...Final score is: $score \r"
 echo -ne "\033[?25h" # turn on cursor
 # Restore terminal settings
 stty $original_stty
 exit
}


init # put all terminal and game setup here
# Main game loop
while true 
do
    draw_screen
    read_keys
    check_collision
    move_buggy
    move_obstacle  
    # sleep 0.1 delay is in read key if more delay needed add it in read
done


