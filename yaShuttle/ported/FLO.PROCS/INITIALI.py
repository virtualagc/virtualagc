#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   INITIALI.py
   Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
               generation process.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-11-18 RSB  Ported from XPL.
"""

from xplBuiltins import *
from HALINCL.SPACELIB import *
import g
import HALINCL.COMMON as h
from NEWHALMA import NEW_HALMAT_BLOCK
from SYMBOLTA import SYMBOL_TABLE_PREPASS
from HALINCL.VMEM3 import GET_CELL

#*************************************************************************
# PROCEDURE NAME:  INITIALIZE
# MEMBER NAME:     INITIALI
# EXTERNAL VARIABLES REFERENCED:
#          COMM
#          INIT_SMRK_LINK
#          OPTIONS_CODE
#          SMRK_LIST
#          STMT_DATA_HEAD
#          SYM_ADD
#          TOGGLE
#          TRUE
#          VMEM_F
# EXTERNAL VARIABLES CHANGED:
#          BLOCK#
#          CTR
#          HMAT_OPT
#          OLD_STMT#
#          SMRK_LINK
#          START_NODE
#          STMT_DATA_CELL
# EXTERNAL PROCEDURES CALLED:
#          GET_CELL
#          NEW_HALMAT_BLOCK
#          SYMBOL_TABLE_PREPASS
#*************************************************************************


def INITIALIZE():
    #  IF PHASE 1 ERRORS OR NOTABLES THEN LINK TO NEXT PHASE
    if (g.OPTIONS_CODE() & 0x800) == 0 or (g.TOGGLE & 0x8) != 0: 
        RECORD_LINK();
    if (g.OPTIONS_CODE() & 0x00040000) != 0:
        g.HMAT_OPT = g.TRUE;
    RECORD_UNSEAL(h.SYM_ADD);
    SYMBOL_TABLE_PREPASS();
    NEW_HALMAT_BLOCK();
    g.CTR = 2;
    g.BLOCKp = 0;
    if g.HMAT_OPT:  # DO
        g.START_NODE = 2;
        g.SMRK_LINK = g.INIT_SMRK_LINK();
    # END
    g.OLD_STMTp = 1;
    # ELIMINATE THE ZERO PTR
    GET_CELL(4, ADDR(g.VMEM_F), 0);
    g.STMT_DATA_CELL = g.STMT_DATA_HEAD;
# END INITIALIZE;
