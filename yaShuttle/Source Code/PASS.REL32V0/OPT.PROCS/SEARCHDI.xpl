 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SEARCHDI.xpl
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
 /* PROCEDURE NAME:  SEARCH_DIMENSION                                       */
 /* MEMBER NAME:     SEARCHDI                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          DSUB                                                           */
 /*          OPR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          LAST_OPERAND                                                   */
 /*          GET_LOOP_DIMENSION                                             */
 /*          OPOP                                                           */
 /*          XHALMAT_QUAL                                                   */
 /* CALLED BY:                                                              */
 /*          PUT_VM_INLINE                                                  */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SEARCH_DIMENSION <==                                                */
 /*     ==> OPOP                                                            */
 /*     ==> XHALMAT_QUAL                                                    */
 /*     ==> LAST_OPERAND                                                    */
 /*     ==> GET_LOOP_DIMENSION                                              */
 /*         ==> LAST_OPERAND                                                */
 /*         ==> SET_VAR                                                     */
 /*             ==> XHALMAT_QUAL                                            */
 /*             ==> LAST_OPERAND                                            */
 /*         ==> COMPUTE_DIM_CONSTANT                                        */
 /*             ==> SAVE_LITERAL                                            */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> GET_LITERAL                                         */
 /*             ==> TEMPLATE_LIT                                            */
 /*                 ==> STRUCTURE_COMPARE                                   */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> GENERATE_TEMPLATE_LIT                               */
 /*                     ==> SAVE_LITERAL                                    */
 /*                         ==> ERRORS                                      */
 /*                             ==> COMMON_ERRORS                           */
 /*                         ==> GET_LITERAL                                 */
 /*             ==> INT_TO_SCALAR                                           */
 /*                 ==> HEX                                                 */
 /*         ==> COMPUTE_DIMENSIONS                                          */
 /***************************************************************************/
                                                                                02373740
 /* TRIES TO FIND DIMENSION OF V/M OPERATION.  OPR(PTR) IS A V/M OPERAND*/      02373750
SEARCH_DIMENSION:                                                               02373760
   PROCEDURE(PTR);                                                              02373770
      DECLARE PTR BIT(16);                                                      02373780
      DO CASE SHR(XHALMAT_QUAL(PTR),4);                                         02373790
                                                                                02373800
         ;  /* 0 */                                                             02373810
                                                                                02373820
         CALL GET_LOOP_DIMENSION(PTR);   /* 1 = SYT*/                           02373830
                                                                                02373840
         ;  /* 2 = INL*/                                                        02373850
                                                                                02373860
         DO;     /* 3 = VAC */                                                  02373870
            PTR = SHR(OPR(PTR),16);                                             02373880
            IF OPOP(PTR) = DSUB THEN                                            02373890
               CALL GET_LOOP_DIMENSION(PTR,1);                                  02373900
         END;                                                                   02373910
                                                                                02373920
         CALL GET_LOOP_DIMENSION(LAST_OPERAND(SHR(OPR(PTR),16)));               02373930
 /* 4 = XPT*/                                                                   02373940
                                                                                02373950
         ;;;;;;;                                                                02373960
         END;                                                                   02373970
   END SEARCH_DIMENSION;                                                        02373980
