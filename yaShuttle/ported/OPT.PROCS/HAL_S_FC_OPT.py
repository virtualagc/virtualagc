#!/usr/bin/env python3
'''
Access:     Public Domain, no restrictions believed to exist.
Filename:   HAL_S_FC_OPT.py
Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-12-02 RSB  Ported from OPT.PROCS/##DRIVER.XPL
'''

#####################################################################
# Every port from ##DRIVER.xpl needs the following, in order for all
# of them to use the same xplBuiltins.py and HALINCL/ without conflict.
import os
import pathlib
import shutil
scriptFolder = os.path.dirname(__file__)
scriptParentFolder = str(pathlib.Path(scriptFolder).parent.absolute())
shutil.copyfile(scriptParentFolder + "/xplBuiltins.py", \
                scriptFolder + "/xplBuiltins.py")
shutil.rmtree(scriptFolder + "/HALINCL", ignore_errors=True)
shutil.copytree(scriptParentFolder + "/HALINCL", \
                scriptFolder + "/HALINCL")
#####################################################################

from xplBuiltins import *
from HALINCL.SPACELIB import *
import g
import HALINCL.COMMON as h
from DISASTER import DISASTER
from INITIALI import INITIALISE
from NEWHALMA import NEW_HALMAT_BLOCK
from OPTIMISE import OPTIMISE
from PREPAREH import PREPARE_HALMAT
from PREPASS  import PREPASS
from PRINTDAT import PRINT_DATE_AND_TIME
from PRINTSUM import PRINTSUMMARY
from PUTHALMA import PUT_HALMAT_BLOCK
from ZAPTABLE import ZAP_TABLES

#***********************************************************************
# PROCEDURE NAME:  MAIN PROGRAM
# MEMBER NAME:     ##DRIVER
# PURPOSE:         THE DRIVER PROGRAM FOR A PHASE OF THE COMPILER.
#                  THIS MEMBER IS THE MAIN PROGRAM, THE OTHER MEMBERS
#                  SHOULD BE CHECKED FOR HEADER INFORMATION.
# LOCAL DECLARATIONS:
# EXTERNAL VARIABLES REFERENCED:
# EXTERNAL VARIABLES CHANGED:
# CALLED BY:
#***********************************************************************

# START OF MAIN PROGRAM
CLOCK = MONITOR(18);
INITIALISE();
OUTPUT(1, '1');
PRINT_DATE_AND_TIME('   HAL/S OPTIMIZER  --  VERSION OF ', \
    g.DATE_OF_GENERATION, g.TIME_OF_GENERATION);
OUTPUT(0, '');
PRINT_DATE_AND_TIME('HAL/S OPTIMIZER ENTERED ', DATE(), TIME());
OUTPUT(0, '');
g.CLOCK[1] = MONITOR(18);
while g.OPTIMISING:
   NEW_HALMAT_BLOCK();
   PREPASS();
   PREPARE_HALMAT(1);  # PHASE 2 OPTIMISE
   OPTIMISE();
   ZAP_TABLES(1);
   PUT_HALMAT_BLOCK();
# END of while;
g.CLOCK[2] = MONITOR(18);
h.COMM[19] = g.CROSS_BLOCK_OPERATORS[1];
if g.LITCHANGE: FILE(g.LITFILE, g.CURLBLK, g.LIT_PG);
if g.STATISTICS: PRINTSUMMARY();
RECORD_FREE(g.COMMONSE_LIST);
RECORD_FREE(g.SYM_SHRINK);
RECORD_FREE(g.PAR_SYM);
RECORD_FREE(g.VAL_TABLE);
RECORD_FREE(g.OBPS);
RECORD_FREE(g.ZAPIT);
RECORD_FREE(g.STRUCTp);
RECORD_FREE(g.LEVEL_STACK_VARS);
OUTPUT(0, '');
PRINT_DATE_AND_TIME('END OF HAL/S OPTIMIZER ', DATE(), TIME());
OUTPUT(0, '');
if not (g.ELEGANT_BUGOUT & 1): RECORD_LINK();

DISASTER()

