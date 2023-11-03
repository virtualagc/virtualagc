#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   ENTERDIM.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-25 RSB  Ported
'''

from xplBuiltins import *
import g
import HALINCL.COMMON as h

LAST_EXT_PTR = 1  # Really a local variable of ENTER_DIMS().


def ENTER_DIMS():
    global LAST_EXT_PTR
    # Locals I, J, K, LAST_EXT_PTR. 
    
    goto_NO_MATCH = False
    ea = (h.EXT_ARRAY[LAST_EXT_PTR] == g.N_DIM)
    if ea:
        J = LAST_EXT_PTR + 1;
        for I in range(0, g.N_DIM):
            if h.EXT_ARRAY[J + I] != g.S_ARRAY[I]:
                goto_NO_MATCH = True
                break
        if not goto_NO_MATCH:
            g.SYT_ARRAY(g.ID_LOC, LAST_EXT_PTR);  # MATCH
            return;
    if goto_NO_MATCH or not ea:  # Was just ELSE. NOT THE SAME AS THE LAST ENTRY
        goto_NO_MATCH = False
        I = 1;
        while I < LAST_EXT_PTR:
            J = h.EXT_ARRAY[I];  # N_DIM OF THIS ENTRY
            K = I + 1;
            goto_INCR_PTR = False
            jn = (J == g.N_DIM)
            if jn: 
                for g.TEMP in range(0, g.N_DIM):
                    if h.EXT_ARRAY[K + g.TEMP] != g.S_ARRAY[g.TEMP]:
                        goto_INCR_PTR = True
                        break
                if not goto_INCR_PTR:
                    g.SYT_ARRAY(g.ID_LOC, I);  # FOUND A MATCH
                    return;
            if goto_INCR_PTR or not jn:  # (Was just ELSE.)
                goto_INCR_PTR = False
                I = K + J;
        # END OF DO WHILE
    # IF WE GET HERE WE MUST TAKE UP NEW EXT_ARRAY SPACE
    h.EXT_ARRAY[g.EXT_ARRAY_PTR] = g.N_DIM;
    LAST_EXT_PTR = g.EXT_ARRAY_PTR;
    g.SYT_ARRAY(g.ID_LOC, g.EXT_ARRAY_PTR);
    g.EXT_ARRAY_PTR = g.EXT_ARRAY_PTR + 1;
    for I in range(0, g.N_DIM):
        h.EXT_ARRAY[g.EXT_ARRAY_PTR + I] = g.S_ARRAY[I];
    g.EXT_ARRAY_PTR = g.EXT_ARRAY_PTR + g.N_DIM;
