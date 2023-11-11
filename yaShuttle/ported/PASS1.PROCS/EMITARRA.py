#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   EMITARRA.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  Note that this port does not necessarily
            include all program comments that were present in the original code.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-28 RSB  Ported
'''

from xplBuiltins import OUTPUT
import g
from HALMATPI import HALMAT_PIP
from HALMATPO import HALMAT_POP

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  EMIT_ARRAYNESS                                         */
 /* MEMBER NAME:     EMITARRA                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          ACODE             BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FCN_LV                                                         */
 /*          XADLP                                                          */
 /*          XASZ                                                           */
 /*          XCO_D                                                          */
 /*          XCO_N                                                          */
 /*          XDLPE                                                          */
 /*          XIMD                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CURRENT_ARRAYNESS                                              */
 /*          ARRAYNESS_FLAG                                                 */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HALMAT_POP                                                     */
 /*          HALMAT_PIP                                                     */
 /* CALLED BY:                                                              */
 /*          INITIALIZATION                                                 */
 /*          SETUP_CALL_ARG                                                 */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''

class cEMIT_ARRAYNESS:
    def __init__(self):
        self.ACODE = None
        
lEMIT_ARRAYNESS = cEMIT_ARRAYNESS()

def EMIT_ARRAYNESS(ACODE = None):
    # Local: I
    l = lEMIT_ARRAYNESS
    if ACODE != None:
        l.ACODE = ACODE
    
    if g.CURRENT_ARRAYNESS[0] > 0:
        HALMAT_POP(l.ACODE, g.CURRENT_ARRAYNESS[0], g.XCO_D, g.FCN_LV);
        for I in range(1, g.CURRENT_ARRAYNESS[0] + 1):
            if g.CURRENT_ARRAYNESS[I] < 0:
                HALMAT_PIP(-g.CURRENT_ARRAYNESS[I], g.XASZ, 0, 0);
            else:
                HALMAT_PIP(g.CURRENT_ARRAYNESS[I], g.XIMD, 0, 0);
        HALMAT_POP(g.XDLPE, 0, g.XCO_N, g.FCN_LV);
        g.CURRENT_ARRAYNESS[0] = 0;
    g.ARRAYNESS_FLAG = 0;
    l.ACODE = g.XADLP;
