#!/usr/bin/env python3
"""
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   SCAN.py
Purpose:    This is part of the port of the original XPL source code for
            HAL/S-FC into Python.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2022-12-07 RSB  Suffixed the filename with ".xpl".  Before this
                            file had been received, it appears as though
                            an EBCDIC-to-ASCII conversion had incorrectly
                            encoded the character '¢' (U.S. cent) as 0x9B.
                            This has been repaired.
            2022-12-14 RSB  Changed encoding from ISO 8859-15 (or -1)
                            to UTF-8.
"""

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ERROR import ERROR
from HEX import HEX
from IDENTIFY import IDENTIFY
from SAVETOKE import SAVE_TOKEN
from PREPLITE import PREP_LITERAL
from HALINCL.FINISHMA import FINISH_MACRO_TEXT
from HALINCL.SPACELIB import NEXT_ELEMENT

from STREAM import STREAM

#*************************************************************************
# PROCEDURE NAME:  SCAN
# MEMBER NAME:     SCAN
# LOCAL DECLARATIONS:
#          BLANK_BYTES       BIT(16)
#          BUILD(1535)       LABEL
#          BUILD_BCD         LABEL
#          BUILD_COMMENT(1507)  LABEL
#          BUILD_INTERNAL_BCD(19)  LABEL
#          CASE13(1516)      LABEL
#          CENT_START        LABEL
#          CHAR_ALREADY_SCANNED  BIT(8)
#          CHAR_NEEDED       BIT(8)
#          CHAR_OP_CHECK(13) LABEL
#          CHECK(1500)       LABEL
#          COMMENT_PTR       BIT(16)
#          CONCAT(1533)      LABEL
#          DEC_POINT         BIT(8)
#          DEC_POINT_ENTRY   LABEL
#          DIGIT             BIT(8)
#          END_CHECK_RESERVED_WORD(1512)  LABEL
#          END_OF_CENT(1558) LABEL
#          ESCAPE_LEVEL      BIT(16)
#          EXP_BEGIN         BIT(16)
#          EXP_CHECK         LABEL
#          EXP_DIGITS        BIT(16)
#          EXP_DONE          LABEL
#          EXP_SIGN          BIT(16)
#          FOUND_ERROR       LABEL
#          FOUND_TOKEN(1505) LABEL
#          GET_NEW_CHAR      LABEL
#          ID_LOOP(1524)     LABEL
#          INTERNAL_BCD      CHARACTER;
#          LOOK_FOR_COMMENT(1572)  LABEL
#          LOOP_END          LABEL
#          NUMBER_DONE       LABEL
#          OVERPUNCH_ALREADY_SCANNED  BIT(8)
#          PARAMETER_PROCESSING(19)  LABEL
#          PARM_FOUND(1514)  LABEL
#          POWER_INDICATOR(1541)  LABEL
#          PUSH_MACRO(1498)  LABEL
#          RESET_LITERAL     LABEL
#          SCAN_END          LABEL
#          SCAN_START        LABEL
#          SCAN_TOP          LABEL
#          SEARCH_NEEDED     BIT(8)
#          SEARCH_NEXT_CHAR(1545)  LABEL
#          SET_SEARCH(1554)  LABEL
#          SIG_CHECK         LABEL
#          SIG_DIGITS        BIT(16)
#          START_EXPONENT(1551)  LABEL
#          STORE_NEXT_CHAR(1576)  LABEL
#          STR_TOO_LONG(1534)  LABEL
#          S1                BIT(16)
#          TEMP_CHAR         BIT(8)
#          TEST_SEARCH(1564) LABEL
# EXTERNAL VARIABLES REFERENCED:
#          CHAR_LENGTH_LIM
#          CHAR_OP
#          CHARACTER_STRING
#          CHARTYPE
#          CLASS_DT
#          CLASS_IL
#          CLASS_IR
#          CLASS_LC
#          CLASS_LF
#          CLASS_LS
#          CLASS_M
#          CLASS_MC
#          CLASS_MO
#          CLASS_XM
#          COMMA
#          CONCATENATE
#          CONST_DW
#          CONTROL
#          DECLARE_CONTEXT
#          DW
#          EOFILE
#          EQUATE_TOKEN
#          ESCP
#          EXPONENTIATE
#          EXPRESSION_CONTEXT
#          FALSE
#          FIRST_FREE
#          FOREVER
#          GROUP_NEEDED
#          ID_LIMIT
#          ID_TOKEN
#          LEFT_PAREN
#          LETTER_OR_DIGIT
#          LEVEL
#          MAC_TXT
#          MACRO_ARG_FLAG
#          MACRO_EXPAN_LIMIT
#          MACRO_TEXT
#          MAX_STRING_SIZE
#          MAX_STRUC_LEVEL
#          NUMBER
#          ONE_BYTE
#          OVER_PUNCH_SIZE
#          OVER_PUNCH_TYPE
#          PARM_CONTEXT
#          PC_INDEX
#          PC_LIMIT
#          PCNAME
#          PERCENT_MACRO
#          PRINT_FLAG
#          RECOVERING
#          REPLACE_TEXT
#          RESERVED_LIMIT
#          RT_PAREN
#          SAVE_COMMENT
#          SET_CONTEXT
#          SRN_PRESENT
#          STMT_PTR
#          STRUCTURE_WORD
#          SUBSCRIPT_LEVEL
#          SYM_ADDR
#          SYM_LENGTH
#          SYM_NAME
#          SYM_TAB
#          SYT_ADDR
#          SYT_NAME
#          TEMPORARY
#          TRANS_IN
#          TRUE
#          TX
#          V_INDEX
#          VALID_00_CHAR
#          VALID_00_OP
#          VAR_LENGTH
#          VOCAB_INDEX
#          X1
# EXTERNAL VARIABLES CHANGED:
#          BASE_PARM_LEVEL
#          BCD
#          BLANK_COUNT
#          C
#          COMM
#          COMMENT_COUNT
#          CONTEXT
#          DONT_SET_WAIT
#          EQUATE_IMPLIED
#          EXP_OVERFLOW
#          EXP_TYPE
#          FIRST_TIME
#          FIRST_TIME_PARM
#          FIXING
#          FOR_DW
#          FOUND_CENT
#          GRAMMAR_FLAGS
#          IMPLIED_TYPE
#          I
#          INCL_SRN
#          K
#          LABEL_IMPLIED
#          LOOKUP_ONLY
#          M_BLANK_COUNT
#          M_CENT
#          M_P
#          M_PRINT
#          M_TOKENS
#          MACRO_CALL_PARM_TABLE
#          MACRO_EXPAN_LEVEL
#          MACRO_EXPAN_STACK
#          MACRO_FOUND
#          MACRO_POINT
#          MACRO_TEXTS
#          NEW_MEL
#          NEXT_CHAR
#          NUM_OF_PARM
#          OLD_MEL
#          OLD_MP
#          OLD_PEL
#          OLD_PR_PTR
#          OLD_TOPS
#          OVER_PUNCH
#          P_CENT
#          PARM_COUNT
#          PARM_EXPAN_LEVEL
#          PARM_REPLACE_PTR
#          PARM_STACK_PTR
#          PASS
#          PRINTING_ENABLED
#          RESERVED_WORD
#          RESTORE
#          SAVE_PE
#          SOME_BCD
#          START_POINT
#          SUPPRESS_THIS_TOKEN_ONLY
#          S
#          SAVE_BLANK_COUNT
#          SAVE_NEXT_CHAR
#          SAVE_OVER_PUNCH
#          SCAN_COUNT
#          SRN
#          SRN_COUNT
#          STRING_OVERFLOW
#          SYT_INDEX
#          T_INDEX
#          TEMP_INDEX
#          TEMP_STRING
#          TEMPLATE_IMPLIED
#          TEMPORARY_IMPLIED
#          TOKEN
#          TOKEN_FLAGS
#          TOP_OF_PARM_STACK
#          VALUE
#          WAIT
# EXTERNAL PROCEDURES CALLED:
#          ERROR
#          FINISH_MACRO_TEXT
#          HEX
#          IDENTIFY
#          MIN
#          PREP_LITERAL
#          SAVE_TOKEN
#          STREAM
# CALLED BY:
#          INITIALIZATION
#          CALL_SCAN
#*************************************************************************


# Persistent local variables for various procedures.
class cSCAN:  # Local variables for SCAN procedure.

    def __init__(self):
        self.SIG_DIGITS = 0
        self.EXP_SIGN = 0
        self.EXP_BEGIN = 0
        self.S1 = 0
        self.EXP_DIGITS = 0
        self.DEC_POINT = 0
        self.CHAR_NEEDED = 0
        self.SEARCH_NEEDED = g.TRUE
        self.CHAR_ALREADY_SCANNED = 0
        self.OVERPUNCH_ALREADY_SCANNED = 0
        self.INTERNAL_BCD = ''
        self.COMMENT_PTR = 0
        self.DIGIT = 0
        self.TEMP_CHAR = 0
        self.BLANK_BYTES = 0
        self.ESCAPE_LEVEL = 0


lSCAN = cSCAN()


class cCHAR_OP_CHECK:  # Local variables for CHAR_OP_CHECK procedure.

    def __init__(self):
        self.HOLD_CHAR = 0


lCHAR_OP_CHECK = cCHAR_OP_CHECK()


class cPARAMETER_PROCESSING:  # Local variables for PARAMETER_PROCESSING proc.

    def __init__(self):
        self.I = 0
        self.ARG_COUNT = 0;
        self.NUM_OF_PAREN = 0 ;
        self.LAST_ARG = g.FALSE;
        self.QUOTE_FLAG = g.FALSE;
        self.D_QUOTE_FLAG = g.FALSE;
        self.CENT_FLAG = g.FALSE;


lPARAMETER_PROCESSING = cPARAMETER_PROCESSING()


def SCAN():
    l = lSCAN  # Locals specific to SCAN()

    goto = None

    def CHAR_OP_CHECK(CHAR):
        ll = lCHAR_OP_CHECK  # Locals specific to CHAR_OP_CHECK()
        
        goto = None

        if g.OVER_PUNCH == 0:
            return CHAR;
        firstTry = True
        while firstTry or goto == "VALID_TEST":
            firstTry = False
            if (goto == None and g.OVER_PUNCH == g.CHAR_OP[0]) \
                    or goto == "VALID_TEST":  # DO
                # LEVEL 1 ESCAPE
                if goto == None:
                    ll.HOLD_CHAR = g.TRANS_IN[CHAR] & 0xFF;
                if goto == "VALID_TEST": goto = None
                if ll.HOLD_CHAR == 0x00:
                    if g.OVER_PUNCH != g.VALID_00_OP or CHAR != g.VALID_00_CHAR:  # DO
                        ERROR(d.CLASS_MO, 6, HEX(CHAR, 2));
                        return CHAR;
                    # END
                return ll.HOLD_CHAR;
            # END
            elif g.OVER_PUNCH == g.CHAR_OP[1]:  # DO
                ll.HOLD_CHAR = SHR(g.TRANS_IN[CHAR], 8) & 0xFF;  # LEVEL 2 ESCAPE
                goto = "VALID_TEST";  # SEE IF IT A LEGAL ESCAPE
                continue
            # END
            else:  # ILLEGAL OVER PUNCH
            # DO;
                ERROR(d.CLASS_MO, 1, HEX(CHAR, 2));
                return CHAR;  # NO TRANSLATION
            # END
    # END CHAR_OP_CHECK;

    def BUILD_BCD():
        # This doesn't much resemble the original XPL, because the original
        # seems to me to be employing a trick (unnecessary in our implementation)
        # extend the size of the allocated storage for BCD.
        g.BCD = BYTE(g.BCD, len(g.BCD), g.NEXT_CHAR)

    def BUILD_INTERNAL_BCD():
        # Same comments as for BUILD_BCD().
        l.INTERNAL_BCD = BYTE(l.INTERNAL_BCD, len(l.INTERNAL_BCD), g.NEXT_CHAR)

    def PARAMETER_PROCESSING():
        ll = lPARAMETER_PROCESSING  # Locals specific to PARAMETER_PROCESSING()

        goto = None

        ll.LAST_ARG = g.FALSE;
        ll.QUOTE_FLAG = g.FALSE;
        ll.D_QUOTE_FLAG = g.FALSE;
        ll.CENT_FLAG = g.FALSE;
        ll.ARG_COUNT = 0;
        ll.NUM_OF_PAREN = 0 ;

        if g.VAR_LENGTH(g.SYT_INDEX) == 0:  # DO
            ll.LAST_ARG = g.TRUE;
            goto = "CHECK_ARG_NUM"; # Fallthrough okay.
        # END
        elif g.NEXT_CHAR == BYTE('('):  # DO
            g.TOKEN_FLAGS(g.STMT_PTR, g.TOKEN_FLAGS(g.STMT_PTR) | 0x20);
            g.RESERVED_WORD = g.TRUE;
            SAVE_TOKEN(g.LEFT_PAREN, 0, 0x20, 1);
            g.GRAMMAR_FLAGS(g.STMT_PTR, 
                            g.GRAMMAR_FLAGS(g.STMT_PTR) | g.MACRO_ARG_FLAG);
            for ll.I in range(1, g.NUM_OF_PARM[g.MACRO_EXPAN_LEVEL + 1] + 1):
                g.TEMP_STRING = g.X1;
                while True:
                    STREAM();
                    if g.NEXT_CHAR == BYTE(g.SQUOTE):
                        ll.QUOTE_FLAG = not ll.QUOTE_FLAG;
                    elif ll.QUOTE_FLAG == g.FALSE:  # DO
                        if g.NEXT_CHAR == BYTE('('):
                            ll.NUM_OF_PAREN = ll.NUM_OF_PAREN + 1;
                        elif g.NEXT_CHAR == BYTE(')'):  # DO
                            ll.NUM_OF_PAREN = ll.NUM_OF_PAREN - 1;
                            if ll.NUM_OF_PAREN < 0:  # DO
                                ll.LAST_ARG = g.TRUE;
                                STREAM()
                                goto = "UP_ARG_COUNT";
                                break
                            # END
                        # END
                        elif g.NEXT_CHAR == BYTE('"'):
                            ll.D_QUOTE_FLAG = not ll.D_QUOTE_FLAG;
                        elif g.NEXT_CHAR == BYTE('`'):
                            ll.CENT_FLAG = not ll.CENT_FLAG;
                        elif g.NEXT_CHAR == BYTE(','):  # DO
                            if ll.NUM_OF_PAREN == 0 and ll.D_QUOTE_FLAG == g.FALSE:
                                if ll.CENT_FLAG == g.FALSE:
                                    if ll.QUOTE_FLAG == g.FALSE:
                                        goto = "UP_ARG_COUNT";
                                        break;
                        # END
                    # END
                    if LENGTH(g.TEMP_STRING) == 250:  # DO
                        ERROR(d.CLASS_IR, 7);
                        return;
                    # END
                    g.ONE_BYTE = BYTE(g.ONE_BYTE, 0, g.NEXT_CHAR);
                    g.TEMP_STRING = g.TEMP_STRING + g.ONE_BYTE;
                    if g.NEXT_CHAR == BYTE(g.X1):
                        if g.BLANK_COUNT > 0:
                            if (LENGTH(g.TEMP_STRING) + g.BLANK_COUNT) > 250:  # DO
                                ERROR(d.CLASS_IR, 7);
                                return;
                            # END
                            else:
                                for g.K in range(1, g.BLANK_COUNT + 1):
                                    g.TEMP_STRING = g.TEMP_STRING + g.X1;
                                # END
                # END OF DO FOREVER
                if goto == "UP_ARG_COUNT": goto = None
                ll.ARG_COUNT = ll.ARG_COUNT + 1;
                g.MACRO_CALL_PARM_TABLE[ll.I + g.TOP_OF_PARM_STACK] \
                    = SUBSTR(g.TEMP_STRING, 1);
                g.TEMP_STRING = SUBSTR(g.TEMP_STRING, 1);
                if LENGTH(g.TEMP_STRING) > 0:  # DO
                    g.RESERVED_WORD = g.FALSE;
                    SAVE_TOKEN(g.CHARACTER_STRING, g.TEMP_STRING, 0, 1);
                    g.GRAMMAR_FLAGS(g.STMT_PTR, \
                                g.GRAMMAR_FLAGS(g.STMT_PTR) | g.MACRO_ARG_FLAG);
                # END
                if ll.LAST_ARG == g.TRUE:
                    goto = "CHECK_ARG_NUM";
                    break;
                g.RESERVED_WORD = g.TRUE;
                SAVE_TOKEN(g.COMMA, 0, 0x20, 1);
                g.GRAMMAR_FLAGS(g.STMT_PTR, \
                                g.GRAMMAR_FLAGS(g.STMT_PTR) | g.MACRO_ARG_FLAG);
            # END for
        # END if
        else:
            ll.LAST_ARG = g.TRUE;
        if goto == "CHECK_ARG_NUM": goto = None
        if ll.ARG_COUNT != g.NUM_OF_PARM[g.MACRO_EXPAN_LEVEL + 1] or \
                ll.LAST_ARG == g.FALSE:  # DO
            ERROR(d.CLASS_IR, 8);
            return;
        # END
        if g.NEXT_CHAR == BYTE('`'):
            if g.FOUND_CENT:
                if g.MACRO_EXPAN_LEVEL > 0:
                    goto = "NO_BACKUP"
                else:
                    STREAM();
        if goto != None:
            pass
        elif g.PARM_EXPAN_LEVEL > g.BASE_PARM_LEVEL[g.MACRO_EXPAN_LEVEL]:  # DO
            if g.FIRST_TIME_PARM[g.PARM_EXPAN_LEVEL]:
                g.PARM_REPLACE_PTR[g.PARM_EXPAN_LEVEL] = \
                    g.PARM_REPLACE_PTR[g.PARM_EXPAN_LEVEL] - 1;
            else:
                g.FIRST_TIME_PARM[g.PARM_EXPAN_LEVEL] = g.TRUE;
        # END
        else:  # DO
            if g.FIRST_TIME[g.MACRO_EXPAN_LEVEL]:  # DO
                if g.MACRO_TEXT(g.MACRO_POINT - 2) == 0xEE:
                    g.MACRO_POINT = g.MACRO_POINT - 2;
                elif g.MACRO_TEXT(g.MACRO_POINT) != 0xEF:
                    g.MACRO_POINT = g.MACRO_POINT - 1;
                elif g.MACRO_TEXT(g.MACRO_POINT) == 0xEF and \
                        g.MACRO_TEXT(g.MACRO_POINT - 1) == g.NEXT_CHAR:
                    g.MACRO_POINT = g.MACRO_POINT - 1;
            # END
            else:
                g.FIRST_TIME[g.MACRO_EXPAN_LEVEL] = g.TRUE;
        # END
        if goto == "NO_BACKUP": goto = None
        if ll.ARG_COUNT > 0:  # DO
            g.RESERVED_WORD = g.TRUE;
            SAVE_TOKEN(g.RT_PAREN, 0, 0, 1);
            g.GRAMMAR_FLAGS(g.STMT_PTR, \
                            g.GRAMMAR_FLAGS(g.STMT_PTR) | g.MACRO_ARG_FLAG);
        # END
        g.M_P[g.MACRO_EXPAN_LEVEL] = g.MACRO_POINT;
        g.M_BLANK_COUNT[g.MACRO_EXPAN_LEVEL] = g.BLANK_COUNT;
        g.MACRO_EXPAN_LEVEL = g.MACRO_EXPAN_LEVEL + 1;
        g.FIRST_TIME[g.MACRO_EXPAN_LEVEL] = g.TRUE;
        g.TOP_OF_PARM_STACK = g.TOP_OF_PARM_STACK + ll.ARG_COUNT;
        g.TEMP_STRING = '';
        g.RESERVED_WORD = g.FALSE;
    # END PARAMETER_PROCESSING;

    #--------------------------------------------------------------------
    # ROUTINE TO DETERMINE IF END OF MACRO HAS BEEN REACHED BY
    # MACRO_POINT
    #--------------------------------------------------------------------

    def END_OF_MACRO():
        MP = g.MACRO_POINT;
        # FIRST SKIP BLANKS
        while (g.MACRO_TEXT(MP) == 0xEE or g.MACRO_TEXT(MP) == BYTE(g.X1)):
            if g.MACRO_TEXT(MP) == 0xEE:
                MP = MP + 1;
            MP = MP + 1;
        # END
        # THEN CHECK FOR END OF MACRO CHARACTER
        if g.MACRO_TEXT(MP) == 0xEF:
            if g.NEXT_CHAR == BYTE(g.X1):
                return g.TRUE;
        return g.FALSE;
    # END END_OF_MACRO;

    if l.SEARCH_NEEDED:  # PRE-SEARCH FOR COMMENTS
        goto = "SCAN_END";

    while True:
        '''
        The stuff below isn't looped in the original code.  It's
        a workaround to implement some of the goto == "XXXX" jumps
        described above, which tend to jump right into the middle
        of blocks.
        '''

        if goto in [None, "SCAN_TOP", "SCAN_START"]:
            if goto == "SCAN_TOP": goto = None  # CONTROL RETURNED HERE FROM COMMENT SEARCH

            if goto == None:
                g.SCAN_COUNT = g.SCAN_COUNT + 1;
                if l.CHAR_NEEDED:
                    STREAM();
                    l.CHAR_NEEDED = g.FALSE;
            if goto == "SCAN_START": goto = None

            g.M_TOKENS[g.MACRO_EXPAN_LEVEL] = g.M_TOKENS[g.MACRO_EXPAN_LEVEL] + 1;
            g.BCD = '';
            g.FIXING = 0;
            g.DW[6] = 0;
            g.DW[7] = 0;
            g.VALUE = 0;
            g.SYT_INDEX = 0;
            g.RESERVED_WORD = g.TRUE;
            g.IMPLIED_TYPE = 0;

        while goto != "SCAN_END":  # START OF SCAN
            
            # See the comments in case 2 of the DO CASE below.
            def ID_LOOP():
                # No locals

                goto = None

                # Note the original freakish syntax in XPL:
                #    S1=NEXT_CHAR=BYTE('_')
                l.S1 = (g.NEXT_CHAR == BYTE('_'));
                if LENGTH(g.BCD) < g.ID_LIMIT:
                    BUILD_BCD();
                    if g.OVER_PUNCH != 0:
                        if g.IMPLIED_TYPE > 0:
                            ERROR(d.CLASS_MO, 3);
                        else:
                            for g.I in range(1, g.OVER_PUNCH_SIZE + 1):
                                if g.OVER_PUNCH == g.OVER_PUNCH_TYPE[g.I]:
                                    g.IMPLIED_TYPE = g.I;
                                    goto = "NEW_CHAR";
                                    break;
                            # END for
                            if goto == None:
                                ERROR(d.CLASS_MO, 4);
                                g.OVER_PUNCH = 0;
                else:
                    # TOO MANY CHARACTERS IN IDENT
                    if not g.STRING_OVERFLOW:
                        ERROR(d.CLASS_IL, 2);
                        g.STRING_OVERFLOW = g.TRUE;
                if goto == "NEW_CHAR": goto = None;
                STREAM();
            # END ID_LOOP
            
            # See the comments for case 2 in the DO CASE below.
            def PUSH_MACRO():
                # No locals
                g.SUPPRESS_THIS_TOKEN_ONLY = g.FALSE;
                #           GET NEXT NON-BLANK BEFORE
                #           PARAMETER_PROCESSING
                while g.NEXT_CHAR == BYTE(g.X1):
                   STREAM();
                if g.MACRO_EXPAN_LEVEL + 1 > g.MACRO_EXPAN_LIMIT:
                    ERROR(d.CLASS_IR, 9, g.BCD);
                    g.MACRO_EXPAN_LEVEL = 0
                    g.PARM_EXPAN_LEVEL = 0
                    g.MACRO_FOUND = 0;
                    g.NEXT_CHAR = g.SAVE_NEXT_CHAR;
                    g.OVER_PUNCH = g.SAVE_OVER_PUNCH;
                    g.PRINTING_ENABLED = g.PRINT_FLAG;
                    return;
                g.MACRO_EXPAN_STACK[g.MACRO_EXPAN_LEVEL + 1] = g.SYT_INDEX;
                if g.PRINTING_ENABLED == g.PRINT_FLAG:
                    g.RESTORE = g.PRINT_FLAG;
                    if g.FOUND_CENT:
                        g.PASS = g.PRINT_FLAG;
                        g.PRINTING_ENABLED = 0;
                    else:
                        g.PASS = 0;
                else:
                    g.RESTORE = 0;
                    g.PASS = 0;
                SAVE_TOKEN(g.ID_TOKEN, g.BCD, 7);
                g.GRAMMAR_FLAGS(g.STMT_PTR, g.GRAMMAR_FLAGS(g.STMT_PTR) \
                                            | g.MACRO_ARG_FLAG);
                g.NUM_OF_PARM[g.MACRO_EXPAN_LEVEL + 1] = \
                    g.VAR_LENGTH(g.SYT_INDEX);
                PARAMETER_PROCESSING();
                g.PRINTING_ENABLED = g.PASS;
                if g.TEMP_STRING == '':
                   g.BASE_PARM_LEVEL[g.MACRO_EXPAN_LEVEL] = g.PARM_EXPAN_LEVEL;
                   g.M_TOKENS[g.MACRO_EXPAN_LEVEL] = 0;
                   g.M_CENT[g.MACRO_EXPAN_LEVEL] = g.FOUND_CENT;
                   g.M_PRINT[g.MACRO_EXPAN_LEVEL] = g.RESTORE;
                   g.FOUND_CENT = g.FALSE;
                   g.MACRO_POINT = g.SYT_ADDR(g.SYT_INDEX);
                   if g.MACRO_EXPAN_LEVEL == 1:
                      g.MACRO_FOUND = g.TRUE ;
                      g.SAVE_NEXT_CHAR = g.NEXT_CHAR;
                      g.SAVE_OVER_PUNCH = g.OVER_PUNCH;
                      g.BLANK_COUNT = 0
                      g.OVER_PUNCH = 0;
                else:
                    g.FOUND_CENT = g.FALSE;
                STREAM();
                return;
            # END PUSH_MACRO
            
            # See the comments in case 13 of the DO CASE below.
            def PARM_FOUND():
                # No locals
                g.TEMP_INDEX = g.MACRO_EXPAN_LEVEL;
                g.PARM_COUNT = g.NUM_OF_PARM[g.TEMP_INDEX];
                while g.TEMP_INDEX > 0:
                    for g.I in range(1, g.NUM_OF_PARM[g.TEMP_INDEX] + 1):
                        if g.BCD == g.SYT_NAME(g.MACRO_EXPAN_STACK[g.TEMP_INDEX] + g.I):
                            g.PARM_EXPAN_LEVEL = g.PARM_EXPAN_LEVEL + 1;
                            g.FIRST_TIME_PARM[g.PARM_EXPAN_LEVEL] = g.TRUE;
                            g.PARM_REPLACE_PTR[g.PARM_EXPAN_LEVEL] = 0;
                            g.PARM_STACK_PTR[g.PARM_EXPAN_LEVEL] = \
                                g.I + g.TOP_OF_PARM_STACK - g.PARM_COUNT;
                            if g.BASE_PARM_LEVEL[g.MACRO_EXPAN_LEVEL] + 1 == \
                                    g.PARM_EXPAN_LEVEL:
                                if not g.FOUND_CENT:
                                    if not END_OF_MACRO():
                                        if g.MACRO_TEXT(g.MACRO_POINT - 2) == 0xEE:
                                            g.MACRO_POINT = g.MACRO_POINT - 1;
                                        g.MACRO_POINT = g.MACRO_POINT - 1;
                            else:
                                if g.FIRST_TIME_PARM[g.PARM_EXPAN_LEVEL - 1]:
                                    #  CHECK FOR CENT SIGN
                                    if g.NEXT_CHAR != BYTE('`'):
                                        g.PARM_REPLACE_PTR[g.PARM_EXPAN_LEVEL - 1] = \
                                            g.PARM_REPLACE_PTR[g.PARM_EXPAN_LEVEL - 1] - 1;
                                else:
                                    g.FIRST_TIME_PARM[g.PARM_EXPAN_LEVEL - 1] = g.TRUE;
                            g.BLANK_COUNT = 0
                            g.OVER_PUNCH = 0;
                            g.P_CENT[g.PARM_EXPAN_LEVEL] = g.FOUND_CENT;
                            STREAM();
                            return 1;
                    g.TEMP_INDEX = g.TEMP_INDEX - 1;
                    g.PARM_COUNT = g.PARM_COUNT + g.NUM_OF_PARM[g.TEMP_INDEX];
                return 0;
            # END PARM_FOUND

            if goto == "DEC_POINT_ENTRY":
                ct = 1
            elif goto == "CENT_START":
                ct = 2
            elif goto == "CASE13":
                ct = 13
            else:
                if not g.MACRO_FOUND:
                    if g.SRN_PRESENT:
                        g.SRN[1] = g.SRN[0][:];
                        g.INCL_SRN[1] = g.INCL_SRN[0][:];
                        g.SRN_COUNT[1] = g.SRN_COUNT[0];
                ct = g.CHARTYPE[g.NEXT_CHAR]

            # DO CASE CHARTYPE(g.NEXT_CHAR);
            if ct == 0:
                # CASE 0--ILLEGAL CHARACTERS
                g.C[0] = HEX(g.NEXT_CHAR, 2);
                ERROR(d.CLASS_DT, 4, g.C[0]);
                if g.OVER_PUNCH != 0:
                   ERROR(d.CLASS_MO, 1);
                STREAM();
            elif ct == 1:
                # CASE 1--DIGITS
                if goto == None:
                    g.RESERVED_WORD = g.FALSE
                    l.DEC_POINT = g.FALSE;
                    BUILD_BCD();
                    if g.OVER_PUNCH != 0:
                        ERROR(d.CLASS_MO, 1);
                    STREAM();
                    g.TOKEN = g.NUMBER;
                    if g.NEXT_CHAR == BYTE(g.X1) or g.NEXT_CHAR == BYTE(')'):
                        g.VALUE = BYTE(g.BCD) - BYTE('0');
                        if g.VALUE >= 1 and g.VALUE <= g.MAX_STRUC_LEVEL:
                            g.TOKEN = g.LEVEL;
                    l.DIGIT = BYTE(g.BCD);
                if goto == "DEC_POINT_ENTRY": goto = None
                l.SIG_DIGITS = 0;
                l.INTERNAL_BCD = g.BCD[:];  # START THE SAME

                goto = "SIG_CHECK"
                while goto in ["SIG_CHECK", "GET_NEW_CHAR"]:
                    while goto in ["SIG_CHECK", "GET_NEW_CHAR"] \
                            or (goto == None and g.CHARTYPE[l.DIGIT] == 1):
                        if goto in [None, "SIG_CHECK"]:
                            if goto == None:
                                if g.OVER_PUNCH != 0:
                                   ERROR(d.CLASS_MO, 1);
                                BUILD_BCD();
                                BUILD_INTERNAL_BCD();
                            if goto == "SIG_CHECK": goto = None
                            if l.SIG_DIGITS == 0 and goto == None:
                                if l.DIGIT == BYTE('0'):
                                    if LENGTH(g.BCD) == 1:
                                        goto = "LOOP_END";
                                    else:
                                        goto = "GET_NEW_CHAR";
                            if goto == None:
                                l.SIG_DIGITS = l.SIG_DIGITS + 1;
                                if l.SIG_DIGITS > 74:
                                    goto = "GET_NEW_CHAR";  # TOO MANY SIG DIGITS
                                elif LENGTH(g.BCD) == 1:
                                    goto = "LOOP_END";
                        if goto == "GET_NEW_CHAR": goto = None
                        if goto == None:
                            STREAM();
                        if goto == "LOOP_END": goto = None
                        l.DIGIT = g.NEXT_CHAR;
                    # OF DO WHILE...

                    if l.DIGIT == BYTE(g.PERIOD):
                        if l.DEC_POINT:
                            BUILD_BCD();
                            ERROR(d.CLASS_LF, 2);
                            # FOUND_ERROR:
                            if g.OVER_PUNCH != 0:
                                ERROR(d.CLASS_MO, 1);
                            goto = "GET_NEW_CHAR";
                            continue
                        l.DEC_POINT = g.TRUE;
                        BUILD_BCD();
                        BUILD_INTERNAL_BCD();
                        # Was GO TO FOUND_ERROR, but I instead duplicated the
                        # code that is at FOUND_ERROR.
                        if g.OVER_PUNCH != 0:
                            ERROR(d.CLASS_MO, 1);
                        goto = "GET_NEW_CHAR";
                        continue;

                firstTry = True
                while firstTry or goto in ["START_EXPONENT", "POWER_INDICATOR"]:
                    firstTry = False
                    if goto == "START_EXPONENT": goto = None
                    if goto == None:
                        g.EXP_TYPE = l.DIGIT;
                    if goto == "POWER_INDICATOR" or \
                            (goto == None and g.EXP_TYPE == BYTE('E')):
                        if goto == "POWER_INDICATOR": goto = None
                        l.EXP_SIGN = 0;
                        l.EXP_BEGIN = 0;
                        l.EXP_DIGITS = 0;
                        l.EXP_BEGIN = LENGTH(l.INTERNAL_BCD) + 1;
                        goto = "EXP_CHECK"
                        while goto == "EXP_CHECK":
                            while goto == "EXP_CHECK" or \
                                    (goto == None and g.CHARTYPE[l.DIGIT] == 1):
                                if goto == None:
                                    l.EXP_DIGITS = l.EXP_DIGITS + 1;
                                if goto == "EXP_CHECK": goto = None
                                if g.OVER_PUNCH != 0:
                                    ERROR(d.CLASS_MO, 1);
                                BUILD_BCD();
                                BUILD_INTERNAL_BCD();
                                STREAM();
                                l.DIGIT = g.NEXT_CHAR;
                            if LENGTH(l.INTERNAL_BCD) == l.EXP_BEGIN:
                                if l.DIGIT == BYTE('+') or l.DIGIT == BYTE('-'):
                                    l.EXP_SIGN = l.DIGIT;
                                    goto = "EXP_CHECK";
                                    continue;
                                ERROR(d.CLASS_LF, 1);
                                goto = "RESET_LITERAL"
                                break
                            else:
                                goto = "EXP_DONE"
                                break

                    if goto in [None, "EXP_DONE"]:
                        if goto == None:
                            if g.EXP_TYPE == BYTE('H') or g.EXP_TYPE == BYTE('B'):
                                goto = "POWER_INDICATOR";
                                continue
                            goto = "NUMBER_DONE"
                        if goto == "EXP_DONE": goto = None

                    if goto in [None, "RESET_LITERAL"]:
                        if goto == "RESET_LITERAL" or \
                                (goto == None and l.EXP_DIGITS <= 0):
                            if goto == None:
                                ERROR(d.CLASS_LF, 5);
                            if goto == "RESET_LITERAL": goto = None;
                            l.INTERNAL_BCD = SUBSTR(l.INTERNAL_BCD, 0, l.EXP_BEGIN - 1);
                        goto = "START_EXPONENT"
                    if goto == "NUMBER_DONE": goto = None
                # End of while goto == "START_EXPONENT" or goto == "POWER_INDICATOR"
                if l.SIG_DIGITS > 74:
                    ERROR(d.CLASS_LF, 3);
                g.EXP_OVERFLOW = MONITOR(10, l.INTERNAL_BCD);  # CONVERT THE NUMBER
                if g.EXP_OVERFLOW:
                    ERROR(d.CLASS_LC, 2, g.BCD);
                PREP_LITERAL();
                goto = "SCAN_END";
                break
                # END OF CASE 1

            elif ct == 2:
                # CASE 2--LETTERS=IDENTS & RESERVED WORDS
                if goto == None:
                    g.STRING_OVERFLOW = g.FALSE;
                    g.LABEL_IMPLIED = g.FALSE;
                    g.IMPLIED_TYPE = 0;
                if goto == "FOUND_TOKEN": goto = None;
                while True:
                    if goto == "CENT_START": goto = None;
                    if g.LETTER_OR_DIGIT[g.NEXT_CHAR]:
                        # VALID CHARACTER
                        
                        # In the original XPL, the ID_LOOP() procedure was
                        # defined here.  However, at least in Python (as I've
                        # had to trick it up to handle GO TO statements, that
                        # would make it out-of-scope for some of the calls to
                        # it below.  So I've had to move it.

                        ID_LOOP();
                        # END OF DO...VALID CHARACTER
                    else:
                        if l.S1:
                            if g.NEXT_CHAR != BYTE('`'):
                                ERROR(d.CLASS_IL, 1);
                        goto = "FOUND_TOKEN";
                        break;
                # OF DO FOREVER

                if goto == "FOUND_TOKEN": goto = None;
                if g.NEXT_CHAR == BYTE('`'):
                    goto = "CASE13"
                    continue
                else:
                    l.S1 = LENGTH(g.BCD);
                    if l.S1 > 1:
                        if l.S1 <= g.RESERVED_LIMIT:
                            # CHECK FOR RESERVED WORDS
                            for g.I in range(g.V_INDEX[l.S1 - 1], g.V_INDEX[l.S1]):
                                g.S = STRING(g.VOCAB_INDEX[g.I]);
                                if BYTE(g.S) > BYTE(g.BCD):
                                    goto = "END_CHECK_RESERVED_WORD";
                                    break;
                                if g.S == g.BCD:
                                    g.TOKEN = g.I;
                                    if g.IMPLIED_TYPE > 0:
                                        ERROR(d.CLASS_MC, 4, g.BCD);
                                    g.I = g.SET_CONTEXT[g.I];
                                    if g.I > 0:
                                        if g.TOKEN == g.TEMPORARY:
                                            g.TEMPORARY_IMPLIED = g.TRUE;
                                        if g.TOKEN == g.EQUATE_TOKEN:
                                           g.EQUATE_IMPLIED = g.TRUE;
                                        if g.I == g.EXPRESSION_CONTEXT:
                                           if g.CONTEXT == g.DECLARE_CONTEXT or \
                                                  g.CONTEXT == g.PARM_CONTEXT:
                                              g.OLD_MEL = g.MACRO_EXPAN_LEVEL;
                                              g.SAVE_PE = g.PRINTING_ENABLED;
                                              while g.NEXT_CHAR == BYTE(g.X1):
                                                  if not g.MACRO_FOUND:
                                                      g.SAVE_BLANK_COUNT = g.BLANK_COUNT;
                                                  STREAM();
                                              if g.OLD_MEL > g.MACRO_EXPAN_LEVEL:
                                                  if g.M_TOKENS[g.OLD_MEL] <= 1:
                                                      if g.SAVE_PE != g.PRINTING_ENABLED:
                                                          g.SUPPRESS_THIS_TOKEN_ONLY = g.TRUE;
                                              if g.NEXT_CHAR == BYTE('('):
                                                  g.CONTEXT = g.I;
                                           else:
                                               if g.TOKEN == g.STRUCTURE_WORD:
                                                   g.CONTEXT = g.DECLARE_CONTEXT;
                                                   g.TEMPLATE_IMPLIED = g.TRUE;
                                        else:
                                           if g.CONTEXT != g.DECLARE_CONTEXT:
                                               if g.CONTEXT != g.EXPRESSION_CONTEXT:
                                                   g.CONTEXT = g.I;
                                    goto = "SCAN_END"
                                    break
                            # END for
                            if goto == "SCAN_END":
                                break

                if goto == "END_CHECK_RESERVED_WORD": goto = None;
                g.RESERVED_WORD = g.FALSE;
                if g.MACRO_EXPAN_LEVEL > 0:
                    '''
                    /*-------------------------------------------------------*/
                    /*           AT THIS POINT, WE ARE CHECKING TO SEE IF    */
                    /*             BCD IS A FORMAL PARAMETER OF THE MACRO.   */
                    /*             IF IT IS THEN THE DELIMITER WE JUST       */
                    /*             FETCHED OUT OF THE MACRO TABLE CANNOT BE  */
                    /*             PROCESSED UNTIL AFTER WE GET THE PARAMETER*/
                    /*             VALUE.  INSTEAD OF SAVING THE DELIMITER,  */
                    /*             MACRO_POINT WILL SIMPLY BACK UP AND THE   */
                    /*             DELIMETER WILL BE FETCHED AGAIN.          */
                    /*           FOR THE DR SCENARIO, THE DELIMITER WAS AN   */
                    /*             END_OF MACRO, THEREFORE THE MACRO_POINT   */
                    /*             WAS NOT ADAVNCED WHEN IT WAS FETCHED.     */
                    /*             IN THIS CASE WE SHOULD NOT BACK UP THE    */
                    /*             MACRO_POINT.                              */
                    /*-------------------------------------------------------*/
                    '''

                    # The PARM_FOUND() procedure, originally defined here by 
                    # the XPL, had to be moved outward to remain in scope for
                    # some calls to it.

                    g.FOUND_CENT = g.FALSE;
                    if PARM_FOUND():
                        goto = "SCAN_START";
                        break;

                g.OLD_MEL = g.MACRO_EXPAN_LEVEL;
                g.OLD_PEL = g.PARM_EXPAN_LEVEL;
                g.OLD_PR_PTR = g.PARM_REPLACE_PTR[g.PARM_EXPAN_LEVEL];
                g.OLD_TOPS = g.TOP_OF_PARM_STACK;
                g.SAVE_PE = g.PRINTING_ENABLED;
                g.OLD_MP = g.MACRO_POINT;
                while g.NEXT_CHAR == BYTE(g.X1):
                    if not g.MACRO_FOUND:
                        g.SAVE_BLANK_COUNT = g.BLANK_COUNT;
                    STREAM();
                g.NEW_MEL = g.MACRO_EXPAN_LEVEL;
                if g.OLD_MEL > g.NEW_MEL:
                    if g.M_TOKENS[g.OLD_MEL] <= 1:
                        if g.SAVE_PE != g.PRINTING_ENABLED:
                            g.SUPPRESS_THIS_TOKEN_ONLY = g.TRUE;
                if g.SUBSCRIPT_LEVEL == 0:
                    if g.NEXT_CHAR == BYTE(':'):
                        if g.CONTEXT != g.DECLARE_CONTEXT:
                            g.LABEL_IMPLIED = g.TRUE;
                    elif g.NEXT_CHAR == BYTE('-'):
                        if g.CONTEXT == g.DECLARE_CONTEXT or g.CONTEXT == g.PARM_CONTEXT:
                            g.TEMPLATE_IMPLIED = g.TRUE;
                            g.LOOKUP_ONLY = g.TRUE;
                if g.RECOVERING:
                    g.LOOKUP_ONLY = g.FALSE;
                    g.TEMPLATE_IMPLIED = g.FALSE;
                    goto = "SCAN_END";  # WITHOUT CALLING IDENTIFY
                    break;
                IDENTIFY(g.BCD, 0);
                g.LOOKUP_ONLY = g.FALSE;
                g.TEMPLATE_IMPLIED = g.FALSE;
                if g.CONTROL[3] & 1:
                    if g.TOKEN > 0:
                        g.S = STRING(g.VOCAB_INDEX[g.TOKEN]);
                    else:
                        g.S = str(g.TOKEN);
                    OUTPUT(0, g.BCD + ' :  TOKEN = ' + g.S + \
                                ', IMPLIED_TYPE = ' + str(g.IMPLIED_TYPE) + \
                                ', SYT_INDEX = ' + str(g.SYT_INDEX) + \
                                ', CONTEXT = ' + str(g.CONTEXT));
                if g.MACRO_FOUND:
                    if g.OLD_PEL != g.PARM_EXPAN_LEVEL:
                        if g.BASE_PARM_LEVEL[g.MACRO_EXPAN_LEVEL] >= g.PARM_EXPAN_LEVEL:
                            g.NEXT_CHAR = BYTE(g.X1);
                            g.MACRO_POINT = g.MACRO_POINT - 1;

                if g.TOKEN < 0:  # MACRO NAME FOUND
                    if g.MACRO_EXPAN_LEVEL == 0 and g.SAVE_NEXT_CHAR == BYTE(g.X1):
                        g.SAVE_NEXT_CHAR = g.NEXT_CHAR;
                    if g.OLD_MEL > g.NEW_MEL:
                        if g.PARM_EXPAN_LEVEL > g.BASE_PARM_LEVEL[g.MACRO_EXPAN_LEVEL]:
                            if g.OLD_PR_PTR < g.PARM_REPLACE_PTR[g.PARM_EXPAN_LEVEL]:
                                g.PARM_REPLACE_PTR[g.PARM_EXPAN_LEVEL] = g.OLD_PR_PTR;
                        g.NEW_MEL, g.MACRO_EXPAN_LEVEL = g.OLD_MEL;
                        g.MACRO_FOUND = g.TRUE;
                        g.WAIT = g.FALSE;
                        g.MACRO_POINT = g.OLD_MP;
                        g.PRINTING_ENABLED = g.SAVE_PE;
                        g.TOP_OF_PARM_STACK = g.OLD_TOPS;
                    if g.STMT_STACK[g.STMT_PTR] == g.SEMI_COLON and g.STMT_END_PTR == g.STMT_PTR:
                        OUTPUT_WRITER(g.LAST_WRITE, g.STMT_PTR);

                    # Procedure PUSH_MACRO(), originally defined here in XPL,
                    # had to be moved to remain in-scope for some of the calls
                    # to it.

                    PUSH_MACRO();
                    goto = "SCAN_START";
                    break
                elif not g.MACRO_FOUND:
                    g.SAVE_BLANK_COUNT = -1;
                goto = "SCAN_END";
                break;
                # END OF CASE 2

            elif ct == 3:
                # CASE 3--SPECIAL SINGLE CHARACTERS
                if g.OVER_PUNCH != 0:
                    ERROR(d.CLASS_MO, 1);
                g.TOKEN = g.TX[g.NEXT_CHAR];
                l.CHAR_NEEDED = g.TRUE;
                goto = "SCAN_END"
                break
                # END OF CASE 3

            elif ct == 4:
                # CASE 4--PERIOD
                # COULD BE DOT PRODUCT OR DECIMAL POINT
                if g.OVER_PUNCH != 0:
                    ERROR(d.CLASS_MO, 1);
                BUILD_BCD();
                STREAM();
                if g.CHARTYPE[g.NEXT_CHAR] == 1:
                    l.DEC_POINT = g.TRUE;
                    BUILD_BCD();
                    g.TOKEN = g.NUMBER;
                    l.DIGIT = g.NEXT_CHAR;
                    if g.OVER_PUNCH != 0:
                        ERROR(d.CLASS_MO, 1);
                    g.RESERVED_WORD = g.FALSE;
                    goto = "DEC_POINT_ENTRY";
                    break;
                g.TOKEN = g.TX[BYTE(g.PERIOD)];
                goto = "SCAN_END"
                break
                # END OF CASE 4

            elif ct == 5:
                # CASE 5--SINGLE QUOTE = CHARACTER LITERAL
                g.I = 0;
                g.STRING_OVERFLOW = g.FALSE
                g.RESERVED_WORD = g.FALSE;
                if g.OVER_PUNCH != 0:
                    ERROR(d.CLASS_MO, 5);
                g.TOKEN = g.CHARACTER_STRING;
                goto = "CHECK";
                while goto in ["CHECK", "BUILD"]:
                    while goto in ["BUILD", "CHECK"] or \
                            (goto == None and g.NEXT_CHAR != BYTE(g.SQUOTE)):
                        if goto == "BUILD": goto = None;
                        if goto == None:
                            if g.NEXT_CHAR != BYTE(g.X1):
                                g.BLANK_COUNT = 0;
                            for g.I in range(0, g.BLANK_COUNT + 1):
                                if LENGTH(g.BCD) < g.CHAR_LENGTH_LIM:
                                    BUILD_BCD();
                                else:
                                    ERROR(d.CLASS_LS, 1);
                                    # Originally the label STR_TOO_LONG
                                    # preceded the following code.
                                    g.STRING_OVERFLOW = g.TRUE;
                                    goto = "SCAN_END";
                                    break;
                            # END for
                        if goto == "SCAN_END":
                            break;
                        if goto == "CHECK": goto = None;
                        STREAM();
                        l.ESCAPE_LEVEL = -1;
                        while g.NEXT_CHAR == g.ESCP:
                            l.ESCAPE_LEVEL = l.ESCAPE_LEVEL + 1;
                            if g.OVER_PUNCH != 0:
                                ERROR(d.CLASS_MO, 8);
                            STREAM();
                        l.TEMP_CHAR = CHAR_OP_CHECK(g.NEXT_CHAR);
                        if l.ESCAPE_LEVEL >= 0:
                            if l.ESCAPE_LEVEL > 1:
                                ERROR(d.CLASS_MO, 7, HEX(g.NEXT_CHAR, 2));
                                l.ESCAPE_LEVEL = 1;
                            g.OVER_PUNCH = g.CHAR_OP[l.ESCAPE_LEVEL];
                            if g.NEXT_CHAR == BYTE(g.X1):  # HANDLE MULT BLANKS CAREFULLY
                                g.NEXT_CHAR = CHAR_OP_CHECK(l.TEMP_CHAR);
                                if g.BLANK_COUNT > 0:
                                    if LENGTH(g.BCD) < g.MAX_STRING_SIZE:
                                        BUILD_BCD();
                                    else:
                                        '''
                                        Originally GO TO STR_TOO_LONG.  However,
                                        it was just simpler the code that is
                                        actually at STR_TOO_LONG than to try
                                        and duplicate the jump.
                                        '''
                                        g.STRING_OVERFLOW = g.TRUE;
                                        goto = "SCAN_END";
                                        break;
                                    g.BLANK_COUNT = g.BLANK_COUNT - 1;
                                    g.NEXT_CHAR = BYTE(g.X1);
                            else:
                                g.NEXT_CHAR = CHAR_OP_CHECK(l.TEMP_CHAR);
                                pass
                        # END OF if ESCAPE LEVEL >= 0
                        else:
                            g.NEXT_CHAR = l.TEMP_CHAR;
                            pass
                    # END OF DO WHILE...
                    if goto == "SCAN_END":
                        break;
                    STREAM();
                    if g.NEXT_CHAR != BYTE(g.SQUOTE):
                        g.VALUE = LENGTH(g.BCD);
                        goto = "SCAN_END";
                        break;
                    if g.OVER_PUNCH != 0:
                        ERROR(d.CLASS_MO, 1);
                    goto = "BUILD";
                    continue
                # End of while goto == "CHECK" or goto == "BUILD"
                if goto == "SCAN_END":
                    break;
                # END OF CASE 5

            elif ct == 6:
                # CASE 6--BLANK
                while g.NEXT_CHAR == BYTE(g.X1):
                    g.DONT_SET_WAIT = g.TRUE;
                    STREAM();
                    g.DONT_SET_WAIT = g.FALSE;
                # OF CASE 6

            elif ct == 7:
                # CASE 7--'|' OR'||'
                g.TOKEN = g.TX[g.NEXT_CHAR];
                if g.OVER_PUNCH != 0:
                    ERROR(d.CLASS_MO, 1);
                STREAM();
                if g.NEXT_CHAR != BYTE('|'):
                    goto = "SCAN_END";
                    break;
                if g.OVER_PUNCH != 0:
                    ERROR(d.CLASS_MO, 1);
                g.TOKEN = g.CONCATENATE;
                STREAM();
                goto = "SCAN_END";
                break;
                # END OF CASE 7

            elif ct == 8:
                # CASE 8--'*' OR '**'
                g.TOKEN = g.TX[g.NEXT_CHAR];
                if g.OVER_PUNCH != 0:
                    ERROR(d.CLASS_MO, 1);
                STREAM();
                if g.NEXT_CHAR != BYTE('*'):
                    goto = "SCAN_END";
                    break;
                if g.OVER_PUNCH != 0:
                    ERROR(d.CLASS_MO, 1);
                g.TOKEN = g.EXPONENTIATE;
                STREAM();
                goto = "SCAN_END";
                break;
                # END OF CASE 8

            elif ct == 9:
                # CASE 9--HEX'FE' = EOF
                g.TOKEN = g.EOFILE;
                STREAM();
                goto = "SCAN_END";
                break;
                # END OF CASE 9

            elif ct == 10:
                # CASE 10--SPECIAL CHARACTERS TREATED AS BLANKS */
                g.NEXT_CHAR = BYTE(g.X1);
                g.BLANK_COUNT = 0;
                # END OF CASE 10

            elif ct == 11:
                # CASE 11--DOUBLE QUOTES FOR REPLACE DEFINITION
                g.TOKEN = g.REPLACE_TEXT;
                g.TEMP_STRING = g.X1;
                l.BLANK_BYTES = 0;
                g.START_POINT = g.FIRST_FREE();
                g.T_INDEX = g.START_POINT
                while True:
                    STREAM();
                    if g.NEXT_CHAR == BYTE('"'):
                        STREAM();
                        if g.NEXT_CHAR != BYTE('"'):
                            g.FIRST_FREE(g.T_INDEX);
                            FINISH_MACRO_TEXT();
                            goto = "SCAN_END";
                            break;
                    goto = "CONCAT"
                    while goto == "CONCAT":
                        if goto == "CONCAT": goto = None;
                        NEXT_ELEMENT(g.MACRO_TEXTS);
                        g.MACRO_TEXT(g.T_INDEX, g.NEXT_CHAR);
                        g.T_INDEX = g.T_INDEX + 1;
                        if g.NEXT_CHAR == BYTE(g.X1):
                            if g.BLANK_COUNT > 0:
                                g.MACRO_TEXT(g.T_INDEX - 1, 0xEE);
                                NEXT_ELEMENT(g.MACRO_TEXTS);
                                NEXT_ELEMENT(g.MACRO_TEXTS);
                                if g.BLANK_COUNT < 256:
                                   g.MACRO_TEXT(g.T_INDEX, g.BLANK_COUNT);
                                   l.BLANK_BYTES = l.BLANK_BYTES + g.BLANK_COUNT - 1;
                                   g.T_INDEX = g.T_INDEX + 1;
                                else:
                                   g.MACRO_TEXT(g.T_INDEX, 255);
                                   l.BLANK_BYTES = l.BLANK_BYTES + 254;
                                   g.BLANK_COUNT = g.BLANK_COUNT - 255;
                                   g.T_INDEX = g.T_INDEX + 1;
                                   goto = "CONCAT"
                                   continue
                    # END OF DO FOREVER (while goto == "CONCAT")
                # END OF CASE 11

            elif ct == 12:
                #  CASE 12 - % FOR %MACROS
                g.RESERVED_WORD = g.FALSE;
                g.STRING_OVERFLOW = g.FALSE;
                g.TOKEN = g.PERCENT_MACRO;
                while True:
                    if LENGTH(g.BCD) < g.PC_LIMIT:
                        BUILD_BCD();
                    else:
                        g.STRING_OVERFLOW = g.TRUE;
                    if g.OVER_PUNCH != 0:
                        ERROR(d.CLASS_MO, 1);
                    STREAM();
                    if not g.LETTER_OR_DIGIT[g.NEXT_CHAR]:
                        if g.STRING_OVERFLOW:
                            ERROR(d.CLASS_IL, 2);
                        l.S1 = LENGTH(g.BCD);
                        for g.SYT_INDEX in range(1, g.PC_INDEX + 1):
                           if SUBSTR(g.PCNAME, SHL(g.SYT_INDEX, 4), l.S1) == g.BCD:
                                goto = "SCAN_END";
                                break;
                        if goto == "SCAN_END":
                            break
                        g.SYT_INDEX += 1
                        ERROR(d.CLASS_XM, 1, g.BCD);
                        g.SYT_INDEX = 0;
                        goto = "SCAN_END";
                        break;
                # End of DO FOREVER
                if goto == "SCAN_END":
                    break
                # END OF CASE 12

            elif ct == 13:
                #  CASE 13 - ¢ FOR ¢MACROS
                # ... replaced already in this ASCII port by `.
                if goto == "CASE13": goto = None;
                g.SOME_BCD = g.BCD[:];
                g.BCD = '';
                STREAM();
                while True:
                    if g.LETTER_OR_DIGIT[g.NEXT_CHAR]:
                        ID_LOOP();
                    else:
                        goto = "END_OF_CENT"
                        break;
                if goto == "END_OF_CENT": goto = None
                g.FOUND_CENT = g.TRUE;
                if g.NEXT_CHAR == BYTE('`'):
                    if PARM_FOUND():
                        if g.SOME_BCD == '':
                            goto = "SCAN_START";
                            break;
                        g.BCD = g.SOME_BCD[:];
                        goto = "CENT_START";
                        break;
                    else:
                        IDENTIFY(g.BCD, 1);
                        if g.TOKEN < 0:
                            PUSH_MACRO();
                            if g.SOME_BCD == '':
                                goto = "SCAN_START";
                                break;
                            g.SYT_INDEX = 0;
                            g.BCD = g.SOME_BCD[:];
                            goto = "CENT_START";
                            break;
                        else:
                            ERROR(d.CLASS_IR, 4, g.BCD);
                            goto = "SCAN_START";
                            break;
                else:
                    IDENTIFY(g.BCD, 1);
                    if g.TOKEN < 0:
                        PUSH_MACRO();
                        goto = "SCAN_START";
                        break;
                    else:
                        ERROR(d.CLASS_IR, 4, g.BCD);
                        goto = "SCAN_START";
                        break;
                #  END OF CASE 13  */

            # END OF DO CASE...
            if goto in ["SCAN_END", "CENT_START"]:
                break
        # END OF DO FOREVER
        if goto in ["SCAN_START", "DEC_POINT_ENTRY", "CENT_START"]:
            continue

        def BUILD_COMMENT():
            if g.NEXT_CHAR != BYTE(g.X1):
                g.BLANK_COUNT = 0;
            for g.BLANK_COUNT in range(0, g.BLANK_COUNT + 1):
                g.COMMENT_COUNT = g.COMMENT_COUNT + 1;
                if g.COMMENT_COUNT >= 256:
                    if g.COMMENT_COUNT == 256:
                        ERROR(d.CLASS_M, 3);
                l.COMMENT_PTR = MIN(g.COMMENT_COUNT, 255);
                g.SAVE_COMMENT = BYTE(g.SAVE_COMMENT, l.COMMENT_PTR, g.NEXT_CHAR);

        goto = "SCAN_END";
        while goto in ["SCAN_END", "TEST_SEARCH", "LOOK_FOR_COMMENT",
                       "SET_SEARCH"]:
            while goto in ["SCAN_END", "TEST_SEARCH", "LOOK_FOR_COMMENT",
                           "SET_SEARCH"]:
                if goto == "SCAN_END": goto = None;
                if goto in [None, "TEST_SEARCH", "LOOK_FOR_COMMENT"]:
                    if goto in [None, "TEST_SEARCH"]:
                        if goto == "TEST_SEARCH" or \
                                (goto == None and l.CHAR_ALREADY_SCANNED != 0):
                            if goto == None:
                                g.NEXT_CHAR = l.CHAR_ALREADY_SCANNED;
                                l.CHAR_ALREADY_SCANNED = 0;
                                l.CHAR_NEEDED = g.FALSE;
                                g.OVER_PUNCH = l.OVERPUNCH_ALREADY_SCANNED;
                            if goto == "TEST_SEARCH": goto = None;
                            if l.SEARCH_NEEDED:
                                l.SEARCH_NEEDED = g.FALSE;
                                goto = "SCAN_TOP"
                                break
                            return;
                    if goto == "LOOK_FOR_COMMENT": goto = None;
                if goto == "SET_SEARCH" or \
                        (goto == None and g.GROUP_NEEDED and g.MACRO_EXPAN_LEVEL == 0):
                    if goto == "SET_SEARCH": goto = None;
                    if l.SEARCH_NEEDED:
                        STREAM();
                        l.CHAR_NEEDED = g.FALSE;
                        goto = "SCAN_END";
                        continue;
                    l.SEARCH_NEEDED = l.CHAR_NEEDED; ''' NO SEARCH NEEDED IF CHAR_NEEDED
                                                         IS NOT ON BECAUSE THE GROUP_NEEDED
                                                         CONDITION MUST BE CAUSED BY A LOOK
                                                         AHEAD IN g.NEXT_CHAR WHICH REALLY WAS
                                                         IN COLUMN 80 AND WILL BE SCANNED OUT
                                                         NEXT TIME '''
                    return;
                else:
                    if l.CHAR_NEEDED:
                        l.CHAR_NEEDED = g.FALSE;
                        STREAM();
            if goto == "SCAN_TOP":
                break

            while g.NEXT_CHAR == BYTE(g.X1):
                if g.M_TOKENS[g.MACRO_EXPAN_LEVEL] <= 1:
                    return;
                if g.GROUP_NEEDED and g.MACRO_EXPAN_LEVEL == 0:
                    l.CHAR_NEEDED = g.TRUE;
                    goto = "SET_SEARCH";
                    break;
                else:
                    STREAM();
            if goto == "SET_SEARCH":
                continue;

            if (g.NEXT_CHAR != BYTE('/')) or g.GROUP_NEEDED:
                goto = "TEST_SEARCH";
                continue
            if g.OVER_PUNCH != 0:
                ERROR(d.CLASS_MO, 1);
            STREAM();  # LOOK AT NEXT CHAR
            if g.NEXT_CHAR != BYTE('*'):  # NOT REALLY A COMMENT
                l.CHAR_ALREADY_SCANNED = g.NEXT_CHAR;
                g.NEXT_CHAR = BYTE('/');
                l.OVERPUNCH_ALREADY_SCANNED = g.OVER_PUNCH;
                goto = "TEST_SEARCH";
                continue;

            # IF WE GET HERE, WE HAVE A GENUINE COMMENT
            if g.OVER_PUNCH != 0:
                ERROR(d.CLASS_MO, 1);
            goto = "SEARCH_NEXT_CHAR";
            while goto in ["SEARCH_NEXT_CHAR", "STORE_NEXT_CHAR"]:
                while goto in ["STORE_NEXT_CHAR", "SEARCH_NEXT_CHAR"] \
                        or (goto == None and g.NEXT_CHAR != BYTE('/')):
                    if goto == "STORE_NEXT_CHAR": goto = None;
                    if goto == None:
                        BUILD_COMMENT();
                    if goto == "SEARCH_NEXT_CHAR": goto = None;
                    if g.GROUP_NEEDED:
                        l.CHAR_NEEDED = g.TRUE;
                        goto = "SET_SEARCH";
                        break;
                    STREAM();
                    if g.OVER_PUNCH != 0:
                        ERROR(d.CLASS_MO, 1);
                if goto == "SET_SEARCH":
                    break

                if BYTE(g.SAVE_COMMENT, l.COMMENT_PTR) != BYTE('*'):
                    goto = "STORE_NEXT_CHAR";
                    continue;
            if goto == "SET_SEARCH":
                continue
            g.COMMENT_COUNT = g.COMMENT_COUNT - 1;  # UNSAVE THE '*'
            l.COMMENT_PTR = l.COMMENT_PTR - 1;  # HERE TOO
            l.CHAR_NEEDED = g.TRUE;
            goto = "LOOK_FOR_COMMENT";
            continue;
        if goto == "SCAN_TOP":
            continue