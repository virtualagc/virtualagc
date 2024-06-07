 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   EXTRACTV.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  EXTRACT_VAR                                            */
 /* MEMBER NAME:     EXTRACTV                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          AB_BITS           FIXED                                        */
 /*          EXITT             LABEL                                        */
 /*          I                 BIT(16)                                      */
 /*          REF               BIT(16)                                      */
 /*          TMP               FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ALPHA_BETA_MASK                                                */
 /*          DSUB_INX                                                       */
 /*          FOR                                                            */
 /*          IADD                                                           */
 /*          IMD_0                                                          */
 /*          OPERAND_TYPE                                                   */
 /*          SUB_TRACE                                                      */
 /*          XLIT                                                           */
 /*          XVAC                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          OPR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HEX                                                            */
 /*          OPOP                                                           */
 /*          XHALMAT_QUAL                                                   */
 /* CALLED BY:                                                              */
 /*          GENERATE_DSUB_COMPUTATION                                      */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> EXTRACT_VAR <==                                                     */
 /*     ==> HEX                                                             */
 /*     ==> OPOP                                                            */
 /*     ==> XHALMAT_QUAL                                                    */
 /***************************************************************************/
                                                                                02369380
                                                                                02369390
                                                                                02369400
 /* FIXES DSUB OPERAND BY REMOVING VARIABLE COMPUTATION AND                     02369410
      LEAVING ONLY CONSTANT.  PTR IS TO DSUB OPERAND.                           02369420
      RETURNS POINTER OPERAND.*/                                                02369430
EXTRACT_VAR:                                                                    02369440
   PROCEDURE;                                                                   02369450
      DECLARE (I,REF) BIT(16);                                                  02369460
      DECLARE AB_BITS FIXED;                                                    02369470
      DECLARE TMP FIXED;                                                        02369480
      AB_BITS = OPR(DSUB_INX) & ALPHA_BETA_MASK;                                02369490
      TMP = OPR(DSUB_INX) - AB_BITS;                                            02369500
      IF OPERAND_TYPE = XVAC THEN DO;                                           02369510
         REF = SHR(OPR(DSUB_INX),16);                                           02369520
         IF OPOP(REF) = IADD THEN                                               02369530
            DO FOR I = REF + 1 TO REF + 2;                                      02369540
                                                                                02369550
            IF XHALMAT_QUAL(I) = XLIT THEN DO;                                  02369560
               OPR(DSUB_INX) = OPR(I) | AB_BITS;  /* LIT REF TO DSUB OPERAND*/  02369570
               TMP = OPR(REF + REF + 3 - I);                                    02369580
               OPR(REF) = "2 000 0";    /* NOP*/                                02369590
               OPR(REF + 1),OPR(REF + 2) = 0;                                   02369600
               IF SUB_TRACE THEN                                                02369610
                  OUTPUT = '   NOP ' || REF || ' TO ' || REF + 2;               02369620
               GO TO EXITT;                                                     02369630
            END;                                                                02369640
         END;                                                                   02369650
      END;                                                                      02369660
      OPR(DSUB_INX) = IMD_0 | AB_BITS;                                          02369670
EXITT:                                                                          02369680
      IF SUB_TRACE THEN                                                         02369690
         OUTPUT = 'EXTRACT_VAR('||DSUB_INX||'):  '||HEX(TMP,8);                 02369700
      RETURN TMP;                                                               02369710
   END EXTRACT_VAR;                                                             02369720
