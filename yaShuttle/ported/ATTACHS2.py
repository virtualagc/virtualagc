#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   ATTACHS2.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-28 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
import HALINCL.COMMON as h
import HALINCL.CERRDECL as d
from ERROR import ERROR
from ASTSTACK import AST_STACKER
from REDUCESU import REDUCE_SUBSCRIPT
from SLIPSUBS import SLIP_SUBSCRIPT

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  ATTACH_SUB_ARRAY                                       */
 /* MEMBER NAME:     ATTACHS2                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          SUB#              BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          ARR_SLIP          LABEL                                        */
 /*          K                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          EXT_ARRAY                                                      */
 /*          CLASS_SC                                                       */
 /*          FALSE                                                          */
 /*          FIX_DIM                                                        */
 /*          FIXL                                                           */
 /*          MP                                                             */
 /*          PTR                                                            */
 /*          SYM_ARRAY                                                      */
 /*          SYM_TAB                                                        */
 /*          SYT_ARRAY                                                      */
 /*          TRUE                                                           */
 /*          VAR                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          INX                                                            */
 /*          TEMP                                                           */
 /*          VAL_P                                                          */
 /*          VAR_ARRAYNESS                                                  */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          AST_STACKER                                                    */
 /*          ERROR                                                          */
 /*          REDUCE_SUBSCRIPT                                               */
 /*          SLIP_SUBSCRIPT                                                 */
 /* CALLED BY:                                                              */
 /*          ATTACH_SUBSCRIPT                                               */
 /***************************************************************************/
'''


def ATTACH_SUB_ARRAY(SUBp):
    # Locals: I, K
    goto = "firstTry"
    
    if SUBp < 0: return g.TRUE;
    I = g.PTR[g.MP];
    g.INX[g.INX[0]] = g.INX[g.INX[0]] - SUBp;
    while goto != None:
        if goto == "firstTry": goto = None
        if g.SYT_ARRAY(g.FIXL[g.MP]) <= 0 or goto == "ARR_SLIP":
            if goto == "ARR_SLIP": goto = None
            if SUBp > 0:
               ERROR(d.CLASS_SC, 2, g.VAR[g.MP]);
               SLIP_SUBSCRIPT(SUBp);
        else: 
            K = h.EXT_ARRAY[g.SYT_ARRAY(g.FIXL[g.MP])];
            if SUBp == 0: 
                AST_STACKER(0x4, K);
            elif SUBp < K:
                ERROR(d.CLASS_SC, 3, g.VAR[g.MP]);
                SLIP_SUBSCRIPT(SUBp);
            else:
                g.VAL_P[I] = g.VAL_P[I] | 0x8;
                SUBp = SUBp - K;
                g.TEMP = 0;
                for K in range(g.VAR_ARRAYNESS[0] - K + 1, g.VAR_ARRAYNESS[0] - SUBp + 1):
                    REDUCE_SUBSCRIPT(0x4, g.VAR_ARRAYNESS[K]);
                    g.VAR_ARRAYNESS[K] = g.FIX_DIM;
                    g.TEMP = g.TEMP or (g.FIX_DIM != 1);
                if g.TEMP == 0: 
                    g.VAL_P[I] = g.VAL_P[I] & 0xFFFE;
                else: 
                    g.VAL_P[I] = g.VAL_P[I] | 0x10;
                goto = "ARR_SLIP"
                continue
    return g.FALSE;
