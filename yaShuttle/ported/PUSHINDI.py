#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   PUSHINDI.py
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
 /* PROCEDURE NAME:  PUSH_INDIRECT                                          */
 /* MEMBER NAME:     PUSHINDI                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          I                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          PTR_MAX                                                        */
 /*          CLASS_BS                                                       */
 /*          STACKSIZE                                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          EXT_P                                                          */
 /*          MAX_PTR_TOP                                                    */
 /*          PTR_TOP                                                        */
 /*          VAL_P                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          AST_STACKER                                                    */
 /*          START_NORMAL_FCN                                               */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def PUSH_INDIRECT(I):
    g.PTR_TOP = g.PTR_TOP + I;
    if g.PTR_TOP > g.PTR_MAX: ERROR(dCLASS_BS, 2);
    elif g.PTR_TOP > g.MAX_PTR_TOP:g.MAX_PTR_TOP = g.PTR_TOP;
    g.VAL_P[g.PTR_TOP] = 0
    g.EXT_P[g.PTR_TOP] = 0;
    return g.PTR_TOP;
