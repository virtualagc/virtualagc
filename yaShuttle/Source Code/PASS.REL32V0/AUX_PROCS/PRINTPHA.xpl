 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PRINTPHA.xpl
    Purpose:    Auxiliary functionality used by the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
/***************************************************************************/
/* PROCEDURE NAME:  PRINT_PHASE_HEADER                                     */
/* MEMBER NAME:     PRINTPHA                                               */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CLOSE                                                          */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          HEADER_ISSUED                                                  */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          PRINT_DATE_AND_TIME                                            */
/* CALLED BY:                                                              */
/*          ERRORS                                                         */
/*          PASS1                                                          */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> PRINT_PHASE_HEADER <==                                              */
/*     ==> PRINT_DATE_AND_TIME                                             */
/*         ==> PRINT_TIME                                                  */
/***************************************************************************/
                                                                                01150000
                                                                                01152000
 /* ROUTINE TO PRINT PHASE HEADER MESSAGE (CALLED ONLY IF 'NECESSARY') */       01154000
                                                                                01156000
PRINT_PHASE_HEADER:PROCEDURE;                                                   01158000
                                                                                01160000
      OUTPUT(1) = '1';                                                          01162000
      HEADER_ISSUED = 1;                                                        01164000
    CALL PRINT_DATE_AND_TIME(' HAL/S AUXILIARY HALMAT GENERATOR -- VERSION OF ',01166000
         DATE_OF_GENERATION, TIME_OF_GENERATION);                               01168000
      OUTPUT = '';                                                              01170000
      CALL PRINT_DATE_AND_TIME(' HAL/S AUXILIARY HALMAT GENERATOR ENTERED ',    01172000
         DATE, TIME);                                                           01174000
      OUTPUT = '';                                                              01176000
                                                                                01178000
      CLOSE PRINT_PHASE_HEADER;                                                 01180000
