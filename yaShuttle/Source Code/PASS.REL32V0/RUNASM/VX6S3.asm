*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VX6S3.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VX6S3--VECTOR CROSS PRODUCT, LENGTH 3, SP'              00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VX6S3    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* TAKES THE CROSS PRODUCT OF V1 AND V2 WHERE V1 AND V2 ARE SINGLE       00000400
*   PRECISION VECTORS.                                                  00000500
*                                                                       00000600
         INPUT R2,            VECTOR(3) SP                             X00000700
               R3             VECTOR(3) SP                              00000800
         OUTPUT R1            VECTOR(3) SP                              00000900
         WORK  F0,F1,F2,F3                                              00001000
*                                                                       00001100
* ALGORITHM:                                                            00001200
*   SEE ALGORITHM DESCRIPTION IN VX6D3                                  00001300
*                                                                       00001400
VX6S3X   LE    F0,4(R2)       V2$(2)                                    00001500
         ME    F0,6(R3)       V2$(2) V3$(3)                             00001600
         LE    F2,6(R2)       V2$(3)                                    00001700
         ME    F2,4(R3)       V2$(3) V3$(2)                             00001800
*
* The blocks below (through .VX6S3C3) have two variants each, selected
* at assembly time and completely invisible to any assembler other than
* the modern ASM101S.py (which is the only tool that ever pre-defines
* &ASM101S as true -- see its own comment at the point that happens).
* Any other/historical assembler never declares &ASM101S at all before
* this point, so the GBLB below freshly declares it defaulting to
* binary false, and assembles the ORIGINAL, unmodified logic (i.e.
* nothing extra here), producing byte-for-byte the same object code as
* before this comment block existed.
*
* THE BUG (yagpc2-yahalmat2-issues.db key
* vector_cross_product_diverges_on_exact_inputs): F0 and F2 are both
* loaded here with single-precision LE/ME, leaving their companion
* registers F1/F3 uncleared -- but each SEDR below is a genuine
* EXTENDED (64-bit, F0:F1 -= F2:F3) subtract. The three cross-product
* components computed here (V2(2)V3(3)-V2(3)V3(2), etc.) are
* mathematically INDEPENDENT of each other -- there is no legitimate
* reason for one component''s own extended remainder to influence the
* next component''s computation. But since F1 is only ever written by
* SEDR''s own extended result (never reset), it genuinely chains
* forward from each SEDR call to the next; F3 is never written by
* anything in this routine at all, so it carries forward whatever
* floating-point-heavy RTL call happened to precede this one. This is
* the same class of finding as MM14SN.asm''s own register-pair
* fragility (datatypes_repeated_singular_inverse_unstable_result): a
* result silently depending on unrelated prior floating-point history
* is a defect in the original RTL, not intentional design, regardless
* of how faithfully it has been reproduced elsewhere. Confirmed via
* 072-EXAMPLE_2.hal: V_PRIME=(14,32,50) x E=(3,2,1) should be exactly
* (-68,136,-68) (no rounding possible, every value is a small exact
* integer) -- yaGPC2 gives (-6.7999985E+01,1.3600000E+02,-6.7999985E+01)
* whenever this call is NOT the very first floating-point-heavy RTL
* call in the program (i.e. F1/F3 do not start clean), the same
* symptom shape as id 53.
*
         GBLB  &ASM101S
         AIF   (&ASM101S).VX6S3F1
         AGO   .VX6S3C1
.VX6S3F1 ANOP
         SER   F1,F1          CLEAR FIRST OPERAND COMPANION REGISTER
         SER   F3,F3          CLEAR SECOND OPERAND COMPANION REGISTER
.VX6S3C1 ANOP
         SEDR  F0,F2          V2$(2) V3$(3) - V2$(3) V3$(2)             00001900
         STE   F0,2(R1)       FIRST ELEMENT OF RESULT                   00002000
         LE    F2,2(R2)       V2$(1)                                    00002100
         ME    F2,6(R3)       V2$(1) V3$(3)                             00002200
         LE    F0,6(R2)       V2$(3)                                    00002300
         ME    F0,2(R3)       V2$(3) V3$(1)                             00002400
*
* Second occurrence of the identical bug/fix split as above (see the
* comment block near .VX6S3F1).
*
         AIF   (&ASM101S).VX6S3F2
         AGO   .VX6S3C2
.VX6S3F2 ANOP
         SER   F1,F1          CLEAR FIRST OPERAND COMPANION REGISTER
         SER   F3,F3          CLEAR SECOND OPERAND COMPANION REGISTER
.VX6S3C2 ANOP
         SEDR  F0,F2          V2$(3) V3$(1) - V2$(1) V3$(3)             00002500
         STE   F0,4(R1)       2ND ELEMENT OF RESULT                     00002600
         LE    F0,2(R2)       V2$(1)                                    00002700
         ME    F0,4(R3)       V2$(1) V3$(2)                             00002800
         LE    F2,4(R2)       V2$(2)                                    00002900
         ME    F2,2(R3)       V2$(2) V3$(1)                             00003000
*
* Third occurrence of the identical bug/fix split as above (see the
* comment block near .VX6S3F1).
*
         AIF   (&ASM101S).VX6S3F3
         AGO   .VX6S3C3
.VX6S3F3 ANOP
         SER   F1,F1          CLEAR FIRST OPERAND COMPANION REGISTER
         SER   F3,F3          CLEAR SECOND OPERAND COMPANION REGISTER
.VX6S3C3 ANOP
         SEDR  F0,F2          V2$(1) V3$(2) - V2$(2) V3$(1)             00003100
         STE   F0,6(R1)       3RD ELEMENT OF RESULT                     00003200
         AEXIT                                                          00003300
         ACLOSE                                                         00003400
