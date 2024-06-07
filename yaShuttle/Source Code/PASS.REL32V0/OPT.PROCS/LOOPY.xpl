 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   LOOPY.xpl
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
 /* PROCEDURE NAME:  LOOPY                                                  */
 /* MEMBER NAME:     LOOPY                                                  */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CLASS(9)          BIT(8)                                       */
 /*          MSUBCODE(7)       BIT(8)                                       */
 /*          TEMP              BIT(8)                                       */
 /*          VSUBCODE(7)       BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          OPR                                                            */
 /*          TRUE                                                           */
 /*          XLIT                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ASSIGN_TYPE                                                    */
 /*          GET_CLASS                                                      */
 /*          NO_OPERANDS                                                    */
 /*          XHALMAT_QUAL                                                   */
 /* CALLED BY:                                                              */
 /*          CHECK_ARRAYNESS                                                */
 /*          CHICKEN_OUT                                                    */
 /*          FINAL_PASS                                                     */
 /*          PREPASS                                                        */
 /*          PUT_VM_INLINE                                                  */
 /*          SETUP_REARRANGE                                                */
 /*          VM_DETAG                                                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> LOOPY <==                                                           */
 /*     ==> GET_CLASS                                                       */
 /*     ==> XHALMAT_QUAL                                                    */
 /*     ==> ASSIGN_TYPE                                                     */
 /*     ==> NO_OPERANDS                                                     */
 /***************************************************************************/
                                                                                01892380
                                                                                01892390
                                                                                01892410
 /* RETURNS TRUE IF OPR(PTR) IS VECTOR/MATRIX OP WHICH CAN BE DONE INLINE.      01892420
      FALSE FOR DSUBS. */                                                       01892430
                                                                                01892440
LOOPY:                                                                          01892450
   PROCEDURE(PTR);                                                              01892460
      DECLARE TEMP BIT(8);                                                      01892470
      DECLARE PTR BIT(16);                                                      01892480
      DECLARE CLASS(9)    BIT(8) INITIAL(0,0,0,1,2,0,3),                        01892490
         MSUBCODE(7) BIT(8) INITIAL(1,0,1,2,0,1),                               01892500
         VSUBCODE(7) BIT(8) INITIAL(1,0,1,0,2,1);                               01892510
                                                                                01892520
 /* MTOM AND VTOV NOW INCLUDED **************/                                  01892530
                                                                                01892540
      TEMP = SHR(OPR(PTR),9) & "7";                                             01892550
      DO CASE CLASS(GET_CLASS(PTR));                                            01892560
                                                                                01892570
         RETURN FALSE;                                                          01892580
                                                                                01892590
         TEMP = MSUBCODE(TEMP);   /* MATRIX */                                  01892600
                                                                                01892610
         TEMP = VSUBCODE(TEMP);   /* VECTOR */                                  01892620
                                                                                01892630
         DO;                         /* SCALAR */                               01892640
            IF ASSIGN_TYPE(PTR) THEN IF XHALMAT_QUAL(PTR + 1) = XLIT THEN       01892650
               RETURN NO_OPERANDS(PTR) = 2;                                     01892652
                                                                                01892654
            RETURN FALSE;                                                       01892660
         END;                                                                   01892670
                                                                                01892680
      END;                                                                      01892690
                                                                                01892700
      DO CASE TEMP;                                                             01892710
                                                                                01892720
         RETURN FALSE;                                                          01892730
                                                                                01892740
         RETURN TRUE;                                                           01892750
                                                                                01892760
         RETURN (SHR(OPR(PTR),4) & "F") < 8;   /* MMPR,VCRS */                  01892770
                                                                                01892780
         RETURN ^(SHR(OPR(PTR),4));      /* OLD MTOM AND VTOV */                01892790
                                                                                01892800
      END;                                                                      01892810
   END LOOPY;                                                                   01892820
