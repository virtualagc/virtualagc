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
import HALINCL.DWNTABLE as t

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


class cDOWNGRADE_SUMMARY:  # Local variables for the procedure.

    def __init__(self):
        self.I = 0
        self.COUNT = 0
        self.DOWN_COUNT = 0
        self.TEMP_CLS = ''
        self.TEMP1 = ''
        self.TEMP2 = ''
        self.TEMP3 = ''
        self.END_OF_LIST = 0
        self.SEARCH_FOR_CLS = 0


lDOWNGRADE_SUMMARY = cDOWNGRADE_SUMMARY()


def DOWNGRADE_SUMMARY():
    l = lDOWNGRADE_SUMMARY
    
    l.END_OF_LIST = 0;
    h.NOT_DOWNGRADED = 0;
    #  PRINT TITLE FOR DOWNGRADE SUMMARY
    l.DOWN_COUNT = 1;
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
        while l.END_OF_LIST == 0 and l.DOWN_COUNT <= len(h.DOWN_INFO):
            if g.DWN_ERR(l.DOWN_COUNT) > ' ':
                if g.DWN_VER(l.DOWN_COUNT) == '1':
                    l.SEARCH_FOR_CLS = 1;
                    l.COUNT = 0;
                    while l.SEARCH_FOR_CLS == 1:
                        if g.DWN_CLS(l.DOWN_COUNT) == t.ERR_VALUE[l.COUNT]:
                            l.TEMP_CLS = SUBSTR(t.ERROR_INDEX[l.COUNT], 6, 2);
                            l.SEARCH_FOR_CLS = 0;
                        else:
                            l.COUNT = l.COUNT + 1;
                    l.TEMP1 = SUBSTR(l.TEMP_CLS, 0, 1);
                    l.TEMP2 = SUBSTR(l.TEMP_CLS, 1, 1);
                    if l.TEMP2 == ' ':
                        l.TEMP3 = l.TEMP1 + g.DWN_ERR(l.DOWN_COUNT);
                    else:
                        l.TEMP3 = l.TEMP_CLS + g.DWN_ERR(l.DOWN_COUNT);
                    OUTPUT(0, '*** ERROR NUMBER ' + l.TEMP3 + ' AT STATEMENT NUMBER '\
                              +g.DWN_STMT(l.DOWN_COUNT) + ' ***');
                    OUTPUT(0, '*** WAS DOWNGRADED FROM A SEVERITY ONE ERROR TO'\
                              +' A SEVERITY ZERO ERROR MESSAGE ***');
                    OUTPUT(0, '  ');
                    OUTPUT(0, '  ');
                    # SUCCESSFUL DOWNGRADE
                else:
                    # SET NOT_DOWNGRADED TO INDICATE THAT THERE WAS AT
                    # LEAST ONE DOWNGRADE NOT USED.
                    h.NOT_DOWNGRADED = 1;
            else:
                l.END_OF_LIST = 1;
            l.DOWN_COUNT = l.DOWN_COUNT + 1;
        #  CHECK FOR ATTEMPTED DOWNGRADES THAT WERE NOT ERRORS
        
        if h.NOT_DOWNGRADED:
            OUTPUT(0, '  ');
            OUTPUT(0, '  ');
            OUTPUT(0, '*****  DOWNGRADE DIRECTIVES THAT WERE NOT DOWNGRADED *****');
            OUTPUT(0, '  ');
            OUTPUT(0, '  ');
            for l.I in range(1, len(h.DOWN_INFO) + 1):
                if g.DWN_VER(l.I) != '1':
                    l.DOWN_COUNT = l.I;
                    l.SEARCH_FOR_CLS = 1;
                    l.COUNT = 0;
                    # IF DWN_UNKN(I) IS SET, A BI107 ERROR HAS OCCURED AND DWN_CLS(I) IS
                    # EMPTY; DWN_UNKN(I) CONTAINS THE UNKNOWN ERROR. MOVE IT TO TEMP3
                    # AND GO PRINT THE ERROR MESSAGE. DO *NOT* ATTEMPT TO EXTRACT THE
                    # ERROR MESSAGE FROM THE DOWNGRADE TABLE (THIS CAUSED THE 0C4 ABEND).
                    if g.DWN_UNKN(l.I) != '':
                        l.TEMP3 = g.DWN_UNKN(l.I);
                    else:
                        while l.SEARCH_FOR_CLS == 1:
                            if g.DWN_CLS(l.DOWN_COUNT) == t.ERR_VALUE[l.COUNT]:
                                l.TEMP_CLS = SUBSTR(t.ERROR_INDEX[l.COUNT], 6, 2);
                                l.SEARCH_FOR_CLS = 0;
                            else:
                                l.COUNT = l.COUNT + 1;
                        l.TEMP1 = SUBSTR(l.TEMP_CLS, 0, 1);
                        l.TEMP2 = SUBSTR(l.TEMP_CLS, 1, 1);
                        if l.TEMP2 == ' ':
                            l.TEMP3 = l.TEMP1 + g.DWN_ERR(l.DOWN_COUNT);
                        else:
                            l.TEMP3 = l.TEMP_CLS + g.DWN_ERR(l.DOWN_COUNT);
                    OUTPUT(0, '*** ERROR NUMBER ' + l.TEMP3 + \
                             ' FOR STATEMENT NUMBER ' + g.DWN_STMT(l.DOWN_COUNT) + \
                             ' WAS NOT DOWNGRADED, REMOVE DOWNGRADE' + \
                             ' DIRECTIVE AND RECOMPILE *** ');
                    OUTPUT(0, '  ');
        
