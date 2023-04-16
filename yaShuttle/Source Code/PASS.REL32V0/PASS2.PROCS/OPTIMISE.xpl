 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   OPTIMISE.xpl
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
/* PROCEDURE NAME:  OPTIMISE                                               */
/* MEMBER NAME:     OPTIMISE                                               */
/* INPUT PARAMETERS:                                                       */
/*          BLOCK_FLAG        BIT(8)                                       */
/* LOCAL DECLARATIONS:                                                     */
/*          FLAG_LOC          BIT(16)                                      */
/*          IFLAG             BIT(8)                                       */
/*          OPCOPT            BIT(16)                                      */
/*          OPDECODE(1201)    LABEL                                        */
/*          OPNUM             BIT(16)                                      */
/*          OPRTR             BIT(16)                                      */
/*          OPTAG             BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CLASS_B                                                        */
/*          CONST_ATOMS                                                    */
/*          FALSE                                                          */
/*          FOR_ATOMS                                                      */
/*          OPR                                                            */
/*          STMTNO                                                         */
/*          TRUE                                                           */
/*          XADLP                                                          */
/*          XIDEF                                                          */
/*          XREAD                                                          */
/*          XSMRK                                                          */
/*          XWRIT                                                          */
/*          XXREC                                                          */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          ASSEMBLER_CODE                                                 */
/*          BINARY_CODE                                                    */
/*          CTR                                                            */
/*          DIAGNOSTICS                                                    */
/*          HALMAT_REQUESTED                                               */
/*          LINE#                                                          */
/*          LITTRACE                                                       */
/*          LITTRACE2                                                      */
/*          NUMOP                                                          */
/*          READCTR                                                        */
/*          REGISTER_TRACE                                                 */
/*          RESET                                                          */
/*          SMRK_CTR                                                       */
/*          STACK_DUMP                                                     */
/*          SUBSCRIPT_TRACE                                                */
/*          VDLP_DETECTED                                                  */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          EMITC                                                          */
/*          ERRORS                                                         */
/*          POPCODE                                                        */
/*          POPNUM                                                         */
/*          POPTAG                                                         */
/* CALLED BY:                                                              */
/*          GENERATE                                                       */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> OPTIMISE <==                                                        */
/*     ==> POPCODE                                                         */
/*     ==> POPNUM                                                          */
/*     ==> POPTAG                                                          */
/*     ==> EMITC                                                           */
/*         ==> FORMAT                                                      */
/*         ==> HEX                                                         */
/*         ==> HEX_LOCCTR                                                  */
/*             ==> HEX                                                     */
/*         ==> GET_CODE                                                    */
/*     ==> ERRORS                                                          */
/*         ==> NEXTCODE                                                    */
/*             ==> DECODEPOP                                               */
/*                 ==> FORMAT                                              */
/*                 ==> HEX                                                 */
/*                 ==> POPCODE                                             */
/*                 ==> POPNUM                                              */
/*                 ==> POPTAG                                              */
/*             ==> AUX_SYNC                                                */
/*                 ==> GET_AUX                                             */
/*                 ==> AUX_LINE                                            */
/*                     ==> GET_AUX                                         */
/*                 ==> AUX_OP                                              */
/*                     ==> GET_AUX                                         */
/*         ==> RELEASETEMP                                                 */
/*             ==> SETUP_STACK                                             */
/*             ==> CLEAR_REGS                                              */
/*                 ==> SET_LINKREG                                         */
/*         ==> COMMON_ERRORS                                               */
/***************************************************************************/
 /*  REVISION HISTORY :                                                     */
 /*  ------------------                                                     */
 /*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */
 /*                                                                         */
 /*03/04/91 RAH   23V2  CR11109 CLEANUP OF COMPILER SOURCE CODE             */
 /*                                                                         */
 /*06/04/99 SMR   30V0  CR13079 ADD HAL/S INITIALIZATION DATA TO SDF        */
 /*               15V0                                                      */
 /***************************************************************************/
                                                                                01508500
 /* SUBROUTINE FOR OPTIMIZING A SENTENCE OF ABSTRACT CODE */                    01509000
OPTIMISE:                                                                       01509500
   PROCEDURE(BLOCK_FLAG);                                                       01510000
      DECLARE                                                                   01510500
         (OPRTR, OPNUM, OPTAG, OPCOPT) BIT(16),                                 01511000
         (BLOCK_FLAG, IFLAG) BIT(1),                                            01511500
         FLAG_LOC BIT(16);                                                      01512000
                                                                                01512500
                                                                                01513000
 /* INTERNAL SUBROUTINE TO QUICKLY DECODE OPCODES */                            01513500
OPDECODE:                                                                       01514000
      PROCEDURE(CTR);                                                           01514500
         DECLARE CTR BIT(16);                                                   01515000
         OPRTR = POPCODE(CTR);                                                   1515500
         OPNUM = POPNUM(CTR);                                                    1516000
         OPTAG = POPTAG(CTR);                                                    1516500
         OPCOPT = SHR(OPR(CTR), 1) & "7";                                       01517000
      END OPDECODE;                                                             01517500
                                                                                01518000
 /*  MAIN CODE FOR OPTIMIZATION SUBROUTINE  */                                  01518500
      RESET=CTR;                                                                01519000
      IF BLOCK_FLAG THEN SMRK_CTR = CTR;                                        01519500
      ELSE SMRK_CTR = CTR + NUMOP + 1;                                          01520000
      CALL OPDECODE(SMRK_CTR);                                                  01520500
      IFLAG, VDLP_DETECTED = FALSE;                                              1521500
      DO WHILE OPRTR^=XSMRK;                                                    01522000
         IF OPRTR=XXREC THEN RETURN;                                             1522100
         IF OPRTR = XIDEF THEN IFLAG = 1;                                       01522500
         ELSE IF OPRTR = XADLP THEN VDLP_DETECTED = SHR(OPR(SMRK_CTR+OPNUM),8);  1522600
         ELSE IF OPRTR >= XREAD & OPRTR <= XWRIT THEN READCTR = SMRK_CTR;       01523000
         SMRK_CTR=SMRK_CTR+OPNUM+1;                                             01523500
         CALL OPDECODE(SMRK_CTR);                                               01524000
      END;                                                                      01524500
      LINE# = SHR(OPR(SMRK_CTR+1), 16);                                         01525000
      CALL EMITC(STMTNO, LINE#);                                                01527500
      IF OPTAG > 0 THEN CALL ERRORS(CLASS_B,100);                               01528000
      FLAG_LOC = SHR(OPR(SMRK_CTR+1), 8) & "FF";                                01528500
      IF FLAG_LOC >= 200 THEN                                                   01529000
         IF FLAG_LOC <= 216 THEN                                                01529500
         DO CASE FLAG_LOC-200;                                                  01530000
         DIAGNOSTICS, HALMAT_REQUESTED, ASSEMBLER_CODE = FALSE;                 01530500
         DIAGNOSTICS, HALMAT_REQUESTED, ASSEMBLER_CODE = TRUE;                  01531000
         HALMAT_REQUESTED, ASSEMBLER_CODE = FALSE;                              01531500
         HALMAT_REQUESTED, ASSEMBLER_CODE = TRUE;                               01532000
         REGISTER_TRACE = ^REGISTER_TRACE;                                      01532500
         HALMAT_REQUESTED = ^HALMAT_REQUESTED;                                  01533000
         ASSEMBLER_CODE = ^ASSEMBLER_CODE;                                      01533500
         BINARY_CODE = ^BINARY_CODE;                                            01534000
         SUBSCRIPT_TRACE = ^SUBSCRIPT_TRACE;                                    01534500
         DIAGNOSTICS = ^DIAGNOSTICS;                                            01535000
         STACK_DUMP = ^STACK_DUMP;                                              01535100
         LITTRACE = ^LITTRACE;                                                  01535110
         LITTRACE2 = ^LITTRACE2;                                                01535120
      END;  /* CASE FLAG_LOC-200 */                                             01535500
      ELSE IF FLAG_LOC = 222 THEN CALL EXIT;                                    01536000
      ELSE IF FLAG_LOC = 254 THEN INITIAL_ON(0) = TRUE;   /*CR13079*/
      ELSE IF FLAG_LOC = 255 THEN INITIAL_ON(1) = TRUE;   /*CR13079*/
      IF ASSEMBLER_CODE THEN                                                     1536100
         OUTPUT = '*** HAL/S STATEMENT ' || LINE#;                               1536200
      CTR = RESET;                                                              01536500
      NUMOP = POPNUM(CTR);                                                       1537000
      LINE# = LINE# + IFLAG;                                                    01537500
   END OPTIMISE;                                                                01538000
