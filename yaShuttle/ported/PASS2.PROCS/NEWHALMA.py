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
from POPNUM import POPNUM

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
    for I in range(0, g.ATOMp_LIM + 1):
        g.VAC_VAL[I] = g.FALSE;
    #END
    
    # In XPL, what we had here was 
    #        OPR(0)=FILE(CODEFILE,CURCBLK);
    # What this did (I think!) was to read an entire HALMAT block from
    # the file into OPR.  (That it indicates OPR(0), I think, is merely
    # to indicate the starting address of the OPR array in memory.)
    # OPR(n) is an alias for FOR_ATOMS(n).CONST_ATOMS, which is a FIXED
    # (32-bit) value.  So OPR() is in essence an array of 1800 4-byte 
    # values; the act of reading the record is a matter of reading
    # 7200 bytes and converting them into 1800 32-bit integers.
    newBlockBytes = bytearray([0] * (4 * 7200))
    FILE(newBlockBytes, g.CODEFILE, g.CURCBLK);
    j = 0
    for i in range(1800):
        k = newBlockBytes[j] << 24
        j += 1
        k |= newBlockBytes[j] << 16
        j += 1
        k |= newBlockBytes[j] << 8
        j += 1
        k |= newBlockBytes[j]
        j += 1
        OPR(i, k)
    
    g.CURCBLK=g.CURCBLK+1;
    g.CTR=0;
    g.OFF_PAGE_LAST = g.OFF_PAGE_NEXT;
    g.OFF_PAGE_NEXT = (g.OFF_PAGE_NEXT + 1) & 1;
    g.OFF_PAGE_CTR[g.OFF_PAGE_NEXT] = 0;
    g.NUMOP = POPNUM(0);
# END NEW_HALMAT_BLOCK;
