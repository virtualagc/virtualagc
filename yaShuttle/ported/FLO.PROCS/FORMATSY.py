#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   FORMATSY.py
   Purpose:    Part of the HAL/S-FC compiler's HALMAT optimization
               process.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-11-19 RSB  Imported from XPL
"""

from xplBuiltins import *
import g
import HALINCL.COMMON as h
from FORMATFO import FORMAT_FORM_PARM_CELL
from FORMATNA import FORMAT_NAME_TERM_CELLS
from FORMATNA import FORMAT_NAME_TERM_CELLS
from FORMATVA import FORMAT_VAR_REF_CELL

#*************************************************************************
# PROCEDURE NAME:  FORMAT_SYT_VPTRS
# MEMBER NAME:     FORMATSY
# LOCAL DECLARATIONS:
#          J                 BIT(16)
# EXTERNAL VARIABLES REFERENCED:
#          EQUATE_LABEL
#          FUNC_CLASS
#          NAME_FLAG
#          PROC_LABEL
#          STRUCTURE
#          SYM_ADD
#          SYM_CLASS
#          SYM_FLAGS
#          SYM_NUM
#          SYM_TAB
#          SYM_TYPE
#          SYM_VPTR
#          SYT_CLASS
#          SYT_FLAGS
#          SYT_NUM
#          SYT_TYPE
#          SYT_VPTR
#          VPTR_INX
# EXTERNAL VARIABLES CHANGED:
#          LEVEL
# EXTERNAL PROCEDURES CALLED:
#          FORMAT_FORM_PARM_CELL
#          FORMAT_NAME_TERM_CELLS
#          FORMAT_VAR_REF_CELL
# CALLED BY:
#          DUMP_ALL
#*************************************************************************

# FORMATS THE CELLS POINTED TO BY THE POINTERS IN THE SYT_VPTR ARRAY


def FORMAT_SYT_VPTRS():
    # Local: J
    for J  in range(1, g.VPTR_INX + 1):
        g.LEVEL = 0;
        if g.SYT_CLASS(g.SYT_NUM(J)) == g.FUNC_CLASS or \
                g.SYT_TYPE(g.SYT_NUM(J)) == g.PROC_LABEL:
            FORMAT_FORM_PARM_CELL(g.SYT_NUM(J), g.SYT_VPTR(J));
        elif (g.SYT_FLAGS(g.SYT_NUM(J)) & g.NAME_FLAG) != 0 or \
                g.SYT_TYPE(g.SYT_NUM(J)) == g.EQUATE_LABEL:
            FORMAT_VAR_REF_CELL(g.SYT_VPTR(J));
        elif g.SYT_TYPE(g.SYT_NUM(J)) == g.STRUCTURE:
            FORMAT_NAME_TERM_CELLS(g.SYT_NUM(J), g.SYT_VPTR(J));
    # END
# END FORMAT_SYT_VPTRS;
