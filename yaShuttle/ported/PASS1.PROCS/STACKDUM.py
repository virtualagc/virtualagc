#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   STACKDUM.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-12 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
from SAVEDUMP import SAVE_DUMP

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  STACK_DUMP                                             */
 /* MEMBER NAME:     STACKDUM                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          LINE              CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          SP                                                             */
 /*          PARTIAL_PARSE                                                  */
 /*          STATE_NAME                                                     */
 /*          STATE_STACK                                                    */
 /*          TRUE                                                           */
 /*          VOCAB_INDEX                                                    */
 /*          X1                                                             */
 /*          X4                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          I                                                              */
 /*          STACK_DUMPED                                                   */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          SAVE_DUMP                                                      */
 /* CALLED BY:                                                              */
 /*          RECOVER                                                        */
 /*          COMPILATION_LOOP                                               */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def STACK_DUMP():
    # Local (LINE) doesn't need to be persistent.
    
    if not g.PARTIAL_PARSE:
        return;  # NO PARTIAL PARSE UNLESS ASKED FOR IN PARM FIELD
    g.STACK_DUMPED = g.TRUE;
    LINE = '***** PARTIAL PARSE TO THIS POINT IS: ';
    for g.I in range(1, g.SP + 1):
        if LENGTH(LINE) > 105:
            SAVE_DUMP(LINE);
            LINE = g.X4;
        LINE = LINE + g.X1 + \
               STRING(g.VOCAB_INDEX[g.STATE_NAME[g.STATE_STACK[g.I]]]);
    SAVE_DUMP(LINE);
