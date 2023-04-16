 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   STMTTOPT.xpl
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
/* PROCEDURE NAME:  STMT_TO_PTR                                            */
/* MEMBER NAME:     STMTTOPT                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          FIXED                                                          */
/* INPUT PARAMETERS:                                                       */
/*          STMT              BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          OFFSET            FIXED                                        */
/*          PAGE              BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          BASE_STMT_OFFSET                                               */
/*          BAIL_OUT                                                       */
/*          BASE_STMT_PAGE                                                 */
/*          FIRST_STMT                                                     */
/*          LAST_STMT                                                      */
/*          PAGE_SIZE                                                      */
/*          SDFLIST_ERR                                                    */
/*          STMT_NODE_SIZE                                                 */
/*          X1                                                             */
/* CALLED BY:                                                              */
/*          DUMP_SDF                                                       */
/***************************************************************************/
                                                                                00146700
 /* MAPPING FUNCTION -- MAPS STATEMENT NUMBERS INTO SDF POINTERS */             00146800
                                                                                00146900
STMT_TO_PTR:                                                                    00147000
   PROCEDURE (STMT) FIXED;                                                      00147100
      DECLARE OFFSET FIXED,                                                     00147200
         (STMT,PAGE) BIT(16);                                                   00147300
      IF (STMT < FIRST_STMT) | (STMT > LAST_STMT) THEN DO;                      00147400
         OUTPUT = X1;                                                           00147500
         OUTPUT = SDFLIST_ERR || 'BAD STMT # (' ||                              00147600
            STMT || ') DETECTED BY STMT_TO_PTR ROUTINE ***';                    00147700
         GO TO BAIL_OUT;                                                        00147800
      END;                                                                      00147900
      OFFSET = (STMT - FIRST_STMT) * STMT_NODE_SIZE + BASE_STMT_OFFSET;         00148000
      PAGE = BASE_STMT_PAGE;                                                    00148100
      IF OFFSET >= PAGE_SIZE THEN DO;                                           00148200
         PAGE = PAGE + OFFSET/PAGE_SIZE;                                        00148300
         OFFSET = OFFSET MOD PAGE_SIZE;                                         00148400
      END;                                                                      00148500
      RETURN (SHL(PAGE,16) + OFFSET);                                           00148600
   END STMT_TO_PTR;                                                             00148700
