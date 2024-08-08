#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   SETBLOCK.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-22 RSB  Began porting from XPL
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


def SET_BLOCK_SRN(SYMNUM):
    # Locals are BLOCK_PTR, BLOCK_SRN.
    
    # Okay, the more I think about this, the more at a loss I am.  For now,
    # let's just ignore it.
    return
    
    # CONVERT SRN TO FIXED AND INSERT WITH SYM_NUM  IN TABLE FOR PHASE2
    BLOCK_PTR = 1
    if g.MAIN_SCOPE == 0:
        return;  # STILL EXTERNAL CSECTS
    # CONVERT SRN TO FIXED
    BLOCK_SRN = 0;
    for g.I in range(0, 5 + 1):
        BLOCK_SRN = (BLOCK_SRN * 10) + (BYTE(g.SRN[0], g.I) - BYTE('0'));
    # INCREMENT ENTRY COUNT AND ENTER PAIR
    '''
    What the following ghastliness was trying to do in XPL was to change
    SRN_BLOCK_RECORD (an array) so that it pointed to a different area of
    memory, for a different block of SRN data.  It seems to use the 
    Virtual Memory system for this, which it can do since SRN blocks are 2044
    bytes in size, whereas virtual-memory blocks are 3360 bytes in size.
    The return address of LOCATE() was originally an absolute numerical 
    address in memory, but for us is a number that encodes a virtual-memory
    buffer number and an offset into that buffer.
    
    Unfortunately, there's no guarantee that the offset is 0, and there's
    no way in Python to create a reference that's a bytearray to (say) just the
    last half of another bytearray.
    '''
    g.SRN_BLOCK_RECORD = LOCATE(g.BLOCK_SRN_DATA(), v2.MODF);
    while len(g.SRN_BLOCK_RECORD) < BLOCK_PTR + 2:
        g.SRN_BLOCK_RECORD.append(0)
    g.SRN_BLOCK_RECORD[0] = g.SRN_BLOCK_RECORD[0] + 1;
    g.SRN_BLOCK_RECORD[BLOCK_PTR] = SYMNUM;
    g.SRN_BLOCK_RECORD[BLOCK_PTR + 1] = BLOCK_SRN;
    BLOCK_PTR = BLOCK_PTR + 2;
    return;
