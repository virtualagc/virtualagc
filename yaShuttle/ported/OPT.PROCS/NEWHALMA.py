#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   NEWHALMA.py
   Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-12-05 RSB  Ported from XPL
"""

from xplBuiltins import *
import g
import HALINCL.COMMON as h

#*************************************************************************
# PROCEDURE NAME:  NEW_HALMAT_BLOCK
# MEMBER NAME:     NEWHALMA
# EXTERNAL VARIABLES REFERENCED:
#          BLOCK_END
#          CODEFILE
#          PULL_LOOP_HEAD
#          STACKED_BLOCK#
#          XPULL_LOOP_HEAD
#          XPXRC
#          XSTACKED_BLOCK#
# EXTERNAL VARIABLES CHANGED:
#          BLOCK_TOP
#          BLOCK#
#          CTR
#          CURCBLK
#          LAST_SMRK
#          LAST_ZAP
#          LEVEL_STACK_VARS
#          NUMOP
#          OPR
#          XREC_PTR
#*************************************************************************
# ROUTINE TO GET A NEW BLOCK OF HALMAT


def NEW_HALMAT_BLOCK():
    # No locals.
    OPR = FILE(g.CODEFILE, g.CURCBLK);
    g.CURCBLK = g.CURCBLK + 1;
    g.CTR = 0;
    g.LAST_ZAP = 0;
    g.LAST_SMRK = 0;
    STACKED_BLOCKp[0] = 1
    BLOCKp = 1
    g.BLOCK_TOP = 1;
    if (OPR & 0xFFF1) == g.XPXRC:
        g.XREC_PTR = SHR(g.OPR[1], 16);
    else:
        g.XREC_PTR = g.BLOCK_END;
    g.PULL_LOOP_HEAD(0) = -1;
    g.NUMOP = SHR(OPR, 16) & 0xFF;
# END NEW_HALMAT_BLOCK;
