 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SPACELIB.xpl
    Purpose:    Part of the HAL/S-FC compiler.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section TBD.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
/**********************************************************************/        00000010
/* MEMBER NAME:     SPACELIB                                          */        00000020
/* FUNCTION:        THIS FILE CONTAINS THE SPACE MANAGEMENT PROCEDURES*/        00000030
/*          AND DECLARATIONS AS WELL AS A NEW COMPACTIFY.             */        00000040
/*          IT SHOULD BE USED AS INPUT2 TO XPL.                       */        00000050
/*                                                                    */        00000060
/**********************************************************************/        00000070
/*  REVISION HISTORY :                                                */        00000080
/*  ------------------                                                */        00000090
/*  DATE   NAME  REL   DR NUMBER AND TITLE                            */        00000091
/*                                                                    */        00000092
/*04/15/82  ?     ?      ?    LINKLIB.SOURCE MODIFIED.                */        00000093
/*                                                                    */        00000094
/*02/16/94 HFG   27V0  104706 OC4 HALS101 COMPILER ABEND              */        00000095
/*                                                                    */        00000096
/*06/14/99 SMR   30V0  111339 ERROR IN SPACELIB FOR XPL RECORDS       */        00000095
/*               15V0                                                 */        00000096
/**********************************************************************/        00000097
                                                                                00000098
   /%DEBUG N+ L+ %/                                                             00000400
DECLARE _AS LITERALLY 'LITERALLY',                                              00000500
         _TRUE _AS '1',                                                         00000600
         _FALSE _AS '0',                                                        00000700
         _ANDIF _AS 'THEN IF';                                                  00000800
                                                                                00000900
DECLARE _IFA(1) _AS '/?A,%1%?/',                                                00001000
        _IFAQ(1) _AS '/?A,''%1%''?/';                                           00001100
/*DOPE VECTOR COMPONENTS FOLLOW*/                                               00001200
DECLARE _DOPE_POINTER(1) _AS 'COREWORD(%1%)',                                   00001300
        _DOPE_WIDTH(1) _AS 'COREHALFWORD(%1%+4)',                               00001400
        _DOPE_#DESCRIPTORS(1) _AS 'COREHALFWORD(%1%+6)',                        00001500
        _DOPE_ALLOC(1) _AS 'COREWORD(%1%+8)',                                   00001600
        _DOPE_USED(1) _AS 'COREWORD(%1%+12)',                                   00001700
        _DOPE_NEXT(1) _AS 'COREWORD(%1%+16)',                                   00001800
        _DOPE_ASSOC(1) _AS 'COREWORD(%1%+20)',                                  00001900
        _DOPE_GLOBAL_FACTOR(1) _AS 'COREHALFWORD(%1%+24)',                      00002000
        _DOPE_GROUP_FACTOR(1) _AS 'COREHALFWORD(%1%+26)';                       00002100
                                                                                00002200
DECLARE _NUM_TIMES_ZEROED(1) _AS '_DOPE_GLOBAL_FACTOR(%1%)',                    00002300
   /*GLOBAL FACTOR NOT USED, SO WE USE IT AS TERMINATION CONDITION COUNT*/      00002400
       _MAX_ZEROED _AS '2';  /*ABORT IF ANY RECORD ZEROED MORE THAN THIS*/      00002500
                                                                                00002600
DECLARE _FREEBLOCK_NEXT(1) _AS 'COREWORD(%1%)',                                 00002700
        _FREEBLOCK_SIZE(1) _AS 'COREWORD(%1%-4)';                               00002800
DECLARE _RF(1) _AS '((%1%^=0)*(%1%-FREEBASE-3))';  /*FOR PRINT STATEMENTS*/     00002900
COMMON (FIRSTRECORD,FIRSTBLOCK,FREEBYTES,RECBYTES,TOTAL_RDESC) FIXED;           00003000
DECLARE FREESTRING_TARGET FIXED INITIAL(5000),  /*WHAT TO TRY FOR*/             00003100
        FREESTRING_TRIGGER FIXED INITIAL(2000), /*WHEN TO TRY FOR MORE*/        00003200
        FREESTRING_MIN     FIXED INITIAL(1000);  /*WHEN TO GIVE UP*/            00003300
COMMON  CORELIMIT FIXED;                                                        00003400
                                                                                00003500
DECLARE _RECORD#BYTES(1) _AS '_SPACE_ROUND(_DOPE_ALLOC(%1%)*_DOPE_WIDTH(%1%))'; 00003600
DECLARE RECORD_ALLOC(1) _AS '_DOPE_ALLOC(ADDR(%1%))',                           00003700
        RECORD_USED(1) _AS '_DOPE_USED(ADDR(%1%))',                             00003800
        RECORD_TOP(1) _AS '(RECORD_USED(%1%)-1)',                               00003900
        SET_RECORD_WIDTH(2) _AS '_DOPE_WIDTH(ADDR(%1%))=%2%',                   00004000
        ALLOCATE_SPACE(2) _AS                                                   00004100
         'CALL _ALLOCATE_SPACE(ADDR(%1%),%2% _IFAQ(%1%))',                      00004200
        NEXT_ELEMENT(1) _AS                                                     00004300
  'DO; IF RECORD_USED(%1%)>=RECORD_ALLOC(%1%) THEN NEEDMORE_SPACE(%1%);         00004400
   RECORD_USED(%1%)=RECORD_USED(%1%)+1; END',                                   00004500
        NEEDMORE_SPACE(1) _AS 'CALL _NEEDMORE_SPACE(ADDR(%1%) _IFAQ(%1%))',     00004600
        RECORD_FREE(1) _AS                                                      00004700
          'CALL _RECORD_FREE(ADDR(%1%) _IFAQ(%1%))',                            00004800
        RECORD_SEAL(1) _AS 'CALL _RECORD_SEAL(ADDR(%1%) _IFAQ(%1%))',           00004900
        RECORD_UNSEAL(1) _AS 'CALL _RECORD_UNSEAL(ADDR(%1%) _IFAQ(%1%))',       00005000
        RECORD_CONSTANT(3) _AS                                                  00005100
         'CALL _RECORD_CONSTANT(ADDR(%1%),%2%,%3% _IFAQ(%1%))',                 00005200
        RECORD_GROUPHEAD(3) _AS 'CALL _RECORD_GROUPHEAD(ADDR(%1%),%2%,%3%)',    00005300
        RECORD_COORDINATED(3) _AS                                               00005400
       'CALL _RECORD_COORDINATED(ADDR(%1%),ADDR(%2%),%3%)';                     00005500
                                                                                00005600
DECLARE _IS_REC_CONSTANT(1) _AS '((_DOPE_ASSOC(%1%)&"3000000")^=0)',            00005700
       _MAKE_REC_CONSTANT(1) _AS '_DOPE_ASSOC(%1%)=_DOPE_ASSOC(%1%)|"1000000"', 00005800
        _IS_REC_UNMOVEABLE(1) _AS '((_DOPE_ASSOC(%1%)&"2000000")^=0)',          00005900
     _MAKE_REC_UNMOVEABLE(1) _AS '_DOPE_ASSOC(%1%)=_DOPE_ASSOC(%1%)|"2000000"'; 00006000
                                                                                00006100
DECLARE COMPACTIFIES(1) BIT(16), REALLOCATIONS BIT(16);                         00006200
DECLARE _IN_COMPACTIFY BIT(1);  /*TRUE IF COMPACTIFY CALLS SPMANAGE*/           00006300
DECLARE _CONDOUTPUT(1) _AS 'DO; IF ^_IN_COMPACTIFY _ANDIF (FREELIMIT >          00006400
FREEPOINT+650) THEN OUTPUT=%1%; END',                                           00006500
    _CONDSPMANERR(1) _AS 'DO; CALL _SPMANERR(%1%); END';                        00006600
DECLARE (_DX_TOTAL,_PREV_DX_TOTAL,_LAST_COMPACTIFY_FOUND) FIXED;                00006700
DECLARE FORCE_MAJOR BIT(1);  /*IF _TRUE, NEXT COMPACTIFY WILL BE MAJOR*/        00006800
BASED DX FIXED;                                                                 00006900
DESCRIPTOR_MONITOR:                                                             00007000
   PROCEDURE(CODE, LOCN, SIZE) BIT(1);                                          00007100
      DECLARE (LOCN, SIZE) FIXED, (CODE, I,J) BIT(16);                          00007200
      DO CASE CODE & 1;                                                         00007300
         DO;  /* GET DESCRIPTORS  */                                            00007400
            DO I = 0 TO 6 BY 2;                                                 00007500
               IF DESCRIPTOR_DESCRIPTOR(I+1) = 0 THEN                           00007600
                  DO;  /* FOUND A HOLE  */                                      00007700
                     DX_SIZE = DX_SIZE + SHR(SIZE, 2);                          00007800
                     J = MONITOR(6, LOCN, SIZE);                                00007900
                     IF ^J THEN DO;                                             00008000
                        DESCRIPTOR_DESCRIPTOR(I) = COREWORD(LOCN);              00008100
                        DESCRIPTOR_DESCRIPTOR(I+1) = SIZE;                      00008200
                     END;                                                       00008300
                     RETURN J;                                                  00008400
                  END;                                                          00008500
            END;                                                                00008600
            OUTPUT = 'BI000 SEVERITY 3   NOTICE FROM DESCRIPTOR_MONITOR:  ' ||  00008700
  ' UNABLE TO ALLOCATE ADDITIONAL DESCRIPTORS. JOB ABANDONED. ';                00008800
            CALL EXIT;   /* DR104706 */                                         00009000
         END;                                                                   00009010
         DO;  /* FREE DESCRIPTORS  */                                           00009100
            DO I = 0 TO 6 BY 2;                                                 00009200
               IF COREWORD(LOCN) = DESCRIPTOR_DESCRIPTOR(I) THEN                00009300
                  IF SIZE = DESCRIPTOR_DESCRIPTOR(I+1) THEN                     00009400
                     DO;                                                        00009500
                        CALL MONITOR(7, LOCN, SIZE);                            00009600
                        DESCRIPTOR_DESCRIPTOR(I+1) = 0;                         00009700
                        DX_SIZE=DX_SIZE-SHR(SIZE,2);                            00009800
                        RETURN J;                                               00009900
                     END;                                                       00010000
            END;                                                                00010100
            OUTPUT = 'BI001 SEVERITY 3 INVALID CALL TO '||                      00010200
                     'RETURN DESCRIPTORS';                                      00010300
            CALL EXIT;   /* DR104706 */                                         00010500
         END;                                                                   00010510
      END;                                                                      00010600
   END DESCRIPTOR_MONITOR;                                                      00010700
                                                                                00010800
_SPMANERR: PROCEDURE(MSG);                                                      00010900
   DECLARE MSG CHARACTER;                                                       00011000
   DECLARE NUMERRORS BIT(16), MAX_NUM_ERRORS _AS '50';                          00011100
   IF ^_IN_COMPACTIFY _ANDIF (FREELIMIT > FREEPOINT+650) THEN DO;               00011200
 OUTPUT/?A,OUTPUT(2)?/='BI002 SEVERITY 3 BUG IN SPACE MANAGEMENT SYSTEM ->->'|| 00011300
         MSG;                                                                   00011400
      CALL EXIT; /* DR104706 */                                                 00011510
   END;                                                                         00011600
   ELSE DO;                                                                     00011700
      OUTPUT/?A,OUTPUT(2)?/='BI003 SEVERITY 3  BUG IN SPACE MANAGEMENT SYSTEM'; 00011800
      CALL EXIT; /* DR104706 */                                                 00011920
   END;                                                                         00012000
   NUMERRORS=NUMERRORS+1;                                                       00012100
   IF NUMERRORS >  MAX_NUM_ERRORS THEN DO;                                      00012200
   OUTPUT/?A,OUTPUT(2)?/='BI004 SEVERITY 3 TOO MANY SPACE MANAGEMENT ERRORS '   00012300
          || '-- ABORTING.';                                                    00012400
      CALL EXIT; /* DR104706 */                                                 00012510
    END;                                                                        00012600
END _SPMANERR;                                                                  00012700
                                                                                00012800
_SPACE_ROUND: PROCEDURE(BYTES) FIXED;                                           00012900
   DECLARE BYTES FIXED;                                                         00013000
   RETURN (BYTES&"FFFFF8")+SHL((BYTES&"7")^=0,3);                               00013100
END _SPACE_ROUND;                                                               00013200
                                                                                00013300
_ACTIVE_DESCRIPTORS: PROCEDURE(DOPE) FIXED;                                     00013400
  /*RETURNS NUMBER OF ACTIVE DESCRIPTORS*/                                      00013500
   DECLARE DOPE FIXED;                                                          00013600
   DECLARE (DP,DW,DLAST,DND,I,J,ANS) FIXED;                                     00013700
   ANS=0;                                                                       00013800
   IF (_DOPE_USED(DOPE) = 0) | (_DOPE_#DESCRIPTORS(DOPE)=0) THEN RETURN 0;      00013900
   DW=_DOPE_WIDTH(DOPE);                                                        00014000
   DND=SHL(_DOPE_#DESCRIPTORS(DOPE),2);                                         00014100
   DP=_DOPE_POINTER(DOPE);  DLAST=DP+(DW*(_DOPE_USED(DOPE)-1));                 00014200
   DO I=DP TO DLAST BY DW;                                                      00014300
      DO J=I TO I+DND-4 BY 4;                                                   00014400
         IF COREWORD(J) ^= 0 THEN ANS=ANS+1;                                    00014500
      END;                                                                      00014600
   END;                                                                         00014700
   RETURN ANS;                                                                  00014800
END _ACTIVE_DESCRIPTORS;                                                        00014900
                                                                                00015000
DECLARE _OLDFREELIMIT FIXED; /*WILL DETECT UNAUTHORIZED THEFT OF FREESTRING*/   00015100
                                                                                00015200
_CHECK_FOR_THEFT: PROCEDURE;  /*COMPLAINS IF THEFT FROM FREE STRING AREA*/      00015300
   IF _OLDFREELIMIT=0 THEN _OLDFREELIMIT=FREELIMIT;                             00015400
   IF _OLDFREELIMIT ^= FREELIMIT THEN _CONDSPMANERR(                            00015500
      'UNAUTHORIZED THEFT FROM FREE STRING AREA, WAS='||_OLDFREELIMIT||         00015600
      ', IS NOW='||FREELIMIT);                                                  00015700
END _CHECK_FOR_THEFT;                                                           00015800
                                                                                00015900
DECLARE FREEPRINT BIT(1);                                                       00016000
                                                                                00016100
_FREEBLOCK_CHECK: PROCEDURE;                                                    00016200
   DECLARE (UPLIM,DOWNLIM,  /*FOR CHECKING BLOCK SIZES*/                        00016300
            FBYTES,RBYTES,                                                      00016400
            RDOPE,RPNTR,RSIZE,  /*FOR RECORD DOPE VECTOR, POINTER,SIZE*/        00016500
            BPNTR,BSIZE) FIXED,  /*FOR FREE BLOCK POINTER, SIZE*/               00016600
           (BLKNO,RECNO) BIT(16);                                               00016700
                                                                                00016800
   ADDRESS_CHECK: PROCEDURE(ADDRESS);  /*SCREAM IF NOT DOUBLE WORD ALIGNED*/    00016900
      DECLARE ADDRESS FIXED;                                                    00017000
      IF ADDRESS >= 0 _ANDIF (ADDRESS&"7")=0 THEN RETURN;                       00017100
      _CONDSPMANERR('IN FREEBLOCK_CHECK, NOT ALIGNED ON DOUBLE WORD, ADDRESS='  00017200
          ||_RF(ADDRESS));                                                      00017300
   END ADDRESS_CHECK;                                                           00017400
                                                                                00017500
   BLKPROC:  PROCEDURE;                                                         00017600
      IF BPNTR > 0 THEN                                                         00017700
       DO;                                                                      00017800
         BLKNO=BLKNO+1;                                                         00017900
         BSIZE=_FREEBLOCK_SIZE(BPNTR);                                          00018000
         FBYTES=FBYTES+BSIZE;                                                   00018100
         IF FREEPRINT THEN _CONDOUTPUT('BLOCK #'||BLKNO||',FROM='||_RF(BPNTR)|| 00018200
          ',FOR='||BSIZE||',TO='||_RF(BPNTR-BSIZE+4));                          00018300
         CALL ADDRESS_CHECK(BPNTR-4);                                           00018400
         IF (BPNTR+4) ^= UPLIM THEN _CONDSPMANERR(                              00018500
          'BLOCK WRONG SIZE, BPNTR='||BPNTR||',UPLIM='||_RF(UPLIM));            00018600
         UPLIM=UPLIM-BSIZE;                                                     00018700
         BPNTR=_FREEBLOCK_NEXT(BPNTR);                                          00018800
         IF BPNTR > 0 _ANDIF BPNTR > RPNTR THEN _CONDSPMANERR(                  00018900
          '2 CONSECUTIVE BLOCKS.');                                             00019000
       END;                                                                     00019100
   END BLKPROC;                                                                 00019200
                                                                                00019300
   CALL _CHECK_FOR_THEFT;                                                       00019400
   FBYTES,RBYTES,BLKNO,RECNO=0;                                                 00019500
   UPLIM=CORELIMIT; DOWNLIM=FREELIMIT+512;                                      00019600
   RDOPE=FIRSTRECORD;                                                           00019700
   BPNTR=FIRSTBLOCK;                                                            00019800
   IF FREEPRINT THEN                                                            00019900
      _CONDOUTPUT('***  DUMP OF RECORDS AND BLOCKS, CORELIMIT='||_RF(CORELIMIT) 00020000
       ||',FREELIMIT='||_RF(FREELIMIT)||',FIRSTRECORD='||FIRSTRECORD||          00020100
            ',FIRSTBLOCK='||_RF(FIRSTBLOCK));                                   00020200
     /*PROLOGUE DONE, START THROUGH STRUCTURES*/                                00020300
   DO WHILE RDOPE > 0;                                                          00020400
      RPNTR=_DOPE_POINTER(RDOPE);                                               00020500
      IF (RPNTR>0) & (RPNTR > BPNTR) THEN                                       00020600
       DO;  /*PROCESS A RECORD*/                                                00020700
         RECNO=RECNO+1;                                                         00020800
         RSIZE=_RECORD#BYTES(RDOPE);                                            00020900
         RBYTES=RBYTES+RSIZE;                                                   00021000
       IF FREEPRINT _ANDIF ^_IN_COMPACTIFY _ANDIF FREELIMIT > FREEPOINT+650 THEN00021100
            OUTPUT='RECORD #'||RECNO||',WIDTH='||_DOPE_WIDTH(RDOPE)             00021200
          ||',ALLOC='||_DOPE_ALLOC(RDOPE)||',USED='||_DOPE_USED(RDOPE)||        00021300
          ', START='||_RF(RPNTR)||', TOTAL BYTES ALLOC='||RSIZE||', DOPE AT '|| 00021400
             RDOPE||', ACTIVE DESCRIPTORS='||_ACTIVE_DESCRIPTORS(RDOPE)||       00021500
             ', C='||SHR(_DOPE_ASSOC(RDOPE),24);                                00021600
         CALL ADDRESS_CHECK(_DOPE_POINTER(RDOPE));                              00021700
         IF (RPNTR+RSIZE)^=UPLIM THEN _CONDSPMANERR(                            00021800
            'RECORD HAS WRONG SIZE,UPLIM='||_RF(UPLIM));                        00021900
         UPLIM=UPLIM-RSIZE;                                                     00022000
         RDOPE=_DOPE_NEXT(RDOPE);                                               00022100
       END;                                                                     00022200
       ELSE CALL BLKPROC;                                                       00022300
   END;                                                                         00022400
   CALL BLKPROC;                                                                00022500
   IF BPNTR ^= 0 THEN _CONDSPMANERR('CONSECUTIVE FREEBLOCKS.');                 00022600
   IF UPLIM ^= DOWNLIM THEN _CONDSPMANERR('FINAL BLOCK WRONG SIZE, UPLIM='||    00022700
     UPLIM||',DOWNLIM='||DOWNLIM);                                              00022800
   IF FREEPRINT THEN _CONDOUTPUT(FBYTES||' BYTES OF FREEBYTES, '||RBYTES||      00022900
      ' ALLOCATED, TOTAL OF '||RBYTES+FBYTES);                                  00023000
   CALL _CHECK_FOR_THEFT;                                                       00023100
   IF (FBYTES^=FREEBYTES) | (RBYTES^=RECBYTES) THEN _CONDSPMANERR(              00023200
      'FBYTES='||FBYTES||', FREEBYTES='||FREEBYTES||', RBYTES='||               00023300
       RBYTES||', RECBYTES='||RECBYTES);                                        00023400
END _FREEBLOCK_CHECK;                                                           00023500
                                                                                00023600
_UNUSED_BYTES: PROCEDURE FIXED; /*RETURNS NUMBER OF UNUSED BYTES                00023700
     IN ALLOCATED RECORDS (OTHER THAN CONSTANT)*/                               00023800
   DECLARE (CUR,ANS) FIXED;                                                     00023900
   CUR=FIRSTRECORD;   ANS=0;                                                    00024000
   DO WHILE CUR > 0;                                                            00024100
      IF ^_IS_REC_CONSTANT(CUR) THEN                                            00024200
       ANS=ANS+                                                                 00024300
         ("FFFFFFF8" & (_DOPE_WIDTH(CUR)*(_DOPE_ALLOC(CUR)-_DOPE_USED(CUR))));  00024400
      CUR=_DOPE_NEXT(CUR);                                                      00024500
   END;                                                                         00024600
   /?A _CONDOUTPUT('UNUSED BYTES='||ANS); ?/                                    00024700
   RETURN ANS;                                                                  00024800
END _UNUSED_BYTES;                                                              00024900
                                                                                00025000
_MOVE_WORDS: PROCEDURE(SOURCE,DEST,NUMBYTES);  /*MOVES WHOLE WORDS              00025100
   IF DEST > SOURCE, THEN MOVE UP WITH SOURCE,DEST THE                          00025200
   BYTE ADDRESSES OF THE TOP WORD OF EACH RECORD;                               00025300
      IF SOURCE < DEST, THEN MOVE DOWN, WITH SOURCE,DEST THE BYTE ADDRESSES     00025400
     OF THE BOTTOM WORD OF EACH  BLOCK*/                                        00025500
   DECLARE (SOURCE,DEST,NUMBYTES) FIXED;                                        00025600
   DECLARE I FIXED;                                                             00025700
  /?A _CONDOUTPUT(                                                              00025800
     'MOVE_WORDS, '||NUMBYTES||', FROM='||_RF(SOURCE)||', TO='||_RF(DEST));?/   00025900
    /?A IF (((SOURCE&"3") | (DEST&"3")) ^= 0) |(SOURCE<=0)|(DEST<=0) THEN  DO;  00026000
         _CONDSPMANERR('IN MOVEWORDS, FROM='                                    00026100
       ||SOURCE||', TO='||DEST||', NUMBYTES='||NUMBYTES);                       00026200
       CALL EXIT;                                                               00026300
       END;  ?/                                                                 00026400
   IF DEST > SOURCE THEN /*MOVE UP */                                           00026500
      DO I=0 TO NUMBYTES-4 BY 4;                                                00026600
         COREWORD(DEST-I) = COREWORD(SOURCE-I);                                 00026700
      END;                                                                      00026800
      ELSE DO I=0 TO NUMBYTES -4 BY 4;                                          00026900
         COREWORD(DEST+I)=COREWORD(SOURCE+I);                                   00027000
      END;                                                                      00027100
END _MOVE_WORDS;                                                                00027200
                                                                                00027300
_SQUASH_RECORDS: PROCEDURE;                                                     00027400
   DECLARE (CURDOPE,RECPTR,LAST_RECPTR,                                         00027500
            CURBLOCK,NEXTBLOCK,BYTES_TO_MOVE_BY) FIXED;                         00027600
   DECLARE SQUASHED FIXED;                                                      00027700
     SQUASHED=0;                                                                00027800
     /?A OUTPUT='SQUASHING'; ?/                                                 00027900
   BYTES_TO_MOVE_BY=0;                                                          00028000
   CURBLOCK=FIRSTBLOCK;  CURDOPE=FIRSTRECORD;                                   00028100
   DO WHILE CURDOPE > 0;                                                        00028200
      IF ^_IS_REC_UNMOVEABLE(CURDOPE) THEN ESCAPE;                              00028300
      CURDOPE=_DOPE_NEXT(CURDOPE);                                              00028400
   END;  /*ESCAPED FROM ABOVE AT FIRST MOVEABLE RECORD*/                        00028500
   IF CURDOPE <= 0 THEN RETURN;                                                 00028600
   RECPTR=_DOPE_POINTER(CURDOPE);                                               00028700
BLOCKLOOP:                                                                      00028800
   DO WHILE CURBLOCK > 0;                                                       00028900
      BYTES_TO_MOVE_BY=BYTES_TO_MOVE_BY+_FREEBLOCK_SIZE(CURBLOCK);              00029000
      NEXTBLOCK=_FREEBLOCK_NEXT(CURBLOCK);                                      00029100
      DO WHILE RECPTR>CURBLOCK; /*PASS THROUGH RECORDS NOT TO BE MOVED*/        00029200
         CURDOPE=_DOPE_NEXT(CURDOPE);                                           00029300
         IF CURDOPE=0 THEN ESCAPE BLOCKLOOP;                                    00029400
         RECPTR=_DOPE_POINTER(CURDOPE);                                         00029500
         IF _IS_REC_UNMOVEABLE(CURDOPE) THEN _CONDSPMANERR(                     00029600
          'IN _SQUASH_RECORDS, UNMOVEABLE AFTER MOVEABLES, DOPE='||CURDOPE);    00029700
      END;                                                                      00029800
      DO UNTIL RECPTR<NEXTBLOCK; /*MOVE RECORDS BEFORE NEXT FREEBLOCK*/         00029900
         DECLARE (RECBYTES,I) FIXED;                                            00030000
         RECBYTES=_RECORD#BYTES(CURDOPE);                                       00030100
         CALL _MOVE_WORDS(RECPTR+RECBYTES-4,RECPTR+RECBYTES-4+BYTES_TO_MOVE_BY, 00030200
            RECBYTES);                                                          00030300
        SQUASHED=SQUASHED+RECBYTES;                                             00030400
         _DOPE_POINTER(CURDOPE)=_DOPE_POINTER(CURDOPE)+BYTES_TO_MOVE_BY;        00030500
         CURDOPE=_DOPE_NEXT(CURDOPE);                                           00030600
         IF CURDOPE <= 0 THEN ESCAPE BLOCKLOOP;                                 00030700
         LAST_RECPTR=RECPTR;                                                    00030800
         RECPTR=_DOPE_POINTER(CURDOPE);                                         00030900
      END;                                                                      00031000
      CURBLOCK=NEXTBLOCK;                                                       00031100
   END BLOCKLOOP;                                                               00031200
   IF BYTES_TO_MOVE_BY > 0 THEN                                                 00031300
    DO;  /*IF ANY MOVING HAPPENED, NEW FREEBLOCK*/                              00031400
      FIRSTBLOCK=FREELIMIT+FREEBYTES-4+512;                                     00031500
      _FREEBLOCK_SIZE(FIRSTBLOCK)=FREEBYTES;                                    00031600
      _FREEBLOCK_NEXT(FIRSTBLOCK)=0;                                            00031700
    END;                                                                        00031800
   /?A _CONDOUTPUT('SQUASH SQUASHED '||SQUASHED);?/                             00031900
   IF SQUASHED > 0 THEN CALL _FREEBLOCK_CHECK;                                  00032000
END _SQUASH_RECORDS;                                                            00032100
                                                                                00032200
_PREV_FREEBLOCK: PROCEDURE(BLOCK) FIXED;                                        00032300
   /*RETURNS A POINTER TO THE FREEBLOCK WHOSE NEXT BLOCK IS BLOCK*/             00032400
   DECLARE BLOCK FIXED;                                                         00032500
   DECLARE (PREV,CUR) FIXED;                                                    00032600
   PREV=0; CUR=FIRSTBLOCK;                                                      00032700
   DO WHILE (CUR > 0) & (CUR ^= BLOCK);                                         00032800
      PREV=CUR;                                                                 00032900
      CUR=_FREEBLOCK_NEXT(CUR);                                                 00033000
   END;                                                                         00033100
   RETURN PREV;                                                                 00033200
END _PREV_FREEBLOCK;                                                            00033300
                                                                                00033400
_PREV_RECORD: PROCEDURE(DOPE) FIXED;                                            00033500
   /*RETURNS POINTER TO THE DOPE VECTOR OF RECORD WHOSE NEXT RECORD IS DOPE*/   00033600
   DECLARE DOPE FIXED;                                                          00033700
   DECLARE (PREV,CUR) FIXED;                                                    00033800
   PREV=0;  CUR=FIRSTRECORD;                                                    00033900
   DO WHILE (CUR > 0) & (CUR ^= DOPE);                                          00034000
      PREV=CUR;                                                                 00034100
      CUR=_DOPE_NEXT(CUR);                                                      00034200
   END;                                                                         00034300
   RETURN PREV;                                                                 00034400
END _PREV_RECORD;                                                               00034500
                                                                                00034600
_ATTACH_BLOCK: PROCEDURE(BLOCK);                                                00034700
  /*BLOCK IS A BLOCK OF FREE STORAGE, ATTACH IT TO FREEBLOCK LIST*/             00034800
   DECLARE BLOCK FIXED;                                                         00034900
   DECLARE (PREV,CUR) FIXED;                                                    00035000
   JOIN: PROCEDURE(B1,B2); /*JOIN BLOCKS B1 TO B2*/                             00035100
      DECLARE (B1,B2) FIXED;                                                    00035200
      IF B1^=0 THEN DO;                                                         00035300
          _FREEBLOCK_NEXT(B1)=B2;                                               00035400
          IF (B1-_FREEBLOCK_SIZE(B1)) = B2 THEN                                 00035500
           DO;                                                                  00035600
             _FREEBLOCK_NEXT(B1)=_FREEBLOCK_NEXT(B2);                           00035700
             _FREEBLOCK_SIZE(B1)=_FREEBLOCK_SIZE(B1)+_FREEBLOCK_SIZE(B2);       00035800
           END;                                                                 00035900
      END;                                                                      00036000
   END JOIN;                                                                    00036100
                                                                                00036200
   PREV=0; CUR=FIRSTBLOCK;                                                      00036300
   DO WHILE CUR > 0;                                                            00036400
      IF CUR < BLOCK THEN ESCAPE;                                               00036500
      PREV=CUR; CUR=_FREEBLOCK_NEXT(CUR);                                       00036600
   END;                                                                         00036700
   _FREEBLOCK_NEXT(BLOCK)=CUR;                                                  00036800
   CALL JOIN(BLOCK,CUR);                                                        00036900
   IF PREV=0 THEN FIRSTBLOCK=BLOCK;                                             00037000
    ELSE CALL JOIN(PREV,BLOCK);                                                 00037100
   /?A OUTPUT='_ATTACH_BLOCK DONE.';?/  CALL _FREEBLOCK_CHECK;                  00037200
END _ATTACH_BLOCK;                                                              00037300
                                                                                00037400
_ATTACH_RECORD: PROCEDURE(DOPE);                                                00037500
   /*DOPE IS POINTER TO DOPE VECTOR OF NEW RECORD -- ATTACH IT TO RECORD LIST*/ 00037600
   DECLARE DOPE FIXED;                                                          00037700
   DECLARE (PREV,CUR,LOC) FIXED;                                                00037800
  /?A _CONDOUTPUT('_ATTACH_RECORD '||DOPE||',WIDTH='||_DOPE_WIDTH(DOPE)||       00037900
       ',ALLOC='||_DOPE_ALLOC(DOPE)); ?/                                        00038000
   IF FIRSTRECORD = 0 THEN FIRSTRECORD=DOPE;                                    00038100
    ELSE DO;                                                                    00038200
      PREV=0;CUR=FIRSTRECORD; LOC=_DOPE_POINTER(DOPE);                          00038300
      DO UNTIL CUR = 0;                                                         00038400
         IF _DOPE_POINTER(CUR) < LOC THEN ESCAPE;                               00038500
         PREV=CUR;  CUR=_DOPE_NEXT(CUR);                                        00038600
      END;                                                                      00038700
      _DOPE_NEXT(DOPE)=CUR;                                                     00038800
      IF PREV=0 THEN FIRSTRECORD=DOPE;                                          00038900
       ELSE _DOPE_NEXT(PREV) =DOPE;                                             00039000
    END;                                                                        00039100
   TOTAL_RDESC=TOTAL_RDESC+(_DOPE_#DESCRIPTORS(DOPE)*_DOPE_ALLOC(DOPE));        00039200
   /?A _CONDOUTPUT('_ATTACH_RECORD DONE, RDESC='||TOTAL_RDESC);?/               00039300
   CALL _FREEBLOCK_CHECK;                                                       00039400
END _ATTACH_RECORD;                                                             00039500
                                                                                00039600
_DETACH_RECORD: PROCEDURE(DOPE);                                                00039700
   DECLARE DOPE FIXED;                                                          00039800
   DECLARE PREV FIXED;                                                          00039900
   PREV=_PREV_RECORD(DOPE);                                                     00040000
   IF PREV=0 THEN FIRSTRECORD=_DOPE_NEXT(DOPE);                                 00040100
    ELSE _DOPE_NEXT(PREV)=_DOPE_NEXT(DOPE);                                     00040200
   TOTAL_RDESC=TOTAL_RDESC-(_DOPE_#DESCRIPTORS(DOPE)*_DOPE_ALLOC(DOPE));        00040300
   /?A _CONDOUTPUT('RECORD DETACHED, DOPE='||DOPE||',RDESC='||TOTAL_RDESC); ?/  00040400
END _DETACH_RECORD;                                                             00040500
                                                                                00040600
_REDUCE_BLOCK: PROCEDURE(BLOCK,REMBYTES,TOP);                                   00040700
   DECLARE (BLOCK,REMBYTES) FIXED,                                              00040800
    TOP BIT(1);  /*TOP TRUE IF BYTES TAKEN FROM TOP*/                           00040900
   DECLARE (PREV,OLDNBYTES,NEWBLOCK) FIXED;                                     00041000
   OLDNBYTES=_FREEBLOCK_SIZE(BLOCK);                                            00041100
   IF REMBYTES > OLDNBYTES THEN DO;                                             00041200
      _CONDSPMANERR('IN REDUCE_BLOCK, REMBYTES='||REMBYTES||', OLDNBYTES='      00041300
        ||OLDNBYTES);                                                           00041400
      CALL EXIT;                                                                00041500
    END;                                                                        00041600
   IF ^TOP & (REMBYTES < OLDNBYTES) THEN                                        00041700
       _FREEBLOCK_SIZE(BLOCK)=OLDNBYTES-REMBYTES;                               00041800
    ELSE DO;                                                                    00041900
      PREV=_PREV_FREEBLOCK(BLOCK);                                              00042000
      IF REMBYTES=OLDNBYTES THEN                                                00042100
       DO;  /*ELIMINATE THE BLOCK */                                            00042200
         IF PREV=0 THEN FIRSTBLOCK=_FREEBLOCK_NEXT(BLOCK);                      00042300
          ELSE _FREEBLOCK_NEXT(PREV)=_FREEBLOCK_NEXT(BLOCK);                    00042400
       END;                                                                     00042500
       ELSE DO;  /*SHORTEN THIS BLOCK FROM TOP */                               00042600
         NEWBLOCK=BLOCK-REMBYTES;                                               00042700
         _FREEBLOCK_NEXT(NEWBLOCK)=_FREEBLOCK_NEXT(BLOCK);                      00042800
         _FREEBLOCK_SIZE(NEWBLOCK)=OLDNBYTES-REMBYTES;                          00042900
         IF PREV=0 THEN FIRSTBLOCK=NEWBLOCK;                                    00043000
          ELSE _FREEBLOCK_NEXT(PREV)=NEWBLOCK;                                  00043100
       END;                                                                     00043200
   END;                                                                         00043300
END _REDUCE_BLOCK;                                                              00043400
                                                                                00043500
_RETURN_TO_FREESTRING: PROCEDURE(NBYTES);                                       00043600
  /*RETURN NBYTES FROM THE BOTTOM OF THE BOTTOM BLOCK TO THE FREESTRING AREA*/  00043700
   DECLARE NBYTES FIXED;                                                        00043800
  /?A _CONDOUTPUT('RETURN TO FREESTRING='||NBYTES||', FREEBYTES='||FREEBYTES);?/00043900
   IF NBYTES=0 THEN RETURN;                                                     00044000
   IF NBYTES > FREEBYTES THEN _CONDSPMANERR(                                    00044100
     'IN RETURN_TO_FREESTRING, NBYTES='||NBYTES||', FREEBYTES='||FREEBYTES);    00044200
    ELSE DO;                                                                    00044300
      CALL _SQUASH_RECORDS;                                                     00044400
      /* FIRSTBLOCK (BECAUSE OF SQUASH) IS THE ONLY BLOCK*/                     00044500
      IF FIRSTBLOCK <= 0 THEN _CONDSPMANERR(                                    00044600
        'IN RETURN_TO_FREESTRING, FIRSTBLOCK='||FIRSTBLOCK);                    00044700
      CALL _REDUCE_BLOCK(FIRSTBLOCK,NBYTES,_FALSE);                             00044800
      _OLDFREELIMIT,FREELIMIT=FREELIMIT+NBYTES;                                 00044900
      FREEBYTES=FREEBYTES-NBYTES;                                               00045000
    END;                                                                        00045100
END _RETURN_TO_FREESTRING;                                                      00045200
                                                                                00045300
_RECORD_FREE: PROCEDURE(DOPE _IFA(NAME));                                       00045400
  /*REATTACHES THE RECORD FOR WHICH DOPE IS THE DOPE VECTOR --                  00045500
     FREEBYTES WILL GROW AND RECBYTES WILL SHRINK*/                             00045600
   DECLARE DOPE FIXED /?A,NAME CHARACTER?/ ;                                    00045700
   DECLARE (SIZE,PREV,NEWBLOCK) FIXED;                                          00045800
    /*DETACH RECORD FROM RECORD LIST*/                                          00045900
   /?A _CONDOUTPUT('RETURNING '||NAME||', DOPE='||DOPE); ?/                     00046000
   CALL _CHECK_FOR_THEFT;                                                       00046100
   IF _DOPE_ALLOC(DOPE) <= 0 THEN                                               00046200
    DO;                                                                         00046300
      _CONDSPMANERR('IN RECORD_FREE, NOT ALLOCATED: '                           00046400
         ||/?ANAME||', DOPE='||?/DOPE);                                         00046500
      RETURN;                                                                   00046600
    END;                                                                        00046700
   CALL _DETACH_RECORD(DOPE);                                                   00046800
   SIZE=_RECORD#BYTES(DOPE);                                                    00046900
   _DOPE_ALLOC(DOPE)=0;                                                         00047000
   FREEBYTES=FREEBYTES+SIZE;  RECBYTES=RECBYTES-SIZE;                           00047100
    /*NOW ATTACH THE SPACE TO FREEBLOCK*/                                       00047200
   NEWBLOCK=_DOPE_POINTER(DOPE)+SIZE-4; /*NOTE THAT RECORDS USE LAST TWO WORDS*/00047300
   _FREEBLOCK_SIZE(NEWBLOCK)=SIZE;                                              00047400
   CALL _ATTACH_BLOCK(NEWBLOCK);                                                00047500
END _RECORD_FREE;                                                               00047600
                                                                                00047700
_RETURN_UNUSED: PROCEDURE(DOPE,NRECS _IFA(NAME));  /*RETURN NRECS UNUSED RECORDS00047800
    OF THE RECORD WHOSE DOPE VECTOR IS DOPE.  NRECS=0 MEANS RETURN ALL UNUSED*/ 00047900
   DECLARE (DOPE,NRECS) FIXED  /?A ,NAME CHARACTER?/ ;                          00048000
   DECLARE (NEWBLOCK,OLDNBYTES,NEWNBYTES,DIF) FIXED;                            00048100
   DIF=_DOPE_ALLOC(DOPE)-_DOPE_USED(DOPE);                                      00048200
   /?A _CONDOUTPUT('RETURN_UNUSED, DOPE='||DOPE||',NRECS='||NRECS||',ALLOC='    00048300
       ||_DOPE_ALLOC(DOPE)||',USED='||_DOPE_USED(DOPE));  ?/                    00048400
   IF NRECS=0 THEN                                                              00048500
    DO;  /*RETURN ALL UNUSED BLOCKS*/                                           00048600
      NRECS=DIF;                                                                00048700
      _NUM_TIMES_ZEROED(DOPE)=0;                                                00048800
      IF NRECS=0 THEN RETURN;                                                   00048900
    END;                                                                        00049000
    ELSE IF NRECS=DIF THEN                                                      00049100
     DO;                                                                        00049200
      _NUM_TIMES_ZEROED(DOPE)=_NUM_TIMES_ZEROED(DOPE)+1;                        00049300
      IF _NUM_TIMES_ZEROED(DOPE)>_MAX_ZEROED THEN DO;                           00049400
         OUTPUT/?A,OUTPUT(2)?/='BI010 SEVERITY 3  SPACE MANAGEMENT ' ||         00049500
         'YOYOING -- TRY LARGER REGION.';                                       00049501
         CALL EXIT;   /* DR104706 */                                            00049610
       END;                                                                     00049700
    END;                                                                        00049800
   ELSE IF NRECS > DIF THEN                                                     00049900
    DO;                                                                         00050000
      _CONDSPMANERR('TRIED TO RETURN '||NRECS||' BUT ONLY '||DIF||              00050100
         'ARE UNUSED IN '||DOPE);                                               00050200
      NRECS=DIF;                                                                00050300
    END;                                                                        00050400
   IF DIF=_DOPE_ALLOC(DOPE) THEN CALL _RECORD_FREE(DOPE _IFA(NAME));            00050500
   ELSE DO;                                                                     00050600
      TOTAL_RDESC=TOTAL_RDESC-NRECS*_DOPE_#DESCRIPTORS(DOPE);                   00050700
      OLDNBYTES=_RECORD#BYTES(DOPE);                                            00050800
      _DOPE_ALLOC(DOPE)=_DOPE_ALLOC(DOPE)-NRECS;                                00050900
      NEWNBYTES=_RECORD#BYTES(DOPE);                                            00051000
      DIF=OLDNBYTES-NEWNBYTES;                                                  00051100
      /*DO NOT TRY TO RETURN FREE SPACE WHEN DIF IS ZERO*/
      IF DIF=0 THEN RETURN; /*DR111339*/
      NEWBLOCK=_DOPE_POINTER(DOPE)+OLDNBYTES-4;                                 00051200
      _FREEBLOCK_NEXT(NEWBLOCK)=0;                                              00051300
      _FREEBLOCK_SIZE(NEWBLOCK)=DIF;                                            00051400
      FREEBYTES=FREEBYTES+DIF;  RECBYTES=RECBYTES-DIF;                          00051500
 /?A _CONDOUTPUT('RECORD REDUCED, DOPE='||DOPE||',ALLOC='||_DOPE_ALLOC(DOPE)||  00051600
        ',RDESC='||TOTAL_RDESC);?/                                              00051700
      CALL _ATTACH_BLOCK(NEWBLOCK);                                             00051800
   END;                                                                         00051900
END _RETURN_UNUSED;                                                             00052000
                                                                                00052100
_TAKE_BACK: PROCEDURE(NBYTES);  /*RESTORE TO FREEBLOCKS UP TO NBYTES*/          00052200
   DECLARE NBYTES FIXED;                                                        00052300
   DECLARE (CUR,RET_RECS,DIF_RECS,POSSIBLE,LEFTBYTES) FIXED,                    00052400
     PREV_FREEBYTES FIXED, PREV_FREEPRINT BIT(1);                               00052500
   /?A _CONDOUTPUT('TAKING BACK '||NBYTES);?/                                   00052600
   REALLOCATIONS=REALLOCATIONS+1;                                               00052700
   PREV_FREEPRINT=FREEPRINT;  FREEPRINT=_FALSE;                                 00052800
   POSSIBLE=_UNUSED_BYTES;                                                      00052900
   IF NBYTES > POSSIBLE THEN NBYTES=POSSIBLE; LEFTBYTES=NBYTES;                 00053000
   CUR=FIRSTRECORD;                                                             00053100
   DO WHILE (CUR > 0) & (LEFTBYTES > 0);                                        00053200
      IF ^_IS_REC_CONSTANT(CUR) THEN                                            00053300
       DO;                                                                      00053400
         DIF_RECS,RET_RECS=_DOPE_ALLOC(CUR)-_DOPE_USED(CUR);                    00053500
         IF RET_RECS > 0 THEN                                                   00053600
          DO;                                                                   00053700
            RET_RECS=(NBYTES*RET_RECS)/POSSIBLE + 1;                            00053800
            IF RET_RECS*_DOPE_WIDTH(CUR) > LEFTBYTES THEN                       00053900
             RET_RECS=LEFTBYTES/_DOPE_WIDTH(CUR) + 1;                           00054000
            IF RET_RECS > DIF_RECS THEN RET_RECS=DIF_RECS;                      00054100
            PREV_FREEBYTES=FREEBYTES;                                           00054200
            CALL _RETURN_UNUSED(CUR,RET_RECS /?A ,'?'?/);                       00054300
            LEFTBYTES=LEFTBYTES-(FREEBYTES-PREV_FREEBYTES);                     00054400
          END;                                                                  00054500
       END;                                                                     00054600
      CUR=_DOPE_NEXT(CUR);                                                      00054700
    END;                                                                        00054800
   FREEPRINT=PREV_FREEPRINT;                                                    00054900
   /?A IF LEFTBYTES > 0 THEN _CONDOUTPUT('BUT TOOK BACK ALL BUT '||LEFTBYTES);?/00055000
END _TAKE_BACK;                                                                 00055100
                                                                                00055200
COMPACTIFY:                                                                     00055300
   PROCEDURE;                                                                   00055400
   DECLARE (I, J, K, L, ND, TC, BC, DELTA, MODE,ACTUAL_DX_TOTAL) FIXED;         00055500
   DECLARE MASK FIXED INITIAL ("FFFFFF"), (LOWER_BOUND, UPPER_BOUND) FIXED,     00055600
           TRIED BIT(1);                                                        00055700
ADD_DESC: PROCEDURE(I);                                                         00055800
   DECLARE(I,L) FIXED;                                                          00055900
     L = COREWORD(I) & MASK;                                                    00056000
      IF (L >= LOWER_BOUND) & (L <= UPPER_BOUND) THEN                           00056100
         DO;                                                                    00056200
            ND = ND + 1;                                                        00056300
            IF ND = ACTUAL_DX_TOTAL THEN                                        00056400
               DO;  /* WE HAVE TOO MANY POTENTIALLY COLLECTABLE STRINGS  */     00056500
                  OUTPUT = 'BI005 SEVERITY 3  NOTICE FROM COMPACTIFY:'||        00056600
                  '  INSUFFICIENT SORT AREA. JOB ABANDONED.';                   00056610
                  CALL EXIT;   /* DR104706 */                                   00056810
               END;                                                             00056900
            DX(ND) = I;                                                         00057000
         END;                                                                   00057100
END ADD_DESC;                                                                   00057200
                                                                                00057300
   /* FIRST WE MUST SET THE LOWER BOUND OF THE COLLECTABLE AREA */              00057400
   IF LOWER_BOUND = 0 THEN LOWER_BOUND = FREEBASE;                              00057500
   GO TO START;                                                                 00057600
   CALL INLINE("50", 2, 0, LOWER_BOUND);                                        00057700
   MODE = 1;  /* LINKING */                                                     00057800
   START:                                                                       00057900
     /?COUTPUT='COMPACTIFY CALLED';?/                                           00058000
   UPPER_BOUND = FREELIMIT + 512;                                               00058100
   _DX_TOTAL=DX_SIZE+TOTAL_RDESC;                                               00058200
    IF _DX_TOTAL ^= _PREV_DX_TOTAL THEN                                         00058300
    DO;                                                                         00058400
     /?C OUTPUT='CHANGING _DX_TOTAL';?/                                         00058500
 IF ACTUAL_DX_TOTAL>0 THEN CALL MONITOR(7,ADDR(DX),SHL(ACTUAL_DX_TOTAL,2));     00058600
   I=MONITOR(21);  /*I NOW HAS THE MAXIMUM NUMBER OF AVAILABLE BYTES*/          00058700
   J=SHL(_DX_TOTAL+1,2);  /*J NOW HAS THE MAXIMUM NUMBER OF NEEDED BYTES*/      00058800
   IF I>J THEN I=J; /*GET LOWER OF AVAILABLE AND NEEDED BYTES*/                 00058900
   ACTUAL_DX_TOTAL=SHR(I,2);                                                    00059000
   IF MONITOR(6,ADDR(DX),I) THEN DO;                                            00059100
      OUTPUT='BI006 SEVERITY 3  BUG IN COMPACTIFY***  ABORTING';                00059200
      CALL EXIT;   /* DR104706 */                                               00059310
    END;                                                                        00059400
       _PREV_DX_TOTAL=_DX_TOTAL;                                                00059500
     END;                                                                       00059600
 DO TRIED = 0 TO 1;                                                             00059700
     IF FORCE_MAJOR THEN DO;                                                    00059800
         FORCE_MAJOR=_FALSE;                                                    00059900
         LOWER_BOUND=FREEBASE;                                                  00060000
         TRIED=1;                                                               00060100
      END;                                                                      00060200
    COMPACTIFIES(TRIED) = COMPACTIFIES(TRIED) + 1;                              00060300
   ND = -1;                                                                     00060400
   /* FIND THE COLLECTABLE DESCRIPTORS  */                                      00060500
   DO J = 0 TO 6 BY 2;                                                          00060600
    K = DESCRIPTOR_DESCRIPTOR(J);                                               00060700
    DO I = K TO K + DESCRIPTOR_DESCRIPTOR(J + 1) - 1 BY 4;                      00060800
      CALL ADD_DESC(I);                                                         00060900
    END;                                                                        00061000
   END;                                                                         00061100
   L=FIRSTRECORD;                                                               00061200
   DO WHILE L ^= 0;                                                             00061300
      IF _DOPE_#DESCRIPTORS(L) > 0 _ANDIF _DOPE_USED(L) > 0 THEN                00061400
       DO;                                                                      00061500
         DECLARE (DP,DW) FIXED;                                                 00061600
         DP=_DOPE_POINTER(L);  DW=_DOPE_WIDTH(L);                               00061700
         DO J=DP TO DP+DW*(_DOPE_USED(L)-1) BY DW;                              00061800
            DO K=J TO J+4*(_DOPE_#DESCRIPTORS(L)-1) BY 4;                       00061900
               CALL ADD_DESC(K);                                                00062000
            END;                                                                00062100
         END;                                                                   00062200
       END;                                                                     00062300
      L=_DOPE_NEXT(L);                                                          00062400
   END;                                                                         00062500
   FREEPOINT = LOWER_BOUND;                                                     00062600
  IF ND >= 0 THEN DO;                                                           00062700
   /* SORT IN ASCENDING ORDER  */                                               00062800
   K = SHR(ND+1,1);                                                             00062900
   DO WHILE K > 0;                                                              00063000
      DO J = 0 TO ND-K;                                                         00063100
         I = J;                                                                 00063200
         DO WHILE (COREWORD(DX(I)) & MASK) > (COREWORD(DX(I+K)) & MASK);        00063300
            L = DX(I);                                                          00063400
            DX(I) = DX(I+K);                                                    00063500
            DX(I+K) = L;                                                        00063600
            I = I - K;                                                          00063700
            IF I < 0 THEN ESCAPE;                                               00063800
         END;                                                                   00063900
      END;                                                                      00064000
      K = SHR(K,1);                                                             00064100
   END;                                                                         00064200
   /* MOVE THE ACTIVE STRINGS DOWN  */                                          00064300
   TC, DELTA = 0;                                                               00064400
   BC = 1;   /* SETUP INITIAL CONDITION  */                                     00064500
   DO I = 0 TO ND;                                                              00064600
      J = COREWORD(DX(I));                                                      00064700
      IF (J & MASK) - 1 > TC THEN                                               00064800
         DO;                                                                    00064900
           IF DELTA > 0 THEN                                                    00065000
            DO K = BC TO TC;                                                    00065100
               COREBYTE(K-DELTA) = COREBYTE(K);                                 00065200
            END;                                                                00065300
            FREEPOINT = FREEPOINT + TC - BC + 1;                                00065400
            BC = J & MASK;                                                      00065500
            DELTA = BC - FREEPOINT;                                             00065600
         END;                                                                   00065700
      COREWORD (DX(I)) = J - DELTA;                                             00065800
      L = (J & MASK) + SHR(J, 24);                                              00065900
      IF TC < L THEN TC = L;                                                    00066000
   END;                                                                         00066100
   DO K = BC TO TC;                                                             00066200
      COREBYTE(K-DELTA) = COREBYTE(K);                                          00066300
   END;                                                                         00066400
   FREEPOINT = FREEPOINT + TC - BC + 1;                                         00066500
  END;                                                                          00066600
   IF MODE THEN                                                                 00066700
      DO;                                                                       00066800
         /?C OUTPUT='LINKING TO NEXT PHASE.'; ?/                                00066900
         IF ACTUAL_DX_TOTAL>0 THEN                                              00067000
         CALL MONITOR(7, ADDR(DX), SHL(ACTUAL_DX_TOTAL , 2));                   00067100
         I = ADDR(DESCRIPTOR_DESCRIPTOR);                                       00067200
         K=FIRSTRECORD;                                                         00067300
         IF K ^= 0 THEN K=K|"80000000";                                         00067400
         CALL INLINE("58", 0, 0, LOWER_BOUND);                                  00067500
         CALL INLINE("58", 2, 0, I);                                            00067600
         CALL INLINE("58", 4, 0, UPPER_BOUND);  /* CORETOP PASSED IN R4 */      00067700
         CALL INLINE("58", 5, 0, K);                                            00067800
         RETURN FREEPOINT;                                                      00067900
      END;                                                                      00068000
   _LAST_COMPACTIFY_FOUND=FREELIMIT-FREEPOINT;                                  00068100
   IF (SHL(FREELIMIT-FREEPOINT, 4) < FREELIMIT-FREEBASE) |                      00068200
      FREELIMIT-FREEPOINT <  FREESTRING_TRIGGER THEN                            00068300
     DO;                                                                        00068400
      LOWER_BOUND = FREEBASE;                                                   00068500
      /?C OUTPUT='MAJOR COMPACTIFY WILL BE TRIED.';?/                           00068600
     END;                                                                       00068700
   ELSE                                                                         00068800
      DO;                                                                       00068900
         LOWER_BOUND = FREEPOINT;                                               00069000
          /?C OUTPUT='COMPACTIFY DONE.'; ?/                                     00069100
         RETURN ND;                                                             00069200
      END;                                                                      00069300
   /* THE HOPE IS THAT WE WON'T HAVE TO COLLECT ALL THE STRINGS EVERY TIME */   00069400
   END;  /* OF THE DO TRIED LOOP       */                                       00069500
   IF _LAST_COMPACTIFY_FOUND < FREESTRING_TRIGGER THEN                          00069600
    DO;                                                                         00069700
      _IN_COMPACTIFY=_TRUE;                                                     00069800
      /?C OUTPUT='COMPACTIFY WILL STEAL BACK.'; ?/                              00069900
      K=_SPACE_ROUND(FREESTRING_TARGET - _LAST_COMPACTIFY_FOUND);               00070000
      IF FREEBYTES < K THEN                                                     00070100
       CALL _TAKE_BACK(K-FREEBYTES);                                            00070200
      IF FREEBYTES+_LAST_COMPACTIFY_FOUND < FREESTRING_MIN THEN                 00070300
       DO;                                                                      00070400
         OUTPUT='BI007 SEVERITY 3 NOT ENOUGH SPACE AVAILABLE -- ' ||            00070500
                'TRY LARGER REGION.';                                           00070510
         CALL EXIT;   /* DR104706 */                                            00070610
       END;                                                                     00070700
      IF K > FREEBYTES THEN K=FREEBYTES;                                        00070800
      CALL _RETURN_TO_FREESTRING(K);                                            00070900
      _IN_COMPACTIFY=_FALSE;                                                    00071000
    END;                                                                        00071100
      _LAST_COMPACTIFY_FOUND=FREELIMIT-FREEPOINT;                               00071200
      IF _LAST_COMPACTIFY_FOUND < FREESTRING_MIN THEN                           00071300
            DO;                                                                 00071400
               OUTPUT = 'BI008 SEVERITY 3 NOTICE FROM COMPACTIFY: ' ||          00071500
               'INSUFFICIENT MEMORY FOR STRING STORAGE. JOB ABANDONED.';        00071510
               CALL EXIT;   /* DR104706 */                                      00071710
            END;                                                                00071800
   RETURN ND;                                                                   00071900
END COMPACTIFY;                                                                 00072000
                                                                                00072100
_STEAL: PROCEDURE(NBYTES); /*STEAL NBYTES FROM FREE STRING AREA*/               00072200
   DECLARE NBYTES FIXED;                                                        00072300
   DECLARE BLOCKLOC FIXED;                                                      00072400
  /?A OUTPUT='STEALING '||NBYTES||'  FROM STRINGS, FREELIMIT='||_RF(FREELIMIT)||00072500
    ',FREEPOINT='||_RF(FREEPOINT)||',DIFF='||FREELIMIT-FREEPOINT; ?/            00072600
   IF CORELIMIT=0 THEN CORELIMIT=FREELIMIT+512;                                 00072700
   IF FREELIMIT-FREEPOINT < NBYTES THEN                                         00072800
    DO;                                                                         00072900
      FORCE_MAJOR=_TRUE;                                                        00073000
      CALL COMPACTIFY;                                                          00073100
    END;                                                                        00073200
   IF FREELIMIT-FREEPOINT < NBYTES THEN                                         00073300
    DO;                                                                         00073400
   /?A OUTPUT=FREELIMIT-FREEPOINT||' BYTES AVAILABLE, REQUIRED='||NBYTES;?/     00073500
      OUTPUT/?A,OUTPUT(2)?/= 'BI011 SEVERITY 3 ' ||                             00073600
         'NOT ENOUGH FREE STRING AVAILABLE, RERUN WITH LARGER REGION.';         00073700
      CALL EXIT;   /* DR104706 */                                               00073810
    END;                                                                        00073900
   _OLDFREELIMIT,FREELIMIT=FREELIMIT-NBYTES;                                    00074000
   FREEBYTES=FREEBYTES+NBYTES;                                                  00074100
   BLOCKLOC=FREELIMIT+NBYTES+512-4;                                             00074200
   _FREEBLOCK_NEXT(BLOCKLOC)=0;                                                 00074300
   _FREEBLOCK_SIZE(BLOCKLOC)=NBYTES;                                            00074400
   CALL _ATTACH_BLOCK(BLOCKLOC);                                                00074500
END _STEAL;                                                                     00074600
                                                                                00074700
DECLARE _GUARANTEE_FREE(1) _AS                                                  00074800
     'DO;IF FREEBYTES < %1% THEN CALL _STEAL(%1%-FREEBYTES);END;';              00074900
                                                                                00075000
_MOVE_RECS: PROCEDURE(DOPE,BYTES_TO_MOVE_BY);                                   00075100
   DECLARE (DOPE,BYTES_TO_MOVE_BY) FIXED;                                       00075200
   DECLARE (NBYTES,SOURCE,CURDOPE) FIXED;                                       00075300
   /?A OUTPUT=' MOVERECS OF DOPE='||DOPE||' FOR '||BYTES_TO_MOVE_BY; ?/         00075400
   CURDOPE=DOPE;                                                                00075500
   NBYTES=0;                                                                    00075600
   IF FIRSTBLOCK ^= 0 _ANDIF _FREEBLOCK_NEXT(FIRSTBLOCK)=0                      00075700
    _ANDIF _FREEBLOCK_SIZE(FIRSTBLOCK) >= BYTES_TO_MOVE_BY                      00075800
    THEN DO;  /*ASSUMES SQUASH -- TEMPORARILY -- WILL FIX*/                     00075900
      DO UNTIL CURDOPE=0;                                                       00076000
         SOURCE=_DOPE_POINTER(CURDOPE);                                         00076100
         NBYTES=NBYTES+ _RECORD#BYTES(CURDOPE);                                 00076200
         _DOPE_POINTER(CURDOPE)=_DOPE_POINTER(CURDOPE)-BYTES_TO_MOVE_BY;        00076300
         CURDOPE=_DOPE_NEXT(CURDOPE);                                           00076400
      END;                                                                      00076500
      CALL _REDUCE_BLOCK(FIRSTBLOCK,BYTES_TO_MOVE_BY,_TRUE);                    00076600
      CALL _MOVE_WORDS(SOURCE,SOURCE-BYTES_TO_MOVE_BY,NBYTES);                  00076700
      RETURN;                                                                   00076800
    END;                                                                        00076900
   CALL _SPMANERR('IN MOVE_RECS,FIRSTBLOCK='||_RF(FIRSTBLOCK)||' SIZE= '||      00077000
      _FREEBLOCK_SIZE(FIRSTBLOCK));                                             00077100
END _MOVE_RECS;                                                                 00077200
                                                                                00077300
_FIND_FREE: PROCEDURE(NBYTES,UNMOVEABLE) FIXED;                                 00077400
    /*RETURNS POINTER TO BLOCK CONTAINING AT LEAST NBYTES FREE BYTES*/          00077500
   DECLARE NBYTES FIXED, UNMOVEABLE BIT(1);                                     00077600
   DECLARE I BIT(16), CURBLOCK FIXED;                                           00077700
   /?A OUTPUT='_FIND_FREE, NBYTES='||NBYTES||',FREEBYTES='||FREEBYTES; ?/       00077800
   _GUARANTEE_FREE(NBYTES);                                                     00077900
   IF UNMOVEABLE THEN                                                           00078000
    DO;  /*GET SPACE BEFORE FIRST MOVEABLE*/                                    00078100
      CALL _SQUASH_RECORDS;                                                     00078200
      DECLARE DOPE FIXED;                                                       00078300
      DOPE=FIRSTRECORD;                                                         00078400
      DO WHILE DOPE^=0;                                                         00078500
         IF ^_IS_REC_UNMOVEABLE(DOPE) THEN                                      00078600
          DO;                                                                   00078700
            CURBLOCK=_DOPE_POINTER(DOPE)+_RECORD#BYTES(DOPE)-4;                 00078800
            CALL _MOVE_RECS(DOPE,NBYTES);                                       00078900
            _FREEBLOCK_SIZE(CURBLOCK)=NBYTES;                                   00079000
            _FREEBLOCK_NEXT(CURBLOCK)=0;                                        00079100
            CALL _ATTACH_BLOCK(CURBLOCK);                                       00079200
            RETURN CURBLOCK;                                                    00079300
          END;                                                                  00079400
         DOPE=_DOPE_NEXT(DOPE);                                                 00079500
       END;                                                                     00079600
      RETURN FIRSTBLOCK; /*ALL RECORDS UNMOVEABLE*/                             00079700
    END;                                                                        00079800
   DO I = 0 TO 1;                                                               00079900
      CURBLOCK=FIRSTBLOCK;                                                      00080000
      DO WHILE CURBLOCK ^= 0;                                                   00080100
        IF _FREEBLOCK_SIZE(CURBLOCK) >= NBYTES THEN RETURN CURBLOCK;            00080200
        CURBLOCK=_FREEBLOCK_NEXT(CURBLOCK);                                     00080300
      END;                                                                      00080400
      CALL _SQUASH_RECORDS;                                                     00080500
      RETURN FIRSTBLOCK;                                                        00080600
    END;                                                                        00080700
END _FIND_FREE;                                                                 00080800
                                                                                00080900
_INCREASE_RECORD: PROCEDURE(DOPE,NRECSMORE);                                    00081000
   DECLARE (DOPE,NRECSMORE) FIXED;                                              00081100
   DECLARE (OLDNRECS,OLDNBYTES,NEWNRECS,NEWNBYTES,NBYTESMORE,I) FIXED;          00081200
   /?A OUTPUT='INCREASE ALLOCATION OF '||DOPE||' BY '||NRECSMORE; ?/            00081300
   REALLOCATIONS=REALLOCATIONS+1;                                               00081400
   NEWNRECS=_DOPE_ALLOC(DOPE)+NRECSMORE;                                        00081500
   NEWNBYTES=_SPACE_ROUND(NEWNRECS*_DOPE_WIDTH(DOPE));                          00081600
   OLDNBYTES=_RECORD#BYTES(DOPE);                                               00081700
   NBYTESMORE=NEWNBYTES-OLDNBYTES;                                              00081800
   IF NBYTESMORE > FREEBYTES THEN CALL _STEAL(NBYTESMORE-FREEBYTES);            00081900
   CALL _SQUASH_RECORDS;                                                        00082000
   CALL _MOVE_RECS(DOPE,NBYTESMORE);                                            00082100
   DO I = _DOPE_POINTER(DOPE)+OLDNBYTES TO _DOPE_POINTER(DOPE)                  00082200
      +NEWNBYTES-4 BY 4;                                                        00082300
      COREWORD(I)=0;                                                            00082400
   END;                                                                         00082500
   _DOPE_ALLOC(DOPE)=NEWNRECS;                                                  00082600
   RECBYTES=RECBYTES+NBYTESMORE;                                                00082700
   FREEBYTES=FREEBYTES-NBYTESMORE;                                              00082800
   TOTAL_RDESC=TOTAL_RDESC+NRECSMORE*_DOPE_#DESCRIPTORS(DOPE);                  00082900
   CALL _FREEBLOCK_CHECK;                                                       00083000
END _INCREASE_RECORD;                                                           00083100
                                                                                00083200
_GET_SPACE: PROCEDURE(NBYTES,UNMOVEABLE) FIXED;                                 00083300
    /*GETS NBYTES BYTES OF FREE SPACE*/                                         00083400
   DECLARE NBYTES FIXED, UNMOVEABLE BIT(1);                                     00083500
   DECLARE (FREEB,NEWREC) FIXED;                                                00083600
   IF (NBYTES&"7") ^= 0 THEN CALL _SPMANERR(                                    00083700
    'IN _GET_SPACE, NBYTES='||NBYTES);                                          00083800
   FREEB=_FIND_FREE(NBYTES,UNMOVEABLE);                                         00083900
   /*FREEB NOW POINTS TO FREE BLOCK WITH AT LEAST NBYTES BYTES*/                00084000
   NEWREC=FREEB-NBYTES+4;                                                       00084100
   CALL _REDUCE_BLOCK(FREEB,NBYTES,_TRUE);                                      00084200
   DECLARE I FIXED;                                                             00084300
   DO I=0 TO NBYTES-4 BY 4;                                                     00084400
      COREWORD(NEWREC+I)=0;                                                     00084500
   END;                                                                         00084600
   RECBYTES=RECBYTES+NBYTES;                                                    00084700
   FREEBYTES=FREEBYTES-NBYTES;                                                  00084800
   RETURN NEWREC;                                                               00084900
END _GET_SPACE;                                                                 00085000
                                                                                00085100
_HOW_MUCH: PROCEDURE(DOPE,ANS) FIXED;                                           00085200
  /*RETURNS NUMBER OF RECORDS TO INCREASE ALLOCATION OF DOPE BY*/               00085300
   DECLARE (DOPE,ANS) FIXED;                                                    00085400
   DECLARE (ANSBYTES,NSTRBYTES,ANSMIN) FIXED;                                   00085500
   IF ANS=0 THEN ANS=_DOPE_ALLOC(DOPE)/2 + 10;                                  00085600
   ANSMIN=ANS/2;                                                                00085700
   ANSBYTES=_SPACE_ROUND(_DOPE_WIDTH(DOPE)*ANS);                                00085800
   NSTRBYTES=FREELIMIT-FREEPOINT-FREESTRING_TRIGGER;                            00085900
   IF NSTRBYTES < 0 THEN NSTRBYTES=0;                                           00086000
   IF ANSBYTES <= NSTRBYTES+FREEBYTES THEN RETURN ANS;                          00086100
   CALL _TAKE_BACK(ANSBYTES-NSTRBYTES-FREEBYTES);                               00086200
   IF ANSBYTES > NSTRBYTES+FREEBYTES _ANDIF ^_IS_REC_CONSTANT(DOPE) THEN        00086300
    DO;                                                                         00086400
      FORCE_MAJOR=_TRUE; CALL COMPACTIFY;                                       00086500
      /?A OUTPUT='MAJOR FOUND '||FREELIMIT-FREEPOINT;?/                         00086600
      NSTRBYTES=FREELIMIT-FREEPOINT-FREESTRING_TRIGGER;                         00086700
      IF ANSBYTES > NSTRBYTES+FREEBYTES THEN                                    00086800
         ANS=((NSTRBYTES+FREEBYTES)/_DOPE_WIDTH(DOPE)) -1;                      00086900
      IF ANS < ANSMIN THEN ANS=((NSTRBYTES+FREEBYTES+FREESTRING_TRIGGER         00087000
                       -FREESTRING_MIN))/_DOPE_WIDTH(DOPE)-1;                   00087100
      IF ANS < ANSMIN THEN DO;                                                  00087200
         OUTPUT='BI009 SEVERITY 3  NOT ENOUGH SPACE FOR INCREASED ' ||          00087300
                ' ALLOCATION, GIVING UP.';                                      00087310
         CALL EXIT;   /* DR104706 */                                            00087410
       END;                                                                     00087500
    END;                                                                        00087600
   RETURN ANS;                                                                  00087700
END _HOW_MUCH;                                                                  00087800
                                                                                00087900
_ALLOCATE_SPACE: PROCEDURE(DOPE,HIREC _IFA(NAME));                              00088000
   DECLARE (DOPE,HIREC,NREC,OREC) FIXED /?A,NAME CHARACTER?/ ;                  00088100
   OREC,NREC=HIREC+1;                                                           00088200
   /?A OUTPUT='ALLOCATING RECORD='||NAME||' ,DOPE='||DOPE||                     00088300
       ', WIDTH='||_DOPE_WIDTH(DOPE)||                                          00088400
     ',NUMDESC='||_DOPE_#DESCRIPTORS(DOPE)||',ALLOC='||NREC; ?/                 00088500
   IF _DOPE_WIDTH(DOPE) <= 0 THEN DO;                                           00088600
      CALL _SPMANERR('RECORD HAS WIDTH=0, DOPE='||DOPE/?A||', NAME='||NAME?/);  00088700
      RETURN;                                                                   00088800
    END;                                                                        00088900
   IF _DOPE_ALLOC(DOPE) > 0 THEN                                                00089000
    DO;                                                                         00089100
      CALL _SPMANERR('IN ALLOCATE_SPACE, ALREADY ALLOCATED: '||                 00089200
         /?A NAME||', DOPE='||?/DOPE);                                          00089300
      RETURN;                                                                   00089400
    END;                                                                        00089500
   NREC=_HOW_MUCH(DOPE,NREC);                                                   00089600
   /?A IF OREC^=NREC THEN OUTPUT='BUT ACTUALLY ALLOCATING '||NREC||             00089700
         ' FOR '||NAME; ?/                                                      00089800
   _DOPE_POINTER(DOPE)=_GET_SPACE(_SPACE_ROUND(_DOPE_WIDTH(DOPE) * NREC),       00089900
         _IS_REC_UNMOVEABLE(DOPE));                                             00090000
   _DOPE_ALLOC(DOPE)=NREC;                                                      00090100
   _DOPE_USED(DOPE)=0;                                                          00090200
   _NUM_TIMES_ZEROED(DOPE)=0;                                                   00090300
   CALL _ATTACH_RECORD(DOPE);                                                   00090400
END _ALLOCATE_SPACE;                                                            00090500
                                                                                00090600
_RECORD_CONSTANT: PROCEDURE(DOPE,HIREC,MOVEABLE _IFA(NAME));                    00090700
   DECLARE (DOPE,HIREC) FIXED, MOVEABLE BIT(1) /?A,NAME CHARACTER ?/;           00090800
   _MAKE_REC_CONSTANT(DOPE);  IF ^MOVEABLE THEN _MAKE_REC_UNMOVEABLE(DOPE);     00090900
   CALL _ALLOCATE_SPACE(DOPE,HIREC _IFA(NAME));                                 00091000
   _DOPE_USED(DOPE) = _DOPE_ALLOC(DOPE);                                        00091100
END _RECORD_CONSTANT;                                                           00091200
                                                                                00091300
                                                                                00091400
_NEEDMORE_SPACE: PROCEDURE(DOPE _IFA(NAME));                                    00091500
   DECLARE DOPE FIXED /?A,NAME CHARACTER?/ ;                                    00091600
   /?A OUTPUT='NEEDMORE SPACE FOR '||NAME||', DOPE='||DOPE; ?/                  00091700
   CALL _CHECK_FOR_THEFT;                                                       00091800
   IF _IS_REC_CONSTANT(DOPE) THEN CALL _SPMANERR(                               00091900
    'TRIED TO INCREASE CONSTANT RECORD, DOPE='||DOPE);                          00092000
  IF _DOPE_ALLOC(DOPE)=0 THEN                                                   00092100
   CALL _ALLOCATE_SPACE(DOPE,-1 _IFA(NAME));                                    00092200
    ELSE CALL _INCREASE_RECORD(DOPE,_HOW_MUCH(DOPE,0));                         00092300
END _NEEDMORE_SPACE;                                                            00092400
                                                                                00092500
_RECORD_SEAL: PROCEDURE(DOPE _IFA(NAME));    /*SEAL THE RECORD*/                00092600
   DECLARE DOPE FIXED /?A,NAME CHARACTER?/ ;                                    00092700
  /?A OUTPUT='SEALING RECORD '||NAME||', DOPE='||DOPE; ?/                       00092800
   CALL _RETURN_UNUSED(DOPE,0 _IFA(NAME));                                      00092900
   _MAKE_REC_CONSTANT(DOPE);                                                    00093000
END _RECORD_SEAL;                                                               00093100
                                                                                00093200
_RECORD_UNSEAL: PROCEDURE(DOPE _IFA(NAME));                                     00093300
   DECLARE DOPE FIXED /?A, NAME CHARACTER?/;                                    00093400
   /?A OUTPUT='UNSEAL '||NAME||' ,DOPE='||DOPE; ?/                              00093500
   IF ^_IS_REC_CONSTANT(DOPE) THEN CALL _SPMANERR(                              00093600
    'IN RECORD UNSEAL, RECORD NOT CONSTANT: '||/?ANAME||' ,DOPE='||?/DOPE);     00093700
   _DOPE_ASSOC(DOPE)=_DOPE_ASSOC(DOPE)&"FFFFFF";                                00093800
END _RECORD_UNSEAL;                                                             00093900
                                                                                00094000
_RECORD_GROUPHEAD: PROCEDURE(DOPE,GLOBFACT,GROUPFACT);                          00094100
   DECLARE DOPE FIXED, (GLOBFACT,GROUPFACT) BIT(16);                            00094200
   _DOPE_GLOBAL_FACTOR(DOPE)=GLOBFACT;                                          00094300
   /* _DOPE_GROUP_FACTOR(DOPE)=GROUPFACT; */                                    00094400
END _RECORD_GROUPHEAD;                                                          00094500
                                                                                00094600
_RECORD_COORDINATED: PROCEDURE(DOPE,REFDOPE,GROUPFACT);                         00094700
   DECLARE (DOPE,REFDOPE) FIXED, GROUPFACT BIT(16);                             00094800
   _DOPE_ASSOC(DOPE)=REFDOPE;                                                   00094900
   /* _DOPE_GROUP_FACTOR(DOPE)=GROUPFACT; */                                    00095000
END _RECORD_COORDINATED;                                                        00095100
                                                                                00095200
RECORD_LINK: PROCEDURE;  /*FIXES UP FOR LINK, DOES LINK*/                       00095300
   DECLARE _IS_COMMON(1) _AS '(%1% < ADDR(DESCRIPTOR))',                        00095400
           CUR FIXED;                                                           00095500
   CUR=FIRSTRECORD;                                                             00095600
   DO WHILE CUR > 0;                                                            00095700
      IF ^_IS_COMMON(CUR) THEN CALL _SPMANERR(                                  00095800
        'NON COMMON RECORD AT LINK, DOPE='||CUR);                               00095900
      IF ^_IS_REC_CONSTANT(CUR) THEN CALL _RETURN_UNUSED(CUR,0 /?A,'?'?/);      00096000
      CUR=_DOPE_NEXT(CUR);                                                      00096100
    END;                                                                        00096200
   CALL _RETURN_TO_FREESTRING(FREEBYTES);  /*DOES A SQUASH*/                    00096300
   CALL LINK;                                                                   00096400
END RECORD_LINK;                                                                00096500
   /% DEBUG N@ S@  %/                                                           00096600
