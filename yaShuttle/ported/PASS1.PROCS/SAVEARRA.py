#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   SAVEARRA.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  Note that this port does not necessarily
            include all program comments that were present in the original code.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-28 RSB  Began porting
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ERROR import ERROR

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  SAVE_ARRAYNESS                                         */
 /* MEMBER NAME:     SAVEARRA                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          RESET             BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AS_PTR_MAX                                                     */
 /*          CLASS_BS                                                       */
 /*          TRUE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          AS_PTR                                                         */
 /*          ARRAYNESS_STACK                                                */
 /*          CURRENT_ARRAYNESS                                              */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          ASSOCIATE                                                      */
 /*          SETUP_CALL_ARG                                                 */
 /*          START_NORMAL_FCN                                               */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def SAVE_ARRAYNESS(RESET=g.TRUE):
    # Local: I
    
    # SAVE OLD CURRENT ARRAYNESS AND ZERO THE NEW 
    if g.CURRENT_ARRAYNESS[0] + g.AS_PTR >= g.AS_PTR_MAX:
        ERROR(d.CLASS_BS, 4);
    g.AS_PTR = g.AS_PTR + g.CURRENT_ARRAYNESS[0] + 1;
    for I in range(1, g.CURRENT_ARRAYNESS[0] + 1):
        g.ARRAYNESS_STACK[g.AS_PTR - I] = g.CURRENT_ARRAYNESS[I];
    g.ARRAYNESS_STACK[g.AS_PTR] = g.CURRENT_ARRAYNESS[0];
    if RESET:
         g.CURRENT_ARRAYNESS[0] = 0;
    RESET = g.TRUE;
