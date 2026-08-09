*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    constants.asm
*/ Purpose:     Regression test for DC duplication factors and
*/              for constants carrying more than one value.
*/ Reference:   GC28-6514-8, the DC pseudo-op.  A duplication
*/              factor replicates the whole constant that many
*/              times, and a factor of zero generates no data at
*/              all -- it is written to force an alignment or to
*/              attach a label and a length attribute.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ Note:        RUNASM contains no DC duplication factor anywhere
*/              and no multi-valued DC, so none of this is
*/              covered by regressionASM101S.sh even at 205 of
*/              205.  OI340600 has 165 of `DC 2F' alone.
*/
*/              Addresses in the listing are in HALFWORDS, so a
*/              fullword constant advances the location counter
*/              by 2.  A gap before a fullword that follows an
*/              odd number of halfwords is alignment padding,
*/              not data.
*/
*/              NOTHING IN THIS FILE MAY REACH COLUMN 72.  That
*/              is the continuation column, and a comment line
*/              that reaches it swallows the statement below.
D        CSECT
*/ One value, for a baseline.
B1       DC    F'1'
*/ Several values in one constant, each a separate fullword.
B2       DC    F'1,2'
B3       DC    F'1,2,3'
B4       DC    H'7,8'
*/ A duplication factor replicates the entire constant, values
*/ and all, so B6 is 1,2,1,2 and not 1,1,2,2.
B5       DC    3H'2'
B6       DC    2F'1,2'
*/ A negative value, and a zero factor that generates nothing.
B7       DC    F'-1'
B8       DC    0F'5'
*/ Floating point, which already flattened its value list
*/ correctly, and is here to keep it that way.
B9       DC    E'1.0,2.0'
*/ Address constants, singly, severally, and replicated.
BA       DC    Y(B1)
BB       DC    Y(B1,B2)
BC       DC    2Y(B1,B2)
BZ       DC    F'9'
*/ Length modifiers.  Ln is a length in bytes, L.n one in bits.
*/ RUNASM contains no length modifier at all, so none of this is
*/ covered by regressionASM101S.sh.
C1       DC    XL8'A'
C2       DC    XL.8'A'
C3       DC    FL2'1'
C4       DC    HL4'1'
*/ Character constants, which generated nothing whatever before
*/ 2026-08-09 -- no bytes, no advance, and no diagnostic.  They
*/ are EBCDIC, right-padded with blanks or truncated on the
*/ right to the length modifier, and '' is one quote.
C5       DC    C'AB'
C6       DC    CL4'AB'
C7       DC    CL1'AB'
C8       DC    C'A''B'
C9       DC    2C'X'
         END
