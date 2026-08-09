*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    alignment.asm
*/ Purpose:     Regression test for CNOP and @CNOP.
*/ Reference:   Derived from the object code of the original build,
*/              in ~/workspace/PFS/"OI301700 as received"/SSSRC,
*/              which lists what every statement actually assembled
*/              to.  CNOP is an assembler directive rather than an
*/              instruction, and so is not in the AP-101S POO.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ Note:        The operand counts HALFWORDS within a fullword, and
*/              the target is its parity.  CNOP 2 aligns to an EVEN
*/              halfword address, which is a fullword boundary, and
*/              CNOP 1 to an ODD one.  That is IBM's CNOP b,w with w
*/              fixed at a fullword and b counted in halfwords, 2
*/              standing where 0 would.
*/
*/              CNOP and @CNOP are two processors' directives, not
*/              two spellings of one, and each pads with its own
*/              no-op: the CPU's D800, which is also what NOP 0
*/              assembles to, and the MSC's C000.  Confirmed on 10
*/              and 59 padded instances in the original build, plus
*/              42 more that needed no padding and emitted nothing.
*/
*/              Addresses in the listing are HALFWORDS, and each DC
*/              H below advances by exactly one, so the parity at
*/              each directive can be read straight off the address
*/              column.  All six cases are covered: each directive
*/              both padding and not.
*/
*/              NOTHING HERE MAY REACH COLUMN 72.  That is the
*/              continuation column, and a comment line reaching it
*/              swallows the statement below.
T        CSECT
*/ At 00000, even.  CNOP 1 wants odd, so it pads with D800.
         CNOP  1
A1       DC    H'1'
*/ At 00002, even.  CNOP 2 wants even, so it emits nothing.
         CNOP  2
A2       DC    H'2'
*/ At 00003, odd.  CNOP 2 wants even, so it pads with D800.
         CNOP  2
A3       DC    H'3'
*/ At 00005, odd.  CNOP 1 wants odd, so it emits nothing.
         CNOP  1
A4       DC    H'4'
*/ At 00006, even.  @CNOP 2 wants even, so it emits nothing.
         @CNOP 2
A5       DC    H'5'
*/ At 00007, odd.  @CNOP 2 wants even, so it pads with C000.
         @CNOP 2
A6       DC    H'6'
         END
