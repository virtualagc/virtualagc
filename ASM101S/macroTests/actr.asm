*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    actr.asm
*/ Purpose:     Regression test for ACTR, the conditional-
*/              assembly loop counter.
*/ Reference:   SC26-4940, ACTR.  The assembler decrements the
*/              counter each time an AIF or AGO branch is TAKEN
*/              -- an AIF whose condition is false is not a
*/              branch and does not count -- and abandons the
*/              expansion when it goes negative.  The default
*/              when no ACTR appears is 4096.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ Note:        This is the assembler's own guard against a
*/              runaway AIF/AGO loop, and the AP-101S sources
*/              rely on it -- five files in OI340600's MLIB80
*/              set it explicitly, ENDCASE with 30000.  While it
*/              went unimplemented, such a loop simply never
*/              terminated, which is the one failure a corpus
*/              sweep cannot survive.
*/
*/              NOTHING HERE MAY REACH COLUMN 72.  That is the
*/              continuation column, and a comment line that
*/              reaches it swallows the statement below it.
*/
*/              &I is global so that it survives the abandoned
*/              expansion and can be reported afterwards; that
*/              count is what shows the loop was bounded rather
*/              than merely slow.
         GBLA  &I
         MACRO
         SPINAGO
         ACTR  50
&I       SETA  0
.LOOP    ANOP
&I       SETA  &I+1
         AGO   .LOOP
         MEND
         MACRO
         SPINAIF
         ACTR  30
&I       SETA  0
.LOOP    ANOP
&I       SETA  &I+1
         AIF   (&I GT 0).LOOP
         MEND
         MACRO
         FALSEAIF
         ACTR  5
&I       SETA  0
&I       SETA  &I+1
         AIF   (&I GT 99).NEVER
         AIF   (&I GT 99).NEVER
         AIF   (&I GT 99).NEVER
         AIF   (&I GT 99).NEVER
         AIF   (&I GT 99).NEVER
         AIF   (&I GT 99).NEVER
         AIF   (&I GT 99).NEVER
.NEVER   MNOTE 'FALSE AIFS DO NOT COUNT AGAINST ACTR: I=&I'
         MEND
         MACRO
         REPORT &WHAT
         GBLA  &I
         MNOTE '&WHAT: I=&I'
         MEND
T        CSECT
         SPINAGO
         REPORT AGO-LOOP-BOUNDED-BY-ACTR-50
         SPINAIF
         REPORT AIF-LOOP-BOUNDED-BY-ACTR-30
         FALSEAIF
         END
