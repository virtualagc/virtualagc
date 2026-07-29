*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV6S3.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV6S3 -- VECTOR DOT PRODUCT,LENGTH 3,SINGLE PREC'       00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV6S3    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
*  COMPUTES THE DOT PRODUCT:                                            00000400
*                                                                       00000500
*   S= V1(3) . V2(3)                                                    00000600
*                                                                       00000700
*   WHERE S,V1,V2 ARE SP                                                00000800
*                                                                       00000900
         INPUT R2,            VECTOR(3)  SP                            X00001000
               R3             VECTOR(3)  SP                             00001100
         OUTPUT F0            SCALAR     SP                             00001200
         WORK  F1,F2,F3                                                 00001300
*                                                                       00001400
*  ALGORITHM :                                                          00001500
*  S = V1(1)V2(1)+V1(2)V2(2)+V1(3)V2(3)                                 00001600
*                                                                       00001700
VV6S3X   LE    F0,2(R3)        X(1)                                     00001800
         ME    F0,2(R2)        X(1)*Y(1)                                00001900
         LE    F2,4(R3)        X(2)                                     00002000
         ME    F2,4(R2)        Y(2)*X(2)                                00002100
*
* The block below (through .VV6S3C) has two variants, selected at
* assembly time and completely invisible to any assembler other than
* the modern ASM101S.py (which is the only tool that ever pre-defines
* &ASM101S as true -- see its own comment at the point that happens).
* Any other/historical assembler never declares &ASM101S at all before
* this point, so the GBLB below freshly declares it defaulting to
* binary false, and assembles the ORIGINAL, unmodified logic (i.e.
* nothing extra here), producing byte-for-byte the same object code as
* before this comment block existed.
*
* THE BUG (yagpc2-yahalmat2-issues.db key
* vector_cross_product_diverges_on_exact_inputs, the dot-product
* sibling of that same finding): F0 and F2 are both loaded here with
* single-precision LE/ME, leaving their companion registers F1/F3
* uncleared -- but this AEDR is a genuine EXTENDED (64-bit) add. Unlike
* the SECOND AEDR below (a legitimate running-sum accumulation, where
* F0:F1 correctly and intentionally carries this AEDR''s own result
* forward as the extended-precision partial sum -- not touched by this
* fix), THIS FIRST AEDR is the dot product''s own starting point: F1
* and F3 have not yet been given any meaningful value by this routine,
* so whatever floating-point garbage is sitting in them from unrelated
* prior work (e.g. the same general class of finding as
* MM14SN.asm''s/VX6S3.asm''s own register-pair fragility) is folded into
* the very first partial sum and propagates through the second AEDR
* too. A single clear here, before any accumulation begins, fixes the
* whole chain without disturbing the intentional carry into the second
* AEDR (F3 is never written again by anything in this routine, and F1
* legitimately becomes this AEDR''s own real result immediately
* afterward).
*
         GBLB  &ASM101S
         AIF   (&ASM101S).VV6S3FIX
         AGO   .VV6S3CONT
.VV6S3FIX ANOP
         SER   F1,F1          CLEAR FIRST-TERM COMPANION REGISTER
         SER   F3,F3          CLEAR SECOND-TERM COMPANION REGISTER
.VV6S3CONT ANOP
         AEDR   F0,F2             X(1)Y(1)+X(2)Y(2)                     00002200
         LE    F2,6(R3)       X(3)                                      00002300
         ME    F2,6(R2)       X(3)*Y(3)                                 00002400
         AEDR   F0,F2             (X(1)Y(1)+X(2)Y(2))+X(3)Y(3)          00002500
           AEXIT                                                        00002600
         ACLOSE                                                         00002700
