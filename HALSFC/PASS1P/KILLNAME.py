#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   KILLNAME.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
from CHECKARR import CHECK_ARRAYNESS
from RESETARR import RESET_ARRAYNESS

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  KILL_NAME                                              */
 /* MEMBER NAME:     KILLNAME                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          PTR                                                            */
 /*          VAL_P                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          NAME_PSEUDOS                                                   */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CHECK_ARRAYNESS                                                */
 /*          RESET_ARRAYNESS                                                */
 /* CALLED BY:                                                              */
 /*          SETUP_CALL_ARG                                                 */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def KILL_NAME(LOC):
    if g.NAME_PSEUDOS:
       if (g.VAL_P[g.PTR[LOC]] & 0x400) == 0:
           RESET_ARRAYNESS();
       CHECK_ARRAYNESS();
       g.NAME_PSEUDOS = g.FALSE;
       return 1;
    return 0;
