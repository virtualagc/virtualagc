#!/bin/bash
# A script to automate some processing for a new folder of
# aperture-card scans from NARA SW.  It's really only useful
# for me personally, but I needed to stick it somewhere, so
# it ends up in this folder along with lots or more generally-useful
# scripts. 
# 
# What the script does is this:  Assuming a folder is loaded up
# with the contents of a scanned aperture-card box named according
# to the pattern
#	"Box N"		or else		"Box N part P"
# then if you've cd'd to the parent directory of that folder,
# the script will added several things to the selected "Box ..." 
# folder:
#   1.	An appropriately-named file XXXX_images.tar that can be
#	uploaded to archive.org.
#   2. 	A file called IndexTable.html that you can import into
#	an AgcDrawingIndexBOX.html file to create an index page
#	for the ibiblio website.  The links in the index table
#	will be appropriate for the archive.org upload.
# Other stuff will be created temporarily too (RenamingScript.sh
# and an untarred form of the tarball), but those will be deleted
# if the script complete successfully.  It would be nice if the
# script could also appropriately update the AgcDrawingIndexBOX.html
# files, upload the tarball, and automatically regenerate all of the
# assembly drilldowns, but I don't see how to do those things in a
# way that wouldn't be more trouble than continuing to do them manually.
#
# Usage:
#	cd path/to/box/part/folders
#	unpunchAllGAEC.sh BoxNum1 PartNum1 BoxNum2 PartNum2 ...
#		or
#	unpunchAllGAEC.sh BoxNum
# In the latter case, the omitted PartNum is set by default to 0.
# Note that while it can accept arguments for multiple Box/Parts as
# shown above, those will be processed in succession.  Therefore,
# to minimize processing time, it's best to instead run several
# instances of the script simultaneously, with one instance for
# each Box/Part.  I think those separate instances would probably
# have to run in separate terminals, though, since the script
# internally performs some 'cd' operations.  
#
# The PartNumX arguments are interpreted as:
#	1	Part 1
#	2	Part 2
#	0	The is just a single part
# In principle, I suppose you could have Part 3, 4, etc., as well,
# but I've never had a Box with more than 2 Parts, so it's kind of 
# a moot point.

while [[ "$1" != "" ]]
do
	DIR=`pwd`
	BOX=$1
	shift
	if [[ "$1" == "" ]]
	then
		PART=0
	else
		PART=$1
		shift
	fi
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
	ls -1 *.PDF | unpunchGAEC.py $OUTDIR >RenamingScript.sh 2>IndexTable.html
	OUTHTML=~/git/virtualagc-web/LemDrawingIndexBox$BOX.html
	if [[ -f "$OUTHTML" ]]
	then
		echo "$OUTHTML already exists ... skipping."
	else
		DATE="`date +%Y-%m-%d`"
		cat ../LemDrawingIndexBoxHeader.html IndexTable.html ../LemDrawingIndexBoxFooter.html \
			| sed -e "s/@BOX_TBD@/$BOX/" -e "s/@TBD_DATE@/$DATE/" \
			> "$OUTHTML"
	fi
	#exit 1
	mkdir $OUTDIR
	count=0
	total="`ls -1 *.PDF | wc -l`"
	for n in *.PDF
	do
		count=$((count+1))
		echo "Processing Box $BOX, Part $PART, slide #$count/$total ..."
		pdfimages -png "$n" $OUTDIR/"$n"
		optipng "$OUTDIR/$n-000.png"
	done
	cd $OUTDIR
	bash ../RenamingScript.sh
	cd -
	tar -cf $OUTDIR.tar $OUTDIR
	rm RenamingScript.sh $OUTDIR -rf
	cd "$DIR"
done
