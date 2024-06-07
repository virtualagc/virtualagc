 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETEON.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  GET_EON                                                */
 /* MEMBER NAME:     GETEON                                                 */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /*          GET_EOL           BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          REPEATT           LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          END_OF_NODE                                                    */
 /*          END_OF_LIST                                                    */
 /*          FALSE                                                          */
 /*          NODE                                                           */
 /* CALLED BY:                                                              */
 /*          CATALOG_ENTRY                                                  */
 /*          CHECK_INVAR                                                    */
 /***************************************************************************/
 /* FINDS INDEX OF END_OF_NODE IN NODE LIST */                                  00567010
GET_EON:                                                                        00567020
   PROCEDURE(PTR,GET_EOL);                                                      00567030
      DECLARE (GET_EOL) BIT(8);                                                 00567033
      DECLARE PTR BIT(16);                                                      00567036
REPEATT:                                                                        00567039
      DO WHILE NODE(PTR) ^= END_OF_NODE;                                        00567050
         PTR = PTR - 1;                                                         00567060
      END;                                                                      00567070
      IF GET_EOL THEN DO;                                                       00567071
         PTR = PTR - 2;                                                         00567072
         IF NODE(PTR) ^= END_OF_LIST THEN GO TO REPEATT;                        00567073
      END;                                                                      00567074
      GET_EOL = FALSE;                                                          00567075
      RETURN PTR;                                                               00567080
   END GET_EON;                                                                 00567090
