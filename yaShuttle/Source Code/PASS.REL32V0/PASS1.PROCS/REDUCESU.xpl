 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   REDUCESU.xpl
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
 /* PROCEDURE NAME:  REDUCE_SUBSCRIPT                                       */
 /* MEMBER NAME:     REDUCESU                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          MODE              BIT(16)                                      */
 /*          SIZE              BIT(16)                                      */
 /*          FLAG              BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          IND_LINK_SAVE     BIT(16)                                      */
 /*          SR_ERR1           LABEL                                        */
 /*          SR_ERR2           LABEL                                        */
 /*          STEPPER           LABEL                                        */
 /*          T1                BIT(16)                                      */
 /*          T2                BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          CLASS_SR                                                       */
 /*          MP                                                             */
 /*          PTR                                                            */
 /*          VAR                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          IND_LINK                                                       */
 /*          FIX_DIM                                                        */
 /*          INX                                                            */
 /*          NEXT_SUB                                                       */
 /*          PSEUDO_LENGTH                                                  */
 /*          VAL_P                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          CHECK_SUBSCRIPT                                                */
 /* CALLED BY:                                                              */
 /*          ATTACH_SUB_ARRAY                                               */
 /*          ATTACH_SUB_COMPONENT                                           */
 /*          ATTACH_SUB_STRUCTURE                                           */
 /*          END_ANY_FCN                                                    */
 /*          END_SUBBIT_FCN                                                 */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> REDUCE_SUBSCRIPT <==                                                */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> CHECK_SUBSCRIPT                                                 */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*         ==> MAKE_FIXED_LIT                                              */
 /*             ==> GET_LITERAL                                             */
 /*         ==> HALMAT_POP                                                  */
 /*             ==> HALMAT                                                  */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /*                 ==> HALMAT_OUT                                          */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*         ==> HALMAT_PIP                                                  */
 /*             ==> HALMAT                                                  */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /*                 ==> HALMAT_OUT                                          */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /***************************************************************************/
 /*********************************************************************/
 /*                                                                   */
 /* REVISION HISTORY:                                                 */
 /*                                                                   */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                          */
 /*                                                                   */
 /* 05/14/01 TKN  31V0/ 111376   NO SR3 ERROR GENERATED FOR CHARACTER */
 /*               16V0           SHAPING FUNCTION                     */
 /*********************************************************************/
                                                                                00932500
REDUCE_SUBSCRIPT:                                                               00932600
   PROCEDURE (MODE,SIZE,FLAG);                                                  00932700
      DECLARE (MODE,SIZE) BIT(16), FLAG BIT(1);                                 00932800
      DECLARE (T1,T2) BIT(16);                                                  00932900
      DECLARE IND_LINK_SAVE BIT(16);                                            00933000
      IND_LINK_SAVE=IND_LINK;                                                   00933100
                                                                                00933200
STEPPER:                                                                        00933300
      PROCEDURE;                                                                00933400
         NEXT_SUB=NEXT_SUB+1;                                                   00933500
         PSEUDO_LENGTH(IND_LINK),IND_LINK=NEXT_SUB;                             00933600
         IF INX(NEXT_SUB)^=1 THEN DO;                                           00933700
            IF MODE="8" THEN VAL_P(PTR(MP))=VAL_P(PTR(MP))|"2000";              00933800
            ELSE VAL_P(PTR(MP))=VAL_P(PTR(MP))|"10";                            00933900
         END;                                                                   00934000
         INX(NEXT_SUB)=INX(NEXT_SUB)|MODE;                                      00934100
         RETURN INX(NEXT_SUB)&"3";                                              00934200
      END STEPPER;                                                              00934300
                                                                                00934400
      DO CASE STEPPER;                                                          00934500
 /*  ASTERISK  */                                                               00934600
         FIX_DIM=SIZE;                                                          00934700
 /*  INDEX  */                                                                  00934800
         DO;                                                                    00934900
            CALL CHECK_SUBSCRIPT(MODE,SIZE,0);                                  00935000
            FIX_DIM=1;                                                          00935100
         END;                                                                   00935200
 /*  TO-PARTITION  */                                                           00935300
         DO;                                                                    00935400
            T1=CHECK_SUBSCRIPT(MODE,SIZE,0);                                    00935500
            VAL_P(NEXT_SUB)=1;                                                  00935600
            CALL STEPPER;                                                       00935700
            T2=CHECK_SUBSCRIPT(MODE,SIZE,0);                                    00935800
            IF ^FLAG THEN DO;                                                   00935900
               IF T1<0|T2<0 THEN DO;                                            00936000
SR_ERR1:                                                                        00936100
                  CALL ERROR(CLASS_SR,1,VAR(MP));                               00936200
                  FIX_DIM=2;                                                    00936300
               END;                                                             00936400
               ELSE IF T2=T1 THEN DO;                                           00936500
                  IF FLAG=2 THEN GO TO SR_ERR2;                                 00936600
                  FIX_DIM=1;                                                    00936700
                  IND_LINK=NEXT_SUB-1;                                          00936800
                  VAL_P(IND_LINK),PSEUDO_LENGTH(IND_LINK)=0;                    00936900
                  INX(IND_LINK)=MODE|"1";                                       00937000
               END;                                                             00937100
               ELSE IF T2<T1 THEN DO;                                           00937200
SR_ERR2:                                                                        00937300
                  CALL ERROR(CLASS_SR,2,VAR(MP));                               00937400
                  FIX_DIM=2;                                                    00937500
               END;                                                             00937600
               ELSE FIX_DIM=T2-T1+1;                                            00937700
            END;                                                                00937800
            ELSE IF (T2>0 & T2<T1) THEN GO TO SR_ERR2; /*DR111376*/
         END;                                                                   00937900
 /*  AT-PARTITION  */                                                           00938000
         DO;                                                                    00938100
            T1=CHECK_SUBSCRIPT(MODE,SIZE,1);                                    00938200
            VAL_P(NEXT_SUB)=1;                                                  00938300
            CALL STEPPER;                                                       00938400
            T2=CHECK_SUBSCRIPT(MODE,SIZE,0);                                    00938500
            IF ^FLAG THEN DO;                                                   00938600
               IF T1<0 THEN GO TO SR_ERR1;                                      00938700
               IF T2<0 THEN T2=T1;                                              00938800
               ELSE T2=T1+T2-1;                                                 00938900
               IF (T2>SIZE&SIZE>0)|T1=0 THEN GO TO SR_ERR2;                     00939000
               IF T1=1 THEN DO;                                                 00939100
                  IF FLAG=2 THEN GO TO SR_ERR2;                                 00939200
                  INX(NEXT_SUB)=MODE|"1";                                       00939300
                  PSEUDO_LENGTH(IND_LINK_SAVE)=NEXT_SUB;                        00939400
               END;                                                             00939500
               FIX_DIM=T1;                                                      00939600
            END;                                                                00939700
 /***DR111376 - GENERATE SR1 & SR2 ERRORS FOR CHARACTER VARIABLES******/
            ELSE DO;  /*FLAG=1*/
               IF T1<-1 THEN GO TO SR_ERR1;
               IF (T1>SIZE & SIZE>0) THEN GO TO SR_ERR2;
               ELSE T2=T1+T2-1;
               IF (T2>SIZE & SIZE>0) THEN GO TO SR_ERR2;
            END;
 /***DR111376**********************************************************/
         END;                                                                   00939800
      END;                                                                      00939900
      FLAG=FALSE;                                                               00940000
      VAL_P(NEXT_SUB)=0;                                                        00940100
   END REDUCE_SUBSCRIPT;                                                        00940200
