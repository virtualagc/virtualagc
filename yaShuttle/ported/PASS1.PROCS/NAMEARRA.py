#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   NAMEARRA.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-10-30 RSB  Ported from XPL.
"""

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
import HALINCL.COMMON as h
from ERROR import ERROR

#*************************************************************************
# PROCEDURE NAME:  NAME_ARRAYNESS
# MEMBER NAME:     NAMEARRA
# INPUT PARAMETERS:
#          LOC               BIT(16)
# EXTERNAL VARIABLES REFERENCED:
#          FALSE
#          EXT_P
#          PTR
# EXTERNAL VARIABLES CHANGED:
#          CURRENT_ARRAYNESS
#          NAME_PSEUDOS
# CALLED BY:
#          SETUP_CALL_ARG
#          SYNTHESIZE
#*************************************************************************


def NAME_ARRAYNESS(LOC):
    # No locals.
    LOC = g.EXT_P[g.PTR[LOC]];
    g.CURRENT_ARRAYNESS[1] = LOC;
    g.CURRENT_ARRAYNESS[0] = (LOC != 0);
    g.NAME_PSEUDOS = g.FALSE;
# END NAME_ARRAYNESS;
