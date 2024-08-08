#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   SETXREFR.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
from SETXREF import SET_XREF

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  SET_XREF_RORS                                          */
 /* MEMBER NAME:     SETXREFR                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          I                 FIXED                                        */
 /*          J                 FIXED                                        */
 /*          K                 FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          L                 FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FIXF                                                           */
 /*          FIXL                                                           */
 /*          FIXV                                                           */
 /*          LOC_P                                                          */
 /*          PTR                                                            */
 /*          SUBSCRIPT_LEVEL                                                */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_TYPE                                                       */
 /*          TEMPL_NAME                                                     */
 /*          XREF_REF                                                       */
 /*          XREF_SUBSCR                                                    */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          PTR_TOP                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          SET_XREF                                                       */
 /* CALLED BY:                                                              */
 /*          CHECK_ASSIGN_CONTEXT                                           */
 /*          CHECK_NAMING                                                   */
 /*          SETUP_NO_ARG_FCN                                               */
 /*          START_NORMAL_FCN                                               */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def SET_XREF_RORS(I, J=0, K=0x4000):
    # L is local
    if g.SUBSCRIPT_LEVEL > 0:
         K = g.XREF_SUBSCR;
    if g.FIXV[I] > 0:
        SET_XREF(g.FIXV[I], K);
        for L in range(g.PTR[I] + 1, g.FIXF[I] + 1):
            SET_XREF(g.LOC_P[L], K);
        g.PTR_TOP = g.PTR[I];  # NOW GET RID OF EXTN STACK - ASSUMED AT TOP
    if g.SYT_TYPE(g.FIXL[I]) != g.TEMPL_NAME:
        SET_XREF(g.FIXL[I], K, J);
