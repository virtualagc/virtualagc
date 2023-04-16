 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PRINTTIM.xpl
    Purpose:    Auxiliary functionality used by the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.
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
/*          CLOSE                                                          */
/*          COLON                                                          */
/* CALLED BY:                                                              */
/*          PRINT_DATE_AND_TIME                                            */
/*          PRINT_SUMMARY                                                  */
/***************************************************************************/
                                                                                01066000
/*******************************************************************************01068000
        P R I N T I N G   R O U T I N E S                                       01070000
*******************************************************************************/01072000
                                                                                01074000
                                                                                01076000
         /* SUBROUTINE TO PRINT OUT THE TIME */                                 01078000
                                                                                01080000
PRINT_TIME: PROCEDURE(MESSAGE, T);                                              01082000
                                                                                01084000
   DECLARE MESSAGE CHARACTER, T FIXED;                                          01086000
   MESSAGE = MESSAGE || T / 360000 || COLON || T MOD 360000 / 6000 || COLON ||  01088000
      T MOD 6000 / 100 || '.';                                                  01090000
   T = T MOD 100;                                                               01092000
   IF T < 10 THEN MESSAGE = MESSAGE || '0';                                     01094000
   OUTPUT = MESSAGE || T;                                                       01096000
                                                                                01098000
CLOSE PRINT_TIME;                                                               01100000
