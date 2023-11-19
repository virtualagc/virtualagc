#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   DUMPALL.py
   Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
               generation process.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-11-19 RSB  Ported from XPL.
"""

from xplBuiltins import *
import g
import HALINCL.VMEM2 as v2
from FORMATSY import FORMAT_SYT_VPTRS
from HEX      import HEX
from PAGEDUMP import PAGE_DUMP
from PRINTSTM import PRINT_STMT_VARS

#*************************************************************************
# PROCEDURE NAME:  DUMP_ALL
# MEMBER NAME:     DUMPALL
# INPUT PARAMETERS:
#          FORMAT            BIT(16)
# LOCAL DECLARATIONS:
#          I                 BIT(16)
#          MSG(1)            CHARACTER;
# EXTERNAL VARIABLES REFERENCED:
#          COMM
#          LINELENGTH
#          SYM_ADD
#          SYM_NAME
#          SYM_NUM
#          SYM_TAB
#          SYM_VPTR
#          SYT_NAME
#          SYT_NUM
#          SYT_VPTR
#          VMEM_DUMP
#          VMEM_LAST_PAGE
#          VPTR_INX
#          X1
#          X3
# EXTERNAL PROCEDURES CALLED:
#          FORMAT_SYT_VPTRS
#          HEX
#          PAGE_DUMP
#          PRINT_STMT_VARS
#*************************************************************************

# DUMPS VMEM POINTERS,CELLS AND PAGES


def DUMP_ALL(FORMAT):
    # Locals: MSG, I
    MSG = [''] * (1 + 1)
    OUTPUT(1, '1');
    OUTPUT(0, 'INCLUDE LIST HEAD: ' + HEX(COMM(14)));
    OUTPUT(0, 'STMT DATA HEAD: ' + HEX(COMM(16)));
    OUTPUT(0, g.X1);
    OUTPUT(0, 'SYT VPTRS(' + g.VPTR_INX + '):');
    OUTPUT(0, g.X1);
    for I  in range(1, g.VPTR_INX + 1):
        MSG[1] = g.SYT_NAME(g.SYT_NUM(I)) + ':' + HEX(g.SYT_VPTR(I), 8) + g.X3;
        if LENGTH(MSG) + LENGTH(MSG[1]) > g.LINELENGTH:  # DO
            OUTPUT(0, MSG[0]);
            MSG[0] = MSG[1];
        # END
        else: MSG[0] = MSG[0] + MSG[1];
    # END
    OUTPUT(0, MSG[0]);
    if FORMAT & 1:  # DO
        FORMAT_SYT_VPTRS();
        OUTPUT(1, '1');
        PRINT_STMT_VARS();
    # END
    if g.VMEM_DUMP & 1:  # DO
        OUTPUT(1, '1');
        for I  in range(0, v2.VMEM_LAST_PAGE + 1):
            PAGE_DUMP(I);
        # END
    # END
# END DUMP_ALL;
