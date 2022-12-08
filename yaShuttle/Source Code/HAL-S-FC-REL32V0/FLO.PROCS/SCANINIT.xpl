 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SCANINIT.xpl
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
 /* PROCEDURE NAME:  SCAN_INITIAL_LIST                                      */
 /* MEMBER NAME:     SCANINIT                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          STRI_LOC          BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          #LOOPS            BIT(16)                                      */
 /*          CELL_#LOOPS       BIT(16)                                      */
 /*          CELL_LOOP_WIDTH   BIT(16)                                      */
 /*          CTR               BIT(16)                                      */
 /*          FIND_GCD(759)     LABEL                                        */
 /*          GCD               BIT(16)                                      */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          LOOP_CYCLE        BIT(16)                                      */
 /*          LOOP_WIDTH        BIT(16)                                      */
 /*          NAME_BIT          FIXED                                        */
 /*          OPERATOR          BIT(16)                                      */
 /*          POINTER_VALUES    BIT(8)                                       */
 /*          PREV_LOC          BIT(16)                                      */
 /*          SLRI_INX          BIT(16)                                      */
 /*          SLRI_LOC(12)      BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BLOCK#                                                         */
 /*          CLASS_BI                                                       */
 /*          ELRI                                                           */
 /*          ETRI                                                           */
 /*          FALSE                                                          */
 /*          FOREVER                                                        */
 /*          IDLP                                                           */
 /*          IMD                                                            */
 /*          NAME_TERM_TRACE                                                */
 /*          OPR                                                            */
 /*          PROC_TRACE                                                     */
 /*          SLRI                                                           */
 /*          STRUCT_COPIES                                                  */
 /*          SYT                                                            */
 /*          TEMPL_WIDTH                                                    */
 /*          TINT                                                           */
 /*          TRUE                                                           */
 /*          X10                                                            */
 /*          X3                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          HALMAT_PTR                                                     */
 /*          IN_IDLP                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERRORS                                                         */
 /*          FORMAT                                                         */
 /*          HEX                                                            */
 /*          NEXT_OP                                                        */
 /*          POPCODE                                                        */
 /*          POPVAL                                                         */
 /*          TYPE_BITS                                                      */
 /* CALLED BY:                                                              */
 /*          GET_NAME_INITIALS                                              */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SCAN_INITIAL_LIST <==                                               */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /*     ==> FORMAT                                                          */
 /*     ==> HEX                                                             */
 /*     ==> POPCODE                                                         */
 /*     ==> POPVAL                                                          */
 /*     ==> TYPE_BITS                                                       */
 /*     ==> NEXT_OP                                                         */
 /***************************************************************************/
 /***************************************************************************/
 /*                                                                         */
 /*  DATE      DEV  REL     DR/CR     TITLE                                 */
 /*                                                                         */
 /*  04/12/01  DCP  31V0/   DR111361  NAME INITIALIZATION INFORMATION       */
 /*                 16V0              MISSING IN SDF                        */
 /*                                                                         */
 /***************************************************************************/
                                                                                00194400
 /* SETS UP HALMAT_PTR ARRAY IN PREPARATION FOR INITIAL LIST PROCESSING */      00194500
SCAN_INITIAL_LIST:                                                              00194600
   PROCEDURE (STRI_LOC) BIT(16);                                                00194700
      DECLARE (PREV_LOC,STRI_LOC,CTR,OPERATOR,J,LOOP_WIDTH,GCD,#LOOPS) BIT(16), 00194800
         SLRI_LOC(12) BIT(16), SLRI_INX BIT(16), POINTER_VALUES BIT(8),         00194900
         NAME_BIT FIXED INITIAL("80000000"),                                    00195000
         (I,LOOP_CYCLE,CELL_LOOP_WIDTH,CELL_#LOOPS) BIT(16);                    00195001
                                                                                00195100
FIND_GCD:                                                                       00195200
      PROCEDURE (ARG1,ARG2) BIT(16);                                            00195300
         DECLARE (ARG1,ARG2) BIT(16);                                           00195400
                                                                                00195500
         IF ARG1 = 0 THEN RETURN ARG2;                                          00195600
         IF ARG2 = 0 THEN RETURN ARG1;                                          00195700
         IF ARG1 = 1 | ARG2 = 1 THEN RETURN 1;                                  00195800
         DO FOREVER;                                                            00195900
            IF ARG1 < ARG2 THEN ARG2 = ARG2 - ARG1;                             00196000
            ELSE IF ARG1 > ARG2 THEN ARG1 = ARG1 - ARG2;                        00196100
            ELSE RETURN ARG1;                                                   00196200
         END;                                                                   00196300
      END FIND_GCD;                                                             00196400
                                                                                00196500
      IF PROC_TRACE THEN OUTPUT='SCAN_INIT_LIST('||BLOCK#||':'||STRI_LOC||')';  00196501
      POINTER_VALUES = FALSE;                                                   00196600
      SLRI_INX = 0;                                                             00196601
      CTR, PREV_LOC = STRI_LOC;                                                 00196700
      DO FOREVER;                                                               00196800
         CTR = NEXT_OP(CTR);                                                    00196900
         OPERATOR = POPCODE(CTR);                                               00197000
         IF OPERATOR = TINT THEN DO;                                            00197100
            IF (OPR(CTR) & NAME_BIT) ^= 0 THEN DO;                              00197200
               IF TYPE_BITS(CTR + 2) ^= IMD THEN DO;                            00197300
                  IF TYPE_BITS(CTR + 2) = SYT THEN                              00197400
                     HALMAT_PTR(CTR+2) = POPVAL(CTR+2) | "80000000";            00197500
                  ELSE HALMAT_PTR(CTR+2) = HALMAT_PTR(POPVAL(CTR+2));           00197600
                  POINTER_VALUES = TRUE;                                        00197700
               END;                                                             00197800
               IF SLRI_INX = 0 | PREV_LOC > SLRI_LOC(SLRI_INX) THEN DO;         00197900
                  HALMAT_PTR(PREV_LOC) = CTR;                                   00198000
               END;                                                             00198100
               ELSE DO;                                                         00198200
                  J = SLRI_INX;                                                 00198300
                  DO WHILE SLRI_LOC(J-1) > PREV_LOC;                            00198400
                     J = J - 1;                                                 00198500
                  END;                                                          00198600
                  HALMAT_PTR(PREV_LOC) = SLRI_LOC(J);                           00198700
                  DO I = J+1 TO SLRI_INX;                                       00198800
                     HALMAT_PTR(SLRI_LOC(I-1)) = SLRI_LOC(I);                   00198900
                  END;                                                          00199000
                  HALMAT_PTR(SLRI_LOC(SLRI_INX)) = CTR;                         00199100
               END;                                                             00199200
               PREV_LOC = CTR;                                                  00199300
            END;                                                                00199400
         END;                                                                   00199500
         ELSE IF OPERATOR = SLRI THEN DO;                                       00199600
            SLRI_INX = SLRI_INX + 1;                                            00199700
            SLRI_LOC(SLRI_INX) = CTR;                                           00199800
         END;                                                                   00199900
         ELSE IF OPERATOR = ELRI THEN DO;                                       00200000
            IF SLRI_INX <= 0 THEN                                               00200100
               CALL ERRORS (CLASS_BI, 206);                                     00200200
            IF PREV_LOC >= SLRI_LOC(SLRI_INX) THEN DO;                          00200300
               SLRI_LOC = SLRI_LOC(SLRI_INX) ;                                  00200500
               LOOP_WIDTH = POPVAL(SLRI_LOC + 2);                               00200600
               #LOOPS = POPVAL(SLRI_LOC + 1);                                   00200700
               IF #LOOPS * LOOP_WIDTH > TEMPL_WIDTH THEN DO;                    00200800
                  GCD = FIND_GCD(TEMPL_WIDTH,LOOP_WIDTH);                       00200900
                  LOOP_CYCLE = TEMPL_WIDTH / GCD;                               00201000
                  CELL_LOOP_WIDTH = LOOP_WIDTH / GCD;                           00201100
                  CELL_#LOOPS = #LOOPS / LOOP_CYCLE;                            00201200
                  HALMAT_PTR(SLRI_LOC+1) = LOOP_CYCLE;                          00201300
                  HALMAT_PTR(SLRI_LOC+2) = SHL(CELL_#LOOPS,16)|CELL_LOOP_WIDTH; 00201400
               END;                                                             00201500
               HALMAT_PTR(PREV_LOC) = CTR;                                      00201600
               PREV_LOC = CTR;                                                  00201700
            END;                                                                00201800
            SLRI_INX = SLRI_INX - 1;                                            00201801
         END;                                                                   00201900
         ELSE IF OPERATOR = ETRI THEN DO;                                       00202000
            HALMAT_PTR(PREV_LOC) = CTR;                                         00202001
            HALMAT_PTR(CTR) = STRI_LOC;                                         00202100
            IF NAME_TERM_TRACE THEN                                             00202101
               DO J = STRI_LOC TO CTR;                                          00202102
               IF HALMAT_PTR(J) ^= 0 THEN                                       00202103
                  OUTPUT = X10||FORMAT(J,4)||X3||HEX(OPR(J),8)||                00202104
                  X3||HEX(HALMAT_PTR(J),8);                                     00202105
            END;                                                                00202106
            CTR = NEXT_OP(CTR);                                                 00202200
            OPERATOR = POPCODE(CTR);                                            00202300
            IF (OPERATOR = IDLP) | (OPERATOR = ADLP) THEN DO;      /*DR111361*/ 00202400
               IN_IDLP = TRUE;                                                  00202500
               IF STRUCT_COPIES ^= POPVAL(CTR+1) THEN                           00202600
                  CALL ERRORS (CLASS_BI, 207);                                  00202700
            END;                                                                00202800
            ELSE IN_IDLP = FALSE;                                               00202900
            RETURN POINTER_VALUES;                                              00203000
         END;                                                                   00203100
      END;                                                                      00203200
   END SCAN_INITIAL_LIST;                                                       00203300
