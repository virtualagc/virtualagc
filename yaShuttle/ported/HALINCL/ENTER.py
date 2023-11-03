#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   ENTER.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-10 RSB  Ported
'''

from xplBuiltins import *
import g
import HALINCL.COMMON   as h
import HALINCL.SPACELIB as s
from HALINCL.ENTERXRE import ENTER_XREF


def ENTER(NAME, CLASS):
    # No locals.

    g.NDECSY(g.NDECSY() + 1);  #  DON'T OCCUPY LAST SLOT
    s.NEXT_ELEMENT(h.SYM_TAB);
    # DELETED NEXT_ELEMENT(DOWN_INFO) FROM THIS SPOT 
    s.NEXT_ELEMENT(g.LINK_SORT);
    g.SYT_NAME(g.NDECSY(), NAME);
    g.SYT_CLASS(g.NDECSY(), CLASS);
    g.SYT_SCOPE(g.NDECSY(), g.SCOPEp);
    g.SYT_NEST(g.NDECSY(), g.NEST);
    g.SYT_XREF(g.NDECSY(), ENTER_XREF(0, 0));
    if CLASS == g.REPL_ARG_CLASS:
        return g.NDECSY();
    g.SYT_HASHLINK(g.NDECSY(), g.SYT_HASHSTART[g.NAME_HASH]);
    g.SYT_HASHSTART[g.NAME_HASH] = g.NDECSY();
    return g.NDECSY();
