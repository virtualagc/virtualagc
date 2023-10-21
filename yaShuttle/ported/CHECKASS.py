#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   CHECKASS.py
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
from HALMATF3 import HALMAT_FIX_PIPTAGS
from SETXREFR import SET_XREF_RORS
from STABVAR import STAB_VAR

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  CHECK_ASSIGN_CONTEXT                                   */
 /* MEMBER NAME:     CHECKASS                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          T                 BIT(16)                                      */
 /*          FIX               FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ACCESS_FLAG                                                    */
 /*          CLASS_A                                                        */
 /*          CLASS_PS                                                       */
 /*          CLASS_SQ                                                       */
 /*          CONTEXT                                                        */
 /*          DELAY_CONTEXT_CHECK                                            */
 /*          FIXL                                                           */
 /*          FIXV                                                           */
 /*          INP_OR_CONST                                                   */
 /*          INX                                                            */
 /*          PTR                                                            */
 /*          SIMULATING                                                     */
 /*          SYM_FLAGS                                                      */
 /*          SYM_TAB                                                        */
 /*          SYT_FLAGS                                                      */
 /*          VAL_P                                                          */
 /*          VAR                                                            */
 /*          XREF_ASSIGN                                                    */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ARRAYNESS_FLAG                                                 */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          HALMAT_FIX_PIPTAGS                                             */
 /*          SET_XREF_RORS                                                  */
 /*          STAB_VAR                                                       */
 /* CALLED BY:                                                              */
 /*          CHECK_NAMING                                                   */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def CHECK_ASSIGN_CONTEXT(LOC):
    # Local T, FIX
    
    if g.CONTEXT > 0:
        SET_XREF_RORS(LOC);
        return;
    T = g.VAL_P[g.PTR[LOC]];
    if g.FIXV[LOC] != 0: 
        FIX = g.FIXV[LOC];
    else: 
        FIX = g.FIXL[LOC];  # NON-STRUC NAME PTR
    if (g.SYT_FLAGS(FIX) & g.INP_OR_CONST) != 0:
        ERROR(d.CLASS_A, 1, g.VAR[LOC]);
    if (g.SYT_FLAGS(FIX) & g.ACCESS_FLAG) != 0:
        ERROR(d.CLASS_PS, 8, g.VAR[LOC]);
    if g.SIMULATING: 
        STAB_VAR(LOC);
    SET_XREF_RORS(LOC, 0, g.XREF_ASSIGN);
    if SHR(T, 5) & 1: 
        HALMAT_FIX_PIPTAGS(g.INX[g.PTR[LOC]], 0, 1);
    if SHR(T, 6) & 1: 
        ERROR(d.CLASS_SQ, 3, g.VAR[LOC]);
    if g.DELAY_CONTEXT_CHECK: 
        return;
    g.ARRAYNESS_FLAG = 1;
