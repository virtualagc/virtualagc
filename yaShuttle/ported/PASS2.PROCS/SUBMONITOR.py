#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   HAL_S_FC_PASS2.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Language:   XPL.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-11-16 RSB  Began adapting PASS2.PROCS/##DRIVER.xpl.
"""

from xplBuiltins import *
import g
import HALINCL.COMMON   as h
from HALINCL.SPACELIB import *
from PRINTSUM import PRINTSUMMARY

def SUBMONITOR():
    PRINTSUMMARY();
    RECORD_FREE(g.LAB_LOC);
    RECORD_FREE(g.STMTNUM);
    RECORD_FREE(g.PAGE_FIX);
    RECORD_FREE(g.P2SYMS);
    if pfs: 
        # BRANCH CONDENSING
        RECORD_FREE(g.BRANCH_TBL);
        # BASE REG ALLOCATION (ADCON)
        RECORD_FREE(g.BASE_REGS);
    if RECORD_ALLOC(g.DNS) > 0:
        RECORD_FREE(g.DNS);
    #MAKE SURE MAX_SEVERITY IS SET CORRECTLY IN CASE A SEVERITY 1
    #ERROR WAS ISSUED IN TERMINATE OR PRINTSUMMARY.
    if (g.MAX_SEVERITY == 0) and g.SEVERITY_ONE: 
        g.MAX_SEVERITY = 1;
    if g.MAX_SEVERITY == 0: #DO
        if (OPTION_BITS & 0x800) != 0: #DO
            RECORD_LINK();
        #END
    #END
    sys.exit(SHL(g.MAX_SEVERITY,2) | h.COMMON_RETURN_CODE)
