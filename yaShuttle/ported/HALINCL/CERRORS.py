#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   CERRORS.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-08-29 RSB  Ported
            2024-06-20 RSB  Stuff related to `D DOWNGRADE`
'''

from xplBuiltins import *
import g
import HALINCL.COMMON as h
import HALINCL.CERRDECL as d
from HALINCL.COMROUT import CHAR_INDEX, PAD

'''
#*********************************************************
#                                                         
#  FUNCTION:                                              
#  ERROR ROUTINE FOR COMMON ERROR HANDLING FUNCTIONS      
#                                                         
#  INCLUDED BY: PASS1, PASS2, AUX, FLO, OPT               
#                                                         
#*********************************************************
'''


class cCOMMON_ERRORS:

    def __init__(self):
        self.ERRORFILE = 5;
        self.SEVERITY = 0;
        self.K = 0;
        self.IMBED = 0;
        self.C = '';
        self.S = '';
        self.CLS_COMPARE = ''
        self.NUMIT = ''
        self.TEMP_STMT = ''
        self.AST = '***** ';
        self.DOWN_COUNT = 0
        self.FOUND = 0;


lCOMMON_ERRORS = cCOMMON_ERRORS()


def COMMON_ERRORS(CLASS, NUM, TEXT, ERRORp, STMTp):
    l = lCOMMON_ERRORS
    
    l.FOUND = 0;
    l.NUMIT = NUM;
    l.TEMP_STMT = STMTp;
    l.DOWN_COUNT = 1;
    while True:
        l.C = SUBSTR(d.ERROR_CLASSES, (CLASS - 1) << 1, 2);
        if BYTE(l.C, 1) == BYTE(' '):
            l.C = SUBSTR(l.C, 0, 1);
        l.C = PAD(l.C + str(NUM), 8);
        if MONITOR(2, 5, l.C):
           CLASS = d.CLASS_BX;
           NUM = 113;
           TEXT = l.C;
        else:
            break
    l.CLS_COMPARE = CLASS;
    l.S = INPUT(l.ERRORFILE);
    l.SEVERITY = BYTE(l.S) - BYTE('0');
    #  DETERMINE IF THERE IS A DOWNGRADE FOR THIS STMT  
    while l.FOUND == 0  and l.DOWN_COUNT <= len(h.DOWN_INFO) - 1:
        if l.NUMIT == g.DWN_ERR(l.DOWN_COUNT) and l.CLS_COMPARE == g.DWN_CLS(l.DOWN_COUNT):
            if l.TEMP_STMT == g.DWN_STMT(l.DOWN_COUNT):
                if l.SEVERITY == 1:
                    l.SEVERITY = 0;
                    OUTPUT(0, l.AST + ' THE FOLLOWING ERROR WAS DOWNGRADED FROM A ' + \
                             'SEVERITY ONE ERROR TO A SEVERITY ZERO ERROR ' + l.AST);
                    l.FOUND = 1;
                    # NOTE THAT THE ERROR WAS DOWNGRADED SUCCESSFULLY  
                    g.DWN_VER(l.DOWN_COUNT, '1');
            else:
                OUTPUT(0, l.AST + ' AN ATTEMPT WAS MADE TO DOWNGRADE AN ' + 
                           'ERROR OTHER THAN A SEVERITY ONE ERROR ' + 
                           'REMOVE DOWNGRADE DIRECTIVE AND RECOMPILE ' + l.AST);
                l.SEVERITY = 2;
                l.FOUND = 1;
        l.DOWN_COUNT = l.DOWN_COUNT + 1;
    OUTPUT(1, '0' + l.AST + l.C + ' ERROR #' + str(ERRORp) + ' OF SEVERITY ' + \
                  str(l.SEVERITY) + ' OCCURRED ' + l.AST);
    OUTPUT(0, l.AST + ' DURING CONVERSION OF HAL/S STATEMENT ' + 
                str(STMTp) + '.' + l.AST);
    l.S = INPUT(l.ERRORFILE);
    if LENGTH(TEXT) > 0:
        l.IMBED = g.TRUE;
    while LENGTH(l.S) > 0:
        if l.IMBED:
            l.K = CHAR_INDEX(l.S, '??');
            if l.K >= 0:
                if l.K == 0:
                    l.S = TEXT + SUBSTR(l.S, 2);
                else:
                    l.S = SUBSTR(l.S, 0, l.K) + TEXT + SUBSTR(l.S, l.K + 2);
                l.IMBED = g.FALSE;
        OUTPUT(0, l.AST + l.S);
        l.S = INPUT(l.ERRORFILE);
    TEXT = '';
    # TREAT l.SEVERITY 1 ERRORS AS WARNINGS 
    if l.SEVERITY == 1: 
        h.SEVERITY_ONE = g.TRUE;
        l.SEVERITY = 0;
    return l.SEVERITY;
    
