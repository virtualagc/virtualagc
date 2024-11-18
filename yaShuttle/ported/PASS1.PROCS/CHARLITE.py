#!/usr/bin/env python3
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   CHARLITE.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-10-25 RSB  Ported from XPL
"""

from xplBuiltins import *
import g
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
        g.VAR[LOC1] = STRING(g.LIT2(GET_LITERAL(g.LOC_P[g.PTR[LOC1]])));
    if LOC2 == 0: return g.TRUE;
    if g.PSEUDO_FORM[g.PTR[LOC2]] != g.XLIT: return g.FALSE;
    if g.LOC_P[g.PTR[LOC2]] == 0: g.VAR[LOC2] = '';
    elif g.LIT1(GET_LITERAL(g.LOC_P[g.PTR[LOC2]])) == 0: 
        g.VAR[LOC2] = STRING(g.LIT2(GET_LITERAL(g.LOC_P[g.PTR[LOC2]])));
    return g.TRUE;
# END CHAR_LITERAL;
