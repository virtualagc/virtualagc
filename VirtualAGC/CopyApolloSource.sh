#!/bin/bash
# This script is used by the VirtualAGC Makefile to copy AGC or AGS
# stuff into the installation-build directory.  The usage is:
#	sh CopyApolloSource.sh dirname sourcename ext
# where sourcename is something like Luminary131 or FP8 and the 
# dirname is something .../Resources.  Finally, ext is either -pR
# for Mac OS X, or -a for everyone else.

SOURCENAME=$2
SOURCEDIR=../$SOURCENAME
DESTDIR=$1/source/$SOURCENAME
EXT=$3

mkdir $DESTDIR
cp $EXT $SOURCEDIR/*.binsource $SOURCEDIR/*.s $DESTDIR
sh ./lst2html.sh $SOURCEDIR/$SOURCENAME.lst $DESTDIR/$SOURCENAME.html
cp $EXT $SOURCEDIR/$SOURCENAME.bin $DESTDIR
cp $EXT $SOURCEDIR/$SOURCENAME.symtab $DESTDIR/$SOURCENAME.bin.symtab

