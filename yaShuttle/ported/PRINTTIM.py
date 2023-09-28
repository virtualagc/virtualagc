#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   PRINTTIM.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-08-28 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
from CHARTIME import CHARTIME

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  PRINT_TIME                                             */
 /* MEMBER NAME:     PRINTTIM                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          MESSAGE           CHARACTER;                                   */
 /*          T                 FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          C                 CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          PERIOD                                                         */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CHARTIME                                                       */
 /* CALLED BY:                                                              */
 /*          PRINT_DATE_AND_TIME                                            */
 /*          PRINT_SUMMARY                                                  */
 /***************************************************************************/
'''


def PRINT_TIME(MESSAGE, T):
    # C is the only local, and requires no persistence
    C = CHARTIME(T);
    OUTPUT(0, MESSAGE + C + g.PERIOD);
