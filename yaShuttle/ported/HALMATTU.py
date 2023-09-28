#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   HALMATTU.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

import g
from HALMATPI import HALMAT_PIP
from HALMATPO import HALMAT_POP

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  HALMAT_TUPLE                                           */
 /* MEMBER NAME:     HALMATTU                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          POPCODE           BIT(16)                                      */
 /*          COPT              BIT(8)                                       */
 /*          OP1               BIT(16)                                      */
 /*          OP2               BIT(16)                                      */
 /*          TAG               BIT(8)                                       */
 /*          OP1T1             BIT(8)                                       */
 /*          OP1T2             BIT(8)                                       */
 /*          OP2T1             BIT(8)                                       */
 /*          OP2T2             BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LOC_P                                                          */
 /*          PSEUDO_FORM                                                    */
 /*          PTR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HALMAT_POP                                                     */
 /*          HALMAT_PIP                                                     */
 /* CALLED BY:                                                              */
 /*          ADD_AND_SUBTRACT                                               */
 /*          ARITH_TO_CHAR                                                  */
 /*          END_ANY_FCN                                                    */
 /*          END_SUBBIT_FCN                                                 */
 /*          MATCH_SIMPLES                                                  */
 /*          MULTIPLY_SYNTHESIZE                                            */
 /*          PREC_SCALE                                                     */
 /*          SETUP_CALL_ARG                                                 */
 /*          SETUP_NO_ARG_FCN                                               */
 /*          SYNTHESIZE                                                     */
 /*          UNARRAYED_INTEGER                                              */
 /*          UNARRAYED_SCALAR                                               */
 /***************************************************************************/
'''


def HALMAT_TUPLE(POPCODE, COPT, OP1, OP2, TAG, OP1T1=0, OP1T2=0, OP2T1=0, OP2T2=0):
    # This procedure is called with as few as 5 parameters, but the final 4
    # are always reset to 0, so we don't need to allow for persistence.    
    HALMAT_POP(POPCODE, (OP1 > 0) + (OP2 > 0), COPT, TAG);
    if OP1 > 0:
        HALMAT_PIP(g.LOC_P[g.PTR[OP1]], g.PSEUDO_FORM[g.PTR[OP1]], OP1T1, OP1T2);
    if OP2 > 0:
        HALMAT_PIP(g.LOC_P[g.PTR[OP2]], g.PSEUDO_FORM[g.PTR[OP2]], OP2T1, OP2T2);
