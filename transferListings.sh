#!/bin/bash
# This is a special-purpose script which is used to copy AGC/AEA program
# listings created by a complete build of the virtualagc master source 
# tree to the program-listings directory of the virtualagc gh-pages branch
# (i.e., the website).  It is assumed that the directory name for the 
# gh-pages branch is the same as for the master source tree, except with a
# suffixed "-web".
#
# What gets transferred is any *.agc.html or *.aea.html files files found
# under virtualagc/VirtualAGC/temp/lVirtualAGC/Resources/source/, to
# virtualagc-web/listings/.

DEST=`pwd`-web/listings
cd VirtualAGC/temp/lVirtualAGC/Resources/source
for n in aea agc
do
	find -name "*."$n".html" -exec cp {} $DEST/{} \;
done
cd -
