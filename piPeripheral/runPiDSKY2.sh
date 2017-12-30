#!/bin/bash
# Runs yaAGC and piDSKY2.py on a Raspberry Pi.
# Assumes that the github repo for virtualagc has been cloned,
# and the software has been built from source,
# and that we are in the piPeripheral subdirectory of that clone.
#
# Strings referenced as $"...string..." rather than just 
# "...string..." have been internationalized and are being looked
# up with gettext, depending on how the environment variable
# LANGUAGE has been set.  There are notes at the top of 
# internationalization/it.po that tell how this works.

# For some reason, the following reports 1 outside of a script and 2 
# within one.  I think it may have something to do with `` having to
# start another copy of bash, but I haven't been able to pin it down
# exactly.
runcount=`ps aux | grep 'bash.*runPiDSKY2' | grep -c --invert-match grep`
if [[ $runcount != 2 ]]
then
	#echo Already running, runcount=$runcount.
	exit 1
fi

ARGLIST="$@"
if [[ "$LANGUAGE" == "" ]]
then
	export LANGUAGE=en
fi
export TEXTDOMAIN=runPiDSKY2.sh
export TEXTDOMAINDIR=$HOME/locale

playbackIteration=0

# Turn off keyboard repeat, but make sure it gets restored on exit.
function cleanup {
	echo ""
	echo $"Restoring keyboard repeat ..."
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
else
	MISSION_DEFAULT="5"
	REPLAY_DEFAULT="2"
	
fi
function saveConfiguration() {
	#echo "Saving external AGC: $AGC_IP:$AGC_PORT ..."
	sudo -u $USER echo -e \
		"AGC_IP=$AGC_IP\nAGC_PORT=$AGC_PORT\nMISSION_DEFAULT=$MISSION_DEFAULT\nREPLAY_DEFAULT=$REPLAY_DEFAULT" \
		>"$HOME"/runPiDSKY2.cfg
	#sleep 2
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
		--language=*)
			export LANGUAGE="`echo $i | sed 's/[^=]*=//'`"
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
			echo -e $"MenuText"
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
	printf $"RAM...HOME""\n" "$RAMDISK" "$HOME"
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

function menuItem() {
	key="$1"
	description="$2"
	defaultKey="$3"
	printf " %4s   %s" $key "$description"
	if [[ "$key" == "$defaultKey" ]]
	then
		echo " "$"(default)"
	else
		echo ""
	fi
}
keyString=""
function keyToString() {
	key="$1"
	if [[ "$key" == 'v' || "$key" == 'V' ]]
	then
		keyString="VERB"
		return
	fi
	if [[ "$key" == 'n' || "$key" == 'N' ]]
	then
		keyString="NOUN"
		return
	fi
	if [[ "$key" == 'c' || "$key" == 'C' ]]
	then
		keyString="CLR"
		return
	fi
	if [[ "$key" == 'p' || "$key" == 'P' ]]
	then
		keyString="PRO"
		return
	fi
	if [[ "$key" == 'k' || "$key" == 'K' ]]
	then
		keyString="KEY REL"
		return
	fi
	if [[ "$key" == 'r' || "$key" == 'R' ]]
	then
		keyString="RSET"
		return
	fi
	if [[ "$key" == '=' ]]
	then
		keyString="+"
		return
	fi
	if [[ "$key" == '_' ]]
	then
		keyString="-"
		return
	fi
	keyString="$key"
}

while true
do
	unset DIR CORE CFG YAGC_PID YADSKY2_PID STATUS_PID STATUS_BARE PLAYBACK EXTERNAL_AGC RUN_PIPERIPHERALPY
	
	# Choose a mission.
	xset r off
	clear
	git -C "$SOURCEDIR" show | grep '^Date:' | sed 's/Date: */'$"Version"': /'
	echo ""
	echo $"Available missions":
	echo ""
	menuItem 0 $"Run"" Apollo 5 LM" $MISSION_DEFAULT
	menuItem 1 $"Run"" Apollo 8 CM" $MISSION_DEFAULT
	menuItem 2 $"Run"" Apollo 9 CM" $MISSION_DEFAULT
	menuItem 3 $"Run"" Apollo 10 LM" $MISSION_DEFAULT
	menuItem 4 $"Run"" Apollo 11 CM" $MISSION_DEFAULT
	menuItem 5 $"Run"" Apollo 11 LM"  $MISSION_DEFAULT
	menuItem 6 $"Run"" Apollo 12 LM" $MISSION_DEFAULT
	menuItem 7 $"Run"" Apollo 13 LM" $MISSION_DEFAULT
	menuItem 8 $"Run"" Apollo 15-17 CM" $MISSION_DEFAULT
	menuItem 9 $"Run"" Apollo 15-17 LM" $MISSION_DEFAULT
	menuItem - "Apollo 11 "$"landing" $MISSION_DEFAULT
	menuItem + $"Other scenarios" $MISSION_DEFAULT
	if [[ "$AGC_IP" != "" && "$AGC_PORT" != "" ]]
	then
		menuItem CLR $"External AGC" $MISSION_DEFAULT
	fi
	if [[ "$CUSTOM_BARE" != "" ]]
	then
		menuItem VERB $"Custom AGC program" $MISSION_DEFAULT
	fi
	echo ""
	read -p $"Choose an option"": " -t 15 -n 1
	TEST_LAMPS=""
	if [[ "$REPLY" == "" || "$REPLY" == "$MISSION_DEFAULT" ]]
	then
		REPLY=$MISSION_DEFAULT
	elif [[ "$REPLY" != "r" && "$REPLY" != "R" ]]
	then
		keyToString "$REPLY"
		MISSION_DEFAULT="$keyString"
		saveConfiguration
	fi
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
	elif [[ "$REPLY" == "5" ]]
	then
		CORE=Luminary099
		CFG=LM
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
		echo $"Pre-recorded scenarios":
		echo ""
		menuItem 0 "Apollo 8 "$"launch" $REPLAY_DEFAULT
		menuItem 1 "Apollo 11 "$"launch" $REPLAY_DEFAULT
		menuItem 2 "Apollo 11 "$"landing" $REPLAY_DEFAULT
		if [[ "$PLAYBACK_OPTION" != "" ]]
		then
			menuItem CLR $"Custom recording" $REPLAY_DEFAULT
		fi
		menuItem RSET $"Mission menu" $REPLAY_DEFAULT
		echo ""
		read -p $"Choose an option"": " -t 15 -n 1
		if [[ "$REPLY" == "" || "$REPLY" == "$REPLAY_DEFAULT" ]]
		then
			REPLY=$REPLAY_DEFAULT
		elif [[ "$REPLY" != "r" && "$REPLY" != "R" ]]
		then
			keyToString "$REPLY"
			REPLAY_DEFAULT="$keyString"
			saveConfiguration
		fi
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
		else # RSET ... but all other unallocated keys as well.
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
		RUN_PIPERIPHERALPY=yes
	elif [[ "$REPLY" == "R" || "$REPLY" == "r" ]]
	then
		echo ""
		read -s -p $"Password"": " -t 30
		if [[ "$REPLY" == "19697R" || "$REPLY" == "19697r" ]]
		then
			clear
			date "+%F %T"
			echo -n $"up since"" "
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
					echo $"not connected"
				fi
			done
			echo -n $"External AGC"": "
			if [[ "$AGC_IP" == "" ]]
			then
				echo $"not configured"
			else
				echo "$AGC_IP:$AGC_PORT"
			fi
			git -C "$SOURCEDIR" show | grep '^Date:' | sed 's/Date: */'$"Version"': /'
			echo ""
			echo $"Maintenance menu":
			menuItem 0 $"Test digits/lamps" RSET
			if [[ "$NON_NATIVE" == "" ]]
			then
				menuItem 1 $"Reboot" RSET
				menuItem 2 $"Shutdown" RSET
			fi
			menuItem 3 $"Command line" RSET
			menuItem 4 $"Desktop" RSET
			menuItem 5 $"Manual DSKY" RSET
			menuItem 6 $"Configure external AGC" RSET
			if [[ "$NON_NATIVE" == "" ]]
			then
				menuItem 7 $"Update"" VirtualAGC" RSET
			fi
			menuItem 8 $"Lamp test" RSET
			menuItem 9 $"Reset settings" RSET
			menuItem RSET $"Mission menu" RSET
			read -p $"Choose a number"": " -t 15 -n 1
			echo ""
			if [[ "$REPLY" == "0" ]]
			then
				TEST_LAMPS=yes
				PLAYBACK="--playback=$SOURCEDIR/yaDSKY2/testLights.canned"
			elif [[ "$REPLY" == "1" && "$NON_NATIVE" == "" ]]
			then
				menuItem 1 $"Confirm reboot" ""
				menuItem 2 $"Don't reboot" ""
				read -p $"Choose"": " -n 1
				echo ""
				if [[ "$REPLY" == "1" ]]
				then
					sudo reboot
				fi
			elif [[ "$REPLY" == "2" && "$NON_NATIVE" == "" ]]
			then
				menuItem 1 $"Confirm shutdown" ""
				menuItem 2 $"Don't shutdown" ""
				read -p $"Choose"": " -n 1
				echo ""
				if [[ "$REPLY" == "1" ]]
				then
					sudo poweroff
				fi
			elif [[ "$REPLY" == "3" ]]
			then
				menuItem 1 $"Confirm exit to console" ""
				menuItem 2 $"Don't exit" ""
				read -p $"Choose"": " -n 1
				echo ""
				if [[ "$REPLY" == "1" ]]
				then
					exit
				fi
			elif [[ "$REPLY" == "4" ]]
			then
				menuItem 1 $"Confirm exit to desktop" ""
				menuItem 2 $"Don't exit" ""
				read -p $"Choose"": " -n 1
				echo ""
				if [[ "$REPLY" == "1" ]]
				then
					sudo killall xterm
					exit
				fi
			elif [[ "$REPLY" == "5" ]]
			then
				optionsPiDSKY2="--port=19697 $WINDOW $SLOW $PIGPIO --manual=1" 
				"$SOURCEDIR/piPeripheral/piDSKY2.py" $optionsPiDSKY2
			elif [[ "$REPLY" == "6" ]]
			then
				NEW_IP=$AGC_IP
				NEW_PORT=$AGC_PORT
				if [[ "$AGC_IP" != "" ]]
				then
					echo $"Current IP address of external AGC is"
					echo "\t$AGC_IP."
					echo -e $"ENTR...point"
				else
					echo -e $"Input...point"
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
					printf $"Current...number"".\n" $AGC_PORT
				else
					echo $"Input a port number for the external AGC."
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
						printf $"AGC not found at"" %s:%s.\n" $NEW_IP $NEW_PORT
						menuItem 1 $"Save settings anyway" 2
						menuItem 2 $"Don't save" 2
						read -p $"Choose"": " -n 1
						echo ""
						if [[ "$REPLY" != "1" ]]
						then
							continue
						fi
					else
						printf $"AGC detected at"" %s:%s.\n" $NEW_IP $NEW_PORT
					fi
					AGC_IP=$NEW_IP
					AGC_PORT=$NEW_PORT
					saveConfiguration
				fi
			elif [[ "$REPLY" == "7" && "$NON_NATIVE" == "" ]]
			then
				echo $"Fetching from VirtualAGC repository ..."
				git -C "$SOURCEDIR" fetch --quiet --all
				git -C "$SOURCEDIR" reset --quiet --hard origin/master
				echo -n -e $"New"" "
				git -C "$SOURCEDIR" show | grep '^Date:' | sed 's/Date: */'$"version"': /'
				echo $"Rebuilding yaAGC and yaYUL ..."
				cp -p "$SOURCEDIR"/yaAGC/yaAGC "$SOURCEDIR"/yaYUL/yaYUL .
				#make -C "$SOURCEDIR"/yaAGC clean &>/dev/null
				#make -C "$SOURCEDIR"/yaYUL clean &>/dev/null
				make -C "$SOURCEDIR" yaAGC yaYUL &>"$SOURCEDIR"/piPeripheral/rebuild.log
				if [[ $? -eq 0 ]]
				then
					echo -e "\t"$"Rebuild successful."
				else
					echo -e "\t"$"Error: Build failed!"
					echo -e "\t"$"Restoring prior builds."
					echo -e "\t"$"See rebuild.log."
					cp -p yaAGC "$SOURCEDIR"/yaAGC
					cp -p yaYUL "$SOURCEDIR"/yaYUL
				fi
				echo $"Generating new translations ..."
				cd "$SOURCEDIR/piPeripheral/internationalization"
				for po in *.po
				do
					lan="`echo $po | sed 's/[.]po$//'`"
					echo -e "\t$lan"
					mkdir -p $HOME/locale/$lan/LC_MESSAGES
					msgfmt -o $HOME/locale/$lan/LC_MESSAGES/runPiDSKY2.sh.mo $po
				done
				cd - &>/dev/null
				echo $"Update operation finished""."
				read -p $"Hit ENTR to continue"": "
				cd "$SOURCEDIR"/piPeripheral
				exec bash ./runPiDSKY2.sh $ARGLIST
				exit 0
			elif [[ "$REPLY" == "8" ]]
			then
				optionsPiDSKY2="--port=19697 $WINDOW $SLOW $PIGPIO --lamptest=1" 
				"$SOURCEDIR/piPeripheral/piDSKY2.py" $optionsPiDSKY2
				sleep 1
				read -p $"Hit ENTR to continue"" ..."
			elif [[ "$REPLY" == "9" ]]
			then
				rm $HOME/runPiDSKY2.cfg
			fi
		else
			echo ""
			echo $"Permission denied"
			sleep 2
		fi
		if [[ "$TEST_LAMPS" == "" ]]
		then
			continue
		fi
	else
		continue
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
	
		printf $"Starting AGC program""\n" $CORE
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
		if [[ "$CUSTOM_BARE" != "" && "$RUN_PIPERIPHERALPY" != "" ]]
		then
			if [[ "$NON_NATIVE" == "" ]]
			then
				EXTRA_PERIPHERAL="--imu=1 --gps=1"
			fi
			#EXTRA_PERIPHERAL="--gpsdebug=1 $EXTRA_PERIPHERAL"
			if [[ "$DEBUG" == "" ]]
			then
				"$SOURCEDIR/piPeripheral/piPeripheral.py" --port=19699 --time=1 $EXTRA_PERIPHERAL &>/dev/null &
			else
				xterm -hold -e "$SOURCEDIR/piPeripheral/piPeripheral.py --port=19699 --time=1 $EXTRA_PERIPHERAL" &
			fi
			STATUS_BARE=$!
		fi
	
		if [[ "$PIDSKY" != "" ]]
		then
			"$SOURCEDIR/piPeripheral/piDSKY.py" --port=19697
			if [[ "$DEBUG" != "" ]]
			then
				read -p $"Hit ENTR to continue"" ..."
			fi
		fi
	fi
	
	if [[ "$PIDSKY" == "" ]]
	then
		if [[ "$DEBUG" == "" ]]
		then
			if [[ "$PLAYBACK" != "" ]]
			then
				playbackIteration=$((playbackIteration+1))
				echo "Starting playback iteration #$playbackIteration"
				d="`date`"
				echo "$d: Starting playback iteration #$playbackIteration" >>playback.log
			fi
			"$SOURCEDIR/piPeripheral/piDSKY2.py" $optionsPiDSKY2 >/dev/null
			if [[ "$PLAYBACK" != "" ]]
			then
				echo "Finished playback iteration #$playbackIteration"
				d="`date`"
				echo "$d: Finished playback iteration #$playbackIteration" >>playback.log
			fi
		else
			"$SOURCEDIR/piPeripheral/piDSKY2.py" $optionsPiDSKY2
			read -p "Hit ENTR to continue ..."
		fi
	fi
	
	echo $"Cleaning up ..."
	kill $YAGC_PID $YADSKY2_PID $STATUS_PID $STATUS_BARE &>/dev/null
	wait $YAGC_PID $YADSKY2_PID $STATUS_PID $STATUS_BARE &>/dev/null
	
	echo "Returning to mission menu in 2 seconds ..."
	sleep 2
done
