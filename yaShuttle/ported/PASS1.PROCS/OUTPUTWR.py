#!/usr/bin/env python
'''
Access:     Public Domain, no restrictions believed to exist.
Filename:   OUTPUTWR.xpl
Purpose:    This is a part of "Phase 1" (syntax analysis) of the HAL/S-FC
            compiler program.
Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
Language:   XPL.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-08-25 RSB  Created place-holder file.
            2023-10-14 RSB  Completed 3rd independent port of this module,
                            reconciling all 3, and it still doesn't print
                            some of the spaces around identifiers or numbers
                            properly.  For example, 
                                C = 4 2 A + 6 3 1.2 B + 1;
                            prints as
                                C= 42A+ 631.2B+ 1;
                            Whereas stuff like 
                                S = M$(2,1); /* M matrix */
                            prints perfectly (except the space after D) as
                                    2   -
                                D= C  + V ;
                                         2
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ERROR    import ERROR
from BLANK    import BLANK
from CHARINDE import CHAR_INDEX
from IFORMAT  import I_FORMAT
from OUTPUT_WRITER_DISASTER import OUTPUT_WRITER_DISASTER
from HALINCL.CHECKDWN import CHECK_DOWN

debugwr = ("--debugwr" in sys.argv[1:])

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


class cEXPAND:

    def __init__(self):
        self.C = ''
        self.CHAR = ''
        self.M_COMMENT_NEEDED = g.FALSE
        self.S_COMMENT_NEEDED = g.FALSE
        self.POST_COMMENT_NEEDED = g.FALSE
        self.NUM_S_NEEDED = 0
        self.LOC = 0
        self.NUM = 0
        self.BUILD = ' ' * 100
        self.FORMAT_CHAR = '|'


lEXPAND = cEXPAND()


class cCOMMENT_BRACKET:

    def __init__(self):
        self.PTR = 0

        
lCOMMENT_BRACKET = cCOMMENT_BRACKET()


def OUTPUT_WRITER(PTR_START=None, PTR_END=None):

    from ERRORS   import ERRORS

    # Note that the only overlap detected between the locals and globals in
    # g.py were TEMP, SEVERITY, and INCLUDE_COUNT, so take care to distinguich
    # between g. and l. for those.
    l = lOUTPUT_WRITER
    if PTR_START != None:
        l.PTR_START = PTR_START
    if PTR_END != None:
        l.PTR_END = PTR_END
    onEntry = True # Used only by debug() function.

    # Workaround-variable for spaghetti GO TO's and their target labels.
    goto = None

    l.ERRORS_PRINTED = g.FALSE;
    if g.STMT_PTR < 0: 
        goto = "PRINT_ANY_ERRORS";
    else:
        goto = "OUTPUT_WRITER_BEGINNING";  # COLLECT A FEW BRANCHES

    def ERROR_PRINT():
        # Locals are C and NEW_SEVERITY.

        for g.I in range(l.LAST_ERROR_WRITTEN + 1, l.CURRENT_ERROR_PTR + 1):
            l.ERRORS_PRINTED = g.TRUE;
            g.ERROR_COUNT = g.ERROR_COUNT + 1;
            g.SAVE_LINE_p[g.ERROR_COUNT] = g.STMT_NUM();
            C = g.SAVE_ERROR_MESSAGE[g.I];
            l.ERRORCODE = SUBSTR(C, 0, 8);  # MEMBER NAME
            if MONITOR(2, 5, l.ERRORCODE):
            # DO;
                ERRORS(d.CLASS_BI, 100, g.X1 + l.ERRORCODE);
                continue  # GO TO ERROR_PRINT_END;
            # END
            g.S = INPUT(5);  # READ FROM ERROR FILE
            l.SEVERITY = BYTE(g.S) - BYTE('0');
            NEW_SEVERITY = CHECK_DOWN(l.ERRORCODE, l.SEVERITY);
            l.SEVERITY = NEW_SEVERITY;
            g.SAVE_SEVERITY[g.ERROR_COUNT] = l.SEVERITY;
            if LENGTH(C) > 8:
            # DO;
                # SOME IMBEDDED TEXT EXISTS
                C = SUBSTR(C, 8);
                l.IMBEDDING = g.TRUE;
            # END
            if g.ERROR_COUNT >= g.ERRLIM - 3:
            # DO;
                g.MAX_SEVERITY = MAX(g.MAX_SEVERITY, 2);
                if l.PRNTERRWARN:
                # DO;
                    l.PRNTERRWARN = g.FALSE;
                    ERRORS(d.CLASS_BI, 106);
                # END
                if g.COMPILING:
                    g.COMPILING = g.FALSE;
                else:
                    OUTPUT_WRITER_DISASTER()
            # END
            OUTPUT(1, '0***** ' + l.ERRORCODE + ' ERROR #' + \
                   str(g.ERROR_COUNT) + ' OF SEVERITY ' + str(l.SEVERITY) \
                   + '. *****');
            if l.SEVERITY > g.MAX_SEVERITY:
                g.MAX_SEVERITY = l.SEVERITY;
            if l.SEVERITY > g.STATEMENT_SEVERITY:
                g.STATEMENT_SEVERITY = l.SEVERITY;
            g.S = INPUT(5);
            while LENGTH(g.S) > 0:
                if l.IMBEDDING:
                # DO;
                    g.K = CHAR_INDEX(g.S, '??');
                    if g.K >= 0:
                    # DO;
                        if g.K == 0:
                            g.S = C + SUBSTR(g.S, 2);
                        else:
                            g.S = SUBSTR(g.S, 0, g.K) + C + SUBSTR(g.S, g.K + 2);
                        l.IMBEDDING = g.FALSE;
                    # END
                # END
                OUTPUT(0, g.STARS + g.X1 + g.S);
                g.S = INPUT(5);
            # END
          # ERROR_PRINT_END:
        # END OF LOOP ON ERROR MSGS
        l.LAST_ERROR_WRITTEN = l.CURRENT_ERROR_PTR;
    # END ERROR_PRINT;
    
    def ATTACH(PNTR, OFFSET):
        # No locals.
        nonlocal onEntry # Used only by debug() function.
        ols = g.LAST_SPACE
        goto = None
        
        # Prints messages that I hope will help me figure out why spaces
        # sometimes aren't added correctly.
        def debug():
            if not debugwr:
                return
            nonlocal onEntry # Tracks whether a linefeed is needed before print.
            if onEntry:
                print("\n", file=sys.stderr)
                onEntry = False
            print(("PNTR=%d, TOKEN=%d, LAST_SPACE=%d, NEEDED=%d, VOCAB='%s', " \
                   + "BCD='%s', " + \
                  "SPACES=0x%02X, FLAGS=0x%02X, C[0]='%s', BUILD_M='%s'") \
                  % (PNTR, g.STMT_STACK[PNTR], ols, l.SPACE_NEEDED,
                     g.VOCAB_INDEX[g.STMT_STACK[PNTR]], 
                     g.SAVE_BCD[SHR(g.TOKEN_FLAGS(PNTR), 6)],
                     g.SPACE_FLAGS[g.STMT_STACK[PNTR]],
                     g.TOKEN_FLAGS(PNTR), g.C[0],
                     l.BUILD_M), file=sys.stderr)
        # End of debug()
        
        l.CURRENT_ERROR_PTR = MAX(l.CURRENT_ERROR_PTR, g.ERROR_PTR[PNTR]);
        if g.STMT_STACK[PNTR] == 0: 
        # DO;
            l.SPACE_NEEDED = 0;
            return '';
        # END
        if (g.GRAMMAR_FLAGS(PNTR) & g.PRINT_FLAG) == 0:
            if not g.RECOVERING:
                return '';
        g.GRAMMAR_FLAGS(PNTR, g.GRAMMAR_FLAGS(PNTR) & g.PRINT_FLAG_OFF);
        l.SPACE_NEEDED = 1;
        if l.MACRO_WRITTEN: 
        # DO;
            l.MACRO_WRITTEN = g.FALSE;
            if g.LAST_SPACE == 2:
                if SHR(g.TOKEN_FLAGS(PNTR), 6) == 0:
                    if g.STMT_STACK[PNTR] == g.LEFT_PAREN:
                        goto = "PARAM_MACRO";  # LEAVE LAST_SPACE ALONE
            if goto == None:
                g.LAST_SPACE = 0;  # FORCE A SPACE AFTER A NON-PARAM MACRO NAME
        # END
        if goto == "PARAM_MACRO": goto = None
        g.L = g.SPACE_FLAGS[g.STMT_STACK[PNTR] + OFFSET];  # SELECT LINE TYPE
        g.I = SHR(g.L, 4) + g.LAST_SPACE;
        if g.I <= 4:
            if g.I > 1:
                l.SPACE_NEEDED = 0;
        if SHR(g.TOKEN_FLAGS(PNTR), 5) & 1:
            g.LAST_SPACE = 2;
        else:
            g.LAST_SPACE = g.L & 0x0F;
        if SHR(g.TOKEN_FLAGS(PNTR), 6) == 0:
            g.C[0] = g.VOCAB_INDEX[g.STMT_STACK[PNTR]];
        else:
        # DO;
            g.J = g.TOKEN_FLAGS(PNTR);
            g.C[0] = g.SAVE_BCD[SHR(g.J, 6)];  # IDENTIFIER
            if g.STMT_STACK[PNTR] == g.CHARACTER_STRING:
            # DO;

                def ADD(STRING):
                    # T is local
                    if LENGTH(g.C[g.K]) + LENGTH(STRING) > 256:
                    # DO;
                        l.TEMP = 256 - LENGTH(g.C[g.K]);
                        T = SUBSTR(STRING, 0, l.TEMP);
                        g.C[g.K] = g.C[g.K] + T;
                        g.K = g.K + 1;
                        g.C[g.K] = SUBSTR(STRING, l.TEMP);
                    # END
                    else:
                        g.C[g.K] = g.C[g.K] + STRING;
                # END ADD;
                
                g.C[1] = ''
                g.C[2] = '';
                if (g.GRAMMAR_FLAGS(PNTR) & g.MACRO_ARG_FLAG) != 0: 
                    debug()
                    return g.C[0];
                g.S = g.C[0];
                g.C[0] = g.SQUOTE;
                g.I = 0
                g.J = 0
                g.K = 0;
                goto = "SEARCH"
                while goto == "SEARCH":
                    if goto == "SEARCH": goto = None
                    while (BYTE(g.S, g.I) != BYTE(g.SQUOTE)) and (g.I < LENGTH(g.S)):
                        if OFFSET != 0:  # NOT AN M-LINE
                        # DO;
                            if (g.TRANS_OUT[BYTE(g.S, g.I)] & 0xFF) != 0:
                            # DO;
                                if g.I != g.J:
                                    ADD(SUBSTR(g.S, g.J, g.I - g.J));
                                for g.L in range(0, (SHR(g.TRANS_OUT[BYTE(g.S, g.I)], 8) \
                                                    & 0xFF) + 1):
                                    ADD(STRING[ADDR(g.ESCP)]);
                                # END
                                ADD(STRING[ADDR(g.TRANS_OUT[BYTE(g.S, g.I)]) + 1]);
                                g.I = g.I + 1;
                                g.J = g.I
                            # END
                            else:
                                g.I = g.I + 1;
                        # END
                        else:
                            g.I = g.I + 1;
                    # END
                    if g.I != g.J:
                        ADD(SUBSTR(g.S, g.J, g.I - g.J));
                    if g.I != LENGTH(g.S):
                    # DO;
                        ADD(g.SQUOTE + g.SQUOTE);
                        g.I = g.I + 1;
                        g.J = g.I;
                        goto = "SEARCH"
                        continue
                    # END
                ADD(g.SQUOTE);
                debug()
                return g.C[0];
            # END
            g.J = g.GRAMMAR_FLAGS(PNTR);
            if (g.J & g.LEFT_BRACKET_FLAG) != 0:
                g.C[0] = '[' + g.C[0];
            if (g.J & g.RIGHT_BRACKET_FLAG) != 0:
               g.C[0] = g.C[0] + ']';
            if (g.J & g.LEFT_BRACE_FLAG) != 0:
                g.C[0] = '{' + g.C[0];
            if (g.J & g.RIGHT_BRACE_FLAG) != 0:
                g.C[0] = g.C[0] + '}';
        # END
        debug()
        return g.C[0];
    # END ATTACH;
    
    def EXPAND(PTR):
        # PTR overlaps with the l. namespace, as does CHAR in the locals,
        # so take care.  The other locals are C, M_COMMENT_NEEDED,
        # S_COMMENT_NEEDED, POST_COMMENT_NEEDED, NUM_S_NEEDED, LOC, NUM,
        # BUILD, FORMAT_CHAR.
        nonlocal onEntry # Used only by debug() function.
        ll = lEXPAND
        
        if (g.GRAMMAR_FLAGS(PTR) & g.STMT_END_FLAG) != 0:
            if g.COMMENT_COUNT >= 0:
            # DO;
                g.COMMENT_COUNT = MIN(g.COMMENT_COUNT, 255);
    
                '''
                Something goofy is going on with PTR in the following
                procedure.  The original XPL (within COMMENT_BRACKET) for PTR
                reads:
                    DECLARE STRING CHARACTER, (LOC, I, J, PTR) BIT(16);
                However, in its first use,
                    DO I = PTR TO MIN(PTR + NUM, COMMENT_COUNT);
                it has not yet been assigned a value.  Due to persistence, it
                is assigned a value later on in COMMENT_BRACKET, and will 
                retain that value on the next call to COMMENT_BRACKET, but is
                definitely unassigned in the first call.  There doesn't seem to
                be any choice other than to initialize it to *some* value,
                and the likely candidate would be 0.
                '''
                def COMMENT_BRACKET(STRING, LOC):
                    # Take care with LOC and locals I, J for potential 
                    # namespace conflicts.
                    lll = lCOMMENT_BRACKET
                    
                    STRING = BYTE(STRING, LOC, BYTE('/'));
                    STRING = BYTE(STRING, LOC + 1, BYTE('*'));
                    LOC = LOC + 2;
                    for I in range(lll.PTR, MIN(lll.PTR + ll.NUM, g.COMMENT_COUNT) + 1):
                        J = BYTE(g.SAVE_COMMENT, I);
                        STRING = BYTE(STRING, LOC, J);
                        LOC = LOC + 1;
                    # END
                    I += 1  # Terminal value of for-loop differs for XPL vs Python.
                    STRING = BYTE(STRING, LOC, BYTE('*'));
                    STRING = BYTE(STRING, LOC + 1, BYTE('/'));
                    lll.PTR = I;
                    ll.NUM = MIN(ll.NUM, g.COMMENT_COUNT - lll.PTR + 1);
                    if ll.NUM <= 0:
                    # DO;
                        lll.PTR = 0;
                        g.COMMENT_COUNT = -1;
                    # END
                    return STRING
                # END COMMENT_BRACKET;
                
                g.COMMENT_COUNT = MIN(g.COMMENT_COUNT, 255);
                g.I = g.COMMENT_COUNT;
                while BYTE(g.SAVE_COMMENT, g.COMMENT_COUNT) == BYTE(g.X1):
                    g.COMMENT_COUNT = g.COMMENT_COUNT - 1;
                # END
                g.COMMENT_COUNT = g.COMMENT_COUNT + (g.COMMENT_COUNT != g.I);
                g.I = MAX(l.M_PTR, l.COMMENT_LOC + 1);
                if g.COMMENT_COUNT < l.LINESIZE - g.I - 4:
                # DO;
                    # COMMENT WILL FIT ON M LINE
                    ll.M_COMMENT_NEEDED = g.TRUE;
                    ll.LOC = g.I;
                    ll.NUM = g.COMMENT_COUNT;
                # END
                elif g.COMMENT_COUNT < l.LINESIZE - l.M_PTR - 5:
                # DO;
                    # WILL FIT IF RIGHT JUSTIFIED
                    ll.M_COMMENT_NEEDED = g.TRUE;
                    ll.LOC = l.LINESIZE - g.COMMENT_COUNT - 5;
                    ll.NUM = g.COMMENT_COUNT;
                # END
                elif l.M_PTR < l.COMMENT_LOC:
                # DO;
                    # NEED MORE THAN ONE LINE
                    ll.M_COMMENT_NEEDED = g.TRUE
                    ll.S_COMMENT_NEEDED = g.TRUE;
                    ll.LOC = l.M_PTR + 1;
                    ll.NUM = l.LINESIZE - ll.LOC - 5;
                    ll.NUM_S_NEEDED = (g.COMMENT_COUNT - 1) // ll.NUM;
                    l.MAX_S_LEVEL = MAX(ll.NUM_S_NEEDED, l.MAX_S_LEVEL);
                # END
                else: 
                # DO;
                    ll.POST_COMMENT_NEEDED = g.TRUE;
                    ll.LOC = l.COMMENT_LOC;
                    ll.NUM = l.LINESIZE - ll.LOC - 5;
                # END
            # END
        if l.MAX_E_LEVEL + MAX(l.MAX_S_LEVEL, g.SDL_OPTION) + 2 + \
                LINE_COUNT > g.LINE_MAX:
            ll.C = g.PAGE;
        else:
            ll.C = g.NEXT_CC;
        g.NEXT_CC = g.X1;  # UNLESS CHANGED BELOW
        g.LINE_MAX = g.LINE_LIM;
        g.S = I_FORMAT(g.STMT_NUM(), 4);
        if (g.INCLUDING or g.INCLUDE_END): 
        # DO;
            g.INCLUDE_CHAR = g.PLUS;
            if g.SRN_PRESENT:
                g.S = LEFT_PAD(g.PLUS + str(l.INCLUDE_COUNT), 6) \
                        + g.X1 + g.S;
            l.T = g.PAD1[:];
        # END
        else:  # NOT AN INCLUDED LINE
        # DO;
            g.INCLUDE_CHAR = g.X1;
            if g.SRN_PRESENT:
                g.S = SUBSTR(l.SDL_INFO, 0, 6) + g.X1 + g.S;  # SRN
            if g.SDL_OPTION:
            # DO;
                l.T = l.C_RVL;  # RECORD REVISION INDICATOR
                if LENGTH(l.SDL_INFO) >= 16:
                    l.T = l.T + g.X1 + SUBSTR(l.SDL_INFO, 8, 8);
                else:
                    l.T = l.T + SUBSTR(g.X70, 0, 9);
            # END
            else:
                l.T = g.PAD1[:];
        if l.MAX_E_LEVEL != 0:
            while l.MAX_E_LEVEL != 0:
                ll.BUILD = BLANK(ll.BUILD, 0, l.LINESIZE);
                for g.I in range(0, l.LINESIZE):
                    if l.BUILD_E_IND[g.I] == l.MAX_E_LEVEL:
                    # DO;
                        l.BUILD_E_IND[g.I] = 0;
                        g.K = BYTE(l.BUILD_E, g.I);
                        ll.BUILD = BYTE(ll.BUILD, g.I, g.K);
                    # END
                    if l.BUILD_E_UND[g.I] == l.MAX_E_LEVEL:
                    # DO;
                        # SOME UNDERLINING TO BE DONE
                        l.BUILD_E_UND[g.I] = 0;
                        l.UNDER_LINE = BYTE(l.UNDER_LINE, g.I, BYTE('_'));
                        l.UNDERLINING = g.TRUE;
                    # END
                # END
                # PRINT A BLANK LINE BEFORE E-LINES.
                if (ll.C != g.PAGE) and (not g.PREV_ELINE): 
                    ll.C = g.DOUBLE;
                # SINCE REVISION LEVEL IS PRINTED ON M-LINE
                # FOR SDL, LEAVE BLANK SPACE ON E-LINE.
                if g.SDL_OPTION:
                    OUTPUT(1, ll.C + g.PAD1 + g.INCLUDE_CHAR + 'E' + g.VBAR + \
                                ll.BUILD + g.VBAR + g.X1 + g.VBAR);
                else:
                    OUTPUT(1, ll.C + g.PAD1 + g.INCLUDE_CHAR + 'E' + g.VBAR + \
                                ll.BUILD + g.VBAR);
                g.PREV_ELINE = g.TRUE;
                if l.UNDERLINING:
                # DO;
                    l.UNDERLINING = g.FALSE;
                    OUTPUT(1, g.PLUS + g.PAD2 + l.UNDER_LINE);
                    l.UNDER_LINE = BLANK(l.UNDER_LINE, 0, l.LINESIZE);
                # END
                l.MAX_E_LEVEL = l.MAX_E_LEVEL - 1;
                ll.C = g.X1;
            # END
            l.BUILD_E = BLANK(l.BUILD_E, 0, l.LINESIZE);
        # END
        if ll.M_COMMENT_NEEDED:
        # DO;
            l.BUILD_M = COMMENT_BRACKET(l.BUILD_M, ll.LOC);
            ll.M_COMMENT_NEEDED = g.FALSE;
        # END
        if not l.LINE_CONTINUED:
            if g.NEST_LEVEL > 0:
                if BYTE(l.BUILD_M, 1) == BYTE(g.X1):
                # DO;
                    '''
                    The original code XPL code here was a trap waiting to
                    snap shut, so let me explain. Here's the original:
                        CHAR = NEST_LEVEL;
                        IF NEST_LEVEL < 10 THEN
                           BYTE(BUILD_M) = BYTE(CHAR);
                        ELSE DO;
                           BYTE(BUILD_M) = BYTE(CHAR);
                           BYTE(BUILD_M,1) = BYTE(CHAR,1);
                    NEST_LEVEL is an integer and CHAR is a string, so what the
                    first statement does is to convert NEST_LEVEL to a string.
                    The next statements either replace the first character of
                    BUILD_M by the digits 1-9, or else to replace the first
                    two characters of BUILD_M by "01"-"99".  All of this in
                    service of the fact that OUTPUTWR will indent due to 
                    nesting by at most a single level.  Higher levels are 
                    indicated instead by just the printed number.
                    '''
                    ll.CHAR = str(g.NEST_LEVEL);
                    if g.NEST_LEVEL < 10:
                        l.BUILD_M = BYTE(l.BUILD_M, 0, BYTE(ll.CHAR));
                    else:
                    # DO;
                        l.BUILD_M = BYTE(l.BUILD_M, 0, BYTE(ll.CHAR));
                        l.BUILD_M = BYTE(l.BUILD_M, 1, BYTE(ll.CHAR, 1));
                    # END
                # END
        # ON THE END STATEMENT, REPLACE THE CURRENT SCOPE WITH
        # THE STATEMENT NUMBER OF THE DO STATEMENT.  ON THE CASES OF THE
        # CASE STATEMENT, MOVE THE INFORMATION FIELD IDENTIFYING THE
        # CASE NUMBER TO REPLACE THE CURRENT SCOPE INSTEAD OF PRINTING
        # IT AFTER THE CURRENT SCOPE.  FOR IF-THEN-DO STATEMENTS, REPLACE
        # THE CURRENT SCOPE WITH THE STATEMENT NUMBER OF THE DO.
        if g.END_FLAG and (g.LABEL_COUNT == 0):
            ll.CHAR = 'ST#' + str(g.DO_STMTp[g.DO_LEVEL + 1]);
        elif (LENGTH(g.INFORMATION) > 0) and (g.LABEL_COUNT == 0):
        # DO;
            ll.CHAR = g.INFORMATION;
            g.INFORMATION = '';
        # END
        elif g.IF_FLAG and (g.LABEL_COUNT == 0):
            ll.CHAR = 'DO=ST#' + str(g.STMT_NUM() + 1);
        else:
            ll.CHAR = g.SAVE_SCOPE[:];
        # PRINT REVISION LEVEL ON M-LINE FOR SDL
        if g.SDL_OPTION:
            ll.C = ll.C + g.S + g.INCLUDE_CHAR + 'M' + g.VBAR + l.BUILD_M + \
                    ll.FORMAT_CHAR + SUBSTR(l.T, 0, 2) + ll.FORMAT_CHAR;
        else:
            ll.C = ll.C + g.S + g.INCLUDE_CHAR + 'M' + g.VBAR + l.BUILD_M + ll.FORMAT_CHAR;
        OUTPUT(1, ll.C + ll.CHAR);
        onEntry = True
        g.PREV_ELINE = g.FALSE;
        if l.M_UNDERSCORE_NEEDED:
        # DO;
            l.M_UNDERSCORE_NEEDED = g.FALSE;
            OUTPUT(1, g.PLUS + g.PAD2 + l.M_UNDERSCORE);
            l.M_UNDERSCORE = BLANK(l.M_UNDERSCORE, 0, l.LINESIZE);
        # END
        l.BUILD_M = BLANK(l.BUILD_M, 0, l.LINESIZE);
        if l.MAX_S_LEVEL != 0:
        # DO;
            for g.J in range(1, l.MAX_S_LEVEL + 1):
                ll.BUILD = BLANK(ll.BUILD, 0, l.LINESIZE);
                for g.I in range(0, l.LINESIZE):
                    if l.BUILD_S_IND[g.I] == g.J:
                    # DO;
                        l.BUILD_S_IND[g.I] = 0;
                        g.K = BYTE(l.BUILD_S, g.I);
                        ll.BUILD = BYTE(ll.BUILD, g.I, g.K);
                    # END
                    if l.BUILD_S_UND[g.I] == g.J:
                    # DO;
                        l.BUILD_S_UND[g.I] = 0;
                        l.UNDER_LINE = BYTE(l.UNDER_LINE, g.I, BYTE('_'));
                        l.UNDERLINING = g.TRUE;
                    # END
                # END
                if ll.S_COMMENT_NEEDED:
                    if g.J <= ll.NUM_S_NEEDED:
                        ll.BUILD = COMMENT_BRACKET(ll.BUILD, ll.LOC);
                # PRINT A BLANK LINE AFTER  S-LINES.
                g.NEXT_CC = g.DOUBLE;
                # SINCE REVISION LEVEL IS PRINTED ON M-LINE
                # FOR SDL, LEAVE BLANK SPACE ON S-LINE.
                if g.SDL_OPTION:
                    OUTPUT(1, g.X1 + g.PAD1 + g.INCLUDE_CHAR + 'S' + g.VBAR + \
                                ll.BUILD + g.VBAR + g.X1 + g.VBAR);
                else:
                    OUTPUT(1, g.X1 + g.PAD1 + g.INCLUDE_CHAR + 'S' + g.VBAR + \
                                ll.BUILD + g.VBAR);
                g.PREV_ELINE = g.FALSE;
                if l.UNDERLINING:
                # DO;
                    l.UNDERLINING = g.FALSE;
                    OUTPUT(1, g.PLUS + g.PAD2 + l.UNDER_LINE);
                    l.UNDER_LINE = BLANK(l.UNDER_LINE, 0, l.LINESIZE);
                # END
            # END
            l.BUILD_S = BLANK(l.BUILD_S, 0, l.LINESIZE);
        # END
        ll.S_COMMENT_NEEDED = g.FALSE;
        l.MAX_S_LEVEL = 0
        l.MAX_E_LEVEL = 0;
        if ll.POST_COMMENT_NEEDED:
        # DO;
            while ll.NUM > 0:
                ll.BUILD = BLANK(ll.BUILD, 0, l.LINESIZE);
                ll.BUILD = COMMENT_BRACKET(ll.BUILD, ll.LOC);
                OUTPUT(1, g.X1 + g.PAD2 + ll.BUILD);
            # END
            ll.POST_COMMENT_NEEDED = g.FALSE;
        # END
        
        ERROR_PRINT();
        l.LINE_CONTINUED = g.FALSE;
    # END EXPAND;
    
    def MATCH(START):
        # Locals: NUM_LEFT, NUM_RIGHT
        ''' THIS PROCEDURE SEARCHES THE STMT_STACK STARTING AT START FOR
            MATCHING OPEN/CLOSE PAREN PAIRS.  IT REPLACES MATCHING OUTER
            PAIRS WITH ZEROS UNLESS THE "FIND_ONLY" FLAG IS ON. IT RETURNS A 
            VALUE WHICH IS THE INDEX OF THE OUTERMOST ")". '''
        g.I = START;
        NUM_LEFT = 1;
        NUM_RIGHT = 0;
        while (NUM_LEFT > NUM_RIGHT) and (g.I <= l.PTR_END):
            g.I = g.I + 1;
            if g.STMT_STACK[g.I] == g.LEFT_PAREN:
                NUM_LEFT = NUM_LEFT + 1;
            elif g.STMT_STACK[g.I] == g.RT_PAREN:
                NUM_RIGHT = NUM_RIGHT + 1;
        # END
        if NUM_LEFT == NUM_RIGHT:
            if (g.STMT_STACK[START] == g.LEFT_PAREN) and \
                    (g.STMT_STACK[g.I] == g.RT_PAREN):
                if not l.FIND_ONLY:
                    g.STMT_STACK[START] = 0
                    g.STMT_STACK[g.I] = 0;
        if NUM_LEFT != NUM_RIGHT: 
            ERROR(d.CLASS_BS, 6);
        return g.I;
    # END MATCH;
    
    def SKIP_REPL(POINT):
        # No locals.
        while ((g.TOKEN_FLAGS(POINT) & 0x1F) == 7) and (POINT <= l.PTR_END):
            POINT = POINT + 1;
        # END
        return POINT;
    # END SKIP_REPL;
    
    def CHECK_FOR_FUNC(START):
        # Locals are FINISH and DEPTH.
        FINISH = START;
        if (g.GRAMMAR_FLAGS(START) & g.FUNC_FLAG) != 0:
        # DO;
            # A FUNCTION - CHECK FOR SUBSCRIPTING AND ARGUMENTS
            DEPTH = 1;
            while (g.STMT_STACK[FINISH + 1] == g.DOLLAR) and \
                    ((FINISH + 1) < l.PTR_END):
                FINISH = FINISH + 2;
                if g.STMT_STACK[FINISH] == g.LEFT_PAREN:
                # DO;
                    l.FIND_ONLY = g.TRUE;
                    FINISH = MATCH(FINISH);
                    l.FIND_ONLY = g.FALSE;
                # END
                elif (g.GRAMMAR_FLAGS(FINISH) & g.FUNC_FLAG) != 0:
                    DEPTH = DEPTH + 1;
            # END OF DO WHILE...
            for DEPTH in range(0, DEPTH + 1):
                if (FINISH + 1) < l.PTR_END:
                    if g.STMT_STACK[FINISH + 1] == g.LEFT_PAREN:
                    # DO;
                        # ARGUMENT LIST
                        l.FIND_ONLY = g.TRUE;
                        FINISH = MATCH(FINISH + 1);
                        l.FIND_ONLY = g.FALSE;
                    # END
            # END
            if g.STMT_STACK[FINISH + 1] == g.LEFT_PAREN: 
                ERROR(d.CLASS_BS, 6);
        # END
        else: 
            # DO;
            goto = "START_SEARCH";
            while goto == "START_SEARCH" \
                            or (goto == None and \
                                g.STMT_STACK[START] == g.STRUC_TOKEN and \
                                g.STMT_STACK[DEPTH] == g.DOT_TOKEN):
                if goto == None:
                    FINISH = MIN(DEPTH + 1, l.PTR_END);
                if goto == "START_SEARCH": goto = None
                START = SKIP_REPL(FINISH);
                DEPTH = SKIP_REPL(START + 1);
            # END
        # END
        return FINISH;
    # END CHECK_FOR_FUNC;
    
    if not goto == "PRINT_ANY_ERRORS":
        if goto == "OUTPUT_WRITER_BEGINNING": goto = None
        l.PRINT_LABEL = g.FALSE;
        g.I = 2;
        l.SDL_INFO = g.SRN[g.I];
        l.INCLUDE_COUNT = g.SRN_COUNT[g.I];
        if not l.LINE_CONTINUED: 
            l.M_PTR = MAX(MIN(g.INDENT_LEVEL, l.INDENT_LIMIT), 0);
        if g.INLINE_INDENT_RESET >= 0: 
        # DO;
            g.INDENT_LEVEL = g.INLINE_INDENT_RESET;
            g.INLINE_INDENT_RESET = -1;
        # END
        if l.PTR_END == -1:
            l.PTR_END = g.STMT_PTR;
        if (l.PTR_END == g.OUTPUT_STACK_MAX) and g.SQUEEZING:
            l.PTR_END = l.PTR_END - 2;
        while ((g.GRAMMAR_FLAGS(l.PTR_START) & g.PRINT_FLAG) == 0) and \
                (l.PTR_START <= l.PTR_END):
            l.PTR_START = l.PTR_START + 1;
        # END
        if l.PTR_START > l.PTR_END:
            goto = "AFTER_EXPAND"
        else:
            # FIND MOST RECENT RVL. THE RVL FOR EACH TOKEN WAS SAVED IN SAVE_TOKEN
            if g.SDL_OPTION and (not g.INCLUDING) and (not g.INCLUDE_END):
            # DO;
                l.C_RVL = STRING(l.PTR_START, g.RVL_STACK1) + \
                                    STRING(l.PTR_START, g.RVL_STACK2);
                for l.IDX in range(l.PTR_START + 1, l.PTR_END + 1):
                    if ((g.GRAMMAR_FLAGS(l.IDX) & g.PRINT_FLAG) != 0):
                    # DO;
                        l.C_TMP = STRING(l.IDX, g.RVL_STACK1) + \
                                    STRING(l.IDX, g.RVL_STACK2);
                        if STRING_GT(l.C_TMP, l.C_RVL): 
                            l.C_RVL = l.C_TMP;
                    # END
                # END
                l.IDX += 1
                if STRING_GT(l.C_RVL, SUBSTR(g.SRN[2], 6, 2)):
                    g.SRN[2] = SUBSTR(g.SRN[2], 0, 6) + l.C_RVL;
            # END
            l.LABEL_START = l.PTR_START;
            if g.LABEL_COUNT > 0:
                while ((g.GRAMMAR_FLAGS(l.PTR_START) & g.LABEL_FLAG) != 0) \
                        and (l.PTR_START < l.PTR_END):
                    l.PTR_START = l.PTR_START + 2;
                # END
            l.LABEL_END = l.PTR_START - 1;
            while ((g.GRAMMAR_FLAGS(l.PTR_START) & g.PRINT_FLAG) == 0) and \
                        (l.PTR_START <= l.PTR_END):
                l.PTR_START = l.PTR_START + 1;
            # END
            if (l.PTR_START > l.PTR_END) and (g.LABEL_COUNT > 0): 
            # DO;
                l.PRINT_LABEL = g.TRUE;
                goto = "STLABEL";
            # END
            '''
            Note that the original DO FOR loop that follows has been 
            refactored as a DO WHILE to allow entry to it via GO TO STLABEL.
            Moreover, doing that has allowed the label PTR_LOOP_END which was
            formerly at the *end* of the DO FOR to move to the *beginning* of 
            the DO WHILE, and to implement GO TO PTR_LOOP_END as just continue.
            '''
            #DO PTR = PTR_START TO PTR_END;
            if goto == None:
                l.PTR = l.PTR_START - 1
            while goto in ["STLABEL", "PTR_LOOP_END"] \
                    or (goto == None and l.PTR < l.PTR_END):
                if goto == "PTR_LOOP_END": 
                    goto = None
                    if l.PTR >= l.PTR_END:
                        break
                if goto == None:
                    l.PTR += 1
                    
                    l.SUB_START[0] = 0
                    l.EXP_START[0] = 0;
                    if (g.GRAMMAR_FLAGS(l.PTR) & g.INLINE_FLAG) != 0: 
                        g.INLINE_INDENT = l.M_PTR + 1;
                    if g.STMT_STACK[l.PTR] == g.DOLLAR:
                    # DO;
                        l.PTR = l.PTR + 1;
                        l.SUB_START[0] = l.PTR;
                        l.S_LEVEL = 0;
                        if l.MAX_S_LEVEL == 0:
                            l.MAX_S_LEVEL = 1;
                        if g.STMT_STACK[l.SUB_START[0]] == g.LEFT_PAREN:
                        # DO;
                            l.SUB_END[0] = MATCH(l.SUB_START[0]);
                            if l.SUB_END[0] < l.PTR_END:
                                if g.STMT_STACK[l.SUB_END[0] + 1] == g.DOLLAR:
                                    if (l.SUB_END[0] - l.SUB_START[0]) > 2:
                                    # DO;
                                        g.STMT_STACK[l.SUB_START[0]] = TX(BYTE('('));
                                        g.STMT_STACK[l.SUB_END[0]] = TX(BYTE(')'));
                                    # END
                        # END
                        else:
                            l.SUB_END[0] = CHECK_FOR_FUNC(l.SUB_START[0]);
                        while (g.STMT_STACK[l.SUB_END[0] + 1] == g.DOLLAR) and \
                                    ((l.SUB_END[0] + 1) < l.PTR_END):
                            l.SUB_END[0] = l.SUB_END[0] + 2;
                            if g.STMT_STACK[l.SUB_END[0]] == g.LEFT_PAREN:
                            # DO;
                                l.FIND_ONLY = g.TRUE;
                                l.SUB_END[0] = MATCH(l.SUB_END[0]);
                                l.FIND_ONLY = g.FALSE;
                            # END
                            else:
                                l.SUB_END[0] = CHECK_FOR_FUNC(l.SUB_END[0]);
                        # END
                        l.PTR = l.SUB_END[0] + 1;
                    # END
                    if (g.STMT_STACK[l.PTR] == g.EXPONENTIATE) and (l.PTR < l.PTR_END):
                    # DO;
                        l.PTR = l.PTR + 1;
                        l.EXP_START[0] = l.PTR;
                        l.E_LEVEL = 0;
                        if l.MAX_E_LEVEL == 0:
                            l.MAX_E_LEVEL = 1;
                        if g.STMT_STACK[l.EXP_START[0]] == g.LEFT_PAREN:
                        # DO;
                            l.EXP_END[0] = MATCH(l.EXP_START[0]);
                            if l.EXP_END[0] < l.PTR_END:
                                if g.STMT_STACK[l.EXP_END[0] + 1] == g.EXPONENTIATE:
                                    if (l.EXP_END[0] - l.EXP_START[0]) > 2:
                                    # DO;
                                        g.STMT_STACK[l.EXP_START[0]] = TX(BYTE('('));
                                        g.STMT_STACK[l.EXP_END[0]] = TX(BYTE(')'));
                                    # END
                        # END
                        else:
                            l.EXP_END[0] = CHECK_FOR_FUNC(l.EXP_START[0]);
                        goto = "DOLLAR_CHECK1";
                        while ((goto == None and \
                                g.STMT_STACK[l.EXP_END[0] + 1] == g.EXPONENTIATE) and \
                                (l.EXP_END[0] + 1) < l.PTR_END) or \
                                    goto == "DOLLAR_CHECK1":
                            if goto == None:
                                l.EXP_END[0] = l.EXP_END[0] + 2;
                            if g.STMT_STACK[l.EXP_END[0]] == g.LEFT_PAREN \
                                    and goto == None:
                            # DO;
                                l.FIND_ONLY = g.TRUE;
                                l.EXP_END[0] = MATCH(l.EXP_END[0]);
                                l.FIND_ONLY = g.FALSE;
                            # END
                            elif (g.GRAMMAR_FLAGS(l.EXP_END[0]) & g.FUNC_FLAG) != 0 \
                                    and goto == None:
                                l.EXP_END[0] = CHECK_FOR_FUNC(l.EXP_END[0]);
                            elif goto in [None, "DOLLAR_CHECK1"]:
                            # DO;
                                if goto == "DOLLAR_CHECK1": goto = None
                                while (g.STMT_STACK[l.EXP_END[0] + 1] == g.DOLLAR) and \
                                        (l.EXP_END[0] + 1 < l.PTR_END):
                                    l.EXP_END[0] = l.EXP_END[0] + 2;
                                    if g.STMT_STACK[l.EXP_END[0]] == g.LEFT_PAREN:
                                    # DO;
                                        l.FIND_ONLY = g.TRUE;
                                        l.EXP_END[0] = MATCH(l.EXP_END[0]);
                                        l.FIND_ONLY = g.FALSE;
                                    # END
                                    else:
                                        l.EXP_END[0] = CHECK_FOR_FUNC(l.EXP_END[0]);
                                # END
                            # END
                        # END
                        l.PTR = l.EXP_END[0] + 1;
                    # END
                    if l.SUB_START[0] + l.EXP_START[0] != 0:
                    # DO;
                        goto = "S_BEGIN"
                        while goto in ["S_BEGIN", "S_LOOP", "E_LOOP"]:
                            if goto in [None, "S_BEGIN"]:
                                if goto == "S_BEGIN": goto = None
                                l.E_PTR = l.M_PTR
                                l.S_PTR = l.M_PTR;
                            if (l.SUB_START[0] != 0 and goto == None) \
                                    or goto == "S_LOOP":
                                if goto == "S_LOOP": goto = None
                                g.LAST_SPACE = 2;
                                while l.SUB_START[l.S_LEVEL] <= l.SUB_END[l.S_LEVEL]:
                                    if g.STMT_STACK[l.SUB_START[l.S_LEVEL]] == 0:
                                    # DO;
                                        l.SUB_START[l.S_LEVEL] = l.SUB_START[l.S_LEVEL] + 1;
                                        goto = "S_LOOP"
                                        break
                                    # END
                                    if g.STMT_STACK[l.SUB_START[l.S_LEVEL]] == g.DOLLAR:
                                    # DO;
                                        if l.S_LEVEL == l.MAX_LEVEL:  # DO;
                                            ERROR(d.CLASS_BS, 7);
                                            l.SUB_START[l.S_LEVEL] = l.SUB_START[l.S_LEVEL] + 1;
                                            goto = "S_LOOP"
                                            break
                                        # END
                                        l.S_LEVEL = l.S_LEVEL + 1;
                                        if l.MAX_S_LEVEL <= l.S_LEVEL:
                                            l.MAX_S_LEVEL = l.S_LEVEL + 1;
                                        l.SUB_START[l.S_LEVEL] = l.SUB_START[l.S_LEVEL - 1] + 1;
                                        if g.STMT_STACK[l.SUB_START[l.S_LEVEL]] == g.LEFT_PAREN:
                                        # DO;
                                            l.SUB_END[l.S_LEVEL] = MATCH(l.SUB_START[l.S_LEVEL]);
                                            if l.SUB_END[l.S_LEVEL] < l.PTR_END:
                                                if g.STMT_STACK[l.SUB_START[l.S_LEVEL] + 1] == g.DOLLAR:
                                                    if (l.SUB_END[l.S_LEVEL] - l.SUB_START[l.S_LEVEL]) > 2:
                                                    # DO;
                                                        g.STMT_STACK[l.SUB_START[l.S_LEVEL]] = \
                                                            TX(BYTE('('));
                                                        g.STMT_STACK[l.SUB_END[l.S_LEVEL]] = \
                                                            TX(BYTE(')'));
                                                    # END
                                        # END
                                        else:
                                            l.SUB_END[l.S_LEVEL] = \
                                                CHECK_FOR_FUNC(l.SUB_START[l.S_LEVEL]);
                                        while (g.STMT_STACK[l.SUB_END[l.S_LEVEL] + 1] == g.DOLLAR) \
                                                and ((l.SUB_END[l.S_LEVEL] + 1) < l.PTR_END):
                                            l.SUB_END[l.S_LEVEL] = l.SUB_END[l.S_LEVEL] + 2;
                                            if g.STMT_STACK[l.SUB_END[l.S_LEVEL]] == g.LEFT_PAREN:
                                            # DO;
                                                l.FIND_ONLY = g.TRUE;
                                                l.SUB_END[l.S_LEVEL] = MATCH(l.SUB_END[l.S_LEVEL]);
                                                l.FIND_ONLY = g.FALSE;
                                            # END
                                            else:
                                                l.SUB_START[l.S_LEVEL] = \
                                                    CHECK_FOR_FUNC(l.SUB_END[l.S_LEVEL]);
                                        # END
                                        if l.SUB_END[l.S_LEVEL] >= l.PTR:
                                            l.PTR = l.SUB_END[l.S_LEVEL] + 1;
                                        goto = "S_LOOP"
                                        break
                                    # END
                                    sss = (g.STMT_STACK[l.SUB_START[l.S_LEVEL]] == g.CHARACTER_STRING)
                                    if sss:
                                    # DO;
                                        if l.S_CHAR_PTR < l.S_CHAR_PTR_MAX:
                                            goto = "MORE_S_C";
                                        else:
                                            g.C[0] = ATTACH(l.SUB_START[l.S_LEVEL], g.NT);
                                            if LENGTH(g.C[0]) == 0: 
                                                goto = "INCR_SUB_START"
                                            else:
                                                l.S_CHAR_PTR = 0
                                                l.S_CHAR_PTR_MAX = 0;
                                                for g.I in range(0, 2 + 1):
                                                    l.SAVE_S_C[g.I] = g.C[g.I];
                                                    l.S_CHAR_PTR_MAX = \
                                                        l.S_CHAR_PTR_MAX + LENGTH(g.C[g.I]);
                                                l.S_PTR = l.S_PTR + l.SPACE_NEEDED;
                                        if goto in [None, "MORE_S_C"]:
                                            if goto == "MORE_S_C": goto = None
                                            while (l.S_CHAR_PTR < l.S_CHAR_PTR_MAX) and \
                                                    (l.S_PTR < l.LINESIZE):
                                                g.J = BYTE(l.SAVE_S_C[SHR(l.S_CHAR_PTR, 8)], \
                                                         (l.S_CHAR_PTR & 0xFF));
                                                l.BUILD_S = BYTE(l.BUILD_S, l.S_PTR, g.J);
                                                l.BUILD_S_IND[l.S_PTR] = l.S_LEVEL + 1;
                                                if (g.GRAMMAR_FLAGS(l.SUB_START[l.S_LEVEL]) \
                                                        & g.MACRO_ARG_FLAG) != 0:
                                                    l.BUILD_S_UND[l.S_PTR] = l.S_LEVEL + 1;
                                                l.S_PTR = l.S_PTR + 1;
                                                l.S_CHAR_PTR = l.S_CHAR_PTR + 1;
                                            # END
                                            if l.S_CHAR_PTR < l.S_CHAR_PTR_MAX:
                                                goto = "S_FULL"
                                        if goto == None:
                                            goto = "INCR_SUB_START"
                                    # END
                                    if (not sss and goto == None) or \
                                            goto in ["INCR_SUB_START", "S_FULL"]:  # was ELSE
                                    # DO;
                                        # NOT A CHARACTER STRING
                                        if goto == None:
                                            g.C[0] = ATTACH(l.SUB_START[l.S_LEVEL], g.NT);
                                        if LENGTH(g.C[0]) == 0 and goto == None: 
                                            goto = "INCR_SUB_START"
                                        elif goto in [None, "S_FULL"]:
                                            if goto == None:
                                                l.S_PTR = l.S_PTR + l.SPACE_NEEDED;
                                            if (goto == None and \
                                                LENGTH(g.C[0]) + l.S_PTR >= l.LINESIZE) \
                                                    or goto == "S_FULL":
                                            # DO;
                                                if goto == "S_FULL": goto = None
                                                # RESTORE PRINT FLAG TO OVERFLOWING TOKEN
                                                g.GRAMMAR_FLAGS(l.SUB_START[l.S_LEVEL], \
                                                    g.GRAMMAR_FLAGS(l.SUB_START[l.S_LEVEL]) | g.PRINT_FLAG);
                                                l.LINE_FULL = g.TRUE;
                                                l.SAVE_MAX_S_LEVEL = l.S_LEVEL + 1;
                                                goto = "E_BEGIN"
                                                break
                                            # END
                                            for g.I in range(0, LENGTH(g.C[0])):
                                                g.J = BYTE(g.C[0], g.I);
                                                l.BUILD_S = BYTE(l.BUILD_S, l.S_PTR + g.I, g.J);
                                                l.BUILD_S_IND[l.S_PTR + g.I] = l.S_LEVEL + 1;
                                            # END
                                            if (g.TOKEN_FLAGS(l.SUB_START[l.S_LEVEL]) & 7) == 7:
                                                l.MACRO_WRITTEN = g.TRUE;
                                            if (g.GRAMMAR_FLAGS(l.SUB_START[l.S_LEVEL]) \
                                                    & g.MACRO_ARG_FLAG) != 0:  # DO;
                                                for g.I in range(0, LENGTH(g.C[0])):
                                                    l.BUILD_S_UND[l.S_PTR + g.I] = l.S_LEVEL + 1;
                                                # END
                                            # END
                                            l.S_PTR = l.S_PTR + LENGTH(g.C[0]);
                                        if goto == "INCR_SUB_START": goto = None
                                        l.SUB_START[l.S_LEVEL] = l.SUB_START[l.S_LEVEL] + 1;
                                    # END OF NOT A CHARACTER STRING
                                # END OF DO WHILE SUB_START <= SUB_END
                                if goto == "S_LOOP":
                                    continue
                            # END OF SUB_START != 0
                            if l.S_LEVEL != 0 and goto == None:
                            # DO;
                                l.S_LEVEL = l.S_LEVEL - 1;
                                l.SUB_START[l.S_LEVEL] = l.SUB_START[l.S_LEVEL + 1];
                                l.MACRO_WRITTEN = g.FALSE;
                                goto = "S_LOOP"
                                continue
                            # END
                            if goto == "E_BEGIN": goto = None
                            if (goto == None and l.EXP_START[0] != 0) or \
                                    goto == "E_LOOP":  # DO;
                                if goto == "E_LOOP": goto = None
                                g.LAST_SPACE = 2;
                                while l.EXP_START[l.E_LEVEL] <= l.EXP_END[l.E_LEVEL]:
                                    if g.STMT_STACK[l.EXP_START[l.E_LEVEL]] == 0:
                                    # DO;
                                        l.EXP_START[l.E_LEVEL] = l.EXP_START[l.E_LEVEL] + 1;
                                        goto = "E_LOOP"
                                        break
                                    # END
                                    if g.STMT_STACK[l.EXP_START[l.E_LEVEL]] == g.EXPONENTIATE:
                                    # DO;
                                        if l.E_LEVEL == l.MAX_LEVEL:  # DO;
                                            ERROR(d.CLASS_BS, 7);
                                            l.EXP_START[l.E_LEVEL] = l.EXP_START[l.E_LEVEL] + 1;
                                            goto = "E_LOOP"
                                            break
                                        # END
                                        l.E_LEVEL = l.E_LEVEL + 1;
                                        if l.MAX_E_LEVEL <= l.E_LEVEL:
                                            l.MAX_E_LEVEL = l.E_LEVEL + 1;
                                        l.EXP_START[l.E_LEVEL] = l.EXP_START[l.E_LEVEL - 1] + 1;
                                        if g.STMT_STACK[l.EXP_START[l.E_LEVEL]] == g.LEFT_PAREN:
                                        # DO;
                                            l.EXP_END[l.E_LEVEL] = MATCH(l.EXP_START[l.E_LEVEL]);
                                            if l.EXP_END[l.E_LEVEL] < l.PTR_END:
                                                if g.STMT_STACK[l.EXP_END[l.E_LEVEL] + 1] == \
                                                        g.EXPONENTIATE:
                                                    if (l.EXP_END[l.E_LEVEL] - \
                                                            l.EXP_START[l.E_LEVEL]) > 2:
                                                    # DO;
                                                        g.STMT_STACK[l.EXP_START[l.E_LEVEL]] = \
                                                            TX(BYTE('('));
                                                        g.STMT_STACK[l.EXP_END[l.E_LEVEL]] = \
                                                            TX(BYTE(')'));
                                                    # END
                                        # END
                                        else:
                                            l.EXP_END[l.E_LEVEL] = \
                                                CHECK_FOR_FUNC(l.EXP_START[l.E_LEVEL]);
                                        goto = "DOLLAR_CHECK2"
                                        while (goto == None and \
                                               g.STMT_STACK[l.EXP_END[l.E_LEVEL] + 1] \
                                                == g.EXPONENTIATE and \
                                                (l.EXP_END[l.E_LEVEL] + 1) < l.PTR_END) \
                                                or goto == "DOLLAR_CHECK2":
                                            if goto == None:
                                                l.EXP_END[l.E_LEVEL] = l.EXP_END[l.E_LEVEL] + 2;
                                            if g.STMT_STACK[l.EXP_END[l.E_LEVEL]] == g.LEFT_PAREN \
                                                    and goto == None:
                                            # DO;
                                                l.FIND_ONLY = g.TRUE;
                                                l.EXP_END[l.E_LEVEL] = MATCH(l.EXP_END[l.E_LEVEL]);
                                                l.FIND_ONLY = g.FALSE;
                                            # END
                                            elif (g.GRAMMAR_FLAGS(l.EXP_END[l.E_LEVEL]) & \
                                                    g.FUNC_FLAG) != 0 and goto == None:
                                                l.EXP_END[l.E_LEVEL] = \
                                                    CHECK_FOR_FUNC(l.EXP_END[l.E_LEVEL]);
                                            elif goto in [None, "DOLLAR_CHECK2"]:
                                                if goto == "DOLLAR_CHECK2": goto = None
                                                while (g.STMT_STACK[l.EXP_END[l.E_LEVEL] + 1] == \
                                                        g.DOLLAR) and (l.EXP_END[l.E_LEVEL] + 1 < l.PTR_END):
                                                    l.EXP_END[l.E_LEVEL] = l.EXP_END[l.E_LEVEL] + 2;
                                                    if g.STMT_STACK[l.EXP_END[l.E_LEVEL]] == \
                                                            g.LEFT_PAREN:
                                                    # DO;
                                                        l.FIND_ONLY = g.TRUE;
                                                        l.EXP_END[l.E_LEVEL] = \
                                                            MATCH(l.EXP_END[l.E_LEVEL]);
                                                        l.FIND_ONLY = g.FALSE;
                                                    # END
                                                    else:
                                                        l.EXP_END[l.E_LEVEL] = \
                                                            CHECK_FOR_FUNC(l.EXP_END[l.E_LEVEL]);
                                                # END
                                        # END
                                        if l.EXP_END[l.E_LEVEL] >= l.PTR:
                                            l.PTR = l.EXP_END[l.E_LEVEL] + 1;
                                        goto = "E_LOOP"
                                        break
                                    # END
                                    ss = g.STMT_STACK[l.EXP_START[l.E_LEVEL]] == g.CHARACTER_STRING
                                    if ss:
                                    # DO;
                                        if l.E_CHAR_PTR < l.E_CHAR_PTR_MAX:
                                            goto = "MORE_E_C";
                                        else:
                                            g.C[0] = ATTACH(l.EXP_START[l.E_LEVEL], g.NT);
                                            if LENGTH(g.C[0]) == 0: 
                                                goto = "INCR_EXP_START";
                                            else:
                                                l.E_CHAR_PTR = 0
                                                l.E_CHAR_PTR_MAX = 0;
                                                for g.I in range(0, 2 + 1):
                                                    l.SAVE_E_C[g.I] = g.C[g.I];
                                                    l.E_CHAR_PTR_MAX = l.E_CHAR_PTR_MAX + LENGTH(g.C[g.I]);
                                                # END
                                                l.E_PTR = l.E_PTR + l.SPACE_NEEDED;
                                        if goto in [None, "MORE_E_C"]:
                                            if goto == "MORE_E_C": goto = None
                                            while (l.E_CHAR_PTR < l.E_CHAR_PTR_MAX) and \
                                                    (l.E_PTR < l.LINESIZE):
                                                g.J = BYTE(l.SAVE_E_C[SHR(l.E_CHAR_PTR, 8)], \
                                                         (l.E_CHAR_PTR & 0xFF));
                                                l.BUILD_E = BYTE(l.BUILD_E, l.E_PTR, g.J);
                                                l.BUILD_E_IND[l.E_PTR] = l.E_LEVEL + 1;
                                                if (g.GRAMMAR_FLAGS(l.EXP_START[l.E_LEVEL]) \
                                                        & g.MACRO_ARG_FLAG) != 0:
                                                    l.BUILD_E_UND[l.E_PTR] = l.E_LEVEL + 1;
                                                l.E_PTR = l.E_PTR + 1;
                                                l.E_CHAR_PTR = l.E_CHAR_PTR + 1;
                                            # END
                                            if l.E_CHAR_PTR < l.E_CHAR_PTR_MAX:
                                                goto = "E_FULL"
                                            else:
                                                goto = "INCR_EXP_START";
                                    # END
                                    if not ss or goto in ["INCR_EXP_START", "E_FULL"]: # ELSE
                                    # DO;
                                        # NOT A CHARACTER STRING
                                        if goto in [None, "E_FULL"]:
                                            if goto == None:
                                                g.C[0] = ATTACH(l.EXP_START[l.E_LEVEL], g.NT);
                                            if LENGTH(g.C[0]) == 0 and goto == None: 
                                                goto = "INCR_EXP_START"
                                            else:
                                                if goto == None:
                                                    l.E_PTR = l.E_PTR + l.SPACE_NEEDED;
                                                if goto == "E_FULL" or \
                                                        (goto == None and \
                                                         LENGTH(g.C[0]) + l.E_PTR >= l.LINESIZE):
                                                # DO;
                                                    if goto == "E_FULL": goto = None
                                                    g.GRAMMAR_FLAGS(l.EXP_START[l.E_LEVEL], \
                                                        g.GRAMMAR_FLAGS(l.EXP_START[l.E_LEVEL]) | g.PRINT_FLAG);
                                                    l.LINE_FULL = g.TRUE;
                                                    l.SAVE_MAX_E_LEVEL = l.E_LEVEL + 1;
                                                    goto = "FULL_LINE"
                                                    break
                                                # END
                                                for g.I in range(0, LENGTH(g.C[0])):
                                                # DO;
                                                    g.J = BYTE(g.C[0], g.I);
                                                    l.BUILD_E = BYTE(l.BUILD_E, l.E_PTR + g.I, g.J);
                                                    l.BUILD_E_IND[l.E_PTR + g.I] = l.E_LEVEL + 1;
                                                # END
                                                if (g.TOKEN_FLAGS(l.EXP_START[l.E_LEVEL]) & 7) == 7:
                                                    l.MACRO_WRITTEN = g.TRUE;
                                                if (g.GRAMMAR_FLAGS(l.EXP_START[l.E_LEVEL]) \
                                                        & g.MACRO_ARG_FLAG) != 0:  # DO;
                                                    for g.I in range(0, LENGTH(g.C[0])):
                                                        l.BUILD_E_UND[l.E_PTR + g.I] = l.E_LEVEL + 1;
                                                    # END
                                                # END
                                                l.E_PTR = l.E_PTR + LENGTH(g.C[0]);
                                        if goto == "INCR_EXP_START": goto = None
                                        l.EXP_START[l.E_LEVEL] = l.EXP_START[l.E_LEVEL] + 1;
                                    # END OF NOT A CHARACTER STRING
                                # END OF DO WHILE EXP_START <= EXP_END
                                if goto == "E_LOOP":
                                    continue
                            # END OF EXP_START != 0
                            if l.E_LEVEL != 0 and goto == None:
                            # DO;
                                l.E_LEVEL = l.E_LEVEL - 1;
                                l.EXP_START[l.E_LEVEL] = l.EXP_START[l.E_LEVEL + 1];
                                l.MACRO_WRITTEN = g.FALSE;
                                goto = "E_LOOP"
                                continue
                            # END
                            if goto == "FULL_LINE": goto = None
                            if l.LINE_FULL:
                            # DO;
                                EXPAND(0);
                                l.MAX_E_LEVEL = l.SAVE_MAX_E_LEVEL;
                                l.MAX_S_LEVEL = l.SAVE_MAX_S_LEVEL;
                                l.SAVE_MAX_E_LEVEL = 0
                                l.SAVE_MAX_S_LEVEL = 0;
                                l.LINE_FULL = g.FALSE;
                                if (l.E_CHAR_PTR + l.S_CHAR_PTR) == 0:
                                    l.M_PTR = MAX(MIN(g.INDENT_LEVEL, l.INDENT_LIMIT), 0);
                                else:
                                # DO;
                                    l.M_PTR = 0;
                                    l.LINE_CONTINUED = g.TRUE;
                                # END
                                goto = "S_BEGIN"
                                continue
                            # END
                            if l.E_PTR > l.S_PTR:
                                l.M_PTR = l.E_PTR;
                            else:
                                l.M_PTR = l.S_PTR;
                            g.LAST_SPACE = 1;
                        # End of while goto == "S_BEGIN"
                    # END OF DO IF SUB_START + EXP_START != 0
                    # I don't see how the following condition could ever be met.
                    if l.PTR > l.PTR_END: 
                        goto = "PTR_LOOP_END"
                        continue
                # END of if not goto == "STLABEL"
                if  g.STMT_STACK[l.PTR] == g.CHARACTER_STRING and goto == None:
                # DO;
                    g.C[0] = ATTACH(l.PTR, 0);
                    if LENGTH(g.C[0]) == 0: 
                        goto = "PTR_LOOP_END"
                        continue
                    if l.M_CHAR_PTR < l.M_CHAR_PTR_MAX:
                        goto = "MORE_M_C"
                    else:
                        l.M_CHAR_PTR = 0
                        l.M_CHAR_PTR_MAX = 0;
                        for g.I in range(0, 2 + 1):
                            l.M_CHAR_PTR_MAX = l.M_CHAR_PTR_MAX + LENGTH(g.C[g.I]);
                        # END
                        l.M_PTR = l.M_PTR + l.SPACE_NEEDED;
                    goto = "MORE_M_C"
                    while goto == "MORE_M_C":
                        if goto == "MORE_M_C": goto = None
                        while (l.M_CHAR_PTR < l.M_CHAR_PTR_MAX) and (l.M_PTR < l.LINESIZE):
                            g.J = BYTE(g.C[SHR(l.M_CHAR_PTR, 8)], (l.M_CHAR_PTR & 0xFF));
                            if (g.TRANS_OUT[g.J] & 0xFF) != 0:  # DO;
                                # ALT CHAR SET
                                g.K = g.CHAR_OP[SHR(g.TRANS_OUT[g.J], 8) & 0xFF];  # OP CHAR
                                l.BUILD_E = BYTE(l.BUILD_E, l.M_PTR, g.K);
                                l.BUILD_E_IND[l.M_PTR] = 1;
                                if l.MAX_E_LEVEL == 0: 
                                    l.MAX_E_LEVEL = 1;
                                g.J = g.TRANS_OUT[g.J] & 0xFF;  # BACK TO NORMAL CHAR SET
                            # END
                            l.BUILD_M = BYTE(l.BUILD_M, l.M_PTR, g.J);
                            if (g.GRAMMAR_FLAGS(l.PTR) & g.MACRO_ARG_FLAG) != 0:  # DO;
                                l.M_UNDERSCORE = BYTE(l.M_UNDERSCORE, l.M_PTR, BYTE('_'));
                                l.M_UNDERSCORE_NEEDED = g.TRUE;
                            # END
                            l.M_PTR = l.M_PTR + 1;
                            l.M_CHAR_PTR = l.M_CHAR_PTR + 1;
                        # END
                        if l.M_CHAR_PTR < l.M_CHAR_PTR_MAX:
                        # DO;

                            def RESET():
                                # No locals
                                EXPAND(0);
                                if l.M_CHAR_PTR == 0:
                                    l.M_PTR = MAX(MIN(g.INDENT_LEVEL, l.INDENT_LIMIT), 0);
                                else:
                                # DO;
                                    l.M_PTR = 0;
                                    l.LINE_CONTINUED = g.TRUE;
                                # END
                            # END RESET;

                            RESET();
                            if g.SQUEEZING:  # DO;
                                g.SQUEEZING = g.FALSE;
                                g.GRAMMAR_FLAGS(l.PTR, \
                                        g.GRAMMAR_FLAGS(l.PTR) | g.PRINT_FLAG);
                                goto = "OUTPUT_WRITER_END"
                                break
                            # END
                            goto = "MORE_M_C"
                            continue
                        # END
                    if goto == "OUTPUT_WRITER_END":
                        break
                    l.M_CHAR_PTR_MAX = 0;
                # END
                elif g.STMT_STACK[l.PTR] == g.REPLACE_TEXT and goto == None:
                # DO;
                    if (g.GRAMMAR_FLAGS(l.PTR) & g.PRINT_FLAG) == 0:
                        if not g.RECOVERING: 
                            goto = "PTR_LOOP_END"
                            continue
                    l.M_PTR = l.M_PTR + 1;
                    l.M_CHAR_PTR = g.SYT_ADDR(g.MAC_NUM);
                    l.BUILD_M = BYTE(l.BUILD_M, l.M_PTR, BYTE('"'));
                    l.M_PTR = l.M_PTR + 1;
                    
                    def PRINT_TEXT(LINELENGTH):
                        # Local WAS_HERE doesn't need persistence.
                        WAS_HERE = g.FALSE;
                        g.J = g.MACRO_TEXT(l.M_CHAR_PTR);
                        goto = "LINEDONE"
                        while goto == "LINEDONE":
                            if goto == "LINEDONE": goto = None
                            while g.J != 0xEF and l.M_PTR < LINELENGTH:
                                if g.J == 0xEE:   # DO;
                                    l.M_CHAR_PTR = l.M_CHAR_PTR + 1;
                                    g.J = g.MACRO_TEXT(l.M_CHAR_PTR);
                                    if g.J == 0:  # DO;
                                        l.M_CHAR_PTR = l.M_CHAR_PTR + 1;
                                        return;
                                    # END
                                    goto = "NEXT_LINE"
                                    while goto == "NEXT_LINE":
                                        if goto == "NEXT_LINE": goto = None
                                        if (g.J + l.M_PTR) >= LINELENGTH:  # DO;
                                            g.J = g.J - LINELENGTH + l.M_PTR;
                                            RESET();
                                            goto = "NEXT_LINE"
                                            continue
                                        # END
                                        else:
                                            l.M_PTR = l.M_PTR + g.J;
                                # END
                                elif g.J == BYTE('"'):  # DO;
                                    if WAS_HERE: 
                                        WAS_HERE = g.FALSE;
                                    else:  # DO;
                                        WAS_HERE = g.TRUE;
                                        l.M_CHAR_PTR = l.M_CHAR_PTR - 1;
                                    # END
                                    l.BUILD_M = BYTE(l.BUILD_M, l.M_PTR, g.J);
                                # END
                                else:
                                    l.BUILD_M = BYTE(l.BUILD_M, l.M_PTR, g.J);
                                l.M_PTR = l.M_PTR + 1;
                                l.M_CHAR_PTR = l.M_CHAR_PTR + 1;
                                g.J = g.MACRO_TEXT(l.M_CHAR_PTR);
                            # END
                            if g.J != 0xEF:  # DO;
                                RESET();
                                goto = "LINEDONE"
                                continue
                            # END
                        if l.M_PTR == LINELENGTH: 
                            RESET();
                    # END PRINT_TEXT;
                    
                    PRINT_TEXT(l.LINESIZE);
                    l.BUILD_M = BYTE(l.BUILD_M, l.M_PTR, BYTE('"'));
                    l.M_PTR = l.M_PTR + 1;
                # END
                else:
                # DO;
                    # NOT A CHARACTER STRING
                    if goto == None:
                        g.C[0] = ATTACH(l.PTR, 0);
                        if LENGTH(g.C[0]) == 0: 
                            goto = "PTR_LOOP_END"
                            continue
                        l.M_PTR = l.M_PTR + l.SPACE_NEEDED;
                        if LENGTH(g.C[0]) + l.M_PTR >= l.LINESIZE:
                        # DO;
                            EXPAND(l.PTR - 1);
                            if g.SQUEEZING:
                            # DO;
                                g.SQUEEZING = g.FALSE;
                                g.GRAMMAR_FLAGS(l.PTR,
                                    g.GRAMMAR_FLAGS(l.PTR) | g.PRINT_FLAG);
                                goto = "OUTPUT_WRITER_END"
                                break
                            # END
                            l.M_PTR = MIN(g.INDENT_LEVEL, l.INDENT_LIMIT);
                        # END
                    if (goto == None and l.PTR == l.PTR_START) \
                            or goto == "STLABEL":
                        if goto == "STLABEL": goto = None 
                        if g.LABEL_COUNT > 0:
                        # DO;
                            l.TEMP = 0;
                            l.LABEL_TOO_LONG = g.TRUE;
                            for g.I in range(l.LABEL_START, l.LABEL_END + 1, 2):
                                g.J = g.TOKEN_FLAGS(g.I);
                                l.TEMP = l.TEMP + LENGTH(g.SAVE_BCD[SHR(g.J, 6)]) + 2;
                            # END
                            if ((g.NEST_LEVEL == 0) and (l.TEMP <= l.M_PTR)) or \
                                    ((g.NEST_LEVEL < 10) and (l.TEMP < (l.M_PTR - 1))) or \
                                    ((g.NEST_LEVEL >= 10) and (l.TEMP < (l.M_PTR - 2))):  # DO;
                                g.J = l.M_PTR - l.TEMP;
                                l.LABEL_TOO_LONG = g.FALSE;
                            # END
                            else:
                                g.J = 0;
                            for g.I in range(l.LABEL_START, l.LABEL_END + 1, 2):
                                g.K = g.TOKEN_FLAGS(g.I);
                                g.S = g.SAVE_BCD[SHR(g.K, 6)];
                                if (LENGTH(g.S) + 2 + g.J) > l.LINESIZE:  # DO;
                                    g.J = g.I;
                                    l.CHAR = g.S;
                                    EXPAND(0);
                                    g.I = g.J;
                                    g.S = l.CHAR;
                                    g.J = 0;
                                # END
                                for g.L in range(0, LENGTH(g.S)):
                                    g.K = BYTE(g.S, g.L);
                                    l.BUILD_M = BYTE(l.BUILD_M, g.J + g.L, g.K);
                                # END
                                g.L += 1  # Terminal value differs from XPL to Python.
                                l.BUILD_M = BYTE(l.BUILD_M, g.J + g.L, BYTE(':'));
                                g.J = g.J + g.L + 2;
                            # END
                            if l.LABEL_TOO_LONG:
                                EXPAND(0);
                            g.LABEL_COUNT = 0;
                        # END
                    if l.PRINT_LABEL: 
                        goto = "AFTER_EXPAND"
                        break
                    for g.I in range(0, LENGTH(g.C[0])):
                        g.J = BYTE(g.C[0], g.I);
                        l.BUILD_M = BYTE(l.BUILD_M, l.M_PTR + g.I, g.J);
                    # END
                    g.I = g.TOKEN_FLAGS(l.PTR) & 0x1F;  # TYPE FOR OVERPUNCH
                    if g.I > 0:
                        if (g.I < g.SCALAR_TYPE) or (g.I == g.MAJ_STRUC):
                        # DO;
                            g.K = g.OVER_PUNCH_TYPE[g.I];
                            g.I = (SHL(l.M_PTR, 1) - 1 + LENGTH(g.C[0])) // 2;
                            l.BUILD_E = BYTE(l.BUILD_E, g.I, g.K);
                            l.BUILD_E_IND[g.I] = 1;
                            if l.MAX_E_LEVEL == 0:
                                l.MAX_E_LEVEL = 1;
                        # END
                    if (g.GRAMMAR_FLAGS(l.PTR) & g.MACRO_ARG_FLAG) != 0:
                    # DO;
                        # REPLACE NAME, SO UNDERLINE IT
                        if g.I == 7:
                            l.MACRO_WRITTEN = g.TRUE;
                        for g.I  in range(0, LENGTH(g.C[0]) - 1 + 1):
                            l.M_UNDERSCORE = BYTE(l.M_UNDERSCORE, \
                                                  l.M_PTR + g.I, BYTE('_'));
                        # END
                        l.M_UNDERSCORE_NEEDED = g.TRUE;
                    # END
                    l.M_PTR = l.M_PTR + LENGTH(g.C[0]);
                # END
            # END OF DO PTR = PTR_START TO PTR_END
            if goto == None:
                EXPAND(l.PTR_END);  # EXPAND BUFFERS
                if g.SQUEEZING and (l.PTR > g.OUTPUT_STACK_MAX - 2):  # DO;
                    if l.PTR > l.PTR_END + 1: 
                        l.PTR = l.PTR_END + 1;
                    g.SQUEEZING = g.FALSE;
                    if (l.SUB_START[0] != 0) and \
                            ((g.STMT_STACK[l.SUB_END[0] + 1] == g.DOLLAR) or \
                             (g.STMT_STACK[l.PTR_END] == g.EXPONENTIATE)):
                        ERROR(d.CLASS_BS, 6);
                    if (l.EXP_START[0] != 0) and \
                            ((g.STMT_STACK[l.PTR_END] == g.DOLLAR) or \
                             (g.STMT_STACK[l.EXP_END[0] + 1] == g.EXPONENTIATE)):
                        ERROR(d.CLASS_BS, 6);
                # END
        if goto in [None, "AFTER_EXPAND"]:
            if goto == "AFTER_EXPAND": goto = None
            if l.PTR_END == g.STMT_PTR:
            # DO;
                if g.STMT_PTR == g.STMT_END_PTR: 
                    g.STMT_END_PTR = -2;
                g.STMT_PTR = -1;
                g.BCD_PTR = 0
                g.LAST_WRITE = 0
                g.ELSEIF_PTR = 0;
            # END
        if goto == "OUTPUT_WRITER_END": goto = None
        g.LAST_SPACE = 2;
        l.MACRO_WRITTEN = g.FALSE;
    if goto == "PRINT_ANY_ERRORS": goto = None
    g.END_FLAG = g.FALSE;
    g.PAGE_THROWN = 0
    l.PTR_START = 0;
    l.PTR_END = -1;

    if g.STMT_PTR == -1:  # ALL TOKEN WRITTEN
        if l.LAST_ERROR_WRITTEN < g.LAST:  # DO;
            # GET ALL ERRORS
            l.CURRENT_ERROR_PTR = g.LAST;
            ERROR_PRINT();
        # END
    if l.ERRORS_PRINTED:  # DO;
        if g.TOO_MANY_ERRORS:
        # DO;
            ERRORS(d.CLASS_BI, 101);
            g.TOO_MANY_ERRORS = g.FALSE;
        # END
        if g.OUT_PREV_ERROR != 0:
            OUTPUT(0, '***** LAST ERROR WAS DETECTED AT STATEMENT ' + \
                        str(g.OUT_PREV_ERROR) + g.PERIOD + g.X1 + g.STARS);
        g.OUT_PREV_ERROR = g.STMT_NUM();
        if l.LAST_ERROR_WRITTEN >= g.LAST:
            l.LAST_ERROR_WRITTEN = -1
            l.CURRENT_ERROR_PTR = -1
            g.LAST = -1;
        # END OF DO WHEN ERRORS_PRINTED
    g.SAVE_SCOPE = g.CURRENT_SCOPE;
    if g.STACK_DUMPED:  # DO;
        for g.I in range(0, g.STACK_DUMP_PTR + 1):
            OUTPUT(0, g.SAVE_STACK_DUMP[g.I]);
        # END
        g.STACK_DUMP_PTR = -1;
        g.STACK_DUMPED = g.FALSE;
    # END
    return l.PTR;
# END OUTPUT_WRITER
