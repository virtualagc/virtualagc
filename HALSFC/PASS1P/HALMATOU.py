#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   HALMATOU.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
import HALINCL.COMMON as h
from HALMATBL import HALMAT_BLAB

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  HALMAT_OUT                                             */
 /* MEMBER NAME:     HALMATOU                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          SAVE_ATOM         FIXED                                        */
 /*          I                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ATOMS                                                          */
 /*          CONST_ATOMS                                                    */
 /*          CONTROL                                                        */
 /*          DOUBLE                                                         */
 /*          DOUBLE_SPACE                                                   */
 /*          EJECT_PAGE                                                     */
 /*          HALMAT_FILE                                                    */
 /*          PAGE                                                           */
 /*          TRUE                                                           */
 /*          XXREC                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ATOM#_FAULT                                                    */
 /*          FOR_ATOMS                                                      */
 /*          HALMAT_BLOCK                                                   */
 /*          HALMAT_RELOCATE_FLAG                                           */
 /*          NEXT_ATOM#                                                     */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HALMAT_BLAB                                                    */
 /* CALLED BY:                                                              */
 /*          HALMAT                                                         */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


class cHALMAT_OUT:

    def __init__(self):
        self.SAVE_ATOM = None


lHALMAT_OUT = cHALMAT_OUT()


def HALMAT_OUT():
    # Local (I) doesn't need to be persistent.
    # Local SAVE_ATOM appears to require persistence.
    l = lHALMAT_OUT
    
    if g.ATOMp_FAULT < 0: 
        g.ATOMp_FAULT = g.NEXT_ATOMp - 1;  # FINAL BLOCK
    else:
        g.NEXT_ATOMp = 2;
        if g.HALMAT_RELOCATE_FLAG: 
            return;  # BACKUP OVER WRAPAROUND
        l.SAVE_ATOM = g.ATOMS(g.ATOMp_FAULT);
        g.ATOMS(g.ATOMp_FAULT, SHL(g.XXREC, 4));
    g.ATOMS(1, SHL(g.ATOMp_FAULT, 16) | 1);  # INSERT PTR TO XREC IN XPXRC
    if g.CONTROL[11]: 
        g.EJECT_PAGE();
        OUTPUT(0, '         *** HALMAT BLOCK ' + str(g.HALMAT_BLOCK) + ' ***');
        g.DOUBLE_SPACE();
        for I in range(0, g.ATOMp_FAULT + 1):
            HALMAT_BLAB(g.ATOMS(I), I);
    # We need to convert the ATOMS list to a bytearray.
    b = bytearray([])
    for i in h.FOR_ATOMS:
        b += (i.CONST_ATOMS & 0xFFFFFFFF).to_bytes(4, "big")
    FILE(g.HALMAT_FILE, g.HALMAT_BLOCK, b);
    g.HALMAT_BLOCK = g.HALMAT_BLOCK + 1;
    g.ATOMS(g.ATOMp_FAULT, l.SAVE_ATOM);
    g.HALMAT_RELOCATE_FLAG = g.TRUE;
