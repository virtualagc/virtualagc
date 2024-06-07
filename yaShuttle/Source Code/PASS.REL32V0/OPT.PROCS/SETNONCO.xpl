 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETNONCO.xpl
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
 /* PROCEDURE NAME:  SET_NONCOMMUTATIVE                                     */
 /* MEMBER NAME:     SETNONCO                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          OP                BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          NONCOMMUTATIVE    BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AND                                                            */
 /*          FALSE                                                          */
 /*          IADD                                                           */
 /*          IIPR                                                           */
 /*          ISHP                                                           */
 /*          MADD                                                           */
 /*          MSHP                                                           */
 /*          MSUB                                                           */
 /*          OK                                                             */
 /*          OR                                                             */
 /*          RTRN                                                           */
 /*          SADD                                                           */
 /*          SSPR                                                           */
 /*          TASN                                                           */
 /*          TRACE                                                          */
 /*          TRUE                                                           */
 /*          VADD                                                           */
 /*          VSUB                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          BIT_TYPE                                                       */
 /*          REVERSE_OP                                                     */
 /*          TRANSPARENT                                                    */
 /*          TWIN_OP                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HEX                                                            */
 /* CALLED BY:                                                              */
 /*          GROW_TREE                                                      */
 /*          GET_NODE                                                       */
 /*          STRIP_NODES                                                    */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SET_NONCOMMUTATIVE <==                                              */
 /*     ==> HEX                                                             */
 /***************************************************************************/
                                                                                01748090
 /* SETS NONCOMMUTATIVE*/                                                       01749000
SET_NONCOMMUTATIVE:                                                             01750000
   PROCEDURE(OP);                                                               01751000
      DECLARE OP BIT(16);                                                       01752000
      DECLARE NONCOMMUTATIVE BIT(8);                                            01753000
      IF TRACE THEN OUTPUT = HEX(OP,4) || ': SET_NONCOMMUTATIVE';               01754000
      TWIN_OP,                                                                  01755000
         BIT_TYPE = FALSE;                                                      01756000
      NONCOMMUTATIVE = TRUE;                                                    01757000
      TRANSPARENT = (OP & "FF") = "01" & SHR(OP,8) ^= 0;                        01758000
      TRANSPARENT = TRANSPARENT & ((OP & "F00") ^= "F00");                      01758010
                                                                                01758020
      DO CASE (SHR(OP,8) & "F") ;                                               01759000
                                                                                01760000
         IF OP = RTRN OR OP = TASN                              /* CLASS 0*/    01760010
            OR (OP >= MSHP AND OP <= ISHP) THEN                                 01760020
            TRANSPARENT = TRUE;                                                 01760030
         DO;                  /* 1 = BIT*/                                      01761000
            BIT_TYPE = TRUE;                                                    01762000
            IF OP > "105" THEN DO;                                              01763000
               IF OP THEN      /* CONVERSION*/                                  01764000
                  TRANSPARENT = TRUE;                                           01765000
            END;                                                                01766000
            ELSE IF OP >= "102" & OP <= "103" THEN                              01767000
               NONCOMMUTATIVE = FALSE;   /* &,| */                              01768000
         END; ;                                                                 01769000
                                                                                01770000
            IF OP = MADD THEN DO; /* 3 = MATRIX*/                               01771000
            NONCOMMUTATIVE = FALSE;                                             01772000
            REVERSE_OP = MSUB;                                                  01773000
         END;                                                                   01774000
                                                                                01775000
         IF OP = VADD THEN DO;   /*4 = VECTOR*/                                 01776000
            NONCOMMUTATIVE = FALSE;                                             01777000
            REVERSE_OP = VSUB;                                                  01778000
         END;                                                                   01779000
                                                                                01780000
         IF OP = SADD | OP = SSPR THEN DO;   /*5 = SCALAR*/                     01781000
            NONCOMMUTATIVE = FALSE;                                             01782000
            REVERSE_OP = OP + 1;                                                01783000
         END;                                                                   01784000
                                                                                01785000
         IF OP = IADD | OP = IIPR THEN DO;     /*6 = INTEGER*/                  01786000
            NONCOMMUTATIVE = FALSE;                                             01787000
            REVERSE_OP = OP + 1;                                                01788000
         END;                                                                   01789000
                                                                                01790000
         TRANSPARENT = TRUE;                /*7 = CONDITIONAL*/                 01791000
         ;;;;;;;                                                                01792000
                                                                                01793000
            DO;            /* F = BUILT IN FN*/                                 01794000
            REVERSE_OP = SHR(OK(OP & "FF"),1) | "F00";                          01795000
            TWIN_OP = REVERSE_OP ^= "F00";                                      01796000
         END;                                                                   01797000
      END;  /* DO CASE*/                                                        01798000
      RETURN NONCOMMUTATIVE;                                                    01799000
   END SET_NONCOMMUTATIVE;                                                      01800000
