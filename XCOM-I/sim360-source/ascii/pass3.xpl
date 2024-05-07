
   /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    *                                                                     *
    *                                                                     *
    *                                                                     *
    *                      P A S C A L   3 6 0 - 3 7 0                    *
    *                                                                     *
    *                         P A S S   T H R E E                         *
    *                                                                     *
    *                           CHARLES R. HILL                           *
    *                    DEPARTMENT OF COMPUTER SCIENCE                   *
    *                       S.U.N.Y. AT STONY BROOK                       *
    *                                                                     *
    *                                                                     *
    *                                                                     *
    *                                                                     *
    *         THE FUNCTION OF PASS 3 IS TO GENERATE RELOCATABLE IBM 360-  *
    *    370 MACHINE CODE FROM THE PSEUDO-MACHINE INSTRUCTIONS KNOWN      *
    *    AS TRIPLES, WHICH ARE GENERATED IN PASS2.  AT THE END OF PASS2   *
    *    THE ENTIRE SEMANTIC CONTENT OF THE ORIGINAL PASCAL PROGRAM IS    *
    *    EMBEDDED IN THE TRIPLES, AND IN THREE COLUMNS OF THE SYMBOL      *
    *    TABLE:    STORAGE_LENGTH, PSEUDO_REG,DISP.                       *
    *                                                                     *
    *         THE PASS 3 PROGRAM MODULES ARE AS FOLLOWS:
    *    1) A MODULE FOR DEBUGGING & ROUTINE MAINTAINENCE                 *
    *    2) A REGISTER ALLOCATION MODULE WHICH PROVIDES PRIMITIVES FOR    *
    *       GETTING INDEX REGISTERS, ACCUMULATOR REGISTERS, FLOATING      *
    *       POINT REGS, DOUBLE REGS, AND RUNTIME TEMPORARIES              *
    *    3) CODE EMISSION PROCEDURES                                      *
    *    4) ADDRESSABILITY PROCEDURES                                     *
    *    5) INITIALIZATION AND INTERPASS COMMUNICATION ROUTINES           *
    *    6) CODE GENERATION MODULE                                        *
    *                                                                     *
    *         SPECIFICALLY, PASS 3 DOES THE FOLLOWING:                    *
    *    1)   BRING IN THE SYMBOL TABLE FROM AUXILARY STORAGE.            *
    *    2)   FOR EACH PASCAL PROCEDURE, BRING IN ITS CORRESPONDING SET   *
    *    OF TRIPLES, GENERATE CODE FOR THE PROCEDURE, AND SWAP THE RE-    *
    *    SULTING CODE OUT TO AUX STORAGE. CODE GENERATION CONSISTS OF     *
    *    A CASE ON THE TRIPLE OPERATION CODES.                            *
    *    3)   EACH ENTRY POINT AND NON-LOCAL BRANCH TARGET OF A PRO-      *
    *    CEDURE IS GIVEN AN ENTRY IN THE  TRANSFER VECTOR.
    *    4)  A CORE IMAGE IS BUILT CONTAINING MULTIPLES OF 4096, THE      *
    *       TRANSFER VECTOR, VARIOUS  INSTRUCTION SEQUENCES & CONSTANTS,  *
    *       AND SWAPPED OUT. THIS SEGMENT IS KNOWN AS THE ORG SEGMENT.    *
    *                                                                     *
    *                                                                     *
    * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * /

   /*
      PASS3, VERSION 1, RELEASE 0, MAY 1976
     COPYRIGHT (C) 1976 DEPARTMENT OF COMPUTER SCIENCE, SUNY AT STONY BROOK
                                                                             */



   /*              G L O B A L    D E C L A R A T I O N S          */




      /*       CONVENIENT ABBREVIATIONS USED FOR FORMATTING OF OUTPUT    */

      DECLARE X1 CHARACTER INITIAL (' '),
              X70 CHARACTER INITIAL (
    '                                                                      ');

      DECLARE SPACE LITERALLY 'SUBSTR(X70,0,';  /*  USED FOR SPACING  */
      DECLARE X LITERALLY ')';
      DECLARE LINE_FEED LITERALLY 'OUTPUT=X70';
      DECLARE DOUBLE_SPACE LITERALLY 'OUTPUT(1)=0';




      /*   THE FOLLOWING ARE USED TO COUNT CALLS TO IMPORTANT PROCEDURES
           DURING COMPILATION (FOR PREPARING COMPILER STATISTICS)     */
      DECLARE ( #FREE_TEMP,#GET_REG,#FLUSH_REG,#STORE_REG,#MAKE_OP_ADDR,
                #FLUSH_ALL_TEMP_REGS,#STM_FLUSHES,#EMIT_RR,#EMIT_RX,#EMIT_SS)
                BIT(16);
      DECLARE INSTRUCTION (255) BIT(16);   /*   USED TO COUNT INSTRUCTIONS  */


      /*  MISCELLANEOUS    */

      DECLARE TRUE LITERALLY '1', FALSE LITERALLY '0';
      DECLARE FOREVER LITERALLY ' WHILE 1 ';
      DECLARE ( I,J ) FIXED;
      DECLARE TPTR BIT(16);
      DECLARE STRING CHARACTER;
      DECLARE POWER BIT(16);
      DECLARE COMPILING BIT(1);
      DECLARE TIME_ENTERED FIXED;      /*  TIME OF ENTRY INTO PASS 3     */
      DECLARE LIST_INSTRUCTIONS BIT(1),
              PROC_NAME CHARACTER,
              STATISTICS BIT(1),
              CPU_CLOCK FIXED;

      /*    CODE ARRAY   */
      DECLARE CODE_ARRAY_SIZE LITERALLY '14399';
      DECLARE CODE_INDEX FIXED;  /* FORCES FULLWORD ALIGNMENT OF CODE ARRAY   */
      DECLARE CODE (CODE_ARRAY_SIZE) BIT(8);


      /*  USED FOR SYMBOLIC LISTINGS OF CODE      */



 /*        OPNAMES & OPNAMES2 ARE STRINGS CONTAINING MNEUMONIC OP CODES
           USED IN PASS 3 FOR GENERATING SYMBOLIC LISTINGS OF CODE.
           TO OBTAIN THE MNEUMONIC FOR A GIVEN INSTRUCTION, INDEX OPER
           USING THE HEX-CODE, YIELDING THE REQUIRED INDEX INTO OPNAMES
           OR OPNAMES2                                 */



   DECLARE OPNAMES CHARACTER INITIAL ('    BALRBCTRBCR LPR LNR LTR LCR NR  CLR O
R  XR  LR  CR  AR  SR  MR  DR  ALR SLR LA  STC IC  EX  BAL BCT BC  CVD CVB ST  N
   CL  O   X   L   C   A   S   M   D   AL  SL  SRL SLL SRA SLA SRDLSLDLSRDASLDAS
TM TM  MVI NI  CLI OI  XI  LM  MVC STH LH  STE CH  MH  ');

      DECLARE OPNAMES2 CHARACTER INITIAL ('AH  SH  LCERLPERLER LE  CER CE  DER D
E  SER SE  AER AE  MER ME  NC  CLC OC  XC  LD  AD  LCDRAW  SDR LTDRSTD AP  ');


    DECLARE OPER(255) BIT(16) INITIAL (
 /*0**/   0,  0,  0,  0,  0,  4,  8, 12,  0,  0,  0,  0,  0,  0,  0,  0,
 /*1**/  16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 64, 68, 72, 76,
 /*2**/   0,  0,356,344,  0,  0,  0,  0,  0,  0,  0,352,  0,  0,  0,  0,
 /*3**/ 268,  0,  0,264,  0,  0,  0,  0,272,280,304,296,312,288,  0,  0,
 /*4**/ 236, 80, 84, 88, 92, 96,100,104,240,248,256,260,252,  0,108,112,
 /*5**/ 116,  0,  0,  0,120,124,128,132,136,140,144,148,152,156,160,164,
 /*6**/ 360,  0,  0,  0,  0,  0,  0,  0,336,  0,340,  0,  0,  0,348,  0,
 /*7**/ 244,  0,  0,  0,  0,  0,  0,  0,  276,284,308,300,316,292,0,  0,
 /*8**/   0,  0,  0,  0,  0,  0,  0,  0,168,172,176,180,184,188,192,196,
 /*9**/ 200,204,208,  0,212,216,220,224,228,  0,  0,  0,  0,  0,  0,  0,
 /*A**/   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
 /*B**/   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
 /*C**/   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
 /*D**/   0,  0,232,  0,320,324,328,332,  0,  0,  0,  0,  0,  0,  0,  0,
 /*E**/   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
 /*F**/   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,364,  0,  0,  0,  0,  0);
 /*      *0  *1  *2  *3  *4  *5  *6  *7  *8  *9  *A  *B  *C  *D  *E  *F  */

   DECLARE OP_CODE CHARACTER;  /* FOR DEBUG PRINTOUT */


      /*   360-370 OPERATION CODE MNEUMONICS   */

      DECLARE BC FIXED INITIAL ("47"), BCR FIXED INITIAL ("07");
      DECLARE BAL FIXED INITIAL ("45"), BALR FIXED INITIAL ("05");
      DECLARE LOAD LITERALLY ' "58" ', ST LITERALLY '"50"';
      DECLARE C FIXED INITIAL("59"), CR FIXED INITIAL("19");
      DECLARE CH BIT(16) INITIAL ("49");
      DECLARE LA LITERALLY '"41"';
      DECLARE STM FIXED INITIAL ("90"),LM FIXED INITIAL ("98");
      DECLARE MVC LITERALLY ' "D2" ';
      DECLARE LR FIXED INITIAL ("18"), SR BIT(16) INITIAL ("1B");
      DECLARE BCTR FIXED INITIAL ("06"),BCT BIT(16) INITIAL("46");
      DECLARE EX FIXED INITIAL ("44"),LH FIXED INITIAL ("48");
      DECLARE IC FIXED INITIAL ("43");    /*  INSERT CHARACTER   */
      DECLARE SLA BIT(16) INITIAL ("8B");   /*  ARITH SHIFT LEFT   */
      DECLARE SLDL BIT(16) INITIAL ("8D"),SRDA BIT(16) INITIAL ("8E");
      DECLARE LPR BIT(16) INITIAL ("10"),LCR BIT(16) INITIAL ("13");
      DECLARE M BIT(16) INITIAL ("5C"),MR BIT(16) INITIAL ("1C");
      DECLARE MH BIT(16) INITIAL ("4C"),AH BIT(16) INITIAL ("4A");
      DECLARE A BIT(16) INITIAL ("5A"), AR BIT(16) INITIAL ("1A"),
              D BIT(16) INITIAL ("5D"), DR BIT(16) INITIAL ("1D"),
              S BIT(16) INITIAL ("5B"), SH BIT(16) INITIAL ("4B");
      DECLARE LTR BIT(16) INITIAL ("12");
      DECLARE ME   BIT(16) INITIAL("7C"),MER  BIT(16) INITIAL("3C"),
              AE   BIT(16) INITIAL("7A"),AER  BIT(16) INITIAL("3A"),
              SE   BIT(16) INITIAL("7B"),SER  BIT(16) INITIAL("3B"),
              DE   BIT(16) INITIAL("7D"),DER  BIT(16) INITIAL("3D"),
              CE   BIT(16) INITIAL("79"),CER  BIT(16) INITIAL("39"),
              LE   BIT(16) INITIAL("78"),LER  BIT(16) INITIAL("38"),
              LPER BIT(16) INITIAL("30"),LCER BIT(16) INITIAL("33");
      DECLARE CLI BIT(16) INITIAL ("95");
      DECLARE XOR BIT(16) INITIAL ("57"), N BIT(16) INITIAL ("54");
      DECLARE SLL BIT(16) INITIAL ("89"),SRL BIT(16) INITIAL ("88");
      DECLARE CLC BIT(16) INITIAL ("D5"), XC BIT(16) INITIAL ("D7"),
              OC BIT(16) INITIAL ("D6"), NC BIT(16) INITIAL ("D4");
      DECLARE LD   BIT(16) INITIAL("68"),AD   BIT(16) INITIAL ("6A"),
              LCDR BIT(16) INITIAL("23"),AW   BIT(16) INITIAL ("6E"),
              STD  BIT(16) INITIAL("60"),STE  BIT(16) INITIAL ("70"),
              STH  BIT(16) INITIAL("40"),STC  BIT(16) INITIAL ("42"),
              LTDR BIT(16) INITIAL("22"),SDR  BIT(16) INITIAL ("2B");
      DECLARE AP BIT(16) INITIAL("FA"), MVI BIT(16) INITIAL ("92");
      DECLARE SRDL BIT(16) INITIAL ("8C");
      DECLARE TM BIT(16) INITIAL("91"),OI BIT(16) INITIAL("96");



      /*   REGISTER ALLOCATION & TEMPORARY MANAGEMENT VARIABLES     */

      DECLARE LAST_TEMP LITERALLY 'NEXT_TEMP-1';
 DECLARE FIX_BASE_REG_PRIORITIES LITERALLY
      ' DO; IF X_REG ~= 0 THEN PRIORITY(X_REG)=FIXED_PRIORITY;IF BASE_REG~=0
THEN PRIORITY(BASE_REG)=FIXED_PRIORITY;END;'  ;
     DECLARE CONTENT(22) FIXED,
             PRIORITY(22) BIT(16),
             USE(22) FIXED,
             FREE_PRIORITY BIT (8) INITIAL (0),
             BASE_PRIORITY BIT(8) INITIAL (1),
             TEMP_PRIORITY BIT(8) INITIAL (2),
             FIXED_PRIORITY BIT(8) INITIAL (3),
             #GP_REGS LITERALLY '16',
             NONE LITERALLY '-1',     /*  FOR NOW   */
             NULL LITERALLY '-1',
             STACKTOP_PSEUDO_REG LITERALLY '100',
             MARKED_FREE BIT(16) INITIAL (200),
              NEXT_TEMP_DISPL FIXED,
              NEXT_TEMP_DISPL_STACK (64) FIXED,   /*  USED FOR REMEMBERING
                 NEXT_TEMP_DISPL DURING NESTED PROCEDURE CALLS       */
              AR_OFFSET FIXED,
              TEMP_DISPL_STACKTOP FIXED;



      /*   GENERAL REGISTERS 11 - 15 ARE FIXED PRIORITY REGISTERS.
            THEY ARE ASSIGNED AS FOLLOWS:                */
      DECLARE
         CURRENT_AR_BASE LITERALLY '11',    /* CURRENT ACTIVATION REC PTR  */
         CODE_BASE LITERALLY '12',          /* BASE OF CURRENT CODE SEGMENT */
         STACKTOP LITERALLY '13',           /*  TOP OF RUN-TIME STACK  */
         GLOBAL_AR_BASE LITERALLY '14',     /*  BASE OF RUN-TIME STACK  */
         ORG LITERALLY '15';           /*  ORIGIN OF RUN-TIME STORAGE AREA  */
      DECLARE HI_REG LITERALLY '10';


     /*  GLOBALS USED TO MAKE AN OPERAND ADDRESSABLE        */
      DECLARE  (
         OP_STORAGE_LENGTH,     /*  STORAGE LENGTH OF LAST ADDRESSED OPERAND */
         BYTE_XREG,
         DISPL,
         ACC,
         ACC1,
         X_REG,
         BASE_REG1,
         X_REG1,
         DISPL1,
         BASE_REG2,
         DISPL2,
         BASE,
         EVEN_REG,
         ODD_REG,
         FLT_REG,
         FLT_ACC,
         OP_MASK,
         BASE_REG   ) FIXED,
         LINK LITERALLY '10';
      DECLARE IN_REG BIT(1),   /* INDICATES AN OP IS IN A REGISTER (ACC) */
              IN_FREE_REG BIT(1),
              FORMAL_PARAMETER BIT(1),
              IMMEDIATE BIT(1);    /*  INDICATES OPERAND IS IMMEDIATE.    */



      /*   THE FOLLOWING DEFINE THE RELATIVE DISPLACEMENTS FROM ORG OF
           RUN-TIME DATA STRUCTURES LOCATED IN THE ORG SEGMENT         */

      DECLARE MAX_TOP BIT(16) INITIAL(4);  /* WILL CONTAIN THE MAXIMUM
              VALUE THE STACKTOP MAY ACHIEVE BEFORE COLLIDING WITH THE HEAP
              POINTER. THIS VALUE IS UPDATED WHENEVER THE HEAP POINTER
              IS CHANGED & IS ALWAYS EQUAL TO HEAP_POINTER - MAX_TEMP_DISPL. */
      DECLARE MULT_OF_4096_BASE LITERALLY '8',
              MVC_INSTR BIT(16) INITIAL (136),  /*  WILL CONTAIN A MVC TO BE EX'
              MVC     20(0,10),20(9)                AT RUN TIME, TO BE USED FOR
                                                   COPYING DISPLAYS        */
              /*   WORKING STORAGE   */
              DS1 BIT(16) INITIAL (144),

         /*  USED FOR INLINE FLT PT/INTEGER ROUTINES   */
              CONP5 BIT(16) INITIAL (152),   /*      DC    E'0.5'      */
              DS4E BIT(16) INITIAL (160),   /*   DC   '4E',7X'00'    */
              CONSTD0 BIT(16) INITIAL (168),   /*   DC    D'0'        */
              CON4E BIT(16) INITIAL (176),    /*   DC    '4E',7X'00'   */

              CONST1 BIT(16) INITIAL (184),         /*   BINARY 1      */
              DEC1   BIT(16) INITIAL (188),     /* DECIMAL 1 USED FOR
                                                   INCREMENTING BLOCK COUNTERS*/
              CONSTM1 BIT(16) INITIAL(192),   /*   A DOUBLEWORD CONST -1  */
              SET_MASKS BIT(16) INITIAL(200),   /* USED BY INTO TRIPLE   */
              PASCAL_REGS BIT(16) INITIAL(208),   /*  SAVE AREA FOR GEN REGS */
              MON_BASE_REGS BIT(16) INITIAL(272), /*  BASE ADDRESSES OF THE
                 SERVICE MONITOR       */
              MEM_OVERFLOW BIT(16) INITIAL(284),  /*  MEM OVERFLOW ERR ENTRY */
              SUBRANGE_ERROR BIT(16) INITIAL (296), /*  ENTRY FOR RANGE ERROR */
              BLOCK_COUNTER_BASE BIT(16) INITIAL(308),
              TRANSFER_VECTOR_BASE FIXED;   /*  VALUE DEPENDS ON THE NUMBER
              OF BLOCK COUNTERS, WHICH IS RECEIVED FROM PASS 2 .
              TRANSFER_VECTOR_BASE IS INITIALED IN RESTORE_SY_TABLE    */


      /*   SYMBOL TABLE DECLARATIONS             */
      DECLARE MAX_TEMP LITERALLY '950',          /* WB */
 /* WB */     BASE_TEMP LITERALLY '851', /* DEFINE TEMP AREA OF SYMBOL TABLE  */
              NEXT_TEMP FIXED;
      DECLARE SYMBOL_TABLE_SIZE LITERALLY '1050';          /* WB */
      DECLARE MULT_OF_4096_TABLE_BASE LITERALLY '951';     /* WB */

      DECLARE DBR_TABLE_BASE LITERALLY '984';   /*  DENOTES INDEX INTO (* WB *)
           SYMBOL TABLE OF FIRST DATA BASE PSEUDO REG              */

      DECLARE PSEUDO_REG (MAX_TEMP) BIT(16),
              DISP (MAX_TEMP) FIXED,             /* WB */
              STORAGE_LENGTH (MAX_TEMP) FIXED,
              REG (SYMBOL_TABLE_SIZE) BIT(16);




      /*  THE TRANSFER VECTOR IS A VECTOR OF ADDRESSES USED TO TRANSFER
          CONTROL FROM ONE CODE SEGMENT TO ANOTHER DURING EXECUTION.
          A CORE IMAGE CONTAINING RELATIVE ADDRESSES IS BUILT DURING
          PASS 3, AND SWAPPED OUT AT THE END OF THE PASS WITH THE ORG SEGMENT.
          THE LOADER WILL ADD THE RELOCATION CONSTANT TO EACH ADDRESS AFTER
          IT HAS SWAPPED IN THE ORG SEGMENT AT LOAD TIME        */


      DECLARE TRANSFER_VECTOR_SIZE LITERALLY '300',
              TRANSFER_VECTOR (TRANSFER_VECTOR_SIZE ) FIXED;



     /*   THE TRIPLES ARRAY CONTAINS THE PSEUDO-MACHINE INSTRUCTIONS
          KNOWN AS TRIPLES, WHICH ARE GENERATED IN PASS2.  THE FORMAT
          OF A TRIPLE IS AS FOLLOWS:

             BYTE 1  - LENGTH CODE (LENGTH - 1)
             BYTE 2 - OPERATION CODE
             2ND HALFWORD - OPERAND 1
             3RD HALFWORD - OPERAND 2

          THE FIRST TWO BITS OF EACH OPERAND FORM A MASK, WHICH HAS
          THE FOLLOWING MEANINGS:

             00 - SYMBOL TABLE POINTER
             01 - IMMEDIATE OPERAND
             10 - TRIPLE (TEMP)
             11 - TRIPLE (TEMP NOT FREED)                         */

      DECLARE TRIPLES(7199) BIT(16),   /*   TRIPLES ARRAY   */
               OP1 LITERALLY 'TRIPLES(CURRENT_TRIPLE + 1) ',   /*  1ST OP  */
               OP2 LITERALLY 'TRIPLES( CURRENT_TRIPLE + 2)',    /*  2ND OP */
               CURRENT_TRIPLE BIT(16);


      /*  MASKS USED FOR PROCESSING THE TRIPLES          */

      DECLARE SY_TABLE_PTR BIT(16) INITIAL (0),
              TRIPLE_PTR BIT(16) INITIAL (2),
              TEMP_MASK BIT(16) INITIAL(3),
              TRIPLE_OP_MASK BIT(16) INITIAL ("7F"),  /* OBTAINS TRIPLE OP  */
              STRIPMASK LITERALLY ' "3FFF" ';  /*  USED TO STRIP OFF OP MASK  */



      /*   TRIPLES REFERRED TO BY NAME         */

      DECLARE INDEX BIT(16) INITIAL (5),
              TEMP_TRIPLE BIT(16) INITIAL(6),
              BNZ_TRIPLE BIT(16) INITIAL (33),
              S_LENGTH BIT(16) INITIAL (57),
              BCH_TARGET BIT(16) INITIAL(4),
              ADDR_TEMP LITERALLY '62',
              PEND BIT(16) INITIAL (40);



      /*   USED FOR PROCESSING PROCEDURE CALLS AND BRANCHES     */

      DECLARE ENTRY_POINT FIXED;   /*  THE DISPLACEMENT OF THE FIRST INSTRUCTION
              OF THE CURRENT PROCEDURE RELATIVE TO THE BASE OF THE ENTIRE
              PROGRAM CODE SEGMENT.  WHEN CODE_GENERATION IS COMPLETE,
              ENTRY_POINT WILL CONTAIN THE ENTRY INTO THE MAIN PROCEDURE    */
      DECLARE CURRENT_LEVEL FIXED;  /*  LEX LEVEL OF CURRENT PROC  */
      DECLARE STATIC_DISPLAY_SIZE BIT(16);
      DECLARE (OPERAND1,OPERAND2 ) FIXED;
      DECLARE OWNER LITERALLY 'STORAGE_LENGTH';
      DECLARE CURRENT_PROCEDURE LITERALLY 'TRIPLES(0)';
      DECLARE CURRENT_PROC_SEQ# FIXED;

      /*   USED IN MONITOR CALLS     */
      DECLARE SERVICE_CODE BIT(16);

      /*   CONDITION CODE MASKS   */
      DECLARE BH  BIT(16) INITIAL ( 2),
              BL  BIT(16) INITIAL ( 4),
              BNE BIT(16) INITIAL ( 7),
              BE  BIT(16) INITIAL ( 8),
              BNL BIT(16) INITIAL (11),
              BNH BIT(16) INITIAL (13),
              UNCOND BIT(16) INITIAL(15);


      /*     GLOBAL VARIABLES PASSED TO PASS THREE         */

      DECLARE LIST_CODE BIT(1);   /*  FLAGS WHETHER GENERATED CODE &ZTRIPLES
              SHOULD BE LISTED       */
      DECLARE N_DECL_SYMB FIXED;   /*  # OF DECLARED SYMBOLS IN USER PROG  */
      DECLARE NEXT_SEQ# FIXED;
      DECLARE #BASIC_BLOCKS FIXED;


      /*   INTERPASS COMMUNICATION VARIABLES       */

     /*   VARIABLES USED IN PASS 3 OUTPUT ROUTINES   */
      DECLARE CODE_FILE BIT(16) INITIAL (3);
      DECLARE ORG_FILE BIT(16) INITIAL(4);
      DECLARE CODE_TEXT CHARACTER INITIAL ( '                                   
                                                                            ' );
     /*   VARIABLES USED IN PASS 3  INPUT ROUTINES   */
      DECLARE SY_TEXT CHARACTER;                           /* WB */
      DECLARE SY_FILE BIT(16) INITIAL(2),
              TRIPLES_FILE BIT(16) INITIAL(3);

      /*   VARIABLES PASSED TO LOADER     */
      DECLARE MAX_TEMP_DISPL FIXED;   /*   CONTAINS MAX VALUE OF
              NEXT_TEMP_DISPL THRU-OUT ENTIRE PROGRAM. USED TO COMPUTE THE
              MAXIMUM VALUE THE STACKTOP MAY ACHIEVE DURING EXECUTION   */
              /*   TRANSFER_VECTOR_BASE IS ALSO PASSED     */


      /*   VARIABLES USED FOR HANDLING LINE NUMBER INFORMATION    */
      DECLARE CURRENT_LINE# FIXED,
              LINE#MASK BIT(16) INITIAL("80"),   /* PICKS OUT LINE# BIT   */
              LINE#BUFF(20) FIXED,   /*  BUFFER FOR LINE# INFORMATION  */
              LINE_BUFF_PTR BIT(16),   /*   PTR FOR ABOVE BUFFER   */
              LINE#FILE BIT(16) INITIAL (6),   /*   FILE USED FOR LINE#S */
              LINE_NUMS CHARACTER;   /*   "DESCRIPTOR" FOR LINE#BUFF   */
      DECLARE END_COMPILATION LABEL;



      /*    END OF GLOBAL  DECLARATIONS        */





  /*     D E B U G G I N G  &   M A I N T A I N A N C E   R O U T I N E S    */


 PRINT_TIME: PROCEDURE (TIME,MESSAGE);
      DECLARE (TIME,L) FIXED, (MESSAGE,STRING) CHARACTER;
      STRING = TIME; L = LENGTH (STRING);
      IF L < 5 THEN STRING = SUBSTR('00000',0,5 - L) || STRING;
      STRING = '0' || SUBSTR(STRING,0,3) || '.' || SUBSTR(STRING,3,2);
      OUTPUT(1) = STRING || MESSAGE;
 END PRINT_TIME;
 ERROR: PROCEDURE (MESSAGE);
      DECLARE MESSAGE CHARACTER;
      OUTPUT = '* * * COMPILER ERROR: ' || MESSAGE || ',';
      OUTPUT = SPACE 7X || 'WHILE GENERATING CODE FOR PROCEDURE ' ||
         PROC_NAME || ' NEAR LINE ' || CURRENT_LINE#;
      MONITOR_LINK(0) = NULL;   /*   INHIBIT EXECUTION   */
      GOTO END_COMPILATION;     /*  BREAK FROM COMPILATION LOOP   */
 END ERROR;


 PAD: PROCEDURE (STRING,WIDTH) CHARACTER;

      DECLARE STRING CHARACTER, (WIDTH,L) FIXED;

      DO WHILE LENGTH(STRING) + 70 < WIDTH;
         STRING = STRING || X70;
      END;
      L = LENGTH(STRING);
      IF L >= WIDTH THEN RETURN (STRING);
      ELSE RETURN STRING || SUBSTR(X70,0,WIDTH - L);

 END PAD;


 I_FORMAT: PROCEDURE (NUMBER,WIDTH) CHARACTER;

      /*    PREPARES A FIELD OF THE GIVEN WIDTH ,INSERTING GIVEN
            INTEGER RIGHT JUSTIFIED.                      */

      DECLARE (NUMBER,WIDTH) FIXED,STRING CHARACTER;

      STRING = NUMBER;
      IF LENGTH(STRING) >= WIDTH THEN RETURN STRING;
      RETURN (SPACE (WIDTH - LENGTH(STRING) ) X || STRING );
 END I_FORMAT;

 PRINT_PASS3_STATISTICS : PROCEDURE;
    DECLARE DELTA FIXED;

    IF STATISTICS THEN
    DO;

      OUTPUT(1) = 1;
      OUTPUT= SPACE 40X || 'C O M P I L A T I O N   S T A T I S T I C S';
      DOUBLE_SPACE;
      OUTPUT = 'TRANSFER VECTOR SIZE = ' || NEXT_SEQ#;
      IF #BASIC_BLOCKS ~= 0 THEN OUTPUT = 'BLOCK COUNTER BASE = ' ||
      BLOCK_COUNTER_BASE;
       DOUBLE_SPACE;
      OUTPUT = 'CALLS TO IMPORTANT PROCEDURES';
      DOUBLE_SPACE;
      OUTPUT = PAD('GET_REG',21) || #GET_REG;
      OUTPUT = PAD('FREE_TEMP',21) || #FREE_TEMP;
      OUTPUT = PAD('FLUSH_REG',21) || #FLUSH_REG;
      OUTPUT = PAD('STORE_REG',21) || #STORE_REG;
      OUTPUT = PAD('MAKE_OP_ADDR',21) || #MAKE_OP_ADDR;
      OUTPUT = PAD('FLUSH_ALL_TEMP_REGS',21) || #FLUSH_ALL_TEMP_REGS;
      OUTPUT = PAD('STM FLUSHES',21) || #STM_FLUSHES;
      OUTPUT = PAD('EMIT_RR',21) || #EMIT_RR;
      OUTPUT = PAD('EMIT_RX',21) || #EMIT_RX;
      OUTPUT = PAD('EMIT_SS',21) || #EMIT_SS;
      DOUBLE_SPACE;
      OUTPUT = 'INSTRUCTION FREQUENCIES';
      LINE_FEED;
      DO I = 0 TO 255;
         IF INSTRUCTION(I) ~= 0 THEN DO;
            IF OPER(I) < 256 THEN STRING = SUBSTR(OPNAMES,OPER(I),4);
            ELSE STRING = SUBSTR(OPNAMES2,OPER(I) - 256, 4);
            OUTPUT = STRING || SPACE 5 X || INSTRUCTION(I);
         END;
      END;
      DELTA = TIME - TIME_ENTERED;
      IF DELTA ~= 0 THEN
      DO;
         IF DELTA < 0 THEN DELTA = DELTA = DELTA + 8640000;
         DOUBLE_SPACE;
         CALL PRINT_TIME(DELTA,' SECONDS (ELAPSED) IN PASS 3');
         DELTA = CLOCK_TRAP(1) - CPU_CLOCK;
         CALL PRINT_TIME(DELTA,' SECONDS (CPU) IN PASS 3');
      END;
    END;

    DELTA = CLOCK_TRAP(NULL);   /*   CANCEL CPU TIMER   */
      CALL PRINT_TIME (DELTA,' SECONDS (CPU) IN COMPILATION, ' ||
         ENTRY_POINT || ' BYTES OF CODE GENERATED.');
    OUTPUT(1) = '0EXECUTION OPTIONS: ' || MONITOR_LINK(0) || ' SECONDS, '       
      || MONITOR_LINK(1) || ' LINES, DEBUG LEVEL = ' || MONITOR_LINK(2);
 END PRINT_PASS3_STATISTICS;

 PRINT_TRIPLE: PROCEDURE(INDEX);
      DECLARE INDEX BIT(16),           /* INDEX INTO TRIPLES           */
              IC FIXED,                /* INSTRUCTION COUNTER          */
              STOR_LEN FIXED,
              LINE# FIXED;             /* CORRESPONDING LINE OF SOURCE */
      DECLARE OP_CODES(61) CHARACTER INITIAL('LOAD', 'MONITOR', 'TRUNCATE',
         'FLOAT', 'BCH_TARGET', 'INDEX', 'TEMP', 'STORE', 'MOVE', 'ADD',
         'SUBTRACT', 'MULTIPLY', 'DIVIDE', 'COMPARE', 'ADD_DECIMAL', 'GREATER',
         'LESS', 'NOT', 'ADDFLT', 'SUBFLT', 'MPYFLT', 'DIVFLT', 'COMPAREFLT',
         'GREATERFLT', 'LESSFLT', 'LOAD_ADDR', 'AND', 'OR', 'XOR', 'LSHIFT',
         'RSHIFT', 'BAL', 'BCH', 'BNZ', 'BZ', 'BCT', 'PCALL', 'PRETURN',
         'PARM', 'BLKMARK', 'PEND', 'TPOP', 'REM', 'ABS', 'ABSFLT', 'NEGATE',
         'NEGATEFLT', 'LLESS', 'LGREATER', 'LCOMPARE', 'PROCPARM', 'CASE',
         'CASE_TARGET', 'ODD', 'SQR', 'SQRFLT', 'ROUND', 'S_LENGTH', 'IN',
         'INTO', 'LINE#', 'RANGE');
      DECLARE LINE CHARACTER;
      DECLARE (OPND, I) BIT(16);

      LINE = PAD('$' || (INDEX - 6) / 3,9);
      LINE = LINE || OP_CODES(TRIPLES(INDEX) & TRIPLE_OP_MASK);
      LINE = PAD(LINE, 21);
      DO I = 1 TO 2;   /* PRINT THE OPERANDS */
         OPND = TRIPLES(INDEX + I);
         IF (I = 2) & (OPND ~= NULL) THEN LINE = LINE || ',';
         DO CASE SHR(OPND,14) & "0003";

            /* 00 -- OPERAND IS A POINTER TO THE SYMBOL TABLE          */
            LINE = LINE || (OPND & "3FFF");

            /* 01 -- OPERAND IS IMMEDIATE DATA, A 14-BIT CONSTANT      */
            LINE = LINE || '=''' || (OPND & "3FFF") || '''';

            /* 10 -- OPERAND IS A POINTER TO ANOTHER TRIPLE            */
            LINE = LINE || '$' || ((OPND & "3FFF") - 6) / 3;

            /* 11 -- OPERAND IS A TRIPLE WHOSE VALUE IS BEING TESTED   */
            IF OPND ~= NULL THEN
            LINE = LINE || '$$'|| ((OPND & "3FFF") - 6) / 3;

         END;
      END;
      /*  COMPUTE AND INCLUDE STORAGE LENGTH OF RESULT IN LINE    */
      STOR_LEN = (SHR (TRIPLES(INDEX),8 ) & "FF" ) + 1;
      LINE = PAD(LINE,45);
      LINE = LINE || 'LENGTH ' || STOR_LEN;
      OUTPUT = LINE;
 END PRINT_TRIPLE;

 LIST_TRIPLES: PROCEDURE;
      DECLARE LINE# BIT(16), LINE#TRIPLE BIT(16) INITIAL(60);

      /*   LIST ALL THE TRIPLES GENERATED FOR THE CURRENT PASCAL PROCEDURE */

      OUTPUT(1) = 1;
      OUTPUT = SPACE 40X || 'TRIPLES FOR PROCEDURE ' || PROC_NAME;
      DOUBLE_SPACE;
      OUTPUT = 'CURRENT_LEVEL = ' || CURRENT_LEVEL;
      OUTPUT = 'CURRENT_PROCEDURE = ' || CURRENT_PROCEDURE;
      OUTPUT = 'CURRENT SEQ# = ' || TRIPLES(1);
      DOUBLE_SPACE;

      LINE# = TRIPLES(7);
      I = 6;
      DO WHILE (TRIPLES(I) & TRIPLE_OP_MASK) ~= PEND;
         IF (TRIPLES(I) & LINE#MASK) ~= 0 THEN DO;
            LINE# = LINE# + 1;
            OUTPUT = X70 || 'SOURCE LINE ' || LINE#;
         END;
         ELSE IF (TRIPLES(I) & TRIPLE_OP_MASK) = LINE#TRIPLE THEN DO;
            LINE# = TRIPLES(I + 1);
            OUTPUT = X70 || 'SOURCE LINE ' || LINE#;
         END;
         CALL PRINT_TRIPLE(I);
         I = I + 3;
      END;
      CALL PRINT_TRIPLE(I);

 END LIST_TRIPLES;

 LIST_SYMBOLIC_CODE: PROCEDURE;
     /*    PROCEDURE TO PRINT OUT SYMBOLIC INSTRUCTIONS FROM CODE ARRAY  */

      DECLARE (IC,OP) FIXED;
      DECLARE (R1,R2,R3,L) BIT (8), (DISP1,DISP2) FIXED;
      DECLARE LINE# BIT(16);
      DECLARE PREFIX CHARACTER;

      /*   ACTION IS A DECISION TABLE FOR THE VARIOUS TRIPLES WHICH
           ENCODES THE SEMANTICS FOR PRINTING OUT A SYMBOLIC CODE LISTING  */

      DECLARE ACTION (62) BIT(8) INITIAL (
      3,3,3,3,3,0,3,3,3,3,3,3,3,2,3,2,2,3,3,3,
      3,3,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
      4,0,3,3,3,3,3,2,2,2,2,3,3,3,3,3,3,0,2,3,1,2);

 LIST_CODE: PROCEDURE;
      DO WHILE IC < OP1;
         OP = CODE(IC);
         IF OPER(OP) < 256 THEN
         OP_CODE = SUBSTR(OPNAMES,OPER(OP),4);
         ELSE OP_CODE = SUBSTR(OPNAMES2,OPER(OP) - 256,4);
      IF OP = "00" THEN DO;    /*  A CONSTANT    */
         I = SHL(CODE(IC+2),8) + CODE(IC + 3);
         OUTPUT = I_FORMAT(IC,8) || ': ' || 'DC' || X1 || 'F''' || I || '''';
         IC = IC + 4;
      END;   ELSE
         IF OP < "40" THEN   /*  AN RR INSTRUCTION    */
         DO;
             R1 = SHR(CODE(IC + 1),4);
             R2 = CODE(IC + 1) & "0F";
             OUTPUT = I_FORMAT(IC,8) ||
                            ': ' || OP_CODE || X1 || R1 || ',' || R2;
             IC = IC + 2;
         END;

         ELSE IF OP < "C0" THEN   /*   AN RX OR RS INSTRUCTION     */
         DO;
             R1 = SHR(CODE(IC + 1),4);
             R2 = CODE(IC + 1) & "0F";
             R3 = SHR(CODE(IC + 2),4);
             DISP1 = SHL(CODE(IC + 2) & "0F",8) + CODE(IC + 3);
             OUTPUT = I_FORMAT(IC,8) ||
                            ': ' || OP_CODE || X1 || R1 || ',' || DISP1
                 || '(' || R2 || ',' || R3 || ')';
             IC = IC + 4;
         END;

         ELSE     /*   AN SS INSTRUCTION    */
         DO;
             L = CODE(IC + 1);
             R1 = SHR(CODE(IC + 2),4);
             R2 = SHR(CODE(IC + 4),4);
             DISP1 = SHL(CODE(IC + 2) & "0F",8) + CODE(IC + 3);
             DISP2 = SHL(CODE(IC + 4) & "0F",8) + CODE(IC + 5);
             OUTPUT = I_FORMAT(IC,8) ||
                            ': ' || OP_CODE || X1 || DISP1 || '('               
                 || L || ',' || R1 || ')' || ',' || DISP2 || '(' || R2 || ')';
             IC = IC + 6;
         END;
      END;
 END LIST_CODE;

      PREFIX = SPACE 40X || 'LINE# ';
      OUTPUT(1) = 1;
      OUTPUT = SPACE 20 X || 'LISTING OF GENERATED CODE FOR PROCEDURE ' ||
         PROC_NAME;
      DOUBLE_SPACE;
      IC = 0;
      LINE# = TRIPLES(7);  /*  OP1 OF 1ST TRIPLE IS 1ST LINE #  */
      OUTPUT = PREFIX || LINE#;
      CURRENT_TRIPLE = 9;

      DO FOREVER;
         DO CASE ACTION(TRIPLES(CURRENT_TRIPLE) & TRIPLE_OP_MASK);
            /*   CASE 0 - NO CODE TO PRINT   */
               IF (TRIPLES(CURRENT_TRIPLE) & LINE#MASK) ~= 0 THEN
               DO;
                  LINE# = LINE# + 1;
                  OUTPUT = PREFIX || LINE#;
               END;
            /*   CASE 1 - LINE#TRIPLE  */
               DO;
                  LINE# = OP1;
                  OUTPUT = PREFIX || LINE#;
               END;
            /*   CASE 2 - TRIPLES WHICH ARE PAIRED   */
               DO;
                  IF (TRIPLES(CURRENT_TRIPLE) & LINE#MASK) ~= 0 THEN DO;
                     LINE# = LINE# + 1;
                     OUTPUT = PREFIX || LINE#;
                  END;
                  CURRENT_TRIPLE = CURRENT_TRIPLE + 3;
                  CALL LIST_CODE;
               END;
            /*   CASE 3   */
               DO;
                  IF (TRIPLES(CURRENT_TRIPLE) & LINE#MASK) ~= 0 THEN DO;
                     LINE# = LINE# + 1;
                     OUTPUT = PREFIX || LINE#;
                  END;
                  CALL LIST_CODE;
               END;
            /*   CASE 4 - PEND   */
               RETURN;
         END;   /*   CASE   */
         CURRENT_TRIPLE = CURRENT_TRIPLE + 3;
      END;

 END LIST_SYMBOLIC_CODE;




   /*       C O D E   E M I S S I O N   P R O C E D U R E S          */

 EMIT_RR: PROCEDURE (OP, R1, R2);

      DECLARE (OP, R1, R2) FIXED;

      /* EMIT A 16-BIT RR FORMAT INSTRUCTION  */

      IF CODE_INDEX + 2 > CODE_ARRAY_SIZE THEN CALL ERROR('CODE ARRAY
      OVERFLOW');
      #EMIT_RR = #EMIT_RR + 1;
      CODE(CODE_INDEX) = OP;       /*   EMIT OP CODE     */
      CODE(CODE_INDEX + 1) = SHL(R1,4) + R2;      /*  EMIT REGISTER OPERANDS  */
      IF LIST_CODE THEN DO;
         IF OPER(OP) < 256 THEN
         OP_CODE = SUBSTR(OPNAMES, OPER(OP), 4);
         ELSE OP_CODE = SUBSTR(OPNAMES2,OPER(OP) - 256,4);
         OUTPUT  = X70 || CODE_INDEX || ': CODE = ' || OP_CODE || X1 || R1
            || ',' || R2;
      END;
      CODE_INDEX = CODE_INDEX + 2;
      INSTRUCTION(OP) = INSTRUCTION(OP) + 1;
 END EMIT_RR;

 EMIT_RX: PROCEDURE (OP,R1,R2,R3,DISP);

      DECLARE (OP, R1,R2,R3,DISP) FIXED;

   /*   EMIT A 32-BIT RX FORMAT INSTRUCTION   */

      IF CODE_INDEX + 4 > CODE_ARRAY_SIZE THEN CALL ERROR('CODE ARRAY
         OVERFLOW');
      #EMIT_RX = #EMIT_RX + 1;
      CODE(CODE_INDEX) = OP;      /*  EMIT OPERATION    */
      CODE(CODE_INDEX + 1) = SHL(R1,4) + R2;         /*  EMIT REG OPERANDS   */
      CODE(CODE_INDEX + 2) = SHL(R3,4) + SHR(DISP,8);   /*  EMIT ADDRESS   */
      CODE(CODE_INDEX + 3) = DISP & "FF";            /*  IN BASE - DISP FORM */
      IF LIST_CODE THEN DO;
         IF OPER(OP) < 256 THEN
         OP_CODE = SUBSTR(OPNAMES, OPER(OP), 4);
         ELSE OP_CODE = SUBSTR(OPNAMES2,OPER(OP) - 256,4);
         OUTPUT = X70 || CODE_INDEX || ': CODE = ' || OP_CODE || X1 || R1
            || ',' || DISP || '(' || R2 || ',' || R3 || ')';
      END;
      CODE_INDEX = CODE_INDEX + 4;
      INSTRUCTION(OP) = INSTRUCTION(OP) + 1;
 END EMIT_RX;



 EMIT_SS: PROCEDURE (OP,L,B1,DISP1,B2,DISP2);
      DECLARE (OP,L,B1,DISP1,B2,DISP2) FIXED;
     /*    EMIT A 48 BIT SS FORMAT INSTRUCTION      */

      IF CODE_INDEX + 6 > CODE_ARRAY_SIZE THEN CALL ERROR ('CODE ARRAY
         OVERFLOW');
      #EMIT_SS = #EMIT_SS + 1;
      CODE(CODE_INDEX) = OP;
      CODE(CODE_INDEX + 1) = L;             /*    EMIT LENGTH CODE     */
      CODE(CODE_INDEX + 2) = SHL(B1,4) + SHR(DISP1,8);    /*  FIRST  ADDR   */
      CODE(CODE_INDEX + 3) = DISP1 & "FF";
      CODE(CODE_INDEX + 4) = SHL(B2,4) + SHR(DISP2,8);    /*   2ND  ADDR */
      CODE(CODE_INDEX + 5) = DISP2 & "FF";
      IF LIST_CODE THEN DO;
         IF OPER(OP) < 256 THEN
         OP_CODE = SUBSTR(OPNAMES, OPER(OP), 4);
         ELSE OP_CODE = SUBSTR(OPNAMES2,OPER(OP) - 256,4);
         OUTPUT = X70 || CODE_INDEX || ': CODE = ' || OP_CODE || X1 ||
            DISP1 || '(' || L || ',' || B1 || ')' || ',' || DISP2
            || '(' || B2 || ')';
      END;
      CODE_INDEX = CODE_INDEX + 6;
      INSTRUCTION(OP) = INSTRUCTION(OP) + 1;
 END EMIT_SS;

      /*   THE OTHER INSTRUCTION FORMATS ARE USED SO INFREQUENTLY THAT
           THEY ARE FUDGED USING THE RX_FORMAT                     */


 INSERT_2BYTE_CONSTANT: PROCEDURE (CODE_PTR,CONSTANT);
      DECLARE (CODE_PTR,CONSTANT) BIT(16);
      CODE(CODE_PTR) = SHR(CONSTANT,8) & "FF";
      CODE(CODE_PTR + 1) = CONSTANT & "FF";
      IF LIST_CODE THEN
      OUTPUT = X70 || SPACE 5X || CODE_PTR || ': CONST = ' || CONSTANT;
 END INSERT_2BYTE_CONSTANT;




       /*   R E G I S T E R  A L L O C A T I O N   P R O C E D U R E S  */


STORE_REG: PROCEDURE(REG#);
     DECLARE REG# FIXED;
     /* STORES A TEMP_REG INTO ITS TEMP LOCATION */
      IF DISP (CONTENT(REG#) ) > 4095 THEN
        /*   MULT OF 4096 NEEDED BUT CAN'T BE LOADED    */
         CALL ERROR('NO MEANS OF FLUSHING TEMPORARY');
      IF REG# <  #GP_REGS THEN        /*   GENERAL REGISTER    */
         CALL EMIT_RX    (ST,REG#,0,STACKTOP,DISP (CONTENT (REG#) ) );
         ELSE   /*   FLOATING POINT REGISTER    */
           CALL EMIT_RX (STE,REG#-16,0,STACKTOP,DISP( CONTENT(REG#) ) );
      #STORE_REG = #STORE_REG + 1;
END STORE_REG;

 FREE_REG: PROCEDURE (REG#);

      DECLARE REG# FIXED;

      PRIORITY(REG#) = FREE_PRIORITY;
      IF CONTENT (REG#) ~= NULL THEN DO;
         REG (CONTENT(REG#) ) = NULL;
         CONTENT (REG#) = NULL;
      END;
 END FREE_REG;

FLUSH_REG: PROCEDURE(REG#);
     DECLARE REG# FIXED;

     DO CASE PRIORITY(REG#);
          ;  /* FREE PRIORITY NOTHING TO DO */
          CALL FREE_REG(REG#);  /* BASE PRIORITY  JUST MARK FREED  */
          DO;  /*  TEMP PRIORITY  SAVE IT THEN MARK FREED  */
               CALL STORE_REG(REG#);
               CALL FREE_REG(REG#);
          END;
     CALL ERROR ('ATTEMPT TO FREE A FIXED PRIORITY REG: ' || REG#);
     END;
      #FLUSH_REG = #FLUSH_REG + 1;
END FLUSH_REG;

 LRU_REG_OF_PRIORITY: PROCEDURE(REG_PRIORITY,LOWER_REG,UPPER_REG) FIXED;

      /*  RETURNS THE LEAST RECENTLY USED REG OF THE GIVEN PRIORITY IN THE GIVEN
          RANGE         */

      DECLARE (REG_PRIORITY,LOWER_REG,UPPER_REG,LRU_REG,LRU_USE,REG#) BIT(16);

      LRU_USE = CODE_ARRAY_SIZE;
      DO REG# = LOWER_REG TO UPPER_REG;
         IF PRIORITY(REG#) = REG_PRIORITY & USE(REG#) < LRU_USE THEN
         DO;
            LRU_USE = USE(REG#);
            LRU_REG = REG#;
         END;
      END;
      CALL FLUSH_REG (LRU_REG);
      RETURN(LRU_REG);

 END LRU_REG_OF_PRIORITY;


 GET_FLT_REG: PROCEDURE(REG_PRIORITY) FIXED;

      DECLARE (REG#,REG_PRIORITY,LOWEST_PRIORITY) BIT(16);

      LOWEST_PRIORITY = PRIORITY(16);
      DO REG# = 16 TO 22 BY 2;
         IF PRIORITY(REG#) = FREE_PRIORITY THEN
         DO;
            PRIORITY(REG#) = REG_PRIORITY;
            RETURN (REG#);
         END;
         ELSE IF PRIORITY(REG#) < LOWEST_PRIORITY THEN
            LOWEST_PRIORITY = PRIORITY(REG#);
      END;
      /*  RETURN HIGHER IF A FREE REG WAS AVAILABLE; OTHERWISE FLUSH OUT A REG*/
      REG# = LRU_REG_OF_PRIORITY(LOWEST_PRIORITY,16,22);
      PRIORITY(REG#) = REG_PRIORITY;
      RETURN(REG#);

 END GET_FLT_REG;








GET_REG: PROCEDURE(REG_PRIORITY) FIXED;
      DECLARE (REG_PRIORITY,REG#,REG_CHOSEN,LOW_REG) BIT(16);


      REG_CHOSEN,REG# = 1;
      DO WHILE ( PRIORITY(REG#) ~= FREE_PRIORITY ) & REG_CHOSEN <= HI_REG;
         IF PRIORITY(REG_CHOSEN) < PRIORITY(REG#) THEN REG# = REG_CHOSEN;
         REG_CHOSEN = REG_CHOSEN + 1;
      END;
      IF REG_PRIORITY ~= BASE_PRIORITY THEN DO;
         IF PRIORITY(0) < PRIORITY(REG#) THEN REG# = 0;
         LOW_REG = 1;
      END;
      ELSE LOW_REG = 0;

     /* NOW THE REG CHOSEN IS IN REG#  */
      DO CASE PRIORITY(REG#);
         ;   /*  FREE PRIORITYFOUND. DO NOTHING     */
         REG# = LRU_REG_OF_PRIORITY(BASE_PRIORITY,LOW_REG,10);
         REG# = LRU_REG_OF_PRIORITY(TEMP_PRIORITY,LOW_REG,10);
         CALL ERROR (' CANNOT FIND A NON FIXED PRIORITY REG');
      END;
      PRIORITY(REG#) = REG_PRIORITY;
      #GET_REG = #GET_REG + 1;
      RETURN(REG#);
END GET_REG;


 ASSIGN_TEMP: PROCEDURE (REG#);

      DECLARE REG# FIXED;

      IF NEXT_TEMP > MAX_TEMP THEN CALL ERROR('TEMP STACK OVERFLOW');
      DISP(NEXT_TEMP) = NEXT_TEMP_DISPL;
      PSEUDO_REG (NEXT_TEMP) = STACKTOP_PSEUDO_REG;
      STORAGE_LENGTH(NEXT_TEMP) = 4;
      REG (NEXT_TEMP) = REG#;
      CONTENT (REG#) = NEXT_TEMP;
      USE(REG#) = CODE_INDEX;
      NEXT_TEMP_DISPL = NEXT_TEMP_DISPL + 4;
      IF NEXT_TEMP_DISPL > MAX_TEMP_DISPL THEN MAX_TEMP_DISPL = NEXT_TEMP_DISPL;
      NEXT_TEMP = NEXT_TEMP + 1;
 END ASSIGN_TEMP;


 REASSIGN_TEMP: PROCEDURE(REG#,TEMP_PTR);
      /*   USED FOR RE-ASSIGNING A REG TO A TEMPORARY AFTER THE TEMP
          HAS BEEN FORCED INTO A REGISTER                   */
      DECLARE (REG#,TEMP_PTR) BIT(16);
      REG(TEMP_PTR) = REG#;
      CONTENT(REG#) = TEMP_PTR;
      USE(REG#) = CODE_INDEX;
      PRIORITY(REG#) = TEMP_PRIORITY;
 END REASSIGN_TEMP;

 GET_TEMP_BYTES: PROCEDURE (#BYTES);
      DECLARE #BYTES BIT(16);

      IF NEXT_TEMP > MAX_TEMP THEN CALL ERROR('TEMP STACK OVERFLOW');
      DISP(NEXT_TEMP) = NEXT_TEMP_DISPL;
      STORAGE_LENGTH(NEXT_TEMP) = #BYTES;
      PSEUDO_REG(NEXT_TEMP) = STACKTOP_PSEUDO_REG;
      /*   ROUND #BYTES TO A MULT OF 4 TO MAINTAIN FULLWORD ALLIGNMENT   */
      #BYTES = (#BYTES + 3 ) & "FFFFFFFC";
      NEXT_TEMP_DISPL = NEXT_TEMP_DISPL + #BYTES;
      IF NEXT_TEMP_DISPL > MAX_TEMP_DISPL THEN MAX_TEMP_DISPL = NEXT_TEMP_DISPL;
      NEXT_TEMP = NEXT_TEMP + 1;
 END GET_TEMP_BYTES;

 FREE_TEMP: PROCEDURE (TEMP);

      DECLARE TEMP FIXED;


      #FREE_TEMP = #FREE_TEMP + 1;
      IF REG(TEMP) ~= NONE THEN CALL FREE_REG(REG(TEMP) );
      IF TEMP = NEXT_TEMP - 1 THEN   /*  TOP TEMP; FREE ALL TEMPS BELOW      */
      DO;                            /*  WHICH ARE MARKED FREE     */
         NEXT_TEMP = NEXT_TEMP - 1;
         NEXT_TEMP_DISPL = DISP(TEMP);
         DO WHILE PSEUDO_REG(LAST_TEMP) = MARKED_FREE;
            NEXT_TEMP_DISPL = DISP(LAST_TEMP);
            NEXT_TEMP = LAST_TEMP;
         END;
      END;
      ELSE     /*    JUST MARK FREE         */
      PSEUDO_REG(TEMP) = MARKED_FREE;

 END FREE_TEMP;



      /*   NEXT_TEMP_DISPL_STACK IS USED TO RETAIN THE VALUE OF
           NEXT_TEMP_DISPL DURING A PROCEDURE CALL    */
 PUSH_NEXT_TEMP_DISPL: PROCEDURE;
      NEXT_TEMP_DISPL_STACK(TEMP_DISPL_STACKTOP) = NEXT_TEMP_DISPL;
      TEMP_DISPL_STACKTOP = TEMP_DISPL_STACKTOP + 1;
 END PUSH_NEXT_TEMP_DISPL;

 POP_NEXT_TEMP_DISPL: PROCEDURE;
      TEMP_DISPL_STACKTOP = TEMP_DISPL_STACKTOP - 1;
      NEXT_TEMP_DISPL = NEXT_TEMP_DISPL_STACK(TEMP_DISPL_STACKTOP);
      IF TEMP_DISPL_STACKTOP ~= 0 THEN AR_OFFSET = NEXT_TEMP_DISPL_STACK
         (TEMP_DISPL_STACKTOP - 1); ELSE AR_OFFSET = NEXT_TEMP_DISPL;
 END POP_NEXT_TEMP_DISPL;

   /*   MAPS A REG PRIORITY TO A CLASS# SUCH THAT THE CLASS OF A REG PAIR
        (SUM OF THE CLASS#S) IS UNIQUE FOR THE PRIORITIES               */

      DECLARE CLASSIFY_REG(3) BIT(16) INITIAL (0,1,3,7);


GET_REG_PAIR: PROCEDURE FIXED;

     /* RETURNS THE # OF AN EVEN REG OF AN ODD EVEN PAIR  AVAILABLE FOR USE */

     DECLARE (TRY_REG,REG_CLASS,EVEN_REG,CLASS) FIXED;

     REG_CLASS = CLASSIFY_REG(PRIORITY(8) ) + CLASSIFY_REG (PRIORITY(9) );
     EVEN_REG,TRY_REG = 8;

          /* LOOK FOR BEST PAIR TO GET   */

      DO WHILE TRY_REG > 2 & REG_CLASS ~= 0;
          TRY_REG=TRY_REG - 2;
         CLASS = CLASSIFY_REG(PRIORITY(TRY_REG) ) +
                   CLASSIFY_REG (PRIORITY (TRY_REG + 1 ) );
          IF CLASS<REG_CLASS THEN DO;
               EVEN_REG=TRY_REG;
               REG_CLASS=CLASS;
          END;
     END;

    /****   OPTIMIZE LATER BY ATTEMPTING TO REASSIGNING TEMPS TO LOWER
      PRIORITY REGS RATHER THAN GENERATE STORE INSTRUCTIONS      */
     CALL FLUSH_REG(EVEN_REG);
     CALL FLUSH_REG(EVEN_REG+1);
     RETURN(EVEN_REG);
END GET_REG_PAIR;


 FLUSH_ALL_TEMP_REGS: PROCEDURE;
      DECLARE (REG_PTR,TEMP_REG) BIT(16);

      #FLUSH_ALL_TEMP_REGS = #FLUSH_ALL_TEMP_REGS + 1;

           /*  FLUSH ALL FLOATING POINT REGS      */
      DO I = 16 TO 22 BY 2;
         IF PRIORITY(I) = TEMP_PRIORITY THEN CALL FLUSH_REG(I);
      END;
    /*  FLUSH ALL TEMP GENERAL REGS. OPTIMIZE BY SEEKING CONSECUTIVE TEMP
      PRIORITY REGS ASSIGNED TO CONTIGUOUS TEMP STORAGE & EMITTING STM
      RATHER THAN INDIVIDUAL STORES.                */
      REG_PTR = 0;
      DO FOREVER;
         DO WHILE PRIORITY(REG_PTR) ~= TEMP_PRIORITY & REG_PTR <= 10;
             REG_PTR = REG_PTR + 1;
         END;
         IF REG_PTR <= HI_REG THEN
         DO;
             TEMP_REG = REG_PTR;
             REG_PTR = REG_PTR + 1;
             DO WHILE DISP(CONTENT(REG_PTR)) = DISP(CONTENT(REG_PTR-1)) + 4
                & PRIORITY(REG_PTR) = TEMP_PRIORITY;
                REG_PTR = REG_PTR + 1;
             END;
             IF TEMP_REG < REG_PTR - 1 THEN
             DO;
                CALL EMIT_RX(STM,TEMP_REG,REG_PTR-1,STACKTOP,
                   DISP(CONTENT(TEMP_REG) ) );
                #STM_FLUSHES = #STM_FLUSHES + 1;
             END;
                ELSE CALL EMIT_RX(ST   ,TEMP_REG,0,STACKTOP,
                   DISP(CONTENT(TEMP_REG) ) );
             DO TEMP_REG = TEMP_REG TO REG_PTR - 1;
                CALL FREE_REG(TEMP_REG);
             END;
         END;
         ELSE RETURN;
      END;
 END FLUSH_ALL_TEMP_REGS;

 FLUSH_ALL_REGS: PROCEDURE;
      CALL FLUSH_ALL_TEMP_REGS;
      /*  FREE REMAINING FP REGS       */
      DO I = 16 TO 22 BY 2;
         CALL FREE_REG(I);
      END;
      DO I = 0 TO HI_REG;
         CALL FREE_REG(I);
      END;

 END FLUSH_ALL_REGS;





      /*      A D D R E S S A B I L I T Y   P R O C E D U R E S         */

 MASK: PROCEDURE (OP);
      DECLARE OP FIXED;
      RETURN ( SHR(OP,14) & "3" );
 END MASK;



 IS_TRIPLE: PROCEDURE (OPERAND,INSTRUCTION) BIT(1);

      /*  FUNCTION TO TEST WHETHER GIVEN OPERAND IS A TRIPLE OF THE
          GIVEN TYPE.                     */

      DECLARE (OPERAND,INSTRUCTION ) BIT(16);

      IF OPERAND >= 0 THEN RETURN(FALSE);     /*  MASK NOT 10 OR 11   */
      ELSE RETURN (TRIPLES(OPERAND & STRIPMASK) & TRIPLE_OP_MASK) = INSTRUCTION;

 END IS_TRIPLE;

 IMMED: PROCEDURE (OPERAND) BIT(1);
      DECLARE OPERAND BIT(16);
      RETURN ( (SHR(OPERAND,14) & "3" ) = 1 );
 END IMMED;


 CHECK_MULT_OF_4096: PROCEDURE;

      /*  IF DISPL > 4095 THEN ASSIGNS X_REG TO A MULT OF 4096, GENERATES
          THE LOAD, RESETS DISPL APPROPRIATELY                   */

      DECLARE (MULT,MULT_PTR) FIXED;

      IF DISPL < 4096 THEN X_REG = 0;
      ELSE   /*  MULT OF 4096 REQUIRED   */
      DO;
         MULT = DISPL / 4096;
         DISPL = DISPL MOD 4096;
         MULT_PTR = MULT_OF_4096_TABLE_BASE + MULT;
         IF REG(MULT_PTR) ~= NULL THEN X_REG = REG(MULT_PTR);
         ELSE DO;    /*  MUST LOAD A REG WITH THE MULT     */
             X_REG = GET_REG(BASE_PRIORITY);
             CALL EMIT_RX(LOAD,X_REG,0,ORG,MULT_OF_4096_BASE + MULT * 4 );
             REG(MULT_PTR) = X_REG;
             CONTENT(X_REG) = MULT_PTR;
         END;
         USE(X_REG) = CODE_INDEX;
      END;

 END CHECK_MULT_OF_4096;

 RESET_ADDR_REG_PRIORITIES: PROCEDURE (BASE_REG,X_REG);

      DECLARE (BASE_REG,X_REG) BIT(16);

      IF  ( BASE_REG <= HI_REG ) & ( BASE_REG ~= 0 ) THEN
      DO;
         IF CONTENT(BASE_REG) = NULL THEN
             PRIORITY(BASE_REG) = FREE_PRIORITY;
         ELSE DO;
            IF CONTENT (BASE_REG)>= BASE_TEMP & CONTENT(BASE_REG) <= MAX_TEMP
            THEN PRIORITY(BASE_REG) = TEMP_PRIORITY;
            ELSE PRIORITY(BASE_REG) = BASE_PRIORITY;
         END;
      END;
      IF ( X_REG <= HI_REG ) & ( X_REG ~= 0 ) THEN
      DO;
         IF CONTENT(X_REG) = NULL THEN PRIORITY(X_REG) = FREE_PRIORITY;
         ELSE DO;
            IF CONTENT (   X_REG)>= BASE_TEMP & CONTENT(   X_REG) <= MAX_TEMP
            THEN PRIORITY(X_REG) = TEMP_PRIORITY;
            ELSE PRIORITY(X_REG) = BASE_PRIORITY;
         END;
      END;
 END RESET_ADDR_REG_PRIORITIES;

      DECLARE RESET_BASE_REG_PRIORITIES LITERALLY
         'RESET_ADDR_REG_PRIORITIES(BASE_REG,X_REG)';  /*  RESET GLOBAL
         ADDRESSING  VALUES        */

 GET_OP_INTO_REG: PROCEDURE (REG_PRIORITY);

      /*  GETS THE ADDRESSED OPERAND INTO A REG (DENOTED BY ACC ) OF
          THE GIVEN PRIORITY.                                    */

      /*  A CALL WITH REG_PRIORITY = FREE_PRIORITY IMPLIES THE REGISTER
          CONTENT WILL NOT BE CHANGED BY THE CURRENT USAGE.  OTHERWISE
      /*  IF ALREADY IN A REGISTER, MAKE SURE THAT REG HAS BEEN FREED
          BY MAKE_ADDRESSABLE, OTHERWISE, LATER USES OF THE REG MAY BE INCORRECT
          IF THE CONTENTS ARE CHANGED BY  THE CURRENT USAGE. IF ACC IS NOT FREE,
          THEN GET ITS CONTENTS INTO ANOTHER REG & RETURN THAT REG IN ACC.  */


      DECLARE REG_PRIORITY FIXED;

      IF IN_REG THEN
      DO;
         IF REG_PRIORITY = FREE_PRIORITY THEN RETURN;
         IF PRIORITY(ACC) ~= FREE_PRIORITY THEN
         DO;
            ACC1 = GET_REG(REG_PRIORITY);
            IF ACC ~= ACC1 THEN CALL EMIT_RR(LR,ACC1,ACC);
            ACC = ACC1;
         END;
         ELSE PRIORITY(ACC) = REG_PRIORITY;
      END;



      ELSE
      IF OP_STORAGE_LENGTH = 1 THEN
      /*  IN THIS CASE CARE MUST BE TAKEN NOT TO EMPLOY THE SAME
          REGISTER AS ONE OF THE ADDRESS REGISTERS     */

      DO;
         FIX_BASE_REG_PRIORITIES;
         ACC = GET_REG(REG_PRIORITY);
         CALL EMIT_RR (SR,ACC,ACC);
         CALL EMIT_RX(IC,ACC,X_REG,BASE_REG,DISPL);
         CALL RESET_BASE_REG_PRIORITIES;
      END;
      ELSE DO;
         ACC = GET_REG(REG_PRIORITY);
         IF IMMEDIATE THEN DO;
            IF DISPL = 0 THEN CALL EMIT_RR(SR,ACC,ACC);
                   ELSE CALL EMIT_RX(LA,ACC,0,0,DISPL);
         END;
      ELSE IF OP_STORAGE_LENGTH = 2 THEN
            CALL EMIT_RX(LH,ACC,X_REG,BASE_REG,DISPL);
      ELSE   /*  FULLWORD   */   CALL EMIT_RX(LOAD,ACC,X_REG,BASE_REG,DISPL);
      END;
      IN_REG = TRUE;

 END GET_OP_INTO_REG;


 FORCE_INTO_BASE_REG: PROCEDURE;
      /*  FORCES THE GIVEN OPERAND INTO A NON-ZERO REGISTER IF NOT ALREADY   */

      IF IN_REG THEN    /*  IN ACC  */
      DO;
         IF ACC = 0 THEN
         DO;
            BASE_REG = GET_REG(BASE_PRIORITY);
            CALL EMIT_RR(LR,BASE_REG,ACC);
         END;
         ELSE BASE_REG = ACC;
      END;
      ELSE
      DO;   /*  MUST GET INTO A REGISTER   */
         CALL GET_OP_INTO_REG(BASE_PRIORITY);
         BASE_REG = ACC;
      END;

      X_REG = 0;
      DISPL = 0;
 END FORCE_INTO_BASE_REG;


 LOAD_ADDRESS: PROCEDURE;

      /*   LOADS THE ADDRESS OF THE ADDRESSED OPERAND INTO A SUITABLE REG */
         IF ( BASE_REG > HI_REG ) | ( CONTENT(BASE_REG) ~= NULL )
            THEN   /*  DBR OR MULT OF 4096 OR TEMP   */
         DO;
            BASE = GET_REG(BASE_PRIORITY);
            IF DISPL = 0 & X_REG = 0 THEN
              CALL EMIT_RR(LR,BASE,BASE_REG);  ELSE
            CALL EMIT_RX(LA,BASE,X_REG,BASE_REG,DISPL);
            BASE_REG = BASE;
            PRIORITY(BASE_REG) = FREE_PRIORITY;
         END;
         ELSE DO;
            IF X_REG = 0 & DISPL = 0 THEN RETURN;
            ELSE CALL EMIT_RX(LA,BASE_REG,X_REG,BASE_REG,DISPL);
         END;
         X_REG = 0;
         DISPL = 0;
 END LOAD_ADDRESS;

 GET_STOR_LEN: PROCEDURE (OPERAND) FIXED;
      DECLARE OPERAND BIT(16);
      DO CASE MASK(OPERAND);
         /*   SY TABLE PTR   */
         RETURN STORAGE_LENGTH(OPERAND);
         /*   IMMEDIATE   */
         RETURN 0;
         /*   TRIPLE   */
         DO;
            /*   IF OPERAND IS AN INDEX TRIPLE, THE STORAGE LENGTH MAY BE
                 CONTAINED IN AN S_LENGTH TRIPLE IMMEDIATELY FOLLOWING  */
            IF IS_TRIPLE(OPERAND,INDEX) | IS_TRIPLE(OPERAND,ADDR_TEMP) THEN
            DO;
               IF TRIPLES((OPERAND & STRIPMASK) + 3) = S_LENGTH THEN DO;
                  OPERAND = (OPERAND & STRIPMASK) + 4;
                  RETURN SHL(TRIPLES(OPERAND),16) + TRIPLES(OPERAND + 1);
               END;
            END;
            /*   SET STORAGE LENGTH FROM LENGTH FIELD   */
            RETURN (SHR(TRIPLES(OPERAND & STRIPMASK),8)& "FF") + 1;
         END;
         /*   TRIPLE   */
         DO;
            /*   IF OPERAND IS AN INDEX TRIPLE, THE STORAGE LENGTH MAY BE
                 CONTAINED IN AN S_LENGTH TRIPLE IMMEDIATELY FOLLOWING  */
            IF IS_TRIPLE(OPERAND,INDEX)  | IS_TRIPLE(OPERAND,ADDR_TEMP) THEN
            DO;
               IF TRIPLES((OPERAND & STRIPMASK) + 3) = S_LENGTH THEN DO;
                  OPERAND = (OPERAND & STRIPMASK) + 4;
                  RETURN SHL(TRIPLES(OPERAND),16) + TRIPLES(OPERAND + 1);
               END;
            END;
            /*   SET STORAGE LENGTH FROM LENGTH FIELD   */
            RETURN (SHR(TRIPLES(OPERAND & STRIPMASK),8)& "FF") + 1;
         END;
      END;
 END GET_STOR_LEN;


 MAKE_OP_ADDRESSABLE: PROCEDURE(OPERAND);

      DECLARE (OPERAND,DBR_PTR ) FIXED;
      DECLARE TEMP BIT(16);

      #MAKE_OP_ADDR = #MAKE_OP_ADDR + 1;    /*****/

      OP_MASK = MASK(OPERAND);
      DO CASE OP_MASK;

         /*  SYMBOL TABLE POINTER  */
      DO;
         IMMEDIATE, IN_REG, IN_FREE_REG = FALSE;
         OP_STORAGE_LENGTH = STORAGE_LENGTH(OPERAND);
         IF PSEUDO_REG(OPERAND) = 0 THEN BASE_REG = GLOBAL_AR_BASE;
         ELSE IF PSEUDO_REG(OPERAND) = CURRENT_LEVEL - 1 THEN
            BASE_REG = CURRENT_AR_BASE;
         ELSE
         DO;
            DBR_PTR = PSEUDO_REG (OPERAND ) + DBR_TABLE_BASE;
            IF REG(DBR_PTR) = NONE THEN
            DO;
                BASE_REG = GET_REG(BASE_PRIORITY);
                CONTENT(BASE_REG) = DBR_PTR;
                REG(DBR_PTR) = BASE_REG;
                CALL EMIT_RX(LOAD,BASE_REG,0,CURRENT_AR_BASE,16 +
                  PSEUDO_REG(OPERAND) * 4 );   /*  LOAD FROM DISPLAY   */
            END;
            ELSE BASE_REG = REG(DBR_PTR);
            DISPL = DISP(OPERAND);
            PRIORITY(BASE_REG) = FIXED_PRIORITY;
            CALL CHECK_MULT_OF_4096;
            PRIORITY(BASE_REG) = BASE_PRIORITY;
            USE(BASE_REG) = CODE_INDEX;
            RETURN;
         END;

         DISPL = DISP(OPERAND);
         CALL CHECK_MULT_OF_4096;
      END;

         /*  IMMEDIATE OPERAND   */
      DO;
         BASE_REG = 0;
         X_REG = 0;
         DISPL = OPERAND & STRIPMASK;
         OP_STORAGE_LENGTH = 0;
         IMMEDIATE = TRUE;
         IN_REG,IN_FREE_REG = FALSE;
      END;

         /*   TRIPLE POINTER. TEMPORARY TO BE FREED        */
      DO;
         TEMP = TRIPLES ( (OPERAND & STRIPMASK) + 2 );
         OP_STORAGE_LENGTH = STORAGE_LENGTH(TEMP);
         IF REG(TEMP) = NONE THEN
         DO;
            BASE_REG = STACKTOP;
            DISPL = DISP(TEMP);
            CALL CHECK_MULT_OF_4096;
            IN_REG,IN_FREE_REG = FALSE;
         END;
         ELSE
         DO;
            IN_REG = TRUE;
            IN_FREE_REG = TRUE;
            ACC = REG(TEMP);
         END;
         IMMEDIATE = FALSE;
         CALL FREE_TEMP(TEMP);
         IF IS_TRIPLE(OPERAND,ADDR_TEMP) THEN DO;
            /*   TEMP MUST BE DE-REFERENCED   */
            CALL FORCE_INTO_BASE_REG;
            IN_REG, IN_FREE_REG = FALSE;
            OP_STORAGE_LENGTH = GET_STOR_LEN(OPERAND);
         END;
      END;

         /*   TRIPLE POINTER. TEMP NOT TO BE FREED: MORE REFERENCES FOLLOW  */

      DO;
         TEMP = TRIPLES ( (OPERAND & STRIPMASK) + 2 );
         OP_STORAGE_LENGTH = STORAGE_LENGTH(TEMP);
         IF REG(TEMP) = NONE THEN
         DO;
            BASE_REG = STACKTOP;
            DISPL = DISP(TEMP);
            CALL CHECK_MULT_OF_4096;
            IN_REG = FALSE;
         END;
         ELSE
         DO;
            IN_REG = TRUE;
            ACC = REG(TEMP);
            USE(ACC) = CODE_INDEX;   /*  UPDATE REG USE COLUMN   */
         END;
         IF IS_TRIPLE(OPERAND,ADDR_TEMP) THEN DO;
            /*   TEMP MUST BE DE-REFERENCED   */
            CALL FORCE_INTO_BASE_REG;
            /*   REMEMBER THE BASE_REG FOR FUTURE REFERENCE   */
            IN_REG = FALSE;
            CALL REASSIGN_TEMP(BASE_REG,TRIPLES((OPERAND & STRIPMASK) + 2));
            OP_STORAGE_LENGTH = GET_STOR_LEN(OPERAND);
         END;
         IN_FREE_REG,IMMEDIATE = FALSE;
      END;

      END;   /*  CASE  */
 END MAKE_OP_ADDRESSABLE;

 MAKE_INDEX_OP_ADDRESSABLE: PROCEDURE (OPERAND);

      DECLARE INDEX_STACK_SIZE LITERALLY '20',
              OPERAND BIT(16),
              (ACC1,DISPL1) BIT(16),
              (BASE_REG1,X_REG1) BIT(16),
              INDEX_STACK (INDEX_STACK_SIZE) BIT(16),
              INDEX_OP_STACK (INDEX_STACK_SIZE) BIT(16),  /* INDICATES
                   WHETHER AN INDEX TRIPLE IS A FIRST OR 2ND OPERAND    */
              INDEX_STACKTOP BIT(16),
              LAST_INDEX_TRIPLE BIT(16),  /*  INDICATES LAST TRIPLE UNSTACKED */
              LAST_INDEX_OP BIT(16), /* INDICATES WHETHER LAST TRIPLE
                   UNSTACKED WAS A FIRST OR 2ND OPERAND.           */
              FIRST_OP BIT(16) INITIAL (1),
              SECOND_OP BIT(16) INITIAL (2),
              ( XOP1,XOP2 ) BIT(16);   /*  LOCAL POINTERS TO TRIPLE OPERANDS */

 PUSH_ONTO_INDEX_STACK: PROCEDURE (OPERAND,OP_POSITION);
      DECLARE (OPERAND,OP_POSITION) BIT(16);

      INDEX_STACKTOP = INDEX_STACKTOP + 1;
      IF INDEX_STACKTOP > INDEX_STACK_SIZE THEN
         CALL ERROR('INDEX STACK OVERFLOW');
      INDEX_STACK(INDEX_STACKTOP) = OPERAND & STRIPMASK;
      INDEX_OP_STACK(INDEX_STACKTOP) = OP_POSITION;
      LAST_INDEX_OP = NULL;
      OPERAND = OPERAND & STRIPMASK;

 END PUSH_ONTO_INDEX_STACK;

POP_INDEX_TRIPLE: PROCEDURE;
      /*   UNSTACKS THE LAST INDEX TRIPLE, SETS THE VALUE OF LAST_INDEX_TRIPLE,
      LAST_INDEX_OP, AND THE GLOBALS IN_REG, IMMEDIATE,OP_STORAGE_LENGTH  */

      LAST_INDEX_TRIPLE = INDEX_STACK(INDEX_STACKTOP);
      OP_STORAGE_LENGTH =
         (SHR (TRIPLES(LAST_INDEX_TRIPLE),8) & "FF" ) + 1;
      IN_REG = FALSE;
      IN_FREE_REG = FALSE;
      IMMEDIATE = FALSE;
      LAST_INDEX_OP = INDEX_OP_STACK(INDEX_STACKTOP);
      INDEX_STACKTOP = INDEX_STACKTOP - 1;

 END POP_INDEX_TRIPLE;


 GENERATE_XREG_BASEREG: PROCEDURE;


      /*   WHEN CALLED, LAST_INDEX_OP = SECOND_OP; THUS, BASE_REG, X_REG, (ACC),
           DISPL WILL ADDRESS THE SECOND OPERAND OF THE TRIPLE ON TOP OF THE
           INDEX STACK. GET THE CONTENTS INTO AN INDEX REG,CALL IT X_REG1.
           FIX ITS PRIORITY.
           THEN MAKE THE FIRST OPERAND ADDRESSABLE, REMOVING INDEXING
           IF ANY.   ASSIGN X_REG = X_REG1;  THEN X_REG, BASE_REG,
           DISPL WILL ADDRESS THE TOP TRIPLE                  */


      CALL GET_OP_INTO_REG(BASE_PRIORITY);
      X_REG1 = ACC;
      PRIORITY(X_REG1) = FIXED_PRIORITY;
      CALL MAKE_OP_ADDRESSABLE(XOP1);
      IF X_REG ~= 0 THEN CALL LOAD_ADDRESS;
      IF IMMEDIATE THEN BASE_REG = X_REG1;   /*  IF IMMED THEN MUST BE 0  */
      ELSE X_REG = X_REG1;
      CALL RESET_ADDR_REG_PRIORITIES(BASE_REG,X_REG1);

 END GENERATE_XREG_BASEREG;


      /*  WHEN CALLED, LAST_INDEX_OP = FIRST_OP OR NULL. IF NU L, THEN
          FIRST OPERAND MUST BE MADE ADDRESSABLE; OTHERWISE, IT ALREADY IS.
          REMOVE INDEXING, GET THE SECOND OPERAND INTO A REGISTER CALLED X_REG.
          NOW BASE_REG, X_REG, DISPL WILL ADDRESS THE TOP TRIPLE       */


 GENERATE_BASEREG_XREG: PROCEDURE;

      IF LAST_INDEX_OP = NULL THEN /* BASE_REG,X_REG,DISPL MUST BE
         SET BY MAKE_OP_ADDRESSABLE; OTHERWISE, THESE ALREADY ADDRESS
         AN INDEX TRIPLE                      */
      DO;
         CALL MAKE_OP_ADDRESSABLE(XOP1);
         IF IMMEDIATE THEN
         DO;
            IF DISPL ~= 0 THEN CALL ERROR('ATTEMPT TO INDEX IMMED OP OTHER
 THAN 0');
            CALL MAKE_OP_ADDRESSABLE(XOP2);
            CALL FORCE_INTO_BASE_REG;
            RETURN;
         END;
      END;

      IF IMMED (XOP2) THEN
      DO;
         IF DISPL + (XOP2  & STRIPMASK) > 4095 THEN CALL LOAD_ADDRESS;
         DISPL = DISPL + (XOP2 & STRIPMASK);
         CALL RESET_BASE_REG_PRIORITIES;
         RETURN;
      END;

      IF X_REG ~= 0 THEN CALL LOAD_ADDRESS;
      BASE_REG1 = BASE_REG;           /*  SAVE BASE_REG & DISPL     */
      DISPL1 = DISPL;
      PRIORITY(BASE_REG) = FIXED_PRIORITY;
      CALL MAKE_OP_ADDRESSABLE(XOP2);
      CALL FORCE_INTO_BASE_REG;
      X_REG = BASE_REG;
      BASE_REG = BASE_REG1;
      DISPL = DISPL1;
      CALL RESET_BASE_REG_PRIORITIES;
     /*  NOW BASE_REG,X_REG,DISPL ADDRESS THE INDEX TRIPLE         */
 END GENERATE_BASEREG_XREG;

 CONVERT_TO_TEMP: PROCEDURE;
      /*   CONVERTS THE ADDRESSED INDEX TRIPLE TO A TEMPORARY SO THAT
           IT CAN BE DE-REFERENCED AGAIN.                     */

      IF (BASE_REG = CURRENT_AR_BASE | BASE_REG = GLOBAL_AR_BASE) & X_REG = 0
         THEN RETURN;   /*   NO NEED TO SAVE ADDRESS- CAN BE SIMPLY RECOMPUTED*/
      CALL LOAD_ADDRESS;
      PRIORITY(BASE_REG) = TEMP_PRIORITY;
      CALL ASSIGN_TEMP(BASE_REG);
      TRIPLES(LAST_INDEX_TRIPLE + 2) = LAST_TEMP;
      /*  CONVERT THE TRIPLE CODE TO TEMP_TRIPLE, PRESERVING THE
          LINE NUMBER BIT AND LENGTH FIELD     */
      TRIPLES(LAST_INDEX_TRIPLE) = ADDR_TEMP +
         (TRIPLES(LAST_INDEX_TRIPLE) & "FF80");

 END CONVERT_TO_TEMP;



      /*  KEEP STACKING FIRST OPERANDS OF AN INDEX TRIPLE WHICH ARE
          THEMSELVES INDEX TRIPLES. AT SOME POINT, THE ADDRESS OF THE
          FIRST OPERAND CAN BE GENERATED BY MAKE_OP_ADDRESSABLE. ANY
          INDEXING IS THEN REMOVED BY LOADING THE ADDRESS INTO A BASE REG
                        WE THEN PROCEED TO EVALUATE THE SECOND OPERAND:
          IF THE SECOND OPERAND IS A CHAIN OF INDEX TRIPLES, THEY ARE
          STACKED IN A SIMILAR MANNER AS ABOVE.
          WHEN THE ADDRESS OF THE SECOND OPERAND IS FINALLY KNOWN, IT IS
          DE-REFERENCED, ITS  C O N T E N T S  LOADED INTO AN INDEX REGISTER.
          THE INDEX STACK IS THEN POPPED; BASE_REG,X_REG,DISPL WILL
          ADDRESS THE TRIPLE JUST PROCESSED. WHEN ALL TRIPLES ARE UNSTACKED,
          BASE_REG,X_REG,DISPL WILL ADDRESS THE WHOLE CHAIN, I.E. , THE
          ORIGINAL OPERAND PASSED TO MAKE_ADDRESSABLE.             */


      CALL PUSH_ONTO_INDEX_STACK(OPERAND);
      DO WHILE INDEX_STACKTOP ~= 0;
         XOP1 = TRIPLES (INDEX_STACK(INDEX_STACKTOP) + 1 );
         XOP2 = TRIPLES (INDEX_STACK(INDEX_STACKTOP) + 2 );
         IF IS_TRIPLE (XOP1,INDEX) & (LAST_INDEX_OP = NULL) THEN
            CALL PUSH_ONTO_INDEX_STACK(XOP1,FIRST_OP);
         ELSE IF IS_TRIPLE(XOP2,INDEX) & (LAST_INDEX_OP ~= SECOND_OP) THEN
         DO;
            IF LAST_INDEX_OP = FIRST_OP THEN   /*  GET THE ADDRESS
                REPRESENTED BY THE FIRST OPERAND (CURRENTLY ADDRESSED BY
                BASE_REG,X_REG,DISPL) INTO A REGISTER.            */
            DO;
                BASE = GET_REG(BASE_PRIORITY);
                PRIORITY(BASE) = TEMP_PRIORITY;
                CALL EMIT_RX(LA,BASE,BASE_REG,X_REG,DISPL);
                CALL ASSIGN_TEMP(BASE);
                /*   CONVERT THE INDEX TRIPLE TO AN OTHERWISE UNUSED TRIPLE,
                     & ASSOCIATE A TEMPORARY WITH IT   */
                TRIPLES(LAST_INDEX_TRIPLE) = ADDR_TEMP +
                  (TRIPLES(LAST_INDEX_TRIPLE) & "FF80");
                TRIPLES(LAST_INDEX_TRIPLE + 2) = LAST_TEMP;
            END;
            CALL PUSH_ONTO_INDEX_STACK(XOP2,SECOND_OP);
         END;
         ELSE
         DO;
            IF LAST_INDEX_OP = SECOND_OP THEN CALL GENERATE_XREG_BASEREG;
            ELSE CALL GENERATE_BASEREG_XREG;
            CALL POP_INDEX_TRIPLE;
         END;
      END;
      IF MASK(OPERAND) = TEMP_MASK THEN DO;
         CALL CONVERT_TO_TEMP;
         OP_MASK = TEMP_MASK;
      END;
      ELSE OP_MASK = TRIPLE_PTR;

      /*   FOR INDEXED  OPERANDS OF EXTRAORDINARY LENGTH, WE OBTAIN THE
          STORAGE LENGTH FROM AN S_LENGTH TRIPLE IMMEDIATELY FOLLOWING
          RATHER THE THE LENGTH FIELD OF THR INDEX TRIPLE. THE LENGTH IS
          GIVEN BY OP1 || OP2 OF THE S_LENGTH TRIPLE           */
      OPERAND = OPERAND & STRIPMASK;
      IF TRIPLES(OPERAND + 3) = S_LENGTH THEN
         OP_STORAGE_LENGTH = SHL(TRIPLES(OPERAND + 4),16) + TRIPLES(OPERAND+5);

 END MAKE_INDEX_OP_ADDRESSABLE;

 MAKE_ADDRESSABLE: PROCEDURE (OPERAND);

      DECLARE OPERAND BIT(16);
      IF IS_TRIPLE(OPERAND,INDEX) THEN
         CALL MAKE_INDEX_OP_ADDRESSABLE(OPERAND);
      ELSE CALL MAKE_OP_ADDRESSABLE (OPERAND);
 END MAKE_ADDRESSABLE;



 FIXUP: PROCEDURE (PTR);

      DECLARE (TEMP_PTR,PTR,NEXT_PTR,DISPLACEMENT,BASE) FIXED;

      DO FOREVER;

         /*   RECOVER NEXT ELEMENT IN CHAIN     */
         NEXT_PTR = SHL (CODE(PTR+2),8 ) + CODE(PTR + 3);

         IF CODE_INDEX < 4096 THEN
         DO;      /*  NO REGISTER NEEDED   */
                IF (CODE(PTR + 1) & "0F") ~= 0 THEN
                DO;     /*  A REGISTER WAS ANTICIPATED     */
                   CODE(PTR + 1) = 0;    /*  INSERT NO-OP    */
                   PTR = PTR - 4;
                  CODE(PTR + 1) = CODE(PTR + 1) & "F0";  /* SET INDEXING TO 0 */
                END;
             DISPLACEMENT = CODE_INDEX;
             BASE = CODE_BASE;
         END;

         ELSE     /*  DISP > 4096. NEED A REG FOR ADDRESSING      */
         IF ( CODE (PTR + 1) & "0F") = 0 THEN  /* NO INDEXING ANTICIPATED   */
         CALL ERROR(' FIXUP FAILURE. NO AVAILABLE REG FOR DOUBLE INDEXING');

         ELSE
         IF CODE_INDEX - PTR < 4094 THEN  /*  MULT OF 4096 NOT NEEDED.   */
            DO;     /*  PATCH IN A BALR, MOVE UP THE BC, INSERT HALFWORD NO-OP*/
                BASE = 0;
                DISPLACEMENT = CODE_INDEX - PTR + 2;
                PTR = PTR - 2;
                CODE(PTR - 2) = BALR;
                CODE(PTR - 1) = SHL(CODE(PTR + 3),4);
                CODE(PTR) = BC;
                CODE(PTR + 1) = CODE(PTR + 3);
                CODE(PTR + 4) = BCR;
                CODE(PTR + 5) = 0;
            END;
         ELSE   /*  GENERATE LOAD AVAIL REG WITH THE NECC MULT OF 4096  */
         DO;
             TEMP_PTR = PTR - 4;
             /*   DISPLACEMENT = 4 * (CODE_INDEX DIV 4096)+ MULT_OF_4096_BASE */
             DISPLACEMENT = SHL(SHR(CODE_INDEX,12),2) + MULT_OF_4096_BASE;
             CODE(TEMP_PTR) = LOAD;
             CODE(TEMP_PTR + 1) = SHL(CODE(PTR + 1),4) + ORG;
             CODE(TEMP_PTR + 2) = SHR(DISPLACEMENT,8);
             CODE(TEMP_PTR + 3) = DISPLACEMENT & "FF";
             /*   SET VALUES FOR BRANCH INSTRUCTION    */
             DISPLACEMENT = CODE_INDEX MOD 4096;
             BASE = CODE_BASE;
         END;

         /*  BREAK HIGHER IF ERROR.   FILL IN DISPLACEMENT & BASE REG    */

         IF LIST_CODE THEN
         OUTPUT = X70 || SPACE 5X ||      PTR || ': FIXUP = ' || DISPLACEMENT;
         CODE(PTR + 2) = SHL(BASE,4) + SHR(DISPLACEMENT,8);
         CODE(PTR + 3) = DISPLACEMENT & "FF";
         IF NEXT_PTR = 0 THEN RETURN; ELSE PTR = NEXT_PTR;
      END;
 END FIXUP;


 FORWARD_BRANCH: PROCEDURE(BRANCH_COND,TARGET#);

      DECLARE (TARGET#,INDEX_REG,BRANCH_COND) FIXED;
      /*  IF TARGET IS A NEW BASIC BLOCK THEN NO LENGTH FIELD     */
      IF TARGET# > 1000 THEN

      DO;    /*  MAY NEED A REG FOR DOUBLE INDEXING    */
         INDEX_REG = GET_REG(BASE_PRIORITY);
         CALL EMIT_RX (BC,BRANCH_COND,INDEX_REG,0,0);
         PRIORITY(INDEX_REG) = FREE_PRIORITY;
      END;
      ELSE INDEX_REG = 0;
      IF TRIPLES(TARGET# + 2)   /*  2ND OPERAND OF BR TARGET TRIPLE   */
      = NULL THEN    /*  NO PREVIOUS ELEMENTS IN CHAIN  */
      CALL EMIT_RX(BC,BRANCH_COND,INDEX_REG,0,0);
      ELSE CALL EMIT_RX(BC,BRANCH_COND,INDEX_REG,SHR(TRIPLES(TARGET# + 2),12)
        ,TRIPLES(TARGET# + 2) & "FFF"  );
      /*  SET THE 2ND OPERAND OF BR TARGET TO ABOVE BR INSTR,I.E. TO
          HEAD OF FIXUP CHAIN             */
      TRIPLES(TARGET# + 2) = CODE_INDEX - 4;

 END FORWARD_BRANCH;

 LOCAL_BRANCH: PROCEDURE(BRANCH_COND,OPERAND);
      DECLARE (BRANCH_COND,OPERAND) BIT(16);
      IF MASK(OPERAND) = SY_TABLE_PTR THEN
      DO;     /*  A LOCAL GOTO  */
         IF DISP(OPERAND) > 0 THEN DO;
            CALL FLUSH_ALL_REGS;
            CALL FORWARD_BRANCH(BRANCH_COND,DISP(OPERAND) );
         END;
         ELSE DO;
            DISPL = DISP(OPERAND) & "7FFFFFFF";
            CALL CHECK_MULT_OF_4096;
            CALL FLUSH_ALL_REGS;
            CALL EMIT_RX(BC,BRANCH_COND,X_REG,CODE_BASE,DISPL);
         END;
      END;
      ELSE
      DO;
         OPERAND = OPERAND & STRIPMASK;
         IF OPERAND > CURRENT_TRIPLE THEN DO;
            IF SHR(TRIPLES(OPERAND),8) = 0 THEN  /*  CHANGING BASIC BLOCKS */
               CALL FLUSH_ALL_REGS;
            CALL FORWARD_BRANCH(BRANCH_COND,OPERAND);
         END;
         ELSE DO;
            DISPL = TRIPLES(OPERAND + 1);
            CALL CHECK_MULT_OF_4096;
            CALL FLUSH_ALL_REGS;
            CALL EMIT_RX(BC,BRANCH_COND,X_REG,CODE_BASE,DISPL);
         END;
      END;
 END LOCAL_BRANCH;


 FORWARD_CODE_BRANCH: PROCEDURE(BR_COND,RELATIVE_DISPL);
      /*   GENERATES A FORWARD BRANCH KNOWN ONLY TO THE CODE GENERATOR,
          I.E. NOT EXPLICITLY INDICATED BY THE TRIPLES BUT NEVERTHELESS
          REQUIRED BY THE EXPANSION OF A TRIPLE INTO CODE.
            THE ARGUMENTS ARE THE BRANCH CONDITION & THE DISPL RELATIVE TO
          THE CODE INDEX                                  */
      DECLARE (BR_COND,RELATIVE_DISPL) BIT(16);
      DISPL = CODE_INDEX + RELATIVE_DISPL;
      CALL CHECK_MULT_OF_4096;
      /*   NOTE CODE_INDEX MAY BE CHANGED BY CHECK_MULT_OF_4096 IF
           A LOAD IS EMITTED         */
      CALL EMIT_RX(BC,BR_COND,X_REG,CODE_BASE,
         (CODE_INDEX + RELATIVE_DISPL) MOD 4096 );
 END FORWARD_CODE_BRANCH;


    /*        C O D E   G E N E R A T I O N   P R O C E D U R E S         */



  LOAD_OPERAND: PROCEDURE;
      CALL MAKE_ADDRESSABLE(OP1);
      CALL GET_OP_INTO_REG(TEMP_PRIORITY);
      CALL ASSIGN_TEMP(ACC);
         OP2 = LAST_TEMP;

 END LOAD_OPERAND;

 GET_OP_INTO_REG#: PROCEDURE(REG#);
      DECLARE REG# BIT(16);
      IF IN_REG THEN CALL EMIT_RR(LR,REG#,ACC);
      ELSE
      IF OP_STORAGE_LENGTH = 1 THEN DO;
         CALL EMIT_RR(SR,REG#,REG#);
         CALL EMIT_RX(IC,REG#,X_REG,BASE_REG,DISPL);
      END;
      ELSE IF IMMEDIATE THEN DO;
         IF DISPL = 0 THEN CALL EMIT_RR(SR,REG#,REG#);
         ELSE CALL EMIT_RX(LA,REG#,0,0,DISPL);
      END;
      ELSE IF OP_STORAGE_LENGTH = 2 THEN
         CALL EMIT_RX(LH,REG#,X_REG,BASE_REG,DISPL);
      ELSE CALL EMIT_RX(LOAD,REG#,X_REG,BASE_REG,DISPL);
 END GET_OP_INTO_REG#;

 RESET_PAIR_PRIORITIES: PROCEDURE(EVEN_REG_PRIORITY,ODD_REG_PRIORITY);
      DECLARE (EVEN_REG_PRIORITY,ODD_REG_PRIORITY) BIT(16);
      PRIORITY(EVEN_REG) = EVEN_REG_PRIORITY;
      PRIORITY(ODD_REG) = ODD_REG_PRIORITY;
 END RESET_PAIR_PRIORITIES;

 GET_INTO_EVEN_REG: PROCEDURE;
      IF OP_STORAGE_LENGTH = 1 THEN FIX_BASE_REG_PRIORITIES;
      EVEN_REG = GET_REG_PAIR;
      ODD_REG = EVEN_REG + 1;
      IF OP_STORAGE_LENGTH = 1 THEN CALL RESET_BASE_REG_PRIORITIES;
      IF IN_REG THEN DO;
         IF ACC ~= EVEN_REG THEN CALL EMIT_RR(LR,EVEN_REG,ACC);
      END;
      ELSE
      CALL GET_OP_INTO_REG#(EVEN_REG);
      CALL RESET_PAIR_PRIORITIES (FIXED_PRIORITY,FIXED_PRIORITY);
      ACC = EVEN_REG;

 END GET_INTO_EVEN_REG;

 GET_INTO_ODD_REG: PROCEDURE;
      /*  GETS THE ADDRESSED OPERAND INTO THE ODD REG OF AN EVEN-ODD PAIR */

      IF OP_STORAGE_LENGTH = 1 THEN FIX_BASE_REG_PRIORITIES;
      EVEN_REG = GET_REG_PAIR;
      ODD_REG = EVEN_REG + 1;
      IF OP_STORAGE_LENGTH = 1 THEN CALL RESET_BASE_REG_PRIORITIES;
      IF IN_REG THEN
      DO;
         IF ACC ~= ODD_REG THEN CALL EMIT_RR(LR,ODD_REG,ACC);
      END;
      ELSE CALL GET_OP_INTO_REG#(ODD_REG);
      CALL RESET_PAIR_PRIORITIES(FIXED_PRIORITY,FIXED_PRIORITY);
      ACC = ODD_REG;
 END GET_INTO_ODD_REG;



 CHECK_STATUS: PROCEDURE(OPERAND);
      /*  THIS PROCEDURE LOOKS AHEAD AT AN OPERAND, WITH OUT MAKING IT
          ADDRESSABLE; IT CHECKS ONLY THAT THE GIVEN OPERAND IS IN A TEMP
          PRIORITY REGISTER THAT WILL NOT BE REFERENCED AGAIN. IN THAT CASE,
          THE TEMPORARY IS FREED, ACC <- THE REG,IN_FREE_REG <- TRUE.
          THIS PROCEDURE CAN THEN PRE-EMPT MAKE_ADDRESSABLE.       */
      DECLARE OPERAND BIT(16);
      DECLARE TEMP BIT(16);
      IN_REG = FALSE;
      IN_FREE_REG = FALSE;
      OP_MASK = MASK(OPERAND);
      DO CASE OP_MASK;
      ;
      ;

      DO;
         IF IS_TRIPLE(OPERAND,INDEX) | IS_TRIPLE(OPERAND,ADDR_TEMP)
            THEN RETURN;
         OPERAND = OPERAND & STRIPMASK;
         ACC = REG(TRIPLES(OPERAND + 2) );
         IF ACC ~= NULL THEN DO;
            IN_REG = TRUE;
            IN_FREE_REG = TRUE;
            CALL FREE_TEMP(TRIPLES(OPERAND + 2) );
         END;
      END;
      DO;
         IF IS_TRIPLE(OPERAND,INDEX) | IS_TRIPLE(OPERAND,ADDR_TEMP)
            THEN RETURN;
         TEMP = TRIPLES( (OPERAND & STRIPMASK) + 2 );
         ACC = REG(TEMP);
         IF ACC ~= NULL THEN IN_REG = TRUE;
      END;
    END;
 END CHECK_STATUS;


 ACCUMULATE: PROCEDURE(OPERAND);
      DECLARE OPERAND BIT(16);
      /*   LOADS THE CURRENTLY ADDRESSED OPERAND INTO AN ACCUMULATOR. IF THE OP
           IS A VALUE TEMP (AS OPPOSED TO AN ADDR_TEMP WHICH MUST BE
           DE-REFERENCED) THE REGISTER PRIORITY IS INCREASED TO TEMP_PRIORITY
           AND ASSOCIATED WITH THE TEMPORARY   */
         CALL GET_OP_INTO_REG(FREE_PRIORITY);
         IF ~IS_TRIPLE(OPERAND,ADDR_TEMP) & ~IS_TRIPLE(OPERAND,INDEX)
            & MASK(OPERAND) = TEMP_MASK THEN
            CALL REASSIGN_TEMP(ACC,TRIPLES((OPERAND & STRIPMASK) + 2));
 END ACCUMULATE;


 DOUBLE_REG_STATUS: PROCEDURE(OPERAND) BIT(1);
      /*  CHECKS IF THE GIVEN OPERAND IS IN A FREE ODD REG, & THAT THE
          CORRESPONDING EVEN REG IS FREE                 */
      DECLARE OPERAND BIT(16);
      DO CASE MASK(OPERAND);
         RETURN FALSE;
         RETURN FALSE;
         DO;
         IF IS_TRIPLE(OPERAND,INDEX) | IS_TRIPLE(OPERAND,ADDR_TEMP)
            THEN RETURN FALSE;
            OPERAND = OPERAND & STRIPMASK;
            ACC = REG(TRIPLES(OPERAND + 2) );
              IF ACC ~= NONE & PRIORITY(ACC) = TEMP_PRIORITY & (ACC & "1") = 1
            & PRIORITY(ACC - 1) = FREE_PRIORITY THEN DO;
            CALL FREE_TEMP( TRIPLES(OPERAND + 2 ) );
            ODD_REG = ACC;
            EVEN_REG = ODD_REG - 1;
            PRIORITY(ODD_REG),PRIORITY(EVEN_REG) = FIXED_PRIORITY;
            RETURN TRUE;
         END;
         ELSE RETURN FALSE;
         END;
         RETURN FALSE;
      END;
 END DOUBLE_REG_STATUS;

 GENERATE_OPERATION:
 PROCEDURE(FULLWORD_INSTR,RR_INSTR,HALFWORD_INSTR,REG#,OPERAND);
      DECLARE (FULLWORD_INSTR,HALFWORD_INSTR,RR_INSTR,REG#,OPERAND) BIT(16);
      DECLARE SAVED_PRIORITY BIT(16);
      /*   THIS  ROCEDURE EXPECTS ONE OPERAND IN A REGISTER (ACC); IT MAKES
          THE OTHER OPERAND ADDRESSABLE, AND GENERATES ONE OF THE GIVEN RX
          OR RR INSTRUCTIONS DEPENDING ON THE STATUS OF THE LATTER OPERAND.
          ACC IS UNCHANGED                 */

      SAVED_PRIORITY = PRIORITY(ACC);
      PRIORITY(ACC) = FIXED_PRIORITY;
      ACC1 = ACC;
      CALL MAKE_ADDRESSABLE(OPERAND);
      IF IN_REG THEN CALL EMIT_RR(RR_INSTR,REG#,ACC);
      ELSE IF OP_STORAGE_LENGTH = 4 THEN
      CALL EMIT_RX(FULLWORD_INSTR,REG#,BASE_REG,X_REG,DISPL);
      ELSE IF(OP_STORAGE_LENGTH = 1) | (HALFWORD_INSTR = NULL) | IMMEDIATE
      THEN DO;
         CALL ACCUMULATE(OPERAND);
         CALL EMIT_RR(RR_INSTR,REG#,ACC);
      END;
      ELSE
         CALL EMIT_RX(HALFWORD_INSTR,ACC1,BASE_REG,X_REG,DISPL);
      ACC = ACC1;
      PRIORITY(ACC) = SAVED_PRIORITY;
 END GENERATE_OPERATION;

 IMMED_POWER_OF_2: PROCEDURE (OPERAND) BIT(1);
      DECLARE OPERAND BIT(16);
      IF ~ IMMED(OPERAND) THEN RETURN FALSE;
      ELSE DO;
         OPERAND = OPERAND & STRIPMASK;
         J = 1;
         POWER = 0;
         DO WHILE J < 4096;
            IF OPERAND = J THEN RETURN TRUE;
            J = SHL(J,1);
            POWER = POWER + 1;
         END;
         RETURN FALSE;
      END;
 END IMMED_POWER_OF_2;


 GEN_COND_BRANCH: PROCEDURE(BR_COND);
      DECLARE BR_COND BIT(16);
      /*  MOVE CURRENT_TRIPLE TO POINT TO THE FOLLOWING BZ OR BNZ TRIPLE  */
      CURRENT_TRIPLE = CURRENT_TRIPLE + 3;
      /****/  IF LIST_CODE THEN CALL PRINT_TRIPLE(CURRENT_TRIPLE);
      IF (TRIPLES(CURRENT_TRIPLE) & TRIPLE_OP_MASK ) = BNZ_TRIPLE THEN
         CALL LOCAL_BRANCH(BR_COND,OP1);
      ELSE CALL LOCAL_BRANCH(15 - BR_COND,OP1);
 END GEN_COND_BRANCH;

 GEN_INTEGER_COMPARE: PROCEDURE(OP1_COND,OP2_COND);

      DECLARE (OP1_COND,OP2_COND) BIT(16);

      CALL CHECK_STATUS(OP2);
      IF IN_REG THEN DO;
         CALL GENERATE_OPERATION(C,CR,CH,ACC,OP1);
         CALL GEN_COND_BRANCH(OP2_COND);
      END;
      ELSE
      IF IMMED(OP2) THEN
    DO;
      IF (OP2 & STRIPMASK) = 0 THEN   /*   SPECIAL CASE.NO NEED TO LOAD OP  */
      DO;
         CALL MAKE_ADDRESSABLE(OP1);
         CALL ACCUMULATE(OP1);
         CALL EMIT_RR(LTR,ACC,ACC);
         CALL GEN_COND_BRANCH(OP1_COND);
      END;
      ELSE DO;
         ACC = GET_REG(FREE_PRIORITY);
         CALL EMIT_RX(LA,ACC,0,0,OP2 & STRIPMASK );
         CALL GENERATE_OPERATION(C,CR,CH,ACC,OP1);
         CALL GEN_COND_BRANCH(OP2_COND);
      END;
      END;
      ELSE
      DO;
         CALL MAKE_ADDRESSABLE(OP1);
         CALL ACCUMULATE(OP1);
         CALL GENERATE_OPERATION(C,CR,CH,ACC,OP2);
         CALL GEN_COND_BRANCH(OP1_COND);
      END;

 END GEN_INTEGER_COMPARE;
 GET_OP_INTO_FLT_REG: PROCEDURE(REG_PRIORITY);
      DECLARE REG_PRIORITY BIT(16);
      IF IN_REG THEN
      DO;
          IF REG_PRIORITY = FREE_PRIORITY THEN RETURN;
         IF PRIORITY(ACC) ~= FREE_PRIORITY THEN
         DO;
            FLT_REG = GET_FLT_REG(REG_PRIORITY);
            CALL EMIT_RR(LER,FLT_REG - #GP_REGS,ACC - #GP_REGS );
         END;
         ELSE DO;
            FLT_REG = ACC;
            PRIORITY(FLT_REG) = REG_PRIORITY;
         END;
      END;
      ELSE DO;
         FLT_REG = GET_FLT_REG(REG_PRIORITY);
         CALL EMIT_RX(LE,FLT_REG - #GP_REGS,BASE_REG,X_REG,DISPL);
         IN_REG = TRUE;
      END;

 END GET_OP_INTO_FLT_REG;

 GENERATE_FLT_OPERATION: PROCEDURE(RX_INSTR,RR_INSTR,OPERAND);
      DECLARE (RX_INSTR,RR_INSTR,OPERAND) BIT(16);
      /*  EXPECTS ONE OPERAND IN FLT_REG; THE GIVEN OPERAND IS MADE
          ADDRESSABLE.  GENERATES RX OR RR INSTRUCTION ACCORDING TO THE
          STATUS OF THE LATTER, AND ASSIGNS A TEMP TO FLT_REG , WHICH HOLDS
          THE RESULT OF THE OPERATION .                        */

      CALL MAKE_ADDRESSABLE(OPERAND);
      IF IN_REG THEN CALL EMIT_RR(RR_INSTR,FLT_REG-#GP_REGS, ACC-#GP_REGS);
      ELSE CALL EMIT_RX(RX_INSTR,FLT_REG-#GP_REGS,BASE_REG,X_REG,DISPL);
      PRIORITY(FLT_REG) = TEMP_PRIORITY;
      CALL ASSIGN_TEMP(FLT_REG);
      OP2 = LAST_TEMP;
 END GENERATE_FLT_OPERATION;

 TEST_FOR_BOOLEAN_0: PROCEDURE (BR_COND);
      DECLARE BR_COND BIT(16);
      IF OP2 = NULL THEN DO;
         CALL LOCAL_BRANCH(BR_COND,OP1);
         RETURN;
      END;
         CALL MAKE_ADDRESSABLE(OP2);
         IF ~IN_REG THEN DO;
            IF IMMEDIATE THEN
            DO;   /*   FOLD FOR IMMEDIATE OPERANDS-NO NEED FOR COND BRANCH  */
               IF (BR_COND = BE & DISPL = 0) | (BR_COND = BNE & DISPL ~= 0 )
                  THEN CALL LOCAL_BRANCH(UNCOND,OP1);
               RETURN;
            END;

            IF (DISPL + OP_STORAGE_LENGTH     < 4097)  & X_REG  = 0 THEN
               CALL EMIT_RX(CLI,0,0,BASE_REG,DISPL + OP_STORAGE_LENGTH - 1 );
            ELSE DO;
               CALL ACCUMULATE(OP2);
               CALL EMIT_RR(LTR,ACC,ACC);
            END;
         END;
         ELSE CALL EMIT_RR(LTR,ACC,ACC);
         CALL LOCAL_BRANCH(BR_COND,OP1);

 END TEST_FOR_BOOLEAN_0;
 GEN_FLT_COMPARE: PROCEDURE(OP1_COND,OP2_COND);
      DECLARE (OP1_COND,OP2_COND) BIT(16);
      CALL CHECK_STATUS(OP2);
      IF IN_REG THEN DO;
         FLT_REG = ACC;
         CALL MAKE_ADDRESSABLE(OP1);
         IF IN_REG THEN CALL EMIT_RR(CER,FLT_REG-#GP_REGS,ACC-#GP_REGS);
         ELSE CALL EMIT_RX(CE,FLT_REG - #GP_REGS,BASE_REG,X_REG,DISPL);
         CALL GEN_COND_BRANCH(OP2_COND);
      END;
      ELSE
      DO;
         CALL MAKE_ADDRESSABLE(OP1);
         IF ~IN_REG THEN DO;
            CALL GET_OP_INTO_FLT_REG(FREE_PRIORITY);
            IF MASK(OP1) = TEMP_MASK THEN
               CALL REASSIGN_TEMP(FLT_REG,TRIPLES((OP1 & STRIPMASK) + 2));
         END;
         ELSE FLT_REG = ACC;
         CALL MAKE_ADDRESSABLE(OP2);
         IF IN_REG THEN CALL EMIT_RR(CER,FLT_REG-#GP_REGS,ACC-#GP_REGS);
         ELSE CALL EMIT_RX(CE,FLT_REG-#GP_REGS,BASE_REG,X_REG,DISPL);
         CALL GEN_COND_BRANCH(OP1_COND);
      END;
 END GEN_FLT_COMPARE;

 GENERATE_STRING_OPERATION : PROCEDURE (INSTR);
      DECLARE INSTR BIT(16);
      CALL MAKE_ADDRESSABLE(OP2);
      IF X_REG ~= 0 THEN CALL LOAD_ADDRESS;
      IF OP1 = OP2 THEN CALL EMIT_SS(INSTR,OP_STORAGE_LENGTH-1,
         BASE_REG,DISPL,BASE_REG,DISPL );
    ELSE DO;
      DISPL1 = DISPL;
      BASE_REG1 = BASE_REG;
      PRIORITY(BASE_REG) = FIXED_PRIORITY;
      CALL MAKE_ADDRESSABLE(OP1);
      /*   NOW BASE_REG,DISPL ADDRESS THE FIRST OPERAND (THE TARGET ),
           BASE_REG1,DISPL1 ADDRESS THE SECOND.              */
      IF X_REG ~= 0 THEN CALL LOAD_ADDRESS;
      CALL EMIT_SS(INSTR,OP_STORAGE_LENGTH-1,BASE_REG,DISPL,BASE_REG1,DISPL1);
      CALL RESET_ADDR_REG_PRIORITIES(BASE_REG,BASE_REG1);
    END;
 END GENERATE_STRING_OPERATION;


 GET_TARGET_ADDRESS: PROCEDURE;
      IF FORMAL_PARAMETER THEN DO;
         BASE_REG = STACKTOP;
         OP_STORAGE_LENGTH = STORAGE_LENGTH(OP1);
         DISPL = DISP(OP1) + AR_OFFSET;
         CALL CHECK_MULT_OF_4096;
      END;
      ELSE CALL MAKE_ADDRESSABLE(OP1);
 END GET_TARGET_ADDRESS;

 STORE_REGISTER: PROCEDURE(REG#);
      DECLARE REG# BIT(16);
      /*   STORES THE GIVEN REGISTER INTO THE CURRENTLY ADDRESSED OPERAND  */
      IF REG# >= #GP_REGS THEN   /*  FLT REG   */
         CALL EMIT_RX(STE,REG# - #GP_REGS,X_REG,BASE_REG,DISPL);
      ELSE   /*   GENERAL REG   */
      IF OP_STORAGE_LENGTH >= 4 THEN CALL EMIT_RX(ST,REG#,X_REG,BASE_REG,DISPL);
      ELSE IF OP_STORAGE_LENGTH = 2 THEN
         CALL EMIT_RX(STH,REG#,X_REG,BASE_REG,DISPL);
      ELSE   /*  OP_STORAGE_LENGTH = 1   */
         CALL EMIT_RX(STC,REG#,X_REG,BASE_REG,DISPL);
 END STORE_REGISTER;

 MAKE_TARGET_ADDR: PROCEDURE;
      DISPL2 = DISPL;
      BASE_REG2 = BASE_REG;
      PRIORITY(BASE_REG) = FIXED_PRIORITY;
      CALL GET_TARGET_ADDRESS;

 END MAKE_TARGET_ADDR;

 SETUP_SS_LOOP: PROCEDURE;
      /*   SETS UP BASE_REGS FOR SS OPERATIONS WITH LONG OPERANDS.
         THESE MAY REQUIRE A LOOP, & HENCE REQUIRE ONE OR TWO BASE REGS
         WHICH CAN BE INCREMENTED WITH IMPUNITY                     */
      DECLARE (BASE_REG1,X_REG1) BIT(16);
      BASE_REG1 = BASE_REG;
      X_REG1 = X_REG;
      IF X_REG ~= 0 THEN CALL LOAD_ADDRESS;
      ELSE DO;
         IF PRIORITY(BASE_REG) ~= FREE_PRIORITY THEN DO;
            BASE_REG2 = GET_REG(BASE_PRIORITY);
            CALL EMIT_RR(LR,BASE_REG2,BASE_REG);
         BASE_REG = BASE_REG2;
         END;
      END;
      CALL MAKE_TARGET_ADDR;
      IF X_REG = X_REG1 & BASE_REG = BASE_REG1 THEN
         /*   WE CAN OPTIMIZE BY USING ONLY ONE BASE REGISTER   */
         BASE_REG = BASE_REG2;
      ELSE DO;
         IF X_REG ~= 0 THEN CALL LOAD_ADDRESS;
         ELSE IF PRIORITY(BASE_REG) ~= FREE_PRIORITY THEN DO;
            BASE_REG1 = GET_REG(BASE_PRIORITY);
            CALL EMIT_RR(LR,BASE_REG1,BASE_REG);
            BASE_REG = BASE_REG1;
         END;
         PRIORITY(BASE_REG) = FIXED_PRIORITY;
      END;
 END SETUP_SS_LOOP;



 GEN_LONG_COMPARE: PROCEDURE (BR_COND);
      /*   GENERATES COMPARISON OF BYTE STRINGS WHOSE LENGTHS EXCCEED 256.
         THE STRINGS, INDICATED BY OP1 & OP2, ARE ASSUMED TO BE OF EQUAL LEN  */
      DECLARE (BR_COND,LOOP_DISPL,B_REG,BR_FAIL,BR_SUCC,FIXUP_DISPL, LEN2,
               COUNTER, TARGET) BIT(16), BR_ON_TRUE BIT(1);

      CALL MAKE_ADDRESSABLE(OP2);
      CALL SETUP_SS_LOOP;
      COUNTER = GET_REG(FIXED_PRIORITY);
      LEN2 = SHR(OP_STORAGE_LENGTH,8);
      DISPL1 = DISPL;
      CALL EMIT_RX(LA,COUNTER,0,0,LEN2);
      LOOP_DISPL = CODE_INDEX;
      CALL EMIT_SS(CLC,255,BASE_REG,DISPL1,BASE_REG2,DISPL2);
      IF CODE_INDEX + 54 > 4095 THEN
      DO;
         /*   WORST CASE LENGTH OF LOOP + CURRENT CODE INDEX > 4095.
              WILL REQUIRE ANOTHER REG FOR BRANCHING TO FAILURE ADDRESS,
              (WHICH IS IMMEDIATELY AFTER THE LOOP BEING SETUP)     */
         B_REG = GET_REG(BASE_PRIORITY);
         PRIORITY(B_REG) = FREE_PRIORITY;
         CALL EMIT_RR(BALR,B_REG,0);
      END;
      ELSE B_REG = CODE_BASE;
      BR_ON_TRUE = ( (TRIPLES(CURRENT_TRIPLE + 3) & TRIPLE_OP_MASK)=BNZ_TRIPLE);
      TARGET = TRIPLES(CURRENT_TRIPLE + 4);  /*   OP1 OF BNZ | BZ TRIPLE FOL */
      FIXUP_DISPL = CODE_INDEX;  /* INSTRUCTION MAY FOLLOW WHICH REQUIRES
              A FIXUP BY THIS PROCEDURE (THIS WOULD BE A BR TO FAILURE ADD   */
      IF BR_COND = BE THEN DO;
         IF BR_ON_TRUE THEN CALL EMIT_RX(BC,BNE,B_REG,0,0);
         ELSE CALL LOCAL_BRANCH(BNE,TARGET);
      END;
      ELSE DO;
         IF BR_ON_TRUE THEN DO;
            BR_FAIL = (2 * BR_COND) MOD 6;
            BR_SUCC = BR_COND;
         END;
         ELSE DO;
            BR_FAIL = BR_COND;
            BR_SUCC = (2 * BR_COND) MOD 6;
         END;
         CALL EMIT_RX(BC,BR_FAIL,B_REG,0,0);
         CALL LOCAL_BRANCH(BR_SUCC,TARGET);
      END;
      /*   COMPLETE THE LOOP SETUP   */
      CALL EMIT_RX(LA,BASE_REG,BASE_REG,0,256);
      IF BASE_REG2 ~= BASE_REG THEN CALL EMIT_RX(LA,BASE_REG2,BASE_REG2,0,256);
       /*   GENERATE A BCT TO LOOP ON CLC INSTR   */
      DISPL = LOOP_DISPL;
      CALL CHECK_MULT_OF_4096;
      CALL EMIT_RX(BCT,COUNTER,X_REG,CODE_BASE,DISPL);
      LEN2 = OP_STORAGE_LENGTH - SHL(LEN2,8) - 1;
      IF LEN2 >= 0 THEN DO;
         CALL EMIT_SS(CLC,LEN2,BASE_REG,DISPL1,BASE_REG2,DISPL2);
         CALL GEN_COND_BRANCH(BR_COND);
      END;
      ELSE CURRENT_TRIPLE = CURRENT_TRIPLE + 3;
      /*   THE VALUE OF CODE_INDEX NOW REPRESENTS THE FAILURE DISPL   */
      IF BR_COND ~= BE | BR_ON_TRUE THEN DO;
         IF B_REG = CODE_BASE THEN DO;
            CODE(FIXUP_DISPL + 2) = SHR(CODE_INDEX,8);
            CODE(FIXUP_DISPL + 3) = CODE_INDEX & "FF";
         END;
         ELSE DO;
            CODE(FIXUP_DISPL + 2) = SHR(FIXUP_DISPL - CODE_INDEX,8);
            CODE(FIXUP_DISPL + 3) = (FIXUP_DISPL - CODE_INDEX) & "FF";
         END;
      END;
      /*   FREE THE REGISTERS USED IN THE LOOP   */
      PRIORITY(BASE_REG), PRIORITY(BASE_REG2) = FREE_PRIORITY;
      PRIORITY(COUNTER) = FREE_PRIORITY;
 END GEN_LONG_COMPARE;

 GEN_LONG_SS_OP: PROCEDURE(INSTR);
      DECLARE (COUNTER,LEN2) BIT(16);
      DECLARE INSTR BIT(16);

      IF OP_STORAGE_LENGTH <= 1536 THEN  /*   EMIT A SERIES OF SS INSTRS  */
      DO;
         IF (X_REG ~= 0) | (DISPL + OP_STORAGE_LENGTH > 3839)
         /*   3839 = 4095 - 256   */
            THEN CALL LOAD_ADDRESS;
         CALL MAKE_TARGET_ADDR;
         IF (X_REG ~= 0) | (DISPL + OP_STORAGE_LENGTH > 3839 ) THEN
            CALL LOAD_ADDRESS;
         I = OP_STORAGE_LENGTH;
         DO WHILE I > 256;
            CALL EMIT_SS(INSTR,255,BASE_REG,DISPL,BASE_REG2,DISPL2);
            I = I - 256;
            DISPL = DISPL + 256;
            DISPL2 = DISPL2 + 256;
         END;
         IF I > 0 THEN
         CALL EMIT_SS(INSTR,I - 1,BASE_REG,DISPL,BASE_REG2,DISPL2);
         CALL RESET_ADDR_REG_PRIORITIES(BASE_REG,BASE_REG2);
      END;
      ELSE   /*     USE  A LOOP TO MAKE THE TRANSFER        */
      DO;
         CALL SETUP_SS_LOOP;
         COUNTER = GET_REG(FREE_PRIORITY);
         LEN2 = SHR(OP_STORAGE_LENGTH,8);
         DISPL1 = DISPL;
         CALL EMIT_RX(LA,COUNTER,0,0,LEN2);
         CALL EMIT_SS(INSTR,255,BASE_REG,DISPL1,BASE_REG2,DISPL2);
         CALL EMIT_RX(LA,BASE_REG,BASE_REG,0,256);
         IF BASE_REG2 ~= BASE_REG THEN
         DO;
            CALL EMIT_RX(LA,BASE_REG2,BASE_REG2,0,256);
            DISPL = CODE_INDEX - 14;
         END;
         ELSE DISPL = CODE_INDEX - 10;

         /*   GENERATE A BCT TO LOOP ON THE SS INSTRUCTION   */
         CALL CHECK_MULT_OF_4096;
         CALL EMIT_RX(BCT,COUNTER,X_REG,CODE_BASE,DISPL);

         LEN2 = OP_STORAGE_LENGTH - SHL(LEN2,8) - 1;
         IF LEN2 >= 0 THEN
         CALL EMIT_SS(INSTR,LEN2,BASE_REG,DISPL1,BASE_REG2,DISPL2);
         CALL RESET_ADDR_REG_PRIORITIES(BASE_REG,BASE_REG2);
      END;
 END GEN_LONG_SS_OP;


 MOVE_STRING: PROCEDURE;
      DECLARE LEN2 BIT(16);
      IF OP_STORAGE_LENGTH <= 256 THEN
      DO;
         IF FORMAL_PARAMETER THEN
         DO;
            IF BASE_REG = STACKTOP & X_REG = 0 & OP_STORAGE_LENGTH = 4 THEN
            DO;
               IF DISP(OP1) = DISPL & STORAGE_LENGTH(OP1) = 4 THEN
                  /*  ARGUMENT IS THE RESULT OF A FUNCTION CALL AND IS
                      ALREADY IN PLACE.                  */
                  RETURN;
            END;
         END;
         LEN2 = OP_STORAGE_LENGTH;
         IF X_REG ~= 0 | DISPL > 4092 THEN CALL LOAD_ADDRESS;
         CALL MAKE_TARGET_ADDR;

         /*   BE CAREFUL MOVING TEMPS INTO VARIABLES WITH SHORTER
             STORAGE LENGTH   */
         IF LEN2 > OP_STORAGE_LENGTH THEN
            DISPL2 = DISPL2 + LEN2 - OP_STORAGE_LENGTH;
         /*   DON'T COPY TOO MUCH.  NOTE  FUNCTION VARIABLES HAVE
              STORAGE_LENGTH COLUMN = ACTIVATION RECORD SIZE        */
         ELSE OP_STORAGE_LENGTH = LEN2;

         IF X_REG ~= 0 THEN CALL LOAD_ADDRESS;
         CALL EMIT_SS(MVC,OP_STORAGE_LENGTH-1,BASE_REG,DISPL,BASE_REG2,DISPL2);
         CALL RESET_ADDR_REG_PRIORITIES(BASE_REG2,BASE_REG);
      END;
      ELSE     /*   LENGTH > 256   */
      CALL GEN_LONG_SS_OP(MVC);

 END MOVE_STRING;

 MOVE_OP: PROCEDURE;

      DECLARE SAVED_PRIORITY BIT(16);



      CALL MAKE_ADDRESSABLE(OP2);
      IF IMMEDIATE THEN DO;
         DISPL2 = DISPL;
         CALL GET_TARGET_ADDRESS;
         IF OP_STORAGE_LENGTH = 1  & X_REG  = 0 THEN   /*  FUDGE AN SI INSTR */
            CALL EMIT_RX(MVI,SHR(DISPL2,4),DISPL2 & "F",BASE_REG,DISPL);
         ELSE DO;
            FIX_BASE_REG_PRIORITIES;
            ACC1 = GET_REG(FREE_PRIORITY);
            IF DISPL2 = 0 THEN CALL EMIT_RR(SR,ACC1,ACC1);  ELSE
            CALL EMIT_RX(LA,ACC1,0,0,DISPL2);
            CALL STORE_REGISTER(ACC1);
            CALL RESET_BASE_REG_PRIORITIES;
         END;
      END;
      ELSE
      IF IN_REG THEN DO;
         SAVED_PRIORITY = PRIORITY(ACC );
         PRIORITY(ACC ) = FIXED_PRIORITY;
         ACC1 = ACC;
         CALL GET_TARGET_ADDRESS;
         CALL STORE_REGISTER(ACC1);
         PRIORITY(ACC1) = SAVED_PRIORITY;
      END;
      ELSE
      IF OP_STORAGE_LENGTH < 3 THEN DO;
         CALL GET_OP_INTO_REG(FREE_PRIORITY);
         SAVED_PRIORITY = PRIORITY(ACC );
         PRIORITY(ACC ) = FIXED_PRIORITY;
         ACC1 = ACC;
         CALL GET_TARGET_ADDRESS;
         CALL STORE_REGISTER(ACC1);
         PRIORITY(ACC1) = SAVED_PRIORITY;
      END;
      ELSE CALL MOVE_STRING;
 END MOVE_OP;


 MOVE_MONITOR_ARG: PROCEDURE(ARG);

      /*   USED IN MONITOR CALL SEQUENCES     */
      /*   MOVES CURRENTLY ADDRESSED OPERAND INTO THE ARG LOCATION SPECIFIED */

      DECLARE ARG BIT(16);
      IF ~IN_REG & (OP_STORAGE_LENGTH < 4 | IMMEDIATE ) THEN
         CALL GET_OP_INTO_REG (FREE_PRIORITY);
      IF IN_REG THEN DO;
      IF ACC < #GP_REGS THEN CALL EMIT_RX(ST,ACC,0,ORG,ARG);
      ELSE CALL EMIT_RX(STE,ACC,0,ORG,ARG);
      END;
      ELSE DO;
         IF X_REG ~= 0 THEN DO;
            CALL LOAD_ADDRESS;
            CALL RESET_ADDR_REG_PRIORITIES(BASE_REG,0);
         END;
         CALL EMIT_SS(MVC,3,ORG,ARG,BASE_REG,DISPL);
      END;
 END MOVE_MONITOR_ARG;


 LOGICAL_SHIFT: PROCEDURE (INSTR);
      DECLARE INSTR BIT(16);
      CALL LOAD_OPERAND;
      ACC1 = ACC;
      PRIORITY(ACC) = FIXED_PRIORITY;
      CALL MAKE_ADDRESSABLE(OP2);
      IF IMMEDIATE THEN DO;
         IF DISPL ~= 0 THEN DO;
            IF DISPL = 1 THEN CALL EMIT_RR(AR,ACC1,ACC1);
            ELSE CALL EMIT_RX(INSTR,ACC1,0,0,DISPL);
         END;
      END;
      ELSE DO;
         CALL FORCE_INTO_BASE_REG;   /*  GET INTO A NON-ZERO REG IF NOT   */
         CALL EMIT_RX(INSTR,ACC1,0,BASE_REG,0);
      END;
      PRIORITY(ACC1) = TEMP_PRIORITY;
      CALL RESET_ADDR_REG_PRIORITIES(BASE_REG,0);

 END LOGICAL_SHIFT;


 SELECT: PROCEDURE;
      /*   PROCEDURE CALLED BY IN & INTO CASES FOR SELECTING A BYTE
           AND A BIT WITHIN THAT BYTE FROM THE GIVEN ORDINALITY (OP1).  THIS
           IS ACCOMPLISHED BY DIVIDING BY 8 : THE REMAINDER SELECTS THE
           BIT, THE QUOTIENT SELECTS THE BYTE   */
      CALL MAKE_ADDRESSABLE(OP1);
      IF GET_STOR_LEN(OP2) = 1 THEN DO;
         /*   NOT NECESSARY TO COMPUTE THE BYTE-THERE IS ONLY ONE   */
         BYTE_XREG = 0;
         CALL GET_INTO_ODD_REG;
      END;
      ELSE DO;
         CALL GET_INTO_EVEN_REG;
         CALL EMIT_RX(SRDL,EVEN_REG,0,0,3);
         CALL EMIT_RX(SRL,ODD_REG,0,0,29);
         BYTE_XREG = EVEN_REG;
      END;
      /*   BYTE_XREG NOW SELECTS THE BYTE, ODD_REG THE BIT   */
      CALL MAKE_ADDRESSABLE(OP2);
      IF X_REG ~= 0 THEN CALL LOAD_ADDRESS;
      CALL RESET_ADDR_REG_PRIORITIES(BASE_REG,0);
 END SELECT;


 FOLD_BIT_OP: PROCEDURE (INSTR);
      /*   USED FOR GEN CODE FOR IN & INTO TRIPLES WHEN BIT ORDINALITY IS
           KNOWN AT COMPILE TIME          */
      DECLARE (BIT_ORD,BYTE_ORD,MASK,INSTR) BIT(16);
      DISPL = OP1 & STRIPMASK;
      BIT_ORD = DISPL MOD 8;
      BYTE_ORD = DISPL / 8;
      CALL MAKE_ADDRESSABLE(OP2);
      IF DISPL + BYTE_ORD > 4095 & X_REG ~= 0 THEN CALL LOAD_ADDRESS;
      DISPL = DISPL + BYTE_ORD;
      CALL CHECK_MULT_OF_4096;
      IF X_REG ~= 0 THEN CALL LOAD_ADDRESS;
      MASK = SHR("80",BIT_ORD);
      /*   FUDGE AN SI INSTRUCTION   */
      CALL EMIT_RX(INSTR,SHR(MASK,4),MASK & "F",BASE_REG,DISPL);
 END FOLD_BIT_OP;



 GEN_TRANSFER_TO_MONITOR: PROCEDURE;
      /*   DETERMINE WHICH GENERAL REGISTERS NEED TO BE SAVED   */
      I = 9;
      DO WHILE PRIORITY(I) = FREE_PRIORITY & I ~= -1;
         I = I - 1;
      END;
      IF I = -1 THEN I = 15;
      /*   SAVE PASCAL REGISTER USAGE, LOAD THE BASE REGS FOR THE MONITOR  */
      CALL EMIT_RX(STM,11,I,ORG,PASCAL_REGS);
      CALL FLUSH_REG(10);
      CALL EMIT_RX(LM,11,13,ORG,MON_BASE_REGS);
      /*   BRANCH INTO MONITOR JUMP TABLE   */
      CALL EMIT_RX(BAL,10,0,13,SERVICE_CODE * 4 + 72);
 END GEN_TRANSFER_TO_MONITOR;

 REAL_ARG_REAL_VALUE: PROCEDURE;
      /*   USED FOR GENERATING MONITOR CALLS WHICH HAVE REAL ARGUMENTS (1),
           AND RETURN A REAL VALUE. WE ATTEMPT TO MAKE ENTRY TO THESE
           MONITOR CALLS PARTICULARLY EFFICIENT BY LOADING ONLY 1
           BASE REG, AND SAVING ONLY THOSE REGS ACTUALLY USED BY
           THE ROUTINES (WHICH ARE NOT CURRENTLY BEING USED IN THE PASCAL CODE).
           THESE CALLS USE ONLY REGS 14..1 FOR SCRATCH,
           EXCEPT FOR EXP, WHICH USES 14..4.              */

      DECLARE FLT_ARG_REG BIT(16) INITIAL (22);
      CALL MAKE_ADDRESSABLE(OP1);
      /*   FLUSH THE FLOATING POINT REGS   */
      DO I = 16 TO 22 BY 2;
         CALL FLUSH_REG(I);
      END;
      IF IN_REG THEN DO;
         IF ACC = FLT_ARG_REG THEN  ;   /*   ARG IN PLACE ALREADY   */
         ELSE CALL EMIT_RR(LER,FLT_ARG_REG - 16,ACC - 16);
      END;
      ELSE
         CALL EMIT_RX(LE,FLT_ARG_REG - 16, X_REG,BASE_REG,DISPL);
      PRIORITY(16) = TEMP_PRIORITY;
      CALL ASSIGN_TEMP(16);   /*   VALUE IS RETURNED IN FLT REG 0   */
      OP2 = LAST_TEMP;   /*   ASSIGN A TEMP TO THE VALUE WHICH IS RETURNED
         IN FLT REG 0           */
      /*   SAVE PASCAL GENERAL REG USAGE   */
      IF SERVICE_CODE = 3 THEN    /*  CALL TO EXP-NEEDS MORE REGS   */
      DO;
         I = 4;
         J = 15;
      END;
      ELSE DO;
         I = 2;
         J = 14;
      END;
      /*   DETERMINE WHICH REGS NEED TO BE FLUSHED   */
      DO WHILE  I > -1 & PRIORITY(I) ~= FREE_PRIORITY;
         I = I - 1;
      END;
      IF I = -1 THEN I = J;
      CALL EMIT_RX(STM,13,I,ORG,PASCAL_REGS + 8);
      CALL FLUSH_REG(LINK);
      /*   LOAD ONLY ONE BASE REG - REG 13   */
      CALL EMIT_RX(LOAD,13,0,ORG,MON_BASE_REGS + 8);
      CALL EMIT_RX(BAL,LINK,0,13,SERVICE_CODE * 4 + 72);
 END REAL_ARG_REAL_VALUE;

 ONE_INT_ARG_INT_VALUE: PROCEDURE;
      CALL MAKE_ADDRESSABLE(OP1);
      CALL FLUSH_REG(9);
      IF IN_REG & ACC = 9 THEN ;
      ELSE CALL GET_OP_INTO_REG#(9);
      PRIORITY(9) = TEMP_PRIORITY;
      CALL ASSIGN_TEMP(9);
      OP2 = LAST_TEMP;
      CALL GEN_TRANSFER_TO_MONITOR;
 END ONE_INT_ARG_INT_VALUE;

 INT_ARGS: PROCEDURE;
      /*   GENERATES MONITOR CALLS WHICH HAVE ONE OR TWO INTEGER ARGUMENTS  */
      IF OP2 ~= NULL THEN DO;
         CALL MAKE_ADDRESSABLE(OP2);
         CALL FLUSH_REG(8);
         IF IN_REG & ACC = 8 THEN   ;
         ELSE CALL GET_OP_INTO_REG#(8);
      END;
      CALL MAKE_ADDRESSABLE(OP1);
      CALL FLUSH_REG(9);
      IF IN_REG & ACC = 9 THEN ;
      ELSE CALL GET_OP_INTO_REG#(9);
      CALL GEN_TRANSFER_TO_MONITOR;
 END INT_ARGS;


 INSERT_SUBRANGE: PROCEDURE;
      DECLARE (A,S_REG) BIT(16);

 PREPARE_RANGE_OPERANDS: PROCEDURE;
      CALL MAKE_ADDRESSABLE(OP1);
      CALL GET_OP_INTO_REG(BASE_PRIORITY);
      PRIORITY(ACC) = FIXED_PRIORITY;
      A = ACC;
      ACC = GET_REG(BASE_PRIORITY);
      PRIORITY(ACC) = FIXED_PRIORITY;
      CALL EMIT_RR(LR,ACC,A);
      CALL GENERATE_OPERATION(S,SR,SH,ACC,OP2);
 END PREPARE_RANGE_OPERANDS;

      OP_STORAGE_LENGTH = GET_STOR_LEN(TRIPLES(CURRENT_TRIPLE + 5) );
      IF OP_STORAGE_LENGTH <= 4 THEN
      DO;
         CALL PREPARE_RANGE_OPERANDS;
         S_REG = GET_REG(FREE_PRIORITY);
         /*   FORM A MASK WITH THE SPECIFIED BITS SET. THIS IS ACCOMPLISHED
              BY LOADING A REG WITH ALL ONES AND SHIFTING OUT ALL THOSE
              WHOSE ORDINALITIES ARE OUTSIDE THE GIVEN SUBRANGE   */
         CALL EMIT_RX(LOAD,S_REG,0,ORG,CONSTM1);
         CALL EMIT_RX(SLL,S_REG,0,ACC,31);
         CALL EMIT_RX(SRL,S_REG,0,A,0);
         PRIORITY(A),PRIORITY(ACC) = FREE_PRIORITY;
         CURRENT_TRIPLE = CURRENT_TRIPLE + 3;
         IF LIST_CODE THEN CALL PRINT_TRIPLE(CURRENT_TRIPLE);
         /*   STORE IN TEMP STORAGE AREA IN ORG SEGMENT   */
         CALL EMIT_RX(ST,S_REG,0,ORG,DS1);
         /*   OR THE MASK INTO THE SPECIFIED SET   */
         CALL MAKE_ADDRESSABLE(OP2);   /*   SET GIVEN IN OP2 OF INTO TRIPLE */
         IF X_REG ~= 0 THEN CALL LOAD_ADDRESS;
         CALL EMIT_SS(OC,OP_STORAGE_LENGTH - 1,BASE_REG,DISPL,ORG,DS1);
      END;
      ELSE IF OP_STORAGE_LENGTH <= 8 THEN
      DO;
         CALL PREPARE_RANGE_OPERANDS;
         S_REG = GET_REG_PAIR;
         CALL EMIT_RX(LM,S_REG,S_REG+1,ORG,CONSTM1);
         CALL EMIT_RX(SLDL,S_REG,0,ACC,63);
         CALL EMIT_RX(SRDL,S_REG,0,A,0);
         PRIORITY(A),PRIORITY(ACC) = FREE_PRIORITY;
         CURRENT_TRIPLE = CURRENT_TRIPLE + 3;
         IF LIST_CODE THEN CALL PRINT_TRIPLE(CURRENT_TRIPLE);
         /*   STORE IN TEMP STORAGE AREA IN ORG SEGMENT   */
         CALL EMIT_RX(STM,S_REG,S_REG+1,ORG,DS1);
         /*   OR THE MASK INTO THE SPECIFIED SET   */
         CALL MAKE_ADDRESSABLE(OP2);   /*   SET GIVEN IN OP2 OF INTO TRIPLE */
         IF X_REG ~= 0 THEN CALL LOAD_ADDRESS;
         CALL EMIT_SS(OC,OP_STORAGE_LENGTH - 1,BASE_REG,DISPL,ORG,DS1);
      END;
      ELSE DO;
         /*   STORAGE LENGTH OF GIVEN SET > 8 BYTES. FORMING THE MASK
              CANNOT BE DONE CONVENIENTLY IN REGISTERS. DO OFFLINE IN
              CALL TO MONITOR          */

         SERVICE_CODE = 34;
         CALL INT_ARGS;
         CURRENT_TRIPLE = CURRENT_TRIPLE + 3;
         IF LIST_CODE THEN CALL PRINT_TRIPLE(CURRENT_TRIPLE);
         /*  R9 RETURNS THE ADDRESS OF THE MASK TO BE OR'D IN  */
         PRIORITY(9) = FIXED_PRIORITY;
         CALL MAKE_ADDRESSABLE(OP2);
         IF X_REG ~= 0 THEN CALL LOAD_ADDRESS;
         CALL EMIT_SS(OC,OP_STORAGE_LENGTH - 1, BASE_REG,DISPL,9,0);
         PRIORITY(9) = FREE_PRIORITY;
         ;
      END;
 END INSERT_SUBRANGE;



      /*   TO ASSOCIATE LINE NUMBERS IN THE PASCAL SOURCE WITH INSTRUCTIONS
           IN THE GENERATED CODE, A LINE# ARRAY IS USED. WHENEVER THE LINE
           NUMBER CHANGES (AS INDICATED BY A BIT IN THE TRIPLES FOR A
           CHANGE OF 1 OR BY A LINE# TRIPLE IF THE CHANGE IS BY MORE THAN ONE)
           AN ENTRY (OR ENTRIES) IS MADE IN THE LINE# ARRAY, (INDEXED BY THE
           LINE NUMBER(S) ) CONTAINING THE CURRENT DISPLACEMENT RELATIVE TO
           THE BEGINNING OF THE ENTIRE CODE SEGMENT. (IN PRACTICE, A SMALL
           BUFFER IS USED, AND WHEN FULL, IS IMMEDIATELY SWAPPED OUT TO A
           LINE# FILE.). IN THIS WAY, THE MONITOR CAN DETERMINE WHICH HIGH
           LEVEL (PASCAL) STATEMENT WAS BEING EXECUTED WHEN A RUN ERROR OCCURS,
           BY SEARCHING THE LINE# ARRAY FOR THE GREATEST LOWER BOUND TO
           THE RELATIVE DISPLACEMENT OF THE LAST EXECUTED INSTRUCTION IN THE
           PASCAL CODE, TAKING AS THE LINE NUMBER THE ASSOCIATED INDEX.     */


 NEXT_LINE: PROCEDURE(LINE#);

      /*   USED FOR UPDATING THE LINE# ARRAY WHEN THE CURRENT LINE CHANGES.
           WHEN THE LINE# BUFFER IS FULL, IT IS WRITTEN OUT TO THE LINE# FILE,
           AND LINE_BUFF_PTR IS RESET.                               */

      DECLARE LINE# BIT(16);
      DO I = CURRENT_LINE# + 1 TO LINE#;
         LINE#BUFF(LINE_BUFF_PTR) = CODE_INDEX + ENTRY_POINT;
         LINE_BUFF_PTR = LINE_BUFF_PTR + 1;
         IF LINE_BUFF_PTR > 20 THEN DO;
         /*   OUTPUT THE FULL BUFFER. NOTE THE "DESCRIPTOR" FOR LINE#BUFF
         (LINE_NUMS) HAS BEEN SET IN INITIALIZE   */
            OUTPUT(LINE#FILE) = LINE_NUMS;
            LINE_BUFF_PTR = 1;
         END;
      END;
      CURRENT_LINE# = LINE#;
      IF LIST_CODE THEN OUTPUT(1) = '+' || X70 || SPACE 40X || 'LINE# ' ||
         CURRENT_LINE#;
 END NEXT_LINE;



       /*           C O D E   G E N E R A T I O N                  */


 GENERATE_CODE: PROCEDURE;


      /*     GENERATES CODE FOR THE CURRENT SET OF TRIPLES        */

      CODE_INDEX = 0;
      CURRENT_TRIPLE = 9;
      CALL NEXT_LINE(TRIPLES(7));   /*FILL IN LINE# VECTOR ELEMENTS DENOTED
                             /*   BY FIRST LINE# TRIPLE   */
      CURRENT_LEVEL = PSEUDO_REG( CURRENT_PROCEDURE ) + 1;
      CURRENT_PROC_SEQ# = TRIPLES(1);
      /*   MAKE ENTRY INTO TRANSFER VECTOR FOR CURRENT PROCEDURE   */
      TRANSFER_VECTOR(CURRENT_PROC_SEQ#) = ENTRY_POINT;
      /*  STORE CURRENT_AR_BASE INTO DISPLAY          */
      IF CURRENT_LEVEL ~= 1 THEN
         CALL EMIT_RX(ST,CURRENT_AR_BASE,0,CURRENT_AR_BASE,CURRENT_LEVEL*4+12);

      /*  STORE RETURN ADDRESS INTO A.R.   */
      CALL EMIT_RX(ST,LINK,0,CURRENT_AR_BASE,4);
      /*   STORAGE LENGTH ENTRY FOR A PROCEDURE CONTAINS ITS ACTIVATION
           RECORD SIZE.  COMPUTE THE STACKTOP FROM THE A.R. BASE ADDRESS
           & THE A.R.  SIZE                             */
      DISPL = STORAGE_LENGTH(CURRENT_PROCEDURE);
      CALL CHECK_MULT_OF_4096;
      CALL EMIT_RX(LA,STACKTOP,CURRENT_AR_BASE,X_REG,DISPL);
      /*   CHECK FOR OVERFLOW OF RUN-TIME STORAGE    */
      CALL EMIT_RX(C,STACKTOP,0,ORG,MAX_TOP);
      CALL EMIT_RX(BC,BH,0,ORG,MEM_OVERFLOW);

      DO FOREVER;

      IF LIST_CODE THEN CALL PRINT_TRIPLE(CURRENT_TRIPLE);
      IF (TRIPLES(CURRENT_TRIPLE) & LINE#MASK) ~= 0 THEN
         CALL NEXT_LINE(CURRENT_LINE# + 1);

      DO CASE (TRIPLES(CURRENT_TRIPLE) & TRIPLE_OP_MASK);

      /*   LOAD   */
      CALL LOAD_OPERAND;


      /*   MONITOR CALL   */



      /*   THIS TRIPLE INDICATES A SERVICE CALL TO THE PASCAL RUN MONITOR
           IS TO BE MADE. OP1 , OP2 INDICATE THE ARGUMENTS, IF ANY, AND
           THE SERVICE CODE IS IN THE LENGTH FIELD.
               TO PASS INTEGER ARGUMENTS, REGS 9 & 8 ARE USED FOR
           OPERANDS 1, 2, RESPECTIVELY. REG 9, WHICH IS ASSIGNED A TEMPORARY,
           IS USED TO RETURN INTEGER VALUES. (BY "INTEGER" IT IS MEANT
           ANY NUMERICAL QUANTITY WHICH CAN BE PROCESSED IN A GENERAL REG-
           ISTER SUCH AS BOOLEANS, INTEGER, OR ADDRESSES).
           FLT REG 6 IS USED TO PASS REAL ARGUMENTS.                 */

      DO;
      SERVICE_CODE = SHR(TRIPLES(CURRENT_TRIPLE),8);
      DO CASE SERVICE_CODE;
         /*   CASE  0 - SIN  */
         CALL REAL_ARG_REAL_VALUE;
         /*   CASE  1 - COS  */
         CALL REAL_ARG_REAL_VALUE;
         /*   CASE  2 - ARCTAN  */
         CALL REAL_ARG_REAL_VALUE;
         /*   CASE  3 - EXP   */
         CALL REAL_ARG_REAL_VALUE;
         /*   CASE  4 - LN  */
         CALL REAL_ARG_REAL_VALUE;
         /*   CASE  5 - SQRT  */
         CALL REAL_ARG_REAL_VALUE;
         /*   CASE  6 - ABSFLT  */
         /*   DONE INLINE   */   ;
         /*   CASE  7 - SQRFLT  */
         /*   DONE INLINE   */   ;
         /*   CASE  8 - ROUND  */
         /*   DONE INLINE   */   ;
         /*   CASE  9 - TRUNC  */
         /*   DONE INLINE   */   ;
         /*   CASE 10 - ABS  */
         /*   DONE INLINE   */   ;
         /*   CASE 11 - SQR  */
         /*   DONE INLINE   */   ;
         /*   CASE 12 - ODD  */
         /*   DONE INLINE   */   ;
         /*   CASE 13 - EOLN  */
         CALL ONE_INT_ARG_INT_VALUE;
         /*   CASE 14 - EOF  */
         CALL ONE_INT_ARG_INT_VALUE;
         /*   CASE 15 - NEW  */
         CALL ONE_INT_ARG_INT_VALUE;
         /*   CASE 16 - DISPOSE  */
         ;
         /*   CASE 17 - GET  */
         CALL INT_ARGS;
         /*   CASE 18 - PUT  */
         CALL INT_ARGS;
         /*   CASE 19 - RESET  */
         CALL INT_ARGS;
         /*   CASE 20 - REWRITE  */
         CALL INT_ARGS;
         /*   CASE 21 - READ_INT  */
         CALL ONE_INT_ARG_INT_VALUE;
         /*   CASE 22 - READ_REAL  */
         DO;
            CALL FLUSH_REG(22);
            PRIORITY(22) = TEMP_PRIORITY;
            CALL ASSIGN_TEMP(22);
            CALL INT_ARGS;
            OP2 = LAST_TEMP;
         END;
         /*   CASE 23 - READ_CHAR  */
         CALL ONE_INT_ARG_INT_VALUE;
         /*   CASE 24 - WRITE_INT  */
         CALL INT_ARGS;
         /*   CASE 25 - WRITE_REAL  */
         DO;
            CALL MAKE_ADDRESSABLE(OP1);
            CALL FLUSH_REG(9);
            IF IN_REG & ACC = 9 THEN ;
            ELSE CALL GET_OP_INTO_REG#(9);
            CALL MAKE_ADDRESSABLE(OP2);
            CALL FLUSH_REG(22);
            IF IN_REG THEN DO;
               IF ACC = 22 THEN ;
               ELSE CALL EMIT_RR(LER,6,ACC - 16);
            END;
            ELSE CALL EMIT_RX(LE,6,X_REG,BASE_REG,DISPL);
            CALL GEN_TRANSFER_TO_MONITOR;
         END;
         /*   CASE 26 - WRITE_BOOL  */
         CALL INT_ARGS;
         /*   CASE 27 - WRITE_CHAR  */
         CALL INT_ARGS;
         /*   CASE 28 - WRITE_STRING  */
         CALL INT_ARGS;
         /*   CASE 29 - READLN  */
         CALL INT_ARGS;
         /*   CASE 30 - WRITELN  */
         CALL INT_ARGS;
         /*   CASE 31 - PAGE  */
         CALL INT_ARGS;
         /*   CASE 32 - RANGE_ERR  */
         /*   HERE MOST OF THE SETUP INSTRUCTIONS ARE DONE OFFLINE IN
              THE ORG SEGMENT TO SAVE CODE , AS THIS CALL MAY OCCUR
              QUITE FREQUENTLY.                        */
         CALL EMIT_RX(BAL,LINK,0,ORG,SUBRANGE_ERROR);
         /*   CASE 33 - MEM_OVFLO  */
         /*   HANDLED ELSEWHERE   */   ;

         /*   CASE 34 - INSERT SUBRANGE   */
         /*   HANDLED ELSEWHERE   */
      ;

         /*   CASE 35 - CLOCK   */
           /*   RETURNS THE VALUE OF THE CLOCK - NO ARGUMENTS   */
         DO;
            CALL FLUSH_REG(9);
            PRIORITY(9) = TEMP_PRIORITY;
            CALL ASSIGN_TEMP(9);
            OP2 = LAST_TEMP;
            CALL GEN_TRANSFER_TO_MONITOR;
         END;
      END;

      END;   /*   MONITOR CALLS   */


      /*   TRUNCATE   */
      DO;
         FLT_REG = GET_FLT_REG(FREE_PRIORITY);
         FLT_ACC = FLT_REG - #GP_REGS;
         CALL EMIT_RR(SDR,FLT_ACC,FLT_ACC);
         CALL MAKE_ADDRESSABLE(OP1);
         IF IN_REG THEN CALL EMIT_RR(LER,FLT_ACC,ACC - #GP_REGS);
         ELSE CALL EMIT_RX(LE,FLT_ACC,X_REG,BASE_REG,DISPL);
         /*   ADD AN UNNORMALIZED FP 0 TO CAUSE LOSS OF FRACTION DURING
            PRE-NORMALIZATION                      */
         CALL EMIT_RX(AW,FLT_ACC,ORG,0,CON4E);
         /*   STORE ENTIRE FP REG INTO WORK AREA     */
         CALL EMIT_RX(STD,FLT_ACC,0,ORG,DS1);
         ACC = GET_REG(TEMP_PRIORITY);   /*  ACC WILL CONTAIN TRUNC RESULT  */
         CALL ASSIGN_TEMP(ACC);
         /*   PUT LOWER ORDER HALF (WHICH IS THE DESIRED RESULT) INTO TEMP REG*/
         CALL EMIT_RX(LOAD,ACC,0,ORG,DS1 + 4);
         /*   TEST IF ORIGINAL ARG WAS NEGATIVE   */
         CALL EMIT_RR(LTDR,FLT_ACC,FLT_ACC);
         CALL FORWARD_CODE_BRANCH(BNL,6);
         CALL EMIT_RR(LCR,ACC,ACC);
         OP2 = LAST_TEMP;
      END;

      /*   FLOAT   */
      DO;
         ACC1 = GET_REG(FIXED_PRIORITY);
         CALL MAKE_ADDRESSABLE(OP1);
         CALL GET_OP_INTO_REG(FREE_PRIORITY);
         CALL EMIT_RR(LPR,ACC1,ACC);   /*  LOAD ABS(OP1) INTO A GEN REG  */
         CALL EMIT_RX(ST,ACC1,0,ORG,DS4E + 4);
         /*  DS4E WOULD NOW CONTAIN FP ABS(OP1)       */
         FLT_REG = GET_FLT_REG(TEMP_PRIORITY);
         FLT_ACC = FLT_REG - #GP_REGS;
         CALL EMIT_RX (LD,FLT_ACC,0,ORG,DS4E);
         /*   GET INTO A FLT REG       */
         CALL EMIT_RX(AD,FLT_ACC,0,ORG,CONSTD0);
         /*   ADD FLT PT 0 TO FORCE NORMALIZATION     */
         CALL EMIT_RR(LTR,ACC,ACC);  /*  TEST IF OPERAND WAS NEGATIVE  */
         CALL FORWARD_CODE_BRANCH(BNL,6);
         CALL EMIT_RR(LCDR,FLT_ACC,FLT_ACC);
         PRIORITY(ACC1) = FREE_PRIORITY;
         CALL ASSIGN_TEMP(FLT_REG);
         OP2 = LAST_TEMP;
      END;

      /*     BCH_TARGET     */

      DO;
         IF SHR(TRIPLES(CURRENT_TRIPLE),8) = 0 THEN   /*  A NEW BASIC BLOCK
            IS BEING ENTERED   */   CALL FLUSH_ALL_REGS;
         OPERAND1 = OP1;
         IF OPERAND1 ~= NULL THEN
         DO;      /*  BRANCH TARGET REPRESENTS A USER DEFINED LABEL. THE
                 /*  FIRST OPERAND POINTS TO THE SY TABLE ENTRY FOR THAT LABEL*/

             IF PSEUDO_REG(OPERAND1) ~= NULL THEN  /* A SEG# HAS BEEN
                ASSIGNED,INDICATING EXTERNAL REFS HAVE BEEN MADE.
                FILL IN THE TRANSFER VECTOR ENTRY                 */
             TRANSFER_VECTOR( PSEUDO_REG(OPERAND1) ) = CODE_INDEX +
           TRANSFER_VECTOR ( CURRENT_PROC_SEQ# );
             /* REPLACE TRIPLE# WITH DISPL,SET A MASK BIT.   */
             DISP(OPERAND1) = "80000000" + CODE_INDEX;
         END;
         IF OP2 ~= NULL THEN CALL FIXUP(OP2);
         /*   NOW PUT DISPL IN FIRST OPERAND.   */
         OP1 = CODE_INDEX;

      END;
      /*   INDEX   */
         /*   GENERATES NO CODE UNTIL REFERENCED    */
       ;
      /*   TEMP   */
      /*   CREATE A TEMPORARY WITH THE VALUE OF OP1   */
      DO;
         IF OP2 = NULL THEN  /*   INTEGER OR BOOLEAN TO BE CONTAINED IN A REG */
         DO;
            IF OP1 ~= NULL THEN CALL LOAD_OPERAND;
            ELSE DO;
               ACC = GET_REG(TEMP_PRIORITY);
               CALL ASSIGN_TEMP(ACC);
               OP2 = LAST_TEMP;
            END;
         END;
         ELSE
         DO;
            OP_STORAGE_LENGTH = (SHR(TRIPLES(CURRENT_TRIPLE),8) & "FF" ) + 1;
            IF OP1 ~= NULL THEN DO;
               CALL MAKE_ADDRESSABLE(OP1);
               IF X_REG ~= 0 THEN CALL LOAD_ADDRESS;
               DISPL1 = DISPL;
               BASE_REG1 = BASE_REG;
               BASE_REG = STACKTOP;
               DISPL = NEXT_TEMP_DISPL;
               CALL CHECK_MULT_OF_4096;
               IF X_REG ~= 0 THEN CALL LOAD_ADDRESS;
               CALL GET_TEMP_BYTES(OP_STORAGE_LENGTH);
               CALL EMIT_SS(MVC,OP_STORAGE_LENGTH - 1,BASE_REG,DISPL,
                  BASE_REG1,DISPL1);
            END;
            ELSE  CALL GET_TEMP_BYTES(OP_STORAGE_LENGTH);
            OP2 = LAST_TEMP;
         END;

      END;   /*   TEMP   */
      /*   STORE   */
      DO;
         CALL CHECK_STATUS(OP1);
         IF IN_REG THEN   /*  TARGET IS A TEMP WHICH IS ASSIGNED THE REG ACC */
         DO;
            PRIORITY(ACC) = FIXED_PRIORITY;
            ACC1 = ACC;
            CALL MAKE_ADDRESSABLE(OP2);
            IF IN_REG THEN CALL EMIT_RR(LR,ACC1,ACC);
            ELSE CALL GET_OP_INTO_REG#(ACC1);
            PRIORITY(ACC1) = TEMP_PRIORITY;
         END;
         ELSE
         CALL MOVE_OP;
      END;

      /*   MOVE   */
      DO;
         CALL MAKE_ADDRESSABLE(OP2);
         CALL MOVE_STRING;
      END;
      /*   ADD   */
      DO;
         CALL CHECK_STATUS(OP2);
         IF IN_FREE_REG THEN
         DO;
            PRIORITY(ACC) = TEMP_PRIORITY;
            CALL GENERATE_OPERATION(A,AR,AH,ACC,OP1);
         END;
         ELSE IF IMMED(OP2) THEN DO;
            ACC = GET_REG(TEMP_PRIORITY);
            CALL EMIT_RX(LA,ACC,0,0,OP2 & STRIPMASK);
            CALL GENERATE_OPERATION(A,AR,AH,ACC,OP1);
         END;
         ELSE DO;
            CALL MAKE_ADDRESSABLE(OP1);
            CALL GET_OP_INTO_REG(TEMP_PRIORITY);
            CALL GENERATE_OPERATION(A,AR,AH,ACC,OP2);
         END;
         CALL ASSIGN_TEMP(ACC);
         OP2 = LAST_TEMP;
      END;
      /*   SUBTRACT   */
      DO;
         CALL MAKE_ADDRESSABLE(OP1);
         CALL GET_OP_INTO_REG(TEMP_PRIORITY);
         IF IMMED(OP2) & ((OP2 & STRIPMASK) = 1)  /*  IMMEDIATE "1"   */
            THEN CALL EMIT_RR(BCTR,ACC,0);
         ELSE
            CALL GENERATE_OPERATION(S,SR,SH,ACC,OP2);
         CALL ASSIGN_TEMP(ACC);
         OP2 = LAST_TEMP;
      END;
      /*   MULTIPLY   */
  DO;
      IF IMMED_POWER_OF_2(OP2) THEN
      DO;
         CALL LOAD_OPERAND;
         IF POWER > 1 THEN CALL EMIT_RX(SLA,ACC,0,0,POWER);
         ELSE IF POWER = 1 THEN CALL EMIT_RR(AR,ACC,ACC);
      END;
      ELSE
      DO;
         IF DOUBLE_REG_STATUS(OP1) THEN
            CALL GENERATE_OPERATION(M,MR,MH,EVEN_REG,OP2);
         ELSE IF DOUBLE_REG_STATUS(OP2) THEN
            CALL GENERATE_OPERATION(M,MR,MH,EVEN_REG,OP1);
       ELSE DO;
         CALL CHECK_STATUS(OP2);
         IF IN_REG THEN
         DO;
            CALL GET_INTO_ODD_REG;
            CALL GENERATE_OPERATION(M,MR,MH,EVEN_REG,OP1);
         END;
         ELSE
         DO;
            CALL MAKE_ADDRESSABLE(OP1);
            CALL GET_INTO_ODD_REG;
            CALL GENERATE_OPERATION(M,MR,MH,EVEN_REG,OP2);
         END;
       END;
         CALL RESET_PAIR_PRIORITIES(FREE_PRIORITY,TEMP_PRIORITY);
         CALL ASSIGN_TEMP(ODD_REG);
         OP2 = LAST_TEMP;
      END;
  END;

      /*   DIVIDE   */
      DO;
         CALL MAKE_ADDRESSABLE(OP1);
      /*  OPTIMIZE LATER BY TESTING IF DIVIDEND IS A RESULT OF AN EARLIER
          MULTIPLY, ELIMINATING THE NEED TO FORCE THE SIGN INTO THE EVEN REG */
         IF OP_STORAGE_LENGTH = 1 THEN DO;
            CALL GET_INTO_ODD_REG;
            CALL EMIT_RR(SR,EVEN_REG,EVEN_REG);
         END;
         ELSE DO;
            CALL GET_INTO_EVEN_REG;
            CALL EMIT_RX(SRDA,EVEN_REG,0,0,32);
         END;
         CALL GENERATE_OPERATION(D,DR,NULL,EVEN_REG,OP2);
         CALL RESET_PAIR_PRIORITIES(FREE_PRIORITY,TEMP_PRIORITY);
         CALL ASSIGN_TEMP(ODD_REG);
         OP2 = LAST_TEMP;
      END;
      /*   COMPARE   */
      CALL GEN_INTEGER_COMPARE(BE,BE);
      /*   ADD_DECIMAL   */
      /*   GENERATE AN INCREMENT OF THE BASIC BLOCK COUNTER GIVEN IN OP1  */

      DO;
         DISPL = 4 * (OP1 & STRIPMASK) + BLOCK_COUNTER_BASE;
         IF DISPL < 4096 THEN
            CALL EMIT_SS(AP,"33",ORG,DISPL,ORG,DEC1);
         ELSE   /*  BLOCK COUNTERS NO LONGER DIRECTLY ADDRESSABLE. WE
                    ALLOW A POSSIBLY EXPENSIVE INDEXING OPERATION RATHER
                    THAN GIVE UP.                                  */
         DO;
            BASE_REG = ORG;
            CALL CHECK_MULT_OF_4096;
            CALL LOAD_ADDRESS;
            CALL EMIT_SS(AP,"33",BASE_REG,DISPL,ORG,DEC1);
         END;
      END;

      /*   GREATER   */
      CALL GEN_INTEGER_COMPARE(BH,BL);
      /*   LESS   */
      CALL GEN_INTEGER_COMPARE(BL,BH);
      /*   NOT   */
      DO;
         CALL LOAD_OPERAND;
         CALL EMIT_RX(XOR,ACC,0,ORG,CONST1);
      END;
      /*   ADDFLT   */
      DO;
         CALL CHECK_STATUS(OP2);
         IF IN_FREE_REG THEN DO;
            FLT_REG = ACC;
            CALL GENERATE_FLT_OPERATION(AE,AER,OP1);
         END;
         ELSE DO;
            CALL MAKE_ADDRESSABLE(OP1);
            CALL GET_OP_INTO_FLT_REG(TEMP_PRIORITY);
            CALL GENERATE_FLT_OPERATION(AE,AER,OP2);
         END;
      END;
      /*   SUBTRACTFLT   */
      DO;
         CALL MAKE_ADDRESSABLE(OP1);
         CALL GET_OP_INTO_FLT_REG(TEMP_PRIORITY);
         CALL GENERATE_FLT_OPERATION(SE,SER,OP2);
      END;
      /*   MPYFLT   */
      DO;
         CALL CHECK_STATUS(OP2);
         IF IN_FREE_REG THEN DO;
            FLT_REG = ACC;
            CALL GENERATE_FLT_OPERATION(ME,MER,OP1);
         END;
         ELSE DO;
            CALL MAKE_ADDRESSABLE(OP1);
            CALL GET_OP_INTO_FLT_REG(TEMP_PRIORITY);
            CALL GENERATE_FLT_OPERATION(ME,MER,OP2);
         END;
      END;
      /*   DIVFLT   */
      DO;
         CALL MAKE_ADDRESSABLE(OP1);
         CALL GET_OP_INTO_FLT_REG(TEMP_PRIORITY);
         CALL GENERATE_FLT_OPERATION(DE,DER,OP2);
      END;
      /*   COMPAREFLT   */
      CALL GEN_FLT_COMPARE(BE,BE);
      /*   GREATERFLT   */
      CALL GEN_FLT_COMPARE(BH,BL);
      /*   LESSFLT   */
      CALL GEN_FLT_COMPARE(BL,BH);

      /*  LOAD ADDR  */

      DO;
         CALL MAKE_ADDRESSABLE(OP1);
         CALL LOAD_ADDRESS;
         PRIORITY(BASE_REG) = TEMP_PRIORITY;
         CALL ASSIGN_TEMP(BASE_REG);
         OP2 = NEXT_TEMP - 1;
      END;

      /*   AND   */
      CALL GENERATE_STRING_OPERATION(NC);
      /*   OR   */
      CALL GENERATE_STRING_OPERATION(OC);
      /*   XOR   */
      DO;
         IF GET_STOR_LEN(OP2) > 256 THEN CALL GEN_LONG_SS_OP(XC);
         /*   ALLOW LONG XOR'S FOR ZEROING OUT ACTIVATION RECORDS   */
         ELSE CALL GENERATE_STRING_OPERATION(XC);
      END;
      /*   LSHIFT   */
      CALL LOGICAL_SHIFT(SLL);
      /*   RSHIFT   */
      CALL LOGICAL_SHIFT(SRL);
      /*   CASE 31   */
     ;

      /*  BRANCH   */
      DO;
         OPERAND1 = OP1 & STRIPMASK;
            IF OP2 = NULL | (OP2 & STRIPMASK) = CURRENT_PROC_SEQ# THEN
            CALL LOCAL_BRANCH(UNCOND,OP1);
             ELSE    /*  A PROCEDURE EXIT VIA GOTO     */
             DO;
                /*  GENERATE RELOAD OF CODE_BASE OF OWNER FROM XFER VECTOR  */
                DISPL = TRANSFER_VECTOR_BASE + 4 * ( OP2 & STRIPMASK );
                CALL CHECK_MULT_OF_4096;
                CALL EMIT_RX(LOAD,CODE_BASE,X_REG,ORG,DISPL);
                /*  RELOAD CURRENT_AR_BASE FROM STATIC DISPLAY, USING
                   PSEUDO_REG AS INDEX. RECALL PSEUDO_REG ENTRY FOR A PROC
                   IS THE LEX LEVEL OF ITS B O D Y  - 1;         */

                IF PSEUDO_REG (OWNER(OPERAND1) ) = 0 THEN
                /* EXITING TO GLOBAL ENVIRONMENT        */
                CALL EMIT_RR(LR,CURRENT_AR_BASE,GLOBAL_AR_BASE);
                ELSE
                CALL EMIT_RX(LOAD,CURRENT_AR_BASE,0,CURRENT_AR_BASE,16 +
                   PSEUDO_REG (OWNER (OPERAND1 ) ) * 4 );

                /*   RELOAD STACKTOP    */
                DISPL = STORAGE_LENGTH( OWNER(OPERAND1) );
                CALL CHECK_MULT_OF_4096;
                CALL EMIT_RX(LA,STACKTOP,X_REG,CURRENT_AR_BASE,DISPL);
                /*  GET THE TARGET ADDRESS FROM THE XFER VEC & EMIT BR  */
                IF PSEUDO_REG(OPERAND1) = NULL THEN
                DO;   /*  SEQ# NOT YET ASSIGNED. ASSIGN ONE FROM NEXT_SEQ#   */
                   IF NEXT_SEQ# > TRANSFER_VECTOR_SIZE THEN CALL ERROR
                   ('TRANSFER VECTOR EXCEEDS MAX ALLOWED SIZE');
                   PSEUDO_REG(OPERAND1) = NEXT_SEQ#;
                   IF DISP(OPERAND1) & "80000000" ~= 0 THEN  /*  DISPLACEMENT
                   IS KNOWN - ENTER IT IN THE TRANSFER VECTOR.    */
                   TRANSFER_VECTOR(NEXT_SEQ#) = ("7FFFFFFF" & DISP(OPERAND1) )
                   + TRANSFER_VECTOR(OP2 & STRIPMASK);
                   DISPL = NEXT_SEQ# * 4 + TRANSFER_VECTOR_BASE;
                   NEXT_SEQ# = NEXT_SEQ# + 1;
                END;
                ELSE DISPL = TRANSFER_VECTOR_BASE + PSEUDO_REG(OPERAND1) * 4;
                CALL CHECK_MULT_OF_4096;
                /*  GENERATE A LOAD OF ADDR FROM XFER VECTOR         */
                CALL EMIT_RX(LOAD,LINK,X_REG,ORG,DISPL);
                CALL EMIT_RR(BCR,UNCOND,LINK);   /*  GENERATE BRANCH     */
             END;   /* "EXTERNAL GOTO   */  ;
      END;

      /*   BNZ   */
      CALL TEST_FOR_BOOLEAN_0(BNE);
      /*   BZ   */
      CALL TEST_FOR_BOOLEAN_0(BE);

      /*   BCT   */
      DO;
         CALL MAKE_ADDRESSABLE(OP2);
         CALL ACCUMULATE(OP2);
         CALL EMIT_RR(LTR,ACC,ACC);
         CALL FORWARD_BRANCH(BNH,OP1 & STRIPMASK);
         CALL EMIT_RR(BCTR,ACC,0);
      END;




      /*    PCALL    */


   /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    *                                                                     *
    *                                                                     *
    *    A PROCEDURE OR FUNCTION CALL SEQUENCE IS ALWAYS INITIATED BY     *
    *    A BLKMARK TRIPLE, WHOSE OPERANDS ARE IDENTICAL TO THOSE OF THE   *
    *    PCALL TRIPLE:  OP1 INDICATES THE PROCEDURE TO BE CALLED, OP2     *
    *    INDICATES THE SEQUENCE # OF THAT PROCEDURE. THE LATTER IS NULL   *
    *    FOR A FORMAL PROCEDURE CALL.                                     *
    *    THE BLKMARK TRIPLE GENERATES CODE TO COPY THE DISPLAY & FILL IN  *
    *    THE DYNAMIC LINK, STACKTOP, CODE BASE INTO THE NEW ACTIVATION    *
    *    RECORD.                                                          *
    *    PARM TRIPLES GENERATE CODE TO MOVE ARGUMENTS INTO THE A.R.       *
    *    PCALL GENERATES A LOAD FROM THE TRANSFER VECTOR, A RELOAD OF     *
    *    CURRENT_AR_BASE, & BRANCH & LINK.  THE CALLED PROCEDURE UPDATES  *
    *    THE STACKTOP & ENTERS THE RETURN ADDRESS INTO THE A.R.           *
    *    FOR FORMAL PROCEDURE CALLS, THE TRANSFER VECTOR INDEX, DISPLAY-  *
    *    SIZE, AND ENVIRONMENT BASE MUST BE FOUND AT RUNTIME FROM THE     *
    *    DESCRIPTOR ENTRY CORRESPONDING TO THE CALLED PROCEDURE.          *
    *                                                                     *
    *                                                                     *
     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


         DO;
             CALL FLUSH_ALL_REGS;
             IF OP2 ~= NULL THEN        /*  USUAL PROCEDURE CALL        */
             DO;
                IF (OP2 & STRIPMASK) ~= CURRENT_PROC_SEQ# THEN
                  DO;    /*  CALL TO A DIFFERENT PROCEDURE THAN THE CURRENT */
                 /*  LOAD CODE BASE FROM TRANSFER VECTOR         */

                DISPL = TRANSFER_VECTOR_BASE + (OP2 & STRIPMASK) * 4;
                CALL CHECK_MULT_OF_4096;
                CALL EMIT_RX (LOAD,CODE_BASE,X_REG,ORG,DISPL);
                  END;

               IF AR_OFFSET = 0 THEN
                CALL EMIT_RR (LR,CURRENT_AR_BASE,STACKTOP);
               ELSE DO;
                  DISPL = AR_OFFSET;
                  CALL CHECK_MULT_OF_4096;
                  CALL EMIT_RX(LA,CURRENT_AR_BASE,X_REG,STACKTOP,DISPL);
               END;
                CALL EMIT_RR (BALR,LINK,CODE_BASE);

             END;

             ELSE       /*   FORMAL PROCEDURE CALL       */
            DO;
               CALL MAKE_ADDRESSABLE(OP1);
               /*   GET BASE ADDRESS FROM DESCRIPTOR   */
               CALL EMIT_RX(LOAD,CODE_BASE,X_REG,BASE_REG,DISPL );
                  CALL FLUSH_ALL_REGS;
               /*   COMPUTE CURRENT_AR_BSSE FROM STACKTOP & DISPLAY SIZE   */
               CALL EMIT_RX(S,STACKTOP,X_REG,BASE_REG,DISPL + 4);
               CALL EMIT_RR(LR,CURRENT_AR_BASE,STACKTOP);
               CALL EMIT_RR(BALR,LINK,CODE_BASE);
             END;
            /*   HERE IT IS ASSUMED THAT ALL TEMPORARIES CREATED DURING
                 ARGUMENT PASSING HAVE VANISHED (WHICH IMPLIES THAT ANY
                 COMMON SUB_EXPRESSIONS THAT ARE TO BE REFERENCED
                 SUBSEQUENT TO THE PARM PASSING COMPUTATIONS SHOULD BE
                 CREATED BEFORE THE BLKMARK TRIPLE).                  */
            CALL POP_NEXT_TEMP_DISPL;
            CALL GET_TEMP_BYTES(4);
            OP2 = LAST_TEMP;
         END;


      /*   PRETURN     */
      DO;
         CALL FLUSH_ALL_REGS;
         CALL EMIT_RX(LM,LINK,STACKTOP,CURRENT_AR_BASE,4);
         CALL EMIT_RR(BCR,UNCOND,LINK);
      END;

      /*   PARM   */
         /*   USED TO MOVE ARGUMENTS INTO THE NEW ACTIVATION RECORD.
              USING STACKTOP AS A BASE.  THE 2ND ARG GIVES THE ACTUAL PARAMETER,
              THE FIRST ARG GIVES THE FORMAL PARAM.
                  NEXT_TEMP_DISPL (DISPL OF THE NEXT TEMPORARY) NEEDS TO
              BE ADJUSTED  IF THE ARGUMENT OVERLAPS ITS PREVIOUS VALUE .   */
      DO;
         FORMAL_PARAMETER = TRUE;
         CALL MOVE_OP;
         FORMAL_PARAMETER = FALSE;
         /*   MAINTAIN ALIGNMENT   */
         OP_STORAGE_LENGTH = (OP_STORAGE_LENGTH + 3) & "FFFFFFFC";
         IF AR_OFFSET + DISP(OP1) + OP_STORAGE_LENGTH > NEXT_TEMP_DISPL THEN
         NEXT_TEMP_DISPL = AR_OFFSET + DISP(OP1) + OP_STORAGE_LENGTH;
      IF NEXT_TEMP_DISPL > MAX_TEMP_DISPL THEN MAX_TEMP_DISPL = NEXT_TEMP_DISPL;
      END;

      /*    BLKMARK   */

      DO;
         IF OP2 ~= NULL THEN
         DO;     /*   USUAL PROCEDURE CALL   */
            CALL PUSH_NEXT_TEMP_DISPL;
            STATIC_DISPLAY_SIZE = PSEUDO_REG(OP1) * 4;
            IF STATIC_DISPLAY_SIZE > 4 THEN
            DO;   /*   COPY DISPLAY  INTO NEW ACTIVATION RECORD   */
                BASE_REG = STACKTOP;
                DISPL = NEXT_TEMP_DISPL + 20;
                CALL CHECK_MULT_OF_4096;
                IF X_REG ~= 0 THEN CALL LOAD_ADDRESS;
                CALL EMIT_SS(MVC,STATIC_DISPLAY_SIZE-5,BASE_REG,DISPL,
                   CURRENT_AR_BASE,20);
            END;

            /*   SAVE CURRENT_AR_BASE (BECOMES DYNAMIC LINK), CODE_BASE,
                 STACKTOP. THE RETURN ADDRESS IS SAVED BY THE CALLED PROC   */
            BASE_REG = STACKTOP;
            DISPL = NEXT_TEMP_DISPL + 8;
            CALL CHECK_MULT_OF_4096;
            IF X_REG ~= 0 THEN CALL LOAD_ADDRESS;
            CALL EMIT_RX(STM,CURRENT_AR_BASE,STACKTOP,BASE_REG,DISPL);
            AR_OFFSET = NEXT_TEMP_DISPL;
            NEXT_TEMP_DISPL = NEXT_TEMP_DISPL + STATIC_DISPLAY_SIZE + 20;
            IF NEXT_TEMP_DISPL > MAX_TEMP_DISPL THEN MAX_TEMP_DISPL =
               NEXT_TEMP_DISPL;
         END;   /*   USUAL PROC   */
         ELSE        /*   FORMAL PROCEDURE     */
         /*   SINCE THE PROCEDURE BEING CALLED IS NOT KNOWN UNTIL RUN-TIME,
              THE CODE BASE ADDRESS FOR THE PROCEDURE, THE DISPLAY SIZE,
              AND THE STATIC ENVIRONMENT CANNOT BE OBTAINED UNTIL RUN-TIME.
              THESE QUANTITIES ARE STORED IN A 3 WORD DESCRIPTOR, WHICH IS
              INITIALIZED WHEN THE ACTUAL PROCEDURE IS PASSED AS A PARAMETER.
              CODE FOR FILLING IN THE DESCRIPTOR IS GENERATED BY THE PROCPARM
              TRIPLE. THE DISPLAY WHICH MUST BE COPIED IS THE CURRENT DISPLAY
              AT THE TIME OF THE CALL. THUS THE CURRENT AR_BASE IS STORED IN
              WORD 3 OF THE DESCRIPTOR (THE ENVIRONMENT POINTER).
              WORD 2 GETS THE DISPLAY SIZE.
              WORD 1 GETS THE CODE BASE ADDRESS.
              TO COPY A  VARIABLE  SIZE STATIC DISPLAY, AN MVC INSTR IS
              EX'D WITH THE LENGTH (OBTAINED FROM THE DESCRIPTOR) IN REG 8.  */

         DO;
            CALL FLUSH_ALL_TEMP_REGS;
            CALL FLUSH_REG(8);  CALL FLUSH_REG(9); CALL FLUSH_REG(10);
            PRIORITY(8), PRIORITY(9) = FIXED_PRIORITY;
            PRIORITY(10) = FIXED_PRIORITY;
            CALL MAKE_ADDRESSABLE(OP1);
            FIX_BASE_REG_PRIORITIES;
            /*   LOAD DISPLAY LENGTH & ENVIRONMENT BASE, RESPECTIVELY   */
            IF X_REG ~= 0 THEN DO;
                CALL EMIT_RX(LOAD,8,X_REG,BASE_REG,DISPL + 4);
                CALL EMIT_RX(LOAD,9,X_REG,BASE_REG,DISPL + 8);
            END;
            ELSE CALL EMIT_RX(LM,8,9,BASE_REG,DISPL + 4);
            X_REG1 = X_REG;
            DISPL1 = DISPL;
            DISPL = NEXT_TEMP_DISPL;
            CALL CHECK_MULT_OF_4096;
            IF X_REG = 0 & DISPL = 0 THEN CALL EMIT_RR(LR,10,STACKTOP);
            ELSE
            CALL EMIT_RX(LA,10,X_REG,STACKTOP,DISPL);
            /*   COPY DISPLAY. DON'T BOTHER TO DECREMENT LEN BY 1 FOR LEN CODE-
                 IRRELEVENT THAT AN EXTRA BYTE IS COPIED       */
            CALL EMIT_RX(EX,8,0,ORG,MVC_INSTR);

            CALL EMIT_RX(STM,CURRENT_AR_BASE,STACKTOP,10,8);
            IF (TRIPLES(CURRENT_TRIPLE + 3) & TRIPLE_OP_MASK) = 36 THEN
            DO;   /*   PCALL TRIPLE FOLLOWS -> NO PARMS.SKIP OVER THE
              PCALL, & BALR IMMEDIATELY    */
               CALL EMIT_RX(LOAD,CODE_BASE,X_REG,BASE_REG,DISPL1);
               CALL FLUSH_ALL_REGS;
               CALL EMIT_RR(LR,CURRENT_AR_BASE,10);
               CALL EMIT_RR(BALR,LINK,CODE_BASE);
               /*   BUMP OVER PCALL   */
               CURRENT_TRIPLE = CURRENT_TRIPLE + 3;
               IF LIST_CODE THEN CALL PRINT_TRIPLE(CURRENT_TRIPLE);
               CALL GET_TEMP_BYTES(4);
               OP2 = LAST_TEMP;   /*  ASSIGN A TEMP TO THE PROC   */
            END;
            ELSE DO;
            /*   ARGS WILL BE ADDRESSED OFF THE STACKTOP. ADJUST IT
               ACCORDINGLY, & ADJUST VALUE OF NEXT_TEMP_DISPL   */
               /*  NOTE THAT BY THUS INCREMENTING THE STACKTOP, TEMPS
                   OUTSTANDING AT THE TIME OF THE CALL ARE NO LONGER
                   ADDRESSABLE FROM THE STACKTOP. THIS EXCLUDES ARG COM-
                   PUTATIONS OF FORMAL PROC CALLS FROM REFERENCING PRE-
                   VIOUSLY COMPUTED COMMON SUB-EXPRESSIONS.         */

               CALL EMIT_RX(LA,STACKTOP,10,8,0);
               CALL PUSH_NEXT_TEMP_DISPL;
               AR_OFFSET,NEXT_TEMP_DISPL = 20;
            END;
            CALL RESET_ADDR_REG_PRIORITIES(BASE_REG,X_REG);
            IF X_REG1 ~= X_REG THEN CALL RESET_ADDR_REG_PRIORITIES(X_REG1,0);
            PRIORITY(8),PRIORITY(9) = FREE_PRIORITY;
            PRIORITY(10) = FREE_PRIORITY;
         END;   /*  FORMAL PROC   */
      END;


      /*    PEND      */
      DO;
         IF CURRENT_PROC_SEQ# = 0   /*   MAIN PROCEDURE   */
            THEN COMPILING = FALSE;
         ELSE ENTRY_POINT = ENTRY_POINT + CODE_INDEX;
         RETURN;   /*   CODE GENERATION COMPLETED FOR CURRENT PROCEDURE   */
      END;

      /*   TPOP   */
      /*   FREE THE TEMPORARY ASSOCIATED WITH THE TRIPLE GIVEN BY OP1   */
      DO;
         TPTR = OP1 & STRIPMASK;
         CALL FREE_TEMP(TRIPLES(TPTR+2) );
      END;
      /*   REM   */
      DO;
         CALL MAKE_ADDRESSABLE(OP1);
         IF OP_STORAGE_LENGTH = 1 THEN DO;
            CALL GET_INTO_ODD_REG;
            CALL EMIT_RR(SR,EVEN_REG,EVEN_REG);
         END;
         ELSE DO;
            CALL GET_INTO_EVEN_REG;
            CALL EMIT_RX(SRDA,EVEN_REG,0,0,32);
         END;
         CALL GENERATE_OPERATION(D,DR,NULL,EVEN_REG,OP2);
         CALL RESET_PAIR_PRIORITIES(TEMP_PRIORITY,FREE_PRIORITY);
         CALL ASSIGN_TEMP(EVEN_REG);
         OP2 = LAST_TEMP;
      END;

      /*   ABS   */
      DO;
         CALL LOAD_OPERAND;
         CALL EMIT_RR(LPR,ACC,ACC);
      END;

      /*   ABSFLT   */
      DO;
         CALL MAKE_ADDRESSABLE(OP1);
         IF IN_REG & ~IN_FREE_REG THEN DO;
            FLT_REG = GET_FLT_REG(TEMP_PRIORITY);
            CALL EMIT_RR(LPER,FLT_REG-#GP_REGS,ACC-#GP_REGS);
         END;
         ELSE DO;
            CALL GET_OP_INTO_FLT_REG(TEMP_PRIORITY);
            CALL EMIT_RR(LPER,FLT_REG-#GP_REGS,FLT_REG-#GP_REGS);
         END;
         CALL ASSIGN_TEMP(FLT_REG);
         OP2 = LAST_TEMP;
      END;

      /*   NEGATE   */
      DO;
         CALL LOAD_OPERAND;
         CALL EMIT_RR(LCR,ACC,ACC);
      END;
      /*   NEGFLT   */
      DO;
         CALL MAKE_ADDRESSABLE(OP1);
         IF IN_REG & ~IN_FREE_REG THEN DO;
            FLT_REG = GET_FLT_REG(TEMP_PRIORITY);
            CALL EMIT_RR(LCER,FLT_REG-#GP_REGS,ACC-#GP_REGS);
         END;
         ELSE DO;
            CALL GET_OP_INTO_FLT_REG(TEMP_PRIORITY);
            CALL EMIT_RR(LCER,FLT_REG-#GP_REGS,FLT_REG-#GP_REGS);
         END;
         CALL ASSIGN_TEMP(FLT_REG);
         OP2 = LAST_TEMP;
      END;

      /*   LLESS   */
         IF GET_STOR_LEN(OP1) > 256 THEN CALL GEN_LONG_COMPARE(BL);
         ELSE
      DO;
         CALL GENERATE_STRING_OPERATION(CLC);
         CALL GEN_COND_BRANCH(BL);
      END;
      /*   LGREATER   */
         IF GET_STOR_LEN(OP1) > 256 THEN CALL GEN_LONG_COMPARE(BH);
         ELSE
      DO;
         CALL GENERATE_STRING_OPERATION(CLC);
         CALL GEN_COND_BRANCH(BH);
      END;
      /*   LCOMPARE   */
         IF GET_STOR_LEN(OP1) > 256 THEN CALL GEN_LONG_COMPARE(BE);
         ELSE
      DO;
         CALL GENERATE_STRING_OPERATION(CLC);
         CALL GEN_COND_BRANCH(BE);
      END;

      /*   PROCPARM   */
         /*   USED TO PASS A PROCEDURE AS AN ACTUAL PARAMETER. THE OPRRANDS
              GIVE THE PROCEDURE & ITS SEQ#. THIS TRIPLE IS ALWAYS FOLLOWED BY
              A PARM TRIPLE WHICH GIVES THE FORMAL PARAMETER IN ITS FIRST OP  */
      DO;
         DECLARE SEQ# BIT(16);
         SEQ# = OP2 & STRIPMASK;
         IF OP1 <= 25 THEN
            /*   ONE OF THE STANDARD PROCEDURES SIN, COS, EXP, LN, SQRT,
            ARCTAN ARE BEING PASSED. THESE ARE THE ONLY STANDARD PROCEDURES
            ALLOWED TO BE PASSED IN THE CURRENT VERSION.            */
            STATIC_DISPLAY_SIZE = 0;
         ELSE STATIC_DISPLAY_SIZE = PSEUDO_REG(OP1) * 4;
         CURRENT_TRIPLE = CURRENT_TRIPLE + 3;
         IF LIST_CODE THEN CALL PRINT_TRIPLE(CURRENT_TRIPLE);
         /*   NOW AT PARM TRIPLE. FILL IN DESCRIPTOR WITH THE DISPLAY SIZE,
              CODE BASE ADDRESS, & CURRENT_AR_BASE, RESPECTIVELY      */
         CALL FLUSH_REG(9); CALL FLUSH_REG(10);
         PRIORITY(9),PRIORITY(10) = FIXED_PRIORITY;
         FORMAL_PARAMETER = TRUE;
         CALL GET_TARGET_ADDRESS;
         FORMAL_PARAMETER = FALSE;
         IF X_REG ~= 0 THEN CALL LOAD_ADDRESS;
         DISPL1 = DISPL;
         IF STATIC_DISPLAY_SIZE = 0 THEN
         DO;   /*  STANDARD PROC. SEQ# WILL BE THE MONITOR SERVICE CODE  */
            /*   PREPARE A THUNK, BAL AROUND IT IN THE PARM PASSING
         SEQUENCE, PUTTING ITS ADDRESS IN THE REG WHICH IS STORED AS THE
         CODE BASE ADDRESS IN THE DESCRIPTOR. THE THUNK WILL THEN BE
         ENTERED WHEN THE  FORMAL PROC CALL HAS BEEN MADE, PERMITTING
         ENTRY INTO THE MONITOR ACCORDING TO THE SPECIFIED PROTOCALL FOR
         MONITOR ENTRIES & RETURNS.                      */
            DISPL = CODE_INDEX + 34;
            CALL CHECK_MULT_OF_4096;
            CALL EMIT_RX(BAL,9,X_REG,CODE_BASE,CODE_INDEX + 34);
            /*   GENERATE THE THUNK. NOTE THAT WHEN THE THUNK IS ENTERED,
                 THE STACKTOP WILL POINT TO THE BASE OF THE A.R. CREATED
                 BY THE CALLING MECHANISM. LOAD THE ARGUMENT TO CONFORM TO
                 THE STANDARD PROCEDURE PROTOCALL, SAVE THE LINK ADDRESS,
                 GENERATE THE MONITOR CALL, & STORE THE VALUE RETURNED
                 IN FLT REG #0 TO THE TEMPORARY ASSOCIATED WITH THE PCALL
                 TRIPLE.                                      */
            CALL EMIT_RX(LE,6,0,STACKTOP,20);  /* GET ARG FROM A.R.  */
            CALL EMIT_RX(ST,LINK,0,CURRENT_AR_BASE,4);   /*  SAVE LINK  */
            CALL EMIT_RX(STM,13,15,ORG,PASCAL_REGS + 8);
            CALL EMIT_RX(LOAD,13,0,ORG,MON_BASE_REGS + 8);
            CALL EMIT_RX(BAL,LINK,0,13,4 * SEQ# + 72);
            CALL EMIT_RX(STE,0,0,  CURRENT_AR_BASE,0);  /* PUT VALUE IN PLACE*/
            CALL EMIT_RX(LM,LINK,STACKTOP,CURRENT_AR_BASE,4);  /* RESTORE  */
            CALL EMIT_RR(BCR,UNCOND,10);
            /*   END OF THUNK   */
            CALL EMIT_RR(SR,10,10);  /*  DISPLAY SIZE WILL BE SET TO 0  */
         END;
         ELSE
         DO;   /*   USER DEFINED PROCEDURE   */
            DISPL = 4 * SEQ# + TRANSFER_VECTOR_BASE;
            CALL CHECK_MULT_OF_4096;
            CALL EMIT_RX(LOAD,9,X_REG,ORG,DISPL);
            CALL EMIT_RX(LA,10,0,0,STATIC_DISPLAY_SIZE);
         END;

         CALL EMIT_RX(STM,9,CURRENT_AR_BASE,BASE_REG,DISPL1);
         PRIORITY(9),PRIORITY(10) = FREE_PRIORITY;
         IF DISPL1 + 8 > NEXT_TEMP_DISPL THEN NEXT_TEMP_DISPL = DISPL1 + 8;
         IF NEXT_TEMP_DISPL > MAX_TEMP_DISPL THEN MAX_TEMP_DISPL =
            NEXT_TEMP_DISPL;
      END;

      /*   CASE   */

   /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    *                                                                     *
    *         THE CASE SEQUENCE IS INITIATED BY A CASE_TRIPLE, FOLLOWED   *
    *       BY A SEQUENCE OF BRANCH TRIPLES, ONE FOR EACH POSSIBLE VALUE  *
    *       OF THE CASE SELECTOR IN THE UNDERLYING INTEGER SUBRANGE. THE  *
    *       TARGETS OF THESE BRANCH TRIPLES ARE CASE_TARGET TRIPLES,      *
    *    FOR NON-EMPTY CASES (THESE PRECEDE THE TRIPLES FOR THAT CASE)    *
    *      OR A BRANCH TARGET AT THE END OF THE ENTIRE CASE SEQUENCE FOR  *
    *      EMPTY CASES.                                                   *
    *         EACH CASE_TARGET IS REFERENCED BY ONE OR MORE BRANCHES. IN  *
    *       GENERATING CODE, A RELATIVE ADDRESS TABLE IS SET UP, TO CON-  *
    *       TAIN THE LOCATION OF THE FIRST BYTE OF CODE FOR THE CASE      *
    *       CORRESPONDING TO EACH OF THE BRANCH TRIPLES.                  *
    *         THE CASE TRIPLE CAUSES EMISSION OF MACHINE INSTRUCTIONS TO  *
    *       DO THE FOLLOWING:                                             *
    *    1) GET THE CASE SELECTOR IN A NON-ZERO REGISTER (BASE_REG)       *
    *    2) SHIFT THE SELECTOR TO OBTAIN AN INDEX INTO THE RELATIVE AD-   *
    *    DRESS TABLE                                                      *
    *    3) RE-LOAD BASE_REG WITH THE CONTENTS OF THE INDEXED TABLE ENTRY *
    *    4) USE BASE_REG TO INDEX A FORWARD UNCOND BRANCH TO THE CASE     *
    *                                                                     *
    *    OP2 OF THE CASE_TARGET TRIPLE IS USED TO HEAD A FIXUP LIST OF    *
    *    REFERENCES TO THAT CASE. AS EACH CASE_TARGET IS ENCOUNTERED,     *
    *    THE LOC OF THE FIRST INSTRUCTION IN THAT CASE IS KNOWN & IS THEN *
    *    ENTERED IN THE RELATIVE ADDRESS TABLE.                           *
    *                                                                     *
    * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **/

      DO;
         CALL MAKE_ADDRESSABLE(OP1);
         CALL FLUSH_ALL_REGS;
         CALL FORCE_INTO_BASE_REG;
         CALL EMIT_RX(SLA,BASE_REG,0,0,2);
         IF CODE_INDEX < 4086 THEN /* CODE_BASE CAN BE USED TO ADDRESS
              THE ADDRESS TABLE     */
            CALL EMIT_RX( LH ,BASE_REG,BASE_REG,CODE_BASE,CODE_INDEX + 10);
         ELSE DO;
            CALL EMIT_RR(BALR,BASE_REG,0);
            CALL EMIT_RX( LH ,BASE_REG,BASE_REG,0,10);
         END;
         CALL EMIT_RX(BC,UNCOND,CODE_BASE,BASE_REG,0);
         CALL RESET_BASE_REG_PRIORITIES;

         OPERAND2 = OP2 & STRIPMASK;
         DO I = 1 TO OPERAND2;
            CURRENT_TRIPLE = CURRENT_TRIPLE + 3;
            IF MASK(OP1) = SY_TABLE_PTR THEN TPTR = DISP(OP1);
               /*  A PSEUDO LABEL. GET TARGET FROM SYMBOL TABLE    */
            ELSE TPTR = (OP1 & STRIPMASK);
            CALL INSERT_2BYTE_CONSTANT(CODE_INDEX,0);
            CALL INSERT_2BYTE_CONSTANT(CODE_INDEX+ 2,TRIPLES(TPTR + 2) );
            TRIPLES(TPTR + 2) = CODE_INDEX;
            CODE_INDEX = CODE_INDEX + 4;
         END;
      END;


      /*   CASE_TARGET     */

      DO;
         CALL FLUSH_ALL_REGS;
         TPTR = OP2;
         DO WHILE TPTR ~= NULL;   /*  FIXUP REFERENCES TO THE CASE TARGET  */
            I = TPTR + 2;
            /*  GET NEXT ELEMENT IN CHAIN   */
            TPTR = SHL(CODE(I),8) + CODE(I + 1);
            CALL INSERT_2BYTE_CONSTANT(I,CODE_INDEX);
         END;
      END;
      /*   ODD   */
      DO;
         CALL LOAD_OPERAND;
         CALL EMIT_RX(N,ACC,0,ORG,CONST1);
      END;
      /*   SQR   */
      DO;
         CALL MAKE_ADDRESSABLE(OP1);
         IF ~ DOUBLE_REG_STATUS THEN CALL GET_INTO_ODD_REG;
         CALL EMIT_RR (MR,EVEN_REG,ODD_REG);
         CALL RESET_PAIR_PRIORITIES(FREE_PRIORITY,TEMP_PRIORITY);
         CALL ASSIGN_TEMP(ODD_REG);
         OP2 = LAST_TEMP;
      END;
      /*   SQRFLT   */
      DO;
         CALL MAKE_ADDRESSABLE(OP1);
         CALL GET_OP_INTO_FLT_REG(TEMP_PRIORITY);
         CALL EMIT_RR(MER,FLT_REG-#GP_REGS,FLT_REG-#GP_REGS);
         CALL ASSIGN_TEMP(FLT_REG);
         OP2 = LAST_TEMP;
      END;

      /*   ROUND   */
         /*   ROUNDING IS PERFORMED BY ADDING OR SUBTRACTING 0.5 (DEPEND-
              ING ON THE SIGN )  AND TRUNCATING THE RESULT   */
      DO;
         FLT_REG = GET_FLT_REG(FREE_PRIORITY);
         FLT_ACC = FLT_REG - #GP_REGS;
         CALL EMIT_RR(SDR,FLT_ACC,FLT_ACC);
         CALL MAKE_ADDRESSABLE(OP1);
         IF IN_REG THEN CALL EMIT_RR(LER,FLT_ACC,ACC - #GP_REGS);
         ELSE CALL EMIT_RX(LE,FLT_ACC,X_REG,BASE_REG,DISPL);
         CALL EMIT_RR(LTDR,FLT_ACC,FLT_ACC);
         ACC = GET_REG(TEMP_PRIORITY);
         CALL ASSIGN_TEMP(ACC);
         CALL FORWARD_CODE_BRANCH(BNL,26);
         /*   IF NEGATIVE  FIRST SUBTRACT  0.5   */
         CALL EMIT_RX(SE,FLT_ACC,0,ORG,CONP5);
         CALL EMIT_RX(AW,FLT_ACC,0,ORG,CON4E);
         CALL EMIT_RX(STD,FLT_ACC,0,ORG,DS1);
         CALL EMIT_RX(LOAD,ACC,0,ORG,DS1 + 4);
         CALL EMIT_RR(LCR,ACC,ACC);
         CALL FORWARD_CODE_BRANCH(UNCOND,20);
         /*   IF POSITIVE ADD  0.5     BEFORE TRUNCATING    */
         CALL EMIT_RX(AE,FLT_ACC,0,ORG,CONP5);
         CALL EMIT_RX(AW,FLT_ACC,0,ORG,CON4E );
         CALL EMIT_RX(STD,FLT_ACC,0,ORG,DS1);
         CALL EMIT_RX(LOAD,ACC,0,ORG,DS1 + 4);
         OP2 = LAST_TEMP;
      END;

      /*   S_LENGTH   */
         /*   GENERATES NO CODE BUT USED TO INDICATE THE STORAGE LENGTH
              FOR INDEX TRIPLES OF LENGTH > 256   */
      ;
      /*   IN   */
         /*   CHECK IF THE BIT WHOSE ORDINALITY IS GIVEN IN THE FIRST OPERAND
              IS SET IN THE SECOND OPERAND     */
      DO;
        IF IMMED(OP1) THEN   /*  ORDINALITY KNOWN AT COMPILE TIME - NO
         NEED TO GEN CODE TO COMPUTE BIT & BYTE ORDINALITIES   */
        DO;
            CALL FOLD_BIT_OP(TM);
            CALL GEN_COND_BRANCH(1);     /*   BNZ => BR IF ONES   */
        END;
        ELSE DO;
         CALL SELECT;
      /*   BYTE_XREG CONTAINS ORDINALITY OF SELECTED BYTE (UNLESS IT = 0,
           IN WHICH CASE THE ORDINALITY IS 0 ). INSERT THAT BYTE INTO EVEN_REG*/
         CALL EMIT_RX(IC,EVEN_REG,BYTE_XREG,BASE_REG,DISPL);
         /*   SHIFT THE SELECTED BIT TO SIGN POSITION   */
         CALL EMIT_RX(SLL,EVEN_REG,0,ODD_REG,24);
         CALL EMIT_RR(LTR,EVEN_REG,EVEN_REG);   /*   TEST THE BIT    */
         /*   MINUS IS THE TRUE CONDITION   */
         CALL GEN_COND_BRANCH(BL);
         CALL RESET_PAIR_PRIORITIES(FREE_PRIORITY,FREE_PRIORITY);
      END;
        END;

      /*   INTO   */
      DO;
        IF IMMED(OP1) THEN CALL FOLD_BIT_OP(OI);
        ELSE DO;
         /*   SET THE BIT WHOSE ORDINALITY IS GIVEN BY OP1   */

         CALL SELECT;
         /*   PUT ADDRESS OF CORRECT MASK IN ODD_REG    */
         CALL EMIT_RX(LA,ODD_REG,ODD_REG,ORG,SET_MASKS);
      IF BYTE_XREG ~= 0 THEN DO;
         /*   PUT ADDRESS OF SELECTED BYTE IN EVEN_REG   */
         CALL EMIT_RX(LA,EVEN_REG,BYTE_XREG,BASE_REG,DISPL);
         CALL EMIT_SS(OC,0,EVEN_REG,0,ODD_REG,0);
      END;
      ELSE CALL EMIT_SS(OC,0,BASE_REG,DISPL,ODD_REG,0);
         CALL RESET_PAIR_PRIORITIES(FREE_PRIORITY,FREE_PRIORITY);
        END;
      END;

      /*   LINE#   */
      CALL NEXT_LINE(OP1);

      /*   RANGE   */

      /*   THIS TRIPLE SPECIFIES THE INSERTION OF A SUBRANGE INTO A SET.
           OP1 & OP2 INDICATE THE RANGE (COERCED TO ORDINALITIES WITHIN
           THE SET);  AN INTO TRIPLE IMMEDIATELY FOLLOWS WHICH GIVES THE
           ADDRESS OF THE BYTES REPRESENTING THE SET IN ITS 2ND OPERAND  */

      CALL INSERT_SUBRANGE;


      END;

      IF LIST_INSTRUCTIONS THEN DO;
         /*   A LISTING OF GEN CODE IS DESIRED. PRESERVE THE CURRENT VALUE
              OF CODE_INDEX SO LINE#S MAY BE ASSOCIATED WITH DISPLACEMENTS */
         I = TRIPLES(CURRENT_TRIPLE) & TRIPLE_OP_MASK;
         IF I ~= INDEX & I ~= S_LENGTH & I ~= 60  /* LINE#TRIPLE */ THEN
         OP1 = CODE_INDEX;
      END;

      CURRENT_TRIPLE = CURRENT_TRIPLE + 3;
      END;
 END GENERATE_CODE;



 /*     I N T E R P A S S   C O M M U N I C A T I O N   P R O C E D U R E S   */




 REWIND: PROCEDURE (IS_OUTPUT_FILE,FILE#);
      /*   USED FOR REWINDING FILES IN ORDER TO FREE BUFFER SPACE   */
      DECLARE IS_OUTPUT_FILE BIT(1), FILE# FIXED;
      CALL INLINE("1B",0,0);                     /* SR   0,0              */
      CALL INLINE("43",0,0,IS_OUTPUT_FILE);      /* IC   0,IS_OUTPUT_FILE */
      CALL INLINE("41",1,0,0,28);                /* LA   1,28             */
      CALL INLINE("58",2,0,FILE#);               /* L    2,FILE#          */
      CALL INLINE("05",12,15);                   /* BALR 12,15            */
 END REWIND;


      /*   INPUT PROCEDURES TO READ IN SYMBOL TABLE AND TRIPLE BLOCKS   */

RESTORE_COLUMN:
   PROCEDURE (ARRAY_ADDR, BYTES_PER_ITEM, LIMIT);
      DECLARE ARRAY_ADDR FIXED,
              (BYTES_PER_ITEM, LIMIT) BIT(16);
      DECLARE (INCREMENT, I, J, K) FIXED;
      DECLARE MOV(3) BIT(16) INITIAL("D200", "2000", "1000");
      INCREMENT = 80 / BYTES_PER_ITEM;
      I = 0;
      J = ARRAY_ADDR;
      DO WHILE I + INCREMENT < LIMIT;
         CALL INLINE("58",1,0,SY_TEXT);          /* L    1,SY_TEXT         */
         CALL INLINE("58",2,0,J);                /* L    2,J               */
         CALL INLINE("D2","4","F",2,0,1,0);      /* MVC  0(80,2),0(1)      */
         I = I + INCREMENT;
         J = J + 80;
         SY_TEXT = INPUT(SY_FILE);
      END;
      K = (LIMIT - I) * BYTES_PER_ITEM - 1;
      CALL INLINE("58",1,0,SY_TEXT);             /* L    1,SY_TEXT         */
      CALL INLINE("58",2,0,J);                   /* L    2,J               */
      CALL INLINE("58",3,0,K);                   /* L    3,K               */
      CALL INLINE("44",3,0,MOV);                 /* EX   3,MVC             */
      SY_TEXT = INPUT(SY_FILE);
   END RESTORE_COLUMN;


RESTORE_SY_TABLE:
   PROCEDURE;
      /* RESTORE THE STORAGE_LENGTH, PSEUDO_REG AND DISP COLUMNS OF THE
         SYMBOL TABLE TO THEIR STATUS AT THE END OF PASS 2.            */
      DECLARE I BIT(16);
      N_DECL_SYMB = 0;
      #BASIC_BLOCKS = 0;
      NEXT_SEQ# = 0;
      SY_TEXT = INPUT(SY_FILE);
      IF SUBSTR(SY_TEXT, 0, 5) ~= '%SYMB' THEN
         DO;
            OUTPUT = '%SYMB CARD EXPECTED.';
            RETURN;
         END;
      /*   READ IN GLOBALS PASSED FROM PASS 2     */
      DO I = 5 TO 9;
         IF BYTE(SY_TEXT, I) ~= BYTE(' ') THEN
            N_DECL_SYMB = 10*N_DECL_SYMB + BYTE(SY_TEXT, I) - BYTE('0');
      END;
      DO I = 10 TO 14;
         IF BYTE(SY_TEXT, I) ~= BYTE(' ') THEN
         #BASIC_BLOCKS = 10 * #BASIC_BLOCKS + BYTE(SY_TEXT,I) - BYTE('0');
      END;
      DO I = 15 TO 19;
         IF BYTE(SY_TEXT, I) ~= BYTE(' ') THEN
         NEXT_SEQ# = 10 * NEXT_SEQ# + BYTE(SY_TEXT,I) - BYTE('0');
      END;
      IF BYTE(SY_TEXT,20) = BYTE('D') THEN STATISTICS = TRUE;
        ELSE STATISTICS = FALSE;
      NEXT_SEQ# = NEXT_SEQ# + 1;


      /*   SET PASS 2 DEPENDENT PASS 3 GLOBALS   */
      TRANSFER_VECTOR_BASE = BLOCK_COUNTER_BASE + 4 * #BASIC_BLOCKS;

      SY_TEXT = INPUT(SY_FILE);
      CALL RESTORE_COLUMN(ADDR(STORAGE_LENGTH), 4, N_DECL_SYMB);
      CALL RESTORE_COLUMN(ADDR(PSEUDO_REG), 2, N_DECL_SYMB);
      CALL RESTORE_COLUMN(ADDR(DISP), 4, N_DECL_SYMB);
      IF SUBSTR(SY_TEXT, 0, 4) ~= '%END' THEN OUTPUT = '%END CARD EXPECTED';
      CALL REWIND(0,SY_FILE);
   END RESTORE_SY_TABLE;



      /*               READ IN A BLOCK OF TRIPLES               */



READ_TRIPLES:
   PROCEDURE;   /* READS IN TRIPLES FOR A PASCAL BLOCK */
      DECLARE (I, J) FIXED;
      DECLARE TRIPLE_LISTING BIT(1);
      SY_TEXT = INPUT(TRIPLES_FILE);
      IF LENGTH(SY_TEXT) = 0 THEN RETURN; /**** ENDFILE ****/
      IF SUBSTR(SY_TEXT, 0, 7) ~= '%TRIPLE' THEN
         DO;
            OUTPUT = '%TRIPLE CARD EXPECTED.';
            RETURN;
         END;

      /*   SET REQUESTED OPTION FLAGS   */
      PROC_NAME = SUBSTR(SY_TEXT,9);
      IF BYTE(SY_TEXT,7) ~= BYTE('E') THEN DO;
         LIST_CODE, LIST_INSTRUCTIONS = FALSE;
         IF BYTE(SY_TEXT,8) = BYTE('T') THEN TRIPLE_LISTING = TRUE;
         ELSE TRIPLE_LISTING = FALSE;
      END;
      ELSE DO;
         IF BYTE(SY_TEXT,8) = BYTE('T') THEN
         DO;   /*   BOTH E & T TOGGLES--GIVE TRIPLES & CODE INTERLEAVED   */
            LIST_INSTRUCTIONS = FALSE;
            LIST_CODE = TRUE;
            OUTPUT(1) = '1' || SPACE 40X || 'TRIPLES AND CODE FOR PROCEDURE '   
               || PROC_NAME;
         END;
         ELSE LIST_INSTRUCTIONS = TRUE;
      END;

      I = 0;
      SY_TEXT = INPUT(TRIPLES_FILE);
      DO WHILE SUBSTR(SY_TEXT, 0, 4) ~= '%END';
         J = ADDR(TRIPLES(I));
         CALL INLINE("58",1,0,SY_TEXT);          /* L    1,SY_TEXT         */
         CALL INLINE("58",2,0,J);                /* L    2,J               */
         CALL INLINE("D2","4","F",2,0,1,0);      /* MVC  0(80,2),0(1)      */
         I = I + 40;
         SY_TEXT = INPUT(TRIPLES_FILE);
      END;
      IF TRIPLE_LISTING THEN CALL LIST_TRIPLES;
   END READ_TRIPLES;

      /*   OUTPUT PROCEDURE FOR SWAPPING OUT CODE AND ORG SEGMENTS   */

 SWAP_OUT_SEGMENT: PROCEDURE(FILE#,HEADER);
      DECLARE FILE# BIT(16),HEADER CHARACTER;
      OUTPUT(FILE#) = HEADER;
      I = 0;
      DO WHILE I < CODE_INDEX;
         J = ADDR(CODE(I) );
         CALL INLINE(LOAD,1,0,CODE_TEXT);     /*   L 1,A(CODE_TEXT)   */
         CALL INLINE(LOAD,2,0,J);        /*  L 2,J    */
         CALL INLINE(MVC,"4","F",1,0,2,0);   /*  MVC 0(80,1),0(2)   */
         OUTPUT(FILE#) = CODE_TEXT;
         I = I + 80;
      END;
 END SWAP_OUT_SEGMENT;



   /*        G E N E R A T I O N   O F    O R G   S E G M E N T               */

 GENERATE_ORG_SEGMENT: PROCEDURE;


 EMIT_4BYTE_CONST: PROCEDURE(CONST);
      DECLARE CONST FIXED;
      COREWORD(SHR(ADDR(CODE(CODE_INDEX    )),2)) = CONST;
      CODE_INDEX = CODE_INDEX + 4;
 END EMIT_4BYTE_CONST;

 EMIT_8BYTE_CONST: PROCEDURE(CONST1,CONST2);
      DECLARE (CONST1,CONST2) FIXED;
      COREWORD(SHR(ADDR(CODE(CODE_INDEX    )),2)) = CONST1;
      COREWORD(SHR(ADDR(CODE(CODE_INDEX + 4)),2)) = CONST2;
      CODE_INDEX = CODE_INDEX + 8;
 END EMIT_8BYTE_CONST;

      /*    USES THE CODE_ARRAY AS A BUFFER     */
      ENTRY_POINT = ENTRY_POINT + CODE_INDEX;   /* SAVE # CODE BYTES GENERATED*/
      CODE_INDEX = 0;
      /*   HEAP POINTER & MAX_TOP ARE FILLED IN BY LOADER     */
      CALL EMIT_4BYTE_CONST(0);
      CALL EMIT_4BYTE_CONST("FFFFFF");     /*   MAX_TOP    */
      /*   EMIT MULTIPLES OF 4096   */
      DO I = 0 TO 31;
         CALL EMIT_4BYTE_CONST(I * 4096);
      END;

       /*   MVC INSTRUCTION FOR COPYING DISPLAYS   */
      CALL EMIT_SS(MVC,0,10,20,9,20);
      CODE_INDEX = CODE_INDEX + 2;   /*   RE-ALIGN   */
      /*   WORKING STORAGE   */
      CALL EMIT_8BYTE_CONST(0,0);

      /*   FLOATING POINT CONSTANTS    */
      CALL EMIT_8BYTE_CONST("40800000",0);    /*   CONP5   */
      CALL EMIT_8BYTE_CONST("4E000000",0);   /*   DS4E   */
      CALL EMIT_8BYTE_CONST(0,0);       /*   CONSTD0     */
      CALL EMIT_8BYTE_CONST("4E000000",0);      /*   CON4E    */

      CALL EMIT_4BYTE_CONST(1);       /*   CONST1    */
      CALL EMIT_4BYTE_CONST("1C");     /*   DEC1    */

      CALL EMIT_8BYTE_CONST(-1,-1);   /*   DOUBLEWORD -1   */
      /*   INITIALIZE 8 ONE BYTE MASKS   */
      CALL EMIT_8BYTE_CONST("80402010","08040201");   /*   SET_MASKS   */
      /*   SPACE FOR SAVE AREA, MONITOR BASE ADDRESSES. THE LATTER ARE TO BE
           FILLED IN BY THE LOADER, BEFORE TRANSFERING CONTROL TO THE PASCAL
           PROGRAM             */
      DO I = 1 TO 19;
         CALL EMIT_4BYTE_CONST(0);
      END;
      /*   EMIT MEMORY OVERFLOW MONITOR ENTRY   */
      CALL EMIT_RX(STM,11,15,ORG,PASCAL_REGS);   /*  SAVE IMP'T REGS   */
      CALL EMIT_RX(LM,11,13,ORG,MON_BASE_REGS);
      CALL EMIT_RX(BC,UNCOND,0,13,204);
      /*   EMIT RANGE ERROR MONITOR ENTRY   */
      CALL EMIT_RX(STM,11,15,ORG,PASCAL_REGS);   /*  SAVE IMP'T REGS   */
      CALL EMIT_RX(LM,11,13,ORG,MON_BASE_REGS);
      CALL EMIT_RX(BC,UNCOND,0,13,200);

      /*   INITIALIZE BLOCK COUNTERS   */
      IF #BASIC_BLOCKS > 0 THEN
      DO I = 0 TO #BASIC_BLOCKS - 1;
         CALL EMIT_4BYTE_CONST("0C");   /*   DECIMAL 0   */
      END;

      /*   TRANSFER VECTOR     */
      DO I = 0 TO NEXT_SEQ# - 1;
         CALL EMIT_4BYTE_CONST(TRANSFER_VECTOR(I) );
      END;
      CALL SWAP_OUT_SEGMENT(ORG_FILE,
            '%ORG ' || I_FORMAT(  CODE_INDEX,5)
                    || I_FORMAT(  TRANSFER_VECTOR_BASE,5)
                ||   I_FORMAT(  MAX_TEMP_DISPL,5)
                  || I_FORMAT(   STORAGE_LENGTH(CURRENT_PROCEDURE),20) );
      CALL REWIND(1,ORG_FILE);

 END GENERATE_ORG_SEGMENT;

 FILL_LAST_LINE#_RECORD: PROCEDURE;
      /*   FILL OUT REMAINING ENTRIES  IN LINE#BUFF (IF ANY) & SWAP IT OUT */
      DO WHILE LINE_BUFF_PTR <= 20;
         LINE#BUFF(LINE_BUFF_PTR) = CODE_INDEX + ENTRY_POINT;
         LINE_BUFF_PTR = LINE_BUFF_PTR + 1;
      END;
      OUTPUT(LINE#FILE) = LINE_NUMS;
      OUTPUT(LINE#FILE) = '%END';
      CALL REWIND(1,LINE#FILE);
 END FILL_LAST_LINE#_RECORD;





      /*      P A S S   T H R E E   I N I T I A L I Z A T I O N        */


 INITIALIZE: PROCEDURE;


      /*     INITIALIZE GLOBAL VARIABLES       */

      COMPILING = TRUE;
      ENTRY_POINT = 0;
      NEXT_TEMP = BASE_TEMP;
      NEXT_TEMP_DISPL = 0;
      TEMP_DISPL_STACKTOP = 0;
      FORMAL_PARAMETER = FALSE;


      /*  INITIALIZE COUNTERS      */

      #FREE_TEMP = 0;
      #GET_REG = 0;
      #FLUSH_REG = 0;
      #STORE_REG = 0;
      #MAKE_OP_ADDR = 0;
      #FLUSH_ALL_TEMP_REGS = 0;
      #STM_FLUSHES = 0;
      #EMIT_RR = 0;
      #EMIT_RX = 0;
      #EMIT_SS = 0;


      /*  INITIALIZE REG COLUMN OF SYMBOL TABLE     */

      DO I = 0 TO SYMBOL_TABLE_SIZE;
         REG(I) = NULL;
      END;
      /*    INITIALIZE REGISTER TABLES. REGS 11-15 ARE FIXED PRIORITY   */

      DO I = 0 TO 22;
         CONTENT(I) = NULL;
         PRIORITY(I) = FREE_PRIORITY;
      END;
      DO I = 11 TO 15;
         PRIORITY(I) = FIXED_PRIORITY;
      END;


      /*   LINE NUMBER VARIABLES   */
      CURRENT_LINE# = 0;
      LINE_BUFF_PTR = 1;
      /*   FUDGE A DESCRIPTOR FOR LINE#BUFF    */
      I = SHL(79,24) + ADDR(LINE#BUFF) + 4;
      CALL INLINE(LOAD,1,0,I);
      CALL INLINE("50",1,0,LINE_NUMS);


 END INITIALIZE;





       /*              M A I N    P R O C E D U R E              */




      CPU_CLOCK = CLOCK_TRAP(1);   /*  READ CPU TIMER   */
      TIME_ENTERED = TIME;

      CALL INITIALIZE;
      CALL RESTORE_SY_TABLE;
      DO WHILE COMPILING;
         CALL READ_TRIPLES;
         CALL GENERATE_CODE;
         IF LIST_INSTRUCTIONS THEN CALL LIST_SYMBOLIC_CODE;
         CALL SWAP_OUT_SEGMENT(CODE_FILE,'%CODE' || I_FORMAT (CODE_INDEX,5) );
      END;
      CALL REWIND(0,TRIPLES_FILE);
      CALL REWIND(1,CODE_FILE);
      CALL FILL_LAST_LINE#_RECORD;
      CALL GENERATE_ORG_SEGMENT;
 END_COMPILATION:
      CALL PRINT_PASS3_STATISTICS;

EOF
