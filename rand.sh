#!/bin/bash 

laps=200000 #num of times around
read -p "Pick a number between 0 and 32767: " pickedNum    #get a guess from user
#need to check for valid number no neg no alpha
myNum=$RANDOM
#lets do many games at once by looping a lot
for ((i=1; i <= $laps ; i++)) do

 echo "$i The number was: $myNum"
  #check if win  
  if [[ $myNum -eq $pickedNum ]]; then
	echo "You win"
	read -p "new number:" pickedNum #allow user to change their number.
  else
	echo "You lose"
  fi
 #we pick new number
 myNum=$RANDOM
 total=$(($total + $myNum)) #get sum to check averages at end

done

echo " The total was: $total"
echo " the mean average was: $(($total / $laps))" 
echo " times 2: $(($(($total / $laps)) * 2)) " #see how close it is to 32767
