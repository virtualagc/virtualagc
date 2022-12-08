 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   STACKPTR.xpl
    Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
                generation process.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section 6.3.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  STACK_PTR                                              */
 /* MEMBER NAME:     STACKPTR                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               FIXED                                        */
 /*          LEVEL             BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CLASS_BI                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          EXP_VARS                                                       */
 /*          EXP_PTRS                                                       */
 /*          PTR_INX                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERRORS                                                         */
 /* CALLED BY:                                                              */
 /*          FORMAT_EXP_VARS_CELL                                           */
 /*          FORMAT_PF_INV_CELL                                             */
 /*          FORMAT_VAR_REF_CELL                                            */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> STACK_PTR <==                                                       */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /***************************************************************************/
                                                                                00274600
 /* ADDS VMEM CELL PTR TO STACK */                                              00274700
STACK_PTR:                                                                      00274800
   PROCEDURE (PTR,LEVEL);                                                       00274900
      DECLARE PTR FIXED, LEVEL BIT(16);                                         00275000
                                                                                00275100
      PTR_INX = PTR_INX + 1;                                                    00275200
      IF PTR_INX>400 THEN                                                       00275300
         CALL ERRORS (CLASS_BI, 219);                                           00275400
      EXP_PTRS(PTR_INX) = PTR;                                                  00275500
      EXP_VARS(PTR_INX) = LEVEL;                                                00275600
   END STACK_PTR;                                                               00275700
