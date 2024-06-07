 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   OUTPUTLI.xpl
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
/* PROCEDURE NAME:  OUTPUT_LIST                                            */
/* MEMBER NAME:     OUTPUTLI                                               */
/* INPUT PARAMETERS:                                                       */
/*          LIST_ID           CHARACTER;                                   */
/*          LIST_HEAD         BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          LINE_ENTRY        BIT(16)                                      */
/*          MESSAGE           CHARACTER;                                   */
/*          PAD_CHARS         CHARACTER;                                   */
/*          WORK              BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          BLANK                                                          */
/*          CDR_CELL                                                       */
/*          CELL_CDR                                                       */
/*          CELL1                                                          */
/*          CELL1_FLAGS                                                    */
/*          CELL2                                                          */
/*          CELL2_FLAGS                                                    */
/*          CLOSE                                                          */
/*          C1                                                             */
/*          C1_FLAGS                                                       */
/*          C2                                                             */
/*          C2_FLAGS                                                       */
/*          EQUAL                                                          */
/*          FOR                                                            */
/*          LEFT_PAREN                                                     */
/*          LIST_STRUX                                                     */
/*          RIGHT_PAREN                                                    */
/*          TRUE                                                           */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          #RJUST                                                         */
/*          HEX                                                            */
/* CALLED BY:                                                              */
/*          PASS1                                                          */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> OUTPUT_LIST <==                                                     */
/*     ==> #RJUST                                                          */
/*     ==> HEX                                                             */
/***************************************************************************/
                                                                                01452000
                                                                                01454000
 /* ROUTINE TO OUTPUT A LINKED LIST IN 'READABLE FORM' */                       01456000
                                                                                01458000
OUTPUT_LIST:PROCEDURE(LIST_ID, LIST_HEAD);                                      01460000
                                                                                01462000
      DECLARE                                                                   01464000
         LIST_ID                        CHARACTER,                              01466000
         LIST_HEAD                      BIT(16),                                01468000
         WORK                           BIT(16),                                01470000
         LINE_ENTRY                     BIT(16),                                01472000
         PAD_CHARS                      CHARACTER INITIAL('  -->  '),           01474000
         MESSAGE                        CHARACTER;                              01476000
                                                                                01478000
   OUTPUT = LIST_ID || BLANK || LEFT_PAREN || LIST_HEAD || RIGHT_PAREN || EQUAL;01480000
      WORK = LIST_HEAD;                                                         01482000
                                                                                01484000
      DO WHILE TRUE;                                                            01486000
                                                                                01488000
         MESSAGE = '';                                                          01490000
                                                                                01492000
         DO FOR LINE_ENTRY = 1 TO 4;                                            01494000
                                                                                01496000
            IF WORK = 0 THEN DO;                                                01498000
               OUTPUT = MESSAGE || 0;                                           01500000
               RETURN;                                                          01502000
            END;                                                                01504000
                                                                                01506000
            MESSAGE =                                                           01508000
               MESSAGE ||                                                       01510000
               HEX(CELL1_FLAGS(WORK), 2) || BLANK ||                            01512000
               #RJUST(CELL1(WORK), 5) || BLANK ||                               01514000
               HEX(CELL2_FLAGS(WORK), 2) || BLANK ||                            01516000
               #RJUST(CELL2(WORK), 5) || BLANK ||                               01518000
               #RJUST(CDR_CELL(WORK), 5) ||                                     01520000
               PAD_CHARS;                                                       01522000
                                                                                01524000
            WORK = CDR_CELL(WORK);                                              01526000
                                                                                01528000
         END;                                                                   01530000
                                                                                01532000
         OUTPUT = MESSAGE;                                                      01534000
                                                                                01536000
      END;                                                                      01538000
                                                                                01540000
      CLOSE OUTPUT_LIST;                                                        01542000
