#!/usr/bin/env python3
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   CHARLITE.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-10-25 RSB  Ported from XPL
               2026-03-25 RSB  Added `hintArray` parameter for `STRING()`
                               calls.
"""

import sys
from xplBuiltins import *
import g
import HALINCL.COMMON as h
from GETLITER import GET_LITERAL

#*************************************************************************
# PROCEDURE NAME:  CHAR_LITERAL
# MEMBER NAME:     CHARLITE
# FUNCTION RETURN TYPE:
#          BIT(8)
# INPUT PARAMETERS:
#          LOC1              BIT(16)
#          LOC2              BIT(16)
# EXTERNAL VARIABLES REFERENCED:
#          FALSE
#          LIT_PG
#          LITERAL2
#          LIT2
#          LOC_P
#          PSEUDO_FORM
#          PTR
#          TRUE
#          XLIT
# EXTERNAL VARIABLES CHANGED:
#          VAR
# EXTERNAL PROCEDURES CALLED:
#          GET_LITERAL
# CALLED BY:
#          SYNTHESIZE
#*************************************************************************


def CHAR_LITERAL(LOC1, LOC2):
    # No locals.
    
    if g.PSEUDO_FORM[g.PTR[LOC1]] != g.XLIT: return g.FALSE;
    if g.LOC_P[g.PTR[LOC1]] == 0: g.VAR[LOC1] = '';
    elif g.LIT1(GET_LITERAL(g.LOC_P[g.PTR[LOC1]])) == 0: 
        arg0 = g.PTR[LOC1]
        arg1 = g.LOC_P[arg0]
        arg2 = GET_LITERAL(arg1)
        arg3 = g.LIT2(arg2)
        #if not isinstance(arg3, str): # For debugging purposes
        #    print("Trap CHARLITE 1:", LOC1, arg0, arg1, arg2, arg3, 
        #          g.LIT1(arg2), g.LIT3(arg2), file=sys.stderr)
        g.VAR[LOC1] = STRING(arg3, h.lit_char);
    if LOC2 == 0: return g.TRUE;
    if g.PSEUDO_FORM[g.PTR[LOC2]] != g.XLIT: return g.FALSE;
    if g.LOC_P[g.PTR[LOC2]] == 0: g.VAR[LOC2] = '';
    elif g.LIT1(GET_LITERAL(g.LOC_P[g.PTR[LOC2]])) == 0: 
        arg0 = g.PTR[LOC1]
        arg1 = g.LOC_P[arg0]
        arg2 = GET_LITERAL(arg1)
        arg3 = g.LIT2(arg2)
        #if not isinstance(arg3, str): # For debugging purposes
        #    print("Trap CHARLITE 2:", LOC2, arg0, arg1, arg2, arg3, 
        #          g.LIT1(arg2), g.LIT3(arg2), file=sys.stderr)
        g.VAR[LOC2] = STRING(arg3, h.lit_char);
    return g.TRUE;
# END CHAR_LITERAL;
