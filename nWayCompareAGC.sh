#!/bin/bash
# This script is for doing an n-way side-by-side comparison for a .agc file
# that appears in multiple AGC versions.  By default, it is limited to
# #-style comment text, and ignores:
#	1. Actual code.
#	2. ##-style comments.
#	3. Blank lines.
#	4. White space within comments.
# The way it works is that it first actively normalizes the file (producing a
# new one for each AGC version, with the stuff listed above factored out), and
# then the normalized files it produces are viewed using the 'Diffuse" utility
# (http://diffuse.sourceforge.net/).

# The script can alternately be used with the 'Difdef' utility
# (https://github.com/Quuxplusone/difdef).  The distinction is that with the
# default (Diffuse) you get a visual side-by-side comparison, whereas alternatively
# (Difdef), you get a machine-readable version of the comparison, containing a 
# list of the unique lines, prepended by a string that indicates *which* of the 
# input files contains that line.  My idea, specifically, for using Difdef is that
# it provides a tool for using an octopus/ProoferComments-like process for determining
# where the whitespace in comments should be, by allowing you to figure out (for any
# given shared line of source code) which assembly-listing printouts contain it.  One
# could then use the *best* of those to deduce the whitespace, and then you could 
# apply that same whitespace for that line to all of the other source file containing it.

# Allowing it to operate on code as well (though continuing to ignore whitespace)
# can also be done, with an environment variable.  Note that if 'Difdef' is being used,
# lines consisting *only* of code are still discarded.  (I.e., lines consisting of 
# comment-only or code+comment are used, but not code-only.)  With 'Diffuse', the 
# code-only lines are retained.  This, of course, is in line with the usage rationale,
# since we're only interested in debugging the whitespace in comments, and not in code.
 
# The usage is:
#	[DIFDEF=yes] [CODETOO=yes] nWayCompareAGC.sh Filename.agc Dir1 Dir2 ...
# None of the arguments is allowed to contain any spaces.  For example, 
#	./nWayCompareAGC.sh ALARM_AND_ABORT.agc Luminary069 Luminary099 Luminary131 Luminary210

if [[ "$1" == "" || "$2" == "" || "$3" == "" ]]
then
	echo "Not enough arguments."
	exit 1
fi

FILE=$1
DIRS=($@)
unset DIRS[0]
WIPECODE="-e s/^[^#]*//"
if [[ "$CODETOO" == 'yes' ]]
then
	WIPECODE=""
fi

letters=(a b c d e f g h i j k l m n o p q r s t u v w x y z)
letter=0
for dir in "${DIRS[@]}"
do
	if [[ ! -f $dir/$FILE ]]
	then
		if [[ "$DIFDEF" == "yes" ]]
		then
			echo "@ $dir/$FILE"
		else
			echo "Input file "$dir/$FILE" does not exist."
			exit 1
		fi
	else
		if [[ "$DIFDEF" == "yes" ]]
		then
			echo "${letters[$letter]} $dir/$FILE"
			letter=$((letter+1))
		fi
	fi
done
if [[ "$DIFDEF" == "yes" ]]
then
	echo "="
	REPAGE="@@"
else
	REPAGE="##"
fi

START=`pwd`
mkdir ~/Desktop/nWayCompareAGC &>/dev/null
cd ~/Desktop/nWayCompareAGC &>/dev/null

# Normalize all of the input files.
if [[ "$DIFDEF" == "yes" ]]
then
COMMAND="difdef"
else
COMMAND="diffuse -w"
fi
for dir in "${DIRS[@]}"
do
	if [[ -f $START/$dir/$FILE ]]
	then
		COMMAND="$COMMAND $dir.txt"
		cat $START/$dir/$FILE | \
		sed -r 's/^\#\#[[:space:]]+Page[[:space:]]+([0-9]+)[[:space:]]*$/'$REPAGE' Page \1/' | \
		sed -r \
			-e 's/[#][#].*//' \
			$WIPECODE \
			-e 's/[[:space:]]+/ /g' \
			-e 's/ ([[:punct:]])/\1/g' \
			-e 's/([[:punct:]]) /\1/g' \
			-e 's/^[#][[:space:]]*$//' | \
		grep --invert-match '^[[:space:]]*$' \
		>$dir.txt
		if [[ "$DIFDEF" == "yes" ]]
		then
			mv $dir.txt temp.txt
			egrep '(\#|@@)' temp.txt >$dir.txt
			rm temp.txt
		fi
	fi
done

$COMMAND

cd - &>/dev/null