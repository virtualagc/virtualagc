 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PREPASS.xpl
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
 /* PROCEDURE NAME:  PREPASS                                                */
 /* MEMBER NAME:     PREPASS                                                */
 /* LOCAL DECLARATIONS:                                                     */
 /*          K                 BIT(16)                                      */
 /*          LAST              BIT(16)                                      */
 /*          N                 BIT(16)                                      */
 /*          OP                BIT(16)                                      */
 /*          PTR               BIT(16)                                      */
 /*          QUAL              BIT(16)                                      */
 /*          STOTAL            BIT(16)                                      */
 /*          TEMP              BIT(16)                                      */
 /*          VM                BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          DSUB                                                           */
 /*          FALSE                                                          */
 /*          FOR                                                            */
 /*          OPR                                                            */
 /*          OPTIMIZER_OFF                                                  */
 /*          OR                                                             */
 /*          SMRK                                                           */
 /*          TRUE                                                           */
 /*          TSUB                                                           */
 /*          XREC                                                           */
 /*          XSYT                                                           */
 /*          XVAC                                                           */
 /*          XXPT                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          D_N_INX                                                        */
 /*          TOTAL                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          BUMP_D_N                                                       */
 /*          LOOPY                                                          */
 /*          QUICK_RELOCATE                                                 */
 /*          XHALMAT_QUAL                                                   */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PREPASS <==                                                         */
 /*     ==> BUMP_D_N                                                        */
 /*     ==> XHALMAT_QUAL                                                    */
 /*     ==> QUICK_RELOCATE                                                  */
 /*         ==> VAC_OR_XPT                                                  */
 /*         ==> RELOCATE                                                    */
 /*         ==> MOVECODE                                                    */
 /*             ==> ENTER                                                   */
 /*         ==> XHALMAT_QUAL                                                */
 /*     ==> LOOPY                                                           */
 /*         ==> GET_CLASS                                                   */
 /*         ==> XHALMAT_QUAL                                                */
 /*         ==> ASSIGN_TYPE                                                 */
 /*         ==> NO_OPERANDS                                                 */
 /***************************************************************************/
                                                                                04229000
 /* LEAVES SPACE FOR PUSH HALMAT*/                                              04229010
PREPASS:                                                                        04229020
   PROCEDURE;                                                                   04229030
      DECLARE (PTR,N,STOTAL,OP,TEMP,K,QUAL,LAST) BIT(16),                       04229040
         VM BIT(8);                                                             04229050
      TOTAL,VM,STOTAL,PTR,D_N_INX = 0;                                          04229060
      IF OPTIMIZER_OFF THEN RETURN;                                             04229065
      OP = SHR(OPR,4) & "FFF";                                                  04229070
      N = SHR(OPR,16) & "FF";                                                   04229080
      DO WHILE OP ^= XREC;                                                      04229090
         IF OP = SMRK THEN DO;                                                  04229100
            IF VM THEN STOTAL = STOTAL + 3;                                     04229110
            IF STOTAL ^= 0 THEN DO;                                             04229120
               CALL BUMP_D_N(PTR,STOTAL);                                       04229130
               TOTAL = TOTAL + STOTAL;                                          04229140
               VM,STOTAL = 0;                                                   04229150
            END;                                                                04229160
         END;                                                                   04229170
                                                                                04229180
         ELSE IF LOOPY(PTR) THEN VM = TRUE;                                     04229190
                                                                                04229200
         ELSE IF OP = DSUB OR OP = TSUB THEN DO;                                04229210
            IF OP = TSUB THEN TEMP = 2;                                         04229212
            ELSE DO;                                                            04229214
               TEMP = 0;                                                        04229220
               DO FOR K = PTR + 2 TO PTR + N;                                   04229230
                  QUAL = XHALMAT_QUAL(K);                                       04229240
                  IF QUAL = XSYT OR QUAL = XVAC OR QUAL = XXPT THEN DO;         04229250
                     TEMP = TEMP + 1;                                           04229260
                     LAST = TRUE;                                               04229270
                  END;                                                          04229280
                  ELSE DO;                                                      04229290
                     LAST = FALSE;                                              04229300
                  END;                                                          04229310
               END;   /* DO FOR K*/                                             04229320
            END;                                                                04229323
            IF TEMP > 0 THEN DO;                                                04229330
               TEMP = (6 * TEMP) - 3;                                           04229340
               IF LAST THEN TEMP = TEMP - 2;                                    04229350
               ELSE TEMP = TEMP + 1;                                            04229360
               STOTAL = STOTAL + TEMP;                                          04229370
            END;                                                                04229380
         END;  /* DSUB*/                                                        04229390
                                                                                04229400
         PTR = PTR + N + 1;                                                     04229410
         DO WHILE OPR(PTR);                                                     04229420
            PTR = PTR + 1;                                                      04229430
         END;                                                                   04229440
                                                                                04229450
         OP = SHR(OPR(PTR),4) & "FFF";                                          04229460
         N = SHR(OPR(PTR),16) & "FF";                                           04229470
      END;  /* DO WHILE*/                                                       04229480
      CALL QUICK_RELOCATE(PTR);                                                 04229490
   END PREPASS;                                                                 04229500
