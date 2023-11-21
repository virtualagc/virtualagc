#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   ERRORS.py
   Purpose:    Part of the HAL/S-FC compiler's HALMAT optimizer
               process.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-11-20 RSB  Ported from XPL
"""

from xplBuiltins import *
import g
import HALINCL.COMMON as h
from BOMB_OUT import BOMB_OUT
from HALINCL.CERRORS import COMMON_ERRORS

#*************************************************************************
# PROCEDURE NAME:  ERRORS
# MEMBER NAME:     ERRORS
# INPUT PARAMETERS:
#          CLASS             BIT(16)
#          NUM               BIT(16)
#          TEXT              CHARACTER;
# LOCAL DECLARATIONS:
#          SEVERITY          BIT(16)
# EXTERNAL VARIABLES REFERENCED:
#          STMT#
#          BOMB_OUT
# EXTERNAL VARIABLES CHANGED:
#          COMMON_RETURN_CODE
#          ERROR_COUNT
#          MAX_SEVERITY
# EXTERNAL PROCEDURES CALLED:
#          COMMON_ERRORS
# CALLED BY:
#          CREATE_STMT
#          DESCENDENT
#          FORMAT_NAME_TERM_CELLS
#          GET_NAME_INITIALS
#          GET_P_F_INV_CELL
#          GET_STMT_VARS
#          GET_SYT_VPTR
#          INTEGER_LIT
#          PROCESS_DECL_SMRK
#          PROCESS_EXTN
#          SCAN_INITIAL_LIST
#          SEARCH_EXPRESSION
#          STACK_PTR
#          TRAVERSE_INIT_LIST
#*************************************************************************

# PRINTS ERROR MESSAGES


def ERRORS(CLASS, NUM, TEXT):
    # Locals: SEVERITY
    
    g.ERROR_COUNT = g.ERROR_COUNT + 1;
    SEVERITY = COMMON_ERRORS(CLASS, NUM, TEXT, g.ERROR_COUNT, g.STMTp);
    if SEVERITY > g.MAX_SEVERITY:
        g.MAX_SEVERITY = SEVERITY;
    h.COMMON_RETURN_CODE = SHL(g.MAX_SEVERITY, 2);
    if SEVERITY > 1: BOMB_OUT();
    return;
# END ERRORS;
