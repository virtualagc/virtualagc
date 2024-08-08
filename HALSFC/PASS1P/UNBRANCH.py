#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   UNBRANCH.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-29 RSB  Ported from XPL
'''

import g
import HALINCL.CERRDECL as d
from ERROR import ERROR

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  UNBRANCHABLE                                           */
 /* MEMBER NAME:     UNBRANCH                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               BIT(16)                                      */
 /*          CAUSE             BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          FLAGGED           BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          CLASS_GL                                                       */
 /*          FIXF                                                           */
 /*          SYM_LENGTH                                                     */
 /*          SYM_PTR                                                        */
 /*          SYT_PTR                                                        */
 /*          TRUE                                                           */
 /*          VAR_LENGTH                                                     */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          SYM_TAB                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def UNBRANCHABLE(LOC, CAUSE):
    # Local: FLAGGED.

    FLAGGED = g.FALSE;
    LOC = g.FIXF[LOC];
    while LOC > 0:
        if g.VAR_LENGTH(LOC) == 3:
            FLAGGED = g.TRUE;
        g.VAR_LENGTH(LOC, CAUSE);
        LOC = g.SYT_PTR(LOC);
    if FLAGGED:
        ERROR(d.CLASS_GL, CAUSE);
