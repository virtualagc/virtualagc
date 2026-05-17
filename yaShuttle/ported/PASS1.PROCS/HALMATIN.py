#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   HALMATIN.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  Note that this port does not necessarily
            include all program comments that were present in the original code.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-25 RSB  Ported.
            2023-11-14 RSB  Imported SAVE_LITERAL.
            2026-05-15 RSB  Changes in `ROUND_SCALAR` related to issue #1306.
            2026-05-16 RSB  Cleanup of HFP code for clarity ... including a
                            bug fix for it a p117_10 in which DW(1) was given
                            a wrong value.
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
import HALINCL.COMMON   as h
from ERROR    import ERROR
from ERRORS   import ERRORS
from GETICQ   import GET_ICQ
from GETLITER import GET_LITERAL
from HALMATPI import HALMAT_PIP
from HALMATPO import HALMAT_POP
from HOWTOINI import HOW_TO_INIT_ARGS
from ICQARRA2 import ICQ_ARRAYNESS_OUTPUT
from ICQCHECK import ICQ_CHECK_TYPE
from ICQOUTPU import ICQ_OUTPUT
from HALINCL.SAVELITE import SAVE_LITERAL

import sys
from ibmFloat import ibm_dp_addsub, ibm_dp_to_hal_string, hfpSplit, hfpJoin, \
                     IBM_DP_MANT_MASK, IBM_DP_SIGN_BIT, IBM_DP_OVERFLOW_PACKED, \
                     IBM_DP_ROUNDER, IBM_DP_FIXED_LIMIT, IBM_DP_FIXER, \
                     IBM_SP_SIGN_BIT
'''
 /***************************************************************************/
 /* PROCEDURE NAME:  HALMAT_INIT_CONST                                      */
 /* MEMBER NAME:     HALMATIN                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 FIXED                                        */
 /*          MULTI_VALUED      LABEL                                        */
 /*          NON_EVALUABLE     LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CHAR_TYPE                                                      */
 /*          CLASS_DI                                                       */
 /*          CONSTANT_FLAG                                                  */
 /*          FALSE                                                          */
 /*          IC_FORM                                                        */
 /*          IC_LEN                                                         */
 /*          IC_LOC                                                         */
 /*          IC_PTR1                                                        */
 /*          IC_PTR2                                                        */
 /*          IC_TYPE                                                        */
 /*          ID_LOC                                                         */
 /*          LOC_P                                                          */
 /*          MP                                                             */
 /*          NAME_IMPLIED                                                   */
 /*          PSEUDO_TYPE                                                    */
 /*          SYM_ARRAY                                                      */
 /*          SYM_FLAGS                                                      */
 /*          SYM_PTR                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_ARRAY                                                      */
 /*          SYT_FLAGS                                                      */
 /*          SYT_PTR                                                        */
 /*          SYT_TYPE                                                       */
 /*          TRUE                                                           */
 /*          VAR                                                            */
 /*          XLIT                                                           */
 /*          XSYT                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          DO_INIT                                                        */
 /*          IC_FOUND                                                       */
 /*          IC_LINE                                                        */
 /*          ICQ                                                            */
 /*          INIT_EMISSION                                                  */
 /*          INX                                                            */
 /*          PTR_TOP                                                        */
 /*          SYM_TAB                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          GET_ICQ                                                        */
 /*          HALMAT_PIP                                                     */
 /*          HALMAT_POP                                                     */
 /*          HOW_TO_INIT_ARGS                                               */
 /*          ICQ_ARRAYNESS_OUTPUT                                           */
 /*          ICQ_CHECK_TYPE                                                 */
 /*          ICQ_OUTPUT                                                     */
 /* CALLED BY:                                                              */
 /*          SET_SYT_ENTRIES                                                */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
''' 

maxFIXED = (1 << 31) - 1
minFIXED = -(1 << 31)
def HALMAT_INIT_CONST ():
    # Locals: I, TEMP, CONSTLIT
    #print("@ Here", file=sys.stderr)

    def MULTI_VALUED():
        g.MONO_VAL = 0b110000011000;
        
        if g.NAME_IMPLIED: 
            return 2;
        if g.SYT_ARRAY(g.ID_LOC) != 0: 
            return g.TRUE;
        if g.SYT_TYPE(g.ID_LOC) < g.CHAR_TYPE: 
            return 2;
        return  SHR(g.MONO_VAL, g.SYT_TYPE(g.ID_LOC)) & 1;
    # END MULTI_VALUED;
    
    #  ROUTINE CREATED TO ROUND A SCALAR LITERAL IN AN INTEGER CONSTANT
    #  DECLARATION TO THE NEAREST WHOLE NUMBER.  IT IS BASED ON MAKE_FIXED_LIT
    #  AND FLOATING.  IT RETURNS FALSE IF THE NUMBER IS OUTSIDE THE RANGE OF
    #  ALLOWED INTEGERS OR IT RETURNS TRUE AND THE ROUNDED NUMBER IS IN DW().
    def ROUND_SCALAR(PTR):
        PTR = GET_LITERAL(PTR)
        ADJ_NEG = 0x41100000
        g.DW[0] = g.LIT2(PTR)
        g.DW[1] = g.LIT3(PTR)
        #print(f"@ {'%08X'%g.DW[0]},{'%08X'%g.DW[1]} {ibm_dp_to_hal_string(g.DW[0], g.DW[1], 16)}", file=sys.stderr)
        #PTR = ADDR(LIMIT_OK) for branches to LIMIT_OK.
        NEG = SHR(g.DW[0], 31)
        # The `while` is so that `GOTO LIMIT_OK` can be `break`. The `while`
        # doesn't actually loop at all, since it ends with a `return`.
        while True: 
            # start of patch92.c
            g.traceInline("ROUND_SCALAR p92")
            g.FR[0] = hfpJoin(g.DW[0], g.DW[1]) # p92_0, _4.
            g.FR[0] &= IBM_DP_OVERFLOW_PACKED  # p92_8
            g.FR[0] = ibm_dp_addsub(g.FR[0], IBM_DP_ROUNDER, 0, 1) # 0.5 p92_10, 14
            scratch = ibm_dp_addsub(g.FR[0], IBM_DP_FIXED_LIMIT, 1, 1) # p92_18, 22, 26
            if (scratch & IBM_DP_SIGN_BIT) != 0 or (scratch & IBM_DP_MANT_MASK) == 0: # <= max integer p92_30
                break # go to LIMIT_OK
            # end of patch92.c
            if 0 != (NEG & 1):
                # start of patch101.c
                g.traceInline("ROUND_SCALAR p101")
                g.FR[4] = hfpJoin(g.DW[0], g.DW[1]) # p101_0
                g.FR[4] &= IBM_DP_OVERFLOW_PACKED # p101_4
                g.FR[2] = 0 # p101_6
                g.FR[2] = hfpJoin(ADJ_NEG, 0) # 1.0 p101_8
                g.FR[4] = ibm_dp_addsub(g.FR[4], g.FR[2], 1, 1) # p101_12
                g.FR[4] = ibm_dp_addsub(g.FR[4], IBM_DP_ROUNDER, 0, 1) # 0.5 p101_14, 18
                scratch = ibm_dp_addsub(g.FR[4], IBM_DP_FIXED_LIMIT, 1, 1) # max int p101_22, 26, 30
                if (scratch & IBM_DP_SIGN_BIT) != 0 or (scratch & IBM_DP_MANT_MASK) == 0: # p101_34
                    break # goto LIMIT_OK
                # end of patch101.c
            return g.FALSE
        #LIMIT_OK:
        # start of patch112.c.  Note that in principle, GR[3] would have
        # been loaded by prior CALL INLINEs with `DW_AD`.
        g.traceInline("ROUND_SCALAR p112")
        g.FR[0] = ibm_dp_addsub(g.FR[0], IBM_DP_FIXER, 0, 0) # p112_0, 4
        g.DW[2], g.DW[3] = hfpSplit(g.FR[0]) # p112_8
        # end of patch112.c
        g.DW[0] = g.DW[8]
        if 0 != (NEG & 1):
            # start of patch115.c
            g.traceInline("ROUND_SCALAR p115")
            g.DW[0] = g.DW[0] ^ IBM_SP_SIGN_BIT
            # end of patch115.c
        g.DW[1] = g.DW[3]
        # start of patch117.c
        g.traceInline("ROUND_SCALAR p117")
        g.FR[0] = 0 # p117_0, 4
        g.FR[0] = ibm_dp_addsub(0, hfpJoin(g.DW[0], g.DW[1]), 0, 1)  # p117_0, 6
        g.DW[0], g.DW[1] = hfpSplit(g.FR[0]) # p117_10
        # end of patch117.c
        return g.TRUE
    # END ROUND_SCALAR;
    
    if g.IC_FOUND == 0:  #  RETURN IN CASE OF NO INITIALIZATION
        return;
    if g.IC_FOUND > 1:  # IS NORMAL NON_FACTORED CASE
        g.ICQ = g.IC_PTR2;  # SET UP LIST PRT
        g.IC_FOUND = g.IC_FOUND - 2;  # THIS INIT CAN ONLY BE USED ONCE
        g.IC_LINE = g.INX[g.IC_PTR2];  # TO REUSE FILE_SPACE
        g.PTR_TOP = g.IC_PTR2 - 1;  # SO RESET PTR_TOP AND INDICATORS
    else:  # FACTORED CASE, SET PTR, BUT CAN'T RESET SINCE MULT. USAGE
        g.ICQ = g.IC_PTR1;
    if g.DO_INIT: 
        g.DO_INIT = g.FALSE;
    else: 
        return;
    # DO CASE HOW_TO_INIT_ARGS(LOC_P(ICQ));
    howto = HOW_TO_INIT_ARGS(g.LOC_P[g.ICQ])
    if howto == 0:
        #  CASE 0,  TOO FEW ELEMENTS
        if g.PSEUDO_TYPE[g.ICQ] == 0: 
            ERROR(d.CLASS_DI, 5, g.VAR[g.MP]);
        ICQ_OUTPUT();
    elif howto == 1:
        #  CASE 1, ONE ARGUMENT
        if g.PSEUDO_TYPE[g.ICQ] != 0:
            if not (MULTI_VALUED() & 1): 
                ERROR(d.CLASS_DI, 4, g.VAR[g.MP]);
            ICQ_OUTPUT();
        else: 
            I = GET_ICQ(g.INX[g.ICQ] + 1);
            while g.IC_FORM[I] != 2:
                g.INX[g.ICQ] = g.INX[g.ICQ] + 1;
                I = GET_ICQ(g.INX[g.ICQ] + 1);
            
            goto_NON_EVALUABLE = False
            if MULTI_VALUED() > 0: 
                goto_NON_EVALUABLE = True
            else:
                sf = ((g.SYT_FLAGS(g.ID_LOC) & g.CONSTANT_FLAG) != 0)
                if sf:
                    if g.IC_LEN[I] != g.XLIT: 
                        goto_NON_EVALUABLE = True
                    else:
                        ICQ_CHECK_TYPE(I);
                        
                        CONSTLIT = GET_LITERAL(g.IC_LOC[I]);
                        #   ROUND SCALARS IN INTEGER CONSTANT DECLARE
                        #   OR EMIT AN ERROR IF OUTSIDE OF RANGE OF INTEGERS
                        if g.SYT_TYPE(g.ID_LOC) == g.INT_TYPE:
                            if ROUND_SCALAR(g.IC_LOC[I]) & 1:
                                if g.IC_TYPE[I] == g.SCALAR_TYPE:
                                    g.IC_LOC[I] = SAVE_LITERAL(1, hfpJoin(g.DW[0], g.DW[1]));
                            else: 
                                ERRORS(d.CLASS_DI, 17);
                        if (g.SYT_TYPE(g.ID_LOC) == g.CHAR_TYPE) and \
                                (g.LIT1(CONSTLIT) == 0):
                            TEMP = STRING(g.LIT2(CONSTLIT), h.lit_char);
                            if (LENGTH(TEMP) > g.VAR_LENGTH(g.ID_LOC)):
                                ERROR(d.CLASS_DI, 18, g.SYT_NAME(g.ID_LOC));
                                TEMP = SUBSTR(TEMP, 0, g.VAR_LENGTH(g.ID_LOC));
                                g.SYT_PTR(g.ID_LOC, -SAVE_LITERAL(0, TEMP));
                            else:
                                g.SYT_PTR(g.ID_LOC, -g.IC_LOC[I]);
                        else:
                            g.SYT_PTR(g.ID_LOC, -g.IC_LOC[I]);
            if goto_NON_EVALUABLE or not sf:  # Was just ELSE
                goto_NON_EVALUABLE = False
                HALMAT_POP(ICQ_CHECK_TYPE(I, 1), 2, 0, g.IC_TYPE[I]);
                HALMAT_PIP(g.ID_LOC, g.XSYT, 0, 0);
                HALMAT_PIP(g.IC_LOC[I], g.IC_LEN[I], 0, 0);
                ICQ_ARRAYNESS_OUTPUT();
    elif howto == 2:
        #  CASE 2,  MATCHES TERMINAL NUMBER
        ICQ_OUTPUT();
        if g.PSEUDO_TYPE[g.ICQ] == 0: 
            ICQ_ARRAYNESS_OUTPUT();
    elif howto == 3:
        #  CASE 3,  MATCHES TOTAL NUMBER
        if g.PSEUDO_TYPE[g.ICQ] != 0: 
            ERROR(d.CLASS_DI, 4, g.VAR[g.MP]);
        ICQ_OUTPUT();
    elif howto == 4:
        #  CASE 4,  TOO MANY ELEMENTS
        ERROR(d.CLASS_DI, 10, g.VAR[g.MP]);
        ICQ_OUTPUT();
    # END of DO CASE;
    g.INIT_EMISSION = g.TRUE;
    
