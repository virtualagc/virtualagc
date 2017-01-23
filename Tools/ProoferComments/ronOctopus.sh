#!/bin/bash
# This is just a wrapper for octopus that matches the directory
# setup I happen to be using, and is just a convenience for me (RSB)
# whilst doing the actual proofing.  No good to anybody else, I expect.

AGC=$1
SWITCHES=$2
EXT=$3

# Where octopus is, along with all its little friends.
bin=$HOME/git/virtualagc/Tools/ocr
# Where the image files are.
images=$HOME/Desktop/Proofing/ProoferComments

TMPDIR=`mktemp -d`
cd $TMPDIR

while [[ "$4" != "" ]]
do
	page=$4
	num=`printf "%04d" $page`
	echo "Page=$num"
	python $bin/octopus.py $images/raw$AGC/$num.$EXT temp.png $SWITCHES
	convert temp.png -threshold 50% -depth 2 $images/prepared$AGC/$num.png
	shift
	sleep 0.1
done

cd -
rm $TMPDIR -rf

if [[ "$GIMP" != "" ]]
then
	gimp $images/prepared$AGC/$num.png
fi

