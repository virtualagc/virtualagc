 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   DENEST.xpl
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
 /* PROCEDURE NAME:  DENEST                                                 */
 /* MEMBER NAME:     DENEST                                                 */
 /* INPUT PARAMETERS:                                                       */
 /*          END_PTR           BIT(16)                                      */
 /*          TAG               BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          COUNT             FIXED                                        */
 /*          LAST              BIT(16)                                      */
 /*          PTR               BIT(16)                                      */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          C_TRACE                                                        */
 /*          DENEST_TAG                                                     */
 /*          FOR                                                            */
 /*          LOOP_HEAD                                                      */
 /*          OR                                                             */
 /*          STRUCTURE_COPIES                                               */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          A_PARITY                                                       */
 /*          AR_DIMS                                                        */
 /*          AR_SIZE                                                        */
 /*          DENEST#                                                        */
 /*          N_INX                                                          */
 /*          OPR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          POP_LOOP_STACKS                                                */
 /*          MULTIPLY_DIMS                                                  */
 /*          VU                                                             */
 /* CALLED BY:                                                              */
 /*          FINAL_PASS                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> DENEST <==                                                          */
 /*     ==> VU                                                              */
 /*         ==> HEX                                                         */
 /*     ==> POP_LOOP_STACKS                                                 */
 /*         ==> MOVE_LOOP_STACK                                             */
 /*     ==> MULTIPLY_DIMS                                                   */
 /*         ==> VU                                                          */
 /*             ==> HEX                                                     */
 /***************************************************************************/
                                                                                01896310
                                                                                01896320
 /* DENESTS ARRAY OR MIXED.  TAG INDICATES MIXED AR/VM DENEST. */               01896330
DENEST:                                                                         01896340
   PROCEDURE(END_PTR,TAG);                                                      01896350
      DECLARE TAG BIT(8);                                                       01896360
      DECLARE (PTR,LAST,END_PTR,I,TEMP) BIT(16);                                01896370
      DECLARE COUNT FIXED;                                                      01896380
                                                                                01896390
      IF C_TRACE THEN OUTPUT = 'DENEST:  '||END_PTR||','||TAG;                  01896400
      IF TAG THEN DO;      /* MIXED DENEST*/                                    01896410
                                                                                01896420
         IF AR_DIMS > 1 OR ^STRUCTURE_COPIES THEN DO;                           01896430
                                                                                01896440
            LAST = LOOP_HEAD(1) + AR_DIMS;  /* LAST DIM*/                       01896450
            PTR = LOOP_HEAD + 1;                                                01896460
            AR_SIZE(1) = AR_SIZE(1) * SHR(OPR(PTR),16);                         01896470
            CALL MULTIPLY_DIMS(LAST,PTR);                                       01896480
            OPR(LAST) = OPR(LAST) | DENEST_TAG;                                 01896490
            CALL POP_LOOP_STACKS(1);                                            01896500
            OPR(END_PTR) = 0;                                                   01896510
            OPR(PTR - 1) = "1 000 0";             /* NOP ADLP*/                 01896520
                                                                                01896530
            N_INX = N_INX - 1;                                                  01896540
            A_PARITY(N_INX) = A_PARITY(N_INX) & A_PARITY(N_INX + 1);            01896550
                                                                                01896560
                                                                                01896570
            IF C_TRACE THEN DO;                                                 01896580
               CALL VU(LAST,1);                                                 01896590
               CALL VU(PTR - 1,1);                                              01896600
            END;                                                                01896610
            DENEST# = DENEST# + 1;                                              01896620
         END;                                                                   01896630
                                                                                01896640
         TAG = 0;                                                               01896650
      END;                                                                      01896660
                                                                                01896670
      ELSE DO;                                                                  01896680
                                                                                01896690
         COUNT = 0;                                                             01896700
         DO FOR I = 1 TO AR_DIMS - 1 - STRUCTURE_COPIES;                        01896710
                                                                                01896720
            TEMP = LOOP_HEAD + AR_DIMS - I;                                     01896730
            CALL MULTIPLY_DIMS(TEMP,TEMP + 1);                                  01896740
            COUNT = COUNT + 1;                                                  01896750
                                                                                01896760
         END;                                                                   01896770
                                                                                01896780
         AR_DIMS = AR_DIMS - COUNT;                                             01896790
         OPR(LOOP_HEAD) = OPR(LOOP_HEAD) - SHL(COUNT,16);  /* FIXES NUMOP*/     01896800
         OPR(LOOP_HEAD + AR_DIMS) = OPR(LOOP_HEAD + AR_DIMS) | DENEST_TAG;      01896810
                                                                                01896820
         IF C_TRACE THEN CALL VU(LOOP_HEAD,AR_DIMS);                            01896830
                                                                                01896840
         DENEST# = DENEST# + 1;                                                 01896850
      END;                                                                      01896860
                                                                                01896870
                                                                                01896880
                                                                                01896890
   END DENEST;                                                                  01896900
