#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   HAL_S_FC_PASS2.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
               It is PASS2's main program.
   Language:   XPL.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-11-16 RSB  Began adapting PASS2.PROCS/##DRIVER.xpl.
"""

from xplBuiltins import *
import g
from DECODEPO import DECODEPOP
from GENERATE import GENERATE
from NEWHALMA import NEW_HALMAT_BLOCK
from OPTIMISE import OPTIMISE
from TERMINAT import TERMINATE

from SUBMONITOR    import SUBMONITOR

def whileGENERATING(srcerr = False):
    if srcerr:
        g.CLASS = 9
    
    while g.GENERATING or srcerr:
        if not srcerr:
            NEW_HALMAT_BLOCK();
            OPTIMISE(1);
            DECODEPOP(g.CTR);
        srcerr = False # RESTART:
        GENERATE();
    g.CLOCK[2] = MONITOR(18);
    #: SEVERITY 1 ERRORS TREATED AS WARNING UNTIL NOW
    if (g.MAX_SEVERITY == 0) and g.SEVERITY_ONE: 
        g.MAX_SEVERITY = 1;
    TERMINATE();
    SUBMONITOR() # Does not return.
