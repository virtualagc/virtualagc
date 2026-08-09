*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    arith.asm
*/ Purpose:     Regression test for assembly-time arithmetic, in
*/              particular division.
*/ Reference:   GC28-6514-8 p.28.  Division yields an INTEGER
*/              result with any fractional portion dropped, and
*/              division by zero yields zero rather than failing.
*/              Truncation is toward zero, so -7/2 is -3 and not
*/              the -4 that a floor division would give.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ Note:        While `/` was Python true division, every
*/              quotient came back as a float, which then reached
*/              `unhash` and raised TypeError on a bitwise AND.
*/              That was 14 of OI340600's crashes.
*/
*/              NOTHING HERE MAY REACH COLUMN 72.  That is the
*/              continuation column, and a comment line that
*/              reaches it swallows the statement below it.
         MACRO
         DIV
         LCLA  &A,&B,&C,&D,&E,&F
&A       SETA  7/2
&B       SETA  -7/2
&C       SETA  7/-2
&D       SETA  6/3
&E       SETA  1/0
&F       SETA  100/7/2
         MNOTE '7/2=&A  -7/2=&B  7/-2=&C'
         MNOTE '6/3=&D  1/0=&E  100/7/2=&F'
         MEND
         MACRO
         MIX
         LCLA  &G,&H
&G       SETA  (10+5)/4
&H       SETA  3*7/2
         MNOTE '(10+5)/4=&G  3*7/2=&H'
         MEND
T        CSECT
         DIV
         MIX
         END
