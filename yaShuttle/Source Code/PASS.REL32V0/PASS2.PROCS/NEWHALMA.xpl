 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   NEWHALMA.xpl
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
/* PROCEDURE NAME:  NEW_HALMAT_BLOCK                                       */
/* MEMBER NAME:     NEWHALMA                                               */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CODEFILE                                                       */
/*          CONST_ATOMS                                                    */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          CTR                                                            */
/*          CURCBLK                                                        */
/*          FOR_ATOMS                                                      */
/*          NUMOP                                                          */
/*          OFF_PAGE_CTR                                                   */
/*          OFF_PAGE_LAST                                                  */
/*          OFF_PAGE_NEXT                                                  */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          POPNUM                                                         */
/* CALLED BY:                                                              */
/*          GENERATE                                                       */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> NEW_HALMAT_BLOCK <==                                                */
/*     ==> POPNUM                                                          */
/***************************************************************************/
/*  REVISION HISTORY:                                                      */
/*  -----------------                                                      */
/*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */
/*12/19/97 SMR   29V0/ 109084 STRUCTURE INITIALIZATION MAY CAUSE           */
/*               14V0         INCORRECT HALMAT                             */
/*                                                                         */
/***************************************************************************/

 /* ROUTINE TO GET A NEW BLOCK OF HALMAT  */                                    00633500
NEW_HALMAT_BLOCK:                                                               00634000
   PROCEDURE;                                                                   00634500
      DECLARE I BIT(16);             /*DR109084*/
      DO FOR I = 0 TO ATOM#_LIM;     /*DR109084*/
         VAC_VAL(I) = FALSE;         /*DR109084*/
      END;                           /*DR109084*/
      OPR(0)=FILE(CODEFILE,CURCBLK);                                            00635000
      CURCBLK=CURCBLK+1;                                                        00635500
      CTR=0;                                                                    00636000
      OFF_PAGE_LAST = OFF_PAGE_NEXT;                                              636100
      OFF_PAGE_NEXT = OFF_PAGE_NEXT + 1 & 1;                                      636200
      OFF_PAGE_CTR(OFF_PAGE_NEXT) = 0;                                            636300
      NUMOP = POPNUM(0);                                                          636500
   END NEW_HALMAT_BLOCK;                                                        00637000
