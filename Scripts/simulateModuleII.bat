@echo off

# This script can be used in Windows to perform a digital simulation
# of a single logical module, or portion thereof.  It should be executed from
# the folder containing the schematic file (module.kicad_sch) and a 
# user-created partial-testbench file called tb.v.
#
# Usage:
#       simulateModule MODULENAME [NETLISTFILE]
# where MODULENAME is one of the names of Block II AGC logic modules:
# A1, A2, A3, ..., A24.  The optional parameter can give the name of a netlist
# file.  If it is not present, then KiCad v7 or later is required so that
# we can generate the netlist file ourself from the command line.

# First, parse the command line and perform sanity checks.

IF "%~1" "=" "" (
  echo "No module number (A1, A2, ..., A24) given"
  exit "1"
) ELSE (
  SET "modulenum=%~1"
)

# Does the schematic exist?
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

# Does the minimal test bench file exist?
IF not exist "tb.v" (
  echo "cannot" "find" "tb.v"
  exit "1"
)

# Workflow step #1: Should have been done before ever running this script!

# Workflow step #2.

IF "%~2" "=" "" (
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

# Workflow step #3

DEL  "empty.init" >NUL 2>&1
touch "empty.init"
python -m dumbVerilog "%modulenum%" "%netlist%" "pins.txt" "20" "empty.init" "%schematic%" >module.v
python -m dumbInitialization <module.v
python -m dumbVerilog "%modulenum%" "%netlist%" "pins.txt" "20" "%modulenum%.init" "%schematic%" >module.v

# Workflow step #4

python -m dumbTestbench <module.v >module_tb.v

# Workflow step #5: None needed for stand-alone logic modules.

# Workflow step #6

iverilog "-o" "module.vvp" "module_tb.v" "module.v"

# Workflow step #7

vvp "module.vvp" "-fst"

# Workflow step #8

gtkwave "module.fst"