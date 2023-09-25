#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   COMPARE.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-24 RSB  Ported from XPL
'''

import g
import HALINCL.CERRDECL as d
from ERROR import ERROR

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  COMPARE                                                */
 /* MEMBER NAME:     COMPARE                                                */
 /* INPUT PARAMETERS:                                                       */
 /*          DIM               FIXED                                        */
 /*          F_DIM             FIXED                                        */
 /*          ERROR#            FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ID_LOC                                                         */
 /*          CLASS_DS                                                       */
 /*          SYM_NAME                                                       */
 /*          SYM_TAB                                                        */
 /*          SYT_NAME                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          CHECK_CONFLICTS                                                */
 /***************************************************************************/
'''


def COMPARE(DIM, F_DIM, ERRORp):
    # No local variables.
    if F_DIM == 0: 
        return DIM;
    if DIM == 0: 
        return F_DIM;
    if DIM == F_DIM: 
        return DIM;
    ERROR(d.CLASS_DS, ERRORp, g.SYT_NAME(g.ID_LOC));
    return DIM;