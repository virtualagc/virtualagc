*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    OPENDIR.bal
*/ Purpose:     This is a part of the "Monitor" of the HAL/S-FC 
*/              compiler program.
*/ Reference:   "HAL/S Compiler Functional Specification", 
*/              section 2.1.1.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-07 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ are from the Virtual AGC Project.
*/              Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'OPENDIR, NEXTMEM, AND CLOSEDIR - PDS DIRECTORY ACCESS RX00000100
               OUTINES'                                                 00000200
*                                                                       00000300
*        ADR=OPENDIR(DDNAME); /* OPEN PDS DIRECTORY ON FILE DDNAME */   00000400
*INPUT   R1 - DESCRIPTOR OF DDNAME                                      00000500
*OUTPUT  R15 - ADR OF WORKAREA TO BE USED AS PARM TO NEXTMEM & CLOSEDIR 00000600
*                                                                       00000700
*        NAME=NEXTMEM(ADR); /* GET NEXT MEMBER NAME FROM DIRECTORY */   00000800
*                                 /* RETURN NULL IF END OF DIRECTORY */ 00000900
*INPUT   R1 - ADR FROM OPENDIR                                          00001000
*OUTPUT  R15 - DESCRIPTOR FOR MEMBER NAME                               00001100
*        WARNING: THIS DESCRIPTOR IS NOT IN THE FREE STRING AREA,       00001200
*        AND REMAINS VALID ONLY UNTIL NEXT CALL TO NEXTMEM              00001300
*                                                                       00001400
*        CALL CLOSEDIR(ADR); /* CLOSE OPENED DIRECTORY. MUST NOT BE     00001500
* /* DONE IF NEXTMEM RETURN NULL, AS CLOSE IS AUTOMATIC IN THIS CASE */ 00001600
*INPUT   R1 - ADR FROM OPENDIR                                          00001700
*                                                                       00001800
OPENDIR  CSECT                                                          00001900
         USING *,15               *                                     00002000
         SAVE  (14,12)            *                                     00002100
         ST    13,SAVE+4          *                                     00002200
         CNOP  0,4                *                                     00002300
         BAL   13,START           * BOOKKEEPING STUFF                   00002400
         USING *,13               *                                     00002500
SAVE     DS    18F                                                      00002600
*                                                                       00002700
*        GETMAIN WORK AREA AND COPY DCB W/ USER'S DDNAME                00002800
*                                                                       00002900
START    LTR   2,1                SAVE AND TEST DESCRIPT                00003000
         BZ    NULL               BR IF USER GOOFED                     00003100
         LA    0,DIRTOTL          LENGTH OF DCB AND EXTENSION           00003200
         GETMAIN R,LV=(0)                                               00003300
         LR    3,1                                                      00003400
         USING IHADCB,3                                                 00003500
         MVC   IHADCB(DCBLEN),MODELDCB COPY DCB AND EXTENSION           00003600
         LR    1,2                USER'S DESCRIPT                       00003700
         SRL   1,24               LENGTH-1                              00003800
         LA    0,7                INSURE USER'S DDNAME <=8              00003900
         CR    1,0                                                      00004000
         BNH   *+6                                                      00004100
         LR    1,0                                                      00004200
         EX    1,MOVEDDN                                                00004300
*                                                                       00004400
*        OPEN THE DCB                                                   00004500
*                                                                       00004600
         OPEN  ((3),(INPUT))                                            00004700
         TM    DCBOFLGS,DCBOFOPN DID IT GET OPENED?                     00004800
         BO    RET3               BR IF YES TO RETURN ADR               00004900
FREEMAIN LA    0,DIRTOTL          LENGTH OF AREA TO FREE                00005000
         FREEMAIN R,A=(3),LV=(0)                                        00005100
NULL     SR    3,3                                                      00005200
RET3     L     13,SAVE+4                                                00005300
         ST    3,16(,13)          SAVE IN SLOT FOR R15                  00005400
         RETURN (14,12)                                                 00005500
*                                                                       00005600
         ENTRY NEXTMEM                                                  00005700
NEXTMEM  DS    0H                                                       00005800
         USING *,15                                                     00005900
         SAVE  (14,12)                                                  00006000
         LR    12,13              *                                     00006100
         L     13,SAVEADR         * BOOKKEEPING STUFF                   00006200
         ST    12,SAVE+4          *                                     00006300
         DROP  15                 *                                     00006400
*                                                                       00006500
*        INSURE ADR IS VALID                                            00006600
*                                                                       00006700
         BAL   14,VALIDITY                                              00006800
*                                                                       00006900
*        LOCATE NEXT MEMBER                                             00007000
*                                                                       00007100
         LH    2,DIRNDX                                                 00007200
         CH    2,DIRLEN           DID WE INDEX TO END OF BLOCK?         00007300
         BL    GENDESC            BR IF NOT                             00007400
*                                                                       00007500
*        READ NEW DIRECTORY BLOCK                                       00007600
*                                                                       00007700
         LA    4,DIRBLK           BUFFER ADR                            00007800
         READ  RDIR,SF,(3),(4)                                          00007900
         CHECK RDIR                                                     00008000
         CLC   DIRLEN,H256        VALID DIR BLK HEADER?                 00008100
         BH    BADDIR             BR IF INVALID                         00008200
         LA    2,DIRDATA-DIRLEN   INDEX FOR 1ST NAME                    00008300
*                                                                       00008400
*        CREATE DESCRIPTOR FOR MEMBER NAME                              00008500
*                                                                       00008600
GENDESC  LA    1,DIRNAME(2)       POINT TO CURRENT MEMBER               00008700
         CLC   LASTNAME,0(1)      IS THIS END OF DIRECTORY?             00008800
         BE    CLOSE              BR IF YES                             00008900
         O     1,DESCLEN8         SET DESC LENGTH                       00009000
*                                                                       00009100
*        BUMP INDEX TO POINT TO NEXT NAME                               00009200
*                                                                       00009300
         SR    4,4                                                      00009400
         IC    4,DIRTTRN+3(2)     GET N OF TTRN                         00009500
         LA    0,X'1F'            MASK FOR # USER HALFWORDS             00009600
         NR    4,0                # HWS                                 00009700
         AR    4,4                # BYTES                               00009800
         LA    2,L'DIRNAME+L'DIRTTRN(2,4) BYTE INDEX TO NEXT NAME       00009900
         STH   2,DIRNDX           SAVE FOR NEXT CALL                    00010000
         LR    3,1                RETURN DESCRIPT                       00010100
         B     RET3                                                     00010200
*                                                                       00010300
MOVEDDN  MVC   DCBDDNAM(0),0(2)   COPY DDNAME TO DCB                    00010400
*                                                                       00010500
         ENTRY CLOSEDIR                                                 00010600
CLOSEDIR DS    0H                                                       00010700
         USING *,15                                                     00010800
         SAVE  (14,12)                                                  00010900
         LR    12,13              *                                     00011000
         L     13,SAVEADR         * BOOKKEEPING STUFF                   00011100
         ST    12,SAVE+4          *                                     00011200
         DROP  15                 *                                     00011300
*                                                                       00011400
*        INSURE ADR IS VALID                                            00011500
*                                                                       00011600
         BAL   14,VALIDITY                                              00011700
*                                                                       00011800
*        CLOSE AND FREEMAIN WORKAREA                                    00011900
*                                                                       00012000
CLOSE    CLOSE ((3))                                                    00012100
         B     FREEMAIN                                                 00012200
*                                                                       00012300
*        VALIDITY CHECK                                                 00012400
*                                                                       00012500
VALIDITY LTR   3,1                TEST AND SAVE ADR                     00012600
         BZ    BADADR                                                   00012700
         CLC   DIRVER,VERKEY                                            00012800
         BER   14                                                       00012900
*        FALL THRU TO BADADR                                            00013000
*                                                                       00013100
*        ERRORS                                                         00013200
*                                                                       00013300
BADADR   XPLABEND 10,'INCORRECT ADR IN NEXTMEM OR CLOSEDIR CALL'        00013400
BADDIR   XPLABEND 20,'NEXTMEM CALL: DATASET NOT PARTITIONED'            00013500
*                                                                       00013600
SAVEADR  DC    A(SAVE)                                                  00013700
DESCLEN8 DC    X'07000000'                                              00013800
LASTNAME DC    X'FFFFFFFFFFFFFFFF'                                      00013900
MODELDCB DCB   DSORG=PS,MACRF=R,LRECL=256,BLKSIZE=256,RECFM=F,DDNAME=X,X00014000
               SYNAD=BADDIR                                             00014100
H256     DC    H'256'             INITIAL BUFFER INDEX TO CAUSE READ    00014200
VERKEY   DC    C'OP*N_D'                                                00014300
         DC    H'0'               INITIAL DIRLEN AS ZERO TO FORCE READ  00014400
DCBLEN   EQU   *-MODELDCB                                               00014500
         PRINT NOGEN                                                    00014600
         DCBD DSORG=PS,DEVD=DA                                          00014700
         ORG   *-8                BSAM DCB SHORTER THAN QSAM            00014800
DIRNDX   DS    H                                                        00014900
DIRVER   DS    CL6                                                      00015000
DIRBLK   DS    XL256                                                    00015100
DIRTOTL  EQU   *-IHADCB                                                 00015200
         ORG   DIRBLK                                                   00015300
DIRNAME  DS    CL8                                                      00015400
DIRTTRN  DS    XL4                                                      00015500
         ORG   DIRBLK                                                   00015600
DIRLEN   DS    H                                                        00015700
DIRDATA  DS    XL254                                                    00015800
         END                                                            00015900
