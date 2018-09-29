#!/bin/bash
# Copyright 2018 Ronald S. Burkey <info@sandroid.org>
# 
# This file is part of yaAGC.
# 
# yaAGC is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# yaAGC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with yaAGC; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# 
# Filename: 	BitmapZ0.sh
# Purpose:	For KiCad .sch files containing a single place image,
#		moves that image to the top of the file.  This used to
#		be part of my workflow for transcribing scanned drawings
#		into KiCad.  Though it still works, it has essentially 
#		been completely obsoleted by addBackgroundPNG.py.
# Mod history:	2018-07-29 RSB	First time I remembered to add the GPL and
#				other boilerplate at the top of the file.
#
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
