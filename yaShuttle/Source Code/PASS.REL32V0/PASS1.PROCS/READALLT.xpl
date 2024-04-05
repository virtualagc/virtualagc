 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   READALLT.xpl
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
 /* PROCEDURE NAME:  READ_ALL_TYPE                                          */
 /* MEMBER NAME:     READALLT                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          P                 BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CHAR_TYPE                                                      */
 /*          EVIL_FLAG                                                      */
 /*          FIXL                                                           */
 /*          FIXV                                                           */
 /*          FOREVER                                                        */
 /*          MAJ_STRUC                                                      */
 /*          PSEUDO_TYPE                                                    */
 /*          PTR                                                            */
 /*          SYM_FLAGS                                                      */
 /*          SYM_LENGTH                                                     */
 /*          SYM_LINK1                                                      */
 /*          SYM_LINK2                                                      */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_FLAGS                                                      */
 /*          SYT_LINK1                                                      */
 /*          SYT_LINK2                                                      */
 /*          SYT_TYPE                                                       */
 /*          VAR_LENGTH                                                     */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
                                                                                00835300
READ_ALL_TYPE:                                                                  00835400
   PROCEDURE (P) BIT(1);                                                        00835500
      DECLARE (P,I) BIT(16);                                                    00835600
      IF PSEUDO_TYPE(PTR(P))=MAJ_STRUC THEN DO;                                 00835700
         I=FIXL(P);                                                             00835800
         IF (SYT_FLAGS(VAR_LENGTH(FIXV(P)))&EVIL_FLAG)^=0 THEN RETURN 0;        00835900
         DO FOREVER;                                                            00836000
            DO WHILE SYT_LINK1(I)^=0;                                           00836100
               I=SYT_LINK1(I);                                                  00836200
            END;                                                                00836300
            IF SYT_TYPE(I)^=CHAR_TYPE THEN RETURN 1;                            00836400
            DO WHILE SYT_LINK2(I)<0;                                            00836500
               I=-SYT_LINK2(I);                                                 00836600
               IF I=FIXL(P) THEN RETURN 0;                                      00836700
            END;                                                                00836800
            I=SYT_LINK2(I);                                                     00836900
         END;                                                                   00837000
      END;                                                                      00837100
      ELSE RETURN PSEUDO_TYPE(PTR(P))^=CHAR_TYPE;                               00837200
   END;                                                                         00837300
