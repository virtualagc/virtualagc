 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CLASSIFY.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  CLASSIFY                                               */
 /* MEMBER NAME:     CLASSIFY                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /*          SET_P             BIT(8)                                       */
 /*          FIX_SPECIALS      BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CHECK_TRANSPOSE   LABEL                                        */
 /*          CONVERSION_FORMAT LABEL                                        */
 /*          LIT_CONVERSION    LABEL                                        */
 /*          OP                BIT(16)                                      */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BFNC                                                           */
 /*          BTOI                                                           */
 /*          BTOS                                                           */
 /*          FALSE                                                          */
 /*          IADD                                                           */
 /*          ISUB                                                           */
 /*          LIT                                                            */
 /*          MADD                                                           */
 /*          MSUB                                                           */
 /*          MTOM                                                           */
 /*          MTRA                                                           */
 /*          MVPR                                                           */
 /*          OK                                                             */
 /*          SADD                                                           */
 /*          SSDV                                                           */
 /*          SSPR                                                           */
 /*          SSUB                                                           */
 /*          STATISTICS                                                     */
 /*          STT#                                                           */
 /*          VAC                                                            */
 /*          VADD                                                           */
 /*          VSUB                                                           */
 /*          VTOV                                                           */
 /*          WATCH                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          BFNC_OK                                                        */
 /*          OPR                                                            */
 /*          PARITY                                                         */
 /*          TRANSPOSE_ELIMINATIONS                                         */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          PRINT_SENTENCE                                                 */
 /* CALLED BY:                                                              */
 /*          FLAG_NODE                                                      */
 /*          GROW_TREE                                                      */
 /*          PUT_NOP                                                        */
 /*          SETUP_REARRANGE                                                */
 /*          TAG_CONDITIONALS                                               */
 /*          TERMINAL                                                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> CLASSIFY <==                                                        */
 /*     ==> PRINT_SENTENCE                                                  */
 /*         ==> FORMAT                                                      */
 /*         ==> HEX                                                         */
 /***************************************************************************/
                                                                                01801000
 /* CLASSIFY OPERATOR*/                                                         01802000
CLASSIFY:                                                                       01803000
   PROCEDURE(PTR,SET_P,FIX_SPECIALS) BIT(16);                                   01804000
      DECLARE (OP,PTR,TEMP) BIT(16),                                            01805000
         (SET_P,FIX_SPECIALS) BIT(8);                                           01806000
                                                                                01807000
 /* CHANGES M**T V TO V M AND V M**T TO M V*/                                   01808000
CHECK_TRANSPOSE:                                                                01809000
      PROCEDURE;                                                                01810000
         DECLARE (VECTOR_ARG,MATRIX_ARG,MATRIX_PTR) BIT(16);                    01811000
         MATRIX_ARG = PTR + TEMP - MVPR + 1;                                    01812000
         IF (SHR(OPR(MATRIX_ARG),4) & "F") = VAC THEN DO;                       01813000
            MATRIX_PTR = SHR(OPR(MATRIX_ARG),16);                               01814000
            IF (SHR(OPR(MATRIX_PTR),4) & "FFF") = MTRA THEN DO;                 01815000
               OPR(PTR) = (OPR(PTR) + "10") & "FFFF FFDF";                      01816000
 /* CHANGE MVPR <=> VMPR*/                                                      01817000
               VECTOR_ARG = PTR + MVPR - TEMP + 2;                              01818000
               OPR(MATRIX_ARG) = OPR(VECTOR_ARG);                               01819000
               OPR(VECTOR_ARG) = OPR(MATRIX_PTR + 1);                           01820000
               OPR(MATRIX_PTR) = OPR(MATRIX_PTR) & "FF 0000";  /* NOP*/         01821000
               OPR(MATRIX_PTR + 1) = 0;                                         01822000
               OP,TEMP = SHR(OPR(PTR),4) & "FFF";                               01823000
               IF WATCH THEN CALL PRINT_SENTENCE(MATRIX_PTR);                   01824000
               TRANSPOSE_ELIMINATIONS = TRANSPOSE_ELIMINATIONS + 1;             01825000
               IF STATISTICS THEN OUTPUT =                                      01826000
                  'MATRIX TRANSPOSE ELIMINATION FOUND IN HAL/S STATEMENT ' ||   01827000
                  STT#;                                                         01828000
            END;                                                                01829000
         END;                                                                   01830000
      END CHECK_TRANSPOSE;                                                      01831000
                                                                                01832000
                                                                                01833000
 /* CHECKS TO SEE IF OPERAND OF CONVERSION IS A LITERAL*/                       01834000
LIT_CONVERSION:                                                                 01835000
      PROCEDURE BIT(8);                                                         01836000
         RETURN (SHR(OPR(PTR + 1),4) & "F") = LIT;                              01837000
      END LIT_CONVERSION;                                                       01838000
                                                                                01839000
 /* PLACE PRECISION AT LEFT OF CONVERSION OPCODE*/                              01840000
CONVERSION_FORMAT:                                                              01841000
      PROCEDURE BIT(16);                                                        01842000
         RETURN TEMP | (SHR(OPR(PTR),12) & "F000");                             01843000
      END CONVERSION_FORMAT;                                                    01844000
                                                                                01845000
      BFNC_OK = FALSE;                                                          01846000
      OP,TEMP = SHR(OPR(PTR),4) & "FFF";                                        01847000
      DO CASE SHR(OP,8);                                                        01848000
         DO;       /* CLASS 0*/                                                 01849000
            IF TEMP = BFNC THEN DO;    /* OR IN 'M' */                          01850000
               TEMP = "F00" | SHR(OPR(PTR),24) ;                                01851000
                                                                                01852000
 /* BFNC IS REPRESENTED INTERNALLY BY CLASS F OPCODES*/                         01853000
                                                                                01854000
               BFNC_OK = OK(SHR(OPR(PTR),24));                                  01855000
            END;                                                                01856000
         END;                                                                   01857000
         IF TEMP > "105" THEN     /* CLASS1 = BIT*/                             01858000
            IF ^TEMP | LIT_CONVERSION THEN       /* SUBBIT OR LIT CONV.*/       01859000
            TEMP = "F00";     /* SKIP*/                                         01860000
         ;                                                                      01861000
         DO;         /* CLASS3 = MATRIX*/                                       01862000
            IF TEMP = MSUB THEN TEMP = MADD;                                    01863000
            ELSE IF TEMP = MTOM THEN TEMP = CONVERSION_FORMAT;                  01864000
         END;                                                                   01865000
         DO;         /* CLASS4 = VECTORS*/                                      01866000
            IF TEMP = VSUB THEN TEMP = VADD;                                    01867000
            ELSE IF FIX_SPECIALS & (TEMP&"F0")="60" THEN CALL CHECK_TRANSPOSE;  01868000
            ELSE IF TEMP = VTOV THEN TEMP = CONVERSION_FORMAT;                  01869000
         END;                                                                   01870000
         DO;         /* CLASS5 = SCALARS*/                                      01871000
            IF TEMP = SSUB THEN TEMP = SADD;                                    01872000
            ELSE IF TEMP = SSDV THEN TEMP = SSPR;                               01873000
            ELSE IF (TEMP & "8F") = "81" THEN DO;      /* CONVERSION*/          01874000
               IF LIT_CONVERSION THEN TEMP = "F00";                             01875000
               ELSE TEMP = CONVERSION_FORMAT;                                   01876000
            END;                                                                01877000
            ELSE IF TEMP = BTOS THEN                                            01877010
               TEMP = CONVERSION_FORMAT;                                        01877020
         END;                                                                   01878000
         DO;           /* CLASS6 = INTEGER*/                                    01879000
            IF TEMP = ISUB THEN TEMP = IADD;                                    01880000
            ELSE IF (TEMP & "8F") = "81" THEN  DO;/* CONVERSION*/               01881000
               IF LIT_CONVERSION THEN                                           01882000
                  TEMP = "F00";        /* DON'T TABLE LIT CONVERSIONS IN CONDS*/01883000
               ELSE TEMP = CONVERSION_FORMAT;                                   01884000
            END;                                                                01885000
            ELSE IF TEMP = BTOI THEN                                            01885010
               TEMP = CONVERSION_FORMAT;                                        01885020
         END;;;;;;;;;;                                                          01886000
         END;     /* DO CASE*/                                                  01887000
      IF SET_P THEN DO;                                                         01888000
         SET_P = 0;                                                             01889000
         PARITY = (TEMP ^= OP);                                                 01890000
      END;                                                                      01890010
      FIX_SPECIALS = 0;                                                         01890020
      RETURN TEMP;                                                              01890030
   END CLASSIFY;                                                                01890040
