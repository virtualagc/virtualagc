 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETINSTR.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

/***************************************************************************/
/* PROCEDURE NAME:  GET_INST_R_X                                           */
/* MEMBER NAME:     GETINSTR                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          BIT(16)                                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          AP101INST                                                      */
/*          RHS                                                            */
/*          RM                                                             */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          AM                                                             */
/*          F                                                              */
/*          IA                                                             */
/*          INST                                                           */
/*          IX                                                             */
/*          R                                                              */
/* CALLED BY:                                                              */
/*          OBJECT_CONDENSER                                               */
/*          OBJECT_GENERATOR                                               */
/***************************************************************************/
                                                                                07156000
 /* ROUTINE TO DECODE INSTRUCTIONS INTO COMPONENT PARTS  */                     07156500
GET_INST_R_X:                                                                   07157000
   PROCEDURE BIT(16);                                                           07157500
      R = SHR(RHS, 4) & RM;                                                     07158000
      IX = RHS & RM;                                                            07158500
      IA = SHR(RHS, 3) & 1;                                                     07159000
      INST = SHR(RHS, 8) & "FF";                                                07159500
      F = SHR(RHS, 7) & 1;                                                      07160000
      AM = 0;                                                                   07160500
      RETURN AP101INST(INST);                                                   07161000
   END GET_INST_R_X;                                                            07161500
