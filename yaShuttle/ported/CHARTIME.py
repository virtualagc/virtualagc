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

import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  CHARTIME                                               */
 /* MEMBER NAME:     CHARTIME                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          CHARACTER                                                      */
 /* INPUT PARAMETERS:                                                       */
 /*          T                 FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          C                 CHARACTER;                                   */
 /*          COLON             CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          PERIOD                                                         */
 /* CALLED BY:                                                              */
 /*          PRINT_TIME                                                     */
 /*          INITIALIZATION                                                 */
 /***************************************************************************/
'''

def CHARTIME(T):
    # None of the locals need persistence.
    COLON = ':'
    C = str(T // 360000)
    C = C + COLON + str((T % 360000) // 6000) + \
        COLON + str((T % 6000) // 100) + g.PERIOD;
    T = T % 100; # DECIMAL FRACTION
    if T < 10:
        C = C + '0';
    return C + str(T)
