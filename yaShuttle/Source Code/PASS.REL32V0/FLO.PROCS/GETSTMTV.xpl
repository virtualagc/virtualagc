 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETSTMTV.xpl
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
 /* PROCEDURE NAME:  GET_STMT_VARS                                          */
 /* MEMBER NAME:     GETSTMTV                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          STMT#             BIT(16)                                      */
 /*          PTR               FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CELL_STMT#        BIT(16)                                      */
 /*          ASSIGN_TYPE(772)  LABEL                                        */
 /*          GET_PMACRO_ARGS(769)  LABEL                                    */
 /*          GET_REALTIME_ARGS(761)  LABEL                                  */
 /*          J                 BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /*          LHS_PTR           FIXED                                        */
 /*          NAME_ASSIGN       BIT(16)                                      */
 /*          RHS_PTR           FIXED                                        */
 /*          STACK_OPERAND_VARS(763)  LABEL                                 */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ADLP                                                           */
 /*          AFOR                                                           */
 /*          BRA                                                            */
 /*          CFOR                                                           */
 /*          CLASS                                                          */
 /*          CLASS_BI                                                       */
 /*          CLASS0                                                         */
 /*          CLBL                                                           */
 /*          CTST                                                           */
 /*          DCAS                                                           */
 /*          DFOR                                                           */
 /*          DLPE                                                           */
 /*          EDCL                                                           */
 /*          ERON                                                           */
 /*          FALSE                                                          */
 /*          FBRA                                                           */
 /*          FOREVER                                                        */
 /*          HALMAT_PTR                                                     */
 /*          IMRK                                                           */
 /*          INL                                                            */
 /*          LBL                                                            */
 /*          LIT                                                            */
 /*          MODF                                                           */
 /*          NASN                                                           */
 /*          NUMOP                                                          */
 /*          PMAR                                                           */
 /*          PMIN                                                           */
 /*          PROC_TRACE                                                     */
 /*          PXRC                                                           */
 /*          RDAL                                                           */
 /*          READ                                                           */
 /*          RTRN                                                           */
 /*          SCHD                                                           */
 /*          SMRK                                                           */
 /*          TASN                                                           */
 /*          TDCL                                                           */
 /*          TRUE                                                           */
 /*          WAIT                                                           */
 /*          WRIT                                                           */
 /*          XFIL                                                           */
 /*          XREC                                                           */
 /*          XXAR                                                           */
 /*          XXND                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          DFOR_LOC                                                       */
 /*          EXP_PTRS                                                       */
 /*          EXP_VARS                                                       */
 /*          OPCODE                                                         */
 /*          PTR_INX                                                        */
 /*          STMT_DATA_CELL                                                 */
 /*          VAR_INX                                                        */
 /*          VMEM_F                                                         */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          DECODEPOP                                                      */
 /*          DISP                                                           */
 /*          ERRORS                                                         */
 /*          GET_EXP_VARS_CELL                                              */
 /*          HEX                                                            */
 /*          INTEGER_LIT                                                    */
 /*          LAST_OP                                                        */
 /*          LOCATE                                                         */
 /*          NEXT_OP                                                        */
 /*          POPCODE                                                        */
 /*          POPNUM                                                         */
 /*          POPTAG                                                         */
 /*          POPVAL                                                         */
 /*          PROCESS_EXTN                                                   */
 /*          SEARCH_EXPRESSION                                              */
 /*          TYPE_BITS                                                      */
 /*          X_BITS                                                         */
 /* CALLED BY:                                                              */
 /*          PROCESS_HALMAT                                                 */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> GET_STMT_VARS <==                                                   */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /*     ==> DISP                                                            */
 /*     ==> LOCATE                                                          */
 /*     ==> HEX                                                             */
 /*     ==> POPNUM                                                          */
 /*     ==> POPCODE                                                         */
 /*     ==> POPVAL                                                          */
 /*     ==> POPTAG                                                          */
 /*     ==> TYPE_BITS                                                       */
 /*     ==> X_BITS                                                          */
 /*     ==> DECODEPOP                                                       */
 /*     ==> NEXT_OP                                                         */
 /*     ==> LAST_OP                                                         */
 /*     ==> PROCESS_EXTN                                                    */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> POPNUM                                                      */
 /*         ==> POPVAL                                                      */
 /*         ==> TYPE_BITS                                                   */
 /*         ==> X_BITS                                                      */
 /*     ==> GET_EXP_VARS_CELL                                               */
 /*         ==> GET_CELL                                                    */
 /*     ==> SEARCH_EXPRESSION                                               */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> POPCODE                                                     */
 /*         ==> TYPE_BITS                                                   */
 /*         ==> DECODEPOP                                                   */
 /*         ==> NEXT_OP                                                     */
 /*         ==> PROCESS_EXTN                                                */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> POPNUM                                                  */
 /*             ==> POPVAL                                                  */
 /*             ==> TYPE_BITS                                               */
 /*             ==> X_BITS                                                  */
 /*     ==> INTEGER_LIT                                                     */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> GET_LITERAL                                                 */
 /*         ==> INTEGERIZABLE                                               */
 /***************************************************************************/
 /***************************************************************************/
 /*  REVISION HISTORY :                                                     */
 /*  ------------------                                                     */
 /*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */
 /*                                                                         */
 /*09/09/02 JAC  32V0/  CR13570 CREATE NEW %MACRO TO PERFORM ZEROTH         */
 /*              17V0           ELEMENT CALCULATIONS                        */
 /***************************************************************************/
                                                                                00240200
 /* GENERATES EXP VAR CELLS FOR RHS AND LHS STATEMENT VARIABLES */              00240300
GET_STMT_VARS:                                                                  00240400
   PROCEDURE (STMT#,PTR);                                                       00240500
      DECLARE (J,K,STMT#,CELL_STMT#) BIT(16), (PTR,RHS_PTR,LHS_PTR) FIXED;      00240600
      DECLARE NAME_ASSIGN BIT(16);                                              00240601
                                                                                00240700
                                                                                00240800
STACK_OPERAND_VARS:                                                             00240900
      PROCEDURE (LOC);                                                          00241000
         DECLARE LOC BIT(16);                                                   00241100
                                                                                00241200
         DO CASE TYPE_BITS(LOC);                                                00241300
            ;                                                                   00241400
            DO;                                                                 00241500
               VAR_INX = VAR_INX + 1;                                           00241600
               EXP_VARS(VAR_INX) = POPVAL(LOC);                                 00241700
            END;                                                                00241800
            ;                                                                   00241900
            CALL SEARCH_EXPRESSION(LOC);                                        00242000
            CALL PROCESS_EXTN(POPVAL(LOC));                                     00242100
            ;;;;;;;                                                             00242200
            END;                                                                00242300
      END STACK_OPERAND_VARS;                                                   00242400
                                                                                00242500
GET_REALTIME_ARGS:                                                              00242600
      PROCEDURE;                                                                00242700
         DECLARE (J,OPERAND#) BIT(16), FLAG BIT(8);                             00242800
                                                                                00242900
         IF PROC_TRACE THEN OUTPUT='GET_REALTIME_ARGS('||PTR||')';              00242901
         DO CASE OPCODE - WAIT;                                                 00243000
            IF POPTAG(PTR) ^= 0 THEN DO;         /* WAIT */                     00243100
               CALL STACK_OPERAND_VARS(PTR + 1);                                00243300
               RHS_PTR = GET_EXP_VARS_CELL;                                     00243400
            END;                                                                00243600
            DO;                           /* SGNL */                            00243700
               CALL STACK_OPERAND_VARS(PTR + 1);                                00243710
               IF PTR_INX > 0 THEN LHS_PTR = GET_EXP_VARS_CELL;                 00243720
               ELSE VAR_INX = 0;                                                00243730
            END;                                                                00243740
            DO;                           /* CANC */                            00243800
GET_PROCESS_LABELS:                                                             00243900
               DO J = 1 TO NUMOP;                                               00244000
                  VAR_INX = VAR_INX + 1;                                        00244100
                  EXP_VARS(VAR_INX) = POPVAL(PTR+J);                            00244200
               END;                                                             00244300
               LHS_PTR = GET_EXP_VARS_CELL;                                     00244400
            END;                                                                00244500
            GO TO GET_PROCESS_LABELS;           /* TERM */                      00244600
            DO;                           /* PRIO */                            00244700
               CALL STACK_OPERAND_VARS(PTR+1);                                  00244800
               RHS_PTR = GET_EXP_VARS_CELL;                                     00244900
               IF NUMOP = 2 THEN DO;                                            00245000
                  VAR_INX = 1;                                                  00245100
                  EXP_VARS(VAR_INX) = POPVAL(PTR+2);                            00245200
                  LHS_PTR = GET_EXP_VARS_CELL;                                  00245300
               END;                                                             00245400
            END;                                                                00245500
            DO;                           /* SCHD */                            00245600
               VAR_INX = 0;                                                     00245700
               CALL STACK_OPERAND_VARS(PTR + 1);                                00245710
               LHS_PTR = GET_EXP_VARS_CELL;                                     00245900
               FLAG = POPTAG(PTR);                                              00246000
               OPERAND# = PTR + 1;                                              00246100
               IF (FLAG & 3) ^= 0 THEN DO;                                      00246200
                  OPERAND# = OPERAND# + 1;                                      00246300
                  CALL STACK_OPERAND_VARS(OPERAND#);                            00246400
               END;                                                             00246500
               IF (FLAG & 4) ^= 0 THEN DO;                                      00246600
                  OPERAND# = OPERAND# + 1;                                      00246700
                  CALL STACK_OPERAND_VARS(OPERAND#);                            00246800
               END;                                                             00246900
               IF (FLAG & "20") ^= 0 THEN DO;                                   00247000
                  OPERAND# = OPERAND# + 1;                                      00247100
                  CALL STACK_OPERAND_VARS(OPERAND#);                            00247200
               END;                                                             00247300
               IF (FLAG & "C0") ^= 0 THEN DO;                                   00247400
                  OPERAND# = OPERAND# + 1;                                      00247500
                  CALL STACK_OPERAND_VARS(OPERAND#);                            00247600
               END;                                                             00247700
               RHS_PTR = GET_EXP_VARS_CELL;                                     00247800
            END;                                                                00247900
         END;                                                                   00248000
      END GET_REALTIME_ARGS;                                                    00248100
                                                                                00248200
GET_PMACRO_ARGS:                                                                00248300
      PROCEDURE (LOC);                                                          00248400
         DECLARE (LOC,ARG#,PM_TYPE) BIT(16),                                    00248500
            PM_ARG#(6) BIT(16) INITIAL(0,2,1,2,3,1,3),         /*CR13570*/      00248501
            COPY BIT(8) INITIAL(4), NAMEADD BIT(8) INITIAL(6); /*CR13570*/      00248600
                                                                                00248700
         IF PROC_TRACE THEN OUTPUT='GET_PMACRO_ARGS('||LOC||')';                00248701
         PM_TYPE = POPTAG(LOC);                                                 00248800
         IF PM_ARG#(PM_TYPE) < 2 THEN RETURN;                                   00248900
         LOC = NEXT_OP(HALMAT_PTR(LOC));                                        00249000
         OPCODE = POPCODE(LOC);                                                 00249100
         ARG# = 0;                                                              00249200
         DO WHILE OPCODE ^= PMIN;                                               00249300
            IF OPCODE = PMAR THEN DO;                                           00249400
               DO CASE ARG#;                                                    00249500
                  DO;                                                           00249600
                     CALL STACK_OPERAND_VARS(LOC+1);                            00249700
                     IF PTR_INX > 0 THEN LHS_PTR = GET_EXP_VARS_CELL;           00249800
                     ELSE VAR_INX = 0;                                          00249900
                  END;                                                          00250000
                  CALL STACK_OPERAND_VARS(LOC+1);                               00250100
                  DO;                                                           00250200
                     CALL STACK_OPERAND_VARS(LOC+1);                            00250300
                     IF TYPE_BITS(LOC+1) = LIT THEN                             00250400
                        IF PM_TYPE=COPY | PM_TYPE=NAMEADD THEN DO;              00250500
                        PTR_INX = PTR_INX + 1;                                  00250600
                        EXP_PTRS(PTR_INX)=INTEGER_LIT(POPVAL(LOC+1))|"C0000000";00250700
                     END;                                                       00250800
                  END;                                                          00250900
               END;                                                             00251000
               ARG# = ARG# + 1;                                                 00251100
            END;                                                                00251200
            LOC = NEXT_OP(LOC);                                                 00251201
            OPCODE = POPCODE(LOC);                                              00251202
         END;                                                                   00251300
         RHS_PTR = GET_EXP_VARS_CELL;                                           00251400
      END GET_PMACRO_ARGS;                                                      00251500
                                                                                00251600
ASSIGN_TYPE:                                                                    00251700
      PROCEDURE BIT(8);                                                         00251800
         IF CLASS > 0 & CLASS < 7 THEN                                          00251900
            IF (OPCODE & "FF") = "01" THEN RETURN TRUE;                         00252000
         IF OPCODE = TASN THEN RETURN TRUE;                                     00252100
         IF OPCODE = NASN THEN DO;                                              00252101
            NAME_ASSIGN = TRUE;                                                 00252102
            RETURN TRUE;                                                        00252103
         END;                                                                   00252104
         RETURN FALSE;                                                          00252200
      END ASSIGN_TYPE;                                                          00252300
                                                                                00252400
                                                                                00252500
      IF PROC_TRACE THEN OUTPUT='GET_STMT_VARS('||STMT#||','||PTR||')';         00252501
      NAME_ASSIGN,RHS_PTR,LHS_PTR,VAR_INX,PTR_INX = 0;                          00252600
      DO FOREVER;                                                               00252700
         CALL DECODEPOP(PTR);                                                   00252800
         IF OPCODE=ADLP | OPCODE=DLPE | OPCODE=TDCL | OPCODE=LBL THEN           00252900
            PTR = LAST_OP(PTR);                                                 00253000
         ELSE ESCAPE;                                                           00253100
      END;                                                                      00253200
 /* AN ADDITIONAL CHECK FOR XREC AND PXRC WAS ADDED HERE TO PROHIBIT */         00253201
 /* AN ERRONEOUS ERROR MESSAGE IN ORDER TO CLOSE DR56085  */                    00253202
      IF OPCODE=SMRK | OPCODE=IMRK | OPCODE=CLBL | OPCODE=EDCL |                00253203
         OPCODE=XREC | OPCODE=PXRC THEN RETURN;                                 00253204
      IF ASSIGN_TYPE THEN DO;                                                   00253300
         DO J = PTR+2 TO PTR+NUMOP;                                             00253400
            CALL STACK_OPERAND_VARS(J);                                         00253500
         END;                                                                   00253600
         IF PTR_INX > 0 THEN LHS_PTR = GET_EXP_VARS_CELL;                       00253700
         VAR_INX,PTR_INX = 0;                                                   00253800
         CALL STACK_OPERAND_VARS(PTR+1);                                        00253900
         RHS_PTR = GET_EXP_VARS_CELL;                                           00254000
      END;                                                                      00254100
      ELSE IF OPCODE=FBRA | OPCODE=RTRN THEN DO;                                00254200
         IF NUMOP>0 THEN DO;                                                    00254300
            IF OPCODE=FBRA THEN CALL SEARCH_EXPRESSION(PTR+2);                  00254301
            ELSE CALL SEARCH_EXPRESSION(PTR+1);                                 00254400
            RHS_PTR = GET_EXP_VARS_CELL;                                        00254500
         END;                                                                   00254600
      END;                                                                      00254700
      ELSE IF OPCODE=XXND THEN DO;                                              00254800
         PTR = LAST_OP(PTR);                                                    00254900
         OPCODE = POPCODE(PTR);                                                 00254901
         IF CLASS0(OPCODE) = 8 THEN DO;    /* PROC,FUNC */                      00255000
            PTR_INX = PTR_INX + 1;                                              00255100
            EXP_PTRS(PTR_INX) = HALMAT_PTR(PTR);                                00255200
            RHS_PTR = GET_EXP_VARS_CELL;                                        00255300
         END;                                                                   00255400
         ELSE IF CLASS0(OPCODE) = 9 THEN DO;     /* I/O */                      00255500
            PTR = NEXT_OP(HALMAT_PTR(PTR));                                     00255600
            OPCODE = POPCODE(PTR);                                              00255700
            DO WHILE OPCODE ^= XXND;                                            00255800
               IF (OPCODE=XXAR) & (X_BITS(PTR+1) = 0) THEN                      00255900
                  CALL STACK_OPERAND_VARS(PTR+1);                               00256000
               ELSE IF OPCODE = WRIT THEN RHS_PTR = GET_EXP_VARS_CELL;          00256100
               ELSE IF (OPCODE=READ | OPCODE=RDAL) & PTR_INX>0 THEN             00256200
                  LHS_PTR = GET_EXP_VARS_CELL;                                  00256300
               PTR = NEXT_OP(PTR);                                              00256400
               OPCODE = POPCODE(PTR);                                           00256500
            END;                                                                00256600
         END;                                                                   00256700
      END;                                                                      00256800
      ELSE IF OPCODE=DFOR | OPCODE=AFOR | OPCODE=CFOR THEN DO;                  00256900
         IF DFOR_LOC ^= 0 THEN DO;                                              00257000
            J = DFOR_LOC;                                                       00257100
            DFOR_LOC = 0;                                                       00257200
         END;                                                                   00257300
         ELSE J = PTR;                                                          00257400
         DO WHILE J <= PTR;                                                     00257500
            OPCODE = POPCODE(J);                                                00257600
            IF OPCODE = DFOR THEN DO;                                           00257700
               CALL STACK_OPERAND_VARS(J+2);                                    00257800
               IF PTR_INX > 0 THEN LHS_PTR = GET_EXP_VARS_CELL;                 00257900
               ELSE VAR_INX = 0;                                                00258000
               DO K = J+3 TO J+POPNUM(J);                                       00258100
                  CALL STACK_OPERAND_VARS(K);                                   00258200
               END;                                                             00258300
            END;                                                                00258400
            ELSE IF OPCODE=AFOR | OPCODE=CFOR THEN                              00258401
               CALL STACK_OPERAND_VARS(J+1);                                    00258500
            J = NEXT_OP(J);                                                     00258501
         END;                                                                   00258600
         RHS_PTR = GET_EXP_VARS_CELL;                                           00258700
      END;                                                                      00258800
      ELSE IF OPCODE=CTST | OPCODE=DCAS THEN DO;                                00258900
         CALL STACK_OPERAND_VARS(PTR+NUMOP);                                    00259000
         RHS_PTR = GET_EXP_VARS_CELL;                                           00259100
      END;                                                                      00259200
      ELSE IF OPCODE = PMIN THEN DO;                                            00259300
         CALL GET_PMACRO_ARGS(PTR);                                             00259400
      END;                                                                      00259500
      ELSE IF OPCODE >=WAIT & OPCODE <=SCHD THEN                                00259600
         CALL GET_REALTIME_ARGS;                                                00259700
      ELSE IF OPCODE=ERON THEN DO;                                              00259800
         IF NUMOP = 2 THEN                                                      00259900
            IF TYPE_BITS(PTR+2) ^= INL THEN DO;                                 00260000
            CALL STACK_OPERAND_VARS(PTR+2);                                     00260100
            IF PTR_INX > 0 THEN LHS_PTR = GET_EXP_VARS_CELL;                    00260200
         END;                                                                   00260300
      END;                                                                      00260400
      ELSE IF OPCODE = BRA THEN DO;                                             00260401
         CALL STACK_OPERAND_VARS(PTR+1);                                        00260402
         RHS_PTR = GET_EXP_VARS_CELL;                                           00260403
      END;                                                                      00260404
      ELSE IF OPCODE = XFIL THEN DO;                                            00260405
         CALL STACK_OPERAND_VARS(PTR+2);                                        00260406
         DO CASE X_BITS(PTR+2);                                                 00260407
            IF PTR_INX>0 THEN LHS_PTR = GET_EXP_VARS_CELL;                      00260408
            RHS_PTR = GET_EXP_VARS_CELL;                                        00260409
         END;                                                                   00260410
      END;                                                                      00260411
      ELSE CALL ERRORS (CLASS_BI, 216, ' '||HEX(OPCODE,3));                     00260500
      IF RHS_PTR = 0 THEN                                                       00260600
         IF LHS_PTR = 0 THEN RETURN;                                            00260700
      DO FOREVER;                                                               00260900
         IF STMT_DATA_CELL = - 1 THEN CALL ERRORS (CLASS_BI, 218, ' '||STMT#);  00261000
         CALL LOCATE(STMT_DATA_CELL,ADDR(VMEM_F),0);                            00261100
         CELL_STMT# = SHR(VMEM_F(7),16);                                        00261300
         IF CELL_STMT# = STMT# THEN DO;                                         00261310
            CALL DISP(MODF);                                                    00261320
            VMEM_F(4) = LHS_PTR;                                                00261330
            VMEM_F(5) = RHS_PTR;                                                00261340
            IF NAME_ASSIGN THEN VMEM_F(6) = VMEM_F(6) | "800";                  00261341
            RETURN;                                                             00261345
         END;                                                                   00261350
         STMT_DATA_CELL = VMEM_F(0);                                            00261360
      END;                                                                      00261400
   END GET_STMT_VARS;                                                           00261800
