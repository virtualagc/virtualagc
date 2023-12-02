#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   STACKPTR.py
   Purpose:    Part of the HAL/S-FC compiler's HALMAT optimization
               process.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-11-21 RSB  Ported from XPL
"""

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ERRORS import ERRORS

#*************************************************************************
# PROCEDURE NAME:  STACK_PTR
# MEMBER NAME:     STACKPTR
# INPUT PARAMETERS:
#          PTR               FIXED
#          LEVEL             BIT(16)
# EXTERNAL VARIABLES REFERENCED:
#          CLASS_BI
# EXTERNAL VARIABLES CHANGED:
#          EXP_VARS
#          EXP_PTRS
#          PTR_INX
# EXTERNAL PROCEDURES CALLED:
#          ERRORS
# CALLED BY:
#          FORMAT_EXP_VARS_CELL
#          FORMAT_PF_INV_CELL
#          FORMAT_VAR_REF_CELL
#*************************************************************************

# ADDS VMEM CELL PTR TO STACK


def STACK_PTR(PTR, LEVEL):
    # No locals.
    g.PTR_INX = g.PTR_INX + 1;
    if g.PTR_INX > 400:
        ERRORS(d.CLASS_BI, 219);
    g.EXP_PTRS[g.PTR_INX] = PTR;
    g.EXP_VARS[g.PTR_INX] = LEVEL;
# END STACK_PTR;
