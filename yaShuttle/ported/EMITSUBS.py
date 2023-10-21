#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   EMITSUBS.xpl
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
   Language:   XPL.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-10-21 RSB  Ported from XPL.
"""

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
import HALINCL.COMMON as h
from ERROR    import ERROR
from HALMATPI import HALMAT_PIP

#*************************************************************************
# PROCEDURE NAME:  EMIT_SUBSCRIPT
# MEMBER NAME:     EMITSUBS
# INPUT PARAMETERS:
#          MODE              BIT(8)
# LOCAL DECLARATIONS:
#          I                 BIT(16)
#          J                 BIT(16)
# EXTERNAL VARIABLES REFERENCED:
#          INX
#          LOC_P
#          PSEUDO_FORM
#          PSEUDO_TYPE
#          VAL_P
# EXTERNAL VARIABLES CHANGED:
#          PSEUDO_LENGTH
#          IND_LINK
# EXTERNAL PROCEDURES CALLED:
#          HALMAT_PIP
# CALLED BY:
#          SYNTHESIZE


def EMIT_SUBSCRIPT(MODE):
    # Locals I and J.

    J = 1;
    I = g.PSEUDO_LENGTH[0];
    while g.INX[I] >= MODE:
        if g.PSEUDO_TYPE[I] != 0:  # DO
            HALMAT_PIP(SHR(g.PSEUDO_TYPE[I], 4), g.PSEUDO_TYPE[I] & 0xF, \
                       g.INX[I], g.VAL_P[I]);
            HALMAT_PIP(g.LOC_P[I], g.PSEUDO_FORM[I], 0, 0);
            J = J + 1;
        # END
        else: HALMAT_PIP(g.LOC_P[I], g.PSEUDO_FORM[I], g.INX[I], g.VAL_P[I]);
        J = J + 1;
        if I == g.IND_LINK:  # DO
            g.IND_LINK = 0;
            return J;
        # END
        I = g.PSEUDO_LENGTH[I];
    # END
    g.PSEUDO_LENGTH[0] = I;
    return J;
# END EMIT_SUBSCRIPT;
