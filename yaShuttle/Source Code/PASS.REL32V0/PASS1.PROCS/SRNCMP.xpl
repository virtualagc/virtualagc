 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SRNCMP.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

 /***************************************************************************/
 /* PROCEDURE NAME:  SRNCMP                                                 */
 /* MEMBER NAME:     SRNCMP                                                 */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          TEXT1             CHARACTER;                                   */
 /*          TEXT2             CHARACTER;                                   */
 /* LOCAL DECLARATIONS:                                                     */
 /*          BYTE1             BIT(16)                                      */
 /*          BYTE2             BIT(16)                                      */
 /*          I                 BIT(16)                                      */
 /*          LIMIT             MACRO                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          NO_MORE_SOURCE                                                 */
 /* CALLED BY:                                                              */
 /*          SOURCE_COMPARE                                                 */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 01/21/91 TKK  23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
 /*                                                                         */
 /***************************************************************************/
SRNCMP:                                                                         00289660
   PROCEDURE (TEXT1,TEXT2) BIT(16);                                             00289670
 /*SRNCMP COMPARES TWO INPUT TEXTS BYTE FOR BYTE FOR NUMERICAL*/                00289680
 /* ORDERING AND RETURNS THE FOLLOWING*/                                        00289690
 /*  0 IF 1=2  */                                                               00289700
 /*  1 IF 1<2  */                                                               00289710
 /*  2 IF 1>2  */                                                               00289720
      DECLARE (TEXT1,TEXT2) CHARACTER;                                          00289730
      DECLARE (BYTE1,BYTE2) BIT(16);                                            00289740
      DECLARE LIMIT LITERALLY '6';                                              00289745
      DECLARE I BIT(16);                                                        00289750
      IF NO_MORE_SOURCE THEN RETURN 2;                                          00289760
      DO I=1 TO LIMIT;                                                          00289775
         BYTE1=BYTE(TEXT1,I-1)-BYTE('0');                                       00289780
         BYTE2=BYTE(TEXT2,I-1)-BYTE('0');                                       00289790
         IF BYTE1<BYTE2 THEN RETURN 1;                                          00289800
         IF BYTE1>BYTE2 THEN RETURN 2;                                          00289810
      END;                                                                      00289820
      RETURN 0;                                                                 00289830
   END SRNCMP;                                                                  00289840
