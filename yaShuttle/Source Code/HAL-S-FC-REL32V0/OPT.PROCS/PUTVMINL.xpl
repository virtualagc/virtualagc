 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PUTVMINL.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  PUT_VM_INLINE                                          */
 /* MEMBER NAME:     PUTVMINL                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          BUMP              BIT(8)                                       */
 /*          ASSIGN            BIT(8)                                       */
 /*          DIFF              BIT(16)                                      */
 /*          REF               BIT(16)                                      */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CTR                                                            */
 /*          DIFF_NODE                                                      */
 /*          DSUB                                                           */
 /*          FALSE                                                          */
 /*          FOR                                                            */
 /*          LOOPY_ASSIGN_ONLY                                              */
 /*          OPR                                                            */
 /*          TRACE                                                          */
 /*          TRUE                                                           */
 /*          XVAC                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          A_INX                                                          */
 /*          ADD                                                            */
 /*          ASSIGN_TOP                                                     */
 /*          D_N_INX                                                        */
 /*          DSUB_REF                                                       */
 /*          LOOP_DIMENSION                                                 */
 /*          LOOP_LAST                                                      */
 /*          LOOP_START                                                     */
 /*          LOOPLESS_ASSIGN                                                */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ASSIGN_TYPE                                                    */
 /*          BUMP_ADD                                                       */
 /*          BUMP_D_N                                                       */
 /*          EXTN_CHECK                                                     */
 /*          INSERT                                                         */
 /*          LAST_OPERAND                                                   */
 /*          LOOP_OPERANDS                                                  */
 /*          LOOPY                                                          */
 /*          NAME_OR_PARM                                                   */
 /*          NO_OPERANDS                                                    */
 /*          NONCONSEC                                                      */
 /*          OPOP                                                           */
 /*          PUT_VDLP                                                       */
 /*          SEARCH_DIMENSION                                               */
 /*          XHALMAT_QUAL                                                   */
 /* CALLED BY:                                                              */
 /*          CHICKEN_OUT                                                    */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PUT_VM_INLINE <==                                                   */
 /*     ==> OPOP                                                            */
 /*     ==> BUMP_D_N                                                        */
 /*     ==> XHALMAT_QUAL                                                    */
 /*     ==> NAME_OR_PARM                                                    */
 /*     ==> ASSIGN_TYPE                                                     */
 /*     ==> NO_OPERANDS                                                     */
 /*     ==> LAST_OPERAND                                                    */
 /*     ==> NONCONSEC                                                       */
 /*         ==> LAST_OPERAND                                                */
 /*     ==> LOOP_OPERANDS                                                   */
 /*         ==> GET_CLASS                                                   */
 /*         ==> LAST_OPERAND                                                */
 /*     ==> EXTN_CHECK                                                      */
 /*         ==> XHALMAT_QUAL                                                */
 /*         ==> NAME_OR_PARM                                                */
 /*     ==> BUMP_ADD                                                        */
 /*     ==> LOOPY                                                           */
 /*         ==> GET_CLASS                                                   */
 /*         ==> XHALMAT_QUAL                                                */
 /*         ==> ASSIGN_TYPE                                                 */
 /*         ==> NO_OPERANDS                                                 */
 /*     ==> PUT_VDLP                                                        */
 /*         ==> ASSIGN_TYPE                                                 */
 /*         ==> LAST_OPERAND                                                */
 /*         ==> VU                                                          */
 /*             ==> HEX                                                     */
 /*         ==> MOVE_LIMB                                                   */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> RELOCATE                                                */
 /*             ==> MOVECODE                                                */
 /*                 ==> ENTER                                               */
 /*         ==> PUSH_HALMAT                                                 */
 /*             ==> HEX                                                     */
 /*             ==> OPOP                                                    */
 /*             ==> VAC_OR_XPT                                              */
 /*             ==> BUMP_D_N                                                */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> ENTER                                                   */
 /*             ==> LAST_OP                                                 */
 /*             ==> NO_OPERANDS                                             */
 /*             ==> MOVE_LIMB                                               */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> RELOCATE                                            */
 /*                 ==> MOVECODE                                            */
 /*                     ==> ENTER                                           */
 /*     ==> INSERT                                                          */
 /*         ==> MOVE_LIMB                                                   */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> RELOCATE                                                */
 /*             ==> MOVECODE                                                */
 /*                 ==> ENTER                                               */
 /*     ==> SEARCH_DIMENSION                                                */
 /*         ==> OPOP                                                        */
 /*         ==> XHALMAT_QUAL                                                */
 /*         ==> LAST_OPERAND                                                */
 /*         ==> GET_LOOP_DIMENSION                                          */
 /*             ==> LAST_OPERAND                                            */
 /*             ==> SET_VAR                                                 */
 /*                 ==> XHALMAT_QUAL                                        */
 /*                 ==> LAST_OPERAND                                        */
 /*             ==> COMPUTE_DIM_CONSTANT                                    */
 /*                 ==> SAVE_LITERAL                                        */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                     ==> GET_LITERAL                                     */
 /*                 ==> TEMPLATE_LIT                                        */
 /*                     ==> STRUCTURE_COMPARE                               */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                     ==> GENERATE_TEMPLATE_LIT                           */
 /*                         ==> SAVE_LITERAL                                */
 /*                             ==> ERRORS                                  */
 /*                                 ==> COMMON_ERRORS                       */
 /*                             ==> GET_LITERAL                             */
 /*                 ==> INT_TO_SCALAR                                       */
 /*                     ==> HEX                                             */
 /*             ==> COMPUTE_DIMENSIONS                                      */
 /***************************************************************************/
                                                                                02373990
 /* PUTS VECTOR/MATRIX OPERATIONS IN THEIR OWN LITTLE LOOPS, WITHOUT            02374000
      CROSSING STATEMENT BOUNDARIES*/                                           02374010
PUT_VM_INLINE:                                                                  02374020
   PROCEDURE;                                                                   02374030
      DECLARE (TEMP,REF,DIFF) BIT(16);                                          02374040
      DECLARE (BUMP,ASSIGN) BIT(8);                                             02374050
      D_N_INX = 0;                                                              02374060
      CALL BUMP_D_N(CTR);                                                       02374070
                                                                                02374080
      DO WHILE D_N_INX ^= 0;                                                    02374090
                                                                                02374100
         IF TRACE THEN                                                          02374110
            OUTPUT = 'PUT_VM_INLINE:  DIFF_NODE(' || D_N_INX|| ') = '||DIFF_NODE02374120
            (D_N_INX);                                                          02374130
                                                                                02374140
         A_INX = 0;                                                             02374150
         LOOP_START,LOOP_LAST = DIFF_NODE(D_N_INX);                             02374160
         D_N_INX = D_N_INX - 1;                                                 02374170
                                                                                02374180
         IF ^ LOOPY(LOOP_LAST) THEN                                             02374190
            DO FOR TEMP = LOOP_LAST + 1 TO LAST_OPERAND(LOOP_LAST);             02374200
                                                                                02374210
            IF XHALMAT_QUAL(TEMP) = XVAC THEN                                   02374220
               CALL BUMP_D_N(SHR(OPR(TEMP),16));                                02374230
         END;                                                                   02374240
                                                                                02374250
         ELSE DO;                                                               02374260
                                                                                02374270
            CALL BUMP_ADD(LOOP_LAST);                                           02374280
 /* ADD CONTAINS ONLY KNOWN LOOPYS*/                                            02374290
            LOOPLESS_ASSIGN,DSUB_REF = FALSE;                                   02374300
                                                                                02374310
            ASSIGN_TOP = ASSIGN_TYPE(LOOP_LAST);                                02374320
                                                                                02374330
            LOOP_DIMENSION = 0;                                                 02374340
                                                                                02374350
            DO WHILE A_INX ^= 0;                                                02374360
                                                                                02374370
               IF TRACE THEN OUTPUT =                                           02374380
                  '   ADD(' || A_INX || ') = ' || ADD(A_INX);                   02374390
                                                                                02374400
               ADD = ADD(A_INX);                                                02374410
               A_INX = A_INX - 1;                                               02374420
               TEMP = LAST_OPERAND(ADD) + 1;                                    02374430
                                                                                02374440
               DIFF = TEMP - ADD;                                               02374450
               BUMP = ADD < LOOP_START;                                         02374460
                                                                                02374470
               IF TEMP < LOOP_START THEN                                        02374480
                  CALL INSERT(ADD,TEMP);                                        02374490
                                                                                02374500
               IF BUMP THEN LOOP_START = LOOP_START - DIFF;                     02374510
                                                                                02374520
               ASSIGN = ASSIGN_TYPE(ADD);                                       02374530
                                                                                02374540
               IF ASSIGN THEN IF LOOPY_ASSIGN_ONLY THEN                         02374550
                  IF NO_OPERANDS(ADD) > 2 THEN RETURN;                          02374560
 /* NO LOOPS AROUND MULTI ASSIGN RECEIVERS SET TO 0*/                           02374570
               DO FOR TEMP = ADD + 1 TO LOOP_OPERANDS(ADD);                     02374580
                                                                                02374590
                  IF LOOP_DIMENSION = 0 THEN CALL SEARCH_DIMENSION(TEMP);       02374600
                                                                                02374610
                  DO CASE SHR(OPR(TEMP),4) & "F";     /* QUAL*/                 02374620
                                                                                02374630
                     ;                                                          02374640
                                                                                02374650
                     DO;    /* 1 = SYT*/                                        02374660
                        IF TRACE THEN OUTPUT = '      NAME_OR_PARM:  '||TEMP;   02374670
                        IF NAME_OR_PARM(TEMP) THEN DO;                          02374680
                           DSUB_REF = TRUE;                                     02374690
 /* ASSIGNMENT IN SEPARATE LOOP*/                                               02374700
                           IF ASSIGN THEN LOOPLESS_ASSIGN = TRUE;               02374710
                        END;                                                    02374720
                     END;                                                       02374730
                     ;                                                          02374740
                     DO;    /* 3 = VAC*/                                        02374750
                        REF = SHR(OPR(TEMP),16);                                02374760
                        IF LOOPY(REF) THEN CALL BUMP_ADD(REF);                  02374770
                        ELSE IF ^LOOPY_ASSIGN_ONLY THEN CALL BUMP_D_N(REF);     02374780
                        IF OPOP(REF) = DSUB THEN DO;                            02374790
                           DSUB_REF = TRUE;                                     02374800
                           IF TEMP > ADD + 1 THEN /*RECEIVER, IF ASSIGN*/       02374810
                              IF ASSIGN THEN DO;                                02374820
                              LOOPLESS_ASSIGN = NONCONSEC(REF);                 02374830
                           END;                                                 02374840
                                                                                02374850
 /* NO LOOP ASSIGNS INTO PARTITION*/                                            02374860
                                                                                02374870
                        END;                                                    02374880
                     END;                                                       02374890
                                                                                02374900
                     DO;    /* 4 = XPT*/                                        02374910
                        IF EXTN_CHECK(TEMP) THEN DO;                            02374920
                           DSUB_REF = TRUE;                                     02374930
                           IF ASSIGN THEN LOOPLESS_ASSIGN = TRUE;               02374940
                        END;                                                    02374950
                     END;                                                       02374960
                     ;;;;;;                                                     02374970
                                                                                02374980
                     END;   /* DO CASE*/                                        02374990
                                                                                02375000
                                                                                02375010
               END;  /* DO FOR*/                                                02375020
                                                                                02375030
            END;   /* DO WHILE A_INX*/                                          02375040
                                                                                02375050
            IF LOOP_DIMENSION > 1 THEN   /* DIMENSION KNOWN*/                   02375060
               CALL PUT_VDLP;                                                   02375070
                                                                                02375080
         END;   /* ELSE DO*/                                                    02375090
                                                                                02375100
      END; /* D_N_INX*/                                                         02375110
   END PUT_VM_INLINE;                                                           02375120
