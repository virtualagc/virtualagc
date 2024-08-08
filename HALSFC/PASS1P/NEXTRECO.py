#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   NEXTRECO.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-07 RSB  Ported from XPL
'''

from xplBuiltins import *
import g

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  NEXT_RECORD                                            */
 /* MEMBER NAME:     NEXTRECO                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          CHARACTER                                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          INCLUDE_COMPRESSED                                             */
 /*          INCLUDING                                                      */
 /*          INPUT_DEV                                                      */
 /*          SYSIN_COMPRESSED                                               */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CURRENT_CARD                                                   */
 /*          INITIAL_INCLUDE_RECORD                                         */
 /*          LOOKED_RECORD_AHEAD                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          DECOMPRESS                                                     */
 /* CALLED BY:                                                              */
 /*          STREAM                                                         */
 /*          INITIALIZATION                                                 */
 /***************************************************************************/
'''


def NEXT_RECORD():
    # There are no locals.
    if g.LOOKED_RECORD_AHEAD:
        g.LOOKED_RECORD_AHEAD = g.FALSE;
        return;
    if g.INCLUDING:
        if g.INCLUDE_COMPRESSED:
            g.CURRENT_CARD = g.DECOMPRESS(1)[:];
            pass
        else:
            if g.INITIAL_INCLUDE_RECORD:
                g.INITIAL_INCLUDE_RECORD = g.FALSE;
            else:
                g.CURRENT_CARD = INPUT(g.INPUT_DEV)[:];
                pass
    else:  # NOT INCLUDE
        if g.SYSIN_COMPRESSED:
            g.CURRENT_CARD = g.DECOMPRESS(0)[:];
            pass
        else:
            g.CURRENT_CARD = INPUT(g.INPUT_DEV)[:];
            pass
