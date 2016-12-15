#!/bin/bash
# This is just a wrapper for octopus that matches the directory
# setup I happen to be using, and is just a convenience for me (RSB)
# whilst doing the actual proofing.  No good to anybody else, I expect.

AGC=$1
SWITCHES=$2

while [[ "$3" != "" ]]
do
	page=$3
	num=`printf "%04d" $page`
	echo "Page=$num"
	python ../octopus.py ~/git/virtualagc/Tools/ProoferComments/raw$AGC/$num.png $num.png $SWITCHES
	gimp $num.png
	shift
done

