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

SRCPATHS="*.binsource *.agc *.aea Apollo32.png *.agc.html *.aea.html"
SRCPATHS="$SRCPATHS *.pad *.cbp Makefile"
# The Block I .lst files have to be added to the Resources/source/ directory
# so that source code can be displayed when doing command-line debugging of the
# AGC program.  Unfortunately, I don't know any way of getting them there 
# without explicitly adding them.  (I could just use *.lst, but that would
# include lots of unnecessary stuff as well.)
SRCPATHS="$SRCPATHS Solarium055.lst"
SRCPATHS="$SRCPATHS Corona261.lst"
SRCPATHS="$SRCPATHS Sunrise45.lst"
SRCPATHS="$SRCPATHS Sunrise69.lst"

mkdir $DESTDIR

cp ../Contributed/SyntaxHighlight/Prettify/*.js $DESTDIR
cp ../Contributed/SyntaxHighlight/Prettify/*.css $DESTDIR

for srcpath in ${SRCPATHS}; do 
    sources=`find $SOURCEDIR -name $srcpath`
    if [ ! -z "$sources" ]; then
        cp $EXT $sources $DESTDIR
    fi
done
 
#sh ./lst2html.sh $SOURCEDIR/$SOURCENAME.lst $DESTDIR/$SOURCENAME.html $WIN

if [ -f $SOURCEDIR/$SOURCENAME.bin ]; then
    cp $EXT $SOURCEDIR/$SOURCENAME.bin $DESTDIR
fi

if [ -f $SOURCEDIR/$SOURCENAME.symtab ]; then
    cp $EXT $SOURCEDIR/$SOURCENAME.symtab $DESTDIR/$SOURCENAME.bin.symtab
fi
