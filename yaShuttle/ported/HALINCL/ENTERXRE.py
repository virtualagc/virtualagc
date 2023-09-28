#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   ENTERXRE.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-10 RSB  Ported
'''

from xplBuiltins import *
import g

# PROCEDURE TO BUILD AN XREF ENTRY TO THE XREF LIST


def ENTER_XREF(ROOT, FLAG):
    # No locals
    
    # TO MAKE SURE A DEFINITION XREF ALWAYS EXISTS FOR EACH VARIABLE
    # (I.E, NOT OVERWRITTEN BY PROCESSING ANOTHER XREF FOR THE SAME
    # VARIABLE AT THE SAME STATEMENT), DR111356 ADDED ANOTHER CHECK
    # ON THE FLAG FIELD OF THE PROCESSING XREF TO DETERMINE WHETHER
    # OR NOT A NEW XREF NEEDS TO BE CREATED.
    # HOWEVER, TO AVOID THE CREATION OF AN EXTRA DEFINITION XREF
    # FOR A COMSUB LABEL AT THE POINT OF CALL, OR FOR A PROCEDURE
    # LABEL IN A FORWARD CALL (A CALL OCCURS BEFORE THE PROCEDURE
    # IS DEFINED), NO_NEW_XREF IS SET TO PREVENT THE DEFINITION XREF
    # FROM BEING CREATED IN THE CALL STATEMENTS.
    
    if ((g.XREF(ROOT) & g.XREF_MASK) == g.STMT_NUM()) and \
            (((g.XREF(ROOT) & 0xE000) != 0) or g.NO_NEW_XREF):
        g.XREF(ROOT, g.XREF(ROOT) | FLAG);
    else:  # CREATE A NEW XREF
        # NEXT_ELEMENT(CROSS_REF);
        g.XREF_INDEX(g.XREF_INDEX() + 1);
        g.XREF(0, SHL(g.XREF_INDEX(), 16));
        g.XREF(g.XREF_INDEX(), (g.XREF(ROOT) & 0xFFFF0000) | g.STMT_NUM() | FLAG);
        g.XREF(ROOT, (g.XREF(ROOT) & 0xFFFF) | g.XREF(0));
        ROOT = g.XREF_INDEX();
    return ROOT;
