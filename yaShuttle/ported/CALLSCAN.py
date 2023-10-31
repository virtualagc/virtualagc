#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   CALLSCAN.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
if g.scan1:
    from SCAN1 import SCAN
elif g.scan2:
    from SCAN2 import SCAN
else:
    from SCAN import SCAN
from HEX      import HEX
from SAVEDUMP import SAVE_DUMP

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  CALL_SCAN                                              */
 /* MEMBER NAME:     CALLSCAN                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BCD                                                            */
 /*          CONST_DW                                                       */
 /*          CONTROL                                                        */
 /*          DW                                                             */
 /*          FALSE                                                          */
 /*          FOR_DW                                                         */
 /*          NEXT_CHAR                                                      */
 /*          PARTIAL_PARSE                                                  */
 /*          RECOVERING                                                     */
 /*          TOKEN                                                          */
 /*          VALUE                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          S                                                              */
 /*          NO_LOOK_AHEAD_DONE                                             */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HEX                                                            */
 /*          SAVE_DUMP                                                      */
 /*          SCAN                                                           */
 /* CALLED BY:                                                              */
 /*          RECOVER                                                        */
 /*          COMPILATION_LOOP                                               */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''

contextNames = ("ORDINARY", "EXPRESSION", "GO TO", "CALL", "SCHEDULE",
                "DECLARE", "PARAMETER", "ASSIGN", "REPLACE", 
                "REPLACE PARAMETER", "EQUATE")

def CALL_SCAN():
    # No local variables.
    g.NO_LOOK_AHEAD_DONE = g.FALSE;
    #if g.TOKEN in [3, 7]:
    #    pass
    SCAN();
    if (g.CONTROL[4] & 1) or (g.PARTIAL_PARSE and g.RECOVERING):
        g.S = HEX(g.DW[7], 0);
        g.S = HEX(g.DW[6], 0) + g.S;
        g.S = 'SCANNER: ' + str(g.TOKEN) + ', NUMBER_VALUE: ' + g.S + \
                ', VALUE: ' + str(g.VALUE);
        if g.BCD != '':
            g.S = g.S + ', CURRENT BCD: ' + g.BCD;
        if g.RECOVERING:
            g.S = g.S + ', SKIPPED OVER BY RECOVERY';
        g.S = g.S + ', NEXT_CHAR: ' + str(g.NEXT_CHAR);
        if g.RECOVERING:
            SAVE_DUMP(g.S);
            if g.extraTrace:
                print("   { RECOVERING ... }", end="")
        else:
            OUTPUT(0, g.S);
            if g.extraTrace:
                s = BYTE('', 0, g.NEXT_CHAR)
                if g.CONTEXT >= 0:
                    s1 = "CONTEXT=" + contextNames[g.CONTEXT]
                else:
                    s1 = "CONTEXT=TBD"
                print("   { \"%s\" NEXT_CHAR=\'%s\' %s }" % \
                      (g.VOCAB_INDEX[g.TOKEN], s, s1), end="")

