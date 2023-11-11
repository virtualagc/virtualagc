#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   ERRORS.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-08-29 RSB  Ported
'''

import g
import HALINCL.CERRORS as c
from ALMOST_DISASTER import ALMOST_DISASTER

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  ERRORS                                                 */
 /* MEMBER NAME:     ERRORS                                                 */
 /* INPUT PARAMETERS:                                                       */
 /*          CLASS             BIT(16)                                      */
 /*          NUM               BIT(16)                                      */
 /*          TEXT              CHARACTER;                                   */
 /* LOCAL DECLARATIONS:                                                     */
 /*          SEVERITY          BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          COMM                                                           */
 /*          ALMOST_DISASTER                                                */
 /*          FALSE                                                          */
 /*          STMT_NUM                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          COMPILING                                                      */
 /*          ERROR_COUNT                                                    */
 /*          MAX_SEVERITY                                                   */
 /*          SAVE_SEVERITY                                                  */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          COMMON_ERRORS                                                  */
 /* CALLED BY:                                                              */
 /*          OUTPUT_WRITER                                                  */
 /*          INITIALIZATION                                                 */
 /*          STREAM                                                         */
 /*          SYT_DUMP                                                       */
 /***************************************************************************/
'''

def ERRORS(CLASS, NUM, TEXT = ''):  # HANDLES ONCE QUIET MESSAGES
    # The only local, SEVERITY, doesn't require persistence.
    
    g.ERROR_COUNT = g.ERROR_COUNT + 1;
    # BI106 IS THE ERROR FOR TOO MANY ERRORS AND THEREFORE
    # ERROR_COUNT NEEDS TO BE DECREMENTED THEN INCREMENTED
    if NUM == 106:
       g.ERROR_COUNT = g.ERROR_COUNT - 1;
    SEVERITY = c.COMMON_ERRORS(CLASS, NUM, TEXT, g.ERROR_COUNT, g.STMT_NUM());
    if NUM == 106:
       g.ERROR_COUNT = g.ERROR_COUNT + 1;
    g.SAVE_SEVERITY[g.ERROR_COUNT] = SEVERITY;
    if SEVERITY > g.MAX_SEVERITY:
       g.MAX_SEVERITY = SEVERITY;
    if g.MAX_SEVERITY > 2:
       g.COMPILING = g.FALSE;
       ALMOST_DISASTER()
