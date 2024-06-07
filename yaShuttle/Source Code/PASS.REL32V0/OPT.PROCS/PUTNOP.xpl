 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PUTNOP.xpl
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
 /* PROCEDURE NAME:  PUT_NOP                                                */
 /* MEMBER NAME:     PUTNOP                                                 */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          POINT             BIT(16)                                      */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FOR                                                            */
 /*          NONCOMMUTATIVE                                                 */
 /*          OPTYPE                                                         */
 /*          OR                                                             */
 /*          TSUB                                                           */
 /*          TWIN_MATCH                                                     */
 /*          WATCH                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          A_INX                                                          */
 /*          ADD                                                            */
 /*          HALMAT_NODE_START                                              */
 /*          OPR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CLASSIFY                                                       */
 /*          NO_OPERANDS                                                    */
 /*          TERMINAL                                                       */
 /* CALLED BY:                                                              */
 /*          REARRANGE_HALMAT                                               */
 /*          COLLAPSE_LITERALS                                              */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PUT_NOP <==                                                         */
 /*     ==> NO_OPERANDS                                                     */
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
 /***************************************************************************/
                                                                                02683000
 /* NOP'S MATCHED CSE'S*/                                                       02684000
PUT_NOP:                                                                        02685000
   PROCEDURE(PTR);                                                              02686000
      DECLARE TEMP BIT(16);                                                     02687000
      DECLARE (PTR,I) BIT(16);                                                  02688000
      DECLARE POINT BIT(16);                                                    02689000
      IF WATCH THEN OUTPUT = 'PUT_NOP: ' || PTR;                                02690000
      HALMAT_NODE_START = PTR;                                                  02691000
      A_INX = 1;                                                                02692000
      ADD(1) = PTR;                                                             02693000
      DO WHILE A_INX ^= 0;                                                      02694000
         TEMP = ADD(A_INX);                                                     02695000
         IF TEMP < HALMAT_NODE_START THEN HALMAT_NODE_START = TEMP;             02696000
         A_INX = A_INX -1;                                                      02697000
         IF OPTYPE = CLASSIFY(TEMP) OR TWIN_MATCH THEN                          02698000
            DO FOR I = TEMP + 1 TO TEMP + NO_OPERANDS(TEMP);                    02699000
            IF  ^TERMINAL(I)  THEN DO;                                          02700000
               POINT = SHR(OPR(I),16);                                          02701000
               IF CLASSIFY(POINT) = TSUB THEN DO;                               02702000
                  OPR(POINT) = OPR(POINT) & "FF 0000";                          02703000
                  POINT = POINT + 1;                                            02704000
                  DO WHILE OPR(POINT);                                          02705000
                     OPR(POINT) = 0;                                            02706000
                     POINT = POINT + 1;                                         02707000
                  END;                                                          02708000
               END;                                                             02709000
               A_INX = A_INX + 1;                                               02710000
               ADD(A_INX) = SHR(OPR(I),16);                                     02711000
            END;                                                                02712000
            OPR(I) = 0;                                                         02713000
         END;                                                                   02714000
         OPR(TEMP) = OPR(TEMP) & "FF 0000";                                     02715000
         IF NONCOMMUTATIVE THEN RETURN;                                         02716000
      END; /* DO WHILE*/                                                        02717000
   END PUT_NOP;                                                                 02718000
