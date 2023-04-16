 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SDFLOCAT.xpl
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
/* PROCEDURE NAME:  SDF_LOCATE                                             */
/* MEMBER NAME:     SDFLOCAT                                               */
/* INPUT PARAMETERS:                                                       */
/*          PTR               FIXED                                        */
/*          BVAR              FIXED                                        */
/*          FLAGS             BIT(8)                                       */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          LOC_ADDR                                                       */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          SDF_PTR_LOCATE                                                 */
/* CALLED BY:                                                              */
/*          PRINT_REPLACE_TEXT                                             */
/*          DUMP_SDF                                                       */
/*          PTR_TO_BLOCK                                                   */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> SDF_LOCATE <==                                                      */
/*     ==> SDF_PTR_LOCATE                                                  */
/***************************************************************************/
                                                                                00161000
 /* ROUTINE TO 'LOCATE' AN EXTERNAL SDF POINTER AND ASSIGN IT */                00161100
 /* TO A BASED VARIABLE                                       */                00161200
                                                                                00161300
SDF_LOCATE:                                                                     00161400
   PROCEDURE (PTR,BVAR,FLAGS);                                                  00161500
      DECLARE (PTR,BVAR) FIXED,                                                 00161600
         FLAGS BIT(8);                                                          00161700
                                                                                00161800
      CALL SDF_PTR_LOCATE(PTR,FLAGS);                                           00161900
      COREWORD(BVAR) = LOC_ADDR;                                                00162000
   END SDF_LOCATE;                                                              00162100
