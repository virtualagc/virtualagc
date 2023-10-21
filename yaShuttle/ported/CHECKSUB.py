#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   CHECKSUB.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-28 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ERROR import ERROR
from HALMATPI import HALMAT_PIP
from HALMATPO import HALMAT_POP
from MAKEFIXE import MAKE_FIXED_LIT

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  CHECK_SUBSCRIPT                                        */
 /* MEMBER NAME:     CHECKSUB                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          MODE              BIT(16)                                      */
 /*          SIZE              BIT(16)                                      */
 /*          FLAG              BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          NEWSIZE           FIXED                                        */
 /*          SHARP_ELIM        LABEL                                        */
 /*          SHARP_GONE        LABEL                                        */
 /*          SHARP_LOC         BIT(16)                                      */
 /*          SHARP_PM          LABEL                                        */
 /*          SHARP_UNKNOWN     LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          INT_TYPE                                                       */
 /*          CLASS_SR                                                       */
 /*          LAST_POP#                                                      */
 /*          MAT_TYPE                                                       */
 /*          MP                                                             */
 /*          NEXT_SUB                                                       */
 /*          SCALAR_TYPE                                                    */
 /*          VAL_P                                                          */
 /*          VAR                                                            */
 /*          XASZ                                                           */
 /*          XCSZ                                                           */
 /*          XIMD                                                           */
 /*          XLIT                                                           */
 /*          XMADD                                                          */
 /*          XMSUB                                                          */
 /*          XSTOI                                                          */
 /*          XVAC                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          LOC_P                                                          */
 /*          PSEUDO_FORM                                                    */
 /*          PSEUDO_TYPE                                                    */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          HALMAT_PIP                                                     */
 /*          HALMAT_POP                                                     */
 /*          MAKE_FIXED_LIT                                                 */
 /* CALLED BY:                                                              */
 /*          REDUCE_SUBSCRIPT                                               */
 /***************************************************************************/
'''


def CHECK_SUBSCRIPT(MODE, SIZE, FLAG):
    # Locals: NEWSIZE, SHARP_LOC
    
    goto = None
    
    if g.PSEUDO_FORM[g.NEXT_SUB] == g.XIMD: 
        NEWSIZE = g.LOC_P[g.NEXT_SUB];
    elif g.PSEUDO_FORM[g.NEXT_SUB] == g.XLIT:
        NEWSIZE = MAKE_FIXED_LIT(g.LOC_P[g.NEXT_SUB]);
        # IF A CHARACTER SUBSCRIPT (FLAG=1) IS LITERALLY A -1, CHANGE
        # IT TO A -2 TO DISTINGUISH IT FROM A CHECK_SUBSCRIPT RETURN
        # VALUE OF -1 WHICH INDICATES AN UNKNOWN SUBSCRIPT
        # (E.G. A VARIABLE).
        if NEWSIZE == -1 and FLAG: 
            NEWSIZE = -2;
        g.PSEUDO_FORM[g.NEXT_SUB] = g.XIMD;
        g.PSEUDO_TYPE[g.NEXT_SUB] = g.INT_TYPE;
        g.LOC_P[g.NEXT_SUB] = NEWSIZE;
    else: 
        NEWSIZE = -1;
    if g.VAL_P[g.NEXT_SUB] > 0: 
        if MODE == 0x0 and g.PSEUDO_TYPE[g.PTR[g.MP]] == g.CHAR_TYPE:
            MODE = g.XCSZ;
            SHARP_LOC = 0;
        elif SIZE < 0: 
            MODE = g.XASZ;
            SHARP_LOC = 0;
        else:
            MODE = g.XIMD;
            if SIZE == 0:
                ERROR(d.CLASS_SR, 5, g.VAR[g.MP]);
                return -1;
            SHARP_LOC = SIZE
            NEWSIZE = SIZE;
    # DO CASE VAL_P[NEXT_SUB];
    vn = g.VAL_P[g.NEXT_SUB]
    firstTry = True
    while firstTry or goto != None:
        firstTry = False
        if (vn == 0 or goto != None) and not goto == "SHARP_PM":
            #  NO SHARP
            if goto in [None, "SHARP_GONE"]:
                if goto == "SHARP_GONE ": goto = None
                if g.PSEUDO_FORM[g.NEXT_SUB] == g.XIMD:
                    g.PSEUDO_TYPE[g.NEXT_SUB] = 0;
                    if FLAG: 
                        return NEWSIZE;
                    if NEWSIZE < 1: 
                        ERROR(d.CLASS_SR, 4, g.VAR[g.MP]);
                        return 1;
                    elif SIZE > 0 and NEWSIZE > SIZE:
                        ERROR(d.CLASS_SR, 3, g.VAR[g.MP]);
                        return SIZE;
                    else: 
                        return NEWSIZE;
                MODE = 0;
            if goto == "SHARP_UNKNOWN ": goto = None
            if (goto == None and g.PSEUDO_TYPE[g.NEXT_SUB] == g.SCALAR_TYPE) \
                    or goto == "SHARP_ELIM":
                if goto == None:
                    HALMAT_POP(g.XSTOI, 1, 0, 0);
                if goto == "SHARP_ELIM ": goto = None
                HALMAT_PIP(g.LOC_P[g.NEXT_SUB], g.PSEUDO_FORM[g.NEXT_SUB], 0, 0);
                g.LOC_P[g.NEXT_SUB] = g.LAST_POPp;
                g.PSEUDO_FORM[g.NEXT_SUB] = g.XVAC;
            if (MODE & 0xF) == g.XIMD:
                if NEWSIZE == 0x10: 
                    NEWSIZE = g.XMADD[g.INT_TYPE - g.MAT_TYPE];
                else: 
                    NEWSIZE = g.XMSUB[g.INT_TYPE - g.MAT_TYPE];
                HALMAT_POP(NEWSIZE, 2, 0, 0);
                HALMAT_PIP(SIZE, g.XIMD, 0, 0);
                MODE = 0;
                goto = "SHARP_ELIM "
                continue
            g.PSEUDO_TYPE[g.NEXT_SUB] = MODE;
            return -1;
        elif vn == 1 and goto == None:
            #  SHARP BY ITSELF
            g.PSEUDO_FORM[g.NEXT_SUB] = MODE;
            g.LOC_P[g.NEXT_SUB] = SHARP_LOC;
            g.PSEUDO_TYPE[g.NEXT_SUB] = g.INT_TYPE;
            goto = "SHARP_GONE "
            continue
        elif (goto == None and vn == 2) or goto == "SHARP_PM":
            #  SHARP PLUS EXPRESSION
            if not goto == "SHARP_PM":
                if g.PSEUDO_FORM[g.NEXT_SUB] == g.XIMD:
                    if MODE == g.XIMD: 
                        NEWSIZE = g.LOC_P[g.NEXT_SUB] + NEWSIZE;
                        g.LOC_P[g.NEXT_SUB] = NEWSIZE
                        goto = "SHARP_GONE "
                        continue
                NEWSIZE = 0x10;
            if goto == "SHARP_PM ": goto = None
            MODE = MODE | NEWSIZE;
            goto = "SHARP_UNKNOWN "
            continue
        elif vn == 3:
            #  SHARP MINUS EXPRESSION
            if g.PSEUDO_FORM[g.NEXT_SUB] == g.XIMD:
                if MODE == g.XIMD:
                    NEWSIZE = NEWSIZE - g.LOC_P[g.NEXT_SUB];
                    g.LOC_P[g.NEXT_SUB] = NEWSIZE
                    goto = "SHARP_GONE "
                    continue
            NEWSIZE = 0x20;
            goto = "SHARP_PM "
            continue
    # END of DO CASE
