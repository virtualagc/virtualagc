 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   HEX.xpl
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
 /* PROCEDURE NAME:  HEX                                                    */
 /* MEMBER NAME:     HEX                                                    */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          CHARACTER                                                      */
 /* INPUT PARAMETERS:                                                       */
 /*          NUM               FIXED                                        */
 /*          WIDTH             FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CHAR_TEMP         CHARACTER;                                   */
 /*          H_LOOP            LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          X256                                                           */
 /* CALLED BY:                                                              */
 /*          HALMAT_BLAB                                                    */
 /*          CALL_SCAN                                                      */
 /*          LIT_DUMP                                                       */
 /*          SCAN                                                           */
 /*          STREAM                                                         */
 /*          SYT_DUMP                                                       */
 /***************************************************************************/
                                                                                00272200
                                                                                00272300
HEX:                                                                            00272400
   PROCEDURE(NUM, WIDTH) CHARACTER;                                             00272500
      DECLARE (NUM, WIDTH) FIXED, CHAR_TEMP CHARACTER;                          00272600
                                                                                00272700
      CHAR_TEMP = '';                                                           00272800
H_LOOP:CHAR_TEMP = SUBSTR('0123456789ABCDEF', NUM & "F", 1) || CHAR_TEMP;       00272900
      NUM = SHR(NUM, 4);                                                        00273000
      IF NUM ^= 0 THEN GO TO H_LOOP;                                            00273100
      NUM = LENGTH(CHAR_TEMP);                                                  00273200
      IF NUM < WIDTH THEN                                                       00273300
         CHAR_TEMP = SUBSTR(X256, 0, WIDTH - NUM) || CHAR_TEMP;                 00273310
      WIDTH = 0;                                                                00273400
      RETURN CHAR_TEMP;                                                         00273500
   END;                                                                         00273600
