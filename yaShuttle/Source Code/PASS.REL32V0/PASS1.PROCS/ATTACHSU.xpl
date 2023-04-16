 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ATTACHSU.xpl
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
 /* PROCEDURE NAME:  ATTACH_SUB_COMPONENT                                   */
 /* MEMBER NAME:     ATTACHSU                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          SUB#              BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          FIXING_BIT_AND_CHAR  LABEL                                     */
 /*          COMP_SLIP         LABEL                                        */
 /*          I                 BIT(16)                                      */
 /*          T1                BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FIX_DIM                                                        */
 /*          CLASS_SC                                                       */
 /*          INX                                                            */
 /*          MAT_TYPE                                                       */
 /*          MP                                                             */
 /*          NEXT_SUB                                                       */
 /*          PTR                                                            */
 /*          SCALAR_TYPE                                                    */
 /*          VAR                                                            */
 /*          VEC_TYPE                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          PSEUDO_TYPE                                                    */
 /*          PSEUDO_LENGTH                                                  */
 /*          VAL_P                                                          */
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
 /* ==> ATTACH_SUB_COMPONENT <==                                            */
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
 /*********************************************************************/
 /*                                                                   */
 /* REVISION HISTORY:                                                 */
 /*                                                                   */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                          */
 /*                                                                   */
 /* 05/14/01 TKN  31V0/ 111376   NO SR3 ERROR GENERATED FOR CHARACTER */
 /*               16V0           SHAPING FUNCTION                     */
 /*                                                                   */
 /* 04/28/05 JAC  32V0/ 120270   INCORRECT EA101 ERROR FOR SUBSCRIPTED*/
 /*               17V0           BIT ARGUMENT                         */
 /*********************************************************************/
                                                                                00942700
ATTACH_SUB_COMPONENT:                                                           00942800
   PROCEDURE(SUB#);                                                             00942900
      DECLARE SUB# BIT(16);                                                     00943000
      DECLARE (I,T1) BIT(16);                                                   00943100
      I=PTR(MP);                                                                00943200
      IF SUB#>0 THEN DO CASE PSEUDO_TYPE(I);                                    00943300
         ;                                                                      00943400
 /*  BIT  */                                                                    00943500
         DO;                                                                    00943600
            CALL REDUCE_SUBSCRIPT("0",PSEUDO_LENGTH(I));                        00943700
            PSEUDO_LENGTH(I)=FIX_DIM;                                           00943800
FIXING_BIT_AND_CHAR:                                                            00943900
            VAL_P(I)=VAL_P(I)|"10";                                             00944000
            SUB#=SUB#-1;                                                        00944100
            IF INX(NEXT_SUB)=0 & ^VAL_P(I) THEN  /*DR120270*/                   00944200
               VAL_P(I)=VAL_P(I)&"FFEF";                                        00944200
COMP_SLIP:                                                                      00944300
            VAL_P(I)=VAL_P(I)|"8";                                              00944400
            IF SUB#>0 THEN DO;                                                  00944500
               CALL ERROR(CLASS_SC,4,VAR(MP));                                  00944600
               CALL SLIP_SUBSCRIPT(SUB#);                                       00944700
            END;                                                                00944800
         END;                                                                   00944900
 /*  CHARACTER  */                                                              00945000
         DO;                                                                    00945100
            CALL REDUCE_SUBSCRIPT("0",PSEUDO_LENGTH(I),1); /*DR111376*/         00945200
            GO TO FIXING_BIT_AND_CHAR;                                          00945300
         END;                                                                   00945400
 /*  MATRIX  */                                                                 00945500
         DO;                                                                    00945600
            IF SUB#=1 THEN DO;                                                  00945700
               CALL ERROR(CLASS_SC,5,VAR(MP));                                  00945800
               CALL SLIP_SUBSCRIPT(SUB#);                                       00945900
            END;                                                                00946000
            ELSE DO;                                                            00946100
               CALL REDUCE_SUBSCRIPT("0",SHR(PSEUDO_LENGTH(I),8),2);            00946200
               T1=FIX_DIM;                                                      00946300
               CALL REDUCE_SUBSCRIPT("0",PSEUDO_LENGTH(I)&"FF",2);              00946400
               IF T1=1&FIX_DIM=1 THEN DO;                                       00946500
                  PSEUDO_TYPE(I) = SCALAR_TYPE;                                 00946510
                  PSEUDO_LENGTH(I) = 0;                                         00946520
               END;                                                             00946530
               ELSE IF T1=1|FIX_DIM=1 THEN DO;                                  00946600
                  PSEUDO_TYPE(I)=VEC_TYPE;                                      00946700
                  PSEUDO_LENGTH(I)=T1+FIX_DIM-1;                                00946800
               END;                                                             00946900
               ELSE PSEUDO_LENGTH(I)=SHL(T1,8)|FIX_DIM;                         00947000
               IF PSEUDO_TYPE(I)^=SCALAR_TYPE THEN VAL_P(I)=VAL_P(I)|"10";      00947100
               SUB#=SUB#-2;                                                     00947200
               GO TO COMP_SLIP;                                                 00947300
            END;                                                                00947400
         END;                                                                   00947500
 /*  VECTOR   */                                                                00947600
         DO;                                                                    00947700
            CALL REDUCE_SUBSCRIPT("0",PSEUDO_LENGTH(I),2);                      00947800
            PSEUDO_LENGTH(I)=FIX_DIM;                                           00947900
            IF FIX_DIM = 1 THEN DO;                                             00948000
               PSEUDO_TYPE(I) = SCALAR_TYPE;                                    00948010
               PSEUDO_LENGTH(I) = 0;                                            00948020
            END;                                                                00948030
            ELSE VAL_P(I)=VAL_P(I)|"10";                                        00948100
            SUB#=SUB#-1;                                                        00948200
            GO TO COMP_SLIP;                                                    00948300
         END;                                                                   00948400
      END;                                                                      00948500
      ELSE DO;                                                                  00948600
         IF PSEUDO_TYPE(I)=MAT_TYPE THEN SUB#=2;                                00948700
         ELSE SUB#=1;                                                           00948800
         CALL AST_STACKER("0",SUB#);                                            00948900
      END;                                                                      00949000
   END ATTACH_SUB_COMPONENT;                                                    00949100
