 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   MULTIPLY.xpl
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
 /* PROCEDURE NAME:  MULTIPLY_DIMS                                          */
 /* MEMBER NAME:     MULTIPLY                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LAST              BIT(16)                                      */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          C_TRACE                                                        */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          OPR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          VU                                                             */
 /* CALLED BY:                                                              */
 /*          DENEST                                                         */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> MULTIPLY_DIMS <==                                                   */
 /*     ==> VU                                                              */
 /*         ==> HEX                                                         */
 /***************************************************************************/
                                                                                01896120
                                                                                01896130
                                                                                01896140
 /* MULTIPLYS DIMENSION OPERANDS AND NOP'S THE LAST ONE*/                       01896150
MULTIPLY_DIMS:                                                                  01896160
   PROCEDURE(LAST,PTR);                                                         01896170
      DECLARE (LAST,PTR) BIT(16);                                               01896180
      OPR(LAST) =                                                               01896190
         SHL(SHR(OPR(LAST),16) * SHR(OPR(PTR),16),16)    |     /* NEW DIM*/     01896200
         ((OPR(LAST) | OPR(PTR)) & "FFFF");                     /* NEW ALPHA*/  01896210
                                                                                01896220
      OPR(PTR) = 0;                                                             01896230
                                                                                01896240
      IF C_TRACE THEN DO;                                                       01896250
         OUTPUT = 'MULTIPLY_DIMS:  '||LAST||','||PTR;                           01896260
         CALL VU(LAST,1);                                                       01896270
         CALL VU(PTR,1);                                                        01896280
      END;                                                                      01896290
   END MULTIPLY_DIMS;                                                           01896300
