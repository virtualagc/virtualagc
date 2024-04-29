 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GENERATE.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

 /***************************************************************************/
 /* PROCEDURE NAME:  GENERATE                                               */
 /* MEMBER NAME:     GENERATE                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*       ADD               BIT(16)            INCR_USAGE        LABEL      */
 /*       ADDITIVE(22)      BIT(8)             INITADDR          FIXED      */
 /*       ADOPTR            BIT(16)            INITAGAIN         BIT(16)    */
 /*       ALCOP             MACRO              INITAUTO          BIT(8)     */
 /*       ALL_FAILS         BIT(8)             INITAUX(10)       FIXED      */
 /*       AND               BIT(16)            INITBASE          BIT(16)    */
 /*       ARG_ASSEMBLE      LABEL              INITBLK(10)       BIT(16)    */
 /*       ARG_COUNTER(20)   BIT(16)            INITCTR(10)       BIT(16)    */
 /*       ARG_NAME(100)     BIT(8)             INITDECR          FIXED      */
 /*       ARG_POINTER(20)   BIT(16)            INITINCR          FIXED      */
 /*       ARG_STACK(100)    BIT(16)            INITINX           BIT(16)    */
 /*       ARG_TYPE(100)     BIT(16)            INITLITMOD        BIT(16)    */
 /*       ARITH_BY_MODE     LABEL              INITMAX           MACRO      */
 /*       ARITH_OP(22)      BIT(16)            INITMOD           FIXED      */
 /*       ARRAY_INDEX_MOD   LABEL              INITMULT          BIT(16)    */
 /*       ARRAYNESS         BIT(16)            INITOP            BIT(16)    */
 /*       ARRAY2_INDEX_MOD  LABEL              INITREL(10)       BIT(16)    */
 /*       ASSIGN_CLEAR      LABEL              INITREPT(10)      BIT(16)    */
 /*       ASSIGN_HEAD(5)    BIT(16)            INITRESET         FIXED      */
 /*       ASSIGN_PARM_FLAG  BIT(8)             INITSTART         FIXED      */
 /*       ASSIGN_START(4)   BIT(16)            INITSTEP(10)      BIT(16)    */
 /*       ASSIGN_TYPES(23)  BIT(16)            INITSTRUCT        BIT(8)     */
 /*       AUX_CODE          BIT(16)            INITTYPE          BIT(16)    */
 /*       AUX_DECODE        LABEL              INITWALK          FIXED      */
 /*       AUX_FORM          BIT(16)            INTCALL           BIT(16)    */
 /*       AUX_LOC           BIT(16)            INTEGER_DIVIDE    LABEL      */
 /*       AUX_LOCATE        LABEL              INTEGER_VALUE     LABEL      */
 /*       AUX_NEXT          BIT(16)            INTEGER_VALUED    LABEL      */
 /*       AUX_SEARCH        LABEL              INTEGERIZABLE     LABEL      */
 /*       AUX_TAG           BIT(16)            INX(1)            MACRO      */
 /*       AVAILABLE_FROM_STORAGE  LABEL        INX_CON(1)        MACRO      */
 /*       BACKUP_REG(1)     MACRO              INX_MUL(1)        MACRO      */
 /*       BASE(1)           MACRO              INX_NEXT_USE(1)   MACRO      */
 /*       BESTAC            LABEL              INX_OK            BIT(8)     */
 /*       BIFCLASS(58)      BIT(16)            INX_SHIFT(1)      MACRO      */
 /*       BIFNAMES(31)      CHARACTER          INXMOD            BIT(16)    */
 /*       BIFNUM            MACRO              IOCONTROL(5)      CHARACTER  */
 /*       BIFOPCODE(58)     BIT(16)            ITYPES(4)         CHARACTER  */
 /*       BIFREG(3)         BIT(16)            KNOWN_SYM         LABEL      */
 /*       BIFTYPE(58)       BIT(16)            LAST_SUBSCRIPT    LABEL      */
 /*       BIT_MASK          LABEL              LEFT_DISJOINT     BIT(8)     */
 /*       BIT_PICK          LABEL              LEFT_NSEC         BIT(8)     */
 /*       BIT_SHIFT         LABEL              LIBNAME           CHARACTER  */
 /*       BIT_STORE         LABEL              LITERAL           LABEL      */
 /*       BIT_SUBSCRIPT     LABEL              LIVES_REMOTE(1)   MACRO      */
 /*       CALL_CONTEXT(20)  BIT(16)            LNON_IDENT        BIT(8)     */
 /*       CASE2SET(29)      BIT(8)             LOAD              BIT(16)    */
 /*       CHAR_CALL(12)     LABEL              LOAD_NUM          LABEL      */
 /*       CHAR_CONVERT      LABEL              LOAD_TEMP         LABEL      */
 /*       CHAR_SUBSCRIPT    LABEL              LOC(1)            MACRO      */
 /*       CHECK_ADDR_NEST   LABEL              LOC2(1)           MACRO      */
 /*       CHECK_AGGREGATE_ASSIGN  LABEL        LUMP_ARRAYSIZE    LABEL      */
 /*       CHECK_AND_DROP_VAC  LABEL            LUMP_TERMINALSIZE LABEL      */
 /*       CHECK_ASSIGN      LABEL              MAJOR_STRUCTURE   LABEL      */
 /*       CHECK_ASSIGN_PARM LABEL              MAKE_BIT_LIT      LABEL      */
 /*       CHECK_CSYM_INX    LABEL              MAKE_INST         LABEL      */
 /*       CHECK_LINKREG     LABEL              MARKER            LABEL      */
 /*       CHECK_LOCAL_SYM   LABEL              MASK_BIT_LIT      LABEL      */
 /*       CHECK_ATTRIBUTES  LABEL              MAT_ASSIGN        LABEL      */
 /*       CHECK_NAME_PARM   LABEL              MAT_EXPRESSION    LABEL      */
 /*       CHECK_REMOTE      LABEL              MAT_NEGATE        LABEL      */
 /*       CHECK_SI          LABEL              MAT_TEMP          LABEL      */
 /*       CHECK_SRCE        LABEL              MIDVAL            BIT(8)     */
 /*       CHECK_STRUCTURE_PARM  LABEL          MINUS             BIT(8)     */
 /*       CHECK_VAC         LABEL              MIX_ASSEMBLE      LABEL      */
 /*       CHECK_VM_ARG_DIMS LABEL              MOD_GET_OPERAND   LABEL      */
 /*       CHECKPOINT_REG    LABEL              MODE_MOD(17)      BIT(16)    */
 /*       CLASS1_OP         BIT(8)             MOVEREG           LABEL      */
 /*       CLASS3_OP         BIT(8)             NAME_OP_FLAG      BIT(8)     */
 /*       CLEAR_CALL_REGS   LABEL              NAME_SUB          BIT(8)     */
 /*       CLEAR_INX         LABEL              NAME_VAR(1)       MACRO      */
 /*       CLEAR_NAME_SAFE   LABEL              NEGLIT            BIT(8)     */
 /*       CLEAR_R           LABEL              NEW_REG           LABEL      */
 /*       COLUMN(1)         MACRO              NEW_USAGE         LABEL      */
 /*       COMMUTATIVE(22)   BIT(8)             NEWPREC(2)        BIT(16)    */
 /*       COMMUTEM          LABEL              NEXT_STACK        LABEL      */
 /*       COMPARE           BIT(16)            NEXT_USE(1)       MACRO      */
 /*       COMPARE_STRUCTURE LABEL              NEXTPOPCODE       LABEL      */
 /*       CONDITION(22)     BIT(8)             NONPART           BIT(8)     */
 /*       CONST(1)          MACRO              NSEC_CHECK        LABEL      */
 /*       COPY(1)           MACRO              NTOC              LABEL      */
 /*       COPY_REG_INFO     LABEL              OFF_INX           LABEL      */
 /*       COPY_STACK_ENTRY  LABEL              OFF_TARGET        LABEL      */
 /*       CSE_FLAG          BIT(8)             OK_TO_ASSIGN      BIT(8)     */
 /*       CTON              LABEL              OPER_PARM_FLAG    BIT(8)     */
 /*       CTRSET(29)        BIT(8)             OPER_STRUCT       BIT(8)     */
 /*       DATA_WIDTH        BIT(16)            OPER_SYMPTR       BIT(16)    */
 /*       DECODEPIP         LABEL              OPER_SYMPTR2      BIT(16)    */
 /*       DEL(1)            MACRO              OPSIZE            MACRO      */
 /*       DENSE_INX         BIT(16)            OPSTAT            LABEL      */
 /*       DENSESHIFT        BIT(16)            PARM_STAT         LABEL      */
 /*       DENSETYPE         BIT(16)            PART_SIZE         BIT(16)    */
 /*       DEREF             LABEL              POINTS_REMOTE(1)  MACRO      */
 /*       DESCENDENT        LABEL              POSITION_HALMAT   LABEL      */
 /*       DESTRUCTIVE(22)   BIT(8)             POWER_OF_TWO      LABEL      */
 /*       DIMFIX            LABEL              PREFIXMINUS       BIT(8)     */
 /*       DISP(1)           MACRO              RECVR             BIT(16)    */
 /*       DO_ASSIGNMENT     LABEL              RECVR_NEST_LEVEL  BIT(8)     */
 /*       DO_DSUB           LABEL              RECVR_OK          BIT(8)     */
 /*       DO_EXPRESSION     LABEL              RECVR_STRUCT      BIT(8)     */
 /*       DOAUX(20)         FIXED              RECVR_SYMPTR      BIT(16)    */
 /*       DOBASE            BIT(16)            RECVR_SYMPTR2     BIT(16)    */
 /*       DOBLK(5)          BIT(16)            REG(1)            MACRO      */
 /*       DOCASECTR         BIT(16)            REG_STAT          LABEL      */
 /*       DOCLOSE           LABEL              REGISTER_STATUS   LABEL      */
 /*       DOCTR(5)          BIT(16)            RELOAD_ADDRESSING LABEL      */
 /*       DOFLAG(20)        BIT(8)             REMOTE_RECVR      BIT(8)     */
 /*       DOFORCLBL         BIT(16)            RESUME_LOCCTR     LABEL      */
 /*       DOFORFINAL(20)    BIT(16)            RETURN_EXP_OR_FN  LABEL      */
 /*       DOFORINCR(20)     BIT(16)            RETURN_FLAG       BIT(8)     */
 /*       DOFORM(5)         BIT(16)            RETURN_STACK_ENTRIES  LABEL  */
 /*       DOFOROP(20)       BIT(16)            RETURN_STACK_ENTRY  LABEL    */
 /*       DOFORREG(20)      BIT(16)            REVERSE(22)       BIT(8)     */
 /*       DOINDEX(20)       BIT(16)            RI                BIT(16)    */
 /*       DOINX             BIT(16)            RIGHT_DISJOINT    BIT(8)     */
 /*       DOLABEL(20)       BIT(16)            RIGHT_NSEC        BIT(8)     */
 /*       DOLBL(20)         BIT(16)            RNON_IDENT        BIT(8)     */
 /*       DOLOOPS           MACRO              ROW(1)            MACRO      */
 /*       DONEST            MACRO              RR                BIT(16)    */
 /*       DOOPEN            LABEL              RS                BIT(16)    */
 /*       DOPTR(5)          BIT(16)            RTYPE             BIT(16)    */
 /*       DOPTR#            BIT(16)            RX                BIT(16)    */
 /*       DOPUSH(5)         BIT(8)             SAFE_INX          LABEL      */
 /*       DORANGE(20)       BIT(16)            SAME_REG_INFO     LABEL      */
 /*       DOSTEP(20)        BIT(16)            SAVE_ARG_STACK_PTR(20)  BIT(16)*/
 /*       DOTEMP(20)        BIT(16)            SAVE_CALL_LEVEL(20)  BIT(16) */
 /*       DOTEMPBLK(20)     BIT(16)            SAVE_FLOATING_REGS  LABEL    */
 /*       DOTEMPCTR(20)     BIT(16)            SAVE_LITERAL      LABEL      */
 /*       DOTOT(5)          BIT(16)            SAVE_REGS         LABEL      */
 /*       DOUNTIL(20)       BIT(16)            SDOLEVEL(5)       BIT(16)    */
 /*       DOVDLP(5)         BIT(8)             SDOPTR(5)         BIT(16)    */
 /*       DROP_BASE         LABEL              SDOTEMP(5)        BIT(16)    */
 /*       DROP_INX          LABEL              SEARCH_INDEX2     LABEL      */
 /*       DROP_PARM_STACK   LABEL              SEARCH_REGS       LABEL      */
 /*       DROP_REG          LABEL              SET_AREA          LABEL      */
 /*       DROP_UNUSED       LABEL              SET_ARRAY_SIZE    LABEL      */
 /*       DROP_VAC          LABEL              SET_BINDEX        LABEL      */
 /*       DROPFREESPACE     LABEL              SET_CHAR_DESC     LABEL      */
 /*       DROPLIST          LABEL              SET_CHAR_INX      LABEL      */
 /*       DROPOUT           LABEL              SET_CINDEX        LABEL      */
 /*       DROPSAVE          LABEL              SET_DOPTRS        LABEL      */
 /*       DROPTEMP          LABEL              SET_EVENT_OPERAND LABEL      */
 /*       DUMP_STACK        LABEL              SET_LABEL         LABEL      */
 /*       DUPLICATE_OPERANDS  LABEL            SET_NAME_TYPE     LABEL      */
 /*       EMIT_ARRAY_DO     LABEL              SET_NEXT_USE      LABEL      */
 /*       EMIT_BY_MODE      LABEL              SET_OPERAND       LABEL      */
 /*       EMIT_CALL         LABEL              SET_REG_NEXT_USE  LABEL      */
 /*       EMIT_EVENT_EXPRESSION  LABEL         SET_RESULT_REG    LABEL      */
 /*       EMIT_Z_CON        LABEL              SET_USAGE         LABEL      */
 /*       EMITBFW           LABEL              SETUP_ADCON       LABEL      */
 /*       EMITDELTA         LABEL              SETUP_BOOLEAN     LABEL      */
 /*       EMITEVENTADDR     LABEL              SETUP_DSUB_CSE    LABEL      */
 /*       EMITLFW           LABEL              SETUP_INX         LABEL      */
 /*       EMITOP            LABEL              SETUP_VAC         LABEL      */
 /*       EMITP             LABEL              SF_RANGE(20)      BIT(16)    */
 /*       EMITPCEADDR       LABEL              SGNLNAME(2)       BIT(16)    */
 /*       EMITPFW           LABEL              SHIFTOP(1)        BIT(16)    */
 /*       EMITRR            LABEL              SHOULD_COMMUTE    LABEL      */
 /*       EMITRX            LABEL              SIZE              MACRO      */
 /*       EMITSI            LABEL              SIZEFIX           LABEL      */
 /*       EMITSIOP          LABEL              SIZE3(29)         BIT(8)     */
 /*       EMITSP            LABEL              SKIP_NOP          LABEL      */
 /*       EMITXOP           LABEL              SLA               MACRO      */
 /*       ENTER_CALL        LABEL              SORD(1)           CHARACTER  */
 /*       ENTER_CHAR_LIT    LABEL              SRCEPART_SIZE     BIT(16)    */
 /*       ERR_DISP(100)     BIT(16)            STACK_EVENT       LABEL      */
 /*       ERR_STACK(100)    BIT(16)            STACK_PARM        LABEL      */
 /*       ERRALL(255)       BIT(16)            STACK_REG_PARM    LABEL      */
 /*       ERRCALL           LABEL              STACK_STATUS      LABEL      */
 /*       ERRPTR(255)       BIT(16)            STACK_TARGET      LABEL      */
 /*       EV_EXP(15)        BIT(8)             START_OFF         FIXED      */
 /*       EV_EXPTR          BIT(16)            START_PART        FIXED      */
 /*       EV_EXPTR_MAX      MACRO              STATIC_BLOCK      LABEL      */
 /*       EV_OP(5)          BIT(16)            STMT_PREC         BIT(16)    */
 /*       EV_PTR            BIT(16)            STORE             BIT(16)    */
 /*       EV_PTR_MAX        MACRO              STRUCT(1)         MACRO      */
 /*       EVALUATE          LABEL              STRUCT_CON(1)     MACRO      */
 /*       EXOR              BIT(16)            STRUCT_INX(1)     MACRO      */
 /*       EXPONENTIAL       LABEL              STRUCT_MOD(1)     FIXED      */
 /*       EXPRESSION        LABEL              STRUCT_REF(1)     BIT(16)    */
 /*       EXTOP             BIT(16)            STRUCT_TEMPL(1)   BIT(16)    */
 /*       FETCH_VAC         LABEL              STRUCTFIX         LABEL      */
 /*       FILECONTROL(1)    CHARACTER          STRUCTOP          MACRO      */
 /*       FINDAC            LABEL              STRUCTURE_ADVANCE LABEL      */
 /*       FIX_STRUCT_INX    LABEL              STRUCTURE_COMPARE LABEL      */
 /*       FIX_TERM_INX      LABEL              STRUCTURE_DECODE  LABEL      */
 /*       FORCE_ACCUMULATOR LABEL              SUB#              BIT(16)    */
 /*       FORCE_ADDRESS     LABEL              SUBLIMIT(20)      BIT(16)    */
 /*       FORCE_ARRAY_SIZE  LABEL              SUBOP             BIT(16)    */
 /*       FORCE_BY_MODE     LABEL              SUBRANGE(20)      BIT(16)    */
 /*       FORCE_NUM         LABEL              SUBSCRIPT_MULT    LABEL      */
 /*       FORM(1)           MACRO              SUBSCRIPT_RANGE_CHECK  LABEL */
 /*       FORM_CHARNAME     CHARACTER          SUBSCRIPT2_MULT   LABEL      */
 /*       FORM_VMNAME       CHARACTER          SUBSTRUCT_FLAG    BIT(8)     */
 /*       FORMAT_OPERANDS   LABEL              SUCCESSOR         LABEL      */
 /*       FREE_ARRAYNESS    LABEL              SUM               BIT(8)     */
 /*       GEN_CLASS0        LABEL              SWAP_REG_INFO     LABEL      */
 /*       GEN_CLASS1(2134)  LABEL              SYT_COPIES        LABEL      */
 /*       GEN_CLASS2(2167)  LABEL              TAG_BITS          LABEL      */
 /*       GEN_CLASS3        LABEL              TERMFLAG          BIT(8)     */
 /*       GEN_CLASS4(2181)  LABEL              TEST              BIT(8)     */
 /*       GEN_CLASS5        LABEL              TO_BE_INCORPORATED  BIT(8)   */
 /*       GEN_CLASS6(5)     LABEL              TO_BE_MODIFIED    BIT(8)     */
 /*       GEN_CLASS7        LABEL              TRUE_INX          LABEL      */
 /*       GEN_CLASS8        LABEL              TYPE(1)           MACRO      */
 /*       GEN_STORE         LABEL              TYPE_BITS         LABEL      */
 /*       GENCALL           LABEL              TYPES(8)          CHARACTER  */
 /*       GENEVENTADDR      LABEL              UNARY(22)         BIT(8)     */
 /*       GENLIBCALL        LABEL              UNARYOP           LABEL      */
 /*       GENSI             LABEL              UNRECOGNIZABLE    LABEL      */
 /*       GENSVC            LABEL              UPDATE_ASSIGN_CHECK  LABEL   */
 /*       GENSVCADDR        LABEL              UPDATE_CHECK      LABEL      */
 /*       GET_ARRAY_TEMP    LABEL              UPDATE_INX_USAGE  LABEL      */
 /*       GET_ASIZ          LABEL              VAC_ARRAY_TEMP(1) LABEL      */
 /*       GET_CHAR_OPERANDS LABEL              VAC_COPIES        LABEL      */
 /*       GET_CSIZ          LABEL              VAC_FLAG          BIT(8)     */
 /*       GET_INTEGER_LITERAL  LABEL           VAL(1)            MACRO      */
 /*       GET_LIT_ONE       LABEL              VALMOD            BIT(16)    */
 /*       GET_OPERAND       LABEL              VALMUL            BIT(16)    */
 /*       GET_OPERANDS      LABEL              VECMAT_ASN        LABEL      */
 /*       GET_R             LABEL              VECMAT_ASSIGN     LABEL      */
 /*       GET_RECVR_INFO    LABEL              VECMAT_CONVERT    LABEL      */
 /*       GET_STACK_ENTRY   LABEL              VERIFY_INX_USAGE  LABEL      */
 /*       GET_SUBSCRIPT     LABEL              VM_COPIES         LABEL      */
 /*       GET_VAC           LABEL              VMCALL(29)        LABEL      */
 /*       GET_VM_TEMP       LABEL              VMCOPY(1)         MACRO      */
 /*       GETFREESPACE      LABEL              VMOPSIZE          MACRO      */
 /*       GETFREETEMP       LABEL              VMREMOTEOP(29)    BIT(8)     */
 /*       GETINVTEMP        LABEL              WAITNAME(3)       BIT(16)    */
 /*       GETSTMTLBL        LABEL              X_BITS            LABEL      */
 /*       GUARANTEE_ADDRESSABLE  LABEL         XITAB(32)         FIXED      */
 /*       IDENT_DISJOINT_CHECK  LABEL          XVAL(1)           MACRO      */
 /*       INCORPORATE       LABEL              YCON_TO_ZCON      LABEL      */
 /*       INCR_REG          LABEL                                           */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*       ADCON                                MATRIX                       */
 /*       AIDX                                 MAX_SEVERITY                 */
 /*       AIDX2                                MAXERR                       */
 /*       APOINTER                             MH                           */
 /*       ARG_STACK#                           MHI                          */
 /*       ASIZ                                 MIH                          */
 /*       A                                    MR                           */
 /*       ADDR_FIXED_LIMIT                     MSTH                         */
 /*       ADDR_FIXER                           MVH                          */
 /*       ADDR_ROUNDER                         NAME_FLAG                    */
 /*       AH                                   NAME_OR_REMOTE               */
 /*       AHI                                  NAMESTORE                    */
 /*       ALWAYS                               NAMETYPE                     */
 /*       ANY_LABEL                            NARGS                        */
 /*       AP101INST                            NEGMAX                       */
 /*       AR                                   NEQ                          */
 /*       ARRAY_LABEL                          NEW_GLOBAL_BASE              */
 /*       ASSEMBLER_CODE                       NEW_INSTRUCTIONS             */
 /*       ASSIGN_FLAG                          NEW_LOCAL_BASE               */
 /*       ASSIGN_OR_NAME                       NEW_STACK_LOC                */
 /*       AUTO_FLAG                            NHI                          */
 /*       AUXMAT_REQUESTED                     NIST                         */
 /*       AUX                                  NO_VM_OPT                    */
 /*       BAL                                  NONHAL_FLAG                  */
 /*       BALR                                 NOT_LEAF                     */
 /*       BASE_USED                            NULL_ADDR                    */
 /*       BC                                   OFF_PAGE_BASE                */
 /*       BCF                                  OFF_PAGE_LAST                */
 /*       BCR                                  OFF_PAGE_LINE                */
 /*       BCRE                                 OFF_PAGE_MAX                 */
 /*       BCT                                  OFF_PAGE_NEXT                */
 /*       BCTB                                 OFF_PAGE_TAB                 */
 /*       BIGHTS                               OFFSET                       */
 /*       BIGNUMBER                            OFFSET                       */
 /*       BINARY_CODE                          OHI                          */
 /*       BITESIZE                             OLD_LINKAGE                  */
 /*       BITMASK_FLAG                         OPCC                         */
 /*       BITS                                 OPERATOR                     */
 /*       BIX                                  OPMODE                       */
 /*       BLANK                                OPR                          */
 /*       BLOCK_CLASS                          PACKFORM                     */
 /*       BOOLEAN                              PACKFUNC_CLASS               */
 /*       CALL_LEVEL#                          PACKTYPE                     */
 /*       CALL#                                PADDR                        */
 /*       CHAR                                 PARM_FLAGS                   */
 /*       CHARLIT                              PCEBASE                      */
 /*       CHARSUBBIT                           PDELTA                       */
 /*       CH                                   PLBL                         */
 /*       CHARTYPE                             PLUS                         */
 /*       CHI                                  PM_FLAGS                     */
 /*       CLASS_B                              POINTER_FLAG                 */
 /*       CLASS_BS                             POINTER_OR_NAME              */
 /*       CLASS_BX                             PRELBASE                     */
 /*       CLASS_D                              PRIMARY                      */
 /*       CLASS_DI                             PROC_LEVEL                   */
 /*       CLASS_DQ                             PROC#                        */
 /*       CLASS_DU                             PROCBASE                     */
 /*       CLASS_E                              PROG_LABEL                   */
 /*       CLASS_EA                             PROGBASE                     */
 /*       CLASS_F                              PROGPOINT                    */
 /*       CLASS_FD                             PROLOG                       */
 /*       CLASS_FN                             PTRARG1                      */
 /*       CLASS_FT                             QUOTE                        */
 /*       CLASS_PE                             R_BASE                       */
 /*       CLASS_PF                             R_BASE_USED                  */
 /*       CLASS_QD                             R_SECTION                    */
 /*       CLASS_SR                             RCLASS_START                 */
 /*       CLASS_XQ                             RCLASS                       */
 /*       CLASS_XS                             READCTR                      */
 /*       CLASS_ZB                             REENTRANT_FLAG               */
 /*       CLASS_ZC                             REG_NUM                      */
 /*       CLASS_ZO                             REGISTER_SAVE_AREA           */
 /*       CLASS_ZP                             REGISTER_TRACE               */
 /*       CLASS_ZS                             REGISTERS                    */
 /*       CLBL                                 RELATIONAL                   */
 /*       CMPUNIT_ID                           REMOTE_BASE                  */
 /*       COLON                                REMOTE_LEVEL                 */
 /*       COMMA                                REMOTE                       */
 /*       COMPACT_CODE                         REMOTE_FLAG                  */
 /*       COMPOOL_LABEL                        RESTART                      */
 /*       COMPOOL#P                            RIGHTBRACKET                 */
 /*       CONST_ATOMS                          RLD                          */
 /*       CONST_DW                             RM                           */
 /*       CONST_LIM                            RPOINTER                     */
 /*       CR_REF                               RRTYPE                       */
 /*       CROSS_REF                            RXTYPE                       */
 /*       CSECT                                R3                           */
 /*       CSECT_LENGTHS                        SB                           */
 /*       CSIZ                                 SCALAR                       */
 /*       CSTRING                              SCAL                         */
 /*       CSYM                                 SDINDEX                      */
 /*       CVFL                                 SDL                          */
 /*       CVFX                                 SDR                          */
 /*       CVTTYPE                              SECTION                      */
 /*       DADDR                                SELECTYPE                    */
 /*       DATA_LIST                            SELF_ALIGNING                */
 /*       DATA_REMOTE                          SELFNAMELOC                  */
 /*       DATABASE                             SER                          */
 /*       DATABLK                              SHCOUNT                      */
 /*       DATATYPE                             SHIFT                        */
 /*       DEFINED_LABEL                        SHW                          */
 /*       DELTA                                SLDL                         */
 /*       DENSE_FLAG                           SLL                          */
 /*       DENSEADDR                            SM_FLAGS                     */
 /*       DENSEVAL                             SMADDR                       */
 /*       DESC                                 SPM                          */
 /*       DIAGNOSTICS                          SRA                          */
 /*       DINTEGER                             SRDA                         */
 /*       DNSADDR                              SRET                         */
 /*       DNSVAL                               SRL                          */
 /*       DOSIZE                               SRSTYPE                      */
 /*       DOUBLE_ACC                           SSTYPE                       */
 /*       DOUBLE_FACC                          STADDR                       */
 /*       DOUBLEFLAG                           STMTNO                       */
 /*       DSCALAR                              STNO                         */
 /*       DSECLR                               STRUCTURE                    */
 /*       DSESET                               ST                           */
 /*       DSR                                  STACK_DUMP                   */
 /*       DW                                   STACK_LINK                   */
 /*       ENDSCOPE_FLAG                        STACKADDR                    */
 /*       ENV_BASE                             STACKPOINT                   */
 /*       ENV_NUM                              STACKVAL                     */
 /*       EQ                                   STH                          */
 /*       ERRALLGRP                            STM                          */
 /*       ERRSEG                               STMT_LABEL                   */
 /*       ESD_LIMIT                            SUBSCRIPT_TRACE              */
 /*       ESD_TYPE                             SVC                          */
 /*       EVENT                                SYM                          */
 /*       EVIL_FLAGS                           SYM_ADDR                     */
 /*       EXCLBASE                             SYM_ARRAY                    */
 /*       EXCLUSIVE#                           SYM_BASE                     */
 /*       EXT_ARRAY                            SYM_CLASS                    */
 /*       EXTENT                               SYM_CONST                    */
 /*       EXTRABIT                             SYM_DISP                     */
 /*       EXTSYM                               SYM_FLAGS                    */
 /*       EZ                                   SYM_LENGTH                   */
 /*       FALSE                                SYM_LEVEL                    */
 /*       FIRSTREMOTE                          SYM_LINK1                    */
 /*       FIXARG1                              SYM_LINK2                    */
 /*       FIXARG2                              SYM_LOCK#                    */
 /*       FIXARG3                              SYM_NAME                     */
 /*       FIXED_ACC                            SYM_NEST                     */
 /*       FLNO                                 SYM_PARM                     */
 /*       FLOATING_ACC                         SYM_PTR                      */
 /*       FOR                                  SYM_SCOPE                    */
 /*       FOREVER                              SYM_TYPE                     */
 /*       FR0                                  SYM_XREF                     */
 /*       FR2                                  SYMFORM                      */
 /*       FR4                                  SYM2                         */
 /*       FR7                                  SYSARG0                      */
 /*       FSIMBASE                             SYSARG1                      */
 /*       FULLBIT                              SYSARG2                      */
 /*       GQ                                   SYT_ADDR                     */
 /*       GT                                   SYT_ARRAY                    */
 /*       HADDR                                SYT_BASE                     */
 /*       HALFMAX                              SYT_CLASS                    */
 /*       HALFMIN                              SYT_CONST                    */
 /*       HALFWORDSIZE                         SYT_DIMS                     */
 /*       HALMAT_OPCODE                        SYT_DISP                     */
 /*       HALMAT_REQUESTED                     SYT_FLAGS                    */
 /*       I_BACKUP_REG                         SYT_LABEL                    */
 /*       I_BASE                               SYT_LEVEL                    */
 /*       I_COLUMN                             SYT_LINK1                    */
 /*       I_CONST                              SYT_LINK2                    */
 /*       I_COPY                               SYT_LOCK#                    */
 /*       I_CSE_USE                            SYT_NAME                     */
 /*       I_DEL                                SYT_NEST                     */
 /*       I_DISP                               SYT_PARM                     */
 /*       I_DSUBBED                            SYT_PTR                      */
 /*       I_FORM                               SYT_SCOPE                    */
 /*       I_INX_CON                            SYT_TYPE                     */
 /*       I_INX                                SYT_XREF                     */
 /*       I_INX_MUL                            TAB_OFF_PAGE                 */
 /*       I_INX_NEXT_USE                       TASK_LABEL                   */
 /*       I_INX_SHIFT                          TB                           */
 /*       I_LIVREMT                            TD                           */
 /*       I_LOC                                TEMPBASE                     */
 /*       I_LOC2                               TEMPLATE_CLASS               */
 /*       I_NAMEVAR                            TEMPORARY_FLAG               */
 /*       I_NEXT_USE                           TH                           */
 /*       I_PNTREMT                            TRACING                      */
 /*       I_REG                                TRB                          */
 /*       I_ROW                                TRUE                         */
 /*       I_STRUCT_CON                         TS                           */
 /*       I_STRUCT                             TYP_SIZE                     */
 /*       I_STRUCT_INX                         ULBL                         */
 /*       I_TYPE                               UNIMPLEMENTED                */
 /*       I_VAL                                UPDATE_FLAGS                 */
 /*       I_VMCOPY                             VAC                          */
 /*       I_XVAL                               VALS                         */
 /*       IAL                                  VDLP_DETECTED                */
 /*       IHL                                  VECMAT                       */
 /*       IMD                                  VECTOR                       */
 /*       INCLUDED_REMOTE                                                   */
 /*       IND_CALL_LAB                         WORDSIZE                     */
 /*       INDEX_REG                            WORK                         */
 /*       INDEXING                             WORKSEG                      */
 /*       INL                                  XADD                         */
 /*       INTEGER                              XBTRU                        */
 /*       INTSCA                               XCSIO                        */
 /*       IODEV                                XCSLD                        */
 /*       LASTEMP                              XCSST                        */
 /*       LBL                                  XDIV                         */
 /*       LIT                                  XDLPE                        */
 /*       LOCREL                               XEQU                         */
 /*       LOGICAL                              XEXP                         */
 /*       L                                    XEXTN                        */
 /*       LA                                   XFILE                        */
 /*       LABEL_ARRAY                          XIMRK                        */
 /*       LATCH_FLAG                           XMASN                        */
 /*       LCR                                  XMDET                        */
 /*       LDM                                  XMEXP                        */
 /*       LEFTBRACKET                          XMIDN                        */
 /*       LER                                  XMINV                        */
 /*       LFLI                                 XMTRA                        */
 /*       LFXI                                 XMVPR                        */
 /*       LH                                   XNOT                         */
 /*       LHI                                  XOR                          */
 /*       LIB_INDEX                            XPASN                        */
 /*       LIB_TABLE                            XPEX                         */
 /*       LINE_OFF_PAGE                        XPT                          */
 /*       LINK_LOCATION                        XR                           */
 /*       LINKREG                              XREF                         */
 /*       LIT_CHAR_ADDR                        XSASN                        */
 /*       LIT_CHAR_USED                        XSFAR                        */
 /*       LIT_NDX                              XSMRK                        */
 /*       LIT_PG                               XTASN                        */
 /*       LITERAL1                             XTNT                         */
 /*       LITERAL2                             XVDLE                        */
 /*       LITERAL3                             XVDLP                        */
 /*       LIT1                                 XVMIO                        */
 /*       LIT2                                 XXASN                        */
 /*       LIT3                                 XXXAR                        */
 /*       LM                                   X2                           */
 /*       LOCAL#D                              X3                           */
 /*       LOCAT                                X4                           */
 /*       LOCATION                             X72                          */
 /*       LOCATION_LINK                        Z_LINKAGE                    */
 /*       LOCK_BITS                            ZADDR                        */
 /*       LQ                                   ZH                           */
 /*       LR                                   ZRB                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*       ADDRS_ISSUED                         MAXTEMP                      */
 /*       AREASAVE                             MESSAGE                      */
 /*       AREA                                 NARGINDEX                    */
 /*       ARG_STACK_PTR                        NEXTCTR                      */
 /*       ARG#                                 NOT_THIS_REGISTER            */
 /*       ARGNO                                NUMOP                        */
 /*       ARGPOINT                             OFF_PAGE_CTR                 */
 /*       ARGTYPE                              OPCODE                       */
 /*       ARRAY_FLAG                           OPCOUNT                      */
 /*       ARRAYPOINT                           OPTYPE                       */
 /*       ARRCONST                             OP1                          */
 /*       ASNCTR                               OP2                          */
 /*       AUX_CTR                              ORIGIN                       */
 /*       BASE_REGS                            PAGE_FIX                     */
 /*       BNOT_FLAG                            PMINDEX                      */
 /*       BOOL_COUNT                           POINT                        */
 /*       CALL_LEVEL                           PROC_LINK                    */
 /*       CCREG                                PROGDATA                     */
 /*       CHARSTRING                           P2SYMS                       */
 /*       CLASS                                R_CON                        */
 /*       COMM                                 R_CONTENTS                   */
 /*       CONSTANT_CTR                         R_INX                        */
 /*       CONSTANT_HEAD                        R_INX_CON                    */
 /*       CONSTANT_PTR                         R_INX_SHIFT                  */
 /*       CONSTANT_REFS                        R_MULT                       */
 /*       CONSTANTS                            R_PARM                       */
 /*       COPT                                 R_PARM#                      */
 /*       CTR                                  R_TYPE                       */
 /*       CURCBLK                              R_VAR                        */
 /*       D_MVH_SOURCE                         R_VAR2                       */
 /*       D_RTL_SETUP                          R_XCON                       */
 /*       D_R3_CHANGE                          REMOTE_ADDRS                 */
 /*       DECLMODE                             RESET                        */
 /*       DNS                                  RESULT                       */
 /*       DOCOPY                               RIGHTOP                      */
 /*       DOLEVEL                              R0                           */
 /*       DOTYPE                               R1                           */
 /*       DOUBLE_TYPE                          SAVED_LINE                   */
 /*       DUMMY                                SAVEPOINT                    */
 /*       ENV_LBL                              SAVEPTR                      */
 /*       ENV_PTR                              SECONDLABEL                  */
 /*       ESD_LINK                             SF_DISP                      */
 /*       ESD_MAX                              SF_RANGE_PTR                 */
 /*       ESD_START                            SRS_REFS                     */
 /*       FIRSTLABEL                           STACK_MAX                    */
 /*       FOR_ATOMS                            STACK_PTR                    */
 /*       FOR_DW                               STACK#                       */
 /*       FULLTEMP                             STMTNUM                      */
 /*       GENERATING                           STOPPERFLAG                  */
 /*       IND_STACK                            STRI_ACTIVE                  */
 /*       INDEXNEST                            SUBCODE                      */
 /*       INDEX                                SYM_TAB                      */
 /*       INFO                                 TAG1                         */
 /*       INLINE_RESULT                        TAG                          */
 /*       INSMOD                               TAGS                         */
 /*       IOMODE                               TAG2                         */
 /*       IX1                                  TAG3                         */
 /*       IX2                                  TARGET_REGISTER              */
 /*       KIN                                  TARGET_R                     */
 /*       LAB_LOC                              TEMPSPACE                    */
 /*       LAST_FLOW_BLK                        TEMP2                        */
 /*       LAST_FLOW_CTR                        TMP                          */
 /*       LAST_STACK_HEADER                    UPDATING                     */
 /*       LAST_TAG                             UPPER                        */
 /*       LASTLABEL                            USAGE                        */
 /*       LASTRESULT                           USAGE_LINE                   */
 /*       LEFTOP                               VDLP_ACTIVE                  */
 /*       LHSPTR                               VDLP_IN_EFFECT               */
 /*       LIB_POINTER                          WORK_BLK                     */
 /*       LINE#                                WORK_CTR                     */
 /*       LITTYPE                              WORK_USAGE                   */
 /*       LOCCTR                               WORK1                        */
 /*       LOWER                                WORK2                        */
 /*       MARKER_ISSUED                                                     */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*       ADJUST                               GETARRAYDIM                  */
 /*       AUX_LINE                             GETSTATNO                    */
 /*       AUX_OP                               HASH                         */
 /*       AUX_SYNC                             HEX                          */
 /*       CHAR_INDEX                           HEX_LOCCTR                   */
 /*       CHECK_SRS                            INSTRUCTION                  */
 /*       CHECKSIZE                            INTRINSIC                    */
 /*       CLEAR_REGS                           MAX                          */
 /*       CSECT_TYPE                           MIN                          */
 /*       CS                                   NAMESIZE                     */
 /*       DECODEPOP                            NEED_STACK                   */
 /*       EMIT_BRANCH_AROUND                   NEW_HALMAT_BLOCK             */
 /*       EMIT_NOP                             NEXTCODE                     */
 /*       EMITADDR                             NO_BRANCH_AROUND             */
 /*       EMITC                                OPTIMISE                     */
 /*       EMITSTRING                           POPCODE                      */
 /*       EMITW                                POPNUM                       */
 /*       ENTER_ESD                            POPTAG                       */
 /*       ERRORS                               SAVE_BRANCH_AROUND           */
 /*       ESD_TABLE                            SET_LINKREG                  */
 /*       FORMAT                               SET_LOCCTR                   */
 /*       GET_AUX                              SET_MASKING_BIT              */
 /*       GET_LITERAL                          SINGLE_VALUED                */
 /*       GETARRAY#                                                         */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> GENERATE <==                                                        */
 /*     ==> CSECT_TYPE                                                      */
 /*     ==> SINGLE_VALUED                                                   */
 /*     ==> MAX                                                             */
 /*     ==> MIN                                                             */
 /*     ==> CHAR_INDEX                                                      */
 /*     ==> FORMAT                                                          */
 /*     ==> HEX                                                             */
 /*     ==> HASH                                                            */
 /*     ==> INSTRUCTION                                                     */
 /*         ==> CHAR_INDEX                                                  */
 /*         ==> PAD                                                         */
 /*     ==> ESD_TABLE                                                       */
 /*     ==> ENTER_ESD                                                       */
 /*         ==> PAD                                                         */
 /*     ==> HEX_LOCCTR                                                      */
 /*         ==> HEX                                                         */
 /*     ==> POPCODE                                                         */
 /*     ==> POPNUM                                                          */
 /*     ==> POPTAG                                                          */
 /*     ==> DECODEPOP                                                       */
 /*         ==> FORMAT                                                      */
 /*         ==> HEX                                                         */
 /*         ==> POPCODE                                                     */
 /*         ==> POPNUM                                                      */
 /*         ==> POPTAG                                                      */
 /*     ==> GET_AUX                                                         */
 /*     ==> AUX_LINE                                                        */
 /*         ==> GET_AUX                                                     */
 /*     ==> NEW_HALMAT_BLOCK                                                */
 /*         ==> POPNUM                                                      */
 /*     ==> AUX_OP                                                          */
 /*         ==> GET_AUX                                                     */
 /*     ==> AUX_SYNC                                                        */
 /*         ==> GET_AUX                                                     */
 /*         ==> AUX_LINE ****                                               */
 /*         ==> AUX_OP ****                                                 */
 /*     ==> NEXTCODE                                                        */
 /*         ==> DECODEPOP ****                                              */
 /*         ==> AUX_SYNC ****                                               */
 /*     ==> GET_LITERAL                                                     */
 /*         ==> MAX                                                         */
 /*     ==> SET_LINKREG                                                     */
 /*     ==> CLEAR_REGS                                                      */
 /*         ==> SET_LINKREG                                                 */
 /*     ==> CHECK_SRS                                                       */
 /*     ==> ADJUST                                                          */
 /*     ==> CS                                                              */
 /*     ==> EMITC                                                           */
 /*         ==> FORMAT                                                      */
 /*         ==> HEX                                                         */
 /*         ==> HEX_LOCCTR ****                                             */
 /*         ==> GET_CODE                                                    */
 /*     ==> EMITW                                                           */
 /*         ==> HEX                                                         */
 /*         ==> HEX_LOCCTR ****                                             */
 /*         ==> GET_CODE                                                    */
 /*     ==> EMITSTRING                                                      */
 /*         ==> CS                                                          */
 /*         ==> EMITC ****                                                  */
 /*         ==> EMITW ****                                                  */
 /*     ==> SET_LOCCTR                                                      */
 /*         ==> EMITC ****                                                  */
 /*         ==> EMITW ****                                                  */
 /*     ==> EMITADDR                                                        */
 /*         ==> EMITC ****                                                  */
 /*         ==> EMITW ****                                                  */
 /*     ==> EMIT_NOP                                                        */
 /*         ==> EMITC ****                                                  */
 /*         ==> EMITW ****                                                  */
 /*     ==> SAVE_BRANCH_AROUND                                              */
 /*         ==> EMIT_NOP                                                    */
 /*             ==> EMITC ****                                              */
 /*             ==> EMITW ****                                              */
 /*     ==> EMIT_BRANCH_AROUND                                              */
 /*         ==> EMITC ****                                                  */
 /*         ==> EMITW ****                                                  */
 /*     ==> NO_BRANCH_AROUND                                                */
 /*         ==> EMIT_NOP                                                    */
 /*             ==> EMITC ****                                              */
 /*             ==> EMITW ****                                              */
 /*     ==> NEED_STACK                                                      */
 /*         ==> NO_BRANCH_AROUND ****                                       */
 /*     ==> ERRORS                                                          */
 /*         ==> NEXTCODE                                                    */
 /*             ==> DECODEPOP ****                                          */
 /*             ==> AUX_SYNC ****                                           */
 /*         ==> RELEASETEMP                                                 */
 /*             ==> SETUP_STACK                                             */
 /*             ==> CLEAR_REGS ****                                         */
 /*         ==> COMMON_ERRORS                                               */
 /*     ==> CHECKSIZE                                                       */
 /*         ==> ERRORS ****                                                 */
 /*     ==> INTRINSIC                                                       */
 /*         ==> LIB_LOOK                                                    */
 /*             ==> HASH                                                    */
 /*     ==> GETSTATNO                                                       */
 /*         ==> ERRORS ****                                                 */
 /*     ==> GETARRAYDIM                                                     */
 /*     ==> GETARRAY#                                                       */
 /*     ==> NAMESIZE                                                        */
 /*     ==> SET_MASKING_BIT                                                 */
 /*         ==> PTR_LOCATE                                                  */
 /*         ==> LOCATE                                                      */
 /*         ==> ERRORS ****                                                 */
 /*     ==> OPTIMISE                                                        */
 /*         ==> POPCODE                                                     */
 /*         ==> POPNUM                                                      */
 /*         ==> POPTAG                                                      */
 /*         ==> EMITC ****                                                  */
 /*         ==> ERRORS ****                                                 */
 /*                                                                         */
 /*                                                                         */
 /*  **** - BRANCH PREVIOUSLY EXPANDED                                      */
 /***************************************************************************/
 /*  REVISION HISTORY :                                                     */
 /*  ------------------                                                     */
 /*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */
 /*                                                                         */
 /*07/26/90 RPC   23V1  102954 NAME REMOTE COMPARISON INCORRECT OBJ CODE    */
 /*                                                                         */
 /*07/26/90 RPC   23V1  102951 NAME ASSIGNMENT ILLEGALLY GENERATING IAL     */
 /*                                                                         */
 /*08/03/90 RPC   23V1  102971 %COPY OF A REMOTE NAME                       */
 /*                                                                         */
 /*08/17/90 RPC   23V1  103753 EXTRA CODE "SLL" GENERATED BY COMPILER       */
 /*                                                                         */
 /*08/24/90 RAH   23V1  102961 LOAD ADDRESS (LA) USED FOR REMOTE ADDRESSES  */
 /*                     IN %NAMEADD                                         */
 /*                                                                         */
 /*10/08/90 DAS   23V1  103659 INEFFICIENT CODE GENERATED BY COMPILER       */
 /*                                                                         */
 /*10/12/90 RAH   23V1  102965 %NAMECOPY FAILS TO GENERATE FT111 ERROR MSG  */
 /*                                                                         */
 /*10/15/90 LWW   23V1  103754 EXTRA CODE "SER" GENERATED BY COMPILER       */
 /*                                                                         */
 /*10/23/90 DAS   23V1  11053  (CR) RESTRICT RUNTIME LIBRARY USE            */
 /*                                                                         */
 /*11/16/90 RPC   23V1  102965 UPDATE TO CORRECT DQ101 ERROR                */
 /*                                                                         */
 /*11/16/90 DAS   23V1  103753 PART2: FIX INCORRECT INDEX VALUES            */
 /*                                                                         */
 /*01/25/91 DKB   23V2  CR11098 DELETE SPILL CODE FROM COMPILER             */
 /*                                                                         */
 /*03/04/91 RAH   23V2  CR11109 CLEANUP OF COMPILER SOURCE CODE             */
 /*                                                                         */
 /*07/08/91 RSJ   24V0  CR11096 #DFLAG - ADD LOGIC TO SUPPORT THE           */
 /*                             REQUIREMENT THAT COMSUBS COMPILED           */
 /*                             WITH DATA_REMOTE HAVE REMOTE FLAG SET       */
 /*                                                                         */
 /*07/15/91 DAS   24V0  CR11096 #DDSE -  CLEAR DSES BEFORE SCAL,            */
 /*                             SET DSES UPON RETURN                        */
 /*                                                                         */  14600006
 /*07/15/91 DAS   24V0  CR11096 #DNAME - CONVERT YCON TO ZCON (DR103750)    */  14610006
 /*                             & SET LIVES_REMOTE FOR #D DATA              */  14620006
 /*                                                                         */
 /*07/15/91 DAS   24V0  CR11096 #DPARM - RESTRICT #D PASS-BY-REFERENCE      */
 /*                             PARAMETERS, & CONVERT TO ZCON OR COPY       */
 /*                             TO STACK BEFORE PASSING TO RTL              */
 /*                                                                         */
 /*07/15/91 DAS   24V0  CR11096 #DREG - NEW #D REGISTER ALLOCATION:         */
 /*                             R1 OR R3 FOR #D, R2 OTHERWISE               */
 /*                                                                         */
 /*07/15/91 DAS   24V0  108601 LDM GETS CLOBBERED IN AP101INST BECAUSE      */
 /*                            (-1) USED AS INDEX INTO REGISTER TABLE       */
 /*                                                                         */
 /*09/23/91 DAS   24V0  105112 REMOVE BAD FIX FROM OLD DR102971 :           */  14701007
 /*                            NAME REMOTE IN %COPY SHOULD GET BX114        */  14702007
 /*                                                                         */  14703007
 /*05/05/92 JAC    7V0  CR11114 MERGE BFS/PASS COMPILERS                    */
 /*                                                                         */
 /*09/09/92 JAC    7V0  CR11114 BACKOUT DR103753 - MAKE PASS SPECIFIC       */
 /*                                                                         */
 /*12/23/92 PMA    8V0  *       MERGED 7V0 AND 24V0 COMPILERS.              */
 /*                             * REFERENCE 24V0 CR/DR                      */
 /*                                                                         */
 /*4/26/93  TEV   25V0/ 108617 R3 INCORRECTLY USED TO DEREFERENCE A         */
 /*                9V0         NAME VARIABLE                                */
 /*                                                                         */
 /*07/07/93 RPC   25V0  105050 REMOTE ARRAY MATRIX MULTIPLY FAILS           */
 /*               9V0                                                       */
 /*                                                                         */  07520005
 /*05/12/93 LJK   25V0  104835  %NAMEADD WITH THE 3RD ARGUMENT A LITERAL    */
 /*                9V0          STILL FAIL                                  */
 /*                                                                         */
 /*05/12/93 RAH   25V0/ 105115  BAD OBJECT CODE FOR %NAMEADD.               */
 /*               9V0           MODIFIED FORCE_ADDRESS TO HANDLE            */
 /*                             REMOTE ADDRESSING THAT USES A CSYM.         */
 /*                                                                         */
 /*05/18/93 RPC   25V0  108620 INDEX IN R4 LOST DURING REMOTE RTL SETUP     */
 /*               9V0                                                       */
 /*                                                                         */  07520005
 /*05/24/93 PMA   25V0  103753  REMOVED "PASS SPECIFIC" CONSTRAINT IN       */
 /*                9V0          CONCURRENCE WITH DR108535 FIX.              */
 /*                                                                         */
 /*05/24/93 TEV,   9V0, 108605 DOUBLE PRECISION VALUE LOADED INCORRECTLY    */  07520005
 /*         DKB    25V0        FROM THE STACK                               */  07520005
 /*                                                                         */
 /*05/25/93 RPC   25V0  105054 INCORRECT INDEX FOR NAME ASSIGNMENT          */
 /*               9V0                                                       */
 /*                                                                         */
 /*05/25/93 PMA   25V0  108609  ARRAYED EXPRESSION IN SUBSCRIPT FOR ARRAY   */
 /*                9V0          OF MATRICES                                 */
 /*                                                                         */
 /*6/8/93   TEV   25V0/ 108535 INVALID USE OF SRS TYPE INSTRUCTION          */
 /*                9V0                                                      */
 /*                                                                         */  07520005
 /*11/02/93 DKB   25V1, 106968 INCORRECT RLD (APPLIED CHANGE FROM 24V2      */  07520005
 /*                9V1         USING CCC, CHANGE NOT IN 25V0/9V0)           */  07520005
 /*                                                                         */
 /*10/7/93  RSJ   26V0/ 106757 INSTRUCTION COUNT FREQUENCIES INCORRECT      */
 /*               10V0                                                      */
 /*                                                                         */
 /*10/26/93 RSJ   26V0/ 107092 BAD POINTER PASSED TO CASR                   */
 /*               10V0                                                      */
 /*                                                                         */
 /*02/01/94 JAC   26V0, 108602 COMPILER FAILS TO EMIT FT108 ERROR           */  07520005
 /*               10V0         MESSAGE                                      */  07520005
 /*                                                                         */  07520005
 /*02/01/94 DAS   26V0/ 102945 INCORRECT CHECK FOR EXIT CONDITION IN       */
 /*               10V0         DO FOR LOOP                                 */
 /*                                                                         */
 /*02/22/94 DAS   26V0/ 109008 INVALID STRUCTURE NODE ADDRESSING            */  07520005
 /*               10V0                                                      */  07520005
 /*                                                                        */
 /*03/01/94 DAS   26V0, 101663 WRONG VALUE LOADED FROM REGISTER AFTER       */  07520005
 /*               10V0         SUBBIT                                       */  07520005
 /*                                                                         */  07520005
 /*02/23/94 TEV   26V0/ 109005  EXTRA YCON TO ZCON CONVERSION FOR           */
 /*               10V0          SUBSCRIPTED NAME REMOTE                     */
 /*                                                                         */
 /*03/22/94 RSJ   26V0/ 109014  REGISTERS NOT MARKED DESTROYED BY CPR       */
 /*               10V0                                                      */
 /*                                                                         */  07520005
 /*05/24/94 TEV   26V0/ 107307 INCORRECT INDEXING OF NAME VARIABLE          */
 /*               10V0                                                      */
 /*06/16/95 TMP   27V0  C12385 ADD PERMANENT TRAPS TO THE COMPILER          */
 /*               11V0                                                      */
 /*                                                                         */  07520005
 /*04/21/95 DAS   27V0/ 109010 INCORRECT AMOUNT OF RUN-TIME STACK SPACE     */
 /*               11V0         RESERVED FOR CHARACTER ARRAYS                */
 /*                                                                         */  07520005
 /*04/13/95 DAS   27V0/ 108613 ERROR IN BIT STRING SUBSCRIPTING             */
 /*               11V0                                                      */
 /*                                                                         */  07520005
 /*03/29/95 DAS   27V0/ 109006 INCORRECT ZCON FOR STRUCTURE NODE NAME       */
 /*               11V0         DEREFERENCE                                  */
 /*                                                                         */  07520005
 /*01/26/95 DAS   27V0/ 103787 WRONG VALUE LOADED FROM REGISTER FOR A       */
 /*               11V0         STRUCTURE NODE REFERENCE                     */
 /*                                                                         */  07520005
 /* 3/23/95 TEV   27V0, 109018 NAME REMOTE DEREFERENCE ALLOWED IN           */
 /*               11V0         NAME ASSIGNMENTS                             */
 /*                                                                         */  07520005
 /*11/09/94 DAS   27V0/ 109015 WRONG TARGET REGISTER LOADED FOR NAME        */
 /*               11V0         REFERENCE WITH DATA_REMOTE IN EFFECT.        */
 /*                                                                         */  07520005
 /*05/18/95 DAS   27V0/ 107880 BI506 ERROR WITH TEMPORARY LOOP COUNTER      */
 /*               11V0                                                      */
 /*                                                                         */  07520005
 /*11/02/94 DAS   27V0/ 107705 RLD WRITTEN TO WRONG ADDRESS                 */
 /*               11V0                                                      */
 /*                                                                         */
 /*05/04/95 TMP   27V0/ 108606 INCORRECT ASSIGNMENT OF A MULTI-COPIED       */
 /*               11V0         STRUCTURE                                    */
 /*                                                                         */
 /*05/03/95 TMP   27V0/ 108608 DOUBLE PRECISION DIVIDE GENERATES            */
 /*               11V0         INCORRECT OBJECT CODE                        */
 /*                                                                         */
 /*04/10/95 RSJ   27V0/ 109009 NEGATIVE BASE REGISTER USED FOR %MACRO       */
 /*               11V0                                                      */
 /*                                                                         */
 /*04/03/95 JMP   27V0/ 108645 COLUMN() NOT INITIALIZED IN SIZEFIX.         */
 /*               11V0                                                      */
 /*                                                                         */
 /*04/05/95 TEV   27V0/ 109034 INDEX REGISTER NOT ADDED TO A SUBSCRIPTED    */
 /*               11V0         NAME REMOTE                                  */
 /*                                                                         */
 /*01/31/95 DAS   27V0/ 109030 WRONG VALUE LOADED FROM REGISTER AFTER       */  08240018
 /*               11V0         %COPY OR DSST                                */  08250018
 /*                                                                         */  08260018
 /*01/15/95 RSJ   27V0/ 109019 COMPILER INCORRECTLY ADJUSTS FOR             */
 /*               11V0         AUTO INDEX ALIGNMENT                         */
 /*                                                                         */
 /*01/27/95 RSJ   27V0/ 107722 HAL/S OBJECT CODE INCORRECT FOR              */
 /*               11V0         INTEGER DIVISION                             */
 /*                                                                         */
 /*11/22/94 TEV   27V0/ 102964 INCORRECT CODE GENERATED FOR NAME            */
 /*               11V0         DEREFERENCING                                */
 /*                                                                         */
 /*08/31/94 TEV   27V0/ 109011 PARAMETERS FOR CATV MAY BE DESTROYED         */
 /*               11V0                                                      */
 /*                                                                         */
 /*11/21/94 RSJ   27V0/ 109022  RETURN R FOR REG_STAT WHEN D_RTL_SETUP      */
 /*               11V0          IS SET                                      */
 /*                                                                         */  07520005
 /*11/03/94 RSJ   27V0/ 109016 WRONG BASE REGISTER USED WITH DATA_REMOTE    */
 /*               11V0                                                      */
 /*                                                                         */
 /*02/03/96 SMR   27V1/ 109038 INDEX REGISTER NOT ADDED CORRECTLY TO A      */
 /*               11V1  SUBSCRIPTED NAME REMOTE                             */
 /*                                                                         */
 /*01/12/96 SMR   27V1/ 109032 BX114 ERROR EMITTED WHEN SUBSCRIPTING        */
 /*               11V1         A NAME REMOTE NODE                           */
 /*                                                                         */
 /*06/18/97 DAS   28V0/ CR12432 ALLOW DEREFERENCING OF NAME REMOTE          */
 /*               12V0                                                      */
 /*                                                                         */
 /*01/15/97 SMR   28V0/ 12713  ENCHANCE COMPILER LISTING                    */
 /*               12V0                                                      */
 /*                                                                         */
 /*03/04/97 TEV   28V0/ 109055 MATRIX STRUCTURE NODE USE INCORRECTLY        */
 /*               12V0         CALLS VR1SN                                  */
 /*                                                                         */
 /*01/24/97 DCP   28V0/ C12714 ADD INTERNAL COMPILER ERROR CHECKING         */
 /*               12V0                                                      */
 /*                                                                         */
 /*01/03/97 TEV   28V0/ 109046 NAME REMOTE PARAMETER SETUP IS BAD           */
 /*               12V0                                                      */
 /*                                                                         */
 /*11/18/96 TEV   28V0/ 109043 NAME VARIABLES INITIALIZED TO LITERALS       */
 /*               12V0         DON'T GET DI101 ERROR                        */
 /*                                                                         */
 /*11/08/96 SMR   28V0/ 109041 BS106 ERROR ON ASSIGNMENT OF REMOTE          */
 /*               12V0         NAME PROGRAM VARIABLES                       */
 /*                                                                         */
 /*08/08/96 SMR   28V0/ 109044 DI17 EMITTED FOR NAME CHARACTER(*)           */
 /*               12V0         PARAMETERS                                   */
 /*                                                                         */
 /*11/03/98 TKN   29V0/ 111315 VR0SN FAILS WITH A NAME REMOTE ARRAY         */
 /*               14V0         STRUCTURE NODE                               */
 /*                                                                         */
 /*07/06/98 SMR   29V0/ 111303 BS123 ERROR FOR STRUCTURE BIT OPERATION      */
 /*               14V0                                                      */
 /*                                                                         */
 /*07/07/98 BJW   29V0  111302 BI506 ERROR ON AUTOMATIC BIT                 */
 /*               14V0         INITIALIZATION                               */
 /*                                                                         */
 /*06/08/98 DCP   29V0/ 109093 NAME REMOTE DEREFERENCE OF                   */
 /*               14V0         MINOR STRUCTRUE NODE FAILS                   */
 /*                                                                         */
 /* 5/06/98 SMR   29V0/ 109095 BIT STORE VIA DATA REMOTE NAME REMOTE        */
 /*               14V0         DEREFERENCE FAILS                            */
 /*                                                                         */
 /*05/04/98 DAS   29V0/ 109090 NAME REMOTE DEREFERENCE OF STRUCTURE         */
 /*               14V0         NODE FAILS                                   */
 /*                                                                         */
 /*01/15/98 DCP   29V0/ 109083 CONSTANT DOUBLE SCALAR CONVERTED TO A        */
 /*               14V0         CHARACTER AS SINGLE PRECISION                */
 /*                                                                         */
 /*03/17/98 TKN   29V0/ 109087 BI516 ERROR EMITTED FOR NESTED               */
 /*               14V0         FUNCTION CALL                                */
 /*                                                                         */
 /*03/17/98 TKN   29V0/ 109089 BAD OBJECT CODE GENERATED FOR                */
 /*               14V0         STACK WALKBACK LOOP                          */
 /*                                                                         */
 /*04/07/98 DAS   29V0/ CR12935 ALLOW REMOTE PASS BY REFERENCE              */  09130000
 /*               14V0          PARAMETERS                                  */  09140000
 /*                                                                         */  09150000
 /*03/09/98 BJW   29V0/ 109071 STRUCTURE IN ASSIGN PARAMETER GETS ERROR     */
 /*               14V0                                                      */
 /*                                                                         */
 /*12/19/97 SMR   29V0/ 109084 STRUCTURE INITIALIZATION MAY CAUSE           */
 /*               14V0         INCORRECT HALMAT                             */
 /*                                                                         */
 /*09/25/97 SMR   29V0/ 109059 INDIRECT STACK ENTRY FOR EVENT NOT RETURNED  */
 /*               14V0                                                      */
 /*                                                                         */
 /*09/25/97 SMR   29V0/ 109064 INDIRECT STACK ENTRY NOT RETURNED FOR %COPY  */
 /*               14V0                                                      */
 /*                                                                         */
 /*10/22/97 SMR   29V0/ 109068 INDIRECT STACK ENTRY NOT RETURNED FOR        */
 /*               14V0         CHECKPOINTED REGISTER                        */
 /*                                                                         */
 /*11/19/97 JAC   29V0/ 109077 FT100 ERROR FOR SIZE(STRUC.NAME_STRUC.ARRAY) */
 /*               14V0                                                      */
 /*                                                                         */
 /*12/03/97 DAS   29V0  109078 BAD SETUP TO VV1S3 FOR MULTICOPY NAME        */
 /*               14V0         NODE LHS                                     */
 /*                                                                         */
 /*09/18/97 SMR   29V0/ 109060 BAD OBJECT CODE FOR EVENT COMPARISON         */
 /*               14V0                                                      */
 /*                                                                         */
 /*10/29/97 TMP   29V0/ 109056 STRUCTURE PARAMETER RECEIVES INVALID         */
 /*               14V0         DQ101 ERROR                                  */
 /*                                                                         */
 /*12/13/99 TKN   30V0/ 13211  GENERATE ADVISORY MSG WHEN BIT STRING        */
 /*               15V0         ASSIGNED TO SHORTER STRING                   */
 /*                                                                         */
 /*11/17/99  DAS  30V0/ CR13222 REMOVE ERROR-PRONE DESIGN OF COMPILER       */
 /*               15V0          LIBRARY DESCRIPTION TABLE                   */
 /*                                                                         */
 /*10/27/99 DCP   30V0/ 111344 CASRV FAILS FOR NAME NODE ASSIGNMENT         */
 /*               15V0                                                      */
 /*                                                                         */
 /*02/05/00 KHP   30V0/ CR13236 REMOVE UNNECESSARY DENSE ATTRIBUTE MATCHES  */
 /*               15V0                                                      */
 /*                                                                         */
 /*04/05/99 LJK   30V0/ CR12620 SELECTIVE CLEARING OF DSES AROUND RTL CALLS */
 /*               15V0                                                      */
 /*                                                                         */
 /*07/19/99 TKN   30V0/ 111337 %COPY USING ASTERISK (*) SUBSCRIPTED         */
 /*               15V0         ARGUMENT DOES NOT GET AN ERROR               */
 /*                                                                         */
 /*10/27/99 TKN   30V0/ 111307 COMPILER ABEND DURING BIX LOOP GENERATION    */
 /*               15V0                                                      */
 /*                                                                         */
 /*08/18/99 DCP   30V0/ 12214  USE THE SAFEST %MACRO THAT WORKS             */
 /*               15V0                                                      */
 /*                                                                         */
 /*06/22/99 DCP   30V0/ 111336 BI516 ERROR DURING NAME REMOTE               */
 /*               15V0         DEREFERENCE OF STRUCTURE NODE                */
 /*                                                                         */
 /*06/04/99 JAC   30V0/ 111328 OC4 ERROR FOR REPLACE MACROS                 */
 /*               15V0                                                      */
 /*                                                                         */
 /*07/07/99 DCP   30V0/ 111331 BAD OBJECT CODE FOR REMOTE STRUCTURE         */
 /*               15V0         USED AS ASSIGN PARAMETER                     */
 /*                                                                         */
 /*06/08/99 DCP   30V0/ 111332 INCORRECT SETUP FOR RTL CASR                 */
 /*               15V0                                                      */
 /*                                                                         */
 /*06/28/99 DCP   30V0/ 111338 NAME REMOTE COMPARISON FAILS                 */
 /*               15V0                                                      */
 /*                                                                         */
 /*03/12/99 JAC   30V0/ 109075 BS112 ERROR IS EMITTED ON THE 99TH NAME      */
 /*               15V0         REMOTE DEREFERENCE                           */
 /*                                                                         */
 /*05/06/99 TKN   30V0/ 111308 COMPILER INCORRECTLY ADJUSTS FOR AUTO        */
 /*               15V0         INDEX ALIGNMENT                              */
 /*                                                                         */
 /*05/11/00 TKN   30V0/ 111318 NAME REMOTE DEREFERENCE WITH VIRTUAL         */
 /*               15V0         BASE FAILS                                   */
 /*                                                                         */
 /*06/25/01 JAC   31V0/ 111384 INCORRECT INDEXING FOR NAME REMOTE           */
 /*               16V0         STRUCTURE NODE                               */
 /*                                                                         */
 /*05/30/01 JAC   31V0/ 111380 INCORRECT OBJECT CODE FOR AUTOMATIC          */
 /*               16V0         INITIALIZATION                               */
 /*                                                                         */
 /*04/25/01 JAC   31V0/ 111374 REFERENCE OF MULTI-COPIED NAME REMOTE        */
 /*               16V0         NODE FAILS (ALSO REMOVED DR111318 FIX)       */
 /*                                                                         */
 /*05/03/01 JAC   31V0/ 111362 UNNECESSARY STACK WALKBACK                   */
 /*               16V0                                                      */
 /*                                                                         */
 /*04/26/01 DCP   31V0/  13335 ALLEVIATE SOME DATA SPACE PROBLEMS           */
 /*               16V0         IN HAL/S COMPILER                            */
 /*                                                                         */
 /*07/30/01 JAC   31V0/ 111372 SHAPING FUNCTION INCORRECTLY PASSED TO       */
 /*               16V0         PROCEDURE                                    */
 /*                                                                         */
 /*03/20/01 JAC   31V0/ 111368 INCORRECT RESULTS FOR REMOTE STRUCTURE       */
 /*               16V0         ASSIGN PARAMETER                             */
 /*                                                                         */
 /*03/14/01 JAC   31V0/ 111363 BI511 ERROR FOR ASSIGN PARAMETER             */
 /*               16V0                                                      */
 /*                                                                         */
 /*02/21/01 DAS   31V0/ 111364 DOUBLE PRECISION INTEGER SUBSCRIPT           */
 /*               16V0         OVERFLOW                                     */
 /*                                                                         */
 /*01/17/01 JAC   31V0/ 111360 NO STACK WALKBACK ERROR FOR REMOTE           */
 /*               16V0         PASS-BY-REFERENCE PARAMETER                  */
 /*                                                                         */
 /*01/15/01 DCP   31V0/ CR13220 GENERATE ERROR MESSAGE FOR UNSUPPORTED      */
 /*               16V0          EVENT EVALUATION                            */
 /*                                                                         */
 /*12/15/00 JAC   31V0/ 111358 BI511 ERROR FOR BIT ASSIGNMENT IN LOOP       */
 /*               16V0                                                      */
 /*                                                                         */
 /*11/04/03 DCP   32V0/ 120230 INCORRECT FD100 ERROR FOR NAME INPUT         */
 /*               17V0         PARAMETER                                    */
 /*                                                                         */
 /*03/22/05 DAS   32V0/ 120265 INCORRECT REGISTER FOR REPEAT ASSIGNMENT     */
 /*               17V0                                                      */
 /*                                                                         */
 /*03/30/04 DCP   32V0/ 120228 NO DS11 FOR CHARACTER PARAMETER              */
 /*               17V0                                                      */
 /*                                                                         */
 /*10/07/03 DCP   32V0/ 120224 INCORRECT SUBBIT FOR DOUBLE LITERAL          */
 /*               17V0                                                      */
 /*                                                                         */
 /*03/02/04 DCP   32V0/ CR13811 ELIMINATE STACK WALKBACK CAPABILITY         */
 /*               17V0                                                      */
 /*                                                                         */
 /*09/23/03 JAC   32V0  120223 NO FT101 ERROR FOR LITERAL ARGUMENT          */
 /*               17V0                                                      */
 /*                                                                         */
 /*08/02/02 TKN   32V0  111398 BS112 ERROR GENERATED FOR A NAME REMOTE      */
 /*               17V0         DEREFERENCE                                  */
 /*                                                                         */
 /*03/30/04 TKN   32V0  13670    ENHANCE & UPDATE INFORMATION ON THE USAGE  */
 /*               17V0           OF TYPE 2 OPTIONS                          */
 /*                                                                         */
 /*01/16/04 TKN   32V0/ CR13339 IMPROVE COMPILER SOURCE CODE FOR INDEXING   */
 /*               17V0                                                      */
 /*                                                                         */
 /*09/16/02 DCP   32V0/ CR13615 MODULARIZE CODE FOR READABILITY             */
 /*               17V0                                                      */
 /*                                                                         */
 /*07/18/03 TKN   32V0/ 120218 BI517 ERROR FOR SIZE FUNCTION                */
 /*               17V0                                                      */
 /*                                                                         */
 /*09/10/02 JAC   32V0/ CR13570 CREATE NEW %MACRO TO PERFORM ZEROTH         */
 /*               17V0          ELEMENT CALCULATIONS                        */
 /*                                                                         */
 /*09/04/02 DCP   32V0/ CR13616 IMPROVE READABILITY AND ADD COMMENTS FOR    */
 /*               17V0          NAME DEREFERENCES                           */
 /*                                                                         */
 /*09/27/02 JAC   32V0/ 111400 DEREFERENCE OF A SUBSCRIPTED NAME REMOTE     */
 /*               17V0         ASSIGN PARAMETER FAILS                       */
 /*                                                                         */
 /*06/20/02 DCP   32V0/ 111395 REMOTE NAME REMOTE SUBSCRIPT FAILS           */
 /*               17V0                                                      */
 /*                                                                         */
 /*06/25/02 JAC   32V0/ CR13538 ALLOW MIXING OF REMOTE AND NON-REMOTE       */
 /*               17V0          POINTERS                                    */
 /*                                                                         */
 /*05/10/02 DCP   32V0/ 111390 %NAMEADD INCORRECT FOR NAME REMOTE COUNT     */
 /*               17V0          FIELD                                       */
 /*                                                                         */
 /*06/06/02 DCP   32V0/ 111393 FT112 ERROR NOT GENERATED FOR REMOTELY       */
 /*               17V0         INCLUDED NAME VARIABLE                       */
 /*                                                                         */
 /*04/18/02 JAC   32V0/ 111394 NAME REMOTE SUBSCRIPT NOT DEREFERENCED       */
 /*               17V0                                                      */
 /*                                                                         */
 /*04/29/02 DCP   32V0/ 111382 BASE NOT LOADED FOR NAME REMOTE              */
 /*               17V0         COMPARISON                                   */
 /*                                                                         */
 /*04/12/02 DCP   32V0/ 111381 COMPARISON FAILS FOR AUTOMATIC REMOTE        */
 /*               17V0         VARIABLES                                    */
 /*                                                                         */
 /*03/18/02 JAC   32V0/ 111377 INCORRECT RESULTS FROM UNVERIFIED LIBRARY    */
 /*               17V0         ROUTINE                                      */
 /*                                                                         */
 /*02/15/02 JAC   32V0/ 111386 BIX LOOP INCORRECT FOR CHARACTER(*)          */
 /*               17V0                                                      */
 /*                                                                         */
 /*11/06/01 TKN   32V0/ 111388 REMOTE CHARACTER PARAMETER FAILS             */
 /*               17V0                                                      */
 /*                                                                         */
 /***************************************************************************/
                                                                                01538500
 /* PROCEDURES TO GENERATE CODE FROM HALMAT SEQUENCES */                        01539000
GENERATE:                                                                       01539500
   PROCEDURE;                                                                   01540000
      DECLARE                                                                   01552500
         STRUCT_MOD(1) FIXED,                                                   01553000
         STRUCT_REF(1) BIT(16),                                                 01553500
         STRUCT_TEMPL(1) BIT(16);                                               01554000
      DECLARE      (AUX_CODE, AUX_TAG, AUX_FORM, AUX_LOC, AUX_NEXT) BIT(16);    01554100
                                                                                01554500
 /* DECLARATIONS USED BY THE CODE GENERATORS  */                                01555000
      DECLARE LOAD BIT(16) INITIAL ("00"),                                      01555500
         STORE BIT(16) INITIAL ("01"),                                          01556000
         ADD  BIT(16) INITIAL ("0B"),                                           01556500
         SLA  LITERALLY 'SLL',                                                  01557000
         MODE_MOD(17) BIT(16) INITIAL                                           01557500
         (0, 0, 0, "20", "10", 1, "30", "40", "60", "50", 0, "90", 0, 0, 0,     01558000
         0, "A0", "B0"),                                                        01558500
         RS BIT(16) INITIAL(15),                                                01559000
         RI BIT(16) INITIAL(10),                                                01559500
         RR BIT(16) INITIAL(0),                                                 01560000
         RX BIT(16) INITIAL(5),                                                 01560500
         COMPARE BIT(16) INITIAL ("05"),                                        01561500
         AND  BIT(16) INITIAL ("02"),                                           01562000
         EXOR BIT(16) INITIAL("04");                                            01562500
                                                                                01563000
 /?B  /* CR11114 -- BFS/PASS INTERFACE; CODE TO CHECK LAST SVCI */
      DECLARE CLOSE_STMT BIT(1) INITIAL(0);
 ?/
      DECLARE TO_BE_MODIFIED BIT(1), TO_BE_INCORPORATED BIT(1) INITIAL(TRUE);   01563500
  DECLARE  (INITOP, INITTYPE, INITAGAIN, INITLITMOD, INITMULT, INITINX) BIT(16);01564500
      DECLARE  (INITADDR, INITSTART, INITWALK, INITMOD) FIXED;                  01565000
      DECLARE  (INITINCR, INITDECR, INITRESET) FIXED;                           01565500
      DECLARE  (INITAUTO, INITSTRUCT) BIT(1);                                   01566000
      ARRAY    INITMAX LITERALLY '10',                                          01566500
         INITAUX(INITMAX) FIXED,                                                 1566600
         (INITREPT, INITSTEP, INITREL, INITCTR, INITBLK)(INITMAX) BIT(16);      01567000
      DECLARE (DENSE_INX,DENSETYPE,DENSESHIFT,INITBASE) BIT(16);                01567500
                                                                                01569000
 /* ARRAY DO-LOOP DECLARATIONS */                                               01569500
      ARRAY   DOLOOPS LITERALLY '20',                                           01570000
         (DOINDEX,DORANGE,DOLABEL,DOSTEP)(DOLOOPS) BIT(16),                     01571000
         DOAUX(DOLOOPS) FIXED,                                                   1571100
         (SUBLIMIT,SUBRANGE)(DOLOOPS) BIT(16),                                  01571500
         DOFLAG(DOLOOPS) BIT(1),                                                 1571600
         DONEST LITERALLY '5';                                                  01572000
      DECLARE                                                                   01572500
         (DOTOT,DOPTR,DOFORM,DOCTR,DOBLK) (DONEST) BIT(16),                     01573000
         (SDOPTR,SDOLEVEL,SDOTEMP) (DONEST) BIT(16),                            01573500
         DOPTR# BIT(16),                                                        01574000
         (ARRAYNESS, ADOPTR) BIT(16),                                           01574500
         (VALMUL, VALMOD, INXMOD) BIT(16), TERMFLAG BIT(1),                     01575000
         (DOPUSH, DOVDLP)(DONEST) BIT(1),                                       01575100
         NAME_SUB BIT(1),                                                       01575500
         (SUB#,SUBOP,EXTOP) BIT(16),                                            01576000
         ALCOP LITERALLY 'RESULT',                                              01576500
         STRUCTOP LITERALLY 'LEFTOP';                                           01577000
                                                                                01577500
      /*------------------ DR108606 --------------------------------*/
      /* ADD A COUNTER FOR BIX LOOPS.  IF THIS COUNTER IS GREATER   */
      /* THAN 0 THEN AN NHI INSTRUCTION WILL BE EMITTED IN          */
      /* FORCE_ADDRESS, PRIOR TO THE AR INSTRUCTION IF CHECK_REMOTE */
      /* IS TRUE.  THIS WILL ZERO THE LOWER HALF OF THE INDEX       */
      /* REGISTER TO PREVENT MESSING UP THE DSR.                    */
      /*------------------ DR108606 --------------------------------*/
      DECLARE BIX_CNTR BIT(16) INITIAL(0);                /*DR108606*/

 /* DO LOOP DESCRIPTOR DECLARATIONS  */                                         01578000
      ARRAY    (DOTEMP, DOTEMPBLK, DOTEMPCTR) (DOSIZE) BIT(16),                 01578500
         DOFOROP(DOSIZE) BIT(16), DOCASECTR BIT(16),                            01579000
         DOFORREG(DOSIZE) BIT(16), (DOBASE, DOINX) BIT(16),                     01579500
         DOLBL(DOSIZE) BIT(16), DOFORCLBL BIT(16),                              01580000
         (DOFORINCR, DOFORFINAL, DOUNTIL)(DOSIZE) BIT(16);                      01580500
                                                                                01581000
 /*   SUBPROGRAM CONTROL DECLARATIONS  */                                       01581500
      ARRAY                                                                     01582000
         (SAVE_CALL_LEVEL, SAVE_ARG_STACK_PTR)(CALL_LEVEL#) BIT(16),            01582500
         (CALL_CONTEXT, ARG_POINTER, ARG_COUNTER)(CALL_LEVEL#) BIT(16),         01583000
         SF_RANGE(CALL_LEVEL#) BIT(16),                                         01583500
         (ARG_STACK, ARG_TYPE)(ARG_STACK#) BIT(16),                             01584000
         ARG_NAME(ARG_STACK#) BIT(1),                                           01584500
         ERRPTR(PROC#) BIT(16),                                                 01585000
         ERRALL(PROC#) BIT(16),                                                 01585500
         ERR_DISP(ARG_STACK#) BIT(16),                                          01586000
         ERR_STACK(ARG_STACK#) BIT(16);                                         01586500
                                                                                01587000
 /* OPERATOR CODES AND PRIORITIES */                                            01587500
      DECLARE                                                                   01588000
         MINUS BIT(8) INITIAL (12),                                             01588500
         SUM BIT(8) INITIAL (11),                                               01589000
         TEST BIT(8) INITIAL (20),                                              01589500
         PREFIXMINUS BIT(8) INITIAL (16),                                       01590000
         MIDVAL BIT(8) INITIAL(22),                                             01590500
         OPSIZE LITERALLY '22';                                                 01591000
      ARRAY                                                                     01591500
         UNARY(OPSIZE) BIT(8) INITIAL                                           01592000
         (0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,1),                           01592500
         COMMUTATIVE(OPSIZE) BIT(8) INITIAL                                     01593000
         (0,0,1,1,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,1),                         01593500
         CONDITION(OPSIZE) BIT(8) INITIAL                                       01594000
         (7,0,0,0,0,4,3,1,6,2,5),                                               01594500
         REVERSE(OPSIZE) BIT(8) INITIAL                                         01595000
         (0,0,0,0,0,5,6,9,10,7,8),                                              01595500
         ADDITIVE(OPSIZE) BIT(8) INITIAL                                        01596000
         (0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0),                               01596500
         DESTRUCTIVE(OPSIZE) BIT(8) INITIAL                                     01597000
         (0,0,1,1,1,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,1,1),                       01597500
         ARITH_OP(OPSIZE) BIT(16) INITIAL                                       01598000
         ("18", "10", "14", "16", "17", "19","19","19","19","19","19",          01598500
         "1A", "1B", "1C", "1D", "1C", "13", "1C", "1C", "13", "18",            01599000
         "17", "1E");                                                           01599500
                                                                                01600000
 /* VECTOR MATRIX CODES AND PARAMETER SETUP INFORMATION  */                     01600500
      ARRAY   VMOPSIZE LITERALLY '29',                                          01601000
         VMREMOTEOP(VMOPSIZE) BIT(8) INITIAL                                    01601500
         (0,26,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,27,28,0,0,29,0),             01602000
         CTRSET(VMOPSIZE) BIT(8) INITIAL                                        01602500
         (0,0,0,0,0,0,0,2,3,2,1,0,2,2,0,0,0,1,1,1,0,2,2,2,2,1,0,0,2,2),         01603000
         CASE2SET(VMOPSIZE) BIT(8) INITIAL                                      01603500
         (0,0,0,0,0,0,0,0,0,0,0,0,1,2,0,0,0,0,0,0,0,1,1,1,0,0,0,0,1,0),         01604000
         SIZE3(VMOPSIZE) BIT(1) INITIAL                                         01604500
         (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,0,0,0,0);         01605000
                                                                                01605500
 /* MULTIPLE ASSIGNMENT CRITERION TABLES */                                     01606000
      ARRAY   ASSIGN_HEAD(5) BIT(16),                                           01606500
         ASSIGN_START(4) BIT(16) INITIAL(0, 6, 12, 18, 24),                     01607000
         ASSIGN_TYPES(23) BIT(16) INITIAL(0,1,4,3,2,5, 1,4,3,2,0,5,             01607500
         2,4,3,1,0,5, 3,4,2,1,0,5);                                             01608000
                                                                                01609500
 /* EVENT EXPRESSION STACKS AND POINTERS  */                                    01610000
      DECLARE EV_EXPTR_MAX LITERALLY '15', EV_PTR_MAX LITERALLY '5',            01610500
         EV_EXP(EV_EXPTR_MAX) BIT(8), EV_EXPTR BIT(16),                         01611000
         EV_OP(EV_PTR_MAX) BIT(16), EV_PTR BIT(16);                             01611500
                                                                                01612000
 /*  LIBRARY CALL DECLARATIONS  */                                              01612500
DECLARE TYPES(8) CHARACTER INITIAL('H', 'I', 'E', 'D', 'B', 'B', 'K', 'O', 'X'),01613000
         ITYPES(4) CHARACTER INITIAL ('B', 'H', 'I', 'E', 'D');                 01613500
      ARRAY BIFNUM LITERALLY '58',                                              01614000
        BIFCLASS(BIFNUM) BIT(16) INITIAL( 0, 0, 1, 2, 0, 1, 1, 5, 5, 0, 0, 0, 0,01614500
         1, 5, 1, 0, 1, 4, 4, 5, 0, 1, 5, 1, 1, 3, 2, 2, 0, 3, 3, 3, 0, 2, 1, 1,01615000
         1, 4, 4, 3, 0, 1, 0, 1, 1, 1, 0, 0, 2, 5, 1, 4, 0, 4, 0, 2, 1, 1),     01615500
         BIFTYPE(BIFNUM) BIT(16) INITIAL( 0, 3, 5, 5, 1, 5, 5, 0, 0, 2, 4, 5, 5,01616000
        5, 0, 5, 3, 5, 14, 6, 0, 4, 5, 0, 5, 5, 2, 4, 5, 0, 6, 2, 2, 0, 5, 5, 5,01616500
         5, 6, 6, 6, 6, 5, 4, 5, 5, 5, 2, 0, 3, 13, 5, 13, 0, 13, 2, 3, 32, 33),01617000
        BIFOPCODE(BIFNUM) BIT(16) INITIAL( 0, 19, 1, 17, 1, 2, 3, 4, 5, 6, 1, 1,01617500
         0, 7, 8, 9, 21, 10, 4, 7, 11, 2, 12, 0, 13, 14, 3, 16, 15, 15, 4, 5, 6,01618000
         16, 18, 17, 18, 19, 3, 5, 0, 20, 21, 3, 22, 23, 24, 25, 26, 10, 6, 27, 01618500
         0, 28, 2, 29, 9, 30, 31);                                              01619000
  DECLARE BIFNAMES(31) CHARACTER INITIAL( '', 'COS', 'EXP', 'LOG', 'MAX', 'MIN',01619500
    'MOD', 'SIN', 'SUM', 'TAN', 'COSH', 'PROD', 'SINH', 'SQRT', 'TANH', 'FLOOR',01620000
  'ROUND', 'ACOS', 'ASIN', 'ATAN', 'MDVAL', 'RANDOM', 'ACOSH', 'ASINH', 'ATANH',01620500
         'ATAN2', 'CEIL', 'RANDG', 'TRUNC', 'REM', 'SNCS', 'SNCS');             01621000
      DECLARE SORD(1) CHARACTER INITIAL ('', 'D');                              01622000
      DECLARE SHIFTOP(1) BIT(16) INITIAL ("8A","89");                           01622500
      DECLARE BIFREG(3) BIT(16) INITIAL(8, 10, 5, 6);                           01623000
      DECLARE IOCONTROL(5) CHARACTER INITIAL ('',                               01623500
         'TAB', 'COLUMN', 'SKIP', 'LINE', 'PAGE');                              01624000
      DECLARE FILECONTROL(1) CHARACTER INITIAL('FILEIN', 'FILEOUT');            01624500
      DECLARE NEWPREC(2) BIT(16) INITIAL (0, 0, 8);                             01625000
      DECLARE WAITNAME(3) BIT(16) INITIAL (9, 6, 7, 8),                         01625500
         SGNLNAME(2) BIT(16) INITIAL (12, 13, 14);                              01626000
      DECLARE INTCALL BIT(16);                                                  01626500
                                                                                01627500
 /*   BIT HANDLING FUNCTION NAMES  */                                           01628000
      DECLARE                                                                   01628500
         NEGLIT BIT(1);                                                         01629000
      ARRAY    XITAB(32)           FIXED     INITIAL(   0,                      01629500
         "1",      "3",      "7",      "F",                                     01630000
         "1F",     "3F",     "7F",     "FF",                                    01630500
         "1FF",    "3FF",    "7FF",    "FFF",                                   01631000
         "1FFF",   "3FFF",   "7FFF",   "FFFF",                                  01631500
         "1FFFF",  "3FFFF",  "7FFFF",  "FFFFF",                                 01632000
         "1FFFFF", "3FFFFF", "7FFFFF", "FFFFFF",                                01632500
         "1FFFFFF","3FFFFFF","7FFFFFF","FFFFFFF",                               01633000
         "1FFFFFFF", "3FFFFFFF","7FFFFFFF", "FFFFFFFF"   ) ;                    01633500
                                                                                01634000
                                                                                01634500
      DECLARE (CLASS1_OP, CLASS3_OP, CSE_FLAG, RETURN_FLAG) BIT(1),             01635000
         VAC_FLAG BIT(1),                                                        1635100
         STMT_PREC BIT(16);                                                     01635500

      /* TRUE WHEN AIA IS CALUCALTED ONLY USING BIGHTS/SHIFT ARRAY */
      DECLARE SIMPLE_AIA_ADJUST BIT(1) INITIAL(FALSE); /*DR109019*/
                                                                                01636000
      DECLARE NR_PREVLOC BIT(16) INITIAL(0); /* CR12432 */

      DECLARE MISMATCH BIT(1);               /* CR12214 */

      DECLARE R1_USED BIT(1) INITIAL(0);     /*DR111338*/
      DECLARE R3_USED BIT(1) INITIAL(0);     /*DR111338*/

      DECLARE INITREPTING(INITMAX) BIT(1);   /*DR120230*/

 /* ROUTINE TO DECODE HALMAT OPERAND  */                                        01636500
DECODEPIP:                                                                      01637000
      PROCEDURE(OP, N);                                                         01637500
         DECLARE (OP, N) BIT(16);                                               01638000
         OP=OP+CTR;                                                             01638500
         OP1=SHR(OPR(OP),16);                                                   01639000
         TAG1=SHR(OPR(OP),4)&"F";                                               01639500
         TAG2(N)=SHR(OPR(OP),1)&"7";                                            01640000
         TAG3(N)=SHR(OPR(OP),8)&"FF";                                           01640500
         IF HALMAT_REQUESTED THEN DO;                                           01641000
            MESSAGE=FORMAT(TAG3(N),3)||COMMA||TAG2(N)||' :'||CURCBLK-1||'.'||OP;01641500
            MESSAGE=FORMAT(TAG1,2)||'),'||MESSAGE;                              01642000
            OUTPUT=FORMAT(OP1,20)||LEFTBRACKET||MESSAGE;                        01642500
         END;                                                                   01643000
         N = 0;                                                                 01643500
      END DECODEPIP;                                                            01644000
                                                                                 1644010
 /* PROCEDURE TO LOCATE AUXILIARY HALMAT INFO FOR GIVEN HALMAT LINE */           1644020
AUX_LOCATE:                                                                      1644030
      PROCEDURE(PTR, LINE, OP) FIXED;                                            1644040
         DECLARE (PTR, LINE, OP) FIXED;                                          1644050
         DO WHILE AUX_LINE(PTR) < LINE;                                          1644060
            PTR = PTR + 2;                                                       1644070
         END;                                                                    1644080
         DO FOREVER;                                                             1644090
            IF AUX_OP(PTR) = 6 THEN RETURN -1;                                   1644100
            ELSE IF AUX_LINE(PTR) > LINE THEN RETURN -1;                         1644110
            ELSE IF AUX_OP(PTR) = OP THEN RETURN PTR;                            1644120
            PTR = PTR + 2;                                                       1644130
         END;                                                                    1644140
      END AUX_LOCATE;                                                            1644150
                                                                                 1644160
 /* ROUTINE TO BREAK OUT AUXILIARY HALMAT COMPONENTS */                          1644170
AUX_DECODE:                                                                      1644180
      PROCEDURE(CTR);                                                            1644190
         DECLARE CTR FIXED, PTR BIT(16);                                         1644200
         PTR = GET_AUX(CTR);                                                     1644210
         AUX_CODE = AUX_OP(CTR);                                                 1644220
         AUX_TAG = SHR(AUX(PTR),5) & "3F";                                       1644230
         AUX_FORM = SHR(AUX(PTR),11) & "1F";                                     1644240
         AUX_LOC = SHR(AUX(PTR+1),16) & "FFFF";                                  1644250
         AUX_NEXT = SHR(AUX(PTR+1),1) & "7FFF";                                  1644260
         IF AUXMAT_REQUESTED THEN                                                1644270
          OUTPUT = SUBSTR(X72,32)||'AUX:'||FORMAT(AUX_LINE(CTR),4)||X2||AUX_CODE 1644280
            || FORMAT(AUX_LOC,6)||LEFTBRACKET||AUX_FORM||RIGHTBRACKET||X4||      1644290
            AUX_NEXT||COMMA||AUX_TAG;                                            1644300
      END AUX_DECODE;                                                            1644310
                                                                                 1644320
 /* ROUTINE TO SEARCH FOR AUXILIARY HALMAT CORRESPONDING TO REGISTER */          1644330
AUX_SEARCH:                                                                      1644340
      PROCEDURE(R, CODE) FIXED;                                                  1644350
         DECLARE PTR FIXED, (R, CODE, REF) BIT(16);                              1644360
         PTR = AUX_LOCATE(AUX_CTR, CTR, CODE);                                   1644370
         DO WHILE PTR >= 0;                                                      1644380
            REF = GET_AUX(PTR);                                                  1644390
            IF (SHR(AUX(REF+1),16)&"7FFF") = R_VAR(R) THEN                       1644400
               IF (SHR(AUX(REF),11) & "1F") = R_CONTENTS(R) THEN                 1644410
               RETURN PTR;                                                       1644420
            PTR = AUX_LOCATE(PTR+2, CTR, CODE);                                  1644430
         END;                                                                    1644440
         RETURN -1;                                                              1644450
      END AUX_SEARCH;                                                            1644460
                                                                                01644500
 /* ROUTINE TO POSITION HALMAT BLOCK IF REQUIRED */                             01645000
POSITION_HALMAT:                                                                01645500
      PROCEDURE(BLK, POS, AUX);                                                  1646000
         DECLARE (BLK, POS) BIT(16), AUX FIXED;                                  1646500
         IF BLK ^= CURCBLK THEN DO;                                             01647000
            CURCBLK = BLK - 1;                                                  01647500
            CALL NEW_HALMAT_BLOCK;                                              01648000
         END;                                                                   01648500
         CTR = POS;                                                              1648510
         NUMOP = POPNUM(CTR);                                                    1648520
         AUX_CTR = AUX;                                                          1648530
      END POSITION_HALMAT;                                                      01649000
                                                                                01649500
 /* ROUTINE TO LOOK AHEAD AT NEXT HALMAT OPCODE */                              01650000
NEXTPOPCODE:                                                                    01650500
      PROCEDURE(CTR);                                                           01651000
         DECLARE CTR BIT(16);                                                   01651500
         NEXTCTR = CTR + POPNUM(CTR) + 1;                                        1652000
         RETURN POPCODE(NEXTCTR);                                               01652500
      END NEXTPOPCODE;                                                          01652501
                                                                                01652502
      DECLARE SIZE LITERALLY 'ROW';                                             01652503
                                                                                01652531
      DECLARE  CONST(1)        LITERALLY 'IND_STACK(%1%).I_CONST',              01652532
         INX_CON(1)      LITERALLY 'IND_STACK(%1%).I_INX_CON',                  01652533
         STRUCT_CON(1)   LITERALLY 'IND_STACK(%1%).I_STRUCT_CON',               01652534
         VAL(1)          LITERALLY 'IND_STACK(%1%).I_VAL',                      01652535
         XVAL(1)         LITERALLY 'IND_STACK(%1%).I_XVAL',                     01652536
         BACKUP_REG(1)   LITERALLY 'IND_STACK(%1%).I_BACKUP_REG',               01652537
         BASE(1)         LITERALLY 'IND_STACK(%1%).I_BASE',                     01652538
         COLUMN(1)       LITERALLY 'IND_STACK(%1%).I_COLUMN',                   01652539
         COPY(1)         LITERALLY 'IND_STACK(%1%).I_COPY',                     01652540
         DEL(1)          LITERALLY 'IND_STACK(%1%).I_DEL',                      01652541
         DISP(1)         LITERALLY 'IND_STACK(%1%).I_DISP',                     01652542
         FORM(1)         LITERALLY 'IND_STACK(%1%).I_FORM',                     01652543
         INX(1)          LITERALLY 'IND_STACK(%1%).I_INX',                      01652544
         INX_MUL(1)      LITERALLY 'IND_STACK(%1%).I_INX_MUL',                  01652545
         INX_NEXT_USE(1) LITERALLY 'IND_STACK(%1%).I_INX_NEXT_USE',             01652546
         LOC(1)          LITERALLY 'IND_STACK(%1%).I_LOC',                      01652547
         LOC2(1)         LITERALLY 'IND_STACK(%1%).I_LOC2',                     01652548
         NEXT_USE(1)     LITERALLY 'IND_STACK(%1%).I_NEXT_USE',                 01652549
         REG(1)          LITERALLY 'IND_STACK(%1%).I_REG',                      01652550
         ROW(1)          LITERALLY 'IND_STACK(%1%).I_ROW',                      01652551
         TYPE(1)         LITERALLY 'IND_STACK(%1%).I_TYPE',                     01652552
         INX_SHIFT(1)    LITERALLY 'IND_STACK(%1%).I_INX_SHIFT',                01652553
         STRUCT(1)       LITERALLY 'IND_STACK(%1%).I_STRUCT',                   01652554
         STRUCT_INX(1)   LITERALLY 'IND_STACK(%1%).I_STRUCT_INX',               01652555
         STRUCT_WALK(1)  LITERALLY 'IND_STACK(%1%).I_STRUCT_WALK', /*DR109016*/ 01652555
         AIA_ADJUSTED(1) LITERALLY 'IND_STACK(%1%).I_AIADONE', /*DR109019*/
 /********************* DR101335 START *******************/
         VMCOPY(1)       LITERALLY 'IND_STACK(%1%).I_VMCOPY',                   01652556
         POINTS_REMOTE(1) LITERALLY 'IND_STACK(%1%).I_PNTREMT',                 01652656
         LIVES_REMOTE(1)  LITERALLY 'IND_STACK(%1%).I_LIVREMT',                 01652756
 /********************* DR101335 FINISH ******************/
         NR_DEREF(1)      LITERALLY 'IND_STACK(%1%).I_NRDEREF', /* CR12432 */
         NR_STACK(1)      LITERALLY 'IND_STACK(%1%).I_NRSTACK', /* CR12432 */
         NR_DELTA(1)      LITERALLY 'IND_STACK(%1%).I_NRDELTA', /* CR12432 */
         NR_DEREF_TMP(1)  LITERALLY 'IND_STACK(%1%).I_NRDEREFTMP',/*DR109095*/
         NR_BASE(1)       LITERALLY 'IND_STACK(%1%).I_NRBASE',    /*DR109095*/
         NAME_VAR(1)      LITERALLY 'IND_STACK(%1%).I_NAMEVAR';
/******* DR109018 ****************************************************/
/* THIS ROUTINE LOOKS AT THE CURRENT HALMAT OPERATOR TO DETERMINE IF */
/* INSIDE A NAME ASSIGNMENT/COMPARE, %NAMEADD OR %NAMECOPY MACROS.   */
NAME_FUNCTION: PROCEDURE(OP) BIT(1);   /* DR111390*/
 /* LOCAL VARIABLES */
   DECLARE OP        BIT(16);          /* DR111390 */
   DECLARE XPCAL     LITERALLY '29';   /* DR109046 */
   DECLARE XFCAL     LITERALLY '30';   /* DR109046 */
   DECLARE XXXAR     LITERALLY '39';   /* DR109046 */
   DECLARE XNNEQ     LITERALLY '85';
   DECLARE XDSUB     LITERALLY '25';   /*DR109032*/
   DECLARE XNEQU     LITERALLY '86';
   DECLARE XNASN     LITERALLY '87';
   DECLARE XPMAR     LITERALLY '90';
   DECLARE XPMIN     LITERALLY '91';
   DECLARE NCOPY_TAG LITERALLY  '3';    /*CR13570*/
   DECLARE NADD_TAG  LITERALLY  '6';    /*CR13570*/

   /* CHECK TO SEE IF THE CURRENT HALMAT OPERATOR IS EITHER A */
   /* NAME COMPARISON OR A NAME ASSIGNMENT                    */
   IF (HALMAT_OPCODE = XNNEQ) | (HALMAT_OPCODE = XNEQU) |
      (HALMAT_OPCODE = XNASN) THEN RETURN TRUE;

   /* CHECK TO SEE IF THE CURRENT HALMAT OPERATOR IS A %MACRO */
   /* ARGUMENT LIST. IF IT IS, SEE IF THE ARGUMENT IS EITHER  */
   /* THE DESTINATION OR SOURCE FIELD IN A %NAMECOPY OR A     */
   /* %NAMEADD MACRO.                                         */
   IF (HALMAT_OPCODE = XPMAR) THEN DO ;
      IF (PMINDEX = NCOPY_TAG) | ( (PMINDEX = NADD_TAG) & /*DR111390*/
         ((ARG_STACK_PTR-SAVE_ARG_STACK_PTR) ^= 2) )      /*DR111390*/
      THEN RETURN TRUE;                               /*MOD-DR111390*/
   END ;

   /* CHECK TO SEE IF THE CURRENT HALMAT OPERATOR IS A %MACRO */
   /* INVOCATION. IF IT IS, SEE IF THE ARGUMENT IS EITHER THE */
   /* DESTINATION OR SOURCE FIELD IN A %NAMECOPY OR A         */
   /* %NAMEADD MACRO.                                         */
   IF (HALMAT_OPCODE = XPMIN) THEN DO ;
      IF (TAG = NCOPY_TAG) | ( (TAG = NADD_TAG) &         /*DR111390*/
         (OP ^= ARG_STACK(SAVE_ARG_STACK_PTR+2)) )        /*DR111390*/
      THEN RETURN TRUE;                               /*MOD-DR111390*/
   END ;

   /* CHECK TO SEE IF THE CURRENT HALMAT OPERATOR IS SUBSCRIPTING */
   /* AN OPERAND OF A NAME PSEUDO-FUNCTION                        */
   IF (HALMAT_OPCODE = XDSUB) & NAME_SUB THEN  /*DR109032*/
   /* TAG3=1,5 MEANS PROCESSING THE SUBSCRIPT (NOT THE VARIABLE-CR12432 */
   /* BEING SUBSCRIPTED). RETURN FALSE FOR THIS CASE BECAUSE   -CR12432 */
   /* ANY SUBSCRIPT IS NOT REALLY PART OF THE NAME FUNCTION.   -CR12432 */
   /* RETURN TRUE FOR LITERAL SUBSCRIPTS (TAG1=6)              -DR111394*/
      IF TAG1=6 | (TAG3 ^= 5 & TAG3 ^= 1) THEN     /*DR111394,DR109058,CR12432*/
      RETURN TRUE;                             /*DR109032*/

   /* IF CURRENT HALMAT IS XXAR, CHECK THE ARGUMENT BEING BUILT */
   /* FOR THE NAME() PSEUDO-FUNCTION (ARG_NAME(ARG_STAK_PTR)).  */
   IF (HALMAT_OPCODE = XXXAR) THEN DO;                            /* DR109046 */
      IF ARG_NAME(ARG_STACK_PTR) THEN RETURN TRUE;                /* DR109046 */
   END;                                                           /* DR109046 */

   /* IF CURRENT HALMAT IS PCAL OR FCAL (PROCEDURE OR FUNCTION  */
   /* CALL), CHECK THE ARGUMENT BEING PROCESSED FOR THE NAME()  */
   /* PSEUDO-FUNCTION (ARG_NAME(ARG#)).                         */
   IF (HALMAT_OPCODE = XPCAL) | (HALMAT_OPCODE = XFCAL) THEN DO;  /* DR109046 */
      IF ARG_NAME(ARG#) THEN RETURN TRUE;                         /* DR109046 */
   END;                                                           /* DR109046 */

   RETURN FALSE;
END NAME_FUNCTION;
/******* END DR109018 **********************************************/

 /**********************DR102948*************************************/          01635504
 /*                                                                 */          01635508
 /* MODULE NAME:                                                    */          01635512
 /*    DEREF(SHORT FOR DEREFERENCE)                                 */          01635516
 /*                                                                 */          01635520
 /* EXTERNAL NAME:                                                  */          01635524
 /*    XXXX.RELYYYY.PASS2.SOURCE, WHERE XXXX IS THE HIGH LEVEL      */          01635528
 /*    QUALIFIER AND YYYY IS THE THE COMPILER VERSION               */          01635532
 /*                                                                 */          01635536
 /* FUNCTIONAL DESCRIPTION:                                         */          01635540
 /*    DEREF IS AN XPL 'FUNCTION' WHICH RETURNS EITHER TRUE OR      */          01635544
 /*    FALSE. IT CALLS NAME_FUNCTION TO DETERMINE IF THE CURRENT    */          01635548
 /*    HALMAT OPERATOR IS NAME COMPARE / ASSIGN, %NAMEADD OR        */          01635552
 /*    %NAMECOPY MACRO. IF INSIDE ONE OF THESE FUNCTIONS,  FURTHER  */          01635556
 /*    CHECKS ARE NECESSARY TO DETERMINE IF PERFORMING A NAME REMOTE*/          01635560
 /*    VARIABLE DEREFERENCE (WHICH IS CURRENTLY RESTRICTED).        */
 /*      1) IF PROCESSING A NON-NAME VARIABLE OR A NON-STRUCTURE    */
 /*         NODE, DO NOT CHECK FOR NAME REMOTE DEREFERENCE SINCE THE*/
 /*         CHECK MAY EMIT FALSE ERRORS; RETURN FALSE.              */
 /*      2) IF POINTS_REMOTE IS NOT SET THEN                        */
 /*         RETURN FALSE (NO NAME REMOTE DEREFERENCE IS OCCURING).  */
 /*    IF NONE OF THE ABOVE CONDITIONS ARE TRUE OR IF NOT IN ONE OF */
 /*    THE ABOVE FUNCTIONS, RETURN TRUE.                            */          01635564
 /*                                                                 */          01635564
 /* INPUT ARGUMENTS:                                                */          01635568
 /*    OP -- THE INDIRECT STACK ENTRY NUMBER TO CHECK               */          01635572
 /*                                                                 */          01635576
 /* EXTERNAL CONTROL VARIABLES:                                     */          01635632
 /*    SYT_FLAGS(OP) -- SYMBOL TABLE FLAGS OF THE IND. STACK ENTRY. */          01635820
 /*    POINTS_REMOTE(OP) -- IS THIS OPERAND A NAME REMOTE?          */          01635636
 /*                                                                 */          01635652
 /* EXTERNAL ROUTINES REFERENCING THIS MODULE( CALLED BY ):         */          01635656
 /*    GET_OPERAND                                                  */          01635660
 /*    GUARANTEE_ADDRESSABLE                                        */          01635660
 /*    FORCE_ADDRESS                                                */          01635664
 /*    STRUCTURE_DECODE                                             */          01635668
 /*                                                                 */          01635672
 /* EXTERNAL ROUTINES INVOKED( CALLED ):                            */          01635676
 /*    NAME_FUNCTION                                                */          01635680
 /*                                                                 */
 /* EXTERNAL VARIABLES CHANGED:                                     */
 /*    NONE.                                                        */
 /*                                                                 */          01635684
 /* EXTERNAL VARIABLES REFERENCED:                                  */          01635688
 /*    SYT_FLAGS(OP), POINTS_REMOTE(OP).                            */          01635692
 /*                                                                 */          01635700
 /* ALGORITHM/PDL:                                                  */          01635704
 /*    IF NAME_FUNCTION RETURNS TRUE THEN DO;                       */          01635708
 /*       IF PROCESSING A NON-NAME VARIABLE OR A NON-STRUCTURE NODE,*/
 /*       RETURN FALSE                                              */
 /*                                                                 */
 /*       IF POINTS_REMOTE NOT SET THEN RETURN FALSE                */          01635720
 /*    END;                                                         */          01635720
 /*                                                                 */          01635748
 /*    RETURN TRUE;                                                 */          01635752
 /*                                                                 */          01635756
 /* AUTHOR OR RESPONSIBLE PROGRAMMER:                               */          01635760
 /*    DAVID WATSON                                                 */          01635764
 /*                                                                 */          01635768
 /* REVISION HISTORY:                                               */          01635772
 /*    ORIGINALLY CODED FOR DR102948 - 2/89                         */          01635776
 /*    MODIFIED FOR DR109018 -- FEB 1995                            */
 /*                                                                 */          01635780
 /*******************************************************************/          01635784
DEREF: PROCEDURE(OP) BIT(1); /* DR109018 */                                     01635788
DECLARE OP BIT(16);          /* DR109018 */
                                                                                01635792
         /* CALL NAME_FUNCTION ROUTINE TO DETERMINE IF THE CURRENT */           01635832
         /* HALMAT OPERATOR IS A NAME() ASSIGNMENT / COMPARE,      */           01635836
         /* %NAMEADD OR %NAMECOPY MACRO.                           */
         IF NAME_FUNCTION(OP) THEN DO;                   /*DR111390*/           01635840

            /* CHECK IF LOC2 IS NON-NAME VARIABLE. SINCE INSIDE A NAME-TYPE */
            /* FUNCTION, A NAME VAR CANNOT GET DEREFERENCED TO A NON-NAME   */
            /* VAR; AN INDEX VALUE WOULD BE ADDED TO THE NAME INSTEAD.      */
            /*                                                              */
            /* THIS IS NECESSARY BECAUSE GUARANTEE_ADDRESSABLE CALLS DEREF &*/
            /* CHECKING LOC, NOT LOC2, FOR A REMOTE_FLAG. DEREF WOULD ALWAYS*/
            /* FALSELY RETURN TRUE (DEREF) WHEN LOC IS A NAME STRUCT. REMOTE*/
            /* W/OUT ANY STRUCTURE NODES AND POINTS REMOTE IS SET.          */
            /*                                                              */
            /* ALSO IF PROCESSING A NON-STRUCTURE VAR RETURN FALSE.         */
            /* FOR EXAMPLE: NAME(NAME_SCALAR_REMOTE) WOULD                  */
            /* HAVE POINTS_REMOTE SET BUT NO POSSIBILITY OF A DEREFERENCE.  */
            /* (ONLY STRUCTURE NAME NODES CAN BE TRUELY DEREFERENCED.)      */
            /*                                                              */
            IF ( ((SYT_FLAGS(LOC2(OP)) & NAME_FLAG) = 0) |
               (SYT_TYPE(LOC(OP)) ^= STRUCTURE) ) THEN
               RETURN FALSE;

            /* REMOVED BX114 FOR NAME_REMOTE.NAME (& 'ELSE')   /* CR12432 */

            /* CHECK IF POINTS_REMOTE(OP) = 0 -> RETURN FALSE */
            IF POINTS_REMOTE(OP) = 0 THEN
            RETURN FALSE ;                                                      01635848
         END ;                                                                  01635852
                                                                                01635856
         RETURN TRUE ;                                                          01635932
                                                                                01635936
      END DEREF ;                                                               01635940
 /**************** DR102965 START *************/                                01652856
 /* ROUTINE TO DETERMINE THE REMOTENESS OF OPERANDS OF NAME ASSIGN,
      %NAMEADD, AND %NAMECOPY OPERATIONS. */
SET_NAME_TYPE:
      PROCEDURE(OP);
         DECLARE OP BIT(16);
 /* THE SOURCE OPERAND MAY BE A NAME OR NON_NAME VARIABLE, SO THE
      SECOND PART OF THE CONDITIONAL IS NEEDED. TO CHECK FOR NON-NAME
      VARIABLES THAT LIVE REMOTE. SINCE THE DESTINATION MUST BE A NAME
      VARIABLE, THE SECOND PART OF THE CONDITIONAL SHOULD HAVE NO
      EFFECT ON IT. */

         IF POINTS_REMOTE(OP) | (LIVES_REMOTE(OP) & ^NAME_VAR(OP)) THEN
            TYPE(OP) = RPOINTER;
         ELSE
            TYPE(OP) = APOINTER;
      END SET_NAME_TYPE;
 /**************** DR102965 FINISH ***********/                                 01652856
 /* ROUTINE TO DUMP OUT CONTENTS OF SPECIFIED INDIRECT STACK */                 01653020
DUMP_STACK:                                                                     01653030
      PROCEDURE(OP);                                                            01653040
         DECLARE OP BIT(16), MSG CHARACTER;                                     01653050
         IF LINE# ^= LAST_STACK_HEADER THEN DO;                                 01653070
            LAST_STACK_HEADER = LINE#;                                          01653080
            OUTPUT =                                                            01653090
 ' N FM  LOC LOC2 TP  B DISP RG IX XS  XC RW CL DL CY VM BR  NX NXI  SC SX S XM'01653100
               ;                                                                01653110
         END;                                                                   01653120
         IF FORM(OP) = SYM | FORM(OP) = SYM2 THEN                               01653130
            MSG = ','||SYT_NAME(LOC(OP));                                       01653140
         ELSE MSG = '';                                                         01653150
         OUTPUT=FORMAT(OP,2)||FORMAT(FORM(OP),3)||FORMAT(LOC(OP),5)||           01653160
            FORMAT(LOC2(OP),5)||FORMAT(TYPE(OP),3)||FORMAT(BASE(OP),3)||        01653170
            FORMAT(DISP(OP),5)||FORMAT(REG(OP),3)||FORMAT(INX(OP),3)||          01653180
            FORMAT(INX_SHIFT(OP),3)||FORMAT(INX_CON(OP),4)||                    01653190
            FORMAT(ROW(OP),3)||FORMAT(COLUMN(OP),3)||FORMAT(DEL(OP),3)||        01653200
            FORMAT(COPY(OP),3)||FORMAT(VMCOPY(OP),3)||FORMAT(BACKUP_REG(OP),3)||01653210
            FORMAT(NEXT_USE(OP),4)||FORMAT(INX_NEXT_USE(OP),4)||                01653220
            FORMAT(STRUCT_CON(OP),4)||FORMAT(STRUCT_INX(OP),3)||                01653230
            FORMAT(STRUCT(OP),2)||FORMAT(INX_MUL(OP),3)||MSG;                   01653240
      END DUMP_STACK;                                                           01653260
                                                                                01653270
STACK_STATUS:                                                                   01653280
      PROCEDURE;                                                                01653290
         DECLARE I BIT(16);                                                     01653300
         IF STACK_DUMP THEN                                                     01653310
            DO I = 1 TO STACK_MAX;                                              01653320
            IF STACK_PTR(I) < 0 THEN                                            01653330
               CALL DUMP_STACK(I);                                              01653340
         END;                                                                   01653350
         LAST_STACK_HEADER = 0;                                                 01653360
      END STACK_STATUS;                                                         01653370
                                                                                01674000
 /* ROUTINE TO ADVANCE TO NEXT AVAILABLE STACK ENTRY IN FREE LIST */            01674500
NEXT_STACK:                                                                     01675000
      PROCEDURE BIT(16);                                                        01675500
         DECLARE PTR BIT(16);                                                   01676000
         PTR = STACK_PTR;                                                       01676500
         STACK_PTR = STACK_PTR(STACK_PTR);                                      01677000
         IF PTR = 0 THEN                                                        01677500
            CALL ERRORS(CLASS_BS, 106);                                         01678000
         STACK_PTR(PTR) = -1;                                                   01678500
         IF PTR > STACK_MAX THEN                                                01679000
            STACK_MAX = PTR;                                                    01679500
         IF DIAGNOSTICS THEN OUTPUT = 'GOT STAK ' || PTR;                       01680000
         RETURN PTR;                                                            01680500
      END NEXT_STACK;                                                           01681000
                                                                                19490000
   /*---------------------------- #DREG -----------------------------*/         19500006
   /* DANNY -- KEEP STATISTICS ON RESTRICTED REGISTERS BEING USED    */         19510006
   /*          TO ADDRESS THE WRONG DATA.  RETURN THE REGISTER THAT  */         19520006
   /*          SHOULD BE USED (R2 FOR #P, R3 FOR #D).                */         19530006
   REG_STAT: PROCEDURE(OP,R,TYPE_LOAD) BIT(16);                                 19540006
      DECLARE (OP,R) BIT(16);                                                   19550006
      DECLARE TYPE_LOAD BIT(8);                                                 12230005
      DECLARE (C_TYPE,NEW_REG) BIT(16);                                         19610006
                                                                                19620006
      /***********************************************************/             19630006
      /* HERE ARE THE CASES WHERE THE REGISTER IS NOT BEING USED */             19640006
      /* AS A BASE, SO DON'T RESTRICT ITS USAGE.                 */             19650006
      /* -- SETTING UP MVH SOURCE OPERAND, OR NO NAME DEREFERENCE*/             19660006
      IF D_MVH_SOURCE | NAME_FUNCTION(OP) THEN         /*DR111390*/             19670006
         RETURN R;                                                              19690006
      /***********************************************************/             19710006
                                                                                19720006
      /***********************************************************/             19730006
      /* LOAD ADDRESS (LA) INTO ANY BASE IS OK IF WE'RE SETTING  */             19740006
      /* UP TO CALL A RTL ROUTINE.                               */             19750006
      IF D_RTL_SETUP & (TYPE_LOAD=LOADADDR) THEN DO;                            19760006
      /* IF R1/R3 USED FOR PARAMETER PASSING TO INTRINSIC RTL, THEN */          19441099
      /* THEY WILL BE RESTORED UPON EXIT FROM THE RTL ROUTINE.      */          19442099
      /* (PASSING PARAMETER TO NON-INTRINSIC IN R1/R3 IS ILLEGAL.)  */          12400005
         IF R=3 THEN D_R3_CHANGE = FALSE;                                       19443099
         IF R=1 THEN D_R1_CHANGE = FALSE;                                       19444099
         RETURN R;                                      /* DR109022 */          19780006
      END;                                                                      19790006
      /***********************************************************/             19800006
                                                                                19810006
      /***********************************************************/             19820006
      /* MUST USE R3 TO LOAD A DO-CASE LABEL (LABELS ARE IN #D). */             19830006
      /* LABELS DONT HAVE INDIRECT STACK ENTRY, SO SKIP REST OF  */             19840006
      /* PROCESSING AND RETURN NOW.                              */             19850006
      IF (R=2) & (TYPE_LOAD=LOADLABEL) THEN DO;                                 12510010
         D_R3_CHANGE = SHL(D_R3_CHANGE,1) | TRUE;                               12520010
         RETURN 3;                                                              19890006
      END;                                                                      19900006
      /***********************************************************/             19910006
                                                                                19920006
      NEW_REG = R;                                                              19930006
      C_TYPE = CSECT_TYPE(LOC(OP),OP);                                          19940006
                                                                                19950006
      /***********************************************************/             19960006
      /* LOADING BASE R1 OR R3 WITH A 16-BIT NAME VARIABLE VALUE.*/             19970006
      IF ((R=3) | (R=1)) & (TYPE_LOAD=LOADNAME) THEN DO;   /*DR109095*/         19980006
         IF (^NR_DEREF(OP)) & (^NR_DEREF_TMP(OP)) THEN     /*DR109095*/         19980006
           NEW_REG = 2;                                                         19990006
         ELSE IF (SYT_FLAGS(LOC(OP))&NAME_FLAG)^=0 THEN    /*DR109095*/         19980006
           NEW_REG = 2;                                    /*DR109095*/         19990006
      END;                                                 /*DR109095*/         19990006
      ELSE                                                                      20010006
      /***********************************************************/             20020006
      /* LOADING BASE R1 OR R3 WITH A FORMAL PASS-BY-REFERENCE   */             20030006
      /* PARAMETER INSIDE AN INTERNAL PROCEDURE.                 */             20040006
      IF ((R=3) | (R=1)) & (TYPE_LOAD=LOADPARM) THEN                            20050006
         NEW_REG = 2;                                                           20060006
                                                                                20070006
      ELSE                                                                      20080006
      /***********************************************************/             20090006
      /* LOADING BASE R1 OR R3 WITH A NON-#D BASE VALUE.         */             20100006
      IF ((R=3) | (R=1)) & (C_TYPE ^= LOCAL#D) THEN                             20110006
         NEW_REG = 2;                                                           20120006
                                                                                20130006
      ELSE                                                                      20140006
      /***********************************************************/             20150006
      /* LOADING BASE R2 WITH A #D BASE VALUE.                   */             20160006
      IF (R=2) & (C_TYPE = LOCAL#D) & (TYPE_LOAD^=LOADNAME) &                   20170006
 /***** DR108617 - TEV - 4/26/93 ******************************/
 /* IF NAME_VAR IS SET, ITEM IS A NAME VARIABLE BEING         */
 /* DEREFERENCED. DO NOT USE REGISTER R3 AS THE BASE REGISTER */
 /* BECAUSE THE DEREFERENCE WOULD KILL THE DSR NUMBER IN THE  */
 /* LOWER HALFWORD OF REGISTER R3.                            */
        (^NAME_VAR(OP)) THEN DO;
 /***** END DR108617 ******************************************/
         NEW_REG = 3;                                                           20180006
         D_R3_CHANGE = SHL(D_R3_CHANGE,1) | TRUE;                               12830010
      END;                                                                      20200006
                                                                                20210006
      /***********************************************************/             20220006
      RETURN NEW_REG;                                                           20240006
                                                                                20250006
   END REG_STAT;                                                                20260006
   /*----------------------------------------------------------------*/         20270006
                                                                                01681500
   /*---------------------------- #DPARM ----------------------------*/         19980020
   /* DANNY -- KEEP STATISTICS ON PARAMETERS PASSED BY REFERENCE     */         19990030
   /*          TO RUNTIME LIBRARY ROUTINES AND PROCEDURES/FUNCTIONS  */         20000040
   /* RESTRICT REMOTE #D DATA FROM BEING PASSED BY REFERENCE.        */         20000040
   PARM_STAT: PROCEDURE(OP,ROUTINE);                                            20010099
      DECLARE OP      BIT(16);                                                  20020060
      DECLARE ROUTINE CHARACTER; /* PARAMETERS ARE PASSED TO THIS */            20030099
                                 /* ROUTINE -- FOR INFORMATION ONLY */          20040099
                                                                                20050099
      IF OP <= 0 THEN RETURN;                                                   20060097
                                                                                20070080
      IF (CSECT_TYPE(LOC(OP),OP) = LOCAL#D) THEN                                20080099
      /*--------- #D DATA PASSED BY REFERENCE ---------*/                       20090090
         CALL ERRORS(CLASS_FT, 108);                                            20100096
                                                                                20110070
   END PARM_STAT;                                                               20120080
   /*----------------------------------------------------------------*/         20130090
                                                                                20140000
 /* SUBROUTINE TO GET A FREE INDIRECT STACK ENTRY  */                           01682000
 /* WHEN A NEW FIELD IS CREATED IN THE INDIRECT STACK, */
 /* UPDATE THE COPY_STACK_ENTRY PROCEDURE SO THAT IT   */
 /* COPIES THAT FIELD AS WELL                          */
GET_STACK_ENTRY:                                                                01682500
      PROCEDURE FIXED;                                                          01683000
         DECLARE PTR BIT(16);                                                   01683500
         PTR = NEXT_STACK;                                                      01684000
         STRUCT_WALK(PTR)=FALSE;   /*DR109016*/
         AIA_ADJUSTED(PTR)=FALSE;    /* DR109019 */
         REG(PTR), BACKUP_REG(PTR) = -1;                                        01684500
         INX(PTR), BASE(PTR) = 0;                                               01685000
         INX_SHIFT(PTR), COPT(PTR) = 0;                                         01685500
         COLUMN(PTR), DEL(PTR) = 0;                                             01686000
         CONST(PTR), INX_CON(PTR) = 0;                                          01686500
         STRUCT_CON(PTR), COPY(PTR) = 0;                                        01687000
         STRUCT(PTR), STRUCT_INX(PTR) = 0;                                      01687500
         VMCOPY(PTR), NEXT_USE(PTR) = 0;                                         1687600
 /****************** DR54572 START ****************/
         IND_STACK(PTR).I_CSE_USE = 0;                                          01687733
         IND_STACK(PTR).I_DSUBBED = 0;                                          01687866
 /****************** DR54572 FINISH ***************/
         INX_MUL(PTR) = 1;                                                      01688000
 /************** DR102965 START *************/
         POINTS_REMOTE(PTR) = 0;                                                01688010
         LIVES_REMOTE(PTR) = 0;                                                 01688020
         NAME_VAR(PTR) = 0;
 /************** DR102965 FINISH ***********/
         NR_DEREF(PTR) = 0; /* CR12432 */
         NR_STACK(PTR) = 0; /* CR12432 */
         NR_DELTA(PTR) = 0; /* CR12432 */
         NR_BASE(PTR) = 0;          /*DR109095*/
         NR_DEREF_TMP(PTR) = FALSE; /*DR109095*/
         RETURN PTR;                                                            01688500
      END GET_STACK_ENTRY;                                                      01689000
                                                                                01689500
 /* ROUTINE TO RELEASE AN INDIRECT STACK ENTRY  */                              01690000
RETURN_STACK_ENTRY:                                                             01690500
      PROCEDURE(P);                                    /*DR109068*/             01691000
   RETURN_ENTRY:                                       /*DR109068*/
         PROCEDURE(PTR);                               /*DR109068*/
         DECLARE PTR BIT(16);                                                   01691500
         IF PTR=0 THEN RETURN;                                                  01692000
      /* RELEASE STACK LOCATION OF NAME REMOTE PUT ON STACK /* CR12432 */
         IF (NR_STACK(PTR) >0) THEN DO;                /* CR12432 */
            SAVEPTR = SAVEPTR + 1;                     /* CR12432 */
            SAVEPOINT(SAVEPTR) = NR_STACK(PTR);        /* CR12432 */
         END;                                          /* CR12432 */
         STACK_PTR(PTR) = STACK_PTR;                                            01692500
         STACK_PTR = PTR;                                                       01693000
         IF STACK_DUMP THEN CALL DUMP_STACK(PTR);                               01693500
         ELSE IF DIAGNOSTICS THEN OUTPUT = 'RET STACK ' || PTR;                 01693510
      END RETURN_ENTRY;                                            /*DR109068*/
      DECLARE P BIT(16);                                           /*DR109068*/
      /*RETURN INDIRECT & RUNTIME STACK ENTRIES LEFT AFTER NAME REMOTE DEREF*/
      IF (NR_BASE(P)>0)&(STACK_PTR(NR_BASE(P))<0) THEN DO;         /*DR109095*/
         SAVEPTR = SAVEPTR + 1;                                    /*DR109095*/
         SAVEPOINT(SAVEPTR) = LOC(NR_BASE(P));    /*RUNTIME STACK -  DR109095*/
         CALL RETURN_ENTRY(NR_BASE(P));           /*INDIRECT STACK - DR109095*/
      END;                                                         /*DR109095*/

      /*DR109068 -- CHECK FOR INDIRECT STACK AND RUNTIME STACK ENTRIES NOT */
      /* RETURNED FOR A CHECKPOINTED BASE REGISTER AND RETURN THEM HERE.   */
      IF FORM(P) = CSYM THEN DO;                                   /*DR109068*/
         IF (BASE(P) < 0) & (STACK_PTR(-BASE(P))< 0) THEN DO;      /*DR109068*/
            WORK_USAGE(LOC(-BASE(P)))=WORK_USAGE(LOC(-BASE(P)))-1; /*DR109068*/
            IF WORK_USAGE(LOC(-BASE(P)))=0 THEN DO;                /*DR109068*/
               SAVEPTR = SAVEPTR + 1;                              /*DR109068*/
               SAVEPOINT(SAVEPTR) = LOC(-BASE(P));/*RUNTIME STACK  - DR109068*/
               CALL RETURN_ENTRY(-BASE(P));      /*INDIRECT STACK  - DR109068*/
            END;                                                   /*DR109068*/
         END;                                                      /*DR109068*/
      END;                                                         /*DR109068*/
      CALL RETURN_ENTRY(P);  /*RETURN INDIRECT STACK ENTRY P*/     /*DR109068*/
      END RETURN_STACK_ENTRY;                                      /*DR109068*/
                                                                                01694500
 /* ROUTINE TO RETURN A PAIR OF INDIRECT STACK ENTRIES */                       01695000
RETURN_STACK_ENTRIES:                                                           01695500
      PROCEDURE(PTR1, PTR2);                                                    01696000
         DECLARE (PTR1, PTR2) BIT(16);                                          01696500
         CALL RETURN_STACK_ENTRY(PTR2);                                         01697000
         CALL RETURN_STACK_ENTRY(PTR1);                                         01697500
      END RETURN_STACK_ENTRIES;                                                 01698000
                                                                                01698500
 /* DR109059/DR109064 - ROUTINE TO RETURN INDIRECT STACK ENTRY FOR COLUMN(PTR)*/
 /*INSTANCES OF WHEN PTR POINTS TO A BIT OR EVENT TYPE.  IN THESE CASES,      */
 /*COLUMN(PTR) WAS GOTTEN IN SIZEFIX.  IF BIT_FLAG IS TRUE, COLUMN(PTR) MAY   */
 /*BE RETURNED FOR EITHER EVENT OR BIT TYPE.  IF IT IS FALSE, COLUMN(PTR) MAY */
 /*ONLY BE RETURNED FOR EVENT TYPE.                                           */
RETURN_COLUMN_STACK:
      PROCEDURE(PTR,BIT_FLAG);
         DECLARE PTR BIT(16);
         DECLARE BIT_FLAG BIT(1);
         IF SYMFORM(FORM(PTR)) THEN DO;  /*MAKE SURE PTR REFERS TO A SYMBOL*/
            IF BIT_FLAG & ( (SYT_TYPE(LOC2(PTR)) = BITS) |
            (SYT_TYPE(LOC2(PTR)) = FULLBIT) ) THEN DO;
                  CALL RETURN_STACK_ENTRY(COLUMN(PTR));
                  COLUMN(PTR) = 0;
            END;
            ELSE DO;  /*RETURN COLUMN(PTR) IF PTR POINTS TO EVENT*/
               IF (SYT_TYPE(LOC2(PTR)) = EVENT) THEN DO;
                  CALL RETURN_STACK_ENTRY(COLUMN(PTR));
                  COLUMN(PTR) = 0;
               END;
            END;
         END;
         BIT_FLAG = FALSE;
      END RETURN_COLUMN_STACK;

 /* ROUTINE TO MARK THE CONTENTS OF A REGISTER AS NOT RECOGNIZABLE */           01699000
UNRECOGNIZABLE:                                                                 01699500
      PROCEDURE(R);                                                             01700000
         DECLARE R BIT(16);                                                     01700500
         USAGE(R) = USAGE(R) & (^TRUE);                                         01701000
      END UNRECOGNIZABLE;                                                       01701500
                                                                                01702000
 /* PROCEDURE TO CLEAR ALL R_INX USERS OF AN INDEXING REGISTER */               01702500
CLEAR_INX:                                                                      01703000
      PROCEDURE(R);                                                             01703500
         DECLARE (R, I) BIT(16);                                                01704000
         IF INDEXING(R) THEN                                                    01704500
            DO I = 0 TO REG_NUM;                                                01705000
            IF R_INX(I) = R THEN                                                01705500
               CALL UNRECOGNIZABLE(I);                                           1706000
         END;  /* DO I */                                                       01706500
      END CLEAR_INX;                                                            01707000
                                                                                01707500
 /* ROUTINE TO CLEAR REGISTER STACKS FOR A GIVEN REGISTER  */                   01708000
CLEAR_R:                                                                        01708500
      PROCEDURE(R);                                                             01709000
         DECLARE R BIT(16);                                                     01709500
         R_VAR(R), R_INX(R) = 0;                                                01710000
         R_VAR2(R), R_MULT(R) = 0;                                              01710500
         R_INX_CON(R), R_CON(R) = 0;                                            01711000
         R_TYPE(R), R_INX_SHIFT(R) = 0;                                         01711500
         DOUBLE_TYPE(R) = 0; /*------- DR103754 --------*/                      01711500
         USAGE(R), USAGE_LINE(R) = 0;                                           01712000
         R_CONTENTS(R) = 0;                                                     01712500
         CALL CLEAR_INX(R);                                                     01713000
         IF R = LINKREG THEN CALL SET_LINKREG;                                  01713500
      END CLEAR_R;                                                              01714000
                                                                                01714500
 /* ROUTINE TO DETERMINE IF STACK ENTRY REFERS TO REMOTE DATA */                01715000
CHECK_REMOTE:                                                                   01715500
      PROCEDURE(OP) BIT(1);                                                     01716000
         DECLARE OP BIT(16);                                                    01716500
         IF OP > 0 THEN                                                         01717000
            IF SYMFORM(FORM(OP)) THEN                                           01717500
            /* CHECK FOR A STRUCTURE WALK BEFORE PROCEEDING WITH  -- DR109055*/
            /* REMOTENESS CHECKS. IF A STRUCTURE WALKED OCCURRED, -- DR109055*/
            /* POINTS_REMOTE CONTAINS THE CORRECT REMOTENESS      -- DR109055*/
            /* VALUE SO RETURN THE VALUE OF POINTS_REMOTE.        -- DR109055*/
            IF STRUCT_WALK(OP) THEN                                /*DR109055*/
               RETURN POINTS_REMOTE(OP);                           /*DR109055*/
            ELSE                                                   /*DR109055*/
            IF (SYT_FLAGS(LOC(OP)) & NAME_OR_REMOTE) = REMOTE_FLAG THEN          1718000
            RETURN TRUE;                                                         1718010
         ELSE IF SYT_SCOPE(LOC(OP)) < PROGPOINT THEN                             1718020
            IF ((SYT_FLAGS(PROC_LEVEL(SYT_SCOPE(LOC(OP))))&REMOTE_FLAG) ^= 0)    1718030
   /*-RSJ----CR11096--------------- #DFLAG --------------------------*/
   /* MAKE SURE IT'S A COMPOOL, SINCE COMSUBS NOW MAY HAVE FLAG SET. */
               & (SYT_TYPE(PROC_LEVEL(SYT_SCOPE(LOC(OP)))) = COMPOOL_LABEL)
   /*----------------------------------------------------------------*/
            THEN RETURN TRUE;                                                    1718040
      /* TREAT NR DEREFERENCE LIKE REMOTE                 CR12432 */
         IF OP > 0 THEN DO;                            /* CR12432 */
            IF SYMFORM(FORM(OP)) THEN                  /* CR12432 */
            IF ((SYT_FLAGS(LOC(OP)) & NAME_OR_REMOTE)  /* CR12432 */
/*DR111390*/    = NAME_OR_REMOTE) & ^NAME_FUNCTION(OP) /* CR12432 */
               THEN RETURN TRUE;                       /* CR12432 */
            IF NR_DEREF(OP) THEN RETURN TRUE;          /* CR12432 */
         END;                                          /* CR12432 */
         RETURN FALSE;                                                          01718500
      END CHECK_REMOTE;                                                         01719000

/************ DR107307 - TEV - 5/13/94 *****************/
/* CHECK STRUCTURE NODE AND RETURN TRUE IF NAME REMOTE */
CHECK_STRUCT_NODE_REMOTENESS:
      PROCEDURE(OP) BIT(1);
         DECLARE OP BIT(16);
         IF (FORM(OP) = SYM) | (FORM(OP) = CSYM) THEN DO;
            IF SYT_TYPE(LOC(OP)) = STRUCTURE THEN DO;
               IF ((SYT_FLAGS(LOC2(OP)) & NAME_OR_REMOTE) =
                  NAME_OR_REMOTE) THEN RETURN TRUE;
               ELSE RETURN FALSE;
            END;
            RETURN FALSE;
         END;
         RETURN FALSE;
END CHECK_STRUCT_NODE_REMOTENESS;
/************ END DR107307 *****************************/
                                                                                01719500
 /* ROUTINE TO DETERMINE IF LINKAGE REGISTER IS DESTROYED */                    01720000
CHECK_LINKREG:                                                                  01720500
      PROCEDURE(R);                                                             01721000
         DECLARE R BIT(16);                                                     01721500
         IF R = LINKREG THEN CALL NEED_STACK(NARGINDEX);                        01722000
      END CHECK_LINKREG;                                                        01722500
                                                                                01723000
 /* ROUTINE TO COUNT INSTRUCTIONS AND CHECK SIDE EFFECTS */                     01723500
OPSTAT:                                                                         01724000
      PROCEDURE(INST, XREG);                                                    01724500
         DECLARE (INST, XREG) BIT(16);                                          01725000
         DECLARE CLASS_C BIT(8) INITIAL(11); /*= DAS DR102945 2/1/94 =*/
         DO CASE OPCC(INST);                                                    01726000
            ;  /* CONDITION CODE UNAFFECTED */                                  01726500
            CCREG = XREG;   /* REGISTER AFFECTED BY CONDITION CODE */           01727000
            CCREG = 0;  /* CONDITION CODE NO LONGER VALID */                    01727500
            CCREG = -XREG;  /* LOGICAL CONDIITION CODE */                       01728000
         END;                                                                   01728500
 /?B  /* CR11114 -- BFS/PASS INTERFACE; CHANGE OP_STAT TO TURN   */
      /*            OFF FIRST TIME                               */
      IF ^DECLMODE THEN
         FIRST_TIME = FALSE;
 ?/
      /*===== DAS DR102945 2/1/94 ===============================*/
      /* WARNING FOR CED/CEDR: BROKEN AND REPLACED WITH CE/CER   */
      IF INST = "69" | INST = "29" THEN
         CALL ERRORS(CLASS_C,5);
      /*=========================================================*/
      END OPSTAT;                                                               01729000
                                                                                01729500
/*--------------------------- #DREG -------------------------------*/           21460099
/* DO THE ACTUAL RESTORE OF REGISTER: R1 FROM STACK LOCATION 5.    */           21470099
/* R3 FROM STACK LOCATION 9. IF A CONDITIONAL BRANCH, MUST         */           21480099
/* PRESERVE CONDITION CODES (UNLESS CONDITION IS ALWAYS).          */           21490099
RESTORE_R1R3:                                                                   21500099
     PROCEDURE(INST, XREG, STACKLOC, COND);                                     14270011
        DECLARE (INST, XREG, STACKLOC, COND) BIT(16);                           14280011
        DECLARE FLAG(1) BIT(16);  /*DR111302*/                                  14290013
        DECLARE VALUE(1) BIT(16); /*DR111302*/
        DECLARE I BIT(16); /* DR109015 */                                       14290013
                                                                                14300011
           /* MAY BE PROLOG OR DELTA ALREADY EMITTED FOR NEXT INST */           14310011
/*DR107705    OR MAY BE AN RLD CARD MODIFYING NEXT INST */                      14320011
           /* SO WE MUST MOVE THEM BELOW OUR RESTORE CODE SEQUENCE.*/           14320011
/*DR111302    THERE MAY BE A PROLOG & DELTA CONSECUTIVELY FOR MULTIPLE   */
/*DR111302    BIT(1)/BOOLEAN AUTOMATIC INITIALIZATIONS, SO NEED 2 MOVES. */
        DO FOR I = 0 TO 1;                                     /*DR111302*/
           FLAG(I) = SHR(CODE(GET_CODE(CODE_LINE-1)),16);      /*DR111302*/     14330013
           VALUE(I) = CODE(GET_CODE(CODE_LINE-1)) & "FFFF";    /*DR111302*/     14340013
           IF (FLAG(I) = PROLOG) | (FLAG(I) = DELTA) |         /*DR111302*/     14350013
/*DR107705*/  (FLAG(I) = RLD) THEN                             /*DR111302*/     14350013
              CODE_LINE = CODE_LINE - 1;                                        21560099
        END;                                                   /*DR111302*/
                                                                                21580099
           IF (INST = BC) | (INST = BCF) | (INST = BCR) | (INST = BCRE)         21590099
              & (COND ^= ALWAYS) THEN DO;                                       14390011
           /* IHL XREG,STACKLOC(R0); SLL XREG,16 - PRESERVES CC */              21610099
              CALL EMITC(RXTYPE, SHL(IHL,8) | SHL(XREG & RM,4));                21620099
              CALL EMITC(CSYM, TEMPBASE);                                       21630099
              CALL EMITC(ADCON, STACKLOC);                                      21640099
              CALL OPSTAT(IHL,XREG);                                            21650099
              CALL EMITC(SRSTYPE, SHL(SLL,8) | SHL(XREG,4));                    21660099
              CALL EMITC(SHCOUNT, 16);                                          21670099
              CALL OPSTAT(SLL,XREG);                                            21680099
           END;                                                                 21690099
           ELSE DO;                                                             21700099
           /* LH XREG,STACKLOC(R0) - SIMPLE LOAD, DOES NOT PRESERVE CC */       21710099
              CALL EMITC(SRSTYPE, SHL(LH,8) | SHL(XREG & RM,4));                21720099
              CALL EMITC(CSYM, TEMPBASE);                                       21730099
              CALL EMITC(ADCON, STACKLOC);                                      21740099
              CALL OPSTAT(LH,XREG);                                             21750099
           END;                                                                 21760099
                                                                                21770099
           /* MOVE PROLOG OR DELTA DOWN */                                      14570013
           IF (FLAG(1) = PROLOG) | (FLAG(1) = DELTA) |         /*DR111302*/
               (FLAG(1) = RLD)                                 /*DR111302*/
               THEN CALL EMITC(FLAG(1), VALUE(1));             /*DR111302*/
           IF (FLAG = PROLOG) | (FLAG = DELTA) |                                14580013
/*DR107705    OR RLD CARD */                                                    14570013
/*DR107705*/  (FLAG = RLD)                                                      14350013
              THEN CALL EMITC(FLAG, VALUE);                                     14590013
                                                                                14600011
           R_VAR(XREG) = 0; /*DOES NOT CONTAIN VIRTUAL BASE ANYMORE*/           21800099
           /* DR109015: IF BASE NOT USED YET, CSYMS BECOME SYMS AGAIN */        21810099
           /* THIS CORRECTS %MACRO PROBLEMS WHEN BASE LOADED EARLY. */          21810099
           DO I = 1 TO STACK_MAX;                 /* DR109015 */                21810099
              IF STACK_PTR(I) < 0 &               /* DR109015 */                21810099
                 FORM(I) = CSYM & BASE(I) = XREG  /* DR109015 */                21810099
                 THEN FORM(I) = SYM;              /* DR109015 */                21810099
           END;                                   /* DR109015 */                21810099
                                                                                21810099
     END RESTORE_R1R3;                                                          21820099
                                                                                21830099
/*--------------------------- #DREG -------------------------------*/           21840099
/* RESTORE R1/R3 AFTER IT HAS BEEN CHANGED FROM THE #D POINTER TO  */           14660005
/* SOME OTHER BASE ADDRESS VALUE AND USED TO REFERENCE #D DATA.    */           14670005
/* COND IS CONDITION FOR BRANCH INST, OTHERWISE IT'S THE DEST REG. */           14670005
CHECK_RESTORE_R1R3:                                                             21870099
     PROCEDURE(INST, FLAG, XBASE, COND, INSTYPE);                               14690015
        DECLARE (INST, FLAG, XBASE, COND, INSTYPE) BIT(16);                     14700015
                                                                                14730005
      /* DR109015: IF THIS IS A CHECKPOINT, DONT RESTORE, BECAUSE */            14730005
      /* CURRENT INSTRUCTION MAY NEED R1/R3 */                                  14730005
        IF ( (INST=ST) | (INST=STH) | (INST=STE) |     /*109015,107880,111382*/ 14730005
             (INST=STD) ) & XBASE = 0 THEN RETURN;        /*DR109015,DR111382*/ 14730005
                                                                                14730005
      /* A PREVIOUS INSTRUCTION HAS USED THE VIRTUAL VALUE IN R1/R3 */          14740005
      /* SO RESTORE IT, UNLESS THE CURRENT INSTRUCTION ALSO NEEDS IT*/          14750005
      /* DR109015: OR REGULAR R1/R3 IS NEEDED FOR VARIABLE OR BASEREG*/         14750005
      /* DR109015: (CORRECTS %MACRO PROBLEMS WHEN BASE LOADED EARLY) */         02471500
        IF (R1_USED & ^((FLAG = CSYM) & (XBASE = 1)) ) |/*DR111338*/            14760005
           (D_R1_CHANGE & (FLAG = SYM) & (XBASE = 1)) | /*DR109015*/            14760005
           (D_R1_CHANGE & (XBASE >= REMOTE_BASE)) |     /*DR109015*/            14760005
           (D_R1_CHANGE & (FLAG = XPT) & (COND ^= 1) &  /*DR109015*/            14760005
               INSTYPE ^= SRSTYPE) THEN DO;             /*DR109015*/            14760005
           CALL RESTORE_R1R3(INST, 1, NEW_GLOBAL_BASE, COND);                   14770005
           D_R1_CHANGE = SHR(D_R1_CHANGE,1);                                    14780010
           R1_USED = FALSE;                             /*DR111338*/            14790005
        END;                                                                    22190099
        IF (R3_USED & ^((FLAG = CSYM) & (XBASE = 3)) ) |/*DR111338*/            14810005
           (D_R3_CHANGE & (FLAG = SYM) & (XBASE = 3)) | /*DR109015*/            14760005
           (D_R3_CHANGE & (FLAG = XPT) & (COND ^= 3) &  /*DR109015*/            14760005
               INSTYPE = SRSTYPE) THEN DO;              /*DR109015*/            14760005
           CALL RESTORE_R1R3(INST, 3, NEW_LOCAL_BASE, COND);                    14820005
           D_R3_CHANGE = SHR(D_R3_CHANGE,1);                                    14830010
           R3_USED = FALSE;                             /*DR111338*/            14840005
        END;                                                                    14850005
                                                                                22191199
      /* IF THE CURRENT INSTRUCTION USES THE CHANGED R1/R3 AS BASE, */          14870005
      /* THEN WE WILL WAIT TO RESTORE IMMEDIATELY BEFORE THE NEXT   */          14880005
      /* INSTRUCTION SO WE CAN TELL IF WE NEED TO PRESERVE COND CODE*/          14890005
        IF D_R1_CHANGE & (FLAG=CSYM) & (XBASE=1) THEN                           14900007
           R1_USED = TRUE;                              /*DR111338*/            14910005
        IF D_R3_CHANGE & (((FLAG=CSYM) & (XBASE=3)) | (INST=MVH)) THEN          14920007
      /* DONT FORGET TO RESTORE AFTER MVH USES R3 */                            14930007
           R3_USED = TRUE;                              /*DR111338*/            14930007
                                                                                14940008
     END CHECK_RESTORE_R1R3;                                                    22200799
/*-----------------------------------------------------------------*/           22200899
                                                                                21426099
 /* SUBROUTINE TO EMIT RR TYPE INSTRUCTIONS  */                                 01730000
EMITRR:                                                                         01730500
      PROCEDURE(INST, REG1, REG2);                                              01731000
         DECLARE (INST, REG1, REG2) BIT(16);                                    01731500
         /*------------------------CR12385-------------------------*/
         IF REG1 < 0 THEN CALL ERRORS(CLASS_BI,511,'ACCUMULATOR');
         IF REG2 < 0 THEN CALL ERRORS(CLASS_BI,511,'ACCUMULATOR');
         /*------------------------CR12385-------------------------*/
         IF INST ^< "04" THEN REG2 = REG2 & RM;                                 01732000
         IF ASSEMBLER_CODE THEN DO;                                             01732500
            MESSAGE=INSTRUCTION(INST)||X3||(REG1&RM)||COMMA||REG2;              01733000
            OUTPUT=HEX_LOCCTR||X3||MESSAGE||INFO;                               01733500
            INFO='';                                                            01734000
         END;                                                                   01734500
/*--------------------------- #DREG -------------------------------*/           21511099
/* RESTORE R1 OR R3 IF THEY WERE CHANGED TO ADDRESS #D.            */           15090005
/* NOTE THAT REG1 IS THE CONDITION TO BRANCH ON FOR A BRANCH INST. */           15100005
         IF DATA_REMOTE & (D_R1_CHANGE | D_R3_CHANGE)                           21513099
            THEN CALL CHECK_RESTORE_R1R3(INST, 0, 0, REG1,RRTYPE);              21514099
/*-----------------------------------------------------------------*/           21515099
         CALL EMITC(RRTYPE, SHL(INST,8) | SHL(REG1&RM,4) | REG2);               01735000
         CALL OPSTAT(INST, REG1);                                               01735500
 /*- DANNY ------------------- DR103754 -----------------------------*/         02398500
 /* THE REGISTER REALLY CONTAINS A DOUBLE PRECISION VALUE; IT WAS SET*/         02398500
 /* TO SINGLE FOR A SINGLE PRECISION INSTRUCTION, SO SET IT BACK.    */         02398500
 /* FOR REG1,   WE ONLY WANT TO RETURN TYPE TO DOUBLE IF INSTRUCTION */         02398500
 /* IS CER, WHICH IS THE ONLY RR SINGLE INSTRUCTION THAT DOESN'T     */         02398500
 /* CHANGE THE CONTENTS OF THE LEFT REGISTER (REG1).                 */         02398500
         IF (DOUBLE_TYPE(REG1) > 0) & (REG1 >= FR0) & (INST="39") THEN          02398500
            R_TYPE(REG1)=DOUBLE_TYPE(REG1);                                     02398500
         IF (DOUBLE_TYPE(REG2) > 0) & (REG2 >= FR0) THEN                        02398500
            R_TYPE(REG2)=DOUBLE_TYPE(REG2);                                     02398500
 /*- DANNY ----------------------------------------------------------*/         02398500
      END EMITRR;                                                               01736500
                                                                                01737000
 /* SUBROUTINE TO EMIT RX TYPE INSTRUCTIONS */                                  01737500
EMITRX:                                                                         01738000
      PROCEDURE(INST, XREG, INDEX, XBASE, XDISP, NRDEREF); /* CR12432 */
         DECLARE (INST, XREG, INDEX, XBASE, XDISP, INSTYPE) BIT(16);            01739000
         DECLARE NRDEREF BIT(1); /* CR12432 */
         IF ASSEMBLER_CODE THEN DO;                                             01739500
            MESSAGE = INSTRUCTION(INST, SHR(INDEX, 3));                         01740000
            OUTPUT=HEX_LOCCTR||X3||MESSAGE||X3||(XREG&RM)||COMMA                01740500
             ||XDISP||INFO||LEFTBRACKET||(INDEX&RM)||COMMA||XBASE||RIGHTBRACKET;01741000
            INFO='';                                                            01742000
         END;                                                                   01742500
         INSTYPE = CHECK_SRS(INST, INDEX, XBASE, XDISP+INSMOD);                 01743000
         /*------------------------CR12385-------------------------*/
         IF XBASE < 0 THEN CALL ERRORS(CLASS_BI,511,'BASE');
         IF INDEX < 0 THEN CALL ERRORS(CLASS_BI,511,'INDEX');
         IF XREG < 0  THEN CALL ERRORS(CLASS_BI,511,'ACCUMULATOR');
         /*------------------------CR12385-------------------------*/
         /*CR12714- ADD TRAPS FOR INVALID BASE REGISTER            */
         /*XBASE IS ANDED WITH RM TO MASK INTERNAL BITS OF REGISTER*/
         /*ASSIGNMENTS TO MACHINE REGISTER NUMBERS. FOR THE BFS    */
         /*CASE, THE SVC INSTRUCTION MUST BE EXCLUDED FROM THE TRAP*/
         /*BECAUSE THE BASE REGISTER IS HARD CODED TO BE 3.        */
 /?B     IF (INSTYPE = RXTYPE) & ((XBASE & RM) > 2) &          /*CR12714*/
            (INST ^= SVC) THEN CALL ERRORS(CLASS_BI,516,'RS'); /*CR12714*/
 ?/                                                            /*CR12714*/
 /?P     IF (INSTYPE = RXTYPE) & ((XBASE & RM) > 2) THEN  /*CR12714*/
            CALL ERRORS(CLASS_BI,516,'RS');               /*CR12714*/
 ?/                                                       /*CR12714*/
         IF (INSTYPE = SRSTYPE) & ((XBASE & RM) > 3) THEN /*CR12714*/
            CALL ERRORS(CLASS_BI,516,'SRS');              /*CR12714*/
         /*------------------------DR111380------------------------*/
         /* ADD PERMANENT TRAP FOR STORING INTO BASE REGISTER      */
         IF ((INST=ST) | (INST=STH)) & XREG=XBASE THEN   /*DR111380*/
            CALL ERRORS(CLASS_BI,517);                   /*DR111380*/
/*--------------------------- #DREG -------------------------------*/           21771099
/* RESTORE R1 OR R3 IF THEY WERE CHANGED TO ADDRESS #D.            */           21772099
         IF DATA_REMOTE & (D_R1_CHANGE | D_R3_CHANGE)                           21774099
            /* DR109015: PASS IN DESTINATION REGISTER (XREG) */                 21775099
            THEN CALL CHECK_RESTORE_R1R3(INST,CSYM,XBASE,XREG,INSTYPE);         21775099
/*-----------------------------------------------------------------*/           21776099
      /* NAME REMOTE DEREFERENCE                    /* CR12432 */
      /* SET UP TO EMIT INDIRECT ADDRESSING (@#)    /* CR12432 */
         IF NRDEREF THEN DO;                        /* CR12432 */
            /* KEEP AUTO-INCR FROM KILLING Z-CON */ /* CR12432 */
            IF INDEX = 0 THEN INDEX = 1;            /* CR12432 */
            XREG = XREG | 8;                        /* CR12432 */
            INDEX = INDEX | 8;                      /* CR12432 */
            INSTYPE = RXTYPE;                       /* CR12432 */
            CALL EMITC(INSTYPE, SHL(INST,8) | SHL(XREG,4) | INDEX);/* CR12432 */
         END;                                       /* CR12432 */
         ELSE                                       /* CR12432 */
         CALL EMITC(INSTYPE, SHL(INST,8) | SHL(XREG&RM,4) | INDEX);             01743500
         CALL EMITC(CSYM, XBASE);                                               01744000
         CALL EMITC(ADCON, XDISP);                                              01744500
         CALL OPSTAT(INST, XREG);                                               01745000
         INSMOD = 0;                                                            01746000
         NRDEREF=0; /* CR12432 - NRDEREF ONLY PASSED IN FROM EMITOP/EMITXOP */
      END EMITRX;                                                               01746500
                                                                                01747000
 /* ROUTINE TO EMIT SI TYPE INSTRUCTIONS */                                     01747500
EMITSI:                                                                         01748000
      PROCEDURE(INST, XBASE, XDISP, VALUE);                                     01748500
         DECLARE (INST, XBASE, XDISP, VALUE) BIT(16);                           01749000
         IF ASSEMBLER_CODE THEN DO;                                             01749500
            MESSAGE = INSTRUCTION(INST);                                        01750000
            OUTPUT = HEX_LOCCTR || X3 || MESSAGE || X3 || XDISP || INFO ||      01750500
               LEFTBRACKET || XBASE || '),' || VALUE;                           01751000
            INFO = '';                                                          01751500
         END;                                                                   01752000
         /*------------------------CR12385-------------------------*/
         IF XBASE < 0 THEN CALL ERRORS(CLASS_BI,511,'BASE');
         /*------------------------CR12385-------------------------*/
         /*CR12714- ADD TRAP FOR INVALID BASE REGISTER             */
         /*XBASE IS ANDED WITH RM TO MASK INTERNAL BITS OF REGISTER*/
         /*ASSIGNMENTS TO MACHINE REGISTER NUMBERS                 */
         IF (XBASE & RM) > 3 THEN CALL ERRORS(CLASS_BI,516,'SI'); /*CR12714*/
/*--------------------------- #DREG -------------------------------*/           21941099
/* RESTORE R1 OR R3 IF THEY WERE CHANGED TO ADDRESS #D.            */           21942099
         IF DATA_REMOTE & (D_R1_CHANGE | D_R3_CHANGE)                           21944099
            THEN CALL CHECK_RESTORE_R1R3(INST, CSYM, XBASE,0,SSTYPE);           21945099
/*-----------------------------------------------------------------*/           21946099
         CALL EMITC(SSTYPE, SHL(INST, 8));                                      01752500
         CALL EMITC(CSYM, XBASE);                                               01753000
         CALL EMITC(ADCON, XDISP);                                              01753500
         CALL EMITC(ADCON, VALUE);                                              01754000
         CALL OPSTAT(INST, 0);                                                  01754500
         INSMOD = 0;                                                            01755000
      END EMITSI;                                                               01755500
                                                                                01771000
 /* ROUTINE TO FORMAT SYMBOLIC OPERANDS FOR STACK EMITS */                      01771500
FORMAT_OPERANDS:                                                                01772000
      PROCEDURE(FLAG, PTR);                                                     01772500
         DECLARE (FLAG, PTR) BIT(16);                                           01773000
         /* HANDLE REMOTE NAME REMOTE PUT ON STACK   -CR12432 */
         IF FLAG = NRTEMP THEN FLAG = CSYM;        /* CR12432 */
         IF FLAG = AIDX THEN FLAG = INL;           /* DR111307 */
         DO CASE FLAG;                                                          01773500
            CHARSTRING = PTR;                                                   01774000
            CHARSTRING = SYT_NAME(PTR);                                         01774500
            CHARSTRING = SYT_NAME(PTR);                                         01775000
            ;                                                                   01775500
            CHARSTRING = 'BASE_REG#' || PTR;                                    01776000
            ;                                                                   01776500
            CHARSTRING = SYT_NAME(PTR);                                         01777000
            ;                                                                   01777500
            CHARSTRING = '=C''' || DESC(CONSTANTS(PTR)) || QUOTE;               01778000
            CHARSTRING = '=H''' || CONSTANTS(PTR) || QUOTE;                     01778500
            CHARSTRING = '=F''' || CONSTANTS(PTR) || QUOTE;                     01779000
            CHARSTRING = '=XL4''' || HEX(CONSTANTS(PTR),8) || QUOTE;            01779500
            CHARSTRING = '=XL8''' || HEX(CONSTANTS(PTR),8) ||                   01780000
               HEX(CONSTANTS(PTR+1),8) || QUOTE;                                01780500
            CHARSTRING = '=A(#' || PTR || RIGHTBRACKET;                         01781000
            ;                                                                   01781500
            ;                                                                   01782000
            ;                                                                   01782500
            CHARSTRING = '*+'||PTR;                                             01783000
            CHARSTRING = SYT_NAME(PTR);                                         01783500
            CHARSTRING = 'L#' || PTR;                                           01784000
            CHARSTRING = 'P#' || PTR;                                           01784500
            ;                                                                   01785000
            CHARSTRING = ESD_TABLE(PTR);                                        01785500
            CHARSTRING = PTR;                                                   01786000
         END;                                                                   01786500
         CHARSTRING = CHARSTRING || INFO;                                       01787000
         INFO = '';                                                             01787500
      END FORMAT_OPERANDS;                                                      01788000
                                                                                01805500
 /* SUBROUTINE TO EMIT RX INSTRUCTIONS OF UNDETERMINED OPERANDS  */             01806000
EMITP:                                                                          01806500
      PROCEDURE(INST, XREG, INDEX, FLAG, PTR, INSTYPE, NRDEREF); /* CR12432 */
         DECLARE (INST, XREG, INDEX, FLAG, PTR, INSTYPE) BIT(16);               01807500
         DECLARE NRDEREF BIT(1); /* CR12432 */
         DECLARE SWITCH BIT(1);                                                 01807505
         IF FLAG < 0                                                            01807560
            THEN DO;                                                            01807580
            SWITCH = 1;                                                         01807600
            FLAG = -FLAG;                                                       01807620
         END;                                                                   01807640
         ELSE SWITCH = 0;                                                       01807660
         /*------------------------CR12385-------------------------*/
         IF INDEX < 0 THEN CALL ERRORS(CLASS_BI,511,'INDEX');
         IF XREG < 0 THEN CALL ERRORS(CLASS_BI,511,'ACCUMULATOR');
         /*------------------------CR12385-------------------------*/
         CALL OPSTAT(INST, XREG);                                               01808000
         XREG = XREG & RM;                                                      01808500
         IF FLAG = SYM THEN                                                     01809000
            IF (SYT_BASE(PTR) >= REMOTE_BASE)                                    1809500
            /* NAME REMOTE DEREFERENCE NEEDS INDIRECT ADDRESSING /* CR12432 */
               | NRDEREF THEN DO;                                /* CR12432 */
 /**************** DR103422 START **************/
 /* BS123 CHECK DOES NOT APPLY TO NAME REMOTE DEREFERENCING:     /* CR12432 */
 /* BS123 #1 OCCURS FOR STRUCT.NAME_REMOTE (OFFSET>0).           /* CR12432 */
 /* BS123 #3 OCCURS FOR NAME_REMOTE_STRUCT.AGGREGATE_COMPONENT.  /* CR12432 */
            IF ^NRDEREF THEN DO;                                 /* CR12432 */
 /*DANNY*/  IF INSMOD ^= 0 THEN CALL ERRORS(CLASS_BS,123,'1');                  01809600
            ELSE IF SYT_BASE(PTR) = REMOTE_BASE THEN DO;                         1809700
 /*DANNY*/     IF INDEX = 0 THEN CALL ERRORS(CLASS_BS,123,'2');                 01809800
            END;                                                                 1809900
 /*DANNY*/  ELSE IF (INDEX ^= 0) &                                              01810000
               ^( ((SYT_FLAGS(PTR) & NAME_FLAG) ^= 0) &                         01810010
               (SYT_ARRAY(PTR) ^= 0) )                                          01810020
 /*DANNY*/          THEN CALL ERRORS(CLASS_BS,123,'3');                         01810030
            END;                                                 /* CR12432 */
 /**************** DR103422 FINISH *************/
            IF INDEX = 0 THEN INDEX = 1; /* KEEP AUTO-INCR FROM KILLING Z-CON */ 1810100
            XREG = XREG | 8;                                                    01811000
            INDEX = INDEX | 8;                                                  01811500
         END;                                                                   01812000
         IF ASSEMBLER_CODE THEN DO;                                             01813000
            CALL FORMAT_OPERANDS(FLAG, PTR);                                    01813500
            IF (INDEX&RM) > 0 THEN                                              01814000
               CHARSTRING=CHARSTRING||LEFTBRACKET||(INDEX&RM)||RIGHTBRACKET;    01814500
            MESSAGE = INSTRUCTION(INST, SHR(INDEX,3));                          01815000
            OUTPUT=HEX_LOCCTR||X3||MESSAGE||X3||(XREG&RM)||COMMA||CHARSTRING;   01815500
         END;                                                                   01817500
         IF INSTYPE = 0 THEN                                                    01818000
            IF FLAG = SYM THEN                                                  01818500
            INSTYPE = CHECK_SRS(INST,INDEX,SYT_BASE(PTR),SYT_DISP(PTR)+INSMOD); 01818510
         ELSE IF FLAG=LOCREL | FLAG=SHCOUNT | FLAG=IMD THEN INSTYPE = SRSTYPE;  01819000
         ELSE INSTYPE = RXTYPE;                                                 01819500
/*--------------------------- #DREG -------------------------------*/           22761099
/* RESTORE R1 OR R3 IF THEY WERE CHANGED TO ADDRESS #D.            */           16500005
/* NOTE THAT XREG IS CONDITION TO BRANCH ON FOR A BRANCH INST.     */           16510005
         IF DATA_REMOTE & (D_R1_CHANGE | D_R3_CHANGE) THEN DO;                  22765099
            IF (FLAG=SYM) THEN                                                  22766099
               CALL                                                             16540008
               CHECK_RESTORE_R1R3(INST,SYM,SYT_BASE(PTR),XREG,INSTYPE);         16550015
            ELSE CALL CHECK_RESTORE_R1R3(INST,FLAG,0,XREG,INSTYPE);             16560015
         END;                                                                   22769099
/*-----------------------------------------------------------------*/           22769199
         CALL EMITC(INSTYPE, SHL(INST,8) | SHL(XREG,4) | INDEX);                01820000
         IF SWITCH                                                              01820010
            THEN CALL EMITC(FLAG, -PTR);                                        01820020
         ELSE                                                                   01820030
            CALL EMITC(FLAG, PTR);                                              01820500
         INSMOD, INSTYPE = 0;                                                   01821500
         NRDEREF=0; /* CR12432- NRDEREF ONLY PASSED IN FROM EMITOP/EMITXOP */
      END EMITP;                                                                01822000
                                                                                01822500
 /* ROUTINE TO OUTPUT INSTRUCTION MODIFIER CODE  */                             01823000
EMITDELTA:                                                                      01823500
      PROCEDURE(VALUE);                                                         01824000
         DECLARE VALUE FIXED;                                                   01824500
         IF VALUE=0 THEN RETURN;                                                01825000
         CALL EMITC(DELTA, VALUE);                                              01825500
         IF ASSEMBLER_CODE THEN                                                 01826000
            IF VALUE<0 THEN INFO=VALUE||INFO;                                   01826500
         ELSE INFO=PLUS||VALUE||INFO;                                           01827000
         INSMOD = VALUE + INSMOD;                                               01827500
      END EMITDELTA;                                                            01828000
                                                                                 1828050
 /* ROUTINE TO DECREMENT BASE REGISTER USAGE */                                  1828100
DROP_BASE:                                                                       1828150
      PROCEDURE(OP);                                                             1828200
         DECLARE OP BIT(16);                                                     1828250
         USAGE(BASE(OP)) = USAGE(BASE(OP)) - 2;                                  1828300
      END DROP_BASE;                                                             1828350
                                                                                01850000
 /* ROUTINE TO COPY REGISTER CONTENTS INFORMATION */                             2078520
COPY_REG_INFO:                                                                   2078530
      PROCEDURE(RF, RT, USG);                                                    2078540
         DECLARE (RF, RT, USG) BIT(16);                                          2078550
         R_TYPE(RT) = R_TYPE(RF);                                                2078560
         IF USAGE(RF) THEN DO;  /* CONTENTS KNOWN  */                            2078570
            R_VAR(RT) = R_VAR(RF);                                               2078580
            R_INX(RT) = R_INX(RF);                                               2078590
            R_INX_CON(RT) = R_INX_CON(RF);                                       2078600
            R_INX_SHIFT(RT) = R_INX_SHIFT(RF);                                   2078610
            R_CONTENTS(RT) = R_CONTENTS(RF);                                     2078620
            R_CON(RT) = R_CON(RF);                                               2078630
            R_XCON(RT) = R_XCON(RF);                                             2078640
            R_VAR2(RT) = R_VAR2(RF);                                             2078650
            R_MULT(RT) = R_MULT(RF);                                             2078660
            USAGE(RT) = USG | TRUE;                                              2078670
         END;                                                                    2078680
         ELSE USAGE(RT) = USG;                                                   2078690
      END COPY_REG_INFO;                                                         2078700
                                                                                02078710
 /*DR109095 - ROUTINE TO CHECKPOINT A BASE REGISTER FROM EMITOP*/
 NR_CHECKPOINT:
         PROCEDURE(R,OP);
            DECLARE (R,OP) BIT(16);
            CALL SAVE_BRANCH_AROUND;
            CALL EMITRX(ST,R,INX(NR_BASE(OP)),BASE(NR_BASE(OP)),
                        DISP(NR_BASE(OP)));
            SAVED_LINE(LOC(NR_BASE(OP))) = EMIT_BRANCH_AROUND;
            WORK_USAGE(LOC(NR_BASE(OP))) = 1;
            DEL(NR_BASE(OP)) = 2;
            BASE(OP),BACKUP_REG(OP) = -NR_BASE(OP);
         END NR_CHECKPOINT;

 /* ROUTINE TO EMIT RX INSTRUCTIONS FROM INDIRECT STACKS  */                    01850500
EMITOP:                                                                         01851000
      PROCEDURE(INST, XREG, OP);                                                01851500
         DECLARE (INST, XREG, OP) BIT(16);                                      01852000
 /*---------------------- #DREG --------------------------*/
 /* REPORT REGISTER BORROWING VIA THE LA INSTRUCTION      */
         IF DATA_REMOTE THEN DO;
            IF (INST = LA) THEN CALL REG_STAT(OP,XREG,LOADADDR);
         /* CHANGE FROM R3 TO R1 FOR DATA_REMOTE - L@# NEEDS BASE -CR12432 */
/*DR109095*/IF (NR_DEREF(OP)|NR_DEREF_TMP(OP)) & (BASE(OP)=3) THEN DO;
               CALL COPY_REG_INFO(1,3,USAGE(1));                /*DR109095*/
               CALL EMITRR(LR, 1, 3);                           /* CR12432 */
               BASE(OP) = 1;                                    /* CR12432 */
               CALL CHECK_RESTORE_R1R3(INST,CSYM,3,XREG,LOADADDR);/*DR109095*/
               D_R1_CHANGE = SHL(D_R1_CHANGE,1) | TRUE;         /* CR12432 */
            END;                                                /* CR12432 */
         END;                                                   /* CR12432 */
 /*-------------------------------------------------------*/
      /* OFFSET IN NR_DELTA MUST BE ADDED INTO DISPLACEMENT  /* CR12432 */
      /* WHEN DEREFERENCING NAME REMOTE NODE OF A STRUCTURE. /* CR12432 */
         IF NR_DEREF(OP) & (NR_DELTA(OP)>0) THEN DO;         /* CR12432 */
            INX_CON(OP) = INX_CON(OP)+NR_DELTA(OP);          /* CR12432 */
            NR_DELTA(OP)=0;                                  /* CR12432 */
         END;                                                /* CR12432 */
         CALL EMITDELTA(INX_CON(OP));                                           01852500
         DO CASE PACKFORM(FORM(OP));                                            01853000
            CALL EMITP( INST, XREG, INX(OP), FORM(OP), LOC(OP),
                        0, NR_DEREF(OP) ); /* CR12432 */
            DO;                                                                 01854000
               CALL EMITRX(INST, XREG, INX(OP), BASE(OP), DISP(OP),
                           NR_DEREF(OP) ); /* CR12432 */
               IF BASE(OP) ^= TEMPBASE THEN                                     01855000
                  CALL DROP_BASE(OP);                                            1855500
               IF FORM(OP) = WORK THEN                                          01855510
            /* NO BRANCH AROUND IS ONLY FOR CHECKPOINTED   -CR12432 */
            /* REG,NOT FOR REMOTE NAME REMOTE PUT ON STACK.-CR12432 */
            /* WHEN A REGISTER IS CHECKPOINTED NR_DEREF   /*DR111395*/
            /* IS SET TO 0. NR_DEREF WILL BE SET TO 1 IF  /*DR111395*/
            /* A REMOTE NAME REMOTE IS PUT ON THE STACK   /*DR111395*/
            /* TO BE DEREFERENCED.                        /*DR111395*/
               IF NR_DEREF(OP) = 0 THEN  /*CR12432,DR109095,DR111395*/
                  SAVED_LINE(LOC(OP)) = NO_BRANCH_AROUND(SAVED_LINE(LOC(OP)));  01855520
            END;                                                                01856000
            CALL ERRORS(CLASS_ZO,2);   /*** DR47141 ***/                        01856001
         END;                                                                   01859500
 /*- DANNY ------------------- DR103754 -----------------------------*/         02398500
 /* THE REGISTER REALLY CONTAINS A DOUBLE PRECISION VALUE; IT WAS SET*/         02398500
 /* TO SINGLE FOR A SINGLE PRECISION INSTRUCTION, SO SET IT BACK.    */         02398500
 /* FOR XREG,   WE ONLY WANT TO RETURN TYPE TO DOUBLE IF INSTRUCTION */         02398500
 /* IS CE OR STE, WHICH ARE THE ONLY RX SINGLE INSTRUCTIONS THAT     */         02398500
 /* DON'T CHANGE THE CONTENTS OF THE LEFT REGISTER (XREG).           */         02398500
         IF (DOUBLE_TYPE(XREG) > 0) & (XREG >= FR0) &                           02398500
            ( (INST="79") | (INST="70") ) THEN                                  02398500
            R_TYPE(XREG)=DOUBLE_TYPE(XREG);                                     02398500
 /*- DANNY ----------------------------------------------------------*/         02398500
         IF NR_BASE(OP) > 0 THEN                         /*DR109095*/
            CALL NR_CHECKPOINT(1,OP);                    /*DR109095*/
      END EMITOP;                                                               01860000
                                                                                01860500
 /* ROUTINE TO EMIT RX INSTRUCTIONS FROM STACKS WITHOUT INDEXING */             01861000
EMITXOP:                                                                        01861500
      PROCEDURE(INST, XREG, OP);                                                01862000
         DECLARE (INST, XREG, OP) BIT(16);                                      01862500
/*----------------------- #DREG -------------------------*/
/* REPORT REGISTER BORROWING VIA THE LA INSTRUCTION.     */
          IF DATA_REMOTE THEN
            IF (INST = LA) THEN CALL REG_STAT(OP,XREG,LOADADDR);
/*-------------------------------------------------------*/
         DO CASE PACKFORM(FORM(OP));                                            01863000
            CALL EMITP(INST, XREG, 0, FORM(OP), LOC(OP),
                       0, NR_DEREF(OP) ); /* CR12432 */
            DO;                                                                 01864000
               CALL EMITRX(INST, XREG, 0, BASE(OP), DISP(OP),
                           NR_DEREF(OP) ); /* CR12432 */
               IF BASE(OP) ^= TEMPBASE THEN                                     01865000
                  CALL DROP_BASE(OP);                                            1865500
            END;                                                                01866000
            CALL ERRORS(CLASS_ZO,2);   /*** DR47141 ***/                        01866001
         END;                                                                   01869000
 /*- DANNY ------------------- DR103754 -----------------------------*/         02398500
 /* THE REGISTER REALLY CONTAINS A DOUBLE PRECISION VALUE; IT WAS SET*/         02398500
 /* TO SINGLE FOR A SINGLE PRECISION INSTRUCTION, SO SET IT BACK.    */         02398500
 /* FOR XREG,   WE ONLY WANT TO RETURN TYPE TO DOUBLE IF INSTRUCTION */         02398500
 /* IS CE OR STE, WHICH ARE THE ONLY RX SINGLE INSTRUCTIONS THAT     */         02398500
 /* DON'T CHANGE THE CONTENTS OF THE LEFT REGISTER (XREG).           */         02398500
         IF (DOUBLE_TYPE(XREG) > 0) & (XREG >= FR0) &                           02398500
            ( (INST="79") | (INST="70") ) THEN                                  02398500
            R_TYPE(XREG)=DOUBLE_TYPE(XREG);                                     02398500
 /*- DANNY ----------------------------------------------------------*/         02398500
      END EMITXOP;                                                              01869500
                                                                                01870000
 /* ROUTINE TO EMIT SI INSTRUCTIONS OF UNDETERMINED OPERANDS */                 01870500
EMITSP:                                                                         01871000
      PROCEDURE(INST, FLAG, PTR, VALUE);                                        01871500
         DECLARE (INST, FLAG, PTR, VALUE) BIT(16);                              01872000
         IF ASSEMBLER_CODE THEN DO;                                             01872500
            CALL FORMAT_OPERANDS(FLAG, PTR);                                    01873000
            MESSAGE = INSTRUCTION(INST);                                        01873500
            OUTPUT = HEX_LOCCTR || X3 || MESSAGE || X3 || CHARSTRING || COMMA ||01874000
               VALUE;                                                           01874500
         END;                                                                   01875000
/*--------------------------- #DREG -------------------------------*/           23761099
/* RESTORE R1 OR R3 IF THEY WERE CHANGED TO ADDRESS #D.            */           23762099
         IF DATA_REMOTE & (D_R1_CHANGE | D_R3_CHANGE) THEN DO;                  23764099
            IF (FLAG=SYM) THEN                                                  23765099
               CALL                                                             17630008
               CHECK_RESTORE_R1R3(INST,SYM,SYT_BASE(PTR),0,SSTYPE);             17640015
            ELSE CALL CHECK_RESTORE_R1R3(INST,FLAG,0,0,SSTYPE);                 17650015
         END;                                                                   23768099
/*-----------------------------------------------------------------*/           23769099
         CALL EMITC(SSTYPE, SHL(INST,8));                                       01875500
         CALL EMITC(FLAG, PTR);                                                 01876000
         CALL EMITC(ADCON, VALUE);                                              01876500
         CALL OPSTAT(INST, 0);                                                  01877000
         INSMOD = 0;                                                            01877500
      END EMITSP;                                                               01878000
                                                                                01878500
 /* ROUTINE TO EMIT SI INSTRUCTIONS FROM INDIRECT STACKS */                     01879000
EMITSIOP:                                                                       01879500
      PROCEDURE(INST, OP, VALUE);                                               01880000
         DECLARE (INST, OP, VALUE) BIT(16);                                     01880500
         CALL EMITDELTA(INX_CON(OP));                                           01881000
         DO CASE PACKFORM(FORM(OP));                                            01881500
            CALL EMITSP(INST, FORM(OP), LOC(OP), VALUE);                        01882000
            DO;                                                                 01882500
               CALL EMITSI(INST, BASE(OP), DISP(OP), VALUE);                    01883000
               IF BASE(OP) ^= TEMPBASE THEN                                     01883500
                  CALL DROP_BASE(OP);                                            1884000
               IF FORM(OP) = WORK THEN                                          01884010
                  SAVED_LINE(LOC(OP)) = NO_BRANCH_AROUND(SAVED_LINE(LOC(OP)));  01884020
            END;                                                                01884500
            CALL ERRORS(CLASS_ZO,2);    /*** DR47141 ***/                       01884501
         END;                                                                   01885000
      END EMITSIOP;                                                             01885500
                                                                                01893500
 /* ROUTINE TO GENERATE INSTRUCTION BASED ON MODE AND FORM */                   01894000
MAKE_INST:                                                                      01894500
      PROCEDURE(OPCODE, OPTYPE, OPFORM) BIT(16);                                01895000
         DECLARE (OPCODE, OPTYPE, OPFORM) BIT(16);                              01895500
         RETURN ARITH_OP(OPCODE) + MODE_MOD(OPMODE(OPTYPE)+OPFORM);             01896000
      END MAKE_INST;                                                            01896500
                                                                                01902500
 /* SUBROUTINE TO EMIT RX INSTRUCTIONS BY MODE  */                              01903000
EMIT_BY_MODE:                                                                   01903500
      PROCEDURE(OP, R, OP2, MODE);                                              01904000
         DECLARE (OP, R, OP2, MODE, ITYPE) BIT(16);                             01904500
         IF FORM(OP2) = 0 THEN ITYPE = RI; ELSE ITYPE = RX;                     01905000
            CALL EMITOP(MAKE_INST(OP, MODE, ITYPE), R, OP2);                    01905500
      END EMIT_BY_MODE;                                                         01906500
                                                                                01907000
 /* ROUTINE TO EMIT RELATIVE FORWARD BRANCHES  */                               01907500
EMITLFW:                                                                        01908000
      PROCEDURE(COND, XDISP);                                                   01908500
         DECLARE (COND, XDISP) BIT(16);                                         01909000
         CALL EMITP(BCF, COND, 0, LOCREL, XDISP);                               01909500
      END EMITLFW;                                                              01910500
                                                                                01911000
 /* ROUTINE TO EMIT PROGRAM ADDRESSING, BOTH FORWARD AND BACKWARD */            01911500
EMITPFW:                                                                        01912000
      PROCEDURE(INST, XREG, PTR);                                               01912500
         DECLARE (INST, XREG, PTR) BIT(16);                                     01913000
         DECLARE (DEST, DIFF) FIXED;                                            01913500
         DEST = LOCATION(VAL(PTR));                                             01914000
         DIFF = LOCCTR(INDEXNEST)+1 - DEST;                                     01914500
         IF (INST=BC|INST=BCT) & DEST^=0 & DIFF>=0 & DIFF<=55 THEN              01915000
            CALL EMITP(INST+"40", XREG, 0, FORM(PTR), LOC(PTR), SRSTYPE);       01915500
         ELSE CALL EMITP(INST, XREG, 0, FORM(PTR), LOC(PTR));                   01916000
         CALL RETURN_STACK_ENTRY(PTR);                                          01917500
      END EMITPFW;                                                              01918000
                                                                                01918500
 /* ROUTINE TO EMIT CONDITIONAL BRANCHES  */                                    01919000
EMITBFW:                                                                        01919500
 /?P  /* CR11114 -- BFS/PASS INTERFACE; CHANGE EMITBFW TO DO EMISSION */
      /*            OF BVC INSTRUCTION (FOR BFS) (INITIAL_ENTRY)      */
   PROCEDURE(COND, PTR);                                                        01920000
      DECLARE (COND, PTR) BIT(16);                                              01920500
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; INITIAL ENTRY PROCESSING */
   PROCEDURE(COND, PTR, INITIAL_ENTRY_FLAG);
      DECLARE (COND, PTR) BIT(16), INITIAL_ENTRY_FLAG BIT(1);
 ?/
      IF COND = 0 THEN DO;                                                      01921000
         CALL RETURN_STACK_ENTRY(PTR);                                          01921500
         RETURN;                                                                01922000
      END;                                                                      01922500
 /?B  /* CR11114 -- BFS/PASS INTERFACE; INITIAL ENTRY PROCESSING */
      IF INITIAL_ENTRY_FLAG THEN DO;
         IF ^FIRST_TIME THEN
            GO TO UNIMPLEMENTED;
         CALL EMITPFW(BVC, COND, PTR);
      END;
      ELSE DO;
 ?/
         CALL EMITPFW(BC, COND, PTR);                                           01923000
         STOPPERFLAG = COND = ALWAYS;                                           01923500
 /?B  /* CR11114 -- BFS/PASS INTERFACE; INITIAL ENTRY PROCESSING */
      END;
      INITIAL_ENTRY_FLAG = 0;
 ?/
      END EMITBFW;                                                              01924000
 /?B  /* CR11114 -- BFS/PASS INTERFACE; ALTERNATE ENTRY PROCESSING */

         /*--- ROUTINE TO PUSH A LOCATION COUNTER WITHIN CURRENT CSECT ---*/
PUSH_LOCCTR:
   PROCEDURE(NEW_LOC);
      DECLARE NEW_LOC FIXED;
      CALL EMITC(LPUSH, 0);
      CALL EMITW(NEW_LOC, 1);
      PUSHED_LOCCTR(INDEXNEST) = LOCCTR(INDEXNEST);
      LOCCTR(INDEXNEST) = NEW_LOC;
   END PUSH_LOCCTR;

         /*--- ROUTINE TO POP THE LOCATION COUNTER FROM A PUSH_LOCCTR ---*/
POP_LOCCTR:
   PROCEDURE;
      CALL EMITC(LPOP, 0);
      LOCCTR(INDEXNEST) = PUSHED_LOCCTR(INDEXNEST);
   END POP_LOCCTR;
 ?/
                                                                                01924500
 /* ROUTINE TO RESUME A GIVEN LOCATION COUNTER AT IT'S LAST VALUE  */           01925000
RESUME_LOCCTR:                                                                  01925500
      PROCEDURE(NEST);                                                          01926000
         DECLARE NEST BIT(16);                                                  01926500
         IF INDEXNEST = NEST THEN RETURN;                                       01927000
         INDEXNEST = NEST;                                                      01927500
         IF NEST = 0 THEN RETURN;                                               01928000
         CALL EMITC(CSECT, NEST);                                               01928500
         CALL EMITW(0, 1);                                                      01929000
         STOPPERFLAG = FALSE;                                                   01929500
         CCREG = 0;                                                             01930000
      END RESUME_LOCCTR;                                                        01930500
                                                                                01931000
 /* ROUTINE TO EMIT STATEMENT MARKER CODE  */                                   01931500
MARKER:                                                                         01932000
      PROCEDURE;                                                                01932500
         IF ^TRACING | MARKER_ISSUED THEN RETURN;                               01933000
         IF CALL#(PROGPOINT) = 2 THEN RETURN;  /* COMPOOL  */                   01933500
         MARKER_ISSUED = TRUE;                                                  01935000
      END MARKER;                                                               01935500
                                                                                01936000
 /* ROUTINE TO EMIT REFERENCES TO PCE ELEMENTS */                               01936500
EMITPCEADDR:                                                                    01937000
      PROCEDURE(OP);                                                            01937500
         DECLARE (OP, SY, IX) BIT(16);                                          01938000
         SY = LOC2(OP);                                                         01938500
         IF SYT_SCOPE(SY) < PROGPOINT THEN                                      01939000
 /?P     /* CR11114 -- BFS/PASS INTERFACE; PDE EMISSION */
            IX = SYT_SCOPE(SY);                                                 01939500
         ELSE IX = PCEBASE;                                                     01940000
         CALL EMITADDR(IX, SYT_PARM(SY) * 6, HADDR);                            01940500
 ?/
 /?B     /* CR11114 -- BFS/PASS INTERFACE; PDE EMISSION */
         CALL EMITADDR(SYT_SCOPE(SY), SYT_PARM(SY) * 6, HADDR);
 ?/
         CALL RETURN_STACK_ENTRY(OP);                                           01941000
      END EMITPCEADDR;                                                          01941500
                                                                                01942000
 /* ROUTINE TO EMIT HALFWORD ADDRESSES FOR EVENT OPERANDS  */                   01942500
EMITEVENTADDR:                                                                  01943000
      PROCEDURE(OP);                                                            01943500
         DECLARE (OP, SY) BIT(16);                                              01944000
         SY = LOC2(OP);                                                         01944500
         IF SYT_TYPE(SY) >= TASK_LABEL THEN                                     01945000
            CALL EMITPCEADDR(OP);                                               01945500
         ELSE DO;                                                               01946000
            CALL EMITADDR(DATABASE(SYT_SCOPE(SY)),                              01946500
               SYT_ADDR(SY)+SYT_CONST(SY)+INX_CON(OP), HADDR);                  01946510
            CALL RETURN_COLUMN_STACK(OP);               /*DR109059*/
            CALL RETURN_STACK_ENTRY(OP);                                        01948500
         END;                                                                   01949000
      END EMITEVENTADDR;                                                        01949500
                                                                                 1949520
 /* ROUTINE TO EMIT Z-TYPE ADDRESS CONSTANTS  */                                 1949540
EMIT_Z_CON:                                                                      1949560
      PROCEDURE(ID1, FLAG1, ID2, FLAG2, REL, ADR, FLAG);                         1949580
         DECLARE (ID1, FLAG1, ID2, FLAG2, REL, FLAG) BIT(16), ADR FIXED;         1949600
         IF ID1 > 0 THEN                                                         1949620
            CALL EMITC(RLD, ID1 + SHL(FLAG1, 12));                               1949640
         IF ID2 > 0 THEN DO;                                                     1949660
            IF ADR < 0 THEN DO;                                                  1949680
               ADR = -ADR;                                                       1949700
               FLAG2 = FLAG2 | 8;                                                1949720
            END;                                                                 1949740
            CALL EMITC(RLD, ID2 + SHL(FLAG2, 12));                               1949760
         END;                                                                    1949780
         CALL EMITC(ZADDR, REL);                                                 1949800
         CALL EMITW(SHL(ADR,16) | SHL(FLAG,8));                                  1949820
      END EMIT_Z_CON;                                                            1949840
                                                                                01950000
 /* ROUTINE TO SET THE LOCATION OF A SPECIFIED STATEMENT NUMBER */              01950500
SET_LABEL:                                                                      01951000
      PROCEDURE(STMTNO, FLAG1, FLAG2);                                          01951500
         DECLARE STMTNO BIT(16), (FLAG1, FLAG2) BIT(1);                         01952000
         IF ^FLAG1 THEN                                                         01952500
            CALL CLEAR_REGS;                                                    01953000
         STOPPERFLAG = FALSE;                                                   01953500
         CCREG = 0;                                                             01954000
         NEXT_ELEMENT(LAB_LOC); /*CR13670*/
         LOCATION(STMTNO) = LOCCTR(INDEXNEST);                                  01956000
         LOCATION_LINK(STMTNO) = LASTLABEL(INDEXNEST);                          01956500
         LASTLABEL(INDEXNEST) = STMTNO;                                         01957000
         /*CR12713 - SAVE THE STATEMENT NUMBER (LINE#) IN LOCATION_ST# WITH  */
         /*THE LABEL NUMBER (STMTNO) AS THE INDEX.                           */
         IF LOCATION_ST#(STMTNO) = 0 THEN                           /*CR12713*/
            LOCATION_ST#(STMTNO) = LINE#;                           /*CR12713*/
         IF ^FLAG2 THEN DO;                                                     01957500
            IF ASSEMBLER_CODE THEN                                              01958000
               OUTPUT = HEX_LOCCTR||'P#'||STMTNO||' EQU *';                     01958500
            CALL EMITC(PLBL, STMTNO);                                           01959000
         END;                                                                   01959500
         FLAG1, FLAG2 = FALSE;                                                  01960000
      END SET_LABEL;                                                            01960500
                                                                                01961000
 /*  ROUTINE TO PRINT OUT CURRENT REGISTER STATUS  */                           01961500
REGISTER_STATUS:                                                                01962000
      PROCEDURE;                                                                01962500
         DECLARE I BIT(16), HEADER_ISSUED BIT(1);                               01963000
         HEADER_ISSUED = TRUE;                                                  01963500
         IF REGISTER_TRACE THEN                                                 01964000
            DO I = 0 TO REG_NUM;                                                01964500
            IF USAGE(I)^=0 THEN DO;                                             01965000
               IF HEADER_ISSUED THEN DO;                                        01965500
                  OUTPUT =                                                      01966000
             ' R USE LIN CTN TYP VAR XR XS     XC  CONST   XCON MULT VR2  NAME';01966500
                  HEADER_ISSUED = FALSE;                                        01967000
               END;                                                             01967500
               MESSAGE='';                                                      01968000
               IF R_CONTENTS(I)=SYM THEN                                        01968500
                  MESSAGE=X3||SYT_NAME(R_VAR(I));                               01969000
               ELSE IF R_CONTENTS(I)=SYM2 THEN                                  01969500
                  IF R_VAR2(I) ^< 0 THEN                                        01970000
                  MESSAGE=X3||SYT_NAME(R_VAR(I))||COMMA||SYT_NAME(R_VAR2(I));   01970500
               ELSE MESSAGE=X3||SYT_NAME(R_VAR(I))||COMMA||'<CONST>';           01971000
               MESSAGE=FORMAT(R_VAR2(I),4)||MESSAGE;                            01971500
               MESSAGE=FORMAT(R_MULT(I),5)||MESSAGE;                            01972000
               MESSAGE=FORMAT(R_XCON(I),7)||MESSAGE;                            01972500
               MESSAGE=FORMAT(R_CON(I),7)||MESSAGE;                             01973000
               MESSAGE=FORMAT(R_INX_CON(I),7)||MESSAGE;                         01973500
               MESSAGE=FORMAT(R_INX_SHIFT(I),3)||MESSAGE;                       01974000
               MESSAGE=FORMAT(R_INX(I),3)||MESSAGE;                             01974500
               MESSAGE=FORMAT(R_VAR(I),4)||MESSAGE;                             01975000
               MESSAGE=FORMAT(R_TYPE(I),4)||MESSAGE;                            01975500
               MESSAGE=FORMAT(R_CONTENTS(I),4)||MESSAGE;                        01976000
               MESSAGE=FORMAT(USAGE_LINE(I),5)||MESSAGE;                        01976500
               MESSAGE=FORMAT(USAGE(I),3)||MESSAGE;                             01977000
               OUTPUT=FORMAT(I,2)||MESSAGE;                                     01977500
            END;                                                                01978000
         END;                                                                   01978500
         CALL STACK_STATUS;                                                     01978600
      END REGISTER_STATUS;                                                      01979000
                                                                                01979500
 /****************************************************************/
 /* ROUTINE TO CLEAR OUTDATED VARIABLE USAGES FOR NEW ONES       */             01980000
 /****************************************************************/
 /*                                                               /*CR13616*/
 /* BY_NAME = TRUE (1)                                            /*CR13616*/
 /* ::= AN ARGUMENT IN A NAME PSEDUO-FUNCTION, OR                 /*CR13616*/
 /* ::= THE DESTINATION VARIABLE IN A NAME ASSIGNMENT, AUTOMATIC  /*CR13616*/
 /*     NAME INITIALIZATION, OR %NAMEADD/%NAMECOPY MACRO.         /*CR13616*/
 /*                                                               /*CR13616*/
 /****************************************************************/
NEW_USAGE:                                                                      01980500
      PROCEDURE (OP, FLAG, BY_NAME);                                            01981000
         DECLARE (OP, FLAG, I) BIT(16), BY_NAME BIT(1);                         01981500
         DO I = 0 TO REG_NUM;                                                   01982000
            IF USAGE(I) THEN DO CASE BY_NAME;                                   01982500
               DO;                                                              01983000
                  IF SYMFORM(FORM(OP)) THEN DO;                                 01983500
                     IF R_CONTENTS(I) = SYM | R_CONTENTS(I) = SYM2 THEN         01984000
                        IF R_VAR(I) = LOC(OP) THEN                              01984500
                        IF FLAG | R_INX(I)>0 | R_INX_CON(I)=INX_CON(OP)         01985000
                        /* DAS DR101663 ------------------------------ */       01984000
                        /* DID SUBBIT MODIFY 2ND WORD OF DOUBLE SCALAR?*/       01984000
                           | (OPMODE(SYT_TYPE(LOC2(OP)))=4 &                    01984000
                              INX_CON(OP)=R_INX_CON(I)+2)                       01984000
                        /* END DR101663 ------------------------------ */       01984000
                        THEN                                                    01984000
                        CALL UNRECOGNIZABLE(I);                                 01985500
                     IF R_CONTENTS(I) = SYM2 THEN                               01986000
                        IF R_VAR2(I) = LOC(OP) THEN                             01986500
                        IF FLAG | R_XCON(I) = INX_CON(OP) THEN                  01987000
                        CALL UNRECOGNIZABLE(I);                                 01987500
                  END;                                                          01988000

                  /* CODE WAS DELETED FOR DR111307 */

               END;                                                             01991000
               IF SYMFORM(FORM(OP)) THEN                                        01991500
                  IF R_CONTENTS(I) = APOINTER THEN                               1992000
                  IF R_VAR(I) = LOC(OP) THEN                                    01992500
                  CALL UNRECOGNIZABLE(I);                                       01993000
            END;  /* CASE BY_NAME */                                            01993500
         END;                                                                   01994000
         BY_NAME = FALSE;                                                       01994500
      END NEW_USAGE;                                                            01995000
                                                                                01995500
 /* ROUTINE TO VERIFY IF REGISTER CONTAINS DESIRED INFORMATION  */              01996000
SEARCH_REGS:                                                                    01996500
      PROCEDURE(OP);                                                            01997000
         DECLARE (OP, RC, I, J) BIT(16);                                        01997500
         RC = RCLASS(TYPE(OP));                                                 01998000
         DO J = RCLASS_START(RC) TO RCLASS_START(RC+1)-1;                       01998500
            I = REGISTERS(J);                                                   01999000
            IF USAGE(I) THEN DO;                                                01999500
               IF FORM(OP) = SYM THEN DO;                                       02000000
                  IF R_CONTENTS(I) = SYM THEN                                   02000500
                     IF R_VAR(I) = LOC(OP) THEN                                 02001000
                     IF R_INX(I) = INX(OP) THEN                                 02001500
                     IF R_INX_CON(I) = INX_CON(OP) THEN                         02002000
                     IF R_CON(I) = CONST(OP) | R_CON(I) = 0 THEN                02002500
                     IF R_INX_SHIFT(I) = INX_SHIFT(OP) THEN                     02003000
                     IF I >= FR0 THEN DO;                                       02003500
                     IF CHECK_REMOTE(OP) &                                      02003510
                        SYT_TYPE(LOC(OP)) = STRUCTURE &                         02003520
                        SYT_ARRAY(LOC(OP)) ^= 0 THEN                            02003530
 /*-------------------- DANNY DR54577 -----------------------------*/           02003540
 /* THE REGISTER TABLE DOES NOT CONTAIN ENOUGH INFORMATION WHEN    */           02003550
 /* THE SYMBOL IS A STRUCTURE. THE LOC FIELD CONTAINS THE SYMBOL   */           02003560
 /* TABLE ENTRY FOR THE STRUCTURE, AND LOC2 IS THE PARTICULAR NODE */           02003570
 /* OF THE STRUCTURE. SINCE THE REGISTER TABLE DOESN'T HAVE AN     */           02003580
 /* ENTRY FOR LOC2,  WE CAN'T BE SURE WHEN A REGISTER HAS THE      */           02003590
 /* DESIRED STRUCTURE NODE. THE ONLY KNOWN OCCURRENCE OF AN ERROR  */           02003600
 /* RESULTING FROM THIS PROBLEM IS WHEN THE STRUCTURE IS REMOTE    */           02003610
 /* AND MULTI-COPY. ALWAYS RETURN -1 TO FORCE A REGISTER LOAD WHEN */           02003620
 /* DEALING WITH A REMOTE MULTI-COPY STRUCTURE.                    */           02003630
                        RETURN -1; /* FLOATING PT. REGISTERS */                 02003640
 /*----------------------------------------------------------------*/           02003650
                     RETURN I;                                                  02003660
                  END;                                                          02003670
                  ELSE IF OPMODE(R_TYPE(I))=OPMODE(TYPE(OP)) THEN               02003680
                     DO;                                                        02004000
                     IF CHECK_REMOTE(OP) &                                      02004005
                        SYT_TYPE(LOC(OP)) = STRUCTURE &                         02004010
                        SYT_ARRAY(LOC(OP))^=0 THEN                              02004015
 /*-------------------- DANNY DR54577 -----------------------------*/           02004020
                        RETURN -1;  /* GENERAL REGISTERS */                     02004022
 /*----------------------------------------------------------------*/           02004024
                     RETURN I;                                                  02004030
                  END;                                                          02004035
               END;                                                             02004500
               ELSE IF FORM(OP) = LIT THEN DO;                                  02005000
                  IF R_CONTENTS(I) = LIT THEN                                   02005500
                     IF R_CON(I) = VAL(OP) THEN DO;                             02006000
                     IF TYPE(OP) = SCALAR THEN                                  02006500
                        RETURN I;                                               02007000
                     IF R_TYPE(I) = TYPE(OP) THEN DO;                           02007500
                        IF I < FR0 THEN RETURN I;                               02008000
                        IF R_XCON(I) = XVAL(OP) THEN                             2008500
                           RETURN I;                                            02009000
                     END;                                                       02009500
                  END;                                                          02010000
               END;                                                             02010500
               ELSE IF FORM(OP) = AIDX THEN DO;                                 02011000
                  IF R_CONTENTS(I) = AIDX THEN                                  02011500
                     IF R_VAR(I) = LOC(OP) THEN                                 02012000
                     IF R_INX_SHIFT(I) = INX_SHIFT(OP) THEN                     02012500
                     IF R_CON(I) = 0 THEN                                       02013000
                     RETURN I;                                                  02013500
               END;                                                             02014000
               ELSE IF FORM(OP) = WORK THEN DO;                                  2014050
                  IF R_CONTENTS(I) = VAC THEN                                    2014100
                     IF R_VAR(I) = LOC2(OP) THEN                                 2014150
                     IF R_INX_SHIFT(I) = INX_SHIFT(OP) THEN                      2014200
                     IF R_CON(I) = 0 THEN                                        2014250
                     RETURN I;                                                   2014300
               END;                                                              2014350
            END;                                                                02014500
         END;                                                                   02015000
         RETURN -1;                                                             02015500
      END SEARCH_REGS;                                                          02016000
                                                                                02016500
 /* ROUTINE TO SEARCH FOR TWO-DIMENSIONAL SUBSCRIPT FORMS */                    02017000
SEARCH_INDEX2:                                                                  02017500
      PROCEDURE(OP);                                                            02018000
         DECLARE (OP, I, J) BIT(16);                                            02018500
         DO J = RCLASS_START(INDEX_REG) TO RCLASS_START(INDEX_REG+1)-1;         02019000
            I = REGISTERS(J);                                                   02019500
            IF USAGE(I) THEN DO;                                                02020000
               IF FORM(OP) = AIDX2 THEN DO;                                     02020500
                  IF R_CONTENTS(I) = AIDX2 THEN                                 02021000
                     IF R_VAR(I) = LOC(OP) THEN                                 02021500
                     IF R_VAR2(I) = LOC2(OP) THEN                               02022000
                     IF R_INX_SHIFT(I) = INX_SHIFT(OP) THEN                     02022500
                     IF R_MULT(I) = XVAL(OP) THEN                               02023000
                     IF R_CON(I) = 0 THEN RETURN I;                             02023500
               END;  /* AIDX */                                                 02024000
               ELSE IF FORM(OP) = SYM THEN DO;                                  02024500
                  IF R_CONTENTS(I) = SYM2 THEN                                  02025000
                     IF R_VAR(I) = LOC(OP) THEN                                 02025500
                     IF R_INX_CON(I) = INX_CON(OP) THEN                         02026000
                     IF R_VAR2(I) = INX(OP) THEN                                02026500
                     IF R_XCON(I) = CONST(OP) THEN                              02027000
                     IF R_MULT(I) = XVAL(OP) THEN                               02027500
                     IF R_INX_SHIFT(I) = INX_SHIFT(OP) THEN                     02028000
                     IF R_CON(I) = 0 THEN RETURN I;                             02028500
               END;  /* SYM2 */                                                 02029000
            END;  /* USAGE */                                                   02029500
         END;  /* DO J */                                                       02030000
         RETURN -1;                                                             02030500
      END SEARCH_INDEX2;                                                        02031000
                                                                                02031500
 /* ROUTINE TO DETERMINE WHETHER STACK ENTRY IS KNOWN SYMBOL ENTRY */           02032000
KNOWN_SYM:                                                                      02032500
      PROCEDURE(OP) BIT(1);                                                     02033000
         DECLARE OP BIT(16);                                                    02033500
         IF FORM(OP) = SYM THEN RETURN TRUE;                                    02034000
         IF FORM(OP) = IMD THEN RETURN TRUE;                                    02034500
         IF FORM(OP) = INL THEN RETURN TRUE;                                    02035000
         IF FORM(OP) = CSYM THEN                                                02035500
            IF BASE(OP) >= 0 THEN                                               02036000
            IF USAGE(BASE(OP)) THEN                                             02036500
            IF R_CONTENTS(BASE(OP)) = XPT THEN                                  02037500
            RETURN R_VAR(BASE(OP)) = SYT_BASE(LOC(OP));                         02038000
         RETURN FALSE;                                                          02038500
      END KNOWN_SYM;                                                            02039000
                                                                                02039500
 /* ROUTINE TO VERIFY THAT INDEX CONTENTS IS KNOWN, IF ANY  */                  02040000
SAFE_INX:                                                                       02040500
      PROCEDURE(OP) BIT(1);                                                     02041000
         DECLARE OP BIT(16);                                                    02041500
         IF ^KNOWN_SYM(OP) THEN RETURN FALSE;                                   02042000
         IF INX(OP) = 0 THEN RETURN TRUE;                                       02042500
         IF INX(OP) < 0 THEN RETURN FALSE;                                      02043000
         RETURN USAGE(INX(OP)) & 1;                                             02043500
      END SAFE_INX;                                                             02044000
                                                                                 2044010
 /* ROUTINE TO ESTABLISH RECOGNITION OF REGISTER CONTENTS */                     2044020
SET_USAGE:                                                                       2044030
      PROCEDURE(R, RFORM, RVAR, RXCON, RINX);                                    2044040
         DECLARE (R, RFORM) BIT(16), (RVAR, RXCON, RINX) FIXED;                  2044050
         USAGE(R) = USAGE(R) | TRUE;                                             2044060
         R_CONTENTS(R) = RFORM;                                                  2044070
         IF RFORM = LIT THEN DO;                                                 2044080
            R_CON(R) = RVAR;                                                     2044090
            R_XCON(R) = RXCON;                                                   2044100
         END;                                                                    2044110
         ELSE DO;                                                                2044120
            R_VAR(R) = RVAR;                                                     2044130
            R_INX_CON(R) = RXCON;                                                2044140
            R_INX(R) = RINX;                                                     2044150
            R_CON(R) = 0;                                                        2044160
         END;                                                                    2044170
         RXCON, RINX = 0;                                                        2044180
 /*********************** TEV DR108605 12/17/91 **********************/
 /* THE BELOW FIX FOR DR103754 WAS MODIFIED IN ORDER TO BE A PART OF */
 /* THE IF-THEN-ELSE CONSTRUCT.                                      */
         IF (R >= FR0) THEN DO;
            IF (RFORM=VAC) THEN DO;
               IF (OPMODE(R_TYPE(R))=4) THEN
                  DOUBLE_TYPE(R) = R_TYPE(R);
            END;
 /*********************** END DR108605 *******************************/
 /*- DANNY -------------- FIX FOR DR103754 ----------------------*/             21470005
 /* SYMBOL IN FLOATING REGISTER IS DOUBLE PRECISION. SAVE TYPE SO*/             21480005
 /* THAT WHEN SINGLE PRECISION INSTRUCTIONS CHANGE IT TO SINGLE, */             21490005
 /* WE CAN CHANGE IT BACK TO DOUBLE.                             */             21500005
            ELSE
               IF (RFORM=SYM) THEN DO;
                  IF (OPMODE(SYT_TYPE(RVAR))=4) THEN                            21520000
                     DOUBLE_TYPE(R) = SYT_TYPE(RVAR);                           21530000
               END;
         END;
 /*--------------------------------------------------------------*/             21540005
      END SET_USAGE;                                                             2044190
                                                                                02044500
 /* ROUTINE FOR GETTING OPERAND QUALIFIER BITS  */                              02045000
TAG_BITS:                                                                       02045500
      PROCEDURE(OP) BIT(8);                                                     02046000
         DECLARE OP BIT(16);                                                    02046500
         RETURN SHR(OPR(CTR+OP),4)&"F";                                         02047000
      END TAG_BITS;                                                             02047500
                                                                                02048000
 /* ROUTINE TO GET OPERAND TYPE BITS (FOR IO PARAMETERS) */                     02048500
TYPE_BITS:                                                                      02049000
      PROCEDURE(OP) BIT(8);                                                     02049500
         DECLARE OP BIT(16);                                                    02050000
         RETURN SHR(OPR(CTR+OP),8) & "FF";                                      02050500
      END TYPE_BITS;                                                            02051000
                                                                                 2051020
 /* SUBROUTINE FOR GETTING CODE OPTIMIZER BITS  */                               2051040
X_BITS:                                                                          2051060
      PROCEDURE(OP) BIT(8);                                                      2051080
         DECLARE OP BIT (16);                                                    2051100
         RETURN SHR(OPR(CTR+OP),1)&"7";                                          2051120
      END X_BITS;                                                                2051140
                                                                                02051500
 /* ROUTINE TO INCREMENT USAGE COUNTS FOR INDEX AND BASE REGISTERS */           02052000
INCR_USAGE:                                                                     02052500
      PROCEDURE(R);                                                             02053000
         DECLARE R BIT(16);                                                     02053500
         IF R > 0 THEN                                                          02054000
            USAGE(R) = USAGE(R) + 2;                                            02054500
         ELSE IF R < 0 THEN DO;                                                 02055000
            R = -R;                                                             02055500
            DEL(R) = DEL(R) + 2;                                                02056000
         END;                                                                   02056500
      END INCR_USAGE;                                                           02057000
                                                                                 2057050
 /* ROUTINE TO INCREMENT REGISTER USAGE */                                       2057100
INCR_REG:                                                                        2057150
      PROCEDURE(OP);                                                             2057200
         DECLARE OP BIT(16);                                                     2057250
         USAGE(REG(OP)) = USAGE(REG(OP)) + 2;                                    2057300
         USAGE_LINE(REG(OP)) = 1;                                                2057350
      END INCR_REG;                                                              2057400
                                                                                02057500
 /* ROUTINE TO MAKE AN EXACT COPY OF AN EXISTING STACK ENTRY */                 02058000
COPY_STACK_ENTRY:                                                               02058500
      PROCEDURE(PTR, FLAG) BIT(16);                                             02059000
         DECLARE (PTR, PTR2) BIT(16), FLAG BIT(8);                              02059500
         PTR2 = NEXT_STACK;                                                     02060000
         STRUCT_WALK(PTR2)=STRUCT_WALK(PTR);   /*DR109016*/
         AIA_ADJUSTED(PTR2)=AIA_ADJUSTED(PTR);         /* DR109019 */
         TYPE(PTR2) = TYPE(PTR); FORM(PTR2) = FORM(PTR);                        02060500
            LOC(PTR2) = LOC(PTR);   LOC2(PTR2) = LOC2(PTR);                     02061000
            BASE(PTR2) = BASE(PTR); DISP(PTR2) = DISP(PTR);                     02061500
            REG(PTR2) = REG(PTR);   INX(PTR2) = INX(PTR);                       02062000
            ROW(PTR2) = ROW(PTR);   COLUMN(PTR2) = COLUMN(PTR);                 02062500
            DEL(PTR2) = DEL(PTR);                                               02063000
         COPY(PTR2) = COPY(PTR);                                                02063500
         BACKUP_REG(PTR2) = BACKUP_REG(PTR);                                    02064000
         NEXT_USE(PTR2) = NEXT_USE(PTR);                                         2064100
         INX_NEXT_USE(PTR2) = INX_NEXT_USE(PTR);                                 2064200
 /**************** DR54572 START ************/
         IND_STACK(PTR2).I_CSE_USE = IND_STACK(PTR).I_CSE_USE;                  02064300
         IND_STACK(PTR2).I_DSUBBED = IND_STACK(PTR).I_DSUBBED;                  02064400
 /**************** DR54572 FINISH ***********/
         VAL(PTR2) = VAL(PTR);                                                  02064500
         CONST(PTR2) = CONST(PTR);                                              02065000
         INX_CON(PTR2) = INX_CON(PTR); INX_SHIFT(PTR2) = INX_SHIFT(PTR);        02065500
            STRUCT(PTR2) = STRUCT(PTR);                                         02066000
         VMCOPY(PTR2) = VMCOPY(PTR);                                             2066100
         STRUCT_INX(PTR2) = STRUCT_INX(PTR); STRUCT_CON(PTR2) = STRUCT_CON(PTR);02066500
            XVAL(PTR2) = XVAL(PTR);                                             02067000
         INX_MUL(PTR2) = INX_MUL(PTR);                                          02067500
         NR_DEREF(PTR2) = NR_DEREF(PTR); /* CR12432 */
         NR_DELTA(PTR2) = NR_DELTA(PTR); /* CR12432 */
         NR_STACK(PTR2) = NR_STACK(PTR); /* CR12432 */
         LIVES_REMOTE(PTR2) = LIVES_REMOTE(PTR); /* CR12432 */
         POINTS_REMOTE(PTR2) = POINTS_REMOTE(PTR); /*DR111388*/
         NAME_VAR(PTR2) = NAME_VAR(PTR);           /*DR111388*/
         NR_BASE(PTR2) = NR_BASE(PTR);           /*DR109095*/
         NR_DEREF_TMP(PTR2) = NR_DEREF_TMP(PTR); /*DR109095*/
         COPT(PTR2) = FLAG;                                                     02068000
         DO CASE PACKFORM(FORM(PTR2));                                          02068500
            DO;                                                                 02069000
               CALL INCR_USAGE(INX(PTR2));                                      02069500
            END;                                                                02070000
            DO;                                                                 02070500
               IF FORM(PTR2) = WORK THEN                                        02071000
                  WORK_USAGE(LOC(PTR2)) = WORK_USAGE(LOC(PTR2)) + 1;            02071500
               ELSE DO;                                                         02072000
                  CALL INCR_USAGE(INX(PTR2));                                   02072500
                  IF BASE(PTR2) ^= TEMPBASE THEN                                02073000
                     CALL INCR_USAGE(BASE(PTR2));                               02073500
               END;                                                             02074000
            END;                                                                02074500
            DO;                                                                 02075000
               IF FORM(PTR2) = VAC THEN                                         02075500
                  CALL INCR_REG(PTR2);                                           2076000
            END;                                                                02076500
         END;  /* CASE PACKFORM */                                              02077000
         FLAG = 0;                                                              02077500
         RETURN PTR2;                                                           02078000
      END COPY_STACK_ENTRY;                                                     02078500
                                                                                 2078510
 /* ROUTINE TO EXCHANGE REGISTER TABLE CONTENTS */                              02078720
SWAP_REG_INFO:                                                                  02078730
      PROCEDURE(RF, RT, USG);                                                   02078740
         DECLARE (RF, RT, USG) BIT(16);                                         02078750
         CALL COPY_REG_INFO(RT, TEMPBASE, 0);  /* ASSUMES THAT TEMPBASE */      02078760
         CALL COPY_REG_INFO(RF, RT, USG);      /* IS NOT USED TO CONTAIN */     02078770
         CALL COPY_REG_INFO(TEMPBASE, RF, 0);  /* VARIABLE INFORMATION */       02078780
         USAGE(TEMPBASE) = 0;                  /* EVER...  */                   02078790
      END SWAP_REG_INFO;                                                        02078800
                                                                                02078810
 /* ROUTINE TO DETERMINE IF REGISTER CONTENTS ARE IDENTICAL */                  02078820
SAME_REG_INFO:                                                                  02078830
      PROCEDURE(RF, RT) BIT(1);                                                 02078840
         DECLARE (RF, RT) BIT(16);                                              02078850
         IF USAGE(RF) & USAGE(RT) THEN                                          02078860
            IF R_CONTENTS(RF) = R_CONTENTS(RT) THEN                             02078870
            IF R_VAR(RF) = R_VAR(RT) THEN                                       02078880
            IF R_INX(RF) = R_INX(RT) THEN                                       02078890
            IF R_INX_CON(RF) = R_INX_CON(RT) THEN                               02078900
            IF R_INX_SHIFT(RF) = R_INX_SHIFT(RT) THEN                           02078910
            IF R_CON(RF) = R_CON(RT) THEN                                       02078920
            IF R_TYPE(RF) = R_TYPE(RT) THEN                                     02078930
            IF R_VAR2(RF) = R_VAR2(RT) THEN                                     02078940
            IF R_MULT(RF) = R_MULT(RT) THEN                                     02078950
            IF R_XCON(RF) = R_XCON(RT) THEN                                     02078960
            RETURN TRUE;                                                        02078970
         RETURN FALSE;                                                          02078980
      END SAME_REG_INFO;                                                        02078990
                                                                                02079000
 /* ROUTINE TO DETERMINE IF SYMBOLIC OPERANDS ARE IDENTICAL (EXCEPT FOR CONST)  02079500
   */                                                                           02080000
DUPLICATE_OPERANDS:                                                             02080500
      PROCEDURE(OP1, OP2) BIT(1);                                               02081000
         DECLARE (OP1, OP2) BIT(16);                                            02081500
         IF COPT(OP2) = 0 THEN                                                  02082000
            IF KNOWN_SYM(OP1) THEN IF KNOWN_SYM(OP2) THEN                       02082500
            IF LOC(OP1) = LOC(OP2) THEN IF INX_CON(OP1) = INX_CON(OP2) THEN     02083000
            IF INX(OP1) = INX(OP2) THEN                                         02083500
            IF DATATYPE(TYPE(OP1)) = BITS THEN DO;                              02084000
            IF SIZE(OP1) = SIZE(OP2) THEN                                       02084500
               IF COLUMN(OP1) = COLUMN(OP2) THEN RETURN TRUE;                   02085000
            ELSE IF COLUMN(OP1)>0 THEN IF COLUMN(OP2)>0 THEN                    02085500
               IF FORM(COLUMN(OP1))=LIT THEN                                    02086000
               IF FORM(COLUMN(OP2))=LIT THEN                                    02086500
               RETURN VAL(COLUMN(OP1))=VAL(COLUMN(OP2));                        02087000
         END;                                                                   02087500
         ELSE RETURN TRUE;                                                      02088000
         RETURN FALSE;                                                          02088500
      END DUPLICATE_OPERANDS;                                                   02089000
                                                                                02089500
 /* ROUTINE TO CONVERT SCALAR LIT TO INTEGER AND CHECK RANGE */                 02090000
INTEGERIZABLE:                                                                  02090500
      PROCEDURE;                                                                02091000
         DECLARE LIT_NEGMAX LABEL, FLT_NEGMAX FIXED INITIAL("C8800000");        02091500
         DECLARE (TEMP, TEMP1) FIXED;                                           02092000
         CALL INLINE("58",1,0,FOR_DW);                /* L  1,DW    */          02092500
         CALL INLINE("68", 0, 0, 1, 0);                   /* LD 0,0(0,1) */     02093000
         IF DW(0)= "FF000000" THEN                                              02093500
            DO;                                                                 02094000
NO_INTEGER:                                                                     02094500
            RETURN FALSE;                                                       02095000
         END;                                                                   02095500
         TEMP = ADDR(NO_INTEGER);                                               02096000
         TEMP1=ADDR(LIT_NEGMAX);                                                02096500
         CALL INLINE("28", 2, 0);                   /* LDR 2,0          */      02097000
         CALL INLINE("20", 0, 0);                   /* LPDR 0,0         */      02097500
         CALL INLINE("2B", 4, 4);                   /* SDR 4,4          */      02098000
         CALL INLINE("78", 4, 0, FLT_NEGMAX);       /* LE 4,FLT_NEGMAX  */      02098500
         CALL INLINE("58", 2, 0, TEMP1);              /* L   2,TEMP1   */       02099000
         CALL INLINE("29", 4, 2);                   /* CDR 4,2          */      02099500
         CALL INLINE("07", 8, 2);                   /* BCR 8,2          */      02100000
         CALL INLINE("58", 1, 0, ADDR_ROUNDER);       /* L    1,ADDR_ROUNDR*/   02100500
         CALL INLINE("6A", 0, 0, 1, 0);               /* AD   0,0(0,1)     */   02101000
         CALL INLINE("58", 1, 0, ADDR_FIXED_LIMIT);   /* L    1,ADDR__LIMIT*/   02101500
         CALL INLINE("58", 2, 0, TEMP);               /* L    2,TEMP       */   02102000
         CALL INLINE("69", 0, 0, 1, 0);               /* CD   0,0(0,1)     */   02102500
         CALL INLINE("07", 2, 2);                     /* BCR  2,2          */   02103000
LIT_NEGMAX:                                                                     02103500
         CALL INLINE("58", 1, 0, ADDR_FIXER);         /* L    1,ADDR_FIXER */   02104000
         CALL INLINE("6E", 0, 0, 1, 0);               /* AW   0,0(0,1)     */   02104500
         CALL INLINE("58",1,0,FOR_DW);             /* L   1,DW   */             02105000
         CALL INLINE("60", 0, 0, 1, 8);            /* STD 0,8(0,1)      */      02105500
         CALL INLINE("70", 2, 0, 1, 8);             /* STE 2,8(0,1)     */      02106000
         NEGLIT=SHR(DW(2), 31);                                                 02106500
         IF NEGLIT THEN                                                         02107000
            DO;  /* NEGATIVE VALUE  */                                          02107500
            IF DW(3) ^= NEGMAX THEN                                             02108000
               DW(3) = -DW(3);                                                  02108500
         END;                                                                   02109000
         RETURN TRUE;                                                           02109500
      END INTEGERIZABLE;                                                        02110000
                                                                                02110500
 /* ROUTINE TO ENTER CHARACTER STRING LITERALS INTO CHARACTER STORAGE */        02111000
ENTER_CHAR_LIT:                                                                 02111500
      PROCEDURE(STR) FIXED;                                                     02112000
         DECLARE STR CHARACTER, XSIZE BIT(8), LIT_MVC LABEL;                    02112500
         DECLARE TEMP FIXED;                                                    02113000
         IF LENGTH(STR) > RECORD_ALLOC(LIT_NDX) - LIT_CHAR_USED THEN            02113500
            CALL ERRORS(CLASS_BS,107);                                          02114000
         LIT_CHAR_ADDR=COREWORD(ADDR(LIT_NDX)) + LIT_CHAR_USED;                 02114100
         XSIZE = LENGTH(STR) - 1;                                               02114500
         TEMP = ADDR(LIT_MVC);                                                  02115000
      CALL INLINE("58", 1, 0, STR);                    /*  L   1,STR          */02115500
      CALL INLINE("58", 2, 0, LIT_CHAR_ADDR);          /*  L   2,LIT_CHAR_ADDR*/02116000
      CALL INLINE("58", 3, 0, TEMP);                   /*  L   3,TEMP         */02116500
       CALL INLINE("D2", 0, 0, 3, 1, XSIZE);            /* MVC 1(0,3),XSIZE   */02117000
LIT_MVC:                                                                        02117500
      CALL INLINE("D2", 0, 0, 2, 0, 1, 0);             /*  MVC 0(0,2),0(1)    */02118000
         TEMP = SHL(XSIZE,24) | LIT_CHAR_ADDR;                                  02118500
         LIT_CHAR_ADDR = LIT_CHAR_ADDR + XSIZE + 1;                             02119000
         LIT_CHAR_USED = LIT_CHAR_USED + XSIZE + 1;                             02119500
         RETURN TEMP;                                                           02120000
      END ENTER_CHAR_LIT;                                                       02120500
                                                                                02121000
 /* ROUTINE TO SETUP LITERAL IN STACKS ACCORDING TO TYPE  */                    02121500
LITERAL:                                                                        02122000
      PROCEDURE(PTR, LTYPE, STACK);                                             02122500
         DECLARE (PTR, STACK) BIT(16),                                          02123000
            LTYPE BIT(16);                                                      02123500
         DECLARE STR CHARACTER;                                                 02125000
         IF PTR < 0 THEN RETURN;                                                02125500
         IF LTYPE=CHAR THEN DO;                              /*DR120223*/
            IF TAG1=VAC & ((TYPE(STACK) & 8)=8) THEN         /*DR120223*/
               DOUBLEFLAG = TRUE;                            /*DR120223*/
            ELSE DOUBLEFLAG = FALSE;                /*DR109083,DR120223*/
         END;                                                /*DR120223*/
         TYPE(STACK) = LTYPE;                                                   02126000
         PTR=GET_LITERAL(PTR);                                                  02126500
         IF LTYPE=CHAR THEN DO;                                                 02127000
            DO CASE (LIT1(PTR) & "3");                       /*MOD-DR109083*/   02127500
               DO;  /* ACTUAL LITERAL */                                        02128000
                  VAL(STACK) = LIT2(PTR);                                       02128500
               END;                                                             02129000
               DO;  /* ARITHMETIC  */                                           02129500
                  DW(0)=LIT2(PTR);                                              02130000
                  DW(1) = LIT3(PTR);                                            02130500
 /*DR120223*/     IF (CLASS = INTEGER) | (TAG3 = INTEGER) THEN DO;              02131000
                     IF ^INTEGERIZABLE THEN GO TO SCALAR_CHAR;                  02131500
                     STR = DW(3);                                               02132000
                     VAL(STACK) = ENTER_CHAR_LIT(STR);                          02132500
                  END;                                                          02133000
                  ELSE DO;                                                      02133500
SCALAR_CHAR:                                                                    02134000
                     IF LIT1(PTR) = 5 THEN DOUBLEFLAG = TRUE;    /*DR109083*/
                     VAL(STACK) = ENTER_CHAR_LIT(MONITOR(12, DOUBLEFLAG));      02134500
                  END;                                                          02135000
               END;                                                             02135500
               GO TO UNIMPLEMENTED;                                             02136000
            END;                                                                02136500
            SIZE(STACK) = LENGTH(DESC(VAL(STACK)));                             02137000
            RETURN;                                                             02137500
         END;                                                                   02138000
         ELSE IF LIT1(PTR) = 2 THEN DO;                                         02138500
            VAL(STACK) = LIT2(PTR);                                             02139500
            SIZE(STACK) = LIT3(PTR);                                            02140000
            IF SIZE(STACK) > HALFWORDSIZE THEN                                  02140500
               TYPE(STACK) = FULLBIT;                                           02141000
            RETURN;                                                             02141500
         END;                                                                   02142000
         DO CASE LTYPE & "7";                                                   02142500
            ;                                                                   02143000
            GO TO INTEGER_LIT;                                                  02143010
 /?P        /* CR11114 -- BFS/PASS INTERFACE */
            GO TO INTEGER_LIT;                                                  02143020
 ?/
 /?B        /* CR11114 -- BFS/PASS INTERFACE */
         ;
 ?/
            GO TO SCALAR_LIT;                                                   02143500
            GO TO SCALAR_LIT;                                                   02144000
            DO;  /* CASE 5 -- SCALAR */                                         02144500
SCALAR_LIT:                                                                     02145000
               VAL(STACK) = LIT2(PTR);                                          02145500
               XVAL(STACK) = LIT3(PTR);                                         02146000
               TYPE(STACK) = TYPE(STACK)&8 | SCALAR;                            02146500
            END;  /* OF CASE 5 */                                               02147000
            DO;  /* CASE 6 -- INTEGER */                                        02147500
INTEGER_LIT:                                                                    02147600
               DW(0)=LIT2(PTR);                                                 02148000
               IF LIT1(PTR) = 3 THEN                                            02148010
                  DW(3)=EXTENT(DW(0))+ SYT_DISP(DW(0));                         02148020
               ELSE DO;                                                         02148030
                  DW(1) = LIT3(PTR);                                            02148500
                  IF ^INTEGERIZABLE THEN                                        02149000
                     CALL ERRORS(CLASS_BS,108);                                 02149500
               END;                                                             02149600
               VAL(STACK) = DW(3);                                              02150000
            IF (DW(3)>HALFMAX) | (DW(3)<HALFMIN) THEN TYPE(STACK)=TYPE(STACK)|8;02150500
            END;  /* OF CASE 6 */                                               02151000
         END;  /* OF DO CASE */                                                 02151500
      END LITERAL;                                                              02152000
                                                                                02152500
 /* ROUTINE TO TABLE CLASSIFIED LITERALS FOR CONSTANT AREA */                   02153000
SAVE_LITERAL:                                                                   02153500
      PROCEDURE(OP, OPTYPE) BIT(16);                                            02154000
         DECLARE (OP, OPTYPE, PTR) BIT(16);                                     02154500
         OPTYPE=OPMODE(OPTYPE);                                                 02155500
         FORM(OP)=CHARLIT+OPTYPE;                                               02156000
         CONSTANT_REFS(OPTYPE) = CONSTANT_REFS(OPTYPE) + 1;                     02156100
         PTR=CONSTANT_HEAD(OPTYPE);                                             02156500
         DO WHILE PTR^=0;                                                       02157000
            IF OPTYPE = 0 THEN DO;                                              02157500
               MESSAGE = DESC(CONSTANTS(PTR));                                  02158000
               IF LENGTH(MESSAGE) = LENGTH(DESC(VAL(OP))) THEN                  02158100
                  IF MESSAGE=DESC(VAL(OP)) THEN                                 02158500
                  GO TO RETURN_PTR;                                             02159000
            END;                                                                02159500
            ELSE IF CONSTANTS(PTR)=VAL(OP) THEN DO;                             02160000
               IF OPTYPE < 4 THEN                                               02160500
                  GO TO RETURN_PTR;                                             02161000
               IF CONSTANTS(PTR+1) = XVAL(OP) THEN                              02161500
                  GO TO RETURN_PTR;                                             02162000
            END;                                                                02162500
            PTR=CONSTANT_PTR(PTR);                                              02163000
         END;                                                                   02163500
 /* INSERT INTO CONSTANT LIST*/                                                 02163922
         PTR,CONSTANT_CTR=CONSTANT_CTR+1;                                       02164000
         CONSTANT_PTR(PTR) = CONSTANT_HEAD(OPTYPE);                             02164550
         CONSTANT_HEAD(OPTYPE) = PTR;                                           02164560
         CONSTANTS(PTR)=VAL(OP);                                                02165500
         IF OPTYPE >= 4 THEN DO;                                                02167500
            CONSTANT_CTR=CONSTANT_CTR+1;                                        02168000
            CONSTANTS(CONSTANT_CTR)=XVAL(OP);                                   02168500
         END;                                                                   02169000
         IF CONSTANT_CTR > CONST_LIM THEN                                       02169500
            CALL ERRORS(CLASS_BS,109);                                          02170000
         IF BINARY_CODE THEN DO;                                                02170500
            MESSAGE=HEX(VAL(OP),8);                                             02171000
            IF OPTYPE >= 4 THEN                                                 02171500
               MESSAGE=MESSAGE||BLANK||HEX(XVAL(OP),8);                         02172000
            OUTPUT=FORMAT(PTR,6)||COLON||MESSAGE;                               02172500
         END;                                                                   02173000
RETURN_PTR:                                                                     02173500
         LOC(OP) = PTR;                                                         02174000
         RETURN PTR;                                                            02174500
      END SAVE_LITERAL;                                                         02175000
                                                                                02175500
 /* ROUTINE TO ESTABLISH LIBRARY NAMING CONVENTIONS */                          02176000
LIBNAME:                                                                        02176500
      PROCEDURE(NAME) CHARACTER;                                                02177000
         DECLARE NAME CHARACTER;                                                02177500
         IF ^Z_LINKAGE THEN RETURN NAME;                                        02178000
         IF SHR(INTRINSIC(NAME),1) THEN RETURN NAME;                            02178500
         RETURN '#Q' || NAME;                                                   02179000
      END LIBNAME;                                                              02179500
                                                                                02180000
 /* ROUTINE TO COLLECT NAMES TO EXTERNAL ROUTINES AND ASSIGN ESDIDS  */         02180500
ENTER_CALL:                                                                     02181000
      PROCEDURE(NAME) BIT(16);                                                  02181500
         DECLARE NAME CHARACTER, (I, J) BIT(16);                                02182000
         NAME = LIBNAME(NAME);                                                  02182500
         J = HASH(NAME);                                                        02183000
         I = ESD_START(J);                                                      02183500
         DO WHILE I ^= 0;                                                       02184000
            IF ESD_TABLE(I) = NAME THEN RETURN I;                               02184500
            I = ESD_LINK(I);                                                    02185000
         END;                                                                   02185500
         ESD_MAX = ESD_MAX + 1;                                                 02186000
         IF ESD_MAX > ESD_LIMIT THEN DO;                                        02186500
            ESD_MAX = ESD_LIMIT;                                                02187000
            CALL ERRORS(CLASS_BS,110);                                          02187500
         END;                                                                   02188000
 /?P     /* CR11114 -- BFS/PASS INTERFACE */
         CALL ENTER_ESD(NAME, ESD_MAX, 2);                                      02188500
 ?/
 /?B     /* CR11114 -- BFS/PASS INTERFACE; ADD CODE TO MAKE VERSION=1 */
         /*            FOR LIBRARIES                                  */
         CALL ENTER_ESD(NAME, ESD_MAX, 2, LIBRARY_CSECT_TYPE);
 ?/
         ESD_LINK(ESD_MAX) = ESD_START(J);                                      02189000
         ESD_START(J) = ESD_MAX;                                                02189500
         RETURN ESD_MAX;                                                        02190000
      END ENTER_CALL;                                                           02190500
                                                                                02191000
 /* ROUTINE TO EMIT EXTERNAL CALLS FOR PROCEDURE/INTRINSIC ROUTINES */          02191500
EMIT_CALL:                                                                      02192000
      PROCEDURE(ESID, INTSIC);                                                  02192500
         DECLARE ESID BIT(16), INTSIC BIT(1);                                   02193000
/*------------------------- #DDSE --------------------------------*/            32540000
/* SET DSES TO ZERO BEFORE CALL. (EXTERNAL PROCEDURES ONLY)       */            32550000
         IF DATA_REMOTE THEN                                                    32560099
         IF (ESD_TYPE(ESID) = 2) & EMIT_LDM THEN       /* CR12620 */            32570099
            CALL EMITP(LDM, 0, 0, EXTSYM, DSECLR   , RXTYPE);                   32580099
/*----------------------------------------------------------------*/            32600000
 /* DANNY STRAUSS ----------- CR11053 -------------------------------*/         00857500
 /* A NEGATIVE LIB_POINTER INDICATES AN UNVERIFIED ROUTINE*/                    00857500
         IF LIB_POINTER < 0 THEN DO;                                            00857500
 /* RESET LIB_POINTER SO LATER CALLS TO HAL PROCEDURES DONT GET ERROR.*/        00857500
            LIB_POINTER = -LIB_POINTER;                                         00857500
            CALL ERRORS(CLASS_XS,3,ESD_TABLE(ESID));                            00857500
         END;                                                                   00857500
 /* DANNY STRAUSS ---------------------------------------------------*/         00857500
         IF INTSIC | OLD_LINKAGE THEN                                           02193500
            CALL EMITP(BAL, LINKREG, 0, EXTSYM, ESID);                          02194000
         ELSE CALL EMITP(SCAL, TEMPBASE, 0, EXTSYM, ESID);                      02194500
/*------------------------- #DDSE --------------------------------*/            32720000
/* RESTORE DSES AFTER RETURN. (EXTERNAL PROCEDURES ONLY)          */            32730000
         IF DATA_REMOTE THEN                                                    32740099
         IF (ESD_TYPE(ESID) = 2) & EMIT_LDM THEN       /* CR12620 */            32750099
            CALL EMITP(LDM, 0, 0, EXTSYM, DSESET   , RXTYPE);                   32760099
         EMIT_LDM = TRUE;                              /* CR12620 */
/*----------------------------------------------------------------*/            32780000
         CALL NEED_STACK(INDEXNEST);                                            02195000
         INTSIC = 0;                                                            02195500
      END EMIT_CALL;                                                            02196000
                                                                                02196500
                                                                                02217000
 /* ROUTINE TO CREATE INTEGER LITERAL STACK ENTRY ANC CLASSIFY */               02217500
GET_INTEGER_LITERAL:                                                            02218000
      PROCEDURE(VALUE) BIT(16);                                                 02218500
         DECLARE VALUE FIXED, PTR BIT(16);                                      02219000
         PTR = GET_STACK_ENTRY;                                                 02219500
         VAL(PTR) = VALUE;                                                      02220000
         FORM(PTR) = LIT;                                                       02220500
         IF (VALUE > HALFMAX) | (VALUE < HALFMIN) THEN TYPE(PTR) = DINTEGER;     2221000
         ELSE TYPE(PTR) = INTEGER;                                              02221500
         SIZE(PTR) = 1;                                                         02222000
         LOC(PTR) = -1;                                                         02222500
         RETURN PTR;                                                            02223000
      END GET_INTEGER_LITERAL;                                                  02223500
                                                                                 2223510
 /* ROUTINE TO SET UP LITERAL 'ONE' DEPENDANT ON OPERAND TYPE */                 2223520
GET_LIT_ONE:                                                                     2223530
      PROCEDURE(OPTYPE) BIT(16);                                                 2223540
         DECLARE (OPTYPE, PTR) BIT(16);                                          2223550
         PTR = GET_STACK_ENTRY;                                                  2223560
         IF CVTTYPE(OPTYPE) = 0 THEN                                             2223570
            VAL(PTR) = "41100000";                                               2223580
         ELSE VAL(PTR) = 1;                                                      2223590
         XVAL(PTR) = 0;                                                          2223600
         TYPE(PTR) = OPTYPE;                                                     2223610
         FORM(PTR) = LIT;                                                        2223620
         LOC(PTR) = -1;                                                          2223630
         RETURN PTR;                                                             2223640
      END GET_LIT_ONE;                                                           2223650
                                                                                02224000
 /* ROUTINE TO SETUP LABEL ADCONS FROM STACKS  */                               02224500
SETUP_ADCON:                                                                    02225000
      PROCEDURE(OP);                                                            02225500
         DECLARE (OP, SY, IX) BIT(16);                                          02226000
         IF ^(FORM(OP) = SYM | FORM(OP) = LBL) THEN RETURN;                     02227000
         SY = LOC2(OP);                                                         02227500
         IF (SYT_FLAGS(SY) & NAME_FLAG) ^= 0 THEN DO;                           02228000
            FORM(OP) = SYM;                                                     02228500
            RETURN;                                                             02229000
         END;                                                                   02229500
 /?P     /* CR11114 -- BFS/PASS INTERFACE; PDE EMISSION */
         IF SYT_SCOPE(SY) < PROGPOINT | SYT_TYPE(SY) < TASK_LABEL THEN          02230000
            IX = SYT_SCOPE(SY);                                                 02230500
         ELSE DO;                                                               02231000
            IX = PCEBASE;                                                       02231500
            INX_CON(OP) = SYT_PARM(SY) * 6;                                     02232000
         END;                                                                   02232500
         FORM(OP) = EXTSYM;                                                     02233000
         LOC(OP) = IX;                                                          02233500
 ?/
 /?B     /* CR11114 -- BFS/PASS INTERFACE; PDE EMISSION */
         FORM(OP) = EXTSYM;                                                     02233000
         LOC(OP) = SYT_SCOPE(SY);
 ?/
      END SETUP_ADCON;                                                          02235500
                                                                                02236000
 /* ROUTINE TO FIND AVAILABLE SLOT IN FREE SPACE LIST */                        02236010
GETFREETEMP:                                                                    02236020
      PROCEDURE;                                                                02236030
         IX1 = 1;                                                               02236040
         DO WHILE UPPER(IX1) > 0;                                               02236050
            IX1 = IX1 + 1;                                                      02236060
         END;                                                                   02236070
         IF IX1 > LASTEMP THEN CALL ERRORS(CLASS_BS, 112);                      02236080
         IF IX1 > FULLTEMP THEN FULLTEMP = IX1;                                 02236090
         RETURN IX1;                                                            02236100
      END GETFREETEMP;                                                          02236110
                                                                                02236120
 /*  SUBROUTINE FOR GETTING FREE TEMPORARY STORAGE   */                         02236500
GETFREESPACE:                                                                   02237000
      PROCEDURE(OPTYPE, TEMPSPACE) FIXED;                                       02237500
         DECLARE (TEMPSPACE, TYPESIZE, XSIZE, TEMP, OPTYPE) FIXED;              02238000
         DECLARE I BIT(16);                                                     02238250
         IX1 = GETFREETEMP;                                                     02238500
         IX2 = PROC_LINK(INDEXNEST);                                            02239000
         CALL NEED_STACK(INDEXNEST);                                            02241500
         TYPESIZE=BIGHTS(OPTYPE);                                               02242000
         IF OPTYPE = STRUCTURE THEN DO;                                         02242500
            TYPESIZE = BIGHTS(FULLBIT);                                         02243000
            XSIZE = TEMPSPACE;                                                  02243500
         END;                                                                   02244000
         ELSE IF OPTYPE = CHAR THEN                                             02244500
            XSIZE = CS(TEMPSPACE);                                              02245000
         ELSE XSIZE = TEMPSPACE * TYPESIZE;                                     02245500
         TEMP = WORKSEG(INDEXNEST);                                             02246000
         DO FOREVER;                                                            02246500
            TEMP = ADJUST(TYPESIZE, TEMP);                                      02247000
            CALL CHECKSIZE(TEMP+XSIZE, 1);                                      02247500
            IF TEMP+XSIZE <= LOWER(POINT(IX2)) THEN DO;                         02248000
               UPPER(IX1) = TEMP+XSIZE;                                         02248500
            IF UPPER(IX1)>MAXTEMP(INDEXNEST) THEN MAXTEMP(INDEXNEST)=UPPER(IX1);02249000
               GO TO SPACEFOUND;                                                02249500
            END;                                                                02250000
            ELSE DO;                                                            02250500
               IX2=POINT(IX2);                                                  02251000
               TEMP = UPPER(IX2);                                               02251500
            END;                                                                02252000
         END;                                                                   02252500
SPACEFOUND:LOWER(IX1)=TEMP;                                                     02253000
         POINT(IX1)=POINT(IX2);                                                 02253500
         POINT(IX2)=IX1;                                                        02254000
         IX2 = GET_STACK_ENTRY;                                                 02254500
         FORM(IX2) = WORK;                                                      02255000
         TYPE(IX2) = OPTYPE;                                                    02255500
         LOC(IX2) = IX1;                                                        02256000
         LOC2(IX2) = -1;                                                         2256100
         WORK_BLK(IX1) = CURCBLK;                                                2256200
         WORK_CTR(IX1) = CTR;                                                   02256500
         WORK_USAGE(IX1) = 1;                                                   02257000
         SAVED_LINE(IX1) = 0;                                                   02257100
         BASE(IX2) = TEMPBASE;                                                  02257500
         IF PACKTYPE(OPTYPE) = VECMAT THEN                                      02258000
            DISP(IX2) = TEMP - TYPESIZE;                                        02258500
         ELSE DISP(IX2) = TEMP;                                                 02259000
         IF DISP(IX2) > 2047 & TEMPSPACE > 1 THEN                               02259500
            CALL ERRORS(CLASS_BS,113);                                          02260000
         DO I = PTRARG1 TO RM;                                                  02260045
            IF USAGE(I) THEN                                                    02260090
               IF R_CONTENTS(I) = WORK THEN                                     02260135
               IF R_VAR(I) = IX1 THEN DO;                                       02260180
               CALL UNRECOGNIZABLE(I);                                          02260225
            END ;                                                               02260270
         END ;                                                                  02260315
         RETURN IX2;                                                            02260500
      END GETFREESPACE;                                                         02261000
                                                                                02261500
 /* ROUTINE TO RELEASE A GIVEN TEMPORARY AREA */                                02262000
DROPTEMP:                                                                       02262500
      PROCEDURE(ENTRY);                                                         02263000
         DECLARE ENTRY BIT(16);                                                 02263500
         IX2 = PROC_LINK(INDEXNEST);                                            02264000
         DO WHILE IX2 ^= ENTRY;                                                 02264500
            IX1 = IX2;                                                          02265000
            IX2 = POINT(IX2);                                                   02265500
            IF IX2 = PROC_LINK(INDEXNEST) THEN RETURN;  /* SAFETY VALVE */      02266000
         END;                                                                   02266500
         UPPER(IX2) = -1;                                                       02267000
         POINT(IX1) = POINT(IX2);                                               02267500
      END DROPTEMP;                                                             02268000
                                                                                02276000
 /* ROUTINE TO DROP TEMPS SAVED THROUGH ARRAYNESS */                            02276500
DROPLIST:                                                                       02277000
      PROCEDURE(LEVEL);                                                         02277500
         DECLARE (LEVEL, PTR) BIT(16);                                          02278000
         DO WHILE SDOTEMP(LEVEL) > 0;                                           02278500
            PTR = SDOTEMP(LEVEL);                                               02279000
            SDOTEMP(LEVEL) = ARRAYPOINT(PTR);                                   02279500
            CALL DROPTEMP(PTR);                                                 02280000
         END;                                                                   02280500
      END DROPLIST;                                                             02281000
                                                                                02281500
 /* SUBROUTINE FOR DROPPING TEMPORARY STORAGE SPACE  */                         02282000
DROPFREESPACE:                                                                  02282500
      PROCEDURE;                                                                02283000
         DECLARE I BIT(16);                                                     02283500
         DO I = 1 TO SAVEPTR;                                                   02284000
            IF SAVEPOINT(I) > 0 THEN                                            02284500
               CALL DROPTEMP(SAVEPOINT(I));                                     02285000
         END;                                                                   02285500
         SAVEPTR = 0;                                                           02286000
      END DROPFREESPACE;                                                        02286500
                                                                                02287000
 /* SUBROUTINE FOR SAVING DETAILS OF TEMPORARY SPACE TO BE DROPPED */           02287500
DROPSAVE:                                                                       02288000
      PROCEDURE(ENTRY);                                                         02288500
         DECLARE ENTRY BIT(16);                                                 02289000
         DECLARE (I, J) BIT(16);                                                02289500
         IF FORM(ENTRY) ^= WORK THEN RETURN;                                    02290000
         IF (NR_STACK(ENTRY)>0) THEN DO;            /* CR12432 */
      /* DROPPING RNR THAT WAS PUT ON STACK.        /* CR12432 */
      /* IF DROPSAVE IS NEVER CALLED, THEN ENTRY    /* CR12432 */
      /* GETS DROPPED BY CODE IN RETURN_STACK_ENTRY /* CR12432 */
            I = NR_STACK(ENTRY);                    /* CR12432 */
            NR_STACK(ENTRY) = 0;                    /* CR12432 */
            ENTRY = I;                              /* CR12432 */
         END;                                       /* CR12432 */
         ELSE                                       /* CR12432 */
         ENTRY = LOC(ENTRY);                                                    02290500
         IF ENTRY <= 0 THEN RETURN;                                             02291000
         WORK_USAGE(ENTRY) = WORK_USAGE(ENTRY) - 1;                             02291500
         IF WORK_USAGE(ENTRY) > 0 THEN RETURN;                                  02292000
         DO I = PTRARG1 TO RM;                                                  02292010
            IF USAGE(I) THEN                                                    02292020
               IF R_CONTENTS(I) = WORK THEN                                     02292030
               IF R_VAR(I) = ENTRY THEN                                         02292040
               CALL UNRECOGNIZABLE(I);                                          02292050
         END;                                                                   02292060
         DO I = 1 TO DOLEVEL;                                                   02292070
            IF DOTEMPBLK(I) > WORK_BLK(ENTRY) | DOTEMPBLK(I) = WORK_BLK(ENTRY)  02292080
               & DOTEMPCTR(I) >= WORK_CTR(ENTRY) THEN DO;                       02292090
               J = DOTEMP(I);                                                   02292100
               DO WHILE J > 0;                                                  02292110
                  IF J = ENTRY THEN RETURN;                                     02292120
                  J = ARRAYPOINT(J);                                            02292130
               END;                                                             02292140
               ARRAYPOINT(ENTRY) = DOTEMP(I);                                   02292150
               DOTEMP(I) = ENTRY;                                               02292160
               RETURN;                                                          02292170
            END;                                                                02292180
         END;                                                                   02292190
         DO I = 0 TO CALL_LEVEL;                                                02292500
            IF DOCOPY(I) > 0 THEN                                               02293000
               IF DOBLK(I) > WORK_BLK(ENTRY) | DOBLK(I) = WORK_BLK(ENTRY)       02293500
               & DOCTR(I) >= WORK_CTR(ENTRY) | CALL_CONTEXT(I) > 1 THEN DO;     02293510
               I = SDOLEVEL(I);                                                 02294000
               J = SDOTEMP(I);                                                  02294500
               DO WHILE J > 0;                                                  02295000
                  IF J = ENTRY THEN RETURN;                                     02295500
                  J = ARRAYPOINT(J);                                            02296000
               END;                                                             02296500
               ARRAYPOINT(ENTRY) = SDOTEMP(I);                                  02297000
               SDOTEMP(I) = ENTRY;                                              02297500
               RETURN;                                                          02298000
            END;                                                                02298500
         END;                                                                   02299000
         DO I = 1 TO SAVEPTR;                                                   02299500
            IF SAVEPOINT(I) = ENTRY THEN RETURN;                                02300000
         END;                                                                   02300500
         SAVEPTR = SAVEPTR + 1;                                                 02301000
         SAVEPOINT(SAVEPTR) = ENTRY;                                            02301500
      END DROPSAVE;                                                             02302000
                                                                                02302500
 /* ROUTINE TO SAVE THE CONTENTS OF A REGISTER IN A TEMPORARY LOCATION */       02303000
CHECKPOINT_REG:                                                                 02303500
      PROCEDURE(R, SAVE);                                                        2304000
         DECLARE (R, RTYPE, PTR, I) BIT(16), SAVE BIT(1);                        2304100
         IF R > FR0 THEN IF R THEN                                               2304200
            IF OPMODE(R_TYPE(R-1)) = 4 THEN IF USAGE(R-1) > 1 THEN R = R - 1;    2304300
         IF USAGE(R) > 1 THEN DO;                                               02305000
            RTYPE = R_TYPE(R);                                                  02305500
            IF PACKTYPE(RTYPE) = VECMAT THEN RTYPE = RTYPE&8 | SCALAR;           2305600
            PTR = GETFREESPACE(RTYPE, 1);                                       02306500
            CALL SAVE_BRANCH_AROUND;                                            02306600
            CALL EMIT_BY_MODE(STORE, R, PTR, TYPE(PTR));                        02307000
            SAVED_LINE(LOC(PTR)) = EMIT_BRANCH_AROUND;                          02307100
            WORK_USAGE(LOC(PTR)) = 0;                                           02307500
            DO I = 1 TO STACK_MAX;                                              02308000
               IF STACK_PTR(I) < 0 THEN                                         02308500
                  IF FORM(I) = VAC THEN DO;                                     02309000
                  IF REG(I) = R THEN DO;                                        02309500
                     DECLARE J BIT(16);                                         02309510
DO_TEMP:             DO J = 1 TO DOLEVEL;                                       02309520
                        IF I = DOFOROP(J) THEN                                  02309530
                           IF SYT_DISP(LOC(I)) = -I THEN DO;                    02309540
                           J = LOC(I);                                          02309550
                           SYT_ADDR(J), SYT_DISP(J) = DISP(PTR);                02309560
                           SYT_BASE(J) = BASE(PTR);                             02309570
                           SAVED_LINE(LOC(PTR)) =                               02309573
                              NO_BRANCH_AROUND(SAVED_LINE(LOC(PTR)));           02309576
                           CALL SET_USAGE(R, SYM, J);                           02309579
                           ESCAPE DO_TEMP;                                      02309580
                        END;                                                    02309590
                     END;                                                       02309600
                     WORK_USAGE(LOC(PTR)) = WORK_USAGE(LOC(PTR)) + 1;           02310000
                     FORM(I) = WORK;                                            02310500
                  /* AVOID @# INST WHEN CHECKPOINT IS RELOADED -CR12432 */
                     NR_DEREF(I) = FALSE;                    /* CR12432 */
                     LOC(I) = LOC(PTR);                                         02311000
                     BASE(I) = BASE(PTR);                                       02311500
                     DISP(I) = DISP(PTR);                                       02312000
                     REG(I) = -1;                                               02314500
                     INX(I), INX_CON(I) = 0;                                    02315000
                     IF DIAGNOSTICS THEN OUTPUT = 'FIXED STAK '||I;             02315500
                  END;                                                          02316000
               END;                                                             02316500
               ELSE IF INDEXING(R) THEN DO;                                     02317000
                  IF INX(I) = R THEN DO;                                        02317500
                     IF DEL(PTR) = 0 THEN                                       02318000
                        WORK_USAGE(LOC(PTR))=WORK_USAGE(LOC(PTR))+1;            02318500
                     DEL(PTR) = DEL(PTR) + 2;                                   02319000
                     INX(I) = -PTR;                                             02319500
                     IF NEXT_USE(PTR) = 0 | NEXT_USE(PTR) > INX_NEXT_USE(I) THEN 2319600
                        NEXT_USE(PTR) = INX_NEXT_USE(I);                         2319700
                  END;                                                          02320000
                  ELSE IF BACKUP_REG(I) = R THEN                                02320500
                     IF FORM(I) = CSYM THEN DO;                                 02321000
                     WORK_USAGE(LOC(PTR)) = WORK_USAGE(LOC(PTR)) + 1;           02322000
                     DEL(PTR) = 2;                                              02322500
                     BACKUP_REG(I), BASE(I) = -PTR;                             02323000
                  END;                                                          02323500
               END;                                                             02324000
            END; /* DO I  */                                                    02324500
            IF DEL(PTR) = 0 THEN                                                02325000
            DO;                                    /*DR109075*/
               IF WORK_USAGE(LOC(PTR))=0 THEN      /*DR109075*/
                  CALL DROPSAVE(PTR);              /*DR109075*/
               CALL RETURN_STACK_ENTRY(PTR);                                    02325500
            END;                                   /*DR109075*/
            ELSE IF WORK_USAGE(LOC(PTR)) = 1 THEN                               02325510
               CALL SET_USAGE(R, WORK, LOC(PTR));                               02325520
            IF RTYPE = DSCALAR THEN                                             02326000
               IF SAVE THEN USAGE(R+1) = USAGE(R+1) & TRUE;                      2326500
            ELSE CALL CLEAR_R(R+1);                                              2326600
         END;                                                                   02327000
         IF SAVE THEN USAGE(R) = USAGE(R) & TRUE;                                2327500
         ELSE DO;                                                                2327550
            CALL CLEAR_R(R);                                                     2327600
            IF R THEN IF OPMODE(R_TYPE(R-1)) = 4 THEN CALL CLEAR_R(R-1);         2327650
         END;                                                                    2327700
         SAVE = FALSE;                                                           2327750
      END CHECKPOINT_REG;                                                       02328000
                                                                                02328500
 /* FUNCTION TO FIND A FREE ACCUMULATOR OF THE APPROPRIATE CLASS */             02329000
BESTAC:                                                                         02329500
      PROCEDURE(RCLASS) BIT(8);                                                 02330000
         DECLARE (RCLASS, I, J, R) BIT(16), DACC BIT(1);                        02330500
         DECLARE SET_J LITERALLY 'DO;IF R^=NOT_THIS_REGISTER /*DR111358*/        2331000
            & R^=NOT_THIS_REGISTER2 THEN J=R;END';           /*DR111358*/        2331000
         DACC = RCLASS=DOUBLE_ACC | RCLASS=DOUBLE_FACC;                         02331500
         R = TARGET_REGISTER;                                                   02332000
         IF R >= 0 THEN                                                         02332500
            GO TO RETURN_R;                                                     02333000
         J = -1;                                                                02333500
         DO I = RCLASS_START(RCLASS) TO RCLASS_START(RCLASS+1)-1;               02334000
            R=REGISTERS(I);                                                     02334500
            IF USAGE(R) = 0 THEN IF R ^= NOT_THIS_REGISTER THEN DO;             02335000
               IF ^DACC THEN                                                    02335500
                  GO TO RETURN_R;                                               02336000
               IF USAGE(R+1) = 0 THEN GO TO RETURN_R;                           02336500
            END;                                                                02337000
            IF R THEN IF RCLASS = FLOATING_ACC THEN                              2337100
               IF USAGE(R-1) ^= 0 THEN                                           2337200
               IF OPMODE(R_TYPE(R-1)) = 4 THEN                                   2337300
               R = R - 1;                                                        2337400
            IF J < 0 THEN                                                       02337500
               SET_J;                                                           02338000
            ELSE IF DACC THEN DO;                                               02338500
               IF USAGE(R+1) <= USAGE(J+1) THEN GO TO CHECK_USAGE;              02339000
            END;                                                                02339500
            ELSE DO;                                                            02340000
CHECK_USAGE:                                                                    02340500
               IF SHR(USAGE(R),1) < SHR(USAGE(J),1) THEN                         2341000
                  SET_J;                                                        02341500
               ELSE IF SHR(USAGE(R),1) = SHR(USAGE(J),1) THEN                    2342000
                  IF USAGE_LINE(R) = 0 THEN                                      2342500
                  SET_J;                                                         2342510
               ELSE IF USAGE_LINE(R) > 0 THEN IF USAGE_LINE(J) > 0 THEN         02342520
                  IF USAGE_LINE(R) > USAGE_LINE(J) THEN                          2342530
                  SET_J;                                                        02343000
            END;                                                                02343500
         END;  /* DO FOR I  */                                                  02344000
         R = J;                                                                 02344250
RETURN_R:                                                                       02344500
         RETURN R;                                                              02344750
      END BESTAC;                                                               02345000
                                                                                02345500
 /* ROUTINE TO ALLOCATE AN ACCUMULATOR OF THE APPROPRIATE CLASS */              02346000
FINDAC:                                                                         02346500
      PROCEDURE(RCLASS, SAVE) BIT(16);                                          02347000
         DECLARE (RCLASS, R) BIT(16), SAVE BIT(8);                              02347500
         R = BESTAC(RCLASS);                                                    02348000
         CALL CHECKPOINT_REG(R,SAVE);                                           02348500
         SAVE = FALSE;                                                          02348510
         USAGE(R) = 2;                                                          02349500
         USAGE_LINE(R) = 1;                                                      2350000
         IF R < FR0 THEN R_TYPE(R) = INTEGER;                                   02350500
         IF RCLASS=DOUBLE_ACC | RCLASS = DOUBLE_FACC THEN DO;                   02351000
            CALL CHECKPOINT_REG(R+1);                                           02351500
            USAGE(R+1) = 1;                                                     02352500
            USAGE_LINE(R+1) = 1;                                                 2353000
            IF R < FR0 THEN DO;                                                  2353500
               R_TYPE(R), R_TYPE(R+1) = DINTEGER;                                2353600
               R_CONTENTS(R+1) = IMD;                                            2353700
            END;                                                                 2353800
            ELSE R_CONTENTS(R+1) = OFFSET;                                       2353900
         END;                                                                   02354500
         CALL CHECK_LINKREG(R);                                                 02355000
         RETURN R;                                                              02355500
      END FINDAC;                                                               02356000
                                                                                02356500
 /* ROUTINE TO GET A UTILITY ADDRESSING REGISTER WITHOUT DISTURBING ANYONE*/    02357000
GET_R:                                                                          02357500
   PROCEDURE(OP,TYPE_LOAD) BIT(16); /*#DREG - PASS IN OP & TYPE_LOAD */
      DECLARE OP BIT(16);     /*#DREG*/
      DECLARE TYPE_LOAD BIT(8);     /*#DREG*/
         DECLARE R BIT(16);                                                     02358500
         IF TARGET_R >= 0 THEN R = TARGET_R;                                    02359000
         ELSE R = PTRARG1;                                                      02359500
         /*----------------------- #DREG ----------------------*/
         /* RESTRICT R2 TO #P AND R1,R3 TO #D */
         IF DATA_REMOTE THEN
            R = REG_STAT(OP,R,TYPE_LOAD);
         /*----------------------------------------------------*/
         CALL CHECKPOINT_REG(R);                                                02360000
         R_TYPE(R) = DINTEGER;                                                  02360500
         USAGE(R) = 1;                                                          02362500
         R_CONTENTS(R) = IMD;                                                    2363000
         RETURN R;                                                              02363500
      END GET_R;                                                                02364000
                                                                                02364500
 /* ROUTINE TO DECREMENT INDEX USAGE AND CHECK FOR NO MORE */                   02365000
OFF_INX:                                                                        02365500
      PROCEDURE(R);                                                             02366000
         DECLARE R BIT(16);                                                     02366500
         IF R > 0 THEN DO;                                                      02367000
            USAGE(R) = USAGE(R) - 2;                                            02367500
         END;                                                                   02368000
         ELSE IF R < 0 THEN DO;                                                 02368500
            R = -R;                                                             02369000
            DEL(R) = DEL(R) - 2;                                                02369500
            IF DEL(R) = 0 THEN DO;                                              02370000
               CALL DROPSAVE(R);                                                02370500
               CALL RETURN_STACK_ENTRY(R);                                      02371000
            END;                                                                02371500
         END;                                                                   02372000
      END OFF_INX;                                                              02372500
                                                                                02373000
 /* ROUTINE TO DROP INDEX USAGES FROM STACK ENTRIES AND CLEAR */                02373500
DROP_INX:                                                                       02374000
      PROCEDURE(OP);                                                            02374500
         DECLARE OP BIT(16);                                                    02375000
         IF INX(OP) > 0 THEN                                                     2375100
            USAGE_LINE(INX(OP)) = INX_NEXT_USE(OP);                              2375200
         CALL OFF_INX(INX(OP));                                                 02375500
         AIA_ADJUSTED(OP)=FALSE;       /*DR109019*/
         INX(OP) = 0;                                                           02376000
      END DROP_INX;                                                             02376500
                                                                                02377000
 /*-ROUTINE TO SET UP POINTER ADDRESSES */                                      02377500
CHECK_ADDR_NEST:                                                                02378000
      PROCEDURE(TR, OP);                                                        02378500
         DECLARE (TR, R, OP, ALOC, SCOPE) BIT(16);                              02379000
         DECLARE IX BIT(16);                                                    02379500
         ALOC = LOC(OP);                                                        02380000
         IF (SYT_FLAGS(ALOC) & NAME_FLAG) = 0 THEN                              02380100
            IF SYT_TYPE(ALOC) >= TASK_LABEL THEN DO;                            02380500
            CALL SETUP_ADCON(OP);                                               02381000
            RETURN;                                                             02381500
         END;                                                                   02382000
         IF SYT_BASE(ALOC) ^= TEMPBASE THEN RETURN;                             02382500
         SCOPE = SYT_SCOPE(ALOC);                                               02383000
         IF SCOPE = INDEXNEST THEN RETURN;                                      02383500
         ELSE IF SCOPE = PROGPOINT THEN                                         02384000
            IF SYT_TYPE(PROC_LEVEL(SCOPE)) < TASK_LABEL THEN SCOPE = 0;         02384500
         IF TR < 0 THEN DO;                                                     02385000
            IX = PTRARG1;                                                       02385010
            IF USAGE(IX) THEN                                                   02385020
               IF R_CONTENTS(IX) = LOCREL THEN                                  02385030
               IF R_VAR(IX) = SCOPE THEN DO;                                    02385040
               R = IX;                                                          02385050
               /*------------------- #DREG ---------------------*/              29950005
               /* R IS USED AS A BASE REGISTER, SO RESTRICT IT. */              29960005
               IF DATA_REMOTE THEN                                              29970005
                  R = REG_STAT(OP,IX,LOADBASE);                                 29980005
               /*-----------------------------------------------*/              29990005
               GO TO SETUP_R;                                                   02385060
            END;                                                                02385070
            R =GET_R(OP,LOADBASE); /*#DREG*/
         END;                                                                   02385090
         /*------------------------- #DREG ---------------------*/              30040005
         /* AGAIN, R IS USED AS A BASE REGISTER, SO RESTRICT IT.*/              30050005
         ELSE IF TR = TEMPBASE | TR > R3 THEN R = GET_R(OP,LOADBASE);           30060005
         ELSE IF DATA_REMOTE THEN R = REG_STAT(OP,TR,LOADBASE);                 30070005
         /*-----------------------------------------------------*/              30080005
         ELSE R = TR;                                                           02385110
         IF SYT_TYPE(PROC_LEVEL(INDEXNEST)) = STMT_LABEL &                      02385120
            SYT_NEST(PROC_LEVEL(INDEXNEST)) = SYT_NEST(ALOC)+1 THEN             02385130
            CALL EMITRX(L, R, 0, TEMPBASE, STACK_LINK);                         02385140
         ELSE                                                       /*CR13811*/ 02385150
            CALL ERRORS(CLASS_XQ, 101, SYT_NAME(ALOC));                         02391020
         IF TR < 0 THEN                                                         02391040
            CALL SET_USAGE(R, LOCREL, SCOPE);                                   02391050
         ELSE USAGE(R) = 0;                                                     02391060
SETUP_R:                                                                        02391070
         BASE(OP), BACKUP_REG(OP) = R;                                          02391500
         DISP(OP) = SYT_DISP(ALOC);                                             02392000
         CALL INCR_USAGE(R);                                                    02392500
         FORM(OP) = CSYM;                                                       02393000
      END CHECK_ADDR_NEST;                                                      02395500
                                                                                 2395510
 /* ROUTINE TO SET NEXT USE OF REGISTER FROM STACKS FOLLOWING CURRENT USE */     2395520
SET_REG_NEXT_USE:                                                                2395530
      PROCEDURE(R, OP);                                                          2395540
         DECLARE (R, OP) BIT(16);                                                2395550
         USAGE_LINE(R) = NEXT_USE(OP);                                           2395560
         IF OPMODE(R_TYPE(R)) = 4 THEN                                           2395570
            USAGE_LINE(R+1) = NEXT_USE(OP);                                      2395580
      END SET_REG_NEXT_USE;                                                      2395590
                                                                                02396000
 /* ROUTINE TO DECREMENT REGISTER USAGE */                                      02396500
DROP_REG:                                                                       02397000
      PROCEDURE(OP);                                                            02397500
         DECLARE OP BIT(16);                                                    02398000
         USAGE(REG(OP)) = USAGE(REG(OP)) - 2;                                   02398500
         CALL SET_REG_NEXT_USE(REG(OP), OP);                                     2398600
      END DROP_REG;                                                             02399000
                                                                                02399500
 /* ROUTINE TO DECREMENT TARGET REGISTER USAGE AND CLEAR TARGET REGISTER */     02404500
OFF_TARGET:                                                                     02405000
      PROCEDURE(OP);                                                            02405500
         DECLARE OP BIT(16);                                                    02406000
         USAGE(TARGET_REGISTER) = USAGE(TARGET_REGISTER) - 2;                   02406500
         CALL SET_REG_NEXT_USE(TARGET_REGISTER, OP);                             2406600
         IF ^USAGE(TARGET_REGISTER) THEN DO;                                    02407000
            USAGE(TARGET_REGISTER) = USAGE(TARGET_REGISTER) + 1;                02407500
            R_CONTENTS(TARGET_REGISTER) = IMD;                                   2408000
         END;                                                                   02408500
         TARGET_REGISTER = -1;                                                  02409000
      END OFF_TARGET;                                                           02409500
                                                                                02410000
 /* ROUTINE TO POST INDEX POINTERS WHEN REQUIRED */                             02410500
CHECK_CSYM_INX:                                                                 02411000
      PROCEDURE(OP, R);                                                         02411500
         DECLARE (OP, R) BIT(16);                                               02412000
         IF NR_DEREF(OP) & R=BASE(OP) THEN RETURN; /*DR111400*/
         IF USAGE(R) > 3 THEN RETURN;                                           02412500
         IF SHIFT(TYPE(OP)) ^= 0 THEN IF SELF_ALIGNING THEN RETURN;             02413000
         IF INX(OP) < 0 THEN DO;                                                02413500
            CALL EMIT_BY_MODE(ADD, R, -INX(OP), TYPE(-INX(OP)));                02414000
            CALL DROP_INX(OP);                                                  02414500
            CALL UNRECOGNIZABLE(R);                                             02415000
         END;                                                                   02415500
      END CHECK_CSYM_INX;                                                       02416000
                                                                                02416500
 /* ROUTINE TO PROTECT INDEX PRIOR TO ARBITRARY ADJUSTMENTS */                  02417000
VERIFY_INX_USAGE:                                                               02417500
      PROCEDURE(OP);                                                            02418000
         DECLARE (OP, R) BIT(16);                                               02418500
         IF USAGE(INX(OP)) < 4 THEN                                             02419000
            CALL UNRECOGNIZABLE(INX(OP));                                       02419500
         ELSE DO;                                                               02420000
            R = FINDAC(INDEX_REG);                                              02420500
            CALL EMITRR(LR, R, INX(OP));                                        02421000
            CALL DROP_INX(OP);                                                   2421500
            INX(OP) = R;                                                        02422000
         END;                                                                   02422500
      END VERIFY_INX_USAGE;                                                     02423000
                                                                                02423500
 /*  ROUTINE TO ALIGN ABSOLUTE INDEX VALUES IF SELF ALIGNMENT PRESENT */        02424000
FIX_STRUCT_INX:                                                                 02424500
      PROCEDURE(IX, OP);                                                        02425000
         DECLARE (IX, OP, SHFT, R, TEMP) BIT(16);                               02425500
         SHFT = SHIFT(TYPE(OP));                                                02426000
/************ DR105054 RPC 5/25/93 ************************************/
/* CHECK IF ITEM IS A STRUCTURE. IF IT IS, USE THE STRUCTURE NODE'S   */
/* TYPE TO DETERMINE SHIFT AMOUNT. IF NODE IS NAME REMOTE, SHIFT      */
/* AMOUNT IS THE SHIFT AMOUNT OF 'RPOINTER'. IF THE NODE IS A 16-BIT  */
/* NAME POINTER, CHECK FOR THE NAME_FLAG AND SHIFT AMOUNT IS THE      */
/* SHIFT AMOUNT OF 'APOINTER'.  ELSE, TAKE THE SYT_TYPE OF THE        */
/* STRUCTURE NODE TO DETERMINE SHIFT AMOUNT.                          */
         /*********** DR107307 - TEV - 2/2/94 ****************************/
         /* SYMBOL MAY HAVE A BASE REGISTER ALREADY LOADED, SO CHECK FOR */
         /* FORM(OP) = CSYM ALSO (FORM IS SET TO CSYM AT THE TIME THE    */
         /* BASE REGISTER IS LOADED).                                    */
         IF (FORM(OP) = SYM) | (FORM(OP) = CSYM)
         /* MAY HAVE BEEN PUT ON STACK FOR RNR DEREF */  /* CR12432 */
            | (NR_DEREF(OP) & (FORM(OP) = NRTEMP)) THEN  /* CR12432 */
         /*********** END DR107307 ***************************************/
            IF SYT_TYPE(LOC(OP)) = STRUCTURE THEN DO;
               IF (SYT_FLAGS(LOC2(OP))&NAME_OR_REMOTE)=NAME_OR_REMOTE THEN
                  SHFT = SHIFT(RPOINTER);
               ELSE
                  IF (SYT_FLAGS(LOC2(OP))&NAME_FLAG)=NAME_FLAG THEN
                    SHFT = SHIFT(APOINTER);
                  ELSE DO;
              /* CHECK IF THE STRUCTURE NODE IS A BIT(16) OR SMALLER. */
              /* IF DENSE ATTRIBUTE IS PRESENT, BIT PACKING IS PERFO- */
              /* RMED ON THE BIT STRUCTURE NODES. CHECK IF SYT_TYPE   */
              /* SYMBOL TABLE VARIABLE VALUE IS SET TO FULLBIT (9)    */
              /* AND IF THE BOTTOM HALF OF THE SYT_DIMS SYMBOL TABLE  */
              /* VARIABLE VALUE IS <= 16 (WHICH INDICATES A BIT(16)   */
              /* OR LESS). IF BOTH CONDITIONS ARE TRUE, SET THE SHFT  */
              /* VARIABLE TO ZERO TO INDICATE THAT NO INDEX SHIFTING  */
              /* IS NECESSARY.                                        */
                     IF ((SYT_TYPE(LOC2(OP))=FULLBIT) &
                       ((SYT_DIMS(LOC2(OP)) & "00FF") <= 16)) THEN
                        SHFT = 0;
                     ELSE
                        SHFT = SHIFT(SYT_TYPE(LOC2(OP)));
                  END;
            END;
/************ END DR105054 RPC ****************************************/
         IF IX ^= 0 THEN                                                        02426500
            CALL CHECK_CSYM_INX(OP, REG(IX));                                    2427000
         IF INX(OP) ^= 0 THEN DO;                                               02427500
/* INDEX VALUE EXISTS, BUT CURRENTLY NOT LOADED IN A REGISTER, */
/* SO LOAD IT.                                                 */
            IF INX(OP) < 0 THEN IF (IX | SHFT) ^= 0 THEN DO;                    02428000
               R =  FINDAC(INDEX_REG);                                          02428500
               TEMP = -INX(OP);                                                 02429000
               CALL EMIT_BY_MODE(LOAD, R, TEMP, TYPE(TEMP));                    02429500
               CALL OFF_INX(INX(OP));                                           02430000
               INX(OP) = R;                                                     02430500
            END;                                                                02431000
            IF SELF_ALIGNING THEN                                               02431500
            /* DR109090 - NO SHIFT NECESSARY FOR 0 INDEX */
/*DR109090*/   IF ^((R_CONTENTS(INX(OP))=LIT) & (INX_CON(OP)=0)) THEN
               IF SHFT > 0 THEN IF STRUCT_INX(OP) >= 4 THEN DO;                  2432000
               CALL VERIFY_INX_USAGE(OP);                                       02432500
 /* PERFORM SHIFT RIGHT OF INDEX ACCORDING TO SHFT */
               CALL EMITP(SRA, INX(OP), 0, SHCOUNT, SHFT);                      02433000
            END;                                                                02433500
            IF IX ^= 0 THEN DO;                                                 02434000
               CALL VERIFY_INX_USAGE(OP);                                       02434500
               CALL EMITRR(AR, INX(OP), REG(IX));                                2435000
               CALL DROP_REG(IX);                                                2435500
            END;                                                                02436000
         END;                                                                   02436500
         ELSE IF IX ^= 0 THEN                                                    2437000
            INX(OP) = REG(IX);                                                   2437010
         ELSE RETURN;                                                           02437015
         INX_NEXT_USE(OP) = NEXT_USE(IX);                                        2437020
         CALL RETURN_STACK_ENTRY(IX);                                            2437030
         STRUCT_INX(OP) = 2;                                                     2437100
      END FIX_STRUCT_INX;                                                       02437500
                                                                                02438000
 /* ROUTINE TO LOAD A PREVIOUSLY CHECKPOINTED REGISTER VALUE  */                02438500
LOAD_TEMP:                                                                      02439000
      PROCEDURE(R, OP) BIT(16);                                                 02439500
         DECLARE (R, OP) BIT(16);                                               02440000
         CALL EMIT_BY_MODE(LOAD, R, OP, TYPE(OP));                              02440500
         USAGE(R) = DEL(OP);                                                    02441000
         CALL DROPSAVE(OP);                                                     02441500
         CALL RETURN_STACK_ENTRY(OP);                                           02442000
         RETURN USAGE(R);                                                       02442500
      END LOAD_TEMP;                                                            02443000
                                                                                 2443500
 /* ROUTINE TO RE-LOAD CHECKPOINTED ADDRESSING VALUES AND CHECK FOR              2444000
    FUTURE CONFLICTS */                                                          2444500
RELOAD_ADDRESSING:                                                               2445000
      PROCEDURE(R, OP, BASING, TR) BIT(16);                                     02445500
         DECLARE (R, OP, TR, I, J, TEMP) BIT(16), BASING BIT(1);                02446000
         IF BASING THEN TEMP = BASE(OP);                                         2446500
         ELSE TEMP = INX(OP);                                                    2447000
         IF R < 0 THEN DO;                                                      02447010
            DO R = PTRARG1 TO RM;                                               02447020
               IF USAGE(R) THEN                                                 02447030
                  IF R_CONTENTS(R) = WORK THEN                                  02447040
                  IF R_VAR(R) = LOC(-TEMP) THEN                                 02447050
                  IF R_CON(R) = 0 THEN DO;                                      02447055
                  CALL OFF_INX(TEMP);                                           02447060
                  IF R = TR THEN CALL CHECKPOINT_REG(R);                        02447070
                  IF BASING THEN BASE(OP), BACKUP_REG(OP) = R;                  02447080
                  ELSE INX(OP) = R;                                             02447090
                  CALL INCR_USAGE(R);                                           02447100
                  TR = 0;                                                       02447110
                  RETURN 0;                                                     02447120
               END;                                                             02447130
            END;                                                                02447140
            /*----------------------------------------------*/
            /* DR109016 - PASS LOADNAME IF NAME_VAR IS TRUE */
            /*----------------------------------------------*/
            IF BASING & NAME_VAR(OP) THEN R = GET_R(OP,LOADNAME);
            ELSE IF BASING THEN R = GET_R(OP,LOADBASE); /*#DREG*/               02447150
            ELSE DO;                                                            02447160
               J = TARGET_REGISTER;                                             02447170
               TARGET_REGISTER = -1;                                            02447180
               R = FINDAC(INDEX_REG);                                           02447190
               TARGET_REGISTER = J;                                             02447200
            END;                                                                02447210
         END;                                                                   02447220
         IF R=TR | (WORK_BLK(LOC(-TEMP)) < LAST_FLOW_BLK) | BASING |            02447500
        (WORK_BLK(LOC(-TEMP))=LAST_FLOW_BLK&WORK_CTR(LOC(-TEMP))<=LAST_FLOW_CTR)02447502
            THEN DO;                                                            02447504
            /*REMOVE BRANCH AROUND FOR ST THAT WAS INSERTED IN NR_CHECKPOINT*/
            IF NR_BASE(OP) > 0 & BASING THEN                        /*DR109095*/
               SAVED_LINE(LOC(OP)) = NO_BRANCH_AROUND(SAVED_LINE(LOC(OP)));/*"*/
 /* OTHER USERS MUST STILL ACCESS FROM MEMORY  */                                2448000

            CALL EMIT_BY_MODE(LOAD, R, -TEMP, TYPE(-TEMP));                      2448500
            CALL OFF_INX(TEMP);                                                  2449000
            USAGE(R) = 2;                                                       02449500
            IF BASING THEN BASE(OP), BACKUP_REG(OP) = R;                        02449600
            ELSE INX(OP) = R;                                                   02449700
            IF STACK_PTR(-TEMP) < 0 THEN                                        02449800
               CALL SET_USAGE(R, WORK, LOC(-TEMP));                             02449900
            J = 0;                                                               2451000
         END;                                                                    2451500
         ELSE DO;                                                                2452000
            J = LOAD_TEMP(R, -TEMP);                                             2452500
            DO I = 1 TO STACK_MAX;                                               2453000
               IF STACK_PTR(I) < 0 THEN DO;                                      2453500
                  IF FORM(I) ^= VAC THEN                                         2454000
                     IF INX(I) = TEMP THEN DO;                                   2454500
                     INX(I) = R;                                                 2455000
                     INX_NEXT_USE(I) = NEXT_USE(-TEMP);                          2455500
                     J = J - 2;                                                  2456000
                  END;                                                           2456500
               END;  /* STACK_PTR(I) < 0 */                                      2457000
            END;  /* DO I  */                                                    2457500
         END;                                                                    2458000
         TR = 0;                                                                02458100
         RETURN J;                                                               2458500
      END RELOAD_ADDRESSING;                                                     2459000
                                                                                02461000
 /* ROUTINE TO CHECK IF LOCAL ADDRESSING MODE CAN BE USED */                    02461500
CHECK_LOCAL_SYM:                                                                02462000
      PROCEDURE(INST, PTR) BIT(16);                                             02462500
         DECLARE (INST, PTR, SY) BIT(16);                                       02463000
         SY = LOC(PTR);                                                         02463500
         IF SYT_SCOPE(SY) < PROGPOINT THEN RETURN SYM;                          02464000
         IF SYT_BASE(SY) = TEMPBASE THEN RETURN SYM;                            02464500
         IF SYT_LINK2(SY) = 0 THEN RETURN SYM;                                  02465000
 /*----------------------------- #DREG -----------------------------*/
 /* IF BASE IS GOING TO BE R1, USE IT -- NOT R3.                    */
 /* THIS WAY R3 IS NOT OVERUSED, AND WE WILL AVOID CONFICTS.        */
         IF ^(DATA_REMOTE & (SYT_BASE(SY) = 1)) THEN
 /*-----------------------------------------------------------------*/
            IF CHECK_SRS(INST,INX(PTR),PROCBASE,SYT_LINK2(SY)+INX_CON(PTR))=    32160000
            SRSTYPE                                                             32170000
            THEN IF SYT_SCOPE(SY) = INDEXNEST & NOT_LEAF(INDEXNEST) = 3 THEN    02465110
            /* CHECK IF THE VARIABLE IS NOT A NAME VARIABLE BEFORE  */
            /* RETURNING IMD. IF IT IS A NAME, RETURN SYM INSTEAD.  */
            /* (WE DO NOT WANT TO DEREFERENCE THE NAME USING THE    */
            /* THE WRONG BASE REGISTER)                             */
            DO;                                                /* DR102964 */
               IF ((SYT_FLAGS(SY) & NAME_FLAG) ^= 0) THEN      /* DR102964 */
                  RETURN SYM;                                  /* DR102964 */
               ELSE RETURN IMD;                                /* DR102964 */   02465120
            END;                                               /* DR102964 */
            ELSE IF SYT_SCOPE(SY) = PROGPOINT THEN                              02465130
               IF INST >= "50" & INST < "80" THEN                               02465140
                  SRS_REFS(1) = SRS_REFS(1) + 1;                                02465150
               ELSE SRS_REFS = SRS_REFS + 1;                                    02465160
         RETURN SYM;                                                            02466500
      END CHECK_LOCAL_SYM;                                                      02467000
                                                                                02467500
 /* ROUTINE USED TO PUT REMOTE NAME REMOTE ON STACK  CR12432 */
 /* SO IT CAN BE DEREFERENCED FROM THERE.            CR12432 */
NR_PUT_ON_STACK:                                  /* CR12432 */
      PROCEDURE(PTR, R, LOCTWO);                  /* CR12432 */
         DECLARE (PTR, R, LOCTWO) BIT(16);        /* CR12432 */
               DECLARE SAVECON  BIT(16);          /* CR12432 */
               DECLARE SAVEINX  BIT(16);          /* CR12432 */
               DECLARE SAVESTINX  BIT(16);        /* CR12432 */
               DECLARE SAVELOC  BIT(16);          /* CR12432 */
               DECLARE SAVEREG  BIT(16);          /* CR12432 */
               DECLARE SAVETYPE BIT(16);          /* CR12432 */
               DECLARE SAVECOL  BIT(16);          /* CR12432 */
               SAVEINX = INX(PTR);                /* CR12432 */
               SAVESTINX = STRUCT_INX(PTR);       /* CR12432 */
               SAVEREG = REG(PTR);                /* CR12432 */
             /*LOC GETS CHANGED WHEN PUT ON STACK /* CR12432 */
               SAVELOC = LOC(PTR);                /* CR12432 */
               SAVECON = STRUCT_CON(PTR);         /* CR12432 */
               SAVETYPE = TYPE(PTR);              /* CR12432 */
               SAVECOL = COLUMN(PTR);             /* CR12432 */
               CALL RETURN_STACK_ENTRY(PTR);      /* CR12432 */
               PTR = GETFREESPACE(DINTEGER, 1);   /* CR12432 */
               CALL EMITOP(ST, R, PTR);           /* CR12432 */
               REG(PTR)= SAVEREG;                 /* CR12432 */
               INX(PTR) = SAVEINX;                /* CR12432 */
               STRUCT_INX(PTR) = SAVESTINX;       /* CR12432 */
               TYPE(PTR) = SAVETYPE;              /* CR12432 */
               STRUCT_CON(PTR) = SAVECON;         /* CR12432 */
               COLUMN(PTR) = SAVECOL;             /* CR12432 */
               LOC2(PTR) = LOCTWO;                /* CR12432 */
               NR_DEREF(PTR) = TRUE;              /* CR12432 */
            /* INDICATE RNR FOR NEXT S_D CALL     /* CR12432 */
               LIVES_REMOTE(PTR) = TRUE;          /* CR12432 */
            /* RELEASE ITS STACK LOCATION         /* CR12432 */
               USAGE(R) = 0;                      /* CR12432 */
               NR_STACK(PTR) = LOC(PTR);          /* CR12432 */
               LOC(PTR) = SAVELOC;                /* CR12432 */
      END NR_PUT_ON_STACK;                        /* CR12432 */
                                                                                02470450
 /* ROUTINE TO CHOOSE A BASE REGISTER IF R3 CAN BE USED */                      02470460
CHOOSE_BASE:                                                                    02470470
   PROCEDURE(OP,TYPE_LOAD,SPAREBASE) BIT(16);  /*#DREG-PASS IN OP & TYPE_LOAD*/ 02470480
      DECLARE (OP, SPAREBASE, R) BIT(16);    /*#DREG*/            /* CR13615 */
      DECLARE TYPE_LOAD BIT(8); /*#DREG*/
      IF TARGET_R >= 0 THEN RETURN GET_R(OP,TYPE_LOAD); /*#DREG*/               02470490
      IF SPAREBASE ^= R3 THEN RETURN GET_R(OP,TYPE_LOAD); /*#DREG*/             02470500
      IF USAGE(R3) <= 1 THEN TARGET_R = R3;                                     02470510
      ELSE IF USAGE(PTRARG1) <= 1 THEN TARGET_R = PTRARG1;                      02470520
      ELSE IF SHR(USAGE(PTRARG1),1)<SHR(USAGE(R3),1) THEN TARGET_R=PTRARG1;     02470530
      ELSE TARGET_R = R3;                                                       02470540
      R = GET_R(OP,TYPE_LOAD); /*#DREG*/                                        02470550
            TARGET_R = -1;                                                      02470560
            RETURN R;                                                           02470570
         END CHOOSE_BASE;                                                       02470580

/* LOAD A NAME VARIABLE OR A NAME NODE INTO A REGISTER            /* CR13615 */
LOAD_NAME : PROCEDURE(PTR, WALK_STRUCT, SPAREBASE, SAVEINX);
      DECLARE (PTR, R, SPAREBASE, SAVEINX) BIT(16);
      DECLARE (BASE_TEMP, BASE_CHECKPOINT) FIXED;                 /* DR109009 */
      DECLARE (WALK_STRUCT, SETUP_NAME) BIT(1);                   /* CR13615 */

      SETUP_NAME = FALSE;                                         /* CR13615 */
      R = PTRARG1;
      BASE_CHECKPOINT = BASE(PTR);                                /* DR109009 */
      IF ( ^(FORM(PTR)=CSYM & BASE(PTR)=R) | (USAGE(R)>3) )
         & WALK_STRUCT                                            /* CR13615 */
      THEN R = GET_R(PTR, LOADNAME); /*#DREG*/
      ELSE IF ^WALK_STRUCT THEN DO;                               /* CR13615 */
        IF FORM(PTR) = CSYM THEN DO;                                            02502000
           IF USAGE(BASE(PTR)) < 4 & BASE(PTR) <= SPAREBASE THEN DO;  /*#DREG*/ 02502500
              R = BASE(PTR);                                                    02503000
              /*----------------------- #DREG -------------------------*/
              /* RESTRICT R3 FROM BEING USED TO LOAD A NAME */
               IF DATA_REMOTE THEN R = REG_STAT(PTR,R,LOADNAME);
              /*-------------------------------------------------------*/
           END; /*#DREG*/
           ELSE DO;                                               /* DR111363 */
 /*#DREG*/    R = CHOOSE_BASE(PTR,LOADNAME,SPAREBASE);    /* CR13615,DR111363 */
              IF BASE(PTR) < 0 THEN BASE(PTR) = R;                /* DR111363 */
           END;                                                   /* DR111363 */
           USAGE(R) = 2;                                                        02504000
        END;                                                                    02504500
        ELSE DO;                                                                02505000
           R = PTRARG1 - 1;                                       /* CR13615 */
           DO UNTIL (R = SPAREBASE) | SETUP_NAME;                 /* CR13615 */ 02505500
              R = R + 1;                                          /* CR13615 */
              IF USAGE(R) THEN                                                  02506000
                 IF R_CONTENTS(R) = APOINTER THEN                                2506500
                   IF R_VAR(R) = LOC(PTR) THEN                                  02507000
                     SETUP_NAME = TRUE;                           /* CR13615 */ 02507500
           END;                                                                 02508000
           IF ^SETUP_NAME THEN DO;                                /* CR13615 */
             R = CHOOSE_BASE(PTR,LOADNAME,SPAREBASE); /*#DREG*/   /* CR13615 */ 02508010
             CALL SET_USAGE(R, APOINTER, LOC(PTR));                              2508500
           END;                                                   /* CR13615 */
        END;                                                                    02510000
      END;                                                        /* CR13615 */
      IF ^SETUP_NAME THEN DO;                                     /* CR13615 */
      /* NEED ZERO INDEX WHEN LOADING FROM REMOTE STRUCT             CR12432 */
      /* SO MUST USE EMITOP INSTEAD OF EMITXOP BELOW                 CR12432 */
        IF NR_DEREF(PTR) | WALK_STRUCT THEN DO;           /* CR13615,CR12432 */
           BASE_TEMP = BASE(PTR);                                 /* DR109009 */
           IF BASE(PTR) < 0 THEN BASE(PTR) = BASE_CHECKPOINT;     /* DR109009 */
           IF POINTS_REMOTE(PTR) THEN                             /* CR12432 */
              CALL EMITOP(L, R, PTR);                             /* CR12432 */
           ELSE CALL EMITOP(LH, R, PTR);                          /* CR12432 */
           BASE(PTR) = BASE_TEMP;                                 /* DR109009 */
           IF INX(PTR) > 0 THEN                                   /* CR12432 */
              CALL DROP_INX(PTR);                                 /* CR12432 */
           IF ^WALK_STRUCT THEN                                   /* CR13615 */
           /* GET ANY SAVED INDEX FOR FINAL LOAD                  /* CR12432 */
             INX(PTR) = SAVEINX;                                  /* CR12432 */
           ELSE DO;                                               /* CR13615 */
             INX_CON(PTR), STRUCT_CON(PTR) = 0;
             USAGE(R) = 2;
             STRUCT_WALK(PTR) = TRUE;                             /* DR109016 */
           END;                                                   /* CR13615 */
        END;                                                      /* CR12432 */
        ELSE DO;                                                  /* CR13615 */
 /**********  DR102954 BOB CHEREWATY  ******************/                       02510000
 /* DISCONTINUE USE OF NAMELOAD.  EMIT A FULLWORD LOAD */
 /* FOR REMOTE NAME VARIABLES OTHERWISE USE A          */
 /* HALFWORD LOAD                                      */
 /******************************************************/
          IF (POINTS_REMOTE(PTR) = TRUE) THEN                                   02501680
             CALL EMITXOP(L, R, PTR);          /* ZCON */                       02511000
          ELSE CALL EMITXOP(LH, R, PTR);       /* YCON */                       02511000
 /**********  DR102954 END  ****************************/                       02510000
        END;                                                      /* CR13615 */
      END;                                                        /* CR13615 */ 02511500
      BASE(PTR), BACKUP_REG(PTR) = R;                                           02512000
      DISP(PTR) = 0;                                                            02512500
  /* IF NAME DEREFERENCE LOADED INTO BASE, BASE CAN                  CR12432 */
  /* NO LONGER CONTAIN A VIRTUAL BASE VALUE.                         CR12432 */
      IF NR_DEREF(PTR) THEN R_VAR(R) = 0;                         /* CR12432 */
      IF ^WALK_STRUCT THEN CALL INCR_USAGE(R);                    /* CR13615 */
      /* IF WE'VE JUST LOADED A HALFWORD NAME                        CR12432 */
      /* THEN IT'S NO LONGER A NAME REMOTE DEREF                     CR12432 */
      ELSE IF ^POINTS_REMOTE(PTR) THEN                            /* CR12432 */
        NR_DEREF(PTR) = FALSE;                                    /* CR12432 */
      FORM(PTR) = CSYM;                                                         02513500
      /* REMOTE NAME REMOTE - PUT ON STACK                        /* CR12432 */
      IF NR_DEREF(PTR) &                                          /* CR12432 */
         ( (((SYT_FLAGS(LOC(PTR)) & INCLUDED_REMOTE) ^= 0)        /* CR12432 */
            & ^WALK_STRUCT) |                                     /* CR13615 */
           /* DO NOT CALL NR_PUT_ON_STACK WHEN NAME_FUNCTION         CR12432 */
           /* IS TRUE BECAUSE WHEN NO MORE DEREF IS NEEDED THEN      CR12432 */
           /* FORCE_ADDRESS WILL USE WHAT IS IN REG.                 CR12432 */
           (POINTS_REMOTE(PTR) & ^NAME_FUNCTION(PTR)) )    /*CR12432,DR111390*/
      THEN CALL NR_PUT_ON_STACK(PTR, R, LOC2(PTR));               /* CR12432 */
END LOAD_NAME;

 /**************************************************************************/
 /* PROCEDURE TO DETERMINE WHETHER A SYMBOLIC VARIABLE IS ADDRESSABLE      */   02468500
 /**************************************************************************/
 /*                                                               /*CR13616*/
 /* BY_NAME = TRUE (1)                                            /*CR13616*/
 /* ::= THE DESTINATION VARIABLE IN A NAME ASSIGNMENT, NAME       /*CR13616*/
 /*     INITIALIZATION, OR %NAMEADD/%NAMECOPY MACRO,              /*CR13616*/
 /* ::= A NAME ASSIGN PARAMETER IN A PROCEDURE CALL,              /*CR13616*/
 /* ::= A SUBSCRIPT IN A NAME PSEDUO-FUNCTION AND THE STATEMENT   /*CR13616*/
 /*     IS AN ASSIGNMENT-TYPE STATEMENT,                          /*CR13616*/
 /* ::= A NAME TEMPORARY DECLARATION,                             /*CR13616*/
 /* ::= AN EQUATE EXTERNAL INITIALIZATION, OR                     /*CR13616*/
 /* ::= FORCE_ADDRESS CALLS THE PROCEDURE TO PROCESS A NAME TASK  /*CR13616*/
 /*     OR NAME PROGRAM THAT SHOULD NOT BE DEREFERENCED.          /*CR13616*/
 /*                                                               /*CR13616*/
 /**************************************************************************/
GUARANTEE_ADDRESSABLE:                                                          02469000
      PROCEDURE(OP, INST, BY_NAME, NEED_SRS, TR);                               02469500
         DECLARE (OP,INST,TR,R,I,J,PLOC) BIT(16), (BY_NAME, NEED_SRS) BIT(1);   02470000
         DECLARE BASE_LOADED BIT(1), BASE_POSSIBLE BIT(16);                     02470002
         DECLARE (FIRSTBASE,SPAREBASE) BIT(16),OTHER_BASE_REFS BIT(16);         38241099
         DECLARE SAVEINX BIT(16);                                 /* CR12432 */
         DECLARE SKIP_LOAD BIT(1);                                /* CR13615 */
         DECLARE SETUP_INX LITERALLY                              /* CR13615 */
           'IF INX(OP) < 0 THEN DO; J=RELOAD_ADDRESSING(-1,OP,0,TR);  /* ""  */ 02516500
            IF J ^= 0 THEN CALL ERRORS(CLASS_BX,103); END';       /* CR13615 */ 02525500
/*#DREG ---- FIRSTBASE - WHICH REG TO START LOOKING IN FOR NEEDED BASE*/        38242099
                                                                                02470006
SRS_DESIRABLE:PROCEDURE(OP,NEED_SRS) BIT(1);                                     2470010
 /* THIS ROUTINE DETERMINES WHTER IT IS ADVANTAGEOUS                             2470020
    TO LOAD A BASE REG OR NOT FOR SRS INST  */                                   2470030
            DECLARE (OP,B_REG,CURRENT_BASE) BIT(16),                             2470040
               NEED_SRS BIT(1),                                                  2470050
               (I,LOOK_COUNT)          FIXED,                                    2470060
               LOADED_BASE             BIT(16),                                 02470065
               X                       BIT(16),                                  2470070
               HMAT_WD                 BIT(32);                                  2470080
            ARRAY NOSTOP(100)          BIT(1)                       /*CR13335*/  2470090
               INITIAL( 1,1,0,1,1,1,1,1,0,1,1,                                   2470100
               0,0,0,0,0,0,0,0,1,0,                                              2470110
               0,0,0,0,1,1,1,1,0,0,                                              2470120
               0,0,0,0,1,1,0,0,0,1,                                              2470130
               1,0,0,0,0,0,0,0,0,1,                                              2470140
               1,0,0,0,0,0,0,0,0,0,                                              2470150
               0,1,1,0,0,0,0,0,0,0,                                              2470160
               0,1,1,1,1,1,1,1,1,1,                                              2470170
               0,0,1,1,1,1,1,1,1,0,                                              2470180
               0,1,1,1,1,1,1,1,1);                                               2470190
         /* CANT USE ABSOLUTE ADDRESSING FOR NAME REMOTE DEREF   CR12432 */
            IF NR_DEREF(OP) THEN RETURN 1;                    /* CR12432 */
            X=LOC(OP);                                                           2470200
            CURRENT_BASE= SYT_BASE(X);                                           2470210
            IF INX(OP) ^=0 THEN  RETURN 1;                                       2470220
            IF CHECK_SRS(INST,0,CURRENT_BASE,SYT_DISP(X)+INX_CON(OP)) ^= SRSTYPE02470230
               THEN RETURN 0;                                                    2470240
            IF NEED_SRS = 1 THEN RETURN 1;                                      02470250
            IF NEED_SRS = 0 THEN DO;                                            02470252
               I = 0;                                                           02470254
               IF (INST&"0F") = "08" THEN DO;  /* LOAD */                       02470255
                  IF OP = LEFTOP THEN I = RIGHTOP;                              02470256
                  ELSE IF OP = RIGHTOP THEN I = LEFTOP;                         02470257
               END;                                                             02470258
               ELSE IF (INST&"0F") = "00" THEN   /* STORE */                    02470259
                  IF OP = LEFTOP THEN I = CONST(OP);                            02470260
               IF I > 0 THEN                                                    02470261
                  IF FORM(I) = SYM THEN IF SYT_BASE(LOC(I)) = CURRENT_BASE THEN 02470262
                IF CHECK_SRS(MAKE_INST(LOAD,TYPE(I),RX),INX(I),SYT_BASE(LOC(I)),02470264
                  SYT_DISP(LOC(I))+INX_CON(I)) = SRSTYPE THEN                   02470266
                  RETURN 1;                                                     02470268
               LOOK_COUNT = CTR+NUMOP;  /* INDEX TO NEXT HALMAT OPERATOR */     02470270
               IF SPAREBASE = R3 THEN                                           02470272
                  LOADED_BASE = R_VAR(BASE_POSSIBLE);                           02470274
               ELSE LOADED_BASE = 0;                                            02470276
               DO I = 1 TO 4;  /* MAX LOOK AHEAD IS 4 VALID OPERANDS */         02470278
RESTART:          LOOK_COUNT=LOOK_COUNT+1;                                       2470280
                  HMAT_WD=OPR(LOOK_COUNT);                                       2470290
                  IF ^HMAT_WD THEN    /* WE FOUND AN OPERATOR */                 2470300
                     IF (SHR(HMAT_WD,4)&"FFF") >= 100 THEN                       2470310
                     GO TO RESTART;                                              2470320
                  ELSE IF NOSTOP(SHR(HMAT_WD,4) & "0FFF") THEN                   2470330
                     GO TO RESTART;                                              2470340
                  ELSE RETURN 0;                                                 2470350
                  IF (SHR(HMAT_WD,4) & "0F") ^= 1 THEN                           2470360
                     GO TO RESTART;                                              2470370
                  IF OPMODE(SYT_TYPE(SHR(HMAT_WD,16))) = 4 THEN                 02470373
                     GO TO RESTART;                                             02470376
                  B_REG= SYT_BASE(SHR(HMAT_WD,16));                              2470380
                  IF B_REG< 0 THEN                                               2470390
                     IF B_REG=CURRENT_BASE THEN RETURN 1;                        2470400
                  ELSE IF B_REG = LOADED_BASE THEN DO;                          02470402
                     OTHER_BASE_REFS = OTHER_BASE_REFS + 1;                     02470404
                     GO TO RESTART;                                             02470406
                  END;                                                          02470408
                  ELSE RETURN 0;                                                 2470410
               END;                                                              2470420
            END;                                                                02470425
            RETURN 0;                                                            2470430
         END;                                                                    2470440

/* ROUTINE TO LOAD A NAME ASSIGN PARAMETER OR  A NON-REMOTE       /* CR13615 */
/* PASS-BY-REFERENCE PARAMETER.                                   /* CR13615 */
PARAMETER_BASE_LOAD : PROCEDURE(OP);
    DECLARE OP BIT(16);                                           /* CR13615 */
    DECLARE SETUP_R BIT(1);

    SETUP_R = FALSE;                                              /* CR13615 */
    R = PTRARG1 - 1;                                              /* CR13615 */
    DO UNTIL (R = SPAREBASE) | SETUP_R;                           /* CR13615 */ 02472500
       R = R + 1;                                                 /* CR13615 */
       IF USAGE(R) THEN                                                         02473000
         IF R_CONTENTS(R) = APOINTER THEN                                        2473500
           IF R_VAR(R) = PLOC THEN SETUP_R = TRUE;                /* CR13615 */ 02474000
    END;                                                                        02475500
    /* VALUE ALREADY FOUND IN A REG, SO DO NOT RELOAD IT          /* CR13615 */
    IF ^SETUP_R THEN DO;                                          /* CR13615 */
 /*----------------------- #DREG -------------------------*/
 /* REFERENCING FORMAL PARAMETER FROM STACK.              */
      R = CHOOSE_BASE(OP,LOADPARM,SPAREBASE);                     /* CR13615 */ 33360005
 /*-------------------------------------------------------*/
      CALL SET_USAGE(R, APOINTER, PLOC);                                         2476000
      CALL CHECK_ADDR_NEST(R, OP);                                              02477500
 /**********  DR102954  BOB CHEREWATY  *****************/
 /* DISCONTINUE USE OF NAMELOAD.  REPLACE WITH LH.     */
 /* BOTH ARE CONSTANTS FOR LOAD HALFWORD OPCODE.       */
 /******************************************************/
  /* LOAD NAME(ZCON) FORMAL REMOTE PARAMETER                      /* CR12935 */
  /* (IF NAME ASSIGN, ONLY DO LH OF BASE HERE)                    /* CR12935 */
      IF ((SYT_FLAGS(PLOC) & ASSIGN_OR_NAME)^=                    /* CR12935 */
         ASSIGN_OR_NAME) & POINTS_REMOTE(OP)                      /* CR12935 */
      THEN CALL EMITXOP(L, R, OP);                                /* CR12935 */
      ELSE CALL EMITXOP(LH, R, OP);                               /* CR12935 */
 /**********  DR102954  END  ***************************/
    END;                                                          /* CR13615 */ 02478500
    CALL INCR_USAGE(R);                                                          2479000
 /* TREAT REFERENCING A FORMAL REMOTE PARAMETER                      CR12935 */
 /* PASSED BY REFERENCE LIKE A NAME REMOTE DEREFERENCE               CR12935 */
 /* THIS IS REMOTE ASSIGN PARAMETER NAME TYPE.                       CR12935 */
    IF ((SYT_FLAGS(PLOC) & REMOTE_FLAG) ^= 0)                     /* CR12935 */
       & DEREF(OP) /* IF PARM IS NAME(), DONT DEREF */            /* CR12935 */
    THEN NR_DEREF(OP) = TRUE;                                     /* CR12935 */
    ELSE IF ^BY_NAME THEN                                         /* CR12935 */ 02479500
      IF (SYT_FLAGS(PLOC) & ASSIGN_OR_NAME) = ASSIGN_OR_NAME THEN DO;           02480000
        IF USAGE(R) > 3 THEN R = GET_R(OP,LOADBASE); /*#DREG*/                  02480500
 /**********  DR102954  BOB CHEREWATY  *****************/
 /* DISCONTINUE USE OF NAMELOAD.  REPLACE WITH LH.     */
 /* BOTH ARE CONSTANTS FOR LOAD HALFWORD OPCODE.       */
 /******************************************************/
     /* LOAD NAME(ZCON) FORMAL NAME ASSIGN REMOTE PARM            /* CR12935 */
        IF POINTS_REMOTE(OP) THEN                                 /* CR12935 */
          CALL EMITRX(L, R, 0, R, 0);                             /* CR12935 */
        ELSE CALL EMITRX(LH, R, 0, R, 0);                         /* CR12935 */
 /**********  DR102954  END  ***************************/
        USAGE(R) = 2;                                                           02483000
    END;                                                                        02483500
    BASE(OP), BACKUP_REG(OP) = R;                                               02484000
    DISP(OP) = INX_CON(OP);                                                     02484500
    CALL CHECK_CSYM_INX(OP, R);                                                 02485000
    IF ^POINTS_REMOTE(OP) THEN                         /* DR111377, DR111331 */
      INX_CON(OP) = 0;                                                          02485500
    FORM(OP) = CSYM;                                                            02486000
END PARAMETER_BASE_LOAD;
                                                                                02470590
/* ROUTINE TO LOAD A VIRTUAL BASE REGISTER.                       /* CR13615 */
/* RETURNS CSYM IF A VIRTUAL BASE REGISTER WILL BE USED.          /* CR13615 */
/* RETURNS INL IF AN ABSOLUTE ADDRESS SHOULD BE USED.             /* CR13615 */
VIRTUAL_BASE_LOAD : PROCEDURE(OP) BIT(8);
    DECLARE OP BIT(16);

    /* NR DEREF OF COMPOOL VAR CANNOT USE R3 AS BASE */
    IF NR_DEREF(OP) & BASE_LOADED & R=3 THEN DO;                  /* CR12432 */
       BASE_LOADED = 0;                                           /* CR12432 */
       TARGET_R = 2;                                              /* CR12432 */
    END;                                                          /* CR12432 */
    IF SRS_DESIRABLE(OP, NEED_SRS | BASE_LOADED) THEN DO;                       02492000
       J = 0;                                                                   02492100
       IF BASE_LOADED THEN DO;                                    /* DR111382 */
         IF R = 1 THEN                                  /* DR111338, DR111382 */
            R1_USED = FALSE;                            /* DR111338, DR111382 */
         ELSE IF R = 3 THEN                             /* DR111338, DR111382 */
            R3_USED = FALSE;                            /* DR111338, DR111382 */
       END;                                                       /* DR111382 */
       IF ^BASE_LOADED THEN DO;                                   /* CR13615 */ 02492500
/*--------------------------- #DREG -------------------------------*/           39961099
/* #D VARIABLE'S BASE REGISTER IS VIRTUAL, FORCE IT TO USE R1/R3.  */           39962099
/* (MUST USE R1 IF IT IS AN RS INSTRUCTION, OTHERWISE USE R3)      */           39963099
         IF DATA_REMOTE & (CSECT_TYPE(PLOC,OP)=LOCAL#D) & (SYT_BASE(PLOC)<0)    39964099
         THEN DO;                                                               39965099
            IF CHECK_SRS(INST, INX(OP), 3, INX_CON(OP)) ^= SRSTYPE THEN DO;     39967099
               TARGET_R = 1;                                                    39969099
               D_R1_CHANGE = SHL(D_R1_CHANGE,1) | TRUE;                         34030010
            END;                                                                39969299
            ELSE DO;                                                            39969399
               TARGET_R = 3;                                                    39969499
               D_R3_CHANGE = SHL(D_R3_CHANGE,1) | TRUE;                         34070010
            END;                                                                39969699
         END;                                                                   39969899
/*-----------------------------------------------------------------*/           39969999
         IF BASE_POSSIBLE > 0 THEN IF INX(OP) ^= 0 THEN                         02493010
           IF R_SECTION(-R_VAR(BASE_POSSIBLE))=R_SECTION(-SYT_BASE(PLOC))       02493020
           THEN DO;                                                             02493030
             I = R_BASE(-SYT_BASE(PLOC)) - R_BASE(-R_VAR(BASE_POSSIBLE));       02493040
             IF I >= 0 THEN                                                     02493050
               IF SYT_DISP(PLOC)+INX_CON(OP)+I < 2048 THEN DO;                  02493060
                 J = I;                                                         02493070
                 R = BASE_POSSIBLE;                                             02493080
                 BASE_LOADED = TRUE;                              /* CR13615 */ 02493090
               END;                                                             02493100
         END;                                                                   02493110
         IF ^BASE_LOADED THEN DO;                                 /* CR13615 */
            IF SPAREBASE = R3 & TARGET_R < 0 THEN DO;                           02493500
               IF USAGE(PTRARG1) = 0 THEN R = PTRARG1;                          02493510
               ELSE IF USAGE(PTRARG1) = 1 THEN DO;                              02493520
                  IF USAGE(R3) <= 1 THEN DO;                                    02493530
                    IF BASE_POSSIBLE=R3 & OTHER_BASE_REFS>0 THEN R = PTRARG1;   02493540
                    ELSE R = R3;                                                02493550
                  END;                                                          02493560
                  ELSE R = PTRARG1;                                             02493570
               END;                                                             02493580
               ELSE IF USAGE(R3) <= 1 THEN R = R3;                              02493590
               ELSE RETURN INL;                                   /* CR13615 */ 02493600
               TARGET_R = R;                                                    02493610
            END;                                                                02493640
            R = GET_R(OP,LOADBASE); /*#DREG*/                     /* CR13615 */ 02493650
            TARGET_R = -1; /* DR109015 */                                       02493650
            CALL SET_USAGE(R, XPT, SYT_BASE(PLOC));                              2494000
            I = -SYT_BASE(PLOC);                                                02495500
/?P  /* SSCR 8348 -- BASE REG ALLOCATION (ADCON)  */
            R_BASE_USED(I) = R_BASE_USED(I) + 1;                                02496000
?/
/?B  /* SSCR 8348 -- BASE REG ALLOCATION (ADCON)  */
            R_BASE_USED(I) = TRUE;
?/
 /**********  DR102954  BOB CHEREWATY  *****************/
 /* DISCONTINUE USE OF NAMELOAD.  REPLACE WITH LH.     */
 /* BOTH ARE CONSTANTS FOR LOAD HALFWORD OPCODE.       */
 /******************************************************/
            CALL EMITP(LH, R, 0, XPT, I);                                       02496500
 /**********  DR102954  END  ***************************/
/*---------------------------- #DREG --------------------------------*/
/* IF LOADING VIRTUAL R1/R3, THEN MUST CLEAR MSB.                    */
            IF DATA_REMOTE & ((R=1) | (R=3)) THEN
               CALL EMITP(NHI,R,0,0,"7FFF");
/*-------------------------------------------------------------------*/
         END;                                                     /* CR13615 */
       END;                                                       /* CR13615 */
       /* INDICATE BASE WAS JUST LOADED ABOVE                      - CR12432 */
       BASE_LOADED=TRUE;                                          /* CR12432 */
       BASE(OP), BACKUP_REG(OP) = R;                                            02497500
       DISP(OP) = SYT_DISP(PLOC) + J;                                           02498000
       CALL INCR_USAGE(R);                                                       2498500
       RETURN CSYM;                                               /* CR13615 */ 02499000
    END;                                                                        02499500
    ELSE                                                                        02500000
       RETURN INL;                                                /* CR13615 */ 02500020
END VIRTUAL_BASE_LOAD;

         SKIP_LOAD = FALSE;                                       /* CR13615 */
         IF FORM(OP) = SYM THEN DO;                                             02471000
            IF SHR(NOT_LEAF(INDEXNEST),1) THEN SPAREBASE = PTRARG1;             02471010
            ELSE IF NEED_SRS = 2 THEN SPAREBASE = PTRARG1;                      02471015
            ELSE IF CHECK_SRS(INST, INX(OP), R3, INX_CON(OP)) ^= SRSTYPE THEN   02471020
               SPAREBASE = PTRARG1;                                             02471030
            ELSE SPAREBASE = R3;                                                02471040
            PLOC = LOC(OP);                                                     02471500
            /* TREAT REFERENCING A FORMAL REMOTE PARAMETER           CR12935 */
            /* PASSED BY REFERENCE LIKE A NAME REMOTE DEREFERENCE.   CR12935 */
            /* ASSIGN PARAMETER THAT IS NAME TYPE IS HANDLED WITHIN  CR12935 */
            /* THE PARAMETER SECTION, BECAUSE IT NEEDS A BASE LOAD.  CR12935 */
            IF ((SYT_FLAGS(PLOC) & POINTER_FLAG) ^= 0) &          /* CR12935 */
               ((SYT_FLAGS(PLOC) & REMOTE_FLAG) ^= 0) &           /* CR12935 */
               ((SYT_FLAGS(PLOC) & ASSIGN_OR_NAME)^=ASSIGN_OR_NAME) /*  ""   */
                  & DEREF(OP) /* IF PARM IS NAME(), DONT DEREF    /* CR12935 */
            THEN DO;                                              /* DR111360 */
               CALL CHECK_ADDR_NEST(-1,OP);                       /* DR111360 */
               NR_DEREF(OP) = TRUE;                               /* CR12935 */
            END;                                                  /* DR111360 */
            /* THIS CORRECTS %MACRO PROBLEMS OF LOADING BASE EARLY. */          02471500
            ELSE IF (SYT_FLAGS(PLOC) & POINTER_FLAG) ^= 0 THEN    /* CR12935 */ 02472000
               CALL PARAMETER_BASE_LOAD(OP);                      /* CR13615 */
            ELSE DO;                                                            02487000
               FORM(OP) = CHECK_LOCAL_SYM(INST, OP);                            02487500
               IF SYT_BASE(PLOC) = TEMPBASE THEN                                02488000
                  CALL CHECK_ADDR_NEST(-1, OP);                                 02488500
               ELSE IF SYT_BASE(PLOC) < 0 & FORM(OP) = SYM THEN DO;             02489000
                  OTHER_BASE_REFS, BASE_LOADED, BASE_POSSIBLE = FALSE;          02489600
/*--------------------------- #DREG -------------------------------*/           39811099
/* SEE IF BASE NEEDED IS IN R1/R3 FOR #D VIRTUAL BASE REGISTERS.   */           39812099
                  FIRSTBASE = PTRARG1;                                          39813099
                  IF DATA_REMOTE & D_R1_CHANGE                                  39814099
                     THEN FIRSTBASE = 1;                                        39815099
                  IF DATA_REMOTE & D_R3_CHANGE &                                39816099
                  (CHECK_SRS(INST, INX(OP), 3, INX_CON(OP)) = SRSTYPE)          39817099
                     THEN SPAREBASE = 3;                                        39818099
/*-----------------------------------------------------------------*/           39819099
                  R = FIRSTBASE - 1;                              /* CR13615 */
                  DO UNTIL (R = SPAREBASE) | BASE_LOADED;         /* CR13615 */ 39819199
                     R = R + 1;                                   /* CR13615 */
                     IF USAGE(R) THEN                                           02490000
                      IF R_CONTENTS(R) = XPT THEN                               02490500
                       IF R_VAR(R) = SYT_BASE(PLOC) THEN DO;                    02491000
                          BASE_LOADED = TRUE;                                   02491510
                     END;                                                       02491530
                     ELSE BASE_POSSIBLE = R;                                    02491540
                  END;                                                          02491550
                  FORM(OP) = VIRTUAL_BASE_LOAD(OP);               /* CR13615 */ 02491560
               END;                                                             02500500
               IF ^BY_NAME THEN                                                 02501000
                  IF (SYT_FLAGS(PLOC) & NAME_FLAG) ^= 0 THEN DO;                02501500
               /* REMOVED BX114 ERROR                             /* CR12432 */
                    IF ((SYT_FLAGS(PLOC) & REMOTE_FLAG) ^= 0) & DEREF(OP) /*"*/
                    THEN DO;                                      /* CR12432 */
                       NR_DEREF(OP) = TRUE;                       /* CR12432 */
                  /* CANNOT DO ABSOLUTE ADDRESS FOR COMPOOL -     /* CR12432 */
                  /* & CANNOT USE R3 (MEANS NO BASE FOR RSTYPE)   /* CR12432 */
                  /* MUST LOAD BASE R2                            /* CR12432 */
                       IF (FORM(OP)=INL) | ((BASE_LOADED & (R=3)) /* CR12432 */
    /*DR111398*/          & CHECK_SRS(INST,INX(OP),3,INX_CON(OP))^=SRSTYPE)
                       THEN FORM(OP) = VIRTUAL_BASE_LOAD(OP);     /* CR13615 */
                       /* IF A DIFFERENT BASE REGISTER WAS NOT    /* CR13615 */
                       /* LOADED THEN END COMPILATION BECAUSE AN  /* CR13615 */
                       /* INTERNAL ERROR EXISTS WHICH WILL NOT    /* CR13615 */
                       /* ALLOW THE COMPILER TO FIND A VALID REG. /* CR13615 */
                       IF (FORM(OP)=INL) | ((BASE_LOADED & (R=3)) /* CR13615 */
    /*DR111398*/          & CHECK_SRS(INST,INX(OP),3,INX_CON(OP))^=SRSTYPE)
                       THEN CALL ERRORS(CLASS_BI,518);            /* CR13615 */
                  /* DONT SKIP LOAD IF REMOTE NAME REMOTE         /* CR12432 */
                       IF (FORM(OP) ^= NRTEMP)                    /* CR12432 */
                          & (SYT_FLAGS(PLOC) & INCLUDED_REMOTE) = 0 /*  ""   */
                       THEN DO;                                   /* CR12432 */
                          /* INDICATE RNR FOR NEXT S_D CALL       /* CR12432 */
                          LIVES_REMOTE(OP)=TRUE;                  /* CR12432 */
                          SKIP_LOAD = TRUE;                       /* CR13615 */
                       END;                                       /* CR12432 */
 /* IF REMOTE NAME REMOTE, INDEX OR OFFSET IS NOT FOR RNR LOAD;   /* CR12432 */
 /* IT IS FOR FINAL LOAD, SO SAVE IT UNTIL THEN.                  /* CR12432 */
                       ELSE DO;                                   /* CR13615 */
                          SAVEINX = INX(OP);                      /* CR12432 */
                          INX(OP) = 0;                            /* CR12432 */
                       END;                                       /* CR13615 */
                    END;                                          /* CR12432 */
 /* CR13615 */      IF ^SKIP_LOAD THEN
 /* CR13615 */          CALL LOAD_NAME(OP, FALSE, SPAREBASE, SAVEINX);
               END;                                                             02514000
            END;                                                                02514500
            SETUP_INX;                                            /* CR13615 */ 02515000
         END;                                                                   02527000
         ELSE IF FORM(OP) = CSYM THEN DO;                                       02527500
            IF BASE(OP) < 0 THEN DO;                                            02528000
               /*------------------DR109016------------------*/
               /* #D VARIABLE'S BASE REGISTER IS VIRTUAL,    */
               /* FORCE IT TO USE R1/R3. (MUST USE R1 IF     */
               /* IT IS AN RS INSTRUCTION, OTHERWISE USE R3) */
               /* IF WE HAVE WALKED THROUGH A STRUCTURE NODE */
               /* DERERENCE, IT MUST BE A COMPOOL TYPE.      */
               /*--------------------------------------------*/
 /*DR109055 - THE CHECK FOR STRUCT_WALK ALREADY TOOK PLACE IN */
 /*DR109055 - CSECT_TYPE SO IT WAS REMOVED FROM HERE.         */
 /*DR109055*/  IF DATA_REMOTE & (CSECT_TYPE(LOC(OP),OP)=LOCAL#D) THEN DO;
                  IF CHECK_SRS(INST,INX(OP),3,INX_CON(OP)) ^= SRSTYPE THEN DO;
                     TARGET_R = 1;
                     D_R1_CHANGE = SHL(D_R1_CHANGE,1) | TRUE;
                  END;
                  ELSE DO;
                     TARGET_R = 3;
                     D_R3_CHANGE = SHL(D_R3_CHANGE,1) | TRUE;
                  END;
               END;
               J = RELOAD_ADDRESSING(-1, OP, 1, TR);                            02528500
               IF (NR_BASE(OP) > 0)&(STACK_PTR(NR_BASE(OP))>-1) THEN/*DR109095*/
                  NR_BASE(OP) = GETFREESPACE(DINTEGER,1);           /*DR109095*/
               IF DATA_REMOTE THEN TARGET_R=-1;                     /*DR109016*/
               IF J ^= 0 THEN                                                    2529010
                  CALL ERRORS(CLASS_BX,104);                                     2529020
            END;                                                                02532500
            SETUP_INX;                                            /* CR13615 */ 02533000
         END;                                                                   02533500
         ELSE IF FORM(OP) = WORK THEN SETUP_INX;                  /* CR13615 */ 02534000
         TR = 0;                                                                02534100
         BY_NAME, NEED_SRS = FALSE;                                             02534500
         BASE_LOADED = FALSE;                                     /* CR12432 */
      END GUARANTEE_ADDRESSABLE;                                                02535000
                                                                                02535110
 /* ROUTINE TO GENERATE CALLS TO THE HAL ERROR MONITOR */                       02535120
ERRCALL:PROCEDURE(ERR#,MSG);                                                    02535130
         DECLARE (ERR# , I) BIT(16) , MSG CHARACTER;                            02535140
         DECLARE ERRMAX LITERALLY '20' , MAXERR# BIT(16) INITIAL(-1),           02535150
            ERRNUM(ERRMAX) BIT(16),                                             02535160
            ERRCON(ERRMAX) BIT(16);                                             02535170
         IF CALL#(PROGPOINT) = 2 THEN RETURN;  /* COMPOOL */                    02535180
 /?P     /* CR11114 -- BFS/PASS INTERFACE; CHANGES ERROR SVC EMITTED */
         VAL(0) = SHL(20 , 16) + SHL(4 , 8) + ERR#;                             02535190
         INX(0), INX_CON(0) = 0;                                                02535200
         CALL SAVE_LITERAL(0,DINTEGER);                                         02535210
         CALL EMITOP(SVC, 0, 0);                                                02535230
 ?/
 /?B     /* CR11114 -- BFS/PASS INTERFACE; CHANGES ERROR SVC EMITTED */
         CALL EMITRX(SVC, 0, 0, 3, -1);
 ?/
      END ERRCALL;                                                              02535240
                                                                                02535500
 /*--------------- #DNAME DR103750 ---------------*/                            41450000
 /* CONVERT THE YCON IN REGISTER R TO ZCON FORMAT */                            41460000
YCON_TO_ZCON:                                                                   41470000
      PROCEDURE(R, OP);                                                         41480000
         DECLARE (R, OP, C_TYPE) BIT(16);                                       41490000
         DECLARE NO_INDEX BIT(1);                                               41500000
         C_TYPE = CSECT_TYPE(LOC(OP),OP);                                       41361099
        /* #DPARM- STACK CSECT IS NOT CREATED AT COMPILE TIME, */               41362099
        /* SO CANNOT PUT ITS CSECT INTO ZCON. BUT IT'S OK TO   */               41363099
        /* USE OLD METHOD HERE, BECAUSE ONLY RTLS WILL USE THE */               41364099
        /* NEWLY CREATED STACK ZCON (SINCE IT'S ILLEGAL FOR    */               41365099
        /* NAME VARIABLES TO POINT TO THE STACK).              */               41366099
        /* CR13538- THIS ONLY WORKS FOR RTL SETUPS-OTHERWISE USE SHIFT METHOD*/
         IF ((C_TYPE = STACKVAL) | (C_TYPE = STACKADDR)) &                      41368099
         (D_RTL_SETUP = 1) THEN DO;                                 /*CR13538*/ 41368099
            CALL EMITP(IAL,R,0,0,"0400"); /*- OLD METHOD   */                   41369199
            RETURN;                                                             41369299
         END;                                                                   41369399
         /*DR106968- DO NOT USE SINGLE_VALUED TO SET NO_INDEX*/
         /*FIGURE OUT HOW TO SET XC BIT OF ZCON ACCORDING TO TYPE*/
         IF (FORM(OP) = LIT)|(FORM(OP)>7) THEN /*LITERAL IN REMOTE #D*/
              NO_INDEX = PACKTYPE(TYPE(OP));
         ELSE NO_INDEX = PACKTYPE(SYT_TYPE(LOC(OP)))
                         & (SYT_ARRAY(LOC(OP))=0);
         /* DR106968- ONLY EMIT RLD CARD IF SOURCE IS NOT A NAME */
         /* DEREFERENCE                                          */
         /* CR13538-CSECT IS UNKNOWN FOR STACK SO USE SHIFT METHOD INSTEAD*/
         IF ^NAME_VAR(OP)      /*DR109006*/
            &(C_TYPE ^= STACKVAL)&(C_TYPE ^= STACKADDR) THEN DO; /*CR13538*/
 /?P     /*CR13538-PILOT USES MSB OF 0 FOR DATA IN SECTOR 0 SO SKIP THIS.  */
            CALL EMITP(OHI,R,0,0,"8000"); /* SET MSB */
 ?/
            /* PUT CSECT NUMBER IN LOWER HALF OF REGISTER USING RLD */          35650005
            IF (C_TYPE = COMPOOL#P) THEN /* COMPOOL DATA */                     35660005
               CALL EMITC(RLD, "4000" + DATABASE(SYT_SCOPE(LOC(OP))));          35670005
            ELSE           /* LOCAL DATA OR LITERAL (#D) */                     35680005
               CALL EMITC(RLD, "4000" + DATABASE);                              35690005
            IF NO_INDEX /*SET THE XC (INDEX INHIBIT) BIT IF ^AGGREGATE*/        35760005
               THEN CALL EMITP(IAL, R, 0, 0, "0800");                           35770005
               ELSE CALL EMITP(IAL, R, 0, 0, 0);                                35780005
         END;
         ELSE DO; /*DR106968 USE SHIFT INSTRUCTIONS TO PLACE SECTOR   */
                  /* NUMBER INTO THE DSV OF THE ZCON.                 */
                  /* SECTOR NUMBER MUST BE EITHER 0 OR 1.             */
                  /* THIS IS TRUE ONLY BECAUSE YOU CANNOT DEREFERENCE */
                  /* MIGRATED #D DATA THROUGH A 32 BIT NAME VARIABLE. */
            IF NO_INDEX /*SET THE XC (INDEX INHIBIT) BIT IF ^AGGREGATE*/        35760005
               THEN CALL EMITP(IAL, R, 0, 0, "0800");                           35770005
            CALL EMITP(SRA, R, 0, SHCOUNT, 1);
            CALL EMITP(SRR, R, 0, SHCOUNT, 31);
 /?P     /*CR13538-PILOT USES MSB OF 0 FOR DATA IN SECTOR 0 SO SKIP THIS.  */
            CALL EMITP(OHI,R,0,0,"8000"); /*SET MSB-MOVED THIS TO LAST*/
 ?/
         END;
      END YCON_TO_ZCON;                                                         41690000
 /*-----------------------------------------------*/                            41700000
 /*----------------------------------------------------------------*/
 /* PROCEDURE: AIA_SHIFT_AMOUNT                                    */
 /*                                                                */
 /* FUNCTION: RETURNS THE AMOUNT OF SHIFTING REQUIRED TO ADJUST    */
 /*           A VALUE LOADED IN AN INDEX REGISTER FOR AUTOMATIC    */
 /*           INDEX ALIGNMENT.                                     */
 /*                                                                */
 /* INPUT:  OP - INDIRECT STACK ENTRY FOR THE VALUE BEING INDEXED  */
 /* OUTPUT: THE NUMBER OF BITS NEEDED TO BE SHIFTED                */
 /*                                                                */
 /* DR HISTORY: THIS ROUTINE WAS ADDED IN 27V0/11V0 WITH THE FIX   */
 /*             TO DR109019.  IT WAS EXTRACTED FROM THE PROCEDURE, */
 /*             "SUBSCRIPT_RANGE_CHECK" IN ORDER TO MAKE THE       */
 /*             ROUTINE MORE MODULAR AND EASY TO READ.             */
 /*             THERE ARE SEVERAL DRS ASSOCIATED WITH AIA IN THOSE */
 /*             ROUTINES. THE FOLLOWING IS A LIST OF THOSE DR'S    */
 /*                                                                */
 /* DR103753 (23V1)      - FIRST ATTEMPT IN FIXING SLL PROBLEM.    */
 /*                        INVOLVED CHANGING THE BIGHTS ARRAY      */
 /*                        AND ADDING LOGIC TO HANDLE LOADING A    */
 /*                        NAME VARIABLE                           */
 /* DR103753 (9V0)       - MADE DR103753 COMMON BFS CODE           */
 /* DR108535 (25V0/9V0)  - RESTORED BIGHTS ARRAY TO ORGINAL VALUES */
 /*                        (PRE DR103753) AND USED SHIFT ARRAY TO  */
 /*                        GET SHIFT AMOUNT.                       */
 /* DR104835 (25V0/9V0)  - FIXED SPECIAL CASE OF %NAMEADDS         */
 /* DR109019 (27V0/11V0) - FIXED CSYM CASE OF NAME STRUCTURE NODES */
 /*                                                                */
 /* NOTE: CR13339 MOVED THIS ROUTINE BEFORE FORCE_ADDRESS          */
 /*----------------------------------------------------------------*/
 AIA_SHIFT_AMOUNT:
    PROCEDURE(OP) BIT(16);
    DECLARE (OP,SHIFT_AMOUNT) BIT(16);

      SHIFT_AMOUNT = SHIFT(TYPE(OP));                                           02844500

      /*--- DR103753 - DANNY ---------------------------------------*/           2571000
      /* FIX SLL PROBLEM: INDEX OF NAME VARIABLES INCORRECTLY SET UP*/           2571000
      /*------------------------------------------------------------*/           2571000
      IF (TYPE(OP)=APOINTER) | (TYPE(OP)=RPOINTER)                              02844000
         THEN SHIFT_AMOUNT = SHIFT(SYT_TYPE(LOC2(OP)));                         02844000

      /*-- DR103753 - PART 2 / DR109019 ----------------------*/
      /* NAME VARIABLE MAY BE STRUCTURE NODE, SO SET RANGE    */
      /* ACCORDINGLY.LOOKING AT TYPE(OP) IN THIS SITUATION IS */
      /* UNRELIABLE. INSTEAD USE NAME VARIABLE TYPE (APOINTER */
      /* OR RPOINTER).                                        */
      /*------------------------------------------------------*/
      IF (SYMFORM(FORM(OP)) | (NR_DEREF(OP) & (FORM(OP)=NRTEMP))) /* CR12432 */
         & ^SIMPLE_AIA_ADJUST THEN DO;
         IF (SYT_TYPE(LOC(OP))=STRUCTURE) THEN DO;
            IF ((SYT_FLAGS(LOC2(OP)) & NAME_OR_REMOTE)=NAME_OR_REMOTE)
               THEN SHIFT_AMOUNT = SHIFT(RPOINTER);
            IF ((SYT_FLAGS(LOC2(OP)) & NAME_OR_REMOTE)=NAME_FLAG)
               THEN SHIFT_AMOUNT = SHIFT(APOINTER);
         END;
      END;

      /************  DR104835  LJK  05/12/93  ************************/
      /* FOR %NAMEADD WITH 3RD ARGUMENT A LITERAL, SET SHIFT_AMOUNT  */
      /* TO 0 TO INDICATE NO SHIFT  IS NEEDED FOR THE LITERAL COUNT. */
      /***********  END DR104835   ***********************************/
      IF HALMAT_OPCODE= "5B" & TAG= 6 & FORM(RIGHTOP)= LIT /*CR13570*/
         THEN SHIFT_AMOUNT = 0;

      IF HALMAT_OPCODE= "5B" & TAG= 4 & NR_DEREF(OP) &    /*DR111308,CR13570*/
                         STRUCT_INX(OP) ^= 2 THEN         /*DR111308*/
         SHIFT_AMOUNT = 0;                                /*DR111308*/
      RETURN SHIFT_AMOUNT;
END AIA_SHIFT_AMOUNT;

 /* ROUTINE TO DETERMINE IF STRUCTURE OPERAND IS MAJOR STRUCTURE  */            02630000
 /* INPUT PARAMETER (OP) IS AN INDIRECT STACK ENTRY NUMBER */
 /*DR111377 - MOVED THIS ROUTINE FROM BEFORE LUMP_ARRAYSIZE*/
MAJOR_STRUCTURE:                                                                02630500
      PROCEDURE(OP) BIT(1);                                                     02631000
         DECLARE OP BIT(16);                                                    02631500
         IF TYPE(OP) = STRUCTURE THEN                                           02632000
            IF SYT_DIMS(LOC(OP)) = LOC2(OP) THEN RETURN TRUE;                   02632500
         RETURN FALSE;                                                          02633000
      END MAJOR_STRUCTURE;                                                      02633500
                                                                                41710000
 /*****************************************************************/
 /*ROUTINE TO FORCE AN ADDRESS POINTER INTO A REGISTER            */            02536000
 /*****************************************************************/
 /*                                                                /*CR13616*/
 /* BY_NAME = TRUE (1)                                             /*CR13616*/
 /* ::= NAME ASSIGN ARGUMENT IN A PROCEDURE CALL.                  /*CR13616*/
 /*                                                                /*CR13616*/
 /* FOR_NAME = TRUE (1)                                            /*CR13616*/
 /* ::= A NAME PASS-BY-REFERENCE ARGUMENT,                         /*CR13616*/
 /* ::= EITHER SIDE OF A NAME COMPARISON,                          /*CR13616*/
 /* ::= THE SOURCE VARIABLE IN A NAME ASSIGNMENT, AUTOMATIC NAME   /*CR13616*/
 /*     INITIALIZATION, OR A %NAMECOPY/%NAMEADD MACRO, OR          /*CR13616*/
 /* ::= PROCESSING OPERANDS IN REAL-TIME STATEMENTS.               /*CR13616*/
 /*                                                                /*CR13616*/
 /*****************************************************************/
FORCE_ADDRESS:                                                                  02536500
      PROCEDURE(TR, OP, FLAG, FOR_NAME, BY_NAME);                               02537000
         DECLARE (TR, OP, R, TEMP) BIT(16), (FLAG, FOR_NAME, BY_NAME) BIT(1);   02537500
      /* A NAME REMOTE DEREFERENCE IS BEING HANDLED WITH A REMOTE   CR12432 */
      /* RTL CALL, SO THE NAME REMOTE MUST BE LOADED (BUT NOT       CR12432 */
      /* DEREFERENCED). CLEAR NR_DEREF(OP) TO AVOID DEREFERENCE     CR12432 */
         NR_DEREF_TMP(OP) = NR_DEREF(OP);               /*DR109095, CR12432 */
         NR_DEREF(OP) = FALSE;                                   /* CR12432 */
         DECLARE TLOC BIT(16);                          /*DR111377*/
         IF MAJOR_STRUCTURE(OP) THEN TLOC=LOC(OP);      /*DR111377*/
         ELSE TLOC=LOC2(OP);                            /*DR111377*/
         R = TR;                                                                02538000
         IF R < 0 THEN DO;                                                      02538500
            R = GET_R(OP,LOADADDR); /*#DREG*/                                   02539000
            USAGE(R) = 0;                                                       02539500
         END;                                                                   02540000
         ELSE DO;                                                               02540500
            IF TR < 3 THEN TARGET_R = TR;                                       02541000
 /************************** START  DR111328  ********************************/
            IF FORM(OP) = SYM THEN DO;                           /* DR111328 */
               IF ^(SYT_BASE(LOC(OP)) = R_VAR(R)                 /* DR111328 */ 02542000
 /***************************  RPC  DR108620  ********************************/
 /********  ADDED CHECK FOR R_CONTENTS(R) = XPT WHEN FORM(OP) = SYM  *********/
 /* DR109078 - NEED TO CHECKPOINT WHEN USAGE IS 2, WHICH MEANS THAT          */
 /*            A STRUCTURE NAME NODE HAS BEEN LOADED INTO R                  */
               & USAGE(R)^=2  & R_CONTENTS(R) = XPT |            /* DR109078 */
 /***************************  RPC  DR108620  END  ***************************/
               INX(OP) = R) | USAGE(R) > 3                       /* DR111328 */ 02542500
               THEN CALL CHECKPOINT_REG(R);                      /* DR111328 */ 02543000
            END; ELSE                                            /* DR111328 */
            IF ^(FORM(OP) = CSYM & BASE(OP) = R |                /* DR111328 */ 02541500
               INX(OP) = R) | USAGE(R) > 3                                      02542500
               THEN CALL CHECKPOINT_REG(R);                                     02543000
 /***************************  END  DR111328  ********************************/
         END;                                                                   02543500
         IF FORM(OP) = LIT THEN DO;                                             02544000
            IF TYPE(OP) = INTEGER & VAL(OP) = 0 THEN DO;                        02544500
               VAL(OP) = NULL_ADDR;                                             02545000
               CALL SAVE_LITERAL(OP, NAMETYPE);                                 02545500
 /**********  DR102954  BOB CHEREWATY  *****************/
 /* DISCONTINUE USE OF NAMELOAD.  REPLACE WITH LH.     */
 /* BOTH ARE CONSTANTS FOR LOAD HALFWORD OPCODE.       */
 /******************************************************/
               CALL EMITOP(LH, R, OP);                                          02546000
 /**********  DR102954  END  ***************************/
               GO TO SET_R;                                                     02546500
            END;                                                                02547000
            CALL SAVE_LITERAL(OP, TYPE(OP));                                    02547500
         END;                                                                   02548000
         IF FORM(OP) = SYM THEN                                                 02548500
            IF BLOCK_CLASS(SYT_CLASS(LOC2(OP))) & FOR_NAME THEN DO;             02549000
            CALL SETUP_ADCON(OP);                                               02549500
 /* CODE FOR LOADING NAMES OF PROGRAMS AND TASKS.  FORCED                       02550000
              THROUGH GUARENTEE_ADDRESSABLE WITH 'BY_NAME' = 1, MEANING         02550050
              THAT NAME VARIABLES SHOULD NOT BE DEREFERENCED BY                 02550100
              GUARENTEE_ADDRESSABLE.      THIS IS AN OPTIMIZATION */            02550150
            IF FORM(OP) = EXTSYM THEN CALL EMITOP(LA,R,OP);                     02550200
            ELSE IF BY_NAME THEN DO;                                            02550250
               CALL GUARANTEE_ADDRESSABLE(OP,LA,BY_NAME_TRUE,0,R); /*CR13616*/  02550300
               CALL EMITOP(LA,R,OP);                                            02550350
            END;                                                                02550400
            ELSE IF (SYT_FLAGS(LOC(OP)) & ASSIGN_OR_NAME) = ASSIGN_OR_NAME      02550450
               | (SYT_FLAGS(LOC(OP)) & POINTER_FLAG) = 0 THEN DO;               02550500
 /**********  DR102954  BOB CHEREWATY  *****************/
 /* DISCONTINUE USE OF NAMELOAD.  REPLACE WITH LH.     */
 /* BOTH ARE CONSTANTS FOR LOAD HALFWORD OPCODE.       */
 /******************************************************/
               CALL GUARANTEE_ADDRESSABLE(OP,LH,BY_NAME_TRUE,0,R); /*CR13616*/  02550550
               CALL EMITOP(LH,R,OP);                                            02550600
 /**********  DR102954  END  ***************************/
            END;                                                                02550650
            ELSE DO;                                                            02550700
               CALL CHECK_ADDR_NEST(R,OP);                                      02550750
 /**********  DR102954  BOB CHEREWATY  *****************/
 /* DISCONTINUE USE OF NAMELOAD.  REPLACE WITH LH.     */
 /* BOTH ARE CONSTANTS FOR LOAD HALFWORD OPCODE.       */
 /******************************************************/
               CALL EMITOP(LH,R,OP);                                            02550800
 /**********  DR102954  END  ***************************/
            END;                                                                02550850
            GO TO SET_R;                                                        02558500
         END;                                                                   02559000
         ELSE IF (SYT_FLAGS(TLOC) & POINTER_OR_NAME) ^= 0 THEN     /*DR111377*/ 02559500
            IF SYT_BASE(LOC(OP)) >= 0 THEN                                      02560000
            IF BY_NAME |                                                        02560001
            (SYT_FLAGS(LOC(OP)) & ASSIGN_OR_NAME) ^= ASSIGN_OR_NAME THEN        02560002
 /* CAN USE OPTIMIZATION.  DONT HAVE TO CALL GUARENTEE                          02560003
                   ADDRESSABLE */                                               02560004
            IF INX(OP) = 0 THEN IF INX_CON(OP) = 0 THEN DO;                     02560500
         /* REMOVED BX114 ERROR                            /* CR12432 */
            CALL CHECK_ADDR_NEST(R, OP);                                        02561000
            IF (SYT_FLAGS(TLOC) & POINTER_FLAG) = 0 & BY_NAME THEN /*DR111377*/ 02561500
               TEMP = LA;                                                       02562000
 /***********  DR102954  BOB CHEREWATY  ***********/                            02562500
            ELSE DO;
 /* DR102954 NAME VARIABLE USED IN RHS */
 /* DISCONTINUE USE OF NAMELOAD        */
               IF (POINTS_REMOTE(OP) = TRUE) THEN
                  TEMP = L;          /* 32 BIT NAME VARIABLE */
               ELSE
                  TEMP = LH;         /* 16 BIT NAME VARIABLE */
            END;
 /***********  DR102954  END  *********************/                            02562500
            CALL EMITXOP(TEMP, R, OP);                                          02563000
            /* IF ITS A 16 BIT NAME VARIABLE AND A REMOTE ADDRESS */
            /* IS EXPECTED, PERFORM A YCON TO ZCON CONVERSION     */
            IF (^POINTS_REMOTE(OP) & REMOTE_ADDRS) THEN  /* DR107092 */
            IF ^NR_DEREF_TMP(OP) THEN /* CR12432,DR109095 */
               CALL YCON_TO_ZCON(R,OP);                  /* DR107092 */
            GO TO SET_R;                                                        02565500
         END;                                                                   02566000
         CALL GUARANTEE_ADDRESSABLE(OP, LA, BY_NAME, 0, R);                     02566500
         /* IF NAME REMOTE IS IN COMPOOL, G_A WILL HAVE  /* CR12432 */
         /* LOADED BASE REGISTER.                        /* CR12432 */
         NR_DEREF_TMP(OP) = NR_DEREF_TMP(OP) | NR_DEREF(OP);/*DR109095,CR12432*/
         /* KEEP NR_DEREF(OP) FOR NEXT CHECK_REMOTE CALL./* CR12432 */
         IF FORM(OP) = CSYM THEN                                                02567000
            IF ^NR_DEREF_TMP(OP) THEN                    /*DR109095,CR12432 */
            IF INX(OP) = 0 THEN IF INX_CON(OP) = 0 THEN IF DISP(OP) = 0 THEN DO;02567500
            IF BASE(OP) ^= R THEN                                               02568000
               IF TR < 0 THEN R = BASE(OP);                                     02568500
            ELSE CALL EMITRR(LR, R, BASE(OP));                                  02569000
            IF REMOTE_ADDRS THEN                                                02569010
 /*DANNY -------------------- DR102951 --------------------------------*/        2571000
 /*DANNY -- IF A NAME REMOTE VALUE IS LOADED (NOT BEING DEREFERENCED), */        2571000
 /*DANNY -- DONT CLOBBER THE LOWER HALF OF REGISTER WITH "IAL 0400"    */        2571000
               IF ^POINTS_REMOTE(OP) THEN                                       02569010
 /*DANNY --------------------------------------------------------------*/        2571000
/*-------------------------- #DNAME -- FIX FOR DR103750 ---------*/             42800006
/* ASSIGNING MIGRATED #D ADDRESS INTO NAME REMOTE VARIABLE,      */             42810006
/* OR CONVERTING YCON TO ZCON FOR PASS-BY-REFERENCE TO RTL.      */             42820006
/* SET MSB AND PUT CSECT NUMBER INTO LOWER HALF OF REGISTER.     */             42830006
/* SET XC BIT (INDEX CONTROL) IF NOT AGGREGATE DATA.             */             42840006
/*-----------     CALL EMITP(IAL,R,0,0,"0400"); --- OLD METHOD --*/             42850006
               IF ^NR_DEREF_TMP(OP) THEN /*DR109095,CR12432 */
                  CALL YCON_TO_ZCON(R,OP);                                      42860006
/*---------------------------------------------------------------*/             42870006
            CALL DROP_BASE(OP);                                                  2569500
            GO TO SET_R;                                                        02570000
         END;                                                                   02570500
 /*-------------------------- DR103753 --------------------------------*/        2571000
 /*DANNY -- FIX SLL PROBLEM: INDEX OF NAME VARIABLES INCORRECTLY SET UP*/        2571000
 /*DANNY -- LOOK AT TYPE OF VARIABLE THAT NAME VARIABLE POINTS TO WHEN */        2571000
 /*DANNY -- FIGURING OUT THE AMOUNT TO SHIFT THE INDEX.                */        2571000
         DECLARE SHIFT_AMOUNT BIT(8);                                            2571000
 /*DANNY ============= DR103753 PART2 === D. STRAUSS ====*/                      2571000
 /*DANNY  ADD A CHECK FOR REMOTENESS BECAUSE IF REMOTE, THEN      */             2571000
 /*DANNY  AUTOINDEXING NOT DONE WHEN INDEX IS ADDED TO A LOADED   */             2571000
 /*DANNY  ADDRESS, SO WE NEED TO SLL THE INDEX OURSELF.           */             2571000
         IF SELF_ALIGNING THEN
            IF (STRUCT_INX(OP) < 4) | CHECK_REMOTE(OP) |  /*DR111374*/
            AIA_ADJUSTED(OP) THEN                         /*DR111374*/
 /*DANNY ================================================*/                      2571000
            IF INX(OP) > 0 THEN                                                 02571500
            DO;                                                                  2571000
               /*----------------------------------------------*/
               /* DR109019 - IF THE INDEX REGISTER WAS SHIFTED */
               /* BY SUBSRIPT_RANGE_CHECK, THEN SHIFT IT BACK  */
               /* HERE.  USE THE SAME SHIFT VALUE.             */
               /* THE AMOUNT SHIFTED IS = 1/2 AIA_ADJUSTED.    */
               /*----------------------------------------------*/
               IF (AIA_ADJUSTED(OP)) THEN DO;
                  SHIFT_AMOUNT=AIA_ADJUSTED(OP)/2;
                  AIA_ADJUSTED(OP)=FALSE;
               END;
               /*----------------------------------------------*/
               /* IF IT NEEDS TO BE ADJUSTED FOR SOME OTHER    */
               /* REASON.  USE THE OLD ALGORTHM FOR GETTING    */
               /* THE SHIFT AMOUNT                             */
               /*----------------------------------------------*/
               ELSE DO;
               /*----------------------------------------------*/
               /* CR13339 - CALL AIA_SHIFT_AMOUNT TO CALCULATE */
               /* THE SHIFT_AMOUNT, SO THE PREVIOUS CODE FOUND */
               /* TO BE A DUPLICATE OF AIA_SHIFT_AMOUNT COULD  */
               /* BE REMOVED. SIMPLE_AIA_ADJUST IS SET TO TRUE */
               /* BEFORE & RESET TO FALSE AFTER THE CALL TO    */
               /* SKIP A SECTION OF CODE IN AIA_SHIFT_AMOUNT   */
               /* THAT WAS NOT COMMON TO THE PREVIOUS CODE IN  */
               /* THIS SECTION.                                */
               /*----------------------------------------------*/
                  SIMPLE_AIA_ADJUST = TRUE;             /*CR13339*/
                  SHIFT_AMOUNT = AIA_SHIFT_AMOUNT(OP);  /*CR13339*/
                  SIMPLE_AIA_ADJUST = FALSE;            /*CR13339*/
               END;
               IF SHIFT_AMOUNT > 0 THEN                                         02572000
                  CALL EMITP(SLA, INX(OP), 0, SHCOUNT, SHIFT_AMOUNT);           02572500
         END;                                                                    2571000
 /*--------------------------------------------------------------------*/        2571000
         /* COMBINED CHECK_REMOTE AND POINTS_REMOTE SECTIONS -  CR12432 */
         /* LOAD THE NAME REMOTE FOR REMOTE RTL CALL         /* CR12432 */
         /* (IT MAY ALREADY BE LOADED IF NRDEREF TOOK PLACE  /* CR12432 */
         /*  UPSTREAM IN STRUCTURE WALK.)                    /* CR12432 */
         /* NAME(ZCON) PASSED AS ASSIGN PARAMETER IS ASSUMED    CR2935*/
         /* TO LIVE LOCALLY (SECTOR 0/1) SO SKIP THE REMOTE     CR2935*/
         /* SECTION AND USE AN LA TO LOAD ITS ADDRESS.          CR2935*/
         IF CHECK_REMOTE(OP) | POINTS_REMOTE(OP) &  /*CR12935/* CR12432 */
            ^(NAME_FUNCTION(OP) & D_RTL_SETUP &       /*CR12935 DR111390*/
             ((SYT_FLAGS(ARGPOINT) & ASSIGN_FLAG)^=0)) THEN DO; /*CR12935*/
 /************* DR105115  RAH  5-12-93 ********************************/
 /* VERIFY THAT THE BASE REGISTER IS NOT EQUAL TO 3 FOR AN   /* DR111336*/
 /* RS INSTRUCTION BEFORE LOADING A NAME REMOTE STRUCT NODE  /* DR111336*/
 /* THAT WILL BE DEREFERENCED BY AN RTL                      /* DR111336*/
            IF NR_DEREF_TMP(OP) & ^NAME_FUNCTION(OP) &     /* DR111336 111390*/
            POINTS_REMOTE(OP) & (FORM(OP)=CSYM) &            /* DR111336*/
            (BASE(OP)=3) THEN                                /* DR111336*/
               IF ((INX(OP) = R) &                           /* DR111336*/
 /*DR111336*/  CHECK_SRS(A,0,BASE(OP),DISP(OP)+NR_DELTA(OP)+INSMOD)=RXTYPE)
 /*DR111336*/  | (CHECK_SRS(L,0,BASE(OP),DISP(OP)+NR_DELTA(OP)+INSMOD)=RXTYPE)
               THEN DO;                                      /* DR111336*/
                  CALL CHECKPOINT_REG(1);                    /* DR111336*/
                  CALL COPY_REG_INFO(3,1,USAGE(3));          /* DR111336*/
                  CALL EMITRR(LR,1,3);                       /* DR111336*/
                  BASE(OP) = 1;                              /* DR111336*/
                  D_R1_CHANGE = SHL(D_R1_CHANGE,1) | TRUE;   /* DR111336*/
                  R3_USED = TRUE;                            /* DR111336*/
               END;                                          /* DR111336*/
            IF INX(OP) = R THEN DO;
               IF BIX_CNTR > 0 THEN                          /* DR111332*/
                  CALL EMITP(NHI, INX(OP), 0, 0, "FFFF");    /* DR111332*/
               IF FORM(OP)=CSYM THEN DO    ;                 /* CR12432 */
  /* LOAD NAME REMOTE STRUCT NODE - DEREFERENCE BY RTL.      /* DR109090*/
  /* (WILL HAVE ALREADY BEEN LOADED IF IN NAME FUNCTION)     /* DR109090*/
  /*DR109095*/    IF NR_DEREF_TMP(OP) & ^NAME_FUNCTION(OP)   /*DR109090 111390*/
                     & POINTS_REMOTE(OP) THEN                /* DR109095*/
                     CALL EMITRX(A,R,0,BASE(OP),             /* CR12432 */
                                 DISP(OP)+NR_DELTA(OP));     /* CR12432 */
                  ELSE                                       /* CR12432 */
                     CALL EMITRR(AR, R, BASE(OP));
               END;                                          /* CR12432 */
               ELSE DO;                                      /* CR12432 */
  /*DR111311*/    IF NR_DEREF_TMP(OP)&(FORM(OP)=NRTEMP) THEN /*12432 109095*/
  /*DR111331*/   /* HANDLE GETTING ZCON STORED ON STACK      /* CR12432 */
  /*DR111331*/       CALL EMITRX(A,R,0,BASE(OP),DISP(OP));   /* CR12432 */
  /*DR111331*/    ELSE                                       /* CR12432 */
      /*CR12935   GET REMOTE PASS-BY-REF ADDRESS (FORMAL PARM), */
      /*DR111381  TEMPORARY NAME REMOTE, OR AUTOMATIC NAME      */
      /*DR111381  REMOTE IN A REENTRANT PROCEDURE/FUNCTION      */
      /*CR12935   FROM THE STACK */
      /*CR12935*/ IF ( ((SYT_FLAGS(LOC(OP)) & POINTER_FLAG)^=0) &
      /*CR12935*/ ((SYT_FLAGS(LOC(OP)) & REMOTE_FLAG)^=0) ) | /*DR111381*/
                  ( ((SYT_FLAGS(LOC(OP)) & AUTO_FLAG) ^= 0) & /*DR111381*/
                    ((SYT_FLAGS(PROC_LEVEL(SYT_SCOPE(LOC(OP)))) & /* "" */
                     REENTRANT_FLAG) ^= 0) ) |                /*DR111381*/
                  ( (SYT_FLAGS(LOC(OP)) & TEMPORARY_FLAG) ^= 0 )  /* "" */
                  THEN                                        /*DR111381*/
      /*CR12935*/    CALL EMITRX(A,R,0,BASE(OP),              /*DR111381*/
      /*CR12935*/         SYT_DISP(LOC(OP))+NR_DELTA(OP));    /*DR111381*/
      /*CR12935*/ ELSE
                     CALL EMITRX(A,R,0,PRELBASE,             /* CR12432 */
                          SYT_DISP(LOC(OP))+NR_DELTA(OP));   /* CR12432 */
               END;                                          /* CR12432 */
            END;
            ELSE DO;
               IF FORM(OP) = CSYM THEN DO;           /*DR101325*/
  /* LOAD NAME REMOTE STRUCT NODE - DEREFERENCE BY RTL.      /* DR109090*/
  /* (WILL HAVE ALREADY BEEN LOADED IF IN NAME FUNCTION)     /* DR109090*/
  /*DR109095*/    IF NR_DEREF_TMP(OP) & ^NAME_FUNCTION(OP)   /*DR109090 111390*/
                     & POINTS_REMOTE(OP) THEN                /* DR109095*/
                     CALL EMITRX(L,R,0,BASE(OP),                   /* CR12432 */
                                 DISP(OP)+NR_DELTA(OP));           /* CR12432 */
                  ELSE                                             /* CR12432 */
                  IF R ^= BASE(OP) THEN
                  DO;                                /*DR111377*/
                     CALL EMITRR(LR,R,BASE(OP));     /*DR101325*/
                     CALL UNRECOGNIZABLE(BASE(OP));  /*DR111377*/
                  END;                               /*DR111377*/
               END;
 /************* END DR105115 ******************************************/
               ELSE                                  /*DR101325*/
               DO;                                                /* CR12432 */
               /* GET NAME REMOTE THAT WAS PUT ON STACK           /* CR12432 */
  /*DR111331*/    IF NR_DEREF_TMP(OP) & (FORM(OP)=NRTEMP) THEN /*12940 109095*/
  /*DR111331*/       CALL EMITRX(L,R,0,BASE(OP),DISP(OP));        /* CR12432 */
  /*DR111331*/    ELSE                                            /* CR12432 */
      /*CR12935   GET REMOTE PASS-BY-REF ADDRESS (FORMAL PARM), */
      /*DR111381  TEMPORARY NAME REMOTE, OR AUTOMATIC NAME      */
      /*DR111381  REMOTE IN A REENTRANT PROCEDURE/FUNCTION      */
      /*CR12935   FROM THE STACK */
      /*CR12935*/ IF ( ((SYT_FLAGS(LOC(OP)) & POINTER_FLAG)^=0) &
      /*CR12935*/ ((SYT_FLAGS(LOC(OP)) & REMOTE_FLAG)^=0) ) |      /*DR111381*/
                  ( ((SYT_FLAGS(LOC(OP)) & AUTO_FLAG) ^= 0) &      /*DR111381*/
                    ((SYT_FLAGS(PROC_LEVEL(SYT_SCOPE(LOC(OP)))) &  /*DR111381*/
                     REENTRANT_FLAG) ^= 0) ) |                     /*DR111381*/
                  ( (SYT_FLAGS(LOC(OP)) & TEMPORARY_FLAG) ^= 0 )   /*DR111381*/
                  THEN                                             /*DR111381*/
      /*CR12935*/    CALL EMITRX(L,R,0,BASE(OP),                   /*DR111381*/
      /*CR12935*/                SYT_DISP(LOC(OP))+NR_DELTA(OP));  /*DR111381*/
      /*CR12935*/ ELSE
                     CALL EMITRX(L,R,0,PRELBASE,                  /* CR12432 */
                                 SYT_DISP(LOC(OP))+NR_DELTA(OP)); /* CR12432 */
               END;                                               /* CR12432 */
               IF INX(OP) > 0 THEN DO;                           /*DR108606*/
                  /*----------------------- DR108606 ----------------------*/
                  /* THE INDEX REGISTER OF A BIX LOOP MAY HAVE THE COUNT   */
                  /* IN THE LOWER HALF.  IF SO, THEN ADDING THIS TO A      */
                  /* ZCON WILL OVERWRITE THE DSR.  THERFORE, EMIT AN NHI   */
                  /* TO ZERO THE LOWER HALF OF THE BIX INDEX REGISTER IF   */
                  /* BIX_CNTR IS GREATER THAN ZERO (IE, WE ARE INSIDE A    */
                  /* BIX LOOP).                                            */
                  /*----------------------- DR108606 ----------------------*/
                  IF BIX_CNTR > 0 THEN                           /*DR108606*/
                     CALL EMITP(NHI, INX(OP), 0, 0, "FFFF");     /*DR108606*/
                  CALL EMITRR(AR, R, INX(OP));                   /*DR108606*/
               END;                                              /*DR108606*/
            END;
            IF POINTS_REMOTE(OP) THEN /* BECAUSE SECTIONS COMBINED -CR12432 */
            IF INX_CON(OP) ^= 0 THEN                      /* DR109034 */
               CALL EMITP(AHI, R, 0, 0, INX_CON(OP));     /* DR109034 */
            /* DR107092: IF ITS A 16 BIT POINTER AND A REMOTE  */
            /* ADDRESS IS EXPECTED, CALL YCON_TO_ZCON          */
            IF CHECK_REMOTE(OP) THEN /* BECAUSE SECTIONS COMBINED -CR12432 */
            IF ((SYT_FLAGS(LOC(OP)) & POINTER_OR_NAME)^=0) THEN
               IF (^POINTS_REMOTE(OP) & REMOTE_ADDRS) THEN
                  IF ^NR_DEREF_TMP(OP) THEN            /*DR109095, CR12432 */
                  CALL YCON_TO_ZCON(R,OP);
         END;
         ELSE DO;                                                               02577500
 /************  DR102961  RAH  ****************************************/
            CALL EMITOP(LA, R, OP);
 /************  END  DR102961  ****************************************/
         /* FORCE YCON TO ZCON WHEN PASSING REMOTE #D PARAMETER   CR12935*/
         /* BY REFERENCE TO PROCEDURE OR RTL.                     CR12935*/
            IF (DATA_REMOTE & (CSECT_TYPE(LOC(OP),OP)=LOCAL#D)  /*CR12935*/
               & D_RTL_SETUP)                                   /*CR12935*/
               | REMOTE_ADDRS THEN
       /* CHECK FOR POINTS_REMOTE (DR109005) WAS REMOVED    -CR12432 */
       /* BECAUSE SECTIONS WERE COMBINED                    -CR12432 */
/*-------------------------- #DNAME -- FIX FOR DR103750 ---------*/             43370006
/* ASSIGNING MIGRATED #D ADDRESS INTO NAME REMOTE VARIABLE VIA   */             43380006
/* %NAMEADD (OR %NAMECOPY?), OR PASS-BY-REF TO RTL.              */             43390006
/* SET MSB AND PUT CSECT NUMBER INTO LOWER HALF OF REGISTER.     */             43400006
/* SET XC BIT (INDEX CONTROL) IF NOT AGGREGATE DATA.             */             43410006
/*-----------     CALL EMITP(IAL,R,0,0,"0400"); --- OLD METHOD --*/             43420006
               IF ^NR_DEREF_TMP(OP) THEN /*DR109095,CR12432 */
                  CALL YCON_TO_ZCON(R,OP);                                      43430000
/*---------------------------------------------------------------*/             43440006
         END;                                                                   02579500
         TEMP = INX(OP);                                                        02580000
         CALL DROP_INX(OP);                                                     02580500
         IF SELF_ALIGNING THEN IF STRUCT_INX(OP) < 4 THEN                        2581000
            IF TEMP > 0 THEN                                                    02581500
 /*-------------------------- DR103753 --------------------------------*/        2571000
 /*DANNY -- FIX SLL PROBLEM: INDEX OF NAME VARIABLES INCORRECTLY SET UP*/        2571000
 /*DANNY -- LOOK AT TYPE OF VARIABLE THAT NAME VARIABLE POINTS TO WHEN */        2571000
 /*DANNY -- FIGURING OUT THE AMOUNT TO SHIFT THE INDEX.                */        2571000
            IF SHIFT_AMOUNT    > 0 THEN DO;                                     02572000
 /*--------------------------------------------------------------------*/        2571000
               IF USAGE(TEMP) > 1 THEN                                          02582500
                  CALL EMITP(SRA, TEMP, 0, SHCOUNT, SHIFT_AMOUNT);              02572500
               ELSE CALL UNRECOGNIZABLE(TEMP);                                  02583500
            END;                                                                 2571000
SET_R:                                                                          02584500
         CALL UNRECOGNIZABLE(R);                                                02585000
         IF FLAG THEN                                                           02585500
            USAGE(R) = 2;                                                       02586000
         R_TYPE(R) = DINTEGER;                                                  02586500
         USAGE_LINE(R) = 1;                                                      2587000
         REG(OP) = R;                                                           02587500
         FLAG, FOR_NAME, BY_NAME = FALSE;                                       02588000
         TARGET_R = -1;                                                         02588500
         CALL CHECK_LINKREG(R);                                                 02589000
         NR_DEREF(OP)=NR_DEREF_TMP(OP); /*DR109095*/
         NR_DEREF_TMP(OP)=FALSE; /*DR109095,CR12432*/
         RETURN R;                                                              02589500
      END FORCE_ADDRESS;                                                        02590000
                                                                                02590500
 /* ROUTINE TO LOAD A NUMBER INTO A SPECIFIED REGISTER */                       02591000
LOAD_NUM:                                                                       02591500
      PROCEDURE(R, NUM, FLAG);                                                  02592000
         DECLARE NUM FIXED, (R, LITOP, RT) BIT(16), FLAG BIT(1);                02592500
         LITOP = GET_INTEGER_LITERAL(NUM);                                      02593000
         TYPE(LITOP) = TYPE(LITOP) & (^8) | FLAG & 8;                           02593500
         RT = SEARCH_REGS(LITOP);                                               02594000
         IF RT >= 0 THEN DO;                                                    02594500
            IF R<0 THEN DO;                                                     02595000
               USAGE(RT) = USAGE(RT) + 2;                                       02595010
               CALL RETURN_STACK_ENTRY(LITOP);                                  02595020
               FLAG = FALSE;                                                    02595025
               RETURN RT;                                                       02595030
            END;                                                                02595040
            ELSE IF RT ^= R THEN CALL EMITRR(LR, R, RT);                        02595050
         END;                                                                   02595500
         ELSE DO;                                                               02596000
            IF R<0 THEN R = FINDAC(INDEX_REG);                                  02596010
            IF NUM = 0 THEN CALL EMITRR(XR, R, R);                              02596500
            ELSE IF TYPE(LITOP) = INTEGER THEN DO;                              02597000
               IF NUM >= -2 & NUM <= 13 & SELF_ALIGNING & COMPACT_CODE THEN     02597500
                  CALL EMITRR(LFXI, R, NUM+2);                                  02598000
               ELSE CALL EMITP(LHI, R, 0, 0, NUM);                              02598500
            END;                                                                02599000
            ELSE DO;                                                            02600000
               CALL SAVE_LITERAL(LITOP, TYPE(LITOP));                           02600500
               CALL EMIT_BY_MODE(LOAD, R, LITOP, TYPE(LITOP));                  02601000
            END;                                                                02601500
         END;                                                                   02602000
         IF ^FLAG THEN DO;                                                      02602500
            CALL SET_USAGE(R, LIT, NUM);                                         2603000
            R_TYPE(R) = TYPE(LITOP);                                            02603100
         END;                                                                   02605000
         FLAG = FALSE;                                                          02605500
         CALL RETURN_STACK_ENTRY(LITOP);                                        02606000
         CALL CHECK_LINKREG(R);                                                 02606500
         CALL CLEAR_INX(R);                                                     02607000
         RETURN R;                                                              02607010
      END LOAD_NUM;                                                             02607500
                                                                                02608000
 /* ROUTINE TO FORCE A NUMBER INTO A SPECIFIED REGISTER */                      02608500
FORCE_NUM:                                                                      02609000
      PROCEDURE(R, NUM, FLAG);                                                  02609500
         DECLARE NUM FIXED, R BIT(16), FLAG BIT(1);                             02610000
         IF USAGE(R) > 1 THEN CALL CHECKPOINT_REG(R);                           02610500
         CALL LOAD_NUM(R, NUM, FLAG);                                           02611000
         FLAG = FALSE;                                                          02611500
      END FORCE_NUM;                                                            02612000
                                                                                02612500
 /* ROUTINE TO SET UP LABEL STACK FOR GENERATED STATEMENT LABEL */              02613000
GETSTMTLBL:                                                                     02613500
      PROCEDURE(STATNO) BIT(16);                                                02614000
         DECLARE STATNO FIXED, PTR BIT(16);                                     02614500
         PTR = GET_STACK_ENTRY;                                                 02615000
         VAL(PTR), LOC(PTR) = STATNO;                                           02615500
         FORM(PTR) = STNO;                                                      02616000
         RETURN PTR;                                                            02616500
      END GETSTMTLBL;                                                           02617000
                                                                                02617500
 /* ROUTINE TO SET UP REGISTER TEMPORARY STACK ENTRY */                         02618000
GET_VAC:                                                                        02618500
      PROCEDURE(R, TYP) BIT(16);                                                02619000
         DECLARE (R, TYP, PTR) BIT(16);                                         02619500
         IF R < 0 THEN R = FINDAC(INDEX_REG);                                   02620000
         ELSE IF USAGE(R) < 2 THEN USAGE(R) = USAGE(R) + 2;                     02620500
         IF TYP = 0 THEN TYP = INTEGER;                                         02621000
         PTR = GET_STACK_ENTRY;                                                 02621500
         FORM(PTR) = VAC;                                                       02622000
         LOC2(PTR) = -1;                                                         2622100
         REG(PTR) = R;                                                          02622500
         TYPE(PTR), R_TYPE(R) = TYP;                                            02623000
         TYP = 0;                                                               02623500
         RETURN PTR;                                                            02624000
      END GET_VAC;                                                              02624500
                                                                                02625000
 /* ROUTINE TO DROP REGISTER TEMPORARY STACK ENTRY */                           02625500
DROP_VAC:                                                                       02626000
      PROCEDURE(PTR);                                                           02626500
         DECLARE PTR BIT(16);                                                   02627000
         IF FORM(PTR) = VAC THEN                                                02627500
            CALL DROP_REG(PTR);                                                  2628000
         CALL RETURN_STACK_ENTRY(PTR);                                          02628500
      END DROP_VAC;                                                             02629000
                                                                                02634000
 /*  ROUTINE FOR GETTING TOTAL ARRAY SIZE IN A BIG LUMP  */                     02634500
LUMP_ARRAYSIZE:                                                                 02635000
      PROCEDURE (OP) FIXED;                                                     02635500
         DECLARE (OP,J) BIT(16), ACC FIXED;                                     02636000
         ACC=1;                                                                 02636500
         IF SYT_ARRAY(OP) > 0 THEN                                              02637000
            DO J=SYT_ARRAY(OP)+1 TO EXT_ARRAY(SYT_ARRAY(OP))+SYT_ARRAY(OP);     02637500
            ACC=EXT_ARRAY(J)*ACC;                                               02638000
         END;                                                                   02638500
         RETURN ACC;                                                            02639000
      END LUMP_ARRAYSIZE;                                                       02639500
                                                                                02640000
 /* ROUTINE TO LUMP THE NUMBER OF ITEMS IN A TERMINAL SYMBOL */                 02640500
LUMP_TERMINALSIZE:                                                              02641000
      PROCEDURE(OP) FIXED;                                                      02641500
         DECLARE OP BIT(16);                                                    02642000
         IF PACKTYPE(SYT_TYPE(OP)) = VECMAT THEN                                02642500
            RETURN SHR(SYT_DIMS(OP), 8) * (SYT_DIMS(OP) & "FF");                02643000
         RETURN 1;                                                              02643500
      END LUMP_TERMINALSIZE;                                                    02644000
                                                                                02644500
 /****************************************************************/
 /* ROUTINE TO SET UP STACK SIZE PARAMETERS FOR SYMBOLS          */             02645000
 /****************************************************************/
 /*                                                               /*CR13616*/
 /* BY_NAME = TRUE (1)                                            /*CR13616*/
 /* ::= THE DESTINATION VARIABLE IN A NAME ASSIGNMENT, NAME       /*CR13616*/
 /*     INITIALIZATION, OR %NAMEADD/%NAMECOPY MACRO,              /*CR13616*/
 /* ::= A NAME ASSIGN ARGUMENT IN A PROCEDURE CALL,               /*CR13616*/
 /* ::= A SUBSCRIPT IN A NAME PSEDUO-FUNCTION AND THE STATEMENT   /*CR13616*/
 /*     IS AN ASSIGNMENT-TYPE STATEMENT,                          /*CR13616*/
 /* ::= THE SOURCE IN A %NAMEBIAS MACRO,                          /*CR13570*/
 /* ::= AN ARGUMENT IN THE SIZE BUILT-IN FUNCTION, OR             /*CR13616*/
 /* ::= FOR BFS ONLY, PROCESSING PROGRAM, TASK, PROCEDURE,        /*CR13616*/
 /*     FUNCTION, COMPOOL OR UPDATE BLOCK HEADERS.                /*CR13616*/
 /*                                                               /*CR13616*/
 /* BY_NAME = 2                                                   /*CR13616*/
 /* ::= PROCESSING OPERANDS IN REAL-TIME STATEMENTS, OR           /*CR13616*/
 /* ::= FOR PASS ONLY, PROCESSING PROGRAM, TASK, PROCEDURE,       /*CR13616*/
 /*     FUNCTION, COMPOOL OR UPDATE BLOCK HEADERS.                /*CR13616*/
 /*                                                               /*CR13616*/
 /* BY_NAME IS USED TO AVOID GETTING AN UNNECESSARY INDIRECT      /*CR13616*/
 /* STACK ENTRY IN THE BITS PROCESSING CASE. THE INDIRECT STACK   /*CR13616*/
 /* ENTRY IS USED TO REPRESENT THE LOCATION OF THE FIRST BIT OF   /*CR13616*/
 /* A BIT STRING IN MEMORY (THIS IS NEEDED FOR DENSE BITS).       /*CR13616*/
 /* EVENTS, TASKS AND PROGRAMS ARE PROCESSED LIKE BITS IN THIS    /*CR13616*/
 /* PROCEDURE.  BY_NAME BEING 2 ALLOWS THIS PROCEDURE TO          /*CR13616*/
 /* DISTINGUISH BETWEEN A BIT THAT CAN BE DENSE AND OTHER         /*CR13616*/
 /* VARIABLES THAT ARE PROCESSED LIKE BITS BUT CANNOT BE DENSE.   /*CR13616*/
 /*                                                               /*CR13616*/
 /****************************************************************/
SIZEFIX:                                                                        02645500
      PROCEDURE(PTR, OP1, BY_NAME);                                             02646000
         DECLARE (PTR, OP1, LITOP) BIT(16), BY_NAME BIT(1);                     02646500
         IF TYPE(PTR) >= ANY_LABEL THEN RETURN;                                 02647000
         DO CASE PACKTYPE(TYPE(PTR));                                           02647500
            DO;  /* VECTOR-MATRIX  */                                           02648000
               ROW(PTR) = SHR(SYT_DIMS(OP1), 8) & "FF";                         02648500
               COLUMN(PTR) = SYT_DIMS(OP1) & "FF";                              02649000
               DEL(PTR) = 0;                                                    02649500
            END;                                                                02650000
            DO;  /* BITS  */                                                    02650500
               LITOP = SYT_DIMS(OP1);                                           02651000
               SIZE(PTR) = LITOP & "FF";                                        02651500
               LITOP = SHR(LITOP, 8) & "FF";                                    02652000
               COLUMN(PTR) = 0;                            /* DR108645 */
               /* DR109041 - TYPE(PTR) IS SET TO BIT FOR ALL PROGRAM */
               /* AND TASK VARIABLES.  IF THE CURRENT VARIABLE IS A  */
               /* PROGRAM OR TASK, ONLY DO THE FOLLOWING IF THE      */
               /* VARIABLE IS ACTUALLY USED AS A BOOLEAN.  THIS      */
               /* OCCURS WHEN CLASS = 7 OR CLASS = 1.                */
               IF ^( (SYT_TYPE(OP1) >= TASK_LABEL) &       /*DR109041*/
                   (CLASS ^=7) & (CLASS ^= 1) ) THEN       /*DR109041*/
               IF LITOP ^= 0 THEN IF BY_NAME = 0 THEN DO;                        2652500
                  IF LITOP = "FF" THEN LITOP = 0;                               02653000
                  IF TYPE(PTR) = FULLBIT THEN                                   02653500
                     IF LITOP+SIZE(PTR) <= HALFWORDSIZE THEN DO;                02654000
                     TYPE(PTR) = BITS;                                          02654500
                     STRUCT_CON(PTR) = STRUCT_CON(PTR) + 1;                      2655000
                  END;                                                          02655500
                  ELSE IF LITOP >= HALFWORDSIZE THEN DO;                        02656000
                     TYPE(PTR) = BITS;                                          02656500
                     LITOP = LITOP - HALFWORDSIZE;                              02657000
                  END;                                                          02657500
                  COLUMN(PTR) = GET_INTEGER_LITERAL(LITOP);                     02662500
               END;                                                             02663000
               DEL(PTR) = 0;                                                    02663500
            END;                                                                02664000
            SIZE(PTR) = SYT_DIMS(OP1);                                          02664500
            DEL(PTR) = 0;                                                       02665000
            DO;  /* STRUCTURE  */                                               02665500
               DEL(PTR) = OP1;                                                  02666000
               SIZE(PTR) = EXTENT(OP1);                                         02666500
            END;                                                                02667000
         END;                                                                   02667500
         BY_NAME = FALSE;                                                       02668000
      END SIZEFIX;                                                              02668500
                                                                                02669000
 /* ROUTINE TO ESTABLISH THE AREA OF A TERMINAL OPERAND  */                     02669500
SET_AREA:                                                                       02670000
      PROCEDURE(PTR);                                                           02670500
         DECLARE PTR BIT(16);                                                   02671000
         IF TYPE(PTR) < ANY_LABEL THEN                                          02671500
            DO CASE PACKTYPE(TYPE(PTR));                                        02672000
            AREASAVE = ROW(PTR) * COLUMN(PTR);                                  02672500
            AREASAVE = 1;                                                       02673000
            IF SIZE(PTR) < 0 THEN AREASAVE = SIZE(PTR);                         02673500
            ELSE AREASAVE = CS(SIZE(PTR) + 2);                                  02674000
            AREASAVE = 1;                                                       02674500
            AREASAVE = EXTENT(DEL(PTR)) + SYT_DISP(DEL(PTR));                   02675000
         END;                                                                   02675500
      END SET_AREA;                                                             02676000
                                                                                02676500
 /*  SUBROUTINE FOR FIXING UP THE TERMINAL SIZE OF OPERANDS  */                 02677000
DIMFIX:                                                                         02677500
      PROCEDURE(PTR, OP1);                                                      02678000
         DECLARE (PTR, OP1) BIT(16);                                            02678500
         ARRAYNESS = GETARRAY#(OP1);                                            02679000
         COPY(PTR) = STRUCT(PTR) + ARRAYNESS;                                    2679500
         CALL SET_AREA(PTR);                                                    02680000
      END DIMFIX;                                                               02680500
                                                                                02681000
 /* ROUTINE TO SET UP STACK ENTRY FOR UNKNOWN ARRAY SIZE  */                    02681500
SET_ARRAY_SIZE:                                                                 02682000
      PROCEDURE(OP, CON) BIT(16);                                               02682500
         DECLARE (OP, CON, PTR) BIT(16);                                        02683000
         PTR = GET_STACK_ENTRY;                                                 02683500
         FORM(PTR) = SYM;                                                       02684000
         LOC(PTR) = OP;                                                         02684500
         TYPE(PTR) = DINTEGER;                                                  02685000
         IF CON ^= 0 THEN INX_CON(PTR) = CON;                                   02685500
         ELSE INX_CON(PTR) = SHL(SYT_LEVEL(OP), 1);                             02686000
         CON = 0;                                                               02686500
         RETURN PTR;                                                            02687000
      END SET_ARRAY_SIZE;                                                       02687500
                                                                                02688000
 /* ROUTINE TO CHECK IF SI-TYPE INSTRUCTION IS VALID */                         02688500
CHECK_SI:                                                                       02689000
      PROCEDURE(INST, OP) BIT(1);                                               02689500
         DECLARE (INST, OP) BIT(16);                                            02690000
         DECLARE BREG BIT(16);                                                  02690100
         IF FORM(OP) = IMD THEN RETURN TRUE;                                    02690500
         IF CHECK_REMOTE(OP) THEN RETURN FALSE;                                 02691000
         IF FORM(OP) ^= EXTSYM THEN IF FORM(OP) ^= INL THEN                     02691500
            DO CASE PACKFORM(FORM(OP));                                         02692000
            IF CHECK_SRS(INST,INX(OP),SYT_BASE(LOC(OP)),                        02692500
               SYT_DISP(LOC(OP))+INX_CON(OP)) = SRSTYPE                         02692510
               THEN RETURN TRUE;                                                02693000
            IF CHECK_SRS(INST,INX(OP),BASE(OP),DISP(OP)+INX_CON(OP)) = SRSTYPE  02693500
               THEN RETURN TRUE;                                                02694000
            RETURN FALSE;                                                       02694500
         END;                                                                   02695000
         IF INST = TB THEN IF INX(OP) ^= 0 THEN RETURN FALSE;  /* TOO SLOW */   02695500
         IF SHR(NOT_LEAF(INDEXNEST),1) THEN BREG = PTRARG1;                     02696000
         ELSE IF USAGE(PTRARG1) > USAGE(R3) THEN BREG = R3;                     02696010
         ELSE BREG = PTRARG1;                                                   02696020
 /*---------------------- #DREG -------------------------*/
 /* ASSIGN REGISTER FOR FORCE_ADDRESS TO USE TO LA INTO. */
         IF DATA_REMOTE THEN
            BREG = REG_STAT(OP,BREG,LOADADDR);
 /*------------------------------------------------------*/
         IF USAGE(BREG) > 1 THEN                                                02696030
            IF USAGE(PTRARG1) > 3 THEN RETURN FALSE;                            02696500
         ELSE IF FORM(OP) ^= CSYM THEN RETURN FALSE;                            02697000
         ELSE IF BASE(OP) ^= BREG THEN RETURN FALSE;                            02697500
         IF KNOWN_SYM(OP) THEN                                                   2697600
            CALL NEW_USAGE(OP, INX(OP) ^= 0);                                    2697700
         CALL EMITC(PROLOG, 1);                                                 02697800
         CALL FORCE_ADDRESS(BREG, OP, 1);                                       02698000
         CALL EMITC(PROLOG, 0);                                                 02698100
         FORM(OP) = CSYM;                                                       02698500
         BASE(OP), BACKUP_REG(OP) = REG(OP);                                    02699000
         INX(OP), DISP(OP) = 0;                                                 02699500
         STRUCT_CON(OP), INX_CON(OP) = 0;                                       02700000
         RETURN TRUE;                                                           02700500
      END CHECK_SI;                                                             02701000
                                                                                02709000
 /* ROUTINE TO GENERATE SI INSTRUCTIONS, IF ALLOWABLE */                        02709500
GENSI:                                                                          02710000
      PROCEDURE(INST, OP, VALUE) BIT(1);                                        02710500
         DECLARE VALUE FIXED, (INST, OP) BIT(16), RC BIT(1);                    02711000
         IF INST = NIST & VALUE = 0 THEN INST = ZH;                             02711500
         ELSE IF INST = SB & VALUE = XITAB(HALFWORDSIZE) THEN DO;               02712000
            INST = SHW;  VALUE = 0;                                             02712500
            END;                                                                02713000
         ELSE IF INST = TB & VALUE = XITAB(HALFWORDSIZE) THEN DO;               02713500
            INST = TH;  VALUE = 0;                                              02714000
            END;                                                                02714500
         ELSE IF INST = MSTH & VALUE = -1 THEN DO;                              02715000
            INST = TD;  VALUE = 0;                                              02715500
            END;                                                                02716000
         CALL GUARANTEE_ADDRESSABLE(OP,INST,BY_NAME_FALSE,VALUE^=0); /*CR13616*/02716500
         RC = TRUE;                                                             02717000
         DO CASE VALUE ^= 0;                                                    02717500
            DO;                                                                 02718000
               CALL EMITOP(INST, 0, OP);                                        02718500
               CALL DROP_INX(OP);                                               02719000
            END;                                                                02719500
            IF CHECK_SI(INST, OP) THEN                                          02720000
               CALL EMITSIOP(INST, OP, VALUE);                                  02720500
            ELSE RC = FALSE;  /* INDICATE NO CODE EMITTED */                    02721000
         END;                                                                   02721500
         VALUE = 0;                                                             02722000
         RETURN RC;                                                             02722500
      END GENSI;                                                                02723000
                                                                                02723010
 /* ROUTINE TO MOVE REGISTER ATTRIBUTES FROM ONE REGISTER TO ANOTHER  */        02723020
MOVEREG:                                                                        02723030
      PROCEDURE(RF, RT, RTYPE, USED);                                           02723040
         DECLARE (RF, RT, RTYPE) BIT(16), USED BIT(1);                          02723050
         IF PACKTYPE(RTYPE) = VECMAT THEN RTYPE = RTYPE&8 | SCALAR;             02723060
         IF RTYPE = DSCALAR THEN DO;                                            02723070
            CALL EMITRR(MAKE_INST(LOAD, SCALAR, RR), RT+1, RF+1);               02723080
            RTYPE = SCALAR;                                                     02723090
         END;                                                                   02723100
         CALL EMITRR(MAKE_INST(LOAD, RTYPE, RR), RT, RF);                       02723110
         CALL COPY_REG_INFO(RF, RT, 2);                                         02723120
         IF USED THEN USAGE(RF) = USAGE(RF) - 2;                                02723130
      END MOVEREG;                                                              02723140
                                                                                02723500
 /* SUBROUTINE TO PERFORM RX OR RR ARITHMETIC BY MODE  */                       02724000
ARITH_BY_MODE:                                                                  02724500
      PROCEDURE(OP, OP1, OP2, OPTYPE, BIAS);                                    02725000
         DECLARE (OP, BIAS, OP1, OP2, OPTYPE, INST) BIT(16);                    02725500
                                                                                02725510
ZERO_TEST:                                                                      02725520
         PROCEDURE(R, N);                                                       02725530
            DECLARE (R, N) BIT(16);                                             02725540
            IF R ^= CCREG THEN                                                  02725550
               CALL EMITRR(LER, R, R);                                          02725560
            CALL EMITLFW(EZ, N);                                                02725590
         END ZERO_TEST;                                                         02725600
         R_TYPE(REG(OP1)) = OPTYPE;                                             02726000
         IF PACKTYPE(OPTYPE) = VECMAT THEN OPTYPE = OPTYPE&8 | SCALAR;           2726100
       IF OPTYPE = DSCALAR THEN IF OP=PREFIXMINUS | OP=20 | OP=BIFOPCODE(1) THEN02726500
            OPTYPE = SCALAR;                                                    02727000
         IF BIAS = 0 THEN                                                       02727500
            IF FORM(OP2) = VAC THEN                                             02728000
            BIAS = RR;                                                          02728500
         ELSE BIAS = RX;                                                        02729000
         INST = MAKE_INST(OP, OPTYPE, BIAS);                                    02729500
         IF OP = XDIV & OPMODE(OPTYPE) = 4 & NEW_INSTRUCTIONS THEN DO;          02729510
            /* ---------------------- DR108608 ------------------------ */
            /* IF DIVIDING A DOUBLE PRECISION NUMBER BY ITSELF THEN     */
            /* PLACE A DOUBLE PRECISION "1" INTO THE DESTINATION        */
            /* REGISTERS.                                               */
            /* ---------------------- DR108608 ------------------------ */
            IF REG(OP1) = REG(OP2) THEN DO;                   /*DR108608*/
               CALL EMITRR(LFLI, REG(OP1), 1);                /*DR108608*/
               CALL EMITRR(LFLI, REG(OP1)+1, 0);              /*DR108608*/
               CALL DROP_REG(OP2);                            /*DR108608*/
            END;                                              /*DR108608*/
            ELSE DO;                                          /*DR108608*/
               DECLARE (TEMP1, TEMP2) BIT(16);                                  02729520
               TEMP1 = GET_VAC(FINDAC(DOUBLE_FACC), OPTYPE);
               CALL MOVEREG(REG(OP1), REG(TEMP1), OPTYPE, 0);
               TEMP2 = FINDAC(DOUBLE_FACC);
               IF FORM(OP2) = VAC THEN DO;                                      02729560
                  INST = MAKE_INST(OP, SCALAR, RR);                             02729570
                  CALL EMITRR(INST, REG(OP1), REG(OP2));                        02729580
                  CALL MOVEREG(REG(OP1), TEMP2, OPTYPE, 0);                     02729590
                  CALL EMITRR(MAKE_INST(XEXP, OPTYPE, RR), TEMP2, REG(OP2));    02729600
                  IF FORM(TEMP1) = VAC THEN                                     02729610
                     CALL EMITRR(SDR, TEMP2, REG(TEMP1));                       02729620
                  ELSE CALL EMIT_BY_MODE(MINUS, TEMP2, TEMP1, OPTYPE);          02729630
                  CALL EMITRR(INST, TEMP2, REG(OP2));                           02729640
                  CALL DROP_REG(OP2);                                           02729650
               END;
               ELSE DO;                                                         02729670
                  IF FORM(OP2) = LIT THEN                                       02729680
                     CALL SAVE_LITERAL(OP2, OPTYPE);                            02729690
                  ELSE CALL GUARANTEE_ADDRESSABLE(OP2, INST);                   02729700
                  CALL DROPSAVE(OP2);                                           02729710
                  IF INX(OP2) ^= 0 THEN DO;                                     02729720
                     CALL FORCE_ADDRESS(-1, OP2, 1);                            02729730
                     FORM(OP2) = CSYM;                                          02729740
                     BASE(OP2), BACKUP_REG(OP2) = REG(OP2);                     02729750
                     DISP(OP2), STRUCT_CON(OP2), INX_CON(OP2) = 0;              02729760
                  END;                                                          02729770
                  IF FORM(OP2) = CSYM THEN                                      02729780
                     USAGE(BASE(OP2)) = USAGE(BASE(OP2)) + 4;                   02729790
                  INST = MAKE_INST(OP, SCALAR, RX);                             02729800
                  CALL EMITOP(INST, REG(OP1), OP2);                             02729810
                  CALL MOVEREG(REG(OP1), TEMP2, OPTYPE, 0);                     02729820
                  CALL EMIT_BY_MODE(XEXP, TEMP2, OP2, OPTYPE);                  02729830
                  IF FORM(TEMP1) = VAC THEN                                     02729840
                     CALL EMITRR(SDR, TEMP2, REG(TEMP1));                       02729850
                  ELSE CALL EMIT_BY_MODE(MINUS, TEMP2, TEMP1, OPTYPE);          02729860
                  CALL EMITOP(INST, TEMP2, OP2);                                02729870
               END;                                                             02729880
               CALL EMITRR(SDR, REG(OP1), TEMP2);
               CALL DROPSAVE(TEMP1);
               CALL DROP_VAC(TEMP1);
               USAGE(TEMP2) = 0;
            END;                                              /*DR108608*/
         END;                                                                   02729930
         ELSE                                                                   02729940
            IF BIAS = RR THEN DO;                                               02730000
            IF OP = PREFIXMINUS & OPMODE(OPTYPE) = 3 THEN                       02730010
               CALL ZERO_TEST(REG(OP1), 2);  /* PREVENT GENERATING -0 */        02730020
            ELSE IF OP = XDIV & OPMODE(OPTYPE) = 4 THEN                         02730030
               CALL ZERO_TEST(REG(OP1), 2);  /* PREVENT DIVIDING INTO ZERO */   02730040
            CALL EMITRR(INST, REG(OP1), REG(OP2));                              02730500
            IF ^UNARY(OP) THEN IF OP1 ^= OP2 THEN                               02731000
               CALL DROP_REG(OP2);                                              02731500
         END;                                                                   02732000
         ELSE DO;                                                               02732500
            IF FORM(OP2) = LIT THEN DO;                                         02733000
               IF OPMODE(OPTYPE) = 1 & AP101INST(INST+"60") ^= 0 THEN DO;       02733500
                  INST = INST + "60";                                           02734000
                  FORM(OP2) = 0;                                                02734500
                  LOC(OP2) = VAL(OP2);                                          02735000
               END;                                                             02735500
               ELSE CALL SAVE_LITERAL(OP2, OPTYPE);                             02736000
            END;                                                                02736500
            ELSE CALL GUARANTEE_ADDRESSABLE(OP2, INST);                         02737500
            IF OP = XDIV & OPMODE(OPTYPE) = 4 THEN                              02737510
               CALL ZERO_TEST(REG(OP1), 3);  /* PREVENT DIVIDING INTO ZERO */   02737520
            CALL EMITOP(INST, REG(OP1), OP2);                                   02738000
            CALL DROP_INX(OP2);                                                 02738500
            CALL DROPSAVE(OP2);                                                 02739000
         END;                                                                   02739500
         IF DESTRUCTIVE(OP) THEN                                                02740500
            CALL UNRECOGNIZABLE(REG(OP1));                                      02741000
         BIAS = 0;                                                              02741500
      END ARITH_BY_MODE;                                                        02742000
                                                                                02755500
 /* ROUTINE TO CHECK THAT A SUPPOSED VAC HAS NOT BEEN CHECKPOINTED */           02756000
CHECK_VAC:                                                                      02756500
      PROCEDURE(OP, R);                                                         02757000
         DECLARE (OP, R) BIT(16);                                               02757500
         IF FORM(OP) = WORK THEN DO;                                            02758000
            IF R = 0 THEN                                                       02758500
               REG(OP) = FINDAC(INDEX_REG);                                     02759000
            ELSE DO;                                                            02759500
               CALL CHECKPOINT_REG(R);                                          02760000
               REG(OP) = R;                                                     02760500
            END;                                                                02761000
            CALL EMIT_BY_MODE(LOAD, REG(OP), OP, TYPE(OP));                     02761500
            USAGE(REG(OP)) = 2;                                                 02762000
            CALL DROPSAVE(OP);                                                  02762500
            FORM(OP) = VAC;                                                     02763000
         END;                                                                   02763500
         R = 0;                                                                 02764000
      END;                                                                      02764500
                                                                                02765000
 /* ROUTINE TO MOVE VAC TO DESIRABLE/NON-CONFLICTING REGISTER */                02765500
NEW_REG:                                                                        02766000
      PROCEDURE(PTR, USED);                                                     02766500
         DECLARE (PTR, RTEMP) BIT(16), USED BIT(1);                             02767000
         RTEMP = FINDAC(INDEX_REG);                                             02767500
         CALL MOVEREG(REG(PTR), RTEMP, TYPE(PTR), USED);                        02768000
         CALL SET_REG_NEXT_USE(REG(PTR), PTR);                                   2768100
         REG(PTR) = RTEMP;                                                      02768500
         USED = 0;                                                              02769000
      END NEW_REG;                                                              02769500
                                                                                02770000
 /* ROUTINE TO SHIFT BIT OPERANDS ACCORDING TO STACK SHIFT DESC */              02770500
BIT_SHIFT:                                                                      02771000
      PROCEDURE(OPCODE, R, OP, FLAG);                                           02771500
         DECLARE (OPCODE, R, OP) BIT(16), FLAG BIT(1);                          02772000
         DECLARE TEMPR BIT(16); /*DR108613*/                                    02772000
         IF FORM(OP) = LIT THEN DO;                                             02772500
            IF VAL(OP) ^= 0 THEN                                                02773000
               IF FORM(R) = LIT THEN DO;                                        02773500
               IF OPCODE = SLL THEN VAL(R) = SHL(VAL(R), VAL(OP)&"3F");         02774000
               ELSE VAL(R) = SHR(VAL(R), VAL(OP)&"3F");                         02774500
               LOC(R) = -1;                                                     02774600
            END;                                                                02775000
            ELSE CALL EMITP(OPCODE, REG(R), 0, SHCOUNT, VAL(OP)&"3F");          02775500
         END;                                                                   02776000
         ELSE DO;                                                               02776500
            /*DR108613: DONT CLOBBER TARGET REG TO RTL OR PROCEDURE */          02772000
            TEMPR = TARGET_REGISTER;       /*DR108613*/                         02772000
            TARGET_REGISTER = -1;          /*DR108613*/                         02772000
            CALL CHECK_VAC(OP);                                                 02777000
            TARGET_REGISTER = TEMPR;       /*DR108613*/                         02772000
            CALL EMITP(OPCODE, REG(R), REG(OP), SHCOUNT, 0);                    02778500
            IF ^FLAG THEN                                                       02779000
               CALL DROP_REG(OP);                                                2779500
         END;                                                                   02780000
         IF FORM(R) = VAC THEN CALL UNRECOGNIZABLE(REG(R));                     02780500
         FLAG = 0;                                                              02781000
      END BIT_SHIFT;                                                            02781500
                                                                                02782000
 /* ROUTINE TO MASK BIT OPERANDS ACCORDING TO SIZE  */                          02782500
BIT_MASK:                                                                       02783000
      PROCEDURE(OPCODE, OP, XSIZE, SHIFT);                                      02783500
         DECLARE (OPCODE, OP, XSIZE, SHIFT, PTR, RM) BIT(16);                   02784000
         DECLARE MASK FIXED;                                                    02785000
         IF SHIFT ^= 0 THEN DO;                                                 02785500
            IF FORM(SHIFT) = LIT THEN DO;                                       02786000
               MASK = SHL(XITAB(XSIZE), VAL(SHIFT));                            02786500
               SHIFT = 0;                                                       02787000
            END;                                                                02787500
            ELSE MASK = XITAB(XSIZE);                                           02788000
         END;                                                                   02788500
         ELSE MASK = XITAB(XSIZE);                                              02789000
         PTR = GET_INTEGER_LITERAL(MASK);                                       02789500
         TYPE(PTR) = INTEGER | (TYPE(OP) & 8);                                  02790000
         IF SHIFT ^= 0 THEN DO;                                                 02790500
            RM = GET_VAC(-1, FULLBIT);                                          02791000
            IF FORM(RM) = VAC THEN NOT_THIS_REGISTER2 = REG(RM);  /*DR111358*/
            CALL INCR_REG(RM);                                                   2791500
            CALL LOAD_NUM(REG(RM), VAL(PTR), TYPE(PTR) & 8 | 1);                02792000
            CALL BIT_SHIFT(SLL, RM, SHIFT);                                     02792500
            CALL CHECK_VAC(OP);                                                 02793000
            CALL ARITH_BY_MODE(OPCODE, OP, RM, TYPE(RM));                       02793500
            NOT_THIS_REGISTER2 = -1;                              /*DR111358*/
            CALL DROP_VAC(RM);                                                  02794000
         END;                                                                   02794500
         ELSE CALL ARITH_BY_MODE(OPCODE, OP, PTR, TYPE(PTR));                   02795000
         CALL RETURN_STACK_ENTRY(PTR);                                          02795500
         SHIFT = 0;                                                             02796000
      END BIT_MASK;                                                             02796500
                                                                                02797000
 /* ROUTINE TO CREATE BIT LITERAL, SHIFTED, SUITABLE FOR GIVEN OPCODE */        02797500
MAKE_BIT_LIT:                                                                   02798000
      PROCEDURE(OPC, VALUE, OP) BIT(16);                                        02798500
         DECLARE (OPC, OP, PTR) BIT(16), VALUE FIXED;                           02799000
         PTR = GET_STACK_ENTRY;                                                 02799500
         TYPE(PTR) = TYPE(OP);                                                  02800000
         SIZE(PTR) = SIZE(OP);                                                  02800500
         FORM(PTR) = LIT;                                                       02801000
         LOC(PTR) = -1;                                                         02801500
         IF COLUMN(OP) = 0 THEN                                                 02802000
            VAL(PTR) = VALUE;                                                   02802500
         ELSE IF OPC = AND THEN DO;                                             02803000
            VAL(PTR) = ^VALUE & XITAB(SIZE(PTR));                               02803500
            CALL BIT_SHIFT(SLL, PTR, COLUMN(OP));                               02804000
            VAL(PTR) = ^VAL(PTR);                                               02804500
         END;                                                                   02805000
         ELSE DO;                                                               02805500
            VAL(PTR) = VALUE;                                                   02806000
            CALL BIT_SHIFT(SLL, PTR, COLUMN(OP));                               02806500
         END;                                                                   02807000
         RETURN PTR;                                                            02807500
      END MAKE_BIT_LIT;                                                         02808000
                                                                                 2808050
 /* ROUTINE TO DETERMINE IF BIT POSITIONING IS NECESSARY */                      2808100
BIT_PICK:                                                                        2808150
      PROCEDURE(OP);                                                             2808200
         DECLARE OP BIT(16);                                                     2808250
         IF CVTTYPE(TYPE(OP)) THEN RETURN COLUMN(OP);                            2808300
         RETURN 0;                                                               2808350
      END BIT_PICK;                                                              2808400
                                                                                02808500
 /* ROUTINE TO INCORPORATE INTEGER CONSTANTS INTO TERMS  */                     02809000
INCORPORATE:                                                                    02809500
      PROCEDURE(OP, BITS_ONLY);                                                  2810000
         DECLARE (OP, LITOP, OPER) BIT(16), USG FIXED;                          02810500
         DECLARE BITS_ONLY BIT(1);                                               2810600
         IF BIT_PICK(OP) > 0 THEN DO;                                            2811000
            LITOP = COLUMN(OP);                                                 02811500
            CALL BIT_SHIFT(SRL, OP, LITOP);                                     02812000
            IF DEL(OP) ^= AND THEN IF FORM(LITOP) ^= LIT |                      02812500
               VAL(LITOP)+SIZE(OP) ^= BIGHTS(FULLBIT)*BITESIZE THEN              2813000
               CALL BIT_MASK(AND, OP, SIZE(OP));                                02814000
            ELSE CALL EMIT_NOP;                                                 02814100
            CALL RETURN_STACK_ENTRY(LITOP);                                     02814500
            COLUMN(OP) = 0;                                                     02815000
         END;                                                                   02815500
         IF ^BITS_ONLY THEN                                                      2815600
 /*-------------------- DANNY DR103422 ----------------------------*/           02816000
 /* CHECK STRUCT_CON; SUBSCRIPT_RANGE_CHECK WILL HAVE SET IT TO 1  */           02816010
 /* SO A 0 WILL BE LOADED INTO AN INDEX REGISTER                   */           02816020
 /* FOR REFERENCING THE 1ST NODE OF A REMOTE SINGLE-COPY STRUCTURE */           02816030
            IF (CONST(OP) | STRUCT_CON(OP) | DEL(OP)) ^= 0 THEN DO;             02816040
 /*----------------------------------------------------------------*/           02816050
            LITOP = GET_INTEGER_LITERAL(CONST(OP));                             02816500
            IF DEL(OP) > 0 THEN                                                 02817000
               OPER = DEL(OP);                                                  02817500
            ELSE IF REG(OP) < 0 THEN DO;                                        02818000
               REG(OP) = SEARCH_REGS(LITOP);                                    02818500
               IF REG(OP) < 0 THEN DO;                                          02819000
                  REG(OP) = FINDAC(INDEX_REG);                                  02820500
                  OPER = LOAD;                                                  02821000
               END;                                                             02821500
               ELSE DO;                                                         02822000
                  CALL INCR_REG(OP);                                             2822500
                  OPER = TEST;                                                  02823000
               END;                                                             02823500
            END;                                                                02824000
            ELSE OPER = SUM;                                                    02824500
            IF OPER ^= TEST THEN DO;                                            02828000
               USG = USAGE(REG(OP)) & DEL(OP)=0;                                02828500
               IF CONST(OP) = -1 & OPER = SUM & OPMODE(TYPE(OP)) = 1 THEN       02829000
                  CALL EMITP(BCTB, REG(OP), 0, LOCREL, 1);                      02829500
               ELSE CALL ARITH_BY_MODE(OPER, OP, LITOP, TYPE(OP));              02830000
               R_CON(REG(OP)) = R_CON(REG(OP)) + CONST(OP);                     02830500
               USAGE(REG(OP)) = USAGE(REG(OP)) | USG;                           02831000
               IF USG THEN CALL CLEAR_INX(REG(OP));                              2831100
            END;                                                                02831500
            CONST(OP), DEL(OP) = 0;                                             02832000
         /* DR109090 - REMEMBER THAT THE INDEX LOADED IS A LITERAL */
         /* SO THAT UNNECESSARY SHIFTING CAN BE AVOIDED IF IT IS 0.*/
            IF OPER = LOAD                   /* DR109090 */
               THEN R_CONTENTS(REG(OP))=LIT; /* DR109090 */
            CALL RETURN_STACK_ENTRY(LITOP);                                     02832500
         END;                                                                   02833000
         BITS_ONLY = FALSE;                                                      2833100
      END INCORPORATE;                                                          02833500

 /*------------------------------------------------------------------*/
 /* SUBROUTINE TO VERIFY THAT DISPLACEMENT ADJUSTMENT IS ADDRESSABLE */         02834500
 /*                                                                  */
 /* PARAMETERS:                                                      */
 /*            OP - INDIRECT STACK ENTRY OF THE ENTRY BEING          */
 /*                 SUBSCRIPTED                                      */
 /* NEED_INDEXING - TELLS COMPILER TO SETUP "LHI R,0" WHEN NO OTHER  */
 /*                 INDEX IS NEEDED (DR103659)                       */
 /* NO_AIA_SHIFT  - DO NOT PERFORM AIA SHIFTING OF THE VALUE TO BE   */
 /*                 LOADED OR ADDED TO THE INDEX REGISTER (DR109019) */
 /*------------------------------------------------------------------*/
SUBSCRIPT_RANGE_CHECK:                                                          02835000
      PROCEDURE(OP,NEED_INDEXING,NO_AIA_SHIFT);                                 02835500
         DECLARE OP BIT(16);                                                    02836000
         DECLARE NEED_INDEXING BIT(1);      /*DR103422*/                        02836110
         DECLARE NO_AIA_SHIFT  BIT(1);      /*DR109019*/                        02836110
         DECLARE INCOP BIT(16), (CON, RANGE) FIXED, REMOTE BIT(1);              02836000
         DECLARE DELTA BIT(16);                                                 02836100
         DECLARE OLD_CON FIXED;                        /*CR12385*/
      /* CR13222- POW_OF_2 IS NOW GLOBAL IN ##DRIVER     DR109019*/
         IF PACKFORM(FORM(OP)) = 2 THEN RETURN;                                 02836500
         DELTA = 2047;                                                          02836600
         IF FORM(OP) = SYM THEN                                                 02837000
            DO;                                                                 02837500
            IF (SYT_FLAGS(LOC(OP)) & POINTER_OR_NAME) ^= 0 THEN                 02838000
               RANGE = 0;                                                       02838500
            ELSE DO;                                                            02839000
               RANGE = -SYT_DISP(LOC(OP));                                      02839010
               IF SYT_BASE(LOC(OP)) = PROGBASE THEN                             02839020
                  DELTA = DELTA - 112;                                          02839030
            END;                                                                02839040
         END;                                                                   02839500
         ELSE RANGE = -DISP(OP);                                                02840000
         CON = INX_CON(OP);                                                     02840500
         REMOTE = CHECK_REMOTE(OP);                                             02841000

      /* SET UP 0 INDEX FOR ALL NAME REMOTE DEREFERENCES.    CR12432 */
      /* THIS IS NEEDED BECAUSE A NAME SINGLE CAN BE MADE    CR12432 */
      /* TO POINT TO NAME AGGREGATE,SO ITS INDEX INHIBIT(XC) CR12432 */
      /* BIT WILL BE CLEAR. IF NAME SINGLE POINTS TO SINGLE, CR12432 */
      /* THEN THE XC BIT WILL BE SET & INDEX IS IGNORED.     CR12432 */
      /* (NR_DEREF(OP) WONT BE SET YET BECAUSE THE INDEX IS  CR12432 */
      /* LOADED 1ST, UNLESS THIS IS RNR ON THE STACK.)       CR12432 */
         IF ^DECLMODE THEN                                /* CR12432 */
         IF INX(OP)=0 THEN /* DONT ALREADY HAVE INDEX */  /* CR12432 */
      /* DONT NEED 0 INDEX WHEN IN NAME OPERATION */      /* CR12432 */
         IF ^(NAME_FUNCTION(OP) & TAG2(1)) THEN           /* CR12432 DR111390*/
         IF (SYMFORM(FORM(OP)) | (FORM(OP)=NRTEMP)) &     /* CR12432 */
            DEREF(OP) THEN                                /* CR12432 */
            IF ((SYT_FLAGS(LOC(OP)) & NAME_OR_REMOTE)     /* CR12432 */
               = NAME_OR_REMOTE) | NR_DEREF(OP)           /* CR12432 */
      /* TREAT REFERENCING A FORMAL REMOTE PARAMETER        CR12935*/           52650000
      /* PASSED BY REFERENCE LIKE A NAME REMOTE DEREFERENCE CR12935*/           52660000
            | ( ((SYT_FLAGS(LOC(OP)) & POINTER_FLAG)^=0)& /*CR12935*/           52670000
                ((SYT_FLAGS(LOC(OP)) & REMOTE_FLAG)^=0) ) /*CR12935*/           52680000
               THEN NEED_INDEXING = TRUE;                 /* CR12432 */
 /*-------------------- DANNY DR103422 ----------------------------*/           02841500
 /*-- DR103659 -- REVISE THIS STATEMENT TO PRESERVE THE VALUE OF   */           02841500
 /*-- NEED_INDEXING IF IT WAS PASSED IN AS TRUE.                   */           02841500
         IF ^(CON = 0 | INX(OP) = 0 & ^REMOTE)                                  02841510
            THEN NEED_INDEXING = TRUE;                                          02841520
 /* SPECIAL CASE WHEN CON=0: IF REFERENCING THE 1ST ELEMENT OF     */           02841540
 /* A REMOTE SINGLE-COPY STRUCTURE, ITS INDEXING IS NOT INHIBITED, */           02841550
 /* SO WE DO NEED INDEXING (ITS INDEX WILL BE 0). NEED_INDEXING    */           02841560
 /* WILL BE PASSED IN AS TRUE IF THIS IS THE CASE, WHICH WILL      */           02841570
 /* FORCE A LHI RX,0 INSTRUCTION HERE. NEED_INDEXING IS PASSED IN  */           02841580
 /* FROM EITHER FORCE_ACCUMULATOR, STRUCTURE_DECODE, OR GEN_STORE. */           02841580
         IF ^NEED_INDEXING THEN DO;                                             02841690
            NO_AIA_SHIFT=FALSE;             /*DR109019*/
            RETURN;
         END;
         NEED_INDEXING = 0; /*DR103659 -- RESET NEED_INDEXING*/                 02841690
 /*--------------------------------------------------------------*/             02841700
 /* IF DATA IS REMOTE OR CON IS OUTSIDE THE POSSIBLE DISPLACEMENT, */
 /* IT CANNOT BE ADDED INTO THE OFFSET. SO WE MUST LOAD AN INDEX   */
 /* REGISTER.                                                      */
         IF REMOTE | CON < RANGE |                                              02842000
            CON > RANGE+DELTA THEN DO;                                          02842500
            INCOP = GET_STACK_ENTRY;                                            02843000
            /*----------------DR109019---------------------------*/
            /* USE AIA_SHIFT_AMOUNT TO DETERMINE THE AIA FACTOR. */
            /* SET THE FLAG TO "TRUE" TO SHOW THAT THE VALUE IS  */
            /* ADJUSTED, AND SAVE THE AMOUNT IT IS SHIFTED BY.   */
            /* DIVIDE THE VALUE BY THE APPROPRIATE POWER OF 2.   */
            /* THE SHIFTING VALUE WAS DOUBLED BEFORE SAVING      */
            /* INTO AIA_ADJUSTED IN ORDER TO MAKE ROOM FOR THE   */
            /* "TRUE" BIT. IT WILL BE HALFED BEFORE IT'S USED.   */
            /*---------------------------------------------------*/
            IF SELF_ALIGNING THEN                                               02843500
         /* DR109090 - NO AIA ADJUSTMENT NECESSARY IF 0 IS LOADED */
            IF CON ^= 0 THEN /* DR109090 */
               DO; /* PERFORM AUTO INDEX ALIGNMENT */                              02844
                  IF (NO_AIA_SHIFT) THEN RANGE = 0;
                  ELSE RANGE = AIA_SHIFT_AMOUNT(OP);
                  AIA_ADJUSTED(OP)=TRUE + (RANGE*2);
                  RANGE=POW_OF_2(RANGE);
                  OLD_CON = CON;                       /*CR12385*/
                  CON = CON/RANGE;
                  IF (OLD_CON ^= (RANGE*CON)) THEN     /*CR12385*/
                     CALL ERRORS(CLASS_BI, 513);       /*CR12385*/
            END;                                                                02845500
            CONST(INCOP) = CON;                                                 02846000
            TYPE(INCOP) = INTEGER;                                              02846500
        /* TO CAUSE A NEW INDEX LOAD */
            IF INX(OP) = 0 THEN REG(INCOP) = -1;                                02847000
            ELSE IF INX(OP) < 0 THEN DO;                                        02847100
        /* INDEX VALUE EXISTS, BUT NOT LOADED */
               CALL RELOAD_ADDRESSING(-1,OP,0);                                 02847200
               REG(INCOP) = INX(OP);                                            02847300
               CALL UNRECOGNIZABLE(REG(INCOP));                                 02847400
            END;                                                                02847500
            ELSE IF USAGE(INX(OP)) > 3 THEN DO;                                 02847600
        /* INDEX VALUE IS LOADED, BUT OTHER OPERATION NEEDS IT */
        /* SO COPY IT TO A NEW REGISTER */
               REG(INCOP) = FINDAC(INDEX_REG);                                  02848000
               CALL MOVEREG(INX(OP), REG(INCOP), INTEGER, 1);                   02848500
               USAGE_LINE(INX(OP)) = INX_NEXT_USE(OP);                           2848600
            END;                                                                02849000
        /* OTHERWISE, USE VALUE IN INX(OP) REGISTER */
            ELSE REG(INCOP) = INX(OP);                                          02849500

            /*-------------------- DANNY DR103422 --------------------------*/  02849510
            /* SET STRUCT_CON TO 1 SO INCORPORATE WILL KNOW TO LOAD A 0 IN  */  02849520
            /* AN INDEX REGISTER IN ORDER TO SUCCESSFULLY REFERENCE NODE 1  */  02849530
            /* OF A REMOTE SINGLE-COPY STRUCTURE                            */  02849540
            /*--------------------------------------------------------------*/  02849560
            IF CON=0 THEN STRUCT_CON(INCOP) = 1;    /*DR103422*/                02849550
        /* PUT CON INTO INX(OP) REGISTER:   */
        /*   IF IT IS A NEW LOAD: USES LHI  */
        /*   IF INX(OP) EXISTS: USES AHI    */
            CALL INCORPORATE(INCOP);                                            02850000
            INX(OP) = REG(INCOP);                                               02850500
            CALL RETURN_STACK_ENTRY(INCOP);                                     02851000
            INX_CON(OP), INX_NEXT_USE(OP) = 0;                                   2851500
         END;                                                                   02852000
         NO_AIA_SHIFT=FALSE;             /*DR109019*/
      END SUBSCRIPT_RANGE_CHECK;                                                02852500
                                                                                02853000
 /* ROUTINE TO GUARANTEE THAT INTEGERIZABLE SCALAR HAS NO FRACTIONAL PART */    02853500
INTEGER_VALUED:                                                                 02854000
      PROCEDURE;                                                                02854500
         CALL INLINE("2B", 2, 2);                              /* SDR 2,2 */    02855000
         CALL INLINE("2A", 0, 2 );                             /* ADR 0,2 */    02855500
 /* 0 HAD UNNORMALIZED RESULT FROM INTEGERIZABLE */                             02856000
         CALL INLINE("58", 1, 0, FOR_DW);              /* L   1,DW  */          02856500
        CALL INLINE("69", 0, 0, 1, 0);                        /* CD  0,0(0,1) */02857000
         CALL INLINE("41", 3, 0, 0, 1);                        /* LA  3,1 */    02857500
         CALL INLINE("05", 14, 0);                             /* BALR 14,0 */  02858000
        CALL INLINE("47", 8, 0, 14, 6);                       /* BC  8,6(,14) */02858500
         RETURN INLINE("1B", 3, 3);                            /* SR  3,3 */    02859000
      END INTEGER_VALUED;                                                       02859500
                                                                                02860000
 /* ROUTINE TO COMPUTE THE INTEGRAL VALUE OF A NUMERIC LITERAL */               02860500
INTEGER_VALUE:                                                                  02861000
      PROCEDURE(PTR) FIXED;                                                     02861500
         DECLARE PTR BIT(16);                                                   02862000
         IF FORM(PTR) ^= LIT THEN RETURN NEGMAX;                                02862500
         IF DATATYPE(TYPE(PTR)) = INTEGER THEN RETURN VAL(PTR);                 02863000
         DW(0) = VAL(PTR);                                                      02863500
         DW(1) = XVAL(PTR);                                                     02864000
         IF INTEGERIZABLE THEN IF INTEGER_VALUED THEN RETURN DW(3);             02864500
         RETURN NEGMAX;                                                         02865000
      END INTEGER_VALUE;                                                        02865500
                                                                                02866000
 /* ROUTINE TO DETERMINE IF STACK ENTRY IS CONSTANT INTEGER POWER OF TWO */     02866500
POWER_OF_TWO:                                                                   02867000
      PROCEDURE(OP) BIT(1);                                                     02867500
         DECLARE OP BIT(16), TEST FIXED;                                        02868000
         IF FORM(OP) ^= LIT THEN RETURN FALSE;                                  02868500
         TEST = INTEGER_VALUE(OP);                                              02869000
         IF TEST <= 0 THEN RETURN FALSE;                                        02869500
         INX_SHIFT(0) = 0;                                                      02870000
         DO WHILE ^TEST;                                                        02870500
            INX_SHIFT(0) = INX_SHIFT(0) + 1;                                    02871000
            TEST = SHR(TEST, 1);                                                02871500
         END;                                                                   02872000
         RETURN TEST = 1;                                                       02872500
      END POWER_OF_TWO;                                                         02873000
                                                                                02873500
 /* ROUTINE TO MULTIPLY BY LOWER LEVEL SUBSCRIPT  */                            02874000
SUBSCRIPT_MULT:                                                                 02874500
      PROCEDURE(OP, VALUE);                                                     02875000
         DECLARE (OP, LITOP) BIT(16), VALUE FIXED;                              02877000
         IF OP=0 THEN RETURN;                                                   02877500
         INX_MUL(OP) = 1;                                                       02878000
         IF VALUE = 1 THEN RETURN;                                              02878500
         IF USAGE(REG(OP)) > 3 THEN                                             02879000
            CALL NEW_REG(OP, 1);                                                02879500
         IF VALUE < 0 THEN DO;                                                  02880000
            LITOP = SET_ARRAY_SIZE(-VALUE, 2);                                  02880500
            CALL CHECK_ADDR_NEST(-1, LITOP);                                    02881000
            /* REMOVED MIH INSTRUCTION CODE - DR111364*/
               CALL EMITOP(MH, REG(OP), LITOP);                                 02883000
               CALL EMITP(SLL, REG(OP), 0, SHCOUNT, 15);                        02883500
         END;                                                                   02884500
         ELSE DO;                                                               02885000
            LITOP=GET_INTEGER_LITERAL(VALUE);                                   02885500
            IF POWER_OF_TWO(LITOP) THEN DO; /*DR111364*/                        02886000
            /* REMOVED AR INSTRUCTION CODE -  DR111364*/
               CALL EMITP(SLA, REG(OP), 0, SHCOUNT, INX_SHIFT(0));              02887000
            END;                                                                02887500
            /* REMOVED MIH INSTRUCTION CODE - DR111364*/
            ELSE DO;                                                            02890000
               CALL EMITP(MHI, REG(OP), 0, 0, VAL(LITOP));                      02890500
               CALL EMITP(SLL, REG(OP), 0, SHCOUNT, 15);                        02891000
            END;                                                                02892000
         END;                                                                   02892500
         CALL UNRECOGNIZABLE(REG(OP));                                          02893500
         CALL RETURN_STACK_ENTRY(LITOP);                                        02894000
/*----------------------- DR108609    PMA    5/25/93 -----------------------*/
/* SET REGISTER TYPE TO INTEGER, SINCE THE RESULT OF MULTIPLICATION         */
/* IS ALWAYS SINGLE PRECISION                                               */
         R_TYPE(REG(OP))=INTEGER;
/*--------------------------------------------------------------------------*/
      END SUBSCRIPT_MULT;                                                       02894500
                                                                                02895000
 /* ROUTINE TO ALIGN INDEX VALUES IF NO SELF ALIGNMENT IS PRESENT */            02895500
FIX_TERM_INX:                                                                   02896000
      PROCEDURE(OP, PTR);                                                       02896500
         DECLARE (OP, PTR) BIT(16);                                             02897000
         IF ^SELF_ALIGNING THEN DO;                                             02897500
         CALL SUBSCRIPT_MULT(PTR,SHL(INX_MUL(PTR),SHIFT(TYPE(OP))-INX_SHIFT(PTR)02898000
               ));                                                              02898500
            R_INX_SHIFT(REG(PTR)) = SHIFT(TYPE(OP));                            02899500
         END;                                                                   02900000
         ELSE CALL SUBSCRIPT_MULT(PTR, INX_MUL(PTR));                           02900500
         RETURN REG(PTR);                                                       02901000
      END FIX_TERM_INX;                                                         02901500
                                                                                02902000
 DECLARE SSTAR_FLAG BIT(1) INITIAL(FALSE);   /*DR111337*/
 /* ROUTINE TO GENERATE 1,1,1 INDEX FROM 0,0,0 REFERENCE  */                    02902500
TRUE_INX:                                                                       02903000
      PROCEDURE(OP, CON, FLAG);                                                 02903500
         DECLARE (OP, CON, LITOP) BIT(16), FLAG BIT(1);                         02904000
         IF SYMFORM(FORM(OP)) | INX(OP) ^= 0 THEN DO;                           02904500
          IF HALMAT_OPCODE="5B"&TAG=4 & SSTAR_FLAG THEN   /*CR13570,DR111337*/
           IF SYT_TYPE(LOC(OP))=STRUCTURE & SYT_ARRAY(LOC(OP))^=0 /*DR111337*/
              THEN CALL ERRORS(CLASS_ZC,1);                       /*DR111337*/
          IF STRUCT_INX(OP)=0 | (STRUCT_INX(OP)>=4|INX(OP)^=0) & COPY(OP)>0 THEN02905000
               DO;                                                              02905010
               IF MAJOR_STRUCTURE(OP) THEN                                      02905500
                  INX_CON(OP) = INX_CON(OP) - SYT_CONST(LOC(OP));               02906000
            ELSE IF TYPE(OP)=CHAR & SIZE(OP)<0 & SYT_CONST(LOC2(OP))^=0 THEN DO;02906500
                  LITOP = GET_VAC(-1);                                          02907000
                  CALL LOAD_NUM(REG(LITOP), -SYT_CONST(LOC2(OP)));              02907500
                  CALL SUBSCRIPT_MULT(LITOP, SIZE(OP));                         02908000
                  INX(OP) = REG(LITOP);                                         02908500
                  INX_NEXT_USE(OP) = 0;                                          2908600
                  CALL RETURN_STACK_ENTRY(LITOP);                               02909000
               END;                                                             02909500
 /************** DR54123 START ************/
               ELSE IF SYT_TYPE(LOC(OP)) = STRUCTURE THEN                       02910000
                  DO;                                                           02910050
                  INX_CON(OP) = INX_CON(OP) - SYT_CONST(LOC(OP))                02910100
                     - SYT_CONST(LOC2(OP));                                     02910200
                  IF SYT_CONST(LOC(OP)) ^= 0 THEN DO;                           02910214
 /*    OUTPUT = '******** CHECK STATEMENT # ' || LINE# */                       02910228
 /*       || ' FOR BAD STRUCT'; */                                              02910242
                     CALL ERRORS(CLASS_ZC,1,''||LINE#); /* ISSUE ZC1 */         02910256
                  END;                                                          02910270
 /*************** DR54123 FINISH *********/
               END;                                                             02910284
               ELSE INX_CON(OP) = INX_CON(OP) - SYT_CONST(LOC2(OP));            02910300
            END;                                                                02910500
            ELSE IF PACKTYPE(TYPE(OP)) = VECMAT THEN                            02911000
               INX_CON(OP) = INX_CON(OP) + BIGHTS(TYPE(OP));                    02911500
         END;                                                                   02912000
         ELSE IF PACKTYPE(TYPE(OP)) = VECMAT THEN                               02912500
            INX_CON(OP) = BIGHTS(TYPE(OP));                                     02913000
         ELSE INX_CON(OP) = 0;                                                  02913500
         INX_CON(OP) = INX_CON(OP) + CON;                                       02914000
         IF ^FLAG THEN                                                          02914500
            CALL SUBSCRIPT_RANGE_CHECK(OP);                                     02915000
         CON, FLAG = 0;                                                         02915500
      END TRUE_INX;                                                             02916000
                                                                                02916500
 /* ROUTINE TO VERIFY INDEX USAGES ARE SAFE */                                  02917000
UPDATE_INX_USAGE:                                                               02917500
      PROCEDURE(OP);                                                            02918000
         DECLARE OP BIT(16);                                                    02918500
         IF USAGE(REG(OP)) > 1 & TO_BE_MODIFIED THEN DO;                        02919000
            CALL NEW_REG(OP);                                                   02919500
         END;                                                                   02920000
         ELSE DO;                                                               02920500
            CALL INCR_REG(OP);                                                   2921000
         END;                                                                   02922000
         TO_BE_MODIFIED = FALSE;                                                02922500
      END UPDATE_INX_USAGE;                                                     02923000
                                                                                02923500
 /* ROUTINE TO LOAD OR MODIFY CURRENT INDEX BY ARRAY LOOP INDEX  */             02924000
ARRAY_INDEX_MOD:                                                                02924500
      PROCEDURE(OP, INDEX, SHIFTCT) BIT(16);                                    02925000
         DECLARE (OP, INDEX, SHIFTCT, I) BIT(16);                               02925500
         IF INDEX = 0  THEN GO TO RETURN_OP;                                    02926000
         IF SELF_ALIGNING THEN SHIFTCT = 0;                                     02926500
         IF OP = 0 THEN DO;                                                     02927000
            OP = GET_STACK_ENTRY;                                               02927500
            FORM(OP) = AIDX;                                                    02928000
            LOC(OP) = INDEX;                                                    02928500
            TYPE(OP) = INTEGER;                                                 02929000
            INX_SHIFT(OP) = SHIFTCT;                                            02929500
            NEXT_USE(OP) = FORM(INDEX) = VAC;                                    2929600
            DO I = 0 TO SHIFTCT^=0;                                             02930000
               REG(OP) = SEARCH_REGS(OP);                                       02930500
               IF REG(OP) >= 0 THEN DO;                                         02931000
                  CALL UPDATE_INX_USAGE(OP);                                    02931500
                  GO TO FOUND_AIDX;                                             02932000
               END;                                                             02932500
               INX_SHIFT(OP) = 0;                                               02933000
               TO_BE_MODIFIED = TRUE;                                           02933500
            END;                                                                02934000
            REG(OP) = FINDAC(INDEX_REG);                                        02934500
            CALL EMITOP(LH, REG(OP), INDEX);                                    02935000
            CALL SET_USAGE(REG(OP), AIDX, INDEX);                                2935500
            NEXT_USE(OP) = 0;                                                    2935600
FOUND_AIDX:                                                                     02937000
            FORM(OP) = VAC;                                                     02937500
            LOC2(OP) = -1;                                                       2937600
         END;                                                                   02938000
         ELSE DO;                                                               02938500
            INX_SHIFT(0) = 0;                                                   02939000
            FORM(0) = AIDX;                                                     02939500
            LOC(0) = INDEX;                                                     02940000
            TYPE(0) = INTEGER;                                                  02940500
            REG(0) = SEARCH_REGS(0);                                            02941000
            IF REG(0) >= 0 THEN                                                 02941500
               CALL EMITRR(AR, REG(OP), REG(0));                                02942000
            ELSE CALL EMITOP(AH, REG(OP), INDEX);                               02942500
            CALL UNRECOGNIZABLE(REG(OP));                                       02943000
            IF NEXT_USE(OP) = 1 THEN NEXT_USE(OP) = 0;                           2943100
         END;                                                                   02943500
RETURN_OP:                                                                      02944000
         TO_BE_MODIFIED, SHIFTCT = 0;                                           02944500
         RETURN OP;                                                             02945000
      END ARRAY_INDEX_MOD;                                                      02945500
                                                                                02946000
 /* ROUTINE TO CHECK FOR TWO-DIMENSIONAL ARRAY INDEXING */                      02946500
ARRAY2_INDEX_MOD:                                                               02947000
      PROCEDURE(OP, INDEX1, SHIFTCT, MULT, INDEX2);                             02947500
         DECLARE (OP, INDEX1, SHIFTCT, MULT, INDEX2, OPX, I) BIT(16);           02948000
         IF SELF_ALIGNING THEN SHIFTCT = 0;                                     02948500
         IF OP = 0 THEN DO;                                                     02949000
            OPX = GET_STACK_ENTRY;                                              02949500
            FORM(OPX) = AIDX2;                                                  02950000
            LOC(OPX) = INDEX1;                                                  02950500
            LOC2(OPX) = INDEX2;                                                 02951000
            TYPE(OPX) = INTEGER;                                                02951500
            INX_SHIFT(OPX) = SHIFTCT;                                           02952000
            XVAL(OPX) = MULT;                                                   02952500
            DO I = 0 TO SHIFTCT ^= 0;                                           02953000
               REG(OPX) = SEARCH_INDEX2(OPX);                                   02953500
               IF REG(OPX) >= 0 THEN DO;                                        02954000
                  CALL UPDATE_INX_USAGE(OPX);                                   02954500
                  LOC2(OPX) = -1;                                                2954600
                  FORM(OPX) = VAC;                                              02955000
                  RETURN OPX;                                                   02955500
               END;                                                             02956000
               INX_SHIFT(OPX) = 0;                                              02956500
               TO_BE_MODIFIED = TRUE;                                           02957000
            END;                                                                02957500
            CALL RETURN_STACK_ENTRY(OPX);                                       02958000
         END;                                                                   02958500
         OPX = ARRAY_INDEX_MOD(OP, INDEX1);                                     02959000
         CALL SUBSCRIPT_MULT(OPX, MULT);                                        02959500
         OPX = ARRAY_INDEX_MOD(OPX, INDEX2);                                    02960000
         IF OP = 0 THEN DO;                                                     02960500
            I = REG(OPX);                                                       02961000
            CALL SET_USAGE(I, AIDX2, INDEX1);                                    2961500
            R_VAR2(I) = INDEX2;                                                 02963000
            R_MULT(I) = MULT;                                                   02963500
         END;                                                                   02964000
         RETURN OPX;                                                            02964500
      END ARRAY2_INDEX_MOD;                                                     02965000
                                                                                02965500
 /* ROUTINE TO SET UP INDEXING FOR UNSUBSCRIPTED VARIABLE  */                   02966000
FREE_ARRAYNESS:                                                                 02966500
      PROCEDURE(OP, FLAG);                                                      02967000
         DECLARE (OP, I, J, K, L) BIT(16), (PTR, SPTR) FIXED, FLAG BIT(1);      02967500
         DECLARE NO_AIA_SHIFT BIT(1);        /*DR109019*/
         PTR, SPTR = 0;                                                         02968000
         L = STRUCT_INX(OP) & 1;                                                02968500
         IF FLAG = 0 THEN DO;                                                   02969000
            IF DOCOPY(CALL_LEVEL) ^= 0 THEN IF COPY(OP) ^= 0 THEN DO;           02969500
               J = STACK#;                                                      02970000
               K = L + 1;                                                       02970500
               IF COPY(OP) > 0 THEN                                             02971000
                  DO CASE DOFORM(CALL_LEVEL);                                   02971500
                  DO CASE STRUCT(OP);                                           02972000
                     DO;   /* CASE 0: ARRAY */                                  02972500
                        IF COPY(OP) = 1 & SUBLIMIT(J+1) = 1 THEN                02973000
                        PTR = ARRAY_INDEX_MOD(PTR, DOINDEX(DOPTR(CALL_LEVEL)+K),02973500
                           SHIFT(TYPE(OP)));                                    02974000
                        ELSE IF COPY(OP) = 2 & SUBLIMIT(J+2) = 1 THEN DO;       02974500
                           I = DOPTR(CALL_LEVEL) + K;                           02975000
                        PTR = ARRAY2_INDEX_MOD(PTR, DOINDEX(I), SHIFT(TYPE(OP)),02975500
                              SUBLIMIT(J+1), DOINDEX(I+1));                     02976000
                        END;                                                    02976500
                        ELSE DO I = DOPTR(CALL_LEVEL)+K TO DOTOT(CALL_LEVEL);   02977000
                           J = J + 1;                                           02977500
                           TO_BE_MODIFIED = TRUE;                               02978000
                           PTR = ARRAY_INDEX_MOD(PTR, DOINDEX(I));              02978500
          /*DR111386-ADD THE CONSTANT DISPLACEMENT FOR CHARACTER(*) VARIABLES*/
          /*DR111386-DIVIDE OFF THE INCORRECT SYT_COPIES MULTIPLICATION FIRST*/
          /*DR111386*/     IF (SUBLIMIT(J) < 0) & (INX_CON(OP) < 0) THEN DO;
          /*DR111386*/        CALL EMITP(AHI, REG(PTR), 0, 0,
          /*DR111386*/           INX_CON(OP)/SUBLIMIT(J));
          /*DR111386*/        INX_CON(OP) = 0;
          /*DR111386*/     END;
                           CALL SUBSCRIPT_MULT(PTR, SUBLIMIT(J));               02979000
                        END;                                                    02979500
           /* TO ALIGN INDEX VALUE IF NO SELF ALIGNMENT IS PRESENT */
                        CALL FIX_TERM_INX(OP, PTR);                              2980000
                        COPY(OP) = 0;                                           02980500
                        CALL FIX_STRUCT_INX(PTR, OP);                            2981000
                     END;                                                       02985500
                     DO;   /* CASE 1: STRUCTURE WITH COPIES */                  02986000
                     SPTR = ARRAY2_INDEX_MOD(SPTR, DOINDEX(DOPTR(CALL_LEVEL)+1), 2986500
                           0, SUBLIMIT(J), 0);                                   2986510
                        INX(OP) = REG(SPTR);                                    02988000
                        INX_NEXT_USE(OP) = NEXT_USE(SPTR);                       2988100
                        CALL RETURN_STACK_ENTRY(SPTR);                          02988500
                        STRUCT(OP) = 0;                                         02989000
                        COPY(OP) = COPY(OP) - 1;                                02989500
                        STRUCT_INX(OP) = 5;                                      2990000
                     END;                                                       02990500
                  END;                                                          02991000
                  DO CASE STRUCT(OP);                                           02991500
                     DO;   /* ARRAY */                                          02992000
                        DO I = DOPTR(CALL_LEVEL)+1 TO DOTOT(CALL_LEVEL);        02992500
                           J = J + 1;                                           02993000
                           PTR = PTR + DOINDEX(I);                              02993500
                           PTR = PTR * SUBLIMIT(J);                             02994000
                        END;                                                    02994500
                        INX_CON(OP) = SHL(PTR, SHIFT(TYPE(OP)));                02995000
                     END;                                                       02995500
                     DO;   /* STRUCTURE WITH COPIES */                          02996000
                        PTR = PTR + DOINDEX(DOPTR(CALL_LEVEL)+1);               02996500
                        INX_CON(OP) = PTR * SUBLIMIT(J);                        02997000
                        J = J + 1;                                              02997500
                        STRUCT(OP) = 0;                                         02998000
                        COPY(OP) = COPY(OP) - 1;                                02998500
                     END;                                                       02999000
                  END;                                                          02999500
                  ;                                                             03000000
               END;                                                             03000500
            END;                                                                03001000
         END;                                                                   03003500
         /**** DR107307 - TEV - 5/10/94 *******************************/
         /* MOVED THE CHECKS FOR A CALL TO FIX_STRUCT_INX SO THAT THE */
         /* ROUTINE IS CALLED WHEN FLAG IS EITHER 0 OR 2 (NOT ONLY    */
         /* WHEN FLAG = 0).                                           */
         /*                                                           */
         /**** END DR107307 *******************************************/
         IF ^FLAG THEN IF SELF_ALIGNING THEN IF SPTR = 0 THEN                    3001500
            IF STRUCT(OP) = 0 THEN                                              03002000
               IF STRUCT_INX(OP) >= 4 THEN DO;                                  03002500
               /* IF NAME() ASSIGNMENT/COMPARE, %NAMEADD OR &NAMECOPY  */
               /* AND IF EITHER STRUCTURE OR STRUCTURE NODE IS REMOTE, */
               /* THEN CALL FIX_STRUCT_INX. ELSE CALL FIX_STRUCT_INX   */
               /* UNCONDITIONALLY...                                   */
                  /* DR109018: CALL NAME_FUNCTION ROUTINE WHICH  */
                  /* HAS THE NAME FUNCTIONALITY AS THE OLD DEREF */
                  /* SINCE WE ARE LOOKING IF INSIDE A NAME       */
                  /* FUNCTION, NOT A NAME REMOTE VARIABLE DEREF. */
 /*DR111390*/     IF (^NAME_FUNCTION(OP) | CHECK_REMOTE(OP) |
                    CHECK_STRUCT_NODE_REMOTENESS(OP)) THEN
                     CALL FIX_STRUCT_INX(0, OP);                                03003000
               END;
         /*----------------------------------------------------------*/
         /* DR109019: DO NOT ADJUST FOR AIA IN SUBSCRIPT_RANGE_CHECK */
         /* FOR NAME FUNCTIONS WITH LOCAL NODES. THIS IS THE SAME    */
         /* LOGIC RESTRICTING THE CALL TO FIX_STRUCT_INX ABOVE.      */
         /*----------------------------------------------------------*/
         IF (^NAME_FUNCTION(OP) | CHECK_REMOTE(OP) |       /*DR111390*/
             CHECK_STRUCT_NODE_REMOTENESS(OP)) THEN
             NO_AIA_SHIFT=FALSE;
          ELSE
             NO_AIA_SHIFT=TRUE;

         INX_CON(OP) = STRUCT_CON(OP) + INX_CON(OP);                            03004000
         STRUCT_CON(OP) = 0;                                                    03004500
         IF ^NAME_FUNCTION(OP) THEN                        /*DR111384 DR111390*/
            SIMPLE_AIA_ADJUST = TRUE;                      /*DR111384*/
         IF DOFORM(CALL_LEVEL) = 0 THEN                                         03005000
            CALL SUBSCRIPT_RANGE_CHECK(OP,0,NO_AIA_SHIFT); /*DR109019*/
         SIMPLE_AIA_ADJUST = FALSE;                        /*DR111384*/
         FLAG = 0;                                                              03006000
      END FREE_ARRAYNESS;                                                       03006500
                                                                                 3006520
 /* ROUTINE TO PREPARE FREE-ARRAYNESS POINTERS */                                3006540
SET_DOPTRS:                                                                      3006560
      PROCEDURE(PTR, FLAG) BIT(16);                                             03006580
         DECLARE (PTR, I, J) BIT(16), FLAG BIT(8);                              03006600
         IF VDLP_ACTIVE THEN DO;                                                 3006620
            IF COPY(PTR) = 0 THEN DO;                                            3006640
               I = CALL_LEVEL;  J = VMCOPY(PTR);                                 3006660
                  STRUCT_INX(PTR) = STRUCT_INX(PTR) & ^1;                        3006670
            END;                                                                 3006680
            ELSE DO;                                                             3006700
               I = CALL_LEVEL - DOPUSH(CALL_LEVEL);                              3006720
               J = (VMCOPY(PTR)&DOPUSH(CALL_LEVEL)) + DOCOPY(I);                03006740
               ARRAY_FLAG = ARRAY_FLAG | FLAG;                                  03006750
            END;                                                                 3006760
         END;                                                                    3006780
         ELSE DO;                                                                3006800
            I = CALL_LEVEL;  J = DOCOPY(I);                                      3006820
               ARRAY_FLAG = ARRAY_FLAG | FLAG;                                  03006840
         END;                                                                    3006860
         DOPTR(CALL_LEVEL) = SDOPTR(I);                                          3006880
         DOTOT(CALL_LEVEL) = DOPTR(CALL_LEVEL) + J;                              3006900
         SUBLIMIT(STACK#+COPY(PTR)+VMCOPY(PTR)) = 1;                             3006920
         SUBLIMIT(STACK#+COPY(PTR)) = AREASAVE;                                  3006940
         RETURN J;                                                               3006960
      END SET_DOPTRS;                                                            3006980
                                                                                03007000
 /* ROUTINE TO SET UP INDEXING INTO SHAPING FUNCTION RESULTS  */                03007500
VAC_COPIES:                                                                     03008000
      PROCEDURE(OP);                                                            03008500
         DECLARE (OP, CPY, I, P) BIT(16);                                        3009000
         IF (COPY(OP) + VMCOPY(OP)) = 0 THEN RETURN;                             3009100
         CALL SET_AREA(OP);                                                      3009200
         COPY(OP), CPY = SET_DOPTRS(OP, TRUE);                                  03009300
         IF FORM(OP) = WORK THEN                                                 3009400
            INX_CON(OP) = 0;                                                     3009500
         ARRCONST = 0;                                                           3009600
         DO I = 0 TO CPY-VMCOPY(OP)-1;                                           3009700
            IF ADOPTR = 0 THEN P = SF_RANGE(I+VAL(OP));   /*DR111372*/
            ELSE P = VAL(DORANGE(DOPTR(CALL_LEVEL)+I+1)); /*DR111372*/
            IF I = 0 THEN ARRCONST = -1;                                         3009900
            ELSE ARRCONST = ARRCONST * P - 1;             /*DR111372*/           3010000
            SUBLIMIT(STACK#+I) = P;                       /*DR111372*/           3010100
         END;                                                                    3010200
         IF VMCOPY(OP) THEN DO;                                                  3010300
            IF ADOPTR = 0 THEN P = SF_RANGE(I+VAL(OP));   /*DR111372*/
            ELSE P = VAL(DORANGE(DOPTR(CALL_LEVEL)+I+1)); /*DR111372*/
            ARRCONST = ARRCONST * P;                      /*DR111372*/           3010500
            SUBLIMIT(STACK#+I) = P;                       /*DR111372*/           3010600
            SUBLIMIT(STACK#+CPY) = 1;                                            3010700
         END;                                                                    3010800
         ELSE DO;                                                                3010900
            ARRCONST = ARRCONST * AREASAVE;                                      3011000
            SUBLIMIT(STACK#+CPY) = AREASAVE;                                     3011100
         END;                                                                    3011200
         IF TYPE(OP) ^= STRUCTURE THEN ARRCONST = ARRCONST * BIGHTS(TYPE(OP));   3011300
         INX_CON(OP) = INX_CON(OP) + ARRCONST;                                   3011400
         VMCOPY(OP) = 0;                                                         3011500
         CALL FREE_ARRAYNESS(OP);                                               03013500
      END VAC_COPIES;                                                           03014000
                                                                                03014500
 /* ROUTINE TO SET UP THE GENERATION OF DO LOOPS FOR ARRAY PROCESSING */        03015000
DOOPEN:                                                                         03015500
      PROCEDURE(START, STEP, STOP);                                             03016000
         DECLARE (START, STEP, STOP) FIXED, PTR BIT(16);                        03016500
         ADOPTR = ADOPTR + 1;                                                   03017000
         IF ADOPTR > DOLOOPS THEN                                               03017500
            CALL ERRORS(CLASS_BS,119);                                          03018000
         DOLABEL(ADOPTR) = GETSTATNO;                                           03018500
         DOSTEP(ADOPTR) = STEP;                                                 03019000
         CALL RESUME_LOCCTR(NARGINDEX);                                         03019500
         PTR, DOINDEX(ADOPTR) = GET_VAC(-1);                                    03020000
         TMP, BACKUP_REG(PTR) = REG(PTR);                                       03020500
         IF STOP < 0 THEN DORANGE(ADOPTR) = SET_ARRAY_SIZE(-STOP);              03021000
         ELSE DORANGE(ADOPTR) = GET_INTEGER_LITERAL(STOP);                      03021500
         IF STEP = 1 & NEW_INSTRUCTIONS THEN DO;                                03022000
            TYPE(PTR) = DINTEGER;                                               03022500
            BIX_CNTR = BIX_CNTR + 1;                             /*DR108606*/
            IF STOP < 0 THEN DO;                                                03023000
               CALL LOAD_NUM(TMP, START, 1);                                    03023500
               CALL CHECK_ADDR_NEST(-1, DORANGE(ADOPTR));                       03024000
               CALL EMITOP(IHL, TMP, DORANGE(ADOPTR));                          03024500
               CONST(PTR) = -1;   CALL INCORPORATE(PTR);                        03025000
               END;                                                             03025500
            ELSE CALL LOAD_NUM(TMP, SHL(START,16) + STOP - 1, 9);               03026000
            R_TYPE(TMP) = DINTEGER;                                             03026500
         END;                                                                   03027000
         ELSE CALL LOAD_NUM(TMP, START, 1);                                     03027500
         CALL SET_LABEL(DOLABEL(ADOPTR), 1);                                    03028000
         CALL SET_USAGE(TMP, AIDX, PTR);                                         3029000
      END DOOPEN;                                                               03035500
                                                                                03036000
 /* ROUTINE TO CLOSE OUT OUTSTANDING DO LOOPS */                                03036500
DOCLOSE:                                                                        03037000
      PROCEDURE;                                                                03037500
         DECLARE PTR BIT(16);                                                   03038000
         IF DOCOPY(CALL_LEVEL) = 0 THEN RETURN;                                 03038500
         DO CASE DOFORM(CALL_LEVEL);                                            03039000
            DO WHILE ADOPTR > SDOPTR(CALL_LEVEL);                               03039500
               PTR = DOINDEX(ADOPTR);                                           03040000
               TMP = BACKUP_REG(PTR);                                           03040500
               IF FORM(PTR) = WORK THEN DO;                                     03041000
                  CALL CHECKPOINT_REG(TMP);                                     03041500
                  CALL EMIT_BY_MODE(LOAD, TMP, PTR, TYPE(PTR));                 03042000
                  USAGE(TMP) = 2;                                               03042500
                  CALL DROPTEMP(LOC(PTR));                                      03043000
               END;                                                             03043500
               IF DOSTEP(ADOPTR) ^= 1 | ^NEW_INSTRUCTIONS THEN                  03044000
                  CALL EMITP(AHI, TMP, 0, 0, DOSTEP(ADOPTR));                   03044500
               FORM(0) = AIDX;                                                  03048500
               LOC(0) = PTR;                                                    03049000
               CALL NEW_USAGE(0);                                               03049500
               CALL RETURN_STACK_ENTRY(PTR);                                    03050000
               PTR = DORANGE(ADOPTR);                                           03050500
               IF DOSTEP(ADOPTR) = 1 & NEW_INSTRUCTIONS THEN DO; /*DR108606*/
                  CALL EMITPFW(BIX, TMP, GETSTMTLBL(DOLABEL(ADOPTR)));          03051500
                  BIX_CNTR = BIX_CNTR - 1;                       /*DR108606*/
               END;                                              /*DR108606*/
               ELSE DO;                                                         03052000
                  IF FORM(PTR) = SYM THEN DO;                                   03052500
                     CALL CHECK_ADDR_NEST(-1, PTR);                             03053000
                     CALL EMIT_BY_MODE(COMPARE, TMP, PTR, TYPE(PTR));           03053500
                  END;                                                          03054000
                  ELSE CALL EMITP(CHI, TMP, 0, 0, VAL(PTR));                    03054500
                  CALL EMITBFW(LQ, GETSTMTLBL(DOLABEL(ADOPTR)));                03055000
               END;                                                             03055500
               USAGE(TMP) = 0;                                                  03056000
               CALL RETURN_STACK_ENTRY(PTR);                                    03056500
               ADOPTR = ADOPTR - 1;                                             03058000
            END;                                                                03058500
            DO;  /* STATIC INITIAL */                                           03059000
               TMP = ADOPTR;                                                    03059500
               DO WHILE TMP > SDOPTR(CALL_LEVEL);                               03060000
                  IF DOINDEX(TMP) < DORANGE(TMP) THEN DO;                       03060500
                     DOINDEX(TMP) = DOINDEX(TMP) + 1;                           03061000
                     DO TMP = TMP + 1 TO ADOPTR;                                03061500
                        DOINDEX(TMP) = 0;                                       03062000
                     END;                                                       03062500
                     CALL POSITION_HALMAT(DOSTEP(ADOPTR), DOLABEL(ADOPTR),      03063000
                        DOAUX(ADOPTR));                                          3063500
                     CALL NEXTCODE;                                             03064500
                     GO TO RESTART;                                             03065000
                  END;                                                          03065500
                  ELSE TMP = TMP - 1;                                           03066000
               END;                                                             03066500
               ADOPTR = TMP;                                                    03067000
            END;                                                                03067500
            ;                                                                   03068000
         END;                                                                   03068500
         DOCOPY(CALL_LEVEL) = 0;                                                03069000
      END DOCLOSE;                                                              03069500
                                                                                03070000
 /* ROUTINE TO STACK REGISTER PARAMETERS IN CASE RE-LOADING IS NECESSARY */     03070500
STACK_PARM:                                                                     03071000
      PROCEDURE(OP);                                                            03071500
         DECLARE OP BIT(16);                                                    03072000
         R_PARM# = R_PARM# + 1;                                                 03072500
         IF R_PARM# > REG_NUM THEN                                              03073000
            CALL ERRORS(CLASS_BS, 103);                                         03073500
         R_PARM(R_PARM#) = OP;                                                  03074000
         BACKUP_REG(OP) = REG(OP);                                              03074500
      END STACK_PARM;                                                           03075000
                                                                                03075500
 /* ROUTINE TO STACK REGISTER PARAMETER AND CLEAR TARGET REGISTER */            03076000
STACK_TARGET:                                                                   03076500
      PROCEDURE(OP);                                                            03077000
         DECLARE OP BIT(16);                                                    03077500
         CALL STACK_PARM(OP);                                                   03078000
         TARGET_REGISTER = -1;                                                  03078500
      END STACK_TARGET;                                                         03079000
                                                                                03079500
 /* ROUTINE TO CREATE VAC FOR REGISTER PARAMETER AND STACK */                   03080000
STACK_REG_PARM:                                                                 03080500
      PROCEDURE(R, TYP);                                                        03081000
         DECLARE (R, TYP) BIT(16);                                              03081500
         IF TYP = 0 THEN TYP = R_TYPE(R);                                       03082000
         CALL STACK_PARM(GET_VAC(R, TYP));                                      03082500
         TYP = 0;                                                               03083000
      END STACK_REG_PARM;                                                       03083500
                                                                                03084000
 /* ROUTINE TO RELOAD POSSIBLE CHECKPOINTED REG AND RELEASE */                  03084500
CHECK_AND_DROP_VAC:                                                             03085000
      PROCEDURE(OP, R);                                                         03085500
         DECLARE (OP, R) BIT(16);                                               03086000
         IF OP > 0 THEN DO;                                                     03086500
            CALL CHECK_VAC(OP, R);                                              03087000
            CALL DROP_VAC(OP);                                                  03087500
         END;                                                                   03088000
      END CHECK_AND_DROP_VAC;                                                   03088500
                                                                                03089000
 /* ROUTINE TO ASSURE REGISTER PARAMETERS ARE PROPERLY LOADED */                03089500
DROP_PARM_STACK:                                                                03090000
      PROCEDURE;                                                                03090500
         DO WHILE R_PARM# >= 0;                                                 03091000
          CALL CHECK_AND_DROP_VAC(R_PARM(R_PARM#), BACKUP_REG(R_PARM(R_PARM#)));03091500
            R_PARM# = R_PARM# - 1;                                              03092000
         END;                                                                   03092500
      END DROP_PARM_STACK;                                                      03093000
                                                                                03093500
 /* ROUTINE TO CLEAR THE CONTENTS OF REGISTERS DESTROYED BY CALLS */            03094000
CLEAR_CALL_REGS:                                                                03094500
      PROCEDURE(N1, INT);                                                       03095000
         DECLARE (I, N1) BIT(16), INT BIT(1);                                   03095100
         IF INT THEN                                                            03095200
            USAGE(PTRARG1), USAGE(R3) = 0;                                      03095300
         DO I = LINKREG TO N1;                                                  03096000
            USAGE(I) = 0;                                                       03096500
         END;                                                                   03097000
         DO I = FR0 TO FR7;                                                     03097500
            USAGE(I) = 0;                                                       03098000
         END;                                                                   03098500
      END CLEAR_CALL_REGS;                                                      03099000
                                                                                03099500
 /*DR109030 -- ROUTINE TO MARK REGISTERS UNRECOGNIZABLE ACROSS %COPY ASSIGN*/   52600000
 /* WHEN HIGHOPT IS OFF, CHECK FOR %COPY STATEMENT ASSIGNING ACROSS   */        52610018
 /* BOUNDS OF DESTINATION VARIABLE: IF IT CANNOT BE RULED OUT FROM    */        52610018
 /* ADDRESSING INFORMATION AVAILABLE AT COMPILE TIME THAT A VARIABLE  */        52610018
 /* IN A REGISTER WAS NOT CLOBBERED BY THE %COPY, THEN CLEAR IT.      */        52610018
 /* (THIS CHECK IS ONLY PERFORMED FOR COMPOOL DATA WHEN HIGHOPT OFF)  */        52610018
CLEAR_COPY_SAFE:                                                                52690000
      PROCEDURE(OP);                                                            52700000
         DECLARE (OP,I) BIT(16);                                                52710000
         DECLARE XPMIN LITERALLY '91';                                          52750000
         DECLARE COPY_TAG LITERALLY '4';    /*CR13570*/                         52760000
         DECLARE (DESTADDR, DESTMAX, REGADDR, REGMAX) BIT(32);                  52920000
         DECLARE CSECT_SIZE LITERALLY '32767';                                  52920000
                                                                                52780000
  IF HALMAT_OPCODE = XPMIN & PMINDEX = COPY_TAG /*%COPY*/                       52790000
     & ^HIGHOPT & ^NAME_VAR(OP) THEN                                            52800018
     IF SYT_TYPE(PROC_LEVEL(SYT_SCOPE(LOC(OP)))) =                              52810000
        COMPOOL_LABEL THEN  /* DESTINATION IN COMPOOL */                        52820000
  DO;                                                                           52820000
     IF INX(OP) = 0 THEN DO;
     /* ADDRESS COMPUTABLE AT COMPILE TIME */
        DESTADDR = SYT_ADDR(LOC(OP)) +
           SYT_CONST(LOC(OP)) + INX_CON(OP);
        DESTMAX  = DESTADDR;                                                    52920000
     END;                                                                       52920000
     ELSE DO; /* RUNTIME ADDRESSING - USE MAX BOUNDS */                         52920000
        DESTADDR = SYT_ADDR(LOC(OP));
        DESTMAX  = DESTADDR +
           EXTENT(LOC(OP)) - BIGHTS(TYPE(OP));
     END;                                                                       52920000
     /* DESTINATION RANGE INCLUDES %COPY COUNT */                               52920000
     IF FORM(EXTOP) = LIT                                                       52920000
        THEN DESTMAX  = DESTMAX + VAL(EXTOP)-1;                                 52920000
        ELSE DESTMAX  = CSECT_SIZE; /* VARIABLE COUNT */                        52920000
     DO I = 0 TO REG_NUM;                                                       52830000
        IF USAGE(I) THEN                                                        52840000
           IF R_CONTENTS(I)=SYM | R_CONTENTS(I)=SYM2 THEN                       52850000
              IF SYT_SCOPE(LOC(OP)) = SYT_SCOPE(R_VAR(I)) THEN                  52870000
              DO; /* VARIABLE IN REGISTER IS FROM THE SAME COMPOOL */           52880000
                 IF R_INX(I) = 0 THEN DO;
                 /* ADDRESS COMPUTABLE AT COMPILE TIME */
                    REGADDR = SYT_ADDR(R_VAR(I)) +                              52920000
                       SYT_CONST(R_VAR(I)) + R_INX_CON(I);                      52880000
                    REGMAX = REGADDR + BIGHTS(R_TYPE(I))-1;                     52920000
                 END;                                                           52920000
                 ELSE DO; /* RUNTIME ADDRESSING - USE MAX BOUNDS */             52920000
                    REGADDR = SYT_ADDR(R_VAR(I));                               52920000
                    REGMAX = REGADDR + EXTENT(R_VAR(I))-1;                      52920000
                 END;                                                           52920000
                 IF ^((REGMAX < DESTADDR) | (REGADDR > DESTMAX))                52880000
                 /* VARIABLE IN REGISTER IS UNSAFE FROM %COPY ASSIGN */         52920000
                     THEN CALL UNRECOGNIZABLE(I);                               52880000
              END;                                                              52890000
     END;                                                                       52890000
  END;                                                                          52890000
  END CLEAR_COPY_SAFE;                                                          53240000
                                                                                03099500
 /* ROUTINE TO MARK REGISTERS UNRECOGNIZABLE ACROSS DEREFERENCED NAME ASSIGN*/  52600000
 /*DR103787 -- ACCORDING TO HIGHOPT OPTION   (0-DEFAULT, 1-ON):      */         52610018
 /*DR103787 -- (0) CLEAR ALL TYPES FROM REGISTERS BECAUSE NAME CAN   */         52620018
 /*DR103787 --     BE MADE TO DEREFERENCE ANY TYPE.                  */         52630000
 /*DR109030 --     ALSO, CALL CLEAR_COPY_SAFE TO CHECK FOR %COPY     */         52640000
 /*DR109030 --     CROSSING DATA BOUNDS.                             */         52650000
 /*DR103787 -- (1) CLEAR REGISTERS THAT HAVE SAME TYPE AS NAME.      */         52670019
 /*DR103787 -- REGARDLESS OF HIGHOPT, ONLY CLEAR REGISTERS OF SAME   */         52681019
 /*DR103787 -- TYPE AS A FORMAL ASSIGN PARAMETER BEING ASSIGNED,     */         52682019
 /*DR103787 -- BECAUSE PARAMETERS MUST BE SAME TYPE AS ACTUAL INPUTS.*/         52683019
CLEAR_NAME_SAFE:                                                                52690000
      PROCEDURE(OP); /* DR103787 - PASS IN INDIRECT STACK ENTRY */              52700000
         DECLARE (OP,I) BIT(16);                                 /*DR103787*/   52710000
         DECLARE (NAMETYPE,REGTYPE) BIT(16);                     /*DR103787*/   52720000
         NAMETYPE = SYT_TYPE(LOC2(OP));                          /*DR103787*/   52750018
                                                                                52880000
         CALL CLEAR_COPY_SAFE(OP);                               /*DR109030*/   52880000
                                                                                52880000
         IF ^NAME_VAR(OP) & (SYT_FLAGS(LOC(OP)) & ASSIGN_FLAG)=0 /*DR103787*/   52890000
             THEN RETURN;                                        /*DR103787*/   52900000
                                                                                52910000
         DO I = 0 TO REG_NUM;                                                   52920000
            IF USAGE(I) THEN                                                    52930000
               IF R_CONTENTS(I) = SYM | R_CONTENTS(I) = SYM2 THEN DO;           52940000
               REGTYPE = SYT_TYPE(R_VAR(I));                     /*DR103787*/   52950018
               IF ^HIGHOPT & NAME_VAR(OP) THEN                   /*DR103787*/   52960019
                  /* HIGHOPT OFF AND NAME DEREFERENCE: */        /*DR103787*/   52970019
                  DO; /* CLEAR ALL TYPES */                      /*DR103787*/   52971019
                     CALL UNRECOGNIZABLE(I);                     /*DR103787*/   52980018
                  END;                                           /*DR103787*/   52990018
               ELSE /* HIGHOPT ON OR ASSIGN PARM ASSIGNMENT: */  /*DR103787*/   53000019
                  DO; /* CLEAR IF TYPES ARE THE SAME */          /*DR103787*/   53001019
                     /* NAME STRUCTURE DEREF - ONLY AFFECT STRUCS  DR103787*/   53010018
                     IF (SYT_FLAGS(LOC2(OP)) & NAME_FLAG)=0 &    /*DR103787*/   53020018
                        (NAME_VAR(OP)) & REGTYPE ^= STRUCTURE    /*DR103787*/   53030019
                        THEN ESCAPE;                             /*DR103787*/   53040019
                     /* ASSIGN PARAMETER - ONLY AFFECTS GLOBALS    DR103787*/   53050018
                     IF ^NAME_VAR(OP) & (SYT_SCOPE(R_VAR(I)) >=  /*DR103787*/   53060018
                        SYT_SCOPE(LOC(OP)) )                     /*DR103787*/   53070018
                        THEN ESCAPE;                             /*DR103787*/   53080018
                     /* R_TYPE CONTAINS DATATYPE FOR STRUCTS AND   DR103787*/   53090018
                     /* SCALAR CAN BE VECTOR/MATRIX COMPONENT      DR103787*/   53100018
                     IF (REGTYPE=STRUCTURE) |                    /*DR103787*/   53110018
                        ((NAMETYPE&"7")=SCALAR) THEN DO;         /*DR103787*/   53110018
                        REGTYPE = R_TYPE(I);                     /*DR103787*/   53120018
                        IF (NAMETYPE&"7") = VECTOR THEN          /*DR103787*/   53130018
                           NAMETYPE = NAMETYPE + 1;              /*DR103787*/   53140018
                        IF (NAMETYPE&"7") = MATRIX THEN          /*DR103787*/   53150018
                           NAMETYPE = NAMETYPE + 2;              /*DR103787*/   53160018
                     END;                                        /*DR103787*/   53170000
                     IF NAMETYPE = REGTYPE THEN                  /*DR103787*/   53180018
                        CALL UNRECOGNIZABLE(I);                  /*DR103787*/   53190000
                  END;                                           /*DR103787*/   53200000
               END;                                              /*DR103787*/   53220018
         END;                                                                   53230000
      END CLEAR_NAME_SAFE;                                                      53240000
                                                                                03106500
                                                                                03106500
 /* ROUTINE TO CHECK LOCK GROUPS USED WITHIN UPDATE BLOCKS  */                  03107000
UPDATE_CHECK:                                                                   03107500
      PROCEDURE(OP);                                                            03108000
         DECLARE OP BIT(16);                                                    03108500
         IF UPDATING > 0 THEN                                                   03109000
            IF (SYT_FLAGS(OP) & LOCK_BITS) ^= 0 THEN DO;                        03109500
            OP = SYT_LOCK#(OP);                                                 03110000
            IF OP = 255 THEN UPDATE_FLAGS = "7FFF" | UPDATE_FLAGS;              03110500
            ELSE UPDATE_FLAGS = SHL(1, OP-1) | UPDATE_FLAGS;                    03111000
         END;                                                                   03111500
      END UPDATE_CHECK;                                                         03112000
                                                                                03112500
 /* ROUTINE TO CHECK ASSIGNMENT INTO LOCKED VARIABLES  */                       03113000
UPDATE_ASSIGN_CHECK:                                                            03113500
      PROCEDURE(OP);                                                            03114000
         DECLARE OP BIT(16);                                                    03114500
         IF UPDATING > 0 THEN                                                   03115000
            IF SYMFORM(FORM(OP)) THEN                                           03115500
            IF (SYT_FLAGS(LOC(OP)) & LOCK_BITS) ^= 0 THEN                       03116000
            UPDATE_FLAGS = UPDATE_FLAGS | NEGMAX;                               03116500
      END UPDATE_ASSIGN_CHECK;                                                  03117000
                                                                                03117500
 /* ROUTINE TO CLEAN OUT STATISTICS FOR UNUSED OR BYPASSED STACK ENTRIES */     03118000
DROP_UNUSED:                                                                    03118500
      PROCEDURE(OP);                                                            03119000
         DECLARE OP BIT(16);                                                    03119500
         CALL DROP_INX(OP);                                                     03120000
         IF FORM(OP) = CSYM THEN                                                03120500
            CALL OFF_INX(BASE(OP));                                             03121000
         CALL RETURN_STACK_ENTRY(BIT_PICK(OP));                                  3121500
      END DROP_UNUSED;                                                          03122000
                                                                                03122500
 /* ROUTINE TO RESET REGISTER REMEMBERANCES FOLLOWING ASSIGNMENT */             03123000
ASSIGN_CLEAR:                                                                   03123500
      PROCEDURE(OP, FLAG, AGAIN, OP2);                                          03124000
         DECLARE (OP, OP2) BIT(16), FLAG BIT(1), AGAIN BIT(2);                  03124500
         CALL UPDATE_ASSIGN_CHECK(OP);                                          03125000
         IF KNOWN_SYM(OP) THEN CALL NEW_USAGE(OP, FLAG);                        03125500
         ELSE CALL CLEAR_NAME_SAFE(OP); /* DR103787 */                          03126000
         IF AGAIN > 1 THEN DO;                                                  03126500
            CALL DROP_UNUSED(OP2);                                              03127000
         END;                                                                   03127500
         FLAG, AGAIN = 0;                                                       03128000
      END ASSIGN_CLEAR;                                                         03128500
                                                                                03129000
 /* ROUTINE TO SAVE THE CONTENTS OF ALL FLOATING REGS  */                       03129500
SAVE_FLOATING_REGS:                                                             03130000
      PROCEDURE(SAVE);                                                           3130500
         DECLARE I BIT(16), SAVE BIT(1);                                         3131000
         DO I = FR0 TO FR7;                                                     03131500
            CALL CHECKPOINT_REG(I, SAVE);                                        3132000
         END;                                                                   03132500
         SAVE = FALSE;                                                           3132600
      END SAVE_FLOATING_REGS;                                                   03133000
                                                                                03133500
 /* ROUTINE TO SAVE THE CONTENTS OF SPECIFIED FIXED PLUS FLOATING REGS */       03134000
SAVE_REGS:                                                                      03134500
      PROCEDURE(N1, FLT, SAVE);                                                  3135000
         DECLARE (I, N1) BIT(16), (FLT, SAVE) BIT(1);                            3135500
         DO I = LINKREG TO N1;                                                  03136000
            CALL CHECKPOINT_REG(I, SAVE);                                        3136500
         END;                                                                   03137000
         IF SHR(FLT, 1) THEN DO I = PTRARG1 TO R3;                              03137500
            CALL CHECKPOINT_REG(I, SAVE);                                       03137510
         END;                                                                   03137520
         IF FLT THEN CALL SAVE_FLOATING_REGS(SAVE);                              3137600
         SAVE = FALSE;                                                           3137700
      END SAVE_REGS;                                                            03139000
                                                                                03139500
 /* ROUTINE TO GENERATE STANDARD LIBRARY CALLING SEQUENCES  */                  03140000
GENLIBCALL:                                                                     03140500
      PROCEDURE(NAME);                                                          03141000
         DECLARE NAME CHARACTER, (MAXARG, REGBITS, I) BIT(16), /* CR13222 */
                 INT BIT(1);
         INT = INTRINSIC(NAME);                                                 03142000
         IF INT THEN MAXARG = FIXARG3;                                          03142500
         ELSE MAXARG = FIXARG1;                                                 03143000
         IF LIB_POINTER = 0 | OLD_LINKAGE THEN                                  03143500
            CALL SAVE_REGS(MAXARG, 3);                                          03144000
         ELSE DO;                                                               03144500
 /*DANNY STRAUSS ---------- CR11053 ------------------------------*/            03145000
 /* LIB_POINTER MAY BE NEGATIVE, SO TAKE ABSOLUTE VALUE.          */            03145000
            REGBITS = LIB_REGS(ABS(LIB_POINTER)); /* CR13222 */
 /*DANNY STRAUSS -------------------------------------------------*/            03145000
            DO I = 1 TO 15;                         /* CR13222 */
               IF (POW_OF_2(I) & REGBITS) ^= 0 THEN /* CR13222 */
               CALL CHECKPOINT_REG(I);              /* CR13222 */
            END;                                                                03146500
         END;                                                                   03147000
         CALL EMIT_CALL(ENTER_CALL(NAME), INT);                                 03147500
         IF LIB_POINTER = 0 | OLD_LINKAGE THEN                                  03148000
            CALL CLEAR_CALL_REGS(MAXARG, INT);                                  03148500
         ELSE DO I = 1 TO 15;                     /* CR13222 */
            IF (POW_OF_2(I) & REGBITS) ^= 0 THEN  /* CR13222 */
            USAGE(I) = 0;                         /* CR13222 */
         END;                                                                   03150000
 /*--------------------------- #DREG -----------------------------*/
         D_RTL_SETUP = FALSE;
 /*---------------------------------------------------------------*/
      END GENLIBCALL;                                                           03152000
                                                                                03152500
 /* ROUTINE TO SET UP RETURN REGISTER STACK TO PROPER FORM */                   03153000
SET_RESULT_REG:                                                                 03153500
      PROCEDURE(OP, OPTYPE, OPMOD);                                             03154000
         DECLARE (OP, OPTYPE, OPMOD) BIT(16);                                   03154500
         IF OPMOD > 0 THEN REG(OP) = OPMOD;                                     03155000
         ELSE IF DATATYPE(OPTYPE) = SCALAR THEN REG(OP) = FR0;                  03155500
         ELSE IF PACKTYPE(OPTYPE) THEN REG(OP) = FIXARG1;                       03156000
         ELSE REG(OP) = PTRARG1;                                                03156500
         IF OPMOD = 0 THEN DO;                                                   3157000
            OPMOD = TARGET_REGISTER;                                             3157100
            TARGET_REGISTER = REG(OP);                                           3157200
            REG(OP) = FINDAC(RCLASS(OPTYPE));                                    3157300
            TARGET_REGISTER = OPMOD;                                             3157400
         END;                                                                    3157500
         CALL SET_REG_NEXT_USE(REG(OP), OP);                                     3157600
         FORM(OP) = VAC;                                                        03158000
         LOC2(OP) = -1;                                                          3158100
         TYPE(OP) = OPTYPE;                                                     03158500
         R_TYPE(REG(OP)) = OPTYPE;                                              03159000
         OPMOD = 0;                                                             03159500
      END SET_RESULT_REG;                                                       03160000
                                                                                03160500
 /* ROUTINE TO PUSH OUT ARRAY DO LOOPS FROM HALMAT  */                          03161000
EMIT_ARRAY_DO:                                                                  03161500
      PROCEDURE(LEVEL);                                                         03162000
         DECLARE (LEVEL, SAVCTR) BIT(16);                                       03162500
         SAVCTR = CTR;                                                          03163000
         CTR = DOCTR(LEVEL);                                                    03163500
         TMP = 0;                                                               03164000
         CALL SAVE_REGS(RM, 3);                                                 03164500
         DO SUBOP = 1 TO DOCOPY(LEVEL);                                         03165000
            CALL CHECKPOINT_REG(TMP);                                           03165500
            CALL DECODEPIP(SUBOP, 2);                                           03166000
            IF TAG1 = ASIZ THEN OP1 = -OP1;                                     03166500
            CALL DOOPEN(1, 1, OP1);                                             03167000
            DOFLAG(ADOPTR) = SHR(TAG3(2), 2);                                    3167100
         END;                                                                   03167500
         DOFORM(LEVEL) = 0;                                                     03168000
         CTR = SAVCTR;                                                          03168500
      END EMIT_ARRAY_DO;                                                        03169000
                                                                                03169500
 /* ROUTINE TO SET UP STACK ENTRIES IN PREPARATION FOR STRUCTURE REFERENCES */  03170000
STRUCTFIX:                                                                      03170500
      PROCEDURE(OP, FLAG);                                                      03171000
         DECLARE (PTR, OP) BIT(16), FLAG BIT(1);                                03171500
         PTR = GET_STACK_ENTRY;                                                 03172000
         LOC(PTR) = OP;                                                         03172500
         CALL UPDATE_CHECK(OP);                                                 03173000
         TYPE(PTR) = SYT_TYPE(OP);                                              03173500
         FORM(PTR) = SYM;                                                       03174000
         OP2, LOC2(PTR) = SYT_DIMS(OP);                                         03174500
 /***********  DR102965  RAH  ****************************************/
 /* #DNAME -- MOVED SECTION DOWN SO FORM WILL BE SET FOR CSECT_TYPE. */         56600099
         IF (SYT_FLAGS(OP) & NAME_OR_REMOTE) = NAME_OR_REMOTE THEN
            POINTS_REMOTE(PTR) = TRUE;
         ELSE IF (SYT_FLAGS(OP) & REMOTE_FLAG) = REMOTE_FLAG THEN
            LIVES_REMOTE(PTR) = TRUE;
        /*--------------------- #DNAME --------------------------*/             56650099
        /* ALLOW NAME REMOTE VARIABLES TO POINT TO MIGRATED #D   */             56660099
         ELSE IF DATA_REMOTE & (CSECT_TYPE(LOC(PTR),PTR)=LOCAL#D)               56670099
            THEN LIVES_REMOTE(PTR) = TRUE;                                      56680099
        /*-------------------------------------------------------*/             56690099
         IF (SYT_FLAGS(OP) & NAME_FLAG) = NAME_FLAG THEN
            NAME_VAR(PTR) = TRUE;
 /***********  END  DR102965  ****************************************/
         CALL SIZEFIX(PTR, OP2);                                                03175000
         IF SYT_ARRAY(OP) ^= 0 THEN DO;                                         03175500
            CALL SET_AREA(PTR);                                                 03176000
            XVAL(PTR), SUBLIMIT(STACK#) = AREASAVE;                             03176500
            COPY(PTR), STRUCT(PTR) = 1;                                         03177000
            DOPTR(CALL_LEVEL) = SDOPTR(CALL_LEVEL-DOPUSH(CALL_LEVEL));           3177500
            DOTOT(CALL_LEVEL) = DOPTR(CALL_LEVEL) + 1;                          03178000
            IF ^FLAG THEN DO;                                                   03178500
               IF DOCOPY(CALL_LEVEL) > 0 THEN                                   03179000
                  IF DOFORM(CALL_LEVEL) = 2 THEN                                03179500
                  IF ^TAG2(1) THEN                                              03180000
                  CALL EMIT_ARRAY_DO(CALL_LEVEL);                               03180500
               CALL FREE_ARRAYNESS(PTR);                                        03181000
               ARRAY_FLAG = TRUE;                                               03181100
            END;                                                                03181500
         END;                                                                   03182000
         FLAG = FALSE;                                                          03182500
         RETURN PTR;                                                            03183000
      END STRUCTFIX;                                                            03183500
                                                                                03184000
 /* ROUTINE TO FETCH VAC POINTER AND CREATE COPY IF CSE RESULT */               03184500
FETCH_VAC:                                                                      03185000
      PROCEDURE(OP, N) BIT(16);                                                 03185500
         DECLARE (OP, N, PTR) BIT(16);                                          03186000
         DECLARE I BIT(16), REF FIXED;                                           3186500
         VAC_FLAG = TRUE;                                                        3186505
         IF OP < 0 THEN DO;                                                      3186510
            OP = OP & "7FFF";                                                    3186520
            I = OFF_PAGE_BASE(OFF_PAGE_LAST);                                    3186530
            DO I = I TO I + OFF_PAGE_CTR(OFF_PAGE_LAST)-1;                       3186540
               IF OFF_PAGE_LINE(I) = OP THEN DO;                                 3186550
                  REF = OFF_PAGE_TAB(I);                                         3186560
                  GO TO LOOP_EXIT;                                               3186570
               END;                                                              3186580
            END;                                                                 3186590
            CALL ERRORS(CLASS_BS, 130);                                          3186600
LOOP_EXIT:                                                                       3186610
         END;                                                                    3186620
         ELSE REF = OPR(OP);                                                     3186630
         IF REF < 0 THEN ARRAY_FLAG = TRUE;                                      3186640
         PTR = REF & "FFFF";                                                     3186650
         IF N < 0 THEN RETURN PTR;                                               3186660
 /*-- DANNY STRAUSS ------------- CR11053 ------------------------*/            03187000
 /* ADD CHECK FOR PTR BEING > STACK_MAX; PTR MAY CONTAIN GARBAGE  */            03187000
 /* BECAUSE PREVIOUS ERROR RECOVERY MAY HAVE PREVENTED PROPER VAC */            03187000
 /* SETUP BY WIPING OUT STACK AND NOT CALLING SETUP_VAC.          */            03187000
         IF (STACK_PTR(PTR) ^< 0) | (PTR > STACK_MAX) THEN                      03187000
            CALL ERRORS(CLASS_BS, 122);                                         03187500
 /*-- DANNY STRAUSS ----------------------------------------------*/            03187000
         COPT(PTR) = COPT(PTR) & TAG2(N);                                       03188000
         IF COPT(PTR) ^= 0 THEN                                                 03188500
            RETURN COPY_STACK_ENTRY(PTR, 4);                                    03189000
         ELSE RETURN PTR;                                                       03189500
      END FETCH_VAC;                                                            03190000
                                                                                 3190010
 /* ROUTINE TO DETERMINE NEXT USE INFORMATION FOR SPECIFIED HALMAT LINE */       3190020
SET_NEXT_USE:                                                                    3190030
      PROCEDURE(PTR, OP);                                                        3190040
         DECLARE (PTR, OP) BIT(16), CTR FIXED;                                   3190050
         CTR = AUX_LOCATE(AUX_CTR, OP, 1);                                       3190060
         IF CTR >= 0 THEN DO;                                                    3190070
            CALL AUX_DECODE(CTR);                                                3190080
            NEXT_USE(PTR) = AUX_NEXT;                                            3190090
         END;                                                                    3190100
         ELSE NEXT_USE(PTR) = 0;                                                 3190110
      END SET_NEXT_USE;                                                          3190120
                                                                                03190500
 /*  SUBROUTINE FOR PICKING UP THE ARRAYNESS OF SYMBOL-TABLE VARIABLES */       03191000
SYT_COPIES:                                                                     03191500
      PROCEDURE(PTR, OP, FLAG);                                                  3192000
         DECLARE (PTR, OP) BIT(16), FLAG BIT(1);                                 3192500
         DECLARE NESTED BIT(1);                                                 03192600
         DECLARE (CPY, I, J, K, L) BIT(16);                                      3193000
         IF (COPY(PTR) + VMCOPY(PTR)) = 0 THEN RETURN;                           3193500
         CPY = SET_DOPTRS(PTR, ^FLAG & 1) - (STRUCT_INX(PTR) & 1);              03194000
         DO I = 1 TO COPY(PTR);                                                  3194500
            J=STACK#+I;                                                         03196000
      /* FOR STRUCTURE, USE AREASAVE  TO SPECIFY SIZE OF 1 COPY   /*CR12935*/   62470000
      /* WHICH WILL BE USED IN COPYING REMOTE MULTI-COPY STRUCT   /*CR12935*/   62480000
      /* PARAMETER TO STACK.                                      /*CR12935*/   62490000
            IF SYT_TYPE(OP)=STRUCTURE                             /*CR12935*/   62500000
               THEN SUBRANGE(J)=AREASAVE;                         /*CR12935*/   62510000
            ELSE                                                  /*CR12935*/   62520000
            SUBRANGE(J)=GETARRAYDIM(I,OP);                                      03196500
            SUBLIMIT(J-1) = SUBRANGE(J);                                        03197000
         END;                                                                   03197500
         COPY(PTR) = COPY(PTR) + VMCOPY(PTR);                                    3197520
         NESTED = VMCOPY(PTR) & DOPUSH(CALL_LEVEL);                             03197530
         VMCOPY(PTR) = 0;                                                        3197540
         IF FLAG^=0 THEN RETURN;                                  /*DR120230*/   3197560
         IF DOFORM(CALL_LEVEL) = 0 THEN IF CPY > 0 THEN                          3197580
            IF CPY < COPY(PTR) THEN DO;                                          3197600
            K = DOPTR(CALL_LEVEL) + (STRUCT_INX(PTR) & 1) - STACK#;              3197620
            DO I = STACK#+1 TO STACK#+CPY;                                       3197640
               IF DOFLAG(K+I) THEN DO;                                           3197660
                  L = STACK#+COPY(PTR)-NESTED;  AREA = 0;                       03197680
                     DO J = I TO L;                                              3197700
                     IF J < L THEN DO;                                           3197720
                        SUBLIMIT(I-1) = SUBLIMIT(J) * SUBLIMIT(I-1);             3197740
                        AREA = (AREA+1) * SUBLIMIT(J);                           3197760
                     END;                                                        3197780
                     ELSE AREA = AREA * SUBLIMIT(J);                             3197800
                  END;                                                           3197820
                  SUBLIMIT(I) = SUBLIMIT(L);                                     3197840
                  IF NESTED THEN                                                03197860
                     SUBLIMIT(I+1) = SUBLIMIT(L+1);                             03197865
                  AREA = AREA * BIGHTS(TYPE(PTR));                              03197870
                  INX_CON(PTR) = INX_CON(PTR) + AREA;                           03197875
               END;                                                              3197880
            END;                                                                 3197900
            COPY(PTR) = CPY;                                                     3197920
         END;                                                                    3197940
      END SYT_COPIES;                                                           03198000
                                                                                 3198020
 /* CHECK FOR POTENTIAL VECTOR COPIES */                                         3198040
VM_COPIES:                                                                       3198060
      PROCEDURE(PTR, N);                                                         3198080
         DECLARE (PTR, N) BIT(16);                                               3198100
         IF PACKTYPE(TYPE(PTR)) = VECMAT THEN                                    3198120
            IF VDLP_IN_EFFECT & DOFORM(CALL_LEVEL) = 0 THEN DO;                 03198140
            IF SHR(TAG2(N),1) THEN DO;                                           3198160
               IF TAG1 = VAC THEN                                                3198180
                  VMCOPY(PTR) = VMCOPY(PTR) | OP1 < DOCTR(CALL_LEVEL);           3198200
               ELSE VMCOPY(PTR) = 1;                                             3198220
               VDLP_ACTIVE = TRUE;                                              03198230
            END;                                                                 3198240
            ELSE VMCOPY(PTR) = 0;                                                3198260
         END;                                                                    3198280
         ELSE VMCOPY(PTR) = 0;                                                   3198300
      END VM_COPIES;                                                             3198320
                                                                                03198500
 /**************************************************************************/
 /* ROUTINE TO DETERMINE IF DEREFERENCE IS REQUIRED IN STRUCTURE NODE      */   03199000
 /**************************************************************************/
 /*                                                               /*CR13616*/
 /* BY_NAME = TRUE (1)                                            /*CR13616*/
 /* ::= THE DESTINATION VARIABLE IN A NAME ASSIGNMENT, NAME       /*CR13616*/
 /*     INITIALIZATION, OR %NAMEADD/%NAMECOPY MACRO,              /*CR13616*/
 /* ::= A NAME ASSIGN ARGUMENT IN A PROCEDURE CALL,               /*CR13616*/
 /* ::= A SUBSCRIPT IN A NAME PSEDUO-FUNCTION AND THE STATEMENT   /*CR13616*/
 /*     IS AN ASSIGNMENT-TYPE STATEMENT,                          /*CR13616*/
 /* ::= AN ARGUMENT IN THE SIZE BUILT-IN FUNCTION,                /*CR13616*/
 /* ::= THE SOURCE IN A %NAMEBIAS MACRO,                          /*CR13570*/
 /* ::= A NAME TEMPORARY DECLARATION, OR                          /*CR13616*/
 /* ::= AN EQUATE EXTERNAL INITIALIZATION.                        /*CR13616*/
 /*                                                               /*CR13616*/
 /**************************************************************************/
STRUCTURE_DECODE:                                                               03199500
      PROCEDURE(PTR, OP, BY_NAME, FLAG);                          /* DR109077 */03200000
         DECLARE FLAG BIT(1);                                     /* DR109077 */
         DECLARE (PTR, OP, R) BIT(16), BY_NAME BIT(1);                          03200500
         DECLARE SAVEOP1 BIT(16);                                 /* CR12432 */

/* ROUTINE TO LOAD A NAME NODE.                                   /* CR13615 */
STRUCTURE_LOAD_NAME : PROCEDURE;
      IF DECLMODE THEN CALL RESUME_LOCCTR(NARGINDEX);                           03203500
      INX_CON(PTR) = STRUCT_CON(PTR);                                           03204000
 /*-- DR103659 -- DANNY STRAUSS ---------------------------------*/             02841700
 /*-- IF IT IS A REMOTE AGGREGATE, NOT YET LOADED (SYM), WITH NO */             02841670
 /*-- INDEX LOADED, THEN WE HAVE BS123 ERROR CASE 2, WHICH IS    */             02841640
 /*-- REFERENCING THE 1ST NODE OF REMOTE SINGLE-COPY STRUCTURE.  */             02841640
      /* DAS ----- DR109008 ----- */                                            02841670
      /* CHANGED 2 IF STATEMENTS TO A COMPOUND IF STATEMENT */                  02841670
      /* SO THAT THE ELSE CLAUSE ALWAYS EXECUTES WHEN FALSE */                  02841670
      R = 0;                                                                    02841670
      IF (FORM(PTR)=SYM) THEN R = SYT_BASE(LOC(PTR));                           02841670
      IF (R=REMOTE_BASE | NR_DEREF(PTR)) & (INX(PTR)=0) THEN DO;  /* CR12432 */
      /* DAS ----- END DR109008 ----- */                                        02841670
         /*-- SAVE AND RESTORE CURRENT TARGET REGISTER ALREADY ALLOCATED.*/     02841640
         TEMP2 = TARGET_REGISTER;                                               02841670
         TARGET_REGISTER = -1;                                                  02841670
         CALL SUBSCRIPT_RANGE_CHECK(PTR,1); /* FORCE LHI RX,0 */                02841670
         TARGET_REGISTER = TEMP2;                                               02841670
      END;                                                                      02841670
 /*--------------------------------------------------------------*/             02841700
 /*********** DR105054 RPC 5/4/93 *************************************/
      ELSE DO;
 /* CHECK TO SEE IF ITEM NEEDS AN INDEX ADJUST TO ACCOUNT FOR AUTO.   */
 /* INDEX ALIGNMENT. %NAMEADD, %NAMECOPY, NAME ASSIGNMENT AND NAME    */
 /* COMPARISONS DO NOT ADJUST FOR AUTOMATIC INDEX ALLIGNMENT FOR      */
 /* MULTI-COPIED STRUCTURE NODES.                                     */
         IF (HALMAT_OPCODE=85) | (HALMAT_OPCODE=86) |
            (HALMAT_OPCODE=87) | ((HALMAT_OPCODE=90) &
 /*CR13570*/(PMINDEX=3)) | ((HALMAT_OPCODE=90) & (PMINDEX=6)) |
            ((HALMAT_OPCODE=25) & NAME_SUB)                       /* DR109032 */
         THEN CALL FIX_STRUCT_INX(0,PTR);
 /*********** END DR105054 RPC ****************************************/
         CALL SUBSCRIPT_RANGE_CHECK(PTR);                                       03204500
      END;                                                        /* DR105054 */
      /* DR109018:                                        */
      /* CHECK PREVIOUS NODE VALUES TO DETERMINE          */
      /* LOCATION OF NEW NODE.                            */
      /* PREV. STRUC. NODE:           NEW STRUC. NODE:    */
      /* -------------------          ----------------    */
      /*        IF POINT_REMOTE    =>  LIVES REMOTE       */
      /*        ELSE IF NAME_VAR   =>  LIVES LOCAL        */
      IF POINTS_REMOTE(PTR) THEN LIVES_REMOTE(PTR) = TRUE;
      ELSE IF NAME_VAR(PTR) THEN LIVES_REMOTE(PTR) = FALSE;
      IF (SYT_FLAGS(OP1) & NAME_OR_REMOTE) = NAME_OR_REMOTE THEN
         POINTS_REMOTE(PTR) = TRUE;
      ELSE POINTS_REMOTE(PTR) = FALSE;
      IF (SYT_FLAGS(OP1) & NAME_FLAG) = NAME_FLAG THEN NAME_VAR(PTR) = TRUE;
      CALL LOAD_NAME(PTR, TRUE);                                  /* CR13615 */
END STRUCTURE_LOAD_NAME;

/* ROUTINE TO PROCESS A NAME REMOTE DEREFERENCE.                  /* CR13615 */
STRUCTURE_DEREF : PROCEDURE;
    NR_DEREF(PTR) = TRUE;                                         /* CR12432 */
    /*GET STACK SPACE IF DATA_REMOTE AND THE STRUCTURE BEING      /* DR109095 */
    /*DEREFERENCED IS NOT A NAME STRUCTURE. THIS STACK SPACE      /* DR109095 */
    /*MAY BE NEEDED IN EMITOP.                                    /* DR109095 */
    IF DATA_REMOTE & ((SYT_FLAGS(LOC(PTR))&NAME_FLAG)=0)          /* DR109095 */
       & (CSECT_TYPE(LOC(PTR))=LOCAL#D)                           /* DR109095 */
    THEN DO;                                                      /* DR109095 */
      IF NR_BASE(PTR) = 0 THEN                                    /* DR109095 */
         NR_BASE(PTR)=GETFREESPACE(DINTEGER,1);                   /* DR109095 */
    END;                                                          /* DR109095 */
    /*************************************************************** CR12432 */
    /* IF NR IN LOCAL STRUCT, ADD OFFSET TO DISP                  /* CR12432 */
    /* (DO NOT USE THAT OFFSET AS AN INDEX)                       /* CR12432 */
    IF (SYT_FLAGS(NR_PREVLOC)&REMOTE_FLAG)=0 THEN DO;             /* CR12432 */
       NR_DELTA(PTR) = STRUCT_CON(PTR);                           /* CR12432 */
       STRUCT_CON(PTR) = 0;                                       /* CR12432 */
    END;                                                          /* CR12432 */
    /*************************************************************** CR12432 */
    /* HANDLE A VARIABLE STRUCTURE INDEX (MULTI_COPY)             /* CR12432 */
    IF (INX(PTR) > 0) THEN DO;                                    /* CR12432 */
       IF (SYT_FLAGS(NR_PREVLOC) & REMOTE_FLAG) ^= 0 THEN DO;     /* CR12432 */
           /* STR.NR: SIMPLY ADJUST INDEX FOR AUTO-ALIGN          /* CR12432 */
           IF STRUCT_INX(PTR) = 5 THEN DO;                        /* DR111315 */
              CALL FIX_STRUCT_INX(0,PTR);                         /* CR12432 */
              STRUCT_INX(PTR) = 5;                                /* DR111315 */
           END;                                                   /* DR111315 */
           ELSE CALL FIX_STRUCT_INX(0,PTR);                       /* DR111315 */
       END;                                                       /* DR111315 */
       ELSE DO;                                                   /* CR12432 */
           /* ST.NR: MUST LOAD BASE + INDEX IN REGISTER           /* CR12432 */
           CALL FORCE_ADDRESS(-1, PTR, 1);                        /* CR12432 */
           DISP(PTR) = 0;                                         /* CR12432 */
           BASE(PTR), BACKUP_REG(PTR) = REG(PTR);                 /* CR12432 */
           FORM(PTR) = CSYM;                                      /* CR12432 */
       END;                                                       /* CR12432 */
    END;                                                          /* CR12432 */
    /*************************************************************** CR12432 */
    /* SET UP VIRTUAL BASE REG IF NEEDED                          /* CR12432 */
    IF FORM(PTR)=INL THEN DO;                                     /* CR12432 */
       /* ADD DR103659 CODE HERE SO WE HAVE AN INDEX              /* CR12432 */
       /* SAVE & RESTORE CURRENT TARGET REGISTER ALREADY ALLOCATED/* CR12432 */
       INX_CON(PTR)=STRUCT_CON(PTR);                              /* CR12432 */
       STRUCT_CON(PTR)=0;                                         /* CR12432 */
       TEMP2 = TARGET_REGISTER;                                   /* CR12432 */
       TARGET_REGISTER = -1;                                      /* CR12432 */
       CALL SUBSCRIPT_RANGE_CHECK(PTR,1);                         /* CR12432 */
       TARGET_REGISTER = TEMP2;              /* END DR103659 CODE /* CR12432 */
       FORM(PTR)=SYM;                                             /* CR12432 */
       IF (CSECT_TYPE(LOC(PTR)) ^= LOCAL#D) |                     /* DR111318 */
          ((DISP(PTR) + NR_DELTA(PTR)) > 2047) |         /* DR111374,DR111318 */
          (TAG2(1) ^= 1)                                          /* DR111374 */
       THEN CALL GUARANTEE_ADDRESSABLE(PTR,L,BY_NAME,TRUE);       /* CR12432 */
    END;                                                          /* CR12432 */
    /*************************************************************** CR12432 */
    /* OFFSET TO NAME REMOTE NODE TO DEREF CAN BE TOO BIG         /* CR12432 */
    /* FOR DISP FIELD OF INST: IF SO, LOAD IT SEPARATELY.         /* CR12432 */
    IF (DISP(PTR)+NR_DELTA(PTR)) > 2047 THEN DO;                  /* CR12432 */
       TEMP2 = INX(PTR);                                          /* CR12432 */
       INX(PTR) = 0; /* USE NO INDEX */                           /* CR12432 */
       IF FORM(PTR)=SYM THEN DO;                                  /* CR12432 */
          FORM(PTR) = CSYM;                                       /* CR12432 */
          DISP(PTR) = SYT_DISP(LOC(PTR)) + NR_DELTA(PTR);         /* CR12432 */
          BASE(PTR) = PRELBASE;                                   /* CR12432 */
       END;                                                       /* CR12432 */
       ELSE DISP(PTR) = DISP(PTR) + NR_DELTA(PTR);                /* CR12432 */
       CALL FORCE_ADDRESS(-1, PTR, 1);                            /* CR12432 */
       DISP(PTR), NR_DELTA(PTR) = 0;                              /* CR12432 */
       BASE(PTR), BACKUP_REG(PTR) = REG(PTR);                     /* CR12432 */
       FORM(PTR) = CSYM;                                          /* CR12432 */
       INX(PTR) = TEMP2;                                          /* CR12432 */
    END;                                                          /* CR12432 */
    /*************************************************************** CR12432 */
    IF NAME_FUNCTION(PTR) & (FORM(PTR)^=NRTEMP) THEN     /* DR111390,CR12432 */
       /* NR WAS LOADED INTO REG FOR NAME FUNC BY G_A BECAUSE        CR12432 */
       /* DEREF() RETURNS FALSE THERE BECAUSE LOC2 ONLY GETS         CR12432 */
       /* SET IN STRUCTURE_DECODE BY WALKING STRUCT.(YOU CANT        CR12432 */
       /* TELL NAME(NSTR.NR) IS DEREF UNTIL YOU SEE 2ND NODE)        CR12432 */
       CALL NR_PUT_ON_STACK(PTR,BASE(PTR),OP1);                   /* CR12432 */
          /* DONT SKIP LOAD                                       /* CR12432 */
          /* IF MAJOR STRUCT IS REMOTE OR NR DEREF IS STRUCT, OR  /* CR12432 */
          /* STRUCTURE IS A NAME REMOTE FORMAL PARAMETER, OR      /* DR111331 */
          /* WHAT WAS LODADED IS LOCAL NAME.                      /* DR111331 */
       IF ( ^LIVES_REMOTE(PTR) &                          /* CR12432,DR111331 */
            (SYT_FLAGS(NR_PREVLOC) & POINTER_FLAG) = 0 ) |        /* DR111331 */
          (SYT_FLAGS(NR_PREVLOC)&REMOTE_FLAG) = 0                 /* CR12432 */
       /* INDICATE RNR FOR NEXT S_D CALL (MORE NODES)             /* CR12432 */
       THEN LIVES_REMOTE(PTR)=TRUE;                               /* CR12432 */
       ELSE CALL STRUCTURE_LOAD_NAME;                             /* CR13615 */
END STRUCTURE_DEREF;

       CALL DECODEPIP(OP, 1);                                                   03201000
       /* KEEP TRACK OF PREVIOUS NODE OF STRUCTURE WALK             -CR12432 */
       /* (WILL BE ROOT UNLESS A NAME NODE IS ENCOUNTERED).         -DR109093 */
       /* WHEN A NAME NODE IS ENCOUNTERED, IT MUST BE DEREFERENCED  -DR109093 */
       /* WHICH CAN CHANGE THE REMOTENESS OF THE REMAINING NODES;   -DR109093 */
       /* ADDRESSING IS DONE DIFFERENTLY ACCORDING TO REMOTENESS.   -DR109093 */
       IF SYT_DIMS(LOC(PTR)) = LOC2(PTR) THEN            /* AT ROOT -CR12432 */
          SAVEOP1 = LOC(PTR);                                     /* DR109093 */
       NR_PREVLOC = SAVEOP1;                                      /* DR109093 */
       LOC2(PTR) = OP1;                                                         03201500
       STRUCT_CON(PTR) = STRUCT_CON(PTR) + SYT_ADDR(OP1);                       03202000
       IF (FLAG ^= 3) | (CLASS ^= 0) THEN                         /* DR109077 */
         IF ^(BY_NAME & TAG2(1)) THEN                                           03202500
           IF (SYT_FLAGS(OP1) & NAME_FLAG) ^= 0 THEN DO;                        03203000
       /************************************************************ CR12432 */
       /* REMOVED BX114 ERROR                                     /* CR12432 */
       /* MUST ALSO CHECK IF PREVIOUS NODE IS NAME REMOTE         /* CR12432 */
       /* TO DETECT A NR DEREF OF THE FORM NAME(NR.N)             /* CR12432 */
            IF ( ((SYT_FLAGS(OP1) & REMOTE_FLAG) ^= 0) |          /* CR12432 */
                 ((SYT_FLAGS(NR_PREVLOC) & NAME_OR_REMOTE) =      /* CR12432 */
                   NAME_OR_REMOTE) |                      /* CR12432 DR111331 */
       /* A NR DEREF ALSO OCCURS IF THE STRUCTURE IS A REMOTE     /* DR111331 */
       /* FORMAL PARAMETER                                        /* DR111331 */
                 ( ((SYT_FLAGS(NR_PREVLOC) & POINTER_FLAG) ^= 0) &      /* "" */
                   ((SYT_FLAGS(NR_PREVLOC) & REMOTE_FLAG) ^= 0) ) )     /* "" */
               & DEREF(PTR)                                       /* CR12432 */
            THEN CALL STRUCTURE_DEREF;                            /* CR13615 */
            ELSE CALL STRUCTURE_LOAD_NAME;                        /* CR13615 */
       /************************************************************ CR12432 */
       END;                                                                     03209500
       /* KEEP TRACK OF PREVIOUS NODE OF STRUCTURE WALK             -CR12432 */
       /* (WILL BE ROOT UNLESS A NAME NODE IS ENCOUNTERED)          -DR109093 */
       IF (SYT_FLAGS(OP1) & NAME_FLAG) ^= 0 THEN                  /* DR109093 */
         SAVEOP1 = OP1;                                           /* CR12432 */
       BY_NAME = FALSE;                                                         03210000
      END STRUCTURE_DECODE;                                                     03210500
                                                                                03211000
 /* SUBROUTINE TO SET UP THE INDIRECT STACK FOR A LINE OF HALMAT  */            03211500
 /*****************************************************************/            03211520
 /* DR101335 - ADD CODE TO SET THE ELEMENTS OF THE INDIRECT_STACK */            03211540
 /*   I_PNTREMT (POINTS_REMOTE) AND I_LIVREMT (LIVES_REMOTE).     */            03211560
 /* DR102961 - MODIFIED THE WAY POINTS_REMOTE IS SET.             */            03211540
 /*                                                               */            03211580
 /*   POINTS_REMOTE = TRUE (1) ::= NAME REMOTE VARIABLE.          */            03211620
 /*   POINTS_REMOTE = FALSE (0) ::= OTHER THAN NAME REMOTE.       */            03211640
 /*   LIVES_REMOTE = TRUE (1) ::= REMOTE DATA ITEM. NOT SET FOR   */            03211660
 /*                  NAME VARIABLES THAT WERE INCLUDED REMOTELY,  */            03211680
 /*                  USE THE INCLUDED_REMOTE FLAG INSTEAD.        */            03211700
 /*   (#DNAME)       SET FOR MIGRATED #D DATA.                    */            58710000
 /*   LIVES_REMOTE = FALSE (0) ::= LOCAL DATA EXCEPT FOR NAMEVARS */            03211720
 /*****************************************************************/            03211740
 /*****************************************************************/
 /*                                                                /*CR13616*/
 /* BY_NAME = TRUE (1)                                             /*CR13616*/
 /* ::= THE DESTINATION VARIABLE IN A NAME ASSIGNMENT, NAME        /*CR13616*/
 /*     INITIALIZATION, OR %NAMEADD/%NAMECOPY MACRO,               /*CR13616*/
 /* ::= A NAME ASSIGN ARGUMENT IN A PROCEDURE CALL,                /*CR13616*/
 /* ::= A SUBSCRIPT IN A NAME PSEDUO-FUNCTION AND THE STATEMENT    /*CR13616*/
 /*     IS AN ASSIGNMENT-TYPE STATEMENT,                           /*CR13616*/
 /* ::= AN ARGUMENT IN THE SIZE BUILT-IN FUNCTION,                 /*CR13616*/
 /* ::= THE SOURCE IN A %NAMEBIAS MACRO,                           /*CR13570*/
 /* ::= AN EQUATE EXTERNAL INITIALIZATION, OR                      /*CR13616*/
 /* ::= FOR BFS ONLY, GETLABEL CALLS THE PROCEDURE. (FOR THIS      /*CR13616*/
 /*     CASE, BY_NAME IS ONLY REFERENCED IN SIZEFIX.               /*CR13616*/
 /*     SEE SIZEFIX FOR DETAILS)                                   /*CR13616*/
 /*                                                                /*CR13616*/
 /* BY_NAME = 2 (THIS IS NECESSARY TO DISTINGUISH FROM 0 IN        /*CR13616*/
 /*              SIZEFIX.  SEE SIZEFIX FOR DETAILS.)               /*CR13616*/
 /* ::= PROCESSING OPERANDS IN REAL-TIME STATEMENTS, OR            /*CR13616*/
 /* ::= FOR PASS ONLY, GETLABEL CALLS THE PROCEDURE.               /*CR13616*/
 /*                                                                /*CR13616*/
 /*****************************************************************/
GET_OPERAND:                                                                    03212000
 /?P  /* CR11114 -- BFS/PASS INTERFACE; CHANGES GET_OPERAND TO CATCH */
      /*            EVENTS AND TASK/PROG EVENTS (FOR BFS)            */
      PROCEDURE(OP, FLAG, BY_NAME, N) BIT(16);                                  03212500
         DECLARE (OP, N, PTR, SAVCTR) BIT(16), (FLAG, BY_NAME) BIT(1);          03213000
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; CHANGES GET_OPERAND TO CATCH */
      /*            EVENTS AND TASK/PROG EVENTS (FOR BFS)            */
   PROCEDURE(OP, FLAG, BY_NAME, N, PROCESS_OK) BIT(16);
   DECLARE
        OP                             BIT(16),
        FLAG                           BIT(1),
        BY_NAME                        BIT(1),
        N                              BIT(16),
        PROCESS_OK                     BIT(1),
        PTR                            BIT(16),
        SAVCTR                         BIT(16);
 ?/
         DECLARE TEMPLATE_OP1 BIT(16);         /*DR109056*/
         DECLARE MULT_COPIED_MAJ_STRUC BIT(1); /* DR102965 */
         MULT_COPIED_MAJ_STRUC = FALSE; /* DR102965 */
         TEMPLATE_OP1 = 0;                     /*DR109056*/
         VAC_FLAG = FALSE;                                                       3213100
         CALL DECODEPIP(OP, N);                                                 03213500
         DO CASE TAG1;                                                          03214000
 /* TAG=0  ABSENT OPERAND  */                                                   03214500
            ;  /* SHOULDN'T GET HERE  */                                        03215000
 /* TAG=1  SYMBOL TABLE VARIABLE  */                                            03215500
            IF SYT_DISP(OP1) < 0 THEN DO;                                        3216000
               PTR = COPY_STACK_ENTRY(-SYT_DISP(OP1), 4);                        3216100
               CALL SET_NEXT_USE(PTR, CTR+OP);                                   3216200
            END;                                                                 3216300
            ELSE DO;                                                             3216400
               PTR = GET_STACK_ENTRY;                                           03216500
               FORM(PTR) = SYM;                                                 03217000
               LOC(PTR), LOC2(PTR) = OP1;                                       03217500
               CALL SET_NEXT_USE(PTR, CTR+OP);                                   3217600
               CALL UPDATE_CHECK(OP1);                                          03218000
 /*************  DR102961  RAH **************************************/
               IF (SYT_FLAGS(OP1) & NAME_OR_REMOTE) = NAME_OR_REMOTE THEN       03218505
                  POINTS_REMOTE(PTR) = TRUE;                                    03218510
               /* SET POINTS_REMOTE FOR FORMAL PASS-BY-REF PARMS CR12935*/      65570000
               ELSE                                            /*CR12935*/      65580000
               IF ((SYT_FLAGS(OP1) & POINTER_FLAG) ^= 0) &     /*CR12935*/      65590000
                  ((SYT_FLAGS(OP1) & REMOTE_FLAG) ^= 0) THEN   /*CR12935*/      65600000
                  POINTS_REMOTE(PTR) = TRUE;                   /*CR12935*/      65610000
               ELSE IF (SYT_FLAGS(OP1) & REMOTE_FLAG) = REMOTE_FLAG THEN        03218525
                  LIVES_REMOTE(PTR) = TRUE;                                     03218530
            /*--------------------- #DNAME --------------------------*/         59010025
            /* ALLOW NAME REMOTE VARIABLES TO POINT TO MIGRATED #D   */         59020025
               ELSE IF DATA_REMOTE & (CSECT_TYPE(LOC(PTR),PTR) = LOCAL#D)       59030099
                  THEN LIVES_REMOTE(PTR) = TRUE;                                59040099
            /*-------------------------------------------------------*/         59050025
 /*************  END DR102961  **************************************/
 /*************  DR102965  RAH **************************************/
               IF (SYT_FLAGS(OP1) & NAME_FLAG) = NAME_FLAG THEN
                  NAME_VAR(PTR) = TRUE;
 /*************  END DR102965  **************************************/
SYM_COM: /* DR109018 -- MOVED HERE TO AVOID REPROCESSING STURCTURES */
               IND_STACK(PTR).I_DSUBBED = 0;   /*** DR54572 ***/                03218750
               TYPE(PTR) = SYT_TYPE(OP1);                                       03219000
 /?P           /* CR11114 -- BFS/PASS INTERFACE; EVENT HANDLING */
               IF TYPE(PTR) >= TASK_LABEL THEN                                  03219500
                  TYPE(PTR) = BOOLEAN;                                          03220000
 ?/
 /?B           /* CR11114 -- BFS/PASS INTERFACE; EVENT HANDLING */
               IF TYPE(PTR) >= TASK_LABEL THEN DO;
                  IF ^PROCESS_OK THEN
                     GO TO UNIMPLEMENTED;
                  ELSE
                     TYPE(PTR) = BOOLEAN;                                       03220000
               END;
               IF TYPE(PTR) = EVENT THEN
                  GO TO UNIMPLEMENTED;
 ?/
               ELSE IF TYPE(PTR) = STRUCTURE THEN                               03220500
               IF PACKFUNC_CLASS(SYT_CLASS(OP1)) | (SYT_FLAGS(OP1)&NAME_FLAG)^=003221000
                  THEN OP1 = SYT_DIMS(OP1);                                     03221500
               CALL SIZEFIX(PTR, OP1, BY_NAME);                                 03222000
               CALL DIMFIX(PTR, OP1);                                           03222500
               CALL VM_COPIES(PTR, N);                                           3223000
               CALL SYT_COPIES(PTR, OP1, FLAG);                                  3223100
               IF ^FLAG THEN CALL FREE_ARRAYNESS(PTR, FLAG);                    03223500
            END;                                                                03224000
 /* TAG=2  GLOBAL INTERNAL VARIABLE  */                                         03224500
            ;                                                                   03225000
 /* TAG=3  VIRTUAL ACCUMULATOR  */                                              03225500
            DO;                                                                 03226000
               PTR = FETCH_VAC(OP1, N);                                         03226500
               /* CODE MOVED FROM THE GENCLAS8::NINT CASE.          /*DR120230*/
               IF INITREPTING THEN DO;                              /*DR120230*/
                 SAVE_STACK = TRUE;                       /*DR109067, DR120230*/
                 SAVE_STACK(PTR) = TRUE;                  /*DR109067, DR120230*/
                 PTR = COPY_STACK_ENTRY(PTR);             /*DR109067, DR120230*/
               END;                                                 /*DR120230*/
               CALL SET_NEXT_USE(PTR, CTR+OP);                                   3226550
               CALL VM_COPIES(PTR, N);                                           3226600
               CALL VAC_COPIES(PTR);                                            03227000
            END;                                                                03227500
 /* TAG=4  POINTER  */                                                          03228000
            DO;                                                                 03228500
               SAVCTR = CTR;                                                    03229000
               CTR = OP1;                                                       03229500
               CALL DECODEPIP(1, 1);                                            03230000
 /************ DR102965 START ***********/
               IF TAG1 = SYM THEN DO;                                           03230500
 /************ DR102965 FINISH **********/                                      03230500
 /*DR120230    THE FLAG ARGUMENT SHOULD ALSO BE ONE WHEN ONLY THE MAJOR     */
 /*DR120230    STRUCTURE (NO NODES) IS REFERENCED IN A NAME PSEUDO-FUNCTION */
 /*DR120230    AND PASSED AS AN ARGUMENT.                                   */
 /*DR120230*/     PTR = STRUCTFIX(OP1,(FLAG=3)|((FLAG=4) & TAG2(1)));           03231005
 /*************  DR102961  RAH **************************************/
                  IF (SYT_FLAGS(OP1) & NAME_OR_REMOTE) = NAME_OR_REMOTE THEN    03231010
                     POINTS_REMOTE(PTR) = TRUE;                                 03231015
                  /* SET POINTS_REMOTE FOR FORMAL PASS-BY-REF PARMS CR12935*/   66210000
                  ELSE                                            /*CR12935*/   66220000
                  IF ((SYT_FLAGS(OP1) & POINTER_FLAG) ^= 0) &     /*CR12935*/   66230000
                     ((SYT_FLAGS(OP1) & REMOTE_FLAG) ^= 0) THEN   /*CR12935*/   66240000
                     POINTS_REMOTE(PTR) = TRUE;                   /*CR12935*/   66250000
                  ELSE IF (SYT_FLAGS(OP1) & REMOTE_FLAG) = REMOTE_FLAG THEN     03231030
                     LIVES_REMOTE(PTR) = TRUE;                                  03231035
            /*--------------------- #DNAME --------------------------*/         59450025
            /* ALLOW NAME REMOTE VARIABLES TO POINT TO MIGRATED #D   */         59460025
                  ELSE IF DATA_REMOTE & (CSECT_TYPE(LOC(PTR),PTR) = LOCAL#D)    59470099
                     THEN LIVES_REMOTE(PTR) = TRUE;                             59480099
            /*-------------------------------------------------------*/         59490025
 /*************  END DR102961  **************************************/
 /*************  DR102965  RAH **************************************/
                  IF (SYT_FLAGS(OP1) & NAME_FLAG) = NAME_FLAG THEN
                     NAME_VAR(PTR) = TRUE;
 /*************  END DR102965  **************************************/
               END ;                                                            03231040
               ELSE DO;                                                         03231500
                  PTR = FETCH_VAC(OP1, N);                                      03231510
                  /* CODE MOVED FROM THE GENCLAS8::NINT CASE.       /*DR120230*/
                  IF INITREPTING THEN DO;                           /*DR120230*/
                    SAVE_STACK = TRUE;                    /*DR109067, DR120230*/
                    SAVE_STACK(PTR) = TRUE;               /*DR109067, DR120230*/
                    PTR = COPY_STACK_ENTRY(PTR);          /*DR109067, DR120230*/
                  END;                                              /*DR120230*/
                  NEXT_USE(PTR) = 0;                                            03231520
               /* LOC2 SHOULD POINT TO STRUCT TEMPLATE - CR12432 */
                  LOC2(PTR) = SYT_DIMS(LOC(PTR));     /* CR12432 */
                  IF ((SYT_FLAGS(LOC(PTR)) & POINTER_FLAG) ^= 0) & /*DR111331*/
                  ((SYT_FLAGS(LOC(PTR)) & REMOTE_FLAG) ^= 0) THEN  /*DR111331*/
                      POINTS_REMOTE(PTR) = TRUE;                   /*DR111331*/
               END;                                                             03231530
               IF FLAG ^= 3 THEN                                                03232000
                  IF POPTAG(CTR) THEN                                            3232500
 /**********  DR102954  BOB CHEREWATY  *****************/
 /* DISCONTINUE USE OF NAMELOAD.  REPLACE WITH LH.     */
 /* BOTH ARE CONSTANTS FOR LOAD HALFWORD OPCODE.       */
 /******************************************************/
                  CALL GUARANTEE_ADDRESSABLE(PTR, LH, BY_NAME & TAG2(1), 2);    03233000
 /**********  DR102954  END  ***************************/
 /*************  DR102965  RAH **************************************/
               IF (TAG1 = 3)  & (TAG2(1) = 1) THEN DO;
                  CTR = OP1;
                  CALL DECODEPIP(1, 1);
                  IF (SYT_FLAGS(OP1) & NAME_OR_REMOTE) = NAME_OR_REMOTE THEN
                     POINTS_REMOTE(PTR) = TRUE;
                  ELSE IF (SYT_FLAGS(OP1) & REMOTE_FLAG) = REMOTE_FLAG THEN
                     LIVES_REMOTE(PTR) = TRUE;
            /*--------------------- #DNAME --------------------------*/         59760025
            /* ALLOW NAME REMOTE VARIABLES TO POINT TO MIGRATED #D   */         59770025
                  ELSE IF DATA_REMOTE & (CSECT_TYPE(LOC(PTR),PTR) = LOCAL#D)    59780099
                     THEN LIVES_REMOTE(PTR) = TRUE;                             59790099
            /*-------------------------------------------------------*/         59800025
                  IF (SYT_FLAGS(OP1) & NAME_FLAG) = NAME_FLAG THEN
                     NAME_VAR(PTR) = TRUE;
                  MULT_COPIED_MAJ_STRUC = TRUE;
               END;
               ELSE DO OP = 2 TO POPNUM(CTR);                                    3233500
                  IF ^TAG2(1) | (OP = 2) THEN DO;                               03234000
 /********************** END DR102965 *********************************/
                     CALL STRUCTURE_DECODE(PTR, OP, BY_NAME, FLAG); /*DR109077*/03234505

                     /* DR109018:                                           */
                     /* CHECK IF PROCESSING THE LAST NODE (TAG2(1)=1) TO BE */
                     /* NAME-ASSIGNED INTO (BY_NAME) (STRUCTURE_DECODE DID  */
                     /* NOT PROCESS THIS NODE). LOOK FOR A NAME REMOTE      */
                     /* DEREFERENCE BY CALLING DEREF NOW SINCE THIS NAME    */
                     /* VARIABLE WOULD NOT BE CHECKED NORMALLY. ALSO SET    */
                     /* LIVES_REMOTE VARIABLE ACCORDINGLY.                  */
                     /*                                                     */
                     /* DO NOT PROCESS LAST_NODE FOR A SIZE FUNCTION/*DR120218*/
                     /* AND AN EQUATE EXTERNAL (I.E, FLAG=3)        /*DR120218*/
                     /* THE CODE TO ESCAPE LAST_NODE FOR EQUATE     /*DR120218*/
                     /* EXTERNAL WAS REMOVED SINCE IT WILL NO LONGER/*DR120218*/
                     /* BE ENTERED WITH THIS DR FIX.                /*DR120218*/
                     IF BY_NAME & TAG2(1) & (FLAG ^= 3) THEN        /*DR120218*/
LAST_NODE:           DO;
                        /* CANNOT BE A NON-NAME UNLESS PROCESSING A */
                        /* STRUCTURE TEMPLATE WHICH DEFINES A NAME  */
                        /* STRUCTURE REFERENCE W/OUT ANY NODES (OP1 */
                        /* NOW POINTS TO THE STRUCTURE TEMPLATE --  */
                        /* NAME STRUCTURE WOULD HAVE BEEN LOADED IN */
                        /* THE ABOVE CODE) ... SKIP PROCESSING.     */
                        IF (SYT_FLAGS(OP1)&NAME_FLAG) = 0 THEN
                           ESCAPE LAST_NODE;


                     /* CHECK FOR A NAME REMOTE DEREFERENCE */
                     /* REMOVED BX114 ERROR                        /* CR12432 */
                     /* SEE IF THIS IS NAME(NR.N) ON LHS OF NASN.     CR12432 */
                     /* MUST PUT LOADED NR ON STACK SO STORE@# WORKS  CR12432 */
                        IF DEREF(PTR) &                            /* CR12432 */
                        (((SYT_FLAGS(OP1) & REMOTE_FLAG) ^= 0) |   /* CR12432 */
                         ((SYT_FLAGS(NR_PREVLOC) & NAME_OR_REMOTE) /* CR12432 */
                          = NAME_OR_REMOTE)                        /* CR12432 */
     /*DR111368*/       | ((SYT_FLAGS(NR_PREVLOC) & POINTER_FLAG) ^= 0))
                        THEN DO;                                   /* CR12432 */
                           CALL NR_PUT_ON_STACK(PTR,BASE(PTR),OP1);/* CR12432 */
                           NR_DEREF(PTR) = TRUE;                   /* CR12432 */
                        /* ADD DR103659 CODE HERE SO WE HAVE AN INDEX CR12432 */
 /*-- SAVE AND RESTORE CURRENT TARGET REGISTER ALREADY ALLOCATED.*//* CR12432 */
                           TEMP2 = TARGET_REGISTER;                /* CR12432 */
                           TARGET_REGISTER = -1;                   /* CR12432 */
                           CALL SUBSCRIPT_RANGE_CHECK(PTR,1);      /* CR12432 */
                           TARGET_REGISTER = TEMP2;                /* CR12432 */
                        END;                                       /* CR12432 */

                        /* CHECK PREVIOUS NODE VALUES TO DETERMINE  */
                        /* LOCATION OF NEW NAME NODE.               */
                        /*                                          */
                        /* PREV. STRUC. NODE:     NEW STRUC. NODE:  */
                        /* -------------------    ----------------  */
                        /*  IF POINT_REMOTE    =>  LIVES REMOTE     */
                        /*  ELSE IF NAME_VAR   =>  LIVES LOCAL      */
                        IF POINTS_REMOTE(PTR) THEN LIVES_REMOTE(PTR) = TRUE;
                        ELSE IF NAME_VAR(PTR) THEN LIVES_REMOTE(PTR) = FALSE;
                     END; /* END OF LAST_NODE LABEL -- ALL ESCAPES COME HERE */

                     IF (SYT_FLAGS(OP1) & NAME_OR_REMOTE) = NAME_OR_REMOTE
                        THEN POINTS_REMOTE(PTR) = TRUE;
                     ELSE IF (SYT_FLAGS(OP1)&NAME_FLAG)^=0 THEN
                        POINTS_REMOTE(PTR) = FALSE;

                     IF (SYT_FLAGS(OP1) & NAME_FLAG) = NAME_FLAG THEN
                        NAME_VAR(PTR) = TRUE;

                  END;                                                          03234540
   /* IF THIS IS THE LAST HALMAT ENTRY, THE LAST STRUCTURE NODE       DR109056*/
   /*  HAS BEEN PROCESSED AND IS A STRUCTURE, THEN SET                DR109056*/
   /*  TEMPLATE_OP1 TO THE SYMBOL TABLE ENTRY FOR THE STRUCTURE       DR109056*/
   /*  TEMPLATE.  THIS WILL THEN BE COPIED INTO OP1 SO THAT DEL       DR109056*/
   /*  WILL BE CORRECT FOR STRUCTURE NODES OF STRUCTURE TYPE.         DR109056*/
                  ELSE IF ( (OP = POPNUM(CTR)) & (TAG2(1) = 1) &    /*DR109056*/
                     (SYT_TYPE(LOC2(PTR)) = STRUCTURE) )            /*DR109056*/
                     THEN TEMPLATE_OP1 = SHR(OPR(OP+CTR), 16);      /*DR109056*/
               END;                                                             03235000
 /*************  DR102965  RAH **************************************/
               IF (FLAG ^= 3) & ^MULT_COPIED_MAJ_STRUC THEN
                  IF (SYT_FLAGS(OP1) & NAME_FLAG) = 0 THEN
                  STRUCT_CON(PTR) = STRUCT_CON(PTR) + SYT_CONST(OP1);           03236000
 /*************  END DR102965  **************************************/
               CTR = SAVCTR;                                                    03236500
               IF TEMPLATE_OP1 = 0 THEN OP1 = LOC2(PTR);  /*DR109056*/
               ELSE OP1 = TEMPLATE_OP1;                   /*DR109056*/
               GO TO SYM_COM;                                                   03237500
            END;                                                                03238000
 /* TAG=5  LITERAL  */                                                          03238500
            DO;                                                                 03239000
               PTR = GET_STACK_ENTRY;                                           03239500
               CALL LITERAL(OP1, LITTYPE, PTR);                                 03240000
               LOC(PTR) = OP1;                                                  03240500
               FORM(PTR) = LIT;                                                 03241000
            END;                                                                03241500
 /* TAG=6  IMMEDIATE  */                                                        03242000
            PTR = GET_INTEGER_LITERAL(OP1);                                     03242500
 /* TAG=7  ASTERISK  */                                                         03243000
            ;                                                                   03243500
 /* TAG = 8  COMPONENT SIZE  */                                                 03244000
            ;                                                                   03244500
 /* TAG = 9  ARRAY / STRUCTURE SIZE  */                                         03245000
            ;                                                                   03245500
 /* TAG=10  OFFSET  */                                                          03246000
            DO;                                                                 03246500
               PTR = GET_STACK_ENTRY;                                           03247000
               VAL(PTR) = OP1;                                                  03247500
               FORM(PTR) = TAG1;                                                03248000
            END;                                                                03248500
            ;  ;  ;  ;  ;  /* INSURANCE  */                                     03249000
            END;  /* DO CASE TAG1  */                                           03249500
         FLAG, N, BY_NAME = 0;                                                  03250000
 /?B     /* CR11114 -- BFS/PASS INTERFACE; EVENT HANDLING */
         PROCESS_OK = 0;
 ?/
         RETURN PTR;                                                            03250500
      END GET_OPERAND;                                                          03251000
                                                                                03251500
 /* ROUTINE TO LOCATE NEXT FUNCTIONAL OPERATOR IN HALMAT */                     03252000
SKIP_NOP:                                                                       03252500
      PROCEDURE(PTR) BIT(16);                                                   03253000
         DECLARE PTR BIT(16);                                                   03253500
         DO WHILE NEXTPOPCODE(PTR) <= XEXTN;                                     3254000
            PTR = NEXTCTR;                                                      03254500
         END;                                                                   03255000
         RETURN NEXTCTR;                                                        03255500
      END SKIP_NOP;                                                             03256000
                                                                                03256500
 /* SUBROUTINE TO SET UP SYMBOLIC INDIRECT STACK FROM KNOWN SYMBOL */           03257000
SET_OPERAND:                                                                    03257500
      PROCEDURE(OP) BIT(16);                                                    03258000
         DECLARE (OP, PTR) BIT(16);                                             03258500
         PTR = GET_STACK_ENTRY;                                                 03259000
         TYPE(PTR) = SYT_TYPE(OP);                                              03259500
         LOC(PTR), LOC2(PTR) = OP;                                              03260000
         FORM(PTR) = SYM;                                                       03260500
         IF TYPE(PTR) = STRUCTURE THEN                                          03261000
            OP = SYT_DIMS(OP);                                                  03261500
         CALL SIZEFIX(PTR, OP);                                                 03262000
         RETURN PTR;                                                            03262500
      END SET_OPERAND;                                                          03263000
                                                                                03263500
 /* SUBROUTINE TO PICK UP OPERANDS FOR ARITHMETIC AND LOGICAL OPERATIONS  */    03264000
GET_OPERANDS:                                                                   03264500
 /?P     /* CR11114 -- BFS/PASS INTERFACE; EVENT HANDLING */
   PROCEDURE;                                                                   03265000
 ?/
 /?B     /* CR11114 -- BFS/PASS INTERFACE; EVENT HANDLING */
   PROCEDURE(PROCESS_OK);
      DECLARE PROCESS_OK BIT(1);
 ?/
         IF NUMOP=2 THEN DO;  /* GUARANTEE BINARY OPERATOR  */                  03265500
            IF TAG_BITS(1)=LIT THEN DO;                                         03266000
               RIGHTOP=GET_OPERAND(2);                                          03266500
               LITTYPE=TYPE(RIGHTOP);                                           03267000
               LEFTOP=GET_OPERAND(1);                                           03267500
            END;                                                                03268000
            ELSE DO;                                                            03268500
               LEFTOP=GET_OPERAND(1);                                           03269000
               LITTYPE=TYPE(LEFTOP);                                            03269500
               RIGHTOP=GET_OPERAND(2);                                          03270000
            END;                                                                03270500
            IF OPMODE(TYPE(LEFTOP)) >= OPMODE(TYPE(RIGHTOP)) THEN               03271000
               OPTYPE = TYPE(LEFTOP);                                           03271500
            ELSE OPTYPE = TYPE(RIGHTOP);                                        03272000
            IF FORM(LEFTOP)=LIT THEN TYPE(LEFTOP) = OPTYPE;                     03272500
            IF FORM(RIGHTOP)=LIT THEN TYPE(RIGHTOP) = OPTYPE;                   03273000
         END;                                                                   03273500
         ELSE DO;   /* UNARY OPERATOR SETUP  */                                 03274000
 /?P        /* CR11114 -- BFS/PASS INTERFACE; EVENT HANDLING */
            LEFTOP = GET_OPERAND(1);                                            03274500
 ?/
 /?B        /* CR11114 -- BFS/PASS INTERFACE; EVENT HANDLING */
         LEFTOP = GET_OPERAND(1, 0, BY_NAME_FALSE, 0, PROCESS_OK); /*CR13616*/
 ?/
            RIGHTOP = 0;                                                        03275000
            OPTYPE = TYPE(LEFTOP);                                              03275500
         END;                                                                   03276000
 /?B        /* CR11114 -- BFS/PASS INTERFACE; EVENT HANDLING */
      PROCESS_OK = 0;
 ?/
      END GET_OPERANDS;                                                         03276500
                                                                                03277000
 /* ROUTINE TO VERIFY THAT OPERAND IS DIRECTLY ACCESSABLE FROM MEMORY */        03277500
AVAILABLE_FROM_STORAGE:                                                         03278000
      PROCEDURE(OP, OPCODE);                                                    03278500
         DECLARE (OP, OPCODE, ITYPE) BIT(16);                                   03279000
         IF SYMFORM(FORM(OP)) | FORM(OP) = WORK | FORM(OP) = LIT THEN DO;       03279500
            ITYPE = RX;                                                         03280000
            IF FORM(OP) = LIT THEN                                              03280500
               IF OPMODE(OPTYPE) = 1 THEN                                       03281000
               ITYPE = RI;                                                      03281500
            IF MODE_MOD(OPMODE(OPTYPE)+ITYPE) THEN RETURN FALSE;                03282000
            IF ^OPERATOR(MAKE_INST(OPCODE, OPTYPE, ITYPE)) THEN RETURN FALSE;   03282500
            IF BIT_PICK(OP) ^= 0 THEN RETURN FALSE;                              3283000
            IF (CONST(OP) | DEL(OP)) ^= 0 THEN RETURN 2;                        03283500
 /*-- DR103659 -- DANNY STRAUSS ---------------------------------*/             02841700
 /*-- IF IT IS A REMOTE AGGREGATE, NOT YET LOADED (SYM), WITH NO */             02841670
 /*-- INDEX LOADED, THEN WE HAVE BS123 ERROR CASE 2, WHICH IS    */             02841640
 /*-- REFERENCING THE 1ST NODE OF REMOTE SINGLE-COPY STRUCTURE.  */             02841640
            IF (FORM(OP)=SYM) THEN                                              02841670
               IF (SYT_BASE(LOC(OP))=REMOTE_BASE | NR_DEREF(OP)) & /* CR12432 */
               (INX(OP)=0) THEN DO;                                             02841670
 /*-- SAVE AND RESTORE CURRENT TARGET REGISTER ALREADY ALLOCATED.*/             02841640
               TEMP2 = TARGET_REGISTER;                                         02841670
               TARGET_REGISTER = -1;                                            02841670
               CALL SUBSCRIPT_RANGE_CHECK(OP,1); /* FORCE LHI RX,0 */           02841670
               TARGET_REGISTER = TEMP2;                                         02841670
            END;                                                                02841670
 /*--------------------------------------------------------------*/             02841700
            RETURN TRUE;                                                        03285000
         END;                                                                   03285500
         RETURN FALSE;                                                          03286000
      END AVAILABLE_FROM_STORAGE;                                               03286500
                                                                                03287000
 /* SUBROUTINE TO FORCE ITEM DESCRIBED BY INDIRECT STACKS INTO ACCUMULATOR */   03287500
FORCE_ACCUMULATOR:                                                              03288000
      PROCEDURE(OP, OPTYPE, ACCLASS, SHIFTCT);                                  03288500
         DECLARE (OP, OPTYPE, ACCLASS, SHIFTCT, R, RM) BIT(16);                 03289000
         DECLARE(RFORM, CONFLICT, TARGET, WATCHIT, AT_SINGLE) BIT(8);           03289500
 /*-- DR106724 -- LWW  ------------------------------------------*/
         DECLARE DBL_SRC_SING_DEST BIT(8);
 /*-- END DR106724 -- LWW  --------------------------------------*/
                                                                                03290000
 /* LOCAL ROUTINE TO CHECK FOR TYPE CONFLICT ADJUSTMENTS  */                    03290500
RESOLVE_CONFLICT:                                                               03291000
         PROCEDURE(RM);                                                         03291500
            DECLARE RM BIT(16);                                                 03292000
            DECLARE DONT_REUSE_REG BIT(8);         /*DR120265*/
            IF ^CONFLICT THEN RETURN;                                           03292500
            REG(OP) = RM;                                                       03293000
            IF TO_BE_INCORPORATED THEN CALL INCORPORATE(OP, TRUE);               3293500
            DONT_REUSE_REG = FALSE;                /*DR120265*/                 03294000
            DO CASE OPMODE(OPTYPE);                                             03294000
               ;                                                                03294500
            /* [1] NEED HALFWORD FROM FULLWORD INTEGER/BIT OP */                03294500
               DO;                                 /*DR120265*/                 03294500
                  CALL EMITP(SLA, RM, 0, SHCOUNT, 16);                          03295000
                  DONT_REUSE_REG = TRUE;           /*DR120265*/                 03294500
               END;                                /*DR120265*/                 03294500
            /* [2] NEED FULLWORD FROM HALFWORD INTEGER/BIT OP */                03294500
               DO;                                 /*DR120265*/                 03294500
                  IF DATATYPE(TYPE(OP)) = BITS THEN                             03295500
                     CALL EMITP(SRL, RM, 0, SHCOUNT, 16);                       03296000
                  ELSE CALL EMITP(SRA, RM, 0, SHCOUNT, 16);                     03296500
                  DONT_REUSE_REG = TRUE;           /*DR120265*/                 03294500
               END;                                /*DR120265*/                 03294500
            /* [3] NEED SINGLE FROM SCALAR DOUBLE OP */                         03294500
            /* (LEAVE AS IS, UNLESS USED IN A DOUBLE OP LATER: [4]) */          03294500
               DO;                                 /*DR120265*/                 03294500
                  DONT_REUSE_REG = TRUE;           /*DR120265*/                 03294500
               END;                                /*DR120265*/                 03294500
            /* [4] NEED DOUBLE FROM SCALAR SINGLE OP */                         03294500
            /* (ALSO DOUBLE CONVERTED TO SINGLE USED IN DOUBLE OP) */           03294500
               CALL EMITRR(SER, RM+1, RM+1);                                    03297500
            END;                                                                03298000
            /*DR120265: DO NOT REUSE REGISTER IF PRECISION CONFLICT */          03298000
            IF (OPTYPE & 8) ^= (TYPE(OP) & 8) THEN /*DR120265*/                 03303500
               IF USAGE(RM) THEN                   /*DR120265*/                 03303500
                  IF DONT_REUSE_REG THEN           /*DR120265*/                 03303500
                     R_VAR(RM)=0;                  /*DR120265*/                 03298000
         END RESOLVE_CONFLICT;                                                  03298500
                                                                                03299000
 /*-- DR103659 -- DANNY STRAUSS ---------------------------------*/             02841700
 /*-- IF IT IS A REMOTE AGGREGATE, NOT YET LOADED (SYM), WITH NO */             02841670
 /*-- INDEX LOADED, THEN WE HAVE BS123 ERROR CASE 2, WHICH IS    */             02841640
 /*-- REFERENCING THE 1ST NODE OF REMOTE SINGLE-COPY STRUCTURE.  */             02841640
         IF (FORM(OP)=SYM) THEN                                                 02841670
            IF (SYT_BASE(LOC(OP))=REMOTE_BASE | NR_DEREF(OP)) & /* CR12432 */
            (INX(OP)=0) THEN DO;                                                02841670
 /*-- SAVE AND RESTORE CURRENT TARGET REGISTER ALREADY ALLOCATED.*/             02841640
            TEMP2 = TARGET_REGISTER;                                            02841670
            TARGET_REGISTER = -1;                                               02841670
            CALL SUBSCRIPT_RANGE_CHECK(OP,1); /* FORCE LHI RX,0 */              02841670
            TARGET_REGISTER = TEMP2;                                            02841670
         END;                                                                   02841670
 /*--------------------------------------------------------------*/             02841700
         IF SELF_ALIGNING THEN SHIFTCT = 0;                                     03299500
         RFORM, CONFLICT, WATCHIT, AT_SINGLE = FALSE;                           03300000
 /*-- DR106724 -- LWW  ------------------------------------------*/
         DBL_SRC_SING_DEST = FALSE;
 /*-- END DR106724 -- LWW  --------------------------------------*/
         IF DECLMODE THEN CALL RESUME_LOCCTR(NARGINDEX);                        03300500
        IF TO_BE_INCORPORATED THEN IF (BIT_PICK(OP)|DEL(OP)|CONST(OP)) ^= 0 THEN 3301000
            TO_BE_MODIFIED = TRUE;                                              03301500
         TARGET = TARGET_REGISTER>=0;                                           03302000
         IF OPTYPE >= EXTRABIT THEN                      /*DR109060*/           03302500
            IF OPTYPE ^= EVENT THEN OPTYPE = FULLBIT;    /*DR109060*/
         IF OPTYPE = 0 THEN OPTYPE = TYPE(OP);                                  03303000
         ELSE IF (OPTYPE & 8) ^= (TYPE(OP) & 8) THEN                            03303500
         DO;                                             /*DR120265*/           03304000
            CONFLICT = TRUE;                             /*DR120265*/           03306540
            IF OPMODE(OPTYPE) = 3 THEN WATCHIT = TRUE;                          03304000
         END;                                            /*DR120265*/           03304000
 /* DR64924: CHECK FOR @SINGLE CODE FOR SCALARS (HALMAT 5A1), */                03304120
 /* VECTORS (441) AND MATRICES (341)                          */                03304140
         IF (CLASS=3 | CLASS=4 | CLASS=5) & (SUBCODE=2 | SUBCODE=5)             03304160
            & OPCODE=1 & TAG=1 THEN AT_SINGLE = TRUE;                           03304180
         /*DR120265: CLEAR DOUBLE FLAG FOR AT_SINGLE     /*DR120265*/           03304180
         IF AT_SINGLE THEN OPTYPE = OPTYPE & "F7";       /*DR120265*/           03304180
         IF FORM(OP) ^= VAC THEN                                                03304500
            IF CVTTYPE(OPTYPE) = CVTTYPE(TYPE(OP)) THEN DO;                     03305000
            INX_SHIFT(OP) = SHIFTCT;                                            03305500
            R = SEARCH_REGS(OP);                                                03306000
            IF R >= 0 THEN DO;                                                  03306500
 /************** DR58234  R. HANDLEY  24/02/89 ********************/            03306505
 /*                                                               */            03306510
 /* CHECK THE REGISTER CONTENTS AGAINST OPTYPE. IF THEY ARE       */            03306515
 /* DIFFERENT PRECISION THEN MAKE SURE THAT A CONVERSION IS DONE. */            03306520
 /*                                                               */            03306525
 /*****************************************************************/            03306530
               IF (OPTYPE & 8) ^= (R_TYPE(R) & 8) THEN                          03306535
               DO;                                       /*DR120265*/           03304000
                  CONFLICT = TRUE;                       /*DR120265*/           03306540
                  IF OPMODE(OPTYPE) = 3 THEN WATCHIT = TRUE;                    03304000
               END;                                      /*DR120265*/           03304000
 /*********************** END DR58234 *****************************/            03306550
R_FOUND:       IF (^RFORM & USAGE(R) > 1 | USAGE(R) > 3) & TO_BE_MODIFIED |     03307000
                  R^=TARGET_REGISTER & TARGET THEN DO;                          03307500
R_MOVE:                                                                         03308000
                  IF ACCLASS = 0 THEN ACCLASS = RCLASS(OPTYPE);                 03308500
                  RM = FINDAC(ACCLASS, TRUE);                                   03309000
                  IF R = RM THEN DO;   /* TARGET REGISTER SAME AS CURRENT */    03310000
                     CALL DROPSAVE(OP);                                         03311500
                  END;                                                          03312000
                  ELSE DO;                                                       3312500
                     CALL CLEAR_R(RM);                                          03312550
                     CALL MOVEREG(R, RM, TYPE(OP), RFORM);                       3312600
                     CALL SET_REG_NEXT_USE(R, OP);                               3312700
                  END;                                                           3312800
                  CALL RESOLVE_CONFLICT(RM);                                    03313000
                  R, REG(OP) = RM;                                              03313500
               END;                                                             03314000
               ELSE IF CONFLICT THEN DO;                                        03314500
                 IF OPMODE(OPTYPE) = 4 & (USAGE(R+1) > 1 | R) THEN GO TO R_MOVE; 3315000
                  CALL RESOLVE_CONFLICT(R);                                     03315500
                  GO TO R_STAY;                                                 03316000
               END;                                                             03316500
               ELSE DO;                                                         03317000
R_STAY:                                                                         03317500
                  REG(OP) = R;                                                  03318500
                  IF ^RFORM THEN CALL INCR_REG(OP);                              3318600
                  USAGE_LINE(R) = 1;                                             3319000
               END;                                                             03319500
               IF ^RFORM THEN DO;                                               03320000
                  CALL DROP_INX(OP);                                            03320500
                  CALL DROPSAVE(OP);                                             3320600
                  IF TO_BE_MODIFIED THEN CALL CLEAR_INX(REG(OP));               03320700
                  IF FORM(OP) = LIT THEN VAL(OP) = VAL(OP) - R_CON(REG(OP));    03321000
                  ELSE CONST(OP) = CONST(OP) - R_CON(REG(OP));                  03321500
               END;                                                             03322000
               GO TO FORCE_RET;                                                 03322500
            END;                                                                03323000
            IF SHIFTCT ^= 0 THEN DO;                                            03323500
               INX_SHIFT(OP) = 0;                                               03324000
               R = SEARCH_REGS(OP);                                             03324500
               TO_BE_MODIFIED = TRUE;                                           03325000
               IF R >= 0 THEN GO TO R_FOUND;                                    03325500
            END;                                                                03326000
         END;                                                                   03326500
         IF FORM(OP) = VAC THEN                                                 03327000
            DO;                                                                 03327500
            R = REG(OP);                                                        03328000
            RFORM = TRUE;                                                       03328500
            IF R_TYPE(R) = OPTYPE THEN DO;                                      03329000
               CONFLICT = FALSE;                                                03329500
               TYPE(OP) = OPTYPE;                                               03330000
            END;                                                                03330500
            IF CONFLICT THEN                                                    03330600
               IF OPMODE(OPTYPE)^=0 & OPMODE(OPTYPE)^= 3 THEN                   03330700
               TO_BE_MODIFIED = TRUE;                                           03330800
            GO TO R_FOUND;                                                      03331000
         END;                                                                   03331500
         IF ACCLASS=0 THEN DO;    /*  DR106724 -NLM-  -ADD DO-    */            03332000
 /* DR106724   IF ACCLASS WAS NOT SPECIFIED AND THE LHS IS SINGLE */
 /*          PRECISION AND THE RHS IS DOUBLE PRECISION, SET THE   */
 /*          FLAG TO FORCE PROPER REGISTER ALLOCATION   */
            IF (TYPE(OP) = 11 | TYPE(OP) = 12 | TYPE(OP) = 13) &
               (OPTYPE = 3 | OPTYPE = 4 | OPTYPE = 5) THEN
               DBL_SRC_SING_DEST = TRUE;
 /*         END OF DR106724       -NLM-                           */
 /* DR64924: SPECIAL CASE FOR @SINGLE CODE */                                   03332050
            IF AT_SINGLE | DBL_SRC_SING_DEST /* DR106724        */              03332100
               THEN ACCLASS=RCLASS(TYPE(OP));                                   03332100
               ELSE ACCLASS=RCLASS(OPTYPE);                                     03332150
         END;    /*  DR 106724 -NLM-   -CLOSE OUT IF THEN DO- */
         R, REG(OP) = FINDAC(ACCLASS);                                          03332500
         IF SYMFORM(FORM(OP)) | FORM(OP) = EXTSYM THEN DO;                      03333000
            IF WATCHIT & ^AT_SINGLE THEN IF ^R THEN CALL CHECKPOINT_REG(R+1);   03333100
            CALL GUARANTEE_ADDRESSABLE(OP, MAKE_INST(LOAD, TYPE(OP), RX));      03333500
            CALL EMIT_BY_MODE(LOAD, R, OP, TYPE(OP));                           03334000
            IF KNOWN_SYM(OP) THEN IF SYT_TYPE(LOC(OP)) ^= EVENT THEN DO;        03335500
               IF SAFE_INX(OP) THEN                                              3336000
                  CALL SET_USAGE(R, SYM, LOC(OP), INX_CON(OP), INX(OP));         3336500
            END;                                                                03338000
            CALL DROP_INX(OP);                                                  03339000
            LOC2(OP) = -1;                                                       3339100
            CALL RESOLVE_CONFLICT(R);                                           03343500
         END;                                                                   03344000
         /* THE NUMBER BEING LOADED IS A LITERAL. */
         ELSE IF FORM(OP) = LIT THEN DO;                                        03344500
            /* THE LITERAL BEING LOADED IS A ZERO. */
            IF VAL(OP) = 0 THEN                                                 03345000
               CALL EMITRR(MAKE_INST(EXOR, OPTYPE, RR), R, R);                  03345500
/*120224   IF THE NUMBER BEING LOADED NEEDS TO BE IN 16-BIT FORMAT &     */
/*120224   NO SHIFTING IS NEEDED THEN LOAD IT NOW REGARDLESS OF THE      */
/*120224   NUMBER'S PRECISION.                                           */
/*120224*/  ELSE IF (OPTYPE = INTEGER | OPTYPE = BITS) & BIT_PICK(OP) = 0 THEN  03346000
               CALL LOAD_NUM(R, VAL(OP));                                       03346500
/*120224   IF THE BIT BEING LOADED IS 16 BITS OR LESS AND IT NEEDS TO BE     */
/*120224   SHIFTED OR IT CANNOT BE RELOADED FROM THE LITERAL TABLE THEN      */
/*120224   LOAD IT AS A HALFWORD AND SHIFT INTO 32-BIT FORMAT SO THE SIGN    */
/*120224   BIT IS NOT PROPAGATED.                                            */
/*120224*/  ELSE IF (BIT_PICK(OP) > 0 | LOC(OP) < 0) &
/*120224*/          (TYPE(OP) = BITS)
/*120224*/  THEN DO;
/*120224*/     CALL LOAD_NUM(R, VAL(OP));
/*120224*/     CALL RESOLVE_CONFLICT(R);
/*120224*/  END;
         ELSE IF OPTYPE=SCALAR & (VAL(OP)&"FF0FFFFF")="41000000" & SELF_ALIGNING03347000
               & COMPACT_CODE THEN CALL EMITRR(LFLI, R, SHR(VAL(OP),20)&"F");   03347500
            /* THESE LITERALS MUST BE LOADED INTO THE CONSTANTS AREA BEFORE */
            /* THEY CAN BE LOADED INTO A REGISTER.                          */
            ELSE DO;                                                            03349000
               IF OPMODE(OPTYPE) = 0 THEN                                       03349500
                  OPTYPE = TYPE(OP);                                            03350000
/*120224   LOAD LITERALS THAT MUST BE SHIFTED AND/OR MASKED DURING RUN-TIME. */
/*120224*/     IF BIT_PICK(OP) > 0 THEN DO;
/*120224*/       CALL SAVE_LITERAL(OP, TYPE(OP));
/*120224*/       CALL EMIT_BY_MODE(LOAD, R, OP, TYPE(OP));
/*120224*/       CALL RESOLVE_CONFLICT(R);
/*120224*/     END;
/*120224   LOAD LITS THAT DON'T NEED TO BE SHIFTED OR MASKED DURING RUN-TIME. */
/*120224*/     ELSE DO;
                 CALL SAVE_LITERAL(OP, OPTYPE);                                 03350500
                 CALL EMIT_BY_MODE(LOAD, R, OP, OPTYPE);                        03351000
/*120224*/     END;
            END;                                                                03351500
            CALL SET_USAGE(R, LIT, VAL(OP), XVAL(OP));                           3352000
         END;                                                                   03354000
         ELSE IF FORM(OP) = WORK THEN DO;                                       03354500
            IF WATCHIT & ^AT_SINGLE THEN IF ^R THEN CALL CHECKPOINT_REG(R+1);   03355000
            CALL ARITH_BY_MODE(LOAD, OP, OP, TYPE(OP));                         03355500
            IF LOC2(OP) >= 0 THEN IF COPT(OP) ^= 0 THEN                          3355600
               CALL SET_USAGE(R, VAC, LOC2(OP));                                 3355700
            CALL RESOLVE_CONFLICT(R);                                           03356000
         END;                                                                   03356500
         INX_SHIFT(OP) = 0;                                                     03357000
FORCE_RET:                                                                      03357500
 /*--------------------- DR103754 ----------------------*/                      03357500
 /* DOUBLE_TYPE MAY NOT GET SET IN SET_USAGE WHEN THE   */                      03357500
 /* VALUE LOADED IS A STRUCTURE NODE, SO SET IT HERE.   */                      03357500
         IF (REG(OP) >= FR0) & (OPMODE(OPTYPE)=4) THEN                          03357500
            DOUBLE_TYPE(REG(OP)) = OPTYPE;                                      03357500
 /* @SINGLE FORCES A DOUBLE PRECISION VALUE TO SINGLE   */                      03357500
         IF AT_SINGLE THEN DOUBLE_TYPE(REG(OP)) = 0;                            03357500
 /*-----------------------------------------------------*/                      03357500
         FORM(OP) = VAC;                                                        03358000
         R_TYPE(REG(OP)) = OPTYPE;                                              03358500
         TYPE(OP) = OPTYPE;                                                     03359000
         IF TO_BE_INCORPORATED THEN                                             03359500
            CALL INCORPORATE(OP);                                               03360000
         TO_BE_MODIFIED = FALSE;                                                03360500
         TO_BE_INCORPORATED = TRUE;                                             03361000
         IF USAGE(R) < 2 THEN USAGE(R) = USAGE(R) + 2;  /* SAFETY VALVE */      03361500
         OPTYPE, ACCLASS, SHIFTCT = 0;                                          03362500
         CALL CHECK_LINKREG(R);                                                 03363000
         RETURN R;                                                              03363500
      END FORCE_ACCUMULATOR;                                                    03364000
                                                                                03364500
 /* ROUTINE TO FORCE STACK ENTRY TO REQUIRED TYPE */                            03365000
FORCE_BY_MODE:                                                                  03365500
      PROCEDURE(OP, MODE, RTYPE);                                               03366000
         DECLARE (OP, MODE, RTYPE, TEMPR, MODEX) BIT(16);                       03366500
         DECLARE FREG(1) BIT(16) INITIAL(5, 8);                                 03367000
         DECLARE HORI(1) CHARACTER INITIAL('H','I'),                            03368000
            EORD(1) CHARACTER INITIAL('E','D');                                 03368500
         IF CVTTYPE(MODE) = CVTTYPE(TYPE(OP)) THEN                              03369500
            CALL FORCE_ACCUMULATOR(OP, MODE, RTYPE);                            03370000
         ELSE IF OPMODE(TYPE(OP)) = 1 & DATATYPE(MODE) = SCALAR THEN DO;        03370500
            TEMPR = TARGET_REGISTER;                                            03371000
            TARGET_REGISTER = -1;                                               03371500
            CALL FORCE_ACCUMULATOR(OP);                                         03372000
            TARGET_REGISTER = TEMPR;                                            03372500
            TEMPR = FINDAC(RCLASS(MODE));                                       03373000
            IF MODE = DSCALAR THEN                                              03373500
               CALL EMITRR(MAKE_INST(EXOR, SCALAR, RR), TEMPR+1, TEMPR+1);      03374000
            CALL EMITRR(CVFL, TEMPR, REG(OP));                                  03374500
            CALL DROP_REG(OP);                                                  03375000
            CALL SET_RESULT_REG(OP, MODE, TEMPR);                               03375500
         END;                                                                   03376000
         ELSE DO;                                                               03376500
            MODEX = DATATYPE(MODE) ^= SCALAR;                                   03377000
            TEMPR = TARGET_REGISTER;                                            03377500
            TARGET_REGISTER = FREG(MODEX);                                      03378000
            CALL FORCE_ACCUMULATOR(OP);                                         03379000
            CALL DROP_REG(OP);                                                  03379500
            CALL UNRECOGNIZABLE(TARGET_REGISTER);                               03380000
            TARGET_REGISTER = TEMPR;                                            03380500
            DO CASE MODEX;                                                      03381500
               CALL GENLIBCALL(HORI((TYPE(OP)&8)^=0)||'TO'||EORD((MODE&8)^=0)); 03382000
               CALL GENLIBCALL(EORD((TYPE(OP)&8)^=0)||'TO'||HORI((MODE&8)^=0)); 03382500
            END;                                                                03383500
            CALL SET_RESULT_REG(OP, MODE);                                      03384500
            IF TARGET_REGISTER >= 0 THEN                                        03385500
               CALL FORCE_ACCUMULATOR(OP, MODE, RTYPE);                         03386000
         END;                                                                   03386500
         RTYPE = 0;                                                             03387000
         RETURN REG(OP);                                                        03387500
      END FORCE_BY_MODE;                                                        03388000
                                                                                03388500
 /* ROUTINE TO FORCE ARRAY SIZES INTO A REGISTER  */                            03389000
FORCE_ARRAY_SIZE:                                                               03389500
      PROCEDURE(R, VALUE) BIT(16);                                              03390000
         DECLARE (R, PTR, TR) BIT(16), VALUE FIXED;                             03390500
         IF DECLMODE THEN CALL RESUME_LOCCTR(NARGINDEX);                        03391000
         IF R < 0 THEN DO;                                                      03391500
            R = FINDAC(INDEX_REG);                                              03392000
            USAGE(R) = 0;                                                       03392500
         END;                                                                   03393000
         ELSE CALL CHECKPOINT_REG(R);                                           03393500
         IF VALUE < 0 THEN DO;                                                  03394000
            PTR = SET_ARRAY_SIZE(-VALUE);                                       03394500
            CALL CHECK_ADDR_NEST(R, PTR);                                       03395000
            CALL EMITOP(L, R, PTR);                                             03395500
            FORM(PTR) = VAC;                                                    03396000
            LOC2(PTR) = -1;                                                      3396100
            TYPE(PTR) = INTEGER;                                                03396500
            REG(PTR) = R;                                                       03397000
            USAGE(R) = 2;                                                       03397500
         END;                                                                   03398000
         ELSE DO;                                                               03398500
            PTR = GET_INTEGER_LITERAL(VALUE);                                   03399000
            TR = TARGET_REGISTER;                                               03399500
            TARGET_REGISTER = R;                                                03400000
            CALL FORCE_ACCUMULATOR(PTR);                                        03400500
            TARGET_REGISTER = TR;                                               03401000
         END;                                                                   03401500
         RETURN PTR;                                                            03402000
      END FORCE_ARRAY_SIZE;                                                     03402500
                                                                                03403000
 /***************************************************************************/
 /* ROUTINE TO STORE INTO INDIRECT STACK ENTRY AND UPDATE REGISTER USAGES   */  03403500
 /***************************************************************************/
 /*                                                                /*CR13616*/
 /* BY_NAME = TRUE (1)                                             /*CR13616*/
 /* ::= THE DESTINATION VARIABLE IN A NAME ASSIGNMENT, AUTOMATIC   /*CR13616*/
 /*      NAME INITIALIZATION, OR %NAMEADD/%NAMECOPY MACRO.         /*CR13616*/
 /*                                                                /*CR13616*/
 /***************************************************************************/
GEN_STORE:                                                                      03404000
      PROCEDURE(ROP, OP, FLAG, BY_NAME);                                        03404500
         DECLARE (ROP, OP, R) BIT(16),                                          03405000
            (FLAG, BY_NAME, ASSIGNED, INDEXED) BIT(1);                          03405500
 /*-- DR103659 -- DANNY STRAUSS----------------------------------*/             02841700
 /*-- IF IT IS A REMOTE AGGREGATE, NOT YET LOADED (SYM), WITH NO */             02841670
 /*-- INDEX LOADED, THEN WE HAVE BS123 ERROR CASE 2, WHICH IS    */             02841640
 /*-- REFERENCING THE 1ST NODE OF REMOTE SINGLE-COPY STRUCTURE.  */             02841640
         IF (FORM(OP)=SYM) THEN                                                 02841670
            IF (SYT_BASE(LOC(OP))=REMOTE_BASE | NR_DEREF(OP)) & /* CR12432 */
            (INX(OP)=0) THEN DO;                                                02841670
 /*-- SAVE AND RESTORE CURRENT TARGET REGISTER ALREADY ALLOCATED.*/             02841640
            TEMP2 = TARGET_REGISTER;                                            02841670
            TARGET_REGISTER = -1;                                               02841670
            CALL SUBSCRIPT_RANGE_CHECK(OP,1); /* FORCE LHI RX,0 */              02841670
            TARGET_REGISTER = TEMP2;                                            02841670
         END;                                                                   02841670
 /*--------------------------------------------------------------*/             02841700
         CALL UPDATE_ASSIGN_CHECK(OP);                                          03406000
         ASSIGNED = FALSE;                                                      03406500
         INDEXED = INX(OP) ^= 0;                                                03407000
         IF DUPLICATE_OPERANDS(OP, ROP) THEN DO;                                03407500
            IF CONST(ROP) = 0 THEN DO;                                          03408000
               CALL DROP_INX(OP);                                               03408500
               ASSIGNED = 3;                                                    03409000
            END;                                                                03409500
            ELSE IF OPMODE(TYPE(OP)) = 1 THEN                                   03410000
               ASSIGNED = GENSI(MSTH, OP, CONST(ROP)) + 2;                      03410500
            ELSE IF TYPE(OP) = DINTEGER THEN DO;                                03411000
               R = GET_INTEGER_LITERAL(CONST(ROP));                             03411500
               CALL FORCE_ACCUMULATOR(R, TYPE(OP));                             03412000
               CALL GUARANTEE_ADDRESSABLE(OP, MAKE_INST(SUM, TYPE(OP), RS));    03412500
               CALL ARITH_BY_MODE(SUM, R, OP, TYPE(OP), RS);                    03413000
               CALL DROP_VAC(R);                                                03413500
               ASSIGNED = 3;                                                    03414000
            END;                                                                03414500
         END;                                                                   03415000
         ELSE IF FORM(ROP) = LIT THEN                                           03415500
            IF OPMODE(TYPE(OP)) = 1 THEN                                        03416000
            IF VAL(ROP) = 0 THEN                                                03416500
            ASSIGNED = GENSI(ZH, OP);                                           03417000
         ELSE IF VAL(ROP) = -1 THEN                                             03417500
            ASSIGNED = GENSI(SHW, OP);                                          03418000
         IF ASSIGNED THEN                                                       03418500
            CALL ASSIGN_CLEAR(OP, INDEXED, ASSIGNED, ROP);                      03419000
         ELSE DO;                                                               03419500
            IF FORM(ROP) ^= VAC THEN CALL FORCE_ACCUMULATOR(ROP, TYPE(OP));     03420000
            R = REG(ROP);                                                       03420500
        CALL GUARANTEE_ADDRESSABLE(OP, MAKE_INST(STORE, TYPE(OP), RX), BY_NAME);03421000
            CALL EMIT_BY_MODE(STORE, R, OP, TYPE(OP));                          03421500
            IF KNOWN_SYM(OP) & CLASS ^= 8 THEN DO;                              03422000
               CALL NEW_USAGE(OP, INX(OP) > 0, BY_NAME);                        03422500
               R_TYPE(R) = TYPE(OP) | R_TYPE(R) & 8;                            03423500
               IF COPT(ROP) = 0 THEN                                             3423600
                  IF SAFE_INX(OP) THEN DO;                                       3424000
           IF ^USAGE(R) | NEXT_USE(ROP)=0 | NEXT_USE(OP)<=NEXT_USE(ROP) THEN DO; 3424200
                     IF BY_NAME THEN                                             3424400
                     CALL SET_USAGE(R, APOINTER, LOC(OP), INX_CON(OP), INX(OP)); 3424600
                     ELSE CALL SET_USAGE(R, SYM, LOC(OP), INX_CON(OP), INX(OP)); 3424800
                     IF NEXT_USE(OP) = 0 THEN IF INX_MUL(OP) > 1 THEN           03424810
                        NEXT_USE(OP) = INX_MUL(OP);                             03424820
                     CALL SET_REG_NEXT_USE(R, OP);                               3425000
                     NEXT_USE(ROP) = NEXT_USE(OP);                               3425200
                  END;                                                           3425400
               END;                                                              3425600
               ELSE CALL UNRECOGNIZABLE(R);                                      3425800
            END;                                                                03428000
            ELSE IF ^BY_NAME THEN                                               03428500
               CALL CLEAR_NAME_SAFE(OP); /* DR103787 */                         03429000
            CALL DROP_INX(OP);                                                  03429500
            IF ^FLAG THEN CALL DROP_REG(ROP);                                    3430000
         END;                                                                   03430500
         BY_NAME = FALSE;                                                       03431000
      END GEN_STORE;                                                            03431500
                                                                                03432000
 /* ROUTINE TO DETERMINATE IF IT IS ADVISABLE TO COMMUTE OPERANDS */            03432500
SHOULD_COMMUTE:                                                                 03433000
      PROCEDURE(OPCODE);                                                        03433500
         DECLARE (OPCODE, OK) BIT(16);                                          03434000
      IF FORM(LEFTOP) = VAC THEN RETURN COPT(LEFTOP) ^= 0 & DESTRUCTIVE(OPCODE); 3434500
      IF FORM(RIGHTOP) = VAC THEN RETURN COPT(RIGHTOP)=0 | ^DESTRUCTIVE(OPCODE); 3435000
         IF OPMODE(TYPE(RIGHTOP))<OPMODE(TYPE(LEFTOP)) THEN RETURN TRUE;        03435500
         IF SEARCH_REGS(LEFTOP)>=0 THEN RETURN FALSE;                           03436000
         IF SEARCH_REGS(RIGHTOP)>=0 THEN RETURN TRUE;                           03436500
         IF ARITH_OP(OPCODE) = ARITH_OP(XEXP) THEN DO;                          03437000
            IF POWER_OF_TWO(LEFTOP) THEN RETURN TRUE;                           03437500
            IF POWER_OF_TWO(RIGHTOP) THEN RETURN FALSE;                         03438000
         END;                                                                   03438500
         IF AVAILABLE_FROM_STORAGE(RIGHTOP, OPCODE) THEN RETURN FALSE;          03439000
         OK = AVAILABLE_FROM_STORAGE(LEFTOP, OPCODE);                           03439500
         IF OK THEN RETURN TRUE;                                                03440000
         IF OK = 2 THEN IF OPCODE = XADD THEN RETURN TRUE;                      03440500
         RETURN FALSE;                                                          03441000
      END SHOULD_COMMUTE;                                                       03441500
                                                                                03442000
 /* ROUTINE TO COMMUTE LEFTOP AND RIGHTOP  */                                   03442500
COMMUTEM:                                                                       03443000
      PROCEDURE;                                                                03443500
         DECLARE TEMP BIT(16);                                                  03444000
         TEMP = LEFTOP;                                                         03444500
         LEFTOP = RIGHTOP;                                                      03445000
         RIGHTOP = TEMP;                                                        03445500
      END COMMUTEM;                                                             03446000
                                                                                03446500
 /* ROUTINE TO EVALUATE UNARY OPERATIONS  */                                    03447000
UNARYOP:                                                                        03447500
      PROCEDURE(OPCODE);                                                        03448000
         DECLARE OPCODE BIT(16);                                                03448500
         TO_BE_MODIFIED = TRUE;                                                 03449000
         CALL FORCE_ACCUMULATOR(LEFTOP);                                        03449500
         IF OPCODE = XNOT THEN                                                  03450000
            CALL BIT_MASK(XNOT, LEFTOP, SIZE(LEFTOP));                          03450500
         ELSE                                                                   03451000
            CALL ARITH_BY_MODE(OPCODE, LEFTOP, LEFTOP, OPTYPE);                 03451500
      END UNARYOP;                                                              03452000
                                                                                03452500
 /* ROUTINE TO EVALUATE BINARY EXPRESSION ELEMENTS  */                          03453000
EXPRESSION:                                                                     03453500
      PROCEDURE(OPCODE);                                                        03454000
         DECLARE (OPCODE, TR) BIT(16),                                          03454500
            (COMPARISON, MULTIPLICATION) BIT(1);                                 3455000
         IF COMMUTATIVE(OPCODE) THEN                                            03455500
            IF SHOULD_COMMUTE(OPCODE) THEN DO;                                  03456000
            CALL COMMUTEM;                                                      03456500
            IF OPCODE = XADD THEN DO;                                           03457000
               CONST(LEFTOP) = CONST(RIGHTOP);  CONST(RIGHTOP) = 0;             03457500
               END;                                                             03458000
         END;                                                                   03458500
         IF NEW_INSTRUCTIONS THEN IF OPMODE(OPTYPE) = 4 THEN                    03458600
            IF ARITH_OP(OPCODE) = ARITH_OP(COMPARE) THEN                         3458700
            OPCODE = MINUS;                                                      3458800
         TO_BE_INCORPORATED = ^ADDITIVE(OPCODE);                                03459000
         TO_BE_MODIFIED = DESTRUCTIVE(OPCODE);                                  03459500
 /?P     /* CR11114 -- BFS/PASS INTERFACE */
         COMPARISON = CVTTYPE(OPTYPE) = 0 & ARITH_OP(OPCODE) = ARITH_OP(COMPARE) 3460000
 ?/
 /?B     /* CR11114 -- BFS/PASS INTERFACE */
         COMPARISON = DATATYPE(OPTYPE) = SCALAR & REVERSE(OPCODE) ^= 0
 ?/
            & ^SELF_ALIGNING;                                                   03460500
         CALL FORCE_ACCUMULATOR(LEFTOP, OPTYPE);                                03461000
      IF ARITH_OP(OPCODE)=ARITH_OP(XEXP) & POWER_OF_TWO(RIGHTOP)&INX_SHIFT(0)<=203461500
            THEN DO WHILE INX_SHIFT(0) > 0;                                     03462000
            INX_SHIFT(0) = INX_SHIFT(0) - 1;                                    03462500
            CALL ARITH_BY_MODE(SUM, LEFTOP, LEFTOP, OPTYPE);                    03464000
         END;                                                                   03464500
         ELSE DO;                                                               03465000
        MULTIPLICATION = ARITH_OP(OPCODE) = ARITH_OP(XEXP) & OPMODE(OPTYPE) ^= 4 3465500
               & ^REG(LEFTOP);                                                  03466000
            IF MULTIPLICATION THEN                                               3466500
               CALL CHECKPOINT_REG(REG(LEFTOP)+1);                              03467500
            NOT_THIS_REGISTER = REG(LEFTOP);                                     3469100
            IF OPMODE(TYPE(RIGHTOP)) = OPMODE(OPTYPE) THEN DO;                   3469500
          IF ^COMPARISON THEN IF SEARCH_REGS(RIGHTOP)>=0 THEN GO TO FORCE_RIGHT;03470000
               IF AVAILABLE_FROM_STORAGE(RIGHTOP, OPCODE) THEN                  03470500
                  CALL ARITH_BY_MODE(OPCODE, LEFTOP, RIGHTOP, OPTYPE);          03471000
               ELSE DO;                                                         03471500
FORCE_RIGHT:                                                                    03472000
                  TR = TARGET_REGISTER;                                         03472500
                  TARGET_REGISTER = -1;                                         03473000
                  CALL FORCE_ACCUMULATOR(RIGHTOP, OPTYPE);                      03473500
                  TARGET_REGISTER = TR;                                         03474000
                  IF COMPARISON THEN                                            03474500
                     CALL CHECKPOINT_REG(REG(RIGHTOP));                         03475000
                  CALL ARITH_BY_MODE(OPCODE, LEFTOP, RIGHTOP, OPTYPE);          03475500
               END;                                                             03476000
            END;                                                                03476500
            ELSE GO TO FORCE_RIGHT;                                             03477000
            NOT_THIS_REGISTER = -1;                                              3477050
            IF MULTIPLICATION THEN CALL UNRECOGNIZABLE(REG(LEFTOP)+1);           3478000
         END;                                                                   03478500
         CALL RETURN_STACK_ENTRY(RIGHTOP);                                      03479000
         IF PACKTYPE(OPTYPE) = BITS THEN                                        03479500
            SIZE(LEFTOP) = MAX(SIZE(LEFTOP), SIZE(RIGHTOP));                    03480000
      END EXPRESSION;                                                           03480500
                                                                                03481000
 /* ROUTINE TO PERFORM EXPRESSION ON SPECIFIED OPERANDS */                      03481500
DO_EXPRESSION:                                                                  03482000
      PROCEDURE(OPC, OP1, OP2) BIT(16);                                         03482500
         DECLARE (OPC, OP1, OP2, SLF, SRT) BIT(16);                             03483000
         SLF = LEFTOP;  SRT = RIGHTOP;                                          03483500
            LEFTOP = OP1;                                                       03484000
         RIGHTOP = OP2;                                                         03484500
         IF DATATYPE(OPTYPE) ^= INTEGER THEN                                    03485000
            CALL EXPRESSION(OPC);                                               03485500
         ELSE IF OPC = SUM THEN DO;                                             03486000
            IF FORM(RIGHTOP) = LIT THEN DO;                                     03486500
               CONST(LEFTOP) = CONST(LEFTOP) + VAL(RIGHTOP);                    03487000
               CALL RETURN_STACK_ENTRY(RIGHTOP);                                03487500
            END;                                                                03488000
            ELSE DO;                                                            03488500
               CONST(LEFTOP) = CONST(LEFTOP) + CONST(RIGHTOP);                  03489000
               CONST(RIGHTOP) = 0;                                              03489500
               CALL EXPRESSION(SUM);                                            03490000
            END;                                                                03490500
         END;                                                                   03491000
         ELSE IF OPC = MINUS THEN DO;                                           03491500
            IF FORM(RIGHTOP) = LIT THEN DO;                                     03492000
               CONST(LEFTOP) = CONST(LEFTOP) - VAL(RIGHTOP);                    03492500
               CALL RETURN_STACK_ENTRY(RIGHTOP);                                03493000
            END;                                                                03493500
            ELSE DO;                                                            03494000
               CONST(LEFTOP) = CONST(LEFTOP) - CONST(RIGHTOP);                  03494500
               CONST(RIGHTOP) = 0;                                              03495000
               CALL EXPRESSION(MINUS);                                          03495500
            END;                                                                03496000
         END;                                                                   03496500
         ELSE CALL EXPRESSION(OPC);                                             03497000
         OP1 = LEFTOP;                                                          03497500
         LEFTOP = SLF;  RIGHTOP = SRT;                                          03498000
            RETURN OP1;                                                         03498500
      END DO_EXPRESSION;                                                        03499000
                                                                                03499500
INTEGER_DIVIDE:                                                                 03500000
      PROCEDURE;                                                                03500500
         CALL GET_OPERANDS;                                                     03501500
         IF DATATYPE(TYPE(RIGHTOP)) ^= INTEGER THEN                             03502000
            CALL FORCE_BY_MODE(RIGHTOP, OPTYPE);                                03502500
         TARGET_REGISTER = BESTAC(DOUBLE_ACC);                                  03503000
         TO_BE_MODIFIED = TRUE;                                                 03503500
         CALL FORCE_BY_MODE(LEFTOP, OPTYPE);                                    03503600
         CALL UNRECOGNIZABLE(REG(LEFTOP));                                      03503700
         CALL CHECKPOINT_REG(TARGET_REGISTER+1);                                03504000
         USAGE(TARGET_REGISTER+1) = 4;                                          03504500
         USAGE_LINE(TARGET_REGISTER+1) = 1;                                      3504600
         /* CLEAR LOWER REGISTER BEFORE SHIFTING */
         CALL EMITRR(XR,TARGET_REGISTER+1,TARGET_REGISTER+1); /*DR107722*/
         CALL EMITP(SRDA, TARGET_REGISTER, 0, SHCOUNT, 31);                     03505000
         TARGET_REGISTER = -1;                                                  03505500
         CALL EXPRESSION(XDIV);                                                 03507500
         IF OPTYPE = INTEGER THEN                                               03508000
            CALL EMITP(SLL, REG(LEFTOP), 0, SHCOUNT, 16);                       03508500
         USAGE(REG(LEFTOP)+1) = 0;                                              03509000
      END INTEGER_DIVIDE;                                                       03513000
                                                                                03513500
EXPONENTIAL:                                                                    03514000
      PROCEDURE(OPCODE);                                                        03514500
         DECLARE (OPCODE) BIT(16);                                              03515000
         DECLARE (R,WRK,I) BIT(16),                                             03515500
            EXP_RCLASS(TYP_SIZE) BIT(16)                                        03516000
            INITIAL(2,3,3,1,1,5,3,3,0,3,3,0,0,0,3,3,0,3,3);                     03516500
         IF OPCODE = XEXP THEN CALL GET_OPERANDS;                               03517000
         ELSE DO;                                                               03517500
            LEFTOP = GET_OPERAND(1);                                            03518000
            LITTYPE = INTEGER;                                                  03518500
            RIGHTOP = GET_OPERAND(2);                                           03519000
            OPTYPE = TYPE(LEFTOP);                                              03519500
            IF OPTYPE = INTEGER THEN OPTYPE = OPTYPE | TYPE(RIGHTOP)&8;         03520000
         END;                                                                   03520500
         IF OPCODE=XPEX THEN DO;                                                03521000
            I=VAL(RIGHTOP);                                                     03521500
            IF I>0 & I<17 THEN                                                  03522000
               IF I=1 THEN DO;                                                  03522500
               CALL RETURN_STACK_ENTRY(RIGHTOP);                                03523000
               RETURN;                                                          03523500
            END;                                                                03524000
            ELSE IF DATATYPE(OPTYPE)=SCALAR THEN DO;                            03524500
               TO_BE_MODIFIED=TRUE;                                             03525000
               R=FORCE_ACCUMULATOR(LEFTOP,OPTYPE,EXP_RCLASS(OPTYPE));           03525500
               IF OPTYPE=SCALAR THEN                                            03526000
                  IF ^R THEN CALL CHECKPOINT_REG(R+1);                          03526500
               OPCODE=MAKE_INST(XEXP,OPTYPE,RR);                                03527000
               DO WHILE ^I;                                                     03527500
                  CALL EMITRR(OPCODE,R,R);                                      03528000
                  I=SHR(I,1);                                                   03528500
               END;                                                             03529000
               CALL UNRECOGNIZABLE(R);                                          03529500
               IF I>1 THEN DO;                                                  03530000
                  NOT_THIS_REGISTER = R | 1;                                    03530500
                  WRK=FINDAC(EXP_RCLASS(OPTYPE));                               03530510
 /************ DR58321 START ***************************/
                  IF WRK = R THEN DO;                                           03530512
 /*    OUTPUT = '****CHECK REGISTER PRESSURE STATEMENT # ' */                   03530514
                     CALL ERRORS(CLASS_ZP,1,''||LINE#) ; /* ISSUE ZP1 */        03530516
                  END;                                                          03530518
 /************ DR58321 FINISH **************************/
                  NOT_THIS_REGISTER = -1;                                       03530520
                  CALL MOVEREG(R,WRK,OPTYPE,1);                                 03531000
                  CALL SET_REG_NEXT_USE(R, LEFTOP);                              3531100
                  DO WHILE I>1;                                                 03531500
                     CALL EMITRR(OPCODE,R,R);                                   03532000
                     I=SHR(I,1);                                                03532500
                     IF I THEN CALL EMITRR(OPCODE,WRK,R);                       03533000
                  END;                                                          03533500
                  R=WRK;                                                        03534000
                  R_TYPE(R) = OPTYPE;                                           03534500
               END;                                                             03535000
               REG(LEFTOP)=R;                                                   03535500
               CALL RETURN_STACK_ENTRY(RIGHTOP);                                03536000
               RETURN;                                                          03536500
            END;                                                                03537000
         END;                                                                   03537500
         IF DATATYPE(TYPE(RIGHTOP))=SCALAR THEN DO;                             03538000
            TARGET_REGISTER = FR2;                                              03538500
            CALL FORCE_ACCUMULATOR(RIGHTOP, OPTYPE);                            03539000
         END;                                                                   03539500
         ELSE DO;                                                               03540000
            TARGET_REGISTER = FIXARG2;                                          03540500
            CALL FORCE_ACCUMULATOR(RIGHTOP);                                    03541000
         END;                                                                   03541500
         CALL STACK_TARGET(RIGHTOP);                                             3542000
         IF DATATYPE(TYPE(LEFTOP)) = SCALAR THEN TARGET_REGISTER = FR0;         03542500
         ELSE TARGET_REGISTER = FIXARG1;                                        03543000
         CALL FORCE_ACCUMULATOR(LEFTOP, OPTYPE);                                03543500
         CALL STACK_TARGET(LEFTOP);                                              3544000
         CALL DROP_PARM_STACK;                                                   3544100
         CALL GENLIBCALL(TYPES(SELECTYPE(TYPE(LEFTOP)))||'PWR'||                03544500
            TYPES(SELECTYPE(TYPE(RIGHTOP))));                                   03545000
         LEFTOP = GET_STACK_ENTRY;                                               3545100
         CALL SET_RESULT_REG(LEFTOP, OPTYPE);                                   03545500
      END EXPONENTIAL;                                                          03546500
                                                                                03547000
                                                                                03547500
 /* ROUTINE TO CLASSIFY OPCODES AS UNARY OR BINARY AND PROPERLY EVALUATE */     03548000
EVALUATE:                                                                       03548500
      PROCEDURE(OPCODE);                                                        03549000
         DECLARE OPCODE BIT(16);                                                03549500
         CALL GET_OPERANDS;                                                     03550000
         IF OPCODE=21 THEN    /*XOR*/             /*CR13211*/
          IF SIZE(LEFTOP) ^= SIZE(RIGHTOP) THEN   /*CR13211*/
             CALL ERRORS(CLASS_YE,100);           /*CR13211*/
         IF UNARY(OPCODE) THEN CALL UNARYOP(OPCODE);                            03550500
         ELSE CALL EXPRESSION(OPCODE);                                          03551000
      END EVALUATE;                                                             03551500
                                                                                03552000
 /* ROUTINE TO FORMULATE THE NAME OF A VECTOR-MATRIX ROUTINE  */                03552500
FORM_VMNAME:                                                                    03553000
      PROCEDURE(OPCODE, PREC, XSIZE, PART) CHARACTER;                           03553500
         DECLARE (OPCODE, XSIZE) BIT(16), (PREC, PART) BIT(8);                  03554000
         DECLARE VMOP(VMOPSIZE) CHARACTER INITIAL                               03554500
         ('VV8', 'VV1', 'VV2', 'VV3', 'VV7', 'VV4', 'VV5', 'VO6', 'MM6', 'MM11',03555000
            'MM14', 'VX6', 'MV6', 'VM6', 'VV6', 'VV9', 'VV10', 'MM12', 'MM13',  03555500
         'MM15', 'VV0', 'MM1', 'MMR', 'MMW', 'MM0', 'MM17', 'VR1', 'VR0', 'MR1',03556000
            'MR0'),                                                             03556500
            VMPREC(3) CHARACTER INITIAL ('S', 'D', 'T', 'W'),                   03557000
            VMPART(1) CHARACTER INITIAL ('', 'P'), VMSIZE CHARACTER;            03557500
         IF (SIZE3(OPCODE) & XSIZE=3) THEN VMSIZE = '3'; ELSE VMSIZE = 'N';     03558000
         RETURN VMOP(OPCODE)||VMPREC(PREC)||VMSIZE||VMPART(PART);               03558500
      END FORM_VMNAME;                                                          03559000
                                                                                03559500
 /* ROUTINE TO EMIT CALLS TO THE VECTOR-MATRIX PACKAGE  */                      03560000
VMCALL:                                                                         03560500
      PROCEDURE(OPCODE, OPTYPE, OP0, OP1, OP2, PART);                           03561000
         DECLARE (OPCODE, OP0, OP1, OP2, TMP) BIT(16), OPTYPE BIT(8);           03561500
         DECLARE (PART, VSIZE) FIXED;                                           03562500
   /*------------------------- #DREG --------------------------------*/
         D_RTL_SETUP = TRUE;
   /*----------------------------------------------------------------*/
         VSIZE = TEMPSPACE;                                                     03563000
         REMOTE_ADDRS = CHECK_REMOTE(OP0);                                      03563500
         REMOTE_ADDRS = CHECK_REMOTE(OP1) | REMOTE_ADDRS;                       03564000
   /*-------------------- DANNY #DPARM --- #D PASS-BY-REF TO RTL ----*/         67160010
   /* FORCE YCON TO ZCON CONVERT OF #D DATA BEING PASSED.            */         67170099
         IF DATA_REMOTE &                                                       67180099
            ( ((OP0>0) & (CSECT_TYPE(LOC(OP0),OP0)=LOCAL#D)) |                  67190099
              ((OP1>0) & (CSECT_TYPE(LOC(OP1),OP1)=LOCAL#D)) )                  67200099
            THEN REMOTE_ADDRS = TRUE;                                           67210099
   /*----------------------------------------------------------------*/         67220018
         INTCALL = INTRINSIC(FORM_VMNAME(OPCODE,OPTYPE,3*SIZE3(OPCODE),PART^=0))03564500
            & ^REMOTE_ADDRS;                                                    03565000
         IF OP0 > 0 THEN INTCALL = INTCALL + 2;                                 03565500
         IF OP2 > 0 THEN                                                        03570000
            CALL STACK_REG_PARM(FORCE_ADDRESS(SYSARG2(INTCALL), OP2, 1));       03570500
         IF OP1 > 0 THEN                                                        03571000
            CALL STACK_REG_PARM(FORCE_ADDRESS(SYSARG1(INTCALL), OP1, 1));       03571500
         IF PART ^= 0 THEN DO;                                                  03572500
            IF PART > 0 THEN DO;                                                03573000
               IF OPCODE = XMASN THEN                                           03573500
                  CALL FORCE_NUM(FIXARG3, PART, 8);                             03574000
               ELSE IF OPCODE = XXASN THEN DO;                                  03574500
                  CALL FORCE_NUM(FIXARG2, SHR(PART, 16));                       03575000
                  CALL STACK_REG_PARM(FIXARG2);                                 03575500
                  CALL FORCE_NUM(FIXARG3, PART & "FFFF");                       03576000
               END;                                                             03576500
               ELSE CALL FORCE_NUM(FIXARG3, PART);                              03577000
            END;                                                                03577500
            ELSE IF PART < 0 THEN                                               03578000
               CALL FORCE_NUM(FIXARG3, 0);                                      03578500
            CALL STACK_REG_PARM(FIXARG3);                                       03579000
         END;                                                                   03579500
         IF OP0 > 0 THEN                                                        03580000
            CALL FORCE_ADDRESS(SYSARG0(INTCALL), OP0);                          03580500
         CALL DROP_PARM_STACK;                                                  03581000
         IF REMOTE_ADDRS THEN OPCODE = VMREMOTEOP(OPCODE);                      03581500
         DO CASE CTRSET(OPCODE);                                                03582000
            DO;  /* 1 SIZE FOR ALL */                                           03582500
               IF ^(TEMPSPACE=3 & SIZE3(OPCODE)) THEN                           03583000
                  CALL FORCE_NUM(FIXARG1, TEMPSPACE);                           03583500
            END;                                                                03584500
            DO;  /* 1 SIZE FOR SQUARE MATRIX  */                                03585000
               IF ^(ROW(0)=3 & SIZE3(OPCODE)) THEN                              03585500
                  CALL FORCE_NUM(FIXARG1, ROW(0));                              03586000
               ELSE VSIZE = 3;                                                  03586500
            END;                                                                03589500
            DO;  /* 2 POINTERS FROM RESULT,OP1, OR OP2  */                      03590000
               DO CASE CASE2SET(OPCODE);                                        03590500
                  TMP = OP0;                                                    03591000
                  TMP = OP1;                                                    03591500
                  TMP = OP2;                                                    03592000
               END;                                                             03592500
               IF ^(ROW(TMP)=3 & COLUMN(TMP)=3 & SIZE3(OPCODE)) THEN DO;        03593000
                  CALL FORCE_NUM(FIXARG1, ROW(TMP));                            03593500
                  CALL FORCE_NUM(FIXARG2, COLUMN(TMP));                         03594000
                  VSIZE = 0;                                                    03594500
               END;                                                             03595500
               ELSE VSIZE = 3;                                                  03596000
            END;                                                                03600500
            DO;  /* 3 POINTERS FROM RESULT, OP1  */                             03601000
              IF ^(ROW(OP1)=3 & ROW(OP2)=3 & COLUMN(OP2)=3 & SIZE3(OPCODE)) THEN03601500
                  DO;                                                           03602000
                  CALL FORCE_NUM(FIXARG1, ROW(OP1));                            03602500
                  CALL FORCE_NUM(FIXARG2, ROW(OP2));                            03603000
                  CALL FORCE_NUM(FIXARG3, COLUMN(OP2));                         03603500
               END;                                                             03604000
               ELSE VSIZE = 3;                                                  03604500
            END;                                                                03606500
         END;  /* CASE CTRSET  */                                               03607000
         CALL GENLIBCALL(FORM_VMNAME(OPCODE, OPTYPE, VSIZE, PART^=0));          03607500
         LASTRESULT, REMOTE_ADDRS = 0;                                          03608500
      END VMCALL;                                                               03609000
                                                                                03609500
 /* ROUTINE TO DO VECTOR-MATRIX ASSIGNMENT CALLS  */                            03610000
VECMAT_ASSIGN:                                                                  03610500
      PROCEDURE(OP0, OP1);                                                      03611000
         DECLARE (OP0, OP1, PREC_SPEC, OPCODE) BIT(16);                         03611500
         IF DATATYPE(TYPE(OP0))=MATRIX & DEL(OP0)^=0 |                          03612000
            DATATYPE(TYPE(OP1))=MATRIX & DEL(OP1)^=0 THEN OPCODE = XMASN;       03612500
         ELSE OPCODE = XXASN;                                                   03613000
         PREC_SPEC = (TYPE(OP0)&8) ^= 0;                                        03613500
         IF (TYPE(OP0)&8) ^= (TYPE(OP1)&8) THEN PREC_SPEC = PREC_SPEC + 2;      03614000
         CALL VMCALL(OPCODE, PREC_SPEC, OP0, OP1, 0, SHL(DEL(OP1),16)+DEL(OP0));03614500
      END VECMAT_ASSIGN;                                                        03615000
                                                                                03615500
 /* ROUTINE TO SET VECMAT TEMPORARY AND SET SIZES */                            03616000
GET_VM_TEMP:                                                                    03616500
      PROCEDURE(N, OPTYP) BIT(16);                                              03617000
         DECLARE (N, OPTYP, PTR) BIT(16);                                       03617500
         IF N = 0 THEN OPTYP = OPTYPE;                                          03618000
         PTR = GETFREESPACE(OPTYP, TEMPSPACE);                                  03618500
         ROW(PTR) = ROW(N);                                                     03619000
         COLUMN(PTR) = COLUMN(N);                                               03619500
         N = 0;                                                                 03620000
         RETURN PTR;                                                            03620500
      END GET_VM_TEMP;                                                          03621000
                                                                                03621500
 /* ROUTINE TO GET TEMPORARY FOR MATRIX INVERSE ROUTINE */                      03622000
GETINVTEMP:                                                                     03622500
      PROCEDURE(OPTYP, SIZ);                                                    03623000
         DECLARE (OPTYP, SIZ) BIT(16);                                          03623500
         IF (OPTYP&8) ^= 0 THEN SIZ = SIZ + 1;                                  03624000
         RETURN GETFREESPACE(SCALAR, SIZ+1);                                    03624500
      END GETINVTEMP;                                                           03625000
                                                                                03625500
 /* ROUTINE TO GATHER PARTITIONED VECMAT OPERANDS AND DO PRECISION SWITCHING*/  03626000
VECMAT_CONVERT:                                                                 03626500
      PROCEDURE(OP, PREC_SPEC);                                                 03627000
         DECLARE (OP, PREC_SPEC, OPTYPE, PTR) BIT(16);                          03627500
         TEMPSPACE = ROW(OP) * COLUMN(OP);                                      03628000
         IF PREC_SPEC > 0 THEN OPTYPE = PREC_SPEC&8 | TYPE(OP)&"F7";            03628500
         ELSE OPTYPE = TYPE(OP);                                                03629000
         PTR = GET_VM_TEMP(OP, OPTYPE);                                         03629500
         CALL VECMAT_ASSIGN(PTR, OP);                                           03630000
         CALL DROPSAVE(OP);                                                     03630500
         CALL RETURN_STACK_ENTRY(OP);                                           03631000
         PREC_SPEC = 0;                                                         03632000
         RETURN PTR;                                                            03632500
      END VECMAT_CONVERT;                                                       03633000
                                                                                03633500
 /* ROUTINE TO SET UP FOR BINARY AND UNARY VECTOR-MATRIX OPERATIONS  */         03634000
ARG_ASSEMBLE:                                                                   03634500
      PROCEDURE;                                                                03635000
         DECLARE (LEFTMODE, RIGHTMODE) BIT(16);                                 03635500
         IF NUMOP = 2 THEN DO;  /* BINARY SETUP  */                             03636000
            LEFTOP = GET_OPERAND(1);                                            03636500
            RIGHTOP = GET_OPERAND(2);                                           03637000
            LEFTMODE = OPMODE(TYPE(LEFTOP));                                    03637500
            RIGHTMODE = OPMODE(TYPE(RIGHTOP));                                  03638000
            STMT_PREC=(TYPE(LEFTOP) & 8)|(TYPE(RIGHTOP) & 8);                   03638500
            IF ^VDLP_ACTIVE THEN DO;                                             3638600
               IF LEFTMODE ^= RIGHTMODE THEN DO;                                03639000
                  IF LEFTMODE > RIGHTMODE THEN                                  03639500
                     RIGHTOP = VECMAT_CONVERT(RIGHTOP, 8);                      03640000
                  ELSE LEFTOP = VECMAT_CONVERT(LEFTOP, 8);                      03640500
               END;                                                             03641000
               IF CHECK_REMOTE(RIGHTOP) | DEL(RIGHTOP) > 0 THEN                 03641500
                  RIGHTOP = VECMAT_CONVERT(RIGHTOP);                            03642000
   /*-------------------- DANNY #DPARM --- #D PASS-BY-REF TO RTL ----*/         68510010
   /* #D AGGREGATE DATA MUST BE COPIED TO THE STACK.                 */         68520099
               IF DATA_REMOTE & (CSECT_TYPE(LOC(RIGHTOP),RIGHTOP)=LOCAL#D)      68530099
                  THEN RIGHTOP = VECMAT_CONVERT(RIGHTOP);                       68540099
   /*----------------------------------------------------------------*/         68550018
               CALL DROPSAVE(RIGHTOP);                                          03642500
            END;                                                                 3642600
         END;                                                                   03643000
         ELSE DO;  /* UNARY SETUP  */                                           03643500
            LEFTOP = GET_OPERAND(1);                                            03644000
            RIGHTOP = 0;                                                        03644500
            STMT_PREC=(TYPE(LEFTOP) & 8);                                       03645000
         END;                                                                   03645500
         IF ^VDLP_ACTIVE THEN DO;                                                3645600
            IF CHECK_REMOTE(LEFTOP) | DEL(LEFTOP) > 0 THEN                      03646000
               LEFTOP = VECMAT_CONVERT(LEFTOP);                                 03646500
   /*-------------------- DANNY #DPARM --- #D PASS-BY-REF TO RTL ----*/         68670010
   /* #D AGGREGATE DATA MUST BE COPIED TO THE STACK.                 */         68680099
            IF DATA_REMOTE & (CSECT_TYPE(LOC(LEFTOP),LEFTOP)=LOCAL#D)           68690099
               THEN LEFTOP = VECMAT_CONVERT(LEFTOP);                            68700099
   /*----------------------------------------------------------------*/         68710018
            CALL DROPSAVE(LEFTOP);                                              03647000
         END;                                                                    3647100
         ROW(0) = ROW(LEFTOP);                                                  03647500
         COLUMN(0) = COLUMN(LEFTOP);                                            03648000
         OPTYPE = TYPE(LEFTOP) | STMT_PREC;                                      3648500
      END ARG_ASSEMBLE;                                                         03649000
                                                                                03649500
 /* ROUTINE TO SET UP MIXED VECTOR-MATRIX CALLS  */                             03650000
MIX_ASSEMBLE:                                                                   03650500
      PROCEDURE;                                                                03651000
         DECLARE (LEFTMODE, RIGHTMODE, RIGHTTYPE) BIT(16);                      03651500
         LEFTOP = GET_OPERAND(1);                                               03652000
         LITTYPE = TYPE(LEFTOP)&8 | SCALAR;                                     03652500
         RIGHTOP = GET_OPERAND(2);                                              03653000
         LEFTMODE = OPMODE(TYPE(LEFTOP));                                       03653500
         RIGHTMODE = OPMODE(TYPE(RIGHTOP));                                     03654000
         RIGHTTYPE = TYPE(RIGHTOP);                                             03654500
         STMT_PREC=(TYPE(LEFTOP) & 8)|(TYPE(RIGHTOP) & 8);                      03655000
         IF ^VDLP_ACTIVE THEN DO;                                                3655100
            IF LEFTMODE ^= RIGHTMODE THEN DO;                                   03655500
               IF LEFTMODE < RIGHTMODE THEN                                     03656000
                  LEFTOP = VECMAT_CONVERT(LEFTOP, 8);                           03656500
               ELSE RIGHTTYPE = RIGHTTYPE | 8;                                  03657000
            END;                                                                03657500
            IF CHECK_REMOTE(LEFTOP) | DEL(LEFTOP) > 0 THEN                      03658000
               LEFTOP = VECMAT_CONVERT(LEFTOP);                                 03658500
   /*-------------------- DANNY #DPARM --- #D PASS-BY-REF TO RTL ----*/         68980010
   /* #D AGGREGATE DATA MUST BE COPIED TO THE STACK.                 */         68990099
            IF DATA_REMOTE & (CSECT_TYPE(LOC(LEFTOP),LEFTOP)=LOCAL#D)           69000099
               THEN LEFTOP = VECMAT_CONVERT(LEFTOP);                            69010099
   /*----------------------------------------------------------------*/         69020018
            CALL DROPSAVE(LEFTOP);                                              03659000
            TARGET_REGISTER = FR0;                                              03659500
            CALL FORCE_ACCUMULATOR(RIGHTOP, RIGHTTYPE);                         03660000
            CALL STACK_TARGET(RIGHTOP);                                          3660500
            RIGHTOP =0;                                                         03661500
         END;                                                                    3661600
         OPTYPE = TYPE(LEFTOP) | STMT_PREC;                                      3662000
         ROW(0) = ROW(LEFTOP);                                                  03662500
         COLUMN(0) = COLUMN(LEFTOP);                                            03663000
      END MIX_ASSEMBLE;                                                         03663500
                                                                                03664000
 /* LOCAL ROUTINE TO SET UP CHAR DESCRIPTOR REGISTERS */                        03664500
SET_CHAR_DESC:                                                                  03665000
      PROCEDURE(OP, R1, R0);                                                    03665500
         DECLARE (OP, R1, R0) BIT(16);                                          03666000
         IF COLUMN(OP) > 0 THEN DO;                                             03667000
            TARGET_REGISTER = R1;                                               03667500
            CALL FORCE_ACCUMULATOR(COLUMN(OP),INTEGER);                         03668000
            CALL STACK_TARGET(COLUMN(OP));                                      03668500
         END;                                                                   03669000
         ELSE DO;                                                               03669500
            CALL FORCE_NUM(R1, 0);                                              03670000
            CALL STACK_REG_PARM(R1);                                            03670500
         END;                                                                   03671000
         IF DEL(OP) > 0 THEN DO;                                                03671500
            TARGET_REGISTER = R0;                                               03672000
            CALL FORCE_ACCUMULATOR(DEL(OP),INTEGER);                            03672500
            CALL STACK_TARGET(DEL(OP));                                         03673000
         END;                                                                   03673500
         ELSE DO;                                                               03674000
            CALL CHECKPOINT_REG(R0);                                            03674500
            CALL MOVEREG(R1, R0, INTEGER, 0);                                   03675000
            CALL STACK_REG_PARM(R0);                                            03675500
         END;                                                                   03676000
      END SET_CHAR_DESC;                                                        03676500
                                                                                03677000
 /* ROUTINE TO FORMULATE THE NAME OF A CHARACTER LIBRARY ROUTINE */             03677500
FORM_CHARNAME:                                                                  03678000
      PROCEDURE(OPCODE, PART, VAC) CHARACTER;                                   03678500
         DECLARE (OPCODE, PART) BIT(16), VAC BIT(1);                            03679000
        DECLARE CHAROP(12) CHARACTER INITIAL ('PR', 'AS', 'AT', 'TRIM', 'INDEX',03679500
            'LJST', 'RJST', 'IN', 'OUT', 'SLD', 'SST', 'PRC', 'ASR'),           03680000
            VTYPE(1) CHARACTER INITIAL('', 'V'),                                03680500
            CP(1) CHARACTER INITIAL('', 'P');                                   03681000
         RETURN 'C'||CP(SHR(PART,1)&1)||CHAROP(OPCODE)||CP(PART&1)              03681500
            || VTYPE(VAC);                                                      03682000
      END FORM_CHARNAME;                                                        03682500
                                                                                03683000
 /* ROUTINE TO GENERATE CALLS TO CHARACTER MANIPULATION ROUTINES */             03683500
CHAR_CALL:                                                                      03684000
      PROCEDURE(OPCODE, OP0, OP1, OP2, OP3, CHAR_ASNMNT);          /*DR111344*/ 03684500
         DECLARE (OPCODE,OP0,OP1,OP2,OP3) BIT(16), (VACOP, CPART) BIT(1);       03685000
         DECLARE CHAR_ASNMNT BIT(1) INITIAL(FALSE);                /*DR111344*/
   /*------------------------- #DREG --------------------------------*/
         D_RTL_SETUP = TRUE;
   /*----------------------------------------------------------------*/
         COLUMN(0), FORM(0) = 0;  /* TO MAKE COLUMN(0), FORM(0) TESTS FAIL */   03686000
         VACOP = FALSE;                                                         03686500
         REMOTE_ADDRS = CHECK_REMOTE(OP0);                                      03687000
         REMOTE_ADDRS = CHECK_REMOTE(OP1) | REMOTE_ADDRS;                       03687500
   /*-------------------- DANNY #DPARM --- #D PASS-BY-REF TO RTL ----*/         69620010
   /* FORCE YCON TO ZCON CONVERT OF #D DATA BEING PASSED.            */         69630099
         IF DATA_REMOTE &                                                       69640099
            ( ((OP0>0) & (CSECT_TYPE(LOC(OP0),OP0)=LOCAL#D)) |                  69650099
              ((OP1>0) & (CSECT_TYPE(LOC(OP1),OP1)=LOCAL#D)) )                  69660099
            THEN REMOTE_ADDRS = TRUE;                                           69670099
   /*----------------------------------------------------------------*/         69680018
         CPART = COLUMN(OP1) > 0;                                               03688000
         IF COLUMN(OP0) > 0 THEN CPART = CPART + 2;                             03688500
         INTCALL = INTRINSIC(FORM_CHARNAME(OPCODE, CPART,         /*DR111344*/  03689000
            (FORM(OP0)=WORK) & ^CHAR_ASNMNT) ) & ^REMOTE_ADDRS;   /*DR111344*/  03689500
         IF OP3 > 0 THEN DO;                                                    03690000
            TARGET_REGISTER = SYSARG2(INTCALL);                                 03690500
            CALL FORCE_ACCUMULATOR(OP3, FULLBIT);                               03691000
            TARGET_REGISTER = -1;                                               03691500
         END;                                                                   03692000
         ELSE IF OP0 > 0 THEN IF FORM(OP0) ^= VAC THEN INTCALL = INTCALL + 2;   03692500
         IF OP2 > 0 THEN                                                        03696000
            CALL STACK_REG_PARM(FORCE_ADDRESS(SYSARG2(INTCALL), OP2, 1));       03696500
         CALL STACK_REG_PARM(FORCE_ADDRESS(SYSARG1(INTCALL), OP1, 1));          03697000
         IF OP0 > 0 THEN IF FORM(OP0) ^= VAC THEN DO;                           03697500
            IF (FORM(OP0)=WORK) & ^CHAR_ASNMNT THEN               /*DR111344*/  03698000
               VACOP = TRUE;                                      /*DR111344*/
            CALL STACK_REG_PARM(FORCE_ADDRESS(SYSARG0(INTCALL), OP0, 1));       03698500
         END;                                                                   03699000
         IF COLUMN(OP1) > 0 THEN DO;                                            03702000
            CALL SET_CHAR_DESC(OP1, FIXARG1, FIXARG2);                          03703000
            IF COLUMN(OP0) > 0 THEN DO;                                         03703500
               IF OLD_LINKAGE & OP3 = 0 THEN                                    03704000
                  CALL SET_CHAR_DESC(OP0, SYSARG2, FIXARG3);                    03704500
               ELSE DO;                                                         03705000
                  IF DEL(OP0) > 0 THEN DO;                                      03705500
                     IF FORM(DEL(OP0)) = LIT & FORM(COLUMN(OP0)) = LIT THEN     03706000
                        CALL FORCE_NUM(FIXARG3,                                 03706500
                        SHL(VAL(COLUMN(OP0)),16)+VAL(DEL(OP0)), 8);             03707000
                     ELSE DO;                                                   03707500
                        TARGET_REGISTER = FIXARG3;                              03708000
                        CALL FORCE_ACCUMULATOR(DEL(OP0));                       03708500
                        CALL EMITP(SRL, FIXARG3, 0, SHCOUNT, 16);               03709000
                        CALL ARITH_BY_MODE(SUM, DEL(OP0), COLUMN(OP0), INTEGER);03709500
                        CALL OFF_TARGET(DEL(OP0));                              03710000
                     END;                                                       03710500
                  END;                                                          03711000
                  ELSE DO;                                                      03711500
                     IF FORM(COLUMN(OP0)) = LIT THEN                            03712000
                        CALL FORCE_NUM(FIXARG3,                                 03712500
                        SHL(VAL(COLUMN(OP0)),16)+VAL(COLUMN(OP0)), 8);          03713000
                     ELSE DO;                                                   03713500
                        TARGET_REGISTER = FIXARG3;                              03714000
                        CALL FORCE_ACCUMULATOR(COLUMN(OP0));                    03714500
                        CALL OFF_TARGET(COLUMN(OP0));                           03715000
                     END;                                                       03715500
                  END;                                                          03716000
                  CALL RETURN_STACK_ENTRIES(COLUMN(OP0), DEL(OP0));             03716500
               END;                                                             03717000
            END;                                                                03717500
         END;                                                                   03718000
         ELSE IF COLUMN(OP0) > 0 THEN DO;                                       03718500
            CALL SET_CHAR_DESC(OP0, FIXARG1, FIXARG2);                          03719500
         END;                                                                   03720000
         CALL DROP_PARM_STACK;                                                  03720500
         IF OP3 > 0 THEN DO;                                                    03721000
            CALL CHECK_VAC(OP3, SYSARG2(INTCALL));                              03721500
            CALL DROP_REG(OP3);                                                 03722000
         END;                                                                   03722500
         IF REMOTE_ADDRS THEN IF OPCODE = XXASN THEN OPCODE = 12;               03725000
         CALL GENLIBCALL(FORM_CHARNAME(OPCODE, CPART, VACOP));                  03725500
         LASTRESULT, OP3, REMOTE_ADDRS, CHAR_ASNMNT = 0;           /*DR111344*/ 03726500
      END CHAR_CALL;                                                            03727000
                                                                                03727500
 /* ROUTINE TO MASK LONG LITERAL STRINGS TO RECEIVER WIDTH */                   03728000
MASK_BIT_LIT:                                                                   03728500
      PROCEDURE(ROP, LOP) BIT(16);                                              03729000
         DECLARE (ROP, LOP) BIT(16);                                            03729500
         IF SIZE(ROP) > SIZE(LOP) THEN DO;                                      03730000
            VAL(ROP) = VAL(ROP) & XITAB(SIZE(LOP));                             03730500
            SIZE(ROP) = SIZE(LOP);                                              03731000
            LOC(ROP) = -1;                                                      03731100
         END;                                                                   03731500
      END MASK_BIT_LIT;                                                         03732000
                                                                                03732500
 /* PROCEDURE TO DO BIT STORES  */                                              03733000
BIT_STORE:                                                                      03733500
      PROCEDURE(ROP, OP, CONFLICT);                                             03734000
         DECLARE (ROP, OP, BOP, TOP, LOP) BIT(16),                              03734500
            (CONFLICT, IMPMASK, SHORTLIT, ASSIGNED, INDEXED) BIT(1);            03735000
                                                                                03735500
MAKE_BIT_OP:                                                                    03736000
         PROCEDURE;                                                             03736500
            CALL RETURN_STACK_ENTRY(TOP);                                       03737000
            IF SHORTLIT THEN DO;                                                03737500
               IF VAL(ROP) = 0 THEN TMP = AND;                                  03738000
               ELSE TMP = XOR;                                                  03738500
               TOP, LOP = MAKE_BIT_LIT(TMP, VAL(ROP), OP);                      03739000
            END;                                                                03739500
            ELSE DO;                                                            03740000
               TMP = DEL(ROP);                                                  03740500
               TOP, LOP = MAKE_BIT_LIT(TMP, CONST(ROP), OP);                    03741000
            END;                                                                03741500
         END MAKE_BIT_OP;                                                       03742000
                                                                                03742500
MASK_BIT_OP:                                                                    03743000
         PROCEDURE;                                                             03743500
            IF TMP = 0 THEN DO;                                                 03744000
               CALL DROP_INX(OP);                                               03744500
               ASSIGNED = TRUE;                                                 03745000
            END;                                                                03745500
            ELSE IF OPMODE(TYPE(OP)) = 1 THEN                                   03746000
               ASSIGNED = GENSI(MAKE_INST(TMP, TYPE(OP), RS), OP,               03746500
               VAL(LOP) & XITAB(HALFWORDSIZE));                                 03747000
            ELSE DO;                                                            03747500
               CALL FORCE_ACCUMULATOR(LOP, TYPE(OP));                           03748000
               CALL GUARANTEE_ADDRESSABLE(OP, MAKE_INST(TMP, TYPE(OP), RS));    03748500
               CALL ARITH_BY_MODE(TMP, LOP, OP, TYPE(OP), RS);                  03749000
               CALL DROP_REG(LOP);                                              03749500
               ASSIGNED = TRUE;                                                 03750000
            END;                                                                03750500
         END MASK_BIT_OP;                                                       03751000
                                                                                03751500
CHECK_BIT_OP:                                                                   03752000
         PROCEDURE(X);                                                          03752500
            DECLARE X BIT(1);                                                   03753000
            IF FORM(ROP) = VAC THEN                                             03753100
               IF USAGE(REG(ROP)) > 3 THEN                                      03753200
               DO;                                                              03753300
               X = ^CONFLICT;                                                   03753310
               CONFLICT = TRUE;                                                 03753320
            END;                                                                03753330
            IF CONFLICT THEN DO;                                                03753500
               TOP = GET_VAC(-1, TYPE(ROP));                                    03754000
               CALL MOVEREG(REG(ROP), REG(TOP), TYPE(ROP), X);                  03754500
               CALL SET_REG_NEXT_USE(REG(ROP), ROP);                             3754600
               ROP = TOP;                                                       03755000
               CONFLICT = FALSE;                                                03755500
            END;                                                                03756000
            X = 0;                                                              03756500
         END CHECK_BIT_OP;                                                      03757000
                                                                                03757500
         CALL UPDATE_ASSIGN_CHECK(OP);                                          03758000
         IF SIZE(LEFTOP) ^= SIZE(RIGHTOP) THEN   /*CR13211*/
            CALL ERRORS(CLASS_YA,100);           /*CR13211*/
         IF TYPE(OP) = EXTRABIT THEN DO;                                        03758500
   /*------------------------- #DREG --------------------------------*/
            D_RTL_SETUP = TRUE;
   /*----------------------------------------------------------------*/
            TARGET_REGISTER = FIXARG3;                                          03759000
            CALL FORCE_ACCUMULATOR(ROP, FULLBIT);                               03759500
            TARGET_REGISTER = -1;                                               03760000
            CALL ASSIGN_CLEAR(OP, INX(OP) ^= 0);                                03760100
            /* DR109030: CLEAR REGS POSSIBLY AFFECTED BY NAME DEREF */          70120000
            CALL CLEAR_NAME_SAFE(OP);            /*DR109030*/                   70130000
            CALL STACK_REG_PARM(FORCE_ADDRESS(PTRARG1, OP, 1));                 03760500
            CALL SET_CHAR_DESC(OP, FIXARG1, FIXARG2);                           03761000
            CALL CHECK_VAC(ROP, FIXARG3);                                       03761500
            CALL DROP_REG(ROP);                                                 03762000
            CALL DROP_PARM_STACK;                                               03762500
            CALL GENLIBCALL('DSST');                                            03764500
   /*-------------------- DANNY #DPARM --- RTL DSST ROUTINE----------*/         71140010
   /* RESTRICT REMOTE #D PASS BY REFERENCE PARAMETERS.               */         71150099
            IF DATA_REMOTE THEN                                                 71160099
               CALL PARM_STAT(OP,'DSST');                                       71170099
   /*----------------------------------------------------------------*/         71180050
            CONFLICT = 0;                                                       03765000
            RETURN;                                                             03765500
         END;                                                                   03766000
         ELSE IF TYPE(OP) = CHARSUBBIT THEN DO;                                 03766500
            CALL ASSIGN_CLEAR(OP, INX(OP) ^= 0);                                03766600
            CALL CHAR_CALL(XCSST, XVAL(OP), OP, 0, ROP);                        03767000
   /*-------------------- DANNY #DPARM --- RTL CSST ROUTINE----------*/         72591099
   /* RESTRICT REMOTE #D PASS BY REFERENCE PARAMETERS.               */         72592099
            IF DATA_REMOTE THEN                                                 72593099
               CALL PARM_STAT(OP,'CSST');                                       72594099
   /*----------------------------------------------------------------*/         72596099
            CALL RETURN_STACK_ENTRY(XVAL(OP));                                  03767500
            CONFLICT = 0;                                                       03768000
            RETURN;                                                             03768500
         END;                                                                   03769000
         /*-- IF IT IS A REMOTE AGGREGATE, NOT YET LOADED (SYM), WITH NO */
         /*-- INDEX LOADED, THEN WE HAVE BS123 ERROR CASE 2, WHICH IS    */
         /*-- REFERENCING THE 1ST NODE OF REMOTE SINGLE-COPY STRUCTURE.  */
         IF (FORM(OP)=SYM) THEN                                     /*DR111303*/
           IF (SYT_BASE(LOC(OP))=REMOTE_BASE | NR_DEREF(OP)) &      /*DR111303*/
              (INX(OP)=0) THEN DO;                                  /*DR111303*/
         /*-- SAVE AND RESTORE CURRENT TARGET REGISTER ALREADY ALLOCATED.*/
                 TEMP2 = TARGET_REGISTER;                           /*DR111303*/
                 TARGET_REGISTER = -1;                              /*DR111303*/
                 CALL SUBSCRIPT_RANGE_CHECK(OP,1);/*FORCE LHI RX,0*//*DR111303*/
                 TARGET_REGISTER = TEMP2;                           /*DR111303*/
              END;                                                  /*DR111303*/
         IMPMASK, SHORTLIT, ASSIGNED = FALSE;                                   03769500
         INDEXED = INX(OP) ^= 0;                                                03770000
         IF SYMFORM(FORM(OP)) THEN                                              03770500
            IF DATATYPE(SYT_TYPE(LOC2(OP))) ^= BITS THEN                        03771000
            IMPMASK = TRUE;                                                     03771500
         IF FORM(ROP) = LIT THEN DO;                                             3772000
            IF CONFLICT THEN DO;                                                 3772100
               ROP = COPY_STACK_ENTRY(ROP);                                      3772200
               CONFLICT = 2;                                                     3772300
            END;                                                                 3772400
            CALL MASK_BIT_LIT(ROP, OP);                                          3772500
         END;                                                                    3772600
         IF COLUMN(OP) = 0 THEN DO;                                             03773000
            IF FORM(ROP) = LIT THEN                                             03773500
            SHORTLIT=(VAL(ROP)=0|VAL(ROP)=XITAB(SIZE(OP))) & OPMODE(TYPE(OP))=1;03774000
            ELSE SHORTLIT = SHL(DUPLICATE_OPERANDS(OP, ROP), 1);                03774500
            IF SHORTLIT > 0 THEN DO;                                            03775000
               CALL MAKE_BIT_OP;                                                03775500
               CALL MASK_BIT_OP;                                                03776000
            END;                                                                03776500
            IF ASSIGNED THEN                                                    03777000
               CALL ASSIGN_CLEAR(OP, INDEXED, SHORTLIT, ROP);                   03777500
            ELSE DO;                                                            03778000
               CALL FORCE_ACCUMULATOR(ROP, TYPE(OP));                           03778500
               IF SIZE(ROP) > SIZE(OP) THEN DO;                                 03779000
                  IF SIZE(OP) ^= BIGHTS(TYPE(OP))*BITESIZE THEN DO;             03779500
                     CALL CHECK_BIT_OP;                                         03780000
                     CALL BIT_MASK(AND, ROP, SIZE(OP));                         03780500
                  END;                                                          03781000
                  ELSE IMPMASK = TRUE;                                          03781500
               END;                                                             03782000
               CALL GEN_STORE(ROP, OP, CONFLICT);                               03782500
               IF IMPMASK THEN CALL UNRECOGNIZABLE(REG(ROP));                   03783000
            END;                                                                03783500
         END;                                                                   03784000
         ELSE DO;                                                               03784500
            IF CONFLICT THEN CALL FORCE_ACCUMULATOR(ROP, TYPE(OP));             03785000
            ELSE IF FORM(COLUMN(OP)) = LIT THEN DO;                             03785500
               IF FORM(ROP) = LIT THEN                                          03786000
                  SHORTLIT = VAL(ROP) = 0 | VAL(ROP) = XITAB(SIZE(OP));         03786500
               ELSE SHORTLIT = SHL(DUPLICATE_OPERANDS(OP, ROP), 1);             03787000
            END;                                                                03787500
            ELSE CALL FORCE_ACCUMULATOR(ROP, TYPE(OP));                         03788000
            IF SHORTLIT > 0 THEN DO;                                            03792000
               CALL MAKE_BIT_OP;                                                03792500
               CALL MASK_BIT_OP;                                                03793000
            END;                                                                03797000
            IF ASSIGNED THEN                                                    03797500
               CALL ASSIGN_CLEAR(OP, INDEXED, SHORTLIT, ROP);                   03798000
            ELSE DO;                                                            03798500
               IF FORM(ROP) = VAC THEN NOT_THIS_REGISTER = REG(ROP);            03798600
               BOP = GET_VAC(-1, FULLBIT);                                      03799000
  /*DR111358*/ IF FORM(BOP) = VAC THEN NOT_THIS_REGISTER2 = REG(BOP);           03798600
  /*CR13616*/  CALL GUARANTEE_ADDRESSABLE(OP, MAKE_INST(LOAD,TYPE(OP),RX),      03799500
  /*CR13616*/                             BY_NAME_FALSE, 1);                    03799500
               IF FORM(OP) = CSYM THEN                                          03802500
                  CALL INCR_USAGE(BASE(OP));                                     3803000
               CALL EMIT_BY_MODE(LOAD, REG(BOP), OP, TYPE(OP));                 03803500
               IF (SYT_DIMS(LOC2(OP)) & "FF00") ^= 0 THEN IMPMASK = TRUE;       03804000
               CALL CHECK_BIT_OP;                                               03804500
               IF SHORTLIT > 0 THEN DO;                                         03805000
                  CALL MAKE_BIT_OP;                                             03805500
                  CALL ARITH_BY_MODE(TMP, BOP, LOP, TYPE(OP));                  03806000
                  IF SHORTLIT > 1 THEN                                          03806500
                     CALL DROP_UNUSED(ROP);                                     03807000
                  CALL GEN_STORE(BOP, OP, TRUE);                                03807500
                  IF IMPMASK THEN CALL UNRECOGNIZABLE(REG(BOP));                03809500
  /*DR111358*/    NOT_THIS_REGISTER2 = -1;
                  CALL DROP_VAC(BOP);                                            3809600
               END;                                                             03810000
               ELSE DO;                                                         03810500
  /*DR111358*/    NOT_THIS_REGISTER2 = -1;
                  IF SYT_CLASS(LOC2(OP)) = TEMPLATE_CLASS                       03810510
                     THEN SYT_FLAGS(LOC2(OP)) = SYT_FLAGS(LOC2(OP)) |           03810520
                     BITMASK_FLAG;                                              03810530
                  ELSE SYT_FLAGS(LOC(OP)) = SYT_FLAGS(LOC(OP)) |                03810540
                     BITMASK_FLAG;                                              03810550
                  SYT_FLAGS(SELFNAMELOC) = SYT_FLAGS(SELFNAMELOC) |             03810560
                     BITMASK_FLAG;                                              03810570
                  CALL SET_MASKING_BIT(LINE#);                                  03810580
                  CALL BIT_SHIFT(SLL, ROP, COLUMN(OP), 1);                      03811000
                  CALL FORCE_ACCUMULATOR(ROP, TYPE(OP));                        03811500
                  NOT_THIS_REGISTER = REG(ROP);                                  3811600
                  CALL ARITH_BY_MODE(EXOR, ROP, BOP, TYPE(BOP));                03812000
                  CALL BIT_MASK(AND, ROP, SIZE(OP), COLUMN(OP));                03813000
                  CALL ARITH_BY_MODE(EXOR, ROP, BOP, TYPE(BOP));                03813500
                  CALL DROP_VAC(BOP);                                            3813600
                  CALL GEN_STORE(ROP, OP, CONFLICT);                            03814000
                  NOT_THIS_REGISTER = -1;                                        3814100
                  IF IMPMASK THEN CALL UNRECOGNIZABLE(REG(ROP));                03814500
               END;                                                             03815000
            END;                                                                03816000
            CALL RETURN_STACK_ENTRY(COLUMN(OP));                                03816500
         END;                                                                   03817000
         IF TOP > 0 THEN CALL RETURN_STACK_ENTRY(TOP);                          03817500
         IF CONFLICT > 1 THEN CALL RETURN_STACK_ENTRY(ROP);                      3817600
         CONFLICT, TOP = 0;                                                     03818000
      END BIT_STORE;                                                            03818500
                                                                                03819000
 /* ROUTINE TO GATHER PARTITIONED STRING TO TEMPORARY AREA */                   03819500
CHAR_CONVERT:                                                                   03820000
      PROCEDURE(OP) BIT(16);                                                    03820500
         DECLARE (OP, PTR) BIT(16);                                             03821000
         IF SIZE(OP) < 0 THEN                                                   03821500
            SIZE(OP) = 255;                                                     03822000
         PTR = GETFREESPACE(CHAR, SIZE(OP) + 2);                                03822500
         CALL CHAR_CALL(XXASN, PTR, OP, 0);                                     03823000
         SIZE(PTR) = SIZE(OP);                                                  03823500
         CALL DROPSAVE(OP);                                                     03824000
         CALL RETURN_STACK_ENTRY(OP);                                           03824500
         RETURN PTR;                                                            03825500
      END CHAR_CONVERT;                                                         03826000
                                                                                03826500
 /* ROUTINE TO CONVERT INTERNAL NUMERIC TO CHARACTER DATA */                    03827000
NTOC:                                                                           03827500
      PROCEDURE(OP, RADIX, FLAG, RFLAG) BIT(16);                                03828000
         DECLARE (OP, RADIX, PTR, LEN) BIT(16), (FLAG, RFLAG) BIT(1);           03828500
         DECLARE CVTLEN(8) BIT(16) INITIAL (11, 11, 14, 23, 32, 32, 11, 11, 8), 03829000
            CVTREG(8) BIT(16) INITIAL ( 5,  5,  8,  8,  5,  5,  5,  5,  5);     03829500
   /*------------------------- #DREG --------------------------------*/
         D_RTL_SETUP = TRUE;
   /*----------------------------------------------------------------*/
         IF FORM(OP) = LIT & TYPE(OP) = CHAR THEN PTR = OP;                     03830500
         ELSE DO;                                                               03831000
            RADIX = RADIX + CHARTYPE(TYPE(OP));                                 03831500
            LEN = CVTLEN(RADIX);                                                03832000
            PTR = GETFREESPACE(CHAR, LEN+2);                                    03832500
            SIZE(PTR) = LEN;                                                    03833000
            TARGET_REGISTER = CVTREG(RADIX);                                    03833500
            IF RADIX > 3 THEN                                                   03834000
               CALL FORCE_ACCUMULATOR(OP, FULLBIT);                             03834500
            ELSE CALL FORCE_ACCUMULATOR(OP);                                    03835000
            IF RFLAG THEN TARGET_REGISTER = -1;                                 03835500
            ELSE CALL OFF_TARGET(OP);                                           03836000
            CALL FORCE_ADDRESS(PTRARG1, PTR);                                   03836500
            IF PACKTYPE(TYPE(OP)) = BITS THEN                                   03838000
               CALL FORCE_NUM(FIXARG2, SIZE(OP));                               03838500
            CALL GENLIBCALL(TYPES(RADIX) || 'TOC');                             03839000
   /*-------------------- DANNY #DPARM --- RTL ?TOC ROUTINES --------*/         72630010
   /* ONLY THING PASSED BY REFERENCE HERE IS OUTPUT STACK ADDRESS,   */         72640099
   /* SO NO NEED TO CHECK FOR #D BEING PASSED.                       */         72641099
   /*----------------------------------------------------------------*/         72650050
            IF ^FLAG THEN                                                       03839500
               CALL RETURN_STACK_ENTRY(OP);                                     03840000
            LASTRESULT = PTR;                                                   03840500
         END;                                                                   03841000
         RADIX, FLAG, RFLAG = 0;                                                03841500
         RETURN PTR;                                                            03842000
      END NTOC;                                                                 03842500
                                                                                03843000
 /* ROUTINE TO DO INTEGER/SCALAR ASSIGNMENTS  */                                03843500
DO_ASSIGNMENT:                                                                  03844000
      PROCEDURE;                                                                03844500
         DECLARE (ASSIGNC, ASSIGNS, ASSIGNT) BIT(16);                           03845000
         DECLARE (PROTECT_RIGHTOP, NEED_LOAD) BIT(1);                           03845500
         ASSIGNC = 0;                                                           03846000
         DO TMP = 0 TO 5;                                                       03846500
            ASSIGN_HEAD(TMP) = 0;                                               03847000
         END;                                                                   03847500
         DO LHSPTR = 2 TO NUMOP;                                                03848000
            LEFTOP = GET_OPERAND(LHSPTR);                                       03848500
            IF VDLP_ACTIVE THEN                                                  3849000
               TMP = SELECTYPE(TYPE(LEFTOP)&8 | SCALAR);                         3849100
            ELSE TMP = SELECTYPE(TYPE(LEFTOP));                                  3849200
            CONST(LEFTOP) = ASSIGN_HEAD(TMP);                                   03849500
            IF ASSIGN_HEAD(TMP) = 0 THEN ASSIGNC = ASSIGNC + 1;                 03850000
            ASSIGN_HEAD(TMP) = LEFTOP;                                          03850500
         END;                                                                   03851000
         RIGHTOP = GET_OPERAND(1);                                              03851500
         IF NUMOP = 2 THEN                                                      03852000
            NEED_LOAD = ^DUPLICATE_OPERANDS(LEFTOP, RIGHTOP);                   03852500
         ELSE NEED_LOAD = TRUE;                                                 03853000
         IF VDLP_ACTIVE THEN                                                     3853500
            TMP = SELECTYPE(TYPE(RIGHTOP)&8 | SCALAR);                           3853600
         ELSE TMP = SELECTYPE(TYPE(RIGHTOP));                                    3853700
         ASSIGNS = 1;                                                           03854000
         DO LHSPTR = ASSIGN_START(TMP) TO ASSIGN_START(TMP+1)-1;                03854500
            ASSIGNT = ASSIGN_TYPES(LHSPTR);                                     03855000
            IF ASSIGN_HEAD(ASSIGNT) > 0 THEN DO;                                03855500
               ASSIGNC = ASSIGNC - 1;                                           03856000
               LITTYPE = TYPE(ASSIGN_HEAD(ASSIGNT));                            03856500
               IF TAG_BITS(1) = LIT THEN DO;                                    03857000
                  IF LITTYPE ^= TYPE(RIGHTOP) THEN DO;                          03857500
                     CALL DROP_VAC(RIGHTOP);                                     3858000
                     RIGHTOP = GET_OPERAND(1);                                  03859500
                  END;                                                          03860000
                  NEED_LOAD = FALSE;                                            03860010
               END;                                                             03860020
               ELSE IF FORM(RIGHTOP) = LIT THEN                                 03860030
                  IF BIT_PICK(RIGHTOP) > 0 THEN                                 03860040
                  NEED_LOAD = TRUE;                                             03860042
               ELSE IF LOC(RIGHTOP) > 0 THEN DO;                                03860044
                  IF LITTYPE ^= TYPE(RIGHTOP) THEN                              03860050
                     CALL LITERAL(LOC(RIGHTOP), LITTYPE, RIGHTOP);              03860060
                  NEED_LOAD = FALSE;                                            03860070
               END;                                                             03860080
               ELSE IF LITTYPE ^= TYPE(RIGHTOP) THEN                            03860090
                  NEED_LOAD = TRUE;                                             03860100
               RESULT = 0;                                                      03860500
               DO CASE PACKTYPE(LITTYPE);                                       03861000
                  IF VDLP_ACTIVE THEN DO;                                        3861500
                     IF NEED_LOAD THEN                                          03861600
                        CALL FORCE_BY_MODE(RIGHTOP, LITTYPE);                    3861700
                  END;                                                           3861800
                  ELSE DO;                                                       3861900
                     CALL CHECKPOINT_REG(FR0);                                  03862000
                     CALL EMITRR(SDR, FR0, FR0);                                03862500
                  END;                                                          03863000
                  IF NEED_LOAD THEN                                             03863500
                     CALL FORCE_BY_MODE(RIGHTOP, LITTYPE);                      03864000
                  DO;                                                           03864500
                     RESULT = NTOC(RIGHTOP, 0, 1, ASSIGNC > 0);                 03865000
                     CALL DROPSAVE(RESULT);                                     03865500
                  END;                                                          03866000
                  IF NEED_LOAD THEN                                             03866500
                     CALL FORCE_BY_MODE(RIGHTOP, LITTYPE);                      03867000
               END;                                                             03867500
               DO WHILE ASSIGN_HEAD(ASSIGNT) > 0;                               03868000
                  ASSIGNS = ASSIGNS + 1;                                        03868500
                  LEFTOP = ASSIGN_HEAD(ASSIGNT);                                03869000
                  CALL UPDATE_ASSIGN_CHECK(LEFTOP);                             03869500
                  PROTECT_RIGHTOP = ASSIGNC^=0 | ASSIGNS^=NUMOP;                03870000
                  DO CASE PACKTYPE(TYPE(LEFTOP));                               03870500
                     IF VDLP_ACTIVE THEN                                         3871000
                        CALL GEN_STORE(RIGHTOP, LEFTOP, PROTECT_RIGHTOP);        3871100
                     ELSE DO;                                                    3871200
                        TEMPSPACE = ROW(LEFTOP) * COLUMN(LEFTOP);               03871500
                        IF DATATYPE(TYPE(LEFTOP)) = MATRIX & DEL(LEFTOP) > 0    03872000
                           THEN OPCODE = XPASN;                                 03872500
                        ELSE OPCODE = XSASN;                                    03873000
                        CALL ASSIGN_CLEAR(LEFTOP, 1);                           03873100
                        CALL VMCALL(OPCODE, (TYPE(LEFTOP)&8)^=0, LEFTOP, 0, 0,  03873500
                           DEL(LEFTOP));                                        03874000
                     END;                                                       03874500
                     DO;                                                        03875000
                        CALL BIT_STORE(RIGHTOP, LEFTOP, PROTECT_RIGHTOP);       03875500
                     END;                                                       03876000
                     CALL CHAR_CALL(OPCODE, LEFTOP, RESULT, 0);                 03876500
                     DO;                                                        03877000
                        CALL GEN_STORE(RIGHTOP, LEFTOP, PROTECT_RIGHTOP);       03877500
                     END;                                                       03878000
                  END;                                                          03878500
                  ASSIGN_HEAD(ASSIGNT) = CONST(LEFTOP);                         03879000
                  CALL RETURN_STACK_ENTRY(LEFTOP);                              03879500
               END;                                                             03880000
               IF RESULT ^= RIGHTOP THEN CALL RETURN_STACK_ENTRY(RESULT);       03880500
            END;                                                                03881000
         END;                                                                   03881500
         CALL RETURN_STACK_ENTRY(RIGHTOP);                                      03882000
      END DO_ASSIGNMENT;                                                        03882500
                                                                                03883000
 /* ROUTINE TO CONVERT CHARACTER DATA TO INTERNAL FORM  */                      03883500
CTON:                                                                           03884000
      PROCEDURE(OP, OPTYPE, TAG) BIT(16);                                       03884500
         DECLARE (OP, OPTYPE, TAG, PTR) BIT(16);                                03885000
   /*------------------------- #DREG --------------------------------*/
         D_RTL_SETUP = TRUE;
   /*----------------------------------------------------------------*/
         IF CHECK_REMOTE(OP) | COLUMN(OP) > 0 THEN                              03885500
            OP = CHAR_CONVERT(OP);                                              03886000
   /*-------------------- DANNY #DPARM --- #D PASS-BY-REF TO RTL ----*/         73840010
   /* #D AGGREGATE DATA MUST BE COPIED TO THE STACK.                 */         73850099
         IF DATA_REMOTE & (CSECT_TYPE(LOC(OP),OP)=LOCAL#D)                      73860099
            THEN OP = CHAR_CONVERT(OP);                                         73870099
   /*----------------------------------------------------------------*/         73880018
         CALL DROPSAVE(OP);                                                     03886500
         CALL FORCE_ADDRESS(PTRARG1, OP);                                       03887000
         CALL GENLIBCALL('CTO' || TYPES(CHARTYPE(OPTYPE)+TAG));                 03887500
         CALL RETURN_STACK_ENTRY(OP);                                           03888000
         PTR = GET_STACK_ENTRY;                                                 03889000
         CALL SET_RESULT_REG(PTR, OPTYPE);                                      03889500
         TAG, LASTRESULT = 0;                                                   03890000
         RETURN PTR;                                                            03890500
      END CTON;                                                                 03891000
                                                                                03891500
 /* ROUTINE TO SET UP CHARACTER OPERANDS FOR OPERATIONS */                      03892000
GET_CHAR_OPERANDS:                                                              03892500
      PROCEDURE;                                                                03893000
         LITTYPE = CHAR;                                                        03893500
         LEFTOP = GET_OPERAND(1);                                               03894000
         IF CHECK_REMOTE(LEFTOP) | COLUMN(LEFTOP) > 0 THEN                      03894500
            LEFTOP = CHAR_CONVERT(LEFTOP);                                      03895000
   /*-------------------- DANNY #DPARM --- #D PASS-BY-REF TO RTL ----*/         74060010
   /* #D AGGREGATE DATA MUST BE COPIED TO THE STACK.                 */         74070099
         IF DATA_REMOTE & (CSECT_TYPE(LOC(LEFTOP),LEFTOP)=LOCAL#D)              74080099
            THEN LEFTOP = CHAR_CONVERT(LEFTOP);                                 74090099
   /*----------------------------------------------------------------*/         74100018
         CALL DROPSAVE(LEFTOP);                                                 03895500
         IF NUMOP = 2 THEN DO;                                                  03896000
            IF CLASS = 0 THEN LITTYPE = TYPE_BITS(2);                           03896500
            RIGHTOP = GET_OPERAND(2);                                           03897000
            IF TYPE(RIGHTOP) = CHAR THEN DO;                                    03897500
               IF CHECK_REMOTE(RIGHTOP) | COLUMN(RIGHTOP) > 0 THEN              03898000
                  RIGHTOP = CHAR_CONVERT(RIGHTOP);                              03898500
   /*-------------------- DANNY #DPARM --- #D PASS-BY-REF TO RTL ----*/         74180010
   /* #D AGGREGATE DATA MUST BE COPIED TO THE STACK.                 */         74190099
               IF DATA_REMOTE & (CSECT_TYPE(LOC(RIGHTOP),RIGHTOP)=LOCAL#D)      74200099
                  THEN RIGHTOP = CHAR_CONVERT(RIGHTOP);                         74210099
   /*----------------------------------------------------------------*/         74220018
               CALL DROPSAVE(RIGHTOP);                                          03899000
            END;                                                                03899500
            ELSE DO;                                                            03900000
               TARGET_REGISTER = FIXARG1;                                       03900500
               CALL FORCE_ACCUMULATOR(RIGHTOP);                                 03901000
               CALL STACK_TARGET(RIGHTOP);                                      03901500
               RIGHTOP = 0;                                                     03902000
            END;                                                                03902500
         END;                                                                   03903000
         ELSE RIGHTOP = 0;                                                      03903500
      END GET_CHAR_OPERANDS;                                                    03904000
                                                                                 3904010
 /* ROUTINE TO ALLOCATE ARRAYED TEMPORARY SPACE  */                              3904020
GET_ARRAY_TEMP:                                                                  3904030
      PROCEDURE(OP, ATYPE) BIT(16);                                              3904040
         DECLARE (OP, ATYPE, PTR, SPTR, I) BIT(16);                              3904050
         SPTR = SF_RANGE_PTR;                                                    3904060
         AREA = 1;                                                               3904070
         COPY(0), VMCOPY(0), STRUCT(0) = 0;                                     03904080
         I = CALL_LEVEL - DOPUSH(CALL_LEVEL);                                    3904090
         DO I = SDOPTR(I)+1 TO SDOPTR(I)+DOCOPY(I);                              3904100
            PTR = DORANGE(I);                                                    3904110
            IF FORM(PTR) = SYM THEN                                              3904120
               CALL ERRORS(CLASS_D,100);                                         3904130
            AREA = AREA * VAL(PTR);                                              3904140
            IF SF_RANGE_PTR > CALL_LEVEL# THEN                                   3904150
               CALL ERRORS(CLASS_BS,116);                                        3904160
            SF_RANGE(SF_RANGE_PTR) = VAL(PTR);                                   3904170
            SF_RANGE_PTR = SF_RANGE_PTR + 1;                                     3904180
            COPY(0) = COPY(0) + 1;                                              03904190
         END;                                                                    3904200
         CALL SET_AREA(OP);                                                      3904210
         IF ^VDLP_ACTIVE | DOPUSH(CALL_LEVEL) THEN                               3904220
            AREA = AREA * AREASAVE;                                              3904230
         /* DR109010: SET_AREA GAVE US # HALFWORDS. ADJUST BACK TO */            3904240
         /* BYTES BECAUSE GETFREESPACE EXPECTS BYTES FOR CHARACTER.*/            3904240
         IF ATYPE = CHAR THEN AREA = AREA * 2;  /* D109010 */                    3904240
         PTR = GETFREESPACE(ATYPE, AREA);                                        3904240
         VAL(PTR) = SPTR;                                                        3904250
         COPY(PTR) = COPY(0);                                                   03904260
         ROW(PTR) = ROW(OP);                                                     3904270
         IF PACKTYPE(ATYPE) = VECMAT THEN DO;                                    3904280
            COLUMN(PTR) = COLUMN(OP);                                            3904290
            VMCOPY(0), VMCOPY(PTR) = VMCOPY(OP);                                03904300
         END;                                                                    3904310
         IF ATYPE = STRUCTURE THEN DO;                                           3904320
            DEL(PTR) = DEL(OP);                                                  3904330
            STRUCT(0) = COPY(0);                                                03904340
         END;                                                                    3904350
         CALL VAC_COPIES(PTR);                                                   3904360
         COPY(PTR) = COPY(0);                                                   03904370
         VMCOPY(PTR) = VMCOPY(0);                                               03904380
         STRUCT(PTR) = STRUCT(0);                                               03904390
         RETURN PTR;                                                             3904400
      END GET_ARRAY_TEMP;                                                        3904410
                                                                                03904500
 /* ROUTINE TO CHECK FOR LEVEL DESCENT IN STRUCTURE TEMPLATE  */                03905000
DESCENDENT:                                                                     03905500
      PROCEDURE(XLOC, REF) BIT(16);                                             03906000
         DECLARE (XLOC, REF) BIT(16);                                           03906500
         IF SYT_TYPE(XLOC) = STRUCTURE THEN DO;                                 03907000
            IF (SYT_FLAGS(XLOC) & EVIL_FLAGS) = EVIL_FLAGS THEN                 03907500
               CALL ERRORS(CLASS_DQ,100);                                       03908000
            IF (SYT_FLAGS(XLOC) & NAME_FLAG) ^= 0 THEN RETURN 0;                03908500
            KIN = SYT_LINK1(XLOC);                                              03909000
            IF KIN > 0 THEN RETURN KIN;                                         03909500
            KIN = SYT_DIMS(XLOC);                                               03910000
            DO CASE REF;                                                        03910500
               SYT_LINK2(KIN) = XLOC;                                           03911000
               SYT_DIMS(KIN) = XLOC;                                            03911010
            END;                                                                03912000
            STRUCT_MOD(REF) = STRUCT_MOD(REF) + SYT_ADDR(XLOC);                 03912500
            RETURN KIN;                                                         03913000
         END;                                                                   03913500
         RETURN 0;                                                              03914000
      END DESCENDENT;                                                           03914500
                                                                                03915000
 /* ROUTINE TO ADVANCE TO NEXT NODE IN A STRUCTURE TEMPLATE  */                 03915500
SUCCESSOR:                                                                      03916000
      PROCEDURE(XLOC, REF) BIT(16);                                             03916500
         DECLARE (XLOC, REF) BIT(16);                                           03917000
         KIN = SYT_LINK2(XLOC);                                                 03917500
         IF KIN >= 0 THEN RETURN KIN;                                           03918000
         IF (SYT_LOCK#(-KIN)&"80") ^= 0 THEN DO;                                03918500
            KIN = -KIN;                                                         03919000
            DO CASE REF;                                                        03919500
               DO;                                                              03920000
                  IF SYT_LINK2(KIN) = 0 THEN RETURN -KIN;                       03920500
                  KIN = SYT_LINK2(KIN);                                         03921000
               END;                                                             03921500
               DO;                                                              03922000
                  IF SYT_DIMS(KIN) = 0 THEN RETURN -KIN;                        03922500
                  KIN = SYT_DIMS(KIN);                                          03923000
               END;                                                             03923500
            END;                                                                03924000
            STRUCT_MOD(REF) = STRUCT_MOD(REF) - SYT_ADDR(KIN);                  03924500
            RETURN -KIN;                                                        03925000
         END;                                                                   03925500
         RETURN KIN;                                                            03926000
      END SUCCESSOR;                                                            03926500
                                                                                03927000
 /* ROUTINE TO ADVANCE TO THE NEXT TERMINAL IN A STRUCTURE TEMPLATE */          03927500
STRUCTURE_ADVANCE:                                                              03928000
      PROCEDURE(REF) BIT(16);                                                   03928500
         DECLARE (REF, RET) BIT(16), A(1) BIT(16);                              03929000
         IF STRUCT_REF(REF) > 0 THEN GO TO RE_ENTER;                            03929500
         STRUCT_REF(REF), A(REF) = STRUCT_TEMPL(REF);                           03930000
         IF (SYT_LOCK#(A(REF))&"80") ^= 0 THEN DO CASE REF;                     03930500
            SYT_LINK2(A(REF)) = 0;                                              03931000
            SYT_DIMS(A(REF)) = 0;                                               03931500
         END;                                                                   03932000
         DO FOREVER;                                                            03932500
            DO WHILE DESCENDENT(A(REF), REF) > 0;                               03933000
               A(REF) = KIN;                                                    03933500
            END;                                                                03934000
            RET = A(REF);                                                       03934500
            REF = 0;                                                            03935000
            RETURN RET;                                                         03935500
RE_ENTER:                                                                       03936000
            A(REF) = SUCCESSOR(A(REF), REF);                                    03936500
            IF A(REF) < 0 THEN DO;                                              03937000
               A(REF) = -A(REF);                                                03937500
               IF A(REF) = STRUCT_REF(REF) THEN DO;                             03938000
                  STRUCT_REF(REF), REF = 0;                                     03938500
                  RETURN 0;                                                     03939000
               END;                                                             03939500
               GO TO RE_ENTER;                                                  03940000
            END;                                                                03940500
         END;                                                                   03941000
      END STRUCTURE_ADVANCE;                                                    03941500
                                                                                03942000
 /* ROUTINE TO ELIMINATE POSSIBLE MULTIPLE ASSIGNMENT CONFLICTS FOR             03942500
      AGGREGATE DATA TYPES */                                                   03943000
CHECK_AGGREGATE_ASSIGN:                                                         03943500
      PROCEDURE(OP) BIT(16);                                                    03944000
         DECLARE OP BIT(16);                                                    03944500
         CALL GUARANTEE_ADDRESSABLE(OP, LA);                                    03945000
         DO CASE PACKTYPE(TYPE(OP));                                            03945500
            IF FORM(OP) = CSYM | INX(OP) ^= 0 THEN                              03946000
               OP = VECMAT_CONVERT(OP);                                         03946500
            ;                                                                   03947000
            IF FORM(OP) = CSYM | INX(OP) ^= 0 | COLUMN(OP) > 0 THEN             03947500
               OP = CHAR_CONVERT(OP);                                           03948000
            ;                                                                   03948500
            ;                                                                   03949000
         END;  /* CASE PACKTYPE */                                              03949500
         RETURN OP;                                                             03950000
      END CHECK_AGGREGATE_ASSIGN;                                               03950500
                                                                                 3950520
 /* PROCEDURE TO LOOK AHEAD FOR VECTOR/MATRIX ASSIGNMENT OPERATIONS */           3950540
VECMAT_ASN:                                                                      3950560
      PROCEDURE(CTR) BIT(16);                                                    3950580
         DECLARE (CTR, OPCODE) BIT(16);                                          3950600
         DECLARE MATASN BIT(16) INITIAL("3010"),                                 3950620
            VECASN BIT(16) INITIAL("4010");                                      3950640
         CTR = SKIP_NOP(CTR);                                                    3950660
         IF (OPR(CTR) & "FFF9") = XVDLP THEN DO;                                 3950680
            CTR = SKIP_NOP(CTR);                                                 3950700
            IF (OPR(SKIP_NOP(CTR)) & "FFF9") ^= XVDLE THEN RETURN -1;            3950720
         END;                                                                    3950740
         ELSE IF (OPR(CTR) & "FFF9") = XVDLE & ^VDLP_IN_EFFECT THEN             03950745
            CTR = SKIP_NOP(CTR);                                                03950750
         IF POPNUM(CTR) = 2 THEN DO;                                             3950760
            OPCODE = POPCODE(CTR);                                               3950780
            IF OPCODE = MATASN | OPCODE = VECASN THEN RETURN CTR;                3950800
         END;                                                                    3950820
         RETURN -1;                                                              3950840
      END VECMAT_ASN;                                                            3950860
                                                                                03951000
 /* ROUTINE TO CENERATE COMPARISON BETWEEN TWO STRUCTURES */                    03951500
COMPARE_STRUCTURE:                                                              03952000
      PROCEDURE(SIZ);                                                           03952500
         DECLARE SIZ BIT(16);                                                   03953000
         DECLARE CSTRUC(1) CHARACTER INITIAL ('CSTRUC', 'CSTR');                03953500
   /*----------------------- #DREG ----------------------------------*/
   /* D_RTL_SETUP IS SET TO TRUE IN CLASS0 FOR THE STRUCTURE RTLS    */
   /* SO NO NEED TO SET IT HERE.                                     */
   /*----------------------------------------------------------------*/
         CALL FORCE_NUM(FIXARG1, SIZ);                                          03954000
         CALL GENLIBCALL(CSTRUC(REMOTE_ADDRS));                                 03954500
         CALL EMITBFW(NEQ, GETSTMTLBL(SECONDLABEL));                            03955000
      END COMPARE_STRUCTURE;                                                    03955500
                                                                                 3955508
 /* ROUTINE TO SET ASIDE ARRAYED CSE'S  */                                       3955516
VAC_ARRAY_TEMP:                                                                  3955524
      PROCEDURE(OP);                                                             3955532
         DECLARE (OP, PTR) BIT(16);                                              3955540
         PTR = GET_ARRAY_TEMP(OP, TYPE(OP));                                     3955548
         DO CASE PACKTYPE(TYPE(OP));                                             3955556
            DO;  /* VECTOR/MATRIX */                                             3955564
               IF VDLP_ACTIVE THEN GO TO INTSCA_TEMP;                            3955572
               TEMPSPACE = ROW(OP) * COLUMN(OP);                                 3955580
               CALL VECMAT_ASSIGN(PTR, OP);                                      3955588
            END;                                                                 3955596
            GO TO INTSCA_TEMP;  /* BITS */                                       3955604
            CALL CHAR_CALL(XXASN, PTR, OP, 0);  /* CHARACTER */                  3955612
            DO;  /* INTEGER/SCALAR */                                            3955620
INTSCA_TEMP:                                                                     3955628
               CALL EMIT_BY_MODE(STORE, REG(OP), PTR, TYPE(OP));                 3955636
               CALL DROP_REG(OP);                                                3955644
            END;                                                                 3955652
            ;  /* STRUCTURE - SHOULDN'T GET HERE */                              3955660
         END;                                                                    3955668
         CALL DROP_INX(PTR);                                                     3955676
         CALL DROPSAVE(OP);                                                      3955684
         CALL RETURN_STACK_ENTRY(OP);                                            3955692
         RETURN PTR;                                                             3955700
      END VAC_ARRAY_TEMP;                                                        3955708
                                                                                 3955716
 /* ROUTINE TO ESTABLISH STACK AS ORDINARY OR CSE RESULT */                      3955724
SETUP_VAC:                                                                       3955732
      PROCEDURE(OP, N);                                                          3955740
         DECLARE (OP, N) BIT(16);                                                3955748
         DECLARE COPT_BITS BIT(16);                                             03955750
         CALL SET_NEXT_USE(OP, CTR);                                             3955756
/*------------------------ #D DR108601 -----------------------------*/
/* ADD CHECK FOR REG >= 0 -- SKIP REGISTER SETUP IF REG<0;NO REG IS */
/* USED. THIS OCCURS FOR EVENT EXPRESSIONS AND SOME BIT EXPRESSIONS.*/
         IF (FORM(OP) = VAC) & (REG(OP) >= 0) THEN DO;                           3955764
/*------------------------------------------------------------------*/
            CALL SET_REG_NEXT_USE(REG(OP), OP);                                  3955772
            IF CSE_FLAG THEN                                                     3955780
             IF ^USAGE(REG(OP))|R_CONTENTS(REG(OP))^=VAC|R_VAR(REG(OP))^<-1 THEN03955784
               CALL SET_USAGE(REG(OP), VAC, CTR+N);                              3955788
         END;                                                                    3955796
         COPT_BITS = X_BITS(N);                                                 03955804
         IF ARRAY_FLAG & COPT_BITS | VDLP_ACTIVE & SHR(TAG,6) THEN              03955808
            OP = VAC_ARRAY_TEMP(OP);                                             3955812
         COPT(OP) = COPT(OP) | COPT & 4;                                         3955820
         IF SHR(COPT_BITS, 1) THEN DO;                                          03955828
            DECLARE P BIT(16);                                                   3955836
            OFF_PAGE_CTR(OFF_PAGE_NEXT) = OFF_PAGE_CTR(OFF_PAGE_NEXT) + 1;       3955844
            IF OFF_PAGE_CTR(OFF_PAGE_NEXT) > OFF_PAGE_MAX THEN                   3955852
               CALL ERRORS(CLASS_BS, 131);                                       3955860
            P = OFF_PAGE_BASE(OFF_PAGE_NEXT) + OFF_PAGE_CTR(OFF_PAGE_NEXT) - 1;  3955868
            DO WHILE P >= RECORD_TOP(PAGE_FIX);                                 03955869
               NEXT_ELEMENT(PAGE_FIX);                                          03955870
            END;                                                                03955871
            OFF_PAGE_TAB(P) = OP | SHL(ARRAY_FLAG, 31);                          3955876
            OFF_PAGE_LINE(P) = CTR+N;                                            3955884
         END;                                                                    3955892
         /*DR109084 - THE HALMAT VALUE IN OPR MAY BE NEEDED AGAIN FOR*/
         /*STRUCTURE INITIALIZATION, SO SAVE THE VALUE.              */
         VAC_VAL(CTR+N) = TRUE;                  /*DR109084*/
         OPR_VAL(CTR+N) = OPR(CTR+N);            /*DR109084*/
         OPR(CTR+N) = OP | SHL(ARRAY_FLAG, 31);                                  3955900
      /* IF AN NR DEREF HAS PUT ZCON ON STACK, DONT SET IT UP    CR12432 */
      /* AS A CSE (BY CHANGING LOC2 TO POINT TO HALMAT) BECAUSE  CR12432 */
      /* IT WILL ONLY BE USED ONCE FOR INDIRECT ADDRESSING, AND  CR12432 */
      /* LOC2 IS NEEDED LATER AS A SYMBOL TABLE POINTER.         CR12432 */
         IF ^(NR_DEREF(OP) & (FORM(OP)=NRTEMP)) THEN          /* CR12432 */
         IF ^SYMFORM(FORM(OP)) THEN LOC2(OP) = CTR+N;                            3955908
         N = 0;                                                                  3955916
      END SETUP_VAC;                                                             3955924
                                                                                03956000
 /* ROUTINE TO CHECK VECTOR-MATRIX PARAMETER DIMS AGAINST TEMPLATE */           03956500
CHECK_VM_ARG_DIMS:                                                              03957000
      PROCEDURE;                                                                03957500
         IF ROW(RIGHTOP) ^= (SHR(SYT_DIMS(ARGPOINT),8)&"FF") |                  03958000
            COLUMN(RIGHTOP) ^= (SYT_DIMS(ARGPOINT)&"FF") THEN                   03958500
            IF CLASS=8 THEN CALL ERRORS(CLASS_DI,110); /*DR109044*/
            ELSE CALL ERRORS(CLASS_FD,101,''||ARGNO);  /*DR109044-MOD*/         03959000
      END CHECK_VM_ARG_DIMS;                                                    03959500
                                                                                03960000
 /* ROUTINE TO MATCH ASSIGN PARAMETER OR NAME INITIAL ATTRIBUTES*/              03960500
CHECK_ATTRIBUTES:  /*DR109044*/                                                 03961000
      PROCEDURE;                                                                03961500
         DECLARE TEMP_LOC BIT(16);                          /*DR109071*/
         IF ^SYMFORM(FORM(RIGHTOP)) THEN                                        03962000
         /* A REMOTE NAME REMOTE COULD HAVE BEEN PASSED, IN   CR12935*/         84750000
         /* WHICH CASE ITS FORM WILL BE NRTEMP.               CR12935*/         84760000
            IF ^(NR_DEREF(RIGHTOP) & (FORM(RIGHTOP)=NRTEMP))/*CR12935*/         84770000
            THEN                                            /*CR12935*/         84780000
            CALL ERRORS(CLASS_F,100);                                           03962500
         /*ATTRIBUTE MATCHING DIFFERS FOR NAME INITIALIZATION AND */
         /*ASSIGN PARAMETERS - USE DIFFERENT FLAG TO CHECK        */
         /* IF PARAMETER IS A MAJOR STRUCTURE, USE LOC TO     DR109071*/
         /* POINT TO SYMBOL TABLE ENTRY FOR THE STRUCTURE.    DR109071*/
         /* OTHERWISE, USE LOC2 TO POINT TO SYMBOL TABLE      DR109071*/
         /* ENTRY OF VARIABLE ITSELF.                         DR109071*/
         IF MAJOR_STRUCTURE(RIGHTOP) THEN                   /*DR109071*/
            TEMP_LOC = LOC(RIGHTOP);                        /*DR109071*/
         ELSE TEMP_LOC = LOC2(RIGHTOP);                     /*DR109071*/
         IF CLASS=8 THEN DO;                                /*DR109044*/
            IF (SYT_FLAGS(ARGPOINT)&NI_FLAGS) ^=            /*DR109044*/
               (SYT_FLAGS(TEMP_LOC)&NI_FLAGS) THEN          /*DR109071*/
               CALL ERRORS(CLASS_DI,109);                   /*DR109044*/
         /*LOCK ATTRIBUTE IS INHERITED, SO ALWAYS CHECK       DR109071*/
         /*ATTRIBUTE AGAINST LOC(RIGHTOP) WHICH POINTS TO     DR109071*/
         /*MAJOR STRUCTURE IF VARIABLE IS A STRUCTURE NODE.   DR109071*/
            ELSE IF (SYT_FLAGS(ARGPOINT)&LOCK_BITS)^=       /*DR109071*/
               (SYT_FLAGS(LOC(RIGHTOP))&LOCK_BITS) THEN     /*DR109071*/
               CALL ERRORS(CLASS_DI,109);                   /*DR109071*/
         END;                                               /*DR109044*/
         ELSE DO;                                           /*DR109044*/
         /*CR13538-CHECK SINGLE/DOUBLE/LATCHED ATTRIBUTE MATCHING.    */
            IF (SYT_FLAGS(ARGPOINT)&NI_FLAGS)^=     /*CR13538,DR109044*/        03963000
               (SYT_FLAGS(TEMP_LOC)&NI_FLAGS)       /*CR13538,DR109071*/        03963000
               THEN CALL ERRORS(CLASS_FT,102);              /*DR109044*/        03963500
         /*CR13538-CHECK FOR REMOTE ARGUMENT PASSED TO NON-REMOTE PARAMETER*/
            ELSE IF ((SYT_FLAGS(ARGPOINT)&REMOTE_FLAG)=0)&        /*CR13538*/
               (POINTS_REMOTE(RIGHTOP) |                          /*CR13538*/
               (LIVES_REMOTE(RIGHTOP) & ^NAME_VAR(RIGHTOP)))      /*CR13538*/
               THEN CALL ERRORS(CLASS_FT,102);                    /*CR13538*/
         /*CR13538-CHECK FOR NAME ARGUMENT PASSED TO NAME REMOTE ASSIGN    */
         /*PARAMETER.  YCON->ZCON CONVERSION IS NOT POSSIBLE IN THIS CASE. */
            ELSE IF ((SYT_FLAGS(TEMP_LOC)&REMOTE_FLAG)=0) &       /*CR13538*/
               ((SYT_FLAGS(ARGPOINT)&NAME_OR_REMOTE)=NAME_OR_REMOTE)/*13538*/
               THEN CALL ERRORS(CLASS_FT,102);                    /*CR13538*/
         /*LOCK ATTRIBUTE IS INHERITED, SO ALWAYS CHECK       DR109071*/
         /*ATTRIBUTE AGAINST LOC(RIGHTOP) WHICH POINTS TO     DR109071*/
         /*MAJOR STRUCTURE IF VARIABLE IS A STRUCTURE NODE.   DR109071*/
            ELSE IF (SYT_FLAGS(ARGPOINT)&LOCK_BITS)^=       /*DR109071*/
              (SYT_FLAGS(LOC(RIGHTOP))&LOCK_BITS)           /*DR109071*/
              THEN CALL ERRORS(CLASS_FT,102);               /*DR109071*/        03963500
        /*CODE TO CHECK FOR DENSE ATTRIBUTE WAS DELETED - CR13236 */
         END;                                               /*DR109044*/
         IF SYT_LOCK#(ARGPOINT) ^= "FF" THEN                                    03964000
            IF ^BLOCK_CLASS(SYT_CLASS(LOC2(RIGHTOP))) THEN                      03964500
            IF SYT_LOCK#(ARGPOINT) ^= SYT_LOCK#(LOC(RIGHTOP)) THEN              03965000
            CALL ERRORS(CLASS_FT,103,''||ARGNO);                                03965500
      END CHECK_ATTRIBUTES;  /*DR109044*/                                       03966000
                                                                                03966500
 /* INTERNAL ROUTINE TO MATCH ASSIGN PARAMETER OR NAME INITIAL */               03967000
 /* TEMPLATE WITH ARGUMENT                                     */
CHECK_ASSIGN_PARM:                                                              03967500
      PROCEDURE(TAG);                                                           03968000
         DECLARE (ARGLOC, ARRNESS, I, J, K) BIT(16), (TAG, SYMP) BIT(1);        03968500
         SYMP = SYMFORM(FORM(RIGHTOP));                                         03969000
         SYMP = SYMP | (NR_DEREF(RIGHTOP) & FORM(RIGHTOP)=NRTEMP); /*DR111331*/
         IF TAG THEN CALL CHECK_ATTRIBUTES;                 /*DR109044*/        03969500
         IF SYMP THEN ARGLOC = LOC2(RIGHTOP);                                   03970000
         ELSE ARGLOC = VAL(RIGHTOP);                                            03970500
         IF ARGTYPE ^= TYPE(RIGHTOP) THEN   /*TYPE MATCHING*/                   03971000
            IF CLASS=8 THEN CALL ERRORS(CLASS_DI,108);  /*DR109044*/
            ELSE CALL ERRORS(CLASS_FT,101,''||ARGNO);   /*DR109044-MOD*/        03971500
         ARRNESS = GETARRAY#(ARGPOINT);                                         03972000
         IF ARRNESS ^= COPY(RIGHTOP) THEN   /*ARRAYNESS MATCHING*/              03972500
            IF CLASS=8 THEN CALL ERRORS(CLASS_DI,110);  /*DR109044*/
            ELSE CALL ERRORS(CLASS_FD,100,''||ARGNO);   /*DR109044-MOD*/        03973000
         DO I = 1 TO ARRNESS;               /*ARRAY SIZE MATCHING*/             03973500
            IF SYMP THEN J = GETARRAYDIM(I, ARGLOC);                            03974000
            ELSE J = SF_RANGE(ARGLOC+I-1);                                      03974500
            K = GETARRAYDIM(I, ARGPOINT);                                       03975000
            IF K ^< 0 THEN                                                      03975500
               IF K ^= J THEN                                                   03976000
                 IF CLASS=8 THEN CALL ERRORS(CLASS_DI,110); /*DR109044*/
                 ELSE CALL ERRORS(CLASS_FD,102,''||ARGNO); /*DR109044-MOD*/     03976500
         END;                                                                   03977000
         IF ARGTYPE >= ANY_LABEL THEN RETURN;                                   03977500
         IF PACKTYPE(ARGTYPE) = VECMAT THEN  /*VECTOR/MATRIX MATCHING*/         03978000
            CALL CHECK_VM_ARG_DIMS;                                             03978500
         /*BIT LENGTH MATCHING*/
         ELSE IF PACKTYPE(ARGTYPE) = BITS THEN DO;       /*DR109044-MOD*/       03978510
            IF SIZE(RIGHTOP) ^= (SYT_DIMS(ARGPOINT)&"FF") THEN DO;              03978520
              IF CLASS=8 THEN CALL ERRORS(CLASS_DI,108); /*DR109044*/
              ELSE CALL ERRORS(CLASS_FT,101,''||ARGNO);  /*DR109044 MOD*/       03978530
            END;                                        /*DR109044*/
            ELSE IF SYMP & (SYT_FLAGS(ARGLOC) & DENSE_FLAG) ^= 0 THEN           03978540
              CALL ERRORS(CLASS_FT,109);                                        03978550
          END;                                                   /*DR109044*/
          /*IF NAME INITIALIZATION THEN CHECK FOR CHARACTER LENGTH MATCHING*/
          ELSE IF (CLASS=8) & (PACKTYPE(ARGTYPE))= CHAR THEN DO; /*DR109044*/
             IF (SIZE(RIGHTOP) ^= -1) &                          /*DR109044*/
                (SYT_DIMS(ARGPOINT) ^= -1) THEN DO;              /*DR109044*/
                IF SIZE(RIGHTOP)^=(SYT_DIMS(ARGPOINT)&"FF") THEN /*DR109044*/
                   CALL ERRORS(CLASS_DI,108);                    /*DR109044*/
                END;                                             /*DR109044*/
          END;                                                   /*DR109044*/
          /* GENERATE ADVISORY MESSAGES FOR CHARACTER ARGUMENTS  /*DR120228*/
          /* IN A NAME PSEUDO-FUNCTION IN A PROC/FUNC CALL.      /*DR120228*/
          ELSE IF (CLASS^=8) & (PACKTYPE(ARGTYPE)=CHAR) THEN DO; /*DR120228*/
             IF (SYT_FLAGS(ARGPOINT) & NAME_FLAG) ^= 0 THEN      /*DR120228*/
               CALL ERRORS(CLASS_YF,104);                        /*DR120228*/
          END;
      END CHECK_ASSIGN_PARM;                                                    03979000
                                                                                03979500
 /* ROUTINE TO MATCH STRUCTURE TEMPLATES FOR LEGALITY  */                       03980000
STRUCTURE_COMPARE:                                                              03980500
      PROCEDURE(A, B, ADV_WARN);                                  /*CR12214*/   03981000
         DECLARE (A, B, AX, BX, I) BIT(16), (ADV_WARN) BIT(1);    /*CR12214*/   03981500
         IF A = B THEN RETURN;                                                  03982000
         IF ^ADV_WARN THEN                                        /*CR12214*/
         IF ((SYT_FLAGS(A) | SYT_FLAGS(B)) & EVIL_FLAGS) = EVIL_FLAGS THEN      03982500
            CALL ERRORS(CLASS_DQ,100);                                          03983000
         AX = A;                                                                03983500
         BX = B;                                                                03984000
         DO FOREVER;                                                            03984500
            DO WHILE SYT_LINK1(AX) > 0;                                         03985000
               AX = SYT_LINK1(AX);                                              03985500
               BX = SYT_LINK1(BX);                                              03986000
               IF BX = 0 THEN GO TO STRUC_ERR;                                  03986500
            END;                                                                03987000
            IF SYT_LINK1(BX) ^= 0 THEN GO TO STRUC_ERR;                         03987500
            IF SYT_TYPE(AX) ^= SYT_TYPE(BX) THEN GO TO STRUC_ERR;               03988000
            IF SYT_DIMS(AX) ^= SYT_DIMS(BX) THEN GO TO STRUC_ERR;               03988500
            IF (SYT_FLAGS(AX)&SM_FLAGS) ^= (SYT_FLAGS(BX)&SM_FLAGS) THEN        03989000
               GO TO STRUC_ERR;                                                 03989500
            DO I = 0 TO EXT_ARRAY(SYT_ARRAY(AX));                               03990000
               IF EXT_ARRAY(SYT_ARRAY(AX)+I) ^= EXT_ARRAY(SYT_ARRAY(BX)+I) THEN 03990500
                  GO TO STRUC_ERR;                                              03991000
            END;                                                                03991500
            DO WHILE SYT_LINK2(AX) < 0;                                         03992000
               AX = -SYT_LINK2(AX);                                             03992500
               BX = -SYT_LINK2(BX);                                             03993000
               IF AX = A THEN DO;                                               03993500
                  IF BX ^= B THEN GO TO STRUC_ERR;                              03994000
                  RETURN;                                                       03994500
               END;                                                             03995000
               IF BX <= 0 THEN GO TO STRUC_ERR;                                 03995500
            END;                                                                03996000
            AX = SYT_LINK2(AX);                                                 03996500
            BX = SYT_LINK2(BX);                                                 03997000
            IF BX <= 0 THEN GO TO STRUC_ERR;                                    03997500
         END;                                                                   03998000
STRUC_ERR:                                                                      03998500
         IF ADV_WARN THEN MISMATCH = TRUE;                        /*CR12214*/
         ELSE CALL ERRORS(CLASS_DQ,101);                          /*CR12214*/   03999000
         ADV_WARN = FALSE;                                        /*CR12214*/
      END STRUCTURE_COMPARE;                                                    03999500
                                                                                04000000
 /* ROUTINE TO MATCH STRUCTURE PARAMETER TEMPLATE WITH ARGUMENT */              04000500
CHECK_STRUCTURE_PARM:                                                           04001000
      PROCEDURE(TAG);                                                           04001500
         DECLARE (TAG, STRUCTP) BIT(1), I BIT(16);                              04002000
         IF TAG THEN CALL CHECK_ATTRIBUTES;     /*DR109044*/                    04002500
         IF TYPE(RIGHTOP) ^= STRUCTURE THEN     /*TYPE MATCHING*/               04003000
            IF CLASS=8 THEN CALL ERRORS(CLASS_DI,108);  /*DR109044*/
            ELSE CALL ERRORS(CLASS_FT,101,''||ARGNO);   /*DR109044-MOD*/        04003500
         STRUCTP = SYT_ARRAY(ARGPOINT) ^= 0;                                    04004000
         IF STRUCTP ^= STRUCT(RIGHTOP) THEN /*STRUCTURE COPINESS MATCHING*/     04004500
            IF CLASS=8 THEN CALL ERRORS(CLASS_DI,110);  /*DR109044*/
            ELSE CALL ERRORS(CLASS_FD,103,''||ARGNO);   /*DR109044-MOD*/        04005000
         IF STRUCTP THEN DO;  /*STRUCTURE COPY SIZE MATCHING*/                  04005500
            IF SYMFORM(FORM(RIGHTOP)) THEN I = SYT_ARRAY(LOC(RIGHTOP));         04006000
            ELSE I = SF_RANGE(VAL(RIGHTOP));                                    04006500
            /*STRUCTURE COPY SIZE MATCHING*/
            IF SYT_ARRAY(ARGPOINT) ^< 0 THEN IF SYT_ARRAY(ARGPOINT) ^= I THEN   04007000
               IF CLASS=8 THEN CALL ERRORS(CLASS_DI,110);  /*DR109044*/
               ELSE CALL ERRORS(CLASS_FD,104,''||ARGNO);   /*DR109044-MOD*/     04007500
         END;                                                                   04008000
            CALL STRUCTURE_COMPARE(SYT_DIMS(ARGPOINT), DEL(RIGHTOP));           04008500
      END CHECK_STRUCTURE_PARM;                                                 04009000
                                                                                04009500
 /* ROUTINE TO MATCH NAME PARAMETER WITH TEMPLATE  */                           04010000
CHECK_NAME_PARM:                                                                04010500
      PROCEDURE(TAG);                                                           04011000
         DECLARE TAG BIT(1);                                                    04011500
         IF FORM(RIGHTOP) = LIT THEN DO;                                        04012000
            /* DR109043--LOOK FOR A LITERAL TABLE ENTRY, NOT AT */
            /* THE VALUE, AS THE CONDITION FOR THE DI101 ERROR. */
            IF LOC(RIGHTOP) ^= -1 THEN   /* DR109043 */                         04012500
               CALL ERRORS(CLASS_DI,101);                                       04013000
         END;                                                                   04013500
         ELSE IF ^SYMFORM(FORM(RIGHTOP)) &                                      04014000
         /* A REMOTE NAME REMOTE COULD HAVE BEEN PASSED, IN   CR12935*/         86431000
         /* WHICH CASE ITS FORM WILL BE NRTEMP.               CR12935*/         86432000
             (^(NR_DEREF(RIGHTOP) & (FORM(RIGHTOP)=NRTEMP)))/*CR12935*/         86433000
            THEN                                            /*CR12935*/         86434000
            CALL ERRORS(CLASS_FT,104,''||ARGNO);                                04014500
         ELSE IF ARGTYPE = STRUCTURE THEN CALL CHECK_STRUCTURE_PARM(TAG);       04015000
         ELSE DO;                                                               04015500
            IF SYT_TYPE(LOC2(RIGHTOP)) >= ANY_LABEL THEN                        04016000
               TYPE(RIGHTOP) = SYT_TYPE(LOC2(RIGHTOP));                         04016500
            CALL CHECK_ASSIGN_PARM(TAG);                                        04017000
         END;                                                                   04017500
      END CHECK_NAME_PARM;                                                      04018000
                                                                                04018500
 /* ROUTINE TO SET UP A BOOLEAN VALUE FROM A RELATIONAL EXPRESSION  */          04019000
SETUP_BOOLEAN:                                                                  04019500
      PROCEDURE(COND, FLAG);                                                    04020000
         DECLARE COND BIT(16), FLAG BIT(1);                                     04020500
         IF PACKTYPE(TYPE(LEFTOP)) THEN                                         04021000
            IF REG(LEFTOP) >= 0 THEN                                            04021500
            CALL DROP_REG(LEFTOP);                                              04022000
         FORM(LEFTOP) = 0;                                                      04022100
         IF FLAG THEN DO;                                                       04022500
            FIRSTLABEL, VAL(LEFTOP) = GETSTATNO;                                04023000
            SECONDLABEL,XVAL(LEFTOP) = GETSTATNO;                               04023500
         END;                                                                   04024000
         ELSE DO;                                                               04024500
            SECONDLABEL, VAL(LEFTOP) = GETSTATNO;                               04025000
            FIRSTLABEL, XVAL(LEFTOP) = GETSTATNO;                               04025500
         END;                                                                   04026000
         IF DOCOPY(CALL_LEVEL) > 0 THEN                                          4026010
            IF DOFORM(CALL_LEVEL) = 0 THEN                                       4026020
            IF FORM(DOINDEX(ADOPTR)) = VAC THEN                                  4026030
            CALL DROP_REG(DOINDEX(ADOPTR));                                      4026040
         CALL SAVE_REGS(RM, 3, TRUE);                                            4026100
         LAST_FLOW_BLK = CURCBLK;                                               04026200
         LAST_FLOW_CTR = CTR;                                                   04026300
         CALL EMITBFW(CONDITION(COND+FLAG), GETSTMTLBL(SECONDLABEL));           04026500
         CALL DOCLOSE;                                                          04027000
         CALL EMITBFW(ALWAYS, GETSTMTLBL(FIRSTLABEL));                          04027500
         CONST(LEFTOP) = GETSTATNO;                                             04028000
         LAST_TAG = SHR(TAG, 1);                                                04028500
         CALL SET_LABEL(CONST(LEFTOP), LAST_TAG | BOOL_COUNT = 0);              04029000
         BOOL_COUNT = BOOL_COUNT + 1;                                           04029500
         TYPE(LEFTOP) = LOGICAL;                                                04030000
      END SETUP_BOOLEAN;                                                        04031000
                                                                                04031500
 /* PROCEDURE TO DETERMINE IF THIS IS THE LAST NON-TERMINAL SUBSCRIPT */        04032000
LAST_SUBSCRIPT:                                                                 04032500
      PROCEDURE BIT(1);                                                         04033000
         IF SUBOP >= NUMOP THEN RETURN TRUE;                                    04033500
         IF DATATYPE(TYPE(ALCOP)) = BITS THEN                                   04034000
            IF TYPE_BITS(SUBOP+1) < 4 THEN                                      04034500
            RETURN TYPE_BITS(NUMOP) < 4;                                        04034600
         RETURN FALSE;                                                          04035000
      END LAST_SUBSCRIPT;                                                       04035500
                                                                                04036000
 /* ROUTINE TO GENERATE SPECIAL CASE CHECK FOR 2 DIMENSIONAL SUBS */            04036500
SUBSCRIPT2_MULT:                                                                04037000
      PROCEDURE(MULT);                                                          04037500
         DECLARE (MULT, I, R) BIT(16);                                          04038000
         IF LEFTOP = 0 THEN RETURN;                                             04038500
         IF MULT = 1 THEN RETURN;                                               04039000
      IF FORM(LEFTOP)^=SYM|FORM(RIGHTOP)^=SYM&FORM(RIGHTOP)^=LIT|INX(RIGHTOP)^=004039500
            THEN DO;                                                            04040000
            IF FORM(LEFTOP) ^= VAC THEN DO;                                     04040500
               TO_BE_MODIFIED = TRUE;                                           04041000
               CALL FORCE_ACCUMULATOR(LEFTOP, INTEGER, INDEX_REG);              04041500
            END;                                                                04042000
            CALL SUBSCRIPT_MULT(LEFTOP, MULT);                                  04042500
         END;                                                                   04043000
         ELSE DO;                                                               04043500
            IF FORM(RIGHTOP) = LIT THEN LOC(RIGHTOP) = -1;                      04044000
            INX(LEFTOP) = LOC(RIGHTOP);                                         04044500
            CONST(LEFTOP) = INX_CON(RIGHTOP);                                   04045000
            XVAL(LEFTOP) = MULT;                                                04045500
            IF LAST_SUBSCRIPT & INXMOD = 0 THEN                                 04046000
               INX_SHIFT(LEFTOP) = SHIFT(TYPE(ALCOP));                          04046100
            ELSE INX_SHIFT(LEFTOP) = 0;                                         04046500
            DO I = 0 TO INX_SHIFT(LEFTOP) ^= 0;                                 04047000
               R = SEARCH_INDEX2(LEFTOP);                                       04047500
               IF R >= 0 THEN DO;                                               04048000
                  REG(LEFTOP) = R;                                              04048500
                  TO_BE_MODIFIED = ^LAST_SUBSCRIPT | INXMOD ^= 0;               04049000
                  CALL UPDATE_INX_USAGE(LEFTOP);                                04049500
                  FORM(LEFTOP) = VAC;                                           04050000
                  LOC2(LEFTOP) = -1;                                             4050100
                  CONST(LEFTOP) = 0;                                            04050500
                  INX_MUL(LEFTOP) = 1;                                          04051000
                  CALL RETURN_STACK_ENTRY(RIGHTOP);                             04051500
                  RIGHTOP = 0;                                                  04052000
                  RETURN;                                                       04052500
               END;                                                             04053000
               INX_SHIFT(LEFTOP) = 0;                                           04053500
               TO_BE_MODIFIED = TRUE;                                           04054000
            END;                                                                04054500
            INX(LEFTOP), CONST(LEFTOP), CONST(RIGHTOP) = 0;                     04055000
            CALL FORCE_ACCUMULATOR(LEFTOP, INTEGER, INDEX_REG);                 04055500
            CALL SUBSCRIPT_MULT(LEFTOP, MULT);                                  04056000
            IF FORM(RIGHTOP) = SYM THEN                                         04056500
               CALL EXPRESSION(XADD);                                           04057000
            ELSE CALL RETURN_STACK_ENTRY(RIGHTOP);                              04057500
            IF BASE(LEFTOP) = 0 & BASE(RIGHTOP) = 0 THEN DO;                    04058000
               R = REG(LEFTOP);                                                 04058500
               CALL SET_USAGE(R, SYM2, LOC(LEFTOP), INX_CON(LEFTOP));            4059000
               R_VAR2(R) = LOC(RIGHTOP);                                        04061000
               R_XCON(R) = INX_CON(RIGHTOP);                                    04061500
               R_MULT(R) = MULT;                                                04062000
            END;                                                                04062500
            RIGHTOP = 0;                                                        04063000
         END;                                                                   04063500
      END SUBSCRIPT2_MULT;                                                      04064000
                                                                                04064500
 /* ROUTINE TO COMPLETE THE NECESSARY FUNCTIONS FOR PROPER INDEXING  */         04065000
SETUP_INX:                                                                      04065500
      PROCEDURE;                                                                04066000
         IF CLASS > 0 THEN RETURN;                                              04066500
         IF LEFTOP ^= 0 THEN DO;                                                04067000
            IF FORM(LEFTOP) ^= VAC THEN DO;                                     04067500
               IF INX_MUL(LEFTOP) = 1 THEN                                      04068000
                  CALL FORCE_ACCUMULATOR(LEFTOP, INTEGER, INDEX_REG);           04068500
               ELSE DO;                                                         04069000
                  RIGHTOP = GET_INTEGER_LITERAL(0);                             04069500
                  CALL SUBSCRIPT2_MULT(INX_MUL(LEFTOP));                        04070000
                  CALL RETURN_STACK_ENTRY(RIGHTOP);                             04070500
               END;                                                             04071000
            END;                                                                04071500
            IF REG(LEFTOP) = 0 THEN                                             04072000
               CALL NEW_REG(LEFTOP, 1);                                         04072500
            CALL FIX_TERM_INX(ALCOP, LEFTOP);                                    4073000
         END;                                                                   04074500
         CALL FIX_STRUCT_INX(LEFTOP, ALCOP);                                     4075000
         TMP = BIGHTS(TYPE(ALCOP));                                             04079500
         INX_CON(ALCOP) = INX_CON(ALCOP) * TMP + STRUCT_CON(ALCOP);             04080000
         STRUCT_CON(ALCOP) = 0;                                                 04080500
         STRUCT_INX(ALCOP) = 2;                                                 04081000
         SIMPLE_AIA_ADJUST=TRUE;   /*DR109019*/
         IF ^DECLMODE THEN                                                      04081500
            CALL SUBSCRIPT_RANGE_CHECK(ALCOP);                                  04082000
         SIMPLE_AIA_ADJUST=FALSE;  /*DR109019*/
      END SETUP_INX;                                                            04082500
                                                                                04083000
 /* ROUTINE TO SET UP # SIZE FOR CHARACTER TERMINAL SUBS */                     04083500
GET_CSIZ:                                                                       04084000
      PROCEDURE(MARK) BIT(16);                                                  04084500
         DECLARE (MARK, PTR) BIT(16);                                           04085000
         IF MARK = 0 THEN                                                       04085500
            PTR = GET_STACK_ENTRY;                                              04086000
         ELSE DO;                                                               04086500
            SUBOP = SUBOP + 1;                                                  04087000
            PTR = GET_OPERAND(SUBOP, 0, BY_NAME_FALSE, 1); /*CR13616*/          04087500
         END;                                                                   04088000
         INX_MUL(PTR) = MARK + 2;                                               04088500
         RETURN PTR;                                                            04089000
      END GET_CSIZ;                                                             04089500
                                                                                04090000
 /* ROUTINE TO PROCESS # ARRAY SUBSCRIPTS  */                                   04090500
GET_ASIZ:                                                                       04091000
      PROCEDURE(MARK) BIT(16);                                                  04091500
         DECLARE (MARK, PTR, OP) BIT(16);                                       04092000
         PTR = FORCE_ARRAY_SIZE(-1, -LOC(ALCOP));                               04092500
         IF MARK > 0 THEN DO;                                                   04093000
            SUBOP = SUBOP + 1;                                                  04093500
            OP = GET_OPERAND(SUBOP, 0, BY_NAME_FALSE, 1); /*CR13616*/           04094000
            OPTYPE = TYPE(OP);                                                  04094500
            PTR = DO_EXPRESSION(SUM+MARK-1, PTR, OP);                           04095000
         END;                                                                   04095500
         RETURN PTR;                                                            04096000
      END GET_ASIZ;                                                             04096500
                                                                                04097000
 /* ROUTINE TO PICK UP NEXT SUBSCRIPT GROUP  */                                 04097500
GET_SUBSCRIPT:                                                                  04098000
      PROCEDURE;                                                                04098500
         LITTYPE = INTEGER;                                                     04099000
         RIGHTOP = GET_OPERAND(SUBOP);                                          04099500
         IF TAG1 = CSIZ THEN RIGHTOP = GET_CSIZ(OP1);                           04100000
         ELSE IF TAG1 = ASIZ THEN RIGHTOP = GET_ASIZ(OP1);                      04100500
         IF TAG2 THEN IF TAG3 ^= 5 THEN DO;  /* NEED EXTENSION */                4101000
            SUBOP = SUBOP + 1;                                                  04101500
            EXTOP = GET_OPERAND(SUBOP);                                         04102000
            IF TAG1 = CSIZ THEN EXTOP = GET_CSIZ(OP1);                          04102500
            ELSE IF TAG1 = ASIZ THEN EXTOP = GET_ASIZ(OP1);                     04103000
         END;                                                                   04103500
      END GET_SUBSCRIPT;                                                        04104000
                                                                                04104500
 /* ROUTINE TO SET UP BIT TERMINAL INDEX SHIFT */                               04105000
SET_BINDEX:                                                                     04105500
      PROCEDURE(OP, SZ, OLDOP) BIT(16);                                         04106000
         DECLARE (OP, OLDOP) BIT(16), SZ FIXED;                                 04106500
         IF FORM(OP) = LIT THEN DO;                                             04107000
            VAL(OP) = SZ - VAL(OP);                                             04107500
            IF VAL(OP) < 0 THEN CALL ERRORS(CLASS_SR,100);                      04108000
            IF OLDOP > 0 THEN DO CASE FORM(OLDOP) ^= LIT;                       04108500
               DO;  /* LIT  */                                                  04109000
                  VAL(OP) = VAL(OP) + VAL(OLDOP);                               04109500
                  CALL RETURN_STACK_ENTRY(OLDOP);                               04110000
               END;                                                             04110500
               DO;                                                              04111000
                  CONST(OLDOP) = CONST(OLDOP) + VAL(OP);                        04111500
                  CALL RETURN_STACK_ENTRY(OP);                                  04112000
                  OP = OLDOP;                                                   04112500
               END;                                                             04113000
            END;  /* OLDOP  */                                                  04113500
         END;                                                                   04114000
         ELSE DO;                                                               04114500
            SZ = SZ - CONST(OP);                                                04115000
            CONST(OP) = 0;                                                      04115500
            TO_BE_MODIFIED = TRUE;                                              04116000
            CALL FORCE_ACCUMULATOR(OP, INTEGER, INDEX_REG);                     04116500
            CALL EMITRR(LCR, REG(OP), REG(OP));                                 04117000
            CONST(OP) = SZ;                                                     04117500
            CALL UNRECOGNIZABLE(REG(OP));                                       04118000
            IF OLDOP > 0 THEN DO CASE FORM(OLDOP) ^= LIT;                       04118500
               DO;  /* LIT  */                                                  04119000
                  CONST(OP) = CONST(OP) + VAL(OLDOP);                           04119500
                  CALL RETURN_STACK_ENTRY(OLDOP);                               04120000
               END;                                                             04120500
               DO;                                                              04121000
                  CONST(OP) = CONST(OP) + CONST(OLDOP);                         04121500
                  CALL ARITH_BY_MODE(SUM, OP, OLDOP, TYPE(OLDOP));               4122000
                  CALL RETURN_STACK_ENTRY(OLDOP);                               04123000
               END;                                                             04123500
            END;  /* OLDOP  */                                                  04124000
         END;                                                                   04124500
         CALL INCORPORATE(OP);                                                  04125000
         OLDOP = 0;                                                             04125500
         RETURN OP;                                                             04126000
      END SET_BINDEX;                                                           04126500
                                                                                04127000
 /* ROUTINE TO SET UP BIT TERMINAL SUBSCRIPTING  */                             04127500
BIT_SUBSCRIPT:                                                                  04128000
      PROCEDURE;                                                                04128500
         DO CASE TAG3;                                                          04129000
            ;  /* TSTAR */                                                      04129500
            DO;  /* TINDX  */                                                   04130000
               COLUMN(ALCOP) = SET_BINDEX(RIGHTOP, SIZE(ALCOP), COLUMN(ALCOP)); 04130500
               SIZE(ALCOP) = 1;                                                 04131000
            END;                                                                04131500
            DO;  /* TTSUB  */                                                   04132000
               TMP = SIZE(ALCOP);                                               04132500
               SIZE(ALCOP) = VAL(EXTOP) - VAL(RIGHTOP) + 1;                     04133000
               COLUMN(ALCOP) = SET_BINDEX(EXTOP, TMP, COLUMN(ALCOP));           04133500
               CALL RETURN_STACK_ENTRY(RIGHTOP);                                04134000
            END;                                                                04134500
            DO;  /* TASUB  */                                                   04135000
               COLUMN(ALCOP) = SET_BINDEX(EXTOP, SIZE(ALCOP) - VAL(RIGHTOP) + 1,04135500
                  COLUMN(ALCOP));                                               04136000
               SIZE(ALCOP) = VAL(RIGHTOP);                                      04136500
               CALL RETURN_STACK_ENTRY(RIGHTOP);                                04137000
            END;                                                                04137500
         END;  /* CASE TAG3  */                                                 04138000
      END BIT_SUBSCRIPT;                                                        04138500
                                                                                04139000
 /* ROUTINE TO SET UP CHARACTER TERMINAL INDEX STACKS */                        04139500
SET_CINDEX:                                                                     04140000
      PROCEDURE(OP, SELECT) BIT(16);                                            04140500
         DECLARE (OP, SELECT, PTR) BIT(16);                                     04141000
         TARGET_REGISTER = FIXARG1 + (SELECT^=0);                               04141500
         IF FORM(OP) ^= LIT | INX_MUL(OP) > 1 THEN DO;                          04142000
            IF INX_MUL(OP) > 1 THEN DO;                                         04142100
               IF FORM(ALCOP) = LIT THEN                                        04142200
                  PTR = GET_INTEGER_LITERAL(LENGTH(DESC(VAL(ALCOP))));          04142300
               ELSE DO;                                                         04142400
                  CALL FINDAC(INDEX_REG);                                       04143500
                  CALL GUARANTEE_ADDRESSABLE(ALCOP, LH);                        04144000
                  CALL EMITOP(LH, TARGET_REGISTER, ALCOP);                      04144500
                  CALL EMITP(NHI, TARGET_REGISTER, 0, 0, "FF");                 04145000
                  PTR = GET_VAC(TARGET_REGISTER);                               04148000
               END;                                                             04148500
               IF INX_MUL(OP) > 2 THEN DO;                                      04148600
                  OPTYPE = INTEGER;                                             04149000
                  TARGET_REGISTER = -1;                                         04149500
                  PTR = DO_EXPRESSION(SUM+INX_MUL(OP)-3, PTR, OP);              04150000
               END;                                                             04150500
               ELSE CALL RETURN_STACK_ENTRY(OP);                                04151000
               OP = PTR;                                                        04151500
            END;                                                                04152000
            ELSE CALL FORCE_ACCUMULATOR(OP, INTEGER);                           04152500
         END;                                                                   04153000
         IF SELECT = 2 THEN DO;                                                 04153500
            PTR = COPY_STACK_ENTRY(COLUMN(ALCOP), 4);                           04154000
            OPTYPE = INTEGER;                                                   04154500
            OP = DO_EXPRESSION(SUM, OP, PTR);                                   04155000
         END;                                                                   04155500
         TARGET_REGISTER = -1;                                                  04156000
         SELECT = 0;                                                            04156500
         RETURN OP;                                                             04157000
      END SET_CINDEX;                                                           04157500
                                                                                04158000
 /* ROUTINE TO SET UP CHARACTER TERMINAL SUBSCRIPTING  */                       04158500
CHAR_SUBSCRIPT:                                                                 04159000
      PROCEDURE;                                                                04159500
         DO CASE TAG3;                                                          04160000
            ;  /* TSTAR  */                                                     04160500
            DO;  /* TINDX  */                                                   04161000
               COLUMN(ALCOP) = SET_CINDEX(RIGHTOP);                             04161500
               DEL(ALCOP) = 0;                                                  04162000
               SIZE(ALCOP) = 1;                                                 04162500
            END;                                                                04163000
            DO;  /* TTSUB  */                                                   04163500
               IF FORM(RIGHTOP) = LIT & FORM(EXTOP) = LIT &                     04164000
                  (INX_MUL(RIGHTOP) | INX_MUL(EXTOP)) = 1 THEN                  04164500
                  SIZE(ALCOP) = VAL(EXTOP) - VAL(RIGHTOP) + 1;                  04165000
               COLUMN(ALCOP) = SET_CINDEX(RIGHTOP);                             04165500
               DEL(ALCOP) = SET_CINDEX(EXTOP, 1);                               04166000
            END;                                                                04166500
            DO;  /* TASUB  */                                                   04167000
               IF FORM(RIGHTOP) = LIT THEN                                      04167500
                  SIZE(ALCOP) = VAL(RIGHTOP);                                   04168000
               EXTOP, COLUMN(ALCOP) = SET_CINDEX(EXTOP);                        04168500
               IF FORM(RIGHTOP) = LIT THEN DO;                                  04169000
                  IF FORM(EXTOP) = LIT THEN DO;                                 04169500
                     VAL(RIGHTOP) = VAL(EXTOP) + VAL(RIGHTOP) - 1;              04170000
                     TAG3 = TAG3 - 1;                                           04170500
                  END;                                                          04171000
                  ELSE VAL(RIGHTOP) = VAL(RIGHTOP) - 1;                         04171500
               END;                                                             04172000
               ELSE CONST(RIGHTOP) = CONST(RIGHTOP) - 1;                        04172500
               DEL(ALCOP) = SET_CINDEX(RIGHTOP, TAG3-1);                        04173000
            END;                                                                04173500
         END;  /* CASE TAG3  */                                                 04174000
      END CHAR_SUBSCRIPT;                                                       04174500
                                                                                04175000
 /* ROUTINE TO SET UP CHARACTER ARRAY INDEX */                                  04175500
SET_CHAR_INX:                                                                   04176000
      PROCEDURE;                                                                04176500
         IF CLASS > 0 THEN RETURN;                                              04177000
         VALMUL = SUBLIMIT(SUB#-1);                                             04177500
         IF SUB# > 1 THEN DO;                                                   04178000
            IF LEFTOP ^= 0 THEN IF FORM(LEFTOP) ^= VAC THEN DO;                 04178500
               TO_BE_MODIFIED = TRUE;                                           04179000
               CALL FORCE_ACCUMULATOR(LEFTOP, INTEGER, INDEX_REG);              04179500
            END;                                                                04180000
            IF VALMUL < 0 & INX_CON(ALCOP) ^= 0 THEN DO;                        04180500
               IF LEFTOP = 0 THEN DO;                                           04181000
                  LEFTOP = GET_INTEGER_LITERAL(INX_CON(ALCOP));                 04181500
                  TO_BE_MODIFIED = TRUE;                                        04182000
                  CALL FORCE_ACCUMULATOR(LEFTOP);                               04182500
                  CALL SUBSCRIPT_MULT(LEFTOP, INX_MUL(LEFTOP)); /*DR111386*/    04187500
               END;                                                             04183000
               ELSE DO;                                                         04183500
                  CONST(LEFTOP) = CONST(LEFTOP) + INX_CON(ALCOP);               04184000
                  CALL SUBSCRIPT_MULT(LEFTOP, INX_MUL(LEFTOP)); /*DR111386*/    04187500
                  CALL INCORPORATE(LEFTOP);                                     04184500
               END;                                                             04185000
               INX_CON(ALCOP) = 0;                                              04185500
            END;                                                                04186000
            ELSE DO;                                            /*DR111386*/
               INX_CON(ALCOP) = INX_CON(ALCOP) * VALMUL;                        04186500
               IF VALMUL < 0 THEN                                               04187000
                  CALL SUBSCRIPT_MULT(LEFTOP, INX_MUL(LEFTOP));                 04187500
            END;                                                /*DR111386*/
            CALL SUBSCRIPT_MULT(LEFTOP, INX_MUL(LEFTOP) * VALMUL);              04188000
         END;                                                                   04188500
         CALL SETUP_INX;                                                        04189000
      END SET_CHAR_INX;                                                         04189500
                                                                                04190000
 /* ROUTINE TO SET UP SINGLE-VALUED SUBSCRIPT CSES */                           04190010
SETUP_DSUB_CSE:                                                                 04190020
      PROCEDURE(OP);                                                            04190030
         DECLARE OP BIT(16);                                                    04190040
         IF SEARCH_REGS(OP) >= 0 THEN                                           04190050
            CALL FORCE_ACCUMULATOR(OP);                                         04190060
         ELSE DO;                                                               04190070
            CALL GUARANTEE_ADDRESSABLE(OP, MAKE_INST(LOAD, TYPE(OP), RX));      04190080
            IF CHECK_REMOTE(OP) | FORM(OP) = CSYM | INX(OP) ^= 0 THEN           04190090
               CALL FORCE_ACCUMULATOR(OP);                                      04190100
            ELSE DO CASE PACKTYPE(TYPE(OP));                                    04190110
               ;  /* VECTOR MATRIX */                                           04190120
               IF COLUMN(OP) > 0 | DEL(OP) ^= 0 THEN /* BITS */                 04190130
                  CALL FORCE_ACCUMULATOR(OP);                                   04190140
               ;  /* CHARACTER */                                               04190150
               IF CONST(OP) ^= 0 THEN /* INTEGER/SCALAR */                      04190160
                  CALL FORCE_ACCUMULATOR(OP);                                   04190170
            END;  /* CASE PACKTYPE */                                           04190180
         END;                                                                   04190190
      END SETUP_DSUB_CSE;                                                       04190200
 /* PROCEDURE TO HANDLE ARRAY AND TERMINAL SUBSCRIPTING */                      04190500
DO_DSUB:                                                                        04191000
      PROCEDURE(ASSIGN_CONTEXT);                                                 4191500
         DECLARE ASSIGN_CONTEXT BIT(1);                                          4191600
         IF DATATYPE(TYPE(ALCOP))=MATRIX THEN TERMFLAG = 1;                     04192000
         ELSE TERMFLAG = 0;                                                     04192500
         SUB#, LEFTOP = 0;                                                      04193000
         STACK# = COPY(ALCOP) + 1;                                              04193500
         DOPTR# = (STRUCT_INX(ALCOP) & 1) + DOPTR(CALL_LEVEL);                  04194000
         DO SUBOP = 2 TO NUMOP;                                                 04194500
            SUB# = SUB# + 1;                                                    04195000
            IF TYPE_BITS(SUBOP) < 4 THEN                                        04195500
               IF TYPE(ALCOP) = CHAR THEN                                       04196000
               CALL SET_CHAR_INX;                                               04196500
            CALL GET_SUBSCRIPT;                                                 04197000
            INXMOD = 0;                                                         04197500
            DO CASE TAG3;                                                       04198000
               DO;  /* TSTAR  */                                                04198500
                  DO CASE PACKTYPE(TYPE(ALCOP));                                04199000
                     DO;  /* VECTOR-MATRIX  */                                  04199500
                        RIGHTOP = GET_INTEGER_LITERAL(0);                       04200000
                        VALMOD = 0;                                             04200500
                        DO CASE TERMFLAG;                                       04201000
                           VALMUL = COLUMN(ALCOP);                              04201500
                           VALMUL = ROW(ALCOP);                                 04202000
                        END;                                                    04202500
                        TERMFLAG = 0;                                           04203000
                        GO TO SET_AINDX;                                        04203500
                     END;                                                       04204000
                     ;  /* BITS  */                                             04204500
                     ;  /* CHARACTERS  */                                       04205000
                     ;                                                          04205500
                  END;                                                          04206000
               END;                                                             04206500
               DO;  /* TINDX  */                                                04207000
                  DO CASE PACKTYPE(TYPE(ALCOP));                                04207500
                     DO;  /* VECTOR - MATRIX  */                                04208000
                        DO CASE TERMFLAG;                                       04208500
                           DO;  /* VECTOR OR SECOND PARTITION  */               04209000
                              DEL(ALCOP) = COLUMN(ALCOP);                       04209500
                              VALMOD = TAG ^= SCALAR;                           04210000
                              VALMUL = COLUMN(ALCOP);                           04210500
                              COLUMN(ALCOP) = 1;                                04211000
                           END;                                                 04211500
                           DO;  /* FIRST TIME FOR MATRIX  */                    04212000
                              VALMOD = 1;  /* MUST BE DONE AT RUN TIME  */      04212500
                              VALMUL = ROW(ALCOP);                              04213000
                              ROW(ALCOP) = 1;                                   04213500
                           END;                                                 04214000
                        END;                                                    04214500
                        TERMFLAG = 0;                                           04215000
                        GO TO SET_AINDX;                                        04215500
                     END;                                                       04216000
                     CALL BIT_SUBSCRIPT;                                        04216500
                     CALL CHAR_SUBSCRIPT;                                       04217000
                     ;  /* SHOULDN'T GET HERE  */                               04217500
                  END;  /* CASE PACKTYPE  */                                    04218000
               END;                                                             04218500
               DO;  /* TTSUB  */                                                04219000
                  DO CASE PACKTYPE(TYPE(ALCOP));                                04219500
                     DO;  /* VECTOR-MATRIX  */                                  04220000
                        VALMOD = 1;                                             04220500
                        DO CASE TERMFLAG;                                       04221000
                           DO;                                                  04221500
                              VALMUL = COLUMN(ALCOP);                           04222000
                              COLUMN(ALCOP)=VAL(EXTOP)-VAL(RIGHTOP)+1;          04222500
                              DEL(ALCOP) = VALMUL - COLUMN(ALCOP);              04223000
                           END;                                                 04223500
                           DO;                                                  04224000
                              VALMUL = ROW(ALCOP);                              04224500
                              ROW(ALCOP)=VAL(EXTOP)-VAL(RIGHTOP)+1;             04225000
                           END;                                                 04225500
                        END;                                                    04226000
                        TERMFLAG = 0;                                           04226500
                        CALL RETURN_STACK_ENTRY(EXTOP);                         04227000
                        GO TO SET_AINDX;                                        04227500
                     END;                                                       04228000
                     CALL BIT_SUBSCRIPT;                                        04228500
                     CALL CHAR_SUBSCRIPT;                                       04229000
                     ;                                                          04229500
                  END;  /* CASE PACKTYPE  */                                    04230000
               END;                                                             04230500
               DO;  /* TASUB  */                                                04231000
                  DO CASE PACKTYPE(TYPE(ALCOP));                                04231500
                     DO;  /* VECTOR-MATRIX  */                                  04232000
                        VALMOD = 1;                                             04232500
                        DO CASE TERMFLAG;                                       04233000
                           DO;                                                  04233500
                              VALMUL = COLUMN(ALCOP);                           04234000
                              DEL(ALCOP) = COLUMN(ALCOP)-VAL(RIGHTOP);          04234500
                              COLUMN(ALCOP) = VAL(RIGHTOP);                     04235000
                           END;                                                 04235500
                           DO;                                                  04236000
                              VALMUL = ROW(ALCOP);                              04236500
                              ROW(ALCOP) = VAL(RIGHTOP);                        04237000
                           END;                                                 04237500
                        END;                                                    04238000
                        TERMFLAG = 0;                                           04238500
                        CALL RETURN_STACK_ENTRY(RIGHTOP);                       04239000
                        RIGHTOP = EXTOP;                                        04239500
                        GO TO SET_AINDX;                                        04240000
                     END;                                                       04240500
                     CALL BIT_SUBSCRIPT;                                        04241000
                     CALL CHAR_SUBSCRIPT;                                       04241500
                     ;                                                          04242000
                  END;  /* CASE PACKTYPE   */                                   04242500
               END;                                                             04243000
               DO;  /* ASTAR  */                                                04243500
                  DOPTR# = DOPTR# + 1;                                          04244000
                  INXMOD = DOINDEX(DOPTR#);                                     04244500
                  RIGHTOP = GET_INTEGER_LITERAL(0);                             04245000
                  VALMOD = 0;                                                   04245500
                  VALMUL = SUBLIMIT(SUB#-1);                                    04246000
                  GO TO SET_AINDX;                                              04246500
               END;                                                             04247000
               DO;  /* AINDX  */                                                04247500
                  IF TAG2 THEN                                                   4247550
                     DO;  /* SCE */                                              4247600
                     SUB# = SUB# - 1;                                            4247650
                     VALMUL = /*SUBLIMIT(SUB#-1)*/1;                             4247700
                     VALMOD = 0;                                                 4247750
                  END;                                                           4247800
                  ELSE                                                           4247850
                     DO;  /* NORMAL */                                           4247900
                     VALMUL = SUBLIMIT(SUB#-1);                                 04248000
                     VALMOD = 0;  /* -1 INCLUDED IN CONSTANT TERM  */           04248500
                     COPY(ALCOP) = COPY(ALCOP) - 1;                             04249000
                     SUBRANGE(SUB#) = 1;                                        04249500
                  END;                                                           4249600
SET_AINDX:                                                                      04250000
                  IF NAME_SUB THEN INXMOD = 0;                                  04250500
                  IF INXMOD > 0 THEN ARRAY_FLAG = TRUE;                          4250600
                  IF FORM(RIGHTOP) = LIT THEN DO;                               04251000
                     IF SUB# = 1 THEN INX_CON(ALCOP) = VAL(RIGHTOP) -           04251500
                        VALMOD + INX_CON(ALCOP);                                 4252000
                     ELSE DO;                                                   04252500
                        INX_CON(ALCOP) = INX_CON(ALCOP) * VALMUL +              04253000
                           VAL(RIGHTOP) - VALMOD;                               04253500
                        INX_MUL(LEFTOP) = INX_MUL(LEFTOP) * VALMUL;             04254000
                        IF INXMOD ^= 0 THEN                                     04254500
                           CALL SUBSCRIPT2_MULT(INX_MUL(LEFTOP));               04255000
                     END;                                                       04255500
                     CALL RETURN_STACK_ENTRY(RIGHTOP);                          04256000
                  END;                                                          04256500
                  ELSE DO;                                                      04257000
                     OPTYPE = TYPE(RIGHTOP);                                    04257500
                     IF SUB# = 1 THEN INX_CON(ALCOP) = CONST(RIGHTOP) -         04258000
                        VALMOD + INX_CON(ALCOP);                                 4258500
                     ELSE DO;                                                   04259000
                        INX_CON(ALCOP) = INX_CON(ALCOP) * VALMUL +              04259500
                           CONST(RIGHTOP) - VALMOD;                             04260000
                        CALL SUBSCRIPT2_MULT(INX_MUL(LEFTOP) * VALMUL);         04260500
                     END;                                                       04261000
                     CONST(RIGHTOP) = 0;                                        04261500
                     IF LEFTOP = 0 THEN DO;                                     04262000
                        IF LAST_SUBSCRIPT & INXMOD = 0                          04262500
                           & TYPE(RIGHTOP) = INTEGER THEN                       04262510
                           CALL FORCE_ACCUMULATOR(RIGHTOP, INTEGER,             04263000
                           INDEX_REG, SHIFT(TYPE(ALCOP)));                      04263500
                        ELSE IF FORM(RIGHTOP) ^= SYM | INX(RIGHTOP) ^= 0        04264000
                           | INXMOD ^= 0 THEN DO;                               04264500
                           TO_BE_MODIFIED=TRUE;                                 04265000
                           CALL FORCE_ACCUMULATOR(RIGHTOP, INTEGER,             04265500
                              INDEX_REG);                                       04266000
                        END;                                                    04266500
                        LEFTOP = RIGHTOP;                                       04267000
                     END;                                                       04267500
                     ELSE IF RIGHTOP > 0 THEN CALL EXPRESSION(XADD);            04268000
                     IF FORM(LEFTOP) = VAC THEN                                 04268500
                        IF TYPE(LEFTOP) = DINTEGER THEN DO;                     04269000
                        CALL EMITP(SLL, REG(LEFTOP), 0, SHCOUNT, 16);           04269500
                        R_TYPE(REG(LEFTOP)), TYPE(LEFTOP) = INTEGER;            04270000
                     END;                                                       04270500
                  END;                                                          04271000
                  TMP = 0;                                                      04271500
                  IF ^LAST_SUBSCRIPT THEN TO_BE_MODIFIED = TRUE;                04272000
                  ELSE TMP = SHIFT(TYPE(ALCOP));                                04272500
                  LEFTOP = ARRAY_INDEX_MOD(LEFTOP, INXMOD, TMP);                04273000
               END;                                                             04273500
               DO;  /* ATSUB  */                                                04274000
                  DOPTR# = DOPTR# + 1;                                          04274500
                  SUBRANGE(SUB#) = VAL(EXTOP) - VAL(RIGHTOP) + 1;               04275000
                  IF SUBRANGE(SUB#) ^= VAL(DORANGE(DOPTR#))                     04275500
                     THEN CALL ERRORS(CLASS_EA,100);                            04276000
                  CALL RETURN_STACK_ENTRY(EXTOP);                               04276500
                  VALMOD = 1;                                                   04277000
                  VALMUL = SUBLIMIT(SUB#-1);                                    04277500
                  INXMOD = DOINDEX(DOPTR#);                                     04278000
                  GO TO SET_AINDX;                                              04278500
               END;                                                             04279000
               DO;  /* AASUB  */                                                04279500
                  DOPTR# = DOPTR# + 1;                                          04280000
                  SUBRANGE(SUB#) = VAL(RIGHTOP);                                04280500
                  IF VAL(RIGHTOP) ^= VAL(DORANGE(DOPTR#)) THEN                  04281000
                     CALL ERRORS(CLASS_EA,100);                                 04281500
                  CALL RETURN_STACK_ENTRY(RIGHTOP);                             04282000
                  RIGHTOP = EXTOP;                                              04282500
                  VALMOD = 1;                                                   04283000
                  VALMUL = SUBLIMIT(SUB#-1);                                    04283500
                  INXMOD = DOINDEX(DOPTR#);                                     04284000
                  GO TO SET_AINDX;                                              04284500
               END;                                                             04285000
            END;  /* CASE TAG3  */                                              04285500
            IF SUBSCRIPT_TRACE THEN                                             04286000
               OUTPUT='INX_CON='||INX_CON(ALCOP)||', SUB#='||SUB#;              04286500
         END;  /* DO WHILE  */                                                  04287000
         STACK# = 0;                                                            04287500
         IF TYPE(ALCOP) ^= CHAR THEN                                            04288000
            CALL SETUP_INX;                                                     04288500
         IF ^NAME_SUB THEN IF COPY(ALCOP) > DOCOPY(CALL_LEVEL) THEN             04289000
            CALL ERRORS(CLASS_EA,101);                                          04289500
         COPY(ALCOP), STRUCT(ALCOP) = 0;                                        04290000
         IF SUBSCRIPT_TRACE THEN OUTPUT='INX_CON='||INX_CON(ALCOP)||            04290500
            ', SIZE/ROW='||SIZE(ALCOP)||', COLUMN='||COLUMN(ALCOP);             04291000
         IF PACKTYPE(TYPE(ALCOP))=VECMAT THEN DO;                               04291500
            TMP = BIGHTS(TYPE(ALCOP));                                          04292000
            DEL(ALCOP) = DEL(ALCOP) * TMP;                                      04292500
            TYPE(ALCOP) = TYPE(ALCOP)&8 | TAG;                                  04293000
         END;                                                                   04293500
         IF PACKTYPE(TAG) = VECMAT THEN DO;                                     04294000
            IF TAG = VECTOR THEN DO;                                            04294500
               IF COLUMN(ALCOP) = 1 THEN DO;                                    04295000
                  COLUMN(ALCOP) = ROW(ALCOP);                                   04295500
                  ROW(ALCOP) = 1;                                               04296000
               END;                                                             04296500
               ELSE DEL(ALCOP) = 0;                                             04297000
            END;                                                                04297500
         END;                                                                   04298000
         ELSE IF PACKTYPE(TAG)=INTSCA THEN DO;       /*DR109059*/               04298500
            CALL RETURN_COLUMN_STACK(ALCOP);         /*DR109059*/
            COLUMN(ALCOP),DEL(ALCOP)=0;              /*DR109059*/               04298500
         END;                                        /*DR109059*/
         ASNCTR = -1;                                                            4299000
         IF CSE_FLAG THEN                                                        4299010
            DO CASE PACKTYPE(TYPE(ALCOP));                                      04299500
            IF CHECK_REMOTE(ALCOP) | DEL(ALCOP) > 0 THEN                        04300000
               ALCOP = VECMAT_CONVERT(ALCOP);  /* VECTOR/MATRIX */              04300500
   /*-------------------- DANNY #DPARM --- #D PASS-BY-REF TO RTL ----*/         83890010
   /* #D AGGREGATE DATA MUST BE COPIED TO THE STACK.                 */         83900099
            ELSE IF DATA_REMOTE & (CSECT_TYPE(LOC(ALCOP),ALCOP)=LOCAL#D)        83910099
               THEN ALCOP = VECMAT_CONVERT(ALCOP);                              83920099
   /*----------------------------------------------------------------*/         83930018
            CALL SETUP_DSUB_CSE(ALCOP);  /* BITS  */                            04301000
            IF CHECK_REMOTE(ALCOP) | COLUMN(ALCOP) > 0 THEN                     04301500
               ALCOP = CHAR_CONVERT(ALCOP);  /* CHARACTER */                    04302000
   /*-------------------- DANNY #DPARM --- #D PASS-BY-REF TO RTL ----*/         83980010
   /* #D AGGREGATE DATA MUST BE COPIED TO THE STACK.                 */         83990099
            ELSE IF DATA_REMOTE & (CSECT_TYPE(LOC(ALCOP),ALCOP)=LOCAL#D)        84000099
               THEN ALCOP = CHAR_CONVERT(ALCOP);                                84010099
   /*----------------------------------------------------------------*/         84020018
            CALL SETUP_DSUB_CSE(ALCOP);  /* INTEGER/SCALAR  */                  04302500
         END;                                                                   04303000
         ELSE IF VDLP_DETECTED THEN IF ^ASSIGN_CONTEXT THEN                      4303010
            IF PACKTYPE(TYPE(ALCOP)) = VECMAT THEN                               4303020
            IF CHECK_REMOTE(ALCOP) | DEL(ALCOP) > 0 THEN                         4303030
            IF VECMAT_ASN(CTR) >= 0 THEN                                         4303040
            ASNCTR = SKIP_NOP(CTR);                                             04303050
         ELSE ALCOP = VECMAT_CONVERT(ALCOP);                                     4303060
         NEXT_USE(0) = NEXT_USE(ALCOP);                                         04303070
         IND_STACK(ALCOP).I_DSUBBED = TRUE;   /*** DR54572 ***/                 04303285
         CALL SETUP_VAC(ALCOP);                                                 04303500
         IF ASNCTR >= 0 THEN DO;                                                 4303510
            CTR = ASNCTR;                                                        4303520
            NUMOP = POPNUM(CTR);                                                 4303530
         END;                                                                    4303540
         IF ASSIGN_CONTEXT THEN                                                 04303550
            IF NEXT_USE(0) > NEXT_USE(ALCOP) THEN                               04303560
            INX_MUL(ALCOP) = NEXT_USE(0);                                       04303570
         ASSIGN_CONTEXT = FALSE;                                                04303580
      END DO_DSUB;                                                              04304000
                                                                                04304500
 /* ROUTINE TO GENERATE STATIC OR DYNAMIC EVENT/PROCESS ADDRESSES */            04305000
GENEVENTADDR:                                                                   04305500
      PROCEDURE(PTR);                                                           04306000
         DECLARE PTR BIT(16);                                                   04306500
         DECLARE REGTMP BIT(16);                                                04306600
         IF FORM(PTR) = LBL THEN FORM(PTR) = SYM;                               04307000
        IF FORM(PTR)=CSYM|INX(PTR)^=0|(SYT_FLAGS(LOC(PTR)) & POINTER_OR_NAME)^=004307500
            THEN DO;                                                            04308000
            CALL RESUME_LOCCTR(NARGINDEX);                                      04308500
            TARGET_REGISTER = -1;                                               04308600
            REGTMP = FINDAC(FIXED_ACC);                                         04308700
            CALL FORCE_ADDRESS(REGTMP, PTR, 0, FOR_NAME_TRUE); /*CR13616*/      04309000
            CALL EMITRX(STH, REGTMP, 0, PRELBASE, LOCCTR(DATABASE));            04309610
            LOCCTR(DATABASE) = LOCCTR(DATABASE) + 1;                            04309710
            CALL RETURN_COLUMN_STACK(PTR);       /*DR109059*/
            CALL RETURN_STACK_ENTRY(PTR);                                       04309910
         END;
         ELSE DO;                                                               04310110
            CALL RESUME_LOCCTR(DATABASE);                                       04310310
            CALL EMITEVENTADDR(PTR);                                            04310410
         END;                                                                   04310510
      END GENEVENTADDR;                                                         04313500
                                                                                04314000
 /* ROUTINE TO GENERATE ADDRESS VALUES FOR AUTOMATIC SVC CALLS */               04314500
GENSVCADDR:                                                                     04315000
      PROCEDURE(PTR, STK, CON);                                                 04315500
         DECLARE (PTR, STK, CON) BIT(16);                                       04316000
         IF FORM(PTR) = LBL THEN FORM(PTR) = SYM;                               04316500
         CALL FORCE_ADDRESS(PTRARG1, PTR, 0, FOR_NAME_TRUE); /*CR13616*/        04317000
         INX_CON(STK) = CON;                                                    04317500
         CALL EMITOP(STH, PTRARG1, STK);                                        04318000
         CALL RETURN_COLUMN_STACK(PTR);       /*DR109059*/
         CALL RETURN_STACK_ENTRY(PTR);                                          04318500
      END GENSVCADDR;                                                           04319000
                                                                                04319500
 /?P /* CR11114 -- BFS/PASS INTERFACE; SVC */
 /* ROUTINE TO GENERATE AUTOMATIC SVC CALL */                                   04320000
GENSVC:                                                                         04320500
      PROCEDURE(SVC#, PTR);                                                     04321000
         DECLARE (SVC#, PTR) FIXED;                                             04321500
         INX_CON(PTR) = 0;                                                      04322000
         IF SVC# ^= 0 THEN DO;                                                  04322500
            CALL FORCE_NUM(LINKREG, SVC#);                                      04323000
            CALL EMITOP(STH, LINKREG, PTR);                                     04323500
         END;                                                                   04324000
         CALL EMITOP(SVC, 0, PTR);                                              04324500
         CALL DROPSAVE(PTR);                                                    04325000
         CALL RETURN_STACK_ENTRY(PTR);                                          04325500
      END GENSVC;                                                               04326000
                                                                                04326500
 ?/
 /* ROUTINE TO SEE WHETHER CURRENT BLOCK IS STATIC OR REENTRANT */              04327000
STATIC_BLOCK:                                                                   04327500
      PROCEDURE;                                                                04328000
         RETURN (SYT_FLAGS(PROC_LEVEL(NARGINDEX)) & REENTRANT_FLAG) = 0;        04328500
      END STATIC_BLOCK;                                                         04329000
                                                                                04330000
 /* ROUTINE TO EMIT EVENT EXPRESSIONS FROM STACKS  */                           04330500
EMIT_EVENT_EXPRESSION:                                                          04331000
      PROCEDURE;                                                                04331500
         DECLARE I BIT(16);                                                     04332000
         DECLARE EXPRESS FIXED;                                                 04332500
         DECLARE EVENT_AND BIT(1) INITIAL(FALSE);             /*CR13220*/
         DECLARE EVENT_OR  BIT(1) INITIAL(FALSE);             /*CR13220*/
         EXPRESS = 0;                                                           04333000
         DO I = 1 TO EV_EXPTR-1;                                                04333500
            EXPRESS = SHL(EV_EXP(I), 28-SHL(I,1)) | EXPRESS;                    04334000
            DO CASE EV_EXP(I);                                /*CR13220*/

               /* DO NOTHING BECAUSE IT IS AN EVENT VARIABLE. /*CR13220*/
               ;                                              /*CR13220*/

               /* OR OPERATOR IS BEING PROCESSED. IF THE      /*CR13220*/
               /* AND OPERATOR HAS NOT PREVIOUSLY BEEN USED   /*CR13220*/
               /* THEN CONTINUE, ELSE EMIT E102 ERROR.        /*CR13220*/
               IF ^EVENT_AND THEN                             /*CR13220*/
                  EVENT_OR = TRUE;                            /*CR13220*/
               ELSE                                           /*CR13220*/
                  CALL ERRORS(CLASS_E, 102);                  /*CR13220*/

               /* NOT OPERATOR IS BEING PROCESSED. THE NOT    /*CR13220*/
               /* OPERATOR MAY NOT BE USED IN AN EXPRESSION   /*CR13220*/
               /* WITH MORE THAN 1 EVENT VARIABLE OR WITH     /*CR13220*/
               /* MULTIPLE NOT OPERATOR. IF THE NOT           /*CR13220*/
               /* OPERATOR IS USED ILLEGALLY EMIT E102 ERROR. /*CR13220*/
               IF EV_EXPTR > 2 THEN                           /*CR13220*/
                  CALL ERRORS(CLASS_E, 102);                  /*CR13220*/

               /* AND OPERATOR IS BEING PROCESSED. IF THE     /*CR13220*/
               /* OR OPERATOR HAS NOT PREVIOUSLY BEEN USED    /*CR13220*/
               /* THEN CONTINUE. ELSE EMIT E102 ERROR.        /*CR13220*/
               IF ^EVENT_OR THEN                              /*CR13220*/
                  EVENT_AND = TRUE;                           /*CR13220*/
               ELSE                                           /*CR13220*/
                  CALL ERRORS(CLASS_E, 102);                  /*CR13220*/

            END;                                              /*CR13220*/
         END;                                                                   04334500
         IF STATIC_BLOCK THEN DO;                                               04335000
            LEFTOP = GET_STACK_ENTRY;                                           04335210
            PROGDATA = (PROGDATA+1) & (^1);                                     04336010
            DISP(LEFTOP)=PROGDATA;                                              04336110
            FORM(LEFTOP)=0;                                                     04336210
            CALL SET_LOCCTR(DATABASE, PROGDATA);                                04336310
            CALL EMITC(DATABLK, 1);                                             04338000
            CALL EMITW(SHL(EV_EXPTR-1, 28) + EXPRESS);                          04338500
            DO I = 1 TO EV_PTR;                                                 04339000
               CALL GENEVENTADDR(EV_OP(I));                                     04339500
            END;                                                                04340000
            PROGDATA=LOCCTR(DATABASE);                                          04340600
            CALL RESUME_LOCCTR(NARGINDEX);                                      04341000
         END;                                                                   04341500
         ELSE DO;                                                               04342000
            LEFTOP = GETFREESPACE(DINTEGER, SHR(EV_PTR+3, 1));                  04342500
            DO I = 1 TO EV_PTR;                                                 04343000
               CALL GENSVCADDR(EV_OP(I), LEFTOP, I+1);                          04343500
            END;                                                                04344000
            INX_CON(LEFTOP) = 0;                                                04344500
            CALL FORCE_NUM(PTRARG1, SHL(EV_EXPTR-1, 28) + EXPRESS, 8);          04345000
            CALL EMITOP(ST, PTRARG1, LEFTOP);                                   04345500
         END;                                                                   04346000
         EV_PTR, EV_EXPTR = 0;                                                  04355500
         EVENT_AND, EVENT_OR = FALSE;                         /*CR13220*/
      END EMIT_EVENT_EXPRESSION;                                                04356000
                                                                                04356500
 /* ROUTINE TO ENTER TOKEN ONTO EVENT EXPRESSION STACK  */                      04357000
STACK_EVENT:                                                                    04357500
      PROCEDURE(TOKEN);                                                         04358000
         DECLARE TOKEN BIT(16);                                                 04358500
         IF EV_EXPTR > EV_EXPTR_MAX THEN                                        04359000
            CALL ERRORS(CLASS_E,100);                                           04359500
         EV_EXP(EV_EXPTR) = TOKEN;                                              04360000
         EV_EXPTR = EV_EXPTR + 1;                                               04360500
      END STACK_EVENT;                                                          04361000
                                                                                04361500
 /* ROUTINE TO ESTABLISH TOKEN FOR EVENT EXPRESSION  */                         04362000
SET_EVENT_OPERAND:                                                              04362500
      PROCEDURE(OP);                                                            04363000
         DECLARE OP BIT(16);                                                    04363500
         EV_PTR = EV_PTR + 1;                                                   04369000
         IF EV_PTR > EV_PTR_MAX THEN                                            04369500
            CALL ERRORS(CLASS_E,101);                                           04370000
         EV_OP(EV_PTR) = OP;                                                    04370500
         CALL STACK_EVENT(0);                                                   04371000
      END SET_EVENT_OPERAND;                                                    04372000
                                                                                04372500
 /* PROCEDURE TO CHECK FOR RETURN OF EXPRESSION OR FUNCTION */                  04373000
RETURN_EXP_OR_FN:PROCEDURE(PTR) BIT(1);                                         04373500
         DECLARE (PTR, OPCODE) BIT(16);                                         04374000
         DECLARE RTURN BIT(16) INITIAL("0320");                                 04374500
         RETURN_FLAG=FALSE;                                                     04375000
         OPCODE = POPCODE(SKIP_NOP(PTR));                                        4375500
         IF OPCODE = RTURN THEN DO;                                             04376000
            INDEX=PROC_LEVEL(INDEXNEST);                                        04376500
            IF SYT_TYPE(INDEX)^=OPTYPE THEN RETURN FALSE;                       04377000
            RESULT=SET_OPERAND(INDEX);                                          04377500
            RETURN_FLAG=TRUE;                                                   04378000
            RETURN TRUE;                                                        04378500
         END;                                                                   04379000
         ELSE                                                                   04379500
            RETURN FALSE;                                                       04380000
      END RETURN_EXP_OR_FN;                                                     04380500
                                                                                04381000
                                                                                 4389510
 /* ROUTINE TO PERFORM INLINE SCALAR ARITHMETIC ON V/M OPERANDS */               4389520
MAT_EXPRESSION:                                                                  4389530
      PROCEDURE(OPCODE, TEMP);                                                   4389540
         DECLARE OPCODE BIT(16), TEMP BIT(1);                                    4389550
         DECLARE OPTRANS(6) BIT(16) INITIAL                                      4389560
            (0,1,11,12,16,13,14);                                                4389570
         OPCODE = OPTRANS(OPCODE);                                               4389580
         IF UNARY(OPCODE) THEN DO;                                               4389590
            CALL UNARYOP(OPCODE);                                                4389600
         END;                                                                    4389610
         ELSE DO;                                                                4389620
            CALL EXPRESSION(OPCODE);                                             4389630
         END;                                                                    4389640
         RESULT = LEFTOP;                                                        4389650
         ROW(RESULT) = ROW(0);                                                  04389660
         COLUMN(RESULT) = COLUMN(0);                                            04389670
         VMCOPY(RESULT) = TEMP;                                                  4389680
      END MAT_EXPRESSION;                                                        4389690
      DECLARE (REMOTE_RECVR,SUBSTRUCT_FLAG) BIT(1);                              4390000
      DECLARE NAME_OP_FLAG BIT(1);                                               4390500
                                                                                04398000
                                                                                04398500
 /* MODIFIED GET_OPERAND TO EXTRACT LIMITED INFORMATION */                      04399000
MOD_GET_OPERAND:                                                                04399500
      PROCEDURE(OP) BIT(16);                                       /*CR13616*/  04400000
         DECLARE (OP,PTR,SAVCTR) BIT(16);                          /*CR13616*/  04400500
         VAC_FLAG,NAME_OP_FLAG,REMOTE_RECVR,SUBSTRUCT_FLAG=FALSE;               04401000
         PTR = 0;                                                                4401100
         CALL DECODEPIP(OP,0);  /* GET OPERAND DATA*/              /*CR13616*/  04401500
         DO CASE TAG1;     /* Q-TAG */                                          04402000
            ;   /*  TAG1=0  */                                                  04402500
            DO;  /*  TAG1=1 (SYT)  */                                           04403000
               PTR=GET_STACK_ENTRY;                                             04403500
               FORM(PTR)=SYM;                                                   04404000
               IF (SYT_FLAGS(OP1) & NAME_FLAG)^=0 THEN                          04405500
                  NAME_OP_FLAG=TRUE;                                            04406000
               LOC(PTR),LOC2(PTR)=OP1;                                          04406500
               TYPE(PTR)=SYT_TYPE(OP1);                                         04407000
               IF SYT_ARRAY(OP1) ^= 0 THEN                                       4407100
                  ARRAY_FLAG = TRUE;                                             4407200
 /********** DR58889 START *************/
               IF CHECK_REMOTE(PTR) THEN                   /* DR113 */          04407201
                  REMOTE_RECVR = TRUE ;                    /* DR113 */          04407202
 /********** DR58889 FINISH ************/
   /*-------------------- DANNY #DPARM --- #D PASS-BY-REF TO RTL ----*/         85930010
   /* SET REMOTE_RECVR FOR #D DATA ALSO (ORIGINALLY DR113).          */         85940099
               IF DATA_REMOTE & (CSECT_TYPE(LOC(PTR),PTR)=LOCAL#D)              85950099
                  THEN REMOTE_RECVR = TRUE;                                     85960099
   /*----------------------------------------------------------------*/         85970018
            END;                                                                04407500
            ;  /* TAG1=2  (GLI)  */                                             04408000
            DO;   /*  TAG1=3  (VAC)  */                                         04408500
               PTR=FETCH_VAC(OP1,-1);                                            4409000
               /**********  DR105050  RPC  **********/
               IF CHECK_REMOTE(PTR) THEN
                  REMOTE_RECVR = TRUE;
               IF DATA_REMOTE & (CSECT_TYPE(LOC(PTR),PTR)=LOCAL#D)              85950099
                  THEN REMOTE_RECVR = TRUE;                                     85960099
               /** END  DR105050  *******************/
            END;                                                                04410000
            DO;   /* TAG1=4   POINTER(XPT)  */                                  04410500
               SAVCTR=CTR;                                                      04411000
               CTR=OP1;                                                         04411500
               CALL DECODEPIP(1,1);                                             04412000
               IF TAG1=SYM THEN DO;                                             04412500
                  PTR=GET_STACK_ENTRY;                                          04413000
                  LOC(PTR)=OP1;                                                 04413500
                  TYPE(PTR)=SYT_TYPE(OP1);                                      04414000
                  FORM(PTR)=SYM;                                                04414500
                  OP2,LOC2(PTR)=SYT_DIMS(OP1);                                  04415000
                  IF SYT_ARRAY(OP1) ^= 0 THEN                                    4415100
                     ARRAY_FLAG = TRUE;                                          4415200
               END;                                                             04415500
               ELSE DO;                                                         04416000
                  PTR=FETCH_VAC(OP1,-1);                                         4416500
                  SUBSTRUCT_FLAG=TRUE;                                           4417000
               END;                                                             04417500
               DO OP=2 TO POPNUM(CTR);                                           4418000
                  CALL DECODEPIP(OP,1);                                         04419000
                  LOC2(PTR)=OP1;                                                04419500
                  IF ^SUBSTRUCT_FLAG THEN                                       04420000
                     INX_CON(PTR)=INX_CON(PTR) + SYT_ADDR(OP1);                 04420500
                  IF OP = POPNUM(CTR) THEN DO;                                   4421000
                     IF (SYT_FLAGS(OP1) & REMOTE_FLAG)^=0 THEN                  04421500
                        REMOTE_RECVR=TRUE;                                      04422000
      /*-------------------- DANNY #DPARM --- #D PASS-BY-REF TO RTL ----*/      86290010
      /* SET REMOTE_RECVR FOR #D DATA ALSO (ORIGINALLY DR113).          */      86300099
                     IF DATA_REMOTE & (CSECT_TYPE(LOC(PTR),PTR)=LOCAL#D)        86310099
                        THEN REMOTE_RECVR = TRUE;                               86320099
      /*----------------------------------------------------------------*/      86330018
                  END;                                                          04422500
                  IF (SYT_FLAGS(OP1) & NAME_FLAG)^= 0 THEN                      04423000
                     NAME_OP_FLAG=TRUE;                                         04423500
               END;                                                             04424500
               IF ^(NAME_OP_FLAG | SUBSTRUCT_FLAG) THEN                         04425000
                  INX_CON(PTR) = INX_CON(PTR) + SYT_CONST(LOC2(PTR));           04425500
               CTR=SAVCTR;                                                      04426000
               OP1=LOC2(PTR);                                                   04426500
               TYPE(PTR)=SYT_TYPE(OP1);                                         04427000
               COLUMN(PTR) = SYT_DIMS(OP1) & "FF";                              04427010
               ROW(PTR) = SHR(SYT_DIMS(OP1), 8);                                04427020
               IF SYT_ARRAY(OP1) ^= 0 THEN                                       4427100
                  ARRAY_FLAG = TRUE;                                             4427200
            END;                                                                04427500
            VAC_FLAG=TRUE;  /* TAG1=5 (LIT)  */                                 04428000
            ;;; /* INSURANCE  */                                                04428500
            END;                                                                04429000
         RETURN PTR;                                                            04430000
      END MOD_GET_OPERAND;                                                      04430500
                                                                                 4430520
 /* DECLARATIONS FOR PROCEDURES MAT_TEMP AND MAT_ASSIGN.  DATA WAS              04430540
      LOCAL TO MAT_TEMP BEFORE IT WAS CHANGED TO ACCOMODATE MAT_ASSIGN */       04430550
 /* MISCELLANEOUS DECLARATIONS */                                                4430600
      DECLARE (LNON_IDENT,OPER_PARM_FLAG,ASSIGN_PARM_FLAG) BIT(1);               4430620
      DECLARE (LEFT_DISJOINT,RIGHT_DISJOINT,RNON_IDENT) BIT(1);                  4430640
      DECLARE (OPER_SYMPTR,RECVR_SYMPTR,PART_SIZE,DATA_WIDTH) BIT(16);           4430660
      DECLARE (START_OFF,START_PART) FIXED;                                      4430680
      DECLARE (INX_OK,RECVR_OK) BIT(1);                                          4430700
      DECLARE (NONPART,LEFT_NSEC,RIGHT_NSEC) BIT(1);                             4430720
      DECLARE (OK_TO_ASSIGN,ALL_FAILS) BIT(1);                                   4430740
      DECLARE (RECVR,RTYPE,SRCEPART_SIZE) BIT(16);                               4430760
      DECLARE RECVR_NEST_LEVEL BIT(8);                                           4430780
      DECLARE (RECVR_STRUCT, OPER_STRUCT) BIT(1);                               04430790
      DECLARE (RECVR_SYMPTR2, OPER_SYMPTR2) BIT(16);                            04430800
                                                                                04431000
                                                                                04431500
 /*  CHECK OPERANDS OF ASSIGNMENT SOURCE */                                     04432000
CHECK_SRCE:                                                                     04432500
      PROCEDURE;                                                                04433000
         DECLARE (LEFTOPER,RIGHTOPER) BIT(16);                                  04433500
         OK_TO_ASSIGN=FALSE;                                                    04434000
         LEFTOPER=MOD_GET_OPERAND(1);                                           04434500
         IF VAC_FLAG THEN                                                       04435000
            NAME_OP_FLAG=FALSE;                                                 04435500
         ELSE CALL RETURN_STACK_ENTRY(LEFTOPER);                                04436000
         IF (^NAME_OP_FLAG & ^SUBSTRUCT_FLAG) THEN DO;                          04436500
            IF NUMOP=2 THEN DO;                                                 04437000
               RIGHTOPER=MOD_GET_OPERAND(2);                                    04437500
               IF VAC_FLAG THEN                                                 04438000
                  NAME_OP_FLAG=FALSE;                                           04438500
               ELSE CALL RETURN_STACK_ENTRY(RIGHTOPER);                         04439000
               IF (^NAME_OP_FLAG & ^SUBSTRUCT_FLAG) THEN                        04439500
                  IF RTYPE=STMT_PREC THEN OK_TO_ASSIGN=TRUE;                    04440000
            END;                                                                04440500
            ELSE IF RTYPE=STMT_PREC THEN OK_TO_ASSIGN=TRUE;                     04441000
         END;                                                                   04441500
      END CHECK_SRCE;                                                           04442000
                                                                                04442500
 /* PROCEDURE TO GATHER INFO ABOUT THE RECEIVER OF A MATRIX ASSIGNMENT.         04442510
      SO THAT PROCEDURE 'IDENT_DISJOINT_CHECK' MAY BE CALLED */                 04442520
GET_RECVR_INFO:                                                                 04442530
      PROCEDURE(RECVR);                                                         04442540
         DECLARE RECVR BIT(16);                                                 04442550
         INX_OK = (INX(RECVR) = 0);  /* NO VARIABLE INDEXING */                 04442560
         NONPART = ^VAC_FLAG;        /* NOT PARTITIONED */                      04442570
         RTYPE=(TYPE(RECVR) & 8);                                               04442580
         START_OFF=INX_CON(RECVR);                                              04442590
         IF RTYPE^=0 THEN DATA_WIDTH=4;                                         04442600
         ELSE DATA_WIDTH=2;                                                     04442610
 /* SPLIT NEXT STATEMENT IN 2 BECAUSE OF DAMN XPL COMPILER -                    04442620
              NOT ENOUGH REGISTERS - 'MULTIPLY FAILED' */                       04442630
         PART_SIZE=START_OFF + ROW(RECVR) * COLUMN(RECVR) * DATA_WIDTH;         04442640
         PART_SIZE=PART_SIZE + (ROW(RECVR) - 1) * DEL(RECVR);                   04442650
         RECVR_SYMPTR = LOC(RECVR);                                             04442660
         RECVR_SYMPTR2 = LOC2(RECVR);                                           04442670
         ASSIGN_PARM_FLAG = (SYT_FLAGS(RECVR_SYMPTR) & ASSIGN_FLAG) ^= 0;       04442680
         RECVR_NEST_LEVEL = SYT_NEST(RECVR_SYMPTR);                             04442690
         RECVR_STRUCT =  SYT_TYPE(RECVR_SYMPTR) = STRUCTURE;                    04442700
      END GET_RECVR_INFO;                                                       04442710
                                                                                04442720
CHECK_ASSIGN:                                                                   04443000
      PROCEDURE(PTR);                                                           04443500
         DECLARE (PTR,HOLDCTR) BIT(16);                                          4444000
         ASSIGN_PARM_FLAG,RECVR_OK,OK_TO_ASSIGN,NONPART,INX_OK=FALSE;           04445500
         ALL_FAILS=TRUE;                                                        04446000
         ASNCTR, PTR = VECMAT_ASN(PTR);                                          4446500
         IF PTR >= 0 THEN DO;                                                    4447000
            HOLDCTR=CTR;                                                        04449000
            CTR=PTR;                                                            04449500
            RECVR=MOD_GET_OPERAND(2);                                           04450000
            IF (^NAME_OP_FLAG & ^REMOTE_RECVR) THEN                             04451500
               IF ^SUBSTRUCT_FLAG THEN IF                                       04452000
               DEL(RECVR)=0 THEN DO;   /*** DR58889 ***/                        04452500
               RECVR_OK = TRUE ;                                                04453000
            END ;                      /*** DR58889 ***/                        04453001
            IF RECVR_OK THEN DO; /* DISJOINT SETUP */                           04453500
               CALL GET_RECVR_INFO(RECVR);                                      04454000
            END;                                                                04465500
            IF ^VAC_FLAG THEN                                                   04466000
               CALL RETURN_STACK_ENTRY(RECVR);                                  04466500
            CTR=HOLDCTR;                                                        04467000
         END;                                                                   04467500
         IF RECVR_OK THEN CALL CHECK_SRCE;                                      04468000
      END CHECK_ASSIGN;                                                         04468500
                                                                                04469000
IDENT_DISJOINT_CHECK:                                                           04469500
      PROCEDURE(OP,N);                                                          04470000
         DECLARE (OP,N) BIT(16);                                                04470500
         DECLARE (DISJOINT,CONSEC_VAC,NON_IDENT) BIT(1);                        04471000
         OPER_PARM_FLAG,NON_IDENT,DISJOINT,CONSEC_VAC=FALSE;                    04471500
         IF SYMFORM(FORM(OP)) THEN DO;                                          04472000
            OPER_PARM_FLAG=(SYT_FLAGS(LOC(OP)) & PARM_FLAGS)^=0;                04472500
            OPER_SYMPTR=LOC(OP);                                                04473000
            OPER_STRUCT =  SYT_TYPE(LOC(OP)) = STRUCTURE;                       04473050
            OPER_SYMPTR2 = LOC2(OP);                                            04473100
            CONSEC_VAC=TAG_BITS(N)=VAC;                                         04473500
         END;                                                                   04474000
         ELSE NON_IDENT,DISJOINT=TRUE;                                          04474500
         IF ^NON_IDENT & RECVR_SYMPTR^=OPER_SYMPTR THEN DO;                     04475000
          IF (^ASSIGN_PARM_FLAG & ^OPER_PARM_FLAG) THEN NON_IDENT,DISJOINT=TRUE;04475500
            IF ASSIGN_PARM_FLAG & ^OPER_PARM_FLAG THEN IF                       04476000
               SYT_NEST(LOC(OP))>=RECVR_NEST_LEVEL THEN NON_IDENT,DISJOINT=TRUE;04476500
            IF OPER_PARM_FLAG & ^ASSIGN_PARM_FLAG THEN IF                       04477000
               RECVR_NEST_LEVEL>=SYT_NEST(LOC(OP)) THEN NON_IDENT,DISJOINT=TRUE;04477500
         END;                                                                   04478000
         IF ^DISJOINT THEN DO;                                                  04478500
            IF STMT_PREC^=0 THEN DATA_WIDTH=4;                                  04480000
            ELSE DATA_WIDTH=2;                                                  04480500
            START_PART=INX_CON(OP);                                             04481000
 /* THE NEXT STATEMENT WAS SPLIT BECAUSE OF - MULTIPLY FAILED  */               04481500
            SRCEPART_SIZE = START_PART + ROW(OP) * COLUMN(OP) * DATA_WIDTH;     04481510
            SRCEPART_SIZE = SRCEPART_SIZE + (ROW(OP) - 1) * DEL(OP);            04481520
 /* HERE IF (1) A PARAMETER AND A MORE GLOBAL MATRIX, OR                        04482000
          (2) TWO PARAMETERS, OR (3) IDENTICAL SYMBOL TABLE POINTERS */         04482050
            IF ^RECVR_STRUCT & ^OPER_STRUCT THEN DO;                            04482100
 /* NEITHER IS A STRUCTURE */                                                   04482150
               IF CONSEC_VAC & ^NONPART THEN  /* BOTH ARE PARTITIONED */        04482200
                  IF INX_OK & INX(OP) = 0 THEN  /* NO VARIABLE SUBSCRIPTS */    04482250
                  IF RECVR_SYMPTR = OPER_SYMPTR THEN                            04482300
 /* CHECK TO SEE IF PARTITIONS OVERLAP */                                       04482350
                DISJOINT = PART_SIZE <= START_PART | SRCEPART_SIZE <= START_OFF;04482400
             ELSE /* ONE OR BOTH ARE PARAMETERS. OTHERWISE WOULD HAVE DETERMINED04482450
                   DISJOINTNESS BEFORE THIS. KNOW DISJOINT IF OPERAND PARTITION 04482500
                   COMES AFTER THAT OF THE RECEIVER. */                         04482550
                  DISJOINT = PART_SIZE <= START_PART;                           04482600
            END;                                                                04482650
            ELSE IF RECVR_STRUCT & OPER_STRUCT THEN DO;                         04482700
 /* BOTH THE RECEIVER AND OPERAND ARE STRUCTURES */                             04482750
              IF RECVR_SYMPTR = OPER_SYMPTR THEN DO;  /* IDENTICAL STRUCTURES */04482800
                  DISJOINT = ^(RECVR_SYMPTR2 = OPER_SYMPTR2); /* TERMINALS? */  04482850
                  IF ^DISJOINT & INX_OK & INX(OP) = 0 THEN                      04482900
                DISJOINT = PART_SIZE <= START_PART | SRCEPART_SIZE <= START_OFF;04482950
               END;                                                             04483000
               ELSE IF INX_OK & INX(OP) = 0 THEN                                04483050
                  IF ASSIGN_PARM_FLAG & ^OPER_PARM_FLAG THEN                    04483100
 /* DISJOINT IF PARAMETER'S PARTITION COMES AFTER THE OTHER */                  04483150
                  DISJOINT = SRCEPART_SIZE <= START_OFF;                        04483200
               ELSE IF ^ASSIGN_PARM_FLAG & OPER_PARM_FLAG THEN                  04483250
 /* DISJOINT IF PARAMETER'S PARTITION COMES AFTER THE OTHER */                  04483300
                  DISJOINT = PART_SIZE <= START_PART;                           04483350
            END;                                                                04483400
            ELSE DO;  /* ONLY ONE STRUCTURE - MUST BE AT LEAST ONE PARAMETER */ 04483450
               IF ^(ASSIGN_PARM_FLAG & OPER_PARM_FLAG) THEN                     04483500
 /* ONLY ONE PARAMETER.  IF THE PARAMETER IS ALSO THE STRUCTURE                 04483550
               THEN THE RECEIVER AND OPERAND MUST BE DISJOINT */                04483600
                  DISJOINT = (ASSIGN_PARM_FLAG & RECVR_STRUCT) |                04483650
                  (OPER_PARM_FLAG & OPER_STRUCT);                               04483700
            END;                                                                04483750
         END;                                                                   04485000
         IF N=1 THEN DO;                                                        04485500
            LEFT_DISJOINT=DISJOINT;                                             04486000
            LNON_IDENT=NON_IDENT;                                               04486500
         END;                                                                   04487000
         ELSE DO;                                                               04487500
            RIGHT_DISJOINT=DISJOINT;                                            04488000
            RNON_IDENT=NON_IDENT;                                               04488500
         END;                                                                   04489000
         IF NUMOP=1 THEN RIGHT_DISJOINT,RNON_IDENT=TRUE;                        04489500
      END IDENT_DISJOINT_CHECK;                                                 04490000
                                                                                04490500
 /* PROCEDURE TO CHECK FOR VACS AS SOURCE OPERANDS */                           04491000
NSEC_CHECK:                                                                     04491500
      PROCEDURE;                                                                04492000
         LEFT_NSEC=LEFTOP=0|FORM(LEFTOP)=WORK;                                  04492500
         RIGHT_NSEC=RIGHTOP=0|FORM(RIGHTOP)=WORK;                               04493000
      END NSEC_CHECK;                                                           04493500
                                                                                04494000
 /* PROCEDURE TO OPTIMIZE VECTOR/MATRIX CALLS */                                04494010
MAT_TEMP:                                                                       04494020
      PROCEDURE;                                                                04494030
         IF VDLP_ACTIVE THEN                                                     4494100
            CALL MAT_EXPRESSION(OPCODE, (SHR(TAG,6)|COPT)&1);                    4494200
         ELSE DO;                                                                4494300
            IF CSE_FLAG | NO_VM_OPT THEN DO;                                    04494500
               RESULT=GET_VM_TEMP;                                              04495000
               OK_TO_ASSIGN=FALSE;                                              04495500
               GO TO MAT_CALL;                                                  04496000
            END;                                                                04496500
            IF RETURN_EXP_OR_FN(CTR) THEN DO;                                   04497000
               OK_TO_ASSIGN=TRUE;                                               04497500
               GO TO MAT_CALL;                                                  04498000
            END;                                                                04498500
            CALL CHECK_ASSIGN(CTR);                                             04499000
            CALL NSEC_CHECK; /* CHECK FOR PREVIOUS OP. VAC */                   04499500
            IF OK_TO_ASSIGN THEN DO;                                            04500000
               IF (NONPART & CLASS3_OP) | CLASS1_OP THEN                        04500500
                  GO TO STACK_ENTRY_ASN;                                        04501000
 /* NSECS TRUE IF VAC FROM PREVIOUS OP OR NONCONSEC PARTITION */                04501500
               ELSE IF (LEFT_NSEC & RIGHT_NSEC)                                 04502000
                  THEN GO TO STACK_ENTRY_ASN;                                   04502500
               ELSE DO;                                                         04503000
                  CALL IDENT_DISJOINT_CHECK(LEFTOP,1);                          04503500
                  CALL IDENT_DISJOINT_CHECK(RIGHTOP,2);                         04504000
                  IF (LNON_IDENT & RNON_IDENT) THEN                             04504500
                     GO TO STACK_ENTRY_ASN;                                     04505000
               END;                                                             04505500
               IF ALL_FAILS THEN IF (LEFT_DISJOINT & RIGHT_DISJOINT)            04506000
                  THEN DO;                                                      04506500
STACK_ENTRY_ASN:  ALL_FAILS=FALSE;                                              04507000
                  CTR=ASNCTR;                                                   04507500
                  CALL AUX_SYNC(CTR);                                            4507600
                  RESULT=GET_OPERAND(2);                                        04508000
                  CALL ASSIGN_CLEAR(RESULT, 1);                                 04508100
                  OK_TO_ASSIGN=TRUE;                                            04508500
               END;                                                             04509000
               IF ALL_FAILS THEN GO TO TEMP_ASN; /* NO MATCH */                 04509500
            END;                                                                04510000
            ELSE DO;  /* IF OK_TO_ASSIGN=FALSE OR NO MATCH */                   04510500
TEMP_ASN:      RESULT=GET_VM_TEMP;                                              04511000
               OK_TO_ASSIGN=FALSE;                                              04511500
            END;                                                                04512000
MAT_CALL:   CALL VMCALL(OPCODE,(OPTYPE&8)^=0,RESULT,LEFTOP,RIGHTOP,0);          04512500
            CALL RETURN_STACK_ENTRIES(LEFTOP,RIGHTOP);                          04513000
            IF OK_TO_ASSIGN THEN                                                04513500
               CALL RETURN_STACK_ENTRY(RESULT);                                 04514000
            ELSE LASTRESULT = RESULT;                                            4514100
         END;                                                                    4514200
         CLASS3_OP,CLASS1_OP=FALSE;                                             04514500
      END MAT_TEMP;                                                             04517000
 /* ROUTINE TO DO VECTOR/MATRIX ASSIGNMENTS.  DECIDES WHETHER A TEMPORARY       04517005
      MUST BE USED */                                                           04517010
MAT_ASSIGN:                                                                     04517015
      PROCEDURE;                                                                04517020
         DECLARE NEED_TEMP BIT(1);                                              04517025
         DECLARE TEMPOPER BIT(16);                                              04517030
         NEED_TEMP = FALSE;                                                     04517035
         IF VDLP_IN_EFFECT THEN                                                 04517040
            DO LHSPTR=2 TO NUMOP;                                               04517045
            VDLP_ACTIVE = VDLP_ACTIVE | SHR(X_BITS(LHSPTR), 1);                 04517050
         END;                                                                   04517055
         IF VDLP_ACTIVE THEN CALL DO_ASSIGNMENT;                                04517060
         ELSE DO;                                                               04517065
            RIGHTOP = GET_OPERAND(1);                                           04517070
 /* FOLLOWING STATEMENT LEFT FROM EARLIER VERSION OF COMPILER */                04517075
            IF NUMOP > 2 THEN RIGHTOP = CHECK_AGGREGATE_ASSIGN(RIGHTOP);        04517080
 /* SEE IF RHS SHOULD FIRST BE ASSIGNED INTO A TEMPORARY */                     04517085
            IF SYMFORM( FORM(RIGHTOP) ) THEN                                    04517090
 /* IF RHS IS NOT PARTITIONED AND IS NOT A PARAMETER THEN A                     04517095
                 TEMPORARY IS NOT NEEDED */                                     04517100
               IF (TAG_BITS(1)=VAC) |                                           04517105
               (SYT_FLAGS(LOC(RIGHTOP)) & PARM_FLAGS) ^= 0 THEN DO;             04517110
               TEMPOPER = MOD_GET_OPERAND(1);                                   04517115
               IF NAME_OP_FLAG | SUBSTRUCT_FLAG THEN NEED_TEMP = TRUE;          04517120
               IF ^VAC_FLAG THEN CALL RETURN_STACK_ENTRY(TEMPOPER);             04517125
               STMT_PREC = (TYPE(RIGHTOP) & 8);                                 04517130
               LHSPTR = 2;                                                      04517135
               DO WHILE ^NEED_TEMP & (LHSPTR <= NUMOP);                         04517140
                  LEFTOP = MOD_GET_OPERAND(LHSPTR);                             04517145
                  IF NAME_OP_FLAG | SUBSTRUCT_FLAG THEN NEED_TEMP = TRUE;       04517150
                  ELSE IF VAC_FLAG THEN DO;                                     04517155
 /* IS PARTITIONED.  IF RECEIVER IS NOT PARTITIONED                             04517160
                           THEN A TEMPORARY IS NEVER NEEDED */                  04517165
                     CALL GET_RECVR_INFO(LEFTOP);                               04517170
                     CALL IDENT_DISJOINT_CHECK(RIGHTOP,1);                      04517175
                     IF ^LEFT_DISJOINT THEN NEED_TEMP = TRUE;                   04517180
                  END;                                                          04517185
                  IF ^VAC_FLAG THEN CALL RETURN_STACK_ENTRY( LEFTOP );          04517190
                  LHSPTR = LHSPTR + 1;                                          04517195
               END; /* DO WHILE */                                              04517200
               IF NEED_TEMP THEN RIGHTOP = VECMAT_CONVERT( RIGHTOP );           04517205
            END; /* SYMFORM(FORM(RIGHTOP)) */                                   04517210
            CALL DROPSAVE(RIGHTOP);                                             04517215
            DO LHSPTR = 2 TO NUMOP;                                             04517220
               LEFTOP = GET_OPERAND( LHSPTR );                                  04517225
               CALL ASSIGN_CLEAR(LEFTOP, 1);                                    04517230
               TEMPSPACE = ROW(LEFTOP) * COLUMN(LEFTOP);                        04517235
               CALL VECMAT_ASSIGN(LEFTOP,RIGHTOP);                              04517240
               CALL CLEAR_NAME_SAFE(LEFTOP); /* DR103787 */                     04517245
               CALL RETURN_STACK_ENTRY(LEFTOP);                                 04517250
            END;                                                                04517255
            CALL RETURN_STACK_ENTRY(RIGHTOP);                                   04517260
         END; /* VDLP_ACTIVE IS FALSE */                                        04517265
      END MAT_ASSIGN;                                                           04517270
                                                                                04517500
 /* ROUTINE TO PERFORM UNARY VECTOR/MATRIX OPERATIONS */                        04518000
MAT_NEGATE:                                                                     04518500
      PROCEDURE;                                                                04519000
         IF OPCODE = XXASN THEN DO;  /* PRECISION */                            04519500
            RESULT = GET_OPERAND(1);                                            04520000
            TMP = NEWPREC(TAG & "3F");                                           4520500
            IF VDLP_ACTIVE THEN DO;                                              4520700
               CALL FORCE_ACCUMULATOR(RESULT, TMP | CLASS);                      4520800
               VMCOPY(RESULT) = SHR(TAG,6);                                      4520900
            END;                                                                 4521000
            ELSE IF (TYPE(RESULT)&8) ^= TMP THEN DO;                            04521100
               RESULT = VECMAT_CONVERT(RESULT, TMP | CLASS);                     4521200
               LASTRESULT = RESULT;                                              4521300
            END;                                                                 4521400
         END;                                                                   04523000
         ELSE DO;                                                               04523500
            CALL ARG_ASSEMBLE;                                                  04524000
            TEMPSPACE = ROW(0) * COLUMN(0);                                     04524500
            CLASS3_OP=TRUE;                                                     04525000
            CALL MAT_TEMP;                                                      04525500
         END;                                                                   04526000
      END MAT_NEGATE;                                                           04526500
                                                                                04527030
 /?B  /* CR11114 -- BFS/PASS INTERFACE; DATA PROTECTION */
         /*--- ROUTINE TO EMIT INTERMEDIATE CODE STORAGE PROTECT OPERATOR ---*/ 04527060
EMIT_STORE_PROTECT:                                                             04527090
   PROCEDURE(ON_OR_OFF);                                                        04527120
                                                                                04527150
      DECLARE ON_OR_OFF BIT(1);                                                 04527180
                                                                                04527210
      CALL EMITC(SPSET, ON_OR_OFF);                                             04527240
      CURR_STORE_PROTECT = ON_OR_OFF;                                           04527270
                                                                                04527300
   END EMIT_STORE_PROTECT;                                                      04527330
 ?/
                                                                                04527360
                                                                                04527000
 /* $%GENCLAS0        INCLUDE GEN_CLASS0 */
 /* $%GENCLAS1        INCLUDE GEN_CLASS1 */
 /* $%GENCLAS2        INCLUDE GEN_CLASS2 */
 /* $%GENCLAS3        INCLUDE GEN_CLASS3 */
 /* $%GENCLAS4        INCLUDE GEN_CLASS4 */
 /* $%GENCLAS5        INCLUDE GEN_CLASS5 */
 /* $%GENCLAS6        INCLUDE GEN_CLASS6 */
 /* $%GENCLAS7        INCLUDE GEN_CLASS7 */
 /* $%GENCLAS8        INCLUDE GEN_CLASS8 */
                                                                                06999500
      DO WHILE GENERATING;                                                      07000000
         LITTYPE = CLASS;                                                       07000500
         CSE_FLAG = SHR(COPT,2);                                                 7001000
         ARRAY_FLAG, VDLP_ACTIVE = FALSE;                                       07001100
         DO CASE CLASS;                                                         07001500
            IF GEN_CLASS0 THEN RETURN;                                           7002000
            CALL GEN_CLASS1;                                                    07002500
            CALL GEN_CLASS2;                                                    07003000
            CALL GEN_CLASS3;                                                    07003500
            CALL GEN_CLASS4;                                                    07004000
            CALL GEN_CLASS5;                                                    07004500
            CALL GEN_CLASS6;                                                    07005000
            CALL GEN_CLASS7;                                                    07005500
            CALL GEN_CLASS8;                                                    07006000
            DO;  /* CLASS 9  -  FOR ERROR RECOVERY */                           07006500
               CALL RESUME_LOCCTR(NARGINDEX);                                   07007000
               CALL ERRCALL(50, 'ERROR IN HAL SOURCE');                         07007500
               IF GEN_CLASS0 THEN RETURN;                                        7007700
            END;                                                                07008000
         END;  /* DO CASE CLASS */                                              07008500
         CALL DROPFREESPACE;                                                    07009000
         CALL NEXTCODE;                                                         07009500
      END;  /* WHILE GENERATING  */                                             07010000
   END GENERATE   /*  $S  */ ;  /*  $S  */                                      07010500
