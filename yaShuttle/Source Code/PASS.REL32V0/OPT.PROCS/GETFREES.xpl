 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETFREES.xpl
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
 /* PROCEDURE NAME:  GET_FREE_SPACE                                         */
 /* MEMBER NAME:     GETFREES                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          SPACE             BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          INDEX             BIT(16)                                      */
 /*          BEGIN             BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LAST_SPACE_BLOCK                                               */
 /*          CLASS_BI                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FREE_SPACE                                                     */
 /*          FREE_BLOCK_BEGIN                                               */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERRORS                                                         */
 /* CALLED BY:                                                              */
 /*          CATALOG_ENTRY                                                  */
 /*          CATALOG                                                        */
 /*          CATALOG_VAC                                                    */
 /*          TABLE_NODE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> GET_FREE_SPACE <==                                                  */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /***************************************************************************/
                                                                                01208000
GET_FREE_SPACE:PROCEDURE(SPACE) BIT(16);                                        01209000
      DECLARE SPACE BIT(16);                                                    01210000
      DECLARE (INDEX,BEGIN) BIT(16);                                            01211000
                                                                                01212000
      DO INDEX=0 TO LAST_SPACE_BLOCK;                                           01213000
         IF FREE_SPACE(INDEX)>=SPACE THEN                                       01214000
            DO;                                                                 01215000
            BEGIN = FREE_BLOCK_BEGIN(INDEX);                                    01216000
            FREE_BLOCK_BEGIN(INDEX) = FREE_BLOCK_BEGIN(INDEX)+SPACE;            01217000
            FREE_SPACE(INDEX) = FREE_SPACE(INDEX)-SPACE;                        01218000
            RETURN BEGIN;                                                       01219000
         END;                                                                   01220000
      END;                                                                      01221000
 /*  REACHING HERE MEANS NOT ENOUGH SPACE  */                                   01222000
      CALL ERRORS (CLASS_BI, 308);                                              01223000
                                                                                01224000
   END GET_FREE_SPACE;                                                          01225000
