 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   BLOCKTOP.xpl
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
/* PROCEDURE NAME:  BLOCK_TO_PTR                                           */
/* MEMBER NAME:     BLOCKTOP                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          FIXED                                                          */
/* INPUT PARAMETERS:                                                       */
/*          BLOCK             BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          OFFSET            FIXED                                        */
/*          PAGE              BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          #PROCS                                                         */
/*          BAIL_OUT                                                       */
/*          BASE_BLOCK_OFFSET                                              */
/*          BASE_BLOCK_PAGE                                                */
/*          BLOCK_NODE_SIZE                                                */
/*          PAGE_SIZE                                                      */
/*          SDFLIST_ERR                                                    */
/*          X1                                                             */
/* CALLED BY:                                                              */
/*          DUMP_SDF                                                       */
/***************************************************************************/
                                                                                00150900
 /* MAPPING FUNCTION -- MAPS BLOCK NUMBERS INTO SDF POINTERS */                 00151000
                                                                                00151100
BLOCK_TO_PTR:                                                                   00151200
   PROCEDURE (BLOCK) FIXED;                                                     00151300
      DECLARE  OFFSET FIXED,                                                    00151400
         (BLOCK,PAGE) BIT(16);                                                  00151500
      IF (BLOCK < 1) | (BLOCK > #PROCS) THEN DO;                                00151600
         OUTPUT = X1;                                                           00151700
         OUTPUT = SDFLIST_ERR || 'BAD BLOCK # (' ||                             00151800
            BLOCK || ') DETECTED BY BLOCK_TO_PTR ROUTINE ***';                  00151900
         GO TO BAIL_OUT;                                                        00152000
      END;                                                                      00152100
      OFFSET = (BLOCK - 1) * BLOCK_NODE_SIZE + BASE_BLOCK_OFFSET;               00152200
      PAGE = BASE_BLOCK_PAGE;                                                   00152300
      IF OFFSET >= PAGE_SIZE THEN DO;                                           00152400
         PAGE = PAGE + OFFSET/PAGE_SIZE;                                        00152500
         OFFSET = OFFSET MOD PAGE_SIZE;                                         00152600
      END;                                                                      00152700
      RETURN (SHL(PAGE,16) + OFFSET);                                           00152800
   END BLOCK_TO_PTR;                                                            00152900
