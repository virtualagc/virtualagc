 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ENTERXRE.xpl
    Purpose:    Part of the HAL/S-FC compiler.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section TBD.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
/****************************************************************/              00000190
/*  REVISION HISTORY:                                           */
/*  -----------------                                           */
/*  DATE      NAME  REL    DR NUMBER & TITLE                    */
/*  12/20/00  TKN   31V0/  111356  XREF INCORRECT FOR STRUCTURE */
/*                  16V0           TEMPLATE DECLARATION         */
/*                                                              */
/****************************************************************/

/* PROCEDURE TO BUILD AN XREF ENTRY TO THE XREF LIST            */

ENTER_XREF:                                                                     00000010
   PROCEDURE (ROOT,FLAG) BIT(16);                                               00000020
      DECLARE (ROOT,FLAG) FIXED;                                                00000030

/*DR111356*/
/* TO MAKE SURE A DEFINITION XREF ALWAYS EXISTS FOR EACH VARIABLE*/
/* (I.E, NOT OVERWRITTEN BY PROCESSING ANOTHER XREF FOR THE SAME */
/* VARIABLE AT THE SAME STATEMENT), DR111356 ADDED ANOTHER CHECK */
/* ON THE FLAG FIELD OF THE PROCESSING XREF TO DETERMINE WHETHER */
/* OR NOT A NEW XREF NEEDS TO BE CREATED.                        */
/* HOWEVER, TO AVOID THE CREATION OF AN EXTRA DEFINITION XREF    */
/* FOR A COMSUB LABEL AT THE POINT OF CALL, OR FOR A PROCEDURE   */
/* LABEL IN A FORWARD CALL (A CALL OCCURS BEFORE THE PROCEDURE   */
/* IS DEFINED), NO_NEW_XREF IS SET TO PREVENT THE DEFINITION XREF*/
/* FROM BEING CREATED IN THE CALL STATEMENTS.                    */

      IF ((XREF(ROOT)&XREF_MASK)=STMT_NUM) &                                    00000050
         (((XREF(ROOT) & "E000") ^= 0) | NO_NEW_XREF) THEN /*DR111356*/
         XREF(ROOT)=XREF(ROOT)|FLAG;
      ELSE DO;         /*CREATE A NEW XREF*/                                    00000110
         NEXT_ELEMENT(CROSS_REF);                                               00000111
         XREF_INDEX=XREF_INDEX+1;                                               00000120
         XREF(0)=SHL(XREF_INDEX,16);                                            00000130
         XREF(XREF_INDEX)=(XREF(ROOT)&"FFFF0000")|STMT_NUM|FLAG;                00000140
         XREF(ROOT)=(XREF(ROOT)&"FFFF")|XREF(0);                                00000150
         ROOT=XREF_INDEX;                                                       00000160
      END;
      RETURN ROOT;                                                              00000180
 END ENTER_XREF;
