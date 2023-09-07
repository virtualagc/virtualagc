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

from g import *
from ERROR import ERROR
from STREAM import STREAM

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
    global BASE_PARM_LEVEL, BCD, BLANK_COUNT, C, COMMENT_COUNT, CONTEXT, \
            DONT_SET_WAIT, EQUATE_IMPLIED, EXP_OVERFLOW, EXP_TYPE, FIRST_TIME, \
            FIRST_TIME_PARM, FOUND_CENT, GRAMMAR_FLAGS, I, IMPLIED_TYPE, \
            INCL_SRN, LABEL_IMPLIED, LOOKUP_ONLY, M_BLANK_COUNT, M_CENT, \
            M_P, M_PRINT, M_TOKENS, MACRO_EXPAN_LEVEL, MACRO_FOUND, \
            MACRO_POINT, MACRO_TEXT, NEW_MEL, NEXT_CHAR, NUM_OF_PARM, \
            OLD_MEL, OLD_MP, OLD_PEL, OLD_PR_PTR, OLD_TOPS, OVER_PUNCH, \
            PARM_COUNT, PARM_EXPAN_LEVEL, PARM_REPLACE_PTR, PARM_STACK_PTR, \
            PASS, P_CENT, PRINTING_ENABLED, RESERVED_WORD, RESTORE, S, \
            SAVE_BLANK_COUNT, \
            SAVE_NEXT_CHAR, SAVE_OVER_PUNCH, SAVE_PE, SCAN_COUNT, SOME_BCD, \
            SRN, SRN_COUNT, STRING_OVERFLOW, SUPPRESS_THIS_TOKEN_ONLY, \
            TEMP_INDEX, TEMPLATE_IMPLIED, TEMPORARY_IMPLIED, TEMP_STRING, \
            T_INDEX, TOKEN, TOKEN_FLAGS, TOP_OF_PARM_STACK, VALUE, WAIT 
    # Locals:
    SIG_DIGITS = 0
    SIGN = 0
    EXP_SIGN = 0
    EXP_BEGIN = 0
    S1 = 0
    EXP_DIGITS = 0
    DEC_POINT = 0
    CHAR_NEEDED = 0
    SEARCH_NEEDED = TRUE
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
        
        if OVER_PUNCH == 0:
            return CHAR;
        if OVER_PUNCH in CHAR_OP:
            if OVER_PUNCH == CHAR_OP[0]:  # LEVEL 1 ESCAPE 
                HOLD_CHAR = TRANS_IN(CHAR) & 0xFF;
            else: # OVER_PUNCH == CHAR_OP[1]
                HOLD_CHAR = SHR(TRANS_IN(CHAR), 8) & 0xFF;  # LEVEL 2 ESCAPE
            if HOLD_CHAR == 0x00:
                if OVER_PUNCH != VALID_00_OP or CHAR != VALID_00_CHAR:
                    ERROR(CLASS_MO, 6, HEX(CHAR, 2));
                    return CHAR;
            return HOLD_CHAR;
        else: # ILLEGAL OVER PUNCH */
            ERROR(CLASS_MO, 1, HEX(CHAR, 2));
            return CHAR;  # NO TRANSLATION 

    def BUILD_BCD():
        global BCD
        # No locals.
        BCD = BCD + NEXT_CHAR

    def BUILD_INTERNAL_BCD():
        nonlocal INTERNAL_BCD
        # No locals.
        INTERNAL_BCD = INTERNAL_BCD + NEXT_CHAR
      
    def PARAMETER_PROCESSING():
        global RESERVED_WORD, TOKEN_FLAGS, GRAMMAR_FLAGS, TEMP_STRING, \
                ONE_BYTE, MACRO_CALL_PARM_TABLE, SAVE_TOKEN, MACRO_POINT, M_P, \
                M_BLANK_COUNT, MACRO_EXPAN_LEVEL, FIRST_TIME, \
                TOP_OF_PARM_STACK
        # Locals
        I = 0
        ARG_COUNT = 0;
        NUM_OF_PAREN = 0 ;
        LAST_ARG = FALSE;
        QUOTE_FLAG = FALSE;
        D_QUOTE_FLAG = FALSE;
        CENT_FLAG= FALSE;
        
        if VAR_LENGTH[SYT_INDEX]==0:
           LAST_ARG = TRUE;
        else:
            if NEXT_CHAR == BYTE('('):
                TOKEN_FLAGS(STMT_PTR, TOKEN_FLAGS(STMT_PTR)|0x20);
                RESERVED_WORD=TRUE;
                SAVE_TOKEN(LEFT_PAREN,0,0x20,1);
                GRAMMAR_FLAGS[STMT_PTR] = GRAMMAR_FLAGS[STMT_PTR] or MACRO_ARG_FLAG;
                for I in range(1, NUM_OF_PARM[MACRO_EXPAN_LEVEL+1]+1):
                    TEMP_STRING=X1;
                    while True:
                        STREAM();
                        if NEXT_CHAR == BYTE(SQUOTE):
                            QUOTE_FLAG = not QUOTE_FLAG;
                        elif QUOTE_FLAG == FALSE:
                            if NEXT_CHAR == BYTE('('):
                                NUM_OF_PAREN=NUM_OF_PAREN+1;
                            elif NEXT_CHAR == BYTE(')'):
                                NUM_OF_PAREN=NUM_OF_PAREN-1;
                                if NUM_OF_PAREN < 0:
                                    LAST_ARG=TRUE;
                                    STREAM();
                                    break;
                            elif NEXT_CHAR==BYTE('"'):
                                D_QUOTE_FLAG=not D_QUOTE_FLAG;
                            elif NEXT_CHAR==BYTE('`'):
                                CENT_FLAG=not CENT_FLAG;
                            elif NEXT_CHAR == BYTE(','):
                                if NUM_OF_PAREN==0 and D_QUOTE_FLAG == FALSE:
                                    if CENT_FLAG==FALSE:
                                        if QUOTE_FLAG==FALSE:
                                            break;
                        if LENGTH(TEMP_STRING) == 250:
                           ERROR(CLASS_IR,7);
                           return;
                        ONE_BYTE = chr(NEXT_CHAR);
                        TEMP_STRING = TEMP_STRING + ONE_BYTE;
                        if NEXT_CHAR == BYTE(X1):
                            if BLANK_COUNT > 0:
                                if (LENGTH(TEMP_STRING)+BLANK_COUNT) > 250:
                                    ERROR(CLASS_IR,7);
                                    return;
                                else:
                                    for K in range(1, BLANK_COUNT+1):
                                        TEMP_STRING=TEMP_STRING+X1;
                    ARG_COUNT= ARG_COUNT + 1;
                    TEMP_STRING=SUBSTR(TEMP_STRING,1);
                    MACRO_CALL_PARM_TABLE[I+TOP_OF_PARM_STACK]=SUBSTR(TEMP_STRING,1);
                    if LENGTH(TEMP_STRING)>0:
                        RESERVED_WORD=FALSE;
                        SAVE_TOKEN(CHARACTER_STRING,TEMP_STRING,0,1); 
                        GRAMMAR_FLAGS[STMT_PTR]=GRAMMAR_FLAGS[STMT_PTR]|MACRO_ARG_FLAG;
                    if LAST_ARG == TRUE:
                        break;
                    RESERVED_WORD=TRUE;
                    SAVE_TOKEN(COMMA,0,0x20,1);
                    GRAMMAR_FLAGS[STMT_PTR]=GRAMMAR_FLAGS[STMT_PTR]|MACRO_ARG_FLAG;
            else:
                LAST_ARG = TRUE;
        if ARG_COUNT != NUM_OF_PARM[MACRO_EXPAN_LEVEL+1] or LAST_ARG == FALSE:
            ERROR(CLASS_IR,8);
            return;
        noBackup = False
        if NEXT_CHAR==BYTE('`'):
            if FOUND_CENT:
                if MACRO_EXPAN_LEVEL>0:
                    noBackup = True
                else:
                    STREAM();
        if not noBackup:
            if PARM_EXPAN_LEVEL>BASE_PARM_LEVEL(MACRO_EXPAN_LEVEL):
                if FIRST_TIME_PARM(PARM_EXPAN_LEVEL):
                    PARM_REPLACE_PTR(PARM_EXPAN_LEVEL, PARM_REPLACE_PTR(PARM_EXPAN_LEVEL)-1);
                else:
                    FIRST_TIME_PARM(PARM_EXPAN_LEVEL, TRUE);
            else:
                if FIRST_TIME(MACRO_EXPAN_LEVEL):
                    if MACRO_TEXT(MACRO_POINT-2)==0xEE:
                        MACRO_POINT=MACRO_POINT-2;
                    elif MACRO_TEXT(MACRO_POINT)!=0xEF:
                        MACRO_POINT=MACRO_POINT-1;
                    elif MACRO_TEXT(MACRO_POINT) ==0xEF and \
                            MACRO_TEXT(MACRO_POINT-1) == NEXT_CHAR:
                        MACRO_POINT=MACRO_POINT-1;
                else:
                    FIRST_TIME(MACRO_EXPAN_LEVEL, TRUE);
        if ARG_COUNT>0:
            RESERVED_WORD=TRUE;
            SAVE_TOKEN(RT_PAREN,0,0,1);
            GRAMMAR_FLAGS[STMT_PTR]=GRAMMAR_FLAGS[STMT_PTR]|MACRO_ARG_FLAG;
        M_P(MACRO_EXPAN_LEVEL, MACRO_POINT);
        M_BLANK_COUNT(MACRO_EXPAN_LEVEL, BLANK_COUNT);
        MACRO_EXPAN_LEVEL=MACRO_EXPAN_LEVEL+1;
        FIRST_TIME(MACRO_EXPAN_LEVEL, TRUE);
        TOP_OF_PARM_STACK = TOP_OF_PARM_STACK + ARG_COUNT;
        TEMP_STRING = '';
        RESERVED_WORD=FALSE;
    
    #--------------------------------------------------------------------
    # ROUTINE TO DETERMINE IF END OF MACRO HAS BEEN REACHED BY
    # MACRO_POINT
    #--------------------------------------------------------------------
    def END_OF_MACRO():
        # MP is local.
        MP=MACRO_POINT;
        # FIRST SKIP BLANKS
        while MACRO_TEXT(MP)==0xEE or MACRO_TEXT(MP)==BYTE(X1):
            if MACRO_TEXT(MP)==0xEE:
                MP=MP+1;
            MP=MP+1;
        # THEN CHECK FOR END OF MACRO CHARACTER
        if MACRO_TEXT(MP)==0xEF:
            if NEXT_CHAR==BYTE(X1):
                return TRUE;
        return FALSE;
    
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
        described above. 
        '''
        
        if not (goto_SCAN_END or goto_DEC_POINT_ENTRY) \
                or goto_SCAN_TOP or goto_SCAN_START:
            if goto_SCAN_TOP: # CONTROL RETURNED HERE FROM COMMENT SEARCH
                goto_SCAN_TOP = False
            
            if not goto_SCAN_START:
                SCAN_COUNT = SCAN_COUNT + 1;
                if CHAR_NEEDED:
                    STREAM();
                    CHAR_NEEDED = FALSE;
            else:
                goto_SCAN_START = False
                
            M_TOKENS[MACRO_EXPAN_LEVEL]=M_TOKENS[MACRO_EXPAN_LEVEL]+1;
            BCD = '';
            FIXING=0;
            VALUE = 0;
            SYT_INDEX = 0;
            RESERVED_WORD = TRUE;
            IMPLIED_TYPE = 0;
        
        while not goto_SCAN_END:    # START OF SCAN
            if goto_DEC_POINT_ENTRY:
                ct = 1
            elif goto_CENT_START:
                ct = 2
            elif goto_CASE13:
                ct = 13
            else:
                if not MACRO_FOUND:
                    if SRN_PRESENT:
                        SRN[1]=SRN[0];
                        INCL_SRN[1] = INCL_SRN[0];
                        SRN_COUNT[1]=SRN_COUNT[0];
                ct = CHARTYPE[NEXT_CHAR]
                
            # DO CASE CHARTYPE(NEXT_CHAR);
            if ct == 0:
                # CASE 0--ILLEGAL CHARACTERS
                C = HEX(NEXT_CHAR, 2);
                ERROR(CLASS_DT,4,C);
                if OVER_PUNCH != 0:
                   ERROR(CLASS_MO,1);
                STREAM()();
            elif ct == 1:
                # CASE 1--DIGITS
                if not goto_DEC_POINT_ENTRY:
                    RESERVED_WORD = FALSE
                    DEC_POINT = FALSE;
                    BUILD_BCD();
                    if OVER_PUNCH != 0:
                        ERROR(CLASS_MO,1);
                    STREAM();
                    TOKEN = NUMBER;
                    if NEXT_CHAR==BYTE(X1) or NEXT_CHAR==BYTE(')'):
                        VALUE = BYTE(BCD) - BYTE('0');
                        if VALUE >= 1 and VALUE <= MAX_STRUC_LEVEL:
                            TOKEN = LEVEL;
                    DIGIT = BYTE(BCD);
                else:
                    goto_DEC_POINT_ENTRY = False
                SIG_DIGITS=0;
                INTERNAL_BCD = BCD;  # START THE SAME
                
                goto_SIG_CHECK = True
                goto_LOOP_END = False
                goto_GET_NEW_CHAR = False
                while not goto_GET_NEW_CHAR:
                    while CHARTYPE[DIGIT] == 1:
                        if not goto_SIG_CHECK:
                            if OVER_PUNCH != 0:
                               ERROR(CLASS_MO,1);
                            BUILD_BCD();
                            BUILD_INTERNAL_BCD();
                        else:
                            goto_SIG_CHECK = False
                        if SIG_DIGITS == 0:
                            if DIGIT == BYTE('0'):
                                if LENGTH(BCD) == 1:
                                    goto_LOOP_END = True;
                                else:
                                    goto_GET_NEW_CHAR = False;
                        if not goto_LOOP_END and not goto_GET_NEW_CHAR:
                            SIG_DIGITS = SIG_DIGITS + 1;
                            if SIG_DIGITS > 74:
                                goto_GET_NEW_CHAR = True;   # TOO MANY SIG DIGITS
                            elif LENGTH(BCD) == 1:
                                goto_LOOP_END = True;
                        if not goto_LOOP_END:
                            goto_GET_NEW_CHAR = False
                            STREAM();
                        goto_LOOP_END = False
                        DIGIT = NEXT_CHAR;
                    # OF DO WHILE...
                    
                    if DIGIT == BYTE(PERIOD):
                        if DEC_POINT:
                            BUILD_BCD();
                            ERROR(CLASS_LF,2);
                            if OVER_PUNCH != 0:
                                ERROR(CLASS_MO,1);
                            goto_GET_NEW_CHAR = True;
                            continue
                        DEC_POINT = TRUE;
                        BUILD_BCD();
                        BUILD_INTERNAL_BCD();
                        if OVER_PUNCH != 0:
                            ERROR(CLASS_MO,1);
                        goto_GET_NEW_CHAR = True;
                        continue;
        
                goto_START_EXPONENT = True
                goto_POWER_INDICATOR = False
                while goto_START_EXPONENT or goto_POWER_INDICATOR:
                    goto_START_EXPONENT = False
                    goto_EXP_DONE = False
                    goto_RESET_LITERAL = False
                    if not goto_POWER_INDICATOR:
                        EXP_TYPE = DIGIT;
                    if goto_POWER_INDICATOR or EXP_TYPE == BYTE('E'):
                        goto_POWER_INDICATOR = False
                        EXP_SIGN = 0;
                        EXP_BEGIN = 0;
                        EXP_DIGITS = 0;
                        EXP_BEGIN = LENGTH(INTERNAL_BCD) + 1;
                        goto_EXP_CHECK = True
                        while goto_EXP_CHECK:
                            while goto_EXP_CHECK or CHARTYPE(DIGIT) == 1:
                                if not goto_EXP_CHECK:
                                    EXP_DIGITS = EXP_DIGITS + 1;
                                else:
                                    goto_EXP_CHECK = False
                                if OVER_PUNCH != 0:
                                    ERROR(CLASS_MO,1);
                                BUILD_BCD();
                                BUILD_INTERNAL_BCD();
                                STREAM();
                                DIGIT = NEXT_CHAR;
                            if LENGTH(INTERNAL_BCD) == EXP_BEGIN:
                                if DIGIT == BYTE('+') or DIGIT == BYTE('-'):
                                    EXP_SIGN = DIGIT;
                                    goto_EXP_CHECK = True;
                                    continue;
                                ERROR(CLASS_LF, 1);
                                goto_RESET_LITERAL = True
                                break
                            else:
                                goto_EXP_DONE = True
                                break
                    
                    goto_NUMBER_DONE = False
                    if not goto_RESET_LITERAL:
                        if not goto_EXP_DONE:
                            if EXP_TYPE == BYTE('H') or EXP_TYPE == BYTE('B'):
                                goto_POWER_INDICATOR = True;
                                continue
                            goto_NUMBER_DONE = True
                        else:
                            goto_EXP_DONE = False
                        
                    if not goto_NUMBER_DONE:
                        if goto_RESET_LITERAL or EXP_DIGITS <= 0:
                            if not goto_RESET_LITERAL:
                                ERROR(CLASS_LF,5);
                            else:
                                goto_RESET_LITERAL = False;
                            INTERNAL_BCD = SUBSTR(INTERNAL_BCD, 0, EXP_BEGIN - 1);
                        goto_START_EXPONENT = True
                    else:
                        goto_NUMBER_DONE = False
                
                if SIG_DIGITS > 74:
                    ERROR(CLASS_LF,3);
                EXP_OVERFLOW = MONITOR(10, INTERNAL_BCD);  # CONVERT THE NUMBER
                if EXP_OVERFLOW:
                    ERROR(CLASS_LC, 2, BCD);
                PREP_LITERAL();
                goto_SCAN_END = True;
                # END OF CASE 1
                
            elif ct == 2:
                # CASE 2--LETTERS=IDENTS & RESERVED WORDS
                if not goto_CENT_START:
                    STRING_OVERFLOW = FALSE;
                    LABEL_IMPLIED = FALSE;
                    IMPLIED_TYPE = 0;
                goto_FOUND_TOKEN = False;
                while True:
                    goto_CENT_START = False;
                    if LETTER_OR_DIGIT(NEXT_CHAR):
                        # VALID CHARACTER 
                        
                        def ID_LOOP():
                            global IMPLIED_TYPE, STRING_OVERFLOW, \
                                    OVER_PUNCH, I
                            nonlocal S1
                            # No locals
                            goto_NEW_CHAR = False;
                            S1=NEXT_CHAR=BYTE('_');
                            if LENGTH(BCD) < ID_LIMIT:
                                BUILD_BCD();
                                if OVER_PUNCH != 0:
                                    if IMPLIED_TYPE > 0:
                                        ERROR(CLASS_MO,3);
                                    else:
                                        for I in range(1, OVER_PUNCH_SIZE+1):
                                            if OVER_PUNCH == OVER_PUNCH_TYPE(I):
                                                IMPLIED_TYPE = I;
                                                goto_NEW_CHAR = True;
                                                break;
                                        if not goto_NEW_CHAR:
                                            ERROR(CLASS_MO,4);
                                            OVER_PUNCH = 0;
                            else:
                                # TOO MANY CHARACTERS IN IDENT
                                if not STRING_OVERFLOW:
                                    ERROR(CLASS_IL,2);
                                    STRING_OVERFLOW = TRUE;
                            goto_NEW_CHAR = False;
                            STREAM();
                        
                        ID_LOOP();
                        # END OF DO...VALID CHARACTER
                    else:
                        if S1:
                            if NEXT_CHAR != BYTE('¢'):
                                ERROR(CLASS_IL, 1);
                        goto_FOUND_TOKEN = True;
                        break;
                # OF DO FOREVER
                
                goto_FOUND_TOKEN = False;
                goto_END_CHECK_RESERVED_WORD = False;
                if NEXT_CHAR==BYTE('¢'):
                    goto_CASE13 = True
                    continue
                else:
                    S1 = LENGTH(BCD);
                    if S1 > 1:
                        if S1 <= RESERVED_LIMIT:
                            # CHECK FOR RESERVED WORDS
                            for I in range(V_INDEX(S1 - 1), V_INDEX(S1)):
                                S = STRING(VOCAB_INDEX(I));
                                if BYTE(S) > BYTE(BCD):
                                    goto_END_CHECK_RESERVED_WORD = True;
                                    break;
                                if S == BCD:
                                    TOKEN = I;
                                    if IMPLIED_TYPE > 0:
                                        ERROR(CLASS_MC,4,BCD);
                                    I = SET_CONTEXT(I);
                                    if I > 0:
                                        if TOKEN==TEMPORARY:
                                            TEMPORARY_IMPLIED=TRUE;
                                        if TOKEN == EQUATE_TOKEN:
                                           EQUATE_IMPLIED = TRUE;
                                        if I == EXPRESSION_CONTEXT:
                                           if CONTEXT == DECLARE_CONTEXT or \
                                                  CONTEXT == PARM_CONTEXT:
                                              OLD_MEL=MACRO_EXPAN_LEVEL;
                                              SAVE_PE=PRINTING_ENABLED;
                                              while NEXT_CHAR == BYTE(X1):
                                                  if not MACRO_FOUND:
                                                      SAVE_BLANK_COUNT = BLANK_COUNT;
                                                  STREAM();
                                              if OLD_MEL>MACRO_EXPAN_LEVEL:
                                                  if M_TOKENS(OLD_MEL)<=1:
                                                      if SAVE_PE!=PRINTING_ENABLED:
                                                          SUPPRESS_THIS_TOKEN_ONLY=TRUE;
                                              if NEXT_CHAR == BYTE('('):
                                                  CONTEXT = I;
                                           else:
                                               if TOKEN == STRUCTURE_WORD:
                                                   CONTEXT = DECLARE_CONTEXT;
                                                   TEMPLATE_IMPLIED = TRUE;
                                        else:
                                           if CONTEXT != DECLARE_CONTEXT:
                                               if CONTEXT != EXPRESSION_CONTEXT:
                                                   CONTEXT = I;
                                    goto_SCAN_END = True
                                    break
                    
                goto_END_CHECK_RESERVED_WORD = False;
                RESERVED_WORD = FALSE;
                if MACRO_EXPAN_LEVEL > 0:
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
                        global TEMP_INDEX, PARM_COUNT, PARM_EXPAN_LEVEL, \
                                FIRST_TIME_PARM, PARM_REPLACE_PTR, \
                                PARM_STACK_PTR, MACRO_POINT, BLANK_COUNT, \
                                OVER_PUNCH, P_CENT
                        # No locals
                        TEMP_INDEX=MACRO_EXPAN_LEVEL;
                        PARM_COUNT=NUM_OF_PARM[TEMP_INDEX];
                        while TEMP_INDEX>0:
                            for I in range(1, NUM_OF_PARM[TEMP_INDEX]+1):
                                if BCD==SYT_NAME[MACRO_EXPAN_STACK[TEMP_INDEX]+I]:
                                    PARM_EXPAN_LEVEL = PARM_EXPAN_LEVEL + 1;
                                    FIRST_TIME_PARM[PARM_EXPAN_LEVEL]=TRUE;
                                    PARM_REPLACE_PTR[PARM_EXPAN_LEVEL] = 0;
                                    PARM_STACK_PTR[PARM_EXPAN_LEVEL] = \
                                        I + TOP_OF_PARM_STACK-PARM_COUNT;
                                    if BASE_PARM_LEVEL[MACRO_EXPAN_LEVEL]+1 == \
                                            PARM_EXPAN_LEVEL:
                                        if not FOUND_CENT:
                                            if not END_OF_MACRO:
                                                if MACRO_TEXT[MACRO_POINT-2]==0xEE:
                                                    MACRO_POINT=MACRO_POINT-1;
                                                MACRO_POINT=MACRO_POINT-1;
                                    else:
                                        if FIRST_TIME_PARM[PARM_EXPAN_LEVEL-1]:
                                            #  CHECK FOR CENT SIGN
                                            if NEXT_CHAR!=BYTE('¢'):
                                                PARM_REPLACE_PTR[PARM_EXPAN_LEVEL-1]= \
                                                    PARM_REPLACE_PTR[PARM_EXPAN_LEVEL-1]-1;
                                        else:
                                            FIRST_TIME_PARM[PARM_EXPAN_LEVEL-1]=TRUE;
                                    BLANK_COUNT = 0
                                    OVER_PUNCH = 0;
                                    P_CENT[PARM_EXPAN_LEVEL]=FOUND_CENT;
                                    STREAM();
                                    return 1;
                            TEMP_INDEX=TEMP_INDEX-1;
                            PARM_COUNT=PARM_COUNT + NUM_OF_PARM[TEMP_INDEX];
                        return 0;
                    
                    FOUND_CENT=FALSE;
                    if PARM_FOUND:
                        goto_SCAN_START = True;
                        break;
                
                OLD_MEL = MACRO_EXPAN_LEVEL;
                OLD_PEL = PARM_EXPAN_LEVEL;
                OLD_PR_PTR = PARM_REPLACE_PTR(PARM_EXPAN_LEVEL);
                OLD_TOPS=TOP_OF_PARM_STACK;
                SAVE_PE = PRINTING_ENABLED;
                OLD_MP=MACRO_POINT;
                while NEXT_CHAR==BYTE(X1):
                    if not MACRO_FOUND:
                        SAVE_BLANK_COUNT=BLANK_COUNT;
                    STREAM();
                NEW_MEL = MACRO_EXPAN_LEVEL;
                if OLD_MEL > NEW_MEL:
                    if M_TOKENS(OLD_MEL) <= 1:
                        if SAVE_PE != PRINTING_ENABLED:
                            SUPPRESS_THIS_TOKEN_ONLY = TRUE;
                if SUBSCRIPT_LEVEL == 0:
                    if NEXT_CHAR == BYTE(':'):
                        if CONTEXT != DECLARE_CONTEXT:
                            LABEL_IMPLIED = TRUE;
                    else:
                        if NEXT_CHAR == BYTE('-'):
                            if CONTEXT == DECLARE_CONTEXT or CONTEXT == PARM_CONTEXT:
                                TEMPLATE_IMPLIED = TRUE;
                                LOOKUP_ONLY = TRUE;
                if RECOVERING:
                    LOOKUP_ONLY = FALSE;
                    TEMPLATE_IMPLIED = FALSE;
                    goto_SCAN_END = True;  # WITHOUT CALLING IDENTIFY
                    break;
                IDENTIFY(BCD,0);
                LOOKUP_ONLY = FALSE;
                TEMPLATE_IMPLIED = FALSE;
                if CONTROL(3):
                    if TOKEN > 0:
                        S = STRING(VOCAB_INDEX(TOKEN));
                    else:
                        S = TOKEN;
                    OUTPUT(0, BCD + ' :  TOKEN = ' + S + ', IMPLIED_TYPE = ' \
                                + IMPLIED_TYPE + ', SYT_INDEX = ' + SYT_INDEX \
                                + ', CONTEXT = ' + CONTEXT);
                if MACRO_FOUND:
                    if OLD_PEL!=PARM_EXPAN_LEVEL:
                        if BASE_PARM_LEVEL(MACRO_EXPAN_LEVEL)>=PARM_EXPAN_LEVEL:
                            NEXT_CHAR=BYTE(X1);
                            MACRO_POINT=MACRO_POINT-1;
                            
                if TOKEN < 0: # MACRO NAME FOUND
                    if MACRO_EXPAN_LEVEL==0 and SAVE_NEXT_CHAR==BYTE(X1):
                        SAVE_NEXT_CHAR = NEXT_CHAR;
                    if OLD_MEL > NEW_MEL:
                        if PARM_EXPAN_LEVEL>BASE_PARM_LEVEL(MACRO_EXPAN_LEVEL):
                            if OLD_PR_PTR<PARM_REPLACE_PTR(PARM_EXPAN_LEVEL):
                                PARM_REPLACE_PTR(PARM_EXPAN_LEVEL, OLD_PR_PTR);
                        NEW_MEL, MACRO_EXPAN_LEVEL = OLD_MEL;
                        MACRO_FOUND = TRUE;
                        WAIT=FALSE;
                        MACRO_POINT = OLD_MP;
                        PRINTING_ENABLED=SAVE_PE;
                        TOP_OF_PARM_STACK=OLD_TOPS;
                    if STMT_STACK(STMT_PTR)==SEMI_COLON and STMT_END_PTR==STMT_PTR:
                        OUTPUT_WRITER(LAST_WRITE,STMT_PTR);
                       
                    def PUSH_MACRO():
                        global SUPPRESS_THIS_TOKEN_ONLY, MACRO_EXPAN_LEVEL, \
                                PARM_EXPAN_LEVEL, MACRO_FOUND, NEXT_CHAR, \
                                OVER_PUNCH, PRINTING_ENABLED, RESTORE, \
                                PASS, GRAMMAR_FLAGS, NUM_OF_PARM, \
                                BASE_PARM_LEVEL, M_TOKENS, M_CENT, M_PRINT, \
                                FOUND_CENT, MACRO_POINT, SAVE_NEXT_CHAR, \
                                SAVE_OVER_PUNCH, BLANK_COUNT, OVER_PUNCH
                        # No locals
                        SUPPRESS_THIS_TOKEN_ONLY = FALSE;
                        #           GET NEXT NON-BLANK BEFORE
                        #           PARAMETER_PROCESSING     
                        while NEXT_CHAR==BYTE(X1):
                           STREAM();
                        if MACRO_EXPAN_LEVEL+1 > MACRO_EXPAN_LIMIT:
                            ERROR(CLASS_IR,9,BCD);
                            MACRO_EXPAN_LEVEL = 0
                            PARM_EXPAN_LEVEL = 0
                            MACRO_FOUND=0;
                            NEXT_CHAR=SAVE_NEXT_CHAR;
                            OVER_PUNCH=SAVE_OVER_PUNCH;
                            PRINTING_ENABLED=PRINT_FLAG;
                            return;
                        MACRO_EXPAN_STACK(MACRO_EXPAN_LEVEL+1, SYT_INDEX);
                        if PRINTING_ENABLED==PRINT_FLAG:
                            RESTORE=PRINT_FLAG;
                            if FOUND_CENT:
                                PASS=PRINT_FLAG;
                                PRINTING_ENABLED=0;
                            else:
                                PASS=0;
                        else:
                            RESTORE = 0;
                            PASS=0;
                        SAVE_TOKEN(ID_TOKEN,BCD,7);
                        GRAMMAR_FLAGS[STMT_PTR] = GRAMMAR_FLAGS[STMT_PTR] \
                                                    or MACRO_ARG_FLAG;
                        NUM_OF_PARM[MACRO_EXPAN_LEVEL+1]= \
                            VAR_LENGTH(SYT_INDEX);
                        PARAMETER_PROCESSING();
                        PRINTING_ENABLED=PASS;
                        if TEMP_STRING == '':
                           BASE_PARM_LEVEL[MACRO_EXPAN_LEVEL]=PARM_EXPAN_LEVEL;
                           M_TOKENS(MACRO_EXPAN_LEVEL, 0);
                           M_CENT(MACRO_EXPAN_LEVEL, FOUND_CENT);
                           M_PRINT(MACRO_EXPAN_LEVEL, RESTORE);
                           FOUND_CENT=FALSE;
                           MACRO_POINT = SYT_ADDR(SYT_INDEX);
                           if MACRO_EXPAN_LEVEL == 1:
                              MACRO_FOUND = TRUE ;
                              SAVE_NEXT_CHAR=NEXT_CHAR;
                              SAVE_OVER_PUNCH = OVER_PUNCH;
                              BLANK_COUNT = 0
                              OVER_PUNCH=0;
                        else:
                            FOUND_CENT=FALSE;
                        STREAM();
                        return;
                    
                    PUSH_MACRO();
                    goto_SCAN_START = True;
                elif not MACRO_FOUND:
                    SAVE_BLANK_COUNT = -1;
                if not goto_SCAN_START:
                    goto_SCAN_END = True;
                break;
                # END OF CASE 2 
                
            elif ct == 3:
                # CASE 3--SPECIAL SINGLE CHARACTERS 
                if OVER_PUNCH != 0:
                    ERROR(CLASS_MO,1);
                TOKEN = TX(NEXT_CHAR);
                CHAR_NEEDED = TRUE;
                goto_SCAN_END = True
                break
                # END OF CASE 3 
               
            elif ct == 4:
                # CASE 4--PERIOD
                # COULD BE DOT PRODUCT OR DECIMAL POINT
                if OVER_PUNCH != 0:
                    ERROR(CLASS_MO,1);
                BUILD_BCD();
                STREAM();
                if CHARTYPE(NEXT_CHAR) == 1:
                    DEC_POINT = TRUE;
                    BUILD_BCD();
                    TOKEN = NUMBER;
                    DIGIT = NEXT_CHAR;
                    if OVER_PUNCH != 0:
                        ERROR(CLASS_MO,1);
                    RESERVED_WORD = FALSE;
                    goto_DEC_POINT_ENTRY = True;
                    break;
                TOKEN = TX(BYTE(PERIOD));
                goto_SCAN_END = True
                break
                # END OF CASE 4
                
            elif ct == 5:
                # CASE 5--SINGLE QUOTE = CHARACTER LITERAL
                I = 0;
                STRING_OVERFLOW, RESERVED_WORD = FALSE;
                if OVER_PUNCH != 0:
                    ERROR(CLASS_MO, 5);
                TOKEN = CHARACTER_STRING;
                goto_CHECK = True;
                goto_BUILD = False;
                firstTry = True
                while firstTry or goto_BUILD:
                    firstTry = False;
                    while goto_BUILD or goto_CHECK or NEXT_CHAR != BYTE(SQUOTE):
                        goto_BUILD = False;
                        if not goto_CHECK:
                            if NEXT_CHAR != BYTE(X1):
                                BLANK_COUNT = 0;
                            for I in range(0, BLANK_COUNT+1):
                                if LENGTH(BCD) < CHAR_LENGTH_LIM:
                                    BUILD_BCD();
                                else:
                                    ERROR(CLASS_LS,1);
                                    # Originally the label STR_TOO_LONG
                                    # preceded the following code.
                                    STRING_OVERFLOW = TRUE;
                                    goto_SCAN_END = True;
                                    break;
                        if goto_SCAN_END:
                            break;
                        goto_CHECK = False;
                        STREAM();
                        ESCAPE_LEVEL = -1;
                        while NEXT_CHAR == ESCP:
                            ESCAPE_LEVEL = ESCAPE_LEVEL + 1;
                            if OVER_PUNCH != 0:
                                ERROR(CLASS_MO, 8);
                            STREAM();
                        TEMP_CHAR = CHAR_OP_CHECK(NEXT_CHAR);
                        if ESCAPE_LEVEL >= 0:
                            if ESCAPE_LEVEL > 1:
                                ERROR(CLASS_MO, 7, HEX(NEXT_CHAR, 2));
                                ESCAPE_LEVEL = 1;
                            OVER_PUNCH = CHAR_OP(ESCAPE_LEVEL);
                            if NEXT_CHAR == BYTE(X1):   # HANDLE MULT BLANKS CAREFULLY
                                NEXT_CHAR = CHAR_OP_CHECK(TEMP_CHAR);
                                if BLANK_COUNT > 0:
                                    if LENGTH(BCD) < MAX_STRING_SIZE:
                                        BUILD_BCD();
                                    else:
                                        '''
                                        Originally GO TO STR_TOO_LONG.  However,
                                        it was just simpler the code that is
                                        actually at STR_TOO_LONG than to try
                                        and duplicate the jump.
                                        '''
                                        STRING_OVERFLOW = TRUE;
                                        goto_SCAN_END = True;
                                        break;
                                    BLANK_COUNT = BLANK_COUNT - 1;
                                    NEXT_CHAR = BYTE(X1);
                            else:
                                NEXT_CHAR = CHAR_OP_CHECK(TEMP_CHAR);
                        # END OF ESCAPE LEVEL >= 0 
                        else:
                            NEXT_CHAR = TEMP_CHAR;
                    # END OF DO WHILE...
                    STREAM();
                    if NEXT_CHAR != BYTE(SQUOTE):
                        VALUE = LENGTH(BCD);
                        goto_SCAN_END = True;
                        break;
                    if OVER_PUNCH != 0:
                        ERROR(CLASS_MO,1);
                    goto_BUILD = True;
                if goto_SCAN_END:
                    break;
                # END OF CASE 5
                
            elif ct == 6:
                # CASE 6--BLANK
                while NEXT_CHAR == BYTE(X1):  
                    DONT_SET_WAIT = TRUE;
                    STREAM();
                    DONT_SET_WAIT = FALSE;
                # OF CASE 6
               
            elif ct == 7:
                # CASE 7--'|' OR'||' 
                TOKEN = TX(NEXT_CHAR);
                if OVER_PUNCH != 0:
                    ERROR(CLASS_MO,1);
                STREAM();
                if NEXT_CHAR != BYTE('|'):
                    goto_SCAN_END = True;
                    break;
                if OVER_PUNCH != 0:
                    ERROR(CLASS_MO,1);
                TOKEN = CONCATENATE;
                STREAM();
                goto_SCAN_END = True;
                break;
                # END OF CASE 7
               
            elif ct == 8:
                # CASE 8--'*' OR '**'
                TOKEN = TX(NEXT_CHAR);
                if OVER_PUNCH != 0:
                    ERROR(CLASS_MO,1);
                STREAM();
                if NEXT_CHAR != BYTE('*'):
                    goto_SCAN_END = True;
                    break;
                if OVER_PUNCH != 0:
                    ERROR(CLASS_MO,1);
                TOKEN = EXPONENTIATE;
                STREAM();
                goto_SCAN_END = True;
                break;
                # END OF CASE 8
               
            elif ct == 9:
                # CASE 9--HEX'FE' = EOF
                TOKEN = EOFILE;
                STREAM();
                goto_SCAN_END = True;
                break;
                # END OF CASE 9
               
            elif ct == 10:
                # CASE 10--SPECIAL CHARACTERS TREATED AS BLANKS */
                NEXT_CHAR = BYTE(X1);
                BLANK_COUNT = 0;
                # END OF CASE 10 
               
            elif ct == 11:
                # CASE 11--DOUBLE QUOTES FOR REPLACE DEFINITION
                TOKEN = REPLACE_TEXT;
                TEMP_STRING=X1;
                BLANK_BYTES = 0;
                T_INDEX,START_POINT = FIRST_FREE;
                while True:
                    STREAM();
                    if NEXT_CHAR == BYTE('"'):
                        STREAM();
                        if NEXT_CHAR != BYTE('"'):
                            FIRST_FREE = T_INDEX;
                            FINISH_MACRO_TEXT();
                            goto_SCAN_END = True;
                            break;
                    goto_CONCAT = True
                    while goto_CONCAT:
                        goto_CONCAT = False;
                        NEXT_ELEMENT(MACRO_TEXTS);
                        MACRO_TEXT(T_INDEX, NEXT_CHAR);
                        T_INDEX = T_INDEX + 1;
                        if NEXT_CHAR == BYTE(X1):
                            if BLANK_COUNT > 0:
                                MACRO_TEXT(T_INDEX-1, 0xEE);
                                NEXT_ELEMENT(MACRO_TEXTS);
                                NEXT_ELEMENT(MACRO_TEXTS);
                                if BLANK_COUNT < 256:
                                   MACRO_TEXT(T_INDEX, BLANK_COUNT);
                                   BLANK_BYTES = BLANK_BYTES + BLANK_COUNT-1;
                                   T_INDEX = T_INDEX+1;
                                else:
                                   MACRO_TEXT(T_INDEX, 255);
                                   BLANK_BYTES = BLANK_BYTES + 254;
                                   BLANK_COUNT=BLANK_COUNT-255;
                                   T_INDEX=T_INDEX+1;
                                   goto_CONCAT = True
                    # END OF DO FOREVER
                # END OF CASE 11
                
            elif ct == 12:
                #  CASE 12 - % FOR %MACROS
                RESERVED_WORD = FALSE;
                STRING_OVERFLOW=FALSE;
                TOKEN=PERCENT_MACRO;
                while True:
                    if LENGTH(BCD)<PC_LIMIT:
                        BUILD_BCD();
                    else:
                        STRING_OVERFLOW=TRUE;
                    if OVER_PUNCH!=0:
                        ERROR(CLASS_MO,1);
                    STREAM();
                    if not LETTER_OR_DIGIT(NEXT_CHAR):
                        if STRING_OVERFLOW:
                            ERROR(CLASS_IL,2);
                        S1=LENGTH(BCD);
                        for SYT_INDEX in range(1, PC_INDEX+1):
                           if SUBSTR(PCNAME,SHL(SYT_INDEX,4),S1)==BCD:
                                goto_SCAN_END = True;
                                break;
                        ERROR(CLASS_XM,1,BCD);
                        SYT_INDEX=0;
                        goto_SCAN_END = True;
                        break;
                # END OF CASE 12
               
            elif ct == 13:
                #  CASE 13 - ¢ FOR ¢MACROS
                if goto_CASE13:
                    goto_CASE13 = False;
                SOME_BCD=BCD;
                BCD='';
                STREAM();
                while True:
                    if LETTER_OR_DIGIT(NEXT_CHAR):
                        ID_LOOP();
                    else:
                        break;
                        
                FOUND_CENT=TRUE;
                if NEXT_CHAR==BYTE('¢'):
                    if PARM_FOUND:
                        if SOME_BCD=='':
                            goto_SCAN_START = True;
                            break;
                        BCD=SOME_BCD;
                        goto_CENT_START = True;
                        break;
                    else:
                        IDENTIFY(BCD,1);
                        if TOKEN<0:
                            PUSH_MACRO();
                            if SOME_BCD=='':
                                goto_SCAN_START = True;
                                break;
                            SYT_INDEX=0;
                            BCD=SOME_BCD;
                            goto_CENT_START = True;
                            break;
                        else:
                            ERROR(CLASS_IR,4,BCD);
                            goto_SCAN_START = True;
                            break;
                else:
                    IDENTIFY(BCD,1);
                    if TOKEN<0:
                        PUSH_MACRO();
                        goto_SCAN_START = True;
                        break;
                    else:
                        ERROR(CLASS_IR,4,BCD);
                        goto_SCAN_START = True;
                        break;
                #  END OF CASE 13  */
                
            # END OF DO CASE...
            if goto_SCAN_END or goto_CENT_START:
                break
        # END OF DO FOREVER
        if goto_SCAN_START or goto_DEC_POINT_ENTRY or goto_CENT_START:
            continue
        
        def BUILD_COMMENT():
            global BLANK_COUNT, COMMENT_COUNT
            nonlocal COMMENT_PTR
            # No locals
            if NEXT_CHAR != BYTE(X1):
                BLANK_COUNT = 0;
            for BLANK_COUNT in range(0, BLANK_COUNT+1):
                COMMENT_COUNT = COMMENT_COUNT + 1;
                if COMMENT_COUNT >= 256:
                    if COMMENT_COUNT == 256:
                        ERROR(CLASS_M, 3);
                COMMENT_PTR = MIN(COMMENT_COUNT, 255);
                BYTE(SAVE_COMMENT, COMMENT_PTR, NEXT_CHAR);
        
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
                                NEXT_CHAR = CHAR_ALREADY_SCANNED;
                                CHAR_ALREADY_SCANNED = 0;
                                CHAR_NEEDED = FALSE;
                                OVER_PUNCH = OVERPUNCH_ALREADY_SCANNED;
                            else:
                                goto_TEST_SEARCH = False;
                            if SEARCH_NEEDED:
                                SEARCH_NEEDED = FALSE;
                                goto_SCAN_TOP = True
                                break
                            return;
                    else:
                        goto_LOOK_FOR_COMMENT = False;
                if goto_SET_SEARCH or (GROUP_NEEDED and MACRO_EXPAN_LEVEL==0):
                    goto_SET_SEARCH = False;
                    if SEARCH_NEEDED:
                        STREAM();
                        CHAR_NEEDED = FALSE;
                        goto_SCAN_END = True;
                        continue;
                    SEARCH_NEEDED = CHAR_NEEDED; ''' NO SEARCH NEEDED IF CHAR_NEEDED
                                                     IS NOT ON BECAUSE THE GROUP_NEEDED
                                                     CONDITION MUST BE CAUSED BY A LOOK
                                                     AHEAD IN NEXT_CHAR WHICH REALLY WAS
                                                     IN COLUMN 80 AND WILL BE SCANNED OUT
                                                     NEXT TIME '''
                    return;
                else:
                    if CHAR_NEEDED:
                        CHAR_NEEDED = FALSE;
                        STREAM();
            if goto_SCAN_TOP:
                break
            
            while NEXT_CHAR == BYTE(X1):
                if M_TOKENS(MACRO_EXPAN_LEVEL) <= 1:
                    return;
                if GROUP_NEEDED and MACRO_EXPAN_LEVEL==0:
                    CHAR_NEEDED = TRUE;
                    goto_SET_SEARCH = True;
                    break;
                else:
                    STREAM();
            if goto_SET_SEARCH:
                continue;
            
            if (NEXT_CHAR != BYTE('/')) or GROUP_NEEDED:
                goto_TEST_SEARCH = True;
                continue
            if OVER_PUNCH != 0:
                ERROR(CLASS_MO, 1);
            STREAM();  # LOOK AT NEXT CHAR
            if NEXT_CHAR != BYTE('*'):  # NOT REALLY A COMMENT
                CHAR_ALREADY_SCANNED = NEXT_CHAR;
                NEXT_CHAR = BYTE('/');
                OVERPUNCH_ALREADY_SCANNED = OVER_PUNCH;
                goto_TEST_SEARCH = True;
                continue;
        
            # IF WE GET HERE, WE HAVE A GENUINE COMMENT
            if OVER_PUNCH != 0:
                ERROR(CLASS_MO, 1);
            goto_SEARCH_NEXT_CHAR = False;
            goto_STORE_NEXT_CHAR = True;
            while goto_STORE_NEXT_CHAR:
                while goto_STORE_NEXT_CHAR or goto_SEARCH_NEXT_CHAR \
                        or NEXT_CHAR != BYTE('/'):
                    goto_STORE_NEXT_CHAR = False;
                    if not goto_SEARCH_NEXT_CHAR:
                        BUILD_COMMENT();
                    else:
                        goto_SEARCH_NEXT_CHAR = False;
                    if GROUP_NEEDED:
                        CHAR_NEEDED = TRUE;
                        goto_SET_SEARCH = True;
                        break;
                    STREAM();
                    if OVER_PUNCH != 0:
                        ERROR(CLASS_MO, 1);
                if goto_SET_SEARCH:
                    continue
                
                if BYTE(SAVE_COMMENT, COMMENT_PTR) != BYTE('*'):
                    goto_STORE_NEXT_CHAR = True;
                    continue;
            COMMENT_COUNT = COMMENT_COUNT - 1;  # UNSAVE THE '*'
            COMMENT_PTR = COMMENT_PTR - 1;  # HERE TOO 
            CHAR_NEEDED = TRUE;
            goto_LOOK_FOR_COMMENT = True;
            continue;
