#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   INITIALI.py
   Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-12-05 RSB  Ported from XPL
"""

from xplBuiltins import *
from HALINCL.SPACELIB import *
import g
import HALINCL.COMMON as h
from SETUPZAP import SETUP_ZAP_BY_TYPE

#*************************************************************************
# PROCEDURE NAME:  INITIALISE
# MEMBER NAME:     INITIALI
# LOCAL DECLARATIONS:
#          SHRINK_SYMBOLS    LABEL
# EXTERNAL VARIABLES REFERENCED:
#          #ZAP_BY_TYPE_ARRAYS
#          COMMONSE_LIST
#          COMM
#          CURLBLK
#          FALSE
#          FOR
#          LIT_TOP
#          LITERAL1
#          LITFILE
#          LITSIZ
#          LIT1
#          MAX_STACK_LEVEL
#          MOVEABLE
#          OBPS
#          OPTION_BITS
#          PAR_SYM
#          PULL_LOOP_HEAD
#          REL
#          STRUCT#
#          SYM_NAME
#          SYM_REL
#          SYM_TAB
#          SYT_NAME
#          TOGGLE
#          VAL_TABLE
#          XPULL_LOOP_HEAD
#          ZAPIT
# EXTERNAL VARIABLES CHANGED:
#          HALMAT_REQUESTED
#          LEVEL_STACK_VARS
#          LIT_PG
#          LITMAX
#          OPTIMIZER_OFF
#          STATISTICS
#          SYM_SHRINK
#          SYT_SIZE
#          TRACE
#          VAL_SIZE
# EXTERNAL PROCEDURES CALLED:
#          REFERENCED
#          SETUP_ZAP_BY_TYPE
#*************************************************************************


def INITIALISE():
    # EJECTS UNREFERENCED SYMBOLS AND SETS UP REL PARALLEL TO SYT TABLE

    def SHRINK_SYMBOLS():
        # Local: INX
        RECORD_CONSTANT(g.SYM_SHRINK, h.COMM[10] + 1, g.MOVEABLE);
        RECORD_USED(g.SYM_SHRINK, RECORD_ALLOC(g.SYM_SHRINK));
        # COMM(10) = SYMBOLS DECLARED
        g.SYT_SIZE = 1;
        g.REL(0, 1)
        g.REL(1, 1);
        for INX in range(2, h.COMM[10] + 1):
            if REFERENCED(INX):  # DO
                g.SYT_SIZE = g.SYT_SIZE + 1;
                g.REL(INX, g.SYT_SIZE);
            # END
            else: g.REL(INX, 1);
            if g.TRACE: OUTPUT(0, 'SYMBOL_SHRINKER(' + str(INX) \
                +'):   ' + str(g.REL(INX)) + '  ' + g.SYT_NAME(INX));
        # END
    # END SHRINK_SYMBOLS;
    
    g.TRACE = (g.OPTION_BITS & 0x200) != 0;  # X5
    g.OPTIMIZER_OFF = g.FALSE;
    g.HALMAT_REQUESTED = ((g.TOGGLE & 0x40) != 0) and \
                        (g.OPTIMIZER_OFF == g.FALSE);
    g.HALMAT_REQUESTED = g.HALMAT_REQUESTED and g.TRACE;
    g.STATISTICS = (g.OPTION_BITS & 0x01000000) != 0;  # X6
    g.HIGHOPT = (g.OPTION_BITS & 0x80) != 0;
    g.LITMAX = g.LIT_TOP;
    g.LITMAX = g.LITMAX // g.LITSIZ;
    g.LIT1(0, FILE(g.LIT1(0), g.LITFILE, g.CURLBLK));
    SHRINK_SYMBOLS();
    SET_RECORD_WIDTH(g.PAR_SYM, SHL(g.SYT_SIZE + 1, 1));
    ALLOCATE_SPACE(g.PAR_SYM, g.MAX_STACK_LEVEL);
    NEXT_ELEMENT(g.PAR_SYM);
    RECORD_CONSTANT(g.STRUCTp, SHL(g.SYT_SIZE + 1, 1), g.MOVEABLE);
    RECORD_USED(g.STRUCTp, RECORD_ALLOC(g.STRUCTp));
    g.VAL_SIZE = SHR(g.SYT_SIZE, 5) + 1;
    SET_RECORD_WIDTH(g.VAL_TABLE, SHL(g.VAL_SIZE, 2));
    ALLOCATE_SPACE(g.VAL_TABLE, g.MAX_STACK_LEVEL);
    NEXT_ELEMENT(g.VAL_TABLE);
    ALLOCATE_SPACE(g.LEVEL_STACK_VARS, g.MAX_STACK_LEVEL);
    NEXT_ELEMENT(g.LEVEL_STACK_VARS);
    g.PULL_LOOP_HEAD(0, -1);
    SET_RECORD_WIDTH(g.OBPS, SHL(g.VAL_SIZE, 2));
    ALLOCATE_SPACE(g.OBPS, g.MAX_STACK_LEVEL);
    NEXT_ELEMENT(g.OBPS);
    SET_RECORD_WIDTH(g.ZAPIT, SHL(g.VAL_SIZE, 2));
    RECORD_CONSTANT(g.ZAPIT, g.pZAP_BY_TYPE_ARRAYS - 1, g.MOVEABLE);
    RECORD_USED(g.ZAPIT, RECORD_ALLOC(g.ZAPIT));
    ALLOCATE_SPACE(g.COMMONSE_LIST, 1499);
    NEXT_ELEMENT(g.COMMONSE_LIST);
    SETUP_ZAP_BY_TYPE();
# END INITIALISE;
