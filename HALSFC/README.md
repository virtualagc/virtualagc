This directory contains the production/distribution version of the HAL/S compiler (HAL/S-FC) for modern computers.  It should be the only software you need (versus the full Virtual AGC source-code tree) for compiling HAL/S programs using HAL/S-FC.  The full original source code for the compiler, written in a combination of the XPL language and Basic Assembly Language, can be found in the Virtual AGC directory "yaShuttle/Source Code/PASS.REL32V0/", but is not needed for simply building or using the modern compiler.

The following resources are found in this directory:

  * The subdirectories PASS1/, FLO/, OPT/, AUX/, PASS2/, PASS3/, PASS4/, PASS1B/, OPTB/, PASS2B/, and PASS3B/ contain source code in the C language for building "phase 1", "phase 1.5", and "phase 2" of HAL/S-FC.  Once built for your computing platform, there will also be the executable files HALSFC-PASS1[.exe], HALSFC-FLO[.exe], and so on.
  * There is a Makefile for building the programs just mentioned.
  * There is a Linux/Mac BASH-script (HALSFC.sh) and a Windows script (HALSFC.bat) for easily and correctly invoking all of the compiler "phases" to compile a HAL/S program.
  * The subdirectory PASS1P/ contains a Python 3 port of "phase 1" of HAL/S-FC.  There is both both a Linux/Mac BASH-script (HALSFC-PASS1P.sh) and a Windows batch script (HALSFC-PASS1P.bat) for running it.  This Python port is not needed for a normal HAL/S compilation workflow, but it is very useful for validating the HAL/S development system via comparison of the the outputs from HALSFC-PASS1P[.sh,.bat] versus the outputs from HALSFC-PASS1P.

When compiling a HAL/S program, the compiler produces object code for the IBM AP-101S computer, AKA the General Purpose Computers (GPC) of the Space Shuttle.  Execution of such AP-101S can be emulated on a Linux, Mac, or Windows computer via TBD.


