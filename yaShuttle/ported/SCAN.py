#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   SCAN.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-08-31 RSB  Created a stub.
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ERROR import ERROR
from STREAM import STREAM
from HEX import HEX

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  SCAN                                                   */
 /* MEMBER NAME:     SCAN                                                   */
 /* LOCAL DECLARATIONS:                                                     */
 /*          BLANK_BYTES       BIT(16)                                      */
 /*          BUILD(1535)       LABEL                                        */
 /*          BUILD_BCD         LABEL                                        */
 /*          BUILD_COMMENT(1507)  LABEL                                     */
 /*          BUILD_INTERNAL_BCD(19)  LABEL                                  */
 /*          CASE13(1516)      LABEL                                        */
 /*          CENT_START        LABEL                                        */
 /*          CHAR_ALREADY_SCANNED  BIT(8)                                   */
 /*          CHAR_NEEDED       BIT(8)                                       */
 /*          CHAR_OP_CHECK(13) LABEL                                        */
 /*          CHECK(1500)       LABEL                                        */
 /*          COMMENT_PTR       BIT(16)                                      */
 /*          CONCAT(1533)      LABEL                                        */
 /*          DEC_POINT         BIT(8)                                       */
 /*          DEC_POINT_ENTRY   LABEL                                        */
 /*          DIGIT             BIT(8)                                       */
 /*          END_CHECK_RESERVED_WORD(1512)  LABEL                           */
 /*          END_OF_CENT(1558) LABEL                                        */
 /*          ESCAPE_LEVEL      BIT(16)                                      */
 /*          EXP_BEGIN         BIT(16)                                      */
 /*          EXP_CHECK         LABEL                                        */
 /*          EXP_DIGITS        BIT(16)                                      */
 /*          EXP_DONE          LABEL                                        */
 /*          EXP_SIGN          BIT(16)                                      */
 /*          FOUND_ERROR       LABEL                                        */
 /*          FOUND_TOKEN(1505) LABEL                                        */
 /*          GET_NEW_CHAR      LABEL                                        */
 /*          ID_LOOP(1524)     LABEL                                        */
 /*          INTERNAL_BCD      CHARACTER;                                   */
 /*          LOOK_FOR_COMMENT(1572)  LABEL                                  */
 /*          LOOP_END          LABEL                                        */
 /*          NUMBER_DONE       LABEL                                        */
 /*          OVERPUNCH_ALREADY_SCANNED  BIT(8)                              */
 /*          PARAMETER_PROCESSING(19)  LABEL                                */
 /*          PARM_FOUND(1514)  LABEL                                        */
 /*          POWER_INDICATOR(1541)  LABEL                                   */
 /*          PUSH_MACRO(1498)  LABEL                                        */
 /*          RESET_LITERAL     LABEL                                        */
 /*          SCAN_END          LABEL                                        */
 /*          SCAN_START        LABEL                                        */
 /*          SCAN_TOP          LABEL                                        */
 /*          SEARCH_NEEDED     BIT(8)                                       */
 /*          SEARCH_NEXT_CHAR(1545)  LABEL                                  */
 /*          SET_SEARCH(1554)  LABEL                                        */
 /*          SIG_CHECK         LABEL                                        */
 /*          SIG_DIGITS        BIT(16)                                      */
 /*          START_EXPONENT(1551)  LABEL                                    */
 /*          STORE_NEXT_CHAR(1576)  LABEL                                   */
 /*          STR_TOO_LONG(1534)  LABEL                                      */
 /*          S1                BIT(16)                                      */
 /*          TEMP_CHAR         BIT(8)                                       */
 /*          TEST_SEARCH(1564) LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CHAR_LENGTH_LIM                                                */
 /*          CHAR_OP                                                        */
 /*          CHARACTER_STRING                                               */
 /*          CHARTYPE                                                       */
 /*          CLASS_DT                                                       */
 /*          CLASS_IL                                                       */
 /*          CLASS_IR                                                       */
 /*          CLASS_LC                                                       */
 /*          CLASS_LF                                                       */
 /*          CLASS_LS                                                       */
 /*          CLASS_M                                                        */
 /*          CLASS_MC                                                       */
 /*          CLASS_MO                                                       */
 /*          CLASS_XM                                                       */
 /*          COMMA                                                          */
 /*          CONCATENATE                                                    */
 /*          CONST_DW                                                       */
 /*          CONTROL                                                        */
 /*          DECLARE_CONTEXT                                                */
 /*          DW                                                             */
 /*          EOFILE                                                         */
 /*          EQUATE_TOKEN                                                   */
 /*          ESCP                                                           */
 /*          EXPONENTIATE                                                   */
 /*          EXPRESSION_CONTEXT                                             */
 /*          FALSE                                                          */
 /*          FIRST_FREE                                                     */
 /*          FOREVER                                                        */
 /*          GROUP_NEEDED                                                   */
 /*          ID_LIMIT                                                       */
 /*          ID_TOKEN                                                       */
 /*          LEFT_PAREN                                                     */
 /*          LETTER_OR_DIGIT                                                */
 /*          LEVEL                                                          */
 /*          MAC_TXT                                                        */
 /*          MACRO_ARG_FLAG                                                 */
 /*          MACRO_EXPAN_LIMIT                                              */
 /*          MACRO_TEXT                                                     */
 /*          MAX_STRING_SIZE                                                */
 /*          MAX_STRUC_LEVEL                                                */
 /*          NUMBER                                                         */
 /*          ONE_BYTE                                                       */
 /*          OVER_PUNCH_SIZE                                                */
 /*          OVER_PUNCH_TYPE                                                */
 /*          PARM_CONTEXT                                                   */
 /*          PC_INDEX                                                       */
 /*          PC_LIMIT                                                       */
 /*          PCNAME                                                         */
 /*          PERCENT_MACRO                                                  */
 /*          PRINT_FLAG                                                     */
 /*          RECOVERING                                                     */
 /*          REPLACE_TEXT                                                   */
 /*          RESERVED_LIMIT                                                 */
 /*          RT_PAREN                                                       */
 /*          SAVE_COMMENT                                                   */
 /*          SET_CONTEXT                                                    */
 /*          SRN_PRESENT                                                    */
 /*          STMT_PTR                                                       */
 /*          STRUCTURE_WORD                                                 */
 /*          SUBSCRIPT_LEVEL                                                */
 /*          SYM_ADDR                                                       */
 /*          SYM_LENGTH                                                     */
 /*          SYM_NAME                                                       */
 /*          SYM_TAB                                                        */
 /*          SYT_ADDR                                                       */
 /*          SYT_NAME                                                       */
 /*          TEMPORARY                                                      */
 /*          TRANS_IN                                                       */
 /*          TRUE                                                           */
 /*          TX                                                             */
 /*          V_INDEX                                                        */
 /*          VALID_00_CHAR                                                  */
 /*          VALID_00_OP                                                    */
 /*          VAR_LENGTH                                                     */
 /*          VOCAB_INDEX                                                    */
 /*          X1                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          BASE_PARM_LEVEL                                                */
 /*          BCD                                                            */
 /*          BLANK_COUNT                                                    */
 /*          C                                                              */
 /*          COMM                                                           */
 /*          COMMENT_COUNT                                                  */
 /*          CONTEXT                                                        */
 /*          DONT_SET_WAIT                                                  */
 /*          EQUATE_IMPLIED                                                 */
 /*          EXP_OVERFLOW                                                   */
 /*          EXP_TYPE                                                       */
 /*          FIRST_TIME                                                     */
 /*          FIRST_TIME_PARM                                                */
 /*          FIXING                                                         */
 /*          FOR_DW                                                         */
 /*          FOUND_CENT                                                     */
 /*          GRAMMAR_FLAGS                                                  */
 /*          IMPLIED_TYPE                                                   */
 /*          I                                                              */
 /*          INCL_SRN                                                       */
 /*          K                                                              */
 /*          LABEL_IMPLIED                                                  */
 /*          LOOKUP_ONLY                                                    */
 /*          M_BLANK_COUNT                                                  */
 /*          M_CENT                                                         */
 /*          M_P                                                            */
 /*          M_PRINT                                                        */
 /*          M_TOKENS                                                       */
 /*          MACRO_CALL_PARM_TABLE                                          */
 /*          MACRO_EXPAN_LEVEL                                              */
 /*          MACRO_EXPAN_STACK                                              */
 /*          MACRO_FOUND                                                    */
 /*          MACRO_POINT                                                    */
 /*          MACRO_TEXTS                                                    */
 /*          NEW_MEL                                                        */
 /*          NEXT_CHAR                                                      */
 /*          NUM_OF_PARM                                                    */
 /*          OLD_MEL                                                        */
 /*          OLD_MP                                                         */
 /*          OLD_PEL                                                        */
 /*          OLD_PR_PTR                                                     */
 /*          OLD_TOPS                                                       */
 /*          OVER_PUNCH                                                     */
 /*          P_CENT                                                         */
 /*          PARM_COUNT                                                     */
 /*          PARM_EXPAN_LEVEL                                               */
 /*          PARM_REPLACE_PTR                                               */
 /*          PARM_STACK_PTR                                                 */
 /*          PASS                                                           */
 /*          PRINTING_ENABLED                                               */
 /*          RESERVED_WORD                                                  */
 /*          RESTORE                                                        */
 /*          SAVE_PE                                                        */
 /*          SOME_BCD                                                       */
 /*          START_POINT                                                    */
 /*          SUPPRESS_THIS_TOKEN_ONLY                                       */
 /*          S                                                              */
 /*          SAVE_BLANK_COUNT                                               */
 /*          SAVE_NEXT_CHAR                                                 */
 /*          SAVE_OVER_PUNCH                                                */
 /*          SCAN_COUNT                                                     */
 /*          SRN                                                            */
 /*          SRN_COUNT                                                      */
 /*          STRING_OVERFLOW                                                */
 /*          SYT_INDEX                                                      */
 /*          T_INDEX                                                        */
 /*          TEMP_INDEX                                                     */
 /*          TEMP_STRING                                                    */
 /*          TEMPLATE_IMPLIED                                               */
 /*          TEMPORARY_IMPLIED                                              */
 /*          TOKEN                                                          */
 /*          TOKEN_FLAGS                                                    */
 /*          TOP_OF_PARM_STACK                                              */
 /*          VALUE                                                          */
 /*          WAIT                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          FINISH_MACRO_TEXT                                              */
 /*          HEX                                                            */
 /*          IDENTIFY                                                       */
 /*          MIN                                                            */
 /*          PREP_LITERAL                                                   */
 /*          SAVE_TOKEN                                                     */
 /*          STREAM                                                         */
 /* CALLED BY:                                                              */
 /*          INITIALIZATION                                                 */
 /*          CALL_SCAN                                                      */
 /***************************************************************************/
'''

def SCAN():
    # Locals:
    SIG_DIGITS = 0
    SIGN = 0
    EXP_SIGN = 0
    EXP_BEGIN = 0
    S1 = 0
    EXP_DIGITS = 0
    DEC_POINT = 0
    CHAR_NEEDED = 0
    SEARCH_NEEDED = g.TRUE
    CHAR_ALREADY_SCANNED = 0
    OVERPUNCH_ALREADY_SCANNED = 0
    INTERNAL_BCD = ''
    COMMENT_PTR = 0
    DIGIT = 0
    TEMP_CHAR = 0
    BLANK_BYTES = 0
    ESCAPE_LEVEL = 0

    def CHAR_OP_CHECK(CHAR):
        # Locals.
        HOLD_CHAR = 0
        
        if g.OVER_PUNCH == 0:
            return CHAR;
        if g.OVER_PUNCH in CHAR_OP:
            if g.OVER_PUNCH == CHAR_OP[0]:  # LEVEL 1 ESCAPE 
                HOLD_CHAR = TRANS_IN(CHAR) & 0xFF;
            else: # g.OVER_PUNCH == CHAR_OP[1]
                HOLD_CHAR = SHR(TRANS_IN(CHAR), 8) & 0xFF;  # LEVEL 2 ESCAPE
            if HOLD_CHAR == 0x00:
                if g.OVER_PUNCH != VALID_00_OP or CHAR != VALID_00_CHAR:
                    ERROR(d.CLASS_MO, 6, HEX(CHAR, 2));
                    return CHAR;
            return HOLD_CHAR;
        else: # ILLEGAL OVER PUNCH */
            ERROR(d.CLASS_MO, 1, HEX(CHAR, 2));
            return CHAR;  # NO TRANSLATION 

    def BUILD_BCD():
        # No locals.
        g.BCD = g.BCD + g.NEXT_CHAR

    def BUILD_INTERNAL_BCD():
        nonlocal INTERNAL_BCD
        # No locals.
        INTERNAL_BCD = INTERNAL_BCD + g.NEXT_CHAR
      
    def PARAMETER_PROCESSING():
        # Locals
        g.I = 0
        ARG_COUNT = 0;
        NUM_OF_PAREN = 0 ;
        LAST_ARG = g.FALSE;
        QUOTE_FLAG = g.FALSE;
        D_QUOTE_FLAG = g.FALSE;
        CENT_FLAG= g.FALSE;
        
        if VAR_LENGTH[g.SYT_INDEX]==0:
           LAST_ARG = g.TRUE;
        else:
            if g.NEXT_CHAR == BYTE('('):
                g.TOKEN_FLAGS(STMT_PTR, g.TOKEN_FLAGS(STMT_PTR)|0x20);
                g.RESERVED_WORD=g.TRUE;
                g.SAVE_TOKEN(LEFT_PAREN,0,0x20,1);
                g.GRAMMAR_FLAGS[STMT_PTR] = g.GRAMMAR_FLAGS[STMT_PTR] or MACRO_ARG_FLAG;
                for g.I in range(1, g.NUM_OF_PARM[g.MACRO_EXPAN_LEVEL+1]+1):
                    g.TEMP_STRING=g.X1;
                    while True:
                        STREAM();
                        if g.NEXT_CHAR == BYTE(SQUOTE):
                            QUOTE_FLAG = not QUOTE_FLAG;
                        elif QUOTE_FLAG == g.FALSE:
                            if g.NEXT_CHAR == BYTE('('):
                                NUM_OF_PAREN=NUM_OF_PAREN+1;
                            elif g.NEXT_CHAR == BYTE(')'):
                                NUM_OF_PAREN=NUM_OF_PAREN-1;
                                if NUM_OF_PAREN < 0:
                                    LAST_ARG=g.TRUE;
                                    STREAM();
                                    break;
                            elif g.NEXT_CHAR==BYTE('"'):
                                D_QUOTE_FLAG=not D_QUOTE_FLAG;
                            elif g.NEXT_CHAR==BYTE('`'):
                                CENT_FLAG=not CENT_FLAG;
                            elif g.NEXT_CHAR == BYTE(','):
                                if NUM_OF_PAREN==0 and D_QUOTE_FLAG == g.FALSE:
                                    if CENT_FLAG==g.FALSE:
                                        if QUOTE_FLAG==g.FALSE:
                                            break;
                        if LENGTH(g.TEMP_STRING) == 250:
                           ERROR(d.CLASS_IR,7);
                           return;
                        ONE_BYTE = BYTE(ONE_BYTE, 0, g.NEXT_CHAR);
                        g.TEMP_STRING = g.TEMP_STRING + g.ONE_BYTE;
                        if g.NEXT_CHAR == BYTE(g.X1):
                            if g.BLANK_COUNT > 0:
                                if (LENGTH(g.TEMP_STRING)+g.BLANK_COUNT) > 250:
                                    ERROR(d.CLASS_IR,7);
                                    return;
                                else:
                                    for K in range(1, g.BLANK_COUNT+1):
                                        g.TEMP_STRING=g.TEMP_STRING+g.X1;
                    ARG_COUNT= ARG_COUNT + 1;
                    g.TEMP_STRING=SUBSTR(g.TEMP_STRING,1);
                    g.MACRO_CALL_PARM_TABLE[g.I+g.TOP_OF_PARM_STACK]=SUBSTR(g.TEMP_STRING,1);
                    if LENGTH(g.TEMP_STRING)>0:
                        g.RESERVED_WORD=g.FALSE;
                        g.SAVE_TOKEN(CHARACTER_STRING,g.TEMP_STRING,0,1); 
                        g.GRAMMAR_FLAGS[STMT_PTR]=g.GRAMMAR_FLAGS[STMT_PTR]|MACRO_ARG_FLAG;
                    if LAST_ARG == g.TRUE:
                        break;
                    g.RESERVED_WORD=g.TRUE;
                    g.SAVE_TOKEN(COMMA,0,0x20,1);
                    g.GRAMMAR_FLAGS[STMT_PTR]=g.GRAMMAR_FLAGS[STMT_PTR]|MACRO_ARG_FLAG;
            else:
                LAST_ARG = g.TRUE;
        if ARG_COUNT != g.NUM_OF_PARM[g.MACRO_EXPAN_LEVEL+1] or LAST_ARG == g.FALSE:
            ERROR(d.CLASS_IR,8);
            return;
        noBackup = False
        if g.NEXT_CHAR==BYTE('`'):
            if g.FOUND_CENT:
                if g.MACRO_EXPAN_LEVEL>0:
                    noBackup = True
                else:
                    STREAM();
        if not noBackup:
            if g.PARM_REPLACE_PTR>g.BASE_PARM_LEVEL(g.MACRO_EXPAN_LEVEL):
                if g.FIRST_TIME_PARM[g.PARM_REPLACE_PTR]:
                    g.PARM_REPLACE_PTR(g.PARM_REPLACE_PTR, g.PARM_REPLACE_PTR(g.PARM_REPLACE_PTR)-1);
                else:
                    g.FIRST_TIME_PARM[g.PARM_REPLACE_PTR, g.TRUE];
            else:
                if g.FIRST_TIME[g.MACRO_EXPAN_LEVEL]:
                    if g.MACRO_TEXT(g.MACRO_POINT-2)==0xEE:
                        g.MACRO_POINT=g.MACRO_POINT-2;
                    elif g.MACRO_TEXT(g.MACRO_POINT)!=0xEF:
                        g.MACRO_POINT=g.MACRO_POINT-1;
                    elif g.MACRO_TEXT(g.MACRO_POINT) ==0xEF and \
                            g.MACRO_TEXT(g.MACRO_POINT-1) == g.NEXT_CHAR:
                        g.MACRO_POINT=g.MACRO_POINT-1;
                else:
                    g.FIRST_TIME[g.MACRO_EXPAN_LEVEL, g.TRUE];
        if ARG_COUNT>0:
            g.RESERVED_WORD=g.TRUE;
            g.SAVE_TOKEN(RT_PAREN,0,0,1);
            g.GRAMMAR_FLAGS[STMT_PTR]=g.GRAMMAR_FLAGS[STMT_PTR]|MACRO_ARG_FLAG;
        g.M_P(g.MACRO_EXPAN_LEVEL, g.MACRO_POINT);
        g.M_BLANK_COUNT(g.MACRO_EXPAN_LEVEL, g.BLANK_COUNT);
        g.MACRO_EXPAN_LEVEL=g.MACRO_EXPAN_LEVEL+1;
        g.FIRST_TIME[g.MACRO_EXPAN_LEVEL, g.TRUE];
        g.TOP_OF_PARM_STACK = g.TOP_OF_PARM_STACK + ARG_COUNT;
        g.TEMP_STRING = '';
        g.RESERVED_WORD=g.FALSE;
    
    #--------------------------------------------------------------------
    # ROUTINE TO DETERMINE IF END OF MACRO HAS BEEN REACHED BY
    # MACRO_POINT
    #--------------------------------------------------------------------
    def END_OF_MACRO():
        # MP is local.
        MP=g.MACRO_POINT;
        # FIRST SKIP BLANKS
        while g.MACRO_TEXT(MP)==0xEE or g.MACRO_TEXT(MP)==BYTE(g.X1):
            if g.MACRO_TEXT(MP)==0xEE:
                MP=MP+1;
            MP=MP+1;
        # THEN CHECK FOR END OF MACRO CHARACTER
        if g.MACRO_TEXT(MP)==0xEF:
            if g.NEXT_CHAR==BYTE(g.X1):
                return g.TRUE;
        return g.FALSE;
    
    '''
    The internals of SCAN() are pure spaghetti, with innumerable labels
    for the XPL to GO TO, and no jump operation in Python3 at all to do it with.
    The various boolean variables goto_XXXX you'll find below, with XXXX 
    corresponding to one of the labels that are targets for GO TO in the 
    original XPL, are the workarounds.  Normally, all of them will be False.
    But when a "GO TO" is in progress, precisely one of them will be True,
    and will be reset to False immediately when the target position is reached.
    '''
    goto_SCAN_END = False
    goto_SCAN_TOP = False
    goto_SCAN_START = False
    goto_DEC_POINT_ENTRY = False
    goto_CASE13 = False
    goto_CENT_START = False
    
    if SEARCH_NEEDED:  # PRE-SEARCH FOR COMMENTS
        goto_SCAN_END = True;
        
    while True: 
        ''' 
        The stuff below isn't looped in the original code.  It's
        a workaround to implement some of the goto_XXXX jumps 
        described above, which tend to jump right into the middle 
        of blocks. 
        '''
        
        if not (goto_SCAN_END or goto_DEC_POINT_ENTRY) \
                or goto_SCAN_TOP or goto_SCAN_START:
            if goto_SCAN_TOP: # CONTROL RETURNED HERE FROM COMMENT SEARCH
                print("SC @ SCAN_TOP:")
                goto_SCAN_TOP = False
            
            if not goto_SCAN_START:
                print("SC A", g.SCAN_COUNT, CHAR_NEEDED)
                g.SCAN_COUNT = g.SCAN_COUNT + 1;
                if CHAR_NEEDED:
                    STREAM();
                    CHAR_NEEDED = g.FALSE;
            else:
                print("SC B SCAN_START:")
                goto_SCAN_START = False
                
            g.M_TOKENS[g.MACRO_EXPAN_LEVEL]=g.M_TOKENS[g.MACRO_EXPAN_LEVEL]+1;
            g.BCD = '';
            g.FIXING=0;
            g.VALUE = 0;
            g.SYT_INDEX = 0;
            g.RESERVED_WORD = g.TRUE;
            g.IMPLIED_TYPE = 0;
        
        while not goto_SCAN_END:    # START OF SCAN
            if goto_DEC_POINT_ENTRY:
                ct = 1
            elif goto_CENT_START:
                ct = 2
            elif goto_CASE13:
                ct = 13
            else:
                if not g.MACRO_FOUND:
                    if g.SRN_PRESENT:
                        g.SRN[1]=g.SRN[0];
                        g.INCL_SRN[1] = g.INCL_SRN[0];
                        g.SRN_COUNT[1]=g.SRN_COUNT[0];
                print("SC B.1", g.NEXT_CHAR)
                ct = g.CHARTYPE[g.NEXT_CHAR]
                
            # DO CASE CHARTYPE(g.NEXT_CHAR);
            if ct == 0:
                print("SC C", g.NEXT_CHAR, "ILLEGAL CHARACTERS")
                # CASE 0--ILLEGAL CHARACTERS
                g.C[0] = HEX(g.NEXT_CHAR, 2);
                ERROR(d.CLASS_DT,4,g.C[0]);
                if g.OVER_PUNCH != 0:
                   ERROR(d.CLASS_MO,1);
                STREAM();
            elif ct == 1:
                print("SC C", g.NEXT_CHAR, "DIGITS")
                # CASE 1--DIGITS
                if not goto_DEC_POINT_ENTRY:
                    g.RESERVED_WORD = g.FALSE
                    DEC_POINT = g.FALSE;
                    BUILD_BCD();
                    if g.OVER_PUNCH != 0:
                        ERROR(d.CLASS_MO,1);
                    STREAM();
                    g.TOKEN = NUMBER;
                    if g.NEXT_CHAR==BYTE(g.X1) or g.NEXT_CHAR==BYTE(')'):
                        g.VALUE = BYTE(g.BCD) - BYTE('0');
                        if g.VALUE >= 1 and g.VALUE <= MAX_STRUC_LEVEL:
                            g.TOKEN = LEVEL;
                    DIGIT = BYTE(g.BCD);
                else:
                    goto_DEC_POINT_ENTRY = False
                SIG_DIGITS=0;
                INTERNAL_BCD = g.BCD;  # START THE SAME
                
                goto_SIG_CHECK = True
                goto_LOOP_END = False
                goto_GET_NEW_CHAR = False
                while not goto_GET_NEW_CHAR:
                    while g.CHARTYPE[DIGIT] == 1:
                        if not goto_SIG_CHECK:
                            if g.OVER_PUNCH != 0:
                               ERROR(d.CLASS_MO,1);
                            BUILD_BCD();
                            BUILD_INTERNAL_BCD();
                        else:
                            goto_SIG_CHECK = False
                        if SIG_DIGITS == 0:
                            if DIGIT == BYTE('0'):
                                if LENGTH(g.BCD) == 1:
                                    goto_LOOP_END = True;
                                else:
                                    goto_GET_NEW_CHAR = False;
                        if not goto_LOOP_END and not goto_GET_NEW_CHAR:
                            SIG_DIGITS = SIG_DIGITS + 1;
                            if SIG_DIGITS > 74:
                                goto_GET_NEW_CHAR = True;   # TOO MANY SIG DIGITS
                            elif LENGTH(g.BCD) == 1:
                                goto_LOOP_END = True;
                        if not goto_LOOP_END:
                            goto_GET_NEW_CHAR = False
                            STREAM();
                        goto_LOOP_END = False
                        DIGIT = g.NEXT_CHAR;
                    # OF DO WHILE...
                    
                    if DIGIT == BYTE(PERIOD):
                        if DEC_POINT:
                            BUILD_BCD();
                            ERROR(d.CLASS_LF,2);
                            if g.OVER_PUNCH != 0:
                                ERROR(d.CLASS_MO,1);
                            goto_GET_NEW_CHAR = True;
                            continue
                        DEC_POINT = g.TRUE;
                        BUILD_BCD();
                        BUILD_INTERNAL_BCD();
                        if g.OVER_PUNCH != 0:
                            ERROR(d.CLASS_MO,1);
                        goto_GET_NEW_CHAR = True;
                        continue;
        
                goto_START_EXPONENT = True
                goto_POWER_INDICATOR = False
                while goto_START_EXPONENT or goto_POWER_INDICATOR:
                    goto_START_EXPONENT = False
                    goto_EXP_DONE = False
                    goto_RESET_LITERAL = False
                    if not goto_POWER_INDICATOR:
                        g.EXP_TYPE = DIGIT;
                    if goto_POWER_INDICATOR or g.EXP_TYPE == BYTE('E'):
                        goto_POWER_INDICATOR = False
                        EXP_SIGN = 0;
                        EXP_BEGIN = 0;
                        EXP_DIGITS = 0;
                        EXP_BEGIN = LENGTH(INTERNAL_BCD) + 1;
                        goto_EXP_CHECK = True
                        while goto_EXP_CHECK:
                            while goto_EXP_CHECK or g.CHARTYPE[DIGIT] == 1:
                                if not goto_EXP_CHECK:
                                    EXP_DIGITS = EXP_DIGITS + 1;
                                else:
                                    goto_EXP_CHECK = False
                                if g.OVER_PUNCH != 0:
                                    ERROR(d.CLASS_MO,1);
                                BUILD_BCD();
                                BUILD_INTERNAL_BCD();
                                STREAM();
                                DIGIT = g.NEXT_CHAR;
                            if LENGTH(INTERNAL_BCD) == EXP_BEGIN:
                                if DIGIT == BYTE('+') or DIGIT == BYTE('-'):
                                    EXP_SIGN = DIGIT;
                                    goto_EXP_CHECK = True;
                                    continue;
                                ERROR(d.CLASS_LF, 1);
                                goto_RESET_LITERAL = True
                                break
                            else:
                                goto_EXP_DONE = True
                                break
                    
                    goto_NUMBER_DONE = False
                    if not goto_RESET_LITERAL:
                        if not goto_EXP_DONE:
                            if g.EXP_TYPE == BYTE('H') or g.EXP_TYPE == BYTE('B'):
                                goto_POWER_INDICATOR = True;
                                continue
                            goto_NUMBER_DONE = True
                        else:
                            goto_EXP_DONE = False
                        
                    if not goto_NUMBER_DONE:
                        if goto_RESET_LITERAL or EXP_DIGITS <= 0:
                            if not goto_RESET_LITERAL:
                                ERROR(d.CLASS_LF,5);
                            else:
                                goto_RESET_LITERAL = False;
                            INTERNAL_BCD = SUBSTR(INTERNAL_BCD, 0, EXP_BEGIN - 1);
                        goto_START_EXPONENT = True
                    else:
                        goto_NUMBER_DONE = False
                
                if SIG_DIGITS > 74:
                    ERROR(d.CLASS_LF,3);
                g.EXP_OVERFLOW = MONITOR(10, INTERNAL_BCD);  # CONVERT THE NUMBER
                if g.EXP_OVERFLOW:
                    ERROR(d.CLASS_LC, 2, g.BCD);
                PREP_LITERAL();
                goto_SCAN_END = True;
                # END OF CASE 1
                
            elif ct == 2:
                print("SC C", g.NEXT_CHAR, "INDENTS & RESERVED WORDS")
                # CASE 2--LETTERS=IDENTS & RESERVED WORDS
                if not goto_CENT_START:
                    g.STRING_OVERFLOW = g.FALSE;
                    g.LABEL_IMPLIED = g.FALSE;
                    g.IMPLIED_TYPE = 0;
                goto_FOUND_TOKEN = False;
                while True:
                    goto_CENT_START = False;
                    if LETTER_OR_DIGIT(g.NEXT_CHAR):
                        # VALID CHARACTER 
                        
                        def ID_LOOP():
                            nonlocal S1
                            # No locals
                            goto_NEW_CHAR = False;
                            S1=g.NEXT_CHAR=BYTE('_');
                            if LENGTH(g.BCD) < ID_LIMIT:
                                BUILD_BCD();
                                if g.OVER_PUNCH != 0:
                                    if g.IMPLIED_TYPE > 0:
                                        ERROR(d.CLASS_MO,3);
                                    else:
                                        for g.I in range(1, OVER_PUNCH_SIZE+1):
                                            if g.OVER_PUNCH == OVER_PUNCH_TYPE(g.I):
                                                g.IMPLIED_TYPE = g.I;
                                                goto_NEW_CHAR = True;
                                                break;
                                        if not goto_NEW_CHAR:
                                            ERROR(d.CLASS_MO,4);
                                            g.OVER_PUNCH = 0;
                            else:
                                # TOO MANY CHARACTERS IN IDENT
                                if not g.STRING_OVERFLOW:
                                    ERROR(d.CLASS_IL,2);
                                    g.STRING_OVERFLOW = g.TRUE;
                            goto_NEW_CHAR = False;
                            STREAM();
                        
                        ID_LOOP();
                        # END OF DO...VALID CHARACTER
                    else:
                        if S1:
                            if g.NEXT_CHAR != BYTE('`'):
                                ERROR(d.CLASS_IL, 1);
                        goto_FOUND_TOKEN = True;
                        break;
                # OF DO FOREVER
                
                goto_FOUND_TOKEN = False;
                goto_END_CHECK_RESERVED_WORD = False;
                if g.NEXT_CHAR==BYTE('`'):
                    goto_CASE13 = True
                    continue
                else:
                    S1 = LENGTH(g.BCD);
                    if S1 > 1:
                        if S1 <= RESERVED_LIMIT:
                            # CHECK FOR RESERVED WORDS
                            for g.I in range(V_INDEX(S1 - 1), V_INDEX(S1)):
                                g.S = STRING(VOCAB_INDEX(g.I));
                                if BYTE(g.S) > BYTE(g.BCD):
                                    goto_END_CHECK_RESERVED_WORD = True;
                                    break;
                                if g.S == g.BCD:
                                    g.TOKEN = g.I;
                                    if g.IMPLIED_TYPE > 0:
                                        ERROR(d.CLASS_MC,4,g.BCD);
                                    g.I = SET_CONTEXT(g.I);
                                    if g.I > 0:
                                        if g.TOKEN==TEMPORARY:
                                            g.TEMPORARY_IMPLIED=g.TRUE;
                                        if g.TOKEN == EQUATE_TOKEN:
                                           g.EQUATE_IMPLIED = g.TRUE;
                                        if g.I == EXPRESSION_CONTEXT:
                                           if g.CONTEXT == DECLARE_CONTEXT or \
                                                  g.CONTEXT == PARM_CONTEXT:
                                              g.OLD_MEL=g.MACRO_EXPAN_LEVEL;
                                              g.SAVE_PE=g.PRINTING_ENABLED;
                                              while g.NEXT_CHAR == BYTE(g.X1):
                                                  if not g.MACRO_FOUND:
                                                      g.SAVE_BLANK_COUNT = g.BLANK_COUNT;
                                                  STREAM();
                                              if g.OLD_MEL>g.MACRO_EXPAN_LEVEL:
                                                  if g.M_TOKENS(g.OLD_MEL)<=1:
                                                      if g.SAVE_PE!=g.PRINTING_ENABLED:
                                                          g.SUPPRESS_THIS_TOKEN_ONLY=g.TRUE;
                                              if g.NEXT_CHAR == BYTE('('):
                                                  g.CONTEXT = g.I;
                                           else:
                                               if g.TOKEN == STRUCTURE_WORD:
                                                   g.CONTEXT = DECLARE_CONTEXT;
                                                   g.TEMPLATE_IMPLIED = g.TRUE;
                                        else:
                                           if g.CONTEXT != DECLARE_CONTEXT:
                                               if g.CONTEXT != EXPRESSION_CONTEXT:
                                                   g.CONTEXT = g.I;
                                    goto_SCAN_END = True
                                    break
                    
                goto_END_CHECK_RESERVED_WORD = False;
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
                    def PARM_FOUND():
                        # No locals
                        g.TEMP_INDEX=g.MACRO_EXPAN_LEVEL;
                        g.PARM_COUNT=g.NUM_OF_PARM[g.TEMP_INDEX];
                        while g.TEMP_INDEX>0:
                            for g.I in range(1, g.NUM_OF_PARM[g.TEMP_INDEX]+1):
                                if g.BCD==SYT_NAME[MACRO_EXPAN_STACK[g.TEMP_INDEX]+g.I]:
                                    g.PARM_REPLACE_PTR = g.PARM_REPLACE_PTR + 1;
                                    g.FIRST_TIME_PARM[g.PARM_REPLACE_PTR]=g.TRUE;
                                    g.PARM_REPLACE_PTR[g.PARM_REPLACE_PTR] = 0;
                                    g.PARM_STACK_PTR[g.PARM_REPLACE_PTR] = \
                                        g.I + g.TOP_OF_PARM_STACK-g.PARM_COUNT;
                                    if g.BASE_PARM_LEVEL[g.MACRO_EXPAN_LEVEL]+1 == \
                                            g.PARM_REPLACE_PTR:
                                        if not g.FOUND_CENT:
                                            if not END_OF_MACRO:
                                                if g.MACRO_TEXT[g.MACRO_POINT-2]==0xEE:
                                                    g.MACRO_POINT=g.MACRO_POINT-1;
                                                g.MACRO_POINT=g.MACRO_POINT-1;
                                    else:
                                        if g.FIRST_TIME_PARM[g.PARM_REPLACE_PTR-1]:
                                            #  CHECK FOR CENT SIGN
                                            if g.NEXT_CHAR!=BYTE('`'):
                                                g.PARM_REPLACE_PTR[g.PARM_REPLACE_PTR-1]= \
                                                    g.PARM_REPLACE_PTR[g.PARM_REPLACE_PTR-1]-1;
                                        else:
                                            g.FIRST_TIME_PARM[g.PARM_REPLACE_PTR-1]=g.TRUE;
                                    g.BLANK_COUNT = 0
                                    g.OVER_PUNCH = 0;
                                    g.P_CENT[g.PARM_REPLACE_PTR]=g.FOUND_CENT;
                                    STREAM();
                                    return 1;
                            g.TEMP_INDEX=g.TEMP_INDEX-1;
                            g.PARM_COUNT=g.PARM_COUNT + g.NUM_OF_PARM[g.TEMP_INDEX];
                        return 0;
                    
                    g.FOUND_CENT=g.FALSE;
                    if PARM_FOUND:
                        goto_SCAN_START = True;
                        break;
                
                g.OLD_MEL = g.MACRO_EXPAN_LEVEL;
                g.OLD_PEL = g.PARM_REPLACE_PTR;
                g.OLD_PR_PTR = g.PARM_REPLACE_PTR(g.PARM_REPLACE_PTR);
                g.OLD_TOPS=g.TOP_OF_PARM_STACK;
                g.SAVE_PE = g.PRINTING_ENABLED;
                g.OLD_MP=g.MACRO_POINT;
                while g.NEXT_CHAR==BYTE(g.X1):
                    if not g.MACRO_FOUND:
                        g.SAVE_BLANK_COUNT=g.BLANK_COUNT;
                    STREAM();
                g.NEW_MEL = g.MACRO_EXPAN_LEVEL;
                if g.OLD_MEL > g.NEW_MEL:
                    if g.M_TOKENS(g.OLD_MEL) <= 1:
                        if g.SAVE_PE != g.PRINTING_ENABLED:
                            g.SUPPRESS_THIS_TOKEN_ONLY = g.TRUE;
                if SUBSCRIPT_LEVEL == 0:
                    if g.NEXT_CHAR == BYTE(':'):
                        if g.CONTEXT != DECLARE_CONTEXT:
                            g.LABEL_IMPLIED = g.TRUE;
                    else:
                        if g.NEXT_CHAR == BYTE('-'):
                            if g.CONTEXT == DECLARE_CONTEXT or g.CONTEXT == PARM_CONTEXT:
                                g.TEMPLATE_IMPLIED = g.TRUE;
                                g.LOOKUP_ONLY = g.TRUE;
                if RECOVERING:
                    g.LOOKUP_ONLY = g.FALSE;
                    g.TEMPLATE_IMPLIED = g.FALSE;
                    goto_SCAN_END = True;  # WITHOUT CALLING IDENTIFY
                    break;
                IDENTIFY(g.BCD,0);
                g.LOOKUP_ONLY = g.FALSE;
                g.TEMPLATE_IMPLIED = g.FALSE;
                if CONTROL(3):
                    if g.TOKEN > 0:
                        g.S = STRING(VOCAB_INDEX(g.TOKEN));
                    else:
                        g.S = g.TOKEN;
                    OUTPUT(0, g.BCD + ' :  TOKEN = ' + g.S + ', IMPLIED_TYPE = ' \
                                + g.IMPLIED_TYPE + ', g.SYT_INDEX = ' + g.SYT_INDEX \
                                + ', CONTEXT = ' + g.CONTEXT);
                if g.MACRO_FOUND:
                    if g.OLD_PEL!=g.PARM_REPLACE_PTR:
                        if g.BASE_PARM_LEVEL(g.MACRO_EXPAN_LEVEL)>=g.PARM_REPLACE_PTR:
                            g.NEXT_CHAR=BYTE(g.X1);
                            g.MACRO_POINT=g.MACRO_POINT-1;
                            
                if g.TOKEN < 0: # MACRO NAME FOUND
                    if g.MACRO_EXPAN_LEVEL==0 and g.SAVE_NEXT_CHAR==BYTE(g.X1):
                        g.SAVE_NEXT_CHAR = g.NEXT_CHAR;
                    if g.OLD_MEL > g.NEW_MEL:
                        if g.PARM_REPLACE_PTR>g.BASE_PARM_LEVEL(g.MACRO_EXPAN_LEVEL):
                            if g.OLD_PR_PTR<g.PARM_REPLACE_PTR(g.PARM_REPLACE_PTR):
                                g.PARM_REPLACE_PTR(g.PARM_REPLACE_PTR, g.OLD_PR_PTR);
                        g.NEW_MEL, g.MACRO_EXPAN_LEVEL = g.OLD_MEL;
                        g.MACRO_FOUND = g.TRUE;
                        g.WAIT=g.FALSE;
                        g.MACRO_POINT = g.OLD_MP;
                        g.PRINTING_ENABLED=g.SAVE_PE;
                        g.TOP_OF_PARM_STACK=g.OLD_TOPS;
                    if STMT_STACK(STMT_PTR)==SEMI_COLON and STMT_END_PTR==STMT_PTR:
                        OUTPUT_WRITER(LAST_WRITE,STMT_PTR);
                       
                    def PUSH_MACRO():
                        # No locals
                        g.SUPPRESS_THIS_TOKEN_ONLY = g.FALSE;
                        #           GET NEXT NON-BLANK BEFORE
                        #           PARAMETER_PROCESSING     
                        while g.NEXT_CHAR==BYTE(g.X1):
                           STREAM();
                        if g.MACRO_EXPAN_LEVEL+1 > MACRO_EXPAN_LIMIT:
                            ERROR(d.CLASS_IR,9,g.BCD);
                            g.MACRO_EXPAN_LEVEL = 0
                            g.PARM_REPLACE_PTR = 0
                            g.MACRO_FOUND=0;
                            g.NEXT_CHAR=g.SAVE_NEXT_CHAR;
                            g.OVER_PUNCH=g.SAVE_OVER_PUNCH;
                            g.PRINTING_ENABLED=PRINT_FLAG;
                            return;
                        MACRO_EXPAN_STACK(g.MACRO_EXPAN_LEVEL+1, g.SYT_INDEX);
                        if g.PRINTING_ENABLED==PRINT_FLAG:
                            g.RESTORE=PRINT_FLAG;
                            if g.FOUND_CENT:
                                g.PASS=PRINT_FLAG;
                                g.PRINTING_ENABLED=0;
                            else:
                                g.PASS=0;
                        else:
                            g.RESTORE = 0;
                            g.PASS=0;
                        g.SAVE_TOKEN(ID_TOKEN,g.BCD,7);
                        g.GRAMMAR_FLAGS[STMT_PTR] = g.GRAMMAR_FLAGS[STMT_PTR] \
                                                    or MACRO_ARG_FLAG;
                        g.NUM_OF_PARM[g.MACRO_EXPAN_LEVEL+1]= \
                            VAR_LENGTH(g.SYT_INDEX);
                        PARAMETER_PROCESSING();
                        g.PRINTING_ENABLED=g.PASS;
                        if g.TEMP_STRING == '':
                           g.BASE_PARM_LEVEL[g.MACRO_EXPAN_LEVEL]=g.PARM_REPLACE_PTR;
                           g.M_TOKENS(g.MACRO_EXPAN_LEVEL, 0);
                           g.M_CENT(g.MACRO_EXPAN_LEVEL, g.FOUND_CENT);
                           g.M_PRINT(g.MACRO_EXPAN_LEVEL, g.RESTORE);
                           g.FOUND_CENT=g.FALSE;
                           g.MACRO_POINT = SYT_ADDR(g.SYT_INDEX);
                           if g.MACRO_EXPAN_LEVEL == 1:
                              g.MACRO_FOUND = g.TRUE ;
                              g.SAVE_NEXT_CHAR=g.NEXT_CHAR;
                              g.SAVE_OVER_PUNCH = g.OVER_PUNCH;
                              g.BLANK_COUNT = 0
                              g.OVER_PUNCH=0;
                        else:
                            g.FOUND_CENT=g.FALSE;
                        STREAM();
                        return;
                    
                    PUSH_MACRO();
                    goto_SCAN_START = True;
                elif not g.MACRO_FOUND:
                    g.SAVE_BLANK_COUNT = -1;
                if not goto_SCAN_START:
                    goto_SCAN_END = True;
                break;
                # END OF CASE 2 
                
            elif ct == 3:
                # CASE 3--SPECIAL SINGLE CHARACTERS 
                if g.OVER_PUNCH != 0:
                    ERROR(d.CLASS_MO,1);
                g.TOKEN = TX(g.NEXT_CHAR);
                CHAR_NEEDED = g.TRUE;
                goto_SCAN_END = True
                break
                # END OF CASE 3 
               
            elif ct == 4:
                print("SC C", g.NEXT_CHAR, "PERIOD")
                # CASE 4--PERIOD
                # COULD BE DOT PRODUCT OR DECIMAL POINT
                if g.OVER_PUNCH != 0:
                    ERROR(d.CLASS_MO,1);
                BUILD_BCD();
                STREAM();
                if g.CHARTYPE[g.NEXT_CHAR] == 1:
                    DEC_POINT = g.TRUE;
                    BUILD_BCD();
                    g.TOKEN = NUMBER;
                    DIGIT = g.NEXT_CHAR;
                    if g.OVER_PUNCH != 0:
                        ERROR(d.CLASS_MO,1);
                    g.RESERVED_WORD = g.FALSE;
                    goto_DEC_POINT_ENTRY = True;
                    break;
                g.TOKEN = TX(BYTE(PERIOD));
                goto_SCAN_END = True
                break
                # END OF CASE 4
                
            elif ct == 5:
                print("SC C", g.NEXT_CHAR, "SINGLE QUOTE")
                # CASE 5--SINGLE QUOTE = CHARACTER LITERAL
                g.I = 0;
                g.STRING_OVERFLOW, g.RESERVED_WORD = g.FALSE;
                if g.OVER_PUNCH != 0:
                    ERROR(d.CLASS_MO, 5);
                g.TOKEN = CHARACTER_STRING;
                goto_CHECK = True;
                goto_BUILD = False;
                firstTry = True
                while firstTry or goto_BUILD:
                    firstTry = False;
                    while goto_BUILD or goto_CHECK or g.NEXT_CHAR != BYTE(SQUOTE):
                        goto_BUILD = False;
                        if not goto_CHECK:
                            if g.NEXT_CHAR != BYTE(g.X1):
                                g.BLANK_COUNT = 0;
                            for g.I in range(0, g.BLANK_COUNT+1):
                                if LENGTH(g.BCD) < CHAR_LENGTH_LIM:
                                    BUILD_BCD();
                                else:
                                    ERROR(d.CLASS_LS,1);
                                    # Originally the label STR_TOO_LONG
                                    # preceded the following code.
                                    g.STRING_OVERFLOW = g.TRUE;
                                    goto_SCAN_END = True;
                                    break;
                        if goto_SCAN_END:
                            break;
                        goto_CHECK = False;
                        STREAM();
                        ESCAPE_LEVEL = -1;
                        while g.NEXT_CHAR == ESCP:
                            ESCAPE_LEVEL = ESCAPE_LEVEL + 1;
                            if g.OVER_PUNCH != 0:
                                ERROR(d.CLASS_MO, 8);
                            STREAM();
                        TEMP_CHAR = CHAR_OP_CHECK(g.NEXT_CHAR);
                        if ESCAPE_LEVEL >= 0:
                            if ESCAPE_LEVEL > 1:
                                ERROR(d.CLASS_MO, 7, HEX(g.NEXT_CHAR, 2));
                                ESCAPE_LEVEL = 1;
                            g.OVER_PUNCH = CHAR_OP(ESCAPE_LEVEL);
                            if g.NEXT_CHAR == BYTE(g.X1):   # HANDLE MULT BLANKS CAREFULLY
                                g.NEXT_CHAR = CHAR_OP_CHECK(TEMP_CHAR);
                                if g.BLANK_COUNT > 0:
                                    if LENGTH(g.BCD) < MAX_STRING_SIZE:
                                        BUILD_BCD();
                                    else:
                                        '''
                                        Originally GO TO STR_TOO_LONG.  However,
                                        it was just simpler the code that is
                                        actually at STR_TOO_LONG than to try
                                        and duplicate the jump.
                                        '''
                                        g.STRING_OVERFLOW = g.TRUE;
                                        goto_SCAN_END = True;
                                        break;
                                    g.BLANK_COUNT = g.BLANK_COUNT - 1;
                                    g.NEXT_CHAR = BYTE(g.X1);
                            else:
                                g.NEXT_CHAR = CHAR_OP_CHECK(TEMP_CHAR);
                        # END OF ESCAPE LEVEL >= 0 
                        else:
                            g.NEXT_CHAR = TEMP_CHAR;
                    # END OF DO WHILE...
                    STREAM();
                    if g.NEXT_CHAR != BYTE(SQUOTE):
                        g.VALUE = LENGTH(g.BCD);
                        goto_SCAN_END = True;
                        break;
                    if g.OVER_PUNCH != 0:
                        ERROR(d.CLASS_MO,1);
                    goto_BUILD = True;
                if goto_SCAN_END:
                    break;
                # END OF CASE 5
                
            elif ct == 6:
                print("SC C", g.NEXT_CHAR, "BLANK")
                # CASE 6--BLANK
                while g.NEXT_CHAR == BYTE(g.X1):  
                    g.DONT_SET_WAIT = g.TRUE;
                    STREAM();
                    g.DONT_SET_WAIT = g.FALSE;
                # OF CASE 6
               
            elif ct == 7:
                print("SC C", g.NEXT_CHAR, "| or ||")
                # CASE 7--'|' OR'||' 
                g.TOKEN = TX(g.NEXT_CHAR);
                if g.OVER_PUNCH != 0:
                    ERROR(d.CLASS_MO,1);
                STREAM();
                if g.NEXT_CHAR != BYTE('|'):
                    goto_SCAN_END = True;
                    break;
                if g.OVER_PUNCH != 0:
                    ERROR(d.CLASS_MO,1);
                g.TOKEN = CONCATENATE;
                STREAM();
                goto_SCAN_END = True;
                break;
                # END OF CASE 7
               
            elif ct == 8:
                print("SC C", g.NEXT_CHAR, "* or **")
                # CASE 8--'*' OR '**'
                g.TOKEN = TX(g.NEXT_CHAR);
                if g.OVER_PUNCH != 0:
                    ERROR(d.CLASS_MO,1);
                STREAM();
                if g.NEXT_CHAR != BYTE('*'):
                    goto_SCAN_END = True;
                    break;
                if g.OVER_PUNCH != 0:
                    ERROR(d.CLASS_MO,1);
                g.TOKEN = EXPONENTIATE;
                STREAM();
                goto_SCAN_END = True;
                break;
                # END OF CASE 8
               
            elif ct == 9:
                print("SC C", g.NEXT_CHAR, "EOF")
                # CASE 9--HEX'FE' = EOF
                g.TOKEN = EOFILE;
                STREAM();
                goto_SCAN_END = True;
                break;
                # END OF CASE 9
               
            elif ct == 10:
                print("SC C", g.NEXT_CHAR, "SPECIALS AS BLANKS")
                # CASE 10--SPECIAL CHARACTERS TREATED AS BLANKS */
                g.NEXT_CHAR = BYTE(g.X1);
                g.BLANK_COUNT = 0;
                # END OF CASE 10 
               
            elif ct == 11:
                print("SC C", g.NEXT_CHAR, "DOUBLE QUOTES")
                # CASE 11--DOUBLE QUOTES FOR REPLACE DEFINITION
                g.TOKEN = REPLACE_TEXT;
                g.TEMP_STRING=g.X1;
                BLANK_BYTES = 0;
                g.T_INDEX,START_POINT = FIRST_FREE;
                while True:
                    STREAM();
                    if g.NEXT_CHAR == BYTE('"'):
                        STREAM();
                        if g.NEXT_CHAR != BYTE('"'):
                            FIRST_FREE = g.T_INDEX;
                            FINISH_MACRO_TEXT();
                            goto_SCAN_END = True;
                            break;
                    goto_CONCAT = True
                    while goto_CONCAT:
                        goto_CONCAT = False;
                        NEXT_ELEMENT(MACRO_TEXTS);
                        g.MACRO_TEXT(g.T_INDEX, g.NEXT_CHAR);
                        g.T_INDEX = g.T_INDEX + 1;
                        if g.NEXT_CHAR == BYTE(g.X1):
                            if g.BLANK_COUNT > 0:
                                g.MACRO_TEXT(g.T_INDEX-1, 0xEE);
                                NEXT_ELEMENT(MACRO_TEXTS);
                                NEXT_ELEMENT(MACRO_TEXTS);
                                if g.BLANK_COUNT < 256:
                                   g.MACRO_TEXT(g.T_INDEX, g.BLANK_COUNT);
                                   BLANK_BYTES = BLANK_BYTES + g.BLANK_COUNT-1;
                                   g.T_INDEX = g.T_INDEX+1;
                                else:
                                   g.MACRO_TEXT(g.T_INDEX, 255);
                                   BLANK_BYTES = BLANK_BYTES + 254;
                                   g.BLANK_COUNT=g.BLANK_COUNT-255;
                                   g.T_INDEX=g.T_INDEX+1;
                                   goto_CONCAT = True
                    # END OF DO FOREVER
                # END OF CASE 11
                
            elif ct == 12:
                print("SC C", g.NEXT_CHAR, "%")
                #  CASE 12 - % FOR %MACROS
                g.RESERVED_WORD = g.FALSE;
                g.STRING_OVERFLOW=g.FALSE;
                g.TOKEN=PERCENT_MACRO;
                while True:
                    if LENGTH(g.BCD)<PC_LIMIT:
                        BUILD_BCD();
                    else:
                        g.STRING_OVERFLOW=g.TRUE;
                    if g.OVER_PUNCH!=0:
                        ERROR(d.CLASS_MO,1);
                    STREAM();
                    if not LETTER_OR_DIGIT(g.NEXT_CHAR):
                        if g.STRING_OVERFLOW:
                            ERROR(d.CLASS_IL,2);
                        S1=LENGTH(g.BCD);
                        for g.SYT_INDEX in range(1, PC_INDEX+1):
                           if SUBSTR(PCNAME,SHL(g.SYT_INDEX,4),S1)==g.BCD:
                                goto_SCAN_END = True;
                                break;
                        ERROR(d.CLASS_XM,1,g.BCD);
                        g.SYT_INDEX=0;
                        goto_SCAN_END = True;
                        break;
                # END OF CASE 12
               
            elif ct == 13:
                print("SC C", g.NEXT_CHAR, "CENT")
                #  CASE 13 - ¢ FOR ¢MACROS
                # ... replaced already in this ASCII port by `.
                if goto_CASE13:
                    goto_CASE13 = False;
                g.SOME_BCD=g.BCD;
                g.BCD='';
                STREAM();
                while True:
                    if LETTER_OR_DIGIT(g.NEXT_CHAR):
                        ID_LOOP();
                    else:
                        break;
                        
                g.FOUND_CENT=g.TRUE;
                if g.NEXT_CHAR==BYTE('`'):
                    if PARM_FOUND:
                        if g.SOME_BCD=='':
                            goto_SCAN_START = True;
                            break;
                        g.BCD=g.SOME_BCD;
                        goto_CENT_START = True;
                        break;
                    else:
                        IDENTIFY(g.BCD,1);
                        if g.TOKEN<0:
                            PUSH_MACRO();
                            if g.SOME_BCD=='':
                                goto_SCAN_START = True;
                                break;
                            g.SYT_INDEX=0;
                            g.BCD=g.SOME_BCD;
                            goto_CENT_START = True;
                            break;
                        else:
                            ERROR(d.CLASS_IR,4,g.BCD);
                            goto_SCAN_START = True;
                            break;
                else:
                    IDENTIFY(g.BCD,1);
                    if g.TOKEN<0:
                        PUSH_MACRO();
                        goto_SCAN_START = True;
                        break;
                    else:
                        ERROR(d.CLASS_IR,4,g.BCD);
                        goto_SCAN_START = True;
                        break;
                #  END OF CASE 13  */
            else:
                print("SC C", g.NEXT_CHAR, "UKNOWN")

            # END OF DO CASE...
            if goto_SCAN_END or goto_CENT_START:
                break
        # END OF DO FOREVER
        if goto_SCAN_START or goto_DEC_POINT_ENTRY or goto_CENT_START:
            continue
        
        def BUILD_COMMENT():
            nonlocal COMMENT_PTR
            # No locals
            if g.NEXT_CHAR != BYTE(g.X1):
                g.BLANK_COUNT = 0;
            for g.BLANK_COUNT in range(0, g.BLANK_COUNT+1):
                g.COMMENT_COUNT = g.COMMENT_COUNT + 1;
                if g.COMMENT_COUNT >= 256:
                    if g.COMMENT_COUNT == 256:
                        ERROR(d.CLASS_M, 3);
                COMMENT_PTR = MIN(g.COMMENT_COUNT, 255);
                SAVE_COMMENT = BYTE(SAVE_COMMENT, COMMENT_PTR, g.NEXT_CHAR);
        
        goto_SCAN_END = True;
        goto_TEST_SEARCH = False;
        goto_LOOK_FOR_COMMENT = False;
        goto_SET_SEARCH = False;
        firstTry = True
        while firstTry or goto_TEST_SEARCH or goto_LOOK_FOR_COMMENT \
                or goto_SET_SEARCH:
            firstTry = False;
            while goto_SCAN_END or goto_TEST_SEARCH or goto_LOOK_FOR_COMMENT \
                    or goto_SET_SEARCH:
                goto_SCAN_END = False;
                if not goto_SET_SEARCH:
                    if not goto_LOOK_FOR_COMMENT:
                        if goto_TEST_SEARCH or CHAR_ALREADY_SCANNED != 0:
                            if not goto_TEST_SEARCH:
                                g.NEXT_CHAR = CHAR_ALREADY_SCANNED;
                                CHAR_ALREADY_SCANNED = 0;
                                CHAR_NEEDED = g.FALSE;
                                g.OVER_PUNCH = OVERPUNCH_ALREADY_SCANNED;
                            else:
                                goto_TEST_SEARCH = False;
                            if SEARCH_NEEDED:
                                SEARCH_NEEDED = g.FALSE;
                                goto_SCAN_TOP = True
                                break
                            return;
                    else:
                        goto_LOOK_FOR_COMMENT = False;
                if goto_SET_SEARCH or (g.GROUP_NEEDED and g.MACRO_EXPAN_LEVEL==0):
                    goto_SET_SEARCH = False;
                    if SEARCH_NEEDED:
                        STREAM();
                        CHAR_NEEDED = g.FALSE;
                        goto_SCAN_END = True;
                        continue;
                    SEARCH_NEEDED = CHAR_NEEDED; ''' NO SEARCH NEEDED IF CHAR_NEEDED
                                                     IS NOT ON BECAUSE THE GROUP_NEEDED
                                                     CONDITION MUST BE CAUSED BY A LOOK
                                                     AHEAD IN g.NEXT_CHAR WHICH REALLY WAS
                                                     IN COLUMN 80 AND WILL BE SCANNED OUT
                                                     NEXT TIME '''
                    return;
                else:
                    if CHAR_NEEDED:
                        CHAR_NEEDED = g.FALSE;
                        STREAM();
            if goto_SCAN_TOP:
                break
            
            while g.NEXT_CHAR == BYTE(g.X1):
                if g.M_TOKENS[g.MACRO_EXPAN_LEVEL] <= 1:
                    return;
                if g.GROUP_NEEDED and g.MACRO_EXPAN_LEVEL==0:
                    CHAR_NEEDED = g.TRUE;
                    goto_SET_SEARCH = True;
                    break;
                else:
                    STREAM();
            if goto_SET_SEARCH:
                continue;
            
            if (g.NEXT_CHAR != BYTE('/')) or g.GROUP_NEEDED:
                goto_TEST_SEARCH = True;
                continue
            if g.OVER_PUNCH != 0:
                ERROR(d.CLASS_MO, 1);
            STREAM();  # LOOK AT NEXT CHAR
            if g.NEXT_CHAR != BYTE('*'):  # NOT REALLY A COMMENT
                CHAR_ALREADY_SCANNED = g.NEXT_CHAR;
                g.NEXT_CHAR = BYTE('/');
                OVERPUNCH_ALREADY_SCANNED = g.OVER_PUNCH;
                goto_TEST_SEARCH = True;
                continue;
        
            # IF WE GET HERE, WE HAVE A GENUINE COMMENT
            if g.OVER_PUNCH != 0:
                ERROR(d.CLASS_MO, 1);
            goto_SEARCH_NEXT_CHAR = False;
            goto_STORE_NEXT_CHAR = True;
            while goto_STORE_NEXT_CHAR:
                while goto_STORE_NEXT_CHAR or goto_SEARCH_NEXT_CHAR \
                        or g.NEXT_CHAR != BYTE('/'):
                    goto_STORE_NEXT_CHAR = False;
                    if not goto_SEARCH_NEXT_CHAR:
                        BUILD_COMMENT();
                    else:
                        goto_SEARCH_NEXT_CHAR = False;
                    if g.GROUP_NEEDED:
                        CHAR_NEEDED = g.TRUE;
                        goto_SET_SEARCH = True;
                        break;
                    STREAM();
                    if g.OVER_PUNCH != 0:
                        ERROR(d.CLASS_MO, 1);
                if goto_SET_SEARCH:
                    continue
                
                if BYTE(SAVE_COMMENT, COMMENT_PTR) != BYTE('*'):
                    goto_STORE_NEXT_CHAR = True;
                    continue;
            g.COMMENT_COUNT = g.COMMENT_COUNT - 1;  # UNSAVE THE '*'
            COMMENT_PTR = COMMENT_PTR - 1;  # HERE TOO 
            CHAR_NEEDED = g.TRUE;
            goto_LOOK_FOR_COMMENT = True;
            continue;
