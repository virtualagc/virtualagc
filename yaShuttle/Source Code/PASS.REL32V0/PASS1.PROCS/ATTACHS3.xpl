 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ATTACHS3.xpl
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
 /* PROCEDURE NAME:  ATTACH_SUB_STRUCTURE                                   */
 /* MEMBER NAME:     ATTACHS3                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          SUB#              BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          RCODE             BIT(8)                                       */
 /*          STRUC_SLIP        LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          CLASS_SC                                                       */
 /*          FIX_DIM                                                        */
 /*          FIXV                                                           */
 /*          MP                                                             */
 /*          PTR                                                            */
 /*          SYM_ARRAY                                                      */
 /*          SYM_TAB                                                        */
 /*          SYT_ARRAY                                                      */
 /*          TRUE                                                           */
 /*          VAR                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          INX                                                            */
 /*          VAL_P                                                          */
 /*          VAR_ARRAYNESS                                                  */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          AST_STACKER                                                    */
 /*          ERROR                                                          */
 /*          REDUCE_SUBSCRIPT                                               */
 /*          SLIP_SUBSCRIPT                                                 */
 /* CALLED BY:                                                              */
 /*          ATTACH_SUBSCRIPT                                               */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> ATTACH_SUB_STRUCTURE <==                                            */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> REDUCE_SUBSCRIPT                                                */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*         ==> CHECK_SUBSCRIPT                                             */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> MAKE_FIXED_LIT                                          */
 /*                 ==> GET_LITERAL                                         */
 /*             ==> HALMAT_POP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*             ==> HALMAT_PIP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*     ==> AST_STACKER                                                     */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*         ==> PUSH_INDIRECT                                               */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*     ==> SLIP_SUBSCRIPT                                                  */
 /***************************************************************************/
                                                                                00953000
ATTACH_SUB_STRUCTURE:                                                           00953100
   PROCEDURE (SUB#);                                                            00953200
      DECLARE SUB# BIT(16);                                                     00953300
      DECLARE RCODE BIT(8);                                                     00953400
      IF SUB#<0 THEN RETURN TRUE;                                               00953500
      RCODE=FALSE;                                                              00953600
      INX(INX)=INX(INX)-SUB#;                                                   00953700
      IF SYT_ARRAY(FIXV(MP))=0 THEN DO;                                         00953800
         RCODE=2;                                                               00953900
STRUC_SLIP:                                                                     00954000
         IF SUB#>0 THEN DO;                                                     00954100
            CALL ERROR(CLASS_SC,1,VAR(MP));                                     00954200
            CALL SLIP_SUBSCRIPT(SUB#);                                          00954300
         END;                                                                   00954400
      END;                                                                      00954500
      ELSE IF SUB#=0 THEN CALL AST_STACKER("8",1);                              00954600
      ELSE DO;                                                                  00954700
         CALL REDUCE_SUBSCRIPT("8",VAR_ARRAYNESS(1));                           00954800
         VAR_ARRAYNESS(1)=FIX_DIM;                                              00954900
         IF FIX_DIM=1 THEN VAL_P(PTR(MP))=VAL_P(PTR(MP))&"FFFD";                00955000
         SUB#=SUB#-1;                                                           00955100
         GO TO STRUC_SLIP;                                                      00955200
      END;                                                                      00955300
      RETURN RCODE;                                                             00955400
   END ATTACH_SUB_STRUCTURE;                                                    00955500
