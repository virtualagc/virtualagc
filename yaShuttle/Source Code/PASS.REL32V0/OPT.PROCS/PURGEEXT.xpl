 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PURGEEXT.xpl
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
 /* PROCEDURE NAME:  PURGE_EXTNS                                            */
 /* MEMBER NAME:     PURGEEXT                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          INX               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          EXTN                                                           */
 /*          LAST_END_OF_LIST                                               */
 /*          NODE2                                                          */
 /*          TRACE                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          NODE                                                           */
 /* CALLED BY:                                                              */
 /*          OPTIMISE                                                       */
 /***************************************************************************/
                                                                                03925010
 /* REMOVES EXTN'S FROM NODE LIST IN ARRAYED STMT.  PTR IS NEXT VACANT          03925020
      ENTRY IN NODE LIST*/                                                      03925030
PURGE_EXTNS:                                                                    03925040
   PROCEDURE(PTR);                                                              03925050
      DECLARE (PTR,INX) BIT(16);                                                03925060
      IF TRACE THEN OUTPUT = 'PURGE EXTNS:  ' || PTR;                           03925070
      INX = NODE2(LAST_END_OF_LIST + 2); /* OPTYPE*/                            03925080
      DO WHILE INX < PTR;                                                       03925090
         IF (NODE(INX) & "FFFF") = EXTN THEN                                    03925100
            NODE(INX) = 0;                                                      03925110
         INX = INX + 2;                                                         03925120
         IF INX < PTR THEN                                                      03925130
            INX = NODE2(INX);  /* NEXT OPTYPE*/                                 03925140
      END;                                                                      03925150
   END PURGE_EXTNS;                                                             03925160
