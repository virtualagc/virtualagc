#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   ASTSTACK.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-28 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ERROR import ERROR
from PUSHINDI import PUSH_INDIRECT

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  AST_STACKER                                            */
 /* MEMBER NAME:     ASTSTACK                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          MODE              BIT(16)                                      */
 /*          NUM               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          MP                                                             */
 /*          CLASS_SS                                                       */
 /*          VAR                                                            */
 /*          XAST                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          INX                                                            */
 /*          IND_LINK                                                       */
 /*          LOC_P                                                          */
 /*          PSEUDO_FORM                                                    */
 /*          PSEUDO_LENGTH                                                  */
 /*          PSEUDO_TYPE                                                    */
 /*          VAL_P                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          PUSH_INDIRECT                                                  */
 /* CALLED BY:                                                              */
 /*          ATTACH_SUB_ARRAY                                               */
 /*          ATTACH_SUB_COMPONENT                                           */
 /*          ATTACH_SUB_STRUCTURE                                           */
 /***************************************************************************/
'''


def AST_STACKER(MODE, NUM):
    # Local: I
    
    if g.INX[g.INX[0]] > 0:
        ERROR(d.CLASS_SS, 1, g.VAR[g.MP]);
    for NUM in range(1, NUM + 1):
        I = PUSH_INDIRECT(1);
        g.VAL_P[I] = 0;
        g.LOC_P[I] = 0
        g.PSEUDO_TYPE[I] = 0;
        g.PSEUDO_FORM[I] = g.XAST;
        g.INX[I] = MODE;
        if leftToRightAssignments:
            g.PSEUDO_LENGTH[g.IND_LINK] = I        
            g.IND_LINK = I;
        else:
            g.IND_LINK = I;
            g.PSEUDO_LENGTH[g.IND_LINK] = I
