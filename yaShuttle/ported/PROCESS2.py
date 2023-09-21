#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   PROCESS2.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ERROR import ERROR
from CHECKARR import CHECK_ARRAYNESS

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  PROCESS_CHECK                                          */
 /* MEMBER NAME:     PROCESS2                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FIXL                                                           */
 /*          CLASS_RT                                                       */
 /*          PROG_LABEL                                                     */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_TYPE                                                       */
 /*          TASK_LABEL                                                     */
 /*          VAR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          CHECK_ARRAYNESS                                                */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def PROCESS_CHECK(LOC):
    if CHECK_ARRAYNESS():
        ERROR(d.CLASS_RT, 11, g.VAR[LOC]);
    if g.SYT_TYPE(g.FIXL[LOC]) != g.PROG_LABEL and \
            g.SYT_TYPE(g.FIXL[LOC]) != g.TASK_LABEL:
        ERROR(d.CLASS_RT, 9, g.VAR[LOC]);
