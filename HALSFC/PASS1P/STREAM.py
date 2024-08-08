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
            2024-06-20 RSB  Stuff related to `D DOWNGRADE`
            
Note that the original of this file was pretty spaghetti-like.  Refer to the
notes concerning goto_XXXX in SCAN.xpl for an explanation of the workaround
technique.
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
import HALINCL.COMMON as h
import HALINCL.SPACELIB as s
import HALINCL.DWNTABLE as t
from CHARINDE import CHAR_INDEX
from ERROR    import ERROR
from ERRORS   import ERRORS
from NEXTRECO import NEXT_RECORD
from ORDEROK  import ORDER_OK
from OUTPUTGR import OUTPUT_GROUP
from OUTPUTWR import OUTPUT_WRITER
from PAD      import PAD
from SAVEINPU import SAVE_INPUT

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


# Persistent local variables for various procedures.
class cSTREAM:

    def __init__(self):
        self.BLANKS = '                                            ';
        self.M_LINE = '';
        ''' THE FOLLOWING DECLARE MUST BE IN THE EXACT ORDER STATED. ITS USE IS
        DEPENDENT UPON THE MEMORY LOCATIONS ASSIGNED TO CONTIGUOUSLY
        DECLARED CHARACTER STRING DESCRIPTORS WHICH IS CURRENTLY
        PRESUMED TO BE IN ASCENDING LOCATIONS '''
        # The comment above sounds bad ... *really* bad.  It appears to me to
        # mean the following:  It expects several of these Exxx variables to be 
        # immediately succeeded in memory by the corresponding Sxxx variables. 
        # Specifically, it's referring to the pairs:
        #        (E_LINE,S_LINE), 
        #        (E_STACK,S_STACK)
        #        (EP,SP)
        #        (E_IND, S_IND)
        #        (E_INDICATOR, S_INDICATOR)
        # Consider EP,EP, for example.  Even though EP is defined as a scalar rather
        # than as an array, the original coders seemed to have the expectation that
        # they could address EP as EP(0) and SP as EP(1).  There is no provision in
        # XPL for doing using this, as far as I can see.  The case of E_INDICATOR
        # is even more tricky, because some (E_IND etc.) are defined a 128-element
        # arrays, so the expectation is that S_IND[0] is the same thing as 
        # E_IND[128], and so on.  For some of these pairs (E_IND,S_IND), the
        # additional expectation is that negative indices can be used with Sxxx(i)
        # to access Exxx(i+128).  I'll refrain from further editorial comments 
        # on this matter, as tempted as I am to make some pithy remarks I may 
        # regret later.
        self.E_LINE = ""
        self.S_LINE = ""
        self.E_STACK = ""
        self.S_STACK = ""
        ''' THE EOF SYMBOL IS A HEX'FE'. IT IS CREATED BY A 12-11-0-6-8-9
            MULTIPLE PUNCH ON A CARD.
            THE FORMAT OF INPUT_PAD IS:
                      'M XY YX Z Z '' Z Z " Z Z'
            WHERE X IS A "/", Y IS A "*", AND Z IS THE EOF SYMBOL '''
        # Note that ASCII '\x04' is transparently converted back and forth with
        # the numerical code 0xFE by the BYTE() built-in function.
        self.INPUT_PAD = 'M /**/ \x04 \x04 \'\' \x04 \x04 " \x04 \x04';
        self.LAST_E_IND = 0
        self.LAST_S_IND = 0
        self.E_BLANKS = 0
        self.S_BLANKS = 0
        self.EP = 0
        self.SP = 0
        self.M_BLANKS = -1
        self.IND_LIM = 127
        self.IND_SHIFT = 7
        self.E_IND = [0] * (self.IND_LIM + 1)
        self.S_IND = [0] * (self.IND_LIM + 1)
        self.E_INDICATOR = [0] * (self.IND_LIM + 1)
        self.S_INDICATOR = [0] * (self.IND_LIM + 1)
        self.E_COUNT = 0
        self.S_COUNT = 0
        self.LAST_E_COUNT = 0
        self.LAST_S_COUNT = 0
        self.PNTR = 0
        self.CP = 0
        self.FILL = 0
        self.INDEX = 1
        self.RETURNING_M = g.TRUE
        self.RETURNING_S = 0
        self.RETURNING_E = 0
        self.PREV_CARD = 0
        self.CHAR_TEMP = ''
        self.RETURN_CHAR = [0] * 3
        self.TYPE_CHAR = [0] * 3
        self.ARROW_FLAG = 0
        self.ARROW = 0
        self.II = 0
        self.SAVE_OVER_PUNCH1 = 0
        self.SAVE_NEXT_CHAR1 = 0
        self.SAVE_BLANK_COUNT1 = 0
        self.I = 0
        self.L = 0
        # The following were originally local to STREAM(), but I've moved them
        # to the globals in g.py.
        # self.CREATING = 0
        # self.TEMPLATE_FLAG = 0
        # INCLUDE CELL FLAG BITS
        # self.INCL_TEMPLATE_FLAG = 0x02
        # self.INCL_REMOTE_FLAG = 0x01
        # The following were originally local to STREAM(), but I've changed 
        # them to be globals of the DTOKEN module.
        # D TOKEN GLOBALS
        # self.D_INDEX = 0
        # self.D_CONTINUATION_OK = g.FALSE


lSTREAM = cSTREAM()


class cPROCESS_COMMENT:  # Locals specific to PROCESS_COMMENT()

    def __init__(self):
        self.NEXT_DIR = [''] * 2;
        self.TMP_INCREMENT = 0;
        self.PRINT_FLAG = 0;
        self.I = 0;
        self.RECORD_NOT_WRITTEN = 0;
        self.LIST_FLAG = 0;
        self.C = [''] * 2
        self.XC = 'C';
        self.INCLUDE_DIR = 'INCLUDE';
        self.START = 'START';
        self.EJECT_DIR = 'EJECT';
        self.SPACE_DIR = 'SPACE';
        self.TOGGLES = '0123456789ABCDEFG';


lPROCESS_COMMENT = cPROCESS_COMMENT()
    

def STREAM():
    l = lSTREAM  # Local variables for STREAM procedure.
    
    # Workarounds for undocumented interactions between Exxx and Sxxx variables.
    def e_line(p=0, value=None):
        if p not in [0, 1]:
            print("Implementation error E_LINE/S_LINE")
            sys.exit(1)
        if value == None:
            if p == 0:
                return l.E_LINE
            else:
                return l.S_LINE
        if p == 0:
            l.E_LINE = value
        else:
            l.S_LINE = value

    def e_count(p=0, value=None):
        if p not in [0, 1]:
            print("Implementation error E_COUNT/S_COUNT")
            sys.exit(1)
        if value == None:
            if p == 0:
                return l.E_COUNT
            else:
                return l.S_COUNT
        if p == 0:
            l.E_COUNT = value
        else:
            l.S_COUNT = value

    def e_stack(p=0, value=None):
        if p not in [0, 1]:
            print("Implementation error E_STACK/S_STACK")
            sys.exit(1)
        if value == None:
            if p == 0:
                return l.E_STACK
            else:
                return l.S_STACK
        if p == 0:
            l.E_STACK = value
        else:
            l.S_STACK = value

    def ep(p=0, value=None):
        if p not in [0, 1]:
            print("Implementation error EP/SP")
            sys.exit(1)
        if value == None:
            if p == 0:
                return l.EP
            else:
                return l.SP
        if p == 0:
            l.EP = value
        else:
            l.SP = value

    def e_ind(index=0, value=None):
        if index < 0 or index >= len(l.E_IND) + len(l.S_IND):
            print("Implementation error E_IND/S_IND")
            sys.exit(1)
        if value == None:
            if index < len(l.E_IND):
                return l.E_IND[index]
            else:
                return l.S_IND[index - len(l.E_IND)]
        if index < len(l.E_IND):
            l.E_IND[index] = value
        else:
            l.S_IND[index - len(l.E_IND)] = value

    def s_ind(index=0, value=None):
        if index < -len(l.E_IND) or index >= len(l.S_IND):
            print("Implementation error E_IND/S_IND")
            sys.exit(1)
        if value == None:
            if index < 0:
                return l.E_IND[index + len(l.E_IND)]
            else:
                return l.S_IND[index]
        if index < 0:
            l.E_IND[index + len(l.E_IND)] = value
        else:
            l.S_IND[index] = value

    def e_indicator(index=0, value=None):
        if index < 0 or index >= len(l.E_INDICATOR) + len(l.S_INDICATOR):
            print("Implementation error E_INDICATOR/S_INDICATOR")
            sys.exit(1)
        if value == None:
            if index < len(l.E_INDICATOR):
                return l.E_INDICATOR[index]
            else:
                return l.S_INDICATOR[index - len(l.E_INDICATOR)]
        if index < len(l.E_INDICATOR):
            l.E_INDICATOR[index] = value
        else:
            l.S_INDICATOR[index - len(l.E_INDICATOR)] = value

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
    is *not* standard XPL, and therefore is presumably something 
    specific to Intermetrics's version of XPL.  I believe that these are all
    "include" directives, in which the form
        /* $%module - procedure */
    includes a specific PROCEDURE from a given module, while the form
        /%INCLUDE module %/
    simply includes an entire module.
    
    As for why you'd want to do that, consider the D_TOKEN() function.
    
    The D_TOKEN() function makes use of the D_INDEX and D_CONTINUATION_OK 
    local variables of SEARCH(), which (since the source code for D_TOKEN 
    is a separate module not ordinarily local to SEARCH) it would 
    otherwise have no knowledge of.  The trick above would seem to
    be that by making procedure D_TOKEN internal to procedure SEARCH,
    it gains the necessary access to SEARCH's local variables.
    But it makes the D_TOKEN() procedure invisible to any other 
    global procedure that would want to call it.  The only other 
    procedure calling D_TOKEN is INCLUDE_OK() from the PATCHINC
    module, so PATCHINC is also embedded in SEARCH.  
        
    D_TOKEN calls PRINT_COMMENT() (in PRINTCOM), but I'm not sure as of 
    yet why that means PRINT_COMMENT has to be embedded here, and perhaps
    I'll come back to that issue later. 
    Later ... PRINT_COMMENT() needs to be included here specifically because
    it need to use the local variable `I` from `STREAM`, whereas otherwise
    it would be using the global variable `I`, which would mess up pagination
    in the procedure `PRINT2`.  There may be other reasons as well.
        
    As for the inclusion of INCSDF, its PROCEDURE INCLUDE_SDF() is similar 
    to D_TOKEN(), in that it accesses (and modifies) D_CONTINUATION_OK, so
    it is made local to SEARCH for the same reason.  

    I handle the D_INDEX/D_CONTINUATION_OK problem somewhat similarly.
    See the Python "import" statements below and the comments in the 
    DTOKEN module.
    ***
    
    '''
    from HALINCL.PRINTCOM import PRINT_COMMENT
    import HALINCL.DTOKEN as hd
    # from HALINCL.INCSDF import *
    from HALINCL.PATCHINC import INCLUDE_OK
    
    # Note: Handling the ERRPRINT label and its GO TOs from the original XPL
    # code in the manner I've typically being using (i.e., with a boolean
    # variable called goto_ERRPRINT) would complicate the following code
    # considerably.  However, ERRPRINT is basically an error exit, which lets
    # us use a much simpler approach: namely, replacing each GO TO ERRPRINT by 
    # a call to a new function(ERRPRINT) followed by an immediate return from 
    # PROCESS_COMMENT().
    
    def PROCESS_COMMENT(): 
        ll = lPROCESS_COMMENT  # Locals specific to PROCESS_COMMENT().

        def ERRPRINT():
            OUTPUT_WRITER();  # PRINT ANY ERRORS
            if not g.INCLUDING:
                g.INCLUDE_STMT = -1;

        def CHAR_VALUE(STR):
            g.K = 0
            g.J = 0;
            g.VAL = 0;
            while g.J < LENGTH(STR):
                g.K = BYTE(STR, g.J);
                if (g.K >= BYTE('0')) and (g.K <= BYTE('9')):
                    g.VAL = g.VAL * 10 + (g.K - BYTE('0'));
                g.J = g.J + 1;
            return g.VAL;

        if BYTE(g.CURRENT_CARD) == BYTE('C'):
            PRINT_COMMENT(g.TRUE, l);
        elif BYTE(g.CURRENT_CARD) == BYTE('D'):
            # A DIRECTIVE CARD 
            hd.D_INDEX = 1;
            ll.C[0] = hd.D_TOKEN();
            if (ll.C[0] == ll.EJECT_DIR) or (ll.C[0] == ll.SPACE_DIR):
                PRINT_COMMENT(g.FALSE, l);
                if ll.C[0] == ll.EJECT_DIR:
                    if not g.PAGE_THROWN or g.LOOKED_RECORD_AHEAD != 0:
                        g.LOOKED_RECORD_AHEAD = 0;
                        g.PAGE_THROWN = g.TRUE;
                else:  # SPACE DIRECTIVE 
                    ll.C[0] = hd.D_TOKEN();
                    if LENGTH(ll.C[0]) == 0:
                        g.J = 1;  # 1 SPACE
                    else:
                        g.J = BYTE(ll.C[1]);
                        if CHARTYPE(g.J) != 1:
                            g.J = 1;  # ASSUME ONE SPACE
                        else:
                            g.J = g.J & 0xF;
                        if g.J > 3:
                            g.J = 3;
                    if g.LOOKED_RECORD_AHEAD == 0:
                        g.LOOKED_RECORD_AHEAD = LINE_LIM;
                        EJECT_PAGE();
                    if lc.LINE_COUNT + g.J > g.LOOKED_RECORD_AHEAD:
                        g.LOOKED_RECORD_AHEAD = 0;
                    else:
                        for ll.I in range(1, g.J + 1):
                            OUTPUT(0, g.X1);
                return;
            PRINT_COMMENT(g.TRUE, l, ll.C[0]);
            if (ll.C[0] == 'EB') or (ll.C[0] == 'EBUG'):  # DEBUG DIRECTIVE
                
                ll.C[0] = hd.D_TOKEN();
                while LENGTH(ll.C[0]) != 0:
                    if SUBSTR(ll.C[0], 0, 2) == 'H(':
                        g.SMRK_FLAG = CHAR_VALUE(ll.C[0]);
                    else:  # ADD NEW DEBUG TYPES HERE
                        pass;
                    ll.C[0] = hd.D_TOKEN();
                for ll.I in range(1, g.TEXT_LIMIT[0]):
                    # See section 2.2.7 (PDF p. 40) of "HAL/S-FC & HAL/S-360
                    # Compiler System Program Description".
                    if BYTE(g.CURRENT_CARD, ll.I) == BYTE('`'):
                        g.J = CHAR_INDEX(ll.TOGGLES, \
                                         SUBSTR(g.CURRENT_CARD, ll.I + 1, 1));
                        if g.J > -1:
                            goto_COMPLEMENT = False
                            if ll.I < g.TEXT_LIMIT[0] - 1:
                                g.K = BYTE(g.CURRENT_CARD, ll.I + 2);
                            else:
                                goto_COMPLEMENT = True;
                            if g.K == BYTE('+') and not goto_COMPLEMENT:
                                g.CONTROL[g.J] = 0xFF;
                            elif g.K == BYTE('-') and not goto_COMPLEMENT:
                                g.CONTROL[g.J] = g.FALSE;
                            else:
                                goto_COMPLEMENT = False
                                g.CONTROL[g.J] = not g.CONTROL[g.J];
                            if g.J == 0x0D:
                                g.INCLUDE_LIST2 = g.CONTROL[g.J];
                                g.INCLUDE_LIST = g.INCLUDE_LIST2
                        if g.CONTROL[0x0A]:
                            EXIT();
            # END OF DEBUG DIRECTIVE
            elif ll.C[0] == 'DEVICE':
                ll.C[0] = hd.D_TOKEN();
                goto_NO_CHAN = False
                firstTry = True
                while firstTry or goto_NO_CHAN:
                    firstTry = False
                    if LENGTH(ll.C[0]) == 0 or goto_NO_CHAN:
                        goto_NO_CHAN = False          
                        ERROR(d.CLASS_XD, 3);
                        ERRPRINT()
                        return
                    ll.I = CHAR_INDEX(ll.C[0], 'CHANNEL=');
                    if ll.I != 0:
                        goto_NO_CHAN = True;
                        continue
                    g.J = 0;
                    ll.I = 8
                    for ll.I in range(8, LENGTH(ll.C[0])):
                        g.K = BYTE(ll.C[0], ll.I);
                        if CHARTYPE(g.K) != 1:
                            goto_NO_CHAN = True;
                            continue;
                        g.J = g.J * 10 + (g.K & 0xF);
                    if ll.I == 8:
                        goto_NO_CHAN = True;
                        continue
                if g.J > 9:
                    ERROR(d.CLASS_XD, 4);
                    ERRPRINT()
                    return
                ll.C[0] = hd.D_TOKEN();
                ll.PRINT_FLAG = g.FALSE;
                l.L = g.J(g.J);
                if ll.C[0] == 'UNPAGED':
                    pass
                elif ll.C[0] == 'PAGED':
                    ll.PRINT_FLAG = g.TRUE;
                elif ll.C[0] != '':
                    l.L = l.L | 0x20;
                    ERROR(d.CLASS_XD, 1);
                goto_D_DONE = False
                if (l.L & 0x40) != 0:
                    ERROR(d.CLASS_XD, 2);
                    goto_D_DONE = True
                if not goto_D_DONE:
                    if l.L == 0:
                        l.L = 0x50;  # DIRECTIVE FOUND AND UNUSED FLAGS
                    else:
                        l.L = l.L | 0x40;  # DIRECTIVE FOUND 
                    if (l.L & 0x28) != 0:
                        goto_D_DONE = True;  # ERRORS ALREADY EXIST FOR THIS CHANNEL
                    if not goto_D_DONE:
                        if ll.PRINT_FLAG:
                            if (l.L & 0x03) != 0:
                                l.L = l.L | 0x08;  # CONFLICT FLAG
                                goto_D_DONE = True;
                            if not goto_D_DONE:
                                l.L = l.L | 0x04;  # PRINT FLAG
                        else:
                            l.L = (l.L & 0xFB) | 0x03;  # PRINT OFF, READ/WRITE ON
                goto_D_DONE = False
                g.J[g.J] = l.L;
                ERRPRINT()
                return
            elif ll.C[0] == ll.INCLUDE_DIR:
                # AN INCLUDE DIRECTIVE
                if INCLUDE_OK():
                    OUTPUT(0, g.X8 + g.STARS + ll.START + g.INCLUDE_MSG + g.STARS);
            # END OF INCLUDE DIRECTIVE
            elif ll.C[0] == 'VERSION':
                if g.TPL_VERSION > 0:
                    ll.I = int(g.CURRENT_CARD[hd.D_INDEX + 1:]);
                    #ll.I = int(g.CURRENT_CARD[hd.D_INDEX + 1:], 16)
                    #print("***DEBUG***", g.CURRENT_CARD, ll.I, file=sys.stderr)
                    g.SYT_LOCKp(g.TPL_VERSION, ll.I);
                    g.TPL_VERSION = 0;
            elif ll.C[0] == 'DOWNGRADE' or ll.C[0] == 'OWNGRADE':  # DOWNGRADE
                g.TEMP_CLS = ''
                g.ULT_TEMP_CLS = ''
                g.FIN_TMP_CLS = ''
                g.TEMP_COUNT = 0
                g.CONTINUE = 0;
                ll.C[0] = hd.D_TOKEN();
                if LENGTH(ll.C[0]) == 0:  # NO ERROR NUMBER TO DOWNGRADE 
                    ERRORS(d.CLASS_BI, 108);
                elif g.DOWN_COUNT > h.DOWNGRADE_LIMIT:  # OBTAIN CLASS
                    '''
                    /* IN ORDER TO COMPLETELY REMOVE THE LIMIT ON THE NUMBER OF          */
                    /* ALLOWABLE DOWNGRADES JUST REMOVE THIS IF STATEMENT AND   */
                    /* CALL TO ERRORS. SUBSEQUENTLY THE ELSE DO AND CORRESPONDING END    */
                    /* STATEMENTS MUST ALSO THEN BE REMOVED.                             */
                    /* CHECK TO SEE IF EXCEEDED DOWNGRADE_LIMIT */
                    '''
                    ERRORS (d.CLASS_BI, 109);
                else:
                    s.NEXT_ELEMENT(h.DOWN_INFO);
                    g.DOWN_COUNT = g.DOWN_COUNT + 1;
                    for ll.I in range(0, 2):
                       g.TEMP_CLS = SUBSTR(ll.C[0], 0, ll.I + 1);
                       g.ULT_TEMP_CLS = SUBSTR(g.TEMP_CLS, ll.I, ll.I);
                       if g.ULT_TEMP_CLS >= '0' and g.ULT_TEMP_CLS <= '9':
                          g.CONTINUE = 1;
                       if g.CONTINUE == 0:  # GET CLASS
                          g.ULT_TEMP_CLS = PAD('CLASS_' + g.TEMP_CLS, 8);
                          g.FIN_TMP_CLS = SUBSTR(g.X1 + g.ULT_TEMP_CLS, 1);
                       # END DETERMINE CLASS
                    # END OF ELSE FOR CLASS
                    '''
                    /* CHECK THE NEXT STATEMENT TO SEE IF DOWNGRADING A DIRECTIVE     */
                    /* OR A STATEMENT  IF THE NEXT STATEMENT IS A DIRECTIVE, THEN     */
                    /* SET INCREMENT_DOWN_STMT TO FALSE.                              */
                    '''
                    ll.TMP_INCREMENT = g.INCREMENT_DOWN_STMT;
                    NEXT_RECORD();
                    g.LOOKED_RECORD_AHEAD = g.TRUE;
                    if g.CARD_TYPE[BYTE(g.CURRENT_CARD)] == g.CARD_TYPE[BYTE('D')]:
                        hd.D_INDEX = 1;
                        ll.NEXT_DIR = hd.D_TOKEN();
                        if ll.NEXT_DIR != 'DOWNGRADE' and ll.NEXT_DIR != 'OWNGRADE':
                            g.INCREMENT_DOWN_STMT = g.FALSE;
                    # ATTACH DOWNGRADE TO CORRECT STATEMENT
                    if g.INCREMENT_DOWN_STMT and TOKEN == SEMI_COLON:
                        g.DWN_STMT(g.DOWN_COUNT, SUBSTR(g.X1 + str(g.STMT_NUM() + 1), 1));
                    else:
                        g.DWN_STMT(g.DOWN_COUNT, SUBSTR(g.X1 + str(g.STMT_NUM()), 1));
                    g.INCREMENT_DOWN_STMT = ll.TMP_INCREMENT;
                    g.TEMP_CLS = CHAR_VALUE(ll.C[0]);
                    g.DWN_ERR(g.DOWN_COUNT, SUBSTR(g.X1 + str(g.TEMP_CLS), 1));
                    g.CONTINUE = 1;
                    g.TEMP_COUNT = 0;
                    while g.CONTINUE == 1 and g.TEMP_COUNT <= t.NUM_ERR:
                        if g.FIN_TMP_CLS == t.ERROR_INDEX[g.TEMP_COUNT]:
                            g.DWN_CLS(g.DOWN_COUNT, t.ERR_VALUE[g.TEMP_COUNT]);
                            g.CONTINUE = 0;
                        else:
                            g.TEMP_COUNT = g.TEMP_COUNT + 1;
                    if g.CONTINUE == 1:  # ERROR CLASS NOT FOUND
                        '''
                        /* SAVE THE ERROR NUMBER LOCATED IN 'C' INTO 'DWN_UNKN'. CODE IN     */
                        /* DOWNGRADE_SUMMARY WILL USE THIS INFO TO BUILD A DOWNGRADE SUMMARY */
                        /* REPORT INSTEAD OF USING 'DWN_CLS' TO FIND THE ERROR CLASS (THERE  */
                        /* IS NO INFORMATION TO PUT INFO 'DWN_CLS' SINCE THE ERROR CLASS DOES*/
                        /* NOT EXIST).                                                       */
                        '''
                        g.DWN_UNKN(g.DOWN_COUNT, ll.C[0]);
                        ERRORS (d.CLASS_BI, 107);
            # END OF DOWNGRADE
            elif ll.C[0] == 'PROGRAM':
                if g.BLOCK_MODE[0] != 0:
                    ERROR(d.CLASS_XA, 3);
                    ERRPRINT()
                    return
                if LENGTH(g.PROGRAM_ID) > 0:
                    ERROR(d.CLASS_XA, 1);
                    ERRPRINT()
                    return
                ll.C[0] = hd.D_TOKEN();
                goto_NO_ID = False
                firstTry = True
                while firstTry or goto_NO_ID:
                    firstTry = False
                    if goto_NO_ID or LENGTH(ll.C[0]) == 0:
                        goto_NO_ID = False
                        ERROR(d.CLASS_XA, 2);
                        ERRPRINT()
                        return
                    ll.I = CHAR_INDEX(ll.C[0], 'ID=');
                    if ll.I != 0:
                        goto_NO_ID = True;
                        continue
                    if LENGTH(ll.C[0]) <= 3:
                        goto_NO_ID = True;
                        continue
                if LENGTH(ll.C[0]) >= 11:
                    g.PROGRAM_ID = SUBSTR(ll.C[0], 3, 8);
                else:
                    g.PROGRAM_ID = PAD(SUBSTR(ll.C[0], 3), 8);
                INTERPRET_ACCESS_FILE();
            elif ll.C[0] == 'DEFINE':
                
                def COPY_TO_8():
                    PRINT_COMMENT(ll.LIST_FLAG, l);
                    OUTPUT(8, g.CURRENT_CARD);
                    ll.RECORD_NOT_WRITTEN = g.FALSE;
                    MONITOR(16, 0x10);
                
                ll.C[1] = hd.D_TOKEN();
                if LENGTH(ll.C[1]) == 0:
                    ERROR(d.CLASS_XD, 5);
                elif LENGTH(ll.C[1]) >= 8:
                    ll.C[1] = SUBSTR(ll.C[1], 0, 8);
                else:
                    ll.C[1] = PAD(ll.C[1], 8);
                ll.C[0] = hd.D_TOKEN();
                if LENGTH(ll.C[0]) > 0:
                    ll.LIST_FLAG = (ll.C[0] == 'LIST');
                else:
                    ll.LIST_FLAG = g.FALSE;
                ll.RECORD_NOT_WRITTEN = g.TRUE;
                if g.INCLUDING:
                    ERROR(d.CLASS_XD, 8);
                else:
                    g.CREATING = g.TRUE;
                while g.CREATING:
                    NEXT_RECORD();
                    if LENGTH(g.CURRENT_CARD) == 0:
                        if g.INCLUDING:
                            g.INPUT_DEV = 0;
                            g.INCLUDING = g.FALSE
                            g.INCLUDE_COMPRESSED = g.FALSE;
                            g.INCLUDE_LIST = g.TRUE;
                            g.INCLUDE_LIST2 = g.TRUE;
                            OUTPUT(8, ll.XC + g.STARS + 'END' + g.INCLUDE_MSG + g.STARS);
                            g.INCLUDE_OFFSET = \
                                g.INCLUDE_COUNT + g.CARD_COUNT + 1 - g.INCLUDE_OFFSET;
                            g.INCLUDE_COUNT = g.INCLUDE_OFFSET
                        else:
                            g.CREATING = g.FALSE;
                            g.END_OF_INPUT = g.TRUE;
                            g.CURRENT_CARD = l.INPUT_PAD + X70;
                            pass
                    else:
                        g.CARD_COUNT = g.CARD_COUNT + 1;
                        if g.CARD_TYPE[BYTE(g.CURRENT_CARD)] == g.CARD_TYPE[BYTE('D')]:
                            hd.D_INDEX = 1;
                            ll.C[0] = hd.D_TOKEN();
                            if ll.C[0] == ll.INCLUDE_DIR:
                                g.CURRENT_CARD = BYTE(g.CURRENT_CARD, 0, BYTE('C'));
                                COPY_TO_8();
                                if INCLUDE_OK():
                                    OUTPUT(8, ll.XC + g.STARS + ll.START + g.INCLUDE_MSG + g.STARS);
                            elif ll.C[0] == 'CLOSE':  # END OF INLINE BLOCK
                                PRINT_COMMENT(g.TRUE, l);
                                ll.C[0] = hd.D_TOKEN();
                                if LENGTH(ll.C[0]) >= 8:
                                    ll.C[0] = SUBSTR(ll.C[0], 0, 8);
                                else:
                                    ll.C[0] = PAD(ll.C[0], 8);
                                if ll.C[0] != ll.C[1]:
                                    ERROR(d.CLASS_XD, 6, ll.C[0]);
                                if ll.RECORD_NOT_WRITTEN:
                                    ERROR(d.CLASS_XD, 7);
                                elif LENGTH(ll.C[1]) > 0:
                                    if MONITOR(1, 8, ll.C[1]):  # STOW THE MEMBER
                                        ERROR(d.CLASS_XD, 9, ll.C[1]);
                                g.CREATING = g.FALSE;
                            else:
                                COPY_TO_8();
                        else:
                            COPY_TO_8();
                # END WHILE CREATING
            # IN THIS SECTION OF CODE,WE LOOK FOR THE DATA_REMOTE DIRECTIVE
            elif ll.C[0] == 'DATA_REMOTE' or ll.C[0] == 'ATA_REMOTE':  # REMOTE #D
                g.DATA_REMOTE = g.TRUE;
                if g.pfs:
                    # CHECK FOR ILLEGAL LOCATION OF THE DIRECTIVE
                    if g.BLOCK_MODE[0] != 0:
                        ERRORS(d.CLASS_XR, 1);
                    # PART2 -- CHECK FOR ILLEGAL LOCATION OF
                    # THE DIRECTIVE INSIDE AN EXTERNAL BLOCK.
                    if ((SYT_FLAGS(g.BLOCK_SYTREF[g.NEST]) & EXTERNAL_FLAG) != 0):
                        ERRORS(d.CLASS_XR, 1);
            # END DATA_REMOTE
            
            #-----------------------------------------------------------------
            else:
                ERROR(d.CLASS_XU, 1);
                
            if not g.pfs:  # BFS
                '''
                /* THIS CODE RESTRICTS BFS FROM USING THE 'DATA_REMOTE' DIRECTIVE  */
                /* AND WILL ISSUE A B102 ERROR MESSAGE.  THIS CODE WILL NEED TO BE */
                /* REMOVED IF AND WHEN BFS BEGINS USING 'DATA_REMOTE'.             */
                '''
                if g.DATA_REMOTE:
                    ERROR(d.CLASS_B, 102);
                    g.DATA_REMOTE = g.FALSE;
            #-----------------------------------------------------------------
            ERRPRINT()
    
    def STACK_RETURN_CHAR(NUMBER, CHAR):
        # I is local but doesn't need to be persistent.
        for I in range(0, 3):
            if l.RETURN_CHAR[I] == 0:
                l.RETURN_CHAR[I] = NUMBER;
                l.TYPE_CHAR[I] = CHAR;
                return;
    
    def READ_CARD():
        if g.END_OF_INPUT:
            g.CURRENT_CARD = l.INPUT_PAD + g.X70;
            return;
        goto_READ = True
        while goto_READ:
            goto_READ = False
            NEXT_RECORD();
            if LENGTH(g.CURRENT_CARD) > 88:
                g.CURRENT_CARD = SUBSTR(g.CURRENT_CARD, 0, 88);
                pass
            if LENGTH(g.CURRENT_CARD) == 0:
                if g.INCLUDING:
                    g.INPUT_DEV = 0;
                    g.INCLUDE_COMPRESSED = g.FALSE
                    g.INCLUDING = g.FALSE;
                    g.INCLUDE_STMT = -1;
                    g.INCLUDE_END = g.TRUE;
                    if not g.pfs:  # BFS/PASS INTERFACE; TEMPLATE LENGTH
                        if g.TEMPLATE_FLAG:
                            g.TEXT_LIMIT[0] = g.TEXT_LIMIT[1];
                    goto_READ = True;
                    continue
                else:
                    g.END_OF_INPUT = g.TRUE;
                    g.CURRENT_CARD = l.INPUT_PAD + g.X70;
                    pass
        g.CARD_COUNT = g.CARD_COUNT + 1;
        if g.LISTING2:
            if g.CARD_COUNT != 0:
                SAVE_INPUT();
        if g.INCLUDE_END:
            g.INCLUDE_LIST2 = g.TRUE;
            g.INCLUDE_OFFSET = g.INCLUDE_COUNT + g.CARD_COUNT - g.INCLUDE_OFFSET;
            g.INCLUDE_COUNT = g.INCLUDE_OFFSET
        g.SAVE_CARD = g.CURRENT_CARD[:];
    
    def SCAN_CARD(TYPE):
        # POINT is local, but doesn't need to be persistent.
        POINT = SHL(TYPE, l.IND_SHIFT);
       
        for l.CP in range(1, g.TEXT_LIMIT[0] + 1):
            if BYTE(g.CURRENT_CARD, l.CP) != BYTE(g.X1):
                if BYTE(e_line(TYPE), l.CP) != BYTE(g.X1):
                    if TYPE == 0:
                        ERROR(d.CLASS_ME, 4);
                    elif TYPE == 1:
                        ERROR(d.CLASS_MS, 4);
                        continue
                e_indicator(l.CP + POINT, e_count(TYPE));
                l.FILL = BYTE(g.CURRENT_CARD, l.CP);
                e_line(TYPE, BYTE(e_line(TYPE), l.CP, l.FILL));
    
    def COMP(TYPE):
        # POINT is local but doesn't need to be persistent.
        POINT = 0xC5 + 0x1D * TYPE;
        
        e_count(TYPE, 1)
        while True:
            SCAN_CARD(TYPE);
            READ_CARD();
            if BYTE(g.CURRENT_CARD) != POINT:  # NO MORE OF THIS TYPE OF CARD
                if not ORDER_OK(POINT):
                    ERROR(d.CLASS_M, 2);
                POINT = SHL(TYPE, l.IND_SHIFT);
                for l.CP in range(1, g.TEXT_LIMIT[0] + 1):
                    if BYTE(e_line(TYPE), l.CP) == BYTE(g.X1):
                        e_indicator(l.CP + POINT, 0);
                    elif not TYPE:
                        l.FILL = e_count() - e_indicator(l.CP) + 1;
                        e_indicator(l.CP, l.FILL);
                return;
            e_count(TYPE, e_count(TYPE) + 1);
    
    def GET_GROUP():
        l.E_LINE = l.BLANKS + l.BLANKS;
        l.S_LINE = l.BLANKS + l.BLANKS;
        l.LAST_E_COUNT = l.E_COUNT;
        l.LAST_S_COUNT = l.S_COUNT;
        l.E_COUNT = 0
        l.S_COUNT = 0;
        if not g.INCREMENT_DOWN_STMT:
            g.INCREMENT_DOWN_STMT = (g.LAST_WRITE <= g.STMT_PTR);
        OUTPUT_GROUP();
        if g.INCLUDE_END:
            OUTPUT_WRITER(LAST_WRITE, STMT_PTR);
            OUTPUT(0, g.X8 + g.STARS + 'END' + g.INCLUDE_MSG + g.STARS);
            g.NEXT_CC = g.DOUBLE;
            g.INCLUDE_LIST = g.TRUE;
            g.SRN_COUNT[0] = 0;
            if g.TPL_REMOTE:
                ERROR(d.CLASS_XI, 5);
                g.TPL_REMOTE = g.FALSE;
            g.INCLUDE_END = g.FALSE;
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
                        READ_CARD();
                    goto_CHECK_ORDER = False
                    if not ORDER_OK(l.PREV_CARD):
                        ERROR(d.CLASS_M, 2);
                        goto_COMMENT_CARD = True
                        continue
                goto_LOOP = False
                ct = g.CARD_TYPE[BYTE(g.CURRENT_CARD)]
                if g.END_GROUP:
                    break  # GO TO FOUND_GROUP
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
                l.M_LINE = g.CURRENT_CARD[:];
                if g.SRN_PRESENT:
                    if g.INCLUDING:
                        g.INCL_SRN[0] = SUBSTR(g.CURRENT_CARD, \
                                               g.TEXT_LIMIT[0] + 1);
                        g.SRN_COUNT[0] = g.SRN_COUNT[0] + 1;
                    else:
                        g.SRN[0] = SUBSTR(g.CURRENT_CARD, g.TEXT_LIMIT[0] + 1);
                        g.RVL[1] = SUBSTR(g.SRN[0], 6, 2);
                g.SAVE_CARD = BYTE(g.SAVE_CARD, 0, BYTE('M'));
                l.PREV_CARD = BYTE(g.CURRENT_CARD);
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
                    g.CURRENT_CARD = BYTE(g.CURRENT_CARD, 0, BYTE('C'));
                    pass
                goto_COMMENT_CARD = False
                if l.PREV_CARD == BYTE('C'):
                    g.COMMENTING = g.TRUE;
                else:
                    g.COMMENTING = g.FALSE;
                l.PREV_CARD = BYTE('C');
                '''
                /*----------------------------------------*/
                /* SAVE SRN FIELD FOR NON-INCLUDED SOURCE */
                /* CODE ONLY. (SRN'S OF COMMENTS ARE      */
                /* NOT NEEDED FOR INCLUDED SOURCE CODE)   */
                /*----------------------------------------*/
                '''
                if g.SRN_PRESENT:
                    if not g.INCLUDING:
                        g.SRN[0] = SUBSTR(g.CURRENT_CARD, g.TEXT_LIMIT[0] + 1);
                        g.RVL[0] = '';
                        g.RVL[1] = '';
                        g.NEXT_CHAR_RVL = '';
                
                PROCESS_COMMENT();
                READ_CARD();
                if g.INCLUDE_END:
                    OUTPUT(0, g.X8 + g.STARS + 'END' + g.INCLUDE_MSG + g.STARS);
                    g.NEXT_CC = g.DOUBLE;
                    g.INCLUDE_LIST = g.TRUE;
                    g.SRN_COUNT[0] = 0;
                    if g.TPL_REMOTE:
                        ERROR(d.CLASS_XI, 5);
                        g.TPL_REMOTE = g.FALSE;
                    g.INCLUDE_END = g.FALSE;
                goto_CHECK_ORDER = True;
                continue
            elif ct == 5:
                # CASE 5--DIRECTIVE
                g.CURRENT_CARD = BYTE(g.CURRENT_CARD, 0, BYTE('D'));
                goto_COMMENT_CARD = True
                continue
        
        # FOUND_GROUP was here!
        g.END_GROUP = g.FALSE;
        l.E_LINE = SUBSTR(l.E_LINE, 0, LENGTH(l.M_LINE));
        if l.E_COUNT <= 0:
            for l.CP in range(1, g.TEXT_LIMIT[0] + 1):
                e_indicator(l.CP, 0);
            l.E_COUNT = l.LAST_E_COUNT;
        l.S_LINE = SUBSTR(l.S_LINE, 0, LENGTH(l.M_LINE));
        if l.S_COUNT <= 0:
            for l.CP in range(1, g.TEXT_LIMIT[0] + 1):
                l.S_INDICATOR[l.CP] = 0;
            l.S_COUNT = l.LAST_S_COUNT;
    
    # Note: From the indenting in the *original* XPL source, we'd infer that
    # the ELSE clause is for the outermost IF.  However, the BNF grammar for
    # XPL implies that it associates with the innermost.  That's also the way
    # I had previously concluded that HAL/S (based on XPL) works.
    def CHOP():
        l.INDEX = l.INDEX + 1;
        if l.INDEX > g.TEXT_LIMIT[0]:
            if not g.INCLUDING or not g.TEMPLATE_FLAG or \
                    (g.INCLUDING and g.TEMPLATE_FLAG and \
                    (l.INDEX > (g.TPL_LRECL - 1))):
                if (g.CARD_TYPE[BYTE(g.CURRENT_CARD)] >= 4) or g.INCLUDE_END:
                    g.GROUP_NEEDED = g.TRUE;
                else:
                   # OUT OF DATA--GET MORE 
                   GET_GROUP();
                   l.INDEX = 1;
    
    def STACK(TYPE):
        # POINT is local, but doesn't need to be persistent.
        POINT = ep(TYPE) + SHL(TYPE, l.IND_SHIFT);
        
        goto_NOT_MULTIPLE = False
        if ep(TYPE) < 0:
            goto_NOT_MULTIPLE = True
        if not goto_NOT_MULTIPLE and BYTE(e_line(TYPE), l.INDEX) == BYTE(g.X1):
            if BYTE(e_stack(TYPE), ep(TYPE)) == BYTE(g.X1):
                e_ind(POINT, e_ind(POINT) + 1);
                return
        goto_NOT_MULTIPLE = False
        ep(TYPE, ep(TYPE) + 1);
        if ep(TYPE) > l.IND_LIM:
            if TYPE == 0:
                ERROR(d.CLASS_ME, 1);
            elif TYPE == 1:
                ERROR(d.CLASS_MS, 1);
        POINT = POINT + 1;
        l.CHAR_TEMP = SUBSTR(e_line(TYPE), l.INDEX, 1);
        if l.CHAR_TEMP != g.X1:
            g.NONBLANK_FOUND = g.TRUE;
        e_stack(TYPE, e_stack(TYPE) + l.CHAR_TEMP);
        e_ind(POINT, e_indicator(l.INDEX + SHL(TYPE, l.IND_SHIFT)));    
    
    def BUILD_XSCRIPTS():
        l.S_STACK = ''
        l.E_STACK = '';
        l.S_BLANKS = -1
        l.E_BLANKS = -1;
        l.SP = -1
        l.EP = -1;
        goto_CHECK_M = True
        while goto_CHECK_M:
            goto_CHECK_M = False
            if BYTE(l.M_LINE, l.INDEX) == BYTE(g.X1):
                STACK(0);
                STACK(1);
                CHOP();
                if not g.GROUP_NEEDED:
                    goto_CHECK_M = True
                    continue
            if g.GROUP_NEEDED:
                if g.NONBLANK_FOUND:
                    GET_GROUP();
                    l.INDEX = 1;
                    g.GROUP_NEEDED = g.FALSE;
                    goto_CHECK_M = True;
                    continue
        g.NONBLANK_FOUND = g.FALSE;
        if BYTE(l.S_STACK, l.SP) == BYTE(g.X1):
            if l.SP > 0:
                l.S_STACK = SUBSTR(l.S_STACK, 0, l.SP);
            else:
                l.S_STACK = '';
            l.S_BLANKS = s_ind(l.SP);
        if BYTE(l.E_STACK, l.EP) == BYTE(g.X1):
            if l.EP > 0:
                l.E_STACK = SUBSTR(l.E_STACK, 0, l.EP);
            else:
                l.E_STACK = '';
            l.E_BLANKS = e_ind(l.EP);
        if l.E_BLANKS >= l.S_BLANKS:
            l.M_BLANKS = l.S_BLANKS;
        else:
            l.M_BLANKS = l.E_BLANKS;
    
    def MACRO_DIAGNOSTICS(WHERE):
        try:
            OUTPUT(0, 'AT ' + str(WHERE) + '  NEXT_CHAR=' + 
                   str(g.NEXT_CHAR) + \
                   '  MACRO_EXPAN_LEVEL=' + \
                    str(g.MACRO_EXPAN_LEVEL) + '  MACRO_TEXT(' + \
                    str(g.MACRO_POINT) + ')=' + \
                    str(g.MACRO_TEXT(g.MACRO_POINT)) + '  PARM_REPLACE_PTR(' + \
                    str(g.PARM_EXPAN_LEVEL) + \
                    ')=' + str(g.PARM_REPLACE_PTR[g.PARM_EXPAN_LEVEL]));
        except:
            pass
    
    # STREAM_START was here!
    goto_CHECK_STRING_POSITION = True
    goto_MACRO_DONE = False
    while goto_CHECK_STRING_POSITION:
        goto_CHECK_STRING_POSITION = False
        if g.MACRO_EXPAN_LEVEL > 0:
            g.OVER_PUNCH = 0;  # FIX ESCAPE BUG WITHIN MACRO 
            if g.PARM_EXPAN_LEVEL > g.BASE_PARM_LEVEL[g.MACRO_EXPAN_LEVEL]:
                goto_PARM_DONE = False
                firstTry = True
                while firstTry or goto_PARM_DONE:
                    firstTry = False
                    if not goto_PARM_DONE and \
                            g.PARM_EXPAN_LEVEL >= g.PARM_EXPAN_LIMIT:
                        ERROR(d.CLASS_IR, 6, 0);
                        g.MACRO_EXPAN_LEVEL = 0
                        g.PARM_EXPAN_LEVEL = 0
                        g.MACRO_FOUND = 0;
                        goto_MACRO_DONE = True
                        break
                    elif not goto_PARM_DONE and \
                            g.PARM_REPLACE_PTR[g.PARM_EXPAN_LEVEL] < \
                                LENGTH(g.MACRO_CALL_PARM_TABLE[ \
                                    g.PARM_STACK_PTR[g.PARM_EXPAN_LEVEL] \
                                ]):
                        g.NEXT_CHAR = BYTE(g.MACRO_CALL_PARM_TABLE[
                                            g.PARM_STACK_PTR[g.PARM_EXPAN_LEVEL]
                                            ], \
                                    g.PARM_REPLACE_PTR[g.PARM_EXPAN_LEVEL]);
                        g.PARM_REPLACE_PTR[g.PARM_EXPAN_LEVEL] = \
                            g.PARM_REPLACE_PTR[g.PARM_EXPAN_LEVEL] + 1;
                        if g.CONTROL[3]:
                            MACRO_DIAGNOSTICS(1);
                        return;
                    elif goto_PARM_DONE or g.FIRST_TIME_PARM[g.PARM_EXPAN_LEVEL]:
                        if goto_PARM_DONE or g.P_CENT[g.PARM_EXPAN_LEVEL]:
                            if not goto_PARM_DONE:
                                g.P_CENT[g.PARM_EXPAN_LEVEL] = g.FALSE;
                            goto_PARM_DONE = False 
                            g.FIRST_TIME_PARM[g.PARM_EXPAN_LEVEL] = g.TRUE;
                            g.PARM_EXPAN_LEVEL = g.PARM_EXPAN_LEVEL - 1;
                            goto_CHECK_STRING_POSITION = True
                            break
                        g.NEXT_CHAR = BYTE(g.X1);
                        g.FIRST_TIME_PARM[g.PARM_EXPAN_LEVEL] = g.FALSE;
                        if g.CONTROL[3]:
                            MACRO_DIAGNOSTICS(2);
                        return;
                    else:
                        goto_PARM_DONE = True
                        continue
                if goto_CHECK_STRING_POSITION:
                    continue
            if not goto_MACRO_DONE:
                if g.MACRO_TEXT(g.MACRO_POINT) != 0xEF:
                    g.BLANK_COUNT = 0;
                    if g.MACRO_TEXT(g.MACRO_POINT) == 0xEE:
                        g.MACRO_POINT = g.MACRO_POINT + 1;
                        g.BLANK_COUNT = g.MACRO_TEXT(g.MACRO_POINT);
                        g.NEXT_CHAR = BYTE(g.X1);
                    else:
                        g.NEXT_CHAR = g.MACRO_TEXT(g.MACRO_POINT);
                    g.MACRO_POINT = g.MACRO_POINT + 1;
                    if g.CONTROL[3]:
                        MACRO_DIAGNOSTICS(3);
                    return;
                if g.FIRST_TIME[g.MACRO_EXPAN_LEVEL]:
                    if not g.M_CENT[g.MACRO_EXPAN_LEVEL]:
                        g.FIRST_TIME[g.MACRO_EXPAN_LEVEL] = g.FALSE;
                        g.NEXT_CHAR = BYTE(g.X1);
                        if g.CONTROL[3]:
                            MACRO_DIAGNOSTICS(4);
                        return;
                else:
                    g.FIRST_TIME[g.MACRO_EXPAN_LEVEL] = g.TRUE;
                g.TOP_OF_PARM_STACK = g.TOP_OF_PARM_STACK - \
                                      g.NUM_OF_PARM[g.MACRO_EXPAN_LEVEL];
                g.PRINTING_ENABLED = g.M_PRINT[g.MACRO_EXPAN_LEVEL];
                if not g.M_CENT[g.MACRO_EXPAN_LEVEL]:
                    if not g.DONT_SET_WAIT:
                        g.WAIT = g.TRUE;
                g.MACRO_EXPAN_LEVEL = g.MACRO_EXPAN_LEVEL - 1;
                g.MACRO_POINT = g. M_P[g.MACRO_EXPAN_LEVEL];
                g.BLANK_COUNT = g.M_BLANK_COUNT[g.MACRO_EXPAN_LEVEL];
            if goto_MACRO_DONE or g.MACRO_EXPAN_LEVEL == 0:
                if not goto_MACRO_DONE:
                    g.MACRO_FOUND = g.FALSE ;
                goto_MACRO_DONE = False
                g.NEXT_CHAR = g.SAVE_NEXT_CHAR;
                g.OVER_PUNCH = g.SAVE_OVER_PUNCH;
                g.PRINTING_ENABLED = g.PRINT_FLAG;
                if g.CONTROL[3]:
                    MACRO_DIAGNOSTICS(5);
                return;
            else:
                goto_CHECK_STRING_POSITION = True
                continue
    
    g.BLANK_COUNT = -1;
    goto_STACK_CHECK = True
    while goto_STACK_CHECK:
        goto_STACK_CHECK = False
        for l.II in range(l.II, 3):
            if l.RETURN_CHAR[l.II] != 0:
                l.ARROW_FLAG = g.TRUE;
                l.RETURN_CHAR[l.II] = l.RETURN_CHAR[l.II] - 1;
                g.NEXT_CHAR = l.TYPE_CHAR[l.II];
                g.OVER_PUNCH = 0;
                return;
        l.II = 0;
        if l.ARROW_FLAG:
            l.ARROW_FLAG = g.FALSE;
            g.NEXT_CHAR = l.SAVE_NEXT_CHAR1;
            g.OVER_PUNCH = l.SAVE_OVER_PUNCH1;
            g.BLANK_COUNT = l.SAVE_BLANK_COUNT1;
            return;
        if g.GROUP_NEEDED:
            GET_GROUP();
            l.INDEX = 1;
            g.GROUP_NEEDED = g.FALSE;
        goto_BEGINNING = True
        while goto_BEGINNING:
            goto_BEGINNING = False
            if l.RETURNING_M:
                if l.M_BLANKS >= 0:
                    g.NEXT_CHAR = BYTE(g.X1);
                    l.ARROW = -l.LAST_E_IND;
                    l.LAST_E_IND = 0;
                    g.BLANK_COUNT = l.M_BLANKS;
                    l.M_BLANKS = -1;
                    break  # GO TO FOUND_CHAR;
                if BYTE(l.M_LINE, l.INDEX) != BYTE(g.X1):
                    if l.E_COUNT > 0:
                        if BYTE(l.E_LINE, l.INDEX) != BYTE(g.X1):
                           if e_indicator(l.INDEX) != 1:
                               ERROR(d.CLASS_ME, 3);
                           else:
                               g.OVER_PUNCH = BYTE(l.E_LINE, l.INDEX);
                        else:
                           g.OVER_PUNCH = 0;
                    else:
                        g.OVER_PUNCH = 0;
                    if l.S_COUNT > 0:
                        if BYTE(l.S_LINE, l.INDEX) != BYTE(g.X1):
                            ERROR(d.CLASS_MS, 3);
                    l.ARROW = -l.LAST_E_IND;
                    l.LAST_E_IND = 0;
                    if not g.INCLUDING:
                        '''
                        /*CHECK THE RVL FOR EACH CHARACTER AS IT IS READ.  RVL WILL */
                        /*HOLD THE MOST RECENT RVL ASSOCIATED WITH A TOKEN.         */
                        '''
                        if STRING_GT(g.NEXT_CHAR_RVL, g.RVL[0]):
                            g.RVL[0] = g.NEXT_CHAR_RVL[:];
                        g.NEXT_CHAR_RVL = g.RVL[1][:];
                    g.NEXT_CHAR = BYTE(l.M_LINE, l.INDEX);
                    CHOP();
                    break  # GO TO FOUND_CHAR;
                else:
                    BUILD_XSCRIPTS();
                    g.OVER_PUNCH = 0;
                    l.RETURNING_M = g.FALSE;
                    l.LAST_S_IND = 0;
                    l.RETURNING_S = g.TRUE;
                    l.PNTR = 0;
            if l.RETURNING_S:
                if LENGTH(l.S_STACK) > 0 and l.PNTR < LENGTH(l.S_STACK):
                    if BYTE(l.S_STACK, l.PNTR) == BYTE(g.X1):
                        if s_ind(l.PNTR) >= 0:  # MORE LEFT
                            g.NEXT_CHAR = BYTE(g.X1);
                            g.BLANK_COUNT = s_ind(l.PNTR);
                            l.PNTR = l.PNTR + 1;
                            l.ARROW = l.LAST_S_IND - s_ind(l.PNTR);
                            l.LAST_S_IND = s_ind(l.PNTR);
                    else:  # A NON-BLANK
                        g.NEXT_CHAR = BYTE(l.S_STACK, l.PNTR);
                        l.ARROW = l.LAST_S_IND - s_ind(l.PNTR);
                        l.LAST_S_IND = s_ind(l.PNTR);
                        l.PNTR = l.PNTR + 1;
                    break  # GO TO FOUND_CHAR;
                else:  # CAN'T RETURN S 
                    l.RETURNING_S = g.FALSE;
                    l.RETURNING_E = g.TRUE;
                    l.LAST_E_IND = -l.LAST_S_IND;
                    l.PNTR = 0;
            if l.RETURNING_E:
                if LENGTH(l.E_STACK) > 0 and l.PNTR < LENGTH(l.E_STACK):
                    if BYTE(l.E_STACK, l.PNTR) == BYTE(g.X1):
                        if e_ind(l.PNTR) >= 0:  # MORE TO GO
                            g.NEXT_CHAR = BYTE(g.X1);
                            g.BLANK_COUNT = e_ind(l.PNTR);
                            l.PNTR = l.PNTR + 1;
                            l.ARROW = e_ind(l.PNTR) - l.LAST_E_IND;
                            l.LAST_E_IND = e_ind(l.PNTR);
                    else:  # A NON-BLANK
                        g.NEXT_CHAR = BYTE(l.E_STACK, l.PNTR);
                        l.ARROW = e_ind(l.PNTR) - l.LAST_E_IND;
                        l.LAST_E_IND = e_ind(l.PNTR);
                        l.PNTR = l.PNTR + 1;
                    break  # GO TO FOUND_CHAR;
                else:  # CAN'T RETURN E 
                    l.RETURNING_E = g.FALSE;
                    l.RETURNING_M = g.TRUE;
            goto_BEGINNING = True
            continue
        # FOUND_CHAR was here!
        if l.ARROW != 0:
            g.OLD_LEVEL = g.NEW_LEVEL;
            g.NEW_LEVEL = g.NEW_LEVEL + l.ARROW;
            l.SAVE_OVER_PUNCH1 = g.OVER_PUNCH;
            l.SAVE_NEXT_CHAR1 = g.NEXT_CHAR;
            l.SAVE_BLANK_COUNT1 = g.BLANK_COUNT;
            goto_EXPONENT = False
            goto_SUBS = False
            firstTry = True
            while firstTry or goto_EXPONENT or goto_SUBS:
                firstTry = False
                if not goto_SUBS and (goto_EXPONENT or g.OLD_LEVEL > 0):
                    if not goto_EXPONENT and l.ARROW < 0:
                        STACK_RETURN_CHAR(-l.ARROW, BYTE(')'));
                    else:
                        goto_EXPONENT = False
                        if l.ARROW > 1:
                            ERROR(d.CLASS_ME, 2);
                        STACK_RETURN_CHAR(2, BYTE('*'));
                        STACK_RETURN_CHAR(l.ARROW, BYTE('('));
                elif goto_SUBS or g.OLD_LEVEL == 0:
                    if goto_SUBS or l.ARROW < 0:
                        goto_SUBS = False
                        if l.ARROW < -1:
                            ERROR(d.CLASS_MS, 2);
                        STACK_RETURN_CHAR(1, BYTE('$'));
                        STACK_RETURN_CHAR(-l.ARROW, BYTE('('));
                    else:
                        goto_EXPONENT = True
                        continue
                else:  # OLD < 0
                    if l.ARROW < 0:
                        goto_SUBS = True
                        continue
                    if g.NEW_LEVEL <= 0:
                        STACK_RETURN_CHAR(l.ARROW, BYTE(')'));
                    else:
                        STACK_RETURN_CHAR(-g.OLD_LEVEL, BYTE(')'));
                        if g.NEW_LEVEL > 1:
                            ERROR(d.CLASS_ME, 2);
                        STACK_RETURN_CHAR(2, BYTE('*'));
                        STACK_RETURN_CHAR(g.NEW_LEVEL, BYTE('('));
            l.ARROW = 0;
            goto_STACK_CHECK = True
            continue
    return;
