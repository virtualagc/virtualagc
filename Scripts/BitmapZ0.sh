#!/bin/bash
# In a KiCad schematics file containing a single image (plus other non-image
# stuff) moves the image to the very beginning, so that it is "behind" the
# other objects in display order.

if [[ ! -f "$1" ]]
then
	echo "File \"$1\" does not exist."
	exit 1
fi
if [[ 1 != "`grep -c '^\$Bitmap$' \"$1\"`" ]]
then 
	echo "No image or more than 1 image in the file ... won't change."
	exit 1
fi	

# Fetch different chunks of the file into temporary files.
#
#	temp1.txt	Contains up to (but not including) "$EndDescr"
#	temp2.txt	Contains "$EndDescr" up to (but not including) "$Bitmap"
#	temp3.txt	Contains "$Bitmap" up to (but not including) "$EndBitmap"
#	temp4.txt 	Contains "$EndBitmap" through the end of the file. 
awk '/^EESchema|^\$EndDescr$|^\$Bitmap$|^\$EndBitmap$/{n++}{print >"temp" n ".txt"}' "$1"

# Backup 
cp -a "$1" "$1".bak

# Reassemble.
cat temp1.txt >temp.txt
echo '$EndDescr' >>temp.txt
cat temp3.txt >>temp.txt
echo '$EndBitmap' >>temp.txt
tail -n +2 temp2.txt >> temp.txt
tail -n +2 temp4.txt >>temp.txt

mv temp.txt "$1"
