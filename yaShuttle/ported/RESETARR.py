#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   RESETARR.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  RESET_ARRAYNESS                                        */
 /* MEMBER NAME:     RESETARR                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          MISMATCH          BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ARRAYNESS_STACK                                                */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CURRENT_ARRAYNESS                                              */
 /*          AS_PTR                                                         */
 /* CALLED BY:                                                              */
 /*          ATTACH_SUBSCRIPT                                               */
 /*          END_ANY_FCN                                                    */
 /*          KILL_NAME                                                      */
 /*          NAME_COMPARE                                                   */
 /*          SETUP_CALL_ARG                                                 */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def RESET_ARRAYNESS():
    ''' COMPARE OLD AND NEW ARRAYNESS-- REPLACE THE NEW WITH THE OLD
        UNLESS THE OLD ARRAYNESS WAS ZERO.   RETURNED VALUE INDICATED
        TRUTH OF MISMATCH '''
    # Locals are I, J, MISMATCH
    MISMATCH = 0;
    if g.ARRAYNESS_STACK[g.AS_PTR] > 0: 
        if g.CURRENT_ARRAYNESS[0] > 0:
            if g.CURRENT_ARRAYNESS[0] == g.ARRAYNESS_STACK[g.AS_PTR]:
                for I in range(1, g.CURRENT_ARRAYNESS[0] + 1):
                    J = g.AS_PTR - I;
                    if g.CURRENT_ARRAYNESS[I] > 0:
                        if g.ARRAYNESS_STACK[J] > 0:
                            if g.CURRENT_ARRAYNESS[I] != g.ARRAYNESS_STACK[J]:
                                MISMATCH = 3;
            else:
                MISMATCH = 3;
        else:
            MISMATCH = 2;
        g.CURRENT_ARRAYNESS[0] = g.ARRAYNESS_STACK[g.AS_PTR];
        for I in range(1, g.CURRENT_ARRAYNESS[0] + 1):
            J = g.AS_PTR - I;
            g.CURRENT_ARRAYNESS[I] = g.ARRAYNESS_STACK[J];
        g.AS_PTR = g.AS_PTR - g.CURRENT_ARRAYNESS[0];
    elif g.CURRENT_ARRAYNESS[0] > 0: 
        MISMATCH = 4;
    g.AS_PTR = g.AS_PTR - 1;
    return MISMATCH;
