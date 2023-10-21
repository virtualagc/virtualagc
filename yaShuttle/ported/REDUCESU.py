#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   REDUCESU.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-28 RSB  Ported from XPL
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


def REDUCE_SUBSCRIPT(MODE, SIZE, FLAG = g.FALSE):
    # Locals: T1, T2, IND_LINK_SAVE
      
    IND_LINK_SAVE = g.IND_LINK;
    
    def STEPPER():
        g.NEXT_SUB = g.NEXT_SUB + 1;
        g.PSEUDO_LENGTH[g.IND_LINK] = g.NEXT_SUB
        g.IND_LINK = g.NEXT_SUB;
        if g.INX[g.NEXT_SUB] != 1:
             if MODE == 0x8: 
                 g.VAL_P[g.PTR[g.MP]] = g.VAL_P[g.PTR[g.MP]] | 0x2000;
             else: 
                 g.VAL_P[g.PTR[g.MP]] = g.VAL_P[g.PTR[g.MP]] | 0x10;
        g.INX[g.NEXT_SUB] = g.INX[g.NEXT_SUB] | MODE;
        return g.INX[g.NEXT_SUB] & 0x3;
    
    # DO CASE STEPPER;
    st = STEPPER()
    goto_SR_ERR1 = False
    goto_SR_ERR2 = False
    firstTry = True
    while firstTry or goto_SR_ERR1 or goto_SR_ERR2:
        firstTry = False
        neither = not (goto_SR_ERR1 or goto_SR_ERR2)
        if st == 0 and neither:
            #  ASTERISK
            g.FIX_DIM = SIZE;
        elif st == 1 and neither:
            #  INDEX
            CHECK_SUBSCRIPT(MODE, SIZE, 0);
            g.FIX_DIM = 1;
        elif st == 2 or not neither:
            #  TO-PARTITION
            if neither:
                T1 = CHECK_SUBSCRIPT(MODE, SIZE, 0);
                g.VAL_P[g.NEXT_SUB] = 1;
                STEPPER();
                T2 = CHECK_SUBSCRIPT(MODE, SIZE, 0);
            if not FLAG or not neither:
                if T1 < 0 or T2 < 0 or goto_SR_ERR1:
                    goto_SR_ERR1 = False
                    ERROR(CLASS_SR, 1, g.VAR[g.MP]);
                    g.FIX_DIM = 2;
                elif T2 == T1 and neither:
                    if FLAG == 2: 
                        goto_SR_ERR2 = True
                        continue
                    g.FIX_DIM = 1;
                    g.IND_LINK = g.NEXT_SUB - 1;
                    g.VAL_P[g.IND_LINK] = 0
                    g.PSEUDO_LENGTH[g.IND_LINK] = 0;
                    g.INX[g.IND_LINK] = MODE | 0x1;
                elif T2 < T1 or goto_SR_ERR2:
                    goto_SR_ERR2 = False
                    ERROR(CLASS_SR, 2, g.VAR[g.MP]);
                    g.FIX_DIM = 2;
                else: 
                    g.FIX_DIM = T2 - T1 + 1;
            elif (T2 > 0 and T2 < T1): 
                goto_SR_ERR2 = True
                continue
        elif st == 3:
            #  AT-PARTITION
            T1 = CHECK_SUBSCRIPT(MODE, SIZE, 1);
            g.VAL_P[g.NEXT_SUB] = 1;
            STEPPER();
            T2 = CHECK_SUBSCRIPT(MODE, SIZE, 0);
            if not FLAG:
                if T1 < 0: 
                    goto_SR_ERR1 = True
                    continue
                if T2 < 0: 
                    T2 = T1;
                else: 
                    T2 = T1 + T2 - 1;
                if (T2 > SIZE and SIZE > 0) or T1 == 0: 
                    goto_SR_ERR2 = True
                    continue
                if T1 == 1:
                    if FLAG == 2: 
                        goto_SR_ERR2 = True
                        continue
                    g.INX[g.NEXT_SUB] = MODE | 0x1;
                    g.PSEUDO_LENGTH[IND_LINK_SAVE] = g.NEXT_SUB;
                g.FIX_DIM = T1;
            #************ GENERATE SR1 & SR2 ERRORS FOR CHARACTER VARIABLES*****
            else:  # FLAG=1*/
                if T1 < -1: 
                    goto_SR_ERR1 = True
                    continue
                if (T1 > SIZE and SIZE > 0): 
                    goto_SR_ERR2 = True
                    continue
                else: 
                    T2 = T1 + T2 - 1;
                if (T2 > SIZE and SIZE > 0): 
                    goto_SR_ERR2 = True
                    continue
            #*******************************************************************
    # END of DO CASE
    FLAG = g.FALSE;
    g.VAL_P[g.NEXT_SUB] = 0;
