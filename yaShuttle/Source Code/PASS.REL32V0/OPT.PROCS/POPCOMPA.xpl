 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   POPCOMPA.xpl
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
 /* PROCEDURE NAME:  POP_COMPARE                                            */
 /* MEMBER NAME:     POPCOMPA                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR1              BIT(16)                                      */
 /*          PTR2              BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          K                 BIT(16)                                      */
 /*          V_MASK            FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          FOR                                                            */
 /*          OPR                                                            */
 /*          TRUE                                                           */
 /*          XSYT                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          XHALMAT_QUAL                                                   */
 /*          NO_OPERANDS                                                    */
 /* CALLED BY:                                                              */
 /*          BUMP_REF_OPS                                                   */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> POP_COMPARE <==                                                     */
 /*     ==> XHALMAT_QUAL                                                    */
 /*     ==> NO_OPERANDS                                                     */
 /***************************************************************************/
                                                                                01893380
                                                                                01893390
 /* COMPARES OPERANDS OF SYT OR XPT TYPE.  TRUE IF EQUAL */                     01893400
POP_COMPARE:                                                                    01893410
   PROCEDURE(PTR1,PTR2) BIT(8);                                                 01893420
      DECLARE (PTR1,PTR2,K) BIT(16);                                            01893430
      DECLARE V_MASK FIXED INITIAL("FFFF FFFB");                                01893440
      IF XHALMAT_QUAL(PTR1) = XSYT THEN                                         01893450
         RETURN (OPR(PTR1) & V_MASK) = (OPR(PTR2) & V_MASK);                    01893460
      IF XHALMAT_QUAL(PTR2) = XSYT THEN RETURN FALSE;                           01893470
                                                                                01893480
 /* BOTH XPT'S */                                                               01893490
      PTR1 = SHR(OPR(PTR1),16);   /* EXTN */                                    01893500
      PTR2 = SHR(OPR(PTR2),16);                                                 01893510
                                                                                01893520
      DO FOR K = 0 TO NO_OPERANDS(PTR1);                                        01893530
         IF (OPR(PTR1 + K) & V_MASK) ^= (OPR(PTR2 + K) & V_MASK) THEN           01893540
            RETURN FALSE;                                                       01893550
      END;                                                                      01893560
                                                                                01893570
      RETURN TRUE;                                                              01893580
   END POP_COMPARE;                                                             01893590
