#!/bin/bash
# The is a sort of regression test for the compiler HAL/S-FC, in which 
# lots of sample HAL/S files are compiled using HAL/S-FC, with an abort 
# occurring on the first failure.  I tried doing this entirely in the Makefile,
# but since the names of the folders containing the HAL/S files contain spaces,
# there was no reasonable way to make it work.  All of the parameters
# normally accepted by the Makefile (XEXTRA, EXTRA, HEXTRA, PEXTRA, REXTRA, 
# CC, etc.) can be used on the regression.sh command line. 

unset BFS
for arg in "$@"
do 
	if [[ "$arg" == BFS* ]]
	then
		BFS=yes
		break
	fi
done

# HAL/S files that create templates in the template library need to be built
# first, so that the other HAL/S files can use `D INCLUDE TEMPLATE ...`.
for file in 	"../Programming in HAL-S/189-IMU_DATA.hal" \
		"../Programming in HAL-S/269-PROCESS_CONTROL.hal" \
		"../Programming in HAL-S/264-TQE.hal"
do
	if ! make -s 	"$@" \
			PEXTRA="--templib" \
			PARM_STRING="TEMPLATE,NOTABLES,LISTING2" \
			HEXTRA="--pdsi=4,TEMPLIB,E --pdso=6,TEMPLIB,E" \
			RTARGET="$file" \
			compile
	then
		exit 1
	fi
done

# Now do all the rest of the HAL/S files.  (The files we already did above will
# be redone, albeit with different compiler options, but so what?)  Note that
# DEMO.hal is built with a different PARM_STRING, so as to agree with what's
# in the book it came from.
for file in	../BENCH/*.hal \
		../"Programming in HAL-S"/*.hal \
		../"HAL-S-360 Users Manual"/*.hal
do
	if [[ "$BFS" != "" ]]
	then
		# The following files all contain TASKs, which seems to be the
		# PASS2 fails on all of them, entering an infinite loop during
		# initialization.  Skip them for now.
		if [[ "$file" == *219*        || \
		      "$file" == *22*         || \
		      "$file" == *23*         || \
		      "$file" == *241*        || \
		      "$file" == *242*        || \
		      "$file" == *260-TEST6*  || \
		      "$file" == *268*        ]]
		then
			echo "Skipping $file due to TASK --------------------"
			continue
		fi
	fi
	if [[ "$file" == *"DEMO.hal" ]]
	then
		PARM=PARM_STRING="LISTING2,LIST,NOADDRS,NOTABLES,TRACE"
	else
		unset PARM
	fi
	if ! make -s "$@" RTARGET="$file" $PARM compile
	then
		exit 1
	fi
done
