#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   HALMATFI.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-29 RSB  Ported from XPL
'''

from xplBuiltins import *
import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  HALMAT_FIX_PIP#                                        */
 /* MEMBER NAME:     HALMATFI                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          POP_LOC           FIXED                                        */
 /*          PIP#              BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ATOMS                                                          */
 /*          CONST_ATOMS                                                    */
 /*          HALMAT_OK                                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FOR_ATOMS                                                      */
 /* CALLED BY:                                                              */
 /*          END_ANY_FCN                                                    */
 /*          END_SUBBIT_FCN                                                 */
 /*          ICQ_ARRAYNESS_OUTPUT                                           */
 /*          SETUP_CALL_ARG                                                 */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def HALMAT_FIX_PIPp(POP_LOC, PIPp):
    # No locals.
    if g.HALMAT_OK:
        g.ATOMS(POP_LOC, (g.ATOMS(POP_LOC) & 0xFF00FFFF) | SHL(PIPp, 16));
