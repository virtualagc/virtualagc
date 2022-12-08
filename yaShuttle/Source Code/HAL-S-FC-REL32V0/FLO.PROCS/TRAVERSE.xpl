 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   TRAVERSE.xpl
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
 /* PROCEDURE NAME:  TRAVERSE_INIT_LIST                                     */
 /* MEMBER NAME:     TRAVERSE                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          STRI_LOC          BIT(16)                                      */
 /*          TERM_OFFSET       BIT(16)                                      */
 /*          FAST              BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CELL_LOOP_INCR(20)  BIT(16)                                    */
 /*          CELL_LOOP_REPEAT(20)  BIT(16)                                  */
 /*          COPY_OFFSET       BIT(16)                                      */
 /*          CTR               BIT(16)                                      */
 /*          DUMP_LOOP_STACKS(774)  LABEL                                   */
 /*          GET_TERM_INIT_CELL  LABEL                                      */
 /*          J                 BIT(16)                                      */
 /*          LOOP_INCR(20)     BIT(16)                                      */
 /*          LOOP_INX          BIT(16)                                      */
 /*          LOOP_OFFSET(20)   BIT(16)                                      */
 /*          LOOP_PASS(20)     BIT(16)                                      */
 /*          LOOP_PERIOD(20)   BIT(16)                                      */
 /*          LOOP_REPEAT(20)   BIT(16)                                      */
 /*          LOOP_START(20)    BIT(16)                                      */
 /*          PUSH_INIT_VAL_OP  LABEL                                        */
 /*          PUSH_LOOP_END_OP  LABEL                                        */
 /*          PUSH_LOOP_START_OP  LABEL                                      */
 /*          PUSHED_LOOP_STARTS  BIT(16)                                    */
 /*          TEMPL_OFFSET      BIT(16)                                      */
 /*          VAR_REF_CELL      FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BLOCK#                                                         */
 /*          CLASS_BI                                                       */
 /*          ELRI                                                           */
 /*          END_OF_LIST_OP                                                 */
 /*          FOREVER                                                        */
 /*          HALMAT_PTR                                                     */
 /*          IMD                                                            */
 /*          LOOP_END_OP                                                    */
 /*          LOOP_START_OP                                                  */
 /*          MODF                                                           */
 /*          NAME_TERM_TRACE                                                */
 /*          PROC_TRACE                                                     */
 /*          RELS                                                           */
 /*          RESV                                                           */
 /*          SINGLE_COPY                                                    */
 /*          SLRI                                                           */
 /*          STRUCT_COPIES                                                  */
 /*          TEMPL_WIDTH                                                    */
 /*          TINT                                                           */
 /*          TRUE                                                           */
 /*          VMEM_LOC_ADDR                                                  */
 /*          WORD_STACK_SIZE                                                */
 /*          X1                                                             */
 /*          X3                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CELLSIZE                                                       */
 /*          INIT_LIST_HEAD                                                 */
 /*          INIT_WORD_START                                                */
 /*          NEST_LEVEL                                                     */
 /*          OPCODE                                                         */
 /*          SAVE_ADDR                                                      */
 /*          STRUCT_COPY#                                                   */
 /*          TERM_LIST_HEAD                                                 */
 /*          VMEM_F                                                         */
 /*          VMEM_H                                                         */
 /*          WORD_INX                                                       */
 /*          WORD_STACK                                                     */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          DISP                                                           */
 /*          ERRORS                                                         */
 /*          FORMAT                                                         */
 /*          GET_CELL                                                       */
 /*          LOCATE                                                         */
 /*          MOVE                                                           */
 /*          POPCODE                                                        */
 /*          POPVAL                                                         */
 /*          PTR_LOCATE                                                     */
 /*          TYPE_BITS                                                      */
 /* CALLED BY:                                                              */
 /*          DO_EACH_TERMINAL                                               */
 /*          GET_NAME_INITIALS                                              */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> TRAVERSE_INIT_LIST <==                                              */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /*     ==> MOVE                                                            */
 /*     ==> DISP                                                            */
 /*     ==> PTR_LOCATE                                                      */
 /*     ==> GET_CELL                                                        */
 /*     ==> LOCATE                                                          */
 /*     ==> FORMAT                                                          */
 /*     ==> POPCODE                                                         */
 /*     ==> POPVAL                                                          */
 /*     ==> TYPE_BITS                                                       */
 /***************************************************************************/
 /***************************************************************************/
 /*                                                                         */
 /*  DATE      DEV  REL     DR/CR     TITLE                                 */
 /*                                                                         */
 /*  04/12/01  DCP  31V0/   DR111361  NAME INITIALIZATION INFORMATION       */
 /*                 16V0              MISSING IN SDF                        */
 /*                                                                         */
 /*  04/09/01  DCP  31V0/   DR111355  SDFLIST PRINTS WRONG INFORMATION      */
 /*                 16V0                                                    */
 /*                                                                         */
 /***************************************************************************/
                                                                                00212900
 /* ROUTINE TO TRAVERSE A TEMPLATE COLLECTING NAME TERMINAL INITIAL VALUES  */  00213000
TRAVERSE_INIT_LIST:                                                             00213300
   PROCEDURE (STRI_LOC,TERM_OFFSET);                              /*DR111361*/  00213400
      DECLARE (LOOP_INX,STRI_LOC,TEMPL_OFFSET,TERM_OFFSET,COPY_OFFSET) BIT(16), 00213500
         (J,CTR) BIT(16), VAR_REF_CELL FIXED,                     /*DR111361*/  00213600
         PUSHED_LOOP_STARTS BIT(16),                                            00213601
         (LOOP_START,LOOP_INCR,LOOP_REPEAT,LOOP_OFFSET,LOOP_PASS,               00213700
         LOOP_PERIOD,CELL_LOOP_INCR,CELL_LOOP_REPEAT) (20) BIT(16);             00213800
                                                                                00213900
 /* ROUTINES TO STACK TERMINAL INITIAL LIST OPERATORS */                        00214000
                                                                                00214100
                                                                                00214200
PUSH_LOOP_START_OP:                                                             00214300
      PROCEDURE (INX);                                                          00214400
         DECLARE INX BIT(16);                                                   00214401
                                                                                00214402
         WORD_INX = WORD_INX + 2;                                               00214500
         NEST_LEVEL = NEST_LEVEL + 1;                                           00214600
         WORD_STACK(WORD_INX-1) = LOOP_START_OP | NEST_LEVEL;                   00214700
         WORD_STACK(WORD_INX) = SHL(CELL_LOOP_REPEAT(INX),16) |                 00214800
            CELL_LOOP_INCR(INX);                                                00214900
      END PUSH_LOOP_START_OP;                                                   00215000
                                                                                00215100
PUSH_LOOP_END_OP:                                                               00215200
      PROCEDURE;                                                                00215300
         WORD_INX = WORD_INX + 1;                                               00215400
         WORD_STACK(WORD_INX) = LOOP_END_OP | NEST_LEVEL;                       00215500
         NEST_LEVEL = NEST_LEVEL - 1;                                           00215600
         IF NEST_LEVEL < 0 THEN CALL ERRORS (CLASS_BI, 213);                    00215700
      END PUSH_LOOP_END_OP;                                                     00215800
                                                                                00215900
PUSH_INIT_VAL_OP:                                                               00216000
      PROCEDURE (VAR_REF_CELL);                                                 00216100
         DECLARE VAR_REF_CELL FIXED;                                            00216200
                                                                                00216300
         WORD_INX = WORD_INX + 2;                                               00216400
         IF WORD_INX > WORD_STACK_SIZE THEN CALL ERRORS (CLASS_BI, 221);        00216500
         WORD_STACK(WORD_INX-1) = STRUCT_COPY#;                                 00216600
         WORD_STACK(WORD_INX) = VAR_REF_CELL;                                   00216700
      END PUSH_INIT_VAL_OP;                                                     00216800
                                                                                00216900
                                                                                00217000
/* SAVE THE INITIAL LIST WORD INFORMATION FOR THE NAME            /*DR111361*/
/* INITIALIZATION TERMINAL CELL IN THE SDF FOR STRUCTURES         /*DR111361*/
/* DECLARED WITH IMPLIED ARRAYNESS.                               /*DR111361*/
GET_TERM_INIT_CELL:                                                             00217100
      PROCEDURE (VAR_REF_CELL);                                   /*DR111361*/  00217200
         DECLARE VAR_REF_CELL FIXED;                              /*DR111361*/  00217300
                                                                                00217400
         WORD_INX = WORD_INX + 5;                                 /*DR111361*/
         WORD_STACK(WORD_INX-4) = LOOP_START_OP | 1;              /*DR111361*/
         WORD_STACK(WORD_INX-3) = SHL(STRUCT_COPIES,16) | 1;      /*DR111361*/
         WORD_STACK(WORD_INX-2) = SINGLE_COPY;                    /*DR111361*/
         WORD_STACK(WORD_INX-1) = VAR_REF_CELL;                   /*DR111361*/
         WORD_STACK(WORD_INX)   = LOOP_END_OP | 1;                /*DR111361*/

      END GET_TERM_INIT_CELL;                                                   00219900
                                                                                00219901
DUMP_LOOP_STACKS:                                                               00219902
      PROCEDURE;                                                                00219903
         DECLARE J BIT(16);                                                     00219904
                                                                                00219905
         IF LOOP_INX = 0 THEN RETURN;                                           00219906
OUTPUT = '#  START  INCR  REPEAT  OFFSET  PASS  PERIOD  CELL INCR  CELL REPEAT';00219920
         DO J = 1 TO LOOP_INX;                                                  00219921
         OUTPUT = J||X3||FORMAT(LOOP_START(J),4)||'  '||FORMAT(LOOP_INCR(J),4)||00219922
               X3||FORMAT(LOOP_REPEAT(J),5)||X3||FORMAT(LOOP_OFFSET(J),5)       00219923
               ||X1||FORMAT(LOOP_PASS(J),5)||X3||FORMAT(LOOP_PERIOD(J),5)||     00219924
               '       '||FORMAT(CELL_LOOP_INCR(J),4)||'        '||             00219925
               FORMAT(CELL_LOOP_REPEAT(J),5);                                   00219926
         END;                                                                   00219927
      END DUMP_LOOP_STACKS;                                                     00219928
                                                                                00219929
                                                                                00220000
      IF PROC_TRACE THEN OUTPUT='TRAVERSE_INIT_LIST('||BLOCK#||':'||            00220001
         STRI_LOC||','||TERM_OFFSET||')';                                       00220002
      STRUCT_COPY# = 1;                                                         00220100
      CTR = HALMAT_PTR(STRI_LOC);                                               00220200
      PUSHED_LOOP_STARTS, NEST_LEVEL, COPY_OFFSET, LOOP_INX = 0;                00220300
      DO FOREVER;                                                               00220400
         OPCODE = POPCODE(CTR);                                                 00220500
         IF OPCODE = SLRI THEN DO;                                              00220600
            IF LOOP_START(LOOP_INX) ^= CTR THEN DO;                             00220700
               LOOP_INX = LOOP_INX + 1;                                         00220800
               LOOP_START(LOOP_INX) = CTR;                                      00220900
               LOOP_INCR(LOOP_INX) = POPVAL(CTR+2);                             00221000
               LOOP_REPEAT(LOOP_INX) = POPVAL(CTR+1);                           00221100
               LOOP_OFFSET(LOOP_INX) = LOOP_OFFSET(LOOP_INX-1);                 00221200
               LOOP_PASS(LOOP_INX) = 0;                                         00221300
               IF ^IN_IDLP THEN DO;                               /*DR111361*/  00221400
                  LOOP_PERIOD(LOOP_INX) = HALMAT_PTR(CTR+1);                    00221500
                  CELL_LOOP_REPEAT(LOOP_INX)=SHR(HALMAT_PTR(CTR+2),16);         00221600
                  CELL_LOOP_INCR(LOOP_INX)=HALMAT_PTR(CTR+2) & "FFFF";          00221700
               END;                                                             00221900
               IF NAME_TERM_TRACE THEN CALL DUMP_LOOP_STACKS;                   00221901
            END;                                                                00222000
            CTR = HALMAT_PTR(CTR);                                              00222100
         END;                                                                   00222200
         ELSE IF OPCODE = ELRI THEN DO;                                         00222300
            LOOP_PASS(LOOP_INX) = LOOP_PASS(LOOP_INX) + 1;                      00222400
            IF ^IN_IDLP THEN                                      /*DR111361*/  00222401
               IF CELL_LOOP_REPEAT(LOOP_INX) > 1 THEN                           00222500
               IF LOOP_PASS(LOOP_INX) = LOOP_PERIOD(LOOP_INX) THEN DO;          00222600
               IF LOOP_INX<=PUSHED_LOOP_STARTS THEN                             00222610
                  CALL PUSH_LOOP_END_OP;                                        00222700
               J = (CELL_LOOP_REPEAT(LOOP_INX)-1) * LOOP_PERIOD(LOOP_INX);      00222701
               LOOP_PASS(LOOP_INX) = LOOP_PASS(LOOP_INX) + J;                   00222800
               LOOP_OFFSET(LOOP_INX) = LOOP_OFFSET(LOOP_INX) +                  00222901
                  (J * LOOP_INCR(LOOP_INX));                                    00222902
               CELL_LOOP_REPEAT(LOOP_INX) = 0;                                  00223000
            END;                                                                00223100
            IF LOOP_PASS(LOOP_INX) = LOOP_REPEAT(LOOP_INX) THEN DO;             00223200
               IF NAME_TERM_TRACE THEN CALL DUMP_LOOP_STACKS;                   00223201
               IF LOOP_INX <= PUSHED_LOOP_STARTS THEN                           00223202
                  PUSHED_LOOP_STARTS, LOOP_INX = LOOP_INX - 1;                  00223203
               ELSE LOOP_INX = LOOP_INX - 1;                                    00223300
               CTR = HALMAT_PTR(CTR);                                           00223400
            END;                                                                00223500
            ELSE DO;                                                            00223600
               LOOP_OFFSET(LOOP_INX)=LOOP_OFFSET(LOOP_INX)+LOOP_INCR(LOOP_INX); 00223700
               CTR = LOOP_START(LOOP_INX);                                      00223800
            END;                                                                00223900
         END;                                                                   00224000
         ELSE IF OPCODE = TINT THEN DO;                                         00224100
/*D111361*/ TEMPL_OFFSET = POPVAL(CTR+1) + LOOP_OFFSET(LOOP_INX) - COPY_OFFSET; 00224200
            DO WHILE TEMPL_OFFSET >= TEMPL_WIDTH;                               00226400
               TEMPL_OFFSET = TEMPL_OFFSET - TEMPL_WIDTH;                       00226500
               COPY_OFFSET = COPY_OFFSET + TEMPL_WIDTH;                         00226600
               STRUCT_COPY# = STRUCT_COPY# + 1;                                 00226700
            END;                                                                00226800
            IF TEMPL_OFFSET = TERM_OFFSET THEN                                  00226900
               IF TYPE_BITS(CTR+2) ^= IMD THEN DO;                              00226910
               IF IN_IDLP THEN                                    /*DR111361*/
                  CALL GET_TERM_INIT_CELL(HALMAT_PTR(CTR+2));     /*DR111361*/
               ELSE DO;                                           /*DR111361*/
                  DO J = PUSHED_LOOP_STARTS+1 TO LOOP_INX;                      00226920
                     IF CELL_LOOP_REPEAT(J) > 1 THEN           /*DR111355*/
                        CALL PUSH_LOOP_START_OP(J);                             00226930
                  END;                                                          00226940
                  CALL PUSH_INIT_VAL_OP(HALMAT_PTR(CTR+2));                     00227000
               END;                                               /*DR111361*/
               PUSHED_LOOP_STARTS = LOOP_INX;                     /*DR111361*/  00226950
            END;                                                                00227001
            CTR = HALMAT_PTR(CTR);                                              00227101
         END;                                                                   00227200
         ELSE RETURN;                                                           00227300
      END;                                                                      00227400
   END TRAVERSE_INIT_LIST;                                                      00227500
