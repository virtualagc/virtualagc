#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   SETLABEL.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-22 RSB  Began porting from XPL
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ERROR import ERROR

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  SET_LABEL_TYPE                                         */
 /* MEMBER NAME:     SETLABEL                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               FIXED                                        */
 /*          NEWTYPE           FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          LABEL_TYPE_CONFLICT  LABEL                                     */
 /*          LINKUP            LABEL                                        */
 /*          OLDTYPE           FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CLASS_DT                                                       */
 /*          CLASS_PL                                                       */
 /*          COMPOOL_LABEL                                                  */
 /*          DO_LEVEL                                                       */
 /*          DO_STMT#                                                       */
 /*          IND_CALL_LAB                                                   */
 /*          NEST                                                           */
 /*          PROC_LABEL                                                     */
 /*          SYM_LINK1                                                      */
 /*          SYM_LINK2                                                      */
 /*          SYM_NAME                                                       */
 /*          SYM_NEST                                                       */
 /*          SYM_PTR                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_LINK1                                                      */
 /*          SYT_LINK2                                                      */
 /*          SYT_NAME                                                       */
 /*          SYT_NEST                                                       */
 /*          SYT_PTR                                                        */
 /*          SYT_TYPE                                                       */
 /*          UNSPEC_LABEL                                                   */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          SYM_TAB                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def SET_LABEL_TYPE(LOC, NEWTYPE):
    # Locals are OLDTYPE, I, J; neither locals nor parameters need persistence.
    
    OLDTYPE = g.SYT_TYPE(LOC);
    goto_LABEL_TYPE_CONFLICT = False
    firstTry = True
    while firstTry or goto_LABEL_TYPE_CONFLICT:
        firstTry = False
        if NEWTYPE < g.UNSPEC_LABEL or goto_LABEL_TYPE_CONFLICT:
            #  STATEMENT LABEL
            if OLDTYPE > g.UNSPEC_LABEL or goto_LABEL_TYPE_CONFLICT:
                goto_LABEL_TYPE_CONFLICT = False
                ERROR(d.CLASS_DT, 3, g.SYT_NAME(LOC));
            if g.EXTERNAL_MODE != 0: 
                g.SYT_TYPE(LOC, 0);
            else:
                g.SYT_TYPE(LOC, NEWTYPE);
        else:
            #  CALLABLE LABEL
            if OLDTYPE < g.UNSPEC_LABEL: 
                goto_LABEL_TYPE_CONFLICT = True
                continue
            if (OLDTYPE >= g.PROC_LABEL) and (OLDTYPE <= g.COMPOOL_LABEL):
                if OLDTYPE != NEWTYPE:
                    ERROR(d.CLASS_DT, 3, g.SYT_NAME(LOC));
            if OLDTYPE == g.IND_CALL_LAB:
                J = LOC;
                I = g.SYT_PTR(LOC);
                while g.SYT_NEST(I) >= g.NEST:
                    J = I;
                    if g.SYT_TYPE(I) == g.IND_CALL_LAB:
                        I = g.SYT_PTR(I);
                    elif g.SYT_TYPE(I) == g.PROC_LABEL:
                        g.SYT_TYPE(I, g.IND_CALL_LAB);
                        break  # GO TO LINKUP;
                # LINKUP:
                g.SYT_PTR(J, LOC);  # LINK I-CALLS TO REAL DEFINITION
                if g.SYT_LINK1(J) > 0: 
                    if g.DO_LEVEL > 0:
                        if g.DO_STMTp[g.DO_LEVEL] > g.SYT_LINK1(J):
                            ERROR(d.CLASS_PL, 10);
                if g.SYT_LINK1(LOC) >= 0: 
                    g.SYT_LINK1(LOC, -g.DO_LEVEL);
                    g.SYT_LINK2(LOC, g.SYT_LINK2(0));
                    g.SYT_LINK2(0, LOC);
            g.SYT_TYPE(LOC, NEWTYPE);
