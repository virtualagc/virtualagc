 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ASTSTACK.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

 /***************************************************************************/
 /* PROCEDURE NAME:  AST_STACKER                                            */
 /* MEMBER NAME:     ASTSTACK                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          MODE              BIT(16)                                      */
 /*          NUM               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          MP                                                             */
 /*          CLASS_SS                                                       */
 /*          VAR                                                            */
 /*          XAST                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          INX                                                            */
 /*          IND_LINK                                                       */
 /*          LOC_P                                                          */
 /*          PSEUDO_FORM                                                    */
 /*          PSEUDO_LENGTH                                                  */
 /*          PSEUDO_TYPE                                                    */
 /*          VAL_P                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          PUSH_INDIRECT                                                  */
 /* CALLED BY:                                                              */
 /*          ATTACH_SUB_ARRAY                                               */
 /*          ATTACH_SUB_COMPONENT                                           */
 /*          ATTACH_SUB_STRUCTURE                                           */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> AST_STACKER <==                                                     */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> PUSH_INDIRECT                                                   */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /***************************************************************************/
                                                                                00940300
AST_STACKER:                                                                    00940400
   PROCEDURE (MODE,NUM);                                                        00940500
      DECLARE (MODE,NUM) BIT(16);                                               00940600
      DECLARE I BIT(16);                                                        00940700
      IF INX(INX)>0 THEN CALL ERROR(CLASS_SS,1,VAR(MP));                        00940800
      DO NUM=1 TO NUM;                                                          00940900
         I=PUSH_INDIRECT(1);                                                    00941000
         LOC_P(I),VAL_P(I)=0;                                                   00941100
         PSEUDO_TYPE(I)=0;                                                      00941200
         PSEUDO_FORM(I)=XAST;                                                   00941300
         INX(I)=MODE;                                                           00941400
         PSEUDO_LENGTH(IND_LINK),IND_LINK=I;                                    00941500
      END;                                                                      00941600
   END AST_STACKER;                                                             00941700
