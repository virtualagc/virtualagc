#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   REDUCESU.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-28 RSB  Ported from XPL
            2026-03-12 RSB  pylint warned that `T1` and `T2` might be used 
                            before assignment.  It's no longer clear to me at
                            a glance that they don't need persistence, so I 
                            added that as well.
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ERROR import ERROR
from CHECKSUB import CHECK_SUBSCRIPT

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  REDUCE_SUBSCRIPT                                       */
 /* MEMBER NAME:     REDUCESU                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          MODE              BIT(16)                                      */
 /*          SIZE              BIT(16)                                      */
 /*          FLAG              BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          IND_LINK_SAVE     BIT(16)                                      */
 /*          SR_ERR1           LABEL                                        */
 /*          SR_ERR2           LABEL                                        */
 /*          STEPPER           LABEL                                        */
 /*          T1                BIT(16)                                      */
 /*          T2                BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          CLASS_SR                                                       */
 /*          MP                                                             */
 /*          PTR                                                            */
 /*          VAR                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          IND_LINK                                                       */
 /*          FIX_DIM                                                        */
 /*          INX                                                            */
 /*          NEXT_SUB                                                       */
 /*          PSEUDO_LENGTH                                                  */
 /*          VAL_P                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          CHECK_SUBSCRIPT                                                */
 /* CALLED BY:                                                              */
 /*          ATTACH_SUB_ARRAY                                               */
 /*          ATTACH_SUB_COMPONENT                                           */
 /*          ATTACH_SUB_STRUCTURE                                           */
 /*          END_ANY_FCN                                                    */
 /*          END_SUBBIT_FCN                                                 */
 /***************************************************************************/
'''

class cREDUCE_SUBSCRIPT:

    def __init__(self):
        self.T1 = 0
        self.T2 = 0
ll = cREDUCE_SUBSCRIPT()

def REDUCE_SUBSCRIPT(MODE, SIZE, FLAG = g.FALSE):
    # Locals: T1, T2, IND_LINK_SAVE
    
    goto = None
    
    IND_LINK_SAVE = g.IND_LINK;
    
    def STEPPER():
        g.NEXT_SUB = g.NEXT_SUB + 1;
        if leftToRightAssignments:
            g.PSEUDO_LENGTH[g.IND_LINK] = g.NEXT_SUB
            g.IND_LINK = g.NEXT_SUB;
        else:
            g.IND_LINK = g.NEXT_SUB;
            g.PSEUDO_LENGTH[g.IND_LINK] = g.NEXT_SUB
        if g.INX[g.NEXT_SUB] != 1:
             if MODE == 0x8: 
                 g.VAL_P[g.PTR[g.MP]] = g.VAL_P[g.PTR[g.MP]] | 0x2000;
             else: 
                 g.VAL_P[g.PTR[g.MP]] = g.VAL_P[g.PTR[g.MP]] | 0x10;
        g.INX[g.NEXT_SUB] = g.INX[g.NEXT_SUB] | MODE;
        return g.INX[g.NEXT_SUB] & 0x3;
    
    # DO CASE STEPPER;
    st = STEPPER()
    firstTry = True
    while firstTry or goto != None:
        firstTry = False
        if st == 0 and goto == None:
            #  ASTERISK
            g.FIX_DIM = SIZE;
        elif st == 1 and goto == None:
            #  INDEX
            CHECK_SUBSCRIPT(MODE, SIZE, 0);
            g.FIX_DIM = 1;
        elif (st == 2 and goto == None) or goto != None:
            #  TO-PARTITION
            if goto == None:
                ll.T1 = CHECK_SUBSCRIPT(MODE, SIZE, 0);
                g.VAL_P[g.NEXT_SUB] = 1;
                STEPPER();
                ll.T2 = CHECK_SUBSCRIPT(MODE, SIZE, 0);
            if (not 0 != (1 & FLAG) and goto == None) or goto != None:
                if ((ll.T1 < 0 or ll.T2 < 0) and goto == None) or goto == "SR_ERR1":
                    if goto == "SR_ERR1": goto = None
                    ERROR(d.CLASS_SR, 1, g.VAR[g.MP]);
                    g.FIX_DIM = 2;
                elif ll.T2 == ll.T1 and goto == None:
                    if FLAG == 2: 
                        goto = "SR_ERR2"
                        continue
                    g.FIX_DIM = 1;
                    g.IND_LINK = g.NEXT_SUB - 1;
                    g.VAL_P[g.IND_LINK] = 0
                    g.PSEUDO_LENGTH[g.IND_LINK] = 0;
                    g.INX[g.IND_LINK] = MODE | 0x1;
                elif (ll.T2 < ll.T1 and goto == None) or goto == "SR_ERR2":
                    if goto == "SR_ERR2": goto = None
                    ERROR(d.CLASS_SR, 2, g.VAR[g.MP]);
                    g.FIX_DIM = 2;
                else: 
                    g.FIX_DIM = ll.T2 - ll.T1 + 1;
            elif (ll.T2 > 0 and ll.T2 < ll.T1): 
                goto = "SR_ERR2"
                continue
        elif st == 3 and goto == None:
            #  AT-PARTITION
            ll.T1 = CHECK_SUBSCRIPT(MODE, SIZE, 1);
            g.VAL_P[g.NEXT_SUB] = 1;
            STEPPER();
            ll.T2 = CHECK_SUBSCRIPT(MODE, SIZE, 0);
            if not (FLAG & 1):
                if ll.T1 < 0: 
                    goto = "SR_ERR1"
                    continue
                if ll.T2 < 0: 
                    ll.T2 = ll.T1;
                else: 
                    ll.T2 = ll.T1 + ll.T2 - 1;
                if (ll.T2 > SIZE and SIZE > 0) or ll.T1 == 0: 
                    goto = "SR_ERR2"
                    continue
                if ll.T1 == 1:
                    if FLAG == 2: 
                        goto = "SR_ERR2"
                        continue
                    g.INX[g.NEXT_SUB] = MODE | 0x1;
                    g.PSEUDO_LENGTH[IND_LINK_SAVE] = g.NEXT_SUB;
                g.FIX_DIM = ll.T1;
            #************ GENERATE SR1 & SR2 ERRORS FOR CHARACTER VARIABLES*****
            else:  # FLAG=1*/
                if ll.T1 < -1: 
                    goto = "SR_ERR1"
                    continue
                if (ll.T1 > SIZE and SIZE > 0): 
                    goto = "SR_ERR2"
                    continue
                else: 
                    ll.T2 = ll.T1 + ll.T2 - 1;
                if (ll.T2 > SIZE and SIZE > 0): 
                    goto = "SR_ERR2"
                    continue
            #*******************************************************************
    # END of DO CASE
    FLAG = g.FALSE;
    g.VAL_P[g.NEXT_SUB] = 0;
