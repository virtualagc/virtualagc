#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   STARTNOR.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-10-22 RSB  Ported from XPL.
"""

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
import HALINCL.COMMON as h
from ERROR    import ERROR
from HALMATPI import HALMAT_PIP
from HALMATPO import HALMAT_POP
from PUSHFCNS import PUSH_FCN_STACK
from PUSHINDI import PUSH_INDIRECT
from SAVEARRA import SAVE_ARRAYNESS
from SETXREFR import SET_XREF_RORS
from SETBIXRE import SET_BI_XREF
from STRUCTU2 import STRUCTURE_FCN
from UPDATEBL import UPDATE_BLOCK_CHECK

#*************************************************************************
# PROCEDURE NAME:  START_NORMAL_FCN
# MEMBER NAME:     STARTNOR
# FUNCTION RETURN TYPE:
#          BIT(16)
# LOCAL DECLARATIONS:
#          MODE              BIT(8)
#          TEMP              BIT(16)
# EXTERNAL VARIABLES REFERENCED:
#          ACCESS_FLAG
#          BI_FLAGS
#          BI_INFO
#          CLASS_PL
#          CLASS_PP
#          CLASS_PS
#          COMM
#          DEFINED_LABEL
#          DO_LEVEL
#          INLINE_LEVEL
#          INT_TYPE
#          IORS_TYPE
#          MP
#          NONHAL_FLAG
#          PTR_TOP
#          STACK_PTR
#          STMT_NUM
#          SYM_FLAGS
#          SYM_LENGTH
#          SYM_LINK1
#          SYM_TYPE
#          SYT_FLAGS
#          SYT_LINK1
#          SYT_MAX
#          SYT_TYPE
#          VAR
#          VAR_LENGTH
#          XCO_N
#          XSFST
#          XSYT
#          XXXST
# EXTERNAL VARIABLES CHANGED:
#          EXT_P
#          FCN_ARG
#          FCN_LOC
#          FCN_LV
#          FIXL
#          LOC_P
#          PSEUDO_FORM
#          PSEUDO_LENGTH
#          PSEUDO_TYPE
#          PTR
#          SYM_TAB
#          VAL_P
# EXTERNAL PROCEDURES CALLED:
#          ERROR
#          HALMAT_PIP
#          HALMAT_POP
#          PUSH_FCN_STACK
#          PUSH_INDIRECT
#          SAVE_ARRAYNESS
#          SET_BI_XREF
#          SET_XREF_RORS
#          STRUCTURE_FCN
#          UPDATE_BLOCK_CHECK
# CALLED BY:
#          SYNTHESIZE
#*************************************************************************


def START_NORMAL_FCN():
    # Locals:  MODE, TEMP
    
    g.PTR[g.MP] = PUSH_INDIRECT(1);
    if g.FIXL[g.MP] > g.SYT_MAX:  # DO
        g.FIXL[g.MP] = g.FIXL[g.MP] - g.SYT_MAX;
        SET_BI_XREF(g.FIXL[g.MP]);
        g.PSEUDO_TYPE[g.PTR_TOP] = SHR(g.BI_INFO[g.FIXL[g.MP]], 24);
        if g.PSEUDO_TYPE[g.PTR_TOP] == g.IORS_TYPE: g.PSEUDO_TYPE[g.PTR_TOP] = g.INT_TYPE;
        if (g.BI_FLAGS[g.FIXL[g.MP]] & 0x20) == 0: MODE = 1;
        else: MODE = 4;
        g.LOC_P[g.PTR_TOP] = g.FIXL[g.MP];
        g.PSEUDO_FORM[g.PTR_TOP] = g.XSYT;
    # END
    else:  # DO
        if (g.SYT_FLAGS(g.FIXL[g.MP]) & g.ACCESS_FLAG) != 0:
            ERROR(d.CLASS_PS, 7, g.VAR[g.MP]);
        TEMP = g.FIXL[g.MP];
        if g.SYT_LINK1(TEMP) < 0:  # DO
            if g.DO_LEVEL < (-g.SYT_LINK1(TEMP)): ERROR(d.CLASS_PL, 9, g.VAR[g.MP]);
        # END
        elif g.SYT_LINK1(TEMP) == 0: g.SYT_LINK1(TEMP, g.STMT_NUM());
        MODE = 0;
        g.VAL_P[g.PTR_TOP] = 0;
        g.EXT_P[g.PTR_TOP] = g.STACK_PTR[g.MP];
        g.PSEUDO_TYPE[g.PTR_TOP] = g.SYT_TYPE(g.FIXL[g.MP]);
        g.PSEUDO_LENGTH[g.PTR_TOP] = g.VAR_LENGTH(g.FIXL[g.MP]);
    # END
    if PUSH_FCN_STACK(MODE):  # DO
        g.FCN_LOC[g.FCN_LV] = g.FIXL[g.MP];
        # DO CASE MODE;
        if MODE == 0:
            if g.INLINE_LEVEL == 0:  # DO
                SAVE_ARRAYNESS();
                HALMAT_POP(g.XXXST, 1, g.XCO_N, g.FCN_LV);
                HALMAT_PIP(g.FIXL[g.MP], g.XSYT, 0, 0);
                UPDATE_BLOCK_CHECK(g.MP);
                if (g.SYT_FLAGS(g.FIXL[g.MP]) & g.DEFINED_LABEL) == 0:
                    g.FCN_ARG[g.FCN_LV] = -1;
                elif (g.SYT_FLAGS2(g.FIXL[g.MP]) & g.NONHAL_FLAG) != 0:
                    g.FCN_ARG[g.FCN_LV] = -2;
                g.LOC_P[g.PTR_TOP] = g.FIXL[g.MP];
                g.PSEUDO_FORM[g.PTR_TOP] = g.XSYT;
                STRUCTURE_FCN();
                SET_XREF_RORS(g.MP, 0x6000);
            # END
            else:  # DO
                ERROR(d.CLASS_PP, 8);
                g.FCN_LV = g.FCN_LV - 1;
            # END
        elif MODE == 1:
            pass;
        elif MODE == 2:
            pass;
        elif MODE == 3:
            pass;
        elif MODE == 4:
            # DO
                SAVE_ARRAYNESS();
                HALMAT_POP(g.XSFST, 0, g.XCO_N, g.FCN_LV);
            # END
        # END DO CASE
    # END
    return MODE == 0;
# END START_NORMAL_FCN;
