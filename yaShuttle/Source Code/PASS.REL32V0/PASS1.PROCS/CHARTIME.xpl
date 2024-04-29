 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHARTIME.xpl
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
 /* PROCEDURE NAME:  CHARTIME                                               */
 /* MEMBER NAME:     CHARTIME                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          CHARACTER                                                      */
 /* INPUT PARAMETERS:                                                       */
 /*          T                 FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          C                 CHARACTER;                                   */
 /*          COLON             CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          PERIOD                                                         */
 /* CALLED BY:                                                              */
 /*          PRINT_TIME                                                     */
 /*          INITIALIZATION                                                 */
 /***************************************************************************/
                                                                                00777700
CHARTIME:                                                                       00777800
   PROCEDURE(T) CHARACTER;                                                      00777900
      DECLARE T FIXED, C CHARACTER;                                             00778000
      DECLARE COLON CHARACTER INITIAL(':');                                     00778100
      C = T /360000;                                                            00778200
      C = C || COLON || T MOD 360000 / 6000 ||                                  00778300
         COLON || T MOD 6000 /100 || PERIOD;                                    00778400
      T = T MOD 100;  /* DECIMAL FRACTION */                                    00778500
      IF T < 10 THEN C = C || '0';                                              00778600
      RETURN C || T;                                                            00778700
   END CHARTIME;                                                                00778800
