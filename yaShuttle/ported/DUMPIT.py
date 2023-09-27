#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   DUMPIT.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  Note that this port does not necessarily
            include all program comments that were present in the original code.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-27 RSB  Ported.
'''

from xplBuiltins import *
import g
from HALINCL.SPACELIB import *
from GETLITER import GET_LITERAL
from IFORMAT  import I_FORMAT

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  DUMPIT                                                 */
 /* MEMBER NAME:     DUMPIT                                                 */
 /* LOCAL DECLARATIONS:                                                     */
 /*          FORM_UP           CHARACTER                                    */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AS_PTR                                                         */
 /*          COMM                                                           */
 /*          DOUBLE                                                         */
 /*          DOUBLE_SPACE                                                   */
 /*          EXT_ARRAY_PTR                                                  */
 /*          FIRST_FREE                                                     */
 /*          IDENT_COUNT                                                    */
 /*          LIT_CHAR_SIZE                                                  */
 /*          LIT_CHAR_USED                                                  */
 /*          MACRO_TEXT_LIM                                                 */
 /*          MAX_PTR_TOP                                                    */
 /*          MAXNEST                                                        */
 /*          MAXSP                                                          */
 /*          NDECSY                                                         */
 /*          OUTER_REF_LIM                                                  */
 /*          OUTER_REF_MAX                                                  */
 /*          PTR_TOP                                                        */
 /*          REDUCTIONS                                                     */
 /*          SCAN_COUNT                                                     */
 /*          STMT_NUM                                                       */
 /*          SYTSIZE                                                        */
 /*          XREF_INDEX                                                     */
 /*          XREF_LIM                                                       */
 /*          X1                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          S                                                              */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          I_FORMAT                                                       */
 /* CALLED BY:                                                              */
 /*          PRINT_SUMMARY                                                  */
 /***************************************************************************/
'''


def DUMPIT():
    # DUMP OUT THE STATISTICS COLLECTED DURING THIS RUN
    # PUT OUT THE ENTRY COUNT FOR IMPORTANT PROCEDURES
    
    def FORM_UP(MSG, VAL1, VAL2):
        if VAL2 > VAL1:
            g.S = ' <-<-<- ';
        else:
            g.S = '';
        g.S = I_FORMAT(VAL2, 8) + g.S;
        g.S = I_FORMAT(VAL1, 10) + g.S;
        return MSG + g.S;
    
    OUTPUT(0, '       OPTIONAL TABLE SIZES');
    OUTPUT(1, '0NAME       REQUESTED    USED');
    OUTPUT(1, '+____       _________    ____');
    OUTPUT(0, g.X1);
    OUTPUT(0, FORM_UP('LITSTRINGS', g.LIT_CHAR_SIZE, g.LIT_CHAR_USED()));
    OUTPUT(0, FORM_UP('SYMBOLS   ', g.SYTSIZE, g.NDECSY()));
    OUTPUT(0, FORM_UP('MACROSIZE ', g.MACRO_TEXT_LIM, g.FIRST_FREE()));
    OUTPUT(0, FORM_UP('XREFSIZE  ', g.XREF_LIM, g.XREF_INDEX()));
    OUTPUT(0, FORM_UP('BLOCKSUM  ', g.OUTER_REF_LIM, g.OUTER_REF_MAX));
    OUTPUT(1, g.DOUBLE);
    
    OUTPUT(0, 'CALLS TO SCAN        = ' + str(g.SCAN_COUNT));
    OUTPUT(0, 'CALLS TO IDENTIFY    = ' + str(g.IDENT_COUNT));
    OUTPUT(0, 'NUMBER OF REDUCTIONS = ' + str(g.REDUCTIONS));
    OUTPUT(0, 'MAX STACK SIZE       = ' + str(g.MAXSP));
    OUTPUT(0, 'MAX IND. STACK SIZE  = ' + str(g.MAX_PTR_TOP));
    OUTPUT(0, 'END IND. STACK SIZE  = ' + str(g.PTR_TOP));
    OUTPUT(0, 'END ARRAY STACK SIZE = ' + str(g.AS_PTR));
    OUTPUT(0, 'MAX EXT_ARRAY INDEX  = ' + str(g.EXT_ARRAY_PTR));
    OUTPUT(0, 'STATEMENT COUNT      = ' + str(g.STMT_NUM() - 1));
    OUTPUT(0, 'MINOR COMPACTIFIES   = ' + str(COMPACTIFIES[0]));
    OUTPUT(0, 'MAJOR COMPACTIFIES   = ' + str(COMPACTIFIES[1]));
    OUTPUT(0, 'REALLOCATIONS        = ' + str(REALLOCATIONS));
    OUTPUT(0, 'MAX NESTING DEPTH    = ' + str(g.MAXNEST));
    # FREEBASE seems to be something from PASS 3.
    # OUTPUT(0, 'FREE STRING AREA     = ' + str(g.FREELIMIT - g.FREEBASE));
    g.DOUBLE_SPACE();
