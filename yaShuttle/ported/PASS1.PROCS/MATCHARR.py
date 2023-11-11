#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   MATCHARR.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  Note that this port does not necessarily
            include all program comments that were present in the original code.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-28 RSB  Ported
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ERROR import ERROR

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  MATCH_ARRAYNESS                                        */
 /* MEMBER NAME:     MATCHARR                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          J                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ARRAYNESS_FLAG                                                 */
 /*          CLASS_AA                                                       */
 /*          CLASS_EA                                                       */
 /*          MP                                                             */
 /*          VAR                                                            */
 /*          g.VAR_ARRAYNESS                                                  */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CURRENT_ARRAYNESS                                              */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          ATTACH_SUBSCRIPT                                               */
 /***************************************************************************/
'''


def MATCH_ARRAYNESS():
    # Local: J

    if g.VAR_ARRAYNESS[0] == 0: 
        return;
    if g.CURRENT_ARRAYNESS[0] == 0:
        for J in range(0, g.VAR_ARRAYNESS[0] + 1):
            g.CURRENT_ARRAYNESS[J] = g.VAR_ARRAYNESS[J];
        return;
    for J in range(0, g.CURRENT_ARRAYNESS[0] + 1):
        if g.CURRENT_ARRAYNESS[J] > 0:
            if g.VAR_ARRAYNESS[J] > 0:
                if g.CURRENT_ARRAYNESS[J] != g.VAR_ARRAYNESS[J]:
                    if g.ARRAYNESS_FLAG: 
                        ERROR(d.CLASS_AA, 3, g.VAR[g.MP]);
                    else: 
                        ERROR(d.CLASS_EA, 1, g.VAR[g.MP]);
                    return;
        else: 
            g.CURRENT_ARRAYNESS[J] = g.VAR_ARRAYNESS[J];
