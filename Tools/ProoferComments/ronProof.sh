#!/bin/bash
# This is just a wrapper for ProoferComments that matches the directory
# setup I happen to be using, and is just a convenience for me (RSB)
# whilst doing the actual proofing.  No good to anybody else, I expect.

AGC=$1
SCALE=$2
PSM=$3

while [[ "$4" != "" ]]
do
	page=$4
	num=`printf "%04d" $page`
	echo Page $num
	./ProoferComments.py ~/Desktop/ocr/prepared$AGC/$num.png proofing$AGC/$num.jpg $page ../../$AGC/MAIN.agc $SCALE 1 $PSM
	shift
done
