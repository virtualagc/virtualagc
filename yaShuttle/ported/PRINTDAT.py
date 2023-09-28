#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   CHARTIME.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-08-28 RSB  Ported from XPL
'''

from CHARDATE import CHARDATE
from PRINTTIM import PRINT_TIME

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  PRINT_DATE_AND_TIME                                    */
 /* MEMBER NAME:     PRINTDAT                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          MESSAGE           CHARACTER;                                   */
 /*          D                 FIXED                                        */
 /*          T                 FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          C                 CHARACTER;                                   */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CHARDATE                                                       */
 /*          PRINT_TIME                                                     */
 /* CALLED BY:                                                              */
 /*          INITIALIZATION                                                 */
 /*          PRINT_SUMMARY                                                  */
 /***************************************************************************/
'''


def PRINT_DATE_AND_TIME(MESSAGE, D, T):
    # C is the only local, and requires no persistence.
    C = CHARDATE(D);
    PRINT_TIME(MESSAGE + C + '.  CLOCK TIME = ', T);
