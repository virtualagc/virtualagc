 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   EMITPUSH.xpl
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
 /* PROCEDURE NAME:  EMIT_PUSH_DO                                           */
 /* MEMBER NAME:     EMITPUSH                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /*          Q                 BIT(16)                                      */
 /*          L                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          DO_LEVEL_LIM                                                   */
 /*          CLASS_BS                                                       */
 /*          FL_NO                                                          */
 /*          STMT_NUM                                                       */
 /*          XINL                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          COMM                                                           */
 /*          DO_CHAIN                                                       */
 /*          DO_INX                                                         */
 /*          DO_LEVEL                                                       */
 /*          DO_LOC                                                         */
 /*          DO_PARSE                                                       */
 /*          DO_STMT#                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          HALMAT_PIP                                                     */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> EMIT_PUSH_DO <==                                                    */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
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
 /***************************************************************************/
 /*     REVISION HISTORY :                                                  */
 /*     ------------------                                                  */
 /*    DATE   NAME  REL    DR NUMBER AND TITLE                              */
 /*                                                                         */
 /* 07/13/95  DAS  27V0  CR12416  IMPROVE COMPILER ERROR PROCESSING         */
 /*                11V0           (MAKE SEVERITY 3&4 ERRORS CAUSE ABORT)    */
 /*                                                                         */
 /***************************************************************************/
                                                                                00812000
EMIT_PUSH_DO:                                                                   00812100
   PROCEDURE (I,J,K,Q,L);                                                       00812200
      DECLARE (I,J,K,Q,L) BIT(16);                                              00812300
      IF DO_LEVEL=DO_LEVEL_LIM THEN DO;                                         00812400
         CALL ERROR(CLASS_BS,1); /* CR12416 */                                  00812500
         DO_LOC=DO_LOC+1;                                                       00812600
      END;                                                                      00812700
      ELSE DO;                                                                  00812800
         DO_LEVEL=DO_LEVEL+1;                                                   00812900
         DO_LOC(DO_LEVEL)=FL_NO;                                                00813000
         DO_INX(DO_LEVEL)=I;                                                    00813100
         DO_CHAIN(DO_LEVEL)=L;                                                  00813200
         DO_PARSE(DO_LEVEL)=Q;                                                  00813300
         DO_STMT#(DO_LEVEL) = STMT_NUM;                                         00813310
      END;                                                                      00813400
      CALL HALMAT_PIP(FL_NO,XINL,0,K);                                          00813500
      FL_NO=FL_NO+J;                                                            00813600
      L=0;                                                                      00813700
   END EMIT_PUSH_DO;                                                            00813800
