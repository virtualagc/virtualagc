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

from g import *

'''
   /* ROUTINE TO PICK OUT TOKENS FROM A DIRECTIVE CARD.            */
   /* IF D_CONTINUATION_OK IS TRUE, THEN IF NO TOKEN EXISTS ON THE */
   /*   CURRENT RECORD, D_TOKEN WILL GET THE NEXT RECORD AND       */
   /*   IF THAT RECORD IS ALSO A DIRECTIVE, RETURN THE FIRST       */
   /*   TOKEN FROM IT.                                             */
   /* D_TOKEN RETURNS THE TOKEN FOUND                              */
'''

def D_TOKEN():
    global D_INDEX, LOOKED_RECORD_AHEAD, D_CONTINUATION_OK
    # Locals
    I = 0
    J = 0
    pSPECIALS = 3
    SPECIALS = ' ,:;';
    
    while True:
        while (BYTE(CURRENT_CARD,D_INDEX) == BYTE(' ')) and \
                (D_INDEX <= TEXT_LIMIT):
            D_INDEX = D_INDEX + 1;
        if D_INDEX <= TEXT_LIMIT:
           break;
        if D_CONTINUATION_OK: # GET NEXT RECORD 
            NEXT_RECORD();
            if CARD_TYPE(BYTE(CURRENT_CARD)) != CARD_TYPE(BYTE('D')):
                LOOKED_RECORD_AHEAD = TRUE;
                D_CONTINUATION_OK = FALSE;
                return '';
            BYTE(CURRENT_CARD, 0, BYTE('D'));
            PRINT_COMMENT(TRUE);
            D_INDEX = 1;
            continue;
        else:
            return '';
    for I in range(1, pSPECIALS+1):
        if BYTE(CURRENT_CARD, D_INDEX)== BYTE(SPECIALS, I):
            D_INDEX = D_INDEX + 1;
            return SUBSTR(CURRENT_CARD, D_INDEX-1, 1);
    I = D_INDEX;
    while D_INDEX <= TEXT_LIMIT:
        for J in range(0, pSPECIALS+1):
            if BYTE(CURRENT_CARD, D_INDEX) == BYTE(SPECIALS, J):
                break;
        D_INDEX = D_INDEX + 1;
    return SUBSTR(CURRENT_CARD, I, D_INDEX - I);
