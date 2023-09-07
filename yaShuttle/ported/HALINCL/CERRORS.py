#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   CERRORS.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-08-29 RSB  Ported
'''

import sys
from g import SUBSTR, BYTE, MONITOR, INPUT, DWN_STMT, DWN_ERR, DWN_CLS, \
                DWN_VER, TRUE, FALSE, PAD, OUTPUT, LENGTH
from CHARINDE import CHAR_INDEX
from HALINCL.COMMON import DOWN_INFO, SEVERITY_ONE
from HALINCL.CERRDECL import ERROR_CLASSES, CLASS_BX

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

def COMMON_ERRORS(CLASS, NUM, TEXT, ERRORp, STMTp):
    global SEVERITY_ONE
    ERRORFILE = 5;
    AST = '***** ';
   
    FOUND = 0;
    NUMIT = NUM;
    TEMP_STMT = STMTp;
    DOWN_COUNT = 1;
    while True:
        C=SUBSTR(ERROR_CLASSES,(CLASS-1)<<1,2);
        if BYTE(C,1)==BYTE(' '):
            C=SUBSTR(C,0,1);
        C=PAD(C+str(NUM),8);
        if MONITOR(2,5,C):
           CLASS=CLASS_BX;
           NUM=113;
           TEXT = C;
        else:
            break
    CLS_COMPARE = CLASS;
    S = INPUT(ERRORFILE);
    SEVERITY = BYTE(S) - BYTE('0');
    #  DETERMINE IF THERE IS A DOWNGRADE FOR THIS STMT  
    while FOUND == 0  and DOWN_COUNT <= len(DOWN_INFO) - 1:
        if NUMIT == DWN_ERR(DOWN_COUNT) and CLS_COMPARE == DWN_CLS(DOWN_COUNT):
            if TEMP_STMT == DWN_STMT(DOWN_COUNT):
                if SEVERITY == 1:
                    SEVERITY = 0;
                    OUTPUT(0, AST + ' THE FOLLOWING ERROR WAS DOWNGRADED FROM A '+\
                             'SEVERITY ONE ERROR TO A SEVERITY ZERO ERROR '+AST);
                    FOUND = 1;
                    # NOTE THAT THE ERROR WAS DOWNGRADED SUCCESSFULLY  
                    DWN_VER(DOWN_COUNT, 1);
            else:
                OUTPUT(0, AST + ' AN ATTEMPT WAS MADE TO DOWNGRADE AN ' +
                           'ERROR OTHER THAN A SEVERITY ONE ERROR ' +
                           'REMOVE DOWNGRADE DIRECTIVE AND RECOMPILE ' + AST);
                SEVERITY = 2;
                FOUND = 1;
        DOWN_COUNT = DOWN_COUNT + 1;
    OUTPUT(1, '0' + AST + C + ' ERROR #' + str(ERRORp) + ' OF SEVERITY ' + \
                  str(SEVERITY) + ' OCCURRED ' + AST );
    OUTPUT(0, AST + ' DURING CONVERSION OF HAL/S STATEMENT ' +
                str(STMTp()) + '.' + AST);
    S = INPUT(ERRORFILE);
    if LENGTH(TEXT) > 0:
        IMBED=TRUE;
    while LENGTH(S)>0:
        if IMBED:
            K = CHAR_INDEX(S,'??');
            if K >= 0:
                if K == 0:
                    S = TEXT + SUBSTR(S,2);
                else:
                    S = SUBSTR(S,0,K) + TEXT + SUBSTR(S,K+2);
                IMBED = FALSE;
        OUTPUT(0, AST + S);
        S = INPUT(ERRORFILE);
    TEXT = '';
    # CR12416: TREAT SEVERITY 1 ERRORS AS WARNINGS 
    if SEVERITY == 1: 
        SEVERITY_ONE = TRUE;
        SEVERITY = 0;
    return SEVERITY;
    
