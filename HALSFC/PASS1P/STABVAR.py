#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   STABVAR.py
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
 /* PROCEDURE NAME:  STAB_VAR                                               */
 /* MEMBER NAME:     STABVAR                                                */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          STAB_STACKER(1534)  LABEL                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FIXF                                                           */
 /*          CLASS_BT                                                       */
 /*          FIXL                                                           */
 /*          FIXV                                                           */
 /*          LOC_P                                                          */
 /*          PTR                                                            */
 /*          STAB_STACKLIM                                                  */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_TYPE                                                       */
 /*          TEMPL_NAME                                                     */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          STAB_STACK                                                     */
 /*          STAB_STACKTOP                                                  */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          CHECK_ASSIGN_CONTEXT                                           */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def STAB_VAR(LOC):
    # Local: I

    def STAB_STACKER(ENTRY):
        if g.STAB_STACKTOP==g.STAB_STACKLIM: 
            ERROR(d.CLASS_BT,2);
        else: 
           g.STAB_STACKTOP=g.STAB_STACKTOP+1;
           g.STAB_STACK[g.STAB_STACKTOP]=ENTRY;
    # END STAB_STACKER;
    
    if g.FIXV[LOC]>0:
        STAB_STACKER((g.FIXV[LOC] & 0x7FFF) | 0x8000);
        for I in range(g.PTR[LOC]+1, g.FIXF[LOC] + 1):
            STAB_STACKER(g.LOC_P[I] & 0x7FFF);
        if SYT_TYPE(g.FIXL[LOC])==g.TEMPL_NAME: 
            return;
        I=0;
    else: 
        I = 0x8000;
    STAB_STACKER((g.FIXL[LOC] & 0x7FFF) | I);
