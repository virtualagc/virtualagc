 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   LABELMAT.xpl
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
 /* PROCEDURE NAME:  LABEL_MATCH                                            */
 /* MEMBER NAME:     LABELMAT                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* LOCAL DECLARATIONS:                                                     */
 /*          LOC               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FIXL                                                           */
 /*          DO_PARSE                                                       */
 /*          LABEL_DEFINITION                                               */
 /*          MPP1                                                           */
 /*          PARSE_STACK                                                    */
 /*          TEMP                                                           */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
                                                                                00815000
LABEL_MATCH:                                                                    00815100
   PROCEDURE BIT(1);                                                            00815200
      DECLARE LOC BIT(16);                                                      00815300
      IF FIXL(MPP1)=0 THEN RETURN 1;                                            00815400
      LOC=DO_PARSE(TEMP);                                                       00815500
      DO WHILE PARSE_STACK(LOC)=LABEL_DEFINITION;                               00815600
         IF FIXL(LOC)=FIXL(MPP1) THEN RETURN 1;                                 00815700
         LOC=LOC-1;                                                             00815800
      END;                                                                      00815900
      RETURN 0;                                                                 00816000
   END LABEL_MATCH;                                                             00816100
