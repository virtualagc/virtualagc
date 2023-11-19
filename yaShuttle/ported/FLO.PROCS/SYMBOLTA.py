#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   SYMBOLTA.py
   Purpose:    Part of the HAL/S-FC compiler's HALMAT optimization
               process.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-11-19 RSB  Ported from XPL.
"""

from xplBuiltins import *
from HALINCL.SPACELIB import *
import g
import HALINCL.COMMON as h
import HALINCL.VMEM2 as v2

#*************************************************************************
# PROCEDURE NAME:  SYMBOL_TABLE_PREPASS
# MEMBER NAME:     SYMBOLTA
# LOCAL DECLARATIONS:
#          ARG               BIT(16)
#          CELL              FIXED
#          I                 BIT(16)
#          INPUT_PARMS       BIT(16)
#          J                 BIT(16)
#          LAST_PARM         LABEL
#          PARM_INX          BIT(16)
#          PARMS(100)        BIT(16)
# EXTERNAL VARIABLES REFERENCED:
#          ACTUAL_SYMBOLS
#          ASSIGN_FLAG
#          COMM
#          ENDSCOPE_FLAG
#          EQUATE_LABEL
#          FUNC_CLASS
#          INPUT_FLAG
#          MISC_NAME_FLAG
#          MODF
#          NAME_FLAG
#          PROC_LABEL
#          STRUCTURE
#          SYM_CLASS
#          SYM_FLAGS
#          SYM_LENGTH
#          SYM_NUM
#          SYM_PTR
#          SYM_TAB
#          SYM_TYPE
#          SYM_VPTR
#          SYT_CLASS
#          SYT_DIMS
#          SYT_FLAGS
#          SYT_NUM
#          SYT_PTR
#          SYT_TYPE
#          SYT_VPTR
#          VAR_CLASS
# EXTERNAL VARIABLES CHANGED:
#          CELLSIZE
#          EXP_VARS
#          SYM_ADD
#          SYT_VPTRS
#          VAR_INX
#          VMEM_H
#          VPTR_INX
#          WORD_STACK
# EXTERNAL PROCEDURES CALLED:
#          GET_CELL
# CALLED BY:
#          INITIALIZE
#*************************************************************************
''' ROUTINE TO CREATE PROC/FUNC INVOCATION CELLS AND TO ALLOCATE AN AREA IN
COMMON FOR THE PASSAGE OF VMEM PTRS FOR SYMBOLS TO PHASE 3 '''


def SYMBOL_TABLE_PREPASS():
    # Locals: PARM_INX, INPUT_PARMS, I, ARG, J, PARMS, CELL.
    PARM_INX = 0  # Wasn't initialized in XPL
    PARMS = [0] (1 + 100)
    
    goto = None
    
    for I in range(1, g.ACTUAL_SYMBOLS() + 1):
        if g.SYT_CLASS(I) == g.FUNC_CLASS | g.SYT_TYPE(I) == g.PROC_LABEL:  # DO
            ARG = g.SYT_PTR(I);
            while (g.SYT_FLAGS(ARG) & g.INPUT_FLAG) != 0:
                PARM_INX = PARM_INX + 1;
                PARMS[PARM_INX] = ARG;
                if (g.SYT_FLAGS(ARG) & g.ENDSCOPE_FLAG) != 0:  # DO
                    INPUT_PARMS = PARM_INX;
                    goto = "LAST_PARM";
                # END
                else:
                    ARG = ARG + 1;
            # END
            if goto == None:
                INPUT_PARMS = PARM_INX;
                while (g.SYT_FLAGS(ARG) & g.ASSIGN_FLAG) != 0:
                    PARM_INX = PARM_INX + 1;
                    PARMS[PARM_INX] = ARG;
                    if (g.SYT_FLAGS(ARG) & g.ENDSCOPE_FLAG) != 0:
                        goto = "LAST_PARM";
                    else:
                        ARG = ARG + 1;
                # END
            if goto == "LAST_PARM": goto = None
            if PARM_INX > 0:  # DO
                g.CELLSIZE = SHL(PARM_INX + 2, 1);
                CELL = GET_CELL(CELLSIZE, ADDR(g.VMEM_H), v2.MODF);
                g.VMEM_H(0, g.CELLSIZE);
                g.VMEM_H(1, SHL(PARM_INX, 8) + INPUT_PARMS);
                for J  in range(1, PARM_INX + 1):
                    g.VMEM_H(J + 1, PARMS[J]);
                # END
                PARM_INX = 0;
            # END
            else:  # DO
                CELL = GET_CELL(4, ADDR(g.VMEM_H), v2.MODF);
                g.VMEM_H(0, 4);
            # END
            g.SYT_VPTRS = g.SYT_VPTRS + 1;
            VAR_INX = VAR_INX + 1;
            g.EXP_VARS[VAR_INX] = I;
            g.WORD_STACK[VAR_INX] = CELL;
        # END
        elif (g.SYT_FLAGS(I) & g.NAME_FLAG) != 0: g.SYT_VPTRS = g.SYT_VPTRS + 1;
        elif g.SYT_CLASS(I) == g.VAR_CLASS and g.SYT_TYPE(I) == g.STRUCTURE:  # DO
            if (g.SYT_FLAGS(g.SYT_DIMS(I)) & g.MISC_NAME_FLAG) != 0:
                g.SYT_VPTRS = g.SYT_VPTRS + 1;
        # END
        elif g.SYT_TYPE(I) == g.EQUATE_LABEL: g.SYT_VPTRS = g.SYT_VPTRS + 1;
    # END
    ALLOCATE_SPACE(h.SYM_ADD, g.SYT_VPTRS);
    NEXT_ELEMENT(h.SYM_ADD);
    for I  in range(1, VAR_INX + 1):
        NEXT_ELEMENT(h.SYM_ADD);
        g.SYT_NUM(I, g.EXP_VARS[I]);
        g.SYT_VPTR(I, g.WORD_STACK[I]);
    # END
    g.VPTR_INX = VAR_INX;
    VAR_INX = 0;
# END SYMBOL_TABLE_PREPASS;
