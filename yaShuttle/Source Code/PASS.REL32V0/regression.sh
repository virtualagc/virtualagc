#!/bin/bash
# The is a sort of regression test for the compiler HAL/S-FC, in which 
# lot's of sample HAL/S files are compiled using HAL/S-FC, with an abort 
# occurring on the first failure.  I tried doing this entirely in the Makefile,
# but since the names of the folders containing the HAL/S files contain spaces,
# there was no reasonable way to make it work.  All of the parameters
# normally accepted by the Makefile (XEXTRA, EXTRA, HEXTRA, PEXTRA, REXTRA, 
# CC, etc.) can be used on the regression.sh command line.  HAL/S files which
# are known to contain COMPOOLs used by "D INCLUDE TEMPLATE" directives in other
# of the files have to be handled separately and be compiled first.

# HAL/S files that need to create templates in the template library:
if ! make -s 	PEXTRA="--templib" PARM_STRING="TEMPLATE,NOTABLES,LISTING2" \
		HEXTRA="--pdsi=4,TEMPLIB,E --pdso=6,TEMPLIB,E" \
	     	RTARGET="../Programming in HAL-S/189-IMU_DATA.hal" compile
then
	exit 1
fi

# "Normal" HAL/S files:
for file in ../BENCH/*.hal ../"Programming in HAL-S"/*.hal ../"HAL-S-360 Users Manual"/*.hal
do
	if ! make -s "$@" RTARGET="$file" compile
	then
		break
	fi
done
