#!/bin/bash
# This script is for copying the files *.c/*.h/Makefile from all of the 
# subdirectories like PASS1.PROCS/PASS1/ into the corresponding directories
# in HALSRC/.

D=~/git/virtualagc/HALSFC
cp -a PASS1.PROCS/PASS1/{Makefile,*.c,*.h} "$D"/PASS1/
cp -a PASS1.PROCS/PASS1B/{Makefile,*.c,*.h} "$D"/PASS1B/
cp -a FLO.PROCS/FLO/{Makefile,*.c,*.h} "$D"/FLO/
cp -a OPT.PROCS/OPT/{Makefile,*.c,*.h} "$D"/OPT/
cp -a OPT.PROCS/OPTB/{Makefile,*.c,*.h} "$D"/OPTB/
cp -a AUX_PROCS/AUX/{Makefile,*.c,*.h} "$D"/AUXP/
cp -a PASS2.PROCS/PASS2/{Makefile,*.c,*.h} "$D"/PASS2/
cp -a PASS2.PROCS/PASS2B/{Makefile,*.c,*.h} "$D"/PASS2B/
cp -a PASS3.PROCS/PASS3/{Makefile,*.c,*.h} "$D"/PASS3/
cp -a PASS3.PROCS/PASS3B/{Makefile,*.c,*.h} "$D"/PASS3B/
cp -a PASS4.PROCS/PASS4/{Makefile,*.c,*.h} "$D"/PASS4/
