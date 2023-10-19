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
import g
import HALINCL.VMEM2 as v

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
    The documentation isn't exactly forthcoming -- i.e., there doesn't appear
    to be any whatsoever -- but it appears to me that what LOCATE() *may* do
    is to alter the location of the SRN_BLOCK_RECORD[] array to correspond to
    BLOCK_SRN_DATA.  At least temporarily, let's just pretend we don't want
    to do that.
    LOCATE(g.BLOCK_SRN_DATA(), ADDR(g.SRN_BLOCK_RECORD), v.MODF);
    '''
    while len(g.SRN_BLOCK_RECORD) < BLOCK_PTR + 2:
        g.SRN_BLOCK_RECORD.append(0)
    g.SRN_BLOCK_RECORD[0] = g.SRN_BLOCK_RECORD[0] + 1;
    g.SRN_BLOCK_RECORD[BLOCK_PTR] = SYMNUM;
    g.SRN_BLOCK_RECORD[BLOCK_PTR + 1] = BLOCK_SRN;
    BLOCK_PTR = BLOCK_PTR + 2;
    return;
