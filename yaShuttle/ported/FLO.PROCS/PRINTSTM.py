#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   PRINTSTM.py
   Purpose:    Part of the HAL/S-FC compiler's HALMAT optimization
               process.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-11-23 RSB  Ported from XPL
"""

from xplBuiltins   import *
from HALINCL.VMEM3 import *
import g
import HALINCL.COMMON as h
from HEX      import HEX
from FORMATCE import IMPORT_CELL_TREE

#*************************************************************************
# PROCEDURE NAME:  PRINT_STMT_VARS
# MEMBER NAME:     PRINTSTM
# LOCAL DECLARATIONS:
#          STMT_PTR          FIXED
# EXTERNAL VARIABLES REFERENCED:
#          COMM
#          STMT_DATA_HEAD
#          VMEM_F
#          VMEM_H
#          VMEM_LOC_ADDR
#          X1
#          X10
# EXTERNAL VARIABLES CHANGED:
#          EXP_VARS
#          EXP_PTRS
#          PTR_INX
# EXTERNAL PROCEDURES CALLED:
#          HEX
#          FORMAT_CELL_TREE
#          LOCATE
# CALLED BY:
#          DUMP_ALL
#*************************************************************************

# FORMATS THE STMT VARIBLES DATA ASSOCIATED WITH THE STMT DATA CELLS

def PRINT_STMT_VARS():
    # Local: STMT_PTR.
    OUTPUT(0, g.X1);
    OUTPUT(0, 'STMT VARIABLES:');
    OUTPUT(0, g.X1);
    '''
    Regarding what immediately follows, I think that it related to data
    passed from PASS1 to FLOWGEN via the COMM[] array in memory.  PASS1
    will have stored something called CELL_PTR in COMM[16] (which is
    the same thing as STMT_DATA_HEAD()).  The CALL LOCATE(...) then
    causes the VMEM_F[] array in FLOWGEN to start at the location 
    pointed to by PASS1's CELL_PTR.  VMEM_F[], recall, overlays a 
    block of memory and interprets it as an array of FIXED.
    
    Then, the VMEM_H[] array is reinterpreted to start atVMEM_LOC_PTR 
    (which, recall, points to the last located virtual-memory address).
    Recall further that VMEM_H[] is used to treat a block of memory as
    BIT(16) values.  
    
    So apparently, the whole while-loop is maneuvering through a linked
    list of "cell" data which has been left in memory by PASS 1. Which, 
    of course, never happened (in this Python port) in the first place.
    
    What to do, what to do?
    '''
    STMT_PTR = g.STMT_DATA_HEAD();
    while STMT_PTR != -1:
        LOCATE(STMT_PTR,ADDR(g.VMEM_F),0);
        COREWORD(ADDR(g.VMEM_H)) = VMEM_LOC_ADDR;
        STMT_PTR = g.VMEM_F(0);
        if g.VMEM_F(4) == g.VMEM_F(5): continue;
        OUTPUT(0, g.X10 + 'STMT#' + g.VMEM_H(14) + '-- LHS: ' + \
               HEX(g.VMEM_F(4),8) + '  RHS: ' + HEX(g.VMEM_F(5),8));
        g.PTR_INX = 2;
        g.EXP_PTRS[1] = g.VMEM_F(5) | 0x80000000;
        g.EXP_PTRS[2] = g.VMEM_F(4) | 0x80000000;
        g.EXP_VARS[1] = 1
        g.EXP_VARS[2] = 1;
        FORMAT_CELL_TREE();
    #END
# END PRINT_STMT_VARS;
