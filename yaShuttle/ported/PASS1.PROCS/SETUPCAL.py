#!/usr/bin/env python3
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   SETUPCAL.py
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
from GETFCNPA import GET_FCN_PARM
from EMITARRA import EMIT_ARRAYNESS
from HALMATF3 import HALMAT_FIX_PIPTAGS
from HALMATTU import HALMAT_TUPLE
from KILLNAME import KILL_NAME
from RESETARR import RESET_ARRAYNESS
from SAVEARRA import SAVE_ARRAYNESS

#*************************************************************************
# PROCEDURE NAME:  SETUP_CALL_ARG
# MEMBER NAME:     SETUPCAL
# LOCAL DECLARATIONS:
#          ARR_CHECKOUT      LABEL
#          I                 BIT(16)
#          J                 BIT(16)
# EXTERNAL VARIABLES REFERENCED:
#          ASSIGN_TYPE
#          BI_FLAGS
#          CLASS_FD
#          CLASS_FT
#          CLASS_QX
#          EXT_ARRAY
#          FALSE
#          FCN_LOC
#          FCN_LV_MAX
#          FCN_LV
#          FCN_MODE
#          INLINE_LEVEL
#          INX
#          LAST_POP#
#          MAJ_STRUC
#          MP
#          NAME_PSEUDOS
#          NEXT_ATOM#
#          SP
#          SYM_ARRAY
#          SYM_LENGTH
#          SYM_TAB
#          SYM_TYPE
#          SYT_ARRAY
#          SYT_TYPE
#          VAR
#          VAR_LENGTH
#          XCO_N
#          XIMD
#          XSFAR
#          XXXAR
# EXTERNAL VARIABLES CHANGED:
#          CURRENT_ARRAYNESS
#          EXT_P
#          FCN_ARG
#          FIXL
#          FIXV
#          LOC_P
#          PSEUDO_LENGTH
#          PSEUDO_TYPE
#          PTR
#          PTR_TOP
#          TEMP
#          VAL_P
# EXTERNAL PROCEDURES CALLED:
#          CHECK_ARRAYNESS
#          EMIT_ARRAYNESS
#          ERROR
#          GET_FCN_PARM
#          HALMAT_FIX_PIP#
#          HALMAT_FIX_PIPTAGS
#          HALMAT_PIP
#          HALMAT_TUPLE
#          KILL_NAME
#          MATRIX_COMPARE
#          NAME_ARRAYNESS
#          NAME_COMPARE
#          RESET_ARRAYNESS
#          SAVE_ARRAYNESS
#          STRUCTURE_COMPARE
#          VECTOR_COMPARE
# CALLED BY:
#          SYNTHESIZE
#*************************************************************************


def SETUP_CALL_ARG():
    # Locals: I, J
    
    goto = None
    
    # DECLARE (I,J) BIT(16);
    if g.FCN_LV > g.FCN_LV_MAX: return;
    I = g.PTR[g.SP];
    if g.FCN_MODE[g.FCN_LV] != 0: 
        if KILL_NAME(g.SP) & 1: 
            ERROR(d.CLASS_FT, 10);
    # DO CASE FCN_MODE[FCN_LV];
    fc = g.FCN_MODE[g.FCN_LV]
    if fc == 0:
        #  PROCS AND USER FUNCS
        if g.INLINE_LEVEL == 0:  # DO
            HALMAT_TUPLE(g.XXXAR, g.XCO_N, g.SP, 0, g.FCN_LV);
            HALMAT_FIX_PIPTAGS(g.NEXT_ATOMp - 1, g.PSEUDO_TYPE[I] | \
                               SHL(g.NAME_PSEUDOS, 7), 0);
            g.PTR_TOP = I - 1;
            if g.FCN_LV == 0:  # DO
                g.FCN_ARG[0] = g.FCN_ARG[0] + 1;
                if g.NAME_PSEUDOS & 1:  # DO
                    KILL_NAME(g.SP);
                    if g.EXT_P[I] != 0: ERROR(d.CLASS_FD, 7);
                # END
                EMIT_ARRAYNESS();
            # END
            elif g.FCN_ARG[g.FCN_LV] >= 0:  # DO
                #  ONLY IF FUNCTION DEFINED AND SOME PARMS LEFT
                g.PTR[0] = 0;
                g.LOC_P[0] = GET_FCN_PARM();
                g.PSEUDO_LENGTH[0] = g.VAR_LENGTH(g.LOC_P[0]);
                np = g.NAME_PSEUDOS & 1
                if np:  # DO
                    if g.SYT_TYPE(g.LOC_P[0]) == g.MAJ_STRUC:  # DO
                        g.FIXV[0] = g.LOC_P[0];
                        g.FIXL[0] = g.VAR_LENGTH(g.LOC_P[0]);
                        g.CURRENT_ARRAYNESS[0] = g.SYT_ARRAY(g.LOC_P[0]) != 0;
                        g.CURRENT_ARRAYNESS[1] = g.SYT_ARRAY(g.LOC_P[0]);
                    # END
                    else:  # DO
                        g.FIXL[0] = g.LOC_P[0];
                        g.CURRENT_ARRAYNESS[0] = \
                            h.EXT_ARRAY[g.SYT_ARRAY(g.LOC_P[0])];
                        for J in range(1, g.CURRENT_ARRAYNESS[0] + 1):
                            g.CURRENT_ARRAYNESS[J] = \
                                EXT_ARRAY(g.SYT_ARRAY(g.LOC_P[0]) + J);
                        # END
                    # END
                    g.PSEUDO_TYPE[0] = g.SYT_TYPE(g.LOC_P[0]);
                    g.EXT_P[0] = 0;
                    # SEE NAME_COMPARE PROCEDURE FOR EXPLANATION OF BELOW STMT 
                    J = ((g.VAL_P[g.PTR[g.SP]] & 0x500) == 0x100); 
                    for J in range(1, J + 1): 
                        RESET_ARRAYNESS(); 
                    # END; 
                    NAME_ARRAYNESS(SP);
                    goto = "ARR_CHECKOUT";
                # END;
                if (not np and goto == None) or goto == "ARR_CHECKOUT": # ELSE
                    if goto == None:
                        g.PSEUDO_LENGTH[0] = g.VAR_LENGTH(g.LOC_P[0]);
                    if (g.SYT_ARRAY(g.LOC_P[0]) == 0 and goto == None) \
                            or goto == "ARR_CHECKOUT":  # DO;
                        if goto == "ARR_CHECKOUT": goto = None
                        if g.CURRENT_ARRAYNESS[0] != 0: g.PTR[g.MP] = 0;
                        # 1ST ARG, MP=SP AND PTR(SP)>0
                        if RESET_ARRAYNESS() & 1: ERROR(d.CLASS_FD, 4);
                        SAVE_ARRAYNESS();
                    # END
                    elif g.SYT_TYPE(g.LOC_P[0]) < g.MAJ_STRUC:  # DO
                        g.LOC_P[0] = g.SYT_ARRAY(g.LOC_P[0]);
                        EMIT_ARRAYNESS();
                    # END
                    else:
                        EMIT_ARRAYNESS();
            # END
        # END
        #  FOR NONHAL FUNCTIONS
        elif g.FCN_ARG[g.FCN_LV] == -2: EMIT_ARRAYNESS();
        #  FOR FORWARD FUNCTION CALLS
        else:  # DO
            if g.NAME_PSEUDOS & 1:  # DO
                # SEE NAME_COMPARE PROCEDURE FOR EXPLANATION OF BELOW STMT
                if ((g.VAL_P[g.PTR[g.SP]] & 0x500) == 0x100): 
                    RESET_ARRAYNESS();
                NAME_ARRAYNESS(g.SP);
            # END
            if g.CURRENT_ARRAYNESS[0] != 0: g.PTR[g.MP] = 0;
            if RESET_ARRAYNESS() & 1: ERROR(d.CLASS_FD, 4);
            SAVE_ARRAYNESS();
        # END
    # END
    elif fc == 1:
    #  NORMAL BUILT-IN FUNCTIONS
    # DO
        g.FCN_ARG[g.FCN_LV] = g.FCN_ARG[g.FCN_LV] + 1;
    # END
    elif fc == 2:
    #  ARITHMETIC SHAPERS
    # DO
        if g.FCN_ARG[g.FCN_LV] == 0:  # DO
            g.FIXV[g.MP] = (g.INX[I] == 0);
            g.FIXL[g.MP] = 0;
            if g.FCN_LOC[g.FCN_LV] > 1: SAVE_ARRAYNESS(g.FALSE);
        # END
        else:  # DO
            g.FIXV[g.MP] = g.FALSE;
            g.PTR_TOP = I - 1;
        # END
        g.TEMP = 1;
        # DO CASE PSEUDO_TYPE[I];
        pt = g.PSEUDO_TYPE[I]
        if pt == 0:
            pass;
        elif pt == 1:
            if g.FCN_LOC[g.FCN_LV] < 2: ERROR(d.CLASS_QX, 2);
        elif pt == 2:
            if g.FCN_LOC[g.FCN_LV] < 2: ERROR(d.CLASS_QX, 3);
        elif pt == 3:
            # DO
            g.TEMP = SHR(g.PSEUDO_LENGTH[I], 8) * g.TEMP;
            g.TEMP = (g.PSEUDO_LENGTH[I] & 0xFF) * g.TEMP;
            # END
        elif pt == 4:
            g.TEMP = g.PSEUDO_LENGTH[I] * g.TEMP;
        elif pt == 5:
            pass;
        elif pt == 6:
            pass;
        elif pt == 7:
            pass;
        elif pt == 8:
            pass;
        elif pt == 9:
            pass;
        elif pt == 10:
            # DO
            g.TEMP = -1;
            ERROR(d.CLASS_QX, 1);
            # END
        # END DO CASE
        HALMAT_TUPLE(g.XSFAR, g.XCO_N, g.SP, 0, g.FCN_LV);
        HALMAT_FIX_PIPTAGS(g.NEXT_ATOMp - 1, g.PSEUDO_TYPE[I], 0);
        if g.TEMP != 1: g.FIXV[g.MP] = g.FALSE;
        if g.INX[I] > 0:  # DO
            g.TEMP = g.INX[I] * g.TEMP;
            HALMAT_PIP(g.INX[I], g.XIMD, 0, 0);
            HALMAT_FIX_PIPp(g.LAST_POPp, 2);
        # END
        g.VAL_P[I] = g.LAST_POPp;
        for I in range(1, g.CURRENT_ARRAYNESS[0] + 1):
            g.TEMP = g.CURRENT_ARRAYNESS[I] * g.TEMP;
        # END
        if g.TEMP <= 0: g.FIXL[g.MP] = g.TEMP;
        else:
            if g.FIXL[g.MP] >= 0: g.FIXL[g.MP] = g.FIXL[g.MP] + g.TEMP;
        EMIT_ARRAYNESS();
        g.FCN_ARG[g.FCN_LV] = g.FCN_ARG[g.FCN_LV] + 1;
    # END
    elif fc == 3:
    #  STRING SHAPERS
    # DO
        g.FCN_ARG[g.FCN_LV] = g.FCN_ARG[g.FCN_LV] + 1;
    # END
    elif fc == 4:
    #   L-FUNC BUILT-INS
    # DO
        if g.FCN_ARG[g.FCN_LV] > 0:  # DO
            CHECK_ARRAYNESS();
            g.PTR_TOP = I - 1;
        # END
        else:  # DO
            HALMAT_TUPLE(g.XSFAR, g.XCO_N, g.SP, 0, g.FCN_LV, g.PSEUDO_TYPE[I], \
                         SHR(g.BI_FLAGS[g.FCN_LOC[g.FCN_LV]], 4) & 0x1);
            EMIT_ARRAYNESS();
        # END
        g.FCN_ARG[g.FCN_LV] = g.FCN_ARG[g.FCN_LV] + 1;
    # END
    # END DO CASE
# END SETUP_CALL_ARG;
