*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    SELECT.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

***********************************************************************
*  PROCEDURE: SELECT                                                  *
***********************************************************************
*  REVISION HISTORY                                                   *
*  ----------------                                                   *
*  DATE     NAME       REL    DR/CR AND TITLE                         *
*                                                                     *
*  1977     SCHULENBERG ??    BASELINE                                *
*                                                                     *
*  ????     ???         ??    ??????? - RETURN RVL FROM SDF           *
*                                                                     *
*  04/27/93 RSJ        25V0   CR11097 - ELIMINATE THE USE OF NOTELISTS*
*                       9V0   HAL COMPILER                            *
*                             IMPLEMENTATION OF CR11097 IS PROVIDED   *
*                             BY IBM CRAIG SCHULENBERG                *
***********************************************************************
         TITLE 'SELECT  -  SELECTS A DESIRED SDF MEMBER'
         GBLA  &FCBEXT
&FCBEXT  SETA  512            SIZE OF FCB SECONDARY ALLOCATIONS
SELECT   CSECT
*
         USING *,15
         B     *+12
         DC    CL8'SELECT  '
         BALR  15,0
         DROP  15
         OSSAVE
         USING COMMTABL,R10
         USING DATABUF,R11
         USING FCBCELL,R12
         XC    SAVEXTPT(8),SAVEXTPT INVALIDATE INFO FOR LAST BLOCK
         LTR   R12,R12        DO WE HAVE AN FCB?
         BZ    DOSELECT
         CLC   SDFNAM,FILENAME  SEE IF ALREADY SELECTED
         BE    EXIT           SELECT ALREADY PERFORMED
         XC    CURFCB,CURFCB  INDICATE NO SELECTION YET!
*
DOSELECT L     R1,SLECTCNT
         A     R1,=F'1'       USE A 32-BIT ADD /*CR11097*/
         ST    R1,SLECTCNT
         L     R12,ROOT
         LTR   R12,R12        HAVE WE DONE ANY SELECTS YET?
         BNZ   COMPARE
         MVI   MODE,0
         B     BUILDFCB
COMPARE  CLC   SDFNAM,FILENAME
         BE    FOUND
         BH    RIGHT
LEFT     L     R8,LTTREEPT
         LTR   R8,R8
         BNZ   GOLEFT
         MVI   MODE,1
         B     BUILDFCB
GOLEFT   LR    R12,R8
         B     COMPARE
RIGHT    L     R8,GTTREEPT
         LTR   R8,R8
         BNZ   GORIGHT
         MVI   MODE,2
         B     BUILDFCB
GORIGHT  LR    R12,R8
         B     COMPARE
*
FOUND    ST    R12,CURFCB
         MVC   SDFVERS,VERSIONX
         BAL   R7,DOFIND     PERFORM A FIND FOR THE MEMBER
         B     EXIT
*
BUILDFCB EQU   *
         MVC   NAME,SDFNAM
*
*        ENSURE THAT ANY PREVIOUS WRITE HAS COMPLETED
*
         L     R6,ADECB       R6 = ADDRESS OF THE DECB
         CLI   IOFLAG,0       WRITE IN PROGRESS?
         BE    NOCHECK
         CHECK (R6)           WAIT FOR COMPLETION
         MVI   IOFLAG,0       INDICATE COMPLETED
NOCHECK  L     R8,DCBADDR
         BLDL  (R8),BLDLAREA
         LTR   R15,R15
         BZ    GETRVL
         MVI   RETCODE+3,8    INDICATE BLDL FAILURE
         B     EXIT
*
*        GET REVISION LEVEL
*
************************ CR11097 *********************************
* PMF ALWAYS INSERTS THE RVL IMMEDIATELY AFTER THE "LAST" TTRN.  *
* SINCE CR11097 ELIMINATE TTRNS, WE NEED TO ADD LOGIC            *
* TO SUPPORT THE CASE OF NO TTRNS.  (PREVIOUSLY THERE WAS ALWAYS *
* AT LEAST 1)                                                    *
*                                                                *
* THE NEW LAYOUT OF THE SDF PDS USER DATA AREA IS THUS:          *
*     2-BYTES EBCDIC RVL (PMF) (FORMERLY HI-ORDER PART OF TTRN1) *
*     2-BYTES OF ZERO (FORMERLY LOW-ORDER PART OF TTRN1)         *
*     4-BYTES OF ZERO (FORMERLY RESERVED FOR TTRN2)              *
*     4-BYTES OF ZERO (FORMERLY RESERVED FOR TTRN3)              *
*     2-BYTES LAST PAGE VALUE (LAST SDF PAGE)                    *
*                                                                *
* FOR BACKWARDS COMPATIBILITY, THE NEW ALGORITHM SUPPORTS EITHER *
* 0, 1, 2, OR 3 TTRNS.                                           *
*                                                                *
* THE C BYTES DESCRIBES THE NUMBER OF TTRNS IN THE SDF MEMBER    *
******************************************************************
GETRVL   SR    R4,R4          ZERO R4 FOR IC TO FOLLOW
         STH   R4,BLKNO       SHOW NO REVISION LEVEL OBTAINED
         IC    R4,C           GET C BYTE IN LOWEST BYTE OF R4
         SRL   R4,3           GET NUMBER OF BYTES OF USER TTRNS
         N     R4,=X'0000000C' R4 WILL BE 0, 4, 8, OR 12
         CH    R4,=H'8'       ONLY ACCEPT UP TO 8 TTR BYTES
         BH    GETCAT         SKIP THE STORING OF REVISION LEVEL
         LH    R1,TTRN1(R4)   FETCH REVISION LEVEL (TTRN1,2,OR 3)
         STH   R1,BLKNO       STORE REVISION LEVEL (2 EBCDIC CHARS)
GETCAT   SR    R2,R2          ZERO R2 FOR IC TO FOLLOW
         IC    R2,K           PICK UP THE 'K' BYTE (CATENATION LEVEL)
         LA    R2,1(R2)       INCREMENT BY 1 (CAT LVLS GO 1,2,3...)
         STH   R2,SYMBNO      RETURN TO THE USER IN SYMBNO
******************** END CR11097 *********************************
*
*        ALLOCATE AN FCB
*
BLDLOK   LH    R1,PGELAST
         LA    R1,1(R1)       R1 = TOTAL # OF PAGES
         SLL   R1,3
         AH    R1,=AL2(FCBLEN)
         ST    R1,SIZE        SAVE # OF BYTES NEEDED
*
*        SET UP BASE ADDRESSES FOR FCB STACKS
*
         L     R6,FCBSTK1     R6 = ADDR OF FCB ADDRESS STACK
         L     R7,FCBSTK2     R7 = ADDR OF FCB LENGTH STACK
*
*        SEE IF WE HAVE ENOUGH SPACE ON HAND
*
         LH    R2,FCBSTKLN    R2 = # OF STACK ENTRIES
         SR    R5,R5          R5 = STACK ENTRY COUNTER
DOCOMP   C     R1,0(R5,R7)    COMPARE DESIRED LENGTH WITH STACK LENGTH
         BH    CONTINUE
         L     R1,0(R5,R6)
         ST    R1,NEXTFCB
         B     SPACEOK
CONTINUE LA    R5,4(R5)
         BCT   R2,DOCOMP
         CLI   GETMFLAG,0     CAN WE DO A GETMAIN?
         BNE   DOGETM         YES!
         MVI   RETCODE+3,12   NO. INDICATE SELECT HAS FAILED.
         STH   R1,NBYTES      TELL THE CALLER WHAT IS NEEDED
         B     EXIT
DOGETM   LH    R4,NUMGETM     R4 = # OF GETMAINS TO DATE
         CH    R4,MAXSTACK    SEE IF WE STILL HAVE STACK SPACE
         BE    ABEND2
         SLL   R4,2
         LH    R5,FCBSTKLN    R5 = # OF FCB AREAS TO DATE
         CH    R5,MAXSTACK    SEE IF WE STILL HAVE STACK SPACE
         BE    ABEND2
         SLL   R5,2
         LA    R0,&FCBEXT     GET SECONDARY EXTENT SIZE
         C     R0,SIZE        SEE IF IT WILL BE SUFFICIENT
         BNL   ENOUGH
         L     R0,SIZE        GET EXACTLY WHAT IS NEEDED
ENOUGH   L     R2,GETMSTK2
         ST    R0,0(R4,R2)    UPDATE LENGTH STACK (GETMAIN)
         ST    R0,0(R5,R7)    UPDATE LENGTH STACK (FCB AREA)
         GETMAIN R,LV=(0)
         LTR   R15,R15        SEE IF GETMAIN SUCCESSFUL
         BNZ   ABEND1         GETMAIN FAILURE!
         ST    R1,NEXTFCB     SET UP NEXTFCB FOR THIS SELECT
         L     R2,GETMSTK1
         ST    R1,0(R4,R2)    UPDATE ADDRESS STACK (GETMAIN)
         ST    R1,0(R5,R6)    UPDATE ADDRESS STACK (FCB AREA)
         LH    R4,FCBSTKLN
         LA    R4,1(R4)       UPDATE FCB AREA COUNTER
         STH   R4,FCBSTKLN
         LH    R4,NUMGETM
         LA    R4,1(R4)       INCREMENT GETMAIN COUNTER
         STH   R4,NUMGETM
*
SPACEOK  CLI   ONEFCB,0       ARE WE IN THE ONE FCB MODE?
         BE    CHECK0
         L     R1,RESERVES    YES. THE GLOBAL RESV CNT MUST BE 0
         LTR   R1,R1
         BNZ   ABEND3
*
*        LIBERATE THE ENTIRE PAGING AREA (DISCONNECT FROM FCB)
*
         L     R4,ADECB
         L     R3,PADADDR
         USING PDENTRY,R3
         LH    R2,NUMOFPGS
FLUSH    L     R12,FCBADDR
         LTR   R12,R12        IS THIS PAGE IN USE?
         BZ    NOWRITE
         CLI   MODFIND,0      IS IT IN A MODIFIED STATE?
         BE    NOWRITE
         MVC   BUFLOC,APGEBUFF
         LH    R1,PAGENO      R1 = PAGE # * 8
         L     R0,FCBTTRZ(R1)
         ST    R0,TTRWORD
         POINT (R8),TTRWORD
         READ  (R4),SF,MF=E
         CHECK (R4)
         MVC   BUFLOC,PAGEADDR
         WRITE (R4),SF,MF=E
         CHECK (R4)
NOWRITE  XC    FCBADDR(12),FCBADDR
         LA    R3,PDENTLEN(R3)
         BCT   R2,FLUSH
         DROP  R3
         L     R1,SIZE
         ST    R1,TOTFCBLN
         MVI   FCBCNT+3,1
         B     CONT
CHECK0   CLI   MODE,0
         BE    FIRSTX
         CLI   MODE,1
         BE    XLEFT
XRIGHT   MVC   GTTREEPT,NEXTFCB
         B     COMMON
XLEFT    MVC   LTTREEPT,NEXTFCB
         B     COMMON
FIRSTX   MVC   ROOT,NEXTFCB
*
*        UPDATE FCB AREA STACKS AND STATISTICS
*
COMMON   L     R1,SIZE
         A     R1,TOTFCBLN
         ST    R1,TOTFCBLN    SAVE TOTAL SIZE OF FCBS
         L     R1,FCBCNT
         LA    R1,1(R1)
         ST    R1,FCBCNT
         L     R0,0(R5,R6)    GET CURRENT ADDRESS
         A     R0,SIZE        INCREMENT BY AMOUNT OF SPACE TAKEN
         ST    R0,0(R5,R6)    UPDATE STACK ADDRESS
         L     R0,0(R5,R7)    GET CURRENT LENGTH
         S     R0,SIZE        DECREASE BY AMOUNT OF SPACE TAKEN
         ST    R0,0(R5,R7)    UPDATE STACK LENGTH
CONT     L     R12,NEXTFCB
         ST    R12,CURFCB
*
*        ZERO OUT THE NEW FCB
*
         SR    R0,R0
         L     R1,SIZE        R1 = # OF BYTES IN NEW FCB
         SRL   R1,2           GET # OF WORDS
         SR    R2,R2
ZERLOOP  ST    R0,0(R2,R12)
         LA    R2,4(R2)
         BCT   R1,ZERLOOP
*
*        BEGIN FCB INITIALIZATION
*
         MVC   TTRK(4),TTR       INSERT INFO FOR FIND MACRO IN FCB
         MVC   FILENAME,SDFNAM   INSERT FILE NAME IN THE FCB
*
*        PERFORM A FIND MACRO IN CASE WE ARE IN A CATENATION LEVEL
*
         BAL   R7,DOFIND         LEAVES R6 POINTING AT THE DECB
*
*        SET UP TTR FOR PAGE 0; SET UP R7 COUNTER FOR ALL SDF PAGES
*
*************************** CR11097 *********************************
* THE FOLLOWING LOGIC READS EVERY SDF PAGE SEQUENTIALLY (FROM PAGE 0*
* THRU THE LAST SDF PAGE)                                           *
* SAVE TTR'S OF PAGES INTO THE FCBTTRZ AREA                         *
*********************************************************************
         SR    R3,R3             USE R3 TO DISPLACE INTO FCB TTR AREA
         MVC   TTRWORD(4),TTR    GET THE TTR OF PAGE 0
         MVI   TTRWORD+3,0       ZERO OUT THE LOW-ORDER BYTE
         LH    R7,PGELAST        GET THE PAGE NUMBER OF THE LAST PAGE
         LA    R7,1(R7)          R7 = TOTAL NUMBER OF PAGES
*
*        INCREMENT THE GLOBAL READ COUNTER
*
         L     R1,READS          GET THE CURRENT NUMBER OF SDF READS
         AR    R1,R7             32-BIT ADD (NO 'LA' FOR US!)
         ST    R1,READS          INCREMENT BY THE NUMBER OF SDF PAGES
*
*        READ ALL PAGES SEQUENTIALLY AND DO A 'NOTE' MACRO TO OBTAIN
*        THE TTRS (AS OPPOSED TO FETCHING THEM FROM THE TTR PAGE!)
*
         POINT (R8),TTRWORD      R8 = DCB ADDRESS; POINT TO PAGE 0
         MVC   BUFLOC,APGEBUFF   ENSURE DECB SET UP FOR READ
READPAGE READ  (R6),SF,MF=E      READ THE SDF PAGE
         CHECK (R6)              WAIT FOR I/O COMPLETION
         NOTE  (R8)              USE THE NOTE MACRO TO GET THE TTR
         IC    R1,=X'00'         ZERO OUT THE LOW-ORDER BYTE
         ST    R1,FCBTTRZ(R3)    SAVE THE NEW TTR
         LA    R3,8(R3)          POINT TO THE NEXT FCB TTR SLOT
         BCT   R7,READPAGE       READ ALL DATA PAGES IN TURN
*********************** END CR11097 *********************************
*
*        NOW READ IN PAGE 0 AND FINISH THE NEW FCB
*
         SR    R1,R1
         CALL  LOCATE         LOCATE PAGE 0
         USING PAGEZERO,R1
         MVC   VERSIONX,VERSION
         MVC   SDFVERS,VERSIONX
         AH    R1,DROOTPTR+2
         USING DROOTCEL,R1
         CLC   LASTPAGE,PGELAST
         BH    ABEND4
         MVC   NUMBLKS,BLKNODES
         MVC   NUMSYMBS,SYMNODES
         MVC   FSTSTMT,FSTMTNUM
         MVC   LSTSTMT,LSTMTNUM
         MVC   LSTPAGE,LASTPAGE
         MVC   FLAGS,SDFFLAGS
         MVI   NODESIZE+1,4
         TM    FLAGS,X'80'
         BNO   NOSRNS
         MVI   NODESIZE+1,12
NOSRNS   MVC   BLKPTR,FBNPTR
         MVC   SYMBPTR,FSNPTR
         MVC   STMTPTR,FSTNPTR
         MVC   TREEPTR,BTREEPTR
         MVC   STMTEXPT,SNELPTR
         DROP  R1
*
EXIT     EQU   *
         OSRETURN
*
*        ROUTINE TO PERFORM FIND MACRO FOR NEWLY SELECTED MEMBER
*
DOFIND   L     R6,ADECB      R6 = ADDRESS OF DECB
         CLI   IOFLAG,0      IS THERE A WRITE IN PROGRESS?
         BE    NOCHECK1
         CHECK (R6)          WAIT FOR COMPLETION
         MVI   IOFLAG,0      INDICATE NO I/O ACTIVE
NOCHECK1 L     R8,DCBADDR    R8 = ADDRESS OF DCB
         FIND  (R8),(R12),C
         BR    R7
*
*        ABENDS
*
ABEND1   LA    R1,4018        FCB AREA EXHAUSTED AND GETMAIN FAILED!
         B     DOABEND
ABEND2   LA    R1,4021        EXHAUSTION OF INTERNAL STACKS
         B     DOABEND
ABEND3   LA    R1,4022        SELECT INVOKED WHILE PAGES RESERVED
         B     DOABEND        (ONEFCB MODE ONLY)
ABEND4   LA    R1,4023        SDF LENGTH MISMATCH (USER DATA FIELD BAD)
         B     DOABEND
*
DOABEND  ABEND (R1),DUMP
*
*        DATA AREA
*
         DS    0F
NEXTFCB  DS    A              ADDRESS OF NEW FCB
SIZE     DS    F              SIZE OF NEW FCB (BYTES)
TTRWORD  DS    F              CURRENT TTR
MODE     DS    CL1
*
*        BLDL AREA
*
         DS    0H
BLDLAREA EQU   *
FF       DC    H'1'
LL       DC    H'28' /*CR11097*/
NAME     DS    CL8
TTR      DS    CL3
K        DS    CL1
Z        DS    CL1
C        DS    CL1
TTRN1    DS    2H
TTRN2    DS    2H
TTRN3    DS    2H
PGELAST  DS    H
*
*        LITERAL POOL
*
         LTORG
*
*        DSECTS
*
         DATABUF
         COMMTABL
         PDENTRY
         FCBCELL
         PAGEZERO
         DROOTCEL
         END
