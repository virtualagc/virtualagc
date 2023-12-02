#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   FORMATVA.py
   Purpose:    Part of the HAL/S-FC compiler's HALMAT optimization
               process.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2022-11-21 RSB  Ported from XPL
"""

from xplBuiltins   import *
from HALINCL.VMEM3 import *
import g
import HALINCL.COMMON as h
from FLUSH    import FLUSH
from HEX      import HEX
from STACKPTR import STACK_PTR

#*************************************************************************
# PROCEDURE NAME:  FORMAT_VAR_REF_CELL
# MEMBER NAME:     FORMATVA
# INPUT PARAMETERS:
#          PTR               FIXED
#          NO_PRINT          BIT(8)
# LOCAL DECLARATIONS:
#          #SYTS             BIT(16)
#          ALPHA             BIT(8)
#          BETA              BIT(8)
#          EXP_STRINGS(4)    CHARACTER;
#          EXP_TYPE          BIT(8)
#          J                 BIT(16)
#          LAST_SUB_TYPE     BIT(16)
#          SUB_STRINGS(2)    CHARACTER;
#          SUB_TYPE          BIT(8)
#          SUBSCRIPTS        BIT(8)
# EXTERNAL VARIABLES REFERENCED:
#          FALSE
#          LEVEL
#          SYM_NAME
#          SYM_TAB
#          SYT_NAME
#          TRUE
#          VMEM_F
#          VMEM_H
#          VMEM_LOC_ADDR
# EXTERNAL VARIABLES CHANGED:
#          S
#          MSG
# EXTERNAL PROCEDURES CALLED:
#          FLUSH
#          HEX
#          LOCATE
#          STACK_PTR
# CALLED BY:
#          FORMAT_CELL_TREE
#          FORMAT_NAME_TERM_CELLS
#          FORMAT_SYT_VPTRS
#*************************************************************************

SUB_STRINGS = ('',':',';')
EXP_STRINGS = ('','#+','#-','','#')

def FORMAT_VAR_REF_CELL(PTR,NO_PRINT):
    # Locals: pSYTS, J, LAST_SUB_TYPE SUBSCRIPTS, ALPHA, SUB_TYPE, BETA,
    #         EXP_TYPE, SUB_STRINGS, EXP_STRINGS
    
    LOCATE(PTR,ADDR(g.VMEM_H),0);
    # COREWORD(ADDR(VMEM_F)) = VMEM_LOC_ADDR;
    if g.VMEM_H(1) < 0: #DO
        SUBSCRIPTS = g.TRUE;
        pSYTS = g.VMEM_H(1) & 0x7FFF;
    #END
    else: #DO
        SUBSCRIPTS = g.FALSE;
        pSYTS = g.VMEM_H(1);
    #END
    MSG = HEX(PTR,8) + ' --> ' + g.SYT_NAME(g.VMEM_H(4));
    for J in range(5, pSYTS+3 + 1):
        MSG = MSG + '.' + g.SYT_NAME(g.VMEM_H(J));
    #END
    if not (SUBSCRIPTS & 1): #DO
        if NO_PRINT & 1: MSG = SUBSTR(MSG,13);
        else: #DO
            g.S[0] = MSG;
            FLUSH(0);
        #END
        NO_PRINT = g.FALSE;
        return;
    #END
    J = pSYTS + 4;
    g.MSG[1] = '$(';
    g.MSG[2] = ''
    g.MSG[3] = '';
    LAST_SUB_TYPE = 0xFFFF & -1;
    while J <= SHR(g.VMEM_H(0),1) - 1:
        ALPHA = SHR(g.VMEM_H(J),8) & 3;
        SUB_TYPE = SHR(g.VMEM_H(J),10) & 3;
        BETA = g.VMEM_H(J) & 0xF;
        EXP_TYPE = SHR(g.VMEM_H(J),4) & 0xF;
        g.MSG[3] = g.MSG[3] + EXP_STRINGS(SHR(EXP_TYPE,1));
        if EXP_TYPE & 1: #DO
            J = J + 1;
            g.MSG[3] = g.MSG[3] + g.VMEM_H(J);
        #END
        else: g.MSG[3] = g.MSG[3] + '?';
        #DO CASE ALPHA;
        if ALPHA == 0:
            g.MSG[3] = '*';
        elif ALPHA == 1:
            pass;
        elif ALPHA == 2:
            if BETA: g.MSG[3] = g.MSG[3] + ' TO ';
        elif ALPHA == 3:
            if BETA: g.MSG[3] = g.MSG[3] + ' AT ';
        #END
        if BETA == 0: #DO
            if LAST_SUB_TYPE >= 0:
                if SUB_TYPE!=LAST_SUB_TYPE: 
                    g.MSG[2]=SUB_STRINGS(LAST_SUB_TYPE);
                else: g.MSG[2] = ',';
            LAST_SUB_TYPE = SUB_TYPE;
            g.MSG[1] = g.MSG[1] + g.MSG[2] + g.MSG[3];
            g.MSG[3] = '';
        #END
        J = J + 1;
    #END
    if SUB_TYPE==1 or SUB_TYPE==2: 
        g.MSG[1]=g.MSG[1] + SUB_STRINGS(SUB_TYPE);
    g.MSG[1] = g.MSG[1] + ')';
    g.MSG[2] = ''
    g.MSG[3] = '';
    if g.VMEM_F(1) != 0: #DO
        g.MSG[1] = g.MSG[1] + ' , ' + HEX(g.VMEM_F(1),8);
        STACK_PTR(g.VMEM_F(1) | 0x80000000,g.LEVEL+1);
    #END
    if NO_PRINT & 1: MSG = SUBSTR(MSG,13) + g.MSG[1];
    else: #DO
        g.S[0] = MSG;
        g.S[1] = g.MSG[1];
        FLUSH(1);
    #END
    NO_PRINT = g.FALSE;
# END FORMAT_VAR_REF_CELL;
