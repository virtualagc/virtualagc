#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   UNARAY2.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
from CHECKARR import CHECK_ARRAYNESS
from HALMATTU import HALMAT_TUPLE
from SETUPVAC import SETUP_VAC

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  UNARRAYED_SCALAR                                       */
 /* MEMBER NAME:     UNARRAY2                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          INT_TYPE                                                       */
 /*          PSEUDO_TYPE                                                    */
 /*          PTR                                                            */
 /*          SCALAR_TYPE                                                    */
 /*          XITOS                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HALMAT_TUPLE                                                   */
 /*          CHECK_ARRAYNESS                                                */
 /*          SETUP_VAC                                                      */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def UNARRAYED_SCALAR(LOC):
    if g.PSEUDO_TYPE[g.PTR[LOC]] == g.INT_TYPE:
        HALMAT_TUPLE(g.XITOS, 0, LOC, 0, 0);
        SETUP_VAC(LOC, g.SCALAR_TYPE);
    return CHECK_ARRAYNESS() or (g.PSEUDO_TYPE[g.PTR[LOC]] != g.SCALAR_TYPE);
