#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   STABHDR.py
Purpose:    This is part of the port of the original XPL source code for
            HAL/S-FC into Python.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
            2026-03-15 RSB  Now sets STMT_TYPE to 0.
            2026-08-02 RSB  Actually ported the body, which until now was
                            merely quoted XPL inside a docstring.  Reached
                            only when SIMULATING is set, which in turn now
                            requires HAL_S_FC.py's --sdf switch.
'''

from xplBuiltins import *
import g
import HALINCL.VMEM2 as v2
from HALINCL.COMDEC19 import NILL
from HALINCL.VMEM3 import GET_CELL, LOCATE, PTR_LOCATE, MOVE, \
                          COREWORD, COREHALFWORD

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  STAB_HDR                                               */
 /* MEMBER NAME:     STABHDR                                                */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CELL_PTR          FIXED                                        */
 /*          CELLSIZE          BIT(16)                                      */
 /*          FIRST_CALL        BIT(8)                                       */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          NODE_F            FIXED                                        */
 /*          NODE_H            BIT(16)                                      */
 /*          SRN_INX           BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ADDR_PRESENT                                                   */
 /*          BLOCK_SYTREF                                                   */
 /*          FALSE                                                          */
 /*          HMAT_OPT                                                       */
 /*          INCL_SRN                                                       */
 /*          MODF                                                           */
 /*          NEST                                                           */
 /*          NILL                                                           */
 /*          RELS                                                           */
 /*          RESV                                                           */
 /*          SRN                                                            */
 /*          SRN_COUNT                                                      */
 /*          SRN_PRESENT                                                    */
 /*          STAB_MARK                                                      */
 /*          STAB_STACK                                                     */
 /*          STAB2_MARK                                                     */
 /*          STAB2_STACK                                                    */
 /*          STMT_DATA_HEAD                                                 */
 /*          STMT_NUM                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          COMM                                                           */
 /*          LAST_STAB_CELL_PTR                                             */
 /*          S                                                              */
 /*          STAB_STACKTOP                                                  */
 /*          STAB2_STACKTOP                                                 */
 /*          STMT_TYPE                                                      */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          GET_CELL                                                       */
 /*          LOCATE                                                         */
 /*          PTR_LOCATE                                                     */
 /* CALLED BY:                                                              */
 /*          EMIT_SMRK                                                      */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''

'''
Notes on the port:

XPL declared "BASED NODE_H BIT(16), NODE_F FIXED", so that NODE_H(n) and
NODE_F(n) were the n-th halfword and n-th fullword of whatever virtual-memory
cell the based variable had most recently been pointed at.  Python has no
pointers, so in the port NODE_H and NODE_F are simply the integer "core
addresses" (see the Virtual Memory section of ../README.md) handed back by
GET_CELL() and LOCATE(), and the based-variable subscripting is spelled out as
COREHALFWORD(NODE_H + 2*n) and COREWORD(NODE_F + 4*n).  In the same vein, the
XPL idioms

        COREWORD(ADDR(NODE_H)) = COREWORD(ADDR(NODE_H)) + 4
        COREWORD(ADDR(NODE_F)) = ADDR(NODE_H(0))

which reach into the *dope vectors* of the based variables in order to slide
NODE_H forward by 4 bytes and to alias NODE_F onto NODE_H's storage, become
just "NODE_H = NODE_H + 4" and "NODE_F = NODE_H".

The 4 INLINE statements in each of the two SRN blocks are, in IBM 360 terms,

        LH  R1,SRN_INX      ;  R1 = SRN_INX
        A   R1,NODE_H       ;  R1 += the data address in NODE_H's dope vector
        L   R2,S            ;  R2 = the string descriptor of S
        MVC 0(8,R1),0(R2)   ;  copy 8 bytes of S's text to that address

i.e. an 8-byte copy of the SRN text into the cell at offset SRN_INX, which is
what the MOVE() below does.  S is blank-extended to 8 bytes first, since
Python (unlike an MVC) cannot read past the end of the string.
'''


class cSTAB_HDR:

    def __init__(self):
        self.FIRST_CALL = 1


lSTAB_HDR = cSTAB_HDR()


def STAB_HDR():
    # Locals CELLSIZE, SRN_INX, I, J, CELL_PTR, NODE_H, NODE_F don't need to
    # be persistent.  Only FIRST_CALL does.
    l = lSTAB_HDR

    CELLSIZE = 32;
    if g.ADDR_PRESENT: CELLSIZE = CELLSIZE + 16;
    SRN_INX = CELLSIZE;
    # ADD SPACE FOR HALMAT CELL PTR
    if g.HMAT_OPT:
        CELLSIZE = CELLSIZE + 4;
    # Note that in the XPL the ELSE below binds to the *inner* IF, in spite of
    # the way the original was indented:  nothing at all is added to CELLSIZE
    # when SRN_PRESENT is FALSE.
    if g.SRN_PRESENT:
        if g.SRN_COUNT[2] > 0: CELLSIZE = CELLSIZE + 17;
        else: CELLSIZE = CELLSIZE + 9;
    CELL_PTR, NODE_H = GET_CELL(CELLSIZE, v2.RESV + v2.MODF);
    # KEEP OFFSETS THE SAME; HALMAT CELL PTR IS AT NODE_F(-1) ASSUMING THAT
    #        NODE_F POINTS AT THE CELL (ONLY IF HMAT_OPT)
    if g.HMAT_OPT:  # DO
        CELL_PTR = CELL_PTR + 4;
        NODE_H = NODE_H + 4;
    # END
    if l.FIRST_CALL:  # DO
        g.STMT_DATA_HEAD(CELL_PTR);
        l.FIRST_CALL = g.FALSE;
    # END
    if g.LAST_STAB_CELL_PTR != -1:  # DO
        NODE_F = LOCATE(g.LAST_STAB_CELL_PTR, v2.MODF);
        COREWORD(NODE_F + 0, CELL_PTR);
    # END
    NODE_F = NODE_H;
    if g.HMAT_OPT: COREWORD(NODE_F - 4, NILL);
    COREWORD(NODE_F + 0, NILL);
    COREWORD(NODE_F + 4, g.LAST_STAB_CELL_PTR);
    COREHALFWORD(NODE_H + 2 * 12, 0);
    COREHALFWORD(NODE_H + 2 * 13, g.STMT_TYPE);
    COREHALFWORD(NODE_H + 2 * 14, g.STMT_NUM());
    COREHALFWORD(NODE_H + 2 * 15, g.BLOCK_SYTREF[g.NEST]);
    if g.SRN_PRESENT:  # DO
        g.S = g.SRN[2];
        MOVE(8, (g.S + g.X8)[:8], NODE_H + SRN_INX);
        COREHALFWORD(NODE_H + 2 * (SHR(SRN_INX, 1) + 4), g.SRN_COUNT[2]);
        if g.SRN_COUNT[2] > 0:  # DO
            g.S = g.INCL_SRN[2];
            SRN_INX = SRN_INX + 10;
            MOVE(8, (g.S + g.X8)[:8], NODE_H + SRN_INX);
            COREHALFWORD(NODE_H + 2 * 13, \
                         COREHALFWORD(NODE_H + 2 * 13) | 0x8000);
        # END
    # END
    CELLSIZE = g.STAB2_STACKTOP - g.STAB2_MARK;
    if CELLSIZE > 0:  # DO
        TEMP, NODE_H = GET_CELL(SHL(CELLSIZE, 1) + 2, v2.MODF);
        COREWORD(NODE_F + 8, TEMP);
        COREHALFWORD(NODE_H + 0, CELLSIZE);
        for I in range(g.STAB2_MARK + 1, g.STAB2_STACKTOP + 1):
            J = I - g.STAB2_MARK;
            COREHALFWORD(NODE_H + 2 * J, g.STAB2_STACK[I]);
        # END
    # END
    else: COREWORD(NODE_F + 8, -1);
    CELLSIZE = g.STAB_STACKTOP - g.STAB_MARK;
    if CELLSIZE > 0:  # DO
        TEMP, NODE_H = GET_CELL(SHL(CELLSIZE, 1) + 2, v2.MODF);
        COREWORD(NODE_F + 12, TEMP);
        COREHALFWORD(NODE_H + 0, CELLSIZE);
        for I in range(g.STAB_MARK + 1, g.STAB_STACKTOP + 1):
            J = I - g.STAB_MARK;
            COREHALFWORD(NODE_H + 2 * J, g.STAB_STACK[I]);
        # END
    # END
    else: COREWORD(NODE_F + 12, -1);
    PTR_LOCATE(CELL_PTR, v2.RELS);
    g.LAST_STAB_CELL_PTR = CELL_PTR;
    g.STAB_STACKTOP = g.STAB_MARK;
    g.STAB2_STACKTOP = g.STAB2_MARK;
    g.STMT_TYPE = 0;
# END STAB_HDR;
