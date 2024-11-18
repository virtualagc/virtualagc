#!/usr/bin/env python3
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   ENDANYFC.py
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
from ARITHLIT import ARITH_LITERAL
from GETFCNPA import GET_FCN_PARM
from HALMATBA import HALMAT_BACKUP
from HALMATFI import HALMAT_FIX_PIPp
from HALMATPI import HALMAT_PIP
from HALMATPO import HALMAT_POP
from HALMATTU import HALMAT_TUPLE
from HALMATXN import HALMAT_XNOP
from MATCHSIM import MATCH_SIMPLES
from REDUCESU import REDUCE_SUBSCRIPT
from RESETARR import RESET_ARRAYNESS
from SETUPVAC import SETUP_VAC
from HALINCL.SAVELITE import SAVE_LITERAL

#*************************************************************************
# PROCEDURE NAME:  END_ANY_FCN
# MEMBER NAME:     ENDANYFC
# LOCAL DECLARATIONS:
#          ARG#              BIT(16)
#          ARGPTR            BIT(16)
#          BI_COMPILE_TIME   LABEL
#          BI_FUNCS_DONE     LABEL
#          BI_FUNCS_EXIT     LABEL
#          END_ARITH_SHAPERS LABEL
#          I                 BIT(16)
#          MAXPTR            BIT(16)
# EXTERNAL VARIABLES REFERENCED:
#          ASSIGN_TYPE
#          BI_ARG_TYPE
#          BI_MULT
#          BI_NAME
#          BIT_LENGTH_LIM
#          BIT_TYPE
#          CHAR_TYPE
#          CLASS_FD
#          CLASS_FN
#          CLASS_FT
#          CLASS_QA
#          CLASS_QD
#          CLASS_QX
#          CLASS_VF
#          CLASS_XS
#          COMM
#          CONST_DW
#          DW_AD
#          DW
#          FALSE
#          FCN_ARG
#          FCN_LOC
#          FCN_LV_MAX
#          FCN_MODE
#          FIX_DIM
#          FIXL
#          FIXV
#          FUNC_FLAG
#          INLINE_LEVEL
#          INT_TYPE
#          INX
#          IORS_TYPE
#          LAST_POP#
#          MP
#          NEXTIME_LOC
#          OPTIONS_CODE
#          SCALAR_TYPE
#          SP
#          STACK_PTR
#          STRING_MASK
#          VAR
#          XBFNC
#          XBTOB
#          XBTOC
#          XBTOI
#          XBTOS
#          XCO_N
#          XFCAL
#          XIMD
#          XITOS
#          XLFNC
#          XLIT
#          XMSHP
#          XPCAL
#          XSFND
#          XSTOI
#          XXXND
# EXTERNAL VARIABLES CHANGED:
#          ASSIGN_ARG_LIST
#          BI_FLAGS
#          BI_INFO
#          CURRENT_ARRAYNESS
#          FCN_LV
#          FIXF
#          FOR_DW
#          GRAMMAR_FLAGS
#          IND_LINK
#          LOC_P
#          NEXT_SUB
#          PSEUDO_FORM
#          PSEUDO_LENGTH
#          PSEUDO_TYPE
#          PTR
#          PTR_TOP
#          TEMP2
#          TEMP
#          VAL_P
# EXTERNAL PROCEDURES CALLED:
#          ARITH_LITERAL
#          ERROR
#          GET_FCN_PARM
#          HALMAT_BACKUP
#          HALMAT_FIX_PIP#
#          HALMAT_PIP
#          HALMAT_POP
#          HALMAT_TUPLE
#          HALMAT_XNOP
#          MATCH_SIMPLES
#          MAX
#          REDUCE_SUBSCRIPT
#          RESET_ARRAYNESS
#          SAVE_LITERAL
#          SETUP_VAC
# CALLED BY:
#          SYNTHESIZE
#*************************************************************************


def END_ANY_FCN():
    # Locals: ARGp, I, MAXPTR, ARGPTR.

    goto = None

    def BI_COMPILE_TIME():
        nonlocal goto
        if (SHR(g.BI_INFO[0], 8) & 0xF) == 0: return;
        if ARITH_LITERAL(g.SP - 1, 0):  # DO
            if MONITOR(9, SHR(g.BI_INFO[0], 8) & 0xF):  # DO
                ERROR(d.CLASS_VF, 1, g.VAR[g.MP]);
                return;
            # END
            g.LOC_P[g.PTR[g.MP]] = SAVE_LITERAL(1, g.DW_AD());
            g.PSEUDO_FORM[g.PTR[g.MP]] = g.XLIT;
            goto = "BI_FUNCS_EXIT";

        # END
    # END BI_COMPILE_TIME;
    
    g.GRAMMAR_FLAGS(g.STACK_PTR[g.MP], \
                    g.GRAMMAR_FLAGS(g.STACK_PTR[g.MP]) | g.FUNC_FLAG);
    MAXPTR = g.PTR[g.SP - 1];
    g.PTR_TOP = g.PTR[g.MP] - (g.FCN_LV == 0);
    if g.FCN_LV > g.FCN_LV_MAX:  # DO
        g.FCN_LV = g.FCN_LV - 1;
        return;
    # END
    
    # DO CASE FCN_MODE[g.FCN_LV];
    fn = g.FCN_MODE[g.FCN_LV]
    if fn == 0:
        #  PROCS AND USER FUNCS
        # DO
            g.ASSIGN_ARG_LIST = g.FALSE;
            if g.INLINE_LEVEL > 0: return;
            if g.FCN_LV == 0: 
                HALMAT_TUPLE(g.XPCAL, 0, g.MP, 0, 0);
            else:  # DO
                RESET_ARRAYNESS();
                HALMAT_TUPLE(g.XFCAL, 0, g.MP, 0, g.FCN_LV);
                SETUP_VAC(g.MP, g.PSEUDO_TYPE[g.PTR[g.MP]]);
            # END
            if MAXPTR > 0: MAXPTR = g.XCO_N;
            HALMAT_POP(g.XXXND, 0, MAXPTR, g.FCN_LV);
        # END
    elif fn == 1:
        #  NORMAL BUILT-IN FUNCS
        # DO
            g.PTR[g.SP] = MAXPTR + 1;
            # TEMP PTR TO SECOND ARG
            g.PTR[g.SP - 2] = MAXPTR + 2;
            # DITTO FOR THIRD ARG
            g.BI_FLAGS[0] = g.BI_FLAGS[g.FCN_LOC[g.FCN_LV]];
            g.BI_INFO[0] = g.BI_INFO[g.FCN_LOC[g.FCN_LV]];
            ARGp = SHR(g.BI_INFO[0], 16) & 0xFF;
            ARGPTR = g.BI_INFO[0] & 0xFF;
            # The following isn't really a loop, since it's executed just once.
            # It's there because it allows "GOTO BI_FUNCS_EXIT to be just a
            # `break`, rather than something much more complicated.
            first = True
            while first:
                first = False
                if ARGp != g.FCN_ARG[g.FCN_LV]: ERROR(d.CLASS_FN, 4, g.VAR[g.MP]);
                elif (SHL(1, g.PSEUDO_TYPE[MAXPTR]) & \
                        g.ASSIGN_TYPE[g.BI_ARG_TYPE[ARGPTR]]) == 0:
                    ERROR(d.CLASS_FT, 2, g.VAR[g.MP]);
                else:  # DO
                    if ARGp >= 2: 
                        if (SHL(1, g.PSEUDO_TYPE[MAXPTR + 1]) & \
                                g.ASSIGN_TYPE[g.BI_ARG_TYPE[ARGPTR + 1]]) == 0:  # DO
                            ERROR(d.CLASS_FT, 2, g.VAR[g.MP]);
                            goto = "BI_FUNCS_DONE";
                        # END
                    if ARGp == 3: 
                        if (SHL(1, g.PSEUDO_TYPE[MAXPTR + 2]) & \
                                g.ASSIGN_TYPE[g.BI_ARG_TYPE[ARGPTR + 2]]) == 0:  # DO
                            ERROR(d.CLASS_FT, 2, g.VAR[g.MP]);
                            goto = "BI_FUNCS_DONE";
                        # END
                    # DO CASE BI_ARG_TYPE(ARGPTR);
                    ba = g.BI_ARG_TYPE[ARGPTR]
                    if ba == 0:
                        pass;
                        # THIS CASE NOT USED
                    elif ba == 1:
                        # DO
                            # BIT TYPE
                            if g.FCN_LOC[g.FCN_LV] == g.NEXTIME_LOC:  # DO
                                # NEXTIME ARG
                                if g.INX[MAXPTR] != 2:  # MUST BE PROCESS
                                    ERROR(d.CLASS_FT, 2, g.VAR[g.MP]);
                            # END
                            else: 
                                g.PSEUDO_LENGTH[g.PTR[g.MP]] = \
                                    MAX(g.PSEUDO_LENGTH[MAXPTR], \
                                        g.PSEUDO_LENGTH[MAXPTR + 1]);
                        # END
                    elif ba == 2:
                        #  CHARACTER TYPE
                        # DO
                            if g.PSEUDO_TYPE[MAXPTR] != g.CHAR_TYPE:  # DO
                                HALMAT_TUPLE(g.XBTOC[g.PSEUDO_TYPE[MAXPTR] - g.BIT_TYPE], \
                                             0, g.SP - 1, 0, 0);
                                SETUP_VAC(g.SP - 1, g.CHAR_TYPE);
                            # END
                            if ARGp == 2:  # DO
                                if g.BI_ARG_TYPE[ARGPTR + 1] == g.CHAR_TYPE:  # DO
                                    if g.PSEUDO_TYPE[MAXPTR + 1] != g.CHAR_TYPE:  # DO
                                        HALMAT_TUPLE(g.XBTOC[g.PSEUDO_TYPE[MAXPTR + 1] - g.BIT_TYPE], \
                                                     0, g.SP, 0, 0);
                                        SETUP_VAC(g.SP, g.CHAR_TYPE);
                                    # END
                                # END
                                elif g.PSEUDO_TYPE[MAXPTR + 1] == g.SCALAR_TYPE:  # DO
                                    HALMAT_TUPLE(g.XSTOI, 0, g.SP, 0, 0);
                                    SETUP_VAC(g.SP, g.INT_TYPE);
                                # END
                            # END
                        # END
                    elif ba == 3:
                        # MATRIX TYPE
                        # DO
                            if (g.BI_FLAGS[0] & 0x80) != 0: 
                                g.PSEUDO_LENGTH[g.PTR[g.MP]] = \
                                    SHL(g.PSEUDO_LENGTH[MAXPTR] & 0xFF, 8) | \
                                    SHR(g.PSEUDO_LENGTH[MAXPTR] & 0xFF00, 8);
                            else: 
                                g.PSEUDO_LENGTH[g.PTR[g.MP]] = g.PSEUDO_LENGTH[MAXPTR];
                            if (g.BI_FLAGS[0] & 0x40) != 0:  # DO
                                if (g.PSEUDO_LENGTH[MAXPTR] & 0xFF) != \
                                        SHR(g.PSEUDO_LENGTH[MAXPTR], 8):
                                    ERROR(d.CLASS_FD, 6, g.VAR[g.MP]);
                            # END
                        # END
                    elif ba == 4:
                        #  VECTOR TYPE
                        g.PSEUDO_LENGTH[g.PTR[g.MP]] = g.PSEUDO_LENGTH[MAXPTR];
                    elif ba == 5:
                        #  SCALAR TYPE
                        # DO
                            BI_COMPILE_TIME();
                            if goto == "BI_FUNCS_EXIT": # Maybe set by `BI_COMPILE_TIME`.
                                break;
                            if g.PSEUDO_TYPE[MAXPTR] == g.INT_TYPE:  # DO
                                HALMAT_TUPLE(g.XITOS, 0, g.SP - 1, 0, 0);
                                SETUP_VAC(g.SP - 1, g.SCALAR_TYPE);
                            # END
                            if ARGp >= 2: 
                                if g.PSEUDO_TYPE[MAXPTR + 1] == g.INT_TYPE:  # DO
                                    HALMAT_TUPLE(g.XITOS, 0, g.SP, 0, 0);
                                    SETUP_VAC(g.SP, g.SCALAR_TYPE);
                                # END
                            if ARGp == 3: 
                                if g.PSEUDO_TYPE[MAXPTR + 2] == g.INT_TYPE:  # DO
                                    HALMAT_TUPLE(g.XITOS, 0, g.SP - 2, 0, 0);
                                    SETUP_VAC(g.SP - 2, g.SCALAR_TYPE);
                                # END
                        # END
                    elif ba == 6:
                        #  INTEGER TYPE
                        # DO
                            BI_COMPILE_TIME();
                            if goto == "BI_FUNCS_EXIT": # Maybe set by `BI_COMPILE_TIME`.
                                break;
                            if g.PSEUDO_TYPE[MAXPTR] == g.SCALAR_TYPE:  # DO
                                HALMAT_TUPLE(g.XSTOI, 0, g.SP - 1, 0, 0);
                                SETUP_VAC(g.SP - 1, g.INT_TYPE);
                            # END
                            if ARGp == 2: 
                                if g.PSEUDO_TYPE[MAXPTR + 1] == g.SCALAR_TYPE:  # DO
                                    HALMAT_TUPLE(g.XSTOI, 0, g.SP, 0, 0);
                                    SETUP_VAC(g.SP, g.INT_TYPE);
                                # END
                            g.PSEUDO_LENGTH[g.PTR[g.MP]] = 1;
                        # END
                    elif ba == 7:
                        pass;
                        # THIS CASE NOT USED
                    elif ba == 8:
                        #  IORS TYPE
                        # DO
                        if ARGp == 2: MATCH_SIMPLES(g.SP - 1, g.SP);
                        if SHR(g.BI_INFO[0], 24) == g.IORS_TYPE:
                            g.PSEUDO_TYPE[g.PTR[g.MP]] = g.PSEUDO_TYPE[MAXPTR];
                        if ARGp == 1: 
                            BI_COMPILE_TIME();
                            if goto == "BI_FUNCS_EXIT": # Maybe set by `BI_COMPILE_TIME`.
                                break;
                        # END
                    # END DO CASE
                    HALMAT_POP(g.XBFNC, ARGp, 0, g.FCN_LOC[g.FCN_LV]);
                    for I  in range(MAXPTR, MAXPTR + ARGp - 1 + 1):
                        HALMAT_PIP(g.LOC_P[I], g.PSEUDO_FORM[I], g.PSEUDO_TYPE[I], 0);
                    # END
                    SETUP_VAC(g.MP, g.PSEUDO_TYPE[g.PTR[g.MP]]);
                # END
                if goto == "BI_FUNCS_DONE": goto = None
                if g.BI_FLAGS[0] & 1: 
                    ERROR(d.CLASS_XS, 1, \
                          SUBSTR(g.BI_NAME[g.BI_INDX[g.FCN_LOC[g.FCN_LV]]], \
                                 g.BI_LOC[g.FCN_LOC[g.FCN_LV]], 10));
            if goto == "BI_FUNCS_EXIT": goto = None
        # END
    elif fn == 2:
        #  ARITHMETIC SHAPERS
        # DO
            ARGp = g.PTR[g.MP];
            g.TEMP2 = g.XMSHP[g.FCN_LOC[g.FCN_LV]];
            if g.FCN_LOC[g.FCN_LV] >= 2:  # DO
                #  INTEGER AND SCALAR
                RESET_ARRAYNESS();
                if g.INX[ARGp] == 0:  # DO
                    if g.FIXV[g.SP - 1] & 1:  # DO
                        HALMAT_XNOP(g.VAL_P[ARGp]);
                        HALMAT_BACKUP(g.VAL_P[MAXPTR]);
                        if RESET_ARRAYNESS() == 3: ERROR(d.CLASS_QA, 1);
                        # DO CASE FCN_LOC[FCN_LV]-2;
                        fl = g.FCN_LOC[g.FCN_LV] - 2
                        if fl == 0:
                            g.TEMP = g.XBTOS[g.PSEUDO_TYPE[MAXPTR] - g.BIT_TYPE];
                        elif fl == 1:
                            g.TEMP = g.XBTOI[g.PSEUDO_TYPE[MAXPTR] - g.BIT_TYPE];
                        # END DO CASE
                        # IF THERE WAS NO PRECISION SPECIFIED ON THE
                        # ARITHMETIC CONVERSION (PSEUDO_FORM=0) AND
                        # THE CONVERSION IS INTEGER TO SCALAR (0x5C1),
                        # FORCE THE PRECISION TO SINGLE (PSEUDO_FORM=1)
                        # TO PREVENT THIS CR'S FIX IN GENCLAS5 FROM
                        # GENERATING A DOUBLE PRECISION RESULT.
                        # ALSO SET PRECISION TO SINGLE FOR SCALAR TO SCALAR (0x5A1),
                        # SCALAR TO INTEGER (0x6A1), AND INTEGER TO INTEGER (0x6C1).
                        if g.PSEUDO_FORM[ARGp] == 0 and (g.TEMP == 0x5C1 or \
                                                         g.TEMP == 0x5A1 or \
                                                         g.TEMP == 0x6C1 or \
                                                         g.TEMP == 0x6A1):
                            g.PSEUDO_FORM[ARGp] = 1;
                        HALMAT_TUPLE(g.TEMP, 0, g.SP - 1, 0, g.PSEUDO_FORM[ARGp]);
                        SETUP_VAC(g.MP, g.PSEUDO_TYPE[ARGp]);
                        goto = "END_ARITH_SHAPERS";
                    # END
                    else:  # DO
                        g.CURRENT_ARRAYNESS[0] = 1;
                        g.CURRENT_ARRAYNESS[1] = g.FIXL[g.SP - 1];
                        if g.CURRENT_ARRAYNESS[1] < 2: 
                            ERROR(d.CLASS_QA, 2);
                    # END
                # END
                else:  # DO
                    g.CURRENT_ARRAYNESS[0] = g.INX[ARGp];
                    for I in range(1, g.CURRENT_ARRAYNESS[0] + 1):
                        g.CURRENT_ARRAYNESS[I] = g.LOC_P[ARGp + I];
                    # END
                    if g.FIXL[g.SP - 1] <= 0: 
                        ERROR(d.CLASS_QA, 2);
                    elif g.FIXL[g.SP - 1] != g.PSEUDO_LENGTH[ARGp]:
                        ERROR(d.CLASS_QA, 3);
                # END
                if goto == None:
                    HALMAT_POP(g.TEMP2, g.CURRENT_ARRAYNESS[0], 0, g.FCN_LV);
                    HALMAT_PIP(g.CURRENT_ARRAYNESS[1], g.XIMD, g.PSEUDO_FORM[ARGp],
                    0);
                    for I in range(2, g.CURRENT_ARRAYNESS[0] + 1):
                        HALMAT_PIP(g.CURRENT_ARRAYNESS[I], g.XIMD, 0, 0);
                    # END
                    if RESET_ARRAYNESS() == 3: ERROR(d.CLASS_QA, 4);
             # END
            else:  # DO
                #  VECTOR AND MATRIX
                RESET_ARRAYNESS();
                if g.INX[ARGp] != g.FIXL[g.SP - 1]: ERROR(d.CLASS_QD, 1);
                HALMAT_POP(g.TEMP2, 1, 0, g.FCN_LV);
                HALMAT_PIP(g.PSEUDO_LENGTH[ARGp], g.XIMD, g.PSEUDO_FORM[ARGp],
                0);
            # END
            if goto == None:
                SETUP_VAC(g.MP, g.PSEUDO_TYPE[ARGp]);
                HALMAT_POP(g.XSFND, 0, g.XCO_N, g.FCN_LV);
            if goto == "END_ARITH_SHAPERS": goto = None
            g.VAL_P[ARGp] = 0;
        # END
    elif fn == 3:
        #  STRING  SHAPERS
        # DO
            g.NEXT_SUB = g.PTR[g.MP];
            g.IND_LINK = 0
            g.PSEUDO_LENGTH[0] = 0;
            if g.FCN_ARG[g.FCN_LV] > 1: ERROR(d.CLASS_QD, 2);
            if (SHL(1, g.PSEUDO_TYPE[MAXPTR]) & g.STRING_MASK) == 0:  # DO
                ERROR(d.CLASS_QX, 4);
                if g.FCN_LOC[g.FCN_LV] == 0: g.PSEUDO_TYPE[MAXPTR] = g.BIT_TYPE;
                else: g.PSEUDO_TYPE[MAXPTR] = g.CHAR_TYPE;
            # END
            # DO CASE FCN_LOC[FCN_LV];
            fl = g.FCN_LOC[g.FCN_LV]
            if fl == 0:
                #  CHARACTER
                # DO
                    if g.PSEUDO_FORM[g.NEXT_SUB] != 0:
                        if g.PSEUDO_TYPE[MAXPTR] != g.BIT_TYPE:
                            ERROR(d.CLASS_QX, 5);
                    if g.INX[g.NEXT_SUB] > 0:  # DO
                        if (g.PSEUDO_TYPE[MAXPTR] == g.BIT_TYPE) or \
                                (g.PSEUDO_TYPE[MAXPTR] == g.CHAR_TYPE or \
                                 g.PSEUDO_FORM[MAXPTR] != g.XVAC): 
                            REDUCE_SUBSCRIPT(0, g.PSEUDO_LENGTH[MAXPTR], 1);
                        else: REDUCE_SUBSCRIPT(0, -1, 1);
                    # END
                    ARGp = g.XBTOC[g.PSEUDO_TYPE[MAXPTR] - g.BIT_TYPE];
                # END
            elif fl == 1:
                #  BIT
                # DO
                    if g.PSEUDO_FORM[g.NEXT_SUB] != 0:
                        if g.PSEUDO_TYPE[MAXPTR] != g.CHAR_TYPE:
                            ERROR(d.CLASS_QX, 6);
                    if g.INX[g.NEXT_SUB] > 0:  # DO
                        REDUCE_SUBSCRIPT(0, g.BIT_LENGTH_LIM);
                        g.PSEUDO_LENGTH[g.PTR_TOP] = g.FIX_DIM;
                    # END
                    else: g.PSEUDO_LENGTH[g.PTR_TOP] = g.BIT_LENGTH_LIM;
                    ARGp = g.XBTOB[g.PSEUDO_TYPE[MAXPTR] - g.BIT_TYPE];
                # END
            # END DO CASE
            HALMAT_TUPLE(ARGp, 0, g.SP - 1, 0, g.PSEUDO_FORM[g.PTR_TOP]);
            SETUP_VAC(g.MP, g.PSEUDO_TYPE[g.PTR_TOP]);
            ARGp = 1;
            I = 0;
            while I != g.IND_LINK:
                I = g.PSEUDO_LENGTH[I];
                if g.PSEUDO_TYPE[I] != 0:  # DO
                    HALMAT_PIP(SHR(g.PSEUDO_TYPE[I], 4), g.PSEUDO_TYPE[I] & 0xF,
                    g.INX[I], g.VAL_P[I]);
                    HALMAT_PIP(g.LOC_P[I], g.PSEUDO_FORM[I], 0, 0);
                    ARGp = ARGp + 1;
                # END
                else: 
                    HALMAT_PIP(g.LOC_P[I], g.PSEUDO_FORM[I], 
                               g.INX[I], g.VAL_P[I]);
                ARGp = ARGp + 1;
            # END
            HALMAT_FIX_PIPp(g.LAST_POPp, ARGp);
        # END
    elif fn == 4:
        #  L-FUNC  BUILT-INS
        # DO
            I = g.PSEUDO_TYPE[MAXPTR];
            g.BI_INFO[0] = g.BI_INFO[g.FCN_LOC[g.FCN_LV]];
            g.BI_FLAGS[0] = g.BI_FLAGS[g.FCN_LOC[g.FCN_LV]];
            if g.BI_FLAGS[0] & 1: 
                ERROR(d.CLASS_XS, 1, \
                      SUBSTR(g.BI_NAME[g.BI_INDX[g.FCN_LOC[g.FCN_LV]]], \
                              g.BI_LOC[g.FCN_LOC[g.FCN_LV]], 10));
            if (SHL(1, I) & g.ASSIGN_TYPE[g.BI_ARG_TYPE[g.BI_INFO[0] & 0xFF]]) == 0:
                ERROR(d.CLASS_FT, 2, g.VAR[g.MP]);
            if g.FCN_ARG[g.FCN_LV] > 1: ERROR(d.CLASS_FN, 4, g.VAR[g.MP]);
            HALMAT_POP(g.XLFNC, 1, 0, g.FCN_LV);
            HALMAT_PIP(g.FCN_LOC[g.FCN_LV], g.XIMD, I, 0);
            if SHR(g.BI_FLAGS[0], 4) & 1: I = SHR(g.BI_INFO[0], 24);
            SETUP_VAC(g.MP, I);
            HALMAT_POP(g.XSFND, 0, g.XCO_N, g.FCN_LV);
            RESET_ARRAYNESS();
        # END
    # END DO CASE
    if g.FCN_LV > 0: g.FCN_LV = g.FCN_LV - 1;
    g.FIXF[g.MP] = 0;
# END END_ANY_FCN;
