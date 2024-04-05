 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   IFORMAT.xpl
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
 /* PROCEDURE NAME:  I_FORMAT                                               */
 /* MEMBER NAME:     IFORMAT                                                */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          CHARACTER                                                      */
 /* INPUT PARAMETERS:                                                       */
 /*          NUMBER            FIXED                                        */
 /*          WIDTH             FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          L                 FIXED                                        */
 /*          STRING            CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          X256                                                           */
 /* CALLED BY:                                                              */
 /*          HALMAT_BLAB                                                    */
 /*          DUMPIT                                                         */
 /*          LIT_DUMP                                                       */
 /*          OUTPUT_WRITER                                                  */
 /*          SAVE_INPUT                                                     */
 /*          SYT_DUMP                                                       */
 /***************************************************************************/
                                                                                00273700
                                                                                00273800
I_FORMAT:                                                                       00273900
   PROCEDURE (NUMBER, WIDTH) CHARACTER;                                         00274000
      DECLARE (NUMBER, WIDTH, L) FIXED, STRING CHARACTER;                       00274100
                                                                                00274200
      STRING = NUMBER;                                                          00274300
      L = LENGTH(STRING);                                                       00274400
      IF L >= WIDTH THEN RETURN STRING;                                         00274500
      ELSE RETURN SUBSTR(X256, 0, WIDTH - L) || STRING;                         00274600
   END I_FORMAT;                                                                00274700
