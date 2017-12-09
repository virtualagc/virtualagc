#!/bin/bash
# Runs yaAGC and piDSKY2.py on a Raspberry Pi.
# Assumes that the github repo for virtualagc has been cloned,
# and the software has been built from source,
# and that we are in the piPeripheral subdirectory of that clone.

# Turn off keyboard repeat, but make sure it gets restored on exit.
function cleanup {
	echo -e "\nRestoring keyboard repeat ..."
	xset r on
}
trap cleanup EXIT

cd ..
SOURCEDIR="`pwd`"
cd -

# Parse the command-line arguments.
LEDPATH="$SOURCEDIR/piPeripheral/led-panel"
for i in "$@"
do
	case $i in
		--debug)
			DEBUG=yes
			;;
		--agc-debug)
			AGCDEBUG=yes
			;;
		--window*)
			WINDOW="--window=1"
			;;
		--yaDSKY2|--yadsky2)
			YADSKY=yes
			;;
		--image-dir=*)
			IMGDIR="`echo $i | sed 's/[^=]*=//'`"
			;;
		--led-panel=*)
			LEDPATH="`echo $i | sed 's/[^=]*=//'`"
			;;
		--slow)
			SLOW="--slow=1"
			;;
		--monitor)
			MONITOR=yes
			;;
		--non-native)
			NON_NATIVE=yes
			;;
		--pigpio=*)
			PIGPIO="$i"
			;;
		--piDSKY)
			PIDSKY=yes
			;;
		--custom-bare)
			CUSTOM_BARE=yes
			;;
		--record)
			RECORD="--record=1"
			;;
		--playback)
			PLAYBACK_OPTION=yes
			;;
		*)
			echo "Usage:"
			echo "  cd piPeripheral"
			echo "  ./runPiDSKY2.sh [OPTIONS]"
			echo "The allowed options are:"
			echo "	--window                Display DSKY registers as a 272x480 window"
			echo "                          rather than full screen."
			echo "	--yaDSKY2               Run yaDSKY2 in addition to (in parallel with)"
			echo "                          the DSKY-register display.  Most useful if"
			echo "                          --window is also used."
			echo "	--image-dir=PATH        Specify directory for alternate widget graphics."
			echo "                          The default is simply the piDSKY2-images"
			echo "                          subdirectory of the current directory."
			echo "	--led-panel=PATH        Specify a path to the 'led-panel' program."
			echo "                          Defaults to simply 'led-panel' (in the current"
			echo "                          directory)."
			echo "  --debug                 Display extra messages useful in debugging piDSKY2."
			echo "  --agc-debug             Display extra messages useful in debugging yaAGC."
			echo "  --monitor               Monitor load, temperature, CPU clock."
			echo "  --non-native            Running on a non-Pi computer."  
			echo "  --pigpio=N              Use pigpio interface to control lamps.  Otherwise,"
			echo "                          Shell out to 'led-panel' to control lamps.  Not"
			echo "                          useful with --non-native, since pigpio is a native"
			echo "                          Pi library.  The value of the parameter, N, is"
			echo "                          a brightness intensity, varying from 0 (the least)"
			echo "                          to 15 (the maximum)." 
			echo "  --piDSKY                Run piDSKY.py rather than piDSKY2.py."
			echo "  --custom-bare           Allows an extra mission menu item, V, for running"
			echo "                          a custom bare-metal AGC program, piPeripheral.agc." 
			echo "  --record                Record incoming output-channel changes to a file."
			echo "  --playback              Add playback option to mission menu."
			exit
			;;
	esac
	shift
done
if [[ "$PIDSKY" == "" ]]
then
	# For use with automateV35.py.
	sudo modprobe uinput
fi
if [[ "$NON_NATIVE" == "" && "$PIGPIO" != "" ]]
then
	# Start pigpiod.  Note that if pigpiod is already started, this
	# won't start a second instance, but will merely show
	# an error message (which we discard).
	sudo pigpiod &>/dev/null
fi

killall yaAGC &>/dev/null
killall yaDSKY2 &>/dev/null
killall piDSKY2.py &>/dev/null

# First, prepare to use the RAM disk.
RAMDISK=/run/user/$UID
if [[ ! -d $RAMDISK ]]
then
	echo "RAM disk $RAMDISK does not exist ... using $HOME"
	RAMDISK=$HOME
fi
RAMDISK=$RAMDISK/piDSKY2
rm $RAMDISK -rf &>/dev/null
mkdir $RAMDISK &>/dev/null
cd $RAMDISK
if [[ "$IMGDIR" != "" ]]
then
	cp -a "$IMGDIR" $RAMDISK/piDSKY2-images
else
	cp -a "$SOURCEDIR/piPeripheral/piDSKY2-images" $RAMDISK
fi
cp -a "$SOURCEDIR/yaDSKY2"/*.{png,jpg} $RAMDISK
cp -a "$LEDPATH" $RAMDISK/led-panel


while true
do
	# Choose a mission.
	xset r off
	clear
	echo "Available missions:"
	echo ""
	echo "    0 - Apollo 5 LM"
	echo "    1 - Apollo 8 CM"
	echo "    2 - Apollo 9 CM"
	echo "    3 - Apollo 10 LM"
	echo "    4 - Apollo 11 CM"
	echo "    5 - Apollo 11 LM (default)"
	echo "    6 - Apollo 12 LM"
	echo "    7 - Apollo 13 LM"
	echo "    8 - Apollo 15-17 CM"
	echo "    9 - Apollo 15-17 LM"
	unset PLAYBACK
	if [[ "$PLAYBACK_OPTION" != "" ]]
	then
		echo " PROG - Play back" 
	fi
	if [[ "$CUSTOM_BARE" != "" ]]
	then
		echo " VERB - Custom program #1"
	fi
	echo ""
	read -p "Choose a number: " -t 15 -n 1
	if [[ "$REPLY" == "0" ]]
	then
		CORE=Sunburst120
		CFG=LM0
	elif [[ "$REPLY" == "1" ]]
	then
		CORE=Colossus237
		CFG=CM
	elif [[ "$REPLY" == "2" ]]
	then
		CORE=Colossus249
		CFG=CM
	elif [[ "$REPLY" == "3" ]]
	then
		CORE=Luminary069
		CFG=CM
	elif [[ "$REPLY" == "4" ]]
	then
		CORE=Comanche055
		CFG=CM
	elif [[ "$REPLY" == "6" ]]
	then
		CORE=Luminary116
		CFG=LM
	elif [[ "$REPLY" == "7" ]]
	then
		CORE=Luminary131
		CFG=LM
	elif [[ "$REPLY" == "8" ]]
	then
		CORE=Artemis072
		CFG=CM
	elif [[ "$REPLY" == "9" ]]
	then
		CORE=Luminary210
		CFG=LM1
	elif [[ "$CUSTOM_BARE" != "" && ( "$REPLY" == "V" || "$REPLY" == "v" ) ]]
	then
		cd "$SOURCEDIR/piPeripheral"
		../yaYUL/yaYUL piPeripheral.agc &>/dev/null
		cd "$RAMDISK"
		CORE=piPeripheral.agc
		DIR=piPeripheral
		CFG=LM
	elif [[ "$PLAYBACK_OPTION" != "" && ( "$REPLY" == "P" || "$REPLY" == "p" ) ]]
	then
		PLAYBACK="--playback=$HOME/Desktop/piDSKY2-recorded.txt"
	elif [[ "$REPLY" == "R" || "$REPLY" == "r" ]]
	then
		echo ""
		read -s -p "Password: " -t 30
		if [[ "$REPLY" == "19697R" || "$REPLY" == "19697r" ]]
		then
			clear
			echo "Maintenance menu:"
			echo "1 - Reboot"
			echo "2 - Shutdown"
			echo "3 - Command line"
			echo "4 - Desktop"
			echo "5 - Missions (default)"
			read -p "Choose a number: " -t 15 -n 1
			echo ""
			if [[ "$REPLY" == "1" ]]
			then
				echo "1 - Confirm reboot"
				echo "2 - Don't reboot"
				read -p "? " -n 1
				echo ""
				if [[ "$REPLY" == "1" ]]
				then
					sudo reboot
				else
					continue
				fi
			elif [[ "$REPLY" == "2" ]]
			then
				echo "1 - Confirm shutdown"
				echo "2 - Don't shut down"
				read -p "? " -n 1
				echo ""
				if [[ "$REPLY" == "1" ]]
				then
					sudo poweroff
				else
					continue
				fi
			elif [[ "$REPLY" == "3" ]]
			then
				echo "1 - Confirm exit to console"
				echo "2 - Don't exit"
				read -p "? " -n 1
				echo ""
				if [[ "$REPLY" == "1" ]]
				then
					exit
				else
					continue
				fi
			elif [[ "$REPLY" == "4" ]]
			then
				echo "1 - Confirm exit to desktop"
				echo "2 - Don't exit"
				read -p "? " -n 1
				echo ""
				if [[ "$REPLY" == "1" ]]
				then
					sudo killall xterm
					exit
				else
					continue
				fi
			else
				continue
			fi
		else
			echo ""
			echo "Permission denied."
			sleep 2
			continue
		fi
	else # $REPLY == 5
		CORE=Luminary099
		CFG=LM
	fi
	if [[ "$DIR" == "" ]]
	then
		DIR=$CORE
	fi
	echo ""
	
	optionsPiDSKY2="--port=19697 $WINDOW $SLOW $PIGPIO"
	if [[ "$PLAYBACK" == "" ]]
	then
		optionsPiDSKY2="$optionsPiDSKY2 $RECORD"
	
		echo "Starting AGC program $CORE ..."
		# Run it!
		rm LM.core CM.core &>/dev/null
		if [[ "$AGCDEBUG" == "" ]]
		then
			"$SOURCEDIR/yaAGC/yaAGC" --core="$SOURCEDIR/$DIR/$CORE.bin" --port=19697 --cfg="$SOURCEDIR/yaDSKY/src/$CFG.ini" >/dev/null &
		else
			"$SOURCEDIR/yaAGC/yaAGC" --core="$SOURCEDIR/$DIR/$CORE.bin" --port=19697 --cfg="$SOURCEDIR/yaDSKY/src/$CFG.ini" &
		fi
		YAGC_PID=$!
		if [[ "$YADSKY" != "" ]]
		then
			"$SOURCEDIR/yaDSKY2/yaDSKY2" --cfg="$SOURCEDIR/yaDSKY/src/$CFG.ini" --port=19698 &>/dev/null &
			YADSKY2_PID=$!
		fi
		clear
		if [[ "$DEBUG" == "" && "$PIDSKY" == "" ]]
		then
			"$SOURCEDIR/piPeripheral/piSplash.py" $WINDOW &>/dev/null
		fi
		if [[ "$MONITOR" != "" && "$PIDSKY" == "" ]]
		then
			xterm -e "$SOURCEDIR/piPeripheral/backgroundStatus.sh" &
			STATUS_PID=$!
		fi
		if [[ "$CUSTOM_BARE" != "" ]]
		then
			xterm -hold -e "$SOURCEDIR/piPeripheral/piPeripheral.py --port=19699 --time=1" &
			STATUS_BARE=$!
		fi
	
		if [[ "$PIDSKY" != "" ]]
		then
			"$SOURCEDIR/piPeripheral/piDSKY.py" --port=19697
			if [[ "$DEBUG" != "" ]]
			then
				read -p "Hit Enter to continue ..."
			fi
		fi
	else
		optionsPiDSKY2="$optionsPiDSKY2 $PLAYBACK"
	fi
	
	if [[ "$PIDSKY" == "" ]]
	then
		if [[ "$DEBUG" == "" ]]
		then
			"$SOURCEDIR/piPeripheral/piDSKY2.py" $optionsPiDSKY2 >/dev/null
		else
			"$SOURCEDIR/piPeripheral/piDSKY2.py" $optionsPiDSKY2
			read -p "Hit Enter to continue ..."
		fi
	fi
	
	echo "Cleaning up ..."
	kill $YAGC_PID $YADSKY2_PID $STATUS_PID $STATUS_BARE
	wait $YAGC_PID $YADSKY2_PID $STATUS_PID $STATUS_BARE &>/dev/null
done
