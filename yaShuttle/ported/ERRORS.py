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

from g import monitorLabel, ERROR_COUNT, STMT_NUM, COMPILING, MAX_SEVERITY, \
            SAVE_SEVERITY
from HALINCL.CERRORS import COMMON_ERRORS

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

def ERRORS(CLASS, NUM, TEXT):  # HANDLES ONCE QUIET MESSAGES
    global ERROR_COUNT, MAX_SEVERITY, COMPILING, SAVE_SEVERITY
    
    ERROR_COUNT = ERROR_COUNT + 1;
    # BI106 IS THE ERROR FOR TOO MANY ERRORS AND THEREFORE
    # ERROR_COUNT NEEDS TO BE DECREMENTED THEN INCREMENTED
    if NUM == 106:
       ERROR_COUNT = ERROR_COUNT - 1;
    SEVERITY = COMMON_ERRORS(CLASS, NUM, TEXT, ERROR_COUNT, STMT_NUM);
    if NUM == 106:
       ERROR_COUNT = ERROR_COUNT + 1;
    SAVE_SEVERITY[ERROR_COUNT] = SEVERITY;
    if SEVERITY > MAX_SEVERITY:
       MAX_SEVERITY = SEVERITY;
    if MAX_SEVERITY > 2:
       COMPILING = FALSE;
       monitorLabel = "ALMOST_DISASTER"
