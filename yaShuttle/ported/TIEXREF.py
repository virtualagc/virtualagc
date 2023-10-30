#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   TIEXREF.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-10-29 RSB  Ported from XPL
"""

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
import HALINCL.COMMON as h
from ERROR import ERROR

#*************************************************************************
# PROCEDURE NAME:  TIE_XREF
# MEMBER NAME:     TIEXREF
# INPUT PARAMETERS:
#          P                 FIXED
# LOCAL DECLARATIONS:
#          I                 FIXED
#          J                 FIXED
#          PP                FIXED
# EXTERNAL VARIABLES REFERENCED:
#          BCD
#          CLASS_UP
#          CR_REF
#          SYM_PTR
#          SYM_XREF
#          SYT_PTR
#          SYT_XREF
#          UPDATE_BLOCK_LEVEL
#          XREF
# EXTERNAL VARIABLES CHANGED:
#          SYM_TAB
#          CROSS_REF
# EXTERNAL PROCEDURES CALLED:
#          ERROR
# CALLED BY:
#          SYNTHESIZE
#*************************************************************************


def TIE_XREF(P):
    # Locals: I, J, PP.
    if g.UPDATE_BLOCK_LEVEL > 0:
        ERROR(d.CLASS_UP, 1, g.BCD);
    if g.SYT_XREF(P) > 0:  # DO
        I = g.SYT_XREF(P);
        g.SYT_XREF(P, -1);
        PP = g.SYT_PTR(P);
        P = g.SYT_XREF(PP);
        if P > 0:  # DO
            J = g.XREF(I) & 0xFFFF0000;
            g.XREF(I, (g.XREF(I) & 0xFFFF) | (g.XREF(P) & 0xFFFF0000));
            g.XREF(P, (g.XREF(P) & 0xFFFF) | J);
        # END
        g.SYT_XREF(PP, I);
    # END
# END TIE_XREF;
