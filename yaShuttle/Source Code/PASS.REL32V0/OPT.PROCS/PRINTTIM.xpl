 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PRINTTIM.xpl
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
                                                                                00826360
                                                                                00827000
                                                                                00828000
 /* SUBROUTINE TO PRINT OUT THE TIME  */                                        00829000
PRINT_TIME:                                                                     00830000
   PROCEDURE (MESSAGE,T);                                                       00831000
      DECLARE MESSAGE CHARACTER,T FIXED;                                        00832000
      MESSAGE=MESSAGE||T/360000||COLON||T MOD 360000/6000||COLON||              00833000
         T MOD 6000/100||'.';                                                   00834000
      T=T MOD 100;                                                              00835000
      IF T < 10 THEN MESSAGE=MESSAGE||'0';                                      00836000
      OUTPUT=MESSAGE||T;                                                        00837000
   END PRINT_TIME;                                                              00838000
