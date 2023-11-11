#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   HOWTOINI.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  Note that this port does not necessarily
            include all program comments that were present in the original code.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-27 RSB  Ported
'''

from xplBuiltins import OUTPUT
import g
import HALINCL.CERRDECL as d
from ERROR import ERROR
from HALINCL.ICQTERMp import ICQ_TERMp
from HALINCL.ICQARRAY import ICQ_ARRAYp

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  HOW_TO_INIT_ARGS                                       */
 /* MEMBER NAME:     HOWTOINI                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          NA                FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          NU                FIXED                                        */
 /*          NW                FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ID_LOC                                                         */
 /*          MAJ_STRUC                                                      */
 /*          NAME_IMPLIED                                                   */
 /*          SYM_ARRAY                                                      */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_ARRAY                                                      */
 /*          SYT_TYPE                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ICQ_TERM#                                                      */
 /*          ICQ_ARRAY#                                                     */
 /* CALLED BY:                                                              */
 /*          HALMAT_INIT_CONST                                              */
 /***************************************************************************/
'''


def HOW_TO_INIT_ARGS(NA):
    # Locals are NU, NW.
    
    if g.SYT_TYPE(g.ID_LOC) == g.MAJ_STRUC and (not g.NAME_IMPLIED):
        NU = ICQ_TERMp(g.ID_LOC);
        NW = NU
        if g.SYT_ARRAY(g.ID_LOC) > 0:
            NU = g.SYT_ARRAY(g.ID_LOC) * NU;
    else:
        if NA <= 1:
            return 1;
        NW = ICQ_TERMp(g.ID_LOC);
        NU = ICQ_ARRAYp(g.ID_LOC) * NW;
    if NA == NU:
        return 3;  # MATCHES TOTAL NUMBER OF ELEMENTS
    if NA == NW:
        return 2;
    if NA > NU:
        return 4;  # NO ROOM FOR ASTERISK
    return 0;  # NO MATCH AT ALL
