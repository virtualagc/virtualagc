#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   ARITHLIT.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from GETLITER import GET_LITERAL

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  ARITH_LITERAL                                          */
 /* MEMBER NAME:     ARITHLIT                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC1              BIT(16)                                      */
 /*          LOC2              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CONST_DW                                                       */
 /*          DW                                                             */
 /*          FALSE                                                          */
 /*          LIT_PG                                                         */
 /*          LITERAL2                                                       */
 /*          LITERAL3                                                       */
 /*          LIT2                                                           */
 /*          LIT3                                                           */
 /*          LOC_P                                                          */
 /*          PSEUDO_FORM                                                    */
 /*          PTR                                                            */
 /*          TRUE                                                           */
 /*          XLIT                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FOR_DW                                                         */
 /*          LIT_PTR                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          GET_LITERAL                                                    */
 /* CALLED BY:                                                              */
 /*          ADD_AND_SUBTRACT                                               */
 /*          END_ANY_FCN                                                    */
 /*          MULTIPLY_SYNTHESIZE                                            */
 /*          PREC_SCALE                                                     */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''

class cARITH_LITERAL:
    def __init__(self):
        self.PWR_MODE = None
lARITH_LITERAL = cARITH_LITERAL()

def ARITH_LITERAL(LOC1, LOC2, PWR_MODE=None):
    # PWR_MODE is optional and seems to need its persistence managed..
    l = lARITH_LITERAL
    if PWR_MODE != None:
        l.PWR_MODE = PWR_MODE
          
    if g.PSEUDO_FORM[g.PTR[LOC1]] != g.XLIT: 
        return g.FALSE;
    g.LIT_PTR=GET_LITERAL(g.LOC_P[g.PTR[LOC1]]);
    # IF EITHER LITERAL IS A DOUBLE THEN SET DOUBLELIT = TRUE
    # SO THE COMPILER WILL KNOW TO CHANGE LIT1 (OF THE RESULT)
    # TO 5 LATER ON.  THE EXCEPTION IS WHEN THE CALCULATION IS
    # AN EXPONENTIAL (PWR_MODE=TRUE).  IN THIS CASE, IF THE
    # EXPONENT IS AN INTEGER THEN THE BASE DETERMINES THE
    # PRECISION.  BUT IF THE EXPONENT IS A SCALAR THEN EITHER
    # MAY DETERMINE THE PRECISION.
    if ((g.TYPE==0) and (g.FACTORED_TYPE==0)) and (g.LIT1(g.LIT_PTR)==5):
        g.DOUBLELIT = g.TRUE;
    g.DW[0]=g.LIT2(g.LIT_PTR);
    g.DW[1]=g.LIT3(g.LIT_PTR);
    if LOC2==0: 
        return g.TRUE;
    if g.PSEUDO_FORM[g.PTR[LOC2]]!=g.XLIT: 
        return g.FALSE;
    g.LIT_PTR=GET_LITERAL(g.LOC_P[g.PTR[LOC2]]);
    if ((g.TYPE==0) and (g.FACTORED_TYPE==0)) and (g.LIT1(g.LIT_PTR)==5): 
        if (l.PWR_MODE and (g.PSEUDO_TYPE[g.PTR[g.SP]]!=g.INT_TYPE)) or \
                not l.PWR_MODE:
            g.DOUBLELIT = g.TRUE;
    g.DW[2]=g.LIT2(g.LIT_PTR);
    g.DW[3]=g.LIT3(g.LIT_PTR);
    l.PWR_MODE = g.FALSE;
    return g.TRUE;
