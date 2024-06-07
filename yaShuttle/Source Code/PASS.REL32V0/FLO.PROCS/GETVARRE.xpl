 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETVARRE.xpl
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
 /* PROCEDURE NAME:  GET_VAR_REF_CELL                                       */
 /* MEMBER NAME:     GETVARRE                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          FIXED                                                          */
 /* INPUT PARAMETERS:                                                       */
 /*          SYT#              BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CELL              FIXED                                        */
 /*          CTR               BIT(16)                                      */
 /*          GET_SUBSCRIPTS    LABEL                                        */
 /*          I                 BIT(16)                                      */
 /*          LIT_VAL           BIT(16)                                      */
 /*          NODE_F            FIXED                                        */
 /*          REF(100)          BIT(16)                                      */
 /*          REF_INX           BIT(16)                                      */
 /*          REFERENCE         MACRO                                        */
 /*          START             BIT(8)                                       */
 /*          SUB_INX           BIT(16)                                      */
 /*          SUBS(25)          BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BLOCK#                                                         */
 /*          INITIALIZING                                                   */
 /*          MODF                                                           */
 /*          OPR                                                            */
 /*          PROC_TRACE                                                     */
 /*          RELS                                                           */
 /*          RESV                                                           */
 /*          SYT                                                            */
 /*          VMEM_LOC_ADDR                                                  */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CELLSIZE                                                       */
 /*          DSUB_LOC                                                       */
 /*          EXP_VARS                                                       */
 /*          EXTN_LOC                                                       */
 /*          PTR_INX                                                        */
 /*          TSUB_LOC                                                       */
 /*          VAR_INX                                                        */
 /*          VMEM_H                                                         */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          GET_CELL                                                       */
 /*          GET_EXP_VARS_CELL                                              */
 /*          INTEGER_LIT                                                    */
 /*          POPNUM                                                         */
 /*          PROCESS_EXTN                                                   */
 /*          PTR_LOCATE                                                     */
 /*          SEARCH_EXPRESSION                                              */
 /*          TYPE_BITS                                                      */
 /*          X_BITS                                                         */
 /* CALLED BY:                                                              */
 /*          GET_NAME_INITIALS                                              */
 /*          GET_P_F_INV_CELL                                               */
 /*          PROCESS_HALMAT                                                 */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> GET_VAR_REF_CELL <==                                                */
 /*     ==> PTR_LOCATE                                                      */
 /*     ==> GET_CELL                                                        */
 /*     ==> POPNUM                                                          */
 /*     ==> TYPE_BITS                                                       */
 /*     ==> X_BITS                                                          */
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
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 03/07/91 TKK  23V2  CR11109  CLEAN UP OF COMPILER SOURCE CODE           */
 /*                                                                         */
 /***************************************************************************/
                                                                                00181600
 /* YOU GUESSED IT */                                                           00181700
GET_VAR_REF_CELL:                                                               00181800
   PROCEDURE (SYT#) FIXED;                                                      00181900
      DECLARE (I,SYT#,REF_INX,SUB_INX,CTR,LIT_VAL) BIT(16),                     00182000
         CELL FIXED, START BIT(8),                                              00182100
         REFERENCE LITERALLY 'SHR(OPR(CTR+I),16)',                              00182200
         REF(100) BIT(16), SUBS(25) BIT(16);                                    00182300
      BASED NODE_F FIXED;                                                       00182400
                                                                                00182500
 /* GROUPS SUBSCRIPTS VARIABLES INTO AN EXP VAR CELL AND PUTS LITERAL           00182600
SUBSCRIPT VALUES INTO THE VAR REF CELL */                                       00182700
GET_SUBSCRIPTS:                                                                 00182800
      PROCEDURE;                                                                00182900
         DECLARE (I,SUB_TYPE,OPERAND) BIT(16), TYPE BIT(8),                     00183000
            REFERENCE1 LITERALLY 'SHR(OPR(OPERAND+1),16)';                      00183100
                                                                                00183200
         DO I = 2 TO POPNUM(CTR);                                               00183300
            TYPE = 0;                                                           00183400
            OPERAND = CTR + I;                                                  00183500
            DO CASE TYPE_BITS(OPERAND);                                         00183600
               ;                                   /* 0 --     */               00183700
               DO;                                 /* 1 -- SYT */               00183800
                  VAR_INX = VAR_INX + 1;                                        00183900
                  EXP_VARS(VAR_INX) = REFERENCE;                                00184000
               END;                                                             00184100
               ;                                   /* 2 -- INL */               00184200
               CALL SEARCH_EXPRESSION(CTR+I);      /* 3 -- VAC */               00184300
               CALL PROCESS_EXTN(REFERENCE);       /* 4 -- XPT */               00184400
               DO;                                 /* 5 -- LIT */               00184500
                  LIT_VAL = INTEGER_LIT(REFERENCE);                             00184600
                  TYPE = 1;                                                     00184700
               END;                                                             00184800
               DO;                                 /* 6 -- IMD */               00184900
                  LIT_VAL = REFERENCE;                                          00185000
                  TYPE = 1;                                                     00185100
               END;                                                             00185200
               ;                                   /* 7 -- AST */               00185300
               DO;                                 /* 8 -- CSZ */               00185400
DO_CSZ:                                                                         00185500
                  IF REFERENCE = 0 THEN TYPE = 8;                               00185600
                  ELSE DO;                                                      00185700
                     TYPE = SHL(REFERENCE,1);                                   00185800
                     I = I + 1;                                                 00185900
                     DO CASE TYPE_BITS(OPERAND+1);                              00186000
                        ;                                                       00186100
                        DO;                                 /* 1 -- SYT */      00186200
                           REF_INX = REF_INX + 1;                               00186300
                           REF(REF_INX) = REFERENCE1;                           00186400
                        END;                                                    00186500
                        ;                                                       00186600
                        CALL SEARCH_EXPRESSION(OPERAND+1);   /* 3 -- VAC */     00186700
                        CALL PROCESS_EXTN(REFERENCE1);      /* 4 -- XPT */      00186800
                        DO;                                 /* 5 -- LIT */      00186900
                           LIT_VAL = INTEGER_LIT(REFERENCE1);                   00187000
                           TYPE = TYPE + 1;                                     00187100
                        END;                                                    00187200
                        DO;                                 /* 6 -- IMD */      00187300
                           LIT_VAL = REFERENCE1;                                00187400
                           TYPE = TYPE + 1;                                     00187500
                        END;                                                    00187600
                     END;                                                       00187700
                  END;                                                          00187800
               END;                                                             00187900
               GO TO DO_CSZ;                       /* 9 -- ASZ */               00188000
               ;                                   /* 10 -- OFF */              00188100
            END;                                                                00188200
            SUB_TYPE = (OPR(OPERAND) & "FF00") + SHL(TYPE,4) + X_BITS(OPERAND); 00188300
            SUB_INX = SUB_INX + 1;                                              00188400
            SUBS(SUB_INX) = SUB_TYPE;                                           00188500
            IF (TYPE & 1) = 1 THEN DO;                                          00188600
               SUB_INX = SUB_INX + 1;                                           00188700
               SUBS(SUB_INX) = LIT_VAL;                                         00188800
            END;                                                                00188900
         END;                                                                   00189000
      END GET_SUBSCRIPTS;                                                       00189100
                                                                                00189200
      IF PROC_TRACE THEN OUTPUT='GET_VAR_REF_CELL('||BLOCK#||':'||TSUB_LOC||    00189201
         ','||EXTN_LOC||','||DSUB_LOC||','||SYT#||')';                          00189202
      REF_INX, VAR_INX, PTR_INX = 0;                                            00189300
      IF SYT# ^= 0 THEN DO;                                                     00189400
         CELL = GET_CELL(12,ADDR(VMEM_H),MODF);                                 00189500
         VMEM_H(0) = 10;                                                        00189600
         VMEM_H(1) = 1;                                                         00189700
         VMEM_H(4) = SYT#;                                                      00189800
         SYT# = 0;                                                              00189900
      END;                                                                      00190000
      ELSE DO;                                                                  00190100
         IF TSUB_LOC ^= 0 THEN DO;                                              00190200
            CTR = TSUB_LOC;                                                     00190300
            REF_INX = REF_INX + 1;                                              00190400
            REF(REF_INX) = SHR(OPR(CTR+1),16);                                  00190500
            CALL GET_SUBSCRIPTS;                                                00190600
         END;                                                                   00190700
         IF EXTN_LOC ^= 0 THEN DO;                                              00190800
            CTR = EXTN_LOC;                                                     00190900
            IF TYPE_BITS(CTR+1) = SYT THEN START = 1;                           00191000
            ELSE START = 2;                                                     00191100
            DO I = START TO POPNUM(CTR);                                        00191200
               REF_INX = REF_INX + 1;                                           00191300
               REF(REF_INX) = REFERENCE;                                        00191400
            END;                                                                00191500
            IF X_BITS(CTR+POPNUM(CTR)-1) = 1 THEN REF_INX = REF_INX - 1;        00191501
         END;                                                                   00191600
         IF DSUB_LOC ^= 0 THEN DO;                                              00191700
            CTR = DSUB_LOC;                                                     00191800
            IF TYPE_BITS(CTR+1) = SYT THEN DO;                                  00191900
               REF_INX = REF_INX + 1;                                           00192000
               REF(REF_INX) = SHR(OPR(CTR+1),16);                               00192100
            END;                                                                00192200
            CALL GET_SUBSCRIPTS;                                                00192300
         END;                                                                   00192400
         CELLSIZE = SHL(REF_INX + SUB_INX + 4,1);                               00192500
         CELL = GET_CELL(CELLSIZE,ADDR(VMEM_H),MODF+RESV);                      00192600
         VMEM_H(0) = CELLSIZE;                                                  00192700
         VMEM_H(1) = REF_INX;                                                   00192800
         DO I = 1 TO REF_INX;                                                   00192900
            VMEM_H(I+3) = REF(I);                                               00193000
         END;                                                                   00193100
         DO I = 1 TO SUB_INX;                                                   00193200
            VMEM_H(I+REF_INX+3) = SUBS(I);                                      00193300
         END;                                                                   00193400
         IF SUB_INX > 0 THEN VMEM_H(1) = VMEM_H(1) | "8000";                    00193405
         IF ^INITIALIZING THEN DO;                                              00193500
            COREWORD(ADDR(NODE_F)) = VMEM_LOC_ADDR;                             00193600
            NODE_F(1) = GET_EXP_VARS_CELL;                                      00193700
         END;                                                                   00193800
         CALL PTR_LOCATE(CELL,RELS);                                            00193900
         TSUB_LOC, EXTN_LOC, DSUB_LOC, REF_INX, SUB_INX = 0;                    00194000
      END;                                                                      00194100
      RETURN CELL;                                                              00194200
   END GET_VAR_REF_CELL;                                                        00194300
