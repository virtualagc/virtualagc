 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETPFINV.xpl
    Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
                generation process.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section 6.3.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  GET_P_F_INV_CELL                                       */
 /* MEMBER NAME:     GETPFINV                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          FIXED                                                          */
 /* INPUT PARAMETERS:                                                       */
 /*          CTR               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          #HW               BIT(16)                                      */
 /*          #INPUT_PARMS      BIT(16)                                      */
 /*          #PARMS            BIT(16)                                      */
 /*          BLOCK_SYT#        BIT(16)                                      */
 /*          CELL              FIXED                                        */
 /*          FORMAL_PARM_CELL  FIXED                                        */
 /*          GET_ARG(755)      LABEL                                        */
 /*          J                 BIT(16)                                      */
 /*          NODE_F            FIXED                                        */
 /*          NODE_H            BIT(16)                                      */
 /*          PARM_END          BIT(16)                                      */
 /*          PARM_START        BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BLOCK#                                                         */
 /*          CLASS_BI                                                       */
 /*          DSUB                                                           */
 /*          FCAL                                                           */
 /*          IDEF                                                           */
 /*          IND_CALL_LAB                                                   */
 /*          MODF                                                           */
 /*          OPR                                                            */
 /*          PCAL                                                           */
 /*          PROC_TRACE                                                     */
 /*          RELS                                                           */
 /*          RESV                                                           */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_TYPE                                                       */
 /*          TSUB                                                           */
 /*          VAC                                                            */
 /*          VMEM_LOC_ADDR                                                  */
 /*          XXAR                                                           */
 /*          XXST                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CELLSIZE                                                       */
 /*          EXTN_LOC                                                       */
 /*          HALMAT_PTR                                                     */
 /*          OPCODE                                                         */
 /*          VMEM_H                                                         */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERRORS                                                         */
 /*          GET_CELL                                                       */
 /*          GET_EXP_VARS_CELL                                              */
 /*          GET_SYT_VPTR                                                   */
 /*          GET_VAR_REF_CELL                                               */
 /*          INDIRECT                                                       */
 /*          LOCATE                                                         */
 /*          NEXT_OP                                                        */
 /*          POPCODE                                                        */
 /*          PTR_LOCATE                                                     */
 /*          SEARCH_EXPRESSION                                              */
 /*          TYPE_BITS                                                      */
 /* CALLED BY:                                                              */
 /*          PROCESS_HALMAT                                                 */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> GET_P_F_INV_CELL <==                                                */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /*     ==> PTR_LOCATE                                                      */
 /*     ==> GET_CELL                                                        */
 /*     ==> LOCATE                                                          */
 /*     ==> POPCODE                                                         */
 /*     ==> TYPE_BITS                                                       */
 /*     ==> NEXT_OP                                                         */
 /*     ==> INDIRECT                                                        */
 /*     ==> GET_SYT_VPTR                                                    */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*     ==> GET_EXP_VARS_CELL                                               */
 /*         ==> GET_CELL                                                    */
 /*     ==> SEARCH_EXPRESSION                                               */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> POPCODE                                                     */
 /*         ==> TYPE_BITS                                                   */
 /*         ==> DECODEPOP                                                   */
 /*         ==> NEXT_OP                                                     */
 /*         ==> PROCESS_EXTN                                                */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> POPNUM                                                  */
 /*             ==> POPVAL                                                  */
 /*             ==> TYPE_BITS                                               */
 /*             ==> X_BITS                                                  */
 /*     ==> GET_VAR_REF_CELL                                                */
 /*         ==> PTR_LOCATE                                                  */
 /*         ==> GET_CELL                                                    */
 /*         ==> POPNUM                                                      */
 /*         ==> TYPE_BITS                                                   */
 /*         ==> X_BITS                                                      */
 /*         ==> PROCESS_EXTN                                                */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> POPNUM                                                  */
 /*             ==> POPVAL                                                  */
 /*             ==> TYPE_BITS                                               */
 /*             ==> X_BITS                                                  */
 /*         ==> GET_EXP_VARS_CELL                                           */
 /*             ==> GET_CELL                                                */
 /*         ==> SEARCH_EXPRESSION                                           */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> POPCODE                                                 */
 /*             ==> TYPE_BITS                                               */
 /*             ==> DECODEPOP                                               */
 /*             ==> NEXT_OP                                                 */
 /*             ==> PROCESS_EXTN                                            */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> POPNUM                                              */
 /*                 ==> POPVAL                                              */
 /*                 ==> TYPE_BITS                                           */
 /*                 ==> X_BITS                                              */
 /*         ==> INTEGER_LIT                                                 */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> GET_LITERAL                                             */
 /*             ==> INTEGERIZABLE                                           */
 /***************************************************************************/
 /***************************************************************************/
 /*  REVISION HISTORY :                                                     */
 /*  ------------------                                                     */
 /*   DATE   NAME   REL    DR NUMBER AND TITLE                              */
 /*                                                                         */
 /* 08/23/02 DCP   32V0/   CR13571   COMBINE PROCEDURE/FUNCTION PARAMETER   */
 /*                17V0              CHECKING                               */
 /***************************************************************************/
                                                                                00203400
 /* GETS A PROC/FUNC INVOCATION CELL */                                         00203500
GET_P_F_INV_CELL:                                                               00203600
   PROCEDURE (CTR) FIXED;                                                       00203700
      DECLARE (FORMAL_PARM_CELL,CELL) FIXED, (#HW,CTR) BIT(16),                 00203800
         (BLOCK_SYT#,#PARMS,#INPUT_PARMS,J,PARM_START,PARM_END) BIT(16);        00203900
      BASED NODE_H BIT(16), NODE_F FIXED;                                       00203901
                                                                                00204000
 /* PROCESSES A PARAMETER EXPRESSION */                                         00204100
GET_ARG:                                                                        00204200
      PROCEDURE (OPERAND) FIXED;                                                00204300
         DECLARE (OPERAND,REF) BIT(16), PTR FIXED;                              00204400
                                                                                00204500
         REF = SHR(OPR(OPERAND),16);                                            00204600
         DO CASE TYPE_BITS(OPERAND);                                            00204700
            ;                                /* 0 --     */                     00204800
            RETURN REF | "C0000000";         /* 1 -- SYT */                     00204900
            ;                                /* 2 -- INL */                     00205000
            DO;                              /* 3 -- VAC */                     00205100
               OPCODE = POPCODE(REF);                                           00205200
               IF OPCODE = TSUB | OPCODE = DSUB THEN DO;                        00205300
                  IF HALMAT_PTR(REF)^=0 THEN RETURN HALMAT_PTR(REF);            00205400
                  ELSE CALL ERRORS (CLASS_BI, 208, ' '||BLOCK#||':'||REF);      00205500
               END;                                                             00205700
               ELSE IF OPCODE=PCAL | OPCODE=FCAL | OPCODE=IDEF THEN DO;         00205800
                  IF HALMAT_PTR(REF)^=0 THEN                                    00205900
                     RETURN HALMAT_PTR(REF) | "40000000";                       00206000
                  ELSE CALL ERRORS (CLASS_BI, 209, ' '||BLOCK#||':'||REF);      00206100
               END;                                                             00206300
               ELSE DO;                                                         00206400
                  CALL SEARCH_EXPRESSION(OPERAND);                              00206500
                  PTR = GET_EXP_VARS_CELL;                                      00206501
                  IF PTR = 0 THEN RETURN 0;                                     00206502
                  ELSE RETURN PTR | "80000000";                                 00206600
               END;                                                             00206700
            END;                                                                00206800
            DO;                              /* 4 -- XPT */                     00206900
               IF HALMAT_PTR(REF)^= 0 THEN RETURN HALMAT_PTR(REF);              00207000
               ELSE IF TYPE_BITS(REF+1) = VAC THEN                              00207100
                  CALL ERRORS (CLASS_BI, 210, ' '||BLOCK#||':'||REF);           00207200
               ELSE DO;                                                         00207400
                  EXTN_LOC = REF;                                               00207500
                  RETURN GET_VAR_REF_CELL;                                      00207600
               END;                                                             00207700
            END;                                                                00207800
            ;;;;;;;                                                             00207900
            END;                                                                00208000
         RETURN 0;                                                              00208100
      END GET_ARG;                                                              00208200
                                                                                00208212
                                                                                00208300
      IF PROC_TRACE THEN OUTPUT='GET_P_F_INV_CELL('||BLOCK#||':'||CTR||')';     00208301
      BLOCK_SYT# = SHR(OPR(CTR + 1),16);                                        00208400
      IF POPCODE(CTR) = IDEF THEN DO;                                           00208500
         CELL = GET_CELL(8,ADDR(VMEM_H),MODF);                                  00208600
         VMEM_H(0) = 8;                                                         00208700
         VMEM_H(3) = BLOCK_SYT#;                                                00208800
         RETURN CELL | "40000000";                                              00208900
      END;                                                                      00208950
      IF SYT_TYPE(BLOCK_SYT#)=IND_CALL_LAB THEN                                 00208951
         BLOCK_SYT# = INDIRECT(BLOCK_SYT#);                                     00208952
      FORMAL_PARM_CELL = GET_SYT_VPTR(BLOCK_SYT#);                              00209100
      IF FORMAL_PARM_CELL = 0 THEN RETURN 0;                                    00209101
      CALL LOCATE(FORMAL_PARM_CELL,ADDR(NODE_H),RESV);                          00209200
      #PARMS = SHR(NODE_H(1),8);                                                00209300
      #INPUT_PARMS = NODE_H(1) & "FF";                                          00209400
      #HW = SHL(#PARMS,1) + #PARMS + 4;                                         00209500
      CELLSIZE = SHL(#HW,1);                                                    00209600
      CELL = GET_CELL(CELLSIZE,ADDR(VMEM_H),MODF);                              00209700
      COREWORD(ADDR(NODE_F)) = VMEM_LOC_ADDR;                                   00209701
      VMEM_H(0) = CELLSIZE;                                                     00209800
      VMEM_H(1) = #PARMS;                                                       00209900
      VMEM_H(2) = #INPUT_PARMS;                                                 00210000
      VMEM_H(3) = BLOCK_SYT#;                                                   00210100
      PARM_END = CTR;                                                           00210110
      CTR = HALMAT_PTR(CTR);                                                    00210120
      HALMAT_PTR(CTR) = PARM_END;                                               00210130
      IF #PARMS ^= 0 THEN DO;                                                   00210200
         PARM_START = #HW - #PARMS - 2;                                         00210300
         DO J = 2 TO #PARMS + 1;                                                00210400
            VMEM_H(PARM_START + J) = NODE_H(J);                                 00210500
         END;                                                                   00210600
         IF POPCODE(CTR) ^= XXST THEN DO;                                       00210900
            CALL ERRORS (CLASS_BI, 211, ' '||BLOCK#||':'||CTR);                 00211000
            RETURN 0;                                                           00211100
         END;                                                                   00211200
         CTR = NEXT_OP(CTR);                                                    00211300
         J = 0;                                                                 00211400
         DO WHILE CTR < PARM_END;                                               00211500
            IF POPCODE(CTR) = XXST THEN CTR = HALMAT_PTR(CTR);                  00211501
            ELSE IF POPCODE(CTR) = XXAR THEN DO;                                00211600
               J = J + 1;                                                       00211700
               NODE_F(J + 1) = GET_ARG(CTR + 1);                                00211900
            END;                                                                00212000
            CTR = NEXT_OP(CTR);                                                 00212100
         END;                                                                   00212200
      END;                                                                      00212500
      CALL PTR_LOCATE(FORMAL_PARM_CELL,RELS);                                   00212600
      RETURN CELL | "40000000";                                                 00212700
   END GET_P_F_INV_CELL;                                                        00212800
