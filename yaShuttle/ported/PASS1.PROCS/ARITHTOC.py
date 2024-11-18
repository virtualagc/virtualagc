#!/usr/bin/env python3
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   ARITHTOC.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-10-25 RSB  Ported to XPL.
"""

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ERROR    import ERROR
from HALMATTU import HALMAT_TUPLE
from SETUPVAC import SETUP_VAC

#*************************************************************************
# PROCEDURE NAME:  ARITH_TO_CHAR
# MEMBER NAME:     ARITHTOC
# INPUT PARAMETERS:
#          I                 BIT(16)
# EXTERNAL VARIABLES REFERENCED:
#          BIT_TYPE
#          CHAR_TYPE
#          CLASS_EM
#          CLASS_EV
#          INT_TYPE
#          MAT_TYPE
#          PSEUDO_TYPE
#          PTR
#          SCALAR_TYPE
#          XBTOC
# EXTERNAL VARIABLES CHANGED:
#          TEMP
# EXTERNAL PROCEDURES CALLED:
#          ERROR
#          HALMAT_TUPLE
#          SETUP_VAC
# CALLED BY:
#          SYNTHESIZE
#*************************************************************************


def ARITH_TO_CHAR(I):
    # No locals.
    g.TEMP = g.SCALAR_TYPE;
    # DO CASE PSEUDO_TYPE[PTR[I]]-MAT_TYPE;
    pt = g.PSEUDO_TYPE[g.PTR[I]] - g.MAT_TYPE
    if pt == 0:
        ERROR(d.CLASS_EM, 2);
    elif pt == 1:
        ERROR(d.CLASS_EV, 5);
    elif pt == 2:
        pass;
    elif pt == 3:
        g.TEMP = g.INT_TYPE;
    # END DO CASE
    HALMAT_TUPLE(g.XBTOC[g.TEMP - g.BIT_TYPE], 0, I, 0, 0);
    SETUP_VAC(I, g.CHAR_TYPE);
# END
