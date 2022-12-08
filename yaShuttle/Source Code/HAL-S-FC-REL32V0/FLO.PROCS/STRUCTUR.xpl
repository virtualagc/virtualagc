 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   STRUCTUR.xpl
    Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
                generation process.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section 6.3.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  STRUCTURE_ADVANCE                                      */
 /* MEMBER NAME:     STRUCTUR                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          A                 BIT(16)                                      */
 /*          RE_ENTER          LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FOREVER                                                        */
 /*          KIN                                                            */
 /*          STRUCT_TEMPL                                                   */
 /*          SYM_LINK2                                                      */
 /*          SYM_LOCK#                                                      */
 /*          SYT_LINK2                                                      */
 /*          SYT_LOCK#                                                      */
 /*          TRUE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          SYM_TAB                                                        */
 /*          STRUCT_REF                                                     */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          DESCENDENT                                                     */
 /*          SUCCESSOR                                                      */
 /* CALLED BY:                                                              */
 /*          STRUCTURE_WALK                                                 */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> STRUCTURE_ADVANCE <==                                               */
 /*     ==> DESCENDENT                                                      */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*     ==> SUCCESSOR                                                       */
 /***************************************************************************/
                                                                                00156100
 /* ROUTINE TO ADVANCE TO THE NEXT TERMINAL IN A STRUCTURE TEMPLATE */          00156200
STRUCTURE_ADVANCE:                                                              00156300
   PROCEDURE BIT(16);                                                           00156400
      DECLARE A BIT(16);                                                        00156500
      IF STRUCT_REF > 0 THEN GO TO RE_ENTER;                                    00156600
      STRUCT_REF, A = STRUCT_TEMPL;                                             00156700
      IF (SYT_LOCK#(A)&"80") ^= 0 THEN SYT_LINK2(A) = 0;                        00156800
      DO FOREVER;                                                               00156900
         DO WHILE DESCENDENT(A) > 0;                                            00157000
            A = KIN;                                                            00157100
         END;                                                                   00157200
         RETURN A;                                                              00157300
RE_ENTER:                                                                       00157400
         A = SUCCESSOR(A);                                                      00157500
         IF A < 0 THEN DO;                                                      00157600
            A = -A;                                                             00157700
            IF A = STRUCT_REF THEN DO;                                          00157800
               STRUCT_REF = 0;                                                  00157900
               RETURN 0;                                                        00158000
            END;                                                                00158100
            GO TO RE_ENTER;                                                     00158200
         END;                                                                   00158300
      END;                                                                      00158400
   END STRUCTURE_ADVANCE;                                                       00158500
