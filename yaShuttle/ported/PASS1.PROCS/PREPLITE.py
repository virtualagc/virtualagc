#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   PREPLITE.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-22 RSB  Ported from XPL
            2026-03-18 RSB  Now truncates floating-point to integer for `VALUE`
                            rather than rounding.
            2026-04-15 RSB  Wasn't detecting fractional parts correctly.
            2026-05-14 RSB  Changes related to issue #1306.
'''

import math
from xplBuiltins import *
import g
import HALINCL.COMMON as h
from HALINCL.SAVELITE import SAVE_LITERAL
from ibmFloat import ibm_dp_addsub

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  PREP_LITERAL                                           */
 /* MEMBER NAME:     PREPLITE                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          NOT_EXACT         LABEL                                        */
 /*          SAVE_NUMBER       LABEL                                        */
 /*          TEMP1             FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ADDR_FIXED_LIMIT                                               */
 /*          ADDR_FIXER                                                     */
 /*          CPD_NUMBER                                                     */
 /*          EXP_OVERFLOW                                                   */
 /*          TABLE_ADDR                                                     */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          TOKEN                                                          */
 /*          SYT_INDEX                                                      */
 /*          VALUE                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          SAVE_LITERAL                                                   */
 /* CALLED BY:                                                              */
 /*          SCAN                                                           */
 /***************************************************************************/
'''

'''
IR-182-1 describes PREP_LITERAL like so:
    "PREP_LITERAL takes a floating point number fresh from
    creation by a MONITOR(10) call, checks it for proper limits,
    enters it in the literal table via SAVE LITERAL and sets
    SYT_INDEX to the absoulute index of the literal."

MONITOR(10,string) converts a stringified representation of a number to IBM
DP HFP, and stores it at both FR[0] and DW[0],DW[1]. 
PREP_LITERAL() expects to find this data in FR[0].
'''
def PREP_LITERAL():
    
    #TEMP1 = 0
    
    goto = None
    first = True
    while first or goto != None:
        first = False
    
        if g.EXP_OVERFLOW or goto == "NOT_EXACT":
            if goto == None:
                g.FR[6] = 0x487FFFFFFFFFFFFF;
            if goto == "NOT_EXACT":
                goto = None
            g.VALUE = -1
            g.TOKEN = g.CPD_NUMBER
            break # GOTO SAVE_NUMBER
        
        g.traceInline("PREP_LITERAL p59")
        # TEMP1 = ADDR(NOT_EXACT)
        g.FR[6] = g.FR[0]  # p59_8 FR[0] was loaded by MONITOR(10)
        g.FR[0] &= 0x7FFFFFFFFFFFFFFF # p59_10
        scratch = ibm_dp_addsub(g.FR[0], 0x487FFFFFFFFFFFFF, 1, 1) # p59_12
        if 0 == (scratch & 0x8000000000000000): # p59_16
            goto = "NOT_EXACT"
            continue
        g.FR[4] = 0 # p59_18
        g.FR[2] = g.FR[0] # p59_20
        g.FR[0] = ibm_dp_addsub(g.FR[0], 0x4E00000000000000, 0, 0) # p59_22, 26
        g.DW[0], g.DW[1] = (g.FR[0] >> 32) & 0xFFFFFFFF, g.FR[0] & 0xFFFFFFFF # p59_30, 34
        g.FR[0] = ibm_dp_addsub(g.FR[0], g.FR[4], 0, 1) # p59_38
        g.FR[2] = ibm_dp_addsub(g.FR[2], g.FR[0], 1, 1) # p59_40
        if (0x00FFFFFFFFFFFFFF & g.FR[2]) != 0: # p59_42
            goto = "NOT_EXACT"
            continue
        g.VALUE = g.DW[1] # p59_44, 48
    
    #SAVE_NUMBER:    
    g.traceInline("PREP_LITERAL p76")
    g.DW[6], g.DW[7] = (g.FR[6] >> 32) & 0xFFFFFFFF, g.FR[6] & 0xFFFFFFFF # p76_0, 4

    #g.SYT_INDEX = SAVE_LITERAL(1, h.TABLE_ADDR);
    g.SYT_INDEX = SAVE_LITERAL(1, (g.DW[0] << 32) | g.DW[1])
    return
