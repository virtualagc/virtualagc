:: This Windows batch script compiles a HAL/S program using the HAL/S-FC program,
:: which is assumed to be in the PATH.  It has the following parameters:
::
::	The path to the HAL/S source-code file.
::
::	The comma-delimited PARM_STRING of HAL/S-FC options, quoted if it contains 
::	spaces.  For example, "SRN,LISTING2,X6,LIST,ADDRS,HALMAT,NOTABLES,DECK".
::
::	"PFS" (default) or "BFS"

set HALS_FILE="%1"
set PARM_STRING="%1"
set TARGET="%1"

if "%TARGET%". == "BFS". (
    set PASS1=HALSFC-PASS1B
    set FLO=HALSFC-FLO
    set OPT=HALSFC-OPTB
    set AUXP=HALSFC-AUXP
    set PASS2=HALSFC-PASS2B
    set PASS3=HALSFC-PASS3B
    set PASS4=HALSFC-PASS4
    set TEMPLIB=TEMPLIBB
    set CARDS--pdso=3,cards,E
) else (
    set PASS1=HALSFC-PASS1
    set FLO=HALSFC-FLO
    set OPT=HALSFC-OPT
    set AUXP=HALSFC-AUXP
    set PASS2=HALSFC-PASS2
    set PASS3=HALSFC-PASS3
    set PASS4=HALSFC-PASS4
    set TEMPLIB=TEMPLIB
    set CARDS=--ddo=3,cards.bin,E
)

%PASS1% \
	--parm="%PARM_STRING%" \
	--ddi=0,"%HALS_FILE%" \
	--ddo=2,listing2.txt \
	--pdsi=4,%TEMPLIB%,E \
	--pdsi=5,ERRORLIB \
	--pdsi=6,ACCESS  \
	--pdso=6,%TEMPLIB%,E \
	--commono=COMMON0.out \
	--raf=B,7200,1,halmat.bin \
	--raf=B,1560,2,litfile.bin \
	--raf=B,3360,6,vmem.bin \
	>pass1.rpt
if errorlevel 1 ( echo "Aborted after PASS1" & exit 1 )

%FLO% \
	--commoni=COMMON0.out \
	--commono=COMMON1.out \
	--raf=B,7200,1,halmat.bin \
	--raf=B,1560,2,litfile.bin \
	--raf=B,3360,6,vmem.bin \
	>flo.rpt
if errorlevel 1 ( echo "Aborted after FLO" & exit 1 )


%OPT% \
	--commoni=COMMON1.out \
	--commono=COMMON2.out \
	--raf=B,7200,1,halmat.bin \
	--raf=B,1560,2,litfile.bin \
	--raf=B,7200,4,optmat.bin \
	--raf=B,3360,6,vmem.bin \
	>opt.rpt
if errorlevel 1 ( echo "Aborted after OPT" & exit 1 )

%AUXP% \
	--commoni=COMMON2.out \
	--commono=COMMON3.out \
	--raf=B,7200,1,auxmat.bin \
	--raf=B,1560,2,litfile.bin \
	--raf=B,7200,4,optmat.bin \
	--raf=B,3360,6,vmem.bin \
	>aux.rpt
if errorlevel 1 ( echo "Aborted after AUXP" & exit 1 )


%PASS2% \
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
if errorlevel 1 ( echo "Aborted after PASS2" & exit 1 )


:: PASS3 and PASS4 aren't ready for use yet.

echo "Compilation successful!"
