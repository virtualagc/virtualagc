#!/bin/bash
# A script to automate lots of processing for a new folder of
# aperture-card scans from NARA SW.  It's really only useful
# for me personally, but I needed to stick it somewhere.  
#
# Usage:
#	cd path/to/box/part/folders
#	unpunchAll.sh BoxNum1 PartNum1 BoxNum2 PartNum2 ...
# The PartNumX arguments are interpreted as:
#	1	Part 1
#	2	Part 2
#	0	The is just a single part

while [[ "$1" != "" ]]
do
	DIR=`pwd`
	BOX=$1
	shift
	PART=$1
	shift
	if [[ "$PART" != "0" ]]
	then
		INDIR="Box $BOX part $PART"
		OUTDIR="apertureCardBox$BOX"Part$PART"NARASW_images"
	else
		INDIR="Box $BOX"
		OUTDIR="apertureCardBox$BOX"NARASW_images
	fi 
	if [[ ! -d "$INDIR" ]]
	then
		echo "The input folder ($INDIR) does not exist."
		exit 1
	fi
	cd "$INDIR"
	ls -1 *.PDF | unpunch.py $OUTDIR >RenamingScript.sh 2>IndexTable.html
	mkdir $OUTDIR
	for n in *.PDF
	do
		pdfimages -png "$n" $OUTDIR/"$n"
		optipng "$OUTDIR/$n-000.png"
	done
	cd $OUTDIR
	bash ../RenamingScript.sh
	cd -
	tar -cf $OUTDIR.tar $OUTDIR
	cd "$DIR"
done
