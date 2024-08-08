#!/usr/bin/env python3
'''
Access:     Public Domain, no restrictions believed to exist.
Filename:   SETUPNOA.py
Purpose:    This is a part of the HAL/g.S-FC compiler program.
Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-10-10 RSB  Ported.
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ERROR    import ERROR
from FLOATING import FLOATING
from HALMATPO import HALMAT_POP
from HALMATTU import HALMAT_TUPLE
from PRECSCAL import PREC_SCALE
from SETBIXRE import SET_BI_XREF
from SETUPVAC import SETUP_VAC
from SETXREFR import SET_XREF_RORS
from STRUCTU2 import STRUCTURE_FCN
from UPDATEBL import UPDATE_BLOCK_CHECK

#*************************************************************************
# PROCEDURE NAME:  SETUP_NO_ARG_FCN
# MEMBER NAME:     SETUPNOA
# INPUT PARAMETERS:
#          PSEUDO_PREC       BIT(16)
# LOCAL DECLARATIONS:
#          I                 BIT(16)
# EXTERNAL VARIABLES REFERENCED:
#          ACCESS_FLAG
#          BI_FUNC_FLAG
#          BI_NAME
#          CLASS_PL
#          CLASS_PP
#          CLASS_PS
#          CLASS_XS
#          COMM
#          CONST_DW
#          DO_LEVEL
#          DW_AD
#          DW
#          FCN_LV
#          INLINE_LEVEL
#          INT_TYPE
#          MP
#          PTR
#          PTR_TOP
#          SCALAR_TYPE
#          STMT_NUM
#          SYM_FLAGS
#          SYM_LINK1
#          SYT_FLAGS
#          SYT_LINK1
#          SYT_MAX
#          VAR
#          XBFNC
#          XFCAL
#          XLIT
#          XXXND
# EXTERNAL VARIABLES CHANGED:
#          BI_INFO
#          BI_FLAGS
#          FIXF
#          FIXL
#          FOR_DW
#          LOC_P
#          PSEUDO_FORM
#          PSEUDO_TYPE
#          SYM_TAB
# EXTERNAL PROCEDURES CALLED:
#          ERROR
#          FLOATING
#          HALMAT_POP
#          HALMAT_TUPLE
#          PREC_SCALE
#          SAVE_LITERAL
#          SET_BI_XREF
#          SET_XREF_RORS
#          SETUP_VAC
#          STRUCTURE_FCN
#          UPDATE_BLOCK_CHECK
# CALLED BY:
#          SYNTHESIZE
#*************************************************************************

# In other modules I handle the persistence-of-parameter-value issue by creating
# a class with the parameters and possibly the local variables as members.
# Belatedly, I've realized it seems a little cleaner to just treat these things
# as globals.
PSEUDO_PREC = 0


def SETUP_NO_ARG_FCN(optional_PSEUDO_PREC=None):
    # Local I.
    global PSEUDO_PREC
    if optional_PSEUDO_PREC != None:
        PSEUDO_PREC = optional_PSEUDO_PREC
    
    if g.FIXL[g.MP] > g.SYT_MAX:
        g.FIXL[g.MP] = g.FIXL[g.MP] - g.SYT_MAX;
        SET_BI_XREF(g.FIXL[g.MP]);
        g.BI_INFO[0] = g.BI_INFO[g.FIXL[g.MP]];
        g.BI_FLAGS[0] = g.BI_FLAGS[g.FIXL[g.MP]];
        if ((g.BI_FLAGS[0] & 0x10) != 0) and g.BI_FUNC_FLAG:
            # DO CASE SHR(BI_INFO,8)&0x0F;
            bi = SHR(g.BI_INFO[0], 8) & 0x0F
            if bi == 0:
                pass;
            elif bi == 1:
                g.PSEUDO_TYPE[g.PTR[g.MP]] = g.INT_TYPE;
                FLOATING(DATE());
            elif bi == 2:
                # CLOCKTIME
                g.PSEUDO_TYPE[g.PTR[g.MP]] = g.SCALAR_TYPE;
                FLOATING(TIME());
                g.DW[2] = 0x42640000 # This is IBM DP float for 100.0.
                g.DW[3] = 0x00000000
                MONITOR(9, 4);  # CHANGE TO SECONDS
            # END of DO CASE
            g.LOC_P[g.PTR[g.MP]] = SAVE_LITERAL(1, g.DW_AD());
            g.PSEUDO_FORM[g.PTR[g.MP]] = g.XLIT;
        else: 
            if g.BI_FLAGS[0]: 
                ERROR(d.CLASS_XS, 1, \
                      SUBSTR(g.BI_NAME[g.BI_INDX[g.FIXL[g.MP]]], \
                             g.BI_LOC[g.FIXL[g.MP]], 10));
            HALMAT_POP(g.XBFNC, 0, 0, g.FIXL[g.MP]);
            SETUP_VAC(g.MP, SHR(g.BI_INFO[0], 24));
    else:
        if (g.SYT_FLAGS(g.FIXL[g.MP]) & g.ACCESS_FLAG) != 0:
            ERROR(d.CLASS_PS, 7, g.VAR[g.MP]);
        I = g.FIXL[g.MP];
        if g.SYT_LINK1(I) < 0: 
            if g.DO_LEVEL < (-g.SYT_LINK1(I)): 
                ERROR(d.CLASS_PL, 9, g.VAR[g.MP]);
        elif g.SYT_LINK1(I) == 0: 
            g.SYT_LINK1(I, g.STMT_NUM());
        UPDATE_BLOCK_CHECK(g.MP);
        STRUCTURE_FCN();
        HALMAT_TUPLE(g.XFCAL, 0, g.MP, 0, g.FCN_LV + 1);
        SETUP_VAC(g.MP, g.PSEUDO_TYPE[g.PTR_TOP]);
        HALMAT_POP(g.XXXND, 0, 0, g.FCN_LV + 1);
        if g.INLINE_LEVEL > 0: 
            ERROR(d.CLASS_PP, 8);
        SET_XREF_RORS(g.MP, 0x6000);
    if PSEUDO_PREC > 0:
        PREC_SCALE(PSEUDO_PREC, g.PSEUDO_TYPE[g.PTR_TOP]);
        PSEUDO_PREC = 0;
    g.FIXF[g.MP] = 0;
# END SETUP_NO_ARG_FCN;
