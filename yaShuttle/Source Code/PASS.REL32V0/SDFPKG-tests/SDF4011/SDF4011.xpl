/***************************************************************/               
/* TEST CATEGORY :                                             */               
/* -------------                                               */               
/*   XPL TEST CASES FOR TESTING THE SDFPKG                     */               
/*                                                             */               
/* DESCRIPTION :                                               */               
/* -----------                                                 */               
/*   TEST CASE TO USE SDFPKG VIA THE MONITOR(22) INTERFACE.    */               
/*   MONITOR(22,N,A)         22 - TO CALL SDFPKG               */               
/*                            N - SDF MODE(0-17)               */               
/*                                                             */               
/*   THIS TEST SHOULD GET A 4011 USER ABEND DUE TO THE PAGING  */               
/*   AREA RESCIND FAILURE - ONE OR MORE PAGES ARE RESERVED.    */               
/*                                                             */               
/* REVISION HISTORY :                                          */               
/* ----------------                                            */               
/*   DATE      NAME      DESCRIPTION OF CHANGE                 */               
/*                                                             */               
/*   9/14/94   LJK       BASELINED FOR REHOST TESTING          */               
/***************************************************************/               
                                                                                
/* SDFPKG COMMUNICATION TABLE */                                                
                                                                                
DECLARE APGAREA  FIXED;   /* ADDR OF EXTERNAL PAGING AREA */                    
DECLARE AFCBAREA FIXED;   /* ADDR OF EXTERNAL FCB AREA */                       
DECLARE NPAGES   BIT(16); /* # OF PGS IN PAGING AREA OR AUGMENT */              
DECLARE NBYTES   BIT(16); /* # OF BYTES IN FCB AREA OR AUGMENT */               
DECLARE MISC     BIT(16); /* MISC PURPOSES */                                   
DECLARE CRETURN  BIT(16); /* SDFPKG RETURN CODE */                              
DECLARE BLKNO    BIT(16); /* BLOCK NUMBER */                                    
DECLARE SYMBNO   BIT(16); /* SYMBOL NUMBER */                                   
DECLARE STMTNO   BIT(16); /* STATEMENT NUMBER */                                
DECLARE BLKNLEN  BIT(8);  /* NUMBER OF CHARS IN BLOCK NAME */                   
DECLARE SYMBNLEN BIT(8);  /* NUMBER OF CHATS IN SYMBOL NAME */                  
DECLARE PNTR     FIXED;   /* VMEM POINTER LAST LOCATED */                       
DECLARE ADDRESS  FIXED;   /* CORE ADDRESS CORRESPONDING TO PNTR */              
DECLARE SDFNAM   FIXED;   /* NAME OF SDF TO BE SELECTED */                      
DECLARE SDFNAMA  FIXED;   /* NAME OF SDF TO BE SELECTED */                      
DECLARE CSECTNAM FIXED;   /* NAME OF CODE CSECT FOR BLOCK */                    
DECLARE COMM40B  FIXED;                                                         
DECLARE SREFNO   FIXED;   /* STATEMENT REFERENCE NUMBER */                      
DECLARE COMM48B  BIT(16);                                                       
DECLARE INCLCNT  BIT(16); /* INCLUDE COUNT */                                   
DECLARE BLKNAM   FIXED;   /* BLOCK NAME */                                      
DECLARE COMM56B  FIXED;                                                         
DECLARE COMM56C  FIXED;                                                         
DECLARE COMM56D  FIXED;                                                         
DECLARE COMM56E  FIXED;                                                         
DECLARE COMM56F  FIXED;                                                         
DECLARE COMM56G  FIXED;                                                         
DECLARE COMM56H  FIXED;                                                         
DECLARE SYMBNAM  FIXED;   /* SYMBOL NAME */                                     
DECLARE COMM88B  FIXED;                                                         
DECLARE COMM88C  FIXED;                                                         
DECLARE COMM88D  FIXED;                                                         
DECLARE COMM88E  FIXED;                                                         
DECLARE COMM88F  FIXED;                                                         
DECLARE COMM88G  FIXED;                                                         
DECLARE COMM88H  FIXED;                                                         
                                                                                
DECLARE C CHARACTER;                                                            
DECLARE (I,BLKS,SYMS,FIRST_STMT,LAST_STMT) BIT(16);                             
DECLARE NAME CHARACTER INITIAL('##COPY1A');                                     
DECLARE NAMEADDR BIT(32);                                                       
DECLARE PGBUFF(1680)  BIT(16);                                                  
DECLARE PGBUF1(1680)  BIT(16);                                                  
DECLARE PGBUF2(1680)  BIT(32);                                                  
BASED   HALFWORD      BIT(16);                                                  
                                                                                
                                                                                
/* INITIALIZE SDFPKG WITH EXTERNAL PAGING AREA SUPPLIED */                      
MISC = 13;                                                                      
NPAGES = 2;                                                                     
APGAREA = ADDR(PGBUFF);                                                         
CALL MONITOR(22,0,ADDR(APGAREA));                                               
IF (CRETURN ^= 0) THEN OUTPUT = 'SDFPKG INITIALIZATION FAILED';                 
OUTPUT = 'NUM OF PAGES CAN YET BE ADDED = '||NPAGES;                            
                                                                                
NAMEADDR = COREWORD(ADDR(NAME)) & "FFFFFF";                                     
SDFNAM   = COREWORD(NAMEADDR);                                                  
SDFNAMA  = COREWORD(NAMEADDR+4);                                                
                                                                                
/* SELECT THE SDF MEMBER */                                                     
CALL MONITOR(22,4);                                                             
OUTPUT=''; OUTPUT = '--- SDFPKG SELECT '||NAME||' ---';                         
                                                                                
/* LOCATE DIRECTORY ROOT CELL */                                                
OUTPUT=''; OUTPUT = '--- SDFPKG MODE 7 TEST ---';                               
CALL MONITOR(22,"80000007");                                                    
COREWORD(ADDR(HALFWORD)) = ADDRESS;                                             
SYMS = HALFWORD(9);                                                             
BLKS = HALFWORD(8);                                                             
FIRST_STMT = HALFWORD(26);                                                      
LAST_STMT = HALFWORD(27);                                                       
OUTPUT = 'TOTAL # SYMBOLS = '||SYMS;                                            
OUTPUT = 'TOTAL # BLOCKS  = '||BLKS;                                            
OUTPUT = '1ST STMT = '||FIRST_STMT||' LAST STMT = '||LAST_STMT;                 
                                                                                
                                                                                
/* LOCATE SYM DATA CELL GIVEN SYM NUMBER */                                     
OUTPUT = ''; OUTPUT = '--- SDFPKG MODE 9  & 13 TEST ---';                       
DO I = 5 TO 10;                                                                 
   SYMBNO = I;                                                                  
   CALL MONITOR(22,9);                                                          
   NAME = STRING(SHL(SYMBNLEN,24)+ ADDR(SYMBNAM));                              
   OUTPUT = 'SYM # '||I||' NAME = '||NAME||' BLOCK # = '||BLKNO;                
   CALL MONITOR(22,8);                                                          
   /* LOCATE SYMBOL DATA CELL USING SYMBOL NAME */                              
   CALL MONITOR(22,13);                                                         
   IF CRETURN = 0                                                               
      THEN OUTPUT = '  LOCATED '||NAME||' SYMBNO= '||SYMBNO;                    
   IF CRETURN = 20                                                              
      THEN OUTPUT = '  '||NAME||' NOT FOUND';                                   
END;                                                                            
   CALL MONITOR(22,"10000006");                                                 
                                                                                
/* AUGMEMT SDFPKG PAGING AREA */                                                
OUTPUT = ' '; OUTPUT = '--- SDFPKG MODE 2 TEST  ---';                           
NPAGES = 2;                                                                     
APGAREA = ADDR(PGBUF1);                                                         
CALL MONITOR(22, 2);   /* AUGMENT 2 PAGES */                                    
IF (CRETURN ^= 0) THEN OUTPUT = 'AUGMENT PAGING AREA FAILED';                   
   ELSE OUTPUT = 'NUM OF PAGES CAN YET BE ADDED = '||NPAGES;                    
NPAGES = 4;                                                                     
APGAREA = ADDR(PGBUF2);                                                         
CALL MONITOR(22, 2);     /* AUGMENT 4 PAGES */                                  
IF (CRETURN ^= 0) THEN OUTPUT = 'AUGMENT PAGING AREA FAILED';                   
   ELSE OUTPUT = 'NUM OF PAGES CAN YET BE ADDED = '||NPAGES;                    
                                                                                
/* LOCATE STATEMENT NODE GIVEN STMT NUMBER */                                   
OUTPUT = ''; OUTPUT = '--- SDFPKG MODE 17 TEST ---';                            
DO I = 1 TO 5;                                                                  
   STMTNO = I;                                                                  
   CALL MONITOR(22,17);         /* LOCATE THE DATA CELL */                      
   CALL MONITOR(22,"10000006"); /* RESERVE THE DATA CELL */                     
   COREWORD(ADDR(NAME)) = SHL(5,24) + ADDR(SREFNO);                             
   OUTPUT = 'ST#'||I||                                                          
         ' SREFNO = '||NAME||' INCLCNT = '||INCLCNT||' PNTR = '||PNTR;          
END;                                                                            
                                                                                
/* RESCIND SDFPKG PAGING AREA AUGMENTS */                                       
OUTPUT = ' '; OUTPUT = '--- SDFPKG MODE 3 TEST  ---';                           
CALL MONITOR(22, 3);                                                            
IF (CRETURN ^= 0) THEN OUTPUT = 'RESCIND PAGING AREA FAILED';                   
   ELSE OUTPUT = 'NUM OF PAGES CAN YET BE ADDED = '||NPAGES;                    
                                                                                
EOF EOF EOF                                                                     
