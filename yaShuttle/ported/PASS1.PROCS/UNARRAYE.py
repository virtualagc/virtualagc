#!/usr/bin/env python3
'''
Access:     Public Domain, no restrictions believed to exist.
Filename:   UNARRAYE.xpl
Purpose:    This is a part of the HAL/g.S-FC compiler program.
Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
Language:   XPL.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-10-10 RSB  Ported.
'''

import g
from CHECKARR import CHECK_ARRAYNESS
from HALMATTU import HALMAT_TUPLE
from SETUPVAC import SETUP_VAC

#*************************************************************************
# PROCEDURE NAME:  UNARRAYED_INTEGER
# MEMBER NAME:     UNARRAYE
# INPUT PARAMETERS:
#          LOC               BIT(16)
# EXTERNAL VARIABLES REFERENCED:
#          INT_TYPE
#          PSEUDO_TYPE
#          PTR
#          SCALAR_TYPE
#          XSTOI
# EXTERNAL PROCEDURES CALLED:
#          HALMAT_TUPLE
#          CHECK_ARRAYNESS
#          SETUP_VAC
# CALLED BY:
#          SYNTHESIZE
#*************************************************************************


def UNARRAYED_INTEGER(LOC):
    # No locals
    if g.PSEUDO_TYPE[g.PTR[LOC]] == g.SCALAR_TYPE:
        HALMAT_TUPLE(g.XSTOI, 0, LOC, 0, 0);
        SETUP_VAC(LOC, g.INT_TYPE);
    return CHECK_ARRAYNESS() or (g.PSEUDO_TYPE[g.PTR[LOC]] != g.INT_TYPE);
# END UNARRAYED_INTEGER;
