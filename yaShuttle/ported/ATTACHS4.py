#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   ATTACHS4.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  Note that this port does not necessarily
            include all program comments that were present in the original code.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-28 RSB  Ported
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ERROR import ERROR
from ATTACHS2 import ATTACH_SUB_ARRAY
from ATTACHS3 import ATTACH_SUB_STRUCTURE
from ATTACHSU import ATTACH_SUB_COMPONENT
from CHECKARR import CHECK_ARRAYNESS
from GETARRAY import GET_ARRAYNESS
from MATCHARR import MATCH_ARRAYNESS
from RESETARR import RESET_ARRAYNESS

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  ATTACH_SUBSCRIPT                                       */
 /* MEMBER NAME:     ATTACHS4                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          SS_FUNNIES        LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CLASS_AA                                                       */
 /*          CLASS_FT                                                       */
 /*          CLASS_SQ                                                       */
 /*          CLASS_SV                                                       */
 /*          FIXL                                                           */
 /*          FIXV                                                           */
 /*          INT_TYPE                                                       */
 /*          MAT_TYPE                                                       */
 /*          MP                                                             */
 /*          NAME_BIT                                                       */
 /*          PSEUDO_TYPE                                                    */
 /*          PTR                                                            */
 /*          SAVE_ARRAYNESS_FLAG                                            */
 /*          SCALAR_TYPE                                                    */
 /*          SP                                                             */
 /*          SUBSCRIPT_LEVEL                                                */
 /*          SYM_ARRAY                                                      */
 /*          SYM_CLASS                                                      */
 /*          SYM_PTR                                                        */
 /*          SYM_TAB                                                        */
 /*          SYT_ARRAY                                                      */
 /*          SYT_CLASS                                                      */
 /*          SYT_PTR                                                        */
 /*          TEMPLATE_CLASS                                                 */
 /*          VAR_CLASS                                                      */
 /*          VAR                                                            */
 /*          XLIT                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ARRAYNESS_FLAG                                                 */
 /*          IND_LINK                                                       */
 /*          INX                                                            */
 /*          LOC_P                                                          */
 /*          NEXT_SUB                                                       */
 /*          PSEUDO_FORM                                                    */
 /*          PSEUDO_LENGTH                                                  */
 /*          TEMP                                                           */
 /*          VAL_P                                                          */
 /*          VAR_ARRAYNESS                                                  */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ATTACH_SUB_ARRAY                                               */
 /*          ATTACH_SUB_COMPONENT                                           */
 /*          ATTACH_SUB_STRUCTURE                                           */
 /*          CHECK_ARRAYNESS                                                */
 /*          ERROR                                                          */
 /*          GET_ARRAYNESS                                                  */
 /*          MATCH_ARRAYNESS                                                */
 /*          RESET_ARRAYNESS                                                */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def ATTACH_SUBSCRIPT():
    # Locals: I, J
    goto = None
    
    g.INX[0] = g.PTR[g.SP];
    I = 2;
    g.IND_LINK = 0;
    if not (GET_ARRAYNESS() & 1): 
        if g.FIXL[g.SP] == 3:
            ERROR(d.CLASS_FT, 8, g.VAR[g.MP]);
            g.INX[g.INX[0]] = 0;
    if g.INX[g.INX[0]] > 0:
        if g.PSEUDO_FORM[g.INX[0]] != 0:
           ERROR(d.CLASS_SQ, 2, g.VAR[g.MP]);
           g.PSEUDO_FORM[g.INX[0]] = 0;
        g.NEXT_SUB = g.INX[0];
        g.PSEUDO_LENGTH[0] = 0;
        I = ATTACH_SUB_STRUCTURE(g.PSEUDO_LENGTH[g.INX[0]]);
        J = ATTACH_SUB_ARRAY(g.VAL_P[g.INX[0]]);
        if g.SYT_CLASS(g.FIXL[g.MP]) != g.VAR_CLASS:
            if g.SYT_CLASS(g.FIXL[g.MP]) != g.TEMPLATE_CLASS: 
                goto = "SS_FUNNIES"
        if g.PSEUDO_TYPE[g.PTR[g.MP]] < g.SCALAR_TYPE and goto == None: 
            if I & 1: I = ATTACH_SUB_STRUCTURE(0);
            if (I != 2) and (J & 1) and (g.INX[g.INX[0]] == 0): 
                g.ESCAPE();
            if J & 1: ATTACH_SUB_ARRAY(0);
            ATTACH_SUB_COMPONENT(g.INX[g.INX[0]]);
        elif (J & 1) != 0 and (g.SYT_ARRAY(g.FIXL[g.MP]) > 0) and goto == None:
            if I & 1: I = ATTACH_SUB_STRUCTURE(0);
            if (I != 2) and (g.INX[g.INX[0]] == 0): 
                g.ESCAPE();
            ATTACH_SUB_ARRAY(g.INX[g.INX[0]]);
        else:
            if goto == "SS_FUNNIES": goto = None
            if (I & 1) != 0 and (g.SYT_ARRAY(g.FIXV[g.MP]) != 0):
                I = ATTACH_SUB_STRUCTURE(g.INX[g.INX[0]]);
            elif g.INX[g.INX[0]] > 0: ERROR(d.CLASS_SV, 3, g.VAR[g.MP]);
        if g.VAR_ARRAYNESS[0] > 0:  # RESIDUAL ARRAYNESS COMPACTIFICATION
            J = 1;
            for g.VAR_ARRAYNESS[0] in range(1, g.VAR_ARRAYNESS[0] + 1):
                if g.VAR_ARRAYNESS[g.VAR_ARRAYNESS[0]] != 1:
                    g.VAR_ARRAYNESS[J] = g.VAR_ARRAYNESS[g.VAR_ARRAYNESS[0]];
                    J = J + 1;
            g.VAR_ARRAYNESS[0] = J - 1;
    elif g.PSEUDO_FORM[g.INX[0]] > 0:
        g.TEMP = g.PSEUDO_TYPE[g.PTR[g.MP]];
        if g.TEMP < g.MAT_TYPE or g.TEMP > g.INT_TYPE:
            ERROR(d.CLASS_SQ, 1, g.VAR[g.MP]);
            g.PSEUDO_FORM[g.INX[0]] = 0;
    if g.SYT_PTR(g.FIXL[g.MP]) < 0: 
        if g.NAME_BIT == 0:
            g.LOC_P[g.PTR[g.MP]] = -g.SYT_PTR(g.FIXL[g.MP]);
            g.PSEUDO_FORM[g.PTR[g.MP]] = g.XLIT;
    if g.NAME_BIT != 0: 
        if CHECK_ARRAYNESS() & 1:
            g.VAL_P[g.PTR[g.MP]] = g.VAL_P[g.PTR[g.MP]] | 0x10;
    if g.SUBSCRIPT_LEVEL == 0: 
        g.ARRAYNESS_FLAG = g.SAVE_ARRAYNESS_FLAG;
    MATCH_ARRAYNESS();
    if g.ARRAYNESS_FLAG: 
        if RESET_ARRAYNESS() > 0: 
            ERROR(d.CLASS_AA, 2, g.VAR[g.MP]);
    return I != 2;
