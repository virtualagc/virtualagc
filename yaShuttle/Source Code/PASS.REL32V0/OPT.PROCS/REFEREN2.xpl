 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   REFEREN2.xpl
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
 /* PROCEDURE NAME:  REFERENCE                                              */
 /* MEMBER NAME:     REFEREN2                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          OLD               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FOR                                                            */
 /*          OPR                                                            */
 /*          TRACE                                                          */
 /*          XSMRK                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          NO_OPERANDS                                                    */
 /*          TERMINAL                                                       */
 /* CALLED BY:                                                              */
 /*          REARRANGE_HALMAT                                               */
 /*          COLLAPSE_LITERALS                                              */
 /*          RELOCATE_HALMAT                                                */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> REFERENCE <==                                                       */
 /*     ==> NO_OPERANDS                                                     */
 /*     ==> TERMINAL                                                        */
 /*         ==> VAC_OR_XPT                                                  */
 /*         ==> HALMAT_FLAG                                                 */
 /*             ==> VAC_OR_XPT                                              */
 /*         ==> CLASSIFY                                                    */
 /*             ==> PRINT_SENTENCE                                          */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /***************************************************************************/
                                                                                01901470
                                                                                01901480
                                                                                01917000
 /* STARTING AT PTR, LOOKS AHEAD TO FIRST VAC REFERENCING HALMAT_PTR*/          01917010
REFERENCE:                                                                      01917020
   PROCEDURE(PTR) BIT(16);                                                      01917030
      DECLARE (PTR,I,OLD) BIT(16);                                              01917040
      OLD = PTR;                                                                01917050
      DO WHILE (OPR(PTR) & "FFF1") ^= XSMRK;                                    01917060
         DO FOR I = PTR + 1 TO PTR + NO_OPERANDS(PTR);                          01917070
            IF ^TERMINAL(I) & SHR(OPR(I),16) = OLD THEN DO;                     01917080
               IF TRACE THEN OUTPUT = 'REFERENCE '|| OLD || ' IS '||I;          01917090
               RETURN I;                                                        01917100
            END;                                                                01917110
         END;                                                                   01917120
         PTR = PTR + 1 + NO_OPERANDS(PTR);                                      01917130
      END;                                                                      01917140
      RETURN PTR;                                                               01917150
   END REFERENCE;                                                               01917160
