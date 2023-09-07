#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   STREAM.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-08-31 RSB  Created a stub.
            2023-09-04 RSB  Began porting.
            
Note that the original of this file was pretty spaghetti-like.  Refer to the
notes concerning goto_XXXX in SCAN.xpl for an explanation of the workaround
technique.
'''

from g import *
from OUTPUTGR import OUTPUT_GROUP

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  STREAM                                                 */
 /* MEMBER NAME:     STREAM                                                 */
 /* LOCAL DECLARATIONS:                                                     */
 /*       ARROW             BIT(16)            LAST_E_COUNT      BIT(16)    */
 /*       ARROW_FLAG        BIT(8)             LAST_E_IND        BIT(16)    */
 /*       BEGINNING         LABEL              LAST_S_COUNT      BIT(16)    */
 /*       BLANKS            CHARACTER          LAST_S_IND        BIT(16)    */
 /*       BUILD_XSCRIPTS    LABEL              M_BLANKS          BIT(16)    */
 /*       CHAR_TEMP         CHARACTER          M_LINE            CHARACTER  */
 /*       CHECK_STRING_POSITION  LABEL         MACRO_DIAGNOSTICS LABEL      */
 /*       CHOP              LABEL              MACRO_DONE(1570)  LABEL      */
 /*       COMP              LABEL              PARM_DONE         LABEL      */
 /*       CP                BIT(16)            PNTR              BIT(16)    */
 /*       CREATING          BIT(8)             PREV_CARD         FIXED      */
 /*       D_CONTINUATION_OK BIT(8)             PRINT_COMMENT(1548)  LABEL   */
 /*       D_INDEX           BIT(16)            PROCESS_COMMENT   LABEL      */
 /*       D_TOKEN           CHARACTER          READ_CARD         LABEL      */
 /*       E_BLANKS          BIT(16)            RETURN_CHAR(2)    BIT(16)    */
 /*       E_COUNT           BIT(16)            RETURNING_E       BIT(16)    */
 /*       E_IND(127)        BIT(16)            RETURNING_M       BIT(8)     */
 /*       E_INDICATOR(127)  BIT(16)            RETURNING_S       BIT(16)    */
 /*       E_LINE            CHARACTER          S_BLANKS          BIT(16)    */
 /*       E_STACK           CHARACTER          S_COUNT           BIT(16)    */
 /*       EP                BIT(16)            S_IND(127)        BIT(16)    */
 /*       EXPONENT          LABEL              S_INDICATOR(127)  BIT(16)    */
 /*       FILL              BIT(16)            S_LINE            CHARACTER  */
 /*       FOUND_CHAR        LABEL              S_STACK           CHARACTER  */
 /*       GET_GROUP         LABEL              SAVE_BLANK_COUNT1 BIT(16)    */
 /*       I                 BIT(16)            SAVE_NEXT_CHAR1   BIT(8)     */
 /*       II                BIT(16)            SAVE_OVER_PUNCH1  BIT(8)     */
 /*       INCL_REMOTE_FLAG  MACRO              SCAN_CARD(1)      LABEL      */
 /*       INCL_TEMPLATE_FLAG  MACRO            SP                BIT(16)    */
 /*       INCLUDE_OK(1677)  LABEL              STACK             LABEL      */
 /*       INCLUDE_SDF       LABEL              STACK_CHECK       LABEL      */
 /*       INCREMENT_DOWN_STMT  BIT(8)          STACK_RETURN_CHAR LABEL      */
 /*       IND_LIM           MACRO              STREAM_START(1562)  LABEL    */
 /*       IND_SHIFT         MACRO              SUBS(1687)        LABEL      */
 /*       INDEX             BIT(16)            TEMPLATE_FLAG     BIT(8)     */
 /*       INPUT_PAD         CHARACTER          TYPE_CHAR(2)      BIT(8)     */
 /*       L                 BIT(16)                                         */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*       ACCESS_FLAG                          MISC_NAME_FLAG               */
 /*       ALIGNED_FLAG                         NAME_FLAG                    */
 /*       AREAFCB                              NDECSY                       */
 /*       AREAPG                               NONHAL_FLAG                  */
 /*       ARRAY_FLAG                           NUM_ERR                      */
 /*       ASSIGN_PARM                          NUM_OF_PARM                  */
 /*       AUTO_FLAG                            PAD1                         */
 /*       BASE_PARM_LEVEL                      PAGE                         */
 /*       BIT_TYPE                             PARM_EXPAN_LIMIT             */
 /*       CARD_TYPE                            PARM_STACK_PTR               */
 /*       CHAR_TYPE                            PLUS                         */
 /*       CHARTYPE                             PRIMARY                      */
 /*       CLASS_BI                             PRINT_FLAG                   */
 /*       CLASS_DI                             PROC_LABEL                   */
 /*       CLASS_DU                             PROC_MODE                    */
 /*       CLASS_IR                             PROG_LABEL                   */
 /*       CLASS_M                              PROG_MODE                    */
 /*       CLASS_ME                             READ_ACCESS_FLAG             */
 /*       CLASS_MS                             REENTRANT_FLAG               */
 /*       CLASS_PE                             REMOTE                       */
 /*       CLASS_PL                             REMOTE_FLAG                  */
 /*       CLASS_PM                             REPL_ARG_CLASS               */
 /*       CLASS_XA                             REPL_CLASS                   */
 /*       CLASS_XD                             REPLACE_TEXT_PTR             */
 /*       CLASS_XI                             RIGID_FLAG                   */
 /*       CLASS_XR                             SAVE_NEXT_CHAR               */
 /*       CLASS_XU                             SAVE_OVER_PUNCH              */
 /*       CMPL_MODE                            SAVE_SCOPE                   */
 /*       COMPOOL_LABEL                        SCALAR_TYPE                  */
 /*       CONSTANT_FLAG                        SDF_INCL_FLAG                */
 /*       CURRENT_SCOPE                        SDF_INCL_LIST                */
 /*       DEFINED_LABEL                        SDL_OPTION                   */
 /*       DENSE_FLAG                           SEMI_COLON                   */
 /*       DOUBLE                               SIMULATING                   */
 /*       DOUBLE_FLAG                          SINGLE_FLAG                  */
 /*                                            SRN_PRESENT                  */
 /*       DOWN_CLS                             STARS                        */
 /*       DOWN_ERR                             STMT_NUM                     */
 /*       DOWN_STMT                            STMT_PTR                     */
 /*       DOWNGRADE_LIMIT                      SYM_ADDR                     */
 /*       DUPL_FLAG                            SYM_ARRAY                    */
 /*       DWN_CLS                              SYM_CLASS                    */
 /*       DWN_ERR                              SYM_FLAGS                    */
 /*       DWN_STMT                             SYM_HASHLINK                 */
 /*       EJECT_PAGE                           SYM_LENGTH                   */
 /*       ENDSCOPE_FLAG                        SYM_LINK1                    */
 /*       ERR_VALUE                            SYM_LINK2                    */
 /*       ERROR_INDEX                          SYM_LOCK#                    */
 /*       EVENT_TYPE                           SYM_NAME                     */
 /*       EVIL_FLAG                            SYM_PTR                      */
 /*       EXCLUSIVE_FLAG                       SYM_SCOPE                    */
 /*       EXTENT                               SYM_TYPE                     */
 /*       EXTERNAL_FLAG                        SYM_XREF                     */
 /*       FACTOR_LIM                           SYT_ADDR                     */
 /*       FALSE                                SYT_ARRAY                    */
 /*       FIRST_FREE                           SYT_CLASS                    */
 /*       FOREVER                              SYT_FLAGS                    */
 /*       FUNC_CLASS                           SYT_HASHLINK                 */
 /*       FUNC_MODE                            SYT_HASHSIZE                 */
 /*       INACTIVE_FLAG                        SYT_HASHSTART                */
 /*       INCLUDE_FILE#                        SYT_LINK1                    */
 /*       INCLUDED_REMOTE                      SYT_LINK2                    */
 /*       INIT_AFCBAREA                        SYT_LOCK#                    */
 /*       INIT_APGAREA                         SYT_NAME                     */
 /*       INIT_FLAG                            SYT_PTR                      */
 /*       INPUT_PARM                           SYT_SCOPE                    */
 /*       INT_TYPE                             SYT_TYPE                     */
 /*       LABEL_CLASS                          SYT_XREF                     */
 /*       LAST_WRITE                           TEMPL_NAME                   */
 /*       LATCHED_FLAG                         TEMPLATE_CLASS               */
 /*       LINE_LIM                             TEMPORARY_FLAG               */
 /*       LINK_SORT                            TEXT_LIMIT                   */
 /*       LISTING2                             TOKEN                        */
 /*       LIT_TOP                              TPL_FUNC_CLASS               */
 /*       LOCK_FLAG                            TPL_LAB_CLASS                */
 /*       M_BLANK_COUNT                        TRUE                         */
 /*       M_CENT                               UNMOVEABLE                   */
 /*       M_P                                  VAR_CLASS                    */
 /*       M_PRINT                              VAR_LENGTH                   */
 /*       M_TOKENS                             VBAR                         */
 /*       MAC_TXT                              VEC_TYPE                     */
 /*       MACRO_CALL_PARM_TABLE                XREF_REF                     */
 /*       MACRO_TEXTS                          XTNT                         */
 /*       MACRO_TEXT                           X1                           */
 /*       MAJ_STRUC                            X4                           */
 /*       MAT_TYPE                             X70                          */
 /*       MAX_SCOPE#                           X8                           */
 /*       MAX_STRUC_LEVEL                                                   */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*       BCD                                  MACRO_EXPAN_LEVEL            */
 /*       BLANK_COUNT                          MACRO_FOUND                  */
 /*       BLOCK_MODE                           MACRO_POINT                  */
 /*       BLOCK_SYTREF                         MEMBER                       */
 /*       BUILDING_TEMPLATE                    N_DIM                        */
 /*       CLOSE_BCD                            NAME_HASH                    */
 /*       C                                    NAME_IMPLIED                 */
 /*       CARD_COUNT                           NEST                         */
 /*       COMM                                 NEW_LEVEL                    */
 /*                                            NEXT_CC                      */
 /*       COMMENTING                           NEXT_CHAR                    */
 /*       COMPARE_SOURCE                       NONBLANK_FOUND               */
 /*       CONTROL                              OLD_LEVEL                    */
 /*       CSECT_LENGTHS                        OVER_PUNCH                   */
 /*       CURRENT_CARD                         P_CENT                       */
 /*       DATA_REMOTE                          PAGE_THROWN                  */
 /*                                            PARM_EXPAN_LEVEL             */
 /*       DOWN_COUNT                           PARM_REPLACE_PTR             */
 /*       DOWN_INFO                            PRINTING_ENABLED             */
 /*       END_GROUP                            PROCMARK                     */
 /*       END_OF_INPUT                         PROCMARK_STACK               */
 /*       FIRST_TIME                           PROGRAM_ID                   */
 /*       FIRST_TIME_PARM                      REF_ID_LOC                   */
 /*       GROUP_NEEDED                         REGULAR_PROCMARK             */
 /*       ID_LOC                               REV_CAT                      */
 /*       INCL_SRN                             START_POINT                  */
 /*       INCLUDE_CHAR                         S                            */
 /*       INCLUDE_COMPRESSED                   S_ARRAY                      */
 /*       INCLUDE_COUNT                        SAVE_CARD                    */
 /*       INCLUDE_END                          SCOPE#                       */
 /*       INCLUDE_LIST                         SCOPE#_STACK                 */
 /*       INCLUDE_LIST2                        SDF_OPEN                     */
 /*       INCLUDE_MSG                          SMRK_FLAG                    */
 /*       INCLUDE_OFFSET                       SRN                          */
 /*       INCLUDE_OPENED                       SRN_COUNT                    */
 /*       INCLUDING                            STRUC_DIM                    */
 /*       INITIAL_INCLUDE_RECORD               STRUC_PTR                    */
 /*       INPUT_DEV                            STRUC_SIZE                   */
 /*       INPUT_REC                            SYM_TAB                      */
 /*       IODEV                                TEMPORARY_IMPLIED            */
 /*       J                                    TOP_OF_PARM_STACK            */
 /*       K                                    TPL_REMOTE                   */
 /*       LINE_MAX                             TPL_VERSION                  */
 /*       LOOKED_RECORD_AHEAD                  TYPE                         */
 /*       LRECL                                WAIT                         */
 /*       MACRO_ARG_COUNT                                                   */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*       CHAR_INDEX                           ICQ_TERM#                    */
 /*       CHECK_STRUC_CONFLICTS                INTERPRET_ACCESS_FILE        */
 /*       DESCORE                              MAKE_INCL_CELL               */
 /*       DISCONNECT                           MAX                          */
 /*       ENTER_XREF                           MIN                          */
 /*       ENTER                                MOVE                         */
 /*       ENTER_DIMS                           NEXT_RECORD                  */
 /*       ENTER_LAYOUT                         ORDER_OK                     */
 /*       ERRORS                               OUTPUT_GROUP                 */
 /*       ERROR                                OUTPUT_WRITER                */
 /*       FINDER                               PAD                          */
 /*       FINISH_MACRO_TEXT                    PRINT2                       */
 /*       HASH                                 SAVE_INPUT                   */
 /*       HEX                                  SAVE_LITERAL                 */
 /*       ICQ_ARRAY#                           SET_DUPL_FLAG                */
 /* CALLED BY:                                                              */
 /*       SCAN                                                              */
 /*       INITIALIZATION                                                    */
 /***************************************************************************/
'''

debugCount = 0
def debug(msg):
    global debugCount
    print(debugCount, msg, NEXT_CHAR, OVER_PUNCH)
    debugCount += 1

def STREAM():
    global BCD, BLANK_COUNT, BLOCK_MODE, BLOCK_SYTREF, BUILDING_TEMPLATE, \
            CLOSE_BCD, CARD_COUNT, COMMENTING, COMPARE_SOURCE, CONTROL, \
            CSECT_LENGTHS, CURRENT_CARD, DATA_REMOTE, DOWN_COUNT, DOWN_INFO, \
            END_GROUP, END_OF_INPUT, FIRST_TIME, FIRST_TIME_PARM, \
            GROUP_NEEDED, ID_LOC, INCL_SRN, INCLUDE_CHAR, INCLUDE_COMPRESSED, \
            INCLUDE_COUNT, INCLUDE_END, INCLUDE_LIST, INCLUDE_LIST2, \
            INCLUDE_MSG, INCLUDE_OFFSET, INCLUDE_OPENED, INCLUDING, \
            INITIAL_INCLUDE_RECORD, INPUT_DEV, INPUT_REC, IODEV, J, K, \
            LINE_MAX, LOOKED_RECORD_AHEAD, LRECL, MACRO_ARG_COUNT, \
            MACRO_EXPAN_LEVEL, MACRO_FOUND, MACRO_POINT, MEMBER, N_DIM, \
            NAME_HASH, NAME_IMPLIED, NEST, NEW_LEVEL, NEXT_CC, NEXT_CHAR, \
            NONBLANK_FOUND, OLD_LEVEL, OVER_PUNCH, P_CENT, PAGE_THROWN, \
            PARM_EXPAND_LEVEL, PARM_REPLACE_PTR, PRINTING_ENABLED, PROCMARK, \
            PROCMARK_STACK, PROGRAM_ID, REF_ID_LOC, REGULAR_PROCMARK, REV_CAT, \
            START_POINT, S, S_ARRAY, SAVE_CARD, SCOPEp, SCOPEp_STACK, \
            SDF_OPEN, SMRK_FLAG, SRN, SRN_COUNT, STRUC_DIM, STRUC_PTR, \
            STRUC_SIZE, SYM_TAB, TEMPORARY_IMPLIED, TOP_OF_PARM_STACK, \
            TPL_REMOTE, TPL_VERSION, TYPE, WAIT, INCLUDE_STMT
    
    ''' THIS PROCEDURE FILLS THE VARIABLES NEXT_CHAR, ARROW, AND OVER_PUNCH.
    NEXT_CHAR IS A ONE BYTE  VARIABLE THAT CONTAINS THE NEXT CHARACTER IN
    THE INPUT STREAM. ARROW IS A HALF-WORD VARIABLE THAT CONTAINS AN INTEGER
    WHICH REPRESENTS THE RELATIVE DISPLACEMENT OF THE CHARACTER IN NEXT_CHAR
    WITH RESPECT TO THE LAST CHARACTER. A POSITIVE VALUE INDICATES A MOVE UP.
    OVER_PUNCH IS A ONE BYTE  VARIABLE THAT IS FILLED WITH A NON-ZERO
    VALUE WHEN A CHARACTER OTHER THAN BLANK APPEARS DIRECTLY OVER AN
    M-LINE CHARACTER--THE VALUE IS THE BYTE VALUE OF THE OVER PUNCH CHARACTER
    '''
    BLANKS = '                                            ';
    M_LINE = '';
    ''' THE FOLLOWING DECLARE MUST BE IN THE EXACT ORDER STATED. ITS USE IS
    DEPENDENT UPON THE MEMORY LOCATIONS ASSIGNED TO CONTIGUOUSLY
    DECLARED CHARACTER STRING DESCRIPTORS WHICH IS CURRENTLY
    PRESUMED TO BE IN ASCENDING LOCATIONS '''
    # The comment above sounds bad ... *really* bad.  We'll see.
    E_LINE = ""
    S_LINE = ""
    E_STACK = ""
    S_STACK = ""
    # Regarding the following comment, see the comments preceding INPUT()
    # in g.py.  We use g.asciiEOT (0x04) in place of 0xFE for EOF.  And 
    # ASCII backtick (`) in place of the EBCDIC cent sign.
    ''' THE EOF SYMBOL IS A HEX'FE'. IT IS CREATED BY A 12-11-0-6-8-9
        MULTIPLE PUNCH ON A CARD.
        THE FORMAT OF INPUT_PAD IS:
                  'M XY YX Z Z '' Z Z " Z Z'
        WHERE X IS A "/", Y IS A "*", AND Z IS THE EOF SYMBOL '''
    INPUT_PAD = 'M /**/ ` ` '' ` ` " ` `';
    LAST_E_IND = 0
    LAST_S_IND = 0
    E_BLANKS = 0
    S_BLANKS = 0
    EP = 0
    SP = 0
    M_BLANKS = -1
    IND_LIM = 127
    IND_SHIFT = 7
    E_IND = [0]*(IND_LIM+1)
    S_IND = [0]*(IND_LIM+1)
    E_INDICATOR = [0]*(IND_LIM+1)
    S_INDICATOR = [0]*(IND_LIM+1)
    
    E_COUNT = 0
    S_COUNT = 0
    LAST_E_COUNT = 0
    LAST_S_COUNT = 0
    PNTR = 0
    CP = 0
    FILL = 0
    INDEX = 1
    RETURNING_M = TRUE
    RETURNING_S = 0
    RETURNING_E = 0
    PREV_CARD = 1.0
    CHAR_TEMP = ''
    RETURN_CHAR = [0]*3
    TYPE_CHAR = [0]*3
    ARROW_FLAG = 0
    ARROW_BIT = 0
    II = 0
    SAVE_OVER_PUNCH1 = 0
    SAVE_NEXT_CHAR1 = 0
    SAVE_BLANK_COUNT1 = 0
    I = 0
    L = 0
    CREATING = 0
    TEMPLATE_FLAG = 0
    # INCLUDE CELL FLAG BITS
    INCL_TEMPLATE_FLAG = 0x02
    INCL_REMOTE_FLAG = 0x01
    # D TOKEN GLOBALS
    D_INDEX = 0
    D_CONTINUATION_OK = FALSE
    # TWO-DIMENSIONAL INPUT PROCEDURES
    # GO TO STREAM_START was here, but there's no actual code between here and
    # the label STREAM_START, so I've just removed both the GO TO and the label.
    
    '''
    /* $%PRINTCOM - PRINT_COMMENT */
    /* $%DTOKEN   - D_TOKEN */
    /%INCLUDE INCSDF %/
    /* $%PATCHINC  -  PATCH_INCLUDE*/
    
    The original 4 lines above are a bit mysterious.  Note that $char within
    an XPL comment is interpreted as a control code for the compiler, but $%
    is *not* standard XPL, and therefore is presumably something (but what?)
    specific to Intermetrics's version of XPL.  I think it may be expressing
    the notion that PRINT_COMMENT, D_TOKEN, and PATCH_INCLUDE are external
    procedures or functions found in the modules PRINTCOM, DTOKEN, and PATCHINC 
    respectively.  As it happens, though PATCH_INCLUDE isn't used here in this
    module, nor is it present in the PATCHINC module ... rather, INCLUDE_OK()
    is in both of those. I have no explanation regarding this discrepancy.
    
    As far as the "INCLUDE INCSDF" line is concerned, note that the procedure 
    INCLUDE_SDF() comprises the entirety of the original HALINCL/INCSDF module.  
    At the same time, the comments within our present module (STREAM) indicate 
    that INCLUDE_SDF() is declared locally in STREAM, even though no such 
    declaration is present.  I infer that the intention is to include the 
    entire contents of the HALINCL/INCSDF module at the current location in 
    *this* module, thus making INCLUDE_SDF() local to this module.
    
    But I don't actually find that INCLUDE_SDF is used in this module, so I'm
    not sure why it would be included.
    
    As for why it requires these 4 weird commands (not encountered elsewhere)  
    to accomplish these things, it may have something to do with these imports
    being local to the STREAM function rather than being global in nature.  Or
    perhaps it has to do with the 4 additional modules referenced not being
    members of the same hierarchical directory containing STREAM, but instead
    being members of the HALINCL directory elsewhere in the hierarchy.  
    Perhaps mose likely, these 4 lines aren't needed at all, and are present
    simply for some legacy documentation reason.  Or perhaps not.  Ultimately,
    I guess it doesn't matter one or the other exactly how it worked originally
    as long as we can fake it adequately now.
    
    At any rate, what that all implies, if true, is that each of the 4 mystery
    lines corresponds to a Python "import", as follows:
    '''
    from HALINCL.PRINTCOM import PRINT_COMMENT
    from HALINCL.DTOKEN import D_TOKEN
    #from HALINCL.INCSDF import *
    from HALINCL.PATCHINC import INCLUDE_OK
    
    # Note: Handling the ERRPRINT label and its GO TOs from the original XPL
    # code in the manner I've typically being using (i.e., with a boolean
    # variable called goto_ERRPRINT) would complicate the following code
    # considerably.  However, ERRPRINT is basically an error exit, which lets
    # us use a much simpler approach: namely, replacing each GO TO ERRPRINT by 
    # a call to a new function(ERRPRINT) followed by an immediate return from 
    # PROCESS_COMMENT().
    def PROCESS_COMMENT():
        global INCLUDE_STMT, D_INDEX, LINE_MAX, PAGE_THROWN, J, K, L, \
                SMRK_FLAG, IODEV, SYT_LOCKp, TPL_VERSION, \
                TEMP_CLS, ULT_TEMP_CLS, FIN_TMP_CLS, TEMP_COUNT, CONTINUE, \
                LOOKED_RECORD_AHEAD, DATA_REMOTE, D_INDEX, CREATING, \
                CARD_COUNT, PROGRAM_ID, TEMP_CLS, \
                CONTROL, CURRENT_CARD, DOWN_COUNT, \
                END_OF_INPUT, INCLUDE_COUNT, INCLUDE_LIST, \
                INCLUDE_LIST2, INCREMENT_DOWN_STMT, VAL
                
        # Locals:
        NEXT_DIR = ['']*2;
        TMP_INCREMENT = 0;
        PRINT_FLAG = 0;
        I = 0;
        RECORD_NOT_WRITTEN = 0;
        LIST_FLAG = 0;
        C = ['']*2
        XC = 'C';
        INCLUDE_DIR = 'INCLUDE',
        START = 'START';
        EJECT_DIR = 'EJECT';
        SPACE_DIR = 'SPACE';
        TOGGLES = '0123456789ABCDEFG';

        def ERRPRINT():
            global INCLUDE_STMT
            OUTPUT_WRITER();  # PRINT ANY ERRORS
            if not INCLUDING:
                INCLUDE_STMT = -1;

        if BYTE(CURRENT_CARD, BYTE('C')):
            PRINT_COMMENT(TRUE);
        elif BYTE(CURRENT_CARD) == BYTE('D'):
            # A DIRECTIVE CARD 
            D_INDEX = 1;
            C[0] = D_TOKEN;
            if (C[0] == EJECT_DIR) or (C[0] == SPACE_DIR):
                PRINT_COMMENT(FALSE);
                if C[0] == EJECT_DIR:
                    if not PAGE_THROWN or LINE_MAX != 0:
                        LINE_MAX = 0;
                        PAGE_THROWN = TRUE;
                else:  # SPACE DIRECTIVE 
                    C[0] = D_TOKEN;
                    if LENGTH(C[0]) == 0:
                        J = 1;  # 1 SPACE
                    else:
                        J = BYTE(C[1]);
                        if CHARTYPE(J) != 1:
                            J = 1;  # ASSUME ONE SPACE
                        else:
                            J = J & 0xF;
                        if J > 3:
                            J = 3;
                    if LINE_MAX == 0:
                        LINE_MAX = LINE_LIM;
                        EJECT_PAGE();
                    if LINE_COUNT + J > LINE_MAX:
                        LINE_MAX = 0;
                    else:
                        for I in range(1, J+1):
                            OUTPUT(0, X1);
                return;
            PRINT_COMMENT(TRUE,C[0]);
            if (C[0] == 'EB') or (C[0] == 'EBUG'):  # DEBUG DIRECTIVE
                
                def CHAR_VALUE(STR):
                    # No nonlocals.
                    # Locals:
                    K = 0
                    J = 0;
                    VAL=0;
                    while J < LENGTH(STR):
                        K = BYTE(STR, J);
                        if (K >= BYTE('0')) and (K <= BYTE('9')):
                            VAL = VAL * 10 + (K - BYTE('0'));
                        J = J + 1;
                    return VAL;
                
                C[0] = D_TOKEN;
                while LENGTH(C[0]) != 0:
                    if SUBSTR(C[0], 0, 2) == 'H(':
                        SMRK_FLAG = CHAR_VALUE(C[0]);
                    else: # ADD NEW DEBUG TYPES HERE
                        C[0] = D_TOKEN;
                for I in range(1, TEXT_LIMIT[0]):
                    if BYTE(CURRENT_CARD, I) == BYTE('`'):
                        J = CHAR_INDEX(TOGGLES, SUBSTR(CURRENT_CARD, I + 1, 1));
                        if J > -1:
                            goto_COMPLEMENT = False
                            if I < TEXT_LIMIT[0] - 1:
                                K = BYTE(CURRENT_CARD, I + 2);
                            else:
                                goto_COMPLEMENT = True;
                            if K == BYTE('+') and not goto_COMPLEMENT:
                                CONTROL[J] = 0xFF;
                            elif K == BYTE('-') and not goto_COMPLEMENT:
                                CONTROL[J] = FALSE;
                            else:
                                goto_COMPLEMENT = False
                                CONTROL[J] = not CONTROL[J];
                            if J == "D":
                                INCLUDE_LIST, INCLUDE_LIST2 = CONTROL[J];
                        if CONTROL["A"]:
                            EXIT();
            # END OF DEBUG DIRECTIVE
            elif C[0] == 'DEVICE':
                C[0] = D_TOKEN;
                goto_NO_CHAN = False
                firstTry = True
                while firstTry or goto_NO_CHAN:
                    firstTry = False
                    if LENGTH(C[0]) == 0 or goto_NO_CHAN:
                        goto_NO_CHAN = False          
                        ERROR(CLASS_XD,3);
                        ERRPRINT()
                        return
                    I = CHAR_INDEX(C[0], 'CHANNEL=');
                    if I != 0:
                        goto_NO_CHAN = True;
                        continue
                    J = 0;
                    for I in range(8, LENGTH(C[0])):
                        K = BYTE(C[0], I);
                        if CHARTYPE(K) != 1:
                            goto_NO_CHAN = True;
                            continue;
                        J = J * 10 + (K & 0xF);
                    if I == 8:
                        goto_NO_CHAN = True;
                        continue
                if J > 9:
                    ERROR(CLASS_XD,4);
                    ERRPRINT()
                    return
                C[0] = D_TOKEN;
                PRINT_FLAG = FALSE;
                L = IODEV(J);
                if C[0] == 'UNPAGED':
                    pass
                elif C[0] == 'PAGED':
                    PRINT_FLAG = TRUE;
                elif C[0] != '':
                    L = L | 0x20;
                    ERROR(CLASS_XD,1);
                goto_D_DONE = False
                if (L & 0x40) != 0:
                    ERROR(CLASS_XD,2);
                    goto_D_DONE = True
                if not goto_D_DONE:
                    if L == 0:
                        L = 0x50;  # DIRECTIVE FOUND AND UNUSED FLAGS
                    else:
                        L = L | 0x40;  # DIRECTIVE FOUND 
                    if (L & 0x28) != 0:
                        goto_D_DONE = True;  # ERRORS ALREADY EXIST FOR THIS CHANNEL
                    if not goto_D_DONE:
                        if PRINT_FLAG:
                            if (L & 0x03) != 0:
                                L = L | 0x08;  # CONFLICT FLAG
                                goto_D_DONE = True;
                            if not goto_D_DONE:
                                L = L | 0x04;  # PRINT FLAG
                        else:
                            L = (L & 0xFB) | 0x03;  # PRINT OFF, READ/WRITE ON
                goto_D_DONE = False
                IODEV[J] = L;
                ERRPRINT()
                return
            elif C[0] == INCLUDE_DIR:
                # AN INCLUDE DIRECTIVE
                if INCLUDE_OK():
                    OUTPUT(0, X8 + STARS + START + INCLUDE_MSG + STARS);
            # END OF INCLUDE DIRECTIVE
            elif C[0]=='VERSION':
                if TPL_VERSION>0:
                    I=BYTE(CURRENT_CARD,D_INDEX+1);
                    SYT_LOCKp[TPL_VERSION]=I;
                    TPL_VERSION=0;
            elif C[0] == 'DOWNGRADE' or C[0] == 'OWNGRADE': # DOWNGRADE
                TEMP_CLS = ''
                ULT_TEMP_CLS = ''
                FIN_TMP_CLS = ''
                TEMP_COUNT = 0
                CONTINUE = 0;
                C[0] = D_TOKEN;
                if LENGTH(C[0]) == 0: # NO ERROR NUMBER TO DOWNGRADE 
                    ERRORS(CLASS_BI, 108);
                elif DOWN_COUNT > DOWNGRADE_LIMIT: # OBTAIN CLASS
                    '''
                    /* IN ORDER TO COMPLETELY REMOVE THE LIMIT ON THE NUMBER OF          */
                    /* ALLOWABLE DOWNGRADES JUST REMOVE THIS IF STATEMENT AND   */
                    /* CALL TO ERRORS. SUBSEQUENTLY THE ELSE DO AND CORRESPONDING END    */
                    /* STATEMENTS MUST ALSO THEN BE REMOVED.                             */
                    /* CHECK TO SEE IF EXCEEDED DOWNGRADE_LIMIT */
                    '''
                    ERRORS (CLASS_BI, 109);
                else:
                    NEXT_ELEMENT(DOWN_INFO);
                    DOWN_COUNT = DOWN_COUNT + 1;
                    for I in range(0, 2):
                       TEMP_CLS = SUBSTR(C[0],0,I+1);
                       ULT_TEMP_CLS = SUBSTR(TEMP_CLS,I,I);
                       if ULT_TEMP_CLS >= '0' and ULT_TEMP_CLS <= '9':
                          CONTINUE = 1;
                       if CONTINUE == 0: # GET CLASS
                          ULT_TEMP_CLS = PAD('CLASS_'+TEMP_CLS,8);
                          FIN_TMP_CLS = SUBSTR(X1+ULT_TEMP_CLS, 1);
                       # END DETERMINE CLASS
                    # END OF ELSE FOR CLASS
                    '''
                    /* CHECK THE NEXT STATEMENT TO SEE IF DOWNGRADING A DIRECTIVE     */
                    /* OR A STATEMENT  IF THE NEXT STATEMENT IS A DIRECTIVE, THEN     */
                    /* SET INCREMENT_DOWN_STMT TO FALSE.                              */
                    '''
                    TMP_INCREMENT = INCREMENT_DOWN_STMT;
                    NEXT_RECORD();
                    LOOKED_RECORD_AHEAD = TRUE;
                    if CARD_TYPE(BYTE(CURRENT_CARD)) == CARD_TYPE(BYTE('D')):
                        D_INDEX = 1;
                        NEXT_DIR = D_TOKEN;
                        if NEXT_DIR != 'DOWNGRADE' and NEXT_DIR != 'OWNGRADE':
                            INCREMENT_DOWN_STMT = FALSE;
                    # ATTACH DOWNGRADE TO CORRECT STATEMENT
                    if INCREMENT_DOWN_STMT and TOKEN==SEMI_COLON:
                        DWN_STMT(DOWN_COUNT, SUBSTR(X1+STMT_NUM+1,1));
                    else:
                        DWN_STMT(DOWN_COUNT, SUBSTR(X1+STMT_NUM,1));
                    INCREMENT_DOWN_STMT = TMP_INCREMENT;
                    TEMP_CLS = CHAR_VALUE(C[0]);
                    DWN_ERR(DOWN_COUNT, SUBSTR(X1+TEMP_CLS,1));
                    CONTINUE = 1;
                    TEMP_COUNT = 0;
                    while CONTINUE == 1 and TEMP_COUNT <= NUM_ERR:
                        if FIN_TMP_CLS == ERROR_INDEX(TEMP_COUNT):
                            DWN_CLS(DOWN_COUNT, ERR_VALUE(TEMP_COUNT));
                            CONTINUE = 0;
                        else:
                            TEMP_COUNT = TEMP_COUNT + 1;
                    if CONTINUE == 1: # ERROR CLASS NOT FOUND
                        '''
                        /* SAVE THE ERROR NUMBER LOCATED IN 'C' INTO 'DWN_UNKN'. CODE IN     */
                        /* DOWNGRADE_SUMMARY WILL USE THIS INFO TO BUILD A DOWNGRADE SUMMARY */
                        /* REPORT INSTEAD OF USING 'DWN_CLS' TO FIND THE ERROR CLASS (THERE  */
                        /* IS NO INFORMATION TO PUT INFO 'DWN_CLS' SINCE THE ERROR CLASS DOES*/
                        /* NOT EXIST).                                                       */
                        '''
                        DWN_UNKN(DOWN_COUNT, C[0]);
                        ERRORS (CLASS_BI, 107);
            # END OF DOWNGRADE
            elif C[0] == 'PROGRAM':
                if BLOCK_MODE != 0:
                    ERROR(CLASS_XA, 3);
                    ERRPRINT()
                    return
                if LENGTH(PROGRAM_ID) > 0:
                    ERROR(CLASS_XA, 1);
                    ERRPRINT()
                    return
                C[0] = D_TOKEN;
                goto_NO_ID = False
                firstTry = True
                while firstTry or goto_NO_ID:
                    firstTry = False
                    if goto_NO_ID or LENGTH(C[0]) == 0:
                        goto_NO_ID = False
                        ERROR(CLASS_XA, 2);
                        ERRPRINT()
                        return
                    I = CHAR_INDEX(C[0], 'ID=');
                    if I != 0:
                        goto_NO_ID = True;
                        continue
                    if LENGTH(C[0]) <= 3:
                        goto_NO_ID = True;
                        continue
                if LENGTH(C[0])>=11:
                    PROGRAM_ID = SUBSTR(C[0], 3, 8);
                else:
                    PROGRAM_ID = PAD(SUBSTR(C[0], 3), 8);
                INTERPRET_ACCESS_FILE();
            elif C[0] == 'DEFINE':
                
                def COPY_TO_8():
                    # No nonlocals or locals.
                    PRINT_COMMENT(LIST_FLAG);
                    OUTPUT(8, CURRENT_CARD);
                    RECORD_NOT_WRITTEN = FALSE;
                    MONITOR(16, 0x10);
                
                C[1] = D_TOKEN;
                if LENGTH(C[1]) == 0:
                    ERROR(CLASS_XD, 5);
                elif LENGTH(C[1]) >= 8:
                    C[1] = SUBSTR(C[1],0,8);
                else:
                    C[1] = PAD(C[1], 8);
                C[0] = D_TOKEN;
                if LENGTH(C[0]) > 0:
                    LIST_FLAG = (C[0] == 'LIST');
                else:
                    LIST_FLAG = FALSE;
                RECORD_NOT_WRITTEN = TRUE;
                if INCLUDING:
                    ERROR(CLASS_XD, 8);
                else:
                    CREATING = TRUE;
                while CREATING:
                    NEXT_RECORD();
                    if LENGTH(CURRENT_CARD) == 0:
                        if INCLUDING:
                            INPUT_DEV = 0;
                            INCLUDING,INCLUDE_COMPRESSED=FALSE;
                            INCLUDE_LIST = TRUE;
                            INCLUDE_LIST2=TRUE;
                            OUTPUT(8, XC+STARS+'END'+ INCLUDE_MSG+STARS);
                            INCLUDE_OFFSET = \
                                INCLUDE_COUNT+CARD_COUNT+1-INCLUDE_OFFSET;
                            INCLUDE_COUNT = INCLUDE_OFFSET
                        else:
                            CREATING = FALSE;
                            END_OF_INPUT = TRUE;
                            CURRENT_CARD = INPUT_PAD + X70;
                    else:
                        CARD_COUNT = CARD_COUNT + 1;
                        if CARD_TYPE(BYTE(CURRENT_CARD))==CARD_TYPE(BYTE('D')):
                            D_INDEX = 1;
                            C[0] = D_TOKEN;
                            if C[0] == INCLUDE_DIR:
                                BYTE(CURRENT_CARD, 0, BYTE('C'));
                                COPY_TO_8();
                                if INCLUDE_OK():
                                    OUTPUT(8, XC+STARS+START+INCLUDE_MSG+STARS);
                            elif C[0] == 'CLOSE': # END OF INLINE BLOCK
                                PRINT_COMMENT(TRUE);
                                C[0] = D_TOKEN;
                                if LENGTH(C[0]) >= 8:
                                    C[0] = SUBSTR(C[0],0,8);
                                else:
                                    C[0] = PAD(C[0], 8);
                                if C[0] != C[1]:
                                    ERROR(CLASS_XD, 6, C[0]);
                                if RECORD_NOT_WRITTEN:
                                    ERROR(CLASS_XD, 7);
                                elif LENGTH(C[1]) > 0:
                                    if MONITOR(1, 8, C[1]): # STOW THE MEMBER
                                        ERROR(CLASS_XD, 9, C[1]);
                                CREATING = FALSE;
                            else:
                                COPY_TO_8();
                        else:
                            COPY_TO_8();
                # END WHILE CREATING
            # IN THIS SECTION OF CODE,WE LOOK FOR THE DATA_REMOTE DIRECTIVE
            elif C[0]=='DATA_REMOTE' or C[0]=='ATA_REMOTE': # REMOTE #D
                DATA_REMOTE=TRUE;
                if pfs:
                    # CHECK FOR ILLEGAL LOCATION OF THE DIRECTIVE
                    if BLOCK_MODE != 0:
                        ERRORS(CLASS_XR,1);
                    # PART2 -- CHECK FOR ILLEGAL LOCATION OF
                    # THE DIRECTIVE INSIDE AN EXTERNAL BLOCK.
                    if ((SYT_FLAGS(BLOCK_SYTREF(NEST))&EXTERNAL_FLAG)!=0):
                        ERRORS(CLASS_XR,1);
            # END DATA_REMOTE
            
            #-----------------------------------------------------------------
            else:
                ERROR(CLASS_XU,1);
                
            if not pfs: # BFS
                '''
                /* THIS CODE RESTRICTS BFS FROM USING THE 'DATA_REMOTE' DIRECTIVE  */
                /* AND WILL ISSUE A B102 ERROR MESSAGE.  THIS CODE WILL NEED TO BE */
                /* REMOVED IF AND WHEN BFS BEGINS USING 'DATA_REMOTE'.             */
                '''
                if DATA_REMOTE:
                    ERROR(CLASS_B,102);
                    DATA_REMOTE=FALSE;
            #-----------------------------------------------------------------
            ERRPRINT()
    
    def STACK_RETURN_CHAR(NUMBER, CHAR):
        nonlocal RETURN_CHAR, TYPE_CHAR
        # Locals:
        I = 0
        CHAR = 0
        
        print("Here")
        
        for I in range(0, 3):
            if RETURN_CHAR[I] == 0:
                RETURN_CHAR[I] = NUMBER;
                TYPE_CHAR[I] = CHAR;
                return;
    
    def READ_CARD():
        global CURRENT_CARD, INPUT_DEV, INCLUDE_COMPRESSED, INCLUDING, \
                INCLUDE_STMT, INCLUDE_END, TEXT_LIMIT, END_OF_INPUT, \
                CARD_COUNT, INCLUDE_LIST2, INCLUDE_OFFSET, INCLUDE_COUNT, \
                SAVE_CARD
        # No locals.
        print("A")
        if END_OF_INPUT:
            CURRENT_CARD = INPUT_PAD + X70;
            return;
        goto_READ = True
        while goto_READ:
            print("B")
            goto_READ = False
            NEXT_RECORD();
            if LENGTH(CURRENT_CARD) > 88:
                CURRENT_CARD = SUBSTR(CURRENT_CARD, 0, 88);
            if LENGTH(CURRENT_CARD) == 0:
                if INCLUDING:
                    INPUT_DEV=0;
                    INCLUDE_COMPRESSED = FALSE
                    INCLUDING=FALSE;
                    INCLUDE_STMT = -1;
                    INCLUDE_END=TRUE;
                    if not pfs: # BFS/PASS INTERFACE; TEMPLATE LENGTH
                        if TEMPLATE_FLAG:
                            TEXT_LIMIT[0]=TEXT_LIMIT[1];
                    goto_READ = True;
                    continue
                else:
                    END_OF_INPUT = TRUE;
                    CURRENT_CARD = INPUT_PAD + X70;
        CARD_COUNT = CARD_COUNT + 1;
        if LISTING2:
            if CARD_COUNT != 0:
                SAVE_INPUT();
        if INCLUDE_END:
            INCLUDE_LIST2 = TRUE;
            INCLUDE_OFFSET = INCLUDE_COUNT + CARD_COUNT - INCLUDE_OFFSET;
            INCLUDE_COUNT = INCLUDE_OFFSET
        SAVE_CARD = CURRENT_CARD;
    
    def SCAN_CARD(TYPE):
        nonlocal E_INDICATOR, FILL
        # Local:
        POINT = SHL(TYPE, IND_SHIFT);
       
        for CP in range(1, TEXT_LIMIT[0]+1):
            if BYTE(CURRENT_CARD, CP) != BYTE(X1):
                if BYTE(E_LINE[TYPE], CP) != BYTE(X1):
                    if TYPE == 0:
                        ERROR(CLASS_ME,4);
                    elif TYPE == 1:
                        ERROR(CLASS_MS,4);
                        continue
                E_INDICATOR[CP + POINT] = E_COUNT[TYPE];
                FILL = BYTE(CURRENT_CARD, CP);
                BYTE(E_LINE[TYPE], CP, FILL);
    
    def COMP(TYPE):
        nonlocal E_COUNT, E_INDICATOR, FILL
        # Local:
        POINT = 0xC5 + 0x1D * TYPE;
        
        E_COUNT[TYPE] = 1;
        while True:
            SCAN_CARD(TYPE);
            READ_CARD();
            if BYTE(CURRENT_CARD) != POINT: # NO MORE OF THIS TYPE OF CARD
                if not ORDER_OK(POINT):
                    ERROR(CLASS_M,2);
                POINT = SHL(TYPE, IND_SHIFT);
                for CP in range(1, TEXT_LIMIT[0]+1):
                    if BYTE(E_LINE(TYPE), CP) == BYTE(X1):
                        E_INDICATOR[CP + POINT] = 0;
                    elif not TYPE:
                        FILL = E_COUNT - E_INDICATOR[CP] + 1;
                        E_INDICATOR[CP] = FILL;
                return;
            E_COUNT[TYPE] = E_COUNT[TYPE] + 1;
    
    def GET_GROUP():
        global INCREMENT_DOWN_STMT, NEXT_CC, INCLUDE_LIST, SRN_COUNT, \
                TPL_REMOTE, INCLUDE_END, INCL_SRN, SRN, RVL, \
                PREV_CARD, COMMENTING, END_GROUP
        nonlocal E_COUNT, S_COUNT, LAST_E_COUNT, LAST_S_COUNT, M_LINE, CP, \
                E_INDICATOR, S_INDICATOR, E_LINE, S_LINE
        # No locals.
        print("In GET_GROUP")
        E_LINE = BLANKS + BLANKS;
        S_LINE = BLANKS + BLANKS;
        LAST_E_COUNT = E_COUNT;
        LAST_S_COUNT = S_COUNT;
        E_COUNT = 0
        S_COUNT = 0;
        if not INCREMENT_DOWN_STMT:
            INCREMENT_DOWN_STMT = (LAST_WRITE <= STMT_PTR);
        OUTPUT_GROUP();
        if INCLUDE_END:
            OUTPUT_WRITER(LAST_WRITE, STMT_PTR);
            OUTPUT(0, X8 + STARS + 'END' + INCLUDE_MSG + STARS);
            NEXT_CC = DOUBLE;
            INCLUDE_LIST = TRUE;
            SRN_COUNT=0;
            if TPL_REMOTE:
                ERROR(CLASS_XI,5);
                TPL_REMOTE = FALSE;
            INCLUDE_END = FALSE;
        goto_LOOP = True;
        goto_READ = False;
        goto_CHECK_ORDER = False;
        goto_COMMENT_CARD = False;
        while goto_LOOP or goto_READ or goto_CHECK_ORDER or goto_COMMENT_CARD:
            if goto_COMMENT_CARD:
                ct = 4
            else:
                if not goto_LOOP:
                    if not goto_CHECK_ORDER:
                        goto_READ = False
                        print("GG A")
                        READ_CARD();
                    goto_CHECK_ORDER = False
                    if not ORDER_OK(PREV_CARD):
                        ERROR(CLASS_M,2);
                        goto_COMMENT_CARD = True
                        continue
                goto_LOOP = False
                print("GG B", END_GROUP, CURRENT_CARD, CARD_TYPE)
                if END_GROUP:
                    break # GO TO FOUND_GROUP
                ct = CARD_TYPE[BYTE(CURRENT_CARD)]
            if ct == 0:
                # CASE 0--DUMMY
               pass
            elif ct == 1:
                # CASE 1--E LINE 
                COMP(0);
                goto_LOOP = True;
                continue
            elif ct == 2:
                # CASE 2--M LINE
                M_LINE = CURRENT_CARD;
                if SRN_PRESENT:
                    if INCLUDING:
                        INCL_SRN = SUBSTR(CURRENT_CARD,TEXT_LIMIT[0]+1);
                        SRN_COUNT = SRN_COUNT + 1;
                    else:
                        SRN=SUBSTR(CURRENT_CARD,TEXT_LIMIT[0]+1);
                        RVL[1] = SUBSTR(SRN,6,2);
                BYTE(SAVE_CARD, BYTE('M'));
                PREV_CARD = BYTE(CURRENT_CARD);
                goto_READ = True;
                continue
            elif ct == 3:
                # CASE 3--S LINE
                COMP(1);
                goto_LOOP = True;
                continue
            elif ct == 4:
                # CASE 4--COMMENT
                if not goto_COMMENT_CARD:
                    BYTE(CURRENT_CARD, 0, BYTE('C'));
                goto_COMMENT_CARD = False
                if PREV_CARD == BYTE('C'):
                    COMMENTING = TRUE;
                else:
                    COMMENTING = FALSE;
                PREV_CARD = BYTE('C');
                '''
                /*----------------------------------------*/
                /* SAVE SRN FIELD FOR NON-INCLUDED SOURCE */
                /* CODE ONLY. (SRN'S OF COMMENTS ARE      */
                /* NOT NEEDED FOR INCLUDED SOURCE CODE)   */
                /*----------------------------------------*/
                '''
                if SRN_PRESENT:
                    if not INCLUDING:
                        SRN=SUBSTR(CURRENT_CARD,TEXT_LIMIT[0]+1);
                        RVL[0] = '';
                        RVL[1] = '';
                        NEXT_CHAR_RVL = '';
                
                PROCESS_COMMENT();
                READ_CARD();
                if INCLUDE_END:
                    OUTPUT(0, X8 + STARS + 'END' + INCLUDE_MSG + STARS);
                    NEXT_CC = DOUBLE;
                    INCLUDE_LIST = TRUE;
                    SRN_COUNT=0;
                    if TPL_REMOTE:
                        ERROR(CLASS_XI,5);
                        TPL_REMOTE = FALSE;
                    INCLUDE_END = FALSE;
                goto_CHECK_ORDER = True;
                continue
            elif ct == 5:
                # CASE 5--DIRECTIVE
                BYTE(CURRENT_CARD, 0, BYTE('D'));
                goto_COMMENT_CARD = True
                continue
        
        # FOUND_GROUP was here!
        END_GROUP = FALSE;
        E_LINE = SUBSTR(E_LINE, 0, LENGTH(M_LINE));
        if E_COUNT <= 0:
            for CP in range(1, TEXT_LIMIT[0]+1):
                E_INDICATOR[CP] = 0;
            E_COUNT = LAST_E_COUNT;
        S_LINE = SUBSTR(S_LINE, 0, LENGTH(M_LINE));
        if S_COUNT <= 0:
            for CP in range(1, TEXT_LIMIT[0]):
                S_INDICATOR[CP] = 0;
            S_COUNT = LAST_S_COUNT;
    
    # Note: From the indenting in the *original* XPL source, we'd infer that
    # the ELSE clause is for the outermost IF.  However, the BNF grammar for
    # XPL implies that it associates with the innermost.  That's also the way
    # I had previously concluded that HAL/S (based on XPL) works.
    def CHOP():
        global INDEX, GROUP_NEEDED
        # No locals.
        INDEX = INDEX + 1;
        if INDEX > TEXT_LIMIT[0]:
            if not INCLUDING or not TEMPLATE_FLAG or \
                    (INCLUDING and TEMPLATE_FLAG and \
                    (INDEX > (TPL_LRECL-1))):
                if (CARD_TYPE(BYTE(CURRENT_CARD)) >= 4) or INCLUDE_END:
                    GROUP_NEEDED = TRUE;
                else:
                   # OUT OF DATA--GET MORE 
                   GET_GROUP();
                   INDEX = 1;
    
    def STACK(TYPE):
        nonlocal E_IND, EP, CHAR_TEMP, E_STACK
        # Local:
        POINT = EP(TYPE) + SHL(TYPE, IND_SHIFT);
        
        goto_NOT_MULTIPLE = False
        if EP(TYPE) < 0:
            goto_NOT_MULTIPLE = True
        if not goto_NOT_MULTIPLE and BYTE(E_LINE(TYPE), INDEX) == BYTE(X1):
            if BYTE(E_STACK(TYPE), EP(TYPE)) == BYTE(X1):
                E_IND(POINT, E_IND(POINT) + 1);
                return
        # NOT_MULTIPLE is here!
        EP(TYPE, EP(TYPE) + 1);
        if EP(TYPE) > IND_LIM:
            if TYPE == 0:
                ERROR(CLASS_ME,1);
            elif TYPE == 1:
                ERROR(CLASS_MS,1);
        POINT = POINT + 1;
        CHAR_TEMP = SUBSTR(E_LINE(TYPE), INDEX, 1);
        if CHAR_TEMP != X1:
            NONBLANK_FOUND = TRUE;
        E_STACK(TYPE, E_STACK(TYPE) + CHAR_TEMP);
        E_IND(POINT, E_INDICATOR(INDEX + SHL(TYPE, IND_SHIFT)));    
    
    def BUILD_XSCRIPTS():
        global S_STACK, E_STACK, S_BLANKS, E_BLANKS, SP, EP, INDEX, \
                GROUP_NEEDED, NONBLANK_FOUND, M_BLANKS
        nonlocal M_LINE
        # No locals.
        S_STACK = ''
        E_STACK = '';
        S_BLANKS = -1
        E_BLANKS = -1;
        SP = -1
        EP = -1;
        goto_CHECK_M = True
        while goto_CHECK_M:
            goto_CHECK_M = False
            if BYTE(M_LINE, INDEX) == BYTE(X1):
                STACK(0);
                STACK(1);
                CHOP();
                if not GROUP_NEEDED:
                    goto_CHECK_M = True
                    continue
            if GROUP_NEEDED:
                if NONBLANK_FOUND:
                    GET_GROUP();
                    INDEX = 1;
                    GROUP_NEEDED = FALSE;
                    goto_CHECK_M = True;
                    continue
        NONBLANK_FOUND = FALSE;
        if BYTE(S_STACK, SP) == BYTE(X1):
            if SP > 0:
                S_STACK = SUBSTR(S_STACK, 0, SP);
            else:
                S_STACK = '';
            S_BLANKS = S_IND(SP);
        if BYTE(E_STACK, EP) == BYTE(X1):
            if EP > 0:
                E_STACK = SUBSTR(E_STACK, 0, EP);
            else:
                E_STACK = '';
            E_BLANKS = E_IND(EP);
        if E_BLANKS >= S_BLANKS:
            M_BLANKS = S_BLANKS;
        else:
            M_BLANKS = E_BLANKS;
    
    def MACRO_DIAGNOSTICS(WHERE):
        # No nonlocals, no locals.
        OUTPUT(0, 'AT '+WHERE+'  NEXT_CHAR='+NEXT_CHAR+'  MACRO_EXPAN_LEVEL=' \
                +MACRO_EXPAN_LEVEL+'  MACRO_TEXT('+MACRO_POINT+')='+ \
                MACRO_TEXT(MACRO_POINT)+'  PARM_REPLACE_PTR('+PARM_EXPAN_LEVEL+\
                ')='+PARM_REPLACE_PTR(PARM_EXPAN_LEVEL));
    
    # STREAM_START was here!
    goto_CHECK_STRING_POSITION = True
    goto_MACRO_DONE = False
    while goto_CHECK_STRING_POSITION:
        goto_CHECK_STRING_POSITION = False
        print("\nA")
        if MACRO_EXPAN_LEVEL > 0:
            OVER_PUNCH = 0;  # FIX ESCAPE BUG WITHIN MACRO 
            if PARM_EXPAN_LEVEL > BASE_PARM_LEVEL(MACRO_EXPAN_LEVEL):
                goto_PARM_DONE = False
                firstTry = True
                while firstTry or goto_PARM_DONE:
                    firstTry = False
                    if not goto_PARM_DONE and PARM_EXPAN_LEVEL>=PARM_EXPAN_LIMIT:
                        ERROR(CLASS_IR,6, 0);
                        MACRO_EXPAN_LEVEL,PARM_EXPAN_LEVEL,MACRO_FOUND=0;
                        goto_MACRO_DONE = True
                    elif not goto_PARM_DONE and \
                            PARM_REPLACE_PTR(PARM_EXPAN_LEVEL) < LENGTH( \
                            MACRO_CALL_PARM_TABLE(PARM_STACK_PTR(PARM_EXPAN_LEVEL))):
                        NEXT_CHAR=BYTE(MACRO_CALL_PARM_TABLE(PARM_STACK_PTR( \
                            PARM_EXPAN_LEVEL)),PARM_REPLACE_PTR(PARM_EXPAN_LEVEL));
                        PARM_REPLACE_PTR(PARM_EXPAN_LEVEL, \
                            PARM_REPLACE_PTR(PARM_EXPAN_LEVEL) + 1) ;
                        if CONTROL(3):
                            MACRO_DIAGNOSTICS(1);
                        debug("a")
                        return;
                    elif goto_PARM_DONE or FIRST_TIME_PARM(PARM_EXPAN_LEVEL):
                        if goto_PARM_DONE or P_CENT(PARM_EXPAN_LEVEL):
                            if not goto_PARM_DONE:
                                P_CENT(PARM_EXPAN_LEVEL, FALSE);
                            goto_PARM_DONE = False 
                            FIRST_TIME_PARM(PARM_EXPAN_LEVEL, TRUE);
                            PARM_EXPAN_LEVEL=PARM_EXPAN_LEVEL-1;
                            goto_CHECK_STRING_POSITION = True
                            continue
                        NEXT_CHAR=BYTE(X1);
                        FIRST_TIME_PARM(PARM_EXPAN_LEVEL, FALSE);
                        if CONTROL(3):
                            MACRO_DIAGNOSTICS(2);
                        debug("b")
                        return;
                    else:
                        goto_PARM_DONE = True
                        continue
            if not goto_MACRO_DONE:
                if MACRO_TEXT(MACRO_POINT) != 0xEF:
                    BLANK_COUNT = 0;
                    if MACRO_TEXT(MACRO_POINT) == 0xEE:
                        MACRO_POINT=MACRO_POINT+1;
                        BLANK_COUNT=MACRO_TEXT(MACRO_POINT);
                        NEXT_CHAR = BYTE(X1);
                    else:
                        NEXT_CHAR=MACRO_TEXT(MACRO_POINT);
                    MACRO_POINT=MACRO_POINT + 1;
                    if CONTROL(3):
                        MACRO_DIAGNOSTICS(3);
                    debug("c")
                    return;
                if FIRST_TIME(MACRO_EXPAN_LEVEL):
                    if not M_CENT(MACRO_EXPAN_LEVEL):
                        FIRST_TIME(MACRO_EXPAN_LEVEL, FALSE);
                        NEXT_CHAR = BYTE(X1);
                        if CONTROL(3):
                            MACRO_DIAGNOSTICS(4);
                        debug("d")
                        return;
                else:
                    FIRST_TIME(MACRO_EXPAN_LEVEL, TRUE);
                TOP_OF_PARM_STACK=TOP_OF_PARM_STACK-NUM_OF_PARM(MACRO_EXPAN_LEVEL);
                PRINTING_ENABLED=M_PRINT(MACRO_EXPAN_LEVEL);
                if not M_CENT(MACRO_EXPAN_LEVEL):
                    if not DONT_SET_WAIT:
                        WAIT = TRUE;
                MACRO_EXPAN_LEVEL = MACRO_EXPAN_LEVEL - 1;
                MACRO_POINT=M_P(MACRO_EXPAN_LEVEL);
                BLANK_COUNT = M_BLANK_COUNT(MACRO_EXPAN_LEVEL);
            if goto_MACRO_DONE or MACRO_EXPAN_LEVEL == 0:
                if not goto_MACRO_DONE:
                    MACRO_FOUND = FALSE ;
                goto_MACRO_DONE = False
                NEXT_CHAR = SAVE_NEXT_CHAR;
                OVER_PUNCH = SAVE_OVER_PUNCH;
                PRINTING_ENABLED=PRINT_FLAG;
                if CONTROL(3):
                    MACRO_DIAGNOSTICS(5);
                debug("e")
                return;
            else:
                goto_CHECK_STRING_POSITION = True
                continue
    
    print("B", II, RETURN_CHAR, ARROW_FLAG)
    BLANK_COUNT = -1;
    goto_STACK_CHECK = True
    while goto_STACK_CHECK:
        goto_STACK_CHECK = False
        for II in range(II, 3):
            print("C", II, RETURN_CHAR[II])
            if RETURN_CHAR[II] != 0:
                ARROW_FLAG = TRUE;
                RETURN_CHAR[II] = RETURN_CHAR[II] - 1;
                NEXT_CHAR = TYPE_CHAR(II);
                OVER_PUNCH = 0;
                debug("f")
                return;
        II = 0;
        print("D", ARROW_FLAG, GROUP_NEEDED)
        if ARROW_FLAG:
            ARROW_FLAG = FALSE;
            NEXT_CHAR = SAVE_NEXT_CHAR1;
            OVER_PUNCH = SAVE_OVER_PUNCH1;
            BLANK_COUNT = SAVE_BLANK_COUNT1;
            debug("g")
            return;
        if GROUP_NEEDED:
            GET_GROUP();
            INDEX = 1;
            GROUP_NEEDED = FALSE;
        goto_BEGINNING = True
        while goto_BEGINNING:
            goto_BEGINNING = False
            if RETURNING_M:
                if M_BLANKS >= 0:
                    NEXT_CHAR = BYTE(X1);
                    ARROW = -LAST_E_IND;
                    LAST_E_IND = 0;
                    BLANK_COUNT = M_BLANKS;
                    M_BLANKS = -1;
                    break # GO TO FOUND_CHAR;
                if BYTE(M_LINE, INDEX) != BYTE(X1):
                    if E_COUNT > 0:
                        if BYTE(E_LINE, INDEX) != BYTE(X1):
                           if E_INDICATOR(INDEX) != 1:
                               ERROR(CLASS_ME,3);
                           else:
                               OVER_PUNCH = BYTE(E_LINE, INDEX);
                        else:
                           OVER_PUNCH = 0;
                    else:
                        OVER_PUNCH = 0;
                    if S_COUNT > 0:
                        if BYTE(S_LINE, INDEX) != BYTE(X1):
                            ERROR(CLASS_MS,3);
                    ARROW = -LAST_E_IND;
                    LAST_E_IND = 0;
                    if not INCLUDING:
                        '''
                        /*CHECK THE RVL FOR EACH CHARACTER AS IT IS READ.  RVL WILL */
                        /*HOLD THE MOST RECENT RVL ASSOCIATED WITH A TOKEN.         */
                        '''
                        if STRING_GT(NEXT_CHAR_RVL,RVL):
                            RVL = NEXT_CHAR_RVL;
                        NEXT_CHAR_RVL = RVL(1);
                    NEXT_CHAR = BYTE(M_LINE, INDEX);
                    CHOP();
                    break # GO TO FOUND_CHAR;
                else:
                    BUILD_XSCRIPTS();
                    OVER_PUNCH = 0;
                    RETURNING_M = FALSE;
                    LAST_S_IND = 0;
                    RETURNING_S = TRUE;
                    PNTR = 0;
            if RETURNING_S:
                if LENGTH(S_STACK) > 0 and PNTR < LENGTH(S_STACK):
                    if BYTE(S_STACK, PNTR) == BYTE(X1):
                        if S_IND(PNTR) >= 0: # MORE LEFT
                            NEXT_CHAR = BYTE(X1);
                            BLANK_COUNT = S_IND(PNTR);
                            PNTR = PNTR + 1;
                            ARROW = LAST_S_IND - S_IND(PNTR);
                            LAST_S_IND = S_IND(PNTR);
                    else:   # A NON-BLANK
                        NEXT_CHAR = BYTE(S_STACK, PNTR);
                        ARROW = LAST_S_IND - S_IND(PNTR);
                        LAST_S_IND = S_IND(PNTR);
                        PNTR = PNTR + 1;
                    break # GO TO FOUND_CHAR;
                else:    # CAN'T RETURN S 
                    RETURNING_S = FALSE;
                    RETURNING_E = TRUE;
                    LAST_E_IND = -LAST_S_IND;
                    PNTR = 0;
            if RETURNING_E:
                if LENGTH(E_STACK) > 0 and PNTR < LENGTH(E_STACK):
                    if BYTE(E_STACK, PNTR) == BYTE(X1):
                        if E_IND(PNTR) >= 0: # MORE TO GO
                            NEXT_CHAR = BYTE(X1);
                            BLANK_COUNT = E_IND(PNTR);
                            PNTR = PNTR + 1;
                            ARROW = E_IND(PNTR) - LAST_E_IND;
                            LAST_E_IND = E_IND(PNTR);
                    else: # A NON-BLANK
                        NEXT_CHAR = BYTE(E_STACK, PNTR);
                        ARROW = E_IND(PNTR) - LAST_E_IND;
                        LAST_E_IND = E_IND(PNTR);
                        PNTR = PNTR + 1;
                    break # GO TO FOUND_CHAR;
                else: # CAN'T RETURN E 
                    RETURNING_E = FALSE;
                    RETURNING_M = TRUE;
            goto_BEGINNING = True
            continue
        # FOUND_CHAR was here!
        if ARROW != 0:
            OLD_LEVEL = NEW_LEVEL;
            NEW_LEVEL = NEW_LEVEL + ARROW;
            SAVE_OVER_PUNCH1 = OVER_PUNCH;
            SAVE_NEXT_CHAR1 = NEXT_CHAR;
            SAVE_BLANK_COUNT1 = BLANK_COUNT;
            goto_EXPONENT = False
            goto_SUBS = False
            firstTry = True
            while firstTry or goto_EXPONENT or goto_SUBS:
                firstTry = False
                if not goto_SUBS and (goto_EXPONENT or OLD_LEVEL > 0):
                    if not goto_EXPONENT and ARROW < 0:
                        STACK_RETURN_CHAR(-ARROW, BYTE(')'));
                    else:
                        goto_EXPONENT = False
                        if ARROW > 1:
                            ERROR(CLASS_ME,2);
                        STACK_RETURN_CHAR(2, BYTE('*'));
                        STACK_RETURN_CHAR(ARROW, BYTE('('));
                elif goto_SUBS or OLD_LEVEL == 0:
                    if goto_SUBS or ARROW < 0:
                        goto_SUBS = False
                        if ARROW < -1:
                            ERROR(CLASS_MS,2);
                        STACK_RETURN_CHAR(1, BYTE('$'));
                        STACK_RETURN_CHAR(-ARROW, BYTE('('));
                    else:
                        goto_EXPONENT = True
                        continue
                else: # OLD < 0
                    if ARROW < 0:
                        goto_SUBS = True
                        continue
                    if NEW_LEVEL <= 0:
                        STACK_RETURN_CHAR(ARROW, BYTE(')'));
                    else:
                        STACK_RETURN_CHAR(-OLD_LEVEL, BYTE(')'));
                        if NEW_LEVEL > 1:
                            ERROR(CLASS_ME,2);
                        STACK_RETURN_CHAR(2, BYTE('*'));
                        STACK_RETURN_CHAR(NEW_LEVEL, BYTE('('));
            ARROW = 0;
            goto_STACK_CHECK = True
            continue
    debug("h")
    return;
