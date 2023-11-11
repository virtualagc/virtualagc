#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   ATTACHS3.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-28 RSB  Ported.
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d 
from ERROR import ERROR
from ASTSTACK import AST_STACKER
from REDUCESU import REDUCE_SUBSCRIPT
from SLIPSUBS import SLIP_SUBSCRIPT

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


def ATTACH_SUB_STRUCTURE(SUBp):
    # Local: RCODE
    
    if SUBp < 0: 
        return g.TRUE;
    RCODE = g.FALSE;
    g.INX[g.INX[0]] = g.INX[g.INX[0]] - SUBp;
    goto_STRUC_SLIP = False
    firstTry = True
    while firstTry or goto_STRUC_SLIP:
        firstTry = False
        if goto_STRUC_SLIP or g.SYT_ARRAY(g.FIXV[g.MP]) == 0:
            if not goto_STRUC_SLIP:
                RCODE = 2;
            goto_STRUC_SLIP = False
            if SUBp > 0: 
                ERROR(d.CLASS_SC, 1, g.VAR[g.MP]);
                SLIP_SUBSCRIPT(SUBp);
        elif SUBp == 0: 
            AST_STACKER(0x8, 1);
        else: 
            REDUCE_SUBSCRIPT(0x8, g.VAR_ARRAYNESS[1]);
            g.VAR_ARRAYNESS[1] = g.FIX_DIM;
            if g.FIX_DIM == 1: 
                g.VAL_P[g.PTR[g.MP]] = g.VAL_P[g.PTR[g.MP]] & 0xFFFD;
            SUBp = SUBp - 1;
            goto_STRUC_SLIP = True
            continue
    return RCODE;
