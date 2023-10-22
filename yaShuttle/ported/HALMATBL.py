#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   HALMATBL.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
from HEX     import HEX
from IFORMAT import I_FORMAT

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  HALMAT_BLAB                                            */
 /* MEMBER NAME:     HALMATBL                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          ANY_ATOM          FIXED                                        */
 /*          I                 FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          BLAB1             CHARACTER;                                   */
 /*          BLAB2             CHARACTER;                                   */
 /*          C                 CHARACTER;                                   */
 /*          ICNT              BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          X70                                                            */
 /*          HALMAT_OK                                                      */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HEX                                                            */
 /*          I_FORMAT                                                       */
 /* CALLED BY:                                                              */
 /*          HALMAT_OUT                                                     */
 /*          HALMAT                                                         */
 /***************************************************************************/
'''


class cHALMAT_BLAB:

    def __init__(self):
        self.ICNT = 0


lHALMAT_BLAB = cHALMAT_BLAB()

BLAB1 = '0ND    X'
BLAB2 = '  0 SYT INL VAC XPT LIT IMD AST CSZ ASZ OFF                     '


def HALMAT_BLAB(ANY_ATOM, I):
    # The parameters are not optional, and therefore don't require persistence.
    # Locals C and J require no persistence.
    # Local ICNT does appear to require persistence.
    l = lHALMAT_BLAB
    
    if ANY_ATOM & 1:
        # PIP ATOM
        C = HEX(SHR(ANY_ATOM, 1) & 0x7, 1);
        C = HEX(SHR(ANY_ATOM, 8) & 0xFF, 2) + ',' + C;
        C = SUBSTR(BLAB2, SHR(ANY_ATOM, 2) & 0x3C, 3) + ')' + C;
        J = SHR(ANY_ATOM, 16);
        C = I_FORMAT(J, 7) + '(' + C;
        C = '  :' + C;
        if l.ICNT == 4:
            l.ICNT = 1;
            C = SUBSTR(g.X70, 0, 36) + C;
        else:
            C = '+' + SUBSTR(g.X70, 0, l.ICNT * 20 + 35) + C;
            l.ICNT = l.ICNT + 1;
    else:
        # POP ATOM
        C = HEX(SHR(ANY_ATOM, 24), 2);
        C = '),' + SUBSTR(BLAB1, SHR(ANY_ATOM, 1) & 0x7, 1) + ',' + C;
        C = I_FORMAT(SHR(ANY_ATOM, 16) & 0xFF, 3) + C;
        C = HEX(SHR(ANY_ATOM, 4) & 0xFFF, 3) + '(' + C;
        if g.HALMAT_OK: 
            C = I_FORMAT(I, 5) + ':   ' + C;
            C = '  HALMAT LINE ' + C;
        else:
            C = '     UNSAVED HALMAT:   ' + C;
        l.ICNT = 0;
    OUTPUT(1, C);
