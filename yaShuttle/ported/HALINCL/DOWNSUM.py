#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   DOWNSUM.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-08-31 RSB  Created a stub.
'''

from xplBuiltins import *
import g
import HALINCL.COMMON as h
import HALINCL.DWNTABLE as d

'''
/***********************************************************/
/*                                                         */
/*  FUNCTION:                                              */
/*  ROUTINE TO SUMMARIZE DOWNGRADE ATTEMPTS AND RESULTS    */
/*                                                         */
/*  INCLUDED BY: PASS1, PASS2, AUX, FLO, OPT               */
/*                                                         */
/***********************************************************/
'''

def DOWNGRADE_SUMMARY():
    
    END_OF_LIST = 0;
    h.NOT_DOWNGRADED = 0;
    #  PRINT TITLE FOR DOWNGRADE SUMMARY
    DOWN_COUNT = 1;
    #  DETERMINE IF THERE ARE ANY DOWNGRADED MESSAGES
    if len(h.DOWN_INFO) >= 1:
        #  THERE ARE ATTEMPTS AT DOWNGRADE
        OUTPUT(0, ' ');
        OUTPUT(0, ' ');
        OUTPUT(0, ' ');
        OUTPUT(0, ' **********  DOWNGRADE SUMMARY   *********************');
        OUTPUT(0, ' ');
        OUTPUT(0, ' ');
        #  TRAVERSE THROUGH DOWNGRADE LIST LOOKING FOR DOWNGRADED ERRORS
        #  CHANGED HARDCODED 10 TO RECORD_TOP(DOWN_INFO) FOR CR11088
        while END_OF_LIST == 0 and DOWN_COUNT <= len(h.DOWN_INFO):
            if DWN_ERR[DOWN_COUNT] > ' ':
                if DWN_VER[DOWN_COUNT] == 1:
                    SEARCH_FOR_CLS = 1;
                    COUNT = 0;
                    while SEARCH_FOR_CLS == 1:
                        if DWN_CLS[DOWN_COUNT] == d.ERR_VALUE[COUNT]:
                            TEMP_CLS = SUBSTR(d.ERROR_INDEX[COUNT],6,2);
                            SEARCH_FOR_CLS = 0;
                        else:
                            COUNT = COUNT + 1;
                    TEMP1 = SUBSTR(TEMP_CLS,0,1);
                    TEMP2 = SUBSTR(TEMP_CLS,1,1);
                    if TEMP2 == ' ':
                        TEMP3 = TEMP1 + DWN_ERR[DOWN_COUNT];
                    else:
                        TEMP3 = TEMP_CLS + DWN_ERR[DOWN_COUNT];
                    OUTPUT(0, '*** ERROR NUMBER '+TEMP3+' AT STATEMENT NUMBER '\
                              + DWN_STMT(DOWN_COUNT) + ' ***');
                    OUTPUT(0, '*** WAS DOWNGRADED FROM A SEVERITY ONE ERROR TO'\
                              + ' A SEVERITY ZERO ERROR MESSAGE ***');
                    OUTPUT(0, '  ');
                    OUTPUT(0, '  ');
                    #SUCCESSFUL DOWNGRADE
                else:
                    # SET NOT_DOWNGRADED TO INDICATE THAT THERE WAS AT
                    # LEAST ONE DOWNGRADE NOT USED.
                    h.NOT_DOWNGRADED = 1;
            else:
                END_OF_LIST = 1;
            DOWN_COUNT = DOWN_COUNT + 1;
        #  CHECK FOR ATTEMPTED DOWNGRADES THAT WERE NOT ERRORS
        
        if h.NOT_DOWNGRADED:
            OUTPUT(0, '  ');
            OUTPUT(0, '  ');
            OUTPUT(0, '*****  DOWNGRADE DIRECTIVES THAT WERE NOT DOWNGRADED *****');
            OUTPUT(0, '  ');
            OUTPUT(0, '  ');
            for I in range(1, len(h.DOWN_INFO)+1):
                if DWN_VER[I] != 1:
                    DOWN_COUNT = I;
                    SEARCH_FOR_CLS = 1;
                    COUNT = 0;
                    # IF DWN_UNKN(I) IS SET, A BI107 ERROR HAS OCCURED AND DWN_CLS(I) IS
                    # EMPTY; DWN_UNKN(I) CONTAINS THE UNKNOWN ERROR. MOVE IT TO TEMP3
                    # AND GO PRINT THE ERROR MESSAGE. DO *NOT* ATTEMPT TO EXTRACT THE
                    # ERROR MESSAGE FROM THE DOWNGRADE TABLE (THIS CAUSED THE 0C4 ABEND).
                    if DWN_UNKN[I] != '':
                        TEMP3 = DWN_UNKN[I];
                    else:
                        while SEARCH_FOR_CLS == 1:
                            if DWN_CLS[DOWN_COUNT] == d.ERR_VALUE[COUNT]:
                                TEMP_CLS = SUBSTR(d.ERROR_INDEX[COUNT],6,2);
                                SEARCH_FOR_CLS = 0;
                            else:
                                COUNT = COUNT + 1;
                        TEMP1 = SUBSTR(TEMP_CLS,0,1);
                        TEMP2 = SUBSTR(TEMP_CLS,1,1);
                        if TEMP2 == ' ':
                            TEMP3 = TEMP1 + DWN_ERR[DOWN_COUNT];
                        else:
                            TEMP3 = TEMP_CLS + DWN_ERR[DOWN_COUNT];
                    OUTPUT(0, '*** ERROR NUMBER ' + TEMP3 + \
                             ' FOR STATEMENT NUMBER ' + DWN_STMT[DOWN_COUNT] + \
                             ' WAS NOT DOWNGRADED, REMOVE DOWNGRADE' + \
                             ' DIRECTIVE AND RECOMPILE *** ');
                    OUTPUT(0, '  ');
        
