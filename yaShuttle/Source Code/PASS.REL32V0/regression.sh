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

# HAL/S files that create templates in the template library need to be built
# first, so that the other HAL/S files can have access to those templates:
if ! make -s 	PEXTRA="--templib" PARM_STRING="TEMPLATE,NOTABLES,LISTING2" \
		HEXTRA="--pdsi=4,TEMPLIB,E --pdso=6,TEMPLIB,E" \
	     	RTARGET="../Programming in HAL-S/189-IMU_DATA.hal" compile
then
	exit 1
fi
if ! make -s 	PEXTRA="--templib" PARM_STRING="TEMPLATE,NOTABLES,LISTING2" \
		HEXTRA="--pdsi=4,TEMPLIB,E --pdso=6,TEMPLIB,E" \
	     	RTARGET="../Programming in HAL-S/269-PROCESS_CONTROL.hal" compile
then
	exit 1
fi
if ! make -s 	PEXTRA="--templib" PARM_STRING="TEMPLATE,NOTABLES,LISTING2" \
		HEXTRA="--pdsi=4,TEMPLIB,E --pdso=6,TEMPLIB,E" \
	     	RTARGET="../Programming in HAL-S/264-TQE.hal" \
	     	DEXTRA=--ignore-space-change \
	     	compile
then
	exit 1
fi

# All the rest of the HAL/S files, whose build order doesn't matter:
for file in	../BENCH/*.hal \
		../"Programming in HAL-S"/*.hal \
		../"HAL-S-360 Users Manual"/*.hal
do
	unset NOCHECK1
	unset NOCHECK2
	unset NOCHECK3
	unset DEXTRA
	# Some special cases of checks that I know don't work as-is.  These
	# all involve columnar alignment in the compilier reports for source
	# files which import templates.
	if [[	"$file" == *"260-TEST5.hal"		|| \
		"$file" == *"260-TEST6.hal"		|| \
		"$file" == *"262-TEST7.hal"		|| \
		"$file" == *"264-INITIALIZE.hal"	|| \
		"$file" == *"264-TQE.hal"		|| \
		"$file" == *"265-ENQUEUE.hal"		|| \
		"$file" == *"268-INT_HANDLER.hal"	|| \
		"$file" == *"269-STALL.hal"		]]
	then
		DEXTRA=DEXTRA=--ignore-space-change
	fi
	if ! make -s "$@" RTARGET="$file" $NOCHECK1 $NOCHECK2 $NOCHECK3 $DEXTRA compile
	then
		exit 1
	fi
done
