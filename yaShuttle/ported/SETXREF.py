#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   SETXREF.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
from HALINCL.ENTERXRE import ENTER_XREF
from SETOUTER import SET_OUTER_REF
from HALINCL.ENTERXRE import ENTER_XREF

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  SET_XREF                                               */
 /* MEMBER NAME:     SETXREF                                                */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               FIXED                                        */
 /*          FLAG              FIXED                                        */
 /*          FLAG2             FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          ENTER_OUTER_REF(17)  LABEL                                     */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CALLED_LABEL                                                   */
 /*          IND_CALL_LAB                                                   */
 /*          NEST                                                           */
 /*          SYM_NEST                                                       */
 /*          SYM_TYPE                                                       */
 /*          SYM_XREF                                                       */
 /*          SYT_NEST                                                       */
 /*          SYT_TYPE                                                       */
 /*          SYT_XREF                                                       */
 /*          XREF_REF                                                       */
 /*          XREF_SUBSCR                                                    */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          SYM_TAB                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ENTER_XREF                                                     */
 /*          SET_OUTER_REF                                                  */
 /* CALLED BY:                                                              */
 /*          IDENTIFY                                                       */
 /*          POP_MACRO_XREF                                                 */
 /*          SET_XREF_RORS                                                  */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def SET_XREF(LOC, FLAG, FLAG2=0):
    # There are no local variables.
    
    if LOC > 0:  # FILTERS FIXV OF NON-STRUCTS
        if FLAG2 == 0:
            if FLAG == g.XREF_SUBSCR: 
                FLAG2 = g.XREF_REF;
            else:
                FLAG2 = FLAG;
        if (g.SYT_TYPE(LOC) == g.IND_CALL_LAB) or \
                ((g.SYT_TYPE(LOC) == g.PROC_LABEL or g.SYT_TYPE(LOC) == g.STMT_LABEL or \
                  g.SYT_TYPE(LOC) == g.TASK_LABEL) and g.SYT_FLAGS(LOC) != g.DEFINED_LABEL):
            g.NO_NEW_XREF = g.TRUE;
        g.SYT_XREF(LOC, ENTER_XREF(g.SYT_XREF(LOC), FLAG));
        if g.NO_NEW_XREF: 
            g.NO_NEW_XREF = g.FALSE;
        goto_ENTER_OUTER_REF = False
        if g.SYT_TYPE(LOC) == g.IND_CALL_LAB or g.SYT_TYPE(LOC) == g.CALLED_LABEL:
             goto_ENTER_OUTER_REF = True;
        if goto_ENTER_OUTER_REF or g.SYT_NEST(LOC) < g.NEST:
            goto_ENTER_OUTER_REF = False
            if FLAG2 != 0:
                SET_OUTER_REF(LOC, FLAG2);
    FLAG2 = 0;
