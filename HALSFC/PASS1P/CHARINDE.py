#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   CHARINDE.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-08-30 RSB  Ported
'''

from xplBuiltins import *

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  CHAR_INDEX                                             */
 /* MEMBER NAME:     CHARINDE                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          STRING1           CHARACTER;                                   */
 /*          STRING2           CHARACTER;                                   */
 /* LOCAL DECLARATIONS:                                                     */
 /*          L1                FIXED                                        */
 /*          I                 FIXED                                        */
 /*          L2                FIXED                                        */
 /* CALLED BY:                                                              */
 /*          OUTPUT_WRITER                                                  */
 /*          STREAM                                                         */
 /***************************************************************************/
'''


def CHAR_INDEX(STRING1, STRING2):
    # None of the locals need persistence.
    L1 = LENGTH(STRING1);
    L2 = LENGTH(STRING2);
    if L2 > L1:
        return -1;
    for I in range(0, L1 - L2 + 1):
        if SUBSTR(STRING1, I, L2) == STRING2:
            return I;
    return -1;
