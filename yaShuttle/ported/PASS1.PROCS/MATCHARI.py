#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   MATCHARI.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ERROR import ERROR
from MATRIXCO import MATRIX_COMPARE
from VECTORCO import VECTOR_COMPARE
from MATCHSIM import MATCH_SIMPLES

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  MATCH_ARITH                                            */
 /* MEMBER NAME:     MATCHARI                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC1              BIT(16)                                      */
 /*          LOC2              BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          ARITH_VALID(3)    BIT(8)                                       */
 /*          I                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CLASS_E                                                        */
 /*          CLASS_EM                                                       */
 /*          CLASS_EV                                                       */
 /*          MAT_TYPE                                                       */
 /*          PSEUDO_TYPE                                                    */
 /*          PTR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          MATCH_SIMPLES                                                  */
 /*          MATRIX_COMPARE                                                 */
 /*          VECTOR_COMPARE                                                 */
 /* CALLED BY:                                                              */
 /*          ADD_AND_SUBTRACT                                               */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''

ARITH_VALID = (0b0001, 0b0010, 0b1100, 0b1100)


def MATCH_ARITH(LOC1, LOC2):
    # Local: I, ARITH_VALID
    
    I = g.PSEUDO_TYPE[g.PTR[LOC1]] - g.MAT_TYPE;
    if (SHL(1, g.PSEUDO_TYPE[g.PTR[LOC2]] - g.MAT_TYPE) & ARITH_VALID[I]) == 0:
        ERROR(d.CLASS_E, 6);
    else:
        if I == 0:
            MATRIX_COMPARE(LOC1, LOC2, d.CLASS_EM, 1);
        elif I == 1:
            VECTOR_COMPARE(LOC1, LOC2, d.CLASS_EV, 1);
        elif I == 2:
            MATCH_SIMPLES(LOC1, LOC2);
        elif I == 3:
            MATCH_SIMPLES(LOC1, LOC2);
