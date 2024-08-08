#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   FINDER.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-10-28 RSB  Ported from XPL.
"""

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
import HALINCL.COMMON as h
from ERROR import ERROR

#*************************************************************************
# PROCEDURE NAME:  FINDER
# MEMBER NAME:     FINDER
# FUNCTION RETURN TYPE:
#          BIT(8)
# INPUT PARAMETERS:
#          FILENO            BIT(16)
#          NAME              CHARACTER;
#          START             BIT(16)
# LOCAL DECLARATIONS:
#          FILENUM(2)        FIXED
#          FILENODD(2)       BIT(8)
#          I                 BIT(16)
#          MAXLIBFILES       MACRO
#          RETCODE           BIT(16)
# EXTERNAL VARIABLES REFERENCED:
#          TRUE
#          FALSE
# EXTERNAL VARIABLES CHANGED:
#          INCLUDE_FILE#
# CALLED BY:
#          STREAM
#          EMIT_EXTERNAL
#*************************************************************************

MAXLIBFILES = 2
# SPECIFIES OUTPUT(8), INPUT(4), AND OUTPUT(6) ENTRIES
FILENUM = (0x80000008, 0x4, 0x80000006)
# TRUE IF DD STATEMENT MISSING
# In other words, PDS files that can actually be opened whould be g.FALSE in the 
# following list.
FILENODD = [g.FALSE] * (MAXLIBFILES + 1) 

# This function returns g.FALSE upon success, g.TRUE upon failure.
def FINDER(FILENO, NAME, START):
    # Locals: I, RETCODE, MAXLIBFILES, FILENUM, FILENODD
    global MAXLIBFILES, FILENUM, FILENODD
    
    for I in range(START, MAXLIBFILES + 1):
        if not FILENODD[I]: #DO
            MONITOR(8, FILENO, FILENUM[I]); # SET FILENO WITH NEW DDNAME
            RETCODE = MONITOR(2, FILENO, NAME); # FIND THE MEMBER
            if RETCODE == 0: #DO
                g.INCLUDE_FILEp = FILENUM[I];
                return g.FALSE;
            #END
            FILENODD[I] = SHR(RETCODE, 1) & 1;
        #END
    #END
    return g.TRUE;
# END FINDER;
