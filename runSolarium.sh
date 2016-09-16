#!/bin/bash
# Temporary script to make it easier to run Solarium sim.

xterm -e yaDSKYb1/yaDSKYb1main &
cd yaAGCb1 
./yaAGCb1 $1 $2 $3 $4 $5 $6 $7 $8 $9
killall yaDSKYb1main
cd -
