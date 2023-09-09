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

'''
   /* ROUTINE TO PICK OUT TOKENS FROM A DIRECTIVE CARD.            */
   /* IF D_CONTINUATION_OK IS TRUE, THEN IF NO TOKEN EXISTS ON THE */
   /*   CURRENT RECORD, D_TOKEN WILL GET THE NEXT RECORD AND       */
   /*   IF THAT RECORD IS ALSO A DIRECTIVE, RETURN THE FIRST       */
   /*   TOKEN FROM IT.                                             */
   /* D_TOKEN RETURNS THE TOKEN FOUND                              */
'''

def D_TOKEN():
    # Locals
    I = 0
    J = 0
    pSPECIALS = 3
    SPECIALS = ' ,:;';
    
    while True:
        while (BYTE(CURRENT_CARD,g.D_INDEX) == BYTE(' ')) and \
                (g.D_INDEX <= TEXT_LIMIT):
            g.D_INDEX = g.D_INDEX + 1;
        if g.D_INDEX <= TEXT_LIMIT:
           break;
        if g.D_CONTINUATION_OK: # GET NEXT RECORD 
            NEXT_RECORD();
            if CARD_TYPE(BYTE(CURRENT_CARD)) != CARD_TYPE(BYTE('D')):
                g.LOOKED_RECORD_AHEAD = TRUE;
                g.D_CONTINUATION_OK = FALSE;
                return '';
            g.CURRENT_CARD = BYTE(g.CURRENT_CARD, 0, BYTE('D'));
            PRINT_COMMENT(TRUE);
            g.D_INDEX = 1;
            continue;
        else:
            return '';
    for I in range(1, pSPECIALS+1):
        if BYTE(CURRENT_CARD, g.D_INDEX)== BYTE(SPECIALS, I):
            g.D_INDEX = g.D_INDEX + 1;
            return SUBSTR(CURRENT_CARD, g.D_INDEX-1, 1);
    I = g.D_INDEX;
    while g.D_INDEX <= TEXT_LIMIT:
        for J in range(0, pSPECIALS+1):
            if BYTE(CURRENT_CARD, g.D_INDEX) == BYTE(SPECIALS, J):
                break;
        g.D_INDEX = g.D_INDEX + 1;
    return SUBSTR(CURRENT_CARD, I, g.D_INDEX - I);
