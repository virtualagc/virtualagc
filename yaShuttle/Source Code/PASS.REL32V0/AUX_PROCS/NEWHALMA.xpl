 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   NEWHALMA.xpl
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
/* PROCEDURE NAME:  NEW_HALMAT_BLOCK                                       */
/* MEMBER NAME:     NEWHALMA                                               */
/* INPUT PARAMETERS:                                                       */
/*          START             BIT(16)                                      */
/*          DO_PRINT          BIT(8)                                       */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CLOSE                                                          */
/*          HALMAT_FILE                                                    */
/*          ON                                                             */
/*          PRETTY_PRINT_REQUESTED                                         */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          CURR_HALMAT_BLOCK                                              */
/*          FIRST_PRINT                                                    */
/*          HALMAT                                                         */
/*          HALMAT_PTR                                                     */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          PRETTY_PRINT_MAT                                               */
/* CALLED BY:                                                              */
/*          PASS1                                                          */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> NEW_HALMAT_BLOCK <==                                                */
/*     ==> PRETTY_PRINT_MAT                                                */
/*         ==> FORMAT_HALMAT                                               */
/*             ==> #RJUST                                                  */
/*             ==> HEX                                                     */
/*         ==> FORMAT_AUXMAT                                               */
/*             ==> #RJUST                                                  */
/*             ==> HEX                                                     */
/***************************************************************************/
                                                                                01808000
/*******************************************************************************01810000
        R O U T I N E S   T O   H A N D L E   F I L E S                         01812000
*******************************************************************************/01814000
                                                                                01816000
                                                                                01818000
         /* SUBROUTINE TO GET A HALMAT BLOCK */                                 01820000
                                                                                01822000
NEW_HALMAT_BLOCK: PROCEDURE(START, DO_PRINT);                                   01824000
                                                                                01826000
   DECLARE START BIT(16), DO_PRINT BIT(1);                                      01828000
                                                                                01830000
   IF DO_PRINT & PRETTY_PRINT_REQUESTED THEN CALL PRETTY_PRINT_MAT;             01832000
   HALMAT(START) = FILE(HALMAT_FILE, CURR_HALMAT_BLOCK);                        01834000
   CURR_HALMAT_BLOCK = CURR_HALMAT_BLOCK + 1;                                   01836000
   HALMAT_PTR = START;                                                          01838000
   FIRST_PRINT = ON;                                                            01840000
                                                                                01842000
CLOSE NEW_HALMAT_BLOCK;                                                         01844000
