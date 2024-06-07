 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   VMDETAG.xpl
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
 /* PROCEDURE NAME:  VM_DETAG                                               */
 /* MEMBER NAME:     VMDETAG                                                */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          DETAGGED          LABEL                                        */
 /*          INX               BIT(16)                                      */
 /*          INX2              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          C_TRACE                                                        */
 /*          ADLP                                                           */
 /*          FOR                                                            */
 /*          LOOP_END                                                       */
 /*          LOOP_HEAD                                                      */
 /*          TAG_BIT                                                        */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          OPR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          NO_OPERANDS                                                    */
 /*          LOOPY                                                          */
 /*          OPOP                                                           */
 /*          TERMINAL                                                       */
 /* CALLED BY:                                                              */
 /*          CHECK_VM_COMBINE                                               */
 /*          FINAL_PASS                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> VM_DETAG <==                                                        */
 /*     ==> OPOP                                                            */
 /*     ==> NO_OPERANDS                                                     */
 /*     ==> TERMINAL                                                        */
 /*         ==> VAC_OR_XPT                                                  */
 /*         ==> HALMAT_FLAG                                                 */
 /*             ==> VAC_OR_XPT                                              */
 /*         ==> CLASSIFY                                                    */
 /*             ==> PRINT_SENTENCE                                          */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /*     ==> LOOPY                                                           */
 /*         ==> GET_CLASS                                                   */
 /*         ==> XHALMAT_QUAL                                                */
 /*         ==> ASSIGN_TYPE                                                 */
 /*         ==> NO_OPERANDS                                                 */
 /***************************************************************************/
                                                                                01893010
 /* ROUTINES FOR LOOP MANGLING */                                               01893020
                                                                                01893030
                                                                                01893040
 /* REMOVES TAG_BIT FROM LOOPY OPS AFTER VM LOOPS ARE COMBINED */               01893050
VM_DETAG:                                                                       01893060
   PROCEDURE;                                                                   01893070
      DECLARE (INX,INX2,I) BIT(16);                                             01893080
      IF C_TRACE THEN OUTPUT= 'VM_DETAG: '||LOOP_HEAD||' TO '||LOOP_END;        01893090
      INX= LOOP_HEAD + NO_OPERANDS(LOOP_HEAD) +1;                               01893100
      DO WHILE INX ^= LOOP_END;                                                 01893110
         IF LOOPY(INX) & (OPR(INX) & TAG_BIT) ^= 0 THEN DO;                     01893120
            INX2 = INX + NO_OPERANDS(INX) +1;                                   01893130
            DO WHILE INX2 ^= LOOP_END;                                          01893140
               DO FOR I = INX2+1 TO INX2+NO_OPERANDS(INX2);                     01893150
                  IF ^TERMINAL(I) & SHR(OPR(I),16)=INX & ^SHR(OPR(I),3) THEN DO;01893160
                     OPR(INX) = OPR(INX) & ^TAG_BIT;                            01893170
                     IF C_TRACE THEN OUTPUT = 'DETAGGED: '||INX||' ,REF: '||I;  01893180
                     GO TO DETAGGED;                                            01893190
                  END;                                                          01893200
               END;                                                             01893210
               INX2 = INX2 + NO_OPERANDS(INX2) +1;                              01893220
            END;                                                                01893230
DETAGGED:                                                                       01893240
         END;                                                                   01893250
         ELSE IF OPOP(INX)=ADLP & SHR(OPR(INX+1),8) THEN RETURN;                01893255
         INX = INX + NO_OPERANDS(INX) +1;                                       01893260
      END;                                                                      01893270
   END VM_DETAG;                                                                01893280
