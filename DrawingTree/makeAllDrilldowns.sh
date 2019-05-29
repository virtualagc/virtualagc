#!/bin/bash
# Use drilldown.py to create all G&N drilldown pages.  While it 
# actually builds every G&N assembly, it doesn't overwrite the
# web directory with any of their HTML unless that HTML has 
# actually changed.  So it's safe to build as many times as you
# like.
#
# Prior to performing the drilldowns, it rebuilds the master
# drawing index.  However, it only changes files drawings.csv
# and tipuesearch_content.js if their content has changed.
#
# If you put any command-line arguments, those will be treated
# as names of assemblies, and it will drill down those assemblies
# instead of the the default (all G&N assemblies).  It will skip
# rebuilding the master drawing index in this case, since the 
# assumption is you're using this method to get stuff done fast.

if [[ ! -f drilldownCompare.py ]]
then
	echo This must be run from the DrawingTree directory.
	exit 1
fi

current=`pwd`
dest=~/git/virtualagc-web
function drilldown {
	assembly=$1
	echo Drilling $assembly ...
	./drilldown.py $assembly >temp.html
	if diff --brief temp.html $dest/$assembly.html
	then
		echo No change in $assembly
		rm temp.html
	else
		#meld temp.html $dest/$assembly.html
		#exit
		mv temp.html $dest/$assembly.html
	fi
}

if [[ "$1" == "" ]]
then

	# Rebuild master drawing index.
	cd $dest
	cat AgcDrawingIndex*.html | AgcDrawingIndex.py >temp.csv
	if diff --brief temp.csv $current/drawings.csv
	then
		echo No change in drawings.csv
		rm temp.csv
	else
		MakeTipueSearch.py <temp.csv >temp.js
		if diff --brief temp.js TipueSearch/tipuesearch_content.js
		then
			echo No change in tipuesearch_content.js
			rm temp.js
		else
		 	mv temp.js TipueSearch/tipuesearch_content.js
		fi
		mv temp.csv $current/drawings.csv
	fi
	cd $current

	# LEM
	for a in `seq -w 21 10 181`
	do
		if [[ $a != 041 ]]
		then
			drilldown 6014999-$a
		fi
	done
	
	# Block II CM
	for a in `seq -w 11 10 221`
	do
		if [[ $a != 031 ]]
		then
			drilldown 2014999-$a
		fi
	done
	
	# Block I CM
	for a in 000 `seq -w 11 10 121`
	do
		drilldown 1014999-$a
	done

else

	while [[ "$1" != "" ]]
	do
		drilldown $1
		shift
	done

fi
