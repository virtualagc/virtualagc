#!/usr/bin/env python3
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   COPINESS.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-10-30 RSB  Ported from XPL
"""

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
import HALINCL.COMMON as h
from ERROR import ERROR

#*************************************************************************
# PROCEDURE NAME:  COPINESS
# MEMBER NAME:     COPINESS
# FUNCTION RETURN TYPE:
#          BIT(8)
# INPUT PARAMETERS:
#          L                 BIT(16)
#          R                 BIT(16)
# LOCAL DECLARATIONS:
#          T                 BIT(16)
# EXTERNAL VARIABLES REFERENCED:
#          PTR
# EXTERNAL VARIABLES CHANGED:
#          EXT_P
# CALLED BY:
#          SYNTHESIZE
#*************************************************************************


def COPINESS(L, R):
    # Local: T
    L = g.EXT_P[g.PTR[L]];
    T = g.EXT_P[g.PTR[R]];
    if T == 0:  # DO
        if L == 0: return 0;
        else:  # DO
            g.EXT_P[g.PTR[R]] = L;
            return 2;
        # END
    # END
    if L == 0: return 4;
    if L != T:  # DO
        g.EXT_P[g.PTR[R]] = L;
        return 3;
    # END
    return 0;
# END COPINESS;
