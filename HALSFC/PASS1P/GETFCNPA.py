#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   GETFCNPA.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
"""

import g

#*************************************************************************
# PROCEDURE NAME:  GET_FCN_PARM
# MEMBER NAME:     GETFCNPA
# LOCAL DECLARATIONS:
#          L                 BIT(16)
# EXTERNAL VARIABLES REFERENCED:
#          ENDSCOPE_FLAG
#          FCN_LOC
#          FCN_LV
#          INPUT_PARM
#          NAME_FLAG
#          SYM_FLAGS
#          SYM_PTR
#          SYM_TAB
#          SYT_FLAGS
#          SYT_PTR
#          TRUE
# EXTERNAL VARIABLES CHANGED:
#          FCN_ARG
#          NAME_PSEUDOS
#          VAL_P
# CALLED BY:
#          SETUP_CALL_ARG
#          END_ANY_FCN
#*************************************************************************


def GET_FCN_PARM():
    # Local: L
    #  CANT GET IN HERE WITH FCN_ARG(.) ALREADY -1
    L = g.SYT_PTR(g.FCN_LOC[g.FCN_LV]);
    if g.FCN_ARG[g.FCN_LV] > 0:  # DO
        L = L + g.FCN_ARG[g.FCN_LV];
        if (g.SYT_FLAGS(L - 1) & g.ENDSCOPE_FLAG) != 0 or \
                (g.SYT_FLAGS(L) & g.INPUT_PARM) == 0:
            L = 0;
    # END
    if L > 0:  # DO
        if (g.SYT_FLAGS(L) & g.NAME_FLAG) != 0:  # DO
            g.VAL_P[0] = 0x300;
            g.NAME_PSEUDOS = g.TRUE;
        # END
        else: g.VAL_P[0] = 0;
        g.FCN_ARG[g.FCN_LV] = g.FCN_ARG[g.FCN_LV] + 1;
    # END
    else: g.FCN_ARG[g.FCN_LV] = -1;
    return L;
# END GET_FCN_PARM;
