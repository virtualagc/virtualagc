 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ADDSMRKN.xpl
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
 /* PROCEDURE NAME:  ADD_SMRK_NODE                                          */
 /* MEMBER NAME:     ADDSMRKN                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          START             BIT(16)                                      */
 /*          STOP              BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          BLOCK_SYT#        BIT(16)                                      */
 /*          CELL              BIT(16)                                      */
 /*          CELL_COUNT        BIT(16)                                      */
 /*          CHANGE_VAC        LABEL                                        */
 /*          HAVE_SYT_PTR(1)   MACRO                                        */
 /*          I                 BIT(16)                                      */
 /*          LIMIT             BIT(16)                                      */
 /*          NEW_START         BIT(16)                                      */
 /*          NODE              FIXED                                        */
 /*          PUSH_NODE         LABEL                                        */
 /*          SMRK_NODE         FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          EDCL                                                           */
 /*          FALSE                                                          */
 /*          IND_CALL_LAB                                                   */
 /*          MODF                                                           */
 /*          NILL                                                           */
 /*          NOP                                                            */
 /*          OPR                                                            */
 /*          RELS                                                           */
 /*          RESV                                                           */
 /*          SAVE_OP                                                        */
 /*          SMRK_NODE_SZ                                                   */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT                                                            */
 /*          SYT_TYPE                                                       */
 /*          VAC_OPERAND                                                    */
 /*          VAC                                                            */
 /*          VMEM_LIM                                                       */
 /*          VMEM_PAGE_SIZE                                                 */
 /*          XREC_WORD                                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          #CELLS                                                         */
 /*          FINAL_OP                                                       */
 /*          INITIAL_CASE                                                   */
 /*          OLD_SMRK_NODE                                                  */
 /*          SMRK_LINK                                                      */
 /*          VAC_START                                                      */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          GET_CELL                                                       */
 /*          INDIRECT                                                       */
 /*          MIN                                                            */
 /*          POPCODE                                                        */
 /*          PTR_LOCATE                                                     */
 /*          TYPE_BITS                                                      */
 /* CALLED BY:                                                              */
 /*          KEEP_POINTERS                                                  */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> ADD_SMRK_NODE <==                                                   */
 /*     ==> PTR_LOCATE                                                      */
 /*     ==> GET_CELL                                                        */
 /*     ==> MIN                                                             */
 /*     ==> POPCODE                                                         */
 /*     ==> TYPE_BITS                                                       */
 /*     ==> INDIRECT                                                        */
 /***************************************************************************/
                                                                                00138910
 /* PROCEDURE TO BUILD A LIST OF HALMAT */                                      00138920
ADD_SMRK_NODE:                                                                  00138930
   PROCEDURE (START,STOP);                                                      00138940
      DECLARE (START,STOP) BIT(16),                                             00138950
         (NEW_START,LIMIT,CELL_COUNT,I,CELL) BIT(16),                           00138960
         NODE FIXED;                                                            00138970
      DECLARE BLOCK_SYT# BIT(16);                                               00138971
      DECLARE HAVE_SYT_PTR(1) LITERALLY                                         00138972
         '(OPR(%1%) & (TYPE_BITS(%1%) = SYT))';                                 00138973
      BASED SMRK_NODE FIXED;                                                    00138980
                                                                                00138990
CHANGE_VAC:                                                                     00139000
      PROCEDURE (CELL) FIXED;                                                   00139010
         DECLARE CELL FIXED,                                                    00139020
            (OLD_VAL,NEW_VAL,OFFSET) BIT(16);                                   00139030
         OFFSET = #CELLS;                                                       00139040
         OLD_VAL = SHR(CELL,16);                                                00139050
         NEW_VAL = OFFSET+(OLD_VAL-VAC_START);                                  00139060
         RETURN SHL(NEW_VAL,16) | (CELL & "FFFF");                              00139070
      END CHANGE_VAC;                                                           00139080
                                                                                00139090
PUSH_NODE:                                                                      00139100
      PROCEDURE;                                                                00139110
         COREWORD(SMRK_LINK) = NODE;  /* LINK NEW NODE TO OLD */                00139120
         IF OLD_SMRK_NODE ^= NILL                                               00139130
            THEN CALL PTR_LOCATE(OLD_SMRK_NODE,RELS); /* RELEASE OLD NODE */    00139140
         OLD_SMRK_NODE = NODE;                                                  00139150
         SMRK_NODE(CELL) = XREC_WORD;  /* NEXT WORD IS USED AS POINTER */       00139160
         SMRK_NODE(CELL+1) = NILL;                                              00139170
         SMRK_LINK = ADDR(SMRK_NODE(CELL+1));                                   00139180
      END PUSH_NODE;                                                            00139190
                                                                                00139200
 /* MAIN CODE FOR ADD_SMRK_NODE */                                              00139210
      IF START > STOP THEN RETURN;  /* NO CODE */                               00139220
      CELL_COUNT,LIMIT =0;                                                      00139230
      NEW_START,VAC_START = START;                                              00139240
      DO WHILE LIMIT<STOP;                                                      00139250
         LIMIT=MIN(NEW_START+VMEM_LIM,STOP);/* WILL HMAT FIT ON PAGE */         00139260
         NODE=GET_CELL(SMRK_NODE_SZ(NEW_START,LIMIT),ADDR(SMRK_NODE),RESV|MODF);00139270
         IF INITIAL_CASE                                                        00139280
            THEN DO;                                                            00139290
            CELL = 1;                                                           00139300
            INITIAL_CASE = FALSE;                                               00139310
         END;                                                                   00139320
         ELSE CELL = 0;                                                         00139330
         DO I = NEW_START TO LIMIT;                                             00139340
            IF SAVE_OP(I)                                                       00139350
               THEN DO;                                                         00139360
               IF VAC_OPERAND(I)                                                00139370
                  THEN SMRK_NODE(CELL) = CHANGE_VAC(OPR(I));                    00139380
               ELSE SMRK_NODE(CELL) = OPR(I);                                   00139390
               IF HAVE_SYT_PTR(I) THEN DO; /* CHECK FOR SYMBOL TABLE ENTRY */   00139391
                  BLOCK_SYT# = SHR(OPR(I), 16);                                 00139392
 /* CHECK FOR INDIRECT CALL LABEL */                                            00139393
                  IF SYT_TYPE(BLOCK_SYT#) = IND_CALL_LAB THEN DO;               00139394
 /* FIND ACTUAL SYMBOL TABLE NUMBER FOR IND_CALL_LAB */                         00139395
                     BLOCK_SYT# = INDIRECT(BLOCK_SYT#);                         00139396
 /* PUT THIS SYT TABLE NUMBER IN THE SMRK_NODE */                               00139397
                     SMRK_NODE(CELL) = SHL(BLOCK_SYT#, 16) |(OPR(I) & "FFFF");  00139398
                  END;                                                          00139399
               END;                                                             00139400
               IF ^OPR(I) THEN FINAL_OP = #CELLS+CELL_COUNT+CELL;               00139401
 /* IF NOT OPERAND, THEN RECORD POSITION OF OPERATOR */                         00139410
               CELL = CELL+1;                                                   00139420
            END;                                                                00139430
            ELSE VAC_START = VAC_START+1;                                       00139440
         END;                                                                   00139450
         CALL PUSH_NODE;                                                        00139460
         CELL_COUNT = CELL_COUNT+CELL;                                          00139470
         NEW_START = LIMIT+1;                                                   00139480
      END;                                                                      00139490
      #CELLS = #CELLS+CELL_COUNT;                                               00139500
   END ADD_SMRK_NODE;                                                           00139510
