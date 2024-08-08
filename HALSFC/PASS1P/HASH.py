#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   HASH.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-10 RSB  Ported from XPL
'''

from xplBuiltins import *
import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  HASH                                                   */
 /* MEMBER NAME:     HASH                                                   */
 /* INPUT PARAMETERS:                                                       */
 /*          BCD               CHARACTER;                                   */
 /*          HASHSIZE          FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          HASH              FIXED                                        */
 /*          I                 FIXED                                        */
 /*          J                 FIXED                                        */
 /* CALLED BY:                                                              */
 /*          IDENTIFY                                                       */
 /*          INTERPRET_ACCESS_FILE                                          */
 /*          STREAM                                                         */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def HASH(BCD, HASHSIZE):
    # HASH, I, and J are local but needn't be persistent.
    
    HASH = 0;
    J = LENGTH(BCD) - 1;
    if J > 22:  #  AVOID OVERFLOW  
        J = 22;
    for I in range(0, J + 1):
        HASH = BYTE(BCD, I) + SHL(HASH, 1);
    return HASH % HASHSIZE;
