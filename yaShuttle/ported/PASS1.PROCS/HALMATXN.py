#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   HALMATXN.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-10-22 RSB  Ported to XPL
"""

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
import HALINCL.COMMON as h
from ERROR import ERROR

#*************************************************************************
# PROCEDURE NAME:  HALMAT_XNOP
# MEMBER NAME:     HALMATXN
# INPUT PARAMETERS:
#          FIX_ATOM          FIXED
# EXTERNAL VARIABLES REFERENCED:
#          ATOMS
#          CONST_ATOMS
#          HALMAT_OK
# EXTERNAL VARIABLES CHANGED:
#          FOR_ATOMS
# CALLED BY:
#          END_ANY_FCN
#*************************************************************************


def HALMAT_XNOP(FIX_ATOM):
    # No locals.
    if g.HALMAT_OK: g.ATOMS(FIX_ATOM, g.ATOMS(FIX_ATOM) & 0xFF0000);
    #  XNOP IS  A ZERO OPCODE
# END HALMAT_XNOP;
