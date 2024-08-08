#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   PRINTSUM.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-08-25 RSB  Created place-holder file.
'''

from xplBuiltins import *
import g
from HALINCL.SPACELIB import *
from DUMPIT   import DUMPIT
from ERRORSUM import ERROR_SUMMARY
from LITDUMP  import LIT_DUMP
from OUTPUTGR import OUTPUT_GROUP
from OUTPUTWR import OUTPUT_WRITER
from PRINTDAT import PRINT_DATE_AND_TIME
from PRINTTIM import PRINT_TIME
from SYTDUMP  import SYT_DUMP

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  PRINT_SUMMARY                                          */
 /* MEMBER NAME:     PRINTSUM                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 FIXED                                        */
 /*          NO_DUMPS(1808)    LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BLOCK_SYTREF                                                   */
 /*          CARD_COUNT                                                     */
 /*          COMPILING                                                      */
 /*          CONTROL                                                        */
 /*          CROSS_REF                                                      */
 /*          CSECT_LENGTHS                                                  */
 /*          DOUBLE                                                         */
 /*          DOUBLE_SPACE                                                   */
 /*          DOWN_INFO                                                      */
 /*          EJECT_PAGE                                                     */
 /*          ERROR_COUNT                                                    */
 /*          INCLUDE_OPENED                                                 */
 /*          INIT_AFCBAREA                                                  */
 /*          INIT_APGAREA                                                   */
 /*          LINK_SORT                                                      */
 /*          LISTING2                                                       */
 /*          MACRO_TEXTS                                                    */
 /*          MAX_SEVERITY                                                   */
 /*          MEMORY_FAILURE                                                 */
 /*          OUTER_REF_TABLE                                                */
 /*          PAGE                                                           */
 /*          SDF_OPEN                                                       */
 /*          SDL_OPTION                                                     */
 /*          SYM_ADD                                                        */
 /*          SYM_LOCK#                                                      */
 /*          SYM_TAB                                                        */
 /*          SYT_LOCK#                                                      */
 /*          TPL_NAME                                                       */
 /*          VMEM_LOC_CNT                                                   */
 /*          VMEM_READ_CNT                                                  */
 /*          VMEM_WRITE_CNT                                                 */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CLOCK                                                          */
 /*          S                                                              */
 /*          STMT_PTR                                                       */
 /*          TPL_FLAG                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          DUMPIT                                                         */
 /*          ERROR_SUMMARY                                                  */
 /*          LIT_DUMP                                                       */
 /*          OUTPUT_GROUP                                                   */
 /*          OUTPUT_WRITER                                                  */
 /*          PRINT_DATE_AND_TIME                                            */
 /*          PRINT_TIME                                                     */
 /*          SYT_DUMP                                                       */
 /***************************************************************************/
'''


def PRINT_SUMMARY():
    # Locals: I

    OUTPUT_WRITER();
    g.STMT_PTR = -1;  # FORCE OUT ERRORS IN CASE OF TERMINATION IN MACRO
    OUTPUT_WRITER();
    OUTPUT_GROUP();
    if g.LISTING2:
        MONITOR(0, 2);  # CLOSE LISTING2
    if g.INCLUDE_OPENED:
        MONITOR(3, 4);  # CLOSE INCLUDE FILE
    if g.SDF_OPEN: 
        MONITOR(22, 1);
    if g.MEMORY_FAILURE: 
        # GO TO NO_DUMPS;
        pass
    else:
        g.EJECT_PAGE();
        SYT_DUMP();
        if RECORD_ALLOC(g.INIT_APGAREA) > 0:
            RECORD_FREE(g.INIT_AFCBAREA);
            RECORD_FREE(g.INIT_APGAREA);
        RECORD_FREE(g.MACRO_TEXTS);
        RECORD_FREE(g.LINK_SORT);
        RECORD_FREE(g.OUTER_REF_TABLE);
        NEXT_ELEMENT(h.SYM_TAB);
        RECORD_SEAL(h.SYM_TAB);
        RECORD_SEAL(h.DOWN_INFO);
        RECORD_SEAL(h.CROSS_REF);
        RECORD_SEAL(h.SYM_ADD);
        RECORD_SEAL(h.CSECT_LENGTHS);
        if g.CONTROL[14] & 1: 
            LIT_DUMP();
    # NO_DUMPS:
    g.EJECT_PAGE();
    DUMPIT();
    PRINT_DATE_AND_TIME('END OF HAL/S PHASE 1, ', DATE(), TIME());
    OUTPUT(0, '');
    OUTPUT(0, str(g.CARD_COUNT) + ' CARDS WERE PROCESSED.');
    if g.ERROR_COUNT == 0:
        OUTPUT(0, 'NO ERRORS WERE DETECTED DURING PHASE 1 .');
    else:
        if g.ERROR_COUNT == 1: 
            g.S = 'ONE ERROR WAS';
        else: 
            g.S = str(g.ERROR_COUNT) + ' ERRORS WERE';
        OUTPUT(0, g.S + ' DETECTED IN PHASE 1.');
        ERROR_SUMMARY();
    '''
    if VMEM_LOC_CNT != 0:
        g.DOUBLE_SPACE();
        OUTPUT(0, 'NUMBER OF FILE 6 LOCATES          = ' + VMEM_LOC_CNT);
        OUTPUT(0, 'NUMBER OF FILE 6 READS            = ' + VMEM_READ_CNT);
        OUTPUT(0, 'NUMBER OF FILE 6 WRITES           = ' + VMEM_WRITE_CNT);
    '''
    g.DOUBLE_SPACE();
    g.DOUBLE_SPACE();
    g.CLOCK[3] = MONITOR(18);
    for I in range(1, 3 + 1):  # WATCH OUT FOR MIDNIGHT
        if g.CLOCK[I] < g.CLOCK[I - 1]: 
            g.CLOCK[I] = g.CLOCK[I] + 8640000;
    PRINT_TIME('TOTAL CPU TIME FOR PHASE 1      ', g.CLOCK[3] - g.CLOCK[0]);
    PRINT_TIME('CPU TIME FOR PHASE 1 SET UP     ', g.CLOCK[1] - g.CLOCK[0]);
    PRINT_TIME('CPU TIME FOR PHASE 1 PROCESSING ', g.CLOCK[2] - g.CLOCK[1]);
    PRINT_TIME('CPU TIME FOR PHASE 1 CLEAN UP   ', g.CLOCK[3] - g.CLOCK[2]);
    if g.CLOCK[2] > g.CLOCK[1]:  # WATCH OUT FOR CLOCK BEING OFF
        OUTPUT(0, 'PROCESSING RATE: ' + str(6000 * g.CARD_COUNT // (g.CLOCK[2] - g.CLOCK[1])) \
                    +' CARDS PER MINUTE.');
    g.DOUBLE_SPACE();
    if g.TPL_FLAG < 3: 
        if (g.COMPILING & 0x80) == 0 or g.MAX_SEVERITY > 0:
            g.TPL_FLAG = 3;
            OUTPUT(0, '*******  COMPILATION ERRORS INHIBITED TEMPLATE GENERATION');
    if g.TPL_FLAG == 3: 
        MONITOR(0, 6);  # CLOSE THE TEMPLATE FILE
        return;  # NO MORE TEMPLATE PROCESSING
    MONITOR(16, 0x80);
    if not (g.TPL_FLAG & 1): 
        MONITOR(1, 6, g.TPL_NAME);
        MONITOR(16, 0x40);
    else: 
        MONITOR(0, 6);  # CLOSE THE FILE ANYWAY
    # DO CASE TPL_FLAG;
    if g.TPL_FLAG == 0:
        g.S = ' NOT FOUND - ADDED ';
    elif g.TPL_FLAG == 1:
        g.S = ' FOUND - CHANGE NOT REQUIRED ';
    elif g.TPL_FLAG == 2:
        g.S = ' FOUND AND CHANGED ';
    # END;
    if not g.SDL_OPTION:
        g.S = g.S + ', VERSION=' + str(g.SYT_LOCKp(g.BLOCK_SYTREF[1]));
    OUTPUT(0, '******* TEMPLATE LIBRARY MEMBER ' + g.TPL_NAME + g.S);
