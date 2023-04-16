 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PRINTTIM.xpl
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
 /* PROCEDURE NAME:  PRINT_TIME                                             */
 /* MEMBER NAME:     PRINTTIM                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          MESSAGE           CHARACTER;                                   */
 /*          T                 FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          COLON                                                          */
 /* CALLED BY:                                                              */
 /*          PRINT_DATE_AND_TIME                                            */
 /*          PRINTSUMMARY                                                   */
 /***************************************************************************/
                                                                                00140800
 /* SUBROUTINE TO PRINT OUT THE TIME  */                                        00140900
PRINT_TIME:                                                                     00141000
   PROCEDURE (MESSAGE,T);                                                       00141100
      DECLARE MESSAGE CHARACTER,T FIXED;                                        00141200
      MESSAGE=MESSAGE||T/360000||COLON||T MOD 360000/6000||COLON||              00141300
         T MOD 6000/100||'.';                                                   00141400
      T=T MOD 100;                                                              00141500
      IF T < 10 THEN MESSAGE=MESSAGE||'0';                                      00141600
      OUTPUT=MESSAGE||T;                                                        00141700
   END PRINT_TIME;                                                              00141800
