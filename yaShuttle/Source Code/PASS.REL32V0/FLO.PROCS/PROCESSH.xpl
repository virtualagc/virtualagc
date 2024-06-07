 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PROCESSH.xpl
    Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
                generation process.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section 6.3.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  PROCESS_HALMAT                                         */
 /* MEMBER NAME:     PROCESSH                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          DEBUG_H           BIT(16)                                      */
 /*          LAST_BLOCK        BIT(8)                                       */
 /*          PMHD_LOC          BIT(16)                                      */
 /*          PTR               BIT(16)                                      */
 /*          SF_INX            BIT(16)                                      */
 /*          SFST_STACK(25)    BIT(16)                                      */
 /*          VARS              BIT(8)                                       */
 /*          XX_INX            BIT(16)                                      */
 /*          XXST_STACK(25)    BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CLASS                                                          */
 /*          CLASS0                                                         */
 /*          DSUB                                                           */
 /*          EXTN                                                           */
 /*          FALSE                                                          */
 /*          FOREVER                                                        */
 /*          HMAT_OPT                                                       */
 /*          IDEF                                                           */
 /*          NILL                                                           */
 /*          OLD_SMRK_NODE                                                  */
 /*          OPCODE                                                         */
 /*          OPR                                                            */
 /*          RELS                                                           */
 /*          TRUE                                                           */
 /*          VAC                                                            */
 /*          XPT                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CTR                                                            */
 /*          DFOR_LOC                                                       */
 /*          DSUB_LOC                                                       */
 /*          EXTN_LOC                                                       */
 /*          HALMAT_PTR                                                     */
 /*          INITIALIZING                                                   */
 /*          OLD_STMT#                                                      */
 /*          START_NODE                                                     */
 /*          STMT#                                                          */
 /*          TSUB_LOC                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CREATE_STMT                                                    */
 /*          DECODEPOP                                                      */
 /*          GET_NAME_INITIALS                                              */
 /*          GET_P_F_INV_CELL                                               */
 /*          GET_STMT_VARS                                                  */
 /*          GET_VAR_REF_CELL                                               */
 /*          KEEP_POINTERS                                                  */
 /*          LAST_OP                                                        */
 /*          NEW_HALMAT_BLOCK                                               */
 /*          NEXT_OP                                                        */
 /*          POPCODE                                                        */
 /*          POPVAL                                                         */
 /*          PROCESS_DECL_SMRK                                              */
 /*          PTR_LOCATE                                                     */
 /*          SET_DEBUG_TOGGLES                                              */
 /*          TYPE_BITS                                                      */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PROCESS_HALMAT <==                                                  */
 /*     ==> PTR_LOCATE                                                      */
 /*     ==> NEW_HALMAT_BLOCK                                                */
 /*         ==> ZERO_CORE                                                   */
 /*     ==> POPCODE                                                         */
 /*     ==> POPVAL                                                          */
 /*     ==> TYPE_BITS                                                       */
 /*     ==> DECODEPOP                                                       */
 /*     ==> NEXT_OP                                                         */
 /*     ==> LAST_OP                                                         */
 /*     ==> CREATE_STMT                                                     */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> DISP                                                        */
 /*         ==> LOCATE                                                      */
 /*     ==> KEEP_POINTERS                                                   */
 /*         ==> PTR_LOCATE                                                  */
 /*         ==> NEXT_OP                                                     */
 /*         ==> ADD_SMRK_NODE                                               */
 /*             ==> PTR_LOCATE                                              */
 /*             ==> GET_CELL                                                */
 /*             ==> MIN                                                     */
 /*             ==> POPCODE                                                 */
 /*             ==> TYPE_BITS                                               */
 /*             ==> INDIRECT                                                */
 /*         ==> CREATE_STMT                                                 */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> DISP                                                    */
 /*             ==> LOCATE                                                  */
 /*     ==> SET_DEBUG_TOGGLES                                               */
 /*     ==> PROCESS_DECL_SMRK                                               */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> DISP                                                        */
 /*         ==> GET_CELL                                                    */
 /*         ==> LOCATE                                                      */
 /*     ==> GET_VAR_REF_CELL                                                */
 /*         ==> PTR_LOCATE                                                  */
 /*         ==> GET_CELL                                                    */
 /*         ==> POPNUM                                                      */
 /*         ==> TYPE_BITS                                                   */
 /*         ==> X_BITS                                                      */
 /*         ==> PROCESS_EXTN                                                */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> POPNUM                                                  */
 /*             ==> POPVAL                                                  */
 /*             ==> TYPE_BITS                                               */
 /*             ==> X_BITS                                                  */
 /*         ==> GET_EXP_VARS_CELL                                           */
 /*             ==> GET_CELL                                                */
 /*         ==> SEARCH_EXPRESSION                                           */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> POPCODE                                                 */
 /*             ==> TYPE_BITS                                               */
 /*             ==> DECODEPOP                                               */
 /*             ==> NEXT_OP                                                 */
 /*             ==> PROCESS_EXTN                                            */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> POPNUM                                              */
 /*                 ==> POPVAL                                              */
 /*                 ==> TYPE_BITS                                           */
 /*                 ==> X_BITS                                              */
 /*         ==> INTEGER_LIT                                                 */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> GET_LITERAL                                             */
 /*             ==> INTEGERIZABLE                                           */
 /*     ==> GET_P_F_INV_CELL                                                */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> PTR_LOCATE                                                  */
 /*         ==> GET_CELL                                                    */
 /*         ==> LOCATE                                                      */
 /*         ==> POPCODE                                                     */
 /*         ==> TYPE_BITS                                                   */
 /*         ==> NEXT_OP                                                     */
 /*         ==> INDIRECT                                                    */
 /*         ==> GET_SYT_VPTR                                                */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*         ==> GET_EXP_VARS_CELL                                           */
 /*             ==> GET_CELL                                                */
 /*         ==> SEARCH_EXPRESSION                                           */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> POPCODE                                                 */
 /*             ==> TYPE_BITS                                               */
 /*             ==> DECODEPOP                                               */
 /*             ==> NEXT_OP                                                 */
 /*             ==> PROCESS_EXTN                                            */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> POPNUM                                              */
 /*                 ==> POPVAL                                              */
 /*                 ==> TYPE_BITS                                           */
 /*                 ==> X_BITS                                              */
 /*         ==> GET_VAR_REF_CELL                                            */
 /*             ==> PTR_LOCATE                                              */
 /*             ==> GET_CELL                                                */
 /*             ==> POPNUM                                                  */
 /*             ==> TYPE_BITS                                               */
 /*             ==> X_BITS                                                  */
 /*             ==> PROCESS_EXTN                                            */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> POPNUM                                              */
 /*                 ==> POPVAL                                              */
 /*                 ==> TYPE_BITS                                           */
 /*                 ==> X_BITS                                              */
 /*             ==> GET_EXP_VARS_CELL                                       */
 /*                 ==> GET_CELL                                            */
 /*             ==> SEARCH_EXPRESSION                                       */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> POPCODE                                             */
 /*                 ==> TYPE_BITS                                           */
 /*                 ==> DECODEPOP                                           */
 /*                 ==> NEXT_OP                                             */
 /*                 ==> PROCESS_EXTN                                        */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                     ==> POPNUM                                          */
 /*                     ==> POPVAL                                          */
 /*                     ==> TYPE_BITS                                       */
 /*                     ==> X_BITS                                          */
 /*             ==> INTEGER_LIT                                             */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> GET_LITERAL                                         */
 /*                 ==> INTEGERIZABLE                                       */
 /*     ==> GET_NAME_INITIALS                                               */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> GET_CELL                                                    */
 /*         ==> NEW_HALMAT_BLOCK                                            */
 /*             ==> ZERO_CORE                                               */
 /*         ==> POPCODE                                                     */
 /*         ==> POPVAL                                                      */
 /*         ==> TYPE_BITS                                                   */
 /*         ==> DECODEPOP                                                   */
 /*         ==> NEXT_OP                                                     */
 /*         ==> KEEP_POINTERS                                               */
 /*             ==> PTR_LOCATE                                              */
 /*             ==> NEXT_OP                                                 */
 /*             ==> ADD_SMRK_NODE                                           */
 /*                 ==> PTR_LOCATE                                          */
 /*                 ==> GET_CELL                                            */
 /*                 ==> MIN                                                 */
 /*                 ==> POPCODE                                             */
 /*                 ==> TYPE_BITS                                           */
 /*                 ==> INDIRECT                                            */
 /*             ==> CREATE_STMT                                             */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> DISP                                                */
 /*                 ==> LOCATE                                              */
 /*         ==> SET_DEBUG_TOGGLES                                           */
 /*         ==> PUT_SYT_VPTR                                                */
 /*         ==> PROCESS_DECL_SMRK                                           */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> DISP                                                    */
 /*             ==> GET_CELL                                                */
 /*             ==> LOCATE                                                  */
 /*         ==> ADD_INITIALIZED_NAME_VAR                                    */
 /*         ==> STRUCTURE_WALK                                              */
 /*             ==> PTR_LOCATE                                              */
 /*             ==> GET_CELL                                                */
 /*             ==> LUMP_ARRAYSIZE                                          */
 /*             ==> LUMP_TERMINALSIZE                                       */
 /*             ==> STRUCTURE_ADVANCE                                       */
 /*                 ==> DESCENDENT                                          */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                 ==> SUCCESSOR                                           */
 /*         ==> GET_VAR_REF_CELL                                            */
 /*             ==> PTR_LOCATE                                              */
 /*             ==> GET_CELL                                                */
 /*             ==> POPNUM                                                  */
 /*             ==> TYPE_BITS                                               */
 /*             ==> X_BITS                                                  */
 /*             ==> PROCESS_EXTN                                            */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> POPNUM                                              */
 /*                 ==> POPVAL                                              */
 /*                 ==> TYPE_BITS                                           */
 /*                 ==> X_BITS                                              */
 /*             ==> GET_EXP_VARS_CELL                                       */
 /*                 ==> GET_CELL                                            */
 /*             ==> SEARCH_EXPRESSION                                       */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> POPCODE                                             */
 /*                 ==> TYPE_BITS                                           */
 /*                 ==> DECODEPOP                                           */
 /*                 ==> NEXT_OP                                             */
 /*                 ==> PROCESS_EXTN                                        */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                     ==> POPNUM                                          */
 /*                     ==> POPVAL                                          */
 /*                     ==> TYPE_BITS                                       */
 /*                     ==> X_BITS                                          */
 /*             ==> INTEGER_LIT                                             */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> GET_LITERAL                                         */
 /*                 ==> INTEGERIZABLE                                       */
 /*         ==> SCAN_INITIAL_LIST                                           */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> FORMAT                                                  */
 /*             ==> HEX                                                     */
 /*             ==> POPCODE                                                 */
 /*             ==> POPVAL                                                  */
 /*             ==> TYPE_BITS                                               */
 /*             ==> NEXT_OP                                                 */
 /*         ==> TRAVERSE_INIT_LIST                                          */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> MOVE                                                    */
 /*             ==> DISP                                                    */
 /*             ==> PTR_LOCATE                                              */
 /*             ==> GET_CELL                                                */
 /*             ==> LOCATE                                                  */
 /*             ==> FORMAT                                                  */
 /*             ==> POPCODE                                                 */
 /*             ==> POPVAL                                                  */
 /*             ==> TYPE_BITS                                               */
 /*         ==> DO_EACH_TERMINAL                                            */
 /*             ==> MOVE                                                    */
 /*             ==> GET_CELL                                                */
 /*             ==> LOCATE                                                  */
 /*             ==> TRAVERSE_INIT_LIST                                      */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> MOVE                                                */
 /*                 ==> DISP                                                */
 /*                 ==> PTR_LOCATE                                          */
 /*                 ==> GET_CELL                                            */
 /*                 ==> LOCATE                                              */
 /*                 ==> FORMAT                                              */
 /*                 ==> POPCODE                                             */
 /*                 ==> POPVAL                                              */
 /*                 ==> TYPE_BITS                                           */
 /*     ==> GET_STMT_VARS                                                   */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> DISP                                                        */
 /*         ==> LOCATE                                                      */
 /*         ==> HEX                                                         */
 /*         ==> POPNUM                                                      */
 /*         ==> POPCODE                                                     */
 /*         ==> POPVAL                                                      */
 /*         ==> POPTAG                                                      */
 /*         ==> TYPE_BITS                                                   */
 /*         ==> X_BITS                                                      */
 /*         ==> DECODEPOP                                                   */
 /*         ==> NEXT_OP                                                     */
 /*         ==> LAST_OP                                                     */
 /*         ==> PROCESS_EXTN                                                */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> POPNUM                                                  */
 /*             ==> POPVAL                                                  */
 /*             ==> TYPE_BITS                                               */
 /*             ==> X_BITS                                                  */
 /*         ==> GET_EXP_VARS_CELL                                           */
 /*             ==> GET_CELL                                                */
 /*         ==> SEARCH_EXPRESSION                                           */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> POPCODE                                                 */
 /*             ==> TYPE_BITS                                               */
 /*             ==> DECODEPOP                                               */
 /*             ==> NEXT_OP                                                 */
 /*             ==> PROCESS_EXTN                                            */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> POPNUM                                              */
 /*                 ==> POPVAL                                              */
 /*                 ==> TYPE_BITS                                           */
 /*                 ==> X_BITS                                              */
 /*         ==> INTEGER_LIT                                                 */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> GET_LITERAL                                             */
 /*             ==> INTEGERIZABLE                                           */
 /***************************************************************************/
                                                                                00261900
 /* MAIN LOOP TO GO THROUGH HALMAT COLLECTING INFO FOR THE SDFS */              00262000
PROCESS_HALMAT:                                                                 00262100
   PROCEDURE;                                                                   00262200
      DECLARE (PTR,SF_INX,XX_INX,DEBUG_H,PMHD_LOC) BIT(16),                     00262300
         (SFST_STACK,XXST_STACK) (25) BIT(16), LAST_BLOCK BIT(1),               00262400
         VARS BIT(1) INITIAL(1);                                                00262500
                                                                                00262600
      DO FOREVER;                                                               00262700
         CALL DECODEPOP(CTR);                                                   00262800
         IF CLASS = 0 THEN DO CASE CLASS0(OPCODE);                              00262900
            ;        /* 0 -- DO NOTHING */                                      00263000
            DO;      /* 1 -- BLOCK OPENINGS */                                  00263100
               IF OPCODE=IDEF THEN HALMAT_PTR(CTR) = GET_P_F_INV_CELL(CTR);     00263101
               CTR = CTR + 2;                                                   00263200
               INITIALIZING = TRUE;                                             00263300
               CALL GET_NAME_INITIALS;                                          00263400
            END;                                                                00263500
            DO;      /* 2 -- TSUB */                                            00263600
               TSUB_LOC = CTR;                                                  00263700
               PTR = NEXT_OP(CTR);                                              00263800
               IF POPCODE(PTR) = EXTN & TYPE_BITS(PTR+1) = VAC THEN DO;         00263900
                  EXTN_LOC,CTR = PTR;                                           00264000
                  PTR = NEXT_OP(CTR);                                           00264100
                  IF POPCODE(PTR) = DSUB & TYPE_BITS(PTR+1) = XPT THEN          00264200
                     DSUB_LOC,CTR = PTR;                                        00264300
               END;                                                             00264400
               HALMAT_PTR(CTR) = GET_VAR_REF_CELL;                              00264500
            END;                                                                00264600
            DO;      /* 3 -- EXTN */                                            00264700
               EXTN_LOC = CTR;                                                  00264800
               PTR = NEXT_OP(CTR);                                              00264900
               IF POPCODE(PTR) = DSUB & TYPE_BITS(PTR+1) = XPT THEN DO;         00265000
                  DSUB_LOC,CTR = PTR;                                           00265100
                  HALMAT_PTR(CTR) = GET_VAR_REF_CELL;                           00265200
               END;                                                             00265300
               EXTN_LOC = 0;                                                    00265301
            END;                                                                00265400
            DO;      /* 4 -- DSUB */                                            00265500
               DSUB_LOC = CTR;                                                  00265600
               HALMAT_PTR(CTR) = GET_VAR_REF_CELL;                              00265700
            END;                                                                00265800
            DO;      /* 5 -- SFST */                                            00265900
               SF_INX = SF_INX + 1;                                             00266000
               SFST_STACK(SF_INX) = CTR;                                        00266100
            END;                                                                00266200
            DO;      /* 6 -- SHAPING,LIST FUNCTIONS */                          00266300
               HALMAT_PTR(CTR) = SFST_STACK(SF_INX);                            00266400
               HALMAT_PTR(SFST_STACK(SF_INX)) = CTR;                            00266401
               SF_INX = SF_INX - 1;                                             00266500
            END;                                                                00266600
            DO;      /* 7 -- XXST */                                            00266700
               XX_INX = XX_INX + 1;                                             00266800
               XXST_STACK(XX_INX) = CTR;                                        00266900
            END;                                                                00267000
            DO;      /* 8 -- PCAL,FCAL */                                       00267100
               HALMAT_PTR(CTR) = XXST_STACK(XX_INX);                            00267200
               XX_INX = XX_INX - 1;                                             00267300
               HALMAT_PTR(CTR) = GET_P_F_INV_CELL(CTR);                         00267400
            END;                                                                00267500
            DO;      /* 9 -- READ,RDAL,WRIT */                                  00267600
               HALMAT_PTR(CTR) = XXST_STACK(XX_INX);                            00267700
               XX_INX = XX_INX - 1;                                             00267800
            END;                                                                00267900
            DO;      /* 10 -- PMHD */                                           00268000
               PMHD_LOC = CTR;                                                  00268100
            END;                                                                00268200
            DO;      /* 11 -- PMIN */                                           00268300
               HALMAT_PTR(CTR) = PMHD_LOC;                                      00268400
            END;                                                                00268500
            DO;      /* 12 -- STMTS WITH NO VARS */                             00268600
               VARS = FALSE;                                                    00268700
            END;                                                                00268800
            DO;      /* 13 -- DFOR */                                           00268900
               DFOR_LOC = CTR;                                                  00269000
            END;                                                                00269100
            DO;      /* 14 -- XREC */                                           00269200
               LAST_BLOCK = SHR(OPR(CTR),24);                                   00269300
               IF LAST_BLOCK                                                    00269400
                  THEN DO;                                                      00269410
                  IF HMAT_OPT                                                   00269420
                     THEN DO;                                                   00269430
                     CALL CREATE_STMT;                                          00269440
                     IF OLD_SMRK_NODE ^= NILL                                   00269450
                        THEN CALL PTR_LOCATE(OLD_SMRK_NODE,RELS);               00269460
                  END;                                                          00269470
                  RETURN;                                                       00269480
               END;                                                             00269490
               ELSE DO;                                                         00269500
                  CALL NEW_HALMAT_BLOCK;                                        00269510
                  IF HMAT_OPT THEN START_NODE = 2;                              00269520
                  CTR = 0;                                                      00269530
               END;                                                             00269540
            END;                                                                00269900
            DO;      /* 15 -- SMRK,IMRK */                                      00270000
               STMT# = POPVAL(CTR + 1);                                         00270100
               CALL PROCESS_DECL_SMRK;                                          00270110
               IF HMAT_OPT THEN CALL KEEP_POINTERS;                             00270120
               OLD_STMT# = STMT#;                                               00270130
               IF VARS THEN CALL GET_STMT_VARS(STMT#,LAST_OP(CTR));             00270200
               ELSE VARS = TRUE;                                                00270300
               DEBUG_H = SHR(OPR(CTR+1),8) & "FF";                              00270400
               IF DEBUG_H>99 & DEBUG_H<110 THEN CALL SET_DEBUG_TOGGLES(DEBUG_H);00270500
            END;                                                                00270800
         END;                                                                   00270900
         CTR = NEXT_OP(CTR);                                                    00271000
      END;                                                                      00271100
   END PROCESS_HALMAT;                                                          00271200
