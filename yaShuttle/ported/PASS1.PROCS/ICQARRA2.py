#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   ICQARRA2.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  Note that this port does not necessarily
            include all program comments that were present in the original code.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-30 RSB  Ported.
'''

from xplBuiltins import *
import g
import HALINCL.COMMON as h
from HALMATFI import HALMAT_FIX_PIPp
from HALMATPI import HALMAT_PIP
from HALMATPO import HALMAT_POP

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  ICQ_ARRAYNESS_OUTPUT                                   */
 /* MEMBER NAME:     ICQARRA2                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AUTO_FLAG                                                      */
 /*          EXT_ARRAY                                                      */
 /*          ID_LOC                                                         */
 /*          LAST_POP#                                                      */
 /*          MAJ_STRUC                                                      */
 /*          NAME_IMPLIED                                                   */
 /*          SYM_ARRAY                                                      */
 /*          SYM_FLAGS                                                      */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_ARRAY                                                      */
 /*          SYT_FLAGS                                                      */
 /*          SYT_TYPE                                                       */
 /*          XADLP                                                          */
 /*          XCO_D                                                          */
 /*          XCO_N                                                          */
 /*          XDLPE                                                          */
 /*          XIDLP                                                          */
 /*          XIMD                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          I                                                              */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HALMAT_PIP                                                     */
 /*          HALMAT_FIX_PIP#                                                */
 /*          HALMAT_POP                                                     */
 /* CALLED BY:                                                              */
 /*          HALMAT_INIT_CONST                                              */
 /***************************************************************************/
''' 


def ICQ_ARRAYNESS_OUTPUT():
    # No locals.
    
    if g.NAME_IMPLIED: 
        return;
    if g.SYT_ARRAY(g.ID_LOC) != 0:
        if (g.SYT_FLAGS(g.ID_LOC) & g.AUTO_FLAG) != 0: 
            g.I = g.XADLP;
        else: 
            g.I = g.XIDLP;
        HALMAT_POP(g.I, 0, g.XCO_D, 0);
        if g.SYT_TYPE(g.ID_LOC) == g.MAJ_STRUC:
            g.I = 2;
            HALMAT_PIP(g.SYT_ARRAY(g.ID_LOC), g.XIMD, 0, 0);
        else: 
            for g.I in range(1, h.EXT_ARRAY[g.SYT_ARRAY(g.ID_LOC)] + 1):
                HALMAT_PIP(h.EXT_ARRAY[g.SYT_ARRAY(g.ID_LOC) + g.I], g.XIMD, 0, 0);
            g.I += 1 # Terminating value differs in XPL vs Python for-loops.
        HALMAT_FIX_PIPp(g.LAST_POPp, g.I - 1);
        HALMAT_POP(g.XDLPE, 0, g.XCO_N, 0);
