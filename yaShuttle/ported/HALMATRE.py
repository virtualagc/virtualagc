#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   HALMATRE.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  HALMAT_RELOCATE                                        */
 /* MEMBER NAME:     HALMATRE                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          D1                BIT(16)                                      */
 /*          D2                FIXED                                        */
 /*          D3                FIXED                                        */
 /*          D4                BIT(16)                                      */
 /*          I                 FIXED                                        */
 /*          MOVE_BLOCK(1549)  LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ATOM#_LIM                                                      */
 /*          ATOMS                                                          */
 /*          CONST_ATOMS                                                    */
 /*          FALSE                                                          */
 /*          HALMAT_OK                                                      */
 /*          XVAC                                                           */
 /*          XXPT                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ATOM#_FAULT                                                    */
 /*          FOR_ATOMS                                                      */
 /*          HALMAT_RELOCATE_FLAG                                           */
 /*          NEXT_ATOM#                                                     */
 /* CALLED BY:                                                              */
 /*          EMIT_SMRK                                                      */
 /***************************************************************************/
'''


def HALMAT_RELOCATE(D1=None, D4=None):
    # The parameters don't need to be persistent (in fact, they're not even
    # used at all).  Nor do the locals (I, D2, D3).
    I = 0
       
    def MOVE_BLOCK(START, STOP, DELTA):
        # The parameters don't require persistence.
        nonlocal I
        for I in range(1 - STOP, -START + 1):
            g.ATOMS(DELTA - I, g.ATOMS(-I));
    
    # FIRST MOVE CODE 
    g.HALMAT_RELOCATE_FLAG = g.FALSE;
    if not g.HALMAT_OK: 
        return;
    if g.ATOMp_FAULT == g.ATOMp_LIM:
        g.ATOMp_FAULT = 0;
        return;
    D1 = g.ATOMp_FAULT - g.NEXT_ATOMp;
    D2 = g.ATOMp_LIM - g.ATOMp_FAULT;
    D3 = 2 - g.ATOMp_FAULT;
    D4 = 2;
    while D1 < D2:
        MOVE_BLOCK(D4, g.NEXT_ATOMp, D1);
        MOVE_BLOCK(g.ATOMp_FAULT, g.ATOMp_FAULT + D1, D3);
        D4 = D4 + D1;
        D2 = D2 - D1;
        g.NEXT_ATOMp = g.NEXT_ATOMp + D1;
        g.ATOMp_FAULT = g.ATOMp_FAULT + D1;
    MOVE_BLOCK(D4, g.NEXT_ATOMp, D2);
    MOVE_BLOCK(g.ATOMp_FAULT, g.ATOMp_LIM, D3);
    g.NEXT_ATOMp = g.NEXT_ATOMp + D2;
    g.ATOMp_FAULT = 2;  # NOW RELOCATE VACS
    D3 = SHL(-D3, 16);
    D2 = SHL(D2 + D4 - g.ATOMp_FAULT, 16);
    for I in range(2, g.NEXT_ATOMp):
        D4 = SHR(g.ATOMS(I) & 0xF0, 4);
        if g.ATOMS(I) & 1: 
            if (D4 == g.XVAC) or (D4 == g.XXPT):
                if g.ATOMS(I) >= D3:
                    g.ATOMS(I, g.ATOMS(I) - D3);
                else:
                    g.ATOMS(I, g.ATOMS(I) + D2);
