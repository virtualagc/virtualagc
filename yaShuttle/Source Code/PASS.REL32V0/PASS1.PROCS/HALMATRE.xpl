 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   HALMATRE.xpl
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
 /* PROCEDURE NAME:  HALMAT_RELOCATE                                        */
 /* MEMBER NAME:     HALMATRE                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          D1                BIT(16)                                      */
 /*          D2                FIXED                                        */
 /*          D3                FIXED                                        */
 /*          D4                BIT(16)                                      */
 /*          I                 FIXED                                        */
 /*          MOVE_BLOCK(1549)  LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ATOM#_LIM                                                      */
 /*          ATOMS                                                          */
 /*          CONST_ATOMS                                                    */
 /*          FALSE                                                          */
 /*          HALMAT_OK                                                      */
 /*          XVAC                                                           */
 /*          XXPT                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ATOM#_FAULT                                                    */
 /*          FOR_ATOMS                                                      */
 /*          HALMAT_RELOCATE_FLAG                                           */
 /*          NEXT_ATOM#                                                     */
 /* CALLED BY:                                                              */
 /*          EMIT_SMRK                                                      */
 /***************************************************************************/
HALMAT_RELOCATE:                                                                00794100
   PROCEDURE;                                                                   00794200
      DECLARE (D1,D4) BIT(16),                                                  00794300
         (I,D2,D3) FIXED;                                                       00794400
MOVE_BLOCK:                                                                     00794500
      PROCEDURE (START,STOP,DELTA);                                             00794600
         DECLARE (START,STOP,DELTA) BIT(16);                                    00794700
         DO I=1-STOP TO -START;                                                 00794800
            ATOMS(DELTA-I)=ATOMS(-I);                                           00794900
         END;                                                                   00795000
      END MOVE_BLOCK;                                                           00795100
 /* FIRST MOVE CODE */                                                          00795200
      HALMAT_RELOCATE_FLAG=FALSE;                                               00795300
      IF ^HALMAT_OK THEN RETURN;                                                00795400
      IF ATOM#_FAULT=ATOM#_LIM THEN DO;                                         00795500
         ATOM#_FAULT=0;                                                         00795600
         RETURN;                                                                00795700
      END;                                                                      00795800
      D1=ATOM#_FAULT-NEXT_ATOM#;                                                00795900
      D2=ATOM#_LIM-ATOM#_FAULT;                                                 00796000
      D3 = 2 - ATOM#_FAULT;                                                     00796100
      D4 = 2;                                                                   00796110
      DO WHILE D1<D2;                                                           00796300
         CALL MOVE_BLOCK(D4,NEXT_ATOM#,D1);                                     00796400
         CALL MOVE_BLOCK(ATOM#_FAULT,ATOM#_FAULT+D1,D3);                        00796500
         D4=D4+D1;                                                              00796600
         D2=D2-D1;                                                              00796700
         NEXT_ATOM#=NEXT_ATOM#+D1;                                              00796800
         ATOM#_FAULT=ATOM#_FAULT+D1;                                            00796900
      END;                                                                      00797000
      CALL MOVE_BLOCK(D4,NEXT_ATOM#,D2);                                        00797100
      CALL MOVE_BLOCK(ATOM#_FAULT,ATOM#_LIM,D3);                                00797200
      NEXT_ATOM#=NEXT_ATOM#+D2;                                                 00797300
      ATOM#_FAULT = 2;    /* NOW RELOCATE VACS */                               00797400
      D3=SHL(-D3,16);                                                           00797500
      D2 = SHL(D2 + D4 - ATOM#_FAULT,16);                                       00797600
      DO I = 2 TO NEXT_ATOM# - 1;                                               00797700
         D4=SHR(ATOMS(I)&"F0",4);                                               00797800
         IF ATOMS(I) THEN IF (D4=XVAC)|(D4=XXPT) THEN DO;                       00797900
            IF ATOMS(I)>=D3 THEN                                                00798000
               ATOMS(I)=ATOMS(I)-D3;                                            00798100
            ELSE ATOMS(I)=ATOMS(I)+D2;                                          00798200
         END;                                                                   00798300
      END;                                                                      00798400
   END HALMAT_RELOCATE;                                                         00798500
