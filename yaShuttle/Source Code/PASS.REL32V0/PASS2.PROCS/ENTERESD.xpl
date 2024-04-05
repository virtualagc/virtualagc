 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ENTERESD.xpl
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
/* PROCEDURE NAME:  ENTER_ESD                                              */
/* MEMBER NAME:     ENTERESD                                               */
/* INPUT PARAMETERS:                                                       */
/*          NAME              CHARACTER;                                   */
/*          PTR               BIT(16)                                      */
/*          TYP               BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          I                 BIT(16)                                      */
/*          J                 BIT(16)                                      */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          ESD_NAME                                                       */
/*          ESD_NAME_LENGTH                                                */
/*          ESD_TYPE                                                       */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          PAD                                                            */
/* CALLED BY:                                                              */
/*          GENERATE                                                       */
/*          INITIALISE                                                     */
/*          OBJECT_GENERATOR                                               */
/*          TERMINATE                                                      */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> ENTER_ESD <==                                                       */
/*     ==> PAD                                                             */
/***************************************************************************/
/***************************************************************************/
/*                                                                         */
/*  REVISION HISTORY                                                       */
/*                                                                         */
/*  DATE     WHO  RLS   CR/DR #  DESCRIPTION                               */
/*                                                                         */
/*  05/05/92 JAC   7V0  CR11114  MERGE BFS/PASS COMPILERS                  */
/*                                                                         */
/***************************************************************************/
                                                                                00608000
 /* ROUTINE TO ENTER ESD TABLE ENTRY  */                                        00608500
ENTER_ESD:                                                                      00609000
 /?P  /* CR11114 -- BFS/PASS INTERFACE; OBJECT MODULE FORMAT */
   PROCEDURE(NAME, PTR, TYP);                                                   00609500
      DECLARE NAME CHARACTER, (PTR, TYP, I, J) BIT(16);                         00610000
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; OBJECT MODULE FORMAT */
   PROCEDURE(NAME, PTR, TYP, CSECT_TYPE);
   DECLARE
           NAME                           CHARACTER,
           (PTR, TYP, I, J)               BIT(16),
           CSECT_TYPE                     BIT(8);
 ?/
      ESD_NAME_LENGTH(PTR) = LENGTH(NAME);                                      00610500
      I = BYTE(NAME, 1);                                                        00611000
      IF BYTE(NAME) = BYTE('#') THEN                                            00611500
         IF I = BYTE('Z') | I = BYTE('Q') THEN                                  00612000
         ESD_NAME_LENGTH(PTR) = ESD_NAME_LENGTH(PTR) | "80";                    00612500
      ESD_TYPE(PTR) = TYP;                                                      00613000
 /?B  /* CR11114 -- BFS/PASS INTERFACE; OBJECT MODULE FORMAT */
      ESD_CSECT_TYPE(PTR) = CSECT_TYPE;
 ?/
      I = SHR(PTR, 5);                                                          00613500
      J = SHL(PTR-SHL(I,5),3);                                                  00614000
      NAME = PAD(NAME, 8);                                                      00614500
      IF J = 0 THEN ESD_NAME(I) = NAME || SUBSTR(ESD_NAME(I), 8);               00615000
      ELSE DO;                                                                  00615500
         NAME = SUBSTR(ESD_NAME(I), 0, J) || NAME || SUBSTR(ESD_NAME(I), J+8);  00616000
         ESD_NAME(I) = NAME;                                                    00616500
      END;                                                                      00617000
   END ENTER_ESD;                                                               00617500
