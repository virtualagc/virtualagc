#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   DTOKEN.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-26 RSB  Ported
            2024-06-20 RSB  Stuff related to `D DOWNGRADE`
'''

from xplBuiltins import *
import g
import HALINCL.COMMON as h
import HALINCL.DWNTABLE as t
from PAD import PAD
from HALINCL.SPACELIB import RECORD_TOP

'''
/************************************************************/
/*                                                          */
/*  FUNCTION:                                               */
/*  ERROR ROUTINE TO DETERMINE DOWNGRADES FOR SYNTAX ERRORS */
/*                                                          */
/*  INCLUDED BY: PASS1                                      */
/*                                                          */
/************************************************************/
'''

# I haven't bothered to try and figure which (if any) local variables need
# to be persistent, so I've just made them all so.  Probably none of them
# need it.


class cCHECK_DOWN:

    def __init__(self):
        self.K = 0
        self.IMBED = 0
        self.C = ''
        self.S = ''
        self.CLS_COMPARE = ''
        self.TMP_CLS = ''
        self.TEMP_STMT = ''
        self.TEMP1 = ''
        self.TEMP2 = ''
        self.TEMP3 = ''
        self.TEMP4 = ''
        self.AST = '***** '
        self.COUNT = 0
        self.DOWN_COUNT = 0
        self.FOUND = 0
        self.TFOUND = 0


lCHECK_DOWN = cCHECK_DOWN()


def CHECK_DOWN(ERRORCODE, SEVERITY):
    l = lCHECK_DOWN
    
    l.FOUND = 0;
    l.DOWN_COUNT = RECORD_TOP(h.DOWN_INFO);
    # FOR 'INCLUDE TEMPLATE' AND 'INCLUDE SDF' USE SAVED STMT NUM
    if g.INCLUDE_STMT != -1: 
        l.TEMP_STMT = g.INCLUDE_STMT;
        g.SAVE_LINE_p[g.ERROR_COUNT] = g.INCLUDE_STMT;
    else:
        l.TEMP_STMT = g.STMT_NUM();
        if g.DWN_VER(l.DOWN_COUNT) == '1': 
            l.DOWN_COUNT = 0;
    #  DETERMINE IF THERE IS A DOWNGRADE FOR THIS STMT.
    #  CHANGE HARDCODED 10 TO RECORD_TOP(DOWN_INFO)
    while l.FOUND == 0 and l.DOWN_COUNT > 0:
        if l.TEMP_STMT == g.DWN_STMT(l.DOWN_COUNT):
            l.TFOUND = 0;
            l.COUNT = 0;
            while l.TFOUND == 0 and l.COUNT < t.NUM_ERR:
                if g.DWN_CLS(l.DOWN_COUNT) == t.ERR_VALUE(l.COUNT): 
                    l.TMP_CLS = SUBSTR(t.ERROR_INDEX(l.COUNT), 6, 2);
                    l.TFOUND = 1;
                else:
                    l.COUNT = l.COUNT + 1;
            l.TEMP1 = SUBSTR(l.TMP_CLS, 0, 1);
            l.TEMP2 = SUBSTR(l.TMP_CLS, 1, 1);
            if l.TEMP2 == ' ':
                l.CLS_COMPARE = l.TEMP1 + g.DWN_ERR(l.DOWN_COUNT);
            else:
                l.CLS_COMPARE = l.TMP_CLS + g.DWN_ERR(l.DOWN_COUNT);
            l.TEMP3 = PAD(ERRORCODE, 10);
            l.TEMP4 = PAD(l.CLS_COMPARE, 10);
            if l.TEMP3 == l.TEMP4:
                if SEVERITY == 1:
                    SEVERITY = 0;
                    OUTPUT(0, l.AST + \
                            ' THE FOLLOWING ERROR WAS DOWNGRADED FROM A ' + \
                            'SEVERITY ONE ERROR TO A SEVERITY ZERO ERROR ' + \
                            l.AST);
                    l.FOUND = 1;
                    # NOTE THAT THE ERROR WAS DOWNGRADED SUCCESSFULLY
                    g.DWN_VER(l.DOWN_COUNT, '1');
                else:
                    OUTPUT(0, l.AST + \
                            ' AN ATTEMPT WAS MADE TO DOWNGRADE AN ' + \
                            'ERROR OTHER THAN A SEVERITY ONE ERROR ' + \
                            'REMOVE DOWNGRADE DIRECTIVE AND RECOMPILE ' + \
                            l.AST);
                    SEVERITY = 2;
                    l.FOUND = 1;
        else:
            ''' DOWN_COUNT FROM HERE ON POINTS TO THE PREVIOUS
                STATEMENT. THE STATEMENT DOES NOT HAVE A DOWNGRADE
                DIRECTIVE FOR THE PROCESSING ERROR.      '''
            l.FOUND = 1;
        l.DOWN_COUNT = l.DOWN_COUNT - 1;
    # END DO WHILE
    return SEVERITY;
    
