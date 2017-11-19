#!/bin/bash
# Runs yaAGC and piDSKY2.py on a Raspberry Pi.
# Assumes that the github repo for virtualagc has been cloned,
# and that we are in the piPeripheral subdirectory of that clone.
# Assumes the Pi executable for yaAGC is in the PATH.

SOURCEDIR="`pwd`/.."

# First, prepare to use the RAM disk.
RAMDISK=/run/user/1000
if [[ ! -d $RAMDISK ]]
then
	echo "RAM disk $RAMDISK does not exist."
	exit 1
fi
RAMDISK=$RAMDISK/piDSKY2
mkdir $RAMDISK
cp -a piDSKY2-images $RAMDISK
cd $RAMDISK

