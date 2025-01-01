#!/bin/bash
# This script runs the PTC program PAST using yaLVDC and yaPTC.py.

# First, find the absolute path to this script, remembering that it may be
# following links.
apparent="`which runSimPTC.sh`"
actual="`readlink -f '$apparent' | sed 's@/runSimPTC.sh$@@'`"
cd "$actual"

xterm -rightbar -hold -e ./yaPTC.py --resize=1 &

# Assemble the PAST program (as slightly altered by me) source code.
../yaASM.py/yaASM.py --ptc --past-bugs <PAST.lvdc >PAST.listing && \
mv yaASM.src PAST.src && \
mv yaASM.tsv PAST.tsv && \
mv yaASM.sym PAST.sym && \
make && \
./yaLVDC --ptc --cold-start --run --assembly=PAST
