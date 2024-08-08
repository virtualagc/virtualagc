#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   HALMATF3.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  Note that this port does not necessarily
            include all program comments that were present in the original code.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-28 RSB  Ported
'''

from xplBuiltins import OUTPUT, SHL
import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  HALMAT_FIX_PIPTAGS                                     */
 /* MEMBER NAME:     HALMATF3                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PIP_LOC           FIXED                                        */
 /*          TAG1              BIT(8)                                       */
 /*          TAG2              BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ATOMS                                                          */
 /*          CONST_ATOMS                                                    */
 /*          HALMAT_OK                                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FOR_ATOMS                                                      */
 /* CALLED BY:                                                              */
 /*          CHECK_ASSIGN_CONTEXT                                           */
 /*          ICQ_OUTPUT                                                     */
 /*          SETUP_CALL_ARG                                                 */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def HALMAT_FIX_PIPTAGS(PIP_LOC, TAG1, TAG2):
    if g.HALMAT_OK:
        g.ATOMS(PIP_LOC, \
                (g.ATOMS(PIP_LOC) & 0xFFFF00F1) | \
                    SHL(TAG1, 8) | SHL(TAG2 & 0x7, 1));
