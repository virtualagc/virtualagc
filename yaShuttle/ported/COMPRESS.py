#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   COMPRESS.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  COMPRESS_OUTER_REF                                     */
 /* MEMBER NAME:     COMPRESS                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          TMP               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          NEST                                                           */
 /*          OUT_REF                                                        */
 /*          OUT_REF_FLAGS                                                  */
 /*          OUTER_REF_PTR                                                  */
 /*          OUTER_REF                                                      */
 /*          OUTER_REF_FLAGS                                                */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          OUTER_REF_INDEX                                                */
 /*          OUTER_REF_MAX                                                  */
 /*          OUTER_REF_TABLE                                                */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          MAX                                                            */
 /* CALLED BY:                                                              */
 /*          BLOCK_SUMMARY                                                  */
 /*          SET_OUTER_REF                                                  */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''

def COMPRESS_OUTER_REF():
    # Locals I, J, and TMP don't need to be persistent.
    
    J = g.OUTER_REF_PTR[g.NEST] & 0x7FFF;
    if J >= g.OUTER_REF_INDEX:
        return;
    for I in range(J, g.OUTER_REF_INDEX):
        if g.OUTER_REF(I) != -1:
            TMP = g.OUTER_REF(I);
            for J in range(I + 1, g.OUTER_REF_INDEX):
                if TMP == g.OUTER_REF(J):
                    if g.OUTER_REF_FLAGS(I) == g.OUTER_REF_FLAGS(J):
                        g.OUTER_REF(J, -1);
    TMP = (g.OUTER_REF_PTR[g.NEST] & 0x7FFF) - 1;
    for I in range(TMP + 1, g.OUTER_REF_INDEX):
        if g.OUTER_REF(I) != -1:
            TMP = TMP + 1;
            g.OUTER_REF(TMP, g.OUTER_REF(I));
            g.OUTER_REF_FLAGS(TMP, g.OUTER_REF_FLAGS(I));
    g.OUTER_REF_INDEX = TMP;
