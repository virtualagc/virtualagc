*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    CINDEX.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'CINDEX--CHARACTER INDEX FUNCTION'                       00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
CINDEX   AMAIN                                                          00000200
*                                                                       00000300
* RETURNS THE INDEX, IF ANY, OF C2 IN C1 WHERE C1 AND C2 ARE            00000400
*   CHARACTER STRINGS.                                                  00000500
*                                                                       00000600
         INPUT R2,            CHARACTER(C1)                            X00000700
               R4             CHARACTER(C2)                             00000800
         OUTPUT R5            INTEGER SP                                00000900
         WORK  R1,R3,R6,R7,F0,F1,F2,F3,F4,F5                            00001000
*                                                                       00001100
* ALGORITHM:                                                            00001200
*   I = 1;                                                              00001300
*   IF CURRENT_LENGTH(C1) = 0 THEN                                      00001400
*     RETURN 0;                                                         00001500
*   IF CURRENT_LENGTH(C2) = 0 THEN                                      00001600
*     RETURN 0;                                                         00001700
*   END_OF_COMPARE = NAME(C1) + CURRENT_LENGTH(C1);                     00001800
*   IF CURRENT_LENGTH(C1) < CURRENT_LENGTH(C2) THEN                     00001900
*     RETURN 0;                                                         00002000
*   DO WHILE NAME(C1$(I)) + CURRENT_LENGTH(C2) <= END_OF_COMPARE;       00002100
*     DO FOR J = 1 TO CURRENT_LENGTH(C2);                               00002200
*       IF C1$(I - 1 + J) = C2$(J) THEN                                 00002300
*         REPEAT;                                                       00002400
*       ELSE                                                            00002500
*         GO TO NEWK;                                                   00002600
*     END;                                                              00002700
*     RETURN I;                                                         00002800
*   NEWK:                                                               00002900
*     I = I + 1;                                                        00003000
*   END;                                                                00003100
*                                                                       00003200
         LR    R3,R4          PUT C2 PTR INTO R3 FOR ADDRESSABILITY     00003300
         LFXI  R7,1           PUT A 1 IN R7                             00003400
         LFLR  F4,R3          SAVE PTR  TO STRING                       00003500
         LFLR  F2,R2          SAVE PTR TO C1 FOR PLACEMARK              00003600
         LFLR  F3,R2          SAVE PTR TO C1                            00003700
*
* The block below (through .CIXCONT) has two variants, selected at
* assembly time and completely invisible to any assembler other than the
* modern ASM101S.py (which is the only tool that ever pre-defines
* &ASM101S as true -- see its own comment at the point that happens).
* Any other/historical assembler never declares &ASM101S at all before
* this point, so the GBLB below freshly declares it defaulting to binary
* false, and assembles the ORIGINAL, unmodified logic that follows,
* producing byte-for-byte the same object code as before this comment
* block existed.
*
* THE BUG (yagpc2-yahalmat2-issues.db key cindex_not_found_overrun):
* END_OF_COMPARE is supposed to be NAME(C1) + CURRENT_LENGTH(C1), using
* the same per-character address-space unit GTBYTE's own pointer
* stepping uses (GTBYTE.asm: BYTEDISP DC X'00008000', i.e. 0x8000 per
* character, two characters packed per halfword). But R6 here, straight
* out of NHI R6,X'00FF' (which -- like every NHI on this CPU -- ANDs
* against the immediate shifted left 16 bits first), ends up as
* CURRENT_LENGTH(C1) positioned in bits 16-31, i.e. scaled by 0x10000 --
* exactly double GTBYTE's real 0x8000-per-character step. END_OF_COMPARE
* therefore lands twice as far from NAME(C1) as it should, letting the
* outer search run about twice as many iterations as it should before
* ever correctly detecting "out of bounds", walking off the end of C1's
* real character data and picking up a coincidental garbage byte-match.
*
         GBLB  &ASM101S
         AIF   (&ASM101S).CIXFIX
*
* ---------- ORIGINAL, HISTORICAL LOGIC (buggy; unmodified) ----------
*
         LH    R6,0(R2)       GET DESCRIPTOR OF C1                      00003800
         NHI   R6,X'00FF'     MASK OFF MAXIMUM_LENGTH                   00003900
         BZ    NO             IF CURRENT_LENGTH(C1) = 0 THEN RETURN     00004000
         LH    R1,0(R3)       GET DESCRIPTOR OF C2                      00004100
         NHI   R1,X'00FF'     MASK OFF MAXIMUM_LENGTH                   00004200
         BZ    NO             IF CURRENT_LENGTH(C2) = 0 THEN RETURN     00004300
         LFLR  F1,R1          SAVE CURRENT_LENGTH(C2)                   00004400
         AR    R2,R6          R2 <- NAME(C1) + CURRENT_LENGTH(C1)       00004500
         LFLR  F5,R2          F5 <- END_OF_COMPARE                      00004600
         CR    R6,R1          COMPARE CURRENT_LENGTH(C1) &              00004700
*                             CURRENT_LENGTH(C2)                        00004800
         BL    NO             IF < THEN RETURN                          00004900
         AGO   .CIXCONT
*
* ---------- FIXED LOGIC (ASM101S.py-assembled builds only) ----------
*
.CIXFIX  ANOP
         LH    R6,0(R2)       GET DESCRIPTOR OF C1
         NHI   R6,X'00FF'     MASK OFF MAXIMUM_LENGTH
         BZ    NO             IF CURRENT_LENGTH(C1) = 0 THEN RETURN
         LH    R1,0(R3)       GET DESCRIPTOR OF C2
         NHI   R1,X'00FF'     MASK OFF MAXIMUM_LENGTH
         BZ    NO             IF CURRENT_LENGTH(C2) = 0 THEN RETURN
         LFLR  F1,R1          SAVE CURRENT_LENGTH(C2)
*                             COMPARE MUST HAPPEN BEFORE R6 IS RESCALED
*                             BELOW, WHILE R6/R1 SHARE THE SAME SCALE
         CR    R6,R1          COMPARE CURRENT_LENGTH(C1) &
*                             CURRENT_LENGTH(C2)
         BL    NO             IF < THEN RETURN
         SRL   R6,1           THE FIX: RESCALE FROM NHI'S 0X10000-PER-
*                             CHARACTER UNIT TO GTBYTE'S REAL 0X8000-
*                             PER-CHARACTER ADDRESS-SPACE UNIT
         AR    R2,R6          R2 <- NAME(C1) + CURRENT_LENGTH(C1),
*                             CORRECTLY SCALED
         LFLR  F5,R2          F5 <- END_OF_COMPARE
.CIXCONT ANOP
NEXTC    LFXR  R2,F3          GET C1 PTR BACK                           00005000
         ABAL  GTBYTE         GET A CHARACTER OF C1                     00005100
         LFLR  F3,R2          SAVE INCREMENTED C1 PTR                   00005200
         LR    R6,R5          SAVE CHARACTER OF C1                      00005300
NEXTK    LFXR  R2,F4          GET C2 PTR BACK                           00005400
         ABAL  GTBYTE         GET A CHARACTER OF C2                     00005500
         LFLR  F4,R2          SAVE INCREMENTED C2 PTR                   00005600
         CR    R6,R5          COMPARE C1 CHAR WITH C2 CHAR              00005700
         BNE   NEWK           IF ^= GO TO NEW COMPARE LOOP              00005800
         BCTB  R1,NEXTC       ELSE CONTINUE COMPARING CHARS             00005900
*                             UP TO CURRENT_LENGTH(C2)                  00006000
         B     OUT            IF GET HERE THEN C1 FOUND IN C2           00006100
NEWK     LFXR  R2,F2          GET PLACEMARK                             00006200
         AHI   R7,1           BUMP I                                    00006300
         ABAL  GTBYTE         CALL GTBYTE TO UPDATE PLACEMARK           00006400
         LFXR  R1,F1          RESET INNER LOOP COUNTER                  00006500
         LFXR  R5,F5          GET BACK END_OF_COMPARE                   00006600
*
* Second occurrence of the identical historical bug/fix split as above
* (see the comment block near .CIXFIX): PLACEMARK + CURRENT_LENGTH(C2)
* is address arithmetic (added to real pointer R2), so it needs the
* same GTBYTE-per-character rescaling as END_OF_COMPARE did. The
* original code below uses R1 directly (wrong scale for this add, but
* R1 itself must stay untouched -- BCTB, above this block, still needs
* it afterward as a plain, unscaled loop counter for the *next* pass).
*
         AIF   (&ASM101S).CIXFIX2
         AR    R2,R1          GET PLACEMARK + CURRENT_LENGTH(C2)        00006700
         CR    R2,R5          COMPARE THIS WITH END_OF_COMPARE          00006800
         BH    NO             IF > THEN C2 NO LONGER FITS               00006900
*                             IN REMAINDER OF C1                        00007000
         SR    R2,R1          GET BACK PLACEMARK                        00007100
         AGO   .CIXCONT2
.CIXFIX2 ANOP
         LR    R6,R1          COPY (R1 ITSELF MUST STAY UNSCALED FOR
*                             BCTB'S NEXT USE, SO RESCALE A COPY)
         SRL   R6,1           SAME RESCALING AS THE FIRST OCCURRENCE
         AR    R2,R6          GET PLACEMARK + CURRENT_LENGTH(C2),
*                             CORRECTLY SCALED
         CR    R2,R5          COMPARE THIS WITH END_OF_COMPARE
         BH    NO             IF > THEN C2 NO LONGER FITS
*                             IN REMAINDER OF C1
         SR    R2,R6          GET BACK PLACEMARK (SAME R6 AS THE ADD
*                             ABOVE, SO THIS EXACTLY UNDOES IT)
.CIXCONT2 ANOP
         LFLR  F3,R2          SAVE PLACEMARK                            00007200
         LFLR  F2,R2          SAVE PLACEMARK                            00007300
         LFLR  F4,R3          SAVE PTR TO S2                            00007400
         B     NEXTC                                                    00007500
NO       SR    R7,R7          RETURN ZERO IF NOT FOUND                  00007600
OUT      ST    R7,ARG5                                                  00007700
         AEXIT                                                          00007800
         ACLOSE                                                         00007900
