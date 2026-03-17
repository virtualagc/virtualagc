#!/usr/bin/env python3
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   INTERPRE.py
   Purpose:    This is a part of the HAL_S_FC.py compiler program.
   Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
   Language:   XPL.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2026-03-12  RSB  Used indentXPL.py to convert from INTERPRE.xpl
"""

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
import HALINCL.COMMON as h
from ERROR import ERROR
from HASH import HASH
from OUTPUTWR import OUTPUT_WRITER

#*************************************************************************
# PROCEDURE NAME:  INTERPRET_ACCESS_FILE
# MEMBER NAME:     INTERPRE
# LOCAL DECLARATIONS:
#          A_TOKEN           CHARACTER;
#          ACCESS_ERROR(1483)  LABEL
#          ACCESS_OFF        FIXED
#          ADVANCE_CP        LABEL
#          BLOCK_END         BIT(16)
#          BLOCK_NAME        CHARACTER;
#          BLOCK_START       BIT(16)
#          CP                BIT(16)
#          END_FILE_EXIT     LABEL
#          I                 BIT(16)
#          LOOKUP            LABEL
#          NEXT_TOKEN        LABEL
#          RECOVER_WITHOUT_MSG(1516)  LABEL
#          RECOVERY_POINT(3) LABEL
#          RESET_ACCESS_FLAG LABEL
#          RESTART           LABEL
#          S                 CHARACTER;
#          SYNTAX_ERROR      LABEL
# EXTERNAL VARIABLES REFERENCED:
#          ACCESS_FLAG
#          ACCESS_FOUND
#          CLASS_PA
#          COMPOOL_LABEL
#          ENDSCOPE_FLAG
#          FALSE
#          FOREVER
#          FUNC_CLASS
#          LINK_SORT
#          PROC_LABEL
#          PROG_LABEL
#          PROGRAM_ID
#          READ_ACCESS_FLAG
#          SYM_CLASS
#          SYM_FLAGS
#          SYM_HASHLINK
#          SYM_NAME
#          SYM_TYPE
#          SYT_CLASS
#          SYT_FLAGS
#          SYT_HASHLINK
#          SYT_HASHSIZE
#          SYT_HASHSTART
#          SYT_NAME
#          SYT_TYPE
#          TEXT_LIMIT
#          TRUE
#          X70
#          X8
# EXTERNAL VARIABLES CHANGED:
#          J
#          LETTER_OR_DIGIT
#          NAME_HASH
#          SYM_TAB
# EXTERNAL PROCEDURES CALLED:
#          ERROR
#          HASH
#          OUTPUT_WRITER
# CALLED BY:
#          STREAM
#*************************************************************************
#********                          CALL TREE                      ********
#*************************************************************************
# ==> INTERPRET_ACCESS_FILE <==
#     ==> ERROR
#         ==> PAD
#     ==> HASH
#     ==> OUTPUT_WRITER
#         ==> CHAR_INDEX
#         ==> ERRORS
#             ==> COMMON_ERRORS
#         ==> MIN
#         ==> MAX
#         ==> BLANK
#         ==> LEFT_PAD
#         ==> I_FORMAT
#         ==> CHECK_DOWN
#*************************************************************************
#
# REVISION HISTORY:
#
# DATE     WHO  RLS   DR/CR #  DESCRIPTION
#
# 01/21/91 TKK  23V2  CR11098  DELETE SPILL CODE FROM COMPILER
#
# 04/26/01 DCP  31V0  CR13335  ALLEVIATE SOME DATA SPACE PROBLEMS
#               16V0           IN HAL/S COMPILER
#*************************************************************************

class cINTERPRET_ACCESS_FILE:
    def __init__(self):
        
        # For `INTERPRET_ACCESS_FILE` itself.
        #DECLARE END_FILE_EXIT LABEL;
        self.CP = 0
        self.BLOCK_START = 0
        self.BLOCK_END = 0
        self.BLOCK_NAME = ""
        self.A_TOKEN = 0
        self.ACCESS_OFF = 0
        self.NAME = ''
        self.goto = None
        
        # For `ACCESS_ERROR`
        self.MSG_ISSUED = 0
        
        # For `ADVANCE_CP`
        self.EOF_FLAG = 0
        
        # For `NEXT_TOKEN1
        self.DELIMETERS = (0x00, 0x4D, 0x5D, 0x6B);

l = cINTERPRET_ACCESS_FILE()

def INTERPRET_ACCESS_FILE():

    def ACCESS_ERROR(MSG_NUM, NAME=l.NAME):
        l.NAME = NAME
        ACCESS_MSG = (
        '**SYNTAX ERROR ON THE FOLLOWING PROGRAM ACCESS FILE RECORD:',
        ' APPEARS ON THE PROGRAM ACCESS FILE BUT IS NOT DEFINED IN THIS COMPILATION',
        ' IS IN A "$BLOCK" LIST BUT IS NOT A COMPOOL, PROGRAM, PROCEDURE, OR FUNCTION',
        ' APPEARS ON THE PROGRAM ACCESS FILE BUT IS NOT CURRENTLY ACCESS PROTECTED',
        ' IS NOT DEFINED WITHIN THE COMPOOL SPECIFIED ON THE PROGRAM ACCESS FILE',
        ' IS USED AS A COMPOOL BLOCK NAME ON THE PROGRAM ACCESS FILE BUT IS NOT A COMPOOL LABEL',
        ' IS A COMPOOL BLOCK NAME WHICH MUST APPEAR IN A $BLOCK LIST BEFORE ITS CONTENTS CAN BE USED');
        
        if not l.MSG_ISSUED: #DO
            l.MSG_ISSUED = g.TRUE;
            ERROR(d.CLASS_PA, 2, g.PROGRAM_ID);
            OUTPUT_WRITER();
            # PUT THE MSG OUT
        #END
        if MSG_NUM == 0: #DO
            # SPECIAL SYNTAX ERROR MSG
            g.OUTPUT = g.X8 + ACCESS_MSG;
            g.OUTPUT = g.S;
        #END
        else: g.OUTPUT = g.X8 + NAME + ACCESS_MSG[MSG_NUM];
    # END ACCESS_ERROR;

    def RESET_ACCESS_FLAG():
        g.J = g.SYT_FLAGS(g.I);
        if (g.J & g.ACCESS_FLAG) != 0:
            g.SYT_FLAGS(g.I, g.J & l.ACCESS_OFF);
        else: ACCESS_ERROR(3, l.A_TOKEN);
    # END RESET_ACCESS_FLAG;

    def LOOKUP(NAME):
        g.NAME_HASH = HASH(NAME, g.SYT_HASHSIZE);
        g.I = g.SYT_HASHSTART[g.NAME_HASH];
        while g.I > 0:
            if NAME == g.SYT_NAME(g.I):
                return g.I;
            g.I = g.SYT_HASHLINK(g.I);
        #END
        return -1;
    # END LOOKUP;

    def ADVANCE_CP():
        l.CP = l.CP + 1;
        if l.CP > g.TEXT_LIMIT: #DO
            if l.EOF_FLAG: 
                goto = "END_FILE_EXIT";
                return
            l.goto = "READIT"
            while l.goto == "READIT":
                if l.goto == "READIT": l.goto = None
                g.S = INPUT(6);
                if LENGTH(g.S) == 0: #DO
                    g.S = g.X70 + g.X70;
                    # SHOULD BE >= 80
                    l.EOF_FLAG = g.TRUE;
                #END
                if g.BYTE(g.S) == g.BYTE('C'): l.goto = "READIT";
            l.CP = 1;
        #END
    # END ADVANCE_CP;

    def NEXT_TOKEN():
        NUM_DELIMETERS = 3
        while g.BYTE(g.S, l.CP) == g.BYTE(g.X1):
            ADVANCE_CP();
            if l.goto != None:
                return 0
        #END
        l.A_TOKEN = '';
        while g.LETTER_OR_DIGIT[g.BYTE(g.S, l.CP)]:
            l.A_TOKEN=l.A_TOKEN + SUBSTR(g.S,l.CP,1);
            ADVANCE_CP();
            if l.goto != None:
                return 0
        #END
        if LENGTH(l.A_TOKEN) != 0: return 0;
        for g.I  in range(1, NUM_DELIMETERS + 1):
            if g.BYTE(g.S,l.CP)==l.DELIMETERS[g.I]: #DO
                ADVANCE_CP();
                if l.goto != None:
                    return 0
                return g.I;
            #END
        #END
        ADVANCE_CP();
        if l.goto != None:
            return 0
        return NUM_DELIMETERS + 1;
        # UNKNOWN DELIMETER
    # END NEXT_TOKEN;
    
    if (g.ACCESS_FOUND & 1) != 0: return;
    # NO ACCESS FLAGS PRESENT
    if MONITOR(2, 6, g.PROGRAM_ID): #DO
        ERROR(d.CLASS_PA, 1, g.PROGRAM_ID);
        return;
    #END
    l.ACCESS_OFF = not g.ACCESS_FLAG;
    g.LETTER_OR_DIGIT[g.BYTE('$')] = g.TRUE;
    # FOR THIS PROC ONLY
    l.CP = g.TEXT_LIMIT;
    l.goto = "firstTime"
    ADVANCE_CP();
    while l.goto not in [None, "END_FILE_EXIT"]:
        if l.goto == "firstTime":
            l.goto = None
        # GET IT ALL STARTED
        if l.goto == "RESTART": l.goto = None
        if l.goto == None: g.I = NEXT_TOKEN();
        if l.goto == None:
            if g.I != 0: 
                l.goto = "SYNTAX_ERROR";
                continue
            l.BLOCK_NAME = l.A_TOKEN;
            if NEXT_TOKEN() != 1: 
                l.goto = "SYNTAX_ERROR";
                continue
        if l.goto =="RECOVERY_POINT": l.goto = None
        if l.goto == None:
            if l.BLOCK_NAME == '$BLOCK':
                while True:
                    if NEXT_TOKEN() != 0: 
                        l.goto = "SYNTAX_ERROR";
                        break
                    g.I = LOOKUP(l.A_TOKEN);
                    if g.I < 0: ACCESS_ERROR(1, l.A_TOKEN);
                    else: #DO
                        if (g.SYT_TYPE(g.I) == g.PROC_LABEL) or \
                               (g.SYT_TYPE(g.I) == g.PROG_LABEL) or \
                               (g.SYT_CLASS(g.I) == g.FUNC_CLASS):
                            RESET_ACCESS_FLAG();
                        elif g.SYT_TYPE(g.I) == g.COMPOOL_LABEL: #DO
                            g.J = not g.READ_ACCESS_FLAG;
                            RESET_ACCESS_FLAG();
                            while (g.SYT_FLAGS(g.I) & g.ENDSCOPE_FLAG) == 0:
                                g.I = g.I + 1;
                                g.SYT_FLAGS(g.I, g.SYT_FLAGS(g.I) & g.J);
                            #END
                        #END
                        else: ACCESS_ERROR(2, l.A_TOKEN);
                    #END
                    g.I = NEXT_TOKEN();
                    if l.goto != None:
                        break
                    if g.I == 2: 
                        l.goto = "RESTART";
                        break
                    # CLOSE PAREN
                    if g.I != 3: 
                        l.goto = "SYNTAX_ERROR";
                        break
            #END
            else: #DO
                # A COMPOOL NAME
                l.BLOCK_START = LOOKUP(l.BLOCK_NAME);
                if l.BLOCK_START < 0: #DO
                    ACCESS_ERROR(1, l.BLOCK_NAME);
                    l.goto = "RECOVER_WITHOUT_MSG";
                    continue
                #END
                if g.SYT_TYPE(l.BLOCK_START) != g.COMPOOL_LABEL: #DO
                    ACCESS_ERROR(5, l.BLOCK_NAME);
                    l.goto = "RECOVER_WITHOUT_MSG";
                    continue
                #END
                if (g.SYT_FLAGS(l.BLOCK_START) & g.ACCESS_FLAG) != 0: #DO
                    ACCESS_ERROR(6, l.BLOCK_NAME);
                    l.goto = "RECOVER_WITHOUT_MSG";
                    continue
                #END
                l.BLOCK_END = l.BLOCK_START;
                while (g.SYT_FLAGS(l.BLOCK_END) & g.ENDSCOPE_FLAG) == 0:
                    l.BLOCK_END = l.BLOCK_END + 1;
                #END
                while True:
                    if NEXT_TOKEN != 0: 
                        l.goto = "SYNTAX_ERROR";
                        break
                    if l.A_TOKEN == '$ALL': #DO
                        for g.I  in range(l.BLOCK_START, l.BLOCK_END + 1):
                            g.SYT_FLAGS(g.I, g.SYT_FLAGS(g.I) & l.ACCESS_OFF);
                        #END
                        if NEXT_TOKEN != 2: 
                            l.goto = "SYNTAX_ERROR";
                            break
                        l.goto = "RESTART";
                        break
                    #END
                    g.I = LOOKUP(l.A_TOKEN);
                    if g.I < 0: ACCESS_ERROR(1, l.A_TOKEN);
                    else: #DO
                        if (g.I > l.BLOCK_END) | (g.I < l.BLOCK_START):
                            ACCESS_ERROR(4, l.A_TOKEN);
                        else: 
                            RESET_ACCESS_FLAG();
                    #END
                    g.I = NEXT_TOKEN();
                    if l.goto != None:
                        break
                    if g.I == 2: 
                        l.goto = "RESTART";
                        break
                    if g.I != 3: 
                        l.goto = "SYNTAX_ERROR";
                        break
                #END
        #END
        if l.goto == "SYNTAX_ERROR": l.goto = None
        if l.goto == None: ACCESS_ERROR(0);
        if l.goto == None: g.I = NEXT_TOKEN();
        if l.goto == None: l.BLOCK_NAME = l.A_TOKEN;
        if l.goto == "RECOVER_WITHOUT_MSG": l.goto = None
        while l.goto == None and NEXT_TOKEN() != 1:
            if l.goto != None:
                continue
            l.BLOCK_NAME = l.A_TOKEN;
        #END
        if l.goto == None: 
            l.goto = "RECOVERY_POINT";
            continue
    if l.goto == "END_FILE_EXIT": l.goto = None
    g.LETTER_OR_DIGIT[g.BYTE('$')] = g.FALSE;
    # RESTORE
    return;
# END INTERPRET_ACCESS_FILE;
