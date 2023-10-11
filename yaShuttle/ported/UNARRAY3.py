#!/usr/bin/env python
'''
Access:     Public Domain, no restrictions believed to exist.
Filename:   UNARRAY3.py
Purpose:    This is a part of the HAL/g.S-FC compiler program.
Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-10-10 RSB  Ported
'''

import g
from CHECKARR import CHECK_ARRAYNESS

#*************************************************************************
# PROCEDURE NAME:  UNARRAYED_SIMPLE
# MEMBER NAME:     UNARRAY3
# INPUT PARAMETERS:
#          LOC               BIT(16)
# EXTERNAL VARIABLES REFERENCED:
#          INT_TYPE
#          PSEUDO_TYPE
#          PTR
#          SCALAR_TYPE
# EXTERNAL PROCEDURES CALLED:
#          CHECK_ARRAYNESS
# CALLED BY:
#          SYNTHESIZE
#*************************************************************************

def UNARRAYED_SIMPLE(LOC):
    # No locals.
    LOC=g.PSEUDO_TYPE[g.PTR[LOC]];
    return CHECK_ARRAYNESS() or ((LOC!=g.INT_TYPE) and (LOC!=g.SCALAR_TYPE));
#END UNARRAYED_SIMPLE;
