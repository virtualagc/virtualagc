#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   SAVEINPU.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-30 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
from IFORMAT import I_FORMAT
from PAD import PAD

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  SAVE_INPUT                                             */
 /* MEMBER NAME:     SAVEINPU                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CARD_COUNT                                                     */
 /*          CARD_TYPE                                                      */
 /*          COMM                                                           */
 /*          INCLUDE_END                                                    */
 /*          INCLUDE_LIST2                                                  */
 /*          INCLUDE_OFFSET                                                 */
 /*          INCLUDING                                                      */
 /*          PLUS                                                           */
 /*          SAVE_CARD                                                      */
 /*          SAVE#                                                          */
 /*          STMT_NUM                                                       */
 /*          TRUE                                                           */
 /*          VBAR                                                           */
 /*          X1                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          INCLUDE_CHAR                                                   */
 /*          NEXT                                                           */
 /*          S                                                              */
 /*          SAVE_GROUP                                                     */
 /*          TOO_MANY_LINES                                                 */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          PAD                                                            */
 /*          I_FORMAT                                                       */
 /* CALLED BY:                                                              */
 /*          STREAM                                                         */
 /***************************************************************************/
'''


def SAVE_INPUT():
    # No locals.
    
    if not g.INCLUDE_LIST2: return;
    if g.CARD_TYPE[BYTE(g.SAVE_CARD)] >= 4:
        if g.NEXT < 0:
            return;         # A LEGITIMATE COMMENT ALREADY PRINTED
    g.NEXT = g.NEXT + 1;    # NEXT AVAILABLE LINE
    if g.NEXT > g.SAVEp:
        g.TOO_MANY_LINES = g.TRUE;
        g.NEXT = g.SAVEp;
        return;
    g.S = str(g.CARD_COUNT - g.INCLUDE_OFFSET);
    g.S = PAD(g.S, 4);
    if (g.INCLUDING or g.INCLUDE_END):
        g.INCLUDE_CHAR = g.PLUS;
    else:
        g.INCLUDE_CHAR = g.X1;
    g.SAVE_GROUP[g.NEXT] = I_FORMAT(g.STMT_NUM(), 7) + g.INCLUDE_CHAR + \
        SUBSTR(g.SAVE_CARD, 0, 1) + g.VBAR + SUBSTR(g.SAVE_CARD, 1) + g.VBAR + g.S;
    return
