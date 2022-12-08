 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FLAGVACO.xpl
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
/* PROCEDURE NAME:  FLAG_VAC_OR_LIT                                        */
/* MEMBER NAME:     FLAGVACO                                               */
/* INPUT PARAMETERS:                                                       */
/*          LITFLAG           BIT(8)                                       */
/* LOCAL DECLARATIONS:                                                     */
/*          I                 BIT(16)                                      */
/*          FOUND             LABEL                                        */
/*          PTR               BIT(16)                                      */
/*          TEMP              BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CSE2                                                           */
/*          FLAG                                                           */
/*          FOR                                                            */
/*          FORWARD                                                        */
/*          HALMAT_NODE_END                                                */
/*          HALMAT_NODE_START                                              */
/*          LIT                                                            */
/*          NODE                                                           */
/*          OPR                                                            */
/*          REVERSE                                                        */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          CSE                                                            */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          COMPARE_LITERALS                                               */
/*          HALMAT_FLAG                                                    */
/*          NO_OPERANDS                                                    */
/*          SET_FLAG                                                       */
/*          VAC_OR_XPT                                                     */
/* CALLED BY:                                                              */
/*          FLAG_MATCHES                                                   */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> FLAG_VAC_OR_LIT <==                                                 */
/*     ==> VAC_OR_XPT                                                      */
/*     ==> COMPARE_LITERALS                                                */
/*         ==> HEX                                                         */
/*         ==> GET_LITERAL                                                 */
/*     ==> NO_OPERANDS                                                     */
/*     ==> HALMAT_FLAG                                                     */
/*         ==> VAC_OR_XPT                                                  */
/*     ==> SET_FLAG                                                        */
/***************************************************************************/
                                                                                02719000
/*******************************************************************************02720000
                                                                                02721000
FLAG:  ARRAY PARALLEL WITH HALMAT                                               02722000
       BIT 0--FOR OPERATORS OF THIS CLASSIFICATION (SET BY FLAG_NODE)           02723000
       BIT 1--FOR MATCHED OPERANDS (SET BY FLAG_MATCHES)                        02724000
       BIT 2--FOR OPERATORS AND OPERANDS WITH ODD PARITY, EG SUBTRACT           02725000
              (SET BY FLAG_NODE)                                                02726000
                                                                                02727000
*******************************************************************************/02728000
                                                                                02729000
   /* FINDS AND FLAGS OUTER TERMINAL VAC MATCHING CSE*/                         02730000
FLAG_VAC_OR_LIT:                                                                02731000
   PROCEDURE(LITFLAG);                                                          02732000
      DECLARE LITFLAG BIT(8);                                                   02733000
      DECLARE (PTR,I,TEMP) BIT(16);                                             02734000
      IF LITFLAG THEN CSE = CSE|CSE2;                                           02735000
      PTR = HALMAT_NODE_START;                                                  02736000
      DO WHILE PTR <= HALMAT_NODE_END;                                          02737000
         IF FLAG(PTR) THEN DO FOR I = 1 TO NO_OPERANDS(PTR);                    02738000
            TEMP = SHR(OPR(PTR + I),16);                                        02739000
            IF ^ SHR(FLAG(PTR + I),1) THEN                                      02740000
               IF (SHR(CSE,20) & "1") = (SHR(FLAG(PTR + I),2) + (FORWARD &      02741000
                  REVERSE) & "1") THEN DO CASE LITFLAG;                         02742000
                                                                                02743000
                  IF TEMP = (CSE & "FFFF") THEN IF HALMAT_FLAG(PTR + I)         02744000
                     THEN IF VAC_OR_XPT(PTR + I) THEN DO;                       02745000
                           CALL SET_FLAG(PTR + I,1);                            02746000
                           RETURN;                                              02747000
                        END;                                                    02748000
                                                                                02749000
                  IF (SHR(OPR(PTR + I),4) & "F") = LIT THEN                     02750000
                     IF COMPARE_LITERALS(CSE & "FFFF",TEMP) THEN DO;            02751000
               FOUND:                                                           02751010
                           CALL SET_FLAG(PTR + I,1);                            02752000
                           LITFLAG = 0;                                         02753000
                           RETURN;                                              02754000
                        END;                                                    02755000
                                                                                02755010
                  IF HALMAT_FLAG(PTR+I) THEN DO;                                02755020
                     IF (CSE & "FFFF") = TEMP THEN GO TO FOUND;                 02755022
                  END;                                                          02755024
                  ELSE IF (NODE(CSE & "FFFF") & "FFFF") = TEMP THEN GO TO FOUND;02755026
                                                                                02755030
               END;           /* DO CASE*/                                      02756000
         END;                                                                   02757000
         PTR = PTR + NO_OPERANDS(PTR) + 1;                                      02758000
      END;                                                                      02759000
   END FLAG_VAC_OR_LIT;                                                         02760000
