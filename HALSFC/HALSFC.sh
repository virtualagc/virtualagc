#!/bin/bash
# This Linux/Mac script compiles a HAL/S program using the HAL/S-FC program,
# which is assumed to be in the PATH.  It has the following parameters:
#
#	The path to the HAL/S source-code file.
#
#	The comma-delimited PARM_STRING of HAL/S-FC options, quoted if it contains 
#	spaces.  For example, "SRN,LISTING2,X6,LIST,ADDRS,HALMAT,NOTABLES,DECK".
#
#	"PFS" (default) or "BFS"

HALS_FILE="$1"
PARM_STRING="$2"
TARGET="$3"

if [[ "$TARGET" == "BFS" ]]
then
	PASS1=HALSFC-PASS1B
	FLO=HALSFC-FLO
	OPT=HALSFC-OPTB
	AUXP=HALSFC-AUXP
	PASS2=HALSFC-PASS2B
	PASS3=HALSFC-PASS3B
	PASS4=HALSFC-PASS4
	TEMPLIB=TEMPLIBB
	CARDS--pdso=3,cards,E
else
	PASS1=HALSFC-PASS1
	FLO=HALSFC-FLO
	OPT=HALSFC-OPT
	AUXP=HALSFC-AUXP
	PASS2=HALSFC-PASS2
	PASS3=HALSFC-PASS3
	PASS4=HALSFC-PASS4
	TEMPLIB=TEMPLIB
	CARDS=--ddo=3,cards.bin,E
fi

$PASS1 \
	--parm="$PARM_STRING" \
	--ddi=0,"$HALS_FILE" \
	--ddo=2,listing2.txt \
	--pdsi=4,$TEMPLIB,E \
	--pdsi=5,ERRORLIB \
	--pdsi=6,ACCESS  \
	--pdso=6,$TEMPLIB,E \
	--commono=COMMON0.out \
	--raf=B,7200,1,halmat.bin \
	--raf=B,1560,2,litfile.bin \
	--raf=B,3360,6,vmem.bin \
	>pass1.rpt
if [[ $? != 0 ]] ; then echo "Aborted after PASS1" ; exit 1 ; fi

$FLO \
	--commoni=COMMON0.out \
	--commono=COMMON1.out \
	--raf=B,7200,1,halmat.bin \
	--raf=B,1560,2,litfile.bin \
	--raf=B,3360,6,vmem.bin \
	>flo.rpt
if [[ $? != 0 ]] ; then echo "Aborted after FLO" ; exit 1 ; fi

$OPT \
	--commoni=COMMON1.out \
	--commono=COMMON2.out \
	--raf=B,7200,1,halmat.bin \
	--raf=B,1560,2,litfile.bin \
	--raf=B,7200,4,optmat.bin \
	--raf=B,3360,6,vmem.bin \
	>opt.rpt
if [[ $? != 0 ]] ; then echo "Aborted after OPT" ; exit 1 ; fi

$AUXP \
	--commoni=COMMON2.out \
	--commono=COMMON3.out \
	--raf=B,7200,1,auxmat.bin \
	--raf=B,1560,2,litfile.bin \
	--raf=B,7200,4,optmat.bin \
	--raf=B,3360,6,vmem.bin \
	>auxp.rpt
if [[ $? != 0 ]] ; then echo "Aborted after AUXP" ; exit 1 ; fi

$PASS2 \
	$CARDS \
	--ddo=4,deck.bin,E \
	--pdsi=5,ERRORLIB \
	--ddo=7,extra.txt \
	--commoni=COMMON3.out \
	--commono=COMMON4.out \
	--raf=B,7200,1,auxmat.bin \
	--raf=B,1560,2,litfile.bin \
	--raf=B,1600,3,objcode.bin \
	--raf=B,7200,4,optmat.bin \
	--raf=B,3360,6,vmem.bin \
	>pass2.rpt
if [[ $? != 0 ]] ; then echo "Aborted after PASS2" ; exit 1 ; fi

# PASS3 and PASS4 aren't ready for use yet.

echo "Compilation successful!"
