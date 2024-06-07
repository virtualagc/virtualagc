 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SYTP.xpl
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
 /* PROCEDURE NAME:  SYTP                                                   */
 /* MEMBER NAME:     SYTP                                                   */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          SYM                                                            */
 /*          OPR                                                            */
 /* CALLED BY:                                                              */
 /*          ST_CHECK                                                       */
 /*          ASSIGNMENT                                                     */
 /***************************************************************************/
                                                                                01378000
 /* RETURNS 1 IF OPERAND WORD IS SYT POINTER*/                                  01379000
SYTP:                                                                           01380000
   PROCEDURE(PTR);                                                              01381000
      DECLARE PTR BIT(16);                                                      01382000
      IF (SHR(OPR(PTR),4) & "F") = SYM THEN RETURN 1;                           01383000
      RETURN 0;                                                                 01384000
   END SYTP;                                                                    01385000
