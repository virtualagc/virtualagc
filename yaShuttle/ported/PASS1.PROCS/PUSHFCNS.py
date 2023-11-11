#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   PUSHFCNS.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-10-22 RSB  Ported from XPL.
"""

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
import HALINCL.COMMON as h
from ERROR import ERROR

#*************************************************************************
# PROCEDURE NAME:  PUSH_FCN_STACK
# MEMBER NAME:     PUSHFCNS
# INPUT PARAMETERS:
#          MODE              BIT(16)
# EXTERNAL VARIABLES REFERENCED:
#          FALSE
#          CLASS_BS
#          FCN_LV_MAX
#          TRUE
# EXTERNAL VARIABLES CHANGED:
#          FCN_LV
#          FCN_ARG
#          FCN_MODE
# EXTERNAL PROCEDURES CALLED:
#          ERROR
# CALLED BY:
#          START_NORMAL_FCN
#          SYNTHESIZE
#*************************************************************************


def PUSH_FCN_STACK(MODE):
    # No locals.
    g.FCN_LV = g.FCN_LV + 1;
    if g.FCN_LV > g.FCN_LV_MAX:  # DO
        ERROR(d.CLASS_BS, 5);
        return g.FALSE;
    # END
    g.FCN_ARG[g.FCN_LV] = 0;
    g.FCN_MODE[g.FCN_LV] = MODE;
    return g.TRUE;
# END PUSH_FCN_STACK;
