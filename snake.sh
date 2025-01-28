 #!/bin/bash


# Initialize variables
score=0
direction=right


# Set the initial position of the snake
snake_x=10
snake_y=10


# Set the initial position of the food
food_x=20
food_y=20


# Display the game board
function display_board {
  clear
  for ((i=0;i<30;i++)); do # height
    for ((j=0;j<30;j++)); do #think this is width
      if [[ $i -eq 0 || $i -eq 29 || $j -eq 0 || $j -eq 29 ]]; then
        echo -n "#"
      elif [[ $i -eq $snake_x && $j -eq $snake_y ]]; then
        echo -n "O"
      elif [[ $i -eq $food_x && $j -eq $food_y ]]; then
        echo -n "X"
      else
        echo -n " "
      fi
    done
    echo
  done
  echo "Score: $score"
}


# Move the snake in the specified direction
function move_snake {
  case $direction in
    right)
      snake_y=$((snake_y+1))
      ;;
    left)
      snake_y=$((snake_y-1))
      ;;
    up)
      snake_x=$((snake_x-1))
      ;;
    down)
      snake_x=$((snake_x+1))
      ;;
  esac
}


# Check if the snake has collided with the wall or itself
function check_collision {
  if [[ $snake_x -lt 1 || $snake_x -gt 28 || $snake_y -lt 1 || $snake_y -gt 28 ]]; then
    game_over
  fi
}


# Check if the snake has eaten the food
function check_food {
  if [[ $snake_x -eq $food_x && $snake_y -eq $food_y ]]; then
    score=$((score+1))
    food_x=$((RANDOM % 28 + 1))
    food_y=$((RANDOM % 28 + 1))
  fi
}


# Display the "game over" message and exit
function game_over {
  clear
  echo "Game Over!"
  echo "Your score was $score"
  echo "Happy New Year 2025!"
  read -p "try other version, hit enter"
  clear
  # Run ./snake.sh
# Arrow keys or wasd to move

c=`tput cols`;L=`tput lines`
let x=$c/2;let y=$L/2;d=0;le=3;t="$y;$x";i=0;j=0;S=0
A(){ let i=($RANDOM%$c);let j=($RANDOM%$L);};A
B(){ printf $*;};C(){ B "\x1B[$1";};D(){ C "$1H";}
F(){ D "0;0";C 2J;C "?25h";printf "GAME OVER\nSCORE: $S\n";exit;};trap F INT
C ?25l;C 2J;da(){ D "$j;$i";echo "$1";}
G() { for n in $t; do D "$n";echo "$1";done;}
mt(){ t=`echo "$t"|cut -d' ' -f2-`;}
sc(){ D "0;0";echo "Score: $S"; }
gt() { t+=" $y;$x";};ct() { for n in $t; do [ "$y;$x" == "$n" ]&&F;done;}
M() { case $d in 0)let y--;;1)let x--;;2)let y++;;3)let x++;;esac
let x%=$c;let y%=$L;ct;[ "$y$x" == "$j$i" ]&&{ let le++;A;let S++;}
l=`tr -dc ' '<<<"$t"|wc -c`;gt;[ $l -gt $le ]&&mt;}
ky() { k=$1;read -sN1 -t 0.01 k1;read -sN1 -t 0.01 k2;read -sN1 -t 0.01 k3
k+=${k1}${k2}${k3};case $k in w|$'\e[A'|$'\e0A')d=0;;a|$'\e[D'|$'\e0D')d=1;;
s|$'\e[B'|$'\e0B')d=2;;d|$'\e[C'|$'\e0C')d=3;;esac;}
while :;do da ' ';G ' ';M;da "@";G "#";sc;read -s -n 1 -t 0.1 k && ky "$k";done
  #exit
}


# Main game loop
while true; do
  display_board
  read -sn1 input
  case $input in
    w)
      direction=up
      ;;
    a)
      direction=left
      ;;
    s)
      direction=down
      ;;
    d)
      direction=right
      ;;
  esac
  move_snake
  check_collision
  check_food
  #sleep 0.1
done 
