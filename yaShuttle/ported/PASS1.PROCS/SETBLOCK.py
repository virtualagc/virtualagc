#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   SETBLOCK.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-22 RSB  Began porting from XPL
            2026-08-02 RSB  Finished the port.  What had stalled it was that
                            LOCATE() returns an address into a paged buffer at
                            an arbitrary offset, and there is no way to make a
                            Python reference to part of a bytearray; the
                            COREWORD() accessor added to VMEM3 for STABHDR
                            removes the difficulty.
'''

from xplBuiltins import *
from HALINCL.VMEM3 import *
import g
import HALINCL.VMEM2 as v2

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  SET_BLOCK_SRN                                          */
 /* MEMBER NAME:     SETBLOCK                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          SYMNUM            FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          BLOCK_PTR         FIXED                                        */
 /*          BLOCK_SRN         FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BLOCK_SRN_DATA                                                 */
 /*          COMM                                                           */
 /*          MAIN_SCOPE                                                     */
 /*          MODF                                                           */
 /*          SRN                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          SRN_BLOCK_RECORD                                               */
 /*          I                                                              */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          LOCATE                                                         */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


# BLOCK_PTR is declared inside the XPL procedure, as "DECLARE BLOCK_PTR FIXED
# INITIAL(1)", but XPL allocates procedure locals statically and performs the
# INITIAL once at load time rather than on entry.  It therefore keeps its value
# from one call to the next, which is the only reason successive blocks land in
# successive slots.  Hence it lives out here.
BLOCK_PTR = 1


def SET_BLOCK_SRN(SYMNUM):
    # The other local is BLOCK_SRN.
    global BLOCK_PTR

    # CONVERT SRN TO FIXED AND INSERT WITH SYM_NUM  IN TABLE FOR PHASE2
    if g.MAIN_SCOPE == 0:
        return;  # STILL EXTERNAL CSECTS
    # CONVERT SRN TO FIXED.  Note that this is not conditioned on SRN_PRESENT,
    # so with no SRNs in the source it converts six bytes of nothing; the XPL
    # did the same, and nothing downstream reads the result in any case.  The
    # loop is written out rather than left to range() because XPL's "DO I=0 TO
    # 5" leaves I at 6, whereas Python's for-loop would leave it at 5, and I is
    # a shared global.
    BLOCK_SRN = 0;
    g.I = 0
    while g.I <= 5:
        BLOCK_SRN = (BLOCK_SRN * 10) + (BYTE(g.SRN[0], g.I) - BYTE('0'));
        g.I = g.I + 1
    # END
    # INCREMENT ENTRY COUNT AND ENTER PAIR.  SRN_BLOCK_RECORD is a BASED FIXED
    # in the XPL, i.e. a pointer to the virtual-memory cell that INITIALIZE
    # allocated and left in BLOCK_SRN_DATA (= COMM(18)).  LOCATE() returns the
    # "core address" of that cell, and the based-variable subscripting is
    # spelled out as COREWORD(SRN_BLOCK_RECORD + 4*n), exactly as in STABHDR.
    # Word 0 is a running count of the blocks recorded, and the pairs follow.
    SRN_BLOCK_RECORD = LOCATE(g.BLOCK_SRN_DATA(), v2.MODF);
    COREWORD(SRN_BLOCK_RECORD, COREWORD(SRN_BLOCK_RECORD) + 1);
    COREWORD(SRN_BLOCK_RECORD + 4 * BLOCK_PTR, SYMNUM);
    COREWORD(SRN_BLOCK_RECORD + 4 * (BLOCK_PTR + 1), BLOCK_SRN);
    BLOCK_PTR = BLOCK_PTR + 2;
    return;
