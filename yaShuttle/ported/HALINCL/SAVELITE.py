#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   SAVELITE.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Made a stub for this.
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
import HALINCL.COMMON as h
from ERROR import ERROR
from GETLITER import GET_LITERAL


def SAVE_LITERAL(TYPE, VAL, SIZE=None, CMPOOL=0):
    g.LIT_TOP(g.LIT_TOP() + 1);
    if g.LIT_TOP() == g.LIT_TOP_MAX: ERROR(d.CLASS_BT, 3);
    g.LIT_PTR = GET_LITERAL(g.LIT_TOP());
    g.LIT1(g.LIT_PTR, TYPE);
    g.LIT2(g.LIT_PTR, 0);
    g.LIT3(g.LIT_PTR, 0);
    # DO CASE TYPE;
    if TYPE == 0:
    # CHARACTER
    # DO
        '''
        It would appear that this procedure implicitly makes use of the 
        knowledge of the internal formst of the object (VAL) which is passed 
        to a function in lieu of the actual contents of the string being 
        referenced.  That, of course, is of no value to us whatsoever, given
        that we don't have a System/360 environment and whatever conventions
        it used for subroutine linkage.  We will have to treat VAL as a Python
        string, and fill in the rest with our imagination.  It further appears
        that strings are saved in whatever character encoding happens to be
        of use.
        '''
        length = len(VAL)
        if length > 256:
            length = 256
        if length == 0:  # DO
            g.LIT2(g.LIT_PTR, 0);
            return g.LIT_TOP();
        # END
        top = length - 1
        # Copy the contents of the string to LIT_CHAR[].
        a = g.LIT_CHAR_AD()
        for i in range(length):
            # I should probably use BYTE() to convert VAL[i] (a character)
            # into EBCDIC.  I don't want to debug that, though, so for now
            # I'll just use the ASCII code.  It means the external file will
            # have the wrong character coding, but that shouldn't cause any
            # problem at the moment.
            c = ord(VAL[i])
            if a >= len(h.LIT_CHAR):
                h.LIT_CHAR.append(c)
            else:
                h.LIT_CHAR[a] = c
            a += 1
        g.LIT2(g.LIT_PTR, (top << 24) | g.LIT_CHAR_AD());
        VAL = SHR(top, 24) + 1;
        # I don't know why the extra 1 is added to LIT_CHAR_USED.  Perhaps
        # a table of string lengths is eventually added to the end of 
        # LIT_CHAR (or something like that), and this is just accounted for
        # the extra space it will eventually need.  I don't find any code for
        # it elsewhere, though.  Perhaps it was just a boo-boo.
        g.LIT_CHAR_USED(g.LIT_CHAR_USED() + length + 1);
        g.LIT_CHAR_AD(g.LIT_CHAR_AD() + length);
    # END
    elif TYPE == 1:
    # ARITHMETIC
    # DO
        msw, lsw = toFloatIBM(VAL)
        g.LIT2(g.LIT_PTR, msw);
        g.LIT3(g.LIT_PTR, lsw);
        # WHEN INSERTING CONSTANTS FROM A COMPOOL INTO THE 
        # LITERAL TABLE CHECK IF THE CONSTANT IS A DOUBLE 
        # AND THEN CHANGE LIT1 TO 5 IF IT IS. 
        if CMPOOL:
            if ((g.SYT_FLAGS(g.ID_LOC) & g.DOUBLE_FLAG) != 0): 
                g.LIT1(g.LIT_PTR, 5); 
    # END;
    elif TYPE == 2:
    #  BIT
    # DO
        g.LIT2(g.LIT_PTR, VAL);
        g.LIT3(g.LIT_PTR, SIZE);
    # END
    # END DO CASE
    CMPOOL = 0;
    return g.LIT_TOP();
# END SAVE_LITERAL;
