#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   HALMATPI.py
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
 /* PROCEDURE NAME:  HALMAT_PIP                                             */
 /* MEMBER NAME:     HALMATPI                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          OPERAND           BIT(16)                                      */
 /*          QUAL              BIT(8)                                       */
 /*          TAG1              BIT(8)                                       */
 /*          TAG2              BIT(8)                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CURRENT_ATOM                                                   */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HALMAT                                                         */
 /* CALLED BY:                                                              */
 /*          CHECK_SUBSCRIPT                                                */
 /*          EMIT_ARRAYNESS                                                 */
 /*          EMIT_PUSH_DO                                                   */
 /*          EMIT_SMRK                                                      */
 /*          EMIT_SUBSCRIPT                                                 */
 /*          END_ANY_FCN                                                    */
 /*          END_SUBBIT_FCN                                                 */
 /*          HALMAT_INIT_CONST                                              */
 /*          HALMAT_TUPLE                                                   */
 /*          ICQ_ARRAYNESS_OUTPUT                                           */
 /*          ICQ_OUTPUT                                                     */
 /*          SETUP_CALL_ARG                                                 */
 /*          START_NORMAL_FCN                                               */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def HALMAT_PIP(OPERAND, QUAL, TAG1, TAG2):
    # No persistence required.
    g.CURRENT_ATOM = SHL(OPERAND, 16) | SHL(TAG1, 8) | SHL(QUAL & 0xF, 4) \
                    | SHL(TAG2 & 0x7, 1) | 0x1;
    HALMAT();
