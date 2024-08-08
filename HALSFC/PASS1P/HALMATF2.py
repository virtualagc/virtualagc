#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   HALMATF2.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  Note that this port does not necessarily
            include all program comments that were present in the original code.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-28 RSB  Began porting
'''

from xplBuiltins import *
import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  HALMAT_FIX_POPTAG                                      */
 /* MEMBER NAME:     HALMATF2                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          POP_LOC           FIXED                                        */
 /*          TAG               BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ATOMS                                                          */
 /*          CONST_ATOMS                                                    */
 /*          HALMAT_OK                                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FOR_ATOMS                                                      */
 /* CALLED BY:                                                              */
 /*          ASSOCIATE                                                      */
 /*          CHECK_EVENT_EXP                                                */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def HALMAT_FIX_POPTAG(POP_LOC, TAG):
    if g.HALMAT_OK:
        g.ATOMS(POP_LOC, (g.ATOMS(POP_LOC) & 0xFFFFFF) | SHL(TAG & 0xFF, 24));
