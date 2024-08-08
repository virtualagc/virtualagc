#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   SETOUTER.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
from HALINCL.SPACELIB import *
from COMPRESS import COMPRESS_OUTER_REF

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  SET_OUTER_REF                                          */
 /* MEMBER NAME:     SETOUTER                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               FIXED                                        */
 /*          FLAG              FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          OUT_REF                                                        */
 /*          OUT_REF_FLAGS                                                  */
 /*          OUTER_REF_LIM                                                  */
 /*          OUTER_REF                                                      */
 /*          OUTER_REF_FLAGS                                                */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          OUTER_REF_INDEX                                                */
 /*          OUTER_REF_TABLE                                                */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          COMPRESS_OUTER_REF                                             */
 /* CALLED BY:                                                              */
 /*          SET_XREF                                                       */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def SET_OUTER_REF(LOC, FLAG):
    # There are no local variables.
    if g.OUTER_REF_INDEX == g.OUTER_REF_LIM:
        COMPRESS_OUTER_REF();
    while g.OUTER_REF_INDEX >= RECORD_TOP(g.OUTER_REF_TABLE):
        NEXT_ELEMENT(g.OUTER_REF_TABLE);
    g.OUTER_REF_INDEX = g.OUTER_REF_INDEX + 1;
    g.OUTER_REF(g.OUTER_REF_INDEX, LOC);
    g.OUTER_REF_FLAGS(g.OUTER_REF_INDEX, SHR(FLAG, 13));
    g.OUTER_REF_MAX = MAX(g.OUTER_REF_MAX, g.OUTER_REF_INDEX);
