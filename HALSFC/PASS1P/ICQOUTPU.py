#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   ICQOUTPU.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  Note that this port does not necessarily
            include all program comments that were present in the original code.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-27 RSB  Ported
'''

from xplBuiltins import OUTPUT
import g
import HALINCL.CERRDECL as d
from ERROR    import ERROR
from GETICQ   import GET_ICQ
from HALMATF3 import HALMAT_FIX_PIPTAGS
from HALMATPI import HALMAT_PIP
from HALMATPO import HALMAT_POP
from ICQCHECK import ICQ_CHECK_TYPE

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  ICQ_OUTPUT                                             */
 /* MEMBER NAME:     ICQOUTPU                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CT                FIXED                                        */
 /*          CT_LIT            BIT(16)                                      */
 /*          CT_LITPTR         BIT(16)                                      */
 /*          CT_OFFPTR         BIT(16)                                      */
 /*          EMIT_XINT         LABEL                                        */
 /*          K                 FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          IC_FORM                                                        */
 /*          IC_LEN                                                         */
 /*          IC_LOC                                                         */
 /*          IC_TYPE                                                        */
 /*          IC_VAL                                                         */
 /*          ICQ                                                            */
 /*          ID_LOC                                                         */
 /*          INX                                                            */
 /*          LAST_POP#                                                      */
 /*          MAJ_STRUC                                                      */
 /*          NEXT_ATOM#                                                     */
 /*          PSEUDO_LENGTH                                                  */
 /*          STRUC_PTR                                                      */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_TYPE                                                       */
 /*          XELRI                                                          */
 /*          XETRI                                                          */
 /*          XEXTN                                                          */
 /*          XIMD                                                           */
 /*          XLIT                                                           */
 /*          XOFF                                                           */
 /*          XSLRI                                                          */
 /*          XSTRI                                                          */
 /*          XSYT                                                           */
 /*          XXPT                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          GET_ICQ                                                        */
 /*          HALMAT_FIX_PIPTAGS                                             */
 /*          HALMAT_PIP                                                     */
 /*          HALMAT_POP                                                     */
 /*          ICQ_CHECK_TYPE                                                 */
 /* CALLED BY:                                                              */
 /*          HALMAT_INIT_CONST                                              */
 /***************************************************************************/
'''


def ICQ_OUTPUT():
    # Locals are CT, K, CT_LIT, CT_OFFPTR, CT_LITPTR
      
    if g.SYT_TYPE(g.ID_LOC) == g.MAJ_STRUC:
        HALMAT_POP(g.XEXTN, 2, 0, 0);
        HALMAT_PIP(g.ID_LOC, g.XSYT, 0, 0);
        HALMAT_PIP(g.STRUC_PTR, g.XSYT, 0, 0);
        CT = g.LAST_POPp;
        K = g.XXPT;
    else: 
        CT = g.ID_LOC;
        K = g.XSYT;
    HALMAT_POP(g.XSTRI, 1, 0, 0);
    HALMAT_PIP(CT, K, 0, 0);
    CT = 1;
    CT_LIT = 0;
    while CT < g.PSEUDO_LENGTH[g.ICQ]:
        K = GET_ICQ(CT + g.INX[g.ICQ]);
        CT = CT + 1;
        if g.IC_FORM[K] == 2:  #  XINT
            goto_EMIT_XINT = False
            firstTry = True
            while firstTry or goto_EMIT_XINT:
                firstTry = False
                if CT_LIT == 0 or goto_EMIT_XINT:
                    goto_EMIT_XINT = False
                    HALMAT_POP(ICQ_CHECK_TYPE(K, 0), 2, 0, g.IC_TYPE[K]);
                    HALMAT_PIP(g.IC_VAL[K], g.XOFF, 0, 0);
                    HALMAT_PIP(g.IC_LOC[K], g.IC_LEN[K], 0, 0);
                    if g.IC_LEN[K] == g.XLIT: 
                        CT_OFFPTR = g.IC_VAL[K];
                        CT_LITPTR = g.IC_LOC[K];
                        CT_LIT = 1;
                    else: 
                        CT_LIT = 0;
                elif g.IC_LEN[K] != g.XLIT or CT_LIT == 255 or \
                        (CT_OFFPTR + CT_LIT) != g.IC_VAL[K] or \
                        (CT_LITPTR + CT_LIT) != g.IC_LOC[K]:
                    HALMAT_FIX_PIPTAGS(g.NEXT_ATOMp - 1, CT_LIT, 0);
                    goto_EMIT_XINT = True
                    continue
                else:
                    ICQ_CHECK_TYPE(K, 0);
                    CT_LIT = CT_LIT + 1;
        else:
            if CT_LIT > 0: 
                HALMAT_FIX_PIPTAGS(g.NEXT_ATOMp - 1, CT_LIT, 0);
                CT_LIT = 0;
            if g.IC_FORM[K] == 1:  #  SLRI
                HALMAT_POP(g.XSLRI, 2, 0, g.IC_VAL[K]);
                HALMAT_PIP(g.IC_LOC[K], g.XIMD, 0, 0);
                HALMAT_PIP(g.IC_LEN[K], g.XIMD, 0, 0);
            else: 
                HALMAT_POP(g.XELRI, 0, 0, g.IC_VAL[K]);  # ELRI  
    if CT_LIT > 0: 
        HALMAT_FIX_PIPTAGS(g.NEXT_ATOMp - 1, CT_LIT, 0);
    HALMAT_POP(g.XETRI, 0, 0, 0);
