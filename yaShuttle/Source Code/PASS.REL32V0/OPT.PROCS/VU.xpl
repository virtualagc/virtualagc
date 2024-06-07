 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   VU.xpl
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
 /* PROCEDURE NAME:  VU                                                     */
 /* MEMBER NAME:     VU                                                     */
 /* INPUT PARAMETERS:                                                       */
 /*          BEGIN             BIT(16)                                      */
 /*          NO                BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FOR                                                            */
 /*          OPR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HEX                                                            */
 /* CALLED BY:                                                              */
 /*          COMBINE_LOOPS                                                  */
 /*          DENEST                                                         */
 /*          INSERT_HALMAT_TRIPLE                                           */
 /*          MULTIPLY_DIMS                                                  */
 /*          PUT_VDLP                                                       */
 /*          SET_SAV                                                        */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> VU <==                                                              */
 /*     ==> HEX                                                             */
 /***************************************************************************/
                                                                                01460000
                                                                                01460010
 /* PRINT HALMAT*/                                                              01460020
VU:                                                                             01460030
   PROCEDURE(BEGIN,NO);                                                         01460040
      DECLARE (BEGIN,NO) BIT(16);                                               01460050
      DO FOR NO = BEGIN TO BEGIN + NO;                                          01460060
         OUTPUT =  '   HALMAT('|| NO || '):  ' || HEX(OPR(NO),8);               01460070
      END;                                                                      01460080
      OUTPUT = '';                                                              01460090
      NO = 0;                                                                   01460100
   END VU;                                                                      01460110
