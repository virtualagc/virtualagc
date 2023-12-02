#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   FORMATFO.py
   Purpose:    Part of the HAL/S-FC compiler's HALMAT optimization
               process.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2022-11-21 RSB  Ported from XPL
"""

from xplBuiltins   import *
from HALINCL.VMEM3 import *
import g
from HEX   import HEX
from FLUSH import FLUSH

#*************************************************************************
# PROCEDURE NAME:  FORMAT_FORM_PARM_CELL
# MEMBER NAME:     FORMATFO
# INPUT PARAMETERS:
#          SYMB#             BIT(16)
#          PTR               FIXED
# LOCAL DECLARATIONS:
#          J                 BIT(16)
#          K                 BIT(16)
# EXTERNAL VARIABLES REFERENCED:
#          LINELENGTH
#          SYM_NAME
#          SYM_TAB
#          SYT_NAME
#          VMEM_B
#          VMEM_H
#          VMEM_LOC_ADDR
# EXTERNAL VARIABLES CHANGED:
#          S
# EXTERNAL PROCEDURES CALLED:
#          HEX
#          FLUSH
#          LOCATE
# CALLED BY:
#          FORMAT_SYT_VPTRS
#*************************************************************************


def FORMAT_FORM_PARM_CELL(SYMBp, PTR):
    # Locals: J, K

    S = HEX(PTR, 8) + ' --> ' + g.SYT_NAME(SYMBp) + '(';
    LOCATE(PTR, ADDR(g.VMEM_H), 0);
    # COREWORD(ADDR(g.VMEM_B)) = VMEM_LOC_ADDR;
    K = 0;
    if g.VMEM_B(3) > 0:  # DO
        for J in range(2, g.VMEM_B(3) + 1 + 1):
            if LENGTH(g.S[K]) > g.LINELENGTH: K = K + 1;
            g.S[K] = g.S[K] + g.SYT_NAME(g.VMEM_H(J)) + ',';
        # END
        g.S[K] = BYTE(g.S[K], LENGTH(g.S[K]) - 1, ')');
    # END
    else: S = S + ')';
    if g.VMEM_B(2) > g.VMEM_B(3):  # DO
        g.S[K] = g.S[K] + ' ASSIGN(';
        for J in range(g.VMEM_B(3) + 2, g.VMEM_B(2) + 1 + 1):
            if LENGTH(g.S[K]) > g.LINELENGTH: K = K + 1;
            g.S[K] = g.S[K] + g.SYT_NAME(g.VMEM_H(J)) + ',';
        # END
        g.S[K] = BYTE(g.S[K], LENGTH(g.S[K]) - 1, ')');
    # END
    FLUSH(K);
# END FORMAT_FORM_PARM_CELL;
