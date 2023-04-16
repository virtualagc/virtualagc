 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   DESCORE.xpl
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
 /* PROCEDURE NAME:  DESCORE                                                */
 /* MEMBER NAME:     DESCORE                                                */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          CHARACTER                                                      */
 /* INPUT PARAMETERS:                                                       */
 /*          CHAR              CHARACTER;                                   */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          X1                                                             */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          PAD                                                            */
 /* CALLED BY:                                                              */
 /*          EMIT_EXTERNAL                                                  */
 /*          STREAM                                                         */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> DESCORE <==                                                         */
 /*     ==> PAD                                                             */
 /***************************************************************************/
                                                                                00270300
DESCORE:                                                                        00270400
   PROCEDURE (CHAR) CHARACTER;                                                  00270500
      DECLARE CHAR CHARACTER, (I,J,K) BIT(16);                                  00270600
      CHAR=CHAR||X1;                                                            00270700
      I,J=1;                                                                    00270800
      DO WHILE I<LENGTH(CHAR);                                                  00270900
         IF BYTE(CHAR,I)^=BYTE('_') THEN DO;                                    00271000
            K=BYTE(CHAR,I);                                                     00271100
            BYTE(CHAR,J)=K;                                                     00271200
            J=J+1;                                                              00271300
         END;                                                                   00271400
         I=I+1;                                                                 00271500
      END;                                                                      00271600
      CHAR=SUBSTR(CHAR,0,J);                                                    00271700
      IF LENGTH(CHAR)>=6 THEN CHAR=SUBSTR(CHAR,0,6);                            00271800
      ELSE CHAR=PAD(CHAR,6);                                                    00271900
      RETURN '@@'||CHAR;                                                        00272000
   END DESCORE;                                                                 00272100
