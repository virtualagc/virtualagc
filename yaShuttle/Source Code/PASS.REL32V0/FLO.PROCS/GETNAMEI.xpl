 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETNAMEI.xpl
    Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
                generation process.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section 6.3.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  GET_NAME_INITIALS                                      */
 /* MEMBER NAME:     GETNAMEI                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          DEBUG_H           BIT(16)                                      */
 /*          INIT_VAL          BIT(16)                                      */
 /*          NAME_VAR          BIT(16)                                      */
 /*          PTR               BIT(16)                                      */
 /*          RESTART(762)      LABEL                                        */
 /*          SMRK_CTR(758)     LABEL                                        */
 /*          VAR_REF(761)      LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BLOCK#                                                         */
 /*          CLASS                                                          */
 /*          CLASS_BI                                                       */
 /*          DSUB                                                           */
 /*          EDCL                                                           */
 /*          EINT                                                           */
 /*          EXTN                                                           */
 /*          FALSE                                                          */
 /*          FOREVER                                                        */
 /*          HMAT_OPT                                                       */
 /*          IMRK                                                           */
 /*          IN_IDLP                                                        */
 /*          MISC_NAME_FLAG                                                 */
 /*          MODF                                                           */
 /*          NAME_INITIAL                                                   */
 /*          OPCODE                                                         */
 /*          OPR                                                            */
 /*          PROC_TRACE                                                     */
 /*          SMRK                                                           */
 /*          STRI                                                           */
 /*          SUBCODE                                                        */
 /*          SYM_ARRAY                                                      */
 /*          SYM_FLAGS                                                      */
 /*          SYM_TAB                                                        */
 /*          SYT                                                            */
 /*          SYT_ARRAY                                                      */
 /*          SYT_FLAGS                                                      */
 /*          TERM_LIST_HEAD                                                 */
 /*          TRUE                                                           */
 /*          TSUB                                                           */
 /*          VAC                                                            */
 /*          XPT                                                            */
 /*          XREC                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CTR                                                            */
 /*          DSUB_LOC                                                       */
 /*          EXTN_LOC                                                       */
 /*          HALMAT_PTR                                                     */
 /*          INIT_LIST_HEAD                                                 */
 /*          INITIALIZING                                                   */
 /*          MAJ_STRUCT                                                     */
 /*          OLD_STMT#                                                      */
 /*          START_NODE                                                     */
 /*          STMT#                                                          */
 /*          STRUCT_COPIES                                                  */
 /*          STRUCT_TEMPL                                                   */
 /*          TEMPL_INX                                                      */
 /*          TEMPL_LIST                                                     */
 /*          TSUB_LOC                                                       */
 /*          VMEM_F                                                         */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ADD_INITIALIZED_NAME_VAR                                       */
 /*          DECODEPOP                                                      */
 /*          DO_EACH_TERMINAL                                               */
 /*          ERRORS                                                         */
 /*          GET_CELL                                                       */
 /*          GET_VAR_REF_CELL                                               */
 /*          KEEP_POINTERS                                                  */
 /*          NEW_HALMAT_BLOCK                                               */
 /*          NEXT_OP                                                        */
 /*          POPCODE                                                        */
 /*          POPVAL                                                         */
 /*          PROCESS_DECL_SMRK                                              */
 /*          PUT_SYT_VPTR                                                   */
 /*          SCAN_INITIAL_LIST                                              */
 /*          SET_DEBUG_TOGGLES                                              */
 /*          STRUCTURE_WALK                                                 */
 /*          TRAVERSE_INIT_LIST                                             */
 /*          TYPE_BITS                                                      */
 /* CALLED BY:                                                              */
 /*          PROCESS_HALMAT                                                 */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> GET_NAME_INITIALS <==                                               */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /*     ==> GET_CELL                                                        */
 /*     ==> NEW_HALMAT_BLOCK                                                */
 /*         ==> ZERO_CORE                                                   */
 /*     ==> POPCODE                                                         */
 /*     ==> POPVAL                                                          */
 /*     ==> TYPE_BITS                                                       */
 /*     ==> DECODEPOP                                                       */
 /*     ==> NEXT_OP                                                         */
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
 /*     ==> PUT_SYT_VPTR                                                    */
 /*     ==> PROCESS_DECL_SMRK                                               */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> DISP                                                        */
 /*         ==> GET_CELL                                                    */
 /*         ==> LOCATE                                                      */
 /*     ==> ADD_INITIALIZED_NAME_VAR                                        */
 /*     ==> STRUCTURE_WALK                                                  */
 /*         ==> PTR_LOCATE                                                  */
 /*         ==> GET_CELL                                                    */
 /*         ==> LUMP_ARRAYSIZE                                              */
 /*         ==> LUMP_TERMINALSIZE                                           */
 /*         ==> STRUCTURE_ADVANCE                                           */
 /*             ==> DESCENDENT                                              */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*             ==> SUCCESSOR                                               */
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
 /*     ==> SCAN_INITIAL_LIST                                               */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> FORMAT                                                      */
 /*         ==> HEX                                                         */
 /*         ==> POPCODE                                                     */
 /*         ==> POPVAL                                                      */
 /*         ==> TYPE_BITS                                                   */
 /*         ==> NEXT_OP                                                     */
 /*     ==> TRAVERSE_INIT_LIST                                              */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> MOVE                                                        */
 /*         ==> DISP                                                        */
 /*         ==> PTR_LOCATE                                                  */
 /*         ==> GET_CELL                                                    */
 /*         ==> LOCATE                                                      */
 /*         ==> FORMAT                                                      */
 /*         ==> POPCODE                                                     */
 /*         ==> POPVAL                                                      */
 /*         ==> TYPE_BITS                                                   */
 /*     ==> DO_EACH_TERMINAL                                                */
 /*         ==> MOVE                                                        */
 /*         ==> GET_CELL                                                    */
 /*         ==> LOCATE                                                      */
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
 /***************************************************************************/
 /***************************************************************************/
 /*                                                                         */
 /*  DATE      DEV  REL     DR/CR     TITLE                                 */
 /*                                                                         */
 /*  04/12/01  DCP  31V0/   DR111361  NAME INITIALIZATION INFORMATION       */
 /*                 16V0              MISSING IN SDF                        */
 /*                                                                         */
 /***************************************************************************/
                                                                                00230800
 /* ROUTINE TO BUILD VMEM NAME INITIALIZATION CELLS */                          00230900
GET_NAME_INITIALS:                                                              00231000
   PROCEDURE;                                                                   00231100
      DECLARE (DEBUG_H,PTR,NAME_VAR,INIT_VAL) BIT(16);                          00231200
                                                                                00231300
 /* RETURNS PTR TO END OF HALMAT FOR THIS STATEMENT */                          00231400
SMRK_CTR:                                                                       00231500
      PROCEDURE (LOC) BIT(16);                                                  00231600
         DECLARE (LOC,OPERATOR,NUMOP) BIT(16);                                  00231700
                                                                                00231800
         IF (OPR(LOC) & 1) = 1 THEN LOC = NEXT_OP(LOC);                         00231900
         OPERATOR = SHR(OPR(LOC),4) & "FFF";                                    00232000
         DO WHILE OPERATOR ^= SMRK & OPERATOR ^= IMRK;                          00232100
            NUMOP = SHR(OPR(LOC),16) & "FF";                                    00232200
            LOC = LOC + NUMOP + 1;                                              00232300
            OPERATOR = SHR(OPR(LOC),4) & "FFF";                                 00232400
         END;                                                                   00232500
         RETURN LOC;                                                            00232600
      END SMRK_CTR;                                                             00232700
                                                                                00232800
      IF PROC_TRACE THEN OUTPUT='GET_NAME_INITIALS';                            00232801
      DO FOREVER;                                                               00232900
RESTART:                                                                        00233000
         DO WHILE POPCODE(CTR) = SMRK | POPCODE(CTR) = IMRK;                    00233100
            DEBUG_H = SHR(OPR(CTR+1),8) & "FF";                                 00233101
            IF DEBUG_H>99 & DEBUG_H<110 THEN CALL SET_DEBUG_TOGGLES(DEBUG_H);   00233102
            STMT# = POPVAL(CTR+1);                                              00233112
            CALL PROCESS_DECL_SMRK;                                             00233122
            IF HMAT_OPT THEN CALL KEEP_POINTERS;                                00233132
            OLD_STMT# = STMT#;                                                  00233142
            CTR = CTR + 2;                                                      00233200
         END;                                                                   00233300
         CALL DECODEPOP(CTR);                                                   00233400
         IF OPCODE = XREC THEN DO;                                              00233500
            CALL NEW_HALMAT_BLOCK;                                              00233600
            IF HMAT_OPT THEN START_NODE = 2;                                    00233700
            CTR = 2;                                                            00233710
            GO TO RESTART;                                                      00233800
         END;                                                                   00233900
         IF OPCODE = EDCL THEN DO;                                              00234000
            INITIALIZING = FALSE;                                               00234100
            RETURN;                                                             00234300
         END;                                                                   00234400
         DO WHILE CLASS ^= 8;                                                   00234500
            IF OPCODE = TSUB THEN DO;                                           00234600
               TSUB_LOC = CTR;                                                  00234610
               PTR = NEXT_OP(CTR);                                              00234620
               IF POPCODE(PTR) = EXTN & TYPE_BITS(PTR+1) = VAC THEN DO;         00234630
                  EXTN_LOC,CTR = PTR;                                           00234640
                  PTR = NEXT_OP(CTR);                                           00234650
                  IF POPCODE(PTR) = DSUB & TYPE_BITS(PTR+1) = XPT THEN          00234660
                     DSUB_LOC,CTR = PTR;                                        00234670
               END;                                                             00234680
               HALMAT_PTR(CTR) = GET_VAR_REF_CELL;                              00234690
            END;                                                                00234691
            ELSE IF OPCODE = EXTN THEN DO;                                      00234700
               EXTN_LOC = CTR;                                                  00234710
               PTR = NEXT_OP(CTR);                                              00234720
               IF POPCODE(PTR) = DSUB & TYPE_BITS(PTR+1) = XPT THEN             00234730
                  DSUB_LOC,CTR = PTR;                                           00234740
               HALMAT_PTR(CTR) = GET_VAR_REF_CELL;                              00234750
            END;                                                                00234780
            ELSE IF OPCODE = DSUB THEN DO;                                      00234800
               DSUB_LOC = CTR;                                                  00234810
               HALMAT_PTR(CTR) = GET_VAR_REF_CELL;                              00234820
            END;                                                                00234830
            CTR = NEXT_OP(CTR);                                                 00235000
            CALL DECODEPOP(CTR);                                                00235100
         END;                                                                   00235400
         IF OPCODE = STRI THEN DO;                                              00235500
            IF TYPE_BITS(CTR+1) = XPT THEN DO;                                  00235600
               STRUCT_TEMPL = POPVAL(POPVAL(CTR+1)+2);                          00235700
               IF (SYT_FLAGS(STRUCT_TEMPL) & MISC_NAME_FLAG) ^= 0 THEN DO;      00235800
                  MAJ_STRUCT = POPVAL(POPVAL(CTR + 1) + 1);                     00235900
                  TEMPL_INX = 1;                                                00236000
                  TEMPL_LIST(TEMPL_INX) = MAJ_STRUCT;                           00236100
                  STRUCT_COPIES = SYT_ARRAY(MAJ_STRUCT);                        00236200
                  CALL STRUCTURE_WALK;                                          00236300
                  IF TERM_LIST_HEAD ^= 0 THEN                                   00236400
                     IF SCAN_INITIAL_LIST(CTR) THEN DO;                         00236500
                     CALL DO_EACH_TERMINAL(CTR);                  /*DR111361*/  00236800
                     CALL ADD_INITIALIZED_NAME_VAR(MAJ_STRUCT);                 00236850
                     CALL PUT_SYT_VPTR(MAJ_STRUCT,INIT_LIST_HEAD);              00236900
                     INIT_LIST_HEAD = 0;                                        00236901
                  END;                                                          00237000
               END;                                                             00237100
            END;                                                                00237200
         END;                                                                   00237300
         ELSE IF SUBCODE = NAME_INITIAL THEN DO;                                00237400
            IF OPCODE = EINT & TYPE_BITS(CTR+2) = SYT THEN ;                    00237500
            ELSE DO;                                                            00237600
               NAME_VAR = POPVAL(CTR+1);                                        00237700
               CALL ADD_INITIALIZED_NAME_VAR(NAME_VAR);                         00237750
               DO CASE TYPE_BITS(CTR+2);                                        00237800
                  ;                                                             00237900
                  DO;                                                           00238000
                     CALL PUT_SYT_VPTR(NAME_VAR,GET_CELL(12,ADDR(VMEM_F),MODF));00238100
                     VMEM_F(0) = "000A0001";                                    00238200
                     VMEM_F(2) = SHL(POPVAL(CTR+2),16);                         00238300
                  END;                                                          00238400
                  ;                                                             00238500
                  DO;                                                           00238600
VAR_REF:                                                                        00238700
                     INIT_VAL = POPVAL(CTR+2);                                  00238800
                     IF HALMAT_PTR(INIT_VAL) = 0 THEN                           00238900
                        CALL ERRORS (CLASS_BI,215,' '||BLOCK#||':'||INIT_VAL);  00239000
                     CALL PUT_SYT_VPTR(NAME_VAR,HALMAT_PTR(INIT_VAL));          00239200
                  END;                                                          00239300
                  GO TO VAR_REF;                                                00239400
                  ;;;;;;;                                                       00239500
                  END;                                                          00239600
            END;                                                                00239700
         END;                                                                   00239800
         CTR = SMRK_CTR(CTR);                                                   00239900
      END;                                                                      00240000
   END GET_NAME_INITIALS;                                                       00240100
