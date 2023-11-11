#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   GETICQ.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  GET_ICQ                                                */
 /* MEMBER NAME:     GETICQ                                                 */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          FIXED                                                          */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          IC_SIZE                                                        */
 /*          IC_FILE                                                        */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          IC_LIM                                                         */
 /*          CUR_IC_BLK                                                     */
 /*          IC_MAX                                                         */
 /*          IC_ORG                                                         */
 /*          IC_VAL                                                         */
 /* CALLED BY:                                                              */
 /*          HALMAT_INIT_CONST                                              */
 /*          ICQ_OUTPUT                                                     */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def GET_ICQ(PTR):
    if PTR >= g.IC_ORG:
        if PTR < g.IC_LIM:
            return PTR - g.IC_ORG;
    FILE(g.IC_FILE, g.CUR_IC_BLK, g.IC_VAL[0]);
    g.CUR_IC_BLK = PTR / g.IC_SIZE;
    g.IC_ORG = g.CUR_IC_BLK * g.IC_SIZE;
    g.IC_LIM = g.IC_ORG + g.IC_SIZE;
    if g.CUR_IC_BLK <= g.IC_MAX:
        g.IC_VAL[0] = FILE(g.IC_FILE, g.CUR_IC_BLK);
    else:
        g.IC_MAX = g.IC_MAX + 1;
    return PTR - g.IC_ORG;
