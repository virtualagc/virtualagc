#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   HALMAT.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d 
from ERROR    import ERROR
from HALMATBL import HALMAT_BLAB
from HALMATOU import HALMAT_OUT

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  HALMAT                                                 */
 /* MEMBER NAME:     HALMAT                                                 */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ATOM#_FAULT                                                    */
 /*          ATOM#_LIM                                                      */
 /*          ATOMS                                                          */
 /*          CLASS_BB                                                       */
 /*          CONST_ATOMS                                                    */
 /*          CONTROL                                                        */
 /*          CURRENT_ATOM                                                   */
 /*          FALSE                                                          */
 /*          TRUE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FOR_ATOMS                                                      */
 /*          HALMAT_CRAP                                                    */
 /*          HALMAT_OK                                                      */
 /*          NEXT_ATOM#                                                     */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          HALMAT_BLAB                                                    */
 /*          HALMAT_OUT                                                     */
 /* CALLED BY:                                                              */
 /*          HALMAT_POP                                                     */
 /*          HALMAT_PIP                                                     */
 /***************************************************************************/
'''


def HALMAT():
    # No locals and no parameters.
    if g.CONTROL[0] & 1: 
        HALMAT_BLAB(g.CURRENT_ATOM, g.NEXT_ATOMp);
    if g.HALMAT_OK:
        if g.NEXT_ATOMp == g.ATOMp_LIM: 
            HALMAT_OUT();
        if g.NEXT_ATOMp == (g.ATOMp_FAULT - 1):
            ERROR(d.CLASS_BB, 1);
            g.HALMAT_OK = g.FALSE;
            g.HALMAT_CRAP = g.TRUE;
        else:
            g.ATOMS(g.NEXT_ATOMp, g.CURRENT_ATOM);
            g.NEXT_ATOMp = g.NEXT_ATOMp + 1;
