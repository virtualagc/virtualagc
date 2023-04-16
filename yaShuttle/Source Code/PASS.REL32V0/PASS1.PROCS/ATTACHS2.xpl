 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ATTACHS2.xpl
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
 /* PROCEDURE NAME:  ATTACH_SUB_ARRAY                                       */
 /* MEMBER NAME:     ATTACHS2                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          SUB#              BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          ARR_SLIP          LABEL                                        */
 /*          K                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          EXT_ARRAY                                                      */
 /*          CLASS_SC                                                       */
 /*          FALSE                                                          */
 /*          FIX_DIM                                                        */
 /*          FIXL                                                           */
 /*          MP                                                             */
 /*          PTR                                                            */
 /*          SYM_ARRAY                                                      */
 /*          SYM_TAB                                                        */
 /*          SYT_ARRAY                                                      */
 /*          TRUE                                                           */
 /*          VAR                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          INX                                                            */
 /*          TEMP                                                           */
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
 /* ==> ATTACH_SUB_ARRAY <==                                                */
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
                                                                                00949200
ATTACH_SUB_ARRAY:                                                               00949300
   PROCEDURE (SUB#);                                                            00949400
      DECLARE SUB# BIT(16);                                                     00949500
      DECLARE (K,I) BIT(16);                                                    00949600
      IF SUB#<0 THEN RETURN TRUE;                                               00949700
      I=PTR(MP);                                                                00949800
      INX(INX)=INX(INX)-SUB#;                                                   00949900
      IF SYT_ARRAY(FIXL(MP))<=0 THEN DO;                                        00950000
ARR_SLIP:                                                                       00950100
         IF SUB#>0 THEN DO;                                                     00950200
            CALL ERROR(CLASS_SC,2,VAR(MP));                                     00950300
            CALL SLIP_SUBSCRIPT(SUB#);                                          00950400
         END;                                                                   00950500
      END;                                                                      00950600
      ELSE DO;                                                                  00950700
         K=EXT_ARRAY(SYT_ARRAY(FIXL(MP)));                                      00950800
         IF SUB#=0 THEN CALL AST_STACKER("4",K);                                00950900
         ELSE IF SUB#<K THEN DO;                                                00951000
            CALL ERROR(CLASS_SC,3,VAR(MP));                                     00951100
            CALL SLIP_SUBSCRIPT(SUB#);                                          00951200
         END;                                                                   00951300
         ELSE DO;                                                               00951400
            VAL_P(I)=VAL_P(I)|"8";                                              00951500
            SUB#=SUB#-K;                                                        00951600
            TEMP=0;                                                             00951700
            DO K=VAR_ARRAYNESS-K+1 TO VAR_ARRAYNESS-SUB#;                       00951800
               CALL REDUCE_SUBSCRIPT("4",VAR_ARRAYNESS(K));                     00951900
               VAR_ARRAYNESS(K)=FIX_DIM;                                        00952000
               TEMP=TEMP|(FIX_DIM^=1);                                          00952100
            END;                                                                00952200
            IF TEMP=0 THEN VAL_P(I)=VAL_P(I)&"FFFE";                            00952300
            ELSE VAL_P(I)=VAL_P(I)|"10";                                        00952400
            GO TO ARR_SLIP;                                                     00952500
         END;                                                                   00952600
      END;                                                                      00952700
      RETURN FALSE;                                                             00952800
   END ATTACH_SUB_ARRAY;                                                        00952900
