#!/bin/bash
# Runs yaAGC and piDSKY2.py on a Raspberry Pi.
# Assumes that the github repo for virtualagc has been cloned,
# and that we are in the piPeripheral subdirectory of that clone.
# Assumes the Pi executable for yaAGC is in the PATH.

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
		*)
			echo "Usage:"
			echo "	cd piPeripheral"
			echo "	./runPiDSKY2.sh [OPTIONS]"
			echo "The allowed options are:"
			echo "	--window		Display DSKY registers as a 272x480 window"
			echo "				rather than full screen."
			echo "	--yaDSKY2		Run yaDSKY2 in addition to (in parallel with)"
			echo "				the DSKY-register display.  Most useful if"
			echo "				--window is also used."
			echo "	--image-dir=PATH	Specify directory for alternate widget graphics."
			echo "				The default is simply the piDSKY2-images"
			echo "				subdirectory of the current directory."
			echo "	--led-panel=PATH	Specify a path to the 'led-panel' program."
			echo "				Defaults to simply 'led-panel' (in the current"
			echo "				directory)."
			echo "  --debug			Display extra messages useful in debugging."
			exit
			;;
	esac
	shift
done

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
	clear
	echo "Available missions:"
	echo "0 - Apollo 5 LM"
	echo "1 - Apollo 8 CM"
	echo "2 - Apollo 9 CM"
	echo "3 - Apollo 10 LM"
	echo "4 - Apollo 11 CM"
	echo "5 - Apollo 11 LM (default)"
	echo "6 - Apollo 12 LM"
	echo "7 - Apollo 13 LM"
	echo "8 - Apollo 15-17 CM"
	echo "9 - Apollo 15-17 LM"
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
	elif [[ "$REPLY" == "R" || "$REPLY" == "r" ]]
	then
		echo ""
		read -s -p "Password: " -t 30
		if [[ "$REPLY" == "19697R" || "$REPLY" == "19697r" ]]
		then
			echo ""
			echo "Exiting ..."
			exit
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
	echo ""
	echo "Starting AGC program $CORE ..."
	
	# Run it!
	rm LM.core CM.core &>/dev/null
	if [[ "$DEBUG" == "" ]]
	then
		"$SOURCEDIR/yaAGC/yaAGC" --core="$SOURCEDIR/$CORE/$CORE.bin" --port=19697 --cfg="$SOURCEDIR/yaDSKY/src/$CFG.ini" >/dev/null &
	else
		"$SOURCEDIR/yaAGC/yaAGC" --core="$SOURCEDIR/$CORE/$CORE.bin" --port=19697 --cfg="$SOURCEDIR/yaDSKY/src/$CFG.ini" &
	fi
	YAGC_PID=$!
	if [[ "$YADSKY" != "" ]]
	then
		"$SOURCEDIR/yaDSKY2/yaDSKY2" --cfg="$SOURCEDIR/yaDSKY/src/$CFG.ini" --port=19698 &>/dev/null &
		YADSKY2_PID=$!
	fi
	clear
	"$SOURCEDIR/piPeripheral/piSplash.py" $WINDOW &>/dev/null
	xset r off
	if [[ "$DEBUG" == "" ]]
	then
		"$SOURCEDIR/piPeripheral/piDSKY2.py" --port=19697 $WINDOW $SLOW >/dev/null
	else
		"$SOURCEDIR/piPeripheral/piDSKY2.py" --port=19697 $WINDOW $SLOW 
		read -p "Hit Enter to continue ..."
	fi
	xset r on
	echo "Cleaning up ..."
	kill $YAGC_PID $YADSKY2_PID
	wait $YAGC_PID $YADSKY2_PID &>/dev/null
done
