 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FLAGVN.xpl
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
 /* PROCEDURE NAME:  FLAG_V_N                                               */
 /* MEMBER NAME:     FLAGVN                                                 */
 /* LOCAL DECLARATIONS:                                                     */
 /*          PTR               BIT(16)                                      */
 /*          I                 BIT(16)                                      */
 /*          TMP               FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CSE                                                            */
 /*          FLAG                                                           */
 /*          FOR                                                            */
 /*          FORWARD                                                        */
 /*          HALMAT_NODE_END                                                */
 /*          HALMAT_NODE_START                                              */
 /*          OPR                                                            */
 /*          REVERSE                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CATALOG_PTR                                                    */
 /*          NO_OPERANDS                                                    */
 /*          SET_FLAG                                                       */
 /*          VALIDITY                                                       */
 /* CALLED BY:                                                              */
 /*          FLAG_MATCHES                                                   */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> FLAG_V_N <==                                                        */
 /*     ==> CATALOG_PTR                                                     */
 /*     ==> VALIDITY                                                        */
 /*     ==> NO_OPERANDS                                                     */
 /*     ==> SET_FLAG                                                        */
 /***************************************************************************/
                                                                                02761000
 /* FINDS AND FLAGS VALUE_NO MATCHING CSE*/                                     02762000
FLAG_V_N:                                                                       02763000
   PROCEDURE;                                                                   02764000
      DECLARE TMP FIXED;                                                        02765000
      DECLARE (PTR,I) BIT(16);                                                  02766000
      PTR = HALMAT_NODE_START;                                                  02767000
      DO WHILE PTR <= HALMAT_NODE_END;                                          02768000
         IF FLAG(PTR) THEN DO FOR I = 1 TO NO_OPERANDS(PTR);   /* PART OF NODE*/02769000
            TMP = OPR(PTR + I);                                                 02770000
            IF (SHR(TMP,4) & "F") = 1 THEN DO; /* SYT */                        02771000
               IF CATALOG_PTR(SHR(TMP,16)) = (CSE & "00 FFFF") THEN DO;         02772000
                  IF (SHR(CSE,20) & 1) = (SHR(FLAG(PTR + I),2) +                02773000
                     ((FORWARD) & REVERSE) & "1")    &                          02774000
                     VALIDITY(SHR(TMP,16)) THEN  /*F=A+B;C=B;B=0;F=A+B+C; CASE*/02775000
                     IF ^SHR(FLAG(PTR + I),1) THEN  DO;                         02776000
                                                                                02777000
                     CALL SET_FLAG(PTR+I,1);                                    02778000
                     RETURN;                                                    02779000
                  END;                                                          02780000
               END;                                                             02781000
            END; /*IF HALMAT*/                                                  02782000
         END; /*IF FLAG*/                                                       02783000
         PTR = PTR + NO_OPERANDS(PTR) + 1;                                      02784000
      END; /* DO WHILE PTR*/                                                    02785000
   END FLAG_V_N;                                                                02786000
