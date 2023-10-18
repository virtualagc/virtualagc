#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   HALMATPO.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
from HALMAT import HALMAT

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  HALMAT_POP                                             */
 /* MEMBER NAME:     HALMATPO                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          POPCODE           BIT(16)                                      */
 /*          PIP#              BIT(8)                                       */
 /*          COPT              BIT(8)                                       */
 /*          TAG               BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          NEXT_ATOM#                                                     */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          LAST_POP#                                                      */
 /*          CURRENT_ATOM                                                   */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HALMAT                                                         */
 /* CALLED BY:                                                              */
 /*          CHECK_SUBSCRIPT                                                */
 /*          EMIT_ARRAYNESS                                                 */
 /*          EMIT_SMRK                                                      */
 /*          END_ANY_FCN                                                    */
 /*          HALMAT_INIT_CONST                                              */
 /*          HALMAT_TUPLE                                                   */
 /*          ICQ_ARRAYNESS_OUTPUT                                           */
 /*          ICQ_OUTPUT                                                     */
 /*          SETUP_NO_ARG_FCN                                               */
 /*          START_NORMAL_FCN                                               */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def HALMAT_POP(POPCODE, PIPp, COPT, TAG):
    # The parameters aren't optional.
    # There are no locals.
    g.CURRENT_ATOM = SHL(TAG, 24) | SHL(PIPp, 16) | SHL(POPCODE & 0xFFF, 4) | \
                        SHL(COPT & 0x7, 1);
    HALMAT();
    g.LAST_POPp = g.NEXT_ATOMp - 1;
