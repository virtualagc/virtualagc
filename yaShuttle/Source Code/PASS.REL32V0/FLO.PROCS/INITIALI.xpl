 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   INITIALI.xpl
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
 /* PROCEDURE NAME:  INITIALIZE                                             */
 /* MEMBER NAME:     INITIALI                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          COMM                                                           */
 /*          INIT_SMRK_LINK                                                 */
 /*          OPTIONS_CODE                                                   */
 /*          SMRK_LIST                                                      */
 /*          STMT_DATA_HEAD                                                 */
 /*          SYM_ADD                                                        */
 /*          TOGGLE                                                         */
 /*          TRUE                                                           */
 /*          VMEM_F                                                         */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          BLOCK#                                                         */
 /*          CTR                                                            */
 /*          HMAT_OPT                                                       */
 /*          OLD_STMT#                                                      */
 /*          SMRK_LINK                                                      */
 /*          START_NODE                                                     */
 /*          STMT_DATA_CELL                                                 */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          GET_CELL                                                       */
 /*          NEW_HALMAT_BLOCK                                               */
 /*          SYMBOL_TABLE_PREPASS                                           */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> INITIALIZE <==                                                      */
 /*     ==> GET_CELL                                                        */
 /*     ==> NEW_HALMAT_BLOCK                                                */
 /*         ==> ZERO_CORE                                                   */
 /*     ==> SYMBOL_TABLE_PREPASS                                            */
 /*         ==> GET_CELL                                                    */
 /***************************************************************************/
                                                                                00150400
INITIALIZE:                                                                     00150401
   PROCEDURE;                                                                   00150402
 /*  IF PHASE 1 ERRORS OR NOTABLES THEN LINK TO NEXT PHASE */                   00150403
      IF (OPTIONS_CODE & "800") = 0 | (TOGGLE & "8") ^=0 THEN CALL RECORD_LINK; 00150404
      IF (OPTIONS_CODE & "00040000") ^= 0                                       00150414
         THEN HMAT_OPT = TRUE;                                                  00150424
      RECORD_UNSEAL(SYM_ADD);                                                   00150434
      CALL SYMBOL_TABLE_PREPASS;                                                00150444
      CALL NEW_HALMAT_BLOCK;                                                    00150454
      CTR = 2;                                                                  00150464
      BLOCK# = 0;                                                               00150474
      IF HMAT_OPT                                                               00150484
         THEN DO;                                                               00150494
         START_NODE = 2;                                                        00150504
         SMRK_LINK = INIT_SMRK_LINK;                                            00150514
      END;                                                                      00150524
      OLD_STMT# = 1;                                                            00150534
 /* ELIMINATE THE ZERO PTR */                                                   00150554
      CALL GET_CELL(4,ADDR(VMEM_F),0);                                          00150564
      STMT_DATA_CELL = STMT_DATA_HEAD;                                          00150574
   END INITIALIZE;                                                              00150584
