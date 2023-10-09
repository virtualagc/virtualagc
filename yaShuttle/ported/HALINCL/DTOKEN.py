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


class cD_TOKEN:

    def __init__(self):
        self.I = 0
        self.J = 0
        self.pSPECIALS = 3
        self.SPECIALS = ' ,:;'
        # D_INDEX and D_CONTINUATION_OK are neither local nor global variable
        # in the original XPL source code.  (They are local in STREAM, and 
        # are used similarly to how they are used here ... for whatever that's
        # worth!)  Why the original XPL compiler thought they were DECLARE'd
        # in *this* scope is currently beyond me.
        self.D_INDEX = 1
        self.D_CONTINUATION_OK = g.FALSE

lD_TOKEN = cD_TOKEN()


def D_TOKEN():
    l = lD_TOKEN
    
    while True:
        while (BYTE(g.CURRENT_CARD, l.D_INDEX) == BYTE(' ')) and \
                (l.D_INDEX <= g.TEXT_LIMIT[0]):
            l.D_INDEX = l.D_INDEX + 1;
        if l.D_INDEX <= g.TEXT_LIMIT[0]:
           break;
        if l.D_CONTINUATION_OK:  # GET NEXT RECORD 
            NEXT_RECORD();
            if g.CARD_TYPE[BYTE(g.CURRENT_CARD)] != g.CARD_TYPE[BYTE('D')]:
                g.LOOKED_RECORD_AHEAD = g.TRUE;
                l.D_CONTINUATION_OK = g.FALSE;
                return '';
            g.CURRENT_CARD = BYTE(g.CURRENT_CARD, 0, BYTE('D'));
            PRINT_COMMENT(g.TRUE);
            l.D_INDEX = 1;
            continue;
        else:
            return '';
    for l.I in range(1, l.pSPECIALS + 1):
        if BYTE(g.CURRENT_CARD, l.D_INDEX) == BYTE(l.SPECIALS, l.I):
            l.D_INDEX = l.D_INDEX + 1;
            return SUBSTR(g.CURRENT_CARD, l.D_INDEX - 1, 1);
    l.I = l.D_INDEX;
    escape_TOKEN = False
    while l.D_INDEX <= g.TEXT_LIMIT[0]:
        for l.J in range(0, l.pSPECIALS + 1):
            if BYTE(g.CURRENT_CARD, l.D_INDEX) == BYTE(l.SPECIALS, l.J):
                escape_TOKEN = True
                break;
        if escape_TOKEN:
            break
        l.D_INDEX = l.D_INDEX + 1;
    return SUBSTR(g.CURRENT_CARD, l.I, l.D_INDEX - l.I);
