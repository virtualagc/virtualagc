#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   COMROUT.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-27 RSB  Ported CHAR_INDEX
            2023-10-09 RSB  Ported PAD
'''

from xplBuiltins import *
import g

X72 = ' ' * 72

# This is a modified duplicate from PAD.
# ROUTINE TO PAD STRINGS WITH BLANKS TO A FIXED LENGTH
def PAD(STRING, WIDTH):
    # Locals L, X72
    
    L = LENGTH(STRING);
    if L >= WIDTH:
        return STRING;
    else:
        return STRING + SUBSTR(X72, 72 + L - WIDTH);
# END PAD;

# Note that the following is a duplicate from CHARINDE, so I'm not sure why
# it's here.
def CHAR_INDEX(STRING1, STRING2):
    # Locals are L1, L2, I.
    
    L1 = LENGTH(STRING1);
    L2 = LENGTH(STRING2);
    if L2 > L1:
       return -1;
    for I in range(0, L1 - L2 + 1):
        if SUBSTR(STRING1, I, L2) == STRING2:
            return I;
    return -1;
# END CHAR_INDEX;
