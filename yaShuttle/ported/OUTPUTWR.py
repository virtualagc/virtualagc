#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   OUTPUTWR.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-08-25 RSB  Created place-holder file.
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ERROR import ERROR
from OUTPUT_WRITER_DISASTER import OUTPUT_WRITER_DISASTER
from HALINCL.CHECKDWN import CHECK_DOWN
from HALINCL.COMROUT import CHAR_INDEX

'''
 #*************************************************************************
 # PROCEDURE NAME:  OUTPUT_WRITER
 # MEMBER NAME:     OUTPUTWR
 # INPUT PARAMETERS:
 #          PTR_START         BIT(16)
 #          PTR_END           BIT(16)
 # LOCAL DECLARATIONS:
 #          ATTACH            CHARACTER
 #          BUILD_E           CHARACTER;
 #          BUILD_E_IND(100)  BIT(8)
 #          BUILD_E_UND(100)  BIT(8)
 #          BUILD_M           CHARACTER;
 #          BUILD_S           CHARACTER;
 #          BUILD_S_IND(100)  BIT(8)
 #          BUILD_S_UND(100)  BIT(8)
 #          CHECK_FOR_FUNC    LABEL
 #          COMMENT_LOC       MACRO
 #          CURRENT_ERROR_PTR BIT(16)
 #          DOLLAR_CHECK1     LABEL
 #          DOLLAR_CHECK2     LABEL
 #          E_BEGIN           LABEL
 #          E_CHAR_PTR        BIT(16)
 #          E_CHAR_PTR_MAX    BIT(16)
 #          E_FULL            LABEL
 #          E_LEVEL           BIT(16)
 #          E_LOOP            LABEL
 #          E_PTR             BIT(16)
 #          ERROR_PRINT       LABEL
 #          ERRORCODE         CHARACTER;
 #          ERRORS_PRINTED    BIT(8)
 #          EXP_END(10)       BIT(16)
 #          EXP_START(10)     BIT(16)
 #          EXPAND            LABEL
 #          FIND_ONLY         BIT(8)
 #          FULL_LINE         LABEL
 #          IMBEDDING         BIT(8)
 #          INCLUDE_COUNT     BIT(16)
 #          INCR_EXP_START    LABEL
 #          INCR_SUB_START    LABEL
 #          INDENT_LIMIT      MACRO
 #          LABEL_END         BIT(16)
 #          LABEL_START       BIT(16)
 #          LAST_ERROR_WRITTEN  BIT(16)
 #          LINE_CONTINUED    BIT(8)
 #          LINE_FULL         BIT(8)
 #          LINESIZE          MACRO
 #          M_CHAR_PTR        FIXED
 #          M_CHAR_PTR_MAX    BIT(16)
 #          M_PTR             BIT(16)
 #          M_UNDERSCORE      CHARACTER;
 #          M_UNDERSCORE_NEEDED  BIT(8)
 #          MACRO_WRITTEN     BIT(8)
 #          MATCH             LABEL
 #          MAX_E_LEVEL       BIT(16)
 #          MAX_S_LEVEL       BIT(16)
 #          MORE_E_C          LABEL
 #          MORE_M_C          LABEL
 #          MORE_S_C          LABEL
 #          OUTPUT_WRITER_BEGINNING  LABEL
 #          OUTPUT_WRITER_END LABEL
 #          PRINT_ANY_ERRORS  LABEL
 #          PRINT_TEXT        LABEL
 #          PRNTERRWARN       BIT(8)
 #          PTR               BIT(16)
 #          PTR_LOOP_END      LABEL
 #          RESET             LABEL
 #          S_BEGIN           LABEL
 #          S_CHAR_PTR        BIT(16)
 #          S_CHAR_PTR_MAX    BIT(16)
 #          S_FULL            LABEL
 #          S_LEVEL           BIT(16)
 #          S_LOOP            LABEL
 #          S_PTR             BIT(16)
 #          SAVE_E_C(2)       CHARACTER;
 #          SAVE_MAX_E_LEVEL  BIT(16)
 #          SAVE_MAX_S_LEVEL  BIT(16)
 #          SAVE_S_C(2)       CHARACTER;
 #          SDL_INFO          CHARACTER;
 #          SEVERITY          BIT(16)
 #          SKIP_REPL         LABEL
 #          SPACE_NEEDED      BIT(16)
 #          SUB_END(10)       BIT(16)
 #          SUB_START(10)     BIT(16)
 #          T                 CHARACTER;
 #          TEMP              FIXED
 #          UNDER_LINE        CHARACTER;
 #          UNDERLINING       BIT(8)
 # EXTERNAL VARIABLES REFERENCED:
 #          CHAR_OP
 #          CHARACTER_STRING
 #          CLASS_BI
 #          COMM
 #          CURRENT_SCOPE
 #          DO_LEVEL
 #          DO_STMT#
 #          DOLLAR
 #          DOT_TOKEN
 #          DOUBLE
 #          END_FLAG
 #          ERRLIM
 #          ERROR_PTR
 #          ESCP
 #          EXPONENTIATE
 #          FALSE
 #          FUNC_FLAG
 #          INCLUDE_END
 #          INCLUDING
 #          INLINE_FLAG
 #          LABEL_FLAG
 #          LEFT_BRACE_FLAG
 #          LEFT_BRACKET_FLAG
 #          LEFT_PAREN
 #          LINE_LIM
 #          MAC_NUM
 #          MAC_TXT
 #          MACRO_ARG_FLAG
 #          MACRO_TEXTS
 #          MACRO_TEXT
 #          MAJ_STRUC
 #          NEST_LEVEL
 #          NT
 #          OUTPUT_WRITER_DISASTER
 #          OVER_PUNCH_TYPE
 #          PAD1
 #          PAD2
 #          PAGE
 #          PLUS
 #          PRINT_FLAG
 #          PRINT_FLAG_OFF
 #          RECOVERING
 #          REPLACE_TEXT
 #          RIGHT_BRACE_FLAG
 #          RIGHT_BRACKET_FLAG
 #          RT_PAREN
 #          SAVE_BCD
 #          SAVE_COMMENT
 #          SAVE_ERROR_MESSAGE
 #          SAVE_STACK_DUMP
 #          SCALAR_TYPE
 #          SDL_OPTION
 #          SPACE_FLAGS
 #          SRN
 #          SRN_COUNT
 #          SRN_PRESENT
 #          STMT_END_FLAG
 #          STMT_NUM
 #          STRUC_TOKEN
 #          SYM_ADDR
 #          SYM_TAB
 #          SYT_ADDR
 #          TOKEN_FLAGS
 #          TRANS_OUT
 #          TRUE
 #          TX
 #          VBAR
 #          VOCAB_INDEX
 #          X1
 #          X70
 # EXTERNAL VARIABLES CHANGED:
 #          BCD_PTR
 #          COMPILING
 #          C
 #          COMMENT_COUNT
 #          ELSEIF_PTR
 #          ERROR_COUNT
 #          GRAMMAR_FLAGS
 #          I
 #          INCLUDE_CHAR
 #          INDENT_LEVEL
 #          INFORMATION
 #          INLINE_INDENT
 #          INLINE_INDENT_RESET
 #          J
 #          K
 #          L
 #          LABEL_COUNT
 #          LAST
 #          LAST_SPACE
 #          LAST_WRITE
 #          LINE_MAX
 #          MAX_SEVERITY
 #          NEXT_CC
 #          OUT_PREV_ERROR
 #          PAGE_THROWN
 #          STATEMENT_SEVERITY
 #          S
 #          SAVE_LINE_#
 #          SAVE_SCOPE
 #          SAVE_SEVERITY
 #          SQUEEZING
 #          STACK_DUMP_PTR
 #          STACK_DUMPED
 #          STMT_END_PTR
 #          STMT_PTR
 #          STMT_STACK
 #          TOO_MANY_ERRORS
 # EXTERNAL PROCEDURES CALLED:
 #          BLANK
 #          CHAR_INDEX
 #          CHECK_DOWN
 #          ERRORS
 #          I_FORMAT
 #          LEFT_PAD
 #          MAX
 #          MIN
 # CALLED BY:
 #          INTERPRET_ACCESS_FILE
 #          PRINT_SUMMARY
 #          RECOVER
 #          SAVE_TOKEN
 #          STREAM
 #          SYNTHESIZE
 #*************************************************************************
'''


class cOUTPUT_WRITER:

    def __init__(self):
        self.PTR_START = 0
        self.PTR_END = -1
        self.COMMENT_LOC = 69
        self.LINESIZE = 100
        self.E_PTR = 0
        self.M_PTR = 0
        self.S_PTR = 0
        self.LABEL_START = 0
        self.LABEL_END = 0
        self.PRINT_LABEL = 0
        self.S_LEVEL = 0
        self.E_LEVEL = 0
        self.MAX_S_LEVEL = 0
        self.MAX_E_LEVEL = 0
        self.PTR = 0
        self.SPACE_NEEDED = 0
        self.MAX_LEVEL = 10
        self.SUB_START = [0] * (self.MAX_LEVEL + 1)
        self.SUB_END = [0] * (self.MAX_LEVEL + 1)
        self.EXP_START = [0] * (self.MAX_LEVEL + 1)
        self.EXP_END = [0] * (self.MAX_LEVEL + 1)
        self.LINE_FULL = 0
        self.FIND_ONLY = 0
        self.MACRO_WRITTEN = 0
        self.LINE_CONTINUED = 0
        self.BUILD_S_IND = [0] * (self.LINESIZE + 1)
        self.BUILD_E_IND = [0] * (self.LINESIZE + 1)
        self.BUILD_E_UND = [0] * (self.LINESIZE + 1)
        self.BUILD_S_UND = [0] * (self.LINESIZE + 1)
        self.M_UNDERSCORE_NEEDED = 0
        self.UNDERLINING = 0
        self.M_UNDERSCORE = ' ' * self.LINESIZE
        self.UNDER_LINE = ' ' * self.LINESIZE
        self.BUILD_S = ' ' * self.LINESIZE
        self.BUILD_M = ' ' * self.LINESIZE
        self.BUILD_E = ' ' * self.LINESIZE
        self.S_CHAR_PTR = 0
        self.S_CHAR_PTR_MAX = 0
        self.E_CHAR_PTR = 0
        self.E_CHAR_PTR_MAX = 0
        self.M_CHAR_PTR_MAX = 0
        self.M_CHAR_PTR = 0
        self.SAVE_S_C = [''] * 3
        self.SAVE_E_C = [''] * 3
        self.INDENT_LIMIT = 69
        self.IMBEDDING = 0
        self.PRNTERRWARN = g.TRUE
        self.TEMP = 0
        self.SEVERITY = 0
        self.ERRORCODE = ''
        self.SAVE_MAX_E_LEVEL = 0
        self.SAVE_MAX_S_LEVEL = 0
        self.T = ''
        self.SDL_INFO = ''
        self.INCLUDE_COUNT = 0
        self.LAST_ERROR_WRITTEN = -1
        self.CURRENT_ERROR_PTR = -1
        self.ERRORS_PRINTED = 0
        self.IDX = 0  # TEMPORARY INTEGER
        self.C_RVL = ''
        self.C_TMP = ''  # TEMORARY CHARACTER
        self.LABEL_TOO_LONG = 0
        self.CHAR = ''


lOUTPUT_WRITER = cOUTPUT_WRITER()


class cCOMMENT_BRACKET:

    def __init__(self):
        self.PTR = 0

        
lCOMMENT_BRACKET = cCOMMENT_BRACKET()


class cEXPAND:

    def __init__(self):
        self.C = ''
        self.CHAR = ''
        self.M_COMMENT_NEEDED = 0
        self.S_COMMENT_NEEDED = 0
        self.POST_COMMENT_NEEDED = 0
        self.NUM_S_NEEDED = 0
        self.LOC = 0
        self.NUM = 0
        self.BUILD = ' ' * 100
        self.FORMAT_CHAR = '|'


lEXPAND = cEXPAND()


def OUTPUT_WRITER(PTR_START=None, PTR_END=None):
    # Persistent locals and (optional) parameters:
    l = lOUTPUT_WRITER
    if PTR_START != None:
        l.PTR_START = PTR_START
    if PTR_END != None:
        l.PTR_END = PTR_END
        
    # Workaround junk for spaghetti GO TO's and their target labels.
    goto_OUTPUT_WRITER_BEGINNING = False
    goto_OUTPUT_WRITER_END = False
    goto_PRINT_ANY_ERRORS = False
    goto_AFTER_EXPAND = False
    goto_STLABEL = False
    goto_INCR_SUB_START = False
    goto_FULL_LINE = False
    goto_PTR_LOOP_END = False

    l.ERRORS_PRINTED = g.FALSE;
    if g.STMT_PTR < 0: 
        goto_PRINT_ANY_ERRORS = True
    else:
        goto_OUTPUT_WRITER_BEGINNING = True;  # COLLECT A FEW BRANCHES
    
    def ERROR_PRINT():
        # Locals are C and NEW_SEVERITY.
        
        for I in range(l.LAST_ERROR_WRITTEN + 1, l.CURRENT_ERROR_PTR + 1):
            l.ERRORS_PRINTED = g.TRUE;
            g.ERROR_COUNT = g.ERROR_COUNT + 1;
            g.SAVE_LINE_p[g.ERROR_COUNT] = g.STMT_NUM();
            C = g.SAVE_ERROR_MESSAGE[I];
            l.ERRORCODE = SUBSTR(C, 0, 8);  # MEMBER NAME
            if MONITOR(2, 5, l.ERRORCODE):
                ERRORS (d.CLASS_BI, 100, g.X1 + l.ERRORCODE);
                continue  # GO TO ERROR_PRINT_END;
            S = INPUT(5);  # READ FROM ERROR FILE
            l.SEVERITY = BYTE(S) - BYTE('0');
            NEW_SEVERITY = CHECK_DOWN(l.ERRORCODE, l.SEVERITY);
            l.SEVERITY = NEW_SEVERITY;
            g.SAVE_SEVERITY[g.ERROR_COUNT] = l.SEVERITY;
            if LENGTH(C) > 8:
                # SOME IMBEDDED TEXT EXISTS
                C = SUBSTR(C, 8);
                l.IMBEDDING = g.TRUE;
            if g.ERROR_COUNT >= g.ERRLIM - 3:
                g.MAX_SEVERITY = MAX(g.MAX_SEVERITY, 2);
                if l.PRNTERRWARN:
                    l.PRNTERRWARN = g.FALSE;
                    ERRORS (d.CLASS_BI, 106);
                if g.COMPILING:
                    g.COMPILING = g.FALSE;
                else:
                    OUTPUT_WRITER_DISASTER()
            OUTPUT(1, '0***** ' + str(l.ERRORCODE) + ' ERROR #' + \
                   str(g.ERROR_COUNT) + ' OF SEVERITY ' + str(l.SEVERITY) + \
                   '. *****');
            if l.SEVERITY > g.MAX_SEVERITY:
                g.MAX_SEVERITY = l.SEVERITY;
            if l.SEVERITY > g.STATEMENT_SEVERITY:
                g.STATEMENT_SEVERITY = l.SEVERITY;
            S = INPUT(5);
            while LENGTH(S) > 0:
                if l.IMBEDDING:
                    K = CHAR_INDEX(S, '??');
                    if K >= 0:
                        if K == 0:
                            S = C + SUBSTR(S, 2);
                        else:
                            S = SUBSTR(S, 0, K) + C + SUBSTR(S, K + 2);
                        l.IMBEDDING = g.FALSE;
                OUTPUT(0, g.STARS + g.X1 + S);
                S = INPUT(5);
                # ERROR_PRINT_END:
        # END OF LOOP ON ERROR MSGS
        l.LAST_ERROR_WRITTEN = l.CURRENT_ERROR_PTR;
    
    def ATTACH(PNTR, OFFSET):
        l.CURRENT_ERROR_PTR = MAX(l.CURRENT_ERROR_PTR, ERROR_PTR(PNTR));
        if g.STMT_STACK[PNTR] == 0:
            l.SPACE_NEEDED = 0;
            return '';
        if (g.GRAMMAR_FLAGS[PNTR] & PRINT_FLAG) == 0:
           if  not RECOVERING:
               return '';
        g.GRAMMAR_FLAGS[PNTR] &= PRINT_FLAG_OFF;
        l.SPACE_NEEDED = 1;
        goto_PARAM_MACRO = False
        if l.MACRO_WRITTEN:
            l.MACRO_WRITTEN = g.FALSE;
            if g.LAST_SPACE == 2:
                if SHR(TOKEN_FLAGS(PNTR), 6) == 0:
                    if g.STMT_STACK[PNTR] == LEFT_PAREN:
                        goto_PARAM_MACRO = True;  # LEAVE LAST_SPACE ALONE
            if not goto_PARAM_MACRO:
                g.LAST_SPACE = 0;  # FORCE A SPACE AFTER A NON-PARAM MACRO NAME
        goto_PARAM_MACRO = False
        L = SPACE_FLAGS(g.STMT_STACK[PNTR] + OFFSET);  # SELECT LINE TYPE
        I = SHR(L, 4) + g.LAST_SPACE;
        if I <= 4:
            if I > 1:
                l.SPACE_NEEDED = 0;
        if SHR(TOKEN_FLAGS(PNTR), 5):
            g.LAST_SPACE = 2;
        else:
            g.LAST_SPACE = L & 0x0F;
        if SHR(TOKEN_FLAGS(PNTR), 6) == 0:
            g.C[0] = STRING(VOCAB_INDEX(g.STMT_STACK[PNTR]));
        else:
            J = TOKEN_FLAGS(PNTR);
            g.C[0] = SAVE_BCD(SHR(J, 6));  # IDENTIFIER
            if g.STMT_STACK[PNTR] == CHARACTER_STRING:
                
                def ADD(STRING):
                    # T is local
                    if LENGTH(g.C[K]) + LENGTH(STRING) > 256:
                        l.TEMP = 256 - LENGTH(g.C[K]);
                        T = SUBSTR(STRING, 0, l.TEMP);
                        g.C[K] = g.C[K] + T;
                        K = K + 1;
                        g.C[K] = SUBSTR(STRING, l.TEMP);
                    else:
                        g.C[K] = g.C[K] + STRING;
                
                g.C[1] = ''
                g.C[2] = '';
                if (g.GRAMMAR_FLAGS[PNTR] & MACRO_ARG_FLAG) != 0: 
                    return g.C[0];
                S = g.C[0];
                g.C[0] = SQUOTE;
                I = 0
                J = 0
                K = 0;
                goto_SEARCH = False
                firstTry = True
                while firstTry or goto_SEARCH:
                    firstTry = False
                    goto_SEARCH = False
                    while (BYTE(S, I) != BYTE(SQUOTE)) and (I < LENGTH(S)):
                        if OFFSET != 0:  # NOT AN M-LINE
                            if (TRANS_OUT(BYTE(S, I)) & 0xFF) != 0:
                                if I != J:
                                    ADD(SUBSTR(S, J, I - J));
                                for L in range(0, (SHR(TRANS_OUT(BYTE(S, I)), 8) \
                                                    & 0xFF) + 1):
                                    ADD(STRING(ADDR(ESCP)));
                                ADD(STRING(ADDR(TRANS_OUT(BYTE(S, I))) + 1));
                                J, I = I + 1;
                            else:
                                I = I + 1;
                        else:
                            I = I + 1;
                    if I != J:
                        ADD(SUBSTR(S, J, I - J));
                    if I != LENGTH(S):
                        ADD(SQUOTE + SQUOTE);
                        I = I + 1;
                        J = I;
                        goto_SEARCH = True
                        continue
                ADD(SQUOTE);
                return g.C[0];
            J = g.GRAMMAR_FLAGS[PNTR];
            if (J & LEFT_BRACKET_FLAG) != 0:
                g.C[0] = '[' + g.C[0];
            if (J & RIGHT_BRACKET_FLAG) != 0:
               g.C[0] = g.C[0] + ']';
            if (J & LEFT_BRACE_FLAG) != 0:
                g.C[0] = '{' + g.C[0];
            if (J & RIGHT_BRACE_FLAG) != 0:
                g.C[0] = g.C[0] + '}';
        return g.C[0];
    
    def EXPAND(PTR):
        # I haven't put in the work to determine which (if any) local 
        # variables are supposed to be persistent.  For safety, I make
        # them all so.
        ll = lEXPAND  # Local variables.
        
        if (g.GRAMMAR_FLAGS[PTR] & STMT_END_FLAG) != 0:
            if COMMENT_COUNT >= 0:
                COMMENT_COUNT = MIN(COMMENT_COUNT, 255);
               
                def COMMENT_BRACKET(STRING, LOC):
                    # Locals are I, J, PTR. Note that PTR must be persistent.
                    # Moreover, STRING (contrary to XPL requirements) is 
                    # expected to be changed in a way that's observable to the 
                    # calling code.  That requires us to return STRING.
                    cb = lCOMMENT_BRACKET  # Persistent locals, for PTR
                    
                    STRING = BYTE(STRING, LOC, BYTE('/'));
                    STRING = BYTE(STRING, LOC + 1, BYTE('*'));
                    LOC = LOC + 2;
                    for I in range(cb.PTR, MIN(cb.PTR + ll.NUM, COMMENT_COUNT) + 1):
                        J = BYTE(SAVE_COMMENT, I);
                        STRING = BYTE(STRING, LOC, J);
                        LOC = LOC + 1;
                    STRING = BYTE(STRING, LOC, BYTE('*'));
                    STRING = BYTE(STRING, LOC + 1, BYTE('/'));
                    cb.PTR = I;
                    ll.NUM = MIN(ll.NUM, COMMENT_COUNT - cb.PTR + 1);
                    if ll.NUM <= 0:
                        cb.PTR = 0;
                        COMMENT_COUNT = -1;
                    return STRING
               
                COMMENT_COUNT = MIN(COMMENT_COUNT, 255);
                I = COMMENT_COUNT;
                while BYTE(SAVE_COMMENT, COMMENT_COUNT) == BYTE(g.X1):
                    COMMENT_COUNT = COMMENT_COUNT - 1;
                COMMENT_COUNT = COMMENT_COUNT + (COMMENT_COUNT != I);
                I = MAX(l.M_PTR, l.COMMENT_LOC + 1);
                if COMMENT_COUNT < l.LINESIZE - I - 4:
                    # COMMENT WILL FIT ON M LINE
                    ll.M_COMMENT_NEEDED = g.TRUE;
                    ll.LOC = I;
                    ll.NUM = COMMENT_COUNT;
                elif COMMENT_COUNT < l.LINESIZE - l.M_PTR - 5:
                    # WILL FIT IF RIGHT JUSTIFIED
                    ll.M_COMMENT_NEEDED = g.TRUE;
                    ll.LOC = l.LINESIZE - COMMENT_COUNT - 5;
                    ll.NUM = COMMENT_COUNT;
                elif l.M_PTR < l.COMMENT_LOC:
                    # NEED MORE THAN ONE LINE
                    ll.M_COMMENT_NEEDED, ll.S_COMMENT_NEEDED = g.TRUE;
                    ll.LOC = l.M_PTR + 1;
                    ll.NUM = l.LINESIZE - ll.LOC - 5;
                    ll.NUM_S_NEEDED = (COMMENT_COUNT - 1) / ll.NUM;
                    l.MAX_S_LEVEL = MAX(ll.NUM_S_NEEDED, l.MAX_S_LEVEL);
                else:
                    ll.POST_COMMENT_NEEDED = g.TRUE;
                    ll.LOC = l.COMMENT_LOC;
                    ll.NUM = l.LINESIZE - ll.LOC - 5;
        if l.MAX_E_LEVEL + MAX(l.MAX_S_LEVEL, SDL_OPTION) + 2 + \
                LINE_COUNT > LINE_MAX:
            ll.C = PAGE;
        else:
            ll.C = NEXT_CC;
        NEXT_CC = g.X1;  # UNLESS CHANGED BELOW
        LINE_MAX = LINE_LIM;
        S = I_FORMAT(g.STMT_NUM(), 4);
        if (INCLUDING or INCLUDE_END): 
            INCLUDE_CHAR = PLUS;
            if SRN_PRESENT:
                S = LEFT_PAD(PLUS + l.INCLUDE_COUNT, 6) + g.X1 + S;
            l.T = PAD1;
        else:  # NOT AN INCLUDED LINE
            INCLUDE_CHAR = g.X1;
            if SRN_PRESENT:
                S = SUBSTR(l.SDL_INFO, 0, 6) + g.X1 + S;  # SRN
            if SDL_OPTION:
                l.T = l.C_RVL;  # RECORD REVISION INDICATOR
                if LENGTH(l.SDL_INFO) >= 16:
                    l.T = l.T + g.X1 + SUBSTR(l.SDL_INFO, 8, 8);
                else:
                    l.T = l.T + SUBSTR(X70, 0, 9);
            else:
                l.T = PAD1;
        if l.MAX_E_LEVEL != 0:
            while l.MAX_E_LEVEL != 0:
                ll.BUILD = BLANK(ll.BUILD, 0, l.LINESIZE);
                for I in range(0, l.LINESIZE):
                    if l.BUILD_E_IND[I] == l.MAX_E_LEVEL:
                        l.BUILD_E_IND[I] = 0;
                        K = BYTE(l.BUILD_E, I);
                        ll.BUILD = BYTE(ll.BUILD, I, K);
                    if l.BUILD_E_UND[I] == l.MAX_E_LEVEL:
                        # SOME UNDERLINING TO BE DONE
                        l.BUILD_E_UND[I] = 0;
                        l.UNDER_LINE = BYTE(l.UNDER_LINE, I, BYTE('_'));
                        l.UNDERLINING = g.TRUE;
                # PRINT A BLANK LINE BEFORE E-LINES.
                if (ll.C != PAGE) and (not PREV_ELINE): 
                    ll.C = DOUBLE;
                # SINCE REVISION LEVEL IS PRINTED ON M-LINE
                # FOR SDL, LEAVE BLANK SPACE ON E-LINE.
                if SDL_OPTION:
                    OUTPUT(1, ll.C + PAD1 + INCLUDE_CHAR + 'E' + VBAR + \
                                ll.BUILD + VBAR + g.X1 + VBAR);
                else:
                    OUTPUT(1, ll.C + PAD1 + INCLUDE_CHAR + 'E' + VBAR + \
                                ll.BUILD + VBAR);
                PREV_ELINE = g.TRUE;
                if l.UNDERLINING:
                    l.UNDERLINING = g.FALSE;
                    OUTPUT(1, PLUS + PAD2 + l.UNDER_LINE);
                    l.UNDER_LINE = BLANK(l.UNDER_LINE, 0, l.LINESIZE);
                l.MAX_E_LEVEL = l.MAX_E_LEVEL - 1;
                ll.C = g.X1;
            l.BUILD_E = BLANK(l.BUILD_E, 0, l.LINESIZE);
        if ll.M_COMMENT_NEEDED:
            l.BUILD_M = COMMENT_BRACKET(l.BUILD_M, ll.LOC);
            ll.M_COMMENT_NEEDED = g.FALSE;
        if not l.LINE_CONTINUED:
            if NEST_LEVEL > 0:
                if BYTE(l.BUILD_M, 1) == BYTE(g.X1):
                    ll.CHAR = NEST_LEVEL;
                    if NEST_LEVEL < 10:
                        l.BUILD_M = BYTE(l.BUILD_M, 0, BYTE(ll.CHAR));
                    else:
                        l.BUILD_M = BYTE(l.BUILD_M, 0, BYTE(ll.CHAR));
                        l.BUILD_M = BYTE(l.BUILD_M, 1, BYTE(ll.CHAR, 1));
        # ON THE END STATEMENT, REPLACE THE CURRENT SCOPE WITH
        # THE STATEMENT NUMBER OF THE DO STATEMENT.  ON THE CASES OF THE
        # CASE STATEMENT, MOVE THE INFORMATION FIELD IDENTIFYING THE
        # CASE NUMBER TO REPLACE THE CURRENT SCOPE INSTEAD OF PRINTING
        # IT AFTER THE CURRENT SCOPE.  FOR IF-THEN-DO STATEMENTS, REPLACE
        # THE CURRENT SCOPE WITH THE STATEMENT NUMBER OF THE DO.
        if g.END_FLAG and (LABEL_COUNT == 0):
            ll.CHAR = 'ST#' + DO_STMTp(DO_LEVEL + 1);
        elif (LENGTH(INFORMATION) > 0)and(LABEL_COUNT == 0):
            ll.CHAR = INFORMATION;
            INFORMATION = '';
        elif IF_FLAG and (LABEL_COUNT == 0):
            ll.CHAR = 'DO=ST#' + g.STMT_NUM() + 1;
        else:
            ll.CHAR = g.SAVE_SCOPE;
        # PRINT REVISION LEVEL ON M-LINE FOR SDL
        if SDL_OPTION:
            ll.C = ll.C + S + INCLUDE_CHAR + 'M' + VBAR + l.BUILD_M + \
                    ll.FORMAT_CHAR + SUBSTR(l.T, 0, 2) + ll.FORMAT_CHAR;
        else:
            ll.C = ll.C + S + INCLUDE_CHAR + 'M' + VBAR + l.BUILD_M + ll.FORMAT_CHAR;
        OUTPUT(1, ll.C + ll.CHAR);
        PREV_ELINE = g.FALSE;
        if l.M_UNDERSCORE_NEEDED:
            l.M_UNDERSCORE_NEEDED = g.FALSE;
            OUTPUT(1, PLUS + PAD2 + l.M_UNDERSCORE);
            l.M_UNDERSCORE = BLANK(l.M_UNDERSCORE, 0, l.LINESIZE);
        l.BUILD_M = BLANK(l.BUILD_M, 0, l.LINESIZE);
        if l.MAX_S_LEVEL != 0:
            for J in range(1, l.MAX_S_LEVEL + 1):
                ll.BUILD = BLANK(ll.BUILD, 0, l.LINESIZE);
                for I in range(0, l.LINESIZE):
                    if l.BUILD_S_IND[I] == J:
                        l.BUILD_S_IND[I] = 0;
                        K = BYTE(l.BUILD_S, I);
                        ll.BUILD = BYTE(ll.BUILD, I, K);
                    if l.BUILD_S_UND[I] == J:
                        l.BUILD_S_UND[I] = 0;
                        l.UNDER_LINE = BYTE(l.UNDER_LINE, I, BYTE('_'));
                        l.UNDERLINING = g.TRUE;
                if ll.S_COMMENT_NEEDED:
                    if J <= ll.NUM_S_NEEDED:
                        ll.BUILD = COMMENT_BRACKET(ll.BUILD, ll.LOC);
                # PRINT A BLANK LINE AFTER  S-LINES.
                NEXT_CC = DOUBLE;
                # SINCE REVISION LEVEL IS PRINTED ON M-LINE
                # FOR SDL, LEAVE BLANK SPACE ON S-LINE.
                if SDL_OPTION:
                    OUTPUT(1, g.X1 + PAD1 + INCLUDE_CHAR + 'S' + VBAR + \
                                ll.BUILD + VBAR + g.X1 + VBAR);
                else:
                    OUTPUT(1, g.X1 + PAD1 + INCLUDE_CHAR + 'S' + VBAR + \
                                ll.BUILD + VBAR);
                PREV_ELINE = g.FALSE;
                if l.UNDERLINING:
                    l.UNDERLINING = g.FALSE;
                    OUTPUT(1, PLUS + PAD2 + l.UNDER_LINE);
                    l.UNDER_LINE = BLANK(l.UNDER_LINE, 0, l.LINESIZE);
            l.BUILD_S = BLANK(l.BUILD_S, 0, l.LINESIZE);
        ll.S_COMMENT_NEEDED = g.FALSE;
        l.MAX_S_LEVEL, l.MAX_E_LEVEL = 0;
        if ll.POST_COMMENT_NEEDED:
            while ll.NUM > 0:
                ll.BUILD = BLANK(ll.BUILD, 0, l.LINESIZE);
                ll.BUILD = COMMENT_BRACKET(ll.BUILD, ll.LOC);
                OUTPUT(1, g.X1 + PAD2 + ll.BUILD);
            ll.POST_COMMENT_NEEDED = g.FALSE;
        
        ERROR_PRINT();
        l.LINE_CONTINUED = g.FALSE;
    
    def MATCH(START):
        # Locals are NUM_LEFT and NUM_RIGHT.
        ''' THIS PROCEDURE SEARCHES THE STMT_STACK STARTING AT START FOR
            MATCHING OPEN/CLOSE PAREN PAIRS.  IT REPLACES MATCHING OUTER
            PAIRS WITH ZEROS UNLESS THE "FIND_ONLY" FLAG IS ON. IT RETURNS A 
            VALUE WHICH IS THE INDEX OF THE OUTERMOST ")". '''
        I = START;
        NUM_LEFT = 1;
        NUM_RIGHT = 0;
        while (NUM_LEFT > NUM_RIGHT) and (I <= l.PTR_END):
            I = I + 1;
            if g.STMT_STACK[I] == LEFT_PAREN:
                NUM_LEFT = NUM_LEFT + 1;
            elif g.STMT_STACK[I] == RT_PAREN:
                NUM_RIGHT = NUM_RIGHT + 1;
        if NUM_LEFT == NUM_RIGHT:
            if (g.STMT_STACK[START] == LEFT_PAREN) and \
                    (g.STMT_STACK[I] == RT_PAREN):
                if not l.FIND_ONLY:
                    g.STMT_STACK[START] = 0
                    g.STMT_STACK[I] = 0;
        if NUM_LEFT != NUM_RIGHT: 
            ERROR(d.CLASS_BS, 6);
        return I;
    
    def SKIP_REPL(POINT):
        while ((TOKEN_FLAGS(POINT) & 0x1F) == 7) and (POINT <= l.PTR_END):
            POINT = POINT + 1;
        return POINT;
    
    def CHECK_FOR_FUNC(START):
        # Locals are FINISH and DEPTH.
        FINISH = START;
        if (g.GRAMMAR_FLAGS[START] & FUNC_FLAG) != 0:
            # A FUNCTION - CHECK FOR SUBSCRIPTING AND ARGUMENTS
            DEPTH = 1;
            while (g.STMT_STACK[FINISH + 1] == g.DOLLAR) and \
                    ((FINISH + 1) < l.PTR_END):
                FINISH = FINISH + 2;
                if g.STMT_STACK[FINISH] == LEFT_PAREN:
                    l.FIND_ONLY = g.TRUE;
                    FINISH = MATCH(FINISH);
                    l.FIND_ONLY = g.FALSE;
                elif (g.GRAMMAR_FLAGS[FINISH] & FUNC_FLAG) != 0:
                    DEPTH = DEPTH + 1;
            # END OF DO WHILE...
            for DEPTH in range(0, DEPTH + 1):
                if (FINISH + 1) < l.PTR_END:
                    if g.STMT_STACK[FINISH + 1] == LEFT_PAREN:
                        # ARGUMENT LIST
                        l.FIND_ONLY = g.TRUE;
                        FINISH = MATCH(FINISH + 1);
                        l.FIND_ONLY = g.FALSE;
            if g.STMT_STACK[FINISH + 1] == LEFT_PAREN:
                ERROR(d.CLASS_BS, 6);
        else:
            goto_START_SEARCH = True
            while goto_START_SEARCH or ((g.STMT_STACK[START] == STRUC_TOKEN) \
                    and (g.STMT_STACK[DEPTH] == DOT_TOKEN)):
                if not goto_START_SEARCH:
                    FINISH = MIN(DEPTH + 1, l.PTR_END);
                goto_START_SEARCH = False
                START = SKIP_REPL(FINISH);
                DEPTH = SKIP_REPL(START + 1);
        return FINISH;
    
    goto_OUTPUT_WRITER_BEGINNING = False
    if not goto_PRINT_ANY_ERRORS:
        l.PRINT_LABEL = g.FALSE;
        I = 2;
        l.SDL_INFO = g.SRN[I];
        l.INCLUDE_COUNT = SRN_COUNT(I);
        if  not l.LINE_CONTINUED:
            l.M_PTR = MAX(MIN(INDENT_LEVEL, l.INDENT_LIMIT), 0);
        if INLINE_INDENT_RESET >= 0: 
            INDENT_LEVEL = INLINE_INDENT_RESET;
            INLINE_INDENT_RESET = -1;
        if l.PTR_END == -1:
            l.PTR_END = g.STMT_PTR;
        if (l.PTR_END == OUTPUT_STACK_MAX) and g.SQUEEZING:
            l.PTR_END = l.PTR_END - 2;
        while ((g.GRAMMAR_FLAGS[l.PTR_START] & PRINT_FLAG) == 0) and \
                (l.PTR_START <= l.PTR_END):
            l.PTR_START = l.PTR_START + 1;
        if l.PTR_START > l.PTR_END:
            goto_AFTER_EXPAND = True
        else:
            # FIND MOST RECENT RVL. THE RVL FOR EACH TOKEN WAS SAVED IN SAVE_TOKEN
            if SDL_OPTION and (not INCLUDING) and (not INCLUDE_END):
                l.C_RVL = STRING(ADDR(RVL_STACK1(l.PTR_START))) + \
                                    STRING(ADDR(RVL_STACK2(l.PTR_START)));
                for l.IDX in range(l.PTR_START + 1, l.PTR_END + 1):
                    if ((g.GRAMMAR_FLAGS[l.IDX] & PRINT_FLAG) != 0):
                        l.C_TMP = STRING(ADDR(RVL_STACK1(l.IDX))) + \
                                    STRING(ADDR(RVL_STACK2(l.IDX)));
                        if STRING_GT(l.C_TMP, l.C_RVL): 
                            l.C_RVL = l.C_TMP;
                if STRING_GT(l.C_RVL, SUBSTR(g.SRN[2], 6, 2)):
                    g.SRN[2] = SUBSTR(g.SRN[2], 0, 6) + l.C_RVL;
            l.LABEL_START = l.PTR_START;
            if LABEL_COUNT > 0:
                while ((g.GRAMMAR_FLAGS[l.PTR_START] & LABEL_FLAG) != 0) \
                        and (l.PTR_START < l.PTR_END):
                  l.PTR_START = l.PTR_START + 2;
            l.LABEL_END = l.PTR_START - 1;
            while ((g.GRAMMAR_FLAGS[l.PTR_START] & PRINT_FLAG) == 0) and \
                        (l.PTR_START <= l.PTR_END):
                l.PTR_START = l.PTR_START + 1;
            if (l.PTR_START > l.PTR_END) and (LABEL_COUNT > 0): 
                l.PRINT_LABEL = g.TRUE;
                goto_STLABEL = True;
                '''
                A conundrum!  To get to STLABEL, we have to somehow get into
                the DO PTR = PTR_START TO PTR_END block below.  This requires
                reworking the DO-block, which would otherwise translate into
                a simple Python for-loop, in a relatively-weird way.
                '''
            l.PTR = l.PTR_START - 1
            while goto_STLABEL or (l.PTR + 1 <= l.PTR_END):
                if not goto_STLABEL:
                    l.PTR += 1
                    
                    l.SUB_START = 0
                    l.EXP_START = 0;
                    if (g.GRAMMAR_FLAGS[l.PTR] & INLINE_FLAG) != 0: 
                        INLINE_INDENT = l.M_PTR + 1;
                    if g.STMT_STACK[l.PTR] == g.DOLLAR:
                        l.PTR = l.PTR + 1;
                        l.SUB_START = l.PTR;
                        l.S_LEVEL = 0;
                        if l.MAX_S_LEVEL == 0:
                            l.MAX_S_LEVEL = 1;
                        if g.STMT_STACK[l.SUB_START] == LEFT_PAREN:
                            DO;
                            l.SUB_END = MATCH(l.SUB_START);
                            if l.SUB_END < l.PTR_END:
                                if g.STMT_STACK[l.SUB_END + 1] == g.DOLLAR:
                                    if (l.SUB_END - l.SUB_START) > 2:
                                        g.STMT_STACK[l.SUB_START] = TX(BYTE('('));
                                        g.STMT_STACK[l.SUB_END] = TX(BYTE(')'));
                        else:
                            l.SUB_END = CHECK_FOR_FUNC(l.SUB_START);
                        while (g.STMT_STACK[l.SUB_END + 1] == g.DOLLAR) and \
                                    ((l.SUB_END + 1) < l.PTR_END):
                            l.SUB_END = l.SUB_END + 2;
                            if g.STMT_STACK[l.SUB_END] == LEFT_PAREN:
                                DO;
                                l.FIND_ONLY = g.TRUE;
                                l.SUB_END = MATCH(l.SUB_END);
                                l.FIND_ONLY = g.FALSE;
                            else:
                                l.SUB_END = CHECK_FOR_FUNC(l.SUB_END);
                        l.PTR = l.SUB_END + 1;
                    if (g.STMT_STACK[l.PTR] == g.EXPONENTIATE) and (l.PTR < l.PTR_END):
                        l.PTR = l.PTR + 1;
                        l.EXP_START = l.PTR;
                        l.E_LEVEL = 0;
                        if l.MAX_E_LEVEL == 0:
                            l.MAX_E_LEVEL = 1;
                        if g.STMT_STACK[l.EXP_START] == LEFT_PAREN:
                            l.EXP_END = MATCH(l.EXP_START);
                            if l.EXP_END < l.PTR_END:
                                if g.STMT_STACK[l.EXP_END + 1] == g.EXPONENTIATE:
                                    if (l.EXP_END - l.EXP_START) > 2:
                                        g.STMT_STACK[l.EXP_START] = TX(BYTE('('));
                                        g.STMT_STACK[l.EXP_END] = TX(BYTE(')'));
                        else:
                            l.EXP_END = CHECK_FOR_FUNC(l.EXP_START);
                        goto_DOLLAR_CHECK1 = True
                        while ((g.STMT_STACK[l.EXP_END + 1] == g.EXPONENTIATE) \
                                    and ((l.EXP_END + 1) < l.PTR_END)) or \
                                    goto_DOLLAR_CHECK1:
                            if not goto_DOLLAR_CHECK1:
                                l.EXP_END = l.EXP_END + 2;
                            if g.STMT_STACK[l.EXP_END] == LEFT_PAREN \
                                    and not goto_DOLLAR_CHECK1:
                                l.FIND_ONLY = g.TRUE;
                                l.EXP_END = MATCH(l.EXP_END);
                                l.FIND_ONLY = g.FALSE;
                            elif (g.GRAMMAR_FLAGS[l.EXP_END] & FUNC_FLAG) != 0 \
                                    and not goto_DOLLAR_CHECK1:
                                l.EXP_END = CHECK_FOR_FUNC(l.EXP_END);
                            else:
                                goto_DOLLAR_CHECK1 = False
                                while (g.STMT_STACK[l.EXP_END + 1] == g.DOLLAR) \
                                            and (l.EXP_END + 1 < l.PTR_END):
                                    l.EXP_END = l.EXP_END + 2;
                                    if g.STMT_STACK[l.EXP_END] == LEFT_PAREN:
                                        l.FIND_ONLY = g.TRUE;
                                        l.EXP_END = MATCH(l.EXP_END);
                                        l.FIND_ONLY = g.FALSE;
                                    else:
                                        l.EXP_END = CHECK_FOR_FUNC(l.EXP_END);
                        l.PTR = l.EXP_END + 1;
                    if l.SUB_START + l.EXP_START != 0:
                        goto_S_BEGIN = True
                        goto_S_LOOP = False
                        goto_E_BEGIN = False
                        goto_E_LOOP = False
                        goto_S_FULL = False
                        while goto_S_BEGIN or goto_S_LOOP or goto_E_BEGIN \
                                or goto_E_LOOP or goto_S_FULL:
                            goto_S_BEGIN = False
                            if not (goto_S_LOOP or goto_E_BEGIN or \
                                    goto_E_LOOP or goto_S_FULL):
                                l.E_PTR = l.M_PTR
                                l.S_PTR = l.M_PTR;
                            if l.SUB_START != 0 or goto_S_LOOP or goto_S_FULL:
                                goto_S_LOOP = False
                                if not goto_S_FULL:
                                    g.LAST_SPACE = 2;
                                while l.SUB_START[l.S_LEVEL] <= l.SUB_END[l.S_LEVEL] \
                                        or goto_S_FULL:
                                    if not goto_S_FULL:
                                        if g.STMT_STACK[l.SUB_START[l.S_LEVEL]] == 0:
                                            l.SUB_START[l.S_LEVEL] = \
                                                l.SUB_START[l.S_LEVEL] + 1;
                                            goto_S_LOOP = True
                                            break
                                        if g.STMT_STACK[l.SUB_START[l.S_LEVEL]] == g.DOLLAR:
                                            if l.S_LEVEL == l.MAX_LEVEL:
                                                ERROR(d.CLASS_BS, 7);
                                                l.SUB_START[l.S_LEVEL] = \
                                                    l.SUB_START[l.S_LEVEL] + 1;
                                                goto_S_LOOP = True
                                                break
                                            l.S_LEVEL = l.S_LEVEL + 1;
                                            if l.MAX_S_LEVEL <= l.S_LEVEL:
                                                l.MAX_S_LEVEL = l.S_LEVEL + 1;
                                            l.SUB_START[l.S_LEVEL] = \
                                                l.SUB_START[l.S_LEVEL - 1] + 1;
                                            if g.STMT_STACK[l.SUB_START[l.S_LEVEL]] == LEFT_PAREN:
                                                l.SUB_END[l.S_LEVEL] = \
                                                    MATCH(l.SUB_START[l.S_LEVEL]);
                                                if l.SUB_END[l.S_LEVEL] < l.PTR_END:
                                                    if g.STMT_STACK[l.SUB_START[l.S_LEVEL] + 1] == g.DOLLAR:
                                                        if (l.SUB_END[l.S_LEVEL] - l.SUB_START[l.S_LEVEL]) > 2:
                                                            g.STMT_STACK[l.SUB_START[l.S_LEVEL]] = TX(BYTE('('));
                                                            g.STMT_STACK[l.SUB_END[l.S_LEVEL]] = TX(BYTE(')'));
                                            else:
                                                l.SUB_END[l.S_LEVEL] = \
                                                    CHECK_FOR_FUNC(l.SUB_START[l.S_LEVEL]);
                                            while (g.STMT_STACK[l.SUB_END[l.S_LEVEL] + 1] \
                                                      == g.DOLLAR) and \
                                                      ((l.SUB_END[l.S_LEVEL] + 1) < l.PTR_END):
                                                l.SUB_END[l.S_LEVEL] = l.SUB_END[l.S_LEVEL] + 2;
                                                if g.STMT_STACK[l.SUB_END[l.S_LEVEL]] == LEFT_PAREN:
                                                    l.FIND_ONLY = g.TRUE;
                                                    l.SUB_END[l.S_LEVEL] = MATCH(l.SUB_END[l.S_LEVEL]);
                                                    l.FIND_ONLY = g.FALSE;
                                                else:
                                                    l.SUB_START[l.S_LEVEL] = \
                                                        CHECK_FOR_FUNC(l.SUB_END[l.S_LEVEL]);
                                            if l.SUB_END[l.S_LEVEL] >= l.PTR:
                                                l.PTR = l.SUB_END[l.S_LEVEL] + 1;
                                            goto_S_LOOP = True
                                            break
                                    if g.STMT_STACK[l.SUB_START[l.S_LEVEL]] == CHARACTER_STRING \
                                            and not goto_S_FULL:
                                        if l.S_CHAR_PTR < l.S_CHAR_PTR_MAX:
                                            # GO TO MORE_S_C;
                                            pass
                                        else:
                                            g.C[0] = ATTACH(l.SUB_START[l.S_LEVEL], NT);
                                            if LENGTH(g.C[0]) == 0: 
                                                goto_INCR_SUB_START = True
                                            else:
                                                l.S_CHAR_PTR = 0
                                                l.S_CHAR_PTR_MAX = 0;
                                                for I in range(0, 2 + 1):
                                                    l.SAVE_S_C[I] = g.C[I];
                                                    l.S_CHAR_PTR_MAX = \
                                                        l.S_CHAR_PTR_MAX + LENGTH(g.C[I]);
                                                l.S_PTR = l.S_PTR + l.SPACE_NEEDED;
                                        # MORE_S_C:
                                        if not goto_INCR_SUB_START:
                                            while (l.S_CHAR_PTR < l.S_CHAR_PTR_MAX) and \
                                                        (l.S_PTR < l.LINESIZE):
                                                J = BYTE(l.SAVE_S_C[SHR(l.S_CHAR_PTR, 8)], \
                                                         (l.S_CHAR_PTR & 0xFF));
                                                l.BUILD_S = BYTE(l.BUILD_S, l.S_PTR, J);
                                                l.BUILD_S_IND[l.S_PTR] = l.S_LEVEL + 1;
                                                if (g.GRAMMAR_FLAGS[l.SUB_START[l.S_LEVEL]] \
                                                        & MACRO_ARG_FLAG) != 0:
                                                    l.BUILD_S_UND[l.S_PTR] = l.S_LEVEL + 1;
                                                l.S_PTR = l.S_PTR + 1;
                                                l.S_CHAR_PTR = l.S_CHAR_PTR + 1;
                                            if l.S_CHAR_PTR < l.S_CHAR_PTR_MAX:
                                                goto_S_FULL = True
                                                continue
                                        goto_INCR_SUB_START = True
                                    else:
                                        # NOT A CHARACTER STRING
                                        if not goto_S_FULL:
                                            g.C[0] = ATTACH(l.SUB_START[l.S_LEVEL], NT);
                                        if LENGTH(g.C[0]) == 0 and not goto_S_FULL: 
                                            goto_INCR_SUB_START = True
                                        else:
                                            if not goto_S_FULL:
                                                l.S_PTR = l.S_PTR + l.SPACE_NEEDED;
                                            if LENGTH(g.C[0]) + l.S_PTR >= l.LINESIZE \
                                                    or goto_S_FULL:
                                                goto_S_FULL = False
                                                # RESTORE PRINT FLAG TO OVERFLOWING TOKEN
                                                g.GRAMMAR_FLAGS[l.SUB_START[l.S_LEVEL]] \
                                                    |= PRINT_FLAG;
                                                l.LINE_FULL = g.TRUE;
                                                l.SAVE_MAX_S_LEVEL = l.S_LEVEL + 1;
                                                goto_E_BEGIN = True
                                                break
                                            for I in range(0, LENGTH(g.C[0])):
                                                J = BYTE(g.C[0], I);
                                                l.BUILD_S = BYTE(l.BUILD_S, l.S_PTR + I, J);
                                                l.BUILD_S_IND[l.S_PTR + I] = l.S_LEVEL + 1;
                                            if (TOKEN_FLAGS(l.SUB_START[l.S_LEVEL]) & 7) == 7:
                                                l.MACRO_WRITTEN = g.TRUE;
                                            if (g.GRAMMAR_FLAGS[l.SUB_START[l.S_LEVEL]] \
                                                    & MACRO_ARG_FLAG) != 0: 
                                                for I in range(0, LENGTH(g.C[0])):
                                                    l.BUILD_S_UND[l.S_PTR + I] = l.S_LEVEL + 1;
                                            l.S_PTR = l.S_PTR + LENGTH(g.C[0]);
                                        goto_INCR_SUB_START = False
                                        l.SUB_START[l.S_LEVEL] = l.SUB_START[l.S_LEVEL] + 1;
                                        # OF NOT A CHARACTER STRING
                                # END OF DO WHILE SUB_START <= SUB_END
                                if goto_S_LOOP:
                                    continue
                                if goto_E_BEGIN:
                                    break
                            # END OF SUB_START != 0
                            if not (goto_E_BEGIN or goto_E_LOOP):
                                if l.S_LEVEL != 0:
                                    l.S_LEVEL = l.S_LEVEL - 1;
                                    l.SUB_START[l.S_LEVEL] = l.SUB_START[l.S_LEVEL + 1];
                                    l.MACRO_WRITTEN = g.FALSE;
                                    goto_S_LOOP = True
                                    continue
                            goto_E_BEGIN = False
                            if l.EXP_START != 0 or goto_E_LOOP: 
                                goto_E_LOOP = False
                                g.LAST_SPACE = 2;
                                while l.EXP_START[l.E_LEVEL] <= l.EXP_END[l.E_LEVEL]:
                                    if g.STMT_STACK[l.EXP_START[l.E_LEVEL]] == 0:
                                        l.EXP_START[l.E_LEVEL] = l.EXP_START[l.E_LEVEL] + 1;
                                        goto_E_LOOP = True
                                        break
                                    if g.STMT_STACK[l.EXP_START[l.E_LEVEL]] == g.EXPONENTIATE:
                                        if l.E_LEVEL == l.MAX_LEVEL: 
                                            ERROR(d.CLASS_BS, 7);
                                            l.EXP_START[l.E_LEVEL] = l.EXP_START[l.E_LEVEL] + 1;
                                            goto_E_LOOP = True
                                            break
                                        l.E_LEVEL = l.E_LEVEL + 1;
                                        if l.MAX_E_LEVEL <= l.E_LEVEL:
                                            l.MAX_E_LEVEL = l.E_LEVEL + 1;
                                        l.EXP_START[l.E_LEVEL] = l.EXP_START[l.E_LEVEL - 1] + 1;
                                        if g.STMT_STACK[l.EXP_START[l.E_LEVEL]] == LEFT_PAREN:
                                            l.EXP_END[l.E_LEVEL] = MATCH(l.EXP_START[l.E_LEVEL]);
                                            if l.EXP_END[l.E_LEVEL] < l.PTR_END:
                                                if g.STMT_STACK[l.EXP_END[l.E_LEVEL] + 1] \
                                                        == g.EXPONENTIATE:
                                                    if (l.EXP_END[l.E_LEVEL] - \
                                                            l.EXP_START[l.E_LEVEL]) > 2:
                                                        g.STMT_STACK[l.EXP_START[l.E_LEVEL]] = \
                                                            TX(BYTE('('));
                                                        g.STMT_STACK[l.EXP_END[l.E_LEVEL]] = \
                                                            TX(BYTE(')'));
                                            else:
                                                l.EXP_END[l.E_LEVEL] = \
                                                    CHECK_FOR_FUNC(l.EXP_START[l.E_LEVEL]);
                                        goto_DOLLAR_CHECK2 = True
                                        while ((g.STMT_STACK[l.EXP_END[l.E_LEVEL] + 1] \
                                                == g.EXPONENTIATE) and \
                                                ((l.EXP_END[l.E_LEVEL] + 1) < l.PTR_END)) \
                                                or goto_DOLLAR_CHECK2:
                                            if not goto_DOLLAR_CHECK2:
                                                l.EXP_END[l.E_LEVEL] = l.EXP_END[l.E_LEVEL] + 2;
                                            if g.STMT_STACK[l.EXP_END[l.E_LEVEL]] == LEFT_PAREN \
                                                    and not goto_DOLLAR_CHECK2:
                                                l.FIND_ONLY = g.TRUE;
                                                l.EXP_END[l.E_LEVEL] = MATCH(l.EXP_END[l.E_LEVEL]);
                                                l.FIND_ONLY = g.FALSE;
                                            elif ((g.GRAMMAR_FLAGS[l.EXP_END[l.E_LEVEL]] & \
                                                    FUNC_FLAG) != 0) and not goto_DOLLAR_CHECK2:
                                                l.EXP_END[l.E_LEVEL] = \
                                                    CHECK_FOR_FUNC(l.EXP_END[l.E_LEVEL]);
                                            else:
                                                goto_DOLLAR_CHECK2 = False
                                                while (g.STMT_STACK[l.EXP_END[l.E_LEVEL] + 1] == \
                                                        g.DOLLAR) & (l.EXP_END[l.E_LEVEL] + 1 < l.PTR_END):
                                                    l.EXP_END[l.E_LEVEL] = l.EXP_END[l.E_LEVEL] + 2;
                                                    if g.STMT_STACK[l.EXP_END[l.E_LEVEL]] == \
                                                            LEFT_PAREN:
                                                        l.FIND_ONLY = g.TRUE;
                                                        l.EXP_END[l.E_LEVEL] = \
                                                            MATCH(l.EXP_END[l.E_LEVEL]);
                                                        l.FIND_ONLY = g.FALSE;
                                                    else:
                                                        l.EXP_END[l.E_LEVEL] = \
                                                            CHECK_FOR_FUNC(l.EXP_END[l.E_LEVEL]);
                                        if l.EXP_END[l.E_LEVEL] >= l.PTR:
                                            l.PTR = l.EXP_END[l.E_LEVEL] + 1;
                                        goto_E_LOOP = True
                                        continue
                                    ss = g.STMT_STACK[l.EXP_START[l.E_LEVEL]] == CHARACTER_STRING
                                    goto_INCR_EXP_START = False
                                    goto_E_FULL = False
                                    if ss:
                                        if l.E_CHAR_PTR < l.E_CHAR_PTR_MAX:
                                            # GO TO MORE_E_C;
                                            pass
                                        else:
                                            g.C[0] = ATTACH(l.EXP_START[l.E_LEVEL], NT);
                                            if LENGTH(g.C[0]) == 0: 
                                                goto_INCR_EXP_START = True;
                                            else:
                                                l.E_CHAR_PTR = 0
                                                l.E_CHAR_PTR_MAX = 0;
                                                for I in range(0, 2 + 1):
                                                    l.SAVE_E_C[I] = g.C[I];
                                                    l.E_CHAR_PTR_MAX = l.E_CHAR_PTR_MAX + LENGTH(g.C[I]);
                                                l.E_PTR = l.E_PTR + l.SPACE_NEEDED;
                                        # MORE_E_C:
                                        if not goto_INCR_EXP_START:
                                            while (l.E_CHAR_PTR < l.E_CHAR_PTR_MAX) and \
                                                    (l.E_PTR < l.LINESIZE):
                                                J = BYTE(l.SAVE_E_C[SHR(l.E_CHAR_PTR, 8)], \
                                                         (l.E_CHAR_PTR & 0xFF));
                                                l.BUILD_E = BYTE(l.BUILD_E, l.E_PTR, J);
                                                l.BUILD_E_IND[l.E_PTR] = l.E_LEVEL + 1;
                                                if (g.GRAMMAR_FLAGS[l.EXP_START[l.E_LEVEL]] \
                                                        & MACRO_ARG_FLAG) != 0:
                                                    l.BUILD_E_UND[l.E_PTR] = l.E_LEVEL + 1;
                                                    l.E_PTR = l.E_PTR + 1;
                                                    l.E_CHAR_PTR = l.E_CHAR_PTR + 1;
                                            if l.E_CHAR_PTR < l.E_CHAR_PTR_MAX:
                                                goto_E_FULL = True
                                        if not goto_E_FULL:
                                            goto_INCR_EXP_START = True
                                    if not ss or goto_INCR_EXP_START \
                                            or goto_E_FULL:  # originally just ELSE
                                        # NOT A CHARACTER STRING
                                        if not goto_INCR_EXP_START:
                                            if not goto_E_FULL:
                                                g.C[0] = ATTACH(l.EXP_START[l.E_LEVEL], NT);
                                            if LENGTH(g.C[0]) == 0 and not goto_E_FULL: 
                                                goto_INCR_EXP_START = True
                                            else:
                                                if not goto_E_FULL:
                                                    l.E_PTR = l.E_PTR + l.SPACE_NEEDED;
                                                if goto_E_FULL or \
                                                        (LENGTH(g.C[0]) + l.E_PTR >= l.LINESIZE):
                                                    goto_E_FULL = False
                                                    g.GRAMMAR_FLAGS[l.EXP_START[l.E_LEVEL]] \
                                                        |= PRINT_FLAG;
                                                    l.LINE_FULL = g.TRUE;
                                                    l.SAVE_MAX_E_LEVEL = l.E_LEVEL + 1;
                                                    goto_FULL_LINE = True
                                                    break
                                                for I in range(0, LENGTH(g.C[0])):
                                                    J = BYTE(g.C[0], I);
                                                    l.BUILD_E = BYTE(l.BUILD_E, l.E_PTR + I, J);
                                                    l.BUILD_E_IND[l.E_PTR + I] = l.E_LEVEL + 1;
                                                if (TOKEN_FLAGS(l.EXP_START[l.E_LEVEL]) & 7) == 7:
                                                    l.MACRO_WRITTEN = g.TRUE;
                                                if (g.GRAMMAR_FLAGS[l.EXP_START[l.E_LEVEL]] \
                                                        & MACRO_ARG_FLAG) != 0: 
                                                    for I in range(0, LENGTH(g.C[0])):
                                                        l.BUILD_E_UND[l.E_PTR + I] = l.E_LEVEL + 1;
                                                l.E_PTR = l.E_PTR + LENGTH(g.C[0]);
                                        goto_INCR_EXP_START = False
                                        l.EXP_START[l.E_LEVEL] = l.EXP_START[l.E_LEVEL] + 1;
                                        # END OF NOT A CHARACTER STRING
                                # END OF DO WHILE EXP_START <= EXP_END
                                if goto_E_LOOP:
                                    continue
                            # END OF EXP_START != 0
                            if l.E_LEVEL != 0 and not goto_FULL_LINE:
                                l.E_LEVEL = l.E_LEVEL - 1;
                                l.EXP_START[l.E_LEVEL] = l.EXP_START[l.E_LEVEL + 1];
                                l.MACRO_WRITTEN = g.FALSE;
                                goto_E_LOOP = True
                                continue
                            goto_FULL_LINE = False
                            if l.LINE_FULL:
                                EXPAND(0);
                                l.MAX_E_LEVEL = l.SAVE_MAX_E_LEVEL;
                                l.MAX_S_LEVEL = l.SAVE_MAX_S_LEVEL;
                                l.SAVE_MAX_E_LEVEL = 0
                                l.SAVE_MAX_S_LEVEL = 0;
                                l.LINE_FULL = g.FALSE;
                                if (l.E_CHAR_PTR + l.S_CHAR_PTR) == 0:
                                    l.M_PTR = MAX(MIN(INDENT_LEVEL, l.INDENT_LIMIT), 0);
                                else:
                                    l.M_PTR = 0;  
                                    l.LINE_CONTINUED = g.TRUE;  
                                goto_S_BEGIN = True
                                continue
                            if l.E_PTR > l.S_PTR:
                                l.M_PTR = l.E_PTR;
                            else:
                                l.M_PTR = l.S_PTR;
                            g.LAST_SPACE = 1;
                    # END OF DO IF SUB_START + EXP_START != 0
                    if l.PTR > l.PTR_END: 
                        goto_PTR_LOOP_END = True
                ss = g.STMT_STACK[l.PTR] == CHARACTER_STRING
                if ss and not goto_STLABEL and not goto_PTR_LOOP_END:
                    g.C[0] = ATTACH(l.PTR, 0);
                    if LENGTH(g.C[0]) == 0: 
                        goto_PTR_LOOP_END = True
                    else:
                        goto_MORE_M_C = False
                        if l.M_CHAR_PTR < l.M_CHAR_PTR_MAX:
                            # GO TO MORE_M_C
                            pass
                        else:
                            l.M_CHAR_PTR = 0
                            l.M_CHAR_PTR_MAX = 0;
                            for I in range(0, 2 + 1):
                                l.M_CHAR_PTR_MAX = l.M_CHAR_PTR_MAX + LENGTH(g.C[I]);
                            l.M_PTR = l.M_PTR + l.SPACE_NEEDED;
                        goto_MORE_M_C = True
                        while goto_MORE_M_C:
                            goto_MORE_M_C = False
                            while (l.M_CHAR_PTR < l.M_CHAR_PTR_MAX) and (l.M_PTR < l.LINESIZE):
                                J = BYTE(g.C[SHR(l.M_CHAR_PTR, 8)], (l.M_CHAR_PTR & 0xFF));
                                if (TRANS_OUT(J) & 0xFF) != 0: 
                                    # ALT CHAR SET
                                    K = CHAR_OP(SHR(TRANS_OUT(J), 8) & 0xFF);  # OP CHAR
                                    l.BUILD_E = BYTE(l.BUILD_E, l.M_PTR, K);
                                    l.BUILD_E_IND[l.M_PTR] = 1;
                                    if l.MAX_E_LEVEL == 0: 
                                        l.MAX_E_LEVEL = 1;
                                    J = TRANS_OUT(J) & 0xFF;  # BACK TO NORMAL CHAR SET
                                l.BUILD_M = BYTE(l.BUILD_M, l.M_PTR, J);
                                if (g.GRAMMAR_FLAGS[l.PTR] & MACRO_ARG_FLAG) != 0: 
                                    l.M_UNDERSCORE = BYTE(l.M_UNDERSCORE, l.M_PTR, BYTE('_'));
                                    l.M_UNDERSCORE_NEEDED = g.TRUE;
                                l.M_PTR = l.M_PTR + 1;
                                l.M_CHAR_PTR = l.M_CHAR_PTR + 1;
                            if l.M_CHAR_PTR < l.M_CHAR_PTR_MAX:
                                
                                def RESET():
                                    EXPAND(0);
                                    if l.M_CHAR_PTR == 0:
                                        l.M_PTR = MAX(MIN(INDENT_LEVEL, l.INDENT_LIMIT), 0);
                                    else:
                                        l.M_PTR = 0;  
                                        l.LINE_CONTINUED = g.TRUE;  
                                    
                                RESET();
                                if g.SQUEEZING: 
                                    g.SQUEEZING = g.FALSE;
                                    g.GRAMMAR_FLAGS[l.PTR] |= PRINT_FLAG;
                                    goto_OUTPUT_WRITER_END = True
                                    break
                                goto_MORE_M_C = True
                                continue
                        if goto_OUTPUT_WRITER_END:
                            break
                        l.M_CHAR_PTR_MAX = 0;
                if not ss or goto_PTR_LOOP_END or goto_STLABEL:  # had been ELSE
                    if g.STMT_STACK[l.PTR] == REPLACE_TEXT \
                            and not goto_STLABEL and not goto_PTR_LOOP_END:
                        if (g.GRAMMAR_FLAGS[l.PTR] & PRINT_FLAG) == 0:
                            if not RECOVERING: 
                                goto_PTR_LOOP_END = True
                        if not goto_PTR_LOOP_END:
                            l.M_PTR = l.M_PTR + 1;
                            l.M_CHAR_PTR = SYT_ADDR(MAC_NUM);
                            l.BUILD_M = BYTE(l.BUILD_M, l.M_PTR, BYTE('"'));
                            l.M_PTR = l.M_PTR + 1;
                            
                            def PRINT_TEXT(LINELENGTH):
                                WAS_HERE = g.FALSE;
                                J = MACRO_TEXT(l.M_CHAR_PTR);
                                goto_LINEDONE = True
                                while goto_LINEDONE:
                                    goto_LINEDONE = False
                                    while J != 0xEF and l.M_PTR < LINELENGTH:
                                        if J == 0xEE: 
                                            l.M_CHAR_PTR = l.M_CHAR_PTR + 1;
                                            J = MACRO_TEXT(l.M_CHAR_PTR);
                                            if J == 0: 
                                                l.M_CHAR_PTR = l.M_CHAR_PTR + 1;
                                                return;
                                            goto_NEXT_LINE = True
                                            while goto_NEXT_LINE:
                                                goto_NEXT_LINE = False
                                                if (J + l.M_PTR) >= LINELENGTH: 
                                                    J = J - LINELENGTH + l.M_PTR;
                                                    RESET();
                                                    goto_NEXT_LINE = True
                                                    continue
                                                else:
                                                    l.M_PTR = l.M_PTR + J;
                                        elif J == BYTE('"'): 
                                            if WAS_HERE: 
                                                WAS_HERE = g.FALSE;
                                            else:
                                                WAS_HERE = g.TRUE;
                                                l.M_CHAR_PTR = l.M_CHAR_PTR - 1;
                                            l.BUILD_M = BYTE(l.BUILD_M, l.M_PTR, J);
                                        else:
                                            l.BUILD_M = BYTE(l.BUILD_M, l.M_PTR, J);
                                        l.M_PTR = l.M_PTR + 1;
                                        l.M_CHAR_PTR = l.M_CHAR_PTR + 1;
                                        J = MACRO_TEXT(l.M_CHAR_PTR);
                                    if J != 0xEF: 
                                        RESET();
                                        goto_LINEDONE = True
                                        continue
                                if l.M_PTR == LINELENGTH: 
                                    RESET();
                    
                            PRINT_TEXT(l.LINESIZE);
                            l.BUILD_M = BYTE(l.BUILD_M, l.M_PTR, BYTE('"'));
                            l.M_PTR = l.M_PTR + 1;
                    elif not goto_PTR_LOOP_END:
                        # NOT A CHARACTER STRING
                        if not goto_STLABEL:
                            g.C[0] = ATTACH(l.PTR, 0);
                            if LENGTH(g.C[0]) == 0: 
                                goto_PTR_LOOP_END = True
                            else:
                                l.M_PTR = l.M_PTR + l.SPACE_NEEDED;
                                if LENGTH(g.C[0]) + l.M_PTR >= l.LINESIZE:
                                    EXPAND(l.PTR - 1);
                                    if g.SQUEEZING:
                                        g.SQUEEZING = g.FALSE;
                                        g.GRAMMAR_FLAGS[l.PTR] |= PRINT_FLAG;
                                        goto_OUTPUT_WRITER_END = True
                                        break
                                    l.M_PTR = MIN(INDENT_LEVEL, l.INDENT_LIMIT);
                        if (l.PTR == l.PTR_START or goto_STLABEL) and \
                                not goto_PTR_LOOP_END:
                            goto_STLABEL = False
                            if LABEL_COUNT > 0:
                                l.TEMP = 0;
                                l.LABEL_TOO_LONG = g.TRUE;
                                for I in range(l.LABEL_START, l.LABEL_END + 2, 2):
                                    J = TOKEN_FLAGS(I);
                                    l.TEMP = l.TEMP + LENGTH(SAVE_BCD(SHR(J, 6))) + 2;
                                if ((NEST_LEVEL == 0) and (l.TEMP <= l.M_PTR)) \
                                        or ((NEST_LEVEL < 10) and \
                                            (l.TEMP < (l.M_PTR - 1))) or \
                                            ((NEST_LEVEL >= 10) and \
                                              (l.TEMP < (l.M_PTR - 2))):
                                    J = l.M_PTR - l.TEMP;
                                    l.LABEL_TOO_LONG = g.FALSE;
                                else:
                                    J = 0;
                                for I in range(l.LABEL_START, l.LABEL_END + 2, 2):
                                    K = TOKEN_FLAGS(I);
                                    S = SAVE_BCD(SHR(K, 6));
                                    if (LENGTH(S) + 2 + J) > l.LINESIZE: 
                                        J = I;
                                        l.CHAR = S;
                                        EXPAND(0);
                                        I = J;
                                        S = l.CHAR;
                                        J = 0;
                                    for L in range(0, LENGTH(S)):
                                        K = BYTE(S, L);
                                        l.BUILD_M = BYTE(l.BUILD_M, J + L, K);
                                    l.BUILD_M = BYTE(l.BUILD_M, J + L, BYTE(':'));
                                    J = J + L + 2;
                                if l.LABEL_TOO_LONG:
                                    EXPAND(0);
                                LABEL_COUNT = 0;
                            if l.PRINT_LABEL: 
                                goto_AFTER_EXPAND = True
                            else:
                                for I in range(0, LENGTH(g.C[0])):
                                    J = BYTE(g.C[0], I);
                                    l.BUILD_M = BYTE(l.BUILD_M, l.M_PTR + I, J);
                                I = TOKEN_FLAGS(l.PTR) & 0x1F;  # TYPE FOR OVERPUNCH
                                if I > 0:
                                    if (I < SCALAR_TYPE) or (I == MAJ_STRUC):
                                        K = OVER_PUNCH_TYPE(I);
                                        I = (SHL(l.M_PTR, 1) - 1 + LENGTH(g.C[0])) / 2;
                                        l.BUILD_E = BYTE(l.BUILD_E, I, K);
                                        l.BUILD_E_IND[I] = 1;
                                        if l.MAX_E_LEVEL == 0:
                                            MAX_E_LEVEL = 1;
                                if (g.GRAMMAR_FLAGS[l.PTR] & MACRO_ARG_FLAG) != 0:
                                    # REPLACE NAME, SO UNDERLINE IT
                                    if I == 7:
                                        l.MACRO_WRITTEN = g.TRUE;
                                    for I in range(0, LENGTH(g.C[0])):
                                        l.M_UNDERSCORE = BYTE(l.M_UNDERSCORE, l.M_PTR + I, BYTE('_'));
                                    l.M_UNDERSCORE_NEEDED = g.TRUE;
                                l.M_PTR = l.M_PTR + LENGTH(g.C[0]);
                    goto_PTR_LOOP_END = False
            # END OF DO PTR = PTR_START TO PTR_END
            if not goto_AFTER_EXPAND and not goto_OUTPUT_WRITER_END:
                EXPAND(l.PTR_END);  # EXPAND BUFFERS
                if l.monitorLabel != None:
                    return l.PTR
                if g.SQUEEZING and (l.PTR > OUTPUT_STACK_MAX - 2): 
                    if l.PTR > l.PTR_END + 1: 
                        l.PTR = l.PTR_END + 1;
                    g.SQUEEZING = g.FALSE;
                    if (l.SUB_START != 0) and \
                            ((g.STMT_STACK[l.SUB_END + 1] == g.DOLLAR) or \
                             (g.STMT_STACK[l.PTR_END] == g.EXPONENTIATE)):
                        ERROR (d.CLASS_BS, 6);
                    if (l.EXP_START != 0) and \
                            ((g.STMT_STACK[l.PTR_END] == g.DOLLAR) or \
                             (g.STMT_STACK[l.EXP_END + 1] == g.EXPONENTIATE)):
                        ERROR (d.CLASS_BS, 6);
        goto_AFTER_EXPAND = False
        if l.PTR_END == g.STMT_PTR and not goto_OUTPUT_WRITER_END:
            if g.STMT_PTR == g.STMT_END_PTR: 
                g.STMT_END_PTR = -2;
            g.STMT_PTR = -1;
            g.BCD_PTR = 0
            g.LAST_WRITE = 0
            g.ELSEIF_PTR = 0;
        goto_OUTPUT_WRITER_END = False
        g.LAST_SPACE = 2;
        l.MACRO_WRITTEN = g.FALSE;
    goto_PRINT_ANY_ERRORS = False
    g.END_FLAG = g.FALSE;
    g.PAGE_THROWN = 0
    l.PTR_START = 0;
    l.PTR_END = -1;

    if g.STMT_PTR == -1:  # ALL TOKEN WRITTEN
        if l.LAST_ERROR_WRITTEN < g.LAST: 
            # GET ALL ERRORS
            l.CURRENT_ERROR_PTR = g.LAST;
            ERROR_PRINT();
    if l.ERRORS_PRINTED: 
        if g.TOO_MANY_ERRORS:
            ERRORS (d.CLASS_BI, 101);
            g.TOO_MANY_ERRORS = g.FALSE;
        if g.OUT_PREV_ERROR != 0:
            OUTPUT(0, '***** LAST ERROR WAS DETECTED AT STATEMENT ' + \
                        g.OUT_PREV_ERROR + g.PERIOD + g.X1 + g.STARS);
        g.OUT_PREV_ERROR = g.STMT_NUM();
        if l.LAST_ERROR_WRITTEN >= g.LAST:
            l.LAST_ERROR_WRITTEN = -1
            l.CURRENT_ERROR_PTR = -1
            g.LAST = -1;
        # END OF DO WHEN ERRORS_PRINTED
    g.SAVE_SCOPE = g.CURRENT_SCOPE;
    if g.STACK_DUMPED: 
        for I in range(0, g.STACK_DUMP_PTR + 1):
            OUTPUT(0, SAVE_STACK_DUMP(I));  
        g.STACK_DUMP_PTR = -1;
        g.STACK_DUMPED = g.FALSE;
    return l.PTR;
