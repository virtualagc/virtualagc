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

# Get the saved configuration, if any.
if [[ -f "$HOME/runPiDSKY2.cfg" ]]
then
	source "$HOME/runPiDSKY2.cfg"
fi
function saveConfiguration() {
	AGC_IP=$NEW_IP
	AGC_PORT=$NEW_PORT
	echo "Saving external AGC: $AGC_IP:$AGC_PORT ..."
	sudo -u $USER echo "AGC_IP=$AGC_IP" >"$HOME"/runPiDSKY2.cfg
	sudo -u $USER echo "AGC_PORT=$AGC_PORT" >>"$HOME"/runPiDSKY2.cfg
	sleep 2
}

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
if [[ "$PIDSKY" == "" && "$NON_NATIVE" == "" ]]
then
	# For use with automateV35.py.  On my desktop
	# this uinput is a built-in, so it's only useful
	# on the Pi, I think.
	sudo modprobe uinput
fi
if [[ "$NON_NATIVE" == "" && "$PIGPIO" != "" ]]
then
	# Start pigpiod.  Note that if pigpiod is already started, this
	# won't start a second instance, but will merely show
	# an error message (which we discard).
	sudo pigpiod &>/dev/null
fi

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
cp -a "$SOURCEDIR/yaDSKY2"/*.{png,jpg,canned} $RAMDISK
cp -a "$LEDPATH" $RAMDISK/led-panel


while true
do
	unset YAGC_PID YADSKY2_PID STATUS_PID STATUS_BARE PLAYBACK EXTERNAL_AGC
	
	# Choose a mission.
	xset r off
	clear
	echo "Available missions:"
	echo ""
	echo "    0   Run Apollo 5 LM"
	echo "    1   Run Apollo 8 CM"
	echo "    2   Run Apollo 9 CM"
	echo "    3   Run Apollo 10 LM"
	echo "    4   Run Apollo 11 CM"
	echo "    5   Run Apollo 11 LM (default)"
	echo "    6   Run Apollo 12 LM"
	echo "    7   Run Apollo 13 LM"
	echo "    8   Run Apollo 15-17 CM"
	echo "    9   Run Apollo 15-17 LM"
	echo "    -   Replay Apollo 11 landing"
	echo "    +   Replay other scenarios"
	if [[ "$AGC_IP" != "" && "$AGC_PORT" != "" ]]
	then
		echo "  CLR   Connect to external AGC"
	fi
	if [[ "$CUSTOM_BARE" != "" ]]
	then
		echo " VERB - Run custom AGC program"
	fi
	echo ""
	read -p "Choose an option: " -t 15 -n 1
	echo ""
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
	elif [[ "$AGC_IP" != "" && "$AGC_PORT" != "" && ( "$REPLY" == "c" || "$REPLY" == "C" ) ]]
	then
		EXTERNAL_AGC=yes
	elif [[ "$REPLY" == "-" || "$REPLY" == "_" ]]
	then
		PLAYBACK="--playback=$SOURCEDIR/yaDSKY2/Apollo11-landing.canned"
	elif [[ "$REPLY" == "+" || "$REPLY" == "=" ]]
	then
		clear
		echo "Pre-recorded scenarios:"
		echo ""
		echo "    0   Replay Apollo 8 Launch"
		echo "    1   Replay Apollo 11 Launch"
		echo "    2   Replay Apollo 11 Landing"
		if [[ "$PLAYBACK_OPTION" != "" ]]
		then
			echo "  CLR   Replay custom recording"
		fi
		echo " ENTR   Return to mission menu"
		echo ""
		read -p "Choose an option: " -n 1
		echo ""
		if [[ "$REPLY" == "0" ]]
		then
			PLAYBACK="--playback=$SOURCEDIR/yaDSKY2/Apollo8-launch.canned"
		elif [[ "$REPLY" == "1" ]]
		then
			PLAYBACK="--playback=$SOURCEDIR/yaDSKY2/Apollo11-launch.canned"
		elif [[ "$REPLY" == "2" ]]
		then
			PLAYBACK="--playback=$SOURCEDIR/yaDSKY2/Apollo11-landing.canned"
		elif [[ "$PLAYBACK_OPTION" != "" && ( "$REPLY" == "c" || "$REPLY" == "C" ) ]]
		then
			PLAYBACK="--playback=$HOME/Desktop/piDSKY2-recorded.canned"
		else
			continue
		fi
	elif [[ "$CUSTOM_BARE" != "" && ( "$REPLY" == "V" || "$REPLY" == "v" ) ]]
	then
		cd "$SOURCEDIR/piPeripheral"
		../yaYUL/yaYUL piPeripheral.agc &>/dev/null
		cd "$RAMDISK"
		CORE=piPeripheral.agc
		DIR=piPeripheral
		CFG=LM
	elif [[ "$REPLY" == "R" || "$REPLY" == "r" ]]
	then
		echo ""
		read -s -p "Password: " -t 30
		if [[ "$REPLY" == "19697R" || "$REPLY" == "19697r" ]]
		then
			clear
			date "+%F %T"
			echo -n "up since "
			uptime -s
			if [[ "$NON_NATIVE" == "" ]]
			then
				vcgencmd measure_temp
				for id in core sdram_c sdram_i sdram_p
				do 
					echo -n "$id: "
					vcgencmd measure_volts $id
				done
			fi
			for nic in eth0 wlan0
			do
				echo -n "$nic: "
				if ifconfig $nic &>/dev/null && ifconfig $nic | grep 'inet addr' &>/dev/null
				then
					ifconfig $nic | grep 'inet addr' | sed -e 's/ B.*//' -e 's/.*://'
				else
					echo "not connected"
				fi
			done
			echo -n "External AGC: "
			if [[ "$AGC_IP" == "" ]]
			then
				echo "not configured"
			else
				echo "$AGC_IP:$AGC_PORT"
			fi
			git -C "$SOURCEDIR" show | grep Date | sed 's/Date: */version: /'
			echo ""
			echo "Maintenance menu:"
			if [[ "$NON_NATIVE" == "" ]]
			then
				echo "1 - Reboot"
				echo "2 - Shutdown"
			fi
			echo "3 - Command line"
			echo "4 - Desktop"
			echo "5 - Missions (default)"
			echo "6 - Configure external AGC"
			if [[ "$NON_NATIVE" == "" ]]
			then
				echo "7 - Update VirtualAGC"
			fi
			echo "8 - Lamp test"
			read -p "Choose a number: " -t 15 -n 1
			echo ""
			if [[ "$REPLY" == "1" && "$NON_NATIVE" == "" ]]
			then
				echo "1 - Confirm reboot"
				echo "2 - Don't reboot"
				read -p "? " -n 1
				echo ""
				if [[ "$REPLY" == "1" ]]
				then
					sudo reboot
				fi
			elif [[ "$REPLY" == "2" && "$NON_NATIVE" == "" ]]
			then
				echo "1 - Confirm shutdown"
				echo "2 - Don't shut down"
				read -p "? " -n 1
				echo ""
				if [[ "$REPLY" == "1" ]]
				then
					sudo poweroff
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
				fi
			elif [[ "$REPLY" == "6" ]]
			then
				NEW_IP=$AGC_IP
				NEW_PORT=$AGC_PORT
				if [[ "$AGC_IP" != "" ]]
				then
					echo "Current IP address of external AGC"
					echo "is $AGC_IP.  ENTR to accept or"
					echo "else input new address, using CLR"
					echo "as a decimal point."
				else
					echo "Input an IP address for the external"
					echo "AGC, using CLR as a decimal point."
				fi
				read -p "> "
				if [[ "$REPLY" != "" ]]
				then
					if echo "$REPLY" | \
					   egrep -v "^[0-9]+[cC][0-9]+[cC][0-9]+[cC][0-9]+$" \
					   &>/dev/null
					then
						continue
					fi
					NEW_IP=`echo $REPLY | sed 's/[cC]/./g'`
				fi
				if [[ "$AGC_PORT" != "" ]]
				then
					echo "Current external AGC port is $AGC_PORT."
					echo "ENTR to accept or else input a new port"
					echo "number."
				else
					echo "Input a port number for the external AGC."
				fi
				read -p "> "
				if [[ "$REPLY" != "" ]]
				then
					if echo "$REPLY" | \
					   egrep -v '^[0-9]{5}$' \
					   &>/dev/null
					then
						continue
					fi
					NEW_PORT=$REPLY
				fi
				if [[ "$NEW_IP" != "$AGC_IP" || "$NEW_PORT" != "$AGC_PORT" ]]
				then
					if ! nmap -p$NEW_PORT $NEW_IP | grep "^$NEW_PORT/tcp open" &>/dev/null
					then
						echo "AGC not found at $NEW_IP:$NEW_PORT."
						echo "1 - Save configuration anyway"
						echo "2 - Don't save (default)"
						read -p "? " -n 1
						echo ""
						if [[ "$REPLY" != "1" ]]
						then
							continue
						fi
					else
						echo "AGC detected at $NEW_IP:$NEW_PORT."
					fi
					saveConfiguration
				fi
			elif [[ "$REPLY" == "7" && "$NON_NATIVE" == "" ]]
			then
				git -C "$SOURCEDIR" fetch --all
				git -C "$SOURCEDIR" reset --hard origin/master
				exec bash "$SOURCEDIR/piPeripheral/runPiDSKY2.sh" $@
				exit 0
			elif [[ "$REPLY" == "8" ]]
			then
				optionsPiDSKY2="--port=19697 $WINDOW $SLOW $PIGPIO --lamptest=1" 
				"$SOURCEDIR/piPeripheral/piDSKY2.py" $optionsPiDSKY2
				sleep 1
				read -p "Hit Enter to continue ..."
			fi
		else
			echo ""
			echo "Permission denied."
			sleep 2
		fi
		continue
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
	if [[ "$PLAYBACK" != "" ]]
	then
		optionsPiDSKY2="$optionsPiDSKY2 $PLAYBACK"
	elif [[ "$EXTERNAL_AGC" != "" ]]
	then
		optionsPiDSKY2="$optionsPiDSKY2 --host=$AGC_IP --port=$AGC_PORT"
	else
		killall yaAGC &>/dev/null
		killall yaDSKY2 &>/dev/null
		killall piDSKY2.py &>/dev/null

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
			if [[ "$DEBUG" == "" ]]
			then
				"$SOURCEDIR/piPeripheral/piPeripheral.py" --port=19699 --time=1 &>/dev/null &
			else
				xterm -hold -e "$SOURCEDIR/piPeripheral/piPeripheral.py --port=19699 --time=1" &
			fi
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
