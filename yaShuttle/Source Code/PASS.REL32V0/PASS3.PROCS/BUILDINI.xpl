 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   BUILDINI.xpl
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
 /* PROCEDURE NAME:  BUILD_INITTAB                                          */
 /* MEMBER NAME:     BUILDINI                                               */
 /* CALLED BY:       BUILD_SDF                                              */
 /***************************************************************************/
 /*  REVISION HISTORY :                                                     */
 /*  ------------------                                                     */
 /*  DATE     NAME  REL   DR NUMBER AND TITLE                               */
 /*                                                                         */
 /*  05/26/99 SMR   30V0  CR13079  ADD HAL/S INITIALIZATION DATA TO SDF     */
 /*                 15V0                                                    */
 /*                                                                         */
 /***************************************************************************/
 /* CR13079 - ROUTINE TO PUT THE INITIALIZATION TABLE INTO THE SDF */
BUILD_INITTAB:
   PROCEDURE;
      BASED DIR_NODE FIXED; /*POINTER TO THE DIRECTORY ROOT CELL*/
      /*HALFWORD POINTER USED TO PUT THE INITIALIZATION TABLE INTO THE SDF*/
      BASED  NODE_H BIT(16);
      /*LOCATION IN THE DIRECTORY ROOT CELL OF THE INITIALIZATION TABLE*/
      DECLARE INIT_PTR LITERALLY '39';
      DECLARE (INIT_TOP,INITIAL_TAB,I,INIT_TAB_INDEX) FIXED;
      /*POINTER TO CURRENT SDF PAGE THAT INITIALIZATION TABLE INFO. IS*/
      /*BEING ADDED TO*/
      DECLARE PTR FIXED;

      INIT_TOP = RECORD_TOP(INIT_TAB);
      /*START #D/#P DATA AT BEGINNING OF THE NEXT UNUSED PAGE*/
      FIRST#D_PAGE = LAST_PAGE+1;
      INITIAL_TAB,PTR =  SHL((FIRST#D_PAGE),16);
      CALL P3_LOCATE(ROOT_PTR,ADDR(DIR_NODE),MODF);
      DIR_NODE(INIT_PTR) = INITIAL_TAB;   /*POINTER TO INITIALIZATION TABLE*/
      DIR_NODE(INIT_PTR+1) = INIT_TOP+1;  /*NUMBER OF HALFWORDS IN TABLE*/
      /*POSITION TO BEGINNING OF FIRST #D/#P PAGE*/
      CALL P3_PTR_LOCATE(INITIAL_TAB,RESV|MODF);
      COREWORD(ADDR(NODE_H)) = LOC_ADDR;
      INIT_TAB_INDEX = 0;
      DO I = 0 TO INIT_TOP;
         IF INIT_TAB_INDEX >= PAGE_SIZE/2 THEN DO;
         /* NEED ANOTHER SDF PAGE */
            CALL P3_PTR_LOCATE(PTR,RELS); /*RELEASE LAST PAGE*/
            PTR = PTR+"1 0000"; /*ADD A PAGE WITH ZERO OFFSET*/
            CALL P3_PTR_LOCATE(PTR,RESV|MODF); /*GET NEXT PAGE*/
            COREWORD(ADDR(NODE_H)) = LOC_ADDR; /*POSITION NODE_H POINTER*/
            INIT_TAB_INDEX = 0;
         END;
         NODE_H(INIT_TAB_INDEX) = INIT_VAL(I);
         INIT_TAB_INDEX = INIT_TAB_INDEX + 1;
      END;  /* FOR LOOP */
      CALL P3_PTR_LOCATE(PTR,RELS);
      #D_FREE_SPACE = PAGE_SIZE - (INIT_TAB_INDEX * 2);
      RECORD_FREE(INIT_TAB);
   END BUILD_INITTAB;
