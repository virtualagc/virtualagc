#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   NEWHALMA.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-11-17 RSB  Ported from XPL
"""

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
import HALINCL.COMMON as h
from ERRORS import ERRORS

#*************************************************************************
# PROCEDURE NAME:  NEW_HALMAT_BLOCK
# MEMBER NAME:     NEWHALMA
# EXTERNAL VARIABLES REFERENCED:
#          CODEFILE
#          CONST_ATOMS
# EXTERNAL VARIABLES CHANGED:
#          CTR
#          CURCBLK
#          FOR_ATOMS
#          NUMOP
#          OFF_PAGE_CTR
#          OFF_PAGE_LAST
#          OFF_PAGE_NEXT
# EXTERNAL PROCEDURES CALLED:
#          POPNUM
# CALLED BY:
#          GENERATE
#*************************************************************************

# ROUTINE TO GET A NEW BLOCK OF HALMAT

def NEW_HALMAT_BLOCK():
    # Local I.
    for I  in range(0, g.ATOMp_LIM + 1):
        g.VAC_VAL[I] = g.FALSE;
    #END
    g.OPR(0)=FILE(g.CODEFILE,g.CURCBLK);
    g.CURCBLK=g.CURCBLK+1;
    g.CTR=0;
    g.OFF_PAGE_LAST = g.OFF_PAGE_NEXT;
    g.OFF_PAGE_NEXT = g.OFF_PAGE_NEXT + 1 & 1;
    g.OFF_PAGE_CTR[g.OFF_PAGE_NEXT] = 0;
    g.NUMOP = POPNUM(0);
# END NEW_HALMAT_BLOCK;
