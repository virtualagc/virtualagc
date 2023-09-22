#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   BUFFERMA.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-22 RSB  Ported from XPL
'''

import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  BUFFER_MACRO_XREF                                      */
 /* MEMBER NAME:     BUFFERMA                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          I                 FIXED                                        */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          MAC_XREF                                                       */
 /*          MAC_CTR                                                        */
 /* CALLED BY:                                                              */
 /*          IDENTIFY                                                       */
 /***************************************************************************/
'''


def BUFFER_MACRO_XREF(I):
    # ROUTINE TO BUFFER MACRO XREF INFO UNTIL APPROPRIATE TIME 
    g.MAC_CTR = g.MAC_CTR + 1;
    g.MAC_XREF[g.MAC_CTR] = I;
    return;
