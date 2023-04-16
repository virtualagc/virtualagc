 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   COPYDOWN.xpl
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
 /* PROCEDURE NAME:  COPY_DOWN                                              */
 /* MEMBER NAME:     COPYDOWN                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          K                 BIT(16)                                      */
 /*          S1                BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CAT_ARRAY                                                      */
 /*          FOR                                                            */
 /*          LEVEL                                                          */
 /*          SYT_SIZE                                                       */
 /*          SYT_USED                                                       */
 /*          SYT_WORDS                                                      */
 /*          VAL_ARRAY                                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          PAR_SYM                                                        */
 /*          VAL_TABLE                                                      */
 /* CALLED BY:                                                              */
 /*          POP_STACK                                                      */
 /***************************************************************************/
                                                                                02207070
 /* COPIES CATALOG_PTR AND VALIDITY_ARRAY FROM PREVIOUS LEVEL*/                 02207080
COPY_DOWN:                                                                      02207090
   PROCEDURE;                                                                   02207100
      DECLARE (K,S1) BIT(16);                                                   02207110
      S1 = SYT_SIZE + 1;                                                        02207120
      DO FOR K = 0 TO SYT_SIZE;                                                 02207130
         PAR_SYM(LEVEL).CAT_ARRAY(K) = PAR_SYM(LEVEL+1).CAT_ARRAY(K);           02207140
      END;                                                                      02207150
      DO FOR K = 0 TO SYT_WORDS;                                                02207160
         VAL_TABLE(LEVEL).VAL_ARRAY(K) = VAL_TABLE(LEVEL+1).VAL_ARRAY(K);       02207170
      END;                                                                      02207180
   END COPY_DOWN;                                                               02207190
