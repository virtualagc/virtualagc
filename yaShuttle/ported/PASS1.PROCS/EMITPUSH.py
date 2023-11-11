#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   EMITPUSH.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  Note that this port does not necessarily
            include all program comments that were present in the original code.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-28 RSB  Ported
'''

import g
import HALINCL.CERRDECL as d
from HALMATPI import HALMAT_PIP
from HALMATPO import HALMAT_POP
from ERROR import ERROR

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  EMIT_PUSH_DO                                           */
 /* MEMBER NAME:     EMITPUSH                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /*          Q                 BIT(16)                                      */
 /*          L                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          DO_LEVEL_LIM                                                   */
 /*          CLASS_BS                                                       */
 /*          FL_NO                                                          */
 /*          STMT_NUM                                                       */
 /*          XINL                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          COMM                                                           */
 /*          DO_CHAIN                                                       */
 /*          DO_INX                                                         */
 /*          DO_LEVEL                                                       */
 /*          DO_LOC                                                         */
 /*          DO_PARSE                                                       */
 /*          DO_STMT#                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          HALMAT_PIP                                                     */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def EMIT_PUSH_DO(I, J, K, Q, L=0):
    if g.DO_LEVEL == g.DO_LEVEL_LIM:
        ERROR(d.CLASS_BS, 1);
        g.DO_LOC[0] = g.DO_LOC[0] + 1;
    else:
        g.DO_LEVEL = g.DO_LEVEL + 1;
        g.DO_LOC[g.DO_LEVEL] = g.FL_NO();
        g.DO_INX[g.DO_LEVEL] = I;
        g.DO_CHAIN[g.DO_LEVEL] = L;
        g.DO_PARSE[g.DO_LEVEL] = Q;
        g.DO_STMTp[g.DO_LEVEL] = g.STMT_NUM();
    HALMAT_PIP(g.FL_NO(), g.XINL, 0, K);
    g.FL_NO(g.FL_NO() + J);
    L = 0;
