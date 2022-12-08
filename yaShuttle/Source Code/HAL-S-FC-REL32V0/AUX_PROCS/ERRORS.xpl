 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ERRORS.xpl
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
/* PROCEDURE NAME:  ERRORS                                                 */
/* MEMBER NAME:     ERRORS                                                 */
/* INPUT PARAMETERS:                                                       */
/*          CLASS             BIT(16)                                      */
/*          NUM               BIT(16)                                      */
/*          TEXT              CHARACTER;                                   */
/* LOCAL DECLARATIONS:                                                     */
/*          ERROR#            BIT(16)                                      */
/*          AST               CHARACTER;                                   */
/*          SEVERITY          BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          BUMMER                                                         */
/*          CLOSE                                                          */
/*          COMMA                                                          */
/*          CURR_HALMAT_BLOCK                                              */
/*          CURRENT_STMT                                                   */
/*          HALMAT_PTR                                                     */
/*          ON                                                             */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          COMMON_RETURN_CODE                                             */
/*          HEADER_ISSUED                                                  */
/*          MAX_SEVERITY                                                   */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          PRINT_PHASE_HEADER                                             */
/*          COMMON_ERRORS                                                  */
/* CALLED BY:                                                              */
/*          DECR_STACK_PTR                                                 */
/*          NEW_SYT_REF_FRAME                                              */
/*          NEW_VAC_REF_FRAME                                              */
/*          PASS1                                                          */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> ERRORS <==                                                          */
/*     ==> PRINT_PHASE_HEADER                                              */
/*         ==> PRINT_DATE_AND_TIME                                         */
/*             ==> PRINT_TIME                                              */
/*     ==> COMMON_ERRORS                                                   */
/***************************************************************************/
                                                                                01768000
/*******************************************************************************01770000
         E R R O R   R O U T I N E                                              01772000
*******************************************************************************/01774000
                                                                                01776000
   /* INCLUDE COMMON ROUTINES:      $%COMROUT  */                               01778000
   /* INCLUDE TABLE FOR DOWNGRADES: $%DWNTABLE */                               01778010
   /* INCLUDE DOWNGRADE SUMMARY:    $%DOWNSUM  */                               01778020
   /* INCLUDE COMMON DECLARES:      $%CERRDECL */                               01778030
   DECLARE MAX_SEVERITY BIT(16);                                                01778040
   DECLARE SEVERITY BIT(16);                                                    01778050
   /* INCLUDE COMMON_ERRORS:  $%CERRORS   */                                    01778060
ERRORS: PROCEDURE (CLASS, NUM, TEXT);                                           01778070
   DECLARE (CLASS, SEVERITY, ERROR#, NUM) BIT(16);                              01778080
   DECLARE TEXT CHARACTER;                                                      01778090
   DECLARE AST CHARACTER CONSTANT('***** ');                                    01778100
                                                                                01784000
   IF ^HEADER_ISSUED THEN DO;                                                   01786000
      CALL PRINT_PHASE_HEADER;                                                  01788000
      HEADER_ISSUED = ON;                                                       01790000
   END;                                                                         01792000
   OUTPUT = '';                                                                 01794000
   ERROR# = ERROR# + 1;                                                         01796000
   SEVERITY = COMMON_ERRORS (CLASS, NUM, TEXT, ERROR#, CURRENT_STMT);           01796010
   OUTPUT = AST || 'HALMAT LINE = ' || HALMAT_PTR || COMMA ||                   01796020
            ' HALMAT BLOCK = ' || CURR_HALMAT_BLOCK - 1 || AST;                 01796030
   IF SEVERITY > MAX_SEVERITY THEN                                              01796040
      MAX_SEVERITY = SEVERITY;                                                  01796050
   COMMON_RETURN_CODE = SHL(MAX_SEVERITY,2);                                    01796060
   IF SEVERITY > = 2 THEN GO TO BUMMER;                                         01796070
                                                                                01804000
CLOSE ERRORS;                                                                   01806000
