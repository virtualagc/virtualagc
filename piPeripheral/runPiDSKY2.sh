#!/bin/bash
# Runs yaAGC and piDSKY2.py on a Raspberry Pi.
# Assumes that the github repo for virtualagc has been cloned,
# and that we are in the piPeripheral subdirectory of that clone.
# Assumes the Pi executable for yaAGC is in the PATH.

# Usage:
#	cd piPeripheral
#	./runPiDSKY2.sh [--window=1 [--yaDSKY2 [IMAGE_DIRECTORY]]

cd ..
SOURCEDIR="`pwd`"
cd -

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
if [[ "$3" != "" ]]
then
	cp -a "$3" $RAMDISK/piDSKY2-images
else
	cp -a "$SOURCEDIR/piPeripheral/piDSKY2-images" $RAMDISK
fi
cp -a "$SOURCEDIR/yaDSKY2"/*.{png,jpg} $RAMDISK

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
	"$SOURCEDIR/yaAGC/yaAGC" --core="$SOURCEDIR/$CORE/$CORE.bin" --port=19697 --cfg="$SOURCEDIR/yaDSKY/src/$CFG.ini" &>/dev/null &
	YAGC_PID=$!
	if [[ "$2" == "--yaDSKY2" ]]
	then
		"$SOURCEDIR/yaDSKY2/yaDSKY2" --cfg="$SOURCEDIR/yaDSKY/src/$CFG.ini" --port=19698 &>/dev/null &
		YADSKY2_PID=$!
	fi
	"$SOURCEDIR/piPeripheral/piDSKY2.py" --port=19697 $1 &>/dev/null
	echo "Cleaning up ..."
	kill $YAGC_PID $YADSKY2_PID
	wait $YAGC_PID $YADSKY2_PID &>/dev/null
done
