 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHARTIME.xpl
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
/* PROCEDURE NAME:  CHARTIME                                               */
/* MEMBER NAME:     CHARTIME                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          CHARACTER                                                      */
/* INPUT PARAMETERS:                                                       */
/*          T                 FIXED                                        */
/* LOCAL DECLARATIONS:                                                     */
/*          C                 CHARACTER;                                   */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          COLON                                                          */
/* CALLED BY:                                                              */
/*          PRINT_TIME                                                     */
/*          INITIALIZE                                                     */
/***************************************************************************/
                                                                                00134900
CHARTIME:                                                                       00135000
   PROCEDURE (T) CHARACTER;                                                     00135100
      DECLARE C CHARACTER,T FIXED;                                              00135200
      C=T/360000||COLON||T MOD 360000/6000||COLON||                             00135300
         T MOD 6000/100||'.';                                                   00135400
      T=T MOD 100;                                                              00135500
      IF T < 10 THEN C=C||'0';                                                  00135600
      RETURN C||T;                                                              00135700
   END CHARTIME;                                                                00135800
