#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   HEX.py
   Purpose:    Part of the HAL/S-FC compiler's HALMAT optimization
               process.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-11-21 RSB  Ported from XPL.
"""

from xplBuiltins import *
import g

#*************************************************************************
# PROCEDURE NAME:  HEX
# MEMBER NAME:     HEX
# FUNCTION RETURN TYPE:
#          CHARACTER
# INPUT PARAMETERS:
#          HVAL              FIXED
#          N                 FIXED
# LOCAL DECLARATIONS:
#          HEXCODES          CHARACTER;
#          H_LOOP            LABEL
#          STRING            CHARACTER;
#          ZEROS             CHARACTER;
# CALLED BY:
#          DUMP_STMT_HALMAT
#          DUMP_ALL
#          FORMAT_EXP_VARS_CELL
#          FORMAT_FORM_PARM_CELL
#          FORMAT_NAME_TERM_CELLS
#          FORMAT_PF_INV_CELL
#          FORMAT_VAR_REF_CELL
#          GET_STMT_VARS
#          PAGE_DUMP
#          PRINT_STMT_VARS
#          SCAN_INITIAL_LIST
#*************************************************************************

# SUBROUTINE TO CONVERT INTEGER TO EXTERNAL HEX NOTATION

ZEROS = '00000000'
HEXCODES = '0123456789ABCDEF'


def HEX(HVAL, N):
    # Locals: STRING, ZEROS, HEXCODES.
    HVAL &= 0xFFFFFFFF # FIXED
    goto = "firstTry"
    
    while goto != None:
        if goto == "firstTry": goto = None
        if goto == None:
             STRING = '';
        if goto == "H_LOOP": goto = None
        STRING = SUBSTR(HEXCODES, HVAL & 0xF, 1) + STRING;
        HVAL = SHR(HVAL, 4);
        if HVAL != 0: 
            goto = "H_LOOP";
            continue
        if LENGTH(STRING) >= N: return STRING;
        return SUBSTR(ZEROS, 0, N - LENGTH(STRING)) + STRING;
# END HEX;
