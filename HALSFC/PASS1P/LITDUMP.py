#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   LITDUMP.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  Note that this port does not necessarily
            include all program comments that were present in the original code.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-27 RSB  Ported.
'''

from xplBuiltins import *
import g
import HALINCL.COMMON as h
from GETLITER import GET_LITERAL
from HEX import HEX
from IFORMAT import I_FORMAT

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  LIT_DUMP                                               */
 /* MEMBER NAME:     LITDUMP                                                */
 /* LOCAL DECLARATIONS:                                                     */
 /*          S                 CHARACTER;                                   */
 /*          T                 CHARACTER;                                   */
 /*          TEMP              FIXED                                        */
 /*          ZEROS             CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          COMM                                                           */
 /*          DOUBLE                                                         */
 /*          DOUBLE_SPACE                                                   */
 /*          LIT_PG                                                         */
 /*          LIT_TOP                                                        */
 /*          LITERAL1                                                       */
 /*          LITERAL2                                                       */
 /*          LITERAL3                                                       */
 /*          LIT1                                                           */
 /*          LIT2                                                           */
 /*          LIT3                                                           */
 /*          X1                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          I                                                              */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          GET_LITERAL                                                    */
 /*          HEX                                                            */
 /*          I_FORMAT                                                       */
 /* CALLED BY:                                                              */
 /*          PRINT_SUMMARY                                                  */
 /***************************************************************************/
'''


def LIT_DUMP():
    # Locals are TEMP, S, T, and ZEROS.
    # Note that SCALAR DOUBLE is *deliberately* displayed just in 
    # single precision in the table. (Due to DR109083; presumably 
    # displayed differently prior to that.)  Moreover, due to the 
    # truncation of T, the type field for any DOUBLE (INTEGER or 
    # SCALAR) is left blank; whether that's deliberate or else just a 
    # kooky cock-up, I don't know.
    T = '  CHAR   ARITH    BIT    '
    ZEROS = '00000000'
       
    if g.LIT_TOP == 0:
        return;
    OUTPUT(1, '0L I T E R A L   T A B L E   D U M P:');
    OUTPUT(1, '0 LOC  TYPE          LITERAL');
    OUTPUT(0, g.X1);
    for g.I in range(1, g.LIT_TOP() + 1):
        if g.I in [8, 9]:
            pass
        TEMP = GET_LITERAL(g.I);
        # DO CASE (LIT1(TEMP) & "3");
        lt = g.LIT1(TEMP) & 0x03
        if lt == 0:
            # CHARACTER
            S = STRING(g.LIT2(TEMP), h.lit_char);
            if LENGTH(S) > 100:
                S = SUBSTR(S, 0, 100);
        elif lt == 1:
            # ARITHMETIC
            S = HEX(g.LIT3(TEMP));
            if LENGTH(S) < 8:
                S = SUBSTR(ZEROS, LENGTH(S)) + S;
            S = HEX(g.LIT2(TEMP)) + S;
            if LENGTH(S) < 16:
                S = SUBSTR(ZEROS, LENGTH(S) - 8) + S;
        elif lt == 2:
            # BIT
            S = HEX(g.LIT2(TEMP));
            if LENGTH(S) < 8:
                S = SUBSTR(ZEROS, LENGTH(S)) + S;
            S = S + ' (' + str(g.LIT3(TEMP)) + ')';
        # END;
        OUTPUT(0, I_FORMAT(g.I, 4) + SUBSTR(T, SHL(g.LIT1(TEMP), 3), 8) + S);
    g.DOUBLE_SPACE();
