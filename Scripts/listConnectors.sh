#!/bin/bash
# A convenience script (probably only for me personally) that is basically
# a wrapper for listConnectors.awk.  The usage is 
#	listConnectors drawingfolder module [ comparisonProgram [ nameOfCaptionField ] ]
# For example, if it were run from the Schematics directory, it might 
# look like 
#	listConnectors 2005271- A22
# If the optional third argument is present, it would be the name of some
# kind of combined diff/viewer program, like kompare or meld.  If absent, the output
# of diff itself is dumped to stdout.

# A CSV dump of the pin-database's (https://github.com/virtualagc/agc_hardware/blob/block2/delphi.db)
# PINS table, with no quotes and a space as the delimiter, is assumed to be
# at ~/Desktop/pins.txt.

if [[ ! -d "$1" ]]
then
	echo "Specified folder ($1) does not exist."
	exit 1
fi

if [[ "$3" != "" ]]
then
	DIFF="$3"
else
	DIFF=diff
fi

if [[ "$4" != "" ]]
then
	CAPTION=$4
else
	CAPTION='"Caption"'
fi

echo "Comparing module $2 (drawing $1, netname field = $CAPTION) with pin database."

cd $1 &>/dev/null
cat *.sch | awk -v CAPTION=$CAPTION -f ../../Scripts/listConnectors.awk | sed 's/"//g'  | sort >pinsLocal.txt
awk '{if ($1 == "'$2'" && $3 != "SPARE" && !($3 == "NC" && (NF < 4 || $4 == "0VDCA"))) print $2 " " $4 ; else {}}' \
	<~/Desktop/pins.txt >pinsDB.txt
$DIFF pinsLocal.txt pinsDB.txt
cd - &>/dev/null
