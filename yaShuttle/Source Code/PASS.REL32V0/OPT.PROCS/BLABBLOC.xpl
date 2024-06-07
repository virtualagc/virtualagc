 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   BLABBLOC.xpl
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
 /* PROCEDURE NAME:  BLAB_BLOCK                                             */
 /* MEMBER NAME:     BLABBLOC                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          START             BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          HR_SV             BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FOR                                                            */
 /*          NUMOP                                                          */
 /*          OPCODE                                                         */
 /*          OR                                                             */
 /*          TRUE                                                           */
 /*          XREC                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CLASS                                                          */
 /*          CTR                                                            */
 /*          HALMAT_REQUESTED                                               */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          DECODEPIP                                                      */
 /*          DECODEPOP                                                      */
 /* CALLED BY:                                                              */
 /*          PUT_HALMAT_BLOCK                                               */
 /*          CHICKEN_OUT                                                    */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> BLAB_BLOCK <==                                                      */
 /*     ==> DECODEPIP                                                       */
 /*         ==> FORMAT                                                      */
 /*     ==> DECODEPOP                                                       */
 /*         ==> FORMAT                                                      */
 /*         ==> HEX                                                         */
 /***************************************************************************/
                                                                                00588000
                                                                                00589000
 /* PRINTS HALMAT BLOCK AFTER OPTIMIZATION*/                                    00590000
BLAB_BLOCK:                                                                     00591000
   PROCEDURE(START);                                                            00592000
      DECLARE START BIT(16);                                                    00593000
      DECLARE I BIT(16);                                                        00594000
      DECLARE HR_SV BIT(8);                                                     00595000
      CTR = START;                                                              00596000
      HR_SV = HALMAT_REQUESTED;                                                 00597000
      HALMAT_REQUESTED = TRUE;                                                  00598000
      CLASS = 1;                                                                00599000
      DO WHILE CLASS ^= 0 OR OPCODE ^= XREC;                                    00600000
         CALL DECODEPOP(CTR);                                                   00601000
         IF OPCODE ^= 0 THEN                                                    00602000
            DO FOR I = 1 TO NUMOP;                                              00603000
            CALL DECODEPIP(I);                                                  00604000
         END;                                                                   00605000
         CTR = CTR + NUMOP + 1;                                                 00606000
      END;                                                                      00607000
      HALMAT_REQUESTED = HR_SV;                                                 00608000
   END BLAB_BLOCK;                                                              00609000
