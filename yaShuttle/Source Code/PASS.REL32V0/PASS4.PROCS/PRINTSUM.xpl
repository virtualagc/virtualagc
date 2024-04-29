 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PRINTSUM.xpl
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
/* PROCEDURE NAME:  PRINTSUMMARY                                           */
/* MEMBER NAME:     PRINTSUM                                               */
/* LOCAL DECLARATIONS:                                                     */
/*          T                 FIXED                                        */
/*          I                 BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          SDFPKG_FCBAREA                                                 */
/*          SDFPKG_LOCATES                                                 */
/*          SDFPKG_NUMGETM                                                 */
/*          SDFPKG_PGAREA                                                  */
/*          SDFPKG_READS                                                   */
/*          SDFPKG_SLECTCNT                                                */
/*          SPACE_1                                                        */
/*          X1                                                             */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          CLOCK                                                          */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          PRINT_TIME                                                     */
/*          PRINT_DATE_AND_TIME                                            */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> PRINTSUMMARY <==                                                    */
/*     ==> PRINT_TIME                                                      */
/*         ==> CHARTIME                                                    */
/*     ==> PRINT_DATE_AND_TIME                                             */
/*         ==> CHARDATE                                                    */
/*         ==> PRINT_TIME                                                  */
/*             ==> CHARTIME                                                */
/***************************************************************************/
                                                                                00267200
PRINTSUMMARY:                                                                   00267300
   PROCEDURE;                                                                   00267400
      DECLARE T FIXED,                                                          00267500
         I BIT(16);                                                             00267600
                                                                                00267700
      OUTPUT(1) = '1';                                                          00267800
      T = TIME;                                                                 00267900
      CALL PRINT_DATE_AND_TIME('END OF SDFLIST ',DATE,T);                       00268000
      SPACE_1;                                                                  00268100
      OUTPUT = 'NUMBER OF SDFPKG LOCATES          = '|| SDFPKG_LOCATES;         00268200
      OUTPUT = 'NUMBER OF SDFPKG READS            = '|| SDFPKG_READS;           00268300
      OUTPUT = 'NUMBER OF SDFPKG SELECTS          = '|| SDFPKG_SLECTCNT;        00268400
      OUTPUT = 'NUMBER OF SDFPKG GETMAINS         = '|| SDFPKG_NUMGETM;         00268500
      OUTPUT = 'SDFPKG FCB AREA SIZE (BYTES)      = '|| SDFPKG_FCBAREA;         00268600
      OUTPUT = 'SDFPKG PAGING AREA SIZE (PAGES)   = '|| SDFPKG_PGAREA;          00268700
      OUTPUT = X1;                                                              00268800
                                                                                00268900
      OUTPUT = 'NUMBER OF MINOR COMPACTIFIES      = '|| COMPACTIFIES;           00269000
      OUTPUT = 'NUMBER OF MAJOR COMPACTIFIES      = '|| COMPACTIFIES(1);        00269100
      OUTPUT = 'NUMBER OF REALLOCATIONS           = '|| REALLOCATIONS;          00269150
      OUTPUT = X1;                                                              00269200
      DO I = 1 TO 2;                                                            00269300
         IF CLOCK(I) < CLOCK(I - 1) THEN CLOCK(I) = CLOCK(I) + 8640000;         00269400
      END;                                                                      00269500
      CALL PRINT_TIME('TOTAL CPU TIME IN SDFLIST              ',                00269600
         CLOCK(2) - CLOCK);                                                     00269700
      OUTPUT = X1;                                                              00269800
   END PRINTSUMMARY;                                                            00269900
