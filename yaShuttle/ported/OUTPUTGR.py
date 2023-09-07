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

from g import NEXT, I, TOO_MANY_LINES, FALSE, LISTING2_COUNT, LINE_LIM, \
                DOUBLE, SAVE_GROUP, X1, CURRENT_SCOPE
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
    global NEXT, LISTING2_COUNT, I, TOO_MANY_LINES
    if NEXT < 0:
        return;
    if LISTING2_COUNT + NEXT + 2 > LINE_LIM:
        LISTING2_COUNT = LINE_LIM;
    PRINT2(DOUBLE + SAVE_GROUP[0] + X1 + CURRENT_SCOPE, 2);
    for I in range(1, NEXT+1):
        PRINT2(X1 + SAVE_GROUP[I] + X1 + CURRENT_SCOPE, 1);
    if TOO_MANY_LINES:
        PRINT2(' *** WARNING *** INPUT BUFFER FILLED; NOT ALL SOURCE LINES ARE PRINTED.', 1);
    NEXT = -1;
    TOO_MANY_LINES = FALSE;
