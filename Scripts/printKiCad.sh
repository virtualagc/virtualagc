#!/bin/bash
# I, the author, Ron Burkey, declare this to be in the Public Domain.

# Performs the steps necessary to transform a KiCad AGC/DSKY drawing
# (or set of drawings) plotted to Postscript into a PNG.  Syntax is
#
#	printKiCad.sh file1.ps file2.ps ...
#
# Requires sed and ImageMagick.

TMPFILE=`mktemp --suffix=.ps`

for ps in "$@"
do
	basename="`echo $ps | sed 's/[.]ps$//'`"
	png="$basename.png"
	echo "$ps -> $png"
	
	# Convert style of dashed lines.
	sed 's/\[[0-9]* [0-9]*\] 0 setdash/[1000 1000] 0 setdash/' "$ps" >$TMPFILE
	# Convert ps and rotate.
	convert -background white -units PixelsPerInch -density 150 $TMPFILE -rotate 90 -flatten -density 150 "$png"
done

rm $TMPFILE
