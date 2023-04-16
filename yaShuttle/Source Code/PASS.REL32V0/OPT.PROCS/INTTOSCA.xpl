 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   INTTOSCA.xpl
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
 /* PROCEDURE NAME:  INT_TO_SCALAR                                          */
 /* MEMBER NAME:     INTTOSCA                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          N                 FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CONST_DW                                                       */
 /*          DW                                                             */
 /*          SUB_TRACE                                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FOR_DW                                                         */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HEX                                                            */
 /* CALLED BY:                                                              */
 /*          COMPUTE_DIM_CONSTANT                                           */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> INT_TO_SCALAR <==                                                   */
 /*     ==> HEX                                                             */
 /***************************************************************************/
                                                                                01597010
 /* CONVERTS INTEGER N TO SCALAR*/                                              01597020
INT_TO_SCALAR:                                                                  01597030
   PROCEDURE(N);                                                                01597040
      DECLARE N FIXED;                                                          01597050
      DW(0) = DW(8);                                                            01597060
      DW(1) = N;                                                                01597070
      CALL INLINE("2B",0,0);                                                    01597080
      CALL INLINE("58",1,0,FOR_DW);                                             01597090
      CALL INLINE("6A",0,0,1,0);                                                01597100
      CALL INLINE("60",0,0,1,0);                                                01597110
      IF SUB_TRACE THEN                                                         01597120
         OUTPUT = '   ' || N || ' CONVERTED TO SCALAR IS ' ||                   01597130
         HEX(DW(0),8) || HEX(DW(1),8);                                          01597140
                                                                                01597150
 /*  DW, DW(1) CONTAINS DOUBLE SCALAR VERSION OF N*/                            01597160
                                                                                01597170
   END INT_TO_SCALAR;                                                           01597180
