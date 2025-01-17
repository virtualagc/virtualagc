@echo off
REM Note: This batch file was auto-converted from the BASH shell script 
REM simulateModuleII, and then manually tweaked.  How correct it is remains
REM to be seen.

REM This script can be used in Windows to perform a digital simulation
REM of a single logical module, or portion thereof.  It should be executed from
REM the folder containing the schematic file (module.kicad_sch) and a 
REM user-created partial-testbench file called tb.v.
REM
REM Usage:
REM       simulateModule MODULENAME [NETLISTFILE]
REM where MODULENAME is one of the names of Block II AGC logic modules:
REM A1, A2, A3, ..., A24.  The optional parameter can give the name of a netlist
REM file.  If it is not present, then KiCad v7 or later is required so that
REM we can generate the netlist file ourself from the command line.

SET PYTHONPATH=%PATH%

REM First, parse the command line and perform sanity checks.

IF "%~1" == "" (
  echo "No module number (A1, A2, ..., A24) given"
  exit "1"
) ELSE (
  SET "modulenum=%~1"
)

REM Does the schematic exist?
IF exist "module.kicad_sch" (
  SET "schematic=module.kicad_sch"
) ELSE (
  IF exist "module.sch" (
    SET "schematic=module.sch"
  ) ELSE (
    echo "Cannot" "find" "either" "module.sch" "or" "module.kicad_sch"
    exit "1"
  )
)

REM Does the minimal test bench file exist?
IF not exist "tb.v" (
  echo "cannot" "find" "tb.v"
  exit "1"
)

REM Workflow step #1: Should have been done before ever running this script!

REM Workflow step #2.

IF "%~2" == "" (
  SET "netlist=module.net"
  DEL  "module.net" >NULL 2>&1
  kicad-cli "sch" "export" "netlist" "--output" "module.net" "--format" "orcadpcb2" "module.kicad_sch"
) ELSE (
  SET "netlist=%~2"
)
IF not exist "%netlist%" (
  echo "Cannot" "find\generate" "netlist" "file" "%netlist%"
  exit "1"
)

REM Workflow step #3

DEL  "empty.init" >NUL 2>&1
touch "empty.init"
python -m dumbVerilog "%modulenum%" "%netlist%" "pins.txt" "20" "empty.init" "%schematic%" >module.v
python -m dumbInitialization <module.v
python -m dumbVerilog "%modulenum%" "%netlist%" "pins.txt" "20" "%modulenum%.init" "%schematic%" >module.v

REM Workflow step #4

python -m dumbTestbench <module.v >module_tb.v

REM Workflow step #5: None needed for stand-alone logic modules.

REM Workflow step #6

iverilog "-o" "module.vvp" "module_tb.v" "module.v"

REM Workflow step #7

vvp "module.vvp" "-fst"

REM Workflow step #8

gtkwave "module.fst"