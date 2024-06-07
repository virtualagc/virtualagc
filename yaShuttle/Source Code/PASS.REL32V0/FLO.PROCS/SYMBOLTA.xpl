 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SYMBOLTA.xpl
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
 /* PROCEDURE NAME:  SYMBOL_TABLE_PREPASS                                   */
 /* MEMBER NAME:     SYMBOLTA                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          ARG               BIT(16)                                      */
 /*          CELL              FIXED                                        */
 /*          I                 BIT(16)                                      */
 /*          INPUT_PARMS       BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          LAST_PARM         LABEL                                        */
 /*          PARM_INX          BIT(16)                                      */
 /*          PARMS(100)        BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ACTUAL_SYMBOLS                                                 */
 /*          ASSIGN_FLAG                                                    */
 /*          COMM                                                           */
 /*          ENDSCOPE_FLAG                                                  */
 /*          EQUATE_LABEL                                                   */
 /*          FUNC_CLASS                                                     */
 /*          INPUT_FLAG                                                     */
 /*          MISC_NAME_FLAG                                                 */
 /*          MODF                                                           */
 /*          NAME_FLAG                                                      */
 /*          PROC_LABEL                                                     */
 /*          STRUCTURE                                                      */
 /*          SYM_CLASS                                                      */
 /*          SYM_FLAGS                                                      */
 /*          SYM_LENGTH                                                     */
 /*          SYM_NUM                                                        */
 /*          SYM_PTR                                                        */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYM_VPTR                                                       */
 /*          SYT_CLASS                                                      */
 /*          SYT_DIMS                                                       */
 /*          SYT_FLAGS                                                      */
 /*          SYT_NUM                                                        */
 /*          SYT_PTR                                                        */
 /*          SYT_TYPE                                                       */
 /*          SYT_VPTR                                                       */
 /*          VAR_CLASS                                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CELLSIZE                                                       */
 /*          EXP_VARS                                                       */
 /*          SYM_ADD                                                        */
 /*          SYT_VPTRS                                                      */
 /*          VAR_INX                                                        */
 /*          VMEM_H                                                         */
 /*          VPTR_INX                                                       */
 /*          WORD_STACK                                                     */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          GET_CELL                                                       */
 /* CALLED BY:                                                              */
 /*          INITIALIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SYMBOL_TABLE_PREPASS <==                                            */
 /*     ==> GET_CELL                                                        */
 /***************************************************************************/
                                                                                00143590
                                                                                00144500
 /*   $S   */                                                                   00144501
                                                                                00144600
 /* ROUTINE TO CREATE PROC/FUNC INVOCATION CELLS AND TO ALLOCATE AN AREA IN     00144700
COMMON FOR THE PASSAGE OF VMEM PTRS FOR SYMBOLS TO PHASE 3 */                   00144800
SYMBOL_TABLE_PREPASS:                                                           00144900
   PROCEDURE;                                                                   00145000
      DECLARE (PARM_INX,INPUT_PARMS,I,ARG,J) BIT(16),                           00145100
         PARMS(100) BIT(16), CELL FIXED;                                        00145200
                                                                                00145300
      DO I = 1 TO ACTUAL_SYMBOLS;                                               00145400
         IF SYT_CLASS(I) = FUNC_CLASS | SYT_TYPE(I) = PROC_LABEL THEN DO;       00145500
            ARG = SYT_PTR(I);                                                   00145600
            DO WHILE (SYT_FLAGS(ARG) & INPUT_FLAG) ^= 0;                        00145700
               PARM_INX = PARM_INX + 1;                                         00145800
               PARMS(PARM_INX) = ARG;                                           00145900
               IF (SYT_FLAGS(ARG) & ENDSCOPE_FLAG) ^= 0 THEN DO;                00145901
                  INPUT_PARMS = PARM_INX;                                       00145902
                  GO TO LAST_PARM;                                              00145905
               END;                                                             00145906
               ARG = ARG + 1;                                                   00146000
            END;                                                                00146100
            INPUT_PARMS = PARM_INX;                                             00146200
            DO WHILE (SYT_FLAGS(ARG) & ASSIGN_FLAG) ^= 0;                       00146300
               PARM_INX = PARM_INX + 1;                                         00146400
               PARMS(PARM_INX) = ARG;                                           00146500
               IF (SYT_FLAGS(ARG) & ENDSCOPE_FLAG) ^= 0 THEN                    00146501
                  GO TO LAST_PARM;                                              00146502
               ARG = ARG + 1;                                                   00146600
            END;                                                                00146700
LAST_PARM:                                                                      00146701
            IF PARM_INX > 0 THEN DO;                                            00146800
               CELLSIZE = SHL(PARM_INX + 2,1);                                  00146900
               CELL = GET_CELL(CELLSIZE,ADDR(VMEM_H),MODF);                     00147000
               VMEM_H(0) = CELLSIZE;                                            00147100
               VMEM_H(1) = SHL(PARM_INX,8) + INPUT_PARMS;                       00147200
               DO J = 1 TO PARM_INX;                                            00147300
                  VMEM_H(J+1) = PARMS(J);                                       00147400
               END;                                                             00147500
               PARM_INX = 0;                                                    00147600
            END;                                                                00147700
            ELSE DO;                                                            00147800
               CELL = GET_CELL(4,ADDR(VMEM_H),MODF);                            00147900
               VMEM_H(0) = 4;                                                   00148000
            END;                                                                00148100
            SYT_VPTRS = SYT_VPTRS + 1;                                          00148400
            VAR_INX = VAR_INX + 1;                                              00148500
            EXP_VARS(VAR_INX) = I;                                              00148600
            WORD_STACK(VAR_INX) = CELL;                                         00148700
         END;                                                                   00148900
         ELSE IF (SYT_FLAGS(I) & NAME_FLAG) ^= 0 THEN SYT_VPTRS = SYT_VPTRS + 1;00149000
         ELSE IF SYT_CLASS(I) = VAR_CLASS & SYT_TYPE(I) = STRUCTURE THEN DO;    00149100
            IF (SYT_FLAGS(SYT_DIMS(I)) & MISC_NAME_FLAG) ^= 0 THEN              00149200
               SYT_VPTRS = SYT_VPTRS + 1;                                       00149300
         END;                                                                   00149301
         ELSE IF SYT_TYPE(I) = EQUATE_LABEL THEN SYT_VPTRS = SYT_VPTRS + 1;     00149302
      END;                                                                      00149400
      ALLOCATE_SPACE(SYM_ADD,SYT_VPTRS);                                        00149500
      NEXT_ELEMENT(SYM_ADD);                                                    00149600
      DO I = 1 TO VAR_INX;                                                      00149700
         NEXT_ELEMENT(SYM_ADD);                                                 00149710
         SYT_NUM(I) = EXP_VARS(I);                                              00149800
         SYT_VPTR(I) = WORD_STACK(I);                                           00149900
      END;                                                                      00150000
      VPTR_INX = VAR_INX;                                                       00150100
      VAR_INX = 0;                                                              00150200
   END SYMBOL_TABLE_PREPASS;                                                    00150300
