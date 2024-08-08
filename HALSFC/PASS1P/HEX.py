#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   HEX.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-07 RSB  Ported from XPL
'''

from xplBuiltins import *
import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  HEX                                                    */
 /* MEMBER NAME:     HEX                                                    */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          CHARACTER                                                      */
 /* INPUT PARAMETERS:                                                       */
 /*          NUM               FIXED                                        */
 /*          WIDTH             FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CHAR_TEMP         CHARACTER;                                   */
 /*          H_LOOP            LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          X256                                                           */
 /* CALLED BY:                                                              */
 /*          HALMAT_BLAB                                                    */
 /*          CALL_SCAN                                                      */
 /*          LIT_DUMP                                                       */
 /*          SCAN                                                           */
 /*          STREAM                                                         */
 /*          SYT_DUMP                                                       */
 /***************************************************************************/
'''


def HEX(NUM, WIDTH=0):
    # The only local, CHAR_TEMP, requires no persistence.  Note that NUM is
    # a 32-bit datatype (in XPL), and we have to truncate negative values to
    # 32 bits in Python, or else the loop is unending.
    CHAR_TEMP = ''
    
    NUM &= 0xFFFFFFFF
    
    while True:
        CHAR_TEMP = SUBSTR('0123456789ABCDEF', NUM & 0xF, 1) + CHAR_TEMP;
        NUM = SHR(NUM, 4);
        if NUM != 0:
            continue
        NUM = LENGTH(CHAR_TEMP);
        if NUM < WIDTH:
            CHAR_TEMP = SUBSTR(g.X256, 0, WIDTH - NUM) + CHAR_TEMP;
        WIDTH = 0;
        return CHAR_TEMP;
