#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   ICQCHECK.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  Note that this port does not necessarily
            include all program comments that were present in the original code.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-29 RSB  Ported
'''

from xplBuiltins import OUTPUT
import g
import HALINCL.CERRDECL as d
from ERROR    import ERROR

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  ICQ_CHECK_TYPE                                         */
 /* MEMBER NAME:     ICQCHECK                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          J                 BIT(16)                                      */
 /*          K                 BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          SYT               BIT(16)                                      */
 /*          I                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BIT_TYPE                                                       */
 /*          CHAR_TYPE                                                      */
 /*          CLASS_DI                                                       */
 /*          EVENT_TYPE                                                     */
 /*          IC_TYPE                                                        */
 /*          ID_LOC                                                         */
 /*          INT_TYPE                                                       */
 /*          MAJ_STRUC                                                      */
 /*          MP                                                             */
 /*          NAME_IMPLIED                                                   */
 /*          SCALAR_TYPE                                                    */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_TYPE                                                       */
 /*          TRUE                                                           */
 /*          VAR                                                            */
 /*          XBINT                                                          */
 /*          XNINT                                                          */
 /*          XTINT                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          ICQ_OUTPUT                                                     */
 /*          HALMAT_INIT_CONST                                              */
 /***************************************************************************/
'''


class cICQ_CHECK_TYPE:

    def __init__(self):
        self.K = g.TRUE

        
lICQ_CHECK_TYPE = cICQ_CHECK_TYPE()


def ICQ_CHECK_TYPE(J, K=None):
    # Locals are SYT and I.
    l = lICQ_CHECK_TYPE
    if K != None:
        l.K = K
    
    I = g.IC_TYPE[J] & 0x7F;
    if g.NAME_IMPLIED: 
        return g.XNINT;
    if g.SYT_TYPE(g.ID_LOC) == g.MAJ_STRUC: 
        return g.XTINT;
    else: 
        SYT = g.ID_LOC;
    if g.SYT_TYPE(SYT) == g.CHAR_TYPE:  #  CAN ONLY BE SET TO CHAR
        if I != g.CHAR_TYPE:
            ERROR(d.CLASS_DI, 6, g.VAR[g.MP]);
        return g.XBINT[g.CHAR_TYPE - g.BIT_TYPE];
    
    if g.SYT_TYPE(SYT) == g.BIT_TYPE: 
        if I != g.BIT_TYPE:
            ERROR(d.CLASS_DI, 7, g.VAR[g.MP]);
        return g.XBINT[0];
    
    if g.SYT_TYPE(SYT) == g.EVENT_TYPE: 
        if I != g.BIT_TYPE:
            ERROR(d.CLASS_DI, 7, g.VAR[g.MP]);
        return g.XBINT[0];
    #  MUST NOW BE EITHER MATRIX, VECTOR, SCALAR, OR INTEGER
    if (I != g.INT_TYPE) and (I != g.SCALAR_TYPE):
        ERROR(d.CLASS_DI, 8, g.VAR[g.MP]);
    if l.K & 1: 
        return g.XBINT[g.SYT_TYPE(SYT) - g.BIT_TYPE];
    return g.XBINT[g.SCALAR_TYPE - g.BIT_TYPE];
