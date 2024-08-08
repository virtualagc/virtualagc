#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   CHARDATE.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-08-28 RSB  Ported from XPL
'''

import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  CHARDATE                                               */
 /* MEMBER NAME:     CHARDATE                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          CHARACTER                                                      */
 /* INPUT PARAMETERS:                                                       */
 /*          D                 FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          DAY               FIXED                                        */
 /*          DAYS(12)          BIT(16)                                      */
 /*          M                 FIXED                                        */
 /*          MONTH(11)         CHARACTER;                                   */
 /*          YEAR              FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          X1                                                             */
 /* CALLED BY:                                                              */
 /*          PRINT_DATE_AND_TIME                                            */
 /*          INITIALIZATION                                                 */
 /***************************************************************************/
'''

MONTH = ['JANUARY', 'FEBRUARY', 'MARCH',
         'APRIL', 'MAY', 'JUNE', 'JULY', 'AUGUST', 'SEPTEMBER',
         'OCTOBER', 'NOVEMBER', 'DECEMBER']
DAYS = [0, 31, 60, 91, 121, 152, 182, 213, 244, 274,
        305, 335, 366]
def CHARDATE(D):
    # None of the locals need to be persistent.
    YEAR = (D // 1000) + 1900;
    DAY = D % 1000;
    if (YEAR & 0x3) != 0:
        if DAY > 59:
            DAY = DAY + 1;  # NOT LEAP YEAR
    M = 1;
    while DAY > DAYS[M]:
       M = M + 1;
    return str(MONTH[M - 1]) + g.X1 + str(DAY - DAYS[M - 1]) + ', ' + str(YEAR);
