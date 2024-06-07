 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FLAGNODE.xpl
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
 /* PROCEDURE NAME:  FLAG_NODE                                              */
 /* MEMBER NAME:     FLAGNODE                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          HALMAT_PTR        BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          A_INX             BIT(16)                                      */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FOR                                                            */
 /*          OPR                                                            */
 /*          OPTYPE                                                         */
 /*          PARITY                                                         */
 /*          PRTYEXP                                                        */
 /*          TRACE                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          A_PARITY                                                       */
 /*          ADD                                                            */
 /*          HALMAT_NODE_END                                                */
 /*          HALMAT_NODE_START                                              */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CLASSIFY                                                       */
 /*          HALMAT_FLAG                                                    */
 /*          NO_OPERANDS                                                    */
 /*          SET_FLAG                                                       */
 /*          TERMINAL                                                       */
 /* CALLED BY:                                                              */
 /*          COLLECT_MATCHES                                                */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> FLAG_NODE <==                                                       */
 /*     ==> NO_OPERANDS                                                     */
 /*     ==> HALMAT_FLAG                                                     */
 /*         ==> VAC_OR_XPT                                                  */
 /*     ==> CLASSIFY                                                        */
 /*         ==> PRINT_SENTENCE                                              */
 /*             ==> FORMAT                                                  */
 /*             ==> HEX                                                     */
 /*     ==> TERMINAL                                                        */
 /*         ==> VAC_OR_XPT                                                  */
 /*         ==> HALMAT_FLAG                                                 */
 /*             ==> VAC_OR_XPT                                              */
 /*         ==> CLASSIFY                                                    */
 /*             ==> PRINT_SENTENCE                                          */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /*     ==> SET_FLAG                                                        */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 03/15/91 DKB  23V2  CR11109  CLEANUP COMPILER SOURCE CODE               */
 /*                                                                         */
 /***************************************************************************/
                                                                                02818000
 /* FLAGS OPERATORS FOR THIS NODE; OMITS MATCHED OPERATORS (EXCEPT FIRST)*/     02819000
FLAG_NODE:                                                                      02820000
   PROCEDURE(HALMAT_PTR);                                                       02821000
      DECLARE TEMP BIT(16);                                                     02822000
      DECLARE (I,HALMAT_PTR,A_INX) BIT(16);                                     02824000
      IF TRACE THEN DO;                                                         02825000
         OUTPUT = 'FLAG_NODE: ' || HALMAT_PTR;                                  02826000
         OUTPUT = '';                                                           02827000
      END;                                                                      02828000
      A_INX = 1;                                                                02829000
      ADD(1) = HALMAT_PTR;                                                      02830000
      A_PARITY(1) = 0;                                                          02831000
      HALMAT_NODE_START = HALMAT_PTR;                                           02832000
      HALMAT_NODE_END = HALMAT_PTR + 2;                                         02833000
      DO WHILE A_INX > 0 ;                                                      02834000
         A_PARITY = A_PARITY(A_INX);                                            02835000
         TEMP = ADD(A_INX);                                                     02836000
         A_INX = A_INX - 1;                                                     02837000
         IF OPTYPE = CLASSIFY(TEMP,1) THEN DO;  /*SETS PARITY*/                 02838000
            IF TEMP < HALMAT_NODE_START THEN HALMAT_NODE_START = TEMP;          02839000
            IF TEMP = HALMAT_PTR | HALMAT_FLAG(TEMP) = 0 THEN DO;               02840000
               CALL SET_FLAG(TEMP);                                             02841000
               IF A_PARITY THEN CALL SET_FLAG(TEMP,2);                          02842000
               DO FOR I = 1 TO NO_OPERANDS(TEMP);                               02843000
                  IF ^TERMINAL(TEMP + I,1) THEN DO;                             02844000
                     A_INX = A_INX + 1;                                         02845000
                     ADD(A_INX) = SHR(OPR(TEMP+I),16);                          02846000
                     A_PARITY(A_INX) = PRTYEXP;                                 02847000
                  END; /* IF ^ TERMINAL */                                      02848000
                  ELSE IF PRTYEXP THEN CALL SET_FLAG(TEMP + I,2);               02849000
               END;                                                             02850000
            END;                                                                02851000
         END;                                                                   02852000
      END; /* DO WHILE*/                                                        02853000
   END FLAG_NODE;                                                               02854000
