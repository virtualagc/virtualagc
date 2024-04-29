 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   EMITSUBS.xpl
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
 /* PROCEDURE NAME:  EMIT_SUBSCRIPT                                         */
 /* MEMBER NAME:     EMITSUBS                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          MODE              BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          INX                                                            */
 /*          LOC_P                                                          */
 /*          PSEUDO_FORM                                                    */
 /*          PSEUDO_TYPE                                                    */
 /*          VAL_P                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          PSEUDO_LENGTH                                                  */
 /*          IND_LINK                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HALMAT_PIP                                                     */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> EMIT_SUBSCRIPT <==                                                  */
 /*     ==> HALMAT_PIP                                                      */
 /*         ==> HALMAT                                                      */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> HALMAT_BLAB                                             */
 /*                 ==> HEX                                                 */
 /*                 ==> I_FORMAT                                            */
 /*             ==> HALMAT_OUT                                              */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /***************************************************************************/
                                                                                00962200
EMIT_SUBSCRIPT:                                                                 00962300
   PROCEDURE (MODE);                                                            00962400
      DECLARE MODE BIT(8),                                                      00962500
         I BIT(16),                                                             00962600
         J BIT(16);                                                             00962700
      J=1;                                                                      00962800
      I=PSEUDO_LENGTH;                                                          00962900
      DO WHILE INX(I)>=MODE;                                                    00963000
         IF PSEUDO_TYPE(I)^=0 THEN DO;                                          00963100
            CALL HALMAT_PIP(SHR(PSEUDO_TYPE(I),4),PSEUDO_TYPE(I)&"F",           00963200
               INX(I),VAL_P(I));                                                00963300
            CALL HALMAT_PIP(LOC_P(I),PSEUDO_FORM(I),0,0);                       00963400
            J=J+1;                                                              00963500
         END;                                                                   00963600
         ELSE CALL HALMAT_PIP(LOC_P(I),PSEUDO_FORM(I),INX(I),VAL_P(I));         00963700
         J=J+1;                                                                 00963800
         IF I=IND_LINK THEN  DO;                                                00963900
            IND_LINK=0;                                                         00964000
            RETURN J;                                                           00964100
         END;                                                                   00964200
         I=PSEUDO_LENGTH(I);                                                    00964300
      END;                                                                      00964400
      PSEUDO_LENGTH=I;                                                          00964500
      RETURN J;                                                                 00964600
   END EMIT_SUBSCRIPT;                                                          00964700
