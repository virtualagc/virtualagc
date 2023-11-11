#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   MATCHSIM.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ERROR import ERROR
from HALMATTU import HALMAT_TUPLE
from SETUPVAC import SETUP_VAC

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  MATCH_SIMPLES                                          */
 /* MEMBER NAME:     MATCHSIM                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC1              BIT(16)                                      */
 /*          LOC2              BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          T1                BIT(16)                                      */
 /*          T2                BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          INT_TYPE                                                       */
 /*          PSEUDO_TYPE                                                    */
 /*          PTR                                                            */
 /*          SCALAR_TYPE                                                    */
 /*          XITOS                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HALMAT_TUPLE                                                   */
 /*          SETUP_VAC                                                      */
 /* CALLED BY:                                                              */
 /*          END_ANY_FCN                                                    */
 /*          MATCH_ARITH                                                    */
 /*          MULTIPLY_SYNTHESIZE                                            */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def MATCH_SIMPLES(LOC1, LOC2):
    T1 = g.PSEUDO_TYPE[g.PTR[LOC1]];
    T2 = g.PSEUDO_TYPE[g.PTR[LOC2]];
    if T1 != T2:
        if T2 == g.INT_TYPE:
            LOC1 = LOC2;
        HALMAT_TUPLE(g.XITOS, 0, LOC1, 0, 0);
        SETUP_VAC(LOC1, g.SCALAR_TYPE);
