#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   IORS.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  Note that this port does not necessarily
            include all program comments that were present in the original code.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-10-07 RSB  Ported
'''

from xplBuiltins import OUTPUT
import g
import HALINCL.CERRDECL as d
from ERROR import ERROR

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  IORS                                                   */
 /* MEMBER NAME:     IORS                                                   */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          INT_TYPE                                                       */
 /*          CLASS_ST                                                       */
 /*          MP                                                             */
 /*          PTR                                                            */
 /*          SCALAR_TYPE                                                    */
 /*          VAR                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          PSEUDO_TYPE                                                    */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def IORS(LOC):
    # No locals
    LOC = g.PTR[LOC];
    if g.PSEUDO_TYPE[LOC] != g.INT_TYPE:
        if g.PSEUDO_TYPE[LOC] != g.SCALAR_TYPE:
            ERROR(d.CLASS_ST, 1, g.VAR[g.MP]);
            g.PSEUDO_TYPE[LOC] = g.INT_TYPE;
