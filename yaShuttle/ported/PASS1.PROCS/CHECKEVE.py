#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   CHECKEVE.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-10-24 RSB  Ported from XPL
"""

import g
from CHECKARR import CHECK_ARRAYNESS
from HALMATF2 import HALMAT_FIX_POPTAG

#*************************************************************************
# PROCEDURE NAME:  CHECK_EVENT_EXP
# MEMBER NAME:     CHECKEVE
# INPUT PARAMETERS:
#          LOC               BIT(16)
# EXTERNAL VARIABLES REFERENCED:
#          INX
#          LOC_P
#          PSEUDO_FORM
#          PTR
#          XVAC
# EXTERNAL PROCEDURES CALLED:
#          HALMAT_FIX_POPTAG
#          CHECK_ARRAYNESS
# CALLED BY:
#          SYNTHESIZE
#*************************************************************************


def CHECK_EVENT_EXP(LOC):
    # Local: LOC.
    if g.PSEUDO_FORM[g.PTR[LOC]] == g.XVAC:
        HALMAT_FIX_POPTAG(g.LOC_P[g.PTR[LOC]], 5);
    return CHECK_ARRAYNESS() or (g.INX[g.PTR[LOC]] == 0);
# END CHECK_EVENT_EXP;
