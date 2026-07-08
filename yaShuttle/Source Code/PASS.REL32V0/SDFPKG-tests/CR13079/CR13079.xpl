/***************************************************************/               00001000
/* TEST CATEGORY :                                             */               00002000
/* -------------                                               */               00003000
/*   CR13079 - ADD HAL/S INITIALIZATION DATA TO SDF            */               00004000
/*   XPL TEST CASE FOR TESTING SDFPKG MODE 18                  */               00004000
/*                                                             */               00005000
/* DESCRIPTION :                                               */               00006000
/* -----------                                                 */               00007000
/*   TEST CASE TO USE SDFPKG VIA THE MONITOR(22) INTERFACE.    */               00008000
/*   MONITOR(22,N,A)         22 - TO CALL SDFPKG               */               00009000
/*                            N - SDF MODE(0-18)               */               00009100
/*                                                             */               00009200
/*   REQUIRES THE SDF FOR HAL TESTCASE "CR3079"                */               00009200
/*   VERIFY THAT THE OUTPUT REFLECTS THE INITIALIZATION        */               00009200
/*   VALUES FOR THE HAL VARIABLES IN CR3079.                   */               00009200
/*                                                             */               00009200
/* REVISION HISTORY :                                          */               00009600
/* ----------------                                            */               00009700
/*   DATE      NAME      DESCRIPTION OF CHANGE                 */               00009800
/*                                                             */               00009900
/*   5/13/99   DAS       CREATED                               */               00010000
/***************************************************************/               00011000
                                                                                00012000
/* SDFPKG COMMUNICATION TABLE */                                                00013000
                                                                                00014000
DECLARE APGAREA  FIXED;   /* ADDR OF EXTERNAL PAGING AREA */                    00015000
DECLARE AFCBAREA FIXED;   /* ADDR OF EXTERNAL FCB AREA */                       00016000
DECLARE NPAGES   BIT(16); /* # OF PGS IN PAGING AREA OR AUGMENT */              00017000
DECLARE NBYTES   BIT(16); /* # OF BYTES IN FCB AREA OR AUGMENT */               00018000
DECLARE MISC     BIT(16); /* MISC PURPOSES */                                   00019000
DECLARE CRETURN  BIT(16); /* SDFPKG RETURN CODE */                              00020000
DECLARE BLKNO    BIT(16); /* BLOCK NUMBER */                                    00021000
DECLARE SYMBNO   BIT(16); /* SYMBOL NUMBER */                                   00022000
DECLARE STMTNO   BIT(16); /* STATEMENT NUMBER */                                00022100
DECLARE BLKNLEN  BIT(8);  /* NUMBER OF CHARS IN BLOCK NAME */                   00022200
DECLARE SYMBNLEN BIT(8);  /* NUMBER OF CHATS IN SYMBOL NAME */                  00022300
DECLARE PNTR     FIXED;   /* VMEM POINTER LAST LOCATED */                       00022400
DECLARE ADDRESS  FIXED;   /* CORE ADDRESS CORRESPONDING TO PNTR */              00022500
DECLARE SDFNAM   FIXED;   /* NAME OF SDF TO BE SELECTED */                      00022600
DECLARE SDFNAMA  FIXED;   /* NAME OF SDF TO BE SELECTED */                      00022700
DECLARE CSECTNAM FIXED;   /* NAME OF CODE CSECT FOR BLOCK */                    00022800
DECLARE COMM40B  FIXED;                                                         00022900
DECLARE SREFNO   FIXED;   /* STATEMENT REFERENCE NUMBER */                      00023000
DECLARE COMM48B  BIT(16);                                                       00024000
DECLARE INCLCNT  BIT(16); /* INCLUDE COUNT */                                   00025000
DECLARE BLKNAM   FIXED;   /* BLOCK NAME */                                      00026000
DECLARE COMM56B  FIXED;                                                         00027000
DECLARE COMM56C  FIXED;                                                         00028000
DECLARE COMM56D  FIXED;                                                         00029000
DECLARE COMM56E  FIXED;                                                         00030000
DECLARE COMM56F  FIXED;                                                         00040000
DECLARE COMM56G  FIXED;                                                         00050000
DECLARE COMM56H  FIXED;                                                         00060000
DECLARE SYMBNAM  FIXED;   /* SYMBOL NAME */                                     00070000
DECLARE COMM88B  FIXED;                                                         00080000
DECLARE COMM88C  FIXED;                                                         00090000
DECLARE COMM88D  FIXED;                                                         00100000
DECLARE COMM88E  FIXED;                                                         00100100
DECLARE COMM88F  FIXED;                                                         00100200
DECLARE COMM88G  FIXED;                                                         00100300
DECLARE COMM88H  FIXED;                                                         00100400
                                                                                00100500
DECLARE C CHARACTER;                                                            00100600
DECLARE (I,BLKS,SYMS,FIRST_STMT,LAST_STMT) BIT(16);                             00100700
DECLARE NAME CHARACTER INITIAL('##CR3079');                                     00100801
DECLARE NAMEADDR BIT(32);                                                       00100900
BASED   HALFWORD      BIT(16);                                                  00104000
                                                                                00106000
/* INITIALIZE SDFPKG */                                                         00107000
CALL MONITOR(22,0,ADDR(APGAREA));                                               00120000
IF (CRETURN ^= 0) THEN OUTPUT = 'SDFPKG INITIALIZATION FAILED';                 00130000
OUTPUT = 'NUM OF PAGES CAN YET BE ADDED = '||NPAGES;                            00140000
                                                                                00150000
NAMEADDR = COREWORD(ADDR(NAME)) & "FFFFFF";                                     00160000
SDFNAM   = COREWORD(NAMEADDR);                                                  00170000
SDFNAMA  = COREWORD(NAMEADDR+4);                                                00180000
                                                                                00190000
/* SELECT THE SDF MEMBER */                                                     00200000
CALL MONITOR(22,4);                                                             00210000
OUTPUT=''; OUTPUT = '--- SDFPKG SELECT '||NAME||' ---';                         00220000
                                                                                00230000
/* LOCATE DIRECTORY ROOT CELL */                                                00240000
OUTPUT=''; OUTPUT = '--- SDFPKG MODE 7 TEST ---';                               00250000
CALL MONITOR(22,"80000007");                                                    00260000
COREWORD(ADDR(HALFWORD)) = ADDRESS;                                             00270000
SYMS = HALFWORD(9);                                                             00280000
BLKS = HALFWORD(8);                                                             00290000
FIRST_STMT = HALFWORD(26);                                                      00300000
LAST_STMT = HALFWORD(27);                                                       00310000
OUTPUT = 'TOTAL # SYMBOLS = '||SYMS;                                            00320000
OUTPUT = 'TOTAL # BLOCKS  = '||BLKS;                                            00330000
OUTPUT = '1ST STMT = '||FIRST_STMT||' LAST STMT = '||LAST_STMT;                 00340000
                                                                                00350000
                                                                                00500000
/* LOCATE SYM DATA CELL GIVEN SYM NUMBER */                                     00510000
OUTPUT = ''; OUTPUT = '--- SDFPKG MODE 9  & 18 TEST ---';                       00520000
DO I = 1 TO SYMS;                                                               00530001
   SYMBNO = I;                                                                  00540000
   CALL MONITOR(22,9);                                                          00550000
   NAME = STRING(SHL(SYMBNLEN,24)+ ADDR(SYMBNAM));                              00560000
   OUTPUT = 'SYM # '||I||' NAME = '||NAME||' BLOCK # = '||BLKNO;                00570000
   IF CRETURN = 0 THEN DO;                                                      00610000
      DECLARE (CLASS,J) BIT(16);
      DECLARE (SIZE,FLAGS) BIT(32);
      OUTPUT = '  LOCATED '||NAME||' SYMBNO= '||SYMBNO||
               '  OFFSET = '||(COREWORD(ADDRESS+12) & "FFFFFF");
      SIZE   = COREWORD(ADDRESS+20) & "FFFFFF";
      OUTPUT = '  SIZE   = '||SIZE;
      CLASS = COREBYTE(ADDRESS+6);
      OUTPUT = '  CLASS  = '||CLASS||' TYPE = '||COREBYTE(ADDRESS+7);
      FLAGS = COREWORD(ADDRESS+8);
      CALL MONITOR(22,18); /* LOCATE INITIAL DATA */
      IF CLASS = 1 THEN /* MUST BE VARIABLE CLASS */
      IF (FLAGS & "00004000") ^= 0 THEN /* INITIALIZED */
      DO J = 0 TO (SIZE-1)*2 BY 2;
         OUTPUT= '     '||J/2||': '||COREHALFWORD(ADDRESS+J);
      END;
   END;                                                                         00650000
   ELSE IF CRETURN = 20                                                         00630000
      THEN OUTPUT = '  '||NAME||' NOT FOUND';                                   00640000
END;                                                                            00650000
                                                                                00660000
                                                                                00950000
EOF EOF EOF                                                                     00960000
