#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   OUTPUTGR.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-06 RSB  Ported from XPL
'''

import g
from PRINT2 import PRINT2

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  OUTPUT_GROUP                                           */
 /* MEMBER NAME:     OUTPUTGR                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CURRENT_SCOPE                                                  */
 /*          DOUBLE                                                         */
 /*          FALSE                                                          */
 /*          LINE_LIM                                                       */
 /*          SAVE_GROUP                                                     */
 /*          X1                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          I                                                              */
 /*          LISTING2_COUNT                                                 */
 /*          NEXT                                                           */
 /*          TOO_MANY_LINES                                                 */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          PRINT2                                                         */
 /* CALLED BY:                                                              */
 /*          STREAM                                                         */
 /*          PRINT_SUMMARY                                                  */
 /***************************************************************************/
'''


def OUTPUT_GROUP():
    # There are no locals.
    if g.NEXT < 0:
        return;
    if g.LISTING2_COUNT + g.NEXT + 2 > g.LINE_LIM:
        g.LISTING2_COUNT = g.LINE_LIM;
    PRINT2(g.DOUBLE + g.SAVE_GROUP[0] + g.X1 + g.CURRENT_SCOPE, 2);
    for g.I in range(1, g.NEXT + 1):
        PRINT2(g.X1 + g.SAVE_GROUP[g.I] + g.X1 + g.CURRENT_SCOPE, 1);
    if g.TOO_MANY_LINES:
        PRINT2(' *** WARNING *** INPUT BUFFER FILLED; NOT ALL SOURCE LINES ARE PRINTED.', 1);
    g.NEXT = -1;
    g.TOO_MANY_LINES = g.FALSE;
