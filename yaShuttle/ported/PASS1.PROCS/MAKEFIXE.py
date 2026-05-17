#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   MAKEFIXE.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-28 RSB  Made a stub.
            2026-03-20 RSB  Added a 2nd version of the internals of the function
                            but continue to use the original (i.e., 1st version)
                            because the problem I was trying to address
                            (namely DD1 errors in compiling APPLSRC/RDDDDI) 
                            ultimately seemed to be unrelated to potential bugs
                            in this function.  But I've kept the 2nd version in
                            reserve since I still think that there may be bugs
                            here that may need to be addressed at some point.
            2026-05-14 RSB  Changes related to issue #1309.
            2026-05-16 RSB  Cleanup of HFP code for clarity.
'''

import math
from xplBuiltins import *
import g
from GETLITER import GET_LITERAL
from ibmFloat import ibm_dp_addsub, IBM_DP_OVERFLOW_PACKED, IBM_DP_ROUNDER, \
                     IBM_DP_FIXED_LIMIT, IBM_DP_SIGN_BIT, IBM_DP_MANT_MASK, \
                     IBM_DP_FIXER, hfpSplit, hfpJoin

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  MAKE_FIXED_LIT                                         */
 /* MEMBER NAME:     MAKEFIXE                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          LIMIT_OK          LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ADDR_FIXED_LIMIT                                               */
 /*          ADDR_FIXER                                                     */
 /*          ADDR_ROUNDER                                                   */
 /*          CONST_DW                                                       */
 /*          DW_AD                                                          */
 /*          DW                                                             */
 /*          LIT_PG                                                         */
 /*          LITERAL2                                                       */
 /*          LITERAL3                                                       */
 /*          LIT2                                                           */
 /*          LIT3                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FOR_DW                                                         */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          GET_LITERAL                                                    */
 /* CALLED BY:                                                              */
 /*          ARITH_SHAPER_SUB                                               */
 /*          CHECK_SUBSCRIPT                                                */
 /*          ERROR_SUB                                                      */
 /*          PREC_SCALE                                                     */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''

'''
MAKE_FIXED_LIT() is called from SYNTHESI to do various things, which I believe
includes handling the numeric literals (say, 2 and 3) in declarations 
such as:
 
    DECLARE V VECTOR(2);
    DECLARE M MATRIX(2,3);
    DECLARE B BIT(2);
    DECLARE C CHARACTER(3);
    
and (probably) lots more of a similar nature

Unfortunately, the XPL source is a mess of INLINEs, and the documentation in 
IR-182-1 merely tells us that `MAKE_FIXED_LIT` is a "procedure". Which is a 
factoid I had managed to deduce for myself.  The assumption is seemingly that 
the value of the literal has been loaded as an IBM DP HFP 
into the floating-point working area at DW[0] and DW[1].  We apparently need
to convert it to an integer, if possible.
'''

def MAKE_FIXED_LIT(PTR):
    PTR=GET_LITERAL(PTR);
    g.DW[0]=g.LIT2(PTR);
    g.DW[1]=g.LIT3(PTR);
    #print(f"^ {'%08X'%g.DW[0]},{'%08X'%g.DW[1]} {ibm_dp_to_hal_string(g.DW[0], g.DW[1], 16)}", file=sys.stderr)
    g.traceInline("MAKE_FIXED_LIT p33")
    #PTR = ADDR(LIMIT_OK);
    g.FR[0] = hfpJoin(g.DW[0], g.DW[1]) # p33_0, 4
    g.FR[0] &= IBM_DP_OVERFLOW_PACKED # p33_8
    g.FR[0] = ibm_dp_addsub(g.FR[0], IBM_DP_ROUNDER, 0, 1) # p33_10,14
    scratch = ibm_dp_addsub(g.FR[0], IBM_DP_FIXED_LIMIT, 1, 1) # p33_18,22,26
    if (scratch & IBM_DP_FIXED_LIMIT) != 0 or (scratch & IBM_DP_MANT_MASK) == 0: # p33_30
        pass # branch to LIMIT_OK
    else:
        g.FR[0] = IBM_DP_FIXED_LIMIT # p33_32
    #LIMIT_OK:
    g.traceInline("MAKE_FIXED_LIT p43")
    result = ibm_dp_addsub(g.FR[0], IBM_DP_FIXER, 0, 0) # p43_0, 4
    g.DW[2], g.DW[3] = hfpSplit(result) # p43_8
    
    if 0 != (1 & SHR(g.DW[0], 31)):
        return -g.DW[3]
    return g.DW[3]
# END MAKE_FIXED_LIT;
