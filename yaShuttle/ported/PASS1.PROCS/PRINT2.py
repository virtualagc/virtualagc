#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   PRINT2.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-06 RSB  Ported from XPL
'''

from xplBuiltins import *
import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  PRINT2                                                 */
 /* MEMBER NAME:     PRINT2                                                 */
 /* INPUT PARAMETERS:                                                       */
 /*          LINE              CHARACTER;                                   */
 /*          SPACE             BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          PAGE_NUM          BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LINE_LIM                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          LISTING2_COUNT                                                 */
 /* CALLED BY:                                                              */
 /*          OUTPUT_GROUP                                                   */
 /*          STREAM                                                         */
 /***************************************************************************/
'''


class cPRINT2:

    def __init__(self):
        self.PAGE_NUM = 0


lPRINT2 = cPRINT2()


def PRINT2(LINE, SPACE):
    l = lPRINT2
    
    g.LISTING2_COUNT = g.LISTING2_COUNT + SPACE;
    if g.LISTING2_COUNT > g.LINE_LIM:
        l.PAGE_NUM = l.PAGE_NUM + 1;
        OUTPUT(2, \
            '1  H A L   C O M P I L A T I O N   --   P H A S E   1   --   U N F O R M A T T E D   S O U R C E   L I S T I N G             PAGE ' \
            +str(l.PAGE_NUM));
        '''
        I haven't ported the commented-out line below because it's pointless.
        In the first place, LINE isn't used in the remainder of this function,
        so why alter it?  If the original XPL was implemented as I *suspect* it
        was (in contradiction to McKeeman et al section 6.14) it would change
        LINE in the *calling* code ... but in all cases I've seen, the LINE
        parameter is either a string literal or else a string expression, and
        trying to change either of those would be not only pointless but bad.
        Not that that's what would happen in the Python port of the line that
        I'd use, namely LINE = BYTE(LINE, 0, BYTE('-')), but still ...
        '''
        # BYTE(LINE) = BYTE('-');
        g.LISTING2_COUNT = 4;
    OUTPUT(2, LINE);
