#!/bin/bash --noprofile

#extra strict flags
set -euo pipefail

#screen buffer
declare -a level

#globals
declare -i lv_w=0 #width of level
declare -i lv_h=0 #height of level
declare -i status_line=0
nextTile=''

#constants, added after the fact to improve tweaking the numbers
kFPSdelay='0.03'  #DEFAULT: 0.03, 33 FPS - good setting
kBarrierBlock='#' #DEFAULT: '#' - the block you can stand on
kEmptyBlock=' '   #DEFAULT: ' ' - air
kCoinBlock='$'    #DEFAULT: '$' - it's not a platformer unless you can increment a variable
kSpikeBlock='^'   #DEFAULT: '^' - instant death when touching this
kWinBlock='%'     #DEFAULT: '%' - instant win when touching this
kUpVelocity=-25   #DEFAULT: -25 - could be too high
kLeftVelocity=-5  #DEFAULT: -5
kRightVelocity=5  #DEFAULT: 5
kGravityFPSMod=5  #DEFAULT: 5 - provides a delay when falling
kVelocityMod=5    #DEFAULT: 5


#Art is hard
 you_won='###############################################################\n'
you_won+='##  __ __  ______  __  __    __  __  __  ______  ______  __  ##\n'
you_won+='##  || ||  |====|  ||  ||    ||  ||  ||  |====|  |====|  ||  ##\n'
you_won+='##  |===|  ||  ||  ||  ||    ||  ||  ||  ||  ||  ||  ||  ||  ##\n'
you_won+='##     ||  ||  ||  ||  ||    ||  ||  ||  ||  ||  ||  ||      ##\n'
you_won+='##  |===|  |====|  |====|    |===||===|  |====|  ||  ||  []  ##\n'
you_won+='##                                                           ##\n'
you_won+='###############################################################\n'

#less ambitious art this time
game_over='You fell into the pit, landed on a spike, and became less of an adventurer.\n'
game_over+='Game Over'

#move the cursor to a specific row and colunm
function put_cursor() {
	echo -en "\e[${1};${2}f"
}

function init_screen() {
	local height
	#get the size of the terminal
	put_cursor 999 999
	echo -en '\e[6n'
	read -s -r -d'['
	read -s -r -d';' height
	read -s -r -d'R' lv_w
	
	lv_h=$((height-1))
	status_line=height
}

#usage: mvprintw $row $col $string
function mvprintw() {
	local row=$(($1+1)) #rows count at 1 in escape sequences, I guess
	local col=$2
	printf "%s%s%s" $'\x1b[' "${row};${col}f" "$3"
}

#usage: draw_row $row_number
function draw_row() {
	mvprintw "$1" 0 "${level[$1]}"
}

#use really fancy procedural generation
function gen_level() {
	local rowstr=''
	local foo=0
	
	for (( y=0; y<lv_h; ++y ))
	do
		for (( x=0; x<lv_w; ++x ))
		do
			foo=$((RANDOM % 4))
			case "$foo" in
				( 0 ) rowstr+="$kBarrierBlock" ;;
				( 1 ) rowstr+="$kEmptyBlock" ;;
				( 2 ) rowstr+="$kEmptyBlock" ;;
				( 3 ) rowstr+="$kCoinBlock" ;;
			esac
		done
		
		level[$y]="$rowstr"
		rowstr=''
	done
}

#usage: twidle $row $col $replace_char
function twidle() {
	local row="$1"
	local col="$2"
	local chr="$3"
	local lvrest="${level[$row]:$col}"
	local lvfirst=''
	col=$((col-1))
	(( col > 0 )) && lvfirst="${level[$row]:0:$col}"
	level[$row]="${lvfirst}${chr}${lvrest}" 
}

#usage: draw_player $row $col
function draw_player() {
	#Display Attribtes         #Foreground Colours   #Background Colours
	#0	Reset all attributes   #30	Black            #40	Black
	#1	Bright                 #31	Red              #41	Red
	#2	Dim                    #32	Green            #42	Green
	#4	Underscore	           #33	Yellow           #43	Yellow
	#5	Blink                  #34	Blue             #44	Blue
	#7	Reverse                #35	Magenta          #45	Magenta
	#8	Hidden                 #36	Cyan             #46	Cyan
    #                          #37	White            #47	White
	mvprintw "$1" "$2" $'\x1b[32m@\x1b[0m'
}

function draw_level() {
	for (( x=0; x<lv_h; ++x ))
	do draw_row "$x"
	done
}

#usage: checktile $row $col
function checktile() {
	local row=$1
	local col=$(($2-1))
	
	if (( row < 0 )) || (( col < 0 ))
	then 
		nextTile="$kBarrierBlock"
		return
	elif (( row == lv_h ))
	then
		nextTile="$kSpikeBlock"
		return
	elif (( col == lv_w ))
	then
		nextTile="$kWinBlock"
		return
	else
		nextTile="${level[$row]:$col:1}"
		return
	fi
	
	return
}

function main() {
	local px=1 #player X coordinate
	local py=0 #player Y coordinate
	local pxv=0 #player X velocity
	local pyv=0 #player Y velocity
	local pog=0 #player is on ground
	local npx=0 #new player X, needs to be checked
	local npy=0 #new player Y, needs to be checked
	local score=0 #player score
	local fps_mod=0 #to delay animations
	
	#disable line wrap, clear screen, disable text cursor
	echo -en '\e[7l\e[2J\e[?25l'
	
	init_screen
	
	gen_level
	
	#make spawnpoint safe
	twidle 0 0 ' '
	twidle 0 1 ' '
	twidle 0 2 ' '
	twidle 0 3 ' '
	twidle 0 4 ' '
	twidle 1 0 ' '
	twidle 1 1 ' '
	twidle 1 2 ' '
	twidle 1 3 ' '
	twidle 1 4 ' '
	
	draw_level
	
	#main loop
	while true
	do
		#read input
		if read -r -s -N1 -t "$kFPSdelay" #framerate control
		then case "$REPLY" in
			( $'\x1b' )
				if read -r -s -N1 -t '0.1'
				then case "$REPLY" in
					( '[' )
						if read -r -s -N1 -t '0.1'
						then case "$REPLY" in
							( 'A' )	(( pog == 1 )) && pyv=$kUpVelocity ;; #up
							( 'B' ) ;; #down, no use yet
							( 'C' ) pxv=$kRightVelocity ;; #right
							( 'D' ) pxv=$kLeftVelocity ;; #left
							esac
						fi
						;;
					esac
				fi
				;;
			esac
		fi
		
		##advance animation	
		checktile $((py+1)) $px
		[[ "$nextTile" == "$kBarrierBlock" ]] && pog=1 || pog=0
		
		(( pog == 0 )) && (( (++fps_mod) == kGravityFPSMod )) && pyv=$((pyv+1)) && fps_mod=0
		
		if (( pxv > 0 ))
		then 
			pxv=$((pxv-1))
			if (( (pxv % kVelocityMod) == 0 ))
			then npx=$((px+1))
			fi
		fi
			
		if (( pxv < 0 ))
		then
			pxv=$((pxv+1))
			if (( (pxv % kVelocityMod) == 0 ))
			then npx=$((px-1))
			fi
		fi

		if (( pyv > 0 ))
		then 
			pyv=$((pyv-1))
			if (( (pyv % kVelocityMod) == 0 ))
			then npy=$((py+1))
			fi
		fi
		
		if (( pyv < 0 ))
		then
			pyv=$((pyv+1))
			if (( (pyv % kVelocityMod) == 0 ))
			then npy=$((py-1))
			fi
		fi
		
		#tile based collision detection
		checktile $npy $npx
		case "$nextTile" in
			( "$kBarrierBlock" )
				npx=$px
				npy=$py
				;;
			( "$kCoinBlock" )
				twidle $npy $npx ' '
				score=$((score+1))
				;;
			( "$kSpikeBlock" ) #lose
				mvprintw 0 0 $'\x1b[2J'
				echo -e "$game_over"
				echo "Final Score: $score"
				break
				;;
			( "$kWinBlock" ) #win
				mvprintw 0 0 $'\x1b[2J'
				echo -e "$you_won"
				echo "Final Score: $score"
				break
				;;
		esac
		
		#render player
		if (( npx != px )) || (( npy != py ))
		then
			mvprintw $py $px ' '
			draw_player $npy $npx
			px=$npx
			py=$npy
		fi
		
		#status line
		mvprintw "$status_line" 0 $'\x1b[2K'
		mvprintw "$status_line" 0 "px: $px  py: $py  pog: $pog  score: $score  pxv: $pxv  pyv: $pyv"
	done
}

main "$@"
