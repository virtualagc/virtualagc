#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   COMROUT.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-27 RSB  Ported
'''

from xplBuiltins import *
import g

'''
I hadn't realized there was XPL code for the PAD function, so I added my own
version of it to xplBuiltins long ago.  For now at least, let's just ignore it,
rather than replacing my version.

   /* ROUTINE TO PAD STRINGS WITH BLANKS TO A FIXED LENGTH */
PAD:
   PROCEDURE(STRING,WIDTH) CHARACTER;
      DECLARE STRING CHARACTER, (WIDTH,L) FIXED;
      DECLARE X72 CHARACTER INITIAL
 ('                                                                        ');
      L = LENGTH(STRING);
      IF L >= WIDTH THEN RETURN STRING;
      ELSE RETURN STRING || SUBSTR(X72, 72 + L - WIDTH);
   END PAD;
'''
   
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
