 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   P3GETCEL.xpl
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
 /* PROCEDURE NAME:  P3_GET_CELL                                            */
 /* MEMBER NAME:     P3GETCEL                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PRED_PTR          FIXED                                        */
 /*          LENGTH            BIT(16)                                      */
 /*          BVAR              FIXED                                        */
 /*          FLAGS             BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CUR_PTR           FIXED                                        */
 /*          DEX               FIXED                                        */
 /*          FULL_TEMP         FIXED                                        */
 /*          GOT_CELL          LABEL                                        */
 /*          NODE              FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FOREVER                                                        */
 /*          FREE_CHAIN                                                     */
 /*          MODF                                                           */
 /*          PAGE_SIZE                                                      */
 /*          PHASE3_ERROR                                                   */
 /*          P3ERR                                                          */
 /*          TRUE                                                           */
 /*          X1                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          OVERFLOW_FLAG                                                  */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          P3_DISP                                                        */
 /*          PUTN                                                           */
 /*          P3_LOCATE                                                      */
 /* CALLED BY:                                                              */
 /*          GET_DIR_CELL                                                   */
 /*          GET_DATA_CELL                                                  */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> P3_GET_CELL <==                                                     */
 /*     ==> P3_DISP                                                         */
 /*     ==> P3_LOCATE                                                       */
 /*         ==> P3_PTR_LOCATE                                               */
 /*             ==> HEX8                                                    */
 /*             ==> ZERO_CORE                                               */
 /*             ==> P3_DISP                                                 */
 /*             ==> PAGING_STRATEGY                                         */
 /*     ==> PUTN                                                            */
 /*         ==> MOVE                                                        */
 /*         ==> P3_PTR_LOCATE                                               */
 /*             ==> HEX8                                                    */
 /*             ==> ZERO_CORE                                               */
 /*             ==> P3_DISP                                                 */
 /*             ==> PAGING_STRATEGY                                         */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /* -----------------                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR#     DESCRIPTION                              */
 /* -------- ---  ----- --------   ---------------------------------------- */
 /*                                                                         */
 /* 01/27/94 TEV  26V0/ DR106822   PHASE 3 INTERNAL ERROR                   */
 /*               10V0                                                      */
 /*                                                                         */
 /***************************************************************************/
                                                                                00192000
 /* ROUTINE TO ALLOCATE SDF CELLS */                                            00192200
                                                                                00192300
P3_GET_CELL:                                                                    00192400
   PROCEDURE (PRED_PTR,LENGTH,BVAR,FLAGS);                                      00192500
      DECLARE (DEX,PRED_PTR,CUR_PTR,BVAR,FULL_TEMP) FIXED,                      00192600
/********** DR106833 - TEV - 1/27/94 ********/
/* CHANGE LENGTH TO A FIXED (SIGNED 32-BIT) */
/* DATATYPE TO AVOID BIT(16) OVERFLOW.      */
         LENGTH FIXED,                                                          00192700
/********** END DR106822 ********************/
         FLAGS BIT(8);                                                          00192800
      BASED NODE FIXED;                                                         00192900
      LENGTH = (LENGTH + 3)&"FFFFFFFC";                                         00193000
      IF LENGTH < 8 THEN LENGTH = 8;                                            00193100
      IF LENGTH > PAGE_SIZE THEN DO;                                            00193200
         OUTPUT = X1;                                                           00193300
         OUTPUT = P3ERR || 'ILLEGAL CELL SIZE (' || LENGTH || ') ***';          00193400
         GO TO PHASE3_ERROR;                                                    00193500
      END;                                                                      00193600
      CUR_PTR = PRED_PTR;                                                       00193700
      DO FOREVER;                                                               00193800
         CALL P3_LOCATE(CUR_PTR,ADDR(NODE),0);                                  00193900
         IF NODE(0) >= LENGTH THEN DO;                                          00194000
            IF NODE(0) < LENGTH + 8 THEN LENGTH = NODE(0);                      00194100
            IF NODE(0) = LENGTH THEN DO;                                        00194200
               FULL_TEMP = NODE(1);                                             00194300
               NODE(1) = 0;                                                     00194400
               CALL P3_DISP(MODF);                                              00194500
               CALL PUTN(PRED_PTR,4,ADDR(FULL_TEMP),4,0);                       00194600
               GO TO GOT_CELL;                                                  00194700
            END;                                                                00194800
            ELSE DO;                                                            00194900
               NODE(0) = NODE(0) - LENGTH;                                      00195000
               CUR_PTR = CUR_PTR + NODE(0);                                     00195100
               DEX = SHR(NODE(0),2);                                            00195200
               NODE(DEX) = LENGTH;                                              00195300
               GO TO GOT_CELL;                                                  00195400
            END;                                                                00195500
         END;                                                                   00195600
         ELSE DO;                                                               00195700
            PRED_PTR = CUR_PTR;                                                 00195800
            CUR_PTR = NODE(1);                                                  00195900
            IF CUR_PTR = 0 THEN DO;                                             00196000
               CUR_PTR = FREE_CHAIN;                                            00196100
               OVERFLOW_FLAG = TRUE;                                            00196200
            END;                                                                00196300
         END;                                                                   00196400
      END;                                                                      00196500
GOT_CELL:                                                                       00196600
      FLAGS = FLAGS | MODF;                                                     00196700
      CALL P3_LOCATE(CUR_PTR,BVAR,FLAGS);                                       00196800
   END P3_GET_CELL;                                                             00197000
