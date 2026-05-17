#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   LITRESUL.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
            2026-05-14 RSB  Changes related to issue #1306.
            2026-05-16 RSB  Cleanup of HFP code for clarity.
'''

from xplBuiltins import *
import g
from ibmFloat import ibm_dp_addsub, hfpJoin, hfpSplit, IBM_DP_OVERFLOW_PACKED, \
                     IBM_SP_MANT_MASK, IBM_SP_SIGN_BIT, IBM_DP_FIXED_LIMIT

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  LIT_RESULT_TYPE                                        */
 /* MEMBER NAME:     LITRESUL                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC1              BIT(16)                                      */
 /*          LOC2              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ADDR_FIXED_LIMIT                                               */
 /*          CONST_DW                                                       */
 /*          DW_AD                                                          */
 /*          DW                                                             */
 /*          FOR_DW                                                         */
 /*          INT_TYPE                                                       */
 /*          PSEUDO_TYPE                                                    */
 /*          PTR                                                            */
 /*          SCALAR_TYPE                                                    */
 /* CALLED BY:                                                              */
 /*          ADD_AND_SUBTRACT                                               */
 /*          MULTIPLY_SYNTHESIZE                                            */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def LIT_RESULT_TYPE(LOC1, LOC2):
    g.traceInline("LIT_RESULT_TYPE p86")
    g.FR[0] = hfpJoin(g.DW[0], g.DW[1]) # p86_0, 4
    g.FR[0] &= IBM_DP_OVERFLOW_PACKED # p86_8
    g.FR[0] = ibm_dp_addsub(g.FR[0], IBM_DP_FIXED_LIMIT, 1, 1) # p86_10, 14
    g.DW[2], g.DW[3] = hfpSplit(g.FR[0]) # p86_18
    
    if g.PSEUDO_TYPE[g.PTR[LOC1]] == g.INT_TYPE:
        if g.PSEUDO_TYPE[g.PTR[LOC2]] == g.INT_TYPE:
            if (g.DW[2] & IBM_SP_MANT_MASK) == 0 or 0 != (IBM_SP_SIGN_BIT & g.DW[2]):
                return g.INT_TYPE;
    return g.SCALAR_TYPE;
