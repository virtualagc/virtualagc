#!/bin/bash
# This script makes a 3-way, side-by-side, visual comparison between the
# comments in different AGC version of the same .agc file, excluding ##-comments
# and blank lines, and reducing multiple spaces to a single space.  If the
# third directory is missing or blank, it just does a 2-way comparison.

LOGSECTION=$1
AGC1=$2
AGC2=$3
AGC3=$4

TMP=`mktemp -d`
cd $TMP
MELDARGS=""

for n in $AGC1 $AGC2 $AGC3
do
	cat ~/git/virtualagc/$n/$LOGSECTION.agc | \
	grep --only-matching '#.*' | \
	egrep --invert-match '^\#\#([^[:space:]]|[[:space:]][^P])' | \
	sed -r 's/[[:space:]]+/ /g' | \
	grep --invert-match '#[[:space:]]*$'  \
	>$n.txt
	MELDARGS="$MELDARGS $n.txt"
done

meld $MELDARGS

cd -
rm $TMP -rf
