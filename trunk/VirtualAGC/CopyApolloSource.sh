#!/bin/bash
# This script is used by the VirtualAGC Makefile to copy AGC or AGS
# stuff into the installation-build directory.  The usage is:
#	sh CopyApolloSource.sh dirname sourcename ext win
# where sourcename is something like Luminary131 or FP8 and the 
# dirname is something .../Resources.  EXT is either -pR
# for Mac OS X, or -a for everyone else.  Finally, WIN is either 
# anything non-blank (for Windows systems) or else blank (for anything
# other than Windows).

SOURCENAME=$2
SOURCEDIR=../$SOURCENAME
DESTDIR=$1/source/$SOURCENAME
EXT=$3
WIN=$4

mkdir $DESTDIR
cp ../Contributed/SyntaxHighlight/Prettify/*.js $DESTDIR
cp ../Contributed/SyntaxHighlight/Prettify/*.css $DESTDIR
cp $EXT $SOURCEDIR/*.binsource $SOURCEDIR/*.agc $DESTDIR
cp $EXT $SOURCEDIR/*.binsource $SOURCEDIR/*.aea $DESTDIR
#sh ./lst2html.sh $SOURCEDIR/$SOURCENAME.lst $DESTDIR/$SOURCENAME.html $WIN
cp $SOURCEDIR/*.html $SOURCEDIR/Apollo32.png $DESTDIR
cp $EXT $SOURCEDIR/$SOURCENAME.bin $DESTDIR
cp $EXT $SOURCEDIR/$SOURCENAME.symtab $DESTDIR/$SOURCENAME.bin.symtab

