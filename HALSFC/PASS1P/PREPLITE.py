#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   PREPLITE.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-22 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
import HALINCL.COMMON as h
from HALINCL.SAVELITE import SAVE_LITERAL

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
    creation by a MONITOR(lO) call, checks it for proper limits,
    enters it in the literal table via SAVE LITERAL and sets
    SYT_INDEX to the absoulute index of the literal."

*I* think it also stores the converted value in the global variable VALUE.

MONITOR(10,string) converts a stringified representation of a number to IBM
DP floating point, and stores the most-significant word in DW[0] and the 
less-significant word in DW[1], return TRUE on error and FALSE on success; this
boolean is the value we expect to find in EXP_OVERFLOW.  So presumably, 
PREP_LITERAL() expects to find DW[0] and DW[1] filled with the data.
'''
def PREP_LITERAL():
    
    #TEMP1 = 0
    
    goto = None
    first = True
    while first or goto != None:
        first = False
    
        if g.EXP_OVERFLOW or goto == "NOT_EXACT":
            if goto == None:
                g.FR[6] = fromFloatIBM(0x487FFFFF, 0xFFFFFFFF);
            if goto == "NOT_EXACT":
                goto = None
            g.VALUE = -1
            g.TOKEN = g.CPD_NUMBER
            break # GOTO SAVE_NUMBER
        
        g.traceInline("PREP_LITERAL p59")
        # TEMP1 = ADDR(NOT_EXACT)
        g.FR[6] = g.FR[0]  # p59_8 FR[0] was loaded by MONITOR(10)
        g.FR[0] = abs(g.FR[0]) # p59_10
        scratch = g.FR[0] - fromFloatIBM(0x487FFFFF, 0xFFFFFFFF) # p59_12
        if scratch > 0: # p59_16
            goto = "NOT_EXACT"
            continue
        g.FR[4] = 0.0 # p59_18
        g.FR[2] = g.FR[0] # p59_20
        g.DW[6] = 0 # p59_22, 26, 30, 34
        g.DW[7] = int(hround(g.FR[0]))
        g.FR[0] += g.FR[4] # p59_38
        g.FR[2] -= g.FR[0] # p 59_40
        if g.FR[2] != 0: # p59_42
            goto = "NOT_EXACT"
            continue
        g.VALUE = g.DW[7] # p59_44, 48
    
    #SAVE_NUMBER:    
    g.traceInline("PREP_LITERAL p76")
    g.DW[6], g.DW[7] = toFloatIBM(g.FR[6]) # p76_0, 4

    #g.SYT_INDEX = SAVE_LITERAL(1, h.TABLE_ADDR);
    g.SYT_INDEX = SAVE_LITERAL(1, g.DW_AD());
    return
