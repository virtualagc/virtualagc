#!/usr/bin/env python3
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   ERRORSUB.xpl
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
   Language:   XPL.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
   Note:       Inline comments beginning with "/*/" were created by the
               Virtual AGC Project. Inline comments beginning merely with
               "/*" are from the original Space Shuttle development.
"""

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
import HALINCL.COMMON as h
from ERROR    import ERROR
from MAKEFIXE import MAKE_FIXED_LIT

#*************************************************************************
# PROCEDURE NAME:  ERROR_SUB
# MEMBER NAME:     ERRORSUB
# INPUT PARAMETERS:
#          MODE              BIT(16)
# LOCAL DECLARATIONS:
#          BAD_ERROR_SUB     LABEL
#          ERROR_SS_FIX(1597)  LABEL
#          RUN_ERR_MAX(2)    BIT(16)
# EXTERNAL VARIABLES REFERENCED:
#          BLOCK_SYTREF
#          CLASS_RE
#          EXT_ARRAY_PTR
#          INX
#          MP
#          NEST
#          PSEUDO_LENGTH
#          PTR
#          SYM_ARRAY
#          SYM_TAB
#          SYT_ARRAY
#          VAL_P
#          XIMD
#          XLIT
#          XSET
# EXTERNAL VARIABLES CHANGED:
#          EXT_ARRAY
#          FIXV
#          LOC_P
#          ON_ERROR_PTR
#          PSEUDO_FORM
#          STMT_TYPE
#          TEMP
# EXTERNAL PROCEDURES CALLED:
#          ERROR
#          MAKE_FIXED_LIT
# CALLED BY:
#          SYNTHESIZE
#*************************************************************************

RUN_ERR_MAX = [0, 127, 63];


def ERROR_SUB(MODE):
    # Local: RUN_ERR_MAX.
    global RUN_ERR_MAX

    goto = None

    def ERROR_SS_FIX(LOC):
        # No locals.
        global RUN_ERR_MAX
        nonlocal goto
        
        RUN_ERR_MAX[0] = RUN_ERR_MAX[LOC];
        LOC = LOC + g.TEMP;
        if g.VAL_P[LOC] != 0: 
            goto = "BAD_ERROR_SUB";
            return LOC
        if g.INX[LOC] != 1: 
            goto = "BAD_ERROR_SUB";
            return LOC
        if g.PSEUDO_FORM[LOC] == g.XIMD: LOC = g.LOC_P[LOC];
        elif g.PSEUDO_FORM[LOC] == g.XLIT: LOC = MAKE_FIXED_LIT(g.LOC_P[LOC]);
        else: 
            goto = "BAD_ERROR_SUB";
            return LOC
        if (LOC < 0) or (LOC > RUN_ERR_MAX[0]): 
            goto = "BAD_ERROR_SUB";
            return LOC
        return LOC;
    # END ERROR_SS_FIX;
    
    g.TEMP = g.PTR[g.MP + 2];
    g.FIXV[g.MP] = 0x3FFF;
    g.LOC_P[g.TEMP] = 0xFF;
    goto = "firstTry"
    while goto != None:
        if goto == "firstTry": goto = None
        if g.PSEUDO_FORM[g.TEMP] != 0 or goto == "BAD_ERROR_SUB":  # DO
            if goto == "BAD_ERROR_SUB": goto = None
            ERROR(d.CLASS_RE, MODE);
            return;
        # END
        g.PSEUDO_FORM[g.TEMP] = g.XIMD;
        if MODE == 2:  # DO
            #  SEND ERROR
            if g.INX[g.TEMP] != 2: 
                goto = "BAD_ERROR_SUB";
                continue
            if g.PSEUDO_LENGTH[g.TEMP] != 0: 
                goto = "BAD_ERROR_SUB";
                continue
            if g.VAL_P[g.TEMP] != 1: 
                goto = "BAD_ERROR_SUB";
                continue
            g.XSET(0xE);
            g.LOC_P[g.TEMP] = ERROR_SS_FIX(1);
            g.FIXV[g.MP] = ERROR_SS_FIX(2) | SHL(g.LOC_P[g.TEMP], 6);
        # END
        else:  # DO
            #  ON OR OFF ERROR
            g.XSET(0xF);
            if g.INX[g.TEMP] > 2: 
                goto = "BAD_ERROR_SUB";
                continue
            # DO CASE INX[TEMP];
            if g.INX[g.TEMP] == 0:
                pass;
            elif g.INX[g.TEMP] == 1:
                # DO
                if g.PSEUDO_LENGTH[g.TEMP] > 0: 
                    goto = "BAD_ERROR_SUB";
                    break
                if not g.VAL_P[g.TEMP]: 
                    goto = "BAD_ERROR_SUB";
                    break
                g.LOC_P[g.TEMP] = ERROR_SS_FIX(1);
                g.FIXV[g.MP] = SHL(g.LOC_P[g.TEMP], 6) | 0x3F;
                # END
            elif g.INX[g.TEMP] == 2:
                # DO
                if g.PSEUDO_LENGTH[g.TEMP] != 0: 
                    goto = "BAD_ERROR_SUB";
                    break
                if g.VAL_P[g.TEMP] != 1: 
                    goto = "BAD_ERROR_SUB";
                    break
                g.LOC_P[g.TEMP] = ERROR_SS_FIX(1);
                g.FIXV[g.MP] = ERROR_SS_FIX(2) | SHL(g.LOC_P[g.TEMP], 6);
                # END
            # END DO CASE
            if goto != None:
                continue
            MODE = -g.SYT_ARRAY(g.BLOCK_SYTREF[g.NEST]);
            while MODE > g.ON_ERROR_PTR:
                MODE = MODE - 1;
                if g.FIXV[g.MP] == h.EXT_ARRAY[MODE]: MODE = 0;
            # END
            if MODE > 0:  # DO
                if g.ON_ERROR_PTR == g.EXT_ARRAY_PTR: ERROR(d.CLASS_RE, 3);
                else:  # DO
                    g.ON_ERROR_PTR = g.ON_ERROR_PTR - 1;
                    h.EXT_ARRAY[g.ON_ERROR_PTR] = g.FIXV[g.MP];
                # END
            # END
        # END
# END ERROR_SUB;
