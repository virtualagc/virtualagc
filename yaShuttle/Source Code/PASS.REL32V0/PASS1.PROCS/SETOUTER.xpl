 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETOUTER.xpl
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
 /* PROCEDURE NAME:  SET_OUTER_REF                                          */
 /* MEMBER NAME:     SETOUTER                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               FIXED                                        */
 /*          FLAG              FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          OUT_REF                                                        */
 /*          OUT_REF_FLAGS                                                  */
 /*          OUTER_REF_LIM                                                  */
 /*          OUTER_REF                                                      */
 /*          OUTER_REF_FLAGS                                                */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          OUTER_REF_INDEX                                                */
 /*          OUTER_REF_TABLE                                                */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          COMPRESS_OUTER_REF                                             */
 /* CALLED BY:                                                              */
 /*          SET_XREF                                                       */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SET_OUTER_REF <==                                                   */
 /*     ==> COMPRESS_OUTER_REF                                              */
 /*         ==> MAX                                                         */
 /***************************************************************************/
 /*     REVISION HISTORY:                                                   */
 /*     -----------------                                                   */
 /*     DATE    NAME  REL    DR NUMBER AND TITLE                            */
 /*                                                                         */
 /*    01/25/05 JAC   32V0/  120267 BLOCKSUM'S USED VALUE INCORRECT         */
 /*                   17V0                                                  */
 /***************************************************************************/
                                                                                00547600
                                                                                00547700
SET_OUTER_REF:                                                                  00547800
   PROCEDURE(LOC, FLAG);                                                        00547900
      DECLARE (LOC, FLAG) FIXED;                                                00548000
      IF OUTER_REF_INDEX = OUTER_REF_LIM THEN CALL COMPRESS_OUTER_REF;          00548100
      DO WHILE OUTER_REF_INDEX >= RECORD_TOP(OUTER_REF_TABLE);                  00548200
         NEXT_ELEMENT(OUTER_REF_TABLE);                                         00548400
      END;                                                                      00548600
      OUTER_REF_INDEX = OUTER_REF_INDEX + 1;                                    00548900
      OUTER_REF(OUTER_REF_INDEX) = LOC;                                         00549000
      OUTER_REF_FLAGS(OUTER_REF_INDEX) = SHR(FLAG, 13);                         00549010
      OUTER_REF_MAX = MAX(OUTER_REF_MAX,OUTER_REF_INDEX); /*DR120267*/          00549010
   END SET_OUTER_REF;                                                           00549200
