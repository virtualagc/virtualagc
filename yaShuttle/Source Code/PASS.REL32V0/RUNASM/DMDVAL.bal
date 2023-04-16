*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    DMDVAL.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'DMDVAL - MIDDLE VALUE SELECT - DOUBLE PRECISION'        00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
*                                                                       00000202
*   REVISION HISTORY:                                                   00000302
*                                                                       00000402
*      DATE       NAME  DR/SSCR#   DESCRIPTION                          00000502
*      --------   ----  --------   -----------------------------------  00000602
*      12/16/89   JAC   DR103762   REPLACED QCED/QCEDR MACRO WITH       00000702
*                                  CED/CEDR INSTRUCTION                 00000802
*      01/26/93   RAH   CR11163    REPLACED COMP MACRO WITH IBMCEDR
*                                  MACRO AND CORRECTED COMMENTS FOR
*                                  A=B CONDITION.
*                                                                       00000902
         MACRO                                                          00001400
&L       RETURN &A                                                      00001500
         AIF   ('&A' EQ 'A').NOLOAD                                     00001600
&L       LER   F0,&A          LOAD RETURN REG WITH ANSWER               00001700
         LER   F1,&A+1                                                  00001800
         B     EXIT           RETURN TO CALLER                          00001900
         MEXIT                                                          00002000
.NOLOAD  ANOP                                                           00002100
EXIT     AEXIT RETURN WITH RESULT ALREADY IN F0                         00002200
         MEND                                                           00002300
DMDVAL   AMAIN                                                          00002400
*                                                                       00002500
*  FIND MID VALUE OF 3 ARG.                                             00002600
*                                                                       00002700
*                                                                       00002800
         INPUT F0,            SCALAR  DP                               X00002900
               F2,            SCALAR  DP                               X00003000
               F4             SCALAR  DP                                00003100
         OUTPUT F0            SCALAR  DP                                00003200
         WORK  F1                                                       00003300
*                                                                       00003400
*                                                                       00003500
*  ALGORITHM                                                            00003600
*                                                                       00003700
*DMDVAL: FUNCTION(A,B,C) SCALAR DOUBLE;                                 00003800
*        DECLARE DOUBLE, A,B,C;                                         00003900
*        IF A<=B THEN DO;                                               00004000
*              IF A=B THEN RETURN A;  /* A=B */
*              IF B<=C THEN RETURN B; /* A<B<=C */                      00004100
*              ELSE IF A<=C THEN RETURN C; /*A<=C<B */                  00004200
*                   ELSE RETURN A; /* C<A<B */                          00004300
*        END;                                                           00004400
*        ELSE DO;                                                       00004500
*              IF C<=B THEN RETURN B; /* C<=B<A */                      00004600
*              ELSE IF C<A THEN RETURN C; /* B<C<A */                   00004700
*                  ELSE RETURN A; /* B<A<=C */                          00004800
*        END;                                                           00004900
*                                                                       00005000
A        EQU   F0                                                       00005100
B        EQU   F2                                                       00005200
C        EQU   F4                                                       00005300
*                                                                       00005400
         IBMCEDR A,B                                                    00005500
         BH    BLTA           BR IF B<A                                 00005600
         AEXIT COND=E                                                   00005700
*                                                                       00005800
*        A LESS THAN B SECTION (ALTB)                                   00005900
*                                                                       00006000
         IBMCEDR B,C                                                    00006100
         BH    CLTBALTB       BR IF C<B                                 00006200
RETB     RETURN B             A<B<=C                                    00006300
CLTBALTB IBMCEDR A,C                                                    00006400
         BH    CLTALTB        BR IF C<A                                 00006500
RETC     RETURN C             A<=C<B                                    00006600
*                                                                       00006700
*        B LESS THAN A SECTION                                          00006800
*                                                                       00006900
BLTA     IBMCEDR C,B                                                    00007000
         BNH   RETB           BR IF C<=B<A                              00007100
BLTCBLTA IBMCEDR C,A                                                    00007200
         BL    RETC           BR IF B<C<A                               00007300
*                                                                       00007400
*        COMMON RETURN A SECTION                                        00007500
CLTALTB  EQU   *              C<A<B                                     00007600
BLTALEC  EQU   *              B<A<=C                                    00007700
         RETURN A                                                       00007800
*                                                                       00007900
         ACLOSE                                                         00008000
