 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CSEWORDF.xpl
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
 /* PROCEDURE NAME:  CSE_WORD_FORMAT                                        */
 /* MEMBER NAME:     CSEWORDF                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          CHARACTER                                                      */
 /* INPUT PARAMETERS:                                                       */
 /*          WORD              FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          MSG               CHARACTER;                                   */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HEX                                                            */
 /* CALLED BY:                                                              */
 /*          ARRAYED_ELT                                                    */
 /*          COLLAPSE_LITERALS                                              */
 /*          CSE_MATCH_FOUND                                                */
 /*          CSE_TAB_DUMP                                                   */
 /*          GET_NODE                                                       */
 /*          INVAR                                                          */
 /*          SET_O_T_V                                                      */
 /*          SETUP_REVERSE_COMPARE                                          */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> CSE_WORD_FORMAT <==                                                 */
 /*     ==> HEX                                                             */
 /***************************************************************************/
                                                                                01404080
                                                                                01405000
 /* PUTS WORDS INTO READABLE CSE FORMAT TO BE PRINTED*/                         01406000
CSE_WORD_FORMAT:                                                                01407000
   PROCEDURE(WORD) CHARACTER;                                                   01408000
      DECLARE WORD FIXED;                                                       01409000
      DECLARE MSG CHARACTER;                                                    01410000
      IF (SHR(WORD,16) & "FF") = 0 THEN DO;    /* NODE TYPE*/                   01411000
         MSG = HEX(WORD,8);                                                     01412000
         RETURN '   '||MSG;                                                     01413000
      END;                                                                      01414000
      ELSE RETURN HEX(SHR(WORD,16),4)||' '||(WORD & "FFFF");                    01415000
   END CSE_WORD_FORMAT;                                                         01416000
