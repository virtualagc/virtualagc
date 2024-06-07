 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETUPREV.xpl
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
 /* PROCEDURE NAME:  SETUP_REVERSE_COMPARE                                  */
 /* MEMBER NAME:     SETUPREV                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CHANGE            BIT(16)                                      */
 /*          I                 BIT(16)                                      */
 /*          LITFLAG(1)        BIT(8)                                       */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          END_OF_NODE                                                    */
 /*          FALSE                                                          */
 /*          FOR                                                            */
 /*          LITERAL                                                        */
 /*          SEARCH                                                         */
 /*          SEARCH_INX                                                     */
 /*          SEARCH2                                                        */
 /*          TRACE                                                          */
 /*          TRUE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          SEARCH_REV                                                     */
 /*          SEARCH2_REV                                                    */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CSE_WORD_FORMAT                                                */
 /*          CONTROL                                                        */
 /* CALLED BY:                                                              */
 /*          CSE_MATCH_FOUND                                                */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SETUP_REVERSE_COMPARE <==                                           */
 /*     ==> CSE_WORD_FORMAT                                                 */
 /*         ==> HEX                                                         */
 /*     ==> CONTROL                                                         */
 /***************************************************************************/
                                                                                03252000
 /* SETS UP SEARCH_REV FOR REVERSE COMPARE*/                                    03253000
SETUP_REVERSE_COMPARE:                                                          03254000
   PROCEDURE BIT(8);                                                            03255000
      DECLARE (I,CHANGE,TEMP) BIT(16);                                          03256000
      DECLARE LITFLAG(1) BIT(8);                                                03257000
      IF TRACE THEN OUTPUT = 'SETUP_REVERSE_COMPARE';                           03258000
      CHANGE = 1;                                                               03259000
      DO WHILE (SEARCH(CHANGE) & "F0 0000") = 0;                                03260000
         CHANGE = CHANGE + 1;                                                   03261000
      END;                                                                      03262000
      DO FOR I = 0 TO 1;                                                        03263000
         LITFLAG(I) = (SEARCH(SEARCH_INX - 1 - I) & "EF 0000") = LITERAL;       03264000
      END;                                                                      03265000
      IF LITFLAG & LITFLAG(1) THEN RETURN FALSE;  /* ONLY WITH FAILED LIT       03266000
                                                       COLLAPSING*/             03267000
      TEMP = SEARCH_INX - CHANGE - LITFLAG;                                     03268000
      DO FOR I=1 TO CHANGE - 1;                                                 03269000
         SEARCH_REV(TEMP + I) = SEARCH(I) | "10 0000";                          03270000
         SEARCH2_REV(TEMP + I) = SEARCH2(I);                                    03271000
      END;                                                                      03272000
      DO FOR I = CHANGE TO SEARCH_INX - LITFLAG - 1;                            03273000
         SEARCH_REV(I - CHANGE + 1) = SEARCH(I) & "EF FFFF";                    03274000
         SEARCH2_REV(I - CHANGE + 1) = SEARCH2(I);                              03275000
      END;                                                                      03276000
      IF LITFLAG THEN DO;                                                       03277000
         SEARCH_REV(SEARCH_INX - 1) = LITERAL | (CONTROL(SEARCH(SEARCH_INX - 1))03278000
            + "10 0000") & "10 0000";                                           03279000
                                                                                03280000
         SEARCH2_REV(SEARCH_INX - 1) = SEARCH2(SEARCH_INX - 1);                 03281000
      END;                                                                      03282000
      SEARCH_REV(SEARCH_INX) = END_OF_NODE;                                     03283000
      SEARCH2_REV(SEARCH_INX) = 0;                                              03284000
      IF TRACE THEN DO FOR I = 1 TO SEARCH_INX;                                 03285000
         OUTPUT = CSE_WORD_FORMAT(SEARCH_REV(I)) || ' *** ' ||SEARCH2_REV(I);   03286000
      END;                                                                      03287000
      RETURN TRUE;                                                              03288000
   END SETUP_REVERSE_COMPARE;                                                   03289000
