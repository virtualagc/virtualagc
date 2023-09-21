#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   EMITSMRK.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
from HALMATPI import HALMAT_PIP
from HALMATPO import HALMAT_POP
from HALMATRE import HALMAT_RELOCATE
from STABHDR  import STAB_HDR

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  EMIT_SMRK                                              */
 /* MEMBER NAME:     EMITSMRK                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          T                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          HALMAT_RELOCATE_FLAG                                           */
 /*          INLINE_LEVEL                                                   */
 /*          NEXT_ATOM#                                                     */
 /*          SIMULATING                                                     */
 /*          SRN_PRESENT                                                    */
 /*          STMT_NUM                                                       */
 /*          TRUE                                                           */
 /*          XCO_N                                                          */
 /*          XIMRK                                                          */
 /*          XSMRK                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ATOM#_FAULT                                                    */
 /*          COMM                                                           */
 /*          INLINE_STMT_RESET                                              */
 /*          SMRK_FLAG                                                      */
 /*          SRN_FLAG                                                       */
 /*          STATEMENT_SEVERITY                                             */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HALMAT_POP                                                     */
 /*          HALMAT_PIP                                                     */
 /*          HALMAT_RELOCATE                                                */
 /*          STAB_HDR                                                       */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /*          RECOVER                                                        */
 /***************************************************************************/
'''

def EMIT_SMRK(T=3):
    # No local variables.
    if INLINE_LEVEL==0:
        HALMAT_POP(XSMRK,1,XCO_N,STATEMENT_SEVERITY);
        HALMAT_PIP(g.STMT_NUM(), 0, SMRK_FLAG, T>1);
        if HALMAT_RELOCATE_FLAG: 
            HALMAT_RELOCATE();
        ATOMp_FAULT=NEXT_ATOMp;
    elif T<5:
        HALMAT_POP(XIMRK,1,XCO_N,STATEMENT_SEVERITY);
        HALMAT_PIP(g.STMT_NUM(), 0, SMRK_FLAG, T>1);
    STATEMENT_SEVERITY=0;
    if SIMULATING: 
        if T==3: 
            STAB_HDR();
    if SRN_PRESENT: 
        if T: 
            SRN_FLAG=TRUE;
    if INLINE_STMT_RESET>0:
        g.STMT_NUM(INLINE_STMT_RESET);
        INLINE_STMT_RESET=0;
    if T: 
        g.STMT_NUM(g.STMT_NUM()+1);
    T=3;
    SMRK_FLAG = 0;
