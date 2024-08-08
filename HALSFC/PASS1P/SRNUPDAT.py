#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   SRNUPDAT.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-08-31 RSB  Created a stub.
            2023-09-18 RSB  Ported.
'''

import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  SRN_UPDATE                                             */
 /* MEMBER NAME:     SRNUPDAT                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          INCL_SRN                                                       */
 /*          SRN                                                            */
 /*          SRN_COUNT                                                      */
 /*          SRN_FLAG                                                       */
 /* CALLED BY:                                                              */
 /*          INITIALIZATION                                                 */
 /*          COMPILATION_LOOP                                               */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def SRN_UPDATE():
    g.SRN_FLAG = g.FALSE;
    g.SRN[2] = g.SRN[1][:];
    g.INCL_SRN[2] = g.INCL_SRN[1][:];
    g.SRN_COUNT[2] = g.SRN_COUNT[1];
