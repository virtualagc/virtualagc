#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   POPMACRO.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-08-25 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
from SETXREF import SET_XREF

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  POP_MACRO_XREF                                         */
 /* MEMBER NAME:     POPMACRO                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          MAC_XREF                                                       */
 /*          XREF_REF                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          MAC_CTR                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          SET_XREF                                                       */
 /* CALLED BY:                                                              */
 /*          COMPILATION_LOOP                                               */
 /***************************************************************************/
'''


def POP_MACRO_XREF():
    # Local I doesn't require persistence.
    
    for I in range(0, g.MAC_CTR + 1):
        SET_XREF(g.MAC_XREF[I], g.XREF_REF);
    g.MAC_CTR = -1;
    return;
