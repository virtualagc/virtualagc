#!/bin/bash
# Runs yaAGS and piDEDA.py on a Raspberry Pi.
# Assumes that the github repo for virtualagc has been cloned,
# and the software has been built from source,
# and that we are in the piPeripheral subdirectory of that clone.

# Turn off keyboard repeat, but make sure it gets restored on exit.
function cleanup {
	echo -e "\nRestoring keyboard repeat ..."
	xset r on
}
trap cleanup EXIT
xset r off

cd ..
SOURCEDIR="`pwd`"
cd -

# Parse the command-line arguments.
for i in "$@"
do
	case $i in
		--debug)
			DEBUG=yes
			;;
		--ags-debug)
			AGSDEBUG=yes
			;;
		--yaDEDA2|--yadeda2)
			YADEDA=yes
			;;
		--image-dir=*)
			IMGDIR="`echo $i | sed 's/[^=]*=//'`"
			;;
		--slow)
			SLOW="--slow=1"
			;;
		--pigpio=*)
			PIGPIO="$i"
			;;
		*)
			echo "Usage:"
			echo "  cd piPeripheral"
			echo "  ./runPiDEDA.sh [OPTIONS]"
			echo "The allowed options are:"
			echo "  --yaDEDA2               Run yaDEDA2 in addition to (in parallel with)"
			echo "                          the piDEDA.py.  Useful for cross-checking."
			echo "  --image-dir=PATH        Specify directory for alternate widget graphics."
			echo "                          The default is simply the piDSKY2-images"
			echo "                          subdirectory of the current directory."
			echo "  --debug                 Display extra messages useful in debugging piDSKY2."
			echo "  --ags-debug             Display extra messages useful in debugging yaAGS."
			echo "  --pigpio=N              Use the Pi native (GPIO-driven) UI.  The value of"
			echo "                          the parameter, N, is an intensity, varying from 0"
			echo "                          (the dimmest) to 15 (the brightest)."  
			echo "Other than --pigpio, none of these options are useful unless there is a monitor"
			echo "attached or there is a remote login (ssh, vnc) with X forwarding.  Conversely,"
			echo "--pigpio is required if the native display is used."       
			exit
			;;
	esac
	shift
done
if [[ "$PIGPIO" != "" ]]
then
	# Start pigpiod.  Note that if pigpiod is already started, this
	# won't start a second instance, but will merely show
	# an error message (which we discard).
	sudo pigpiod &>/dev/null
fi

killall yaAGS &>/dev/null
killall yaDEDA2 &>/dev/null
killall piDEDA.py &>/dev/null

# First, prepare to use the RAM disk.
RAMDISK=/run/user/$UID
if [[ ! -d $RAMDISK ]]
then
	echo "RAM disk $RAMDISK does not exist ... using $HOME"
	RAMDISK=$HOME
fi
RAMDISK=$RAMDISK/piDEDA
rm $RAMDISK -rf &>/dev/null
mkdir $RAMDISK &>/dev/null
cd $RAMDISK
if [[ "$IMGDIR" != "" ]]
then
	cp -a "$IMGDIR" $RAMDISK/piDEDA-images
else
	cp -a "$SOURCEDIR/piPeripheral/piDSKY2-images" $RAMDISK/piDEDA-images
fi
cp -a "$SOURCEDIR/yaDEDA2"/*.{png,jpg} $RAMDISK

while true
do
	# Choose a mission.
	clear
	echo "Available missions:"
	echo "0 - Apollo 11 (default)"
	echo "1 - Apollo 15-17"
	read -p "Choose a number: " -t 15 -n 1
	if [[ "$REPLY" == "1" ]]
	then
		CORE=FP8
	elif [[ "$REPLY" == "C" || "$REPLY" == "c" ]]
	then
		echo ""
		read -s -p "Password: " -t 30
		if [[ "$REPLY" == "19697C" || "$REPLY" == "19697c" ]]
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
	else
		CORE=FP6
	fi
	echo ""
	echo "Starting AGS program $CORE ..."
	
	# Run it!
	if [[ "$AGSDEBUG" == "" ]]
	then
		"$SOURCEDIR/yaAGS/yaAGS" --core="$SOURCEDIR/$CORE/$CORE.bin" >/dev/null &
	else
		"$SOURCEDIR/yaAGS/yaAGS" --core="$SOURCEDIR/$CORE/$CORE.bin" &
	fi
	YAGS_PID=$!
	if [[ "$YADEDA" != "" ]]
	then
		"$SOURCEDIR/yaDEDA2/yaDEDA2" &>/dev/null &
		YADEDA2_PID=$!
	fi
	clear
	if [[ "$DEBUG" == "" ]]
	then
		"$SOURCEDIR/piPeripheral/piDEDA.py" $SLOW $PIGPIO >/dev/null
	else
		"$SOURCEDIR/piPeripheral/piDEDA.py" $SLOW $PIGPIO 
		read -p "Hit Enter to continue ..."
	fi
	echo "Cleaning up ..."
	kill $YAGS_PID $YADEDA2_PID $STATUS_PID
	wait $YAGS_PID $YADEDA2_PID $STATUS_PID &>/dev/null
done
