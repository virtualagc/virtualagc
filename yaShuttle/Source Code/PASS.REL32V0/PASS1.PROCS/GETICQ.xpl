 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETICQ.xpl
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
 /* PROCEDURE NAME:  GET_ICQ                                                */
 /* MEMBER NAME:     GETICQ                                                 */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          FIXED                                                          */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          IC_SIZE                                                        */
 /*          IC_FILE                                                        */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          IC_LIM                                                         */
 /*          CUR_IC_BLK                                                     */
 /*          IC_MAX                                                         */
 /*          IC_ORG                                                         */
 /*          IC_VAL                                                         */
 /* CALLED BY:                                                              */
 /*          HALMAT_INIT_CONST                                              */
 /*          ICQ_OUTPUT                                                     */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 02/22/91 TKK  23V2  CR11109  CLEAN UP OF COMPILER SOURCE CODE           */
 /*                                                                         */
 /***************************************************************************/
                                                                                00997300
GET_ICQ:                                                                        00997400
   PROCEDURE(PTR) FIXED;                                                        00997500
      DECLARE (PTR) FIXED;                                                      00997600
      IF PTR >= IC_ORG THEN                                                     00997700
         IF PTR < IC_LIM THEN                                                   00997800
         RETURN PTR - IC_ORG;                                                   00997900
      FILE(IC_FILE, CUR_IC_BLK) = IC_VAL;                                       00998000
      CUR_IC_BLK = PTR / IC_SIZE;                                               00998100
      IC_ORG = CUR_IC_BLK * IC_SIZE;                                            00998200
      IC_LIM = IC_ORG + IC_SIZE;                                                00998300
      IF CUR_IC_BLK <= IC_MAX THEN                                              00998400
         IC_VAL = FILE(IC_FILE, CUR_IC_BLK);                                    00998500
      ELSE IC_MAX=IC_MAX+1;                                                     00998600
      RETURN PTR - IC_ORG;                                                      00998700
   END GET_ICQ;                                                                 00998800
