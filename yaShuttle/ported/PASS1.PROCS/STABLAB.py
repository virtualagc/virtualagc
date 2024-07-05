#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   STABLAB.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2024-07-04 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ERROR import ERROR

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  STAB_LAB                                               */
 /* MEMBER NAME:     STABLAB                                                */
 /* INPUT PARAMETERS:                                                       */
 /*          VAL               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          STAB_STACKLIM                                                  */
 /*          CLASS_BT                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          STAB2_STACK                                                    */
 /*          STAB2_STACKTOP                                                 */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> STAB_LAB <==                                                        */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /***************************************************************************/
'''


def STAB_LAB(VAL):
    if g.STAB2_STACKTOP == g.STAB_STACKLIM:
        ERROR(d.CLASS_BT, 2)
    else:
        g.STAB2_STACKTOP = g.STAB2_STACKTOP + 1
        g.STAB2_STACK[g.STAB2_STACKTOP] = VAL & 0x7FFF
        