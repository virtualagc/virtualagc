@echo off
:: This Windows batch script compiles a HAL/S program using the HAL/S-FC program,
:: which is assumed to be in the PATH.  

set HALS_FILE="%1"
set TEST="%2"
set PARM_STRING="%3"
set TARGET="%4"
:: No parameter 5

:: For some reason, in Windows, an empty PARM_STRING is interpreted wrong by
:: PASS1.  If it's empty, let's just set it to a safe default value.
if "%PARM_STRING%". == . \
        set PARM_STRING=TABLES

if not exist "%HALS_FILE%" (
        echo.
        echo. This script compiles a HAL/S file to an AP-101S object-code file.
        echo.
        echo.      HALSFC SOURCE.hal [ TEST [ PARMS [ TARGET ]]]
        echo.
        echo. Parameters appear in the indicated order.  Missing parameters
        echo. in the middle of the list can use \"\" as place markers for the.
        echo. defaults.  The parameters are interpreted as follows:
        echo.
        echo.      SOURCE.hal        The HAL/S source-code file.
        echo.      TEST              Perform all available validity tests.
        echo.      PARMS             Comma-separated list of compiler options.
        echo.      TARGET            Use either PFS, the default, or BFS.
        echo.
        exit /B 1
)

set PARM_LIST=%PARM_STRING:,= %

if "%TARGET%". == "BFS". (
    set PASS1=HALSFC-PASS1B
    set FLO=HALSFC-FLO
    set OPT=HALSFC-OPTB
    set AUXP=HALSFC-AUXP
    set PASS2=HALSFC-PASS2B
    set PASS3=HALSFC-PASS3B
    set PASS4=HALSFC-PASS4
    set TEMPLIB=TEMPLIBB
    set CARDS=--pdso=3,cards,E
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

%PASS1% ^
	--parm="%PARM_STRING%" ^
	--ddi=0,"%HALS_FILE%" ^
	--ddo=2,listing2.txt ^
	--pdsi=4,%TEMPLIB%,E ^
	--pdsi=5,ERRORLIB ^
	--pdsi=6,ACCESS  ^
	--pdso=6,%TEMPLIB%,E ^
	--commono=COMMON0.out ^
	--raf=B,7200,1,halmat.bin ^
	--raf=B,1560,2,litfile.bin ^
	--raf=B,3360,6,vmem.bin ^
	>pass1.rpt
if errorlevel 1 ( echo Aborted after PASS1 & exit /b 1 )

set IGNORE_LINES=(HAL/S^|FREE STRING AREA^|NUMBER OF FILE 6^|PROCESSING RATE^|CPU TIME FOR^|TODAY IS^|COMPOOL.*VERSION)
if not "%TEST%. == . (
        echo ======================================================
        ( egrep -V >NUL 2>NUL && diff -v >NUL 2>NUL ) && \
        echo off || echo Utilities egrep or diff not available && exit 1
        ( HAL_S_FC.py %PARM_LIST% --hal="%HALS_FILE%" >pass1p.rpt ) && \
        echo PASS1 cross-comparison test ... || exit 1
        egrep -v "%IGNORE_LINES%" pass1.rpt >pass1A.rpt
        egrep -v "%IGNORE_LINES%" pass1p.rpt >pass1pA.rpt
        diff -q -s pass1A.rpt pass1pA.rpt
        diff -s FILE1.bin halmat.bin
        if not "%PARM_LIST%." == "%PARM_LIST:LISTING2=%." \
               diff -q -s LISTING2.txt listing2.txt
        echo ======================================================
)

%FLO% ^
	--commoni=COMMON0.out ^
	--commono=COMMON1.out ^
	--raf=B,7200,1,halmat.bin ^
	--raf=B,1560,2,litfile.bin ^
	--raf=B,3360,6,vmem.bin ^
	>flo.rpt
if errorlevel 1 ( echo Aborted after FLO & exit /b 1 )


%OPT% ^
	--commoni=COMMON1.out ^
	--commono=COMMON2.out ^
	--raf=B,7200,1,halmat.bin ^
	--raf=B,1560,2,litfile.bin ^
	--raf=B,7200,4,optmat.bin ^
	--raf=B,3360,6,vmem.bin ^
	>opt.rpt
if errorlevel 1 ( echo Aborted after OPT & exit /b 1 )

%AUXP% ^
	--commoni=COMMON2.out ^
	--commono=COMMON3.out ^
	--raf=B,7200,1,auxmat.bin ^
	--raf=B,1560,2,litfile.bin ^
	--raf=B,7200,4,optmat.bin ^
	--raf=B,3360,6,vmem.bin ^
	>auxp.rpt
if errorlevel 1 ( echo Aborted after AUXP & exit /b 1 )


%PASS2% ^
	%CARDS% ^
	--ddo=4,deck.bin,E ^
	--pdsi=5,ERRORLIB ^
	--ddo=7,extra.txt ^
	--commoni=COMMON3.out ^
	--commono=COMMON4.out ^
	--raf=B,7200,1,auxmat.bin ^
	--raf=B,1560,2,litfile.bin ^
	--raf=B,1600,3,objcode.bin ^
	--raf=B,7200,4,optmat.bin ^
	--raf=B,3360,6,vmem.bin ^
	>pass2.rpt
if errorlevel 1 ( echo Aborted after PASS2 & exit /b 1 )


:: PASS3 and PASS4 aren't ready for use yet.

echo Compilation successful!
