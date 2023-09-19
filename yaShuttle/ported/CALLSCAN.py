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
from SCAN     import SCAN
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

def CALL_SCAN():
    # No local variables.
    g.NO_LOOK_AHEAD_DONE = g.FALSE;
    SCAN();
    if g.CONTROL[4] or (g.PARTIAL_PARSE and g.RECOVERING):
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
        else:
            OUTPUT(0, g.S);
