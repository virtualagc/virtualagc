#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   DTOKEN.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-06 RSB  Ported
'''

from xplBuiltins import *
import g
from NEXTRECO import NEXT_RECORD
from HALINCL.PRINTCOM import PRINT_COMMENT

'''
   /* ROUTINE TO PICK OUT TOKENS FROM A DIRECTIVE CARD.            */
   /* IF D_CONTINUATION_OK IS TRUE, THEN IF NO TOKEN EXISTS ON THE */
   /*   CURRENT RECORD, D_TOKEN WILL GET THE NEXT RECORD AND       */
   /*   IF THAT RECORD IS ALSO A DIRECTIVE, RETURN THE FIRST       */
   /*   TOKEN FROM IT.                                             */
   /* D_TOKEN RETURNS THE TOKEN FOUND                              */
'''

'''
Big pain in the neck!  Internally, D_TOKEN() accesses and/or updates the
variables D_INDEX and D_CONTINUATION_OK, which are neither parameters, nor
local variables, nor global variables.  In fact, they are *local* variables
of STREAM(), which calls D_TOKEN().  So somehow we must provide access to 
them.

To complicate matter further, D_TOKEN() is also called by INCLUDE_OK() 
(module PATCHINC), for which they are *not* local variables.  However, 
INCLUDE_OK() is called (only) by STREAM(), so presumably that's how D_TOKEN()
gets access to them.

There are several possible workarounds in Python.  The simplest would seem to
be to make D_INDEX and D_CONTINUATION_OK global variables in this DTOKEN
module, and to give STREAM() access to them via that method rather than as 
locals to STREAM().
'''

D_INDEX = 1
D_CONTINUATION_OK = g.FALSE

class cD_TOKEN:

    def __init__(self):
        self.I = 0
        self.J = 0
        self.pSPECIALS = 3
        self.SPECIALS = ' ,:;'

lD_TOKEN = cD_TOKEN()

def D_TOKEN():
    global D_INDEX, D_CONTINUATION_OK
    l = lD_TOKEN
    
    while True:
        while (BYTE(g.CURRENT_CARD, D_INDEX) == BYTE(' ')) and \
                (D_INDEX <= g.TEXT_LIMIT[0]):
            D_INDEX = D_INDEX + 1;
        if D_INDEX <= g.TEXT_LIMIT[0]:
           break;
        if D_CONTINUATION_OK:  # GET NEXT RECORD 
            NEXT_RECORD();
            if g.CARD_TYPE[BYTE(g.CURRENT_CARD)] != g.CARD_TYPE[BYTE('D')]:
                g.LOOKED_RECORD_AHEAD = g.TRUE;
                D_CONTINUATION_OK = g.FALSE;
                return '';
            g.CURRENT_CARD = BYTE(g.CURRENT_CARD, 0, BYTE('D'));
            PRINT_COMMENT(g.TRUE);
            D_INDEX = 1;
            continue;
        else:
            return '';
    for l.I in range(1, l.pSPECIALS + 1):
        if BYTE(g.CURRENT_CARD, D_INDEX) == BYTE(l.SPECIALS, l.I):
            D_INDEX = D_INDEX + 1;
            return SUBSTR(g.CURRENT_CARD, D_INDEX - 1, 1);
    l.I = D_INDEX;
    escape_TOKEN = False
    while D_INDEX <= g.TEXT_LIMIT[0]:
        for l.J in range(0, l.pSPECIALS + 1):
            if BYTE(g.CURRENT_CARD, D_INDEX) == BYTE(l.SPECIALS, l.J):
                escape_TOKEN = True
                break;
        if escape_TOKEN:
            break
        D_INDEX = D_INDEX + 1;
    return SUBSTR(g.CURRENT_CARD, l.I, D_INDEX - l.I);
