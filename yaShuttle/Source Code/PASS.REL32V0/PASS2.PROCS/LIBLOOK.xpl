 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   LIBLOOK.xpl
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
/* PROCEDURE NAME:  LIB_LOOK                                               */
/* MEMBER NAME:     LIBLOOK                                                */
/* FUNCTION RETURN TYPE:                                                   */
/*          BIT(16)                                                        */
/* INPUT PARAMETERS:                                                       */
/*          NAME              CHARACTER;                                   */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          LIB_LINK                                                       */
/*          DESC                                                           */
/*          LIB_NAME_INDEX                                                 */
/*          LIB_START                                                      */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          LIB_POINTER                                                    */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          HASH                                                           */
/* CALLED BY:                                                              */
/*          INTRINSIC                                                      */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> LIB_LOOK <==                                                        */
/*     ==> HASH                                                            */
/***************************************************************************/
 /*  REVISION HISTORY :                                                     */
 /*  ------------------                                                     */
 /*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */
 /*                                                                         */
 /*10/19/90 DAS   23V1  11053  (CR) RESTRICT RUNTIME LIBRARY USE            */
 /*                                                                         */
 /*04/05/99 LJK   30V0/ CR12620 SELECTIVE CLEARING OF DSES AROUND RTL CALLS */
 /*               15V0                                                      */
 /***************************************************************************/
                                                                                00848500
 /* ROUTINE TO DETERMINE WHETHER LIBRARY DESCRIPTION EXISTS */                  00849000
LIB_LOOK:                                                                       00849500
   PROCEDURE(NAME) BIT(16);                                                     00850000
      DECLARE NAME CHARACTER;                                                   00850500
      LIB_POINTER = LIB_START(HASH(NAME));                                      00851000
      DO WHILE LIB_POINTER ^= 0;                                                00851500
 /* DANNY STRAUSS ----------- CR11053 -------------------------------*/         00857500
 /* LIB_POINTER MAY BE NEGATIVE, SO TAKE ABSOLUTE VALUE.             */         00857500
         IF NAME = DESC(LIB_NAME_INDEX(ABS(LIB_POINTER))) THEN                  00852000
           DO;                                              /*CR12620*/
            IF EMIT_LDM_TABLE(ABS(LIB_POINTER))= 0 THEN     /*CR12620*/
                 EMIT_LDM = FALSE;                          /*CR12620*/
            ELSE EMIT_LDM = TRUE;                           /*CR12620*/
            RETURN(ABS(LIB_POINTER));                                           00852500
           END;                                             /*CR12620*/
         LIB_POINTER = LIB_LINK(ABS(LIB_POINTER));                              00853000
 /* DANNY STRAUSS ---------------------------------------------------*/         00857500
      END;                                                                      00853500
      RETURN 0;                                                                 00854000
   END LIB_LOOK;                                                                00854500
