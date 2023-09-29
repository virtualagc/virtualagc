#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   DISCONNE.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-29 RSB  Ported
'''

import g
from HASH import HASH

def DISCONNECT(LOC):
    # Locals: I, J

    ''' REMOVES ENTRY AT LOC FROM SYMBOL TABLE HASH STRUCTURE
        ASSUMES CLOSE_BCD CONTAINS THE VARIABLE NAME  '''
    if g.BLOCK_MODE[g.NEST] == g.CMPL_MODE: 
        g.SYT_NEST(LOC, 0);
    else: 
        I = HASH(g.CLOSE_BCD, g.SYT_HASHSIZE);
        if g.SYT_HASHSTART[I] == LOC:
            g.SYT_HASHSTART[I] = g.SYT_HASHLINK(LOC);
        else:
            I = g.SYT_HASHSTART[I];
            while I != LOC:
                J = I;
                I = g.SYT_HASHLINK(I);
            g.SYT_HASHLINK(J, g.SYT_HASHLINK(LOC));
        g.SYT_FLAGS(LOC, g.SYT_FLAGS(LOC) | g.INACTIVE_FLAG);
