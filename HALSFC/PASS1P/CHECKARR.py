#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   CHECKARR.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  CHECK_ARRAYNESS                                        */
 /* MEMBER NAME:     CHECKARR                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CURRENT_ARRAYNESS                                              */
 /*          ARRAYNESS_FLAG                                                 */
 /* CALLED BY:                                                              */
 /*          ATTACH_SUBSCRIPT                                               */
 /*          CHECK_EVENT_EXP                                                */
 /*          KILL_NAME                                                      */
 /*          PROCESS_CHECK                                                  */
 /*          RECOVER                                                        */
 /*          SETUP_CALL_ARG                                                 */
 /*          SYNTHESIZE                                                     */
 /*          UNARRAYED_INTEGER                                              */
 /*          UNARRAYED_SCALAR                                               */
 /*          UNARRAYED_SIMPLE                                               */
 /***************************************************************************/
'''

def CHECK_ARRAYNESS():
    # Local I doesn't need to be persistent.
    I=(g.CURRENT_ARRAYNESS[0]>0);
    g.CURRENT_ARRAYNESS[0] = 0
    g.ARRAYNESS_FLAG=0;
    return I;
