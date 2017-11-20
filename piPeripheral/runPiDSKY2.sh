#!/bin/bash
# Runs yaAGC and piDSKY2.py on a Raspberry Pi.
# Assumes that the github repo for virtualagc has been cloned,
# and that we are in the piPeripheral subdirectory of that clone.
# Assumes the Pi executable for yaAGC is in the PATH.

SOURCEDIR="`pwd`/.."

killall yaAGC
killall yaDSKY2
killall piDSKY2.py

# First, prepare to use the RAM disk.
RAMDISK=/run/user/1000
if [[ ! -d $RAMDISK ]]
then
	echo "RAM disk $RAMDISK does not exist."
	exit 1
fi
RAMDISK=$RAMDISK/piDSKY2
rm $RAMDISK -rf
mkdir $RAMDISK
cp -a piDSKY2* $RAMDISK
cd $RAMDISK
find "$SOURCEDIR" -name "*.bin" -exec cp {} . \;
find "$SOURCEDIR" -name "*.ini" -exec cp {} . \;
cp -a "$SOURCEDIR/yaAGC/yaAGC" .
cp -a "$SOURCEDIR/yaDSKY2/yaDSKY2" .

# Choose a mission.
clear
echo "Available missions:"
echo "   0 Apollo 5 LM"
echo "   1 Apollo 8 CM"
echo "   2 Apollo 9 CM"
echo "   3 Apollo 10 LM"
echo "   4 Apollo 11 CM"
echo "   5 Apollo 11 LM"
echo "   6 Apollo 12 LM"
echo "   7 Apollo 13 LM"
echo "   8 Apollo 15-17 CM"
echo "   9 Apollo 15-17 LM"
echo "Default Apollo 11 LM after 10 seconds."
read -p "Choose one: " -t 10 -n 1
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
else # $REPLY == 5
	CORE=Luminary099
	CFG=LM
fi
echo "Running $CORE $CFG"

# Run it!
rm LM.core CM.core
./yaAGC --core=$CORE.bin --port=19697 --cfg=$CFG.ini &
./piDSKY2.py --port=19697 --window=1
killall yaAGC
