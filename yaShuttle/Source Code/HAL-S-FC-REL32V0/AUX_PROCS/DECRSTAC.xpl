 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   DECRSTAC.xpl
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
/* PROCEDURE NAME:  DECR_STACK_PTR                                         */
/* MEMBER NAME:     DECRSTAC                                               */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CLOSE                                                          */
/*          CLASS_BI                                                       */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          STACK_PTR                                                      */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          ERRORS                                                         */
/* CALLED BY:                                                              */
/*          PASS1                                                          */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> DECR_STACK_PTR <==                                                  */
/*     ==> ERRORS                                                          */
/*         ==> PRINT_PHASE_HEADER                                          */
/*             ==> PRINT_DATE_AND_TIME                                     */
/*                 ==> PRINT_TIME                                          */
/*         ==> COMMON_ERRORS                                               */
/***************************************************************************/
                                                                                02944000
                                                                                02946000
 /* ROUTINE TO DECREMENT AND CHECK STACK_PTR */                                 02948000
                                                                                02950000
DECR_STACK_PTR:PROCEDURE;                                                       02952000
                                                                                02954000
      STACK_PTR = STACK_PTR - 1;                                                02956000
      IF STACK_PTR < 0 THEN                                                     02958000
         CALL ERRORS (CLASS_BI, 402);                                           02960000
                                                                                02962000
      CLOSE DECR_STACK_PTR;                                                     02964000
