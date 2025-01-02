#!/bin/bash
# This script runs the PTC program PAST using yaLVDC and yaPTC.py.

# First, find the absolute path to this script, remembering that it may 
# involve symbolic links.
apparent="`which runSimPTC.sh`"
actual="`readlink -f \"$apparent\" | sed 's@/runSimPTC.sh$@@'`"
cd "$actual"

# Start the PTC simulator.
xterm -fa monospace -rightbar -hold -e ./yaPTC.py &
#./yaPTC.py --resize=1 &

# Assemble the PAST program (as slightly altered by me) source code, and then
# run the LVDC CPU emulator.
../yaASM.py/yaASM.py --ptc --past-bugs <PAST.lvdc >PAST.listing && \
mv yaASM.src PAST.src && \
mv yaASM.tsv PAST.tsv && \
mv yaASM.sym PAST.sym && \
make && \
./yaLVDC --ptc --cold-start --run --assembly=PAST
