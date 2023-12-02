#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   POPNUM.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-11-27 RSB  Ported from XPL
"""

from xplBuiltins import *
import g

#*************************************************************************
# PROCEDURE NAME:  POPNUM
# MEMBER NAME:     POPNUM
# INPUT PARAMETERS:
#          CTR               BIT(16)
# EXTERNAL VARIABLES REFERENCED:
#          CONST_ATOMS
#          FOR_ATOMS
#          OPR
# CALLED BY:
#          DECODEPOP
#          GENERATE
#          NEW_HALMAT_BLOCK
#          OPTIMISE
#*************************************************************************


def POPNUM(CTR):
    # No locals.
    return SHR(g.OPR(CTR), 16) & 0xFF;
# END POPNUM;
