#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   ATTACHSU.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-28 RSB  Ported.
            2023-10-17 RSB  2nd attempt.
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d 
from ERROR import ERROR
from ASTSTACK import AST_STACKER
from REDUCESU import REDUCE_SUBSCRIPT
from SLIPSUBS import SLIP_SUBSCRIPT

#*************************************************************************
# PROCEDURE NAME:  ATTACH_SUB_COMPONENT
# MEMBER NAME:     ATTACHSU
# INPUT PARAMETERS:
#          SUB#              BIT(16)
# LOCAL DECLARATIONS:
#          FIXING_BIT_AND_CHAR  LABEL
#          COMP_SLIP         LABEL
#          I                 BIT(16)
#          T1                BIT(16)
# EXTERNAL VARIABLES REFERENCED:
#          FIX_DIM
#          CLASS_SC
#          INX
#          MAT_TYPE
#          MP
#          NEXT_SUB
#          PTR
#          SCALAR_TYPE
#          VAR
#          VEC_TYPE
# EXTERNAL VARIABLES CHANGED:
#          PSEUDO_TYPE
#          PSEUDO_LENGTH
#          VAL_P
# EXTERNAL PROCEDURES CALLED:
#          AST_STACKER
#          ERROR
#          REDUCE_SUBSCRIPT
#          SLIP_SUBSCRIPT
# CALLED BY:
#          ATTACH_SUBSCRIPT
#*************************************************************************


def ATTACH_SUB_COMPONENT(SUBp):
    # Locals: I, T1
    
    goto = None
    
    I = g.PTR[g.MP];
    if SUBp > 0: 
        firstTry = True
        while firstTry or goto != None:
            firstTry = False
            # DO CASE g.PSEUDO_TYPE[I];
            pt = g.PSEUDO_TYPE[I]
            if pt == 0 and goto == None:
                pass;
            elif pt == 1 or goto != None:
            #  BIT
            # DO
                if goto == None:
                    REDUCE_SUBSCRIPT(0x0, g.PSEUDO_LENGTH[I]);
                    g.PSEUDO_LENGTH[I] = g.FIX_DIM;
                if goto == "FIXING_BIT_AND_CHAR": goto = None
                if goto == None:
                    g.VAL_P[I] = g.VAL_P[I] | 0x10;
                    SUBp = SUBp - 1;
                    if g.INX[g.NEXT_SUB] == 0 and not (g.VAL_P[I] & 1): 
                        g.VAL_P[I] = g.VAL_P[I] & 0xFFEF;
                if goto == "COMP_SLIP": goto = None
                g.VAL_P[I] = g.VAL_P[I] | 0x8;
                if SUBp > 0:  # DO
                    ERROR(d.CLASS_SC, 4, g.VAR[g.MP]);
                    SLIP_SUBSCRIPT(SUBp);
                # END
            # END
            elif pt == 2 and goto == None:
            #  CHARACTER
            # DO
                REDUCE_SUBSCRIPT(0x0, g.PSEUDO_LENGTH[I], 1);
                goto = "FIXING_BIT_AND_CHAR";
                continue
            # END
            elif pt == 3 and goto == None:
            #  MATRIX
            # DO
                if SUBp == 1:  # DO
                    ERROR(d.CLASS_SC, 5, g.VAR[g.MP]);
                    SLIP_SUBSCRIPT(SUBp);
                # END
                else:  # DO
                    REDUCE_SUBSCRIPT(0x0, SHR(g.PSEUDO_LENGTH[I], 8), 2);
                    T1 = g.FIX_DIM;
                    REDUCE_SUBSCRIPT(0x0, g.PSEUDO_LENGTH[I] & 0xFF, 2);
                    if T1 == 1 and g.FIX_DIM == 1:  # DO
                        g.PSEUDO_TYPE[I] = g.SCALAR_TYPE;
                        g.PSEUDO_LENGTH[I] = 0;
                    # END
                    elif T1 == 1 or g.FIX_DIM == 1:  # DO
                        g.PSEUDO_TYPE[I] = g.VEC_TYPE;
                        g.PSEUDO_LENGTH[I] = T1 + g.FIX_DIM - 1;
                    # END
                    else: g.PSEUDO_LENGTH[I] = SHL(T1 & 0xFF, 8) | g.FIX_DIM;
                    if g.PSEUDO_TYPE[I] != g.SCALAR_TYPE: 
                        g.VAL_P[I] = g.VAL_P[I] | 0x10;
                    SUBp = SUBp - 2;
                    goto = "COMP_SLIP";
                    continue
                # END
            # END
            elif pt == 4 and goto == None:
            #  VECTOR
            # DO
                REDUCE_SUBSCRIPT(0x0, g.PSEUDO_LENGTH[I], 2);
                g.PSEUDO_LENGTH[I] = g.FIX_DIM;
                if g.FIX_DIM == 1:  # DO
                    g.PSEUDO_TYPE[I] = g.SCALAR_TYPE;
                    g.PSEUDO_LENGTH[I] = 0;
                # END
                else: g.VAL_P[I] = g.VAL_P[I] | 0x10;
                SUBp = SUBp - 1;
                goto = "COMP_SLIP";
                continue
            # END
            # END of DO CASE
        # End of while goto != None
    else:  # DO
        if g.PSEUDO_TYPE[I] == g.MAT_TYPE: SUBp = 2;
        else: SUBp = 1;
        AST_STACKER(0x0, SUBp);
    # END
# END ATTACH_SUB_COMPONENT;
