#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   CHECKIMP.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  Note that this port does not necessarily
            include all program comments that were present in the original code.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-27 RSB  Ported
'''

from xplBuiltins import OUTPUT
import g
import HALINCL.CERRDECL as d
from ERROR import ERROR

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  CHECK_IMPLICIT_T                                       */
 /* MEMBER NAME:     CHECKIMP                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          CLASS_DU                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          IMPLICIT_T                                                     */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def CHECK_IMPLICIT_T():
    if g.IMPLICIT_T:
       g.IMPLICIT_T = g.FALSE;
       ERROR(d.CLASS_DU, 1, 'T');
