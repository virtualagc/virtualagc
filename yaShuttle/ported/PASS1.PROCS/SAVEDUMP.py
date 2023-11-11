#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   SAVEDUMP.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-12 RSB  Ported from XPL
'''

from xplBuiltins import *
import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  SAVE_DUMP                                              */
 /* MEMBER NAME:     SAVEDUMP                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          MSG               CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          STACK_DUMP_MAX                                                 */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          SAVE_STACK_DUMP                                                */
 /*          STACK_DUMP_PTR                                                 */
 /* CALLED BY:                                                              */
 /*          CALL_SCAN                                                      */
 /*          STACK_DUMP                                                     */
 /***************************************************************************/
'''


def SAVE_DUMP(MSG):
    # No locals
    g.STACK_DUMP_PTR = g.STACK_DUMP_PTR + 1;
    if g.STACK_DUMP_PTR >= g.STACK_DUMP_MAX:
        g.SAVE_STACK_DUMP[g.STACK_DUMP_MAX] = '***** DUMP INCOMPLETE.';
        g.STACK_DUMP_PTR = g.STACK_DUMP_MAX;
    g.SAVE_STACK_DUMP[g.STACK_DUMP_PTR] = MSG[:];
