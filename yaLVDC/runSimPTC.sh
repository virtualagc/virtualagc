#!/bin/bash

PROGRAM=PROC9
if [[ "$1" != "" && -f "$1.lvdc" ]]
then
	PROGRAM="$1"
fi

xterm -rightbar -e ./yaPTC.py &

# Assemble the PROGRAM's source code.
../yaASM.py/yaASM.py --ptc --past-bugs <$PROGRAM.lvdc >$PROGRAM.listing && \
mv yaASM.src $PROGRAM.src && \
mv yaASM.tsv $PROGRAM.tsv && \
mv yaASM.sym $PROGRAM.sym && \
make && \
./yaLVDC --ptc --cold-start --run --assembly=$PROGRAM
