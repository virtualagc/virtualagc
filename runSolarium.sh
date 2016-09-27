#!/bin/bash
# Temporary script to make it easier to run Solarium sim.  If you want to use
# the nav-bay sim, use a CLI switch of --nav-bay, but it should be the first 
# switch, if there's more than one.

nav=
if [[ "$1" == "--nav-bay" ]]
then
	nav=--nav-bay
	shift
fi

xterm -e yaDSKYb1/yaDSKYb1 --images=yaDSKYb1/images/ $nav &
cd yaAGCb1 
./yaAGCb1 $1 $2 $3 $4 $5 $6 $7 $8 $9
killall yaDSKYb1
cd -
