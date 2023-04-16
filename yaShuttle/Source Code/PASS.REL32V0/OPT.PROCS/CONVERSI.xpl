 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CONVERSI.xpl
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
 /* PROCEDURE NAME:  CONVERSION_TYPE                                        */
 /* MEMBER NAME:     CONVERSI                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CLASS             BIT(16)                                      */
 /*          OP                FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          OPR                                                            */
 /* CALLED BY:                                                              */
 /*          CHECK_COMPONENT                                                */
 /*          GROW_TREE                                                      */
 /***************************************************************************/
                                                                                01485000
 /* CHECKS IF HARMLESS CONVERSION OPERATOR*/                                    01486000
CONVERSION_TYPE:                                                                01487000
   PROCEDURE(PTR) BIT(8);                                                       01488000
      DECLARE (PTR,CLASS) BIT(16);                                              01489000
      DECLARE OP FIXED;                                                         01490000
      OP = OPR(PTR) & "FFFF 0FF F";                                             01491000
      CLASS = OPR(PTR) & "F000";                                                01492000
      IF (OP = "1 0A1 0" | OP = "1 0C1 0" ) & (CLASS = "5000" | CLASS = "6000") 01493000
         THEN RETURN 1;                                                         01494000
      RETURN 0;                                                                 01495000
   END CONVERSION_TYPE;                                                         01496000
