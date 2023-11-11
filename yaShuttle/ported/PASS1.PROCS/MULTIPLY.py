#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   MULTIPLY.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-29 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ERROR import ERROR
from ARITHLIT import ARITH_LITERAL
from HALMATTU import HALMAT_TUPLE
from LITRESUL import LIT_RESULT_TYPE
from MATCHSIM import MATCH_SIMPLES
from SETUPVAC import SETUP_VAC
from VECTORCO import VECTOR_COMPARE
from HALINCL.SAVELITE import SAVE_LITERAL

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  MULTIPLY_SYNTHESIZE                                    */
 /* MEMBER NAME:     MULTIPLY                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /*          DOCASE            BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          MUL_FAIL(1638)    LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CLASS_EC                                                       */
 /*          CLASS_EM                                                       */
 /*          CLASS_EV                                                       */
 /*          CLASS_VA                                                       */
 /*          DW_AD                                                          */
 /*          MAT_TYPE                                                       */
 /*          PSEUDO_LENGTH                                                  */
 /*          SCALAR_TYPE                                                    */
 /*          VEC_TYPE                                                       */
 /*          XMMPR                                                          */
 /*          XMSPR                                                          */
 /*          XMVPR                                                          */
 /*          XSSPR                                                          */
 /*          XVCRS                                                          */
 /*          XVDOT                                                          */
 /*          XVMPR                                                          */
 /*          XVSPR                                                          */
 /*          XVVPR                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          LOC_P                                                          */
 /*          PSEUDO_TYPE                                                    */
 /*          PTR                                                            */
 /*          TEMP2                                                          */
 /*          TEMP                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ARITH_LITERAL                                                  */
 /*          ERROR                                                          */
 /*          HALMAT_TUPLE                                                   */
 /*          LIT_RESULT_TYPE                                                */
 /*          MATCH_SIMPLES                                                  */
 /*          SAVE_LITERAL                                                   */
 /*          SETUP_VAC                                                      */
 /*          VECTOR_COMPARE                                                 */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def MULTIPLY_SYNTHESIZE(I, J, K, DOCASE):
    # No locals.
    
    # print("\n!!", g.LOC_P[g.PTR[I]], g.LOC_P[g.PTR[J]], file=sys.stderr)
    
    # DO CASE (DOCASE) ;
    if DOCASE == 0:
        # CASE 0 : SCLAR AND/OR INTEGER MULT. */
        goto_MUL_FAIL = False
        al = ARITH_LITERAL(I, J)
        if al:
            if MONITOR(9, 3):
                ERROR(d.CLASS_VA, 3);
                goto_MUL_FAIL = True
            else:
                g.LOC_P[g.PTR[K]] = SAVE_LITERAL(1, g.DW_AD());
                g.PSEUDO_TYPE[g.PTR[K]] = LIT_RESULT_TYPE(I, J);
        if not al or goto_MUL_FAIL:  # Was just ELSE
            goto_MUL_FAIL = False
            MATCH_SIMPLES(I, J);
            HALMAT_TUPLE(g.XSSPR[g.PSEUDO_TYPE[g.PTR[I]] - g.SCALAR_TYPE], 0, I, J, 0);
            SETUP_VAC(K, g.PSEUDO_TYPE[g.PTR[I]]);
    elif DOCASE == 1:
        # CASE 1:  VECTOR   (SCALAR OR INTEGER)     */
        g.PTR[0] = 0;
        g.PSEUDO_TYPE[0] = g.SCALAR_TYPE;
        MATCH_SIMPLES(0, J);
        HALMAT_TUPLE(g.XVSPR, 0, I, J, 0);
        SETUP_VAC(K, g.VEC_TYPE, g.PSEUDO_LENGTH[g.PTR[I]]);
    elif DOCASE == 2:
        # CASE 2 : MATRIX (OP) (SCALAR OR INTEGER) */
        g.PTR[0] = 0;
        g.PSEUDO_TYPE[0] = g.SCALAR_TYPE;
        MATCH_SIMPLES(0, J);
        HALMAT_TUPLE(g.XMSPR, 0, I, J, 0);
        SETUP_VAC(K, g.MAT_TYPE, g.PSEUDO_LENGTH[g.PTR[I]]);
    elif DOCASE == 3:
        # CASE 3, VECTOR DOT VECTOR */
        VECTOR_COMPARE(I, J, d.CLASS_EV, 1);
        HALMAT_TUPLE(g.XVDOT, 0, I, J, 0);
        SETUP_VAC(K, g.SCALAR_TYPE);
    elif DOCASE == 4:
        # CASE 4, VECTOR CROSS VECTOR */
        HALMAT_TUPLE(g.XVCRS, 0, I, J, 0);
        SETUP_VAC(K, g.VEC_TYPE, 3);
        if (g.PSEUDO_LENGTH[g.PTR[I]] != 3) or (g.PSEUDO_LENGTH[g.PTR[J]] != 3):
           ERROR(d.CLASS_EC, 1);
    elif DOCASE == 5:
        # CASE 5,VECTOR  VECTOR */
        HALMAT_TUPLE(g.XVVPR, 0, I, J, 0);
        SETUP_VAC(K, g.MAT_TYPE, SHL(g.PSEUDO_LENGTH[g.PTR[I]], 8) + \
                             (g.PSEUDO_LENGTH[g.PTR[J]] & 0xFF));
    elif DOCASE == 6:
        # CASE 6 : VECTOR MATRIX */
        g.TEMP = SHR(g.PSEUDO_LENGTH[g.PTR[J]], 8);
        if g.TEMP != g.PSEUDO_LENGTH[g.PTR[I]]: 
            ERROR(d.CLASS_EV, 3);
        HALMAT_TUPLE(g.XVMPR, 0, I, J, 0);
        SETUP_VAC(K, g.VEC_TYPE, g.PSEUDO_LENGTH[g.PTR[J]] & 0xFF);
    elif DOCASE == 7:
        # CASE 7 : MATRIX VECTOR */
        g.TEMP = g.PSEUDO_LENGTH[g.PTR[I]] & 0xFF;
        if g.TEMP != g.PSEUDO_LENGTH[g.PTR[J]]: 
            ERROR(d.CLASS_EV, 2);
        HALMAT_TUPLE(g.XMVPR, 0, I, J, 0);
        SETUP_VAC(K, g.VEC_TYPE, SHR(g.PSEUDO_LENGTH[g.PTR[I]], 8));
    elif DOCASE == 8:
        # CASE 8 : MATRIX MATRIX */
        g.TEMP = g.PSEUDO_LENGTH[g.PTR[I]] & 0xFF;
        g.TEMP2 = SHR(g.PSEUDO_LENGTH[g.PTR[J]], 8);
        if g.TEMP != g.TEMP2: 
            ERROR(d.CLASS_EM, 3);
        HALMAT_TUPLE(g.XMMPR, 0, I, J, 0);
        SETUP_VAC(K, g.MAT_TYPE, (g.PSEUDO_LENGTH[g.PTR[I]] & 0xFF00) | \
                                (g.PSEUDO_LENGTH[g.PTR[J]] & 0x00FF));
    # END OF DO CASE 
