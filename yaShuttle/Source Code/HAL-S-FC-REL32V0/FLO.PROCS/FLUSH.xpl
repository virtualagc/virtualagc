 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FLUSH.xpl
    Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
                generation process.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section 6.3.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  FLUSH                                                  */
 /* MEMBER NAME:     FLUSH                                                  */
 /* INPUT PARAMETERS:                                                       */
 /*          LAST              BIT(16)                                      */
 /*          NO_PTR            BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /*          OFFSET            CHARACTER;                                   */
 /*          STRING            CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LEVEL                                                          */
 /*          LINELENGTH                                                     */
 /*          X13                                                            */
 /*          X3                                                             */
 /*          X70                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          S                                                              */
 /* CALLED BY:                                                              */
 /*          FORMAT_EXP_VARS_CELL                                           */
 /*          FORMAT_FORM_PARM_CELL                                          */
 /*          FORMAT_NAME_TERM_CELLS                                         */
 /*          FORMAT_PF_INV_CELL                                             */
 /*          FORMAT_VAR_REF_CELL                                            */
 /***************************************************************************/
                                                                                00271300
 /* PRINTS OUT CONCATENATED S ARRAY */                                          00271400
FLUSH:                                                                          00271500
   PROCEDURE (LAST,NO_PTR);                                                     00271600
      DECLARE (LAST,I,J,K) BIT(16), (OFFSET,STRING) CHARACTER, NO_PTR BIT(8);   00271700
                                                                                00271800
      J = 10 + 3*LEVEL;                                                         00271900
      OFFSET = SUBSTR(X70,0,J);                                                 00272000
      J = 0;                                                                    00272100
      STRING = OFFSET;                                                          00272200
      DO WHILE J <= LAST;                                                       00272300
         IF LENGTH(STRING) + LENGTH(S(J)) < LINELENGTH THEN DO;                 00272400
            STRING = STRING || S(J);                                            00272500
            S(J) = '';                                                          00272700
            J = J + 1;                                                          00272701
         END;                                                                   00272800
         ELSE DO;                                                               00272900
            I,K = LINELENGTH - LENGTH(STRING) - 1;                              00273000
            DO WHILE BYTE(S(J),I)^=BYTE(' ') & BYTE(S(J),I)^=BYTE(',') & I>0;   00273100
               I = I - 1;                                                       00273200
            END;                                                                00273300
            IF I=0 THEN DO;                                                     00273400
               I = K;                                                           00273401
               DO WHILE BYTE(S(J))^=BYTE('.') & I>0;                            00273500
                  I = I - 1;                                                    00273600
               END;                                                             00273700
               IF I = 0 THEN I = K;                                             00273800
            END;                                                                00273900
            OUTPUT = STRING || SUBSTR(S(J),0,I+1);                              00274000
            S(J) = SUBSTR(S(J),I+1);                                            00274100
            IF NO_PTR THEN STRING = OFFSET || X3;                               00274101
            ELSE STRING = OFFSET || X13;                                        00274200
         END;                                                                   00274300
      END;                                                                      00274400
      OUTPUT = STRING;                                                          00274401
      NO_PTR = 0;                                                               00274402
   END FLUSH;                                                                   00274500
