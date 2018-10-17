#!/bin/bash
# Create a gate-translation file for Mike's vs my corresponding module.
#
# Usage:
#	makeGateTranslate.sh MODULE MIKENAME MYNAME
# The MODULE is A01-A24.  MIKENAME is the name of Mike's schematic, assumed
# to be a subdirectory of agc_hardware/, which should be at the same level
# as virtualagc-schematics/.  The resulting file will be
# virtualagc-schematics/Schematics/MYNAME/gateTranslate.txt.  It is assumed
# that this script is being run from virtualagc-schematics/Schematics/.
#
# Example:
#	cd Schematics
#	makeGateTranslate.sh A01 scaler 2005259A

SCRIPTDIR=../Scripts
PINSDB=$SCRIPTDIR/pins.txt
MODULE=$1
MIKENAME=$2
MYNAME=$3
MIKEDIR=../../agc_hardware/$MIKENAME
MYDIR=$MYNAME
MIKENETLIST=$MIKEDIR/$MIKENAME.net
MIKEPINS=$MIKEDIR/pins.tmp
MYNETLIST=$MYDIR/module.net
MYSCRIPT=$MYDIR/temp.sh
MYPINS=$MYDIR/pins.tmp
OUTFILE=$MYDIR/gateTranslate.txt

if [[ -f $OUTFILE ]]
then
	echo "The output file \"$OUTFILE\" already exists"
	exit 1
fi
if [[ ! -f $MIKENETLIST ]]
then
	echo "The input file \"$MIKENETLIST\" does not exist"
	exit 1
fi
if [[ ! -f $MYNETLIST ]]
then
	echo "The input file \"$MYNETLIST\" does not exist"
	exit 1
fi

awk -v module=$MODULE -f $SCRIPTDIR/extractMikeGates.awk $MIKENETLIST | \
sed -e 's@/$@_@' -e 's@/[AB][0-9][0-9]_[0-9]/@@' | \
sort --key=2 >$MIKEPINS

awk -v module=$MODULE -f $SCRIPTDIR/pinDB2Lookup.awk <$PINSDB >$MYSCRIPT
chmod +x $MYSCRIPT

awk -v module=$MODULE -f $SCRIPTDIR/extractMikeGates.awk $MYNETLIST | \
sed -e 's@/$@_@' -e 's@[^ ]*/@@' | \
sort --key=2 | $MYSCRIPT | sort --key=2 >$MYPINS

join -1 2 -2 2 -a 1 $MIKEPINS $MYPINS >$OUTFILE
if [[ "$4" != "" ]]
then
  gedit $OUTFILE &
fi


