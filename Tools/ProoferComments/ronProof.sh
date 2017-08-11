#!/bin/bash
# This is just a wrapper for ProoferComments that matches the directory
# setup I happen to be using, and is just a convenience for me (RSB)
# whilst doing the actual proofing.  No good to anybody else, I expect.

AGC=$1
SCALE=$2
PSM=$3

if [[ "$EXT" == "" ]]
then
	EXT=png
fi

# Where ProoferComments is, along with all its little friends.
bin=$HOME/git/virtualagc/Tools/ProoferComments
# Where the image files are.
images=$HOME/Desktop/Proofing/ProoferComments
# Where the AGC source files are.
if [[ "$AGCOVERRIDE" != "" ]]
then
	source=$HOME/git/virtualagc/$AGCOVERRIDE
else
	source=$HOME/git/virtualagc/$AGC
fi

# Switch into a temporary working directory
mkdir /tmp/ProoferComments$$
cd /tmp/ProoferComments$$
ln --symbolic $bin/* .
rm *.box &>/dev/null

while [[ "$4" != "" ]]
do
	page=$4
	num=`printf "%04d" $page`
	echo Page $num
	./ProoferComments.py $images/prepared$AGC/$num.$EXT $images/proofing$AGC/$num.jpg $page $source/MAIN.agc $SCALE 1 $PSM
	shift
done

if [[ "$BOX" == "yes" ]]
then
	cp $images/prepared$AGC/$num.png eng.agc.exp0.png
	echo `pwd`
	~/Desktop/jTessBoxEditor-1.6.1.jar
	#less eng.agc.exp0.box
fi
if [[ "$LESS" == "yes" ]]
then
	less eng.agc.exp0.box
fi

cd -
rm /tmp/ProoferComments$$ -rf
