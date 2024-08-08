#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   BLOCKSUM.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-29 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
from COMPRESS import COMPRESS_OUTER_REF

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  BLOCK_SUMMARY                                          */
 /* MEMBER NAME:     BLOCKSUM                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CHECK_IDENT(1538) LABEL                                        */
 /*          CLASS(17)         BIT(8)                                       */
 /*          CONDITION(17)     BIT(8)                                       */
 /*          FIRST_HEADING     CHARACTER;                                   */
 /*          FIRST_TIME        BIT(8)                                       */
 /*          HEADER_ISSUED     BIT(8)                                       */
 /*          HEADING(2)        CHARACTER;                                   */
 /*          I                 BIT(16)                                      */
 /*          INDIRECT(1569)    LABEL                                        */
 /*          ISSUE_HEADER(1563)  LABEL                                      */
 /*          J                 BIT(16)                                      */
 /*          MASK(17)          BIT(8)                                       */
 /*          MASK2(17)         BIT(8)                                       */
 /*          MAX_SUM           MACRO                                        */
 /*          OUT_BLOCK_SUMMARY(1543)  LABEL                                 */
 /*          OUTPUT_IDENT(1560)  LABEL                                      */
 /*          PTR               BIT(16)                                      */
 /*          TYPE(17)          BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BLOCK_SYTREF                                                   */
 /*          DOUBLE                                                         */
 /*          EXTERNAL_FLAG                                                  */
 /*          FALSE                                                          */
 /*          IND_CALL_LAB                                                   */
 /*          LABEL_CLASS                                                    */
 /*          NEST                                                           */
 /*          OUT_REF                                                        */
 /*          OUT_REF_FLAGS                                                  */
 /*          OUTER_REF_INDEX                                                */
 /*          OUTER_REF_PTR                                                  */
 /*          OUTER_REF                                                      */
 /*          OUTER_REF_FLAGS                                                */
 /*          SYM_CLASS                                                      */
 /*          SYM_FLAGS                                                      */
 /*          SYM_NAME                                                       */
 /*          SYM_NEST                                                       */
 /*          SYM_PTR                                                        */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_CLASS                                                      */
 /*          SYT_FLAGS                                                      */
 /*          SYT_NAME                                                       */
 /*          SYT_NEST                                                       */
 /*          SYT_PTR                                                        */
 /*          SYT_TYPE                                                       */
 /*          TRUE                                                           */
 /*          X4                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          C                                                              */
 /*          LINE_MAX                                                       */
 /*          OUTER_REF_TABLE                                                */
 /*          PAGE_THROWN                                                    */
 /*          S                                                              */
 /*          TEMP1                                                          */
 /*          TEMP2                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          COMPRESS_OUTER_REF                                             */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''

MAX_SUM = 17
CLASS = (2, 2, 2, 1, 1, 2, 2, 2, 3, 2, 3, 0, 3, 6, 7, 3, 6, 7)
TYPE = (0x48, 0x48, 0x48, 9, 9, 0x48, 0x48, 0x47, 0,
        0x47, 0, 0, 1, 0, 0x3E, 1, 0, 0x3E)
CONDITION = (1, 1, 1, 0, 0, 1, 1, 0, 2, 0, 2, 0, 1, 2, 0, 1, 2, 0)
MASK = (3, 7, 5, 4, 2, 1, 6, 3, 3, 3, 3, 0, 0, 2, 2, 0, 2, 2)
MASK2 = (0,0,0,0,0,0,0,1,1,0,0,0,1,1,1,0,0,0) # BIT(8)
HEADING = (
    'PROGRAMS AND TASKS SCHEDULED    PROGRAMS AND TASKS TERMINATED   ' + \
    'PROGRAMS AND TASKS CANCELLED    EVENTS SIGNALLED, SET OR RESET  ' + \
    'EVENTS REFERENCED               PROCESS EVENTS REFERENCED       ' + \
    'PROCESS PRIORITIES UPDATED      EXTERNAL PROCEDURES CALLED      ',
    'EXTERNAL FUNCTIONS INVOKED      OUTER PROCEDURES CALLED         ' + \
    'OUTER FUNCTIONS INVOKED         ERRORS SENT                     ' + \
    'COMPOOL VARIABLES USED          COMPOOL REPLACE MACROS USED     ' + \
    'COMPOOL STRUCTURE TEMPLATES USEDOUTER VARIABLES USED            ',
    'OUTER REPLACE MACROS USED       OUTER STRUCTURE TEMPLATES USED  '
    )
FIRST_HEADING = '-**** B L O C K   S U M M A R Y ****'


def BLOCK_SUMMARY():
    # Locals: I, J, PTR, HEADER_ISSUED, FIRST_TIME, 
    #         MAX_SUM, CLASS, TYPE, CONDITION, MASK, MASK2, HEADING[],
    #         FIRST_HEADING.
    I = 0
    J = 0
    PTR = 0
    HEADER_ISSUED = g.FALSE
    FIRST_TIME = g.FALSE

    def INDIRECT():
        # No Locals
        nonlocal PTR
        if g.SYT_CLASS(PTR) != g.LABEL_CLASS: 
            return;
        while g.SYT_TYPE(PTR) == g.IND_CALL_LAB:
            PTR = g.SYT_PTR(PTR);
    # END INDIRECT;
    
    def ISSUE_HEADER():
        # No locals
        nonlocal HEADER_ISSUED, FIRST_TIME
        if HEADER_ISSUED: 
            return;
        if FIRST_TIME:
            OUTPUT(1, FIRST_HEADING);
            FIRST_TIME = g.FALSE;
        g.TEMP1 = SHR(I, 3);
        g.TEMP2 = SHL(I - SHL(g.TEMP1, 3), 5);
        OUTPUT(1, g.DOUBLE + SUBSTR(HEADING[g.TEMP1], g.TEMP2, 32));
        HEADER_ISSUED = g.TRUE;
    # END ISSUE_HEADER;
    
    def OUTPUT_IDENT(FLAG):
        # No locals
        ISSUE_HEADER();
        if (FLAG & 1) != 0:
            if PTR == 0x3FFF: 
                g.S = '*:*';
            else: 
                g.S = str(SHR(PTR, 6)) + ':';
                if (PTR & 0x3F) == 0x3F: 
                    g.S = g.S + '*';
                else: 
                    g.S = g.S + str(PTR & 0x3F);
        elif FLAG == 4: 
            g.S = g.SYT_NAME(PTR) + '*';
        else: 
            g.S = g.SYT_NAME(PTR);
        if LENGTH(g.S) + LENGTH(g.C[0]) > 130:
            OUTPUT(0, g.C[0]);
            g.C[0] = '';
            g.C[1] = g.X4;
        g.C[0] = g.C[0] + g.C[1] + g.S;
        g.C[1] = ', ';
        FLAG = g.FALSE;
    # END OUTPUT_IDENT;
    
    def CHECK_IDENT():
        # No locals
        if g.SYT_NEST(PTR) >= g.NEST: 
            return;
        if 0 != (1 & MASK2[I]): 
            if g.SYT_NEST(PTR) > 0: 
                return;
        if MASK[I] != 0: 
            if g.TEMP1 != MASK[I]: 
                return; 
            else: 
                g.TEMP1 = 0;
        OUTPUT_IDENT(g.TEMP1 & 6);
        g.OUTER_REF(J, -1);
    # END CHECK_IDENT;
    
    def OUT_BLOCK_SUMMARY():
        nonlocal J, PTR
        for J in range(g.OUTER_REF_PTR[g.NEST] & 0x7FFF, g.OUTER_REF_INDEX + 1):
            if g.OUTER_REF(J) == -1: 
                pass  # GO TO NEXT_ENTRY;
            else:
                PTR = g.OUTER_REF(J);
                g.TEMP1 = g.OUTER_REF_FLAGS(J);
                if g.TEMP1 == 0:
                    if CLASS[I] == 0: 
                        OUTPUT_IDENT(g.TRUE);
                        g.OUTER_REF(J, -1);
                else: 
                    INDIRECT();
                    if g.SYT_CLASS(PTR) <= CLASS[I]:
                        # DO CASE CONDITION(I);
                        ci = CONDITION[I]
                        if ci == 0:
                            if g.SYT_TYPE(PTR) == TYPE[I]: 
                                CHECK_IDENT();
                        elif ci == 1:
                            if g.SYT_TYPE(PTR) >= TYPE[I]: 
                                CHECK_IDENT();
                        elif ci == 2:
                            if g.SYT_CLASS(PTR) == CLASS[I]: 
                                CHECK_IDENT();
                        # END DO CASE
            # NEXT_ENTRY:
    # END OUT_BLOCK_SUMMARY;
    
    COMPRESS_OUTER_REF();
    FIRST_TIME = g.TRUE;
    for I in range(0, MAX_SUM + 1):
        g.C[0] = '';
        g.C[1] = g.X4;
        HEADER_ISSUED = g.FALSE;
        OUT_BLOCK_SUMMARY();
        if LENGTH(g.C[0]) != 0: 
            OUTPUT(0, g.C[0]);
    # End of DO I
    if (g.SYT_FLAGS(g.BLOCK_SYTREF[g.NEST]) & g.EXTERNAL_FLAG) == 0: 
        g.LINE_MAX = 0;
        g.PAGE_THROWN = g.TRUE;
