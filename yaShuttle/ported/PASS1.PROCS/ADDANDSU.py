#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   ADDANDSU.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ARITHLIT import ARITH_LITERAL
from ERROR    import ERROR
from HALMATTU import HALMAT_TUPLE
from LITRESUL import LIT_RESULT_TYPE
from MATCHARI import MATCH_ARITH
from SETUPVAC import SETUP_VAC
from HALINCL.SAVELITE import SAVE_LITERAL

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  ADD_AND_SUBTRACT                                       */
 /* MEMBER NAME:     ADDANDSU                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          MODE              BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          AS_FAIL(1613)     LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          DW_AD                                                          */
 /*          CLASS_VA                                                       */
 /*          MAT_TYPE                                                       */
 /*          MP                                                             */
 /*          PTR                                                            */
 /*          SP                                                             */
 /*          XMADD                                                          */
 /*          XMSUB                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          LOC_P                                                          */
 /*          PSEUDO_TYPE                                                    */
 /*          PTR_TOP                                                        */
 /*          TEMP                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ARITH_LITERAL                                                  */
 /*          ERROR                                                          */
 /*          HALMAT_TUPLE                                                   */
 /*          LIT_RESULT_TYPE                                                */
 /*          MATCH_ARITH                                                    */
 /*          SAVE_LITERAL                                                   */
 /*          SETUP_VAC                                                      */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def ADD_AND_SUBTRACT(MODE):
    # Persistence not required.
    al = ARITH_LITERAL(g.MP, g.SP)
    goto_AS_FAIL = False
    if al: 
        if MONITOR(9, MODE + 1):
            ERROR(d.CLASS_VA, MODE + 1);
            goto_AS_FAIL = True
        else:
            g.LOC_P[g.PTR[g.MP]] = SAVE_LITERAL(1, g.DW_AD());
            g.PSEUDO_TYPE[g.PTR[g.MP]] = LIT_RESULT_TYPE(g.MP, g.SP);
    if goto_AS_FAIL or not al:
        goto_AS_FAIL = False
        MATCH_ARITH(g.MP, g.SP);
        g.TEMP = g.PSEUDO_TYPE[g.PTR[g.MP]];
        if MODE == 0:
            MODE = g.XMADD(g.TEMP - g.MAT_TYPE);
        elif MODE == 1:
            MODE = g.XMSUB(g.TEMP - g.MAT_TYPE);
        HALMAT_TUPLE(MODE, 0, g.MP, g.SP, 0);
        SETUP_VAC(g.MP, g.TEMP);
    g.PTR_TOP = g.PTR[g.MP];
