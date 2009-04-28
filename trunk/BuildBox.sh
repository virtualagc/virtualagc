#!/bin/bash
# Filename:	BuildBox.sh
# Mods:		2009-04-27 RSB	Wrote

# This is a little script I use to build a Virtual AGC snapshot (source tarball
# plus binary installers) on my build box, which is set up for ssh passwordless
# access from the workstation I use to do code development.  It's of no earthly
# use to anyone who isn't maintaining the Virtual AGC website.  The script:
#
#   1.	Creates a source tarball on the coding workstation.
#   2.	Sends it to the build box.
#   3.	Builds it on the build box.
#   4.  Fetches the new snapshot files into my Virtual AGC website directory.  

BUILDBOX=192.168.254.4
TODAY=`date +%Y%m%d`
WEBSITE=sandroid.org/public_html/apollo/Downloads

make clean dev
ssh $BUILDBOX rm Projects/yaAGC -rf
cat ../$WEBSITE/yaAGC-dev-$TODAY.tar.bz2 | ssh $BUILDBOX tar -C Projects -xjvf -
ssh $BUILDBOX make -C Projects/yaAGC snapshot
scp -p $BUILDBOX:Projects/$WEBSITE/yaAGC-dev-$TODAY.tar.bz2 ~/Projects/$WEBSITE
scp -p $BUILDBOX:Projects/$WEBSITE/VirtualAGC-installer ~/Projects/$WEBSITE
scp -p $BUILDBOX:Projects/$WEBSITE/VirtualAGC-setup.exe ~/Projects/$WEBSITE
scp -p $BUILDBOX:Projects/$WEBSITE/VirtualAGC.app.tar.gz ~/Projects/$WEBSITE
ls -ltr ~/Projects/$WEBSITE

