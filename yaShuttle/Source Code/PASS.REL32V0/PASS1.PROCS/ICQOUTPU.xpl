 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ICQOUTPU.xpl
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
 /* PROCEDURE NAME:  ICQ_OUTPUT                                             */
 /* MEMBER NAME:     ICQOUTPU                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CT                FIXED                                        */
 /*          CT_LIT            BIT(16)                                      */
 /*          CT_LITPTR         BIT(16)                                      */
 /*          CT_OFFPTR         BIT(16)                                      */
 /*          EMIT_XINT         LABEL                                        */
 /*          K                 FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          IC_FORM                                                        */
 /*          IC_LEN                                                         */
 /*          IC_LOC                                                         */
 /*          IC_TYPE                                                        */
 /*          IC_VAL                                                         */
 /*          ICQ                                                            */
 /*          ID_LOC                                                         */
 /*          INX                                                            */
 /*          LAST_POP#                                                      */
 /*          MAJ_STRUC                                                      */
 /*          NEXT_ATOM#                                                     */
 /*          PSEUDO_LENGTH                                                  */
 /*          STRUC_PTR                                                      */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_TYPE                                                       */
 /*          XELRI                                                          */
 /*          XETRI                                                          */
 /*          XEXTN                                                          */
 /*          XIMD                                                           */
 /*          XLIT                                                           */
 /*          XOFF                                                           */
 /*          XSLRI                                                          */
 /*          XSTRI                                                          */
 /*          XSYT                                                           */
 /*          XXPT                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          GET_ICQ                                                        */
 /*          HALMAT_FIX_PIPTAGS                                             */
 /*          HALMAT_PIP                                                     */
 /*          HALMAT_POP                                                     */
 /*          ICQ_CHECK_TYPE                                                 */
 /* CALLED BY:                                                              */
 /*          HALMAT_INIT_CONST                                              */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> ICQ_OUTPUT <==                                                      */
 /*     ==> HALMAT_POP                                                      */
 /*         ==> HALMAT                                                      */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> HALMAT_BLAB                                             */
 /*                 ==> HEX                                                 */
 /*                 ==> I_FORMAT                                            */
 /*             ==> HALMAT_OUT                                              */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /*     ==> HALMAT_PIP                                                      */
 /*         ==> HALMAT                                                      */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> HALMAT_BLAB                                             */
 /*                 ==> HEX                                                 */
 /*                 ==> I_FORMAT                                            */
 /*             ==> HALMAT_OUT                                              */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /*     ==> HALMAT_FIX_PIPTAGS                                              */
 /*     ==> GET_ICQ                                                         */
 /*     ==> ICQ_CHECK_TYPE                                                  */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /***************************************************************************/
 /***************************************************************************/
 /*                                                                         */
 /*  DATE      DEV  REL     DR/CR     TITLE                                 */
 /*                                                                         */
 /*  02/02/01  DCP  31V0/   DR111375  NO DI8 ERROR GENERATED FOR ARRAYS     */
 /*                 16V0              OF SCALARS & INTEGERS                 */
 /*                                                                         */
 /***************************************************************************/
                                                                                01007100
ICQ_OUTPUT:                                                                     01007200
   PROCEDURE;                                                                   01007300
      DECLARE (CT,K) FIXED;                                                     01007400
      DECLARE CT_LIT BIT(16);                                                   01007500
      DECLARE (CT_OFFPTR, CT_LITPTR) BIT(16);                                   01007600
      IF SYT_TYPE(ID_LOC)=MAJ_STRUC THEN DO;                                    01007700
         CALL HALMAT_POP(XEXTN,2,0,0);                                          01007800
         CALL HALMAT_PIP(ID_LOC,XSYT,0,0);                                      01007900
         CALL HALMAT_PIP(STRUC_PTR,XSYT,0,0);                                   01008000
         CT=LAST_POP#;                                                          01008100
         K=XXPT;                                                                01008200
      END;                                                                      01008300
      ELSE DO;                                                                  01008400
         CT=ID_LOC;                                                             01008500
         K=XSYT;                                                                01008600
      END;                                                                      01008700
      CALL HALMAT_POP(XSTRI,1,0,0);                                             01008800
      CALL HALMAT_PIP(CT,K,0,0);                                                01008900
      CT=1;                                                                     01009000
      CT_LIT=0;                                                                 01009100
      DO WHILE CT<PSEUDO_LENGTH(ICQ);                                           01009200
         K=GET_ICQ(CT+INX(ICQ));                                                01009300
         CT=CT+1;                                                               01009400
         IF IC_FORM(K)=2 THEN DO;   /*  XINT  */                                01009500
            IF CT_LIT=0 THEN DO;                                                01009600
EMIT_XINT:                                                                      01009700
               CALL HALMAT_POP(ICQ_CHECK_TYPE(K,0),2,0,IC_TYPE(K));             01009800
               CALL HALMAT_PIP(IC_VAL(K),XOFF,0,0);                             01009900
               CALL HALMAT_PIP(IC_LOC(K),IC_LEN(K),0,0);                        01010000
               IF IC_LEN(K)=XLIT THEN DO;                                       01010100
                  CT_OFFPTR=IC_VAL(K);                                          01010200
                  CT_LITPTR=IC_LOC(K);                                          01010300
                  CT_LIT=1;                                                     01010400
               END;                                                             01010500
               ELSE CT_LIT=0;                                                   01010600
            END;                                                                01010700
            ELSE IF IC_LEN(K)^=XLIT|CT_LIT=255|(CT_OFFPTR+CT_LIT)^=IC_VAL(K)    01010800
               |(CT_LITPTR+CT_LIT)^=IC_LOC(K) THEN DO;                          01010900
               CALL HALMAT_FIX_PIPTAGS(NEXT_ATOM#-1,CT_LIT,0);                  01011000
               GO TO EMIT_XINT;                                                 01011100
            END;                                                                01011200
            ELSE DO;                             /*DR111375*/
              CALL ICQ_CHECK_TYPE(K,0);          /*DR111375*/
              CT_LIT=CT_LIT+1;                   /*DR111375*/                   01011300
            END;                                 /*DR111375*/
         END;                                                                   01011400
         ELSE DO;                                                               01011500
            IF CT_LIT>0 THEN DO;                                                01011600
               CALL HALMAT_FIX_PIPTAGS(NEXT_ATOM#-1,CT_LIT,0);                  01011700
               CT_LIT=0;                                                        01011800
            END;                                                                01011900
            IF IC_FORM(K)=1 THEN DO;  /*  SLRI  */                              01012000
               CALL HALMAT_POP(XSLRI,2,0,IC_VAL(K));                            01012100
               CALL HALMAT_PIP(IC_LOC(K),XIMD,0,0);                             01012200
               CALL HALMAT_PIP(IC_LEN(K),XIMD,0,0);                             01012300
            END;                                                                01012400
            ELSE CALL HALMAT_POP(XELRI,0,0,IC_VAL(K));  /* ELRI  */             01012500
         END;                                                                   01012600
      END;                                                                      01012700
      IF CT_LIT>0 THEN CALL HALMAT_FIX_PIPTAGS(NEXT_ATOM#-1,CT_LIT,0);          01012800
      CALL HALMAT_POP(XETRI,0,0,0);                                             01012900
   END ICQ_OUTPUT;                                                              01013000
