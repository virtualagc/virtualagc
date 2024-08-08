#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   SLIPSUBS.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-28 RSB  Ported.
'''

import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  SLIP_SUBSCRIPT                                         */
 /* MEMBER NAME:     SLIPSUBS                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          NUM               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          INX                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          NEXT_SUB                                                       */
 /* CALLED BY:                                                              */
 /*          ATTACH_SUB_ARRAY                                               */
 /*          ATTACH_SUB_COMPONENT                                           */
 /*          ATTACH_SUB_STRUCTURE                                           */
 /***************************************************************************/
'''


def SLIP_SUBSCRIPT(NUM):
    while NUM > 0:
        NUM = NUM - 1;
        # Note that in both XPL and Python, "true" is 1 and "false" is 0.
        g.NEXT_SUB = g.NEXT_SUB + 1 + int(g.INX[g.NEXT_SUB] > 1);
