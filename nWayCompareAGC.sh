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

# Allowing it to operate on code as well (though continuing to ignore whitespace
# can also be done, with an environment variable.
 
# The usage is:
#	[CODETOO=yes] nWayCompareAGC.sh Filename.agc Dir1 Dir2 ...
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

for dir in "${DIRS[@]}"
do
	if [[ ! -f $dir/$FILE ]]
	then
		echo "Input file "$dir/$FILE" does not exist."
		exit 1
	fi
done

START=`pwd`
mkdir ~/Desktop/nWayCompareAGC
cd ~/Desktop/nWayCompareAGC

# Normalize all of the input files.
COMMAND="diffuse -w"
for dir in "${DIRS[@]}"
do
	COMMAND="$COMMAND $dir.txt"
	sed -r \
		-e 's/[#][#].*//' \
		$WIPECODE \
		-e 's/[[:space:]]+/ /g' \
		-e 's/^[#][[:space:]]*$//' \
		$START/$dir/$FILE | grep --invert-match '^[[:space:]]*$' >$dir.txt
done

$COMMAND

cd -