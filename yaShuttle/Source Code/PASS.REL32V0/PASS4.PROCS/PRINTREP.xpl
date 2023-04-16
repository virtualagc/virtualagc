 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PRINTREP.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

/***************************************************************************/
/* PROCEDURE NAME:  PRINT_REPLACE_TEXT                                     */
/* MEMBER NAME:     PRINTREP                                               */
/* INPUT PARAMETERS:                                                       */
/*          TEXT_PTR          FIXED                                        */
/*          #BYTES            FIXED                                        */
/* LOCAL DECLARATIONS:                                                     */
/*          #ARGS             BIT(16)                                      */
/*          BUILD_M           CHARACTER;                                   */
/*          CELL_SIZE         BIT(16)                                      */
/*          J                 BIT(8)                                       */
/*          LINE_DONE         LABEL                                        */
/*          M_CHAR_PTR        BIT(16)                                      */
/*          M_PTR             BIT(16)                                      */
/*          NEXT_CELL         LABEL                                        */
/*          NEXT_LINE         LABEL                                        */
/*          NODE_B            BIT(8)                                       */
/*          NODE_F            FIXED                                        */
/*          S(1)              CHARACTER;                                   */
/*          S1                CHARACTER;                                   */
/*          S2                CHARACTER;                                   */
/*          WAS_HERE          BIT(8)                                       */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          FALSE                                                          */
/*          LINELENGTH                                                     */
/*          LOC_ADDR                                                       */
/*          TRUE                                                           */
/*          X10                                                            */
/*          X2                                                             */
/*          X28                                                            */
/*          X60                                                            */
/*          X72                                                            */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          SDF_LOCATE                                                     */
/* CALLED BY:                                                              */
/*          DUMP_SDF                                                       */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> PRINT_REPLACE_TEXT <==                                              */
/*     ==> SDF_LOCATE                                                      */
/*         ==> SDF_PTR_LOCATE                                              */
/***************************************************************************/
/*  REVISION HISTORY :                                                     */
/*  ------------------                                                     */
/*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */
/*                                                                         */
/*02/01/94 RJN   26V0/ 108615 COPILER GENERATES ABEND 4005 WITH TABLST OPT */
/*               10V0                                                      */
/*                                                                         */
/***************************************************************************/
                                                                                00170200
 /* ROUTINE TO FORMAT AND PRINT REPLACE TEXT FROM SDF */                        00170201
                                                                                00170202
PRINT_REPLACE_TEXT:                                                             00170203
   PROCEDURE(TEXT_PTR,#BYTES);                                                  00170204
      DECLARE (TEXT_PTR,#BYTES) FIXED, (WAS_HERE,J) BIT(8),                     00170205
         (#ARGS,CELL_SIZE,M_PTR,M_CHAR_PTR) BIT(16),                            00170206
         (S1,S2,BUILD_M) CHARACTER, S(1) CHARACTER INITIAL('','S');             00170207
      BASED NODE_F FIXED, NODE_B BIT(8);                                        00170208
                                                                                00170209
      M_CHAR_PTR,WAS_HERE = 0;                                                  00170210
      BUILD_M = X10||'REPLACE TEXT('||#BYTES||' BYTE'||S(#BYTES^=1)||'):  "';   00170211
      M_PTR = LENGTH(BUILD_M);                                                  00170212
      BUILD_M = BUILD_M || X28 || X72;                                          00170213
NEXT_CELL:                                                                      00170214
      CALL SDF_LOCATE(TEXT_PTR,ADDR(NODE_F),0);                                 00170215
      CELL_SIZE = SHR(NODE_F(1),16);                                            00170217
      IF (CELL_SIZE & "8000") ^= 0 THEN DO;                                     00170218
         #ARGS = -CELL_SIZE - 1;                                                00170219
         TEXT_PTR = NODE_F(0);                                                  00170220
         IF #ARGS >= 1 THEN DO;                                                 00170221
            S1 = X10 || 'REPLACE ARG' || S(#ARGS>1) || ': ';                    00170222
            DO J = 1 TO #ARGS;                                                  00170223
               COREWORD(ADDR(S2)) = LOC_ADDR + NODE_F(J+1);                     00170224
               IF LENGTH(S1) + LENGTH(S2) > LINELENGTH THEN DO;                 00170225
                  OUTPUT = S1;                                                  00170226
                  S1 = X10 || S2 || ',';                                        00170227
               END;                                                             00170228
               ELSE S1 = S1 || S2 || ',';                                       00170229
            END;                                                                00170230
            BYTE(S1,LENGTH(S1) - 1) = BYTE(' ');                                00170231
            IF LENGTH(S1) + M_PTR < LINELENGTH THEN DO;                         00170232
               BUILD_M = S1 || X2 || SUBSTR(BUILD_M,17);                        00170233
               M_PTR = M_PTR + LENGTH(S1) - 15;                                 00170234
            END;                                                                00170235
            ELSE OUTPUT = S1;                                                   00170236
         END;                                                                   00170237
/*  DR 108615 - RJN  */
/*  IF THE NUMBER OF BYTES OF REPLACE TEXT IS ZERO THEN THERE WILL  */
/*  BE NO REPLACE TEXT MACRO CELLS.  THUS, EXIT THE LOOP NOW.       */
         IF #BYTES ^= 0 THEN GO TO NEXT_CELL;                                   00170238
      END;                                                                      00170239
      COREWORD(ADDR(NODE_B)) = LOC_ADDR + 6;                                    00170240
      J = NODE_B(M_CHAR_PTR);                                                   00170241
LINE_DONE:                                                                      00170242
      DO WHILE M_CHAR_PTR<CELL_SIZE & M_PTR<LINELENGTH;                         00170243
         IF J = "EE" THEN DO;                                                   00170244
            M_CHAR_PTR = M_CHAR_PTR + 1;                                        00170245
            J = NODE_B(M_CHAR_PTR);                                             00170246
            IF J=0 THEN RETURN;                                                 00170247
NEXT_LINE:  IF (J + M_PTR)>LINELENGTH THEN DO;                                  00170248
               J = J - LINELENGTH + M_PTR;                                      00170249
               OUTPUT = BUILD_M;                                                00170250
               BUILD_M = X72 || X60;                                            00170251
               M_PTR = 10;                                                      00170252
               GO TO NEXT_LINE;                                                 00170253
            END;                                                                00170254
            ELSE M_PTR = M_PTR + J;                                             00170255
         END;                                                                   00170256
         ELSE IF J = BYTE('"') THEN DO;                                         00170257
            IF WAS_HERE THEN WAS_HERE = FALSE;                                  00170258
            ELSE DO;                                                            00170259
               WAS_HERE = TRUE;                                                 00170260
               M_CHAR_PTR = M_CHAR_PTR - 1;                                     00170261
            END;                                                                00170262
            BYTE(BUILD_M,M_PTR) = J;                                            00170263
         END;                                                                   00170264
         ELSE BYTE(BUILD_M,M_PTR) = J;                                          00170265
         M_PTR = M_PTR + 1;                                                     00170266
         M_CHAR_PTR = M_CHAR_PTR + 1;                                           00170267
         J = NODE_B(M_CHAR_PTR);                                                00170268
      END;                                                                      00170269
      IF M_CHAR_PTR < CELL_SIZE THEN DO;                                        00170270
         OUTPUT = BUILD_M;                                                      00170271
         BUILD_M = X72 || X60;                                                  00170272
         M_PTR = 10;                                                            00170273
         GO TO LINE_DONE;                                                       00170274
      END;                                                                      00170275
      ELSE IF NODE_F(0) ^= 0 THEN DO;                                           00170276
         TEXT_PTR = NODE_F(0);                                                  00170277
         GO TO NEXT_CELL;                                                       00170278
      END;                                                                      00170279
      ELSE DO;                                                                  00170280
         BYTE(BUILD_M,M_PTR) = BYTE('"');                                       00170281
         OUTPUT = BUILD_M;                                                      00170282
      END;                                                                      00170283
   END PRINT_REPLACE_TEXT;                                                      00170284
