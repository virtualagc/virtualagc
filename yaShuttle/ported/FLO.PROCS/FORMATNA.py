#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   FORMATNA.py
   Purpose:    Part of the HAL/S-FC compiler's HALMAT optimization
               process.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-11-19 RSB  Ported from XPL.
"""

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
import HALINCL.VMEM2    as v2
from ERRORS   import ERRORS
from FLUSH    import FLUSH
from FORMATVA import FORMAT_VAR_REF_CELL

#*************************************************************************
# PROCEDURE NAME:  FORMAT_NAME_TERM_CELLS
# MEMBER NAME:     FORMATNA
# INPUT PARAMETERS:
#          SYMB#             BIT(16)
#          PTR               FIXED
# LOCAL DECLARATIONS:
#          #SYTS             BIT(16)
#          DONE              LABEL
#          DONETOO           LABEL
#          FIRSTWORD         BIT(16)
#          I                 BIT(16)
#          J                 BIT(16)
#          K                 BIT(16)
#          PTR_TEMP          FIXED
#          VARNAMES(100)     CHARACTER;
#          VMEM_F            FIXED
#          VMEM_H            BIT(16)
#          WORDTYPE          BIT(16)
# EXTERNAL VARIABLES REFERENCED:
#          CLASS_BI
#          FOREVER
#          LINELENGTH
#          MAXLINES
#          MSG
#          SYM_NAME
#          SYM_TAB
#          SYT_NAME
#          TRUE
#          VMEM_LOC_ADDR
#          X10
# EXTERNAL VARIABLES CHANGED:
#          LEVEL
#          PTR_INX
#          S
# EXTERNAL PROCEDURES CALLED:
#          ERRORS
#          FLUSH
#          FORMAT_VAR_REF_CELL
#          HEX
#          LOCATE
# CALLED BY:
#          FORMAT_SYT_VPTRS
#*************************************************************************

# FORMATS AND PRINTS A CHAIN OF NAME TERMINAL INITIALIZATION CELLS

# VMEM_F and VMEMH are intended to be local variables of 
# FORMAT_NAME_TERM_CELLS(), but I'm putting them here (as globals), 
# because I think they're supposed to be persistent.  Maybe.  Note
# that there are also global variables of these names in g.py, defined
# identically, so it's necessary to be careful with them.

vmem_h = []  # BIT(16)


def VMEM_H(n, value=None):
    global vmem_h
    while len(vmem_h) <= n:
        vmem_h.append(0)
    if value == None:
        return vmem_h[n]
    vmem_h[n] = value & 0xFFFF

    
vmem_f = []  # FIXED


def VMEM_F(n, value=None):
    global vmem_f
    while len(vmem_f) <= n:
        vmem_f.append(0)
    if value == None:
        return vmem_f[n]
    vmem_f[n] = value & 0xFFFFFFFF


def FORMAT_NAME_TERM_CELLS(SYMBp, PTR):
    # Locals: pSYTS, I, J, K, WORDTYPE, FIRSTWORD, PTR_TEMP, VARNAMES,
    #         VMEM_F, VMEM_H. 
    VARNAMES = [''] * (1 + 100)
    goto = None
    
    OUTPUT(0, g.X10 + HEX(PTR, 8) + ' --> ' + \
        'INITIAL VALUES FOR NAME TERMINALS IN STRUCTURE: ' + \
        g.SYT_NAME(SYMBp));
    while PTR != 0:
        LOCATE(PTR, ADDR(VMEM_F), 0);
        PTR = VMEM_F(1);
        #COREWORD(ADDR(VMEM_H)) = VMEM_LOC_ADDR;
        K = 0
        g.PTR_INX = 0;
        g.LEVEL = 1;
        pSYTS = VMEM_H(1);
        FIRSTWORD = (pSYTS + 5) & 0xFFFE;
        g.S[0] = g.SYT_NAME(VMEM_H(4));
        for J in range(5, pSYTS + 3 + 1):
            g.S[0] = g.S[0] + '.' + g.SYT_NAME(VMEM_H(J));
        # END
        FLUSH(0);
        g.S[0] = '';
        g.LEVEL = 2;
        J = FIRSTWORD;
        if VMEM_H(J) == 3:  # DO
            g.S[0] = 'ALL COPIES NULL.';
            FLUSH(0);
            goto = "DONETOO";
        # END
        if goto == None:
            while True:
                WORDTYPE = VMEM_H(J);
                if WORDTYPE < 0 or WORDTYPE > 3:  # DO
                    ERRORS(d.CLASS_BI, 217);
                    goto = "DONE";
                    break
                # END
                if LENGTH(g.S[K]) > g.LINELENGTH:
                    if K >= g.MAXLINES:  # DO
                        FLUSH(K, 1);
                        K = 0;
                    # END
                    else: K = K + 1;
                # DO CASE WORDTYPE;
                if WORDTYPE == 0:
                    # DO
                    PTR_TEMP = VMEM_F(SHR(J + 2, 1));
                    if PTR_TEMP > 0:  # DO
                        ''' GET VARIABLE USED TO INITIAL NAME VARIABLE.
                        NOTE THAT THIS SAME PROCEDURE IS IN PHASE 4 '''
                        FORMAT_VAR_REF_CELL(PTR_TEMP, 1);
                        g.S[K] = g.S[K] + VMEM_H(J + 1) + ':' + MSG + ',';
                    # END
                    else: 
                        g.S[K] = g.S[K] + VMEM_H(J + 1) + ':' + \
                                 g.SYT_NAME(VMEM_H(J + 3)) + ',';
                    J = J + 4;
                    # END
                elif WORDTYPE == 1:
                    # DO
                    g.S[K] = g.S[K] + '(' + VMEM_H(J + 2) + '#,+' + \
                             VMEM_H(J + 3) + ')(';
                    J = J + 4;
                    # END
                elif WORDTYPE == 2:
                    # DO
                    if BYTE(g.S[K], LENGTH(g.S[K]) - 1) == BYTE(','):
                        g.S[K] = SUBSTR(g.S[K], 0, LENGTH(g.S[K]) - 1);
                    g.S[K] = g.S[K] + '),';
                    J = J + 2;
                    # END
                elif WORDTYPE == 3:
                    if VMEM_H(J + 1) == 0: 
                        goto = "DONE";
                        break
                    else:  # DO
                        LOCATE(VMEM_F(SHR(J + 2, 1)), ADDR(VMEM_F), 0);
                        #COREWORD(ADDR(VMEM_H)) = VMEM_LOC_ADDR;
                        J = 2;
                    # END
                # END DO CASE
            # END
        if goto == "DONE": goto = None
        if goto == None:
            if BYTE(g.S[K], LENGTH(g.S[K]) - 1) == BYTE(','):
                g.S[K] = SUBSTR(g.S[K], 0, LENGTH(g.S[K]) - 1);
            FLUSH(K, 1);
        if goto == "DONETOO": goto = None
    # END
# END FORMAT_NAME_TERM_CELLS;
