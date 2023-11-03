#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   GETARRAY.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-28 RSB  Ported.
'''

from xplBuiltins import *
import g
import HALINCL.COMMON as h

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  GET_ARRAYNESS                                          */
 /* MEMBER NAME:     GETARRAY                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          EXT_ARRAY                                                      */
 /*          FIXL                                                           */
 /*          FIXV                                                           */
 /*          MP                                                             */
 /*          NAME_FLAG                                                      */
 /*          PTR                                                            */
 /*          SYM_ARRAY                                                      */
 /*          SYM_FLAGS                                                      */
 /*          SYM_TAB                                                        */
 /*          SYT_ARRAY                                                      */
 /*          SYT_FLAGS                                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          VAL_P                                                          */
 /*          VAR_ARRAYNESS                                                  */
 /* CALLED BY:                                                              */
 /*          ATTACH_SUBSCRIPT                                               */
 /***************************************************************************/
'''


def GET_ARRAYNESS():
    # Locals: I, J, K
    
    if g.SYT_ARRAY(g.FIXV[g.MP]) != 0: 
        g.VAR_ARRAYNESS[0] = 1;
        g.VAR_ARRAYNESS[1] = g.SYT_ARRAY(g.FIXV[g.MP]);
        K = 2;
    else: 
        K = 0
        g.VAR_ARRAYNESS[0] = 0;
    I = g.SYT_ARRAY(g.FIXL[g.MP]);
    if I > 0:
        for J in range(1, h.EXT_ARRAY[I] + 1):
            g.VAR_ARRAYNESS[g.VAR_ARRAYNESS[0] + J] = h.EXT_ARRAY[I + J];
        g.VAR_ARRAYNESS[0] = g.VAR_ARRAYNESS[0] + h.EXT_ARRAY[I];
        K = K | 1;
    I = g.FIXL[g.MP];
    if (g.SYT_FLAGS(I) & g.NAME_FLAG) != 0: K = K | 0x200;
    g.VAL_P[g.PTR[g.MP]] = g.VAL_P[g.PTR[g.MP]] | K;
    return SHR(K, 9) & 0xFFFF;
