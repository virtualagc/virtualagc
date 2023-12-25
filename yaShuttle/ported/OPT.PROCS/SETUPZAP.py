#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   SETUPZAP.py
   Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-12-05 RSB  Ported from XPL
"""

from xplBuiltins import *
import g
import HALINCL.COMMON as h

#*************************************************************************
# PROCEDURE NAME:  SETUP_ZAP_BY_TYPE
# MEMBER NAME:     SETUPZAP
# LOCAL DECLARATIONS:
#          BIT_PTR           BIT(16)
#          K                 BIT(16)
#          MAT_BASE          BIT(16)
#          PTR               BIT(16)
#          SCAL_BASE         BIT(16)
#          TYPE              BIT(16)
#          VEC_BASE          BIT(16)
#          WD#               BIT(16)
# EXTERNAL VARIABLES REFERENCED:
#          AND
#          COMM
#          FOR
#          INT_VAR
#          REL
#          SYM_REL
#          SYM_SHRINK
#          SYM_TAB
#          SYM_TYPE
#          SYT_TYPE
#          TYPE_ZAP
#          VAL_SIZE
# EXTERNAL VARIABLES CHANGED:
#          ZAPIT
# CALLED BY:
#          INITIALISE
#*************************************************************************
# SETS UP ARRAYS USED FOR ASSIGNMENT TO A NAME OR ASSIGN PARM


def SETUP_ZAP_BY_TYPE():
    # Locals: K,TYPE,PTR,WDp,BIT_PTR,MAT_BASE,VEC_BASE,SCAL_BASE
    for K in range(2, h.COMM[10] + 1):
        PTR = g.REL(K);
        if PTR > 1:  # DO
            # USED
            TYPE = g.SYT_TYPE(K);
            if TYPE > 0 and TYPE <= g.INT_VAR:  # DO
                BIT_PTR = PTR & 0x1F;
                g.ZAPIT[TYPE - 1 + SHR(PTR, 5)].TYPE_ZAP |= SHL(1, BIT_PTR);
            # END
        # END
    # END
    # DO FOR
    MAT_BASE = g.VAL_SIZE + g.VAL_SIZE;
    MAT_BASE = 2;
    VEC_BASE = 3;
    SCAL_BASE = 4;
    for K in range(0, g.VAL_SIZE - 1 + 1):
        g.ZAPIT[VEC_BASE + K].TYPE_ZAP |= g.ZAPIT[MAT_BASE + K].TYPE_ZAP;
        g.ZAPIT[SCAL_BASE + K].TYPE_ZAP |= g.ZAPIT[VEC_BASE + K].TYPE_ZAP;
    # END 
    ''' AN ASSIGN TO A NAME OF A VECTOR ALSO ZAPS MATRIX.
        AN ASSIGN TO A SCALAR ZAPS ALL 3. '''
# END SETUP_ZAP_BY_TYPE;
