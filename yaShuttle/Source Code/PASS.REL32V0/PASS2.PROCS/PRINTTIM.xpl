 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PRINTTIM.xpl
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
                                                                                00833000
 /* SUBROUTINE TO PRINT OUT THE TIME  */                                        00833500
PRINT_TIME:                                                                     00834000
   PROCEDURE (MESSAGE,T);                                                       00834500
      DECLARE MESSAGE CHARACTER,T FIXED;                                        00835000
      MESSAGE=MESSAGE||T/360000||COLON||T MOD 360000/6000||COLON||              00835500
         T MOD 6000/100||'.';                                                   00836000
      T=T MOD 100;                                                              00836500
      IF T < 10 THEN MESSAGE=MESSAGE||'0';                                      00837000
      OUTPUT=MESSAGE||T;                                                        00837500
   END PRINT_TIME;                                                              00838000
