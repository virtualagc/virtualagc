#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   MAKEFIXE.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-28 RSB  Made a stub.
'''

from xplBuiltins import *
import g
from GETLITER import GET_LITERAL

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

Unfortunately, the XPL source is an indecipherable (to me!) mess of INLINEs,
and the documentation in IR-182-1 is useless: MAKE_FIXED_LIT, it tells us,
is a "procedure". Which is a factoid I had managed to deduce for myself.
However, it appears to me that what the INLINEs are probably trying to do is
to detect that N can be interpreted as an integer, and to perform whatever
processing (such as rounding) that's needed to do that, probably with range
checking.  

The assumption is seemingly that the literal has been loaded as an IBM DP float, 
into the floating-point working area at DW[0] and DW[1].  Therefore, perhaps, 
all we really need to do, is to convert that value to a python float and round 
it correctly to an integer.
'''

def MAKE_FIXED_LIT(PTR):
    PTR=GET_LITERAL(PTR);
    g.DW[0]=g.LIT2(PTR);
    g.DW[1]=g.LIT3(PTR);
    if False:
        # Original implementation
        i = hround(fromFloatIBM(g.DW[0], g.DW[1]))
        if i < 0:
            i = -i
        return i
    else:
        # Replacement implementation
        g.traceInline("MAKE_FIXED_LIT p33")
        #PTR = ADDR(LIMIT_OK);
        g.FR[0] = fromFloatIBM(g.DW[0], g.DW[1]) # p33_0, 4
        g.FR[0] = abs(g.FR[0]) # p33_8
        g.FR[0] += fromFloatIBM(0x407FFFFF, 0xFFFFFFFF) # p33_10,14
        scratch = g.FR[0] - fromFloatIBM(0x487FFFFF, 0xFFFFFFFF) # p33_18,22,26
        if scratch <= 0: # p33_30
            pass # branch to LIMIT_OK
        else:
            g.FR[0] = fromFloatIBM(0x487FFFFF, 0xFFFFFFFF) # p33_32
        #LIMIT_OK:
        g.traceInline("MAKE_FIXED_LIT p43")
        g.DW[2] = 0 # p43 (all)
        g.DW[3] = int(g.FR[0])
        
        if 0 != (1 & SHR(g.DW[0], 31)):
            return -g.DW[3]
        return g.DW[3]
# END MAKE_FIXED_LIT;
