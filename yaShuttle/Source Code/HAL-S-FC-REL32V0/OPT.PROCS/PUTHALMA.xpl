 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PUTHALMA.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  PUT_HALMAT_BLOCK                                       */
 /* MEMBER NAME:     PUTHALMA                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          PUT_BLOCK         LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BLOCK_END                                                      */
 /*          BLOCK_PLUS_1                                                   */
 /*          CLASS_BI                                                       */
 /*          CODE_OUTFILE                                                   */
 /*          HALMAT_BLAB                                                    */
 /*          IMD_0                                                          */
 /*          TOTAL                                                          */
 /*          XPXRC                                                          */
 /*          XREC_PTR                                                       */
 /*          XSMRK                                                          */
 /*          XXREC                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          OUTBLK                                                         */
 /*          OPR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          BLAB_BLOCK                                                     */
 /*          ERRORS                                                         */
 /*          PUSH_HALMAT                                                    */
 /*          QUICK_RELOCATE                                                 */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PUT_HALMAT_BLOCK <==                                                */
 /*     ==> BLAB_BLOCK                                                      */
 /*         ==> DECODEPIP                                                   */
 /*             ==> FORMAT                                                  */
 /*         ==> DECODEPOP                                                   */
 /*             ==> FORMAT                                                  */
 /*             ==> HEX                                                     */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /*     ==> PUSH_HALMAT                                                     */
 /*         ==> HEX                                                         */
 /*         ==> OPOP                                                        */
 /*         ==> VAC_OR_XPT                                                  */
 /*         ==> BUMP_D_N                                                    */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> ENTER                                                       */
 /*         ==> LAST_OP                                                     */
 /*         ==> NO_OPERANDS                                                 */
 /*         ==> MOVE_LIMB                                                   */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> RELOCATE                                                */
 /*             ==> MOVECODE                                                */
 /*                 ==> ENTER                                               */
 /*     ==> QUICK_RELOCATE                                                  */
 /*         ==> VAC_OR_XPT                                                  */
 /*         ==> RELOCATE                                                    */
 /*         ==> MOVECODE                                                    */
 /*             ==> ENTER                                                   */
 /*         ==> XHALMAT_QUAL                                                */
 /***************************************************************************/
                                                                                01598790
                                                                                01598800
                                                                                01598810
 /* ROUTINE TO WRITE HALMAT BLOCK FOR PHASE 2*/                                 01599000
PUT_HALMAT_BLOCK:                                                               01600000
   PROCEDURE;                                                                   01601000
      DECLARE I BIT(16);                                                        01602000
                                                                                01603000
PUT_BLOCK:                                                                      01604000
      PROCEDURE(START);                                                         01605000
         DECLARE START BIT(16);                                                 01606000
         FILE(CODE_OUTFILE,OUTBLK) = OPR(START);                                01607000
         IF HALMAT_BLAB THEN CALL BLAB_BLOCK(START);                            01608000
         OUTBLK = OUTBLK + 1;                                                   01609000
      END PUT_BLOCK;                                                            01610000
                                                                                01611000
                                                                                01612000
      IF XREC_PTR > BLOCK_END THEN DO;                                          01613000
         I = BLOCK_END - 2;                                                     01614000
         DO WHILE (OPR(I) & "FFF1") ^= XSMRK;                                   01615000
            I = I - 1;                                                          01616000
            IF I < 0 THEN CALL ERRORS (CLASS_BI, 310);                          01617000
         END;                                                                   01619000
         I = I + 2;   /* NEXT OPERATOR*/                                        01620000
         IF PUSH_HALMAT(I,BLOCK_END - I + 3,0,1) THEN DO;                       01621000
            OPR(BLOCK_PLUS_1 + 1) = SHL(XREC_PTR + TOTAL - BLOCK_PLUS_1,16)     01621010
               | IMD_0;                                                         01621020
            CALL QUICK_RELOCATE(XREC_PTR,1);  /* RECOVERS EXTNS*/               01621030
         END;                                                                   01621040
         ELSE OPR(BLOCK_PLUS_1 + 1) = SHL(XREC_PTR - BLOCK_PLUS_1,16) | IMD_0;  01621050
         CALL PUSH_HALMAT(BLOCK_PLUS_1,0,1);                                    01621060
         IF (OPR & "FFF1") = XPXRC THEN                                         01621070
            OPR(1) = IMD_0 | SHL(I,16);                                         01621080
         OPR(BLOCK_PLUS_1) = XPXRC | "1 0000";                                  01621090
         OPR(I) = XXREC | "8";      /* CSE TAG ON XREC FOLLOWED BY              01622000
                                          SPILLOVER BLOCK*/                     01622010
         CALL PUT_BLOCK(0);                                                     01623000
         CALL PUT_BLOCK(BLOCK_END + 1);                                         01624000
      END;                                                                      01625000
      ELSE CALL PUT_BLOCK(0);    /* NO CARRYOVER*/                              01626000
   END PUT_HALMAT_BLOCK;                                                        01627000
