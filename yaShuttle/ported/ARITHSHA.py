#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   ARITHSHA.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-10-24 RSB  Ported from XPL
"""

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
import HALINCL.COMMON as h
from ERROR    import ERROR
from MAKEFIXE import MAKE_FIXED_LIT

#*************************************************************************
# PROCEDURE NAME:  ARITH_SHAPER_SUB
# MEMBER NAME:     ARITHSHA
# FUNCTION RETURN TYPE:
#          FIXED
# INPUT PARAMETERS:
#          SIZE              FIXED
# LOCAL DECLARATIONS:
#          DEF_SIZE          FIXED
#          TRY_VAL_SUB       LABEL
# EXTERNAL VARIABLES REFERENCED:
#          INX
#          CLASS_QS
#          LOC_P
#          PSEUDO_FORM
#          VAL_P
#          XIMD
#          XLIT
# EXTERNAL VARIABLES CHANGED:
#          NEXT_SUB
# EXTERNAL PROCEDURES CALLED:
#          ERROR
#          MAKE_FIXED_LIT
# CALLED BY:
#          SYNTHESIZE
#*************************************************************************


def ARITH_SHAPER_SUB(SIZE):
    # Local: DEF_SIZE
    DEF_SIZE = 2;
    g.NEXT_SUB = g.NEXT_SUB + 1;
    if g.INX[g.NEXT_SUB] != 1:  # DO
        ERROR(d.CLASS_QS, 5);
        if g.INX[g.NEXT_SUB] > 1: g.NEXT_SUB = g.NEXT_SUB + 1;
    # END
    elif g.VAL_P[g.NEXT_SUB] > 0: ERROR(d.CLASS_QS, 6);
    elif g.PSEUDO_FORM[g.NEXT_SUB] == g.XIMD:  # DO
        DEF_SIZE = g.LOC_P[g.NEXT_SUB];
        # Was: GO TO TRY_VAL_SUB;  However, it was easier to cut-and-paste the
        # code from TRY_VAL_SUB than to actually fake up a GO TO.
        if (DEF_SIZE < 2) or (DEF_SIZE > SIZE):  # DO
            ERROR(d.CLASS_QS, 8);
            if DEF_SIZE < 2: return 2;
            return SIZE;
        # END
    # END
    elif g.PSEUDO_FORM[g.NEXT_SUB] != g.XLIT: ERROR(d.CLASS_QS, 7);
    else:  # DO
        DEF_SIZE = MAKE_FIXED_LIT(g.LOC_P[g.NEXT_SUB]);
        # TRY_VAL_SUB:
        if (DEF_SIZE < 2) or (DEF_SIZE > SIZE):  # DO
            ERROR(d.CLASS_QS, 8);
            if DEF_SIZE < 2: return 2;
            return SIZE;
        # END
    # END
    return DEF_SIZE;
# END ARITH_SHAPER_SUB;
