 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   TEMPLATE.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  TEMPLATE_LIT                                           */
 /* MEMBER NAME:     TEMPLATE                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          PTR               BIT(16)                                      */
 /*          RETT              LABEL                                        */
 /*          STK_PTR           BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          DSUB_LOC                                                       */
 /*          CLASS_BI                                                       */
 /*          FOR                                                            */
 /*          OPR                                                            */
 /*          REL                                                            */
 /*          SUB_TRACE                                                      */
 /*          SYM_LENGTH                                                     */
 /*          SYM_REL                                                        */
 /*          SYM_SHRINK                                                     */
 /*          SYM_TAB                                                        */
 /*          SYT_DIMS                                                       */
 /*          TEMPL#                                                         */
 /*          TEMPLATE_STACK_END                                             */
 /*          TMPLT                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          TEMPLATE_STACK                                                 */
 /*          STRUCT#                                                        */
 /*          TEMPLATE_STACK_START                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERRORS                                                         */
 /*          GENERATE_TEMPLATE_LIT                                          */
 /*          STRUCTURE_COMPARE                                              */
 /* CALLED BY:                                                              */
 /*          COMPUTE_DIM_CONSTANT                                           */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> TEMPLATE_LIT <==                                                    */
 /*     ==> STRUCTURE_COMPARE                                               */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /*     ==> GENERATE_TEMPLATE_LIT                                           */
 /*         ==> SAVE_LITERAL                                                */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> GET_LITERAL                                             */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 03/15/91 DKB  23V2  CR11109  CLEANUP COMPILER SOURCE CODE               */
 /*                                                                         */
 /***************************************************************************/
                                                                                00826100
 /* FINDS TEMPLATE MATCH WITH PTR AND RETURNS PTR TO LIT TABLE*/                00826110
TEMPLATE_LIT:                                                                   00826120
   PROCEDURE BIT(16);                                                           00826130
      DECLARE (PTR,STK_PTR) BIT(16);                                            00826140
      PTR = SYT_DIMS(SHR(OPR(DSUB_LOC + 1),16)); /* TEMPLATE # */               00826150
      IF REL(PTR) = 0 THEN                                                      00826160
         CALL ERRORS (CLASS_BI, 306);                                           00826163
      IF TEMPL#(REL(PTR)) = 0 THEN DO;  /* NOT PREVIOUSLY ENCOUNTERED*/         00826166
         DO FOR STK_PTR = TEMPLATE_STACK_START TO TEMPLATE_STACK_END;           00826180
            IF STRUCTURE_COMPARE(TEMPLATE_STACK(STK_PTR),PTR) THEN DO;          00826190
               TEMPL#(REL(PTR)) = TEMPL#(REL(TEMPLATE_STACK(STK_PTR)));         00826200
               GO TO RETT;                                                      00826210
            END;                                                                00826220
         END;                                                                   00826240
         IF TEMPLATE_STACK_START <= 0 THEN                                      00826250
            CALL ERRORS (CLASS_BI, 307);                                        00826260
         TEMPLATE_STACK_START = TEMPLATE_STACK_START - 1;                       00826270
         TEMPLATE_STACK(TEMPLATE_STACK_START) = PTR;                            00826280
         TEMPL#(REL(PTR)) = GENERATE_TEMPLATE_LIT(PTR);                         00826290
      END;                                                                      00826300
RETT:                                                                           00826310
      IF SUB_TRACE THEN                                                         00826320
         OUTPUT = 'TEMPLATE_LIT(' || PTR || ') = ' || TEMPL#(REL(PTR));         00826330
      RETURN TEMPL#(REL(PTR));                                                  00826340
   END TEMPLATE_LIT;                                                            00826350
