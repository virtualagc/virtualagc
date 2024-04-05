 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETSTMTD.xpl
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
 /* PROCEDURE NAME:  GET_STMT_DATA                                          */
 /* MEMBER NAME:     GETSTMTD                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          NODE_F            FIXED                                        */
 /*          NODE_H            BIT(16)                                      */
 /*          TYPE              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          HMAT_OPT                                                       */
 /*          LABEL_SIZE                                                     */
 /*          NILL                                                           */
 /*          PHASE3_ERROR                                                   */
 /*          P3ERR                                                          */
 /*          RELS                                                           */
 /*          RESV                                                           */
 /*          STAB_FIXED_LEN                                                 */
 /*          X1                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          #LABELS                                                        */
 /*          #LHS                                                           */
 /*          DATA_CELL_PTR                                                  */
 /*          DECL_EXP_PTR                                                   */
 /*          HALMAT_CELL                                                    */
 /*          LABEL_TAB                                                      */
 /*          LHS_PTR                                                        */
 /*          LHS_TAB                                                        */
 /*          LHSSAVE                                                        */
 /*          OVERFLOW                                                       */
 /*          RHS_PTR                                                        */
 /*          SDC_FLAGS                                                      */
 /*          STMT_DATA                                                      */
 /*          TZCOUNT                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CHECK_COMPOUND                                                 */
 /*          LHS_CHECK                                                      */
 /*          LOCATE                                                         */
 /*          PTR_LOCATE                                                     */
 /*          REFORMAT_HALMAT                                                */
 /* CALLED BY:                                                              */
 /*          BUILD_SDF                                                      */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> GET_STMT_DATA <==                                                   */
 /*     ==> PTR_LOCATE                                                      */
 /*     ==> LOCATE                                                          */
 /*     ==> CHECK_COMPOUND                                                  */
 /*     ==> LHS_CHECK                                                       */
 /*     ==> REFORMAT_HALMAT                                                 */
 /*         ==> MIN                                                         */
 /*         ==> PTR_LOCATE                                                  */
 /*         ==> LOCATE                                                      */
 /*         ==> P3_PTR_LOCATE                                               */
 /*             ==> HEX8                                                    */
 /*             ==> ZERO_CORE                                               */
 /*             ==> P3_DISP                                                 */
 /*             ==> PAGING_STRATEGY                                         */
 /*         ==> GET_DATA_CELL                                               */
 /*             ==> P3_GET_CELL                                             */
 /*                 ==> P3_DISP                                             */
 /*                 ==> P3_LOCATE                                           */
 /*                     ==> P3_PTR_LOCATE                                   */
 /*                         ==> HEX8                                        */
 /*                         ==> ZERO_CORE                                   */
 /*                         ==> P3_DISP                                     */
 /*                         ==> PAGING_STRATEGY                             */
 /*                 ==> PUTN                                                */
 /*                     ==> MOVE                                            */
 /*                     ==> P3_PTR_LOCATE                                   */
 /*                         ==> HEX8                                        */
 /*                         ==> ZERO_CORE                                   */
 /*                         ==> P3_DISP                                     */
 /*                         ==> PAGING_STRATEGY                             */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 07/14/99 DCP  30V0  CR12214  USE THE SAFEST %MACRO THAT WORKS           */
 /*               15V0                                                      */
 /*                                                                         */
 /***************************************************************************/
                                                                                00209170
 /* ROUTINE TO ASSEMBLE STATEMENT DATA READ FROM FILE 6 */                      00209180
                                                                                00209190
GET_STMT_DATA:                                                                  00209200
   PROCEDURE BIT(16);                                                           00209210
      DECLARE (I,TYPE,INDX) BIT(16);          /*CR12214*/                       00209220
      BASED NODE_F FIXED, NODE_H BIT(16);                                       00209230
                                                                                00209240
      #LHS,#LABELS,TZCOUNT = 0;                                                 00209250
      DECL_EXP_PTR = NILL;                                                      00209260
      CALL LOCATE(DATA_CELL_PTR,ADDR(NODE_F),RESV);                             00209270
      IF NODE_F(2) ^= -1 THEN DO;                                               00209280
         IF (NODE_F(6) & "000000FF") = "15" THEN DECL_EXP_PTR = NODE_F(2);      00209290
         ELSE DO;                                                               00209300
            CALL LOCATE(NODE_F(2),ADDR(NODE_H),0);                              00209310
            DO I = 1 TO NODE_H(0);                                              00209320
               LABEL_TAB(#LABELS) = NODE_H(I);                                  00209330
               #LABELS = #LABELS + 1;                                           00209340
               IF #LABELS > LABEL_SIZE THEN DO;                                 00209350
                  OUTPUT = X1;                                                  00209360
                  OUTPUT = P3ERR || 'LABEL BUFFER OVERFLOW ***';                00209370
                  GO TO PHASE3_ERROR;                                           00209380
               END;                                                             00209390
            END;                                                                00209400
         END;                                                                   00209410
      END;                                                                      00209420
      IF NODE_F(3) ^= -1 THEN DO;                                               00209430
         CALL LOCATE(NODE_F(3),ADDR(NODE_H),0);                                 00209440
         DO I = 1 TO NODE_H(0);                                                 00209450
            TYPE = (NODE_H(I) & "8000");                                        00209460
            IF TYPE = 0 THEN DO;                                                00209470
               IF TZCOUNT = 0 THEN DO;                                          00209500
                  LHSSAVE = #LHS - 1;                                           00209550
                  LHS_TAB(#LHS) = LHS_TAB(LHSSAVE);                             00209600
                  #LHS = #LHS + 1;                                              00209650
                  CALL LHS_CHECK;                                               00209700
                  TZCOUNT = 1;                                                  00209750
               END;                                                             00209800
               LHS_TAB(#LHS) = NODE_H(I);                                       00209850
               #LHS = #LHS + 1;                                                 00209900
               CALL LHS_CHECK;                                                  00209950
               TZCOUNT = TZCOUNT + 1;                                           00210000
            END;                                                                00210050
            ELSE DO;                                                            00210100
               CALL CHECK_COMPOUND;                                             00210150
               LHS_TAB(#LHS) = (NODE_H(I) & "7FFF");                            00210200
               #LHS = #LHS + 1;                                                 00210250
               CALL LHS_CHECK;                                                  00210300
            END;                                                                00210350
         END;                                                                   00210400
      END;                                                                      00210450
      CALL CHECK_COMPOUND;                                                      00210500
      LHS_PTR = NODE_F(4);                                                      00210510
      RHS_PTR = NODE_F(5);                                                      00210520
      COREWORD(ADDR(NODE_H)) = ADDR(NODE_F(0)) + 26;                            00210550
      SDC_FLAGS = NODE_H(-1);      /*  GET OVERFLOW FLAG BITS */                00210555
      OVERFLOW = ((SDC_FLAGS & "4000") ^= 0);                                   00210560
      DO I = 0 TO STAB_FIXED_LEN;                                               00210600
         STMT_DATA(I) = NODE_H(I);                                              00210650
      END;                                                                      00210700
      IF SRN_FLAG THEN DO;                                          /*CR12214*/
        DO INDX = 0 TO RECORD_ALLOC(ADVISE)-1;                      /*CR12214*/
          IF STMT_DATA(1) = ADV_STMT#(INDX) THEN DO;                /*CR12214*/
            IF SDL_FLAG THEN                                        /*CR12214*/
              RVL#(INDX) = STMT_DATA(I-2);                          /*CR12214*/
            SRN#(INDX) = STRING(ADDR(STMT_DATA(I-5))+"1000000") ||  /*CR12214*/
                         STRING(ADDR(STMT_DATA(I-4))+"1000000") ||  /*CR12214*/
                         STRING(ADDR(STMT_DATA(I-3))+"1000000");    /*CR12214*/
          END;                                                      /*CR12214*/
        END;                                                        /*CR12214*/
        STMT_DATA(I-2) = STMT_DATA(I-1);                            /*CR12214*/
      END;                                                          /*CR12214*/
      IF NODE_H(0) < 0 THEN                                                     00210750
         DO I = STAB_FIXED_LEN+1 TO STAB_FIXED_LEN+3;                           00210800
           IF SRN_FLAG THEN                                         /*CR12214*/
             STMT_DATA(I-1) = NODE_H(I);                            /*CR12214*/
           ELSE                                                     /*CR12214*/
             STMT_DATA(I) = NODE_H(I);                                          00210850
      END;                                                                      00210900
      IF HMAT_OPT                                                               00210910
         THEN HALMAT_CELL = REFORMAT_HALMAT(NODE_F(-1));                        00210920
      CALL PTR_LOCATE(DATA_CELL_PTR,RELS);                                      00210950
      DATA_CELL_PTR = NODE_F(0);                                                00211000
      RETURN STMT_DATA(1);                                                      00211050
   END GET_STMT_DATA;                                                           00213900
