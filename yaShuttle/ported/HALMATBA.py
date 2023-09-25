#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   HALMATBA.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-23 RSB  Ported from XPL
'''

import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  HALMAT_BACKUP                                          */
 /* MEMBER NAME:     HALMATBA                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          OLD_ATOM          FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          HALMAT_OK                                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          NEXT_ATOM#                                                     */
 /* CALLED BY:                                                              */
 /*          END_ANY_FCN                                                    */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def HALMAT_BACKUP(OLD_ATOM):
    if g.HALMAT_OK:
        g.NEXT_ATOMp = OLD_ATOM;
