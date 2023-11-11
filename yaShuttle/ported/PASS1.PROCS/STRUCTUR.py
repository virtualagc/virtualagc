#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   STRUCTUR.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-10-26 RSB  Ported from XPL
"""

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
import HALINCL.COMMON as h
from ERROR import ERROR

#*************************************************************************
# PROCEDURE NAME:  STRUCTURE_COMPARE
# MEMBER NAME:     STRUCTUR
# INPUT PARAMETERS:
#          A                 BIT(16)
#          B                 BIT(16)
#          ERR_CLASS         BIT(16)
#          ERR_NUM           BIT(16)
# LOCAL DECLARATIONS:
#          AX                BIT(16)
#          BX                BIT(16)
#          I                 BIT(16)
#          STRUC_ERR(1601)   LABEL
# EXTERNAL VARIABLES REFERENCED:
#          EVIL_FLAG
#          EXT_ARRAY
#          FOREVER
#          SM_FLAGS
#          SYM_ARRAY
#          SYM_FLAGS
#          SYM_LENGTH
#          SYM_LINK1
#          SYM_LINK2
#          SYM_TAB
#          SYM_TYPE
#          SYT_ARRAY
#          SYT_FLAGS
#          SYT_LINK1
#          SYT_LINK2
#          SYT_TYPE
#          VAR_LENGTH
# EXTERNAL PROCEDURES CALLED:
#          ERROR
# CALLED BY:
#          SETUP_CALL_ARG
#          SYNTHESIZE
#*************************************************************************


def STRUCTURE_COMPARE(A, B, ERR_CLASS, ERR_NUM):
    # Locals: AX, BX, I.
    goto = None
    
    if ((g.SYT_FLAGS(A) | g.SYT_FLAGS(B)) & g.EVIL_FLAG) != 0: return;
    if A == B: return;
    AX = A;
    BX = B;
    while True:
        while g.SYT_LINK1(AX) > 0:
            AX = g.SYT_LINK1(AX);
            BX = g.SYT_LINK1(BX);
            if BX == 0: 
                goto = "STRUC_ERR";
                break
        # END
        if goto != None:
            break
        if g.SYT_LINK1(BX) != 0: 
            goto = "STRUC_ERR";
            break
        if g.SYT_TYPE(AX) != g.SYT_TYPE(BX): 
            goto = "STRUC_ERR";
            break
        if g.VAR_LENGTH(AX) != g.VAR_LENGTH(BX): 
            goto = "STRUC_ERR";
            break
        if (g.SYT_FLAGS(AX) & g.SM_FLAGS) != (g.SYT_FLAGS(BX) & g.SM_FLAGS):
            goto = "STRUC_ERR";
            break
        for I in range(0, h.EXT_ARRAY[g.SYT_ARRAY(AX)] + 1):
            if h.EXT_ARRAY[g.SYT_ARRAY(AX) + I] \
                    != h.EXT_ARRAY[g.SYT_ARRAY(BX) + I]:
                goto = "STRUC_ERR";
                break
        if goto != None:
            break
        # END
        while g.SYT_LINK2(AX) < 0:
            AX = -g.SYT_LINK2(AX);
            BX = -g.SYT_LINK2(BX);
            if AX == A:  # DO
                if BX != B: 
                    goto = "STRUC_ERR";
                    break
                return;
            # END
            if BX <= 0: 
                goto = "STRUC_ERR";
                break
        # END
        if goto != None:
            break
        AX = g.SYT_LINK2(AX);
        BX = g.SYT_LINK2(BX);
        if BX <= 0: 
            goto = "STRUC_ERR";
            break
    # END
    if goto == "STRUC_ERR": goto = None
    ERROR(ERR_CLASS, ERR_NUM);
# END STRUCTURE_COMPARE;
