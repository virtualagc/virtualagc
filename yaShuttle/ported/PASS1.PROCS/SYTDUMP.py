#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   SYTDUMP.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-11 RSB  Began porting from XPL
'''

from xplBuiltins import *
import g
import HALINCL.COMMON as h
import HALINCL.CERRDECL as d
import HALINCL.VMEM2 as v2
from BLANK   import BLANK
from HEX     import HEX
from IFORMAT import I_FORMAT
from PAD     import PAD

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  SYT_DUMP                                               */
 /* MEMBER NAME:     SYTDUMP                                                */
 /* LOCAL DECLARATIONS:                                                     */
 /*          ADD_ATTR          LABEL                                        */
 /*          ADD_QUOTE(1534)   LABEL                                        */
 /*          ADD_XREFS(1541)   LABEL                                        */
 /*          ATTR_START        BIT(16)                                      */
 /*          CHAR_ATTR(19)     CHARACTER;                                   */
 /*          CHECK_AND_ENTER(1538)  LABEL                                   */
 /*          CUSS(7)           CHARACTER;                                   */
 /*          DEFINITION_FOUND(1524)  LABEL                                  */
 /*          DOUBLE_QUOTE(1535)  LABEL                                      */
 /*          ENTER_SORT(1544)  LABEL                                        */
 /*          EXCHANGES         BIT(8)                                       */
 /*          FLAG_MASK(19)     FIXED                                        */
 /*          I                 FIXED                                        */
 /*          J                 FIXED                                        */
 /*          JI                FIXED                                        */
 /*          JL                FIXED                                        */
 /*          K                 FIXED                                        */
 /*          KI                FIXED                                        */
 /*          KL                FIXED                                        */
 /*          L                 FIXED                                        */
 /*          LABEL_NAME(13)    CHARACTER;                                   */
 /*          LABEL_TYPES       CHARACTER;                                   */
 /*          LM                LABEL                                        */
 /*          M                 FIXED                                        */
 /*          MACRO_END(1498)   LABEL                                        */
 /*          MACRO_LOOP(1514)  LABEL                                        */
 /*          MACRO_TEXT_RESET(1551)  LABEL                                  */
 /*          MAX_LENGTH        BIT(16)                                      */
 /*          N_FIX(1516)       LABEL                                        */
 /*          NAMER             CHARACTER;                                   */
 /*          NEWLINE(1500)     LABEL                                        */
 /*          NO_INDIRECT       LABEL                                        */
 /*          NO_SREF           LABEL                                        */
 /*          NO_XREF(1512)     LABEL                                        */
 /*          R                 CHARACTER;                                   */
 /*          S                 CHARACTER;                                   */
 /*          SORT_COUNT        BIT(16)                                      */
 /*          STORE_BI_XREF     LABEL                                        */
 /*          T                 CHARACTER;                                   */
 /*          T_CASE            BIT(16)                                      */
 /*          T_LEVEL           BIT(16)                                      */
 /*          T_REFS(1505)      LABEL                                        */
 /*          V_ARRAY           CHARACTER;                                   */
 /*          V_LEN             CHARACTER;                                   */
 /*          VAR_NAME(10)      CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ASSIGN_PARM                                                    */
 /*          BI_LIMIT                                                       */
 /*          BI_NAME                                                        */
 /*          BI_XREF_CELL                                                   */
 /*          BI#                                                            */
 /*          BLOCK_SYTREF                                                   */
 /*          CLASS_BI                                                       */
 /*          COMPOOL_LABEL                                                  */
 /*          CR_REF                                                         */
 /*          DOUBLE                                                         */
 /*          DOUBLE_SPACE                                                   */
 /*          DUPL_FLAG                                                      */
 /*          EJECT_PAGE                                                     */
 /*          EOFILE                                                         */
 /*          EQUATE_LABEL                                                   */
 /*          EVENT_TYPE                                                     */
 /*          EVIL_FLAG                                                      */
 /*          EXT_ARRAY                                                      */
 /*          EXTERNAL_FLAG                                                  */
 /*          FALSE                                                          */
 /*          FIRST_STMT                                                     */
 /*          FOREVER                                                        */
 /*          FUNC_CLASS                                                     */
 /*          IMP_DECL                                                       */
 /*          IMPL_T_FLAG                                                    */
 /*          IND_CALL_LAB                                                   */
 /*          INIT_CONST                                                     */
 /*          INP_OR_CONST                                                   */
 /*          LATCHED_FLAG                                                   */
 /*          LOCK_FLAG                                                      */
 /*          MAC_TXT                                                        */
 /*          MACRO_TEXTS                                                    */
 /*          MACRO_TEXT                                                     */
 /*          MAIN_SCOPE                                                     */
 /*          MAJ_STRUC                                                      */
 /*          MAT_TYPE                                                       */
 /*          MAX_STRUC_LEVEL                                                */
 /*          MISC_NAME_FLAG                                                 */
 /*          MODF                                                           */
 /*          NAME_FLAG                                                      */
 /*          NDECSY                                                         */
 /*          PAGE                                                           */
 /*          PARM_FLAGS                                                     */
 /*          PROC_LABEL                                                     */
 /*          PROG_LABEL                                                     */
 /*          PROGRAM_LAYOUT_INDEX                                           */
 /*          PROGRAM_LAYOUT                                                 */
 /*          REPL_ARG_CLASS                                                 */
 /*          REPL_CLASS                                                     */
 /*          RIGID_FLAG                                                     */
 /*          SDF_INCL_OFF                                                   */
 /*          SDL_OPTION                                                     */
 /*          SREF_OPTION                                                    */
 /*          STMT_LABEL                                                     */
 /*          SUBHEADING                                                     */
 /*          SYM_ADDR                                                       */
 /*          SYM_ARRAY                                                      */
 /*          SYM_CLASS                                                      */
 /*          SYM_FLAGS                                                      */
 /*          SYM_LENGTH                                                     */
 /*          SYM_LINK1                                                      */
 /*          SYM_LINK2                                                      */
 /*          SYM_LOCK#                                                      */
 /*          SYM_NAME                                                       */
 /*          SYM_NEST                                                       */
 /*          SYM_PTR                                                        */
 /*          SYM_SCOPE                                                      */
 /*          SYM_SORT                                                       */
 /*          SYM_TYPE                                                       */
 /*          SYM_XREF                                                       */
 /*          SYT_ADDR                                                       */
 /*          SYT_ARRAY                                                      */
 /*          SYT_CLASS                                                      */
 /*          SYT_FLAGS                                                      */
 /*          SYT_LINK1                                                      */
 /*          SYT_LINK2                                                      */
 /*          SYT_LOCK#                                                      */
 /*          SYT_NAME                                                       */
 /*          SYT_NEST                                                       */
 /*          SYT_PTR                                                        */
 /*          SYT_SCOPE                                                      */
 /*          SYT_SORT                                                       */
 /*          SYT_TYPE                                                       */
 /*          SYT_XREF                                                       */
 /*          TEMPL_NAME                                                     */
 /*          TEMPLATE_CLASS                                                 */
 /*          TOKEN                                                          */
 /*          TPL_FUNC_CLASS                                                 */
 /*          TRUE                                                           */
 /*          VAR_CLASS                                                      */
 /*          VAR_LENGTH                                                     */
 /*          VEC_TYPE                                                       */
 /*          XREF_FULL                                                      */
 /*          XREF_MASK                                                      */
 /*          XREF                                                           */
 /*          X1                                                             */
 /*          X256                                                           */
 /*          X2                                                             */
 /*          X4                                                             */
 /*          X70                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          BI_XREF                                                        */
 /*          BI_XREF#                                                       */
 /*          COMM                                                           */
 /*          CONTROL                                                        */
 /*          CROSS_REF                                                      */
 /*          ERROR_COUNT                                                    */
 /*          LINK_SORT                                                      */
 /*          MAX_SEVERITY                                                   */
 /*          NOT_ASSIGNED_FLAG                                              */
 /*          SAVE_LINE_#                                                    */
 /*          SAVE_SEVERITY                                                  */
 /*          SYM_TAB                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          BLANK                                                          */
 /*          ERRORS                                                         */
 /*          GET_CELL                                                       */
 /*          HEX                                                            */
 /*          I_FORMAT                                                       */
 /*          PAD                                                            */
 /* CALLED BY:                                                              */
 /*          COMPILATION_LOOP                                               */
 /*          PRINT_SUMMARY                                                  */
 /***************************************************************************/
'''


class cSYT_DUMP:  # Local variables for SYT_DUMP().

    def __init__(self):
        self.HEADER_PRINTED = g.FALSE
        self.R = ''
        self.S = ''
        self.T = ''
        self.V_LEN = ''
        self.V_ARRAY = ''
        self.T_LEVEL = 0
        self.T_CASE = 0
        self.I = 0
        self.J = 0
        self.K = 0
        self.L = 0
        self.M = 0
        self.JI = 0
        self.KI = 0
        self.JL = 0
        self.KL = 0
        self.SORT_COUNT = 0
        self.MAX_LENGTH = 0
        self.ATTR_START = 0
        self.EXCHANGES = 0
        '''
        CHANGED VAR_NAME FROM A CHARACTER ARRAY OF 10 TO A SINGLE
        STRING TO REDUCE THE NUMBER OF STRINGS IN PASS1.
        11 CHARACTER SPACES FOR EACH VARIABLE NAME.
        '''
        self.VAR_NAME = '? DATA TYPEBIT        CHARACTER  MATRIX     ' + \
                        'VECTOR     SCALAR     INTEGER    <BORC>     ' + \
                        '<IORS>     EVENT      STRUCTURE  '
        '''
        CHANGED LABEL_NAME FROM A CHARACTER ARRAY OF 13 TO A SINGLE
        STRING TO REDUCE THE NUMBER OF STRINGS IN PASS1.
        18 CHARACTER SPACES FOR EACH LABEL NAME.
        '''
        self.LABEL_NAME = 'STRUCTURE TEMPLATETEMPLATE REFERENCE' + \
                          '<MB STMT LAB>     <IND STMT LAB>    ' + \
                          'STATEMENT LABEL   ? LABEL           ' + \
                          '<MBCALL LABEL>    <IND CALL LABEL>  ' + \
                          '<CALLED LABEL>    PROCEDURE         ' + \
                          'TASK              PROGRAM           ' + \
                          'COMPOOL           EQUATE LABEL      '
        '''
        CHANGED CUSS FROM CHARACTER ARRAY OF 7 TO A SINGLE STRING
        TO REDUCE THE NUMBER OF STRINGS IN PASS1. 23 CHARACTER
        SPACES FOR EACH CUSS PHRASE. THERE ARE BLANK PHRASES
        STARTING AT LOCATIONS 92 & 184.
        '''
        self.CUSS = 'NOT USED               ' + \
                    'NOT ASSIGNED           ' + \
                    'NOT REFERENCED         ' + \
                    '                       ' + \
                    'POSSIBLY NOT USED      ' + \
                    'POSSIBLY NOT ASSIGNED  ' + \
                    'POSSIBLY NOT REFERENCED' + \
                    '                       '
        self.LABEL_TYPES = \
            'FUNCTION; UPDATE;   PROCEDURE;TASK;     PROGRAM;  COMPOOL;  '
        self.FLAG_MASK = (
            0,
            0x00800000,  # SINGLE
            0x00400000,  # DOUBLE
            0x08000000,  # TEMPORARY
            0x04000000,  # RIGID  (AS MODIFIED IN CHECK_AND_ENTER)
            0x00000004,  # DENSE
            0x00000008,  # ALIGNED
            0x00000020,  # ASSIGN
            0x00000400,  # INPUT
            0x00000100,  # AUTOMATIC
            0x00000200,  # STATIC
            0x00000800,  # INITIAL
            0x00001000,  # CONSTANT
            0x00010000,  # ACCESS
            0x00000002,  # REENTRANT
            0x00080000,  # EXCLUSIVE
            0x00100000,  # EXTERNAL
            0x00000080,  # REMOTE
            0x02000000,  # INCLUDED_REMOTE
            0
            )
        '''
        CHANGED CHAR_ATTR FROM A CHARACTER ARRAY OF 19 TO A SINGLE
        STRING TO REDUCE THE NUMBER OF STRINGS IN PASS1.
        11 CHARACTER SPACES FOR EACH CHARACTER ATTRIBUTE.
        '''
        self.CHAR_ATTR = 'LOCK=*     SINGLE     DOUBLE     TEMPORARY  ' + \
                         'RIGID      DENSE      ALIGNED    ASSIGN-PARM' + \
                         'INPUT-PARM AUTOMATIC  STATIC     INITIAL    ' + \
                         'CONSTANT   ACCESS     REENTRANT  EXCLUSIVE  ' + \
                         'EXTERNAL   REMOTE     INCREM     '
        self.NAMER = 'NAME '
        self.LABEL_ON_END = g.FALSE


lSYT_DUMP = cSYT_DUMP()

class cPRINT_VAR_NAMES:
    def __init__(self):
        self.M = 0
        
lPRINT_VAR_NAMES = cPRINT_VAR_NAMES()

def SYT_DUMP():
    l = lSYT_DUMP  # Local variables.
    
    # These imports are from within the function in order to avoid a 
    # "partially initialized module" circular import error.
    from ERRORS import ERRORS
    from HALINCL.VMEM3 import GET_CELL
    
    # PRINTS THE SYMBOL TABLE HEADER.
    def PRINT_SYMBOL_HEADER(STRUC, NEW_PAGE):
        # Local J doesn't need to be persistent.
        
        if STRUC:
            OUTPUT(1, '0S T R U C T U R E   T E M P L A T E   S Y M B O L' + \
                      '  &  C R O S S   R E F E R E N C E   T A B L E   ' + \
                      'L I S T I N G :');
        else:
            l.HEADER_PRINTED = g.TRUE;
            if NEW_PAGE:
                OUTPUT(1, g.SUBHEADING);
                g.EJECT_PAGE();
            OUTPUT(1, '0S Y M B O L  &  C R O S S   R E F E R E N C E   ' + \
                      'T A B L E   L I S T I N G :');
        if l.MAX_LENGTH < 4:
            J = 4;
        else:
            J = l.MAX_LENGTH;
        OUTPUT(1, '0         (CROSS REFERENCE FLAG KEY:  4 = ASSIGNMENT, ' + \
                  '2 = REFERENCE, 1 = SUBSCRIPT USE, 0 = DEFINITION)');
        l.S = ' DCL  NAME' + SUBSTR(g.X70, 0, J - 3) + \
                "        TYPE                          " \
                             "ATTRIBUTES & CROSS REFERENCE";
        OUTPUT(1, g.DOUBLE + l.S);
        OUTPUT(1, g.SUBHEADING + l.S);
        OUTPUT(0, g.X1);
    
    # PRINTS THE STRUCTURES THAT ARE DECLARED USING THE CURRENT TEMPLATE
    # SYT_NO IS THE SYMBOL TABLE ENTRY FOR THE STRUCTURE TEMPLATE.
    # M IS THE INDEX INTO SORTED SYMBOL TABLE TO START LOOKING FOR
    #   STRUCTURES USING THE CURRENT STRUCTURE TEMPLTE.
    def PRINT_VAR_NAMES(SYT_NO, M = None):
        # The locals, IDX, USED, and STR_OUT, don't require persistence.
        # But parameter M is optional, and so it does require it.
        ll = lPRINT_VAR_NAMES
        if M != None:
            ll.M = M
        
        USED = 'USED BY: '
        STR_OUT = SUBSTR(g.X70, 0, l.ATTR_START) + USED;
        for IDX in range(ll.M, l.SORT_COUNT + 1):
            if (g.SYT_TYPE(g.SYT_SORT(IDX)) == g.MAJ_STRUC) and \
                    (g.VAR_LENGTH(g.SYT_SORT(IDX)) == SYT_NO):
                if (LENGTH(STR_OUT) + LENGTH(g.SYT_NAME(g.SYT_SORT(IDX))) > 132):
                    OUTPUT(0, SUBSTR(STR_OUT, 0, LENGTH(STR_OUT)));
                    STR_OUT = SUBSTR(g.X70, 0, l.ATTR_START);
                STR_OUT = STR_OUT + g.SYT_NAME(g.SYT_SORT(IDX)) + ',';
        if  LENGTH(STR_OUT) == l.ATTR_START + LENGTH(USED):
            STR_OUT = STR_OUT + '** ' + SUBSTR(l.CUSS, 46, 14) + ' ** ';
        OUTPUT(0, SUBSTR(STR_OUT, 0, LENGTH(STR_OUT) - 1));
    
    def ENTER_SORT(LOC):
        # No Locals
        l.SORT_COUNT = l.SORT_COUNT + 1;
        g.SYT_SORT(l.SORT_COUNT, LOC);
        if LENGTH(g.SYT_NAME(LOC)) > l.MAX_LENGTH:
             l.MAX_LENGTH = LENGTH(g.SYT_NAME(LOC));
    
    # Regarding the ALWAYS parameter, CHECK_AND_ENTER() is sometimes called
    # with it in XPL, and sometimes without.  My supposition that it defaults to
    # FALSE is based on the fact that when it's present, it's always specified
    # as TRUE
    def CHECK_AND_ENTER(LOC, ALWAYS=g.FALSE):
        # Locals (I and J) don't need to be persistent.
        I = g.SYT_XREF(LOC);  # PTR TO LAST ENTRY
        J = g.SYT_FLAGS(LOC);
        if g.TOKEN == g.EOFILE:
            if (J & g.RIGID_FLAG) != 0:
               g.SYT_FLAGS(LOC, (J & (~g.RIGID_FLAG)) | g.DUPL_FLAG);
            else:
                g.SYT_FLAGS(LOC, J & (~g.DUPL_FLAG));
            if I > 0:
                g.SYT_XREF(LOC, SHR(g.XREF(I), 16));
                g.XREF(I, g.XREF(I) & 0xFFFF);
            else:
                g.SYT_XREF(LOC, 0);
        if ALWAYS:  # ENTRY BEING FORCED INTO SORT ARRAY
            ENTER_SORT(LOC);
            ALWAYS = g.FALSE;  # FOR NEXT TIME
            return g.TRUE;
        if (g.XREF(I) & g.XREF_MASK) > g.FIRST_STMT():
            ENTER_SORT(LOC);
            return g.TRUE;
        return g.FALSE;
    
    def ADD_ATTR(ATTR):
        # No locals
        if LENGTH(l.S) + LENGTH(ATTR) + 2 > 132:
           OUTPUT(0, l.S);
           l.S = SUBSTR(g.X70, 0, l.ATTR_START);
        l.S = l.S + ATTR + ', ';
    
    def MACRO_TEXT_RESET():
        # No locals
        OUTPUT(0, l.S);
        l.S = BLANK(l.S, 0, 132);
        l.JL = l.ATTR_START;
    
    #*********************************************************************
    # FINDS THE CROSS-REFERENCES FOR EACH SYMBOL AND/OR BUILT-IN FUNCTION
    # AND FORMATS THE CROSS-REFERENCES FOR REPORTING IN THE COMPILATION
    # LISTING.
    # INPUT PARAMETERS:
    # PTR - THE INDEX IN THE XREFS ARRAY FOR THE FIRST CROSS-REFERENCE
    #       OF THE SYMBOL/BUILT-IN FUNCTION BEING PROCESSED.
    # PROCESSING_BI- EQUAL TO 1 WHEN PROCESSING A BUILT-IN
    #                FUNCTION, OTHERWISE IT IS EQUAL TO 0.
    #*********************************************************************
    def ADD_XREFS(PTR, PROCESSING_BI):
        # The locals, A and TMP_PTR, don't need to be persistent.
        l.T = '';
        A = 0;
        l.LABEL_ON_END = g.FALSE;
        while True:
            TMP_PTR = PTR;
            A = A | g.XREF(PTR);  # COLLECT FLAGS
            l.T = l.T + str((SHR(g.XREF(PTR), 13) & 7)) + g.X1 + \
                SUBSTR(str(10000 + (g.XREF(PTR) & g.XREF_MASK)), 1, 4) + g.X2;
            if LENGTH(l.S) + LENGTH(l.T) + 6 > 132:
                OUTPUT(0, l.S + l.T);
                l.S = SUBSTR(g.X70, 0, l.ATTR_START);
                l.T = '';
            PTR = SHR(g.XREF(PTR), 16);
            # IF THE XREF ENTRY IS AN ASSIGN XREF & THE
            # SYMBOL IS A STATEMENT LABEL THEN THE LABEL
            # IS BEING USED ON AN END STATEMENT. SO THE
            # ASSIGN XREF ENTRY NEEDS TO BE REMOVED AND
            # LABEL_ON_END IS SET TO TRUE SO THE INACCURATE
            # "NOT REFERENCED" MESSAGE WILL NOT BE PRINTED.
            if ((g.SYT_TYPE(l.I) & g.STMT_LABEL) == g.STMT_LABEL) and \
                    ((SHR(g.XREF(PTR), 13) & 7) == 4) \
                    and not PROCESSING_BI:
                l.LABEL_ON_END = g.TRUE;
                g.XREF(TMP_PTR, (g.XREF(TMP_PTR) & 0xFFFF) | \
                                    (g.XREF(PTR) & 0xFFFF0000));
                PTR = SHR(g.XREF(PTR), 16);
            if PTR == 0:
                return A;
    
    # PROCEDURE TO STORE BI_XREF ARRAYS IN VMEM
    class cSTORE_BI_XREF:

        def __init__(self):
            self.I = 0
            self.PTR = 0
            self.NODE_H = []

    lSTORE_BI_XREF = cSTORE_BI_XREF()

    def STORE_BI_XREF():
        ll = lSTORE_BI_XREF
        g.BI_XREF_CELL(GET_CELL((g.BIp + 1) * 4, v2.MODF)[0]);
        ll.PTR = 0;
        for ll.I in range(0, g.BIp + 1):
            while len(ll.NODE_H) < ll.PTR + 2:
                ll.NODE_H.append(0)
            ll.NODE_H[ll.PTR] = g.BI_XREFp[ll.I];
            ll.NODE_H[ll.PTR + 1] = g.BI_XREF[ll.I];
            ll.PTR = ll.PTR + 2;
    
    # TRUNCATE PROCEDURE ADDED TO STRIP THE BLANK SPACES FROM A
    # CHARACTER STRING.
    def TRUNCATE(STRING):
        # Local (L) doesn't need persistence.
    
        L = LENGTH(STRING);
        while SUBSTR(STRING, L - 1, 1) == g.X1:
            L = L - 1;
        
        return SUBSTR(STRING, 0, L);
    
    l.KI = 0;
    g.CONTROL[7] = 0;  #  ONE SHOT ONLY
    if g.TOKEN == g.EOFILE:
        OUTPUT(1, '0**** C O M P I L A T I O N   L A Y O U T ****');
        for l.M in range(1, g.PROGRAM_LAYOUT_INDEX + 1):
            l.I = g.PROGRAM_LAYOUT[l.M];
            l.S = g.SYT_NAME(l.I);
            for l.J in range(l.M + 1, g.PROGRAM_LAYOUT_INDEX + 1):
                if g.SYT_NAME(g.PROGRAM_LAYOUT[l.J]) == l.S:
                    l.KI = 1;
            l.S = l.S + ': ';
            l.J = g.SYT_CLASS(l.I);
            l.K = g.SYT_TYPE(l.I);
            if (g.SYT_FLAGS(l.I) & g.EXTERNAL_FLAG) != 0:
                l.S = l.S + 'EXTERNAL ';
            if l.J == g.FUNC_CLASS:
                l.S = l.S + SUBSTR(l.LABEL_TYPES, 0, 10);
            elif l.K == g.STMT_LABEL:
                l.S = l.S + SUBSTR(l.LABEL_TYPES, 10, 10);
            else:
                l.K = l.K - g.PROC_LABEL + 2;
                l.K = l.K * 10;
                l.S = l.S + SUBSTR(l.LABEL_TYPES, l.K, 10);
            l.K = g.SYT_NEST(l.I) * 3;
            OUTPUT(1, g.DOUBLE + SUBSTR(g.X70, 0, l.K + 1) + l.S);
        if l.KI:
            if g.MAX_SEVERITY < 1:
                g.MAX_SEVERITY = 1;
            g.ERROR_COUNT = g.ERROR_COUNT + 1;
            g.SAVE_SEVERITY[g.ERROR_COUNT] = 1;
            g.SAVE_LINE_p[g.ERROR_COUNT] = -2;
            ERRORS (d.CLASS_BI, 104);
        g.EJECT_PAGE();
    
    l.MAX_LENGTH = 0;
    l.I = 1;  # DEFAULT START OF SORT_COUNT
    if g.SREF_OPTION:
        if g.XREF_FULL:
            OUTPUT(1, '0*****SREF OPTION WILL BE IGNORED DUE TO CROSS ' + \
                      'REFERENCE TABLE OVERFLOW*****');
            # GO TO NO_SREF;
        else:
            while l.I < g.BLOCK_SYTREF[1]:
                if g.SYT_TYPE(l.I) == g.TEMPL_NAME:  # STRUCTURE TEMPLATE
                    l.K = l.I + 1;  # FIRST ELEMENT
                    l.M = g.FALSE;  # SET TRUE IF ANY ELEMENTS OF STR ARE USED
                    while g.SYT_CLASS(l.K) == g.TEMPLATE_CLASS and \
                                               g.SYT_TYPE(l.K) != g.TEMPL_NAME:
                        l.M = l.M | CHECK_AND_ENTER(l.K);
                        l.K = l.K + 1;
                    if l.M:  # ENTER TPL NAME IF ANY TERMINALS USED
                        CHECK_AND_ENTER(l.I, g.TRUE);  # FORCE ENTRY
                    else:  # CONDITIONALLY ENTER TEMPLATE NAME
                        CHECK_AND_ENTER(l.I);
                    l.I = l.K;  # JUMP OVER BODY OF TEMPLATE
                elif (g.SYT_TYPE(l.I) == g.PROC_LABEL) or \
                        (g.SYT_TYPE(l.I) == g.PROG_LABEL) or \
                        (g.SYT_CLASS(l.I) == g.FUNC_CLASS):
                    CHECK_AND_ENTER(l.I, g.TRUE);  # PRINT ALL NON-CPL TEMPLATES
                    l.I = l.I + 1;  # FIRST PARM (OR ANOTHER BLOCK)
                    while (g.SYT_FLAGS(l.I) & g.PARM_FLAGS) != 0:
                        CHECK_AND_ENTER(l.I, g.TRUE);  # ENTER PARMS TOO
                        l.I = l.I + 1;
                else:  # NONE OF ABOVE
                    CHECK_AND_ENTER(l.I);
                    if g.SYT_TYPE(l.I) == g.EQUATE_LABEL:
                        if g.TOKEN == g.EOFILE:
                            g.SYT_NAME(l.I, SUBSTR(g.SYT_NAME(l.I), 1));  # NO @
                    l.I = l.I + 1;
            # END OF WHILE I < BLOCK_SYTREF(1)
    # END OF SREF PROCESSING
    # NO_SREF:
    for l.I in range(l.I, g.NDECSY() + 1):
        CHECK_AND_ENTER(l.I, g.TRUE);
        if g.SYT_TYPE(l.I) == g.EQUATE_LABEL:
            if g.TOKEN == g.EOFILE:
                g.SYT_NAME(l.I, SUBSTR(g.SYT_NAME(l.I), 1));  # NO @
    if l.MAX_LENGTH < 4:
        l.J = 4;
    else:
        l.J = l.MAX_LENGTH;
    l.ATTR_START = l.J + 44;
    l.EXCHANGES = g.TRUE;
    
    if not g.CONTROL[0xF]:
        l.M = SHR(l.SORT_COUNT, 1);
        while l.M > 0:
            for l.J in range(1, l.SORT_COUNT - l.M + 1):
                l.I = l.J;
                while STRING_GT(g.SYT_NAME(g.SYT_SORT(l.I)), \
                                g.SYT_NAME(g.SYT_SORT(l.I + l.M))):
                    l.L = g.SYT_SORT(l.I);
                    g.SYT_SORT(l.I, g.SYT_SORT(l.I + l.M));
                    g.SYT_SORT(l.I + l.M, l.L);
                    l.I = l.I - l.M;
                    if l.I < 1:
                        break  # GO TO LM;
                # END DO WHILE STRING_GT
                # LM:
            # END DO J
            l.M = SHR(l.M, 1);
        # END DO WHILE M
    # END OF SORTING IF NOT CONTROL(F)
    
    l.T_CASE = 0 
    l.T_LEVEL = 0;
    l.M = 1;
    # IF 1ST SYMBOL IN SORTED LIST IS A STRUCTURE TEMPLATE
    # THEN PRINT THE HEADER FOR STRUCTURES.
    if g.SYT_TYPE(g.SYT_SORT(1)) == g.TEMPL_NAME:
        PRINT_SYMBOL_HEADER(g.TRUE, g.FALSE);
    else:
        PRINT_SYMBOL_HEADER(g.FALSE, g.FALSE);
    while l.M <= l.SORT_COUNT:
        goto_NO_INDIRECT = False
        if not l.HEADER_PRINTED:
            if (g.SYT_TYPE(g.SYT_SORT(l.M)) != g.TEMPL_NAME):
               PRINT_SYMBOL_HEADER(g.FALSE, g.TRUE);
        # DO CASE T_CASE;
        if l.T_CASE == 0:
            l.I = g.SYT_SORT(l.M);
        elif l.T_CASE == 1:
            if g.SYT_LINK1(l.I) > 0:
                l.T_LEVEL = l.T_LEVEL + 1;
                l.I = g.SYT_LINK1(l.I);
            else:
                while g.SYT_LINK2(l.I) < 0:
                    l.I = -g.SYT_LINK2(l.I);
                    l.T_LEVEL = l.T_LEVEL - 1;
                if g.SYT_LINK2(l.I) == 0:
                    l.T_CASE = 0
                    l.T_LEVEL = 0;
                    goto_NO_INDIRECT = True;
                else:
                    l.I = g.SYT_LINK2(l.I);
        elif l.T_CASE == 2:
            l.I = l.I + 1;
        # End of DO CASE
        if not goto_NO_INDIRECT:
            l.J = g.SYT_TYPE(l.I);
            l.K = g.SYT_CLASS(l.I);
            l.L = g.SYT_FLAGS(l.I);
            if (l.L & g.IMPL_T_FLAG) != 0:
                goto_NO_INDIRECT = True
            else:
                if l.K >= g.TEMPLATE_CLASS:
                    if l.J == g.TEMPL_NAME: 
                        if (l.L & g.EVIL_FLAG) == 0:
                            l.T_CASE = 1;
                elif l.K == g.REPL_CLASS:
                    if g.VAR_LENGTH(l.I) > 0:
                        l.T_CASE = 2;
                        l.T_LEVEL = -g.VAR_LENGTH(l.I);
                elif l.K == g.REPL_ARG_CLASS:
                    if l.T_CASE == 0:
                        goto_NO_INDIRECT = True
                    else:
                        l.T_LEVEL = l.T_LEVEL + 1;
                        if l.T_LEVEL == 0:
                            l.T_CASE = 0;
                if not goto_NO_INDIRECT:
                    if l.J == g.IND_CALL_LAB:
                        if not g.CONTROL[0xF]:
                            goto_NO_INDIRECT = True
                    if not goto_NO_INDIRECT:
                        l.T = PAD(g.SYT_NAME(l.I), l.ATTR_START - 44);
                        if l.K >= g.TEMPLATE_CLASS:
                            if l.J == g.TEMPL_NAME:
                                l.T = SUBSTR(l.T, 1) + g.X4;
                            elif l.T_CASE == 0:
                                l.T = l.T + SUBSTR(g.X4, 1);
                            else:
                                l.T = g.X1 + l.T + g.X2;
                        elif l.K == g.REPL_ARG_CLASS:
                            l.T = g.X1 + l.T + g.X2;
                        else:
                            l.T = l.T + SUBSTR(g.X4, 1);
                        if (l.L & g.IMP_DECL) != 0:
                            l.T = ' *' + l.T;
                        else:
                            l.T = g.X2 + l.T;
                        l.JI = g.SYT_XREF(l.I);
                        l.JL = l.JI
                        if g.TOKEN != g.EOFILE:
                           l.JI = SHR(g.XREF(l.JI), 16);
                        elif l.JI <= 0:
                           l.JI = 0;
                        else:
                            while True:
                                if (SHR(g.XREF(l.JI), 13) & 7) == 0:
                                    break  # GO TO DEFINITION_FOUND;
                                l.JI = SHR(g.XREF(l.JI), 16);
                                if l.JI == 0:
                                    l.JI = l.JL;
                                    break  # GO TO DEFINITION_FOUND;
                        # DEFINITION_FOUND:
                        l.KI = g.XREF(l.JI) & g.XREF_MASK;
                        l.V_ARRAY = '';
                        l.T = I_FORMAT(l.KI, 4) + l.T;
                        if l.K == g.REPL_CLASS:
                            l.S = 'REPLACE MACRO';
                        elif l.K == g.REPL_ARG_CLASS:
                            l.S = 'MACRO ARG';
                        elif l.J < g.TEMPL_NAME:
                            l.S = TRUNCATE(SUBSTR(l.VAR_NAME, l.J * 11, 11));
                            if l.J < g.MAT_TYPE:
                                if g.VAR_LENGTH(l.I) == -1:
                                    l.V_LEN = '*';
                                else:
                                    l.V_LEN = g.VAR_LENGTH(l.I);
                                l.S = l.S + '(' + str(l.V_LEN) + ')';
                            elif l.J == g.VEC_TYPE:
                                l.S = str(g.VAR_LENGTH(l.I)) + ' - ' + l.S;
                            elif l.J == g.MAT_TYPE:
                                l.V_LEN = str(SHR(g.VAR_LENGTH(l.I), 8)) + ' X ';
                                l.V_LEN = l.V_LEN + str(g.VAR_LENGTH(l.I) & 0xFF);
                                l.S = l.V_LEN + g.X1 + l.S;
                            if l.K == g.FUNC_CLASS or l.K == g.TPL_FUNC_CLASS:
                                l.S = l.S + ' FUNCTION';
                            elif g.SYT_ARRAY(l.I) != 0:
                                if l.J == g.MAJ_STRUC:
                                    if  g.SYT_ARRAY(l.I) < 0:
                                        l.V_LEN = '*';
                                    else:
                                        l.V_LEN = g.SYT_ARRAY(l.I);
                                    l.S = l.S + '(' + str(l.V_LEN) + ')';
                                else:
                                    l.S = l.S + ' ARRAY';
                                    l.V_ARRAY = 'ARRAY(';
                                    for l.KL in range(1, h.EXT_ARRAY[g.SYT_ARRAY(l.I)] + 1):
                                       if h.EXT_ARRAY[g.SYT_ARRAY(l.I) + l.KL] < 0:
                                           l.V_ARRAY = l.V_ARRAY + '*,';
                                       else:
                                           l.V_ARRAY = l.V_ARRAY + \
                                                str(h.EXT_ARRAY[g.SYT_ARRAY(l.I) + l.KL]) \
                                                + ',';
                                    l.V_ARRAY = SUBSTR(l.V_ARRAY, 0, LENGTH(l.V_ARRAY) - 1) + ')';
                            if l.J == g.MAJ_STRUC:
                                goto_T_REFS = False
                                firstTry = True
                                while firstTry or goto_T_REFS:
                                    firstTry = False
                                    if goto_T_REFS or l.K != g.TEMPLATE_CLASS:
                                        goto_T_REFS = False
                                        l.V_ARRAY = SUBSTR(g.SYT_NAME(g.VAR_LENGTH(l.I)), 1) + '-STRUCTURE';
                                    elif g.VAR_LENGTH(l.I) > 0:
                                        goto_T_REFS = True
                                        continue
                                    else:
                                        l.S = 'MINOR NODE';
                            # N_FIX:
                            if (l.L & g.NAME_FLAG) != 0:
                                l.S = l.NAMER + l.S;
                            if l.T_LEVEL > 0:
                                l.S = SUBSTR(g.X70, 0, g.MAX_STRUC_LEVEL + 1) + l.S;
                                if l.T_LEVEL <= g.MAX_STRUC_LEVEL:
                                    l.S = BYTE(l.S, l.T_LEVEL - 1, l.T_LEVEL | 0xF0);
                        else:
                            l.S = TRUNCATE(SUBSTR(l.LABEL_NAME, (l.J - g.TEMPL_NAME) * 18, 18));
                            if (l.L & g.NAME_FLAG) != 0:
                                # The logic to actually GO TO N_FIX is a lot
                                # more complex than I like, so alternatively,
                                # I've just duplicated the handful of code that
                                # is at N_FIX here.
                                # GO TO N_FIX;
                                if (l.L & g.NAME_FLAG) != 0:
                                    l.S = l.NAMER + l.S;
                                if l.T_LEVEL > 0:
                                    l.S = SUBSTR(g.X70, 0, g.MAX_STRUC_LEVEL + 1) + l.S;
                                    if l.T_LEVEL <= g.MAX_STRUC_LEVEL:
                                        l.S = BYTE(l.S, l.T_LEVEL - 1, l.T_LEVEL | 0xF0);
                            else:
                                l.L = l.L & g.SDF_INCL_OFF;
                                if l.J == g.STMT_LABEL:
                                   if (g.VAR_LENGTH(l.I) > 0) and (g.VAR_LENGTH(l.I) < 3):
                                       l.S = 'UPDATE LABEL';
                        l.S = PAD(l.T + l.S, l.ATTR_START);
                        if l.K >= g.TEMPLATE_CLASS:
                            if l.T_CASE == 0:
                                if l.J != g.TEMPL_NAME:
                                    l.KI = l.I;
                                    while g.SYT_TYPE(l.KI) != g.TEMPL_NAME:
                                        l.KI = l.KI - 1;
                                    l.R = ' **** SEE STRUCTURE TEMPLATE' + g.SYT_NAME(l.KI);
                                    l.T = '';
                                    if (g.SYT_FLAGS(l.KI) & g.EVIL_FLAG) == 0:
                                        # The logic to get to N_XREF from here
                                        # is pretty complex, so instead I've
                                        # just duplicated the code found at
                                        # NO_XREF and mimicked what happens 
                                        # after that code is executed.
                                        # GO TO NO_XREF;
                                        if LENGTH(l.S) + LENGTH(l.T) + LENGTH(l.R) <= 132:
                                            l.S = l.S + l.T + l.R;
                                            if LENGTH(l.S) > l.ATTR_START:
                                                OUTPUT(0, l.S);
                                        else:
                                            OUTPUT(0, l.S + l.T);
                                            OUTPUT(0, SUBSTR(g.X70, 0, l.ATTR_START) + l.R);
                                        goto_NO_INDIRECT = True
                        if not goto_NO_INDIRECT:  # (for GO TO NO_XREF).
                            if LENGTH(l.V_ARRAY) > 0:
                                ADD_ATTR(l.V_ARRAY);
                            if (l.L & g.LATCHED_FLAG) != 0:
                                if l.J == g.EVENT_TYPE:
                                    ADD_ATTR('LATCHED');
                            for l.KL in range(1, 19 + 1):
                                if (l.L & l.FLAG_MASK[l.KL]) != 0:
                                    ADD_ATTR(TRUNCATE(SUBSTR(l.CHAR_ATTR, l.KL * 11, 11)));
                            if not g.SDL_OPTION:
                                if (l.L & g.EXTERNAL_FLAG) != 0:
                                    ADD_ATTR('VERSION=' + str(g.SYT_LOCKp(l.I)));
                            if (l.L & g.LOCK_FLAG) != 0:
                                if g.SYT_LOCKp(l.I) == 0xFF:
                                    ADD_ATTR(SUBSTR(l.CHAR_ATTR, 0, 6));
                                else:
                                    ADD_ATTR(SUBSTR(l.CHAR_ATTR, 0, 5) + str(g.SYT_LOCKp(l.I)));
                            if g.CONTROL[0xF]:
                                # EXTRA SYMBOL TABLE DUMP REQUESTED
                                l.T = HEX(l.L);
                                ADD_ATTR('FLAGS=' + l.T);
                                ADD_ATTR('NEST=' + str(g.SYT_NEST(l.I)));
                                ADD_ATTR('SCOPE=' + str(g.SYT_SCOPE(l.I)));
                                ADD_ATTR('PTR=' + str(g.SYT_PTR(l.I)));
                                ADD_ATTR('LENGTH=' + str(g.VAR_LENGTH(l.I)));
                                ADD_ATTR('LINK1=' + str(g.SYT_LINK1(l.I)));
                                ADD_ATTR('LINK2=' + str(g.SYT_LINK2(l.I)));
                                ADD_ATTR('SYT_NO=' + str(l.I));
                                ADD_ATTR('ARRAY=' + str(g.SYT_ARRAY(l.I)));
                                ADD_ATTR('ADDR=' + str(g.SYT_ADDR(l.I)));
                                ADD_ATTR('CLASS=' + str(g.SYT_CLASS(l.I)));
                                ADD_ATTR('TYPE=' + str(g.SYT_TYPE(l.I)));
                            if l.K == g.REPL_CLASS:
                                goto_MACRO_LOOP = False
                                goto_MACRO_END = False
                                firstTry = True
                                while firstTry or goto_MACRO_LOOP or \
                                        goto_MACRO_END:
                                    firstTry = False
                                    if not (goto_MACRO_LOOP or goto_MACRO_END):
                                        ADD_ATTR('MACRO TEXT="');
                                        l.S = SUBSTR(l.S, 0, LENGTH(l.S) - 2);
                                        l.JL = LENGTH(l.S);
                                        l.S = l.S + SUBSTR(g.X256, 0, 132 - l.JL);  # MAKE S 132 CHARS
                                        l.KL = g.SYT_ADDR(l.I);  # PTR TO TEXT
                                        l.JI = g.MACRO_TEXT(l.KL);  # FIRST CHARACTER
                                    if not goto_MACRO_END:
                                        goto_MACRO_LOOP = False
                                        while l.JI != 0xEF  and l.JL < 132:
                                            if l.JI == 0xEE:  # MULTIPLE BLANKS
                                                l.KL = l.KL + 1;
                                                l.JI = g.MACRO_TEXT(l.KL);
                                                if l.JI == 0:
                                                    goto_MACRO_END = True
                                                    break
                                                # NEWLINE:
                                                while True:
                                                    if (l.JI + l.JL) > 132:
                                                        l.JI = l.JI - 132 + l.JL;
                                                        MACRO_TEXT_RESET();
                                                        # GO TO NEWLINE;
                                                    else:
                                                        l.JL = l.JL + l.JI;
                                                        break
                                            # END OF JI = "EE"
                                            elif l.JI == BYTE('"'):  # DOUBLE ANY "
                                                l.S = BYTE(l.S, l.JL, l.JI);
                                                l.JL = l.JL + 1;
                                                goto_DOUBLE_QUOTE = False
                                                firstTry = True
                                                while firstTry or goto_DOUBLE_QUOTE:
                                                    firstTry = False
                                                    if l.JL < 132:
                                                        goto_DOUBLE_QUOTE = False
                                                        l.S = BYTE(l.S, l.JL, l.JI);
                                                    else:
                                                        MACRO_TEXT_RESET();
                                                        goto_DOUBLE_QUOTE = True;
                                                        continue
                                            # END OF JI = BYTE('"')
                                            else:
                                                l.S = BYTE(l.S, l.JL, l.JI);
                                            l.JL = l.JL + 1;
                                            l.KL = l.KL + 1;
                                            l.JI = g.MACRO_TEXT(l.KL);
                                    # END OF WHILE JI != "EF" ETC
                                    if l.JI != 0xEF and not goto_MACRO_END:
                                        # JUST RAN OUT OF ROOM
                                        MACRO_TEXT_RESET();
                                        goto_MACRO_LOOP = True
                                        continue
                                    else:  # END OF MACRO TEXT
                                        goto_MACRO_END = False
                                        goto_ADD_QUOTE = False
                                        firstTry = True
                                        while firstTry or goto_ADD_QUOTE:
                                            firstTry = False
                                            if l.JL < 132 or goto_ADD_QUOTE:
                                                goto_ADD_QUOTE = False
                                                l.S = BYTE(l.S, l.JL, BYTE('"'));
                                            else:
                                                MACRO_TEXT_RESET();
                                                goto_ADD_QUOTE = True
                                                continue
                                        l.S = SUBSTR(l.S, 0, l.JL + 1);
                            # END OF K = REPL_CLASS
                            else:
                                l.S = SUBSTR(l.S, 0, LENGTH(l.S) - 2);
                            l.T = ''
                            l.R = '';
                            l.KL = g.SYT_XREF(l.I);
                            if g.TOKEN != g.EOFILE or l.KL <= 0:
                                OUTPUT(0, l.S);
                                goto_NO_INDIRECT = True
                            if not goto_NO_INDIRECT:
                                l.KI = (LENGTH(l.S) - l.ATTR_START + 7) // 8;
                                l.KI = (l.KI * 8) + l.ATTR_START - LENGTH(l.S);
                                if l.KI > 0:
                                    l.S = l.S + SUBSTR(g.X70, 0, l.KI);
                                ADD_ATTR('  XREF:     ');
                                l.S = SUBSTR(l.S, 0, LENGTH(l.S) - 6);
                                l.KI = 1;
                                l.JL = SHR(ADD_XREFS(g.SYT_XREF(l.I), g.FALSE), 13) & 7;
                                if 0 != (l.JL & 1):
                                    l.JL = l.JL | 2;  # MERGE SUBSCR & REF FLAGS
                                if l.J == g.COMPOOL_LABEL:
                                    l.JL = l.JL | 6;
                                elif l.J == g.PROG_LABEL and (l.L & g.EXTERNAL_FLAG) == 0:
                                    l.JL = l.JL | 6;
                                elif g.SYT_NEST(l.I) == 0:
                                    l.KI = 0;
                                elif g.SYT_SCOPE(l.I) < g.MAIN_SCOPE:
                                    l.JL = l.JL | 6;
                                if l.K >= g.TEMPLATE_CLASS: 
                                    if l.J == g.TEMPL_NAME:
                                        l.JL = l.JL | 4;
                                    else:
                                        l.JL = l.JL | 8;
                                elif l.K == g.REPL_ARG_CLASS:
                                    l.JL = l.JL | 6;
                                elif (l.L & g.NAME_FLAG) != 0: 
                                    pass
                                elif l.K != g.VAR_CLASS:
                                    l.JL = l.JL | 4;
                                elif l.J == g.EVENT_TYPE:
                                    l.JL = l.JL | 4;
                                if (l.L & g.INIT_CONST) != 0:
                                    l.JL = l.JL | 4;
                                if (l.L & g.INP_OR_CONST) != 0:
                                    l.JL = l.JL | 4;
                                if (l.L & g.ASSIGN_PARM) != 0:
                                    l.KI = 0;
                                if (l.L & g.MISC_NAME_FLAG) != 0:
                                    if l.J != g.TEMPL_NAME:
                                        l.JL = l.JL | 8;
                                if l.LABEL_ON_END:
                                    l.JL = l.JL | 6;
                                l.JL = SHR(l.JL, 1);
                                l.R = TRUNCATE(SUBSTR(l.CUSS, l.JL * 23, 23));
                                if 0 != (1 & ((l.JL == 1) & l.KI)): 
                                    g.NOT_ASSIGNED_FLAG = 0xFF;
                                    l.R = '***** ERROR ***** REFERENCED BUT ' + l.R;
                                    OUTPUT(0, l.S + l.T);
                                    OUTPUT(0, SUBSTR(g.X70, 0, l.ATTR_START - 3) + l.R);  # MAKE IT STICK OUT
                                    goto_NO_INDIRECT = True;  # SKIP OTHER PRINT LOGIC
                                if not goto_NO_INDIRECT:
                                    # NO_XREF:
                                    if LENGTH(l.S) + LENGTH(l.T) + LENGTH(l.R) <= 132:
                                        l.S = l.S + l.T + l.R;
                                        if LENGTH(l.S) > l.ATTR_START:
                                            OUTPUT(0, l.S);
                                    else:
                                        OUTPUT(0, l.S + l.T);
                                        OUTPUT(0, SUBSTR(g.X70, 0, l.ATTR_START) + l.R);
        goto_NO_INDIRECT = False
        # THE LOGIC TO GO THROUGH STRUCTURES STARTS AT THE ROOT NODE AND
        # ENDS AT THE ROOT NODE.  TO PREVENT VARIABLES FROM BEING PRINTED
        # TWICE, CHECK FOR T_CASE^=0 BECAUSE T_CASE=0 AT THE SECOND
        # VISIT TO THE ROOT NODE BUT NOT THE FIRST.
        if (g.SYT_TYPE(l.I) == g.TEMPL_NAME):
            if (l.T_CASE != 0):
                PRINT_VAR_NAMES(l.I);
        if l.T_CASE == 0:
            l.M = l.M + 1;
    
    if g.XREF_FULL:
        ERRORS (d.CLASS_BI, 102);
        g.NOT_ASSIGNED_FLAG = g.FALSE;
    elif g.NOT_ASSIGNED_FLAG:
        if g.MAX_SEVERITY < 1:
            g.MAX_SEVERITY = 1;
        g.ERROR_COUNT = g.ERROR_COUNT + 1;
        g.SAVE_SEVERITY[g.ERROR_COUNT] = 1;
        g.SAVE_LINE_p[g.ERROR_COUNT] = -1;
        ERRORS (d.CLASS_BI, 105);
    OUTPUT(1, g.SUBHEADING);
    g.DOUBLE_SPACE();
    if g.BI_XREF[0]:
        if g.TOKEN == g.EOFILE:
            g.EJECT_PAGE();
            OUTPUT(1, \
                '0B U I L T - I N   F U N C T I O N   C R O S S   R E F E R E N C E');
            OUTPUT(1, \
                '0   (CROSS REFERENCE FLAG KEY:  4 = ASSIGNMENT, 2 = REFERENCE, 1 = SUBSCRIPT USE)');
            l.S = '  NAME      CROSS REFERENCE';
            OUTPUT(1, g.DOUBLE + l.S);
            OUTPUT(1, g.SUBHEADING + l.S);
            l.KI = g.BI_LIMIT + 1;
            l.ATTR_START = l.KI + 6;
            for l.J in range(1, g.BIp + 1):
                 l.S = SUBSTR(g.BI_NAME[g.BI_INDX[l.J]], g.BI_LOC[l.J], 10);
                 if g.BI_XREF[l.J] > 0:
                 # KEEP TRACK OF THE USED XREF CELLS
                     g.BI_XREFp[0] = g.BI_XREFp[0] + 1;
                     l.S = l.S + 'XREF: ';
                     l.KL = g.BI_XREF[l.J];
                     g.BI_XREF[l.J] = SHR(g.XREF(l.KL), 16);
                     g.XREF(l.KL, g.XREF(l.KL) & 0xFFFF);
                     ADD_XREFS(g.BI_XREF[l.J], g.TRUE);
                     if LENGTH(l.T) > 0:
                         OUTPUT(0, l.S + l.T);
            STORE_BI_XREF();
            OUTPUT(1, g.SUBHEADING);
            g.DOUBLE_SPACE();
