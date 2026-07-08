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
/*                            A - ADDR OF SDFPKG COMMTABL      */               
/*   THE FORMAT OF N:                                          */               
/*          0123              1516               31            */               
/*          ---------------------------------------            */               
/*          ||||_RESV           |    MODE NUMBER  |            */               
/*          |||_RELS                                           */               
/*          ||_MODF                                            */               
/*          |AUTO-SELECT                                       */               
/*                                                             */               
/* REVISION HISTORY :                                          */               
/* ----------------                                            */               
/*   DATE      NAME      DESCRIPTION OF CHANGE                 */               
/*                                                             */               
/*   X/XX/XX   DAS       CREATED                               */               
/*   8/18/94   LJK       EXPANDED FOR REHOST TESTING           */               
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
DECLARE FLAGS BIT(16);                                                          
                                                                                
/* INITIALIZE SDFPKG */                                                         
CALL MONITOR(22,0,ADDR(APGAREA));                                               
IF (CRETURN ^= 0) THEN OUTPUT = 'SDFPKG INITIALIZATION FAILED';                 
NAMEADDR = COREWORD(ADDR(NAME)) & "FFFFFF";                                     
SDFNAM  = COREWORD(NAMEADDR);                                                   
SDFNAMA = COREWORD(NAMEADDR+4);                                                 
                                                                                
/* SELECT THE SDF MEMBER */                                                     
CALL MONITOR(22,4);                                                             
OUTPUT = '--- SDFPKG SELECT '||NAME||' ---';                                    
                                                                                
/* LOCATE DIRECTORY ROOT CELL */                                                
OUTPUT = '--- SDFPKG MODE 7 TEST ---';                                          
CALL MONITOR(22,7);                                                             
FLAGS =  COREHALFWORD(ADDRESS);                                                 
OUTPUT = 'ROOT CELL = '|| PNTR ||' FLAGS = '|| FLAGS;                           
IF (FLAGS & "1000") ^= 0 THEN OUTPUT = 'FC_FLAG   IS SET';                      
IF (FLAGS & "4000") ^= 0 THEN OUTPUT = 'ADDR_FLAG IS SET';                      
IF (FLAGS & "8000") ^= 0 THEN OUTPUT = 'SRN_FLAG  IS SET';                      
IF (FLAGS & "0008") ^= 0 THEN OUTPUT = 'SDL_FLAG  IS SET';                      
SYMS = COREHALFWORD(ADDRESS+18);                                                
BLKS = COREHALFWORD(ADDRESS+16);                                                
FIRST_STMT = COREHALFWORD(ADDRESS+52);                                          
LAST_STMT = COREHALFWORD(ADDRESS+54);                                           
OUTPUT = 'TOTAL # SYMBOLS = '||SYMS;                                            
OUTPUT = 'TOTAL # BLOCKS  = '||BLKS;                                            
OUTPUT = '1ST STMT = '||FIRST_STMT||' LAST STMT = '||LAST_STMT;                 
                                                                                
/* LOCATE BLOCK NODE GIVEN BLOCK NUMBER */                                      
OUTPUT = ''; OUTPUT = '--- SDFPKG MODE 15 TEST ---';                            
DO I = 1 TO BLKS;                                                               
   BLKNO = I; /* BLOCKNO */                                                     
   CALL MONITOR(22,15);                                                         
   COREWORD(ADDR(C)) = SHL(7,24) + ADDR(CSECTNAM);/* CSECTNAM */                
   OUTPUT = 'BLOCK NODE '||I||' CSECT = '||C||' PNTR = '||PNTR;                 
END;                                                                            
                                                                                
 /* LOCATE BLOCK DATA CELL GIVEN BLOCK NUMBER */                                
OUTPUT = ''; OUTPUT = '--- SDFPKG MODE 8 & 11 TEST ---';                        
DO I = 1 TO BLKS;                                                               
   BLKNO = I; /* BLOCKNO */                                                     
   CALL MONITOR(22,8);                                                          
   NAME = STRING(SHL((BLKNLEN-1),24) + ADDR(BLKNAM));                           
   OUTPUT = 'BLOCK # '||I||' NAME = '|| NAME;                                   
   CALL MONITOR(22,11); /* LOCATE BLOCK DATA CELL */                            
   IF CRETURN = 0 THEN DO;                                                      
      COREWORD(ADDR(C)) = SHL(7,24) + ADDR(CSECTNAM);/* CSECTNAM */             
      OUTPUT = '  BLOCK '|| NAME||' CSECT ='||C||' PNTR = '||PNTR;              
   END;                                                                         
   IF CRETURN = 16                                                              
      THEN OUTPUT = '  BLOCK '|| NAME|| ' NOT FOUND';                           
END;                                                                            
                                                                                
/* LOCATE SYMBOL DATA CELL GIVEN SYMBOL NUMBER */                               
OUTPUT = ''; OUTPUT = '--- SDFPKG MODE 9  & 13 TEST ---';                       
DO I = 1 TO SYMS;                                                               
   SYMBNO = I; /* SYMBNO */                                                     
   CALL MONITOR(22,9);                                                          
   NAME = STRING(SHL((SYMBNLEN-1),24) + ADDR(SYMBNAM));                         
   OUTPUT = 'SYM # '||I||' NAME = '||NAME||' BLOCK # = '||BLKNO;                
   CALL MONITOR(22,8); /* MUST LOCATE BLOCK DATA CELL BEFORE MODE 13 */         
   /* LOCATE SYMBOL DATA CELL USING SYMBOL NAME ONLY */                         
   CALL MONITOR(22,13);                                                         
   IF CRETURN = 0                                                               
      THEN OUTPUT = '  LOCATED '||NAME||' SYMBNO= '||SYMBNO;                    
   IF CRETURN = 20                                                              
      THEN OUTPUT = '  '||NAME||' NOT FOUND';                                   
END;                                                                            
                                                                                
/* LOCATE SYM DATA CELL GIVEN SYM NAME & BLK NAME */                            
OUTPUT = ''; OUTPUT = '--- SDFPKG MODE 12 TEST ---';                            
/* USE SYM NAME & BLOCK NAME ALREADY STORED FROM PREVIOUS TESTS */              
CALL MONITOR(22,12); /* LOCATE THAT SYMBOL */                                   
IF CRETURN = 0 THEN DO;                                                         
   COREWORD(ADDR(C)) = SHL(7,24) + ADDR(CSECTNAM); /* CSECTNAME */              
   COREWORD(ADDR(NAME)) = SHL((SYMBNLEN-1),24) + ADDR(SYMBNAM);                 
   OUTPUT = 'LOCATED '||NAME||' SYMBNO= '||SYMBNO||' CSECT = '||C;              
END;                                                                            
IF CRETURN = 16 THEN DO;                                                        
   COREWORD(ADDR(NAME)) = SHL((BLKNLEN-1),24) + ADDR(BLKNAM);                   
   OUTPUT = 'BLOCK '||NAME||' NOT FOUND';                                       
END;                                                                            
IF CRETURN = 20 THEN DO;                                                        
   COREWORD(ADDR(NAME)) = SHL((SYMBNLEN-1),24) + ADDR(SYMBNAM);                 
   OUTPUT = NAME||' NOT FOUND';                                                 
END;                                                                            
                                                                                
/* LOCATE STMT DATA CELL GIVEN STMT NUMBER */                                   
OUTPUT = ''; OUTPUT = '--- SDFPKG MODE 10 TEST ---';                            
DO I = FIRST_STMT TO LAST_STMT;                                                 
   STMTNO = I;                                                                  
   CALL MONITOR(22,10); /* LOCATE STATEMENT DATA CELL */                        
   COREWORD(ADDR(NAME)) = SHL(5,24) + ADDR(SREFNO); /* SREFNO */                
   OUTPUT = 'ST#'||I||' BLKNO = '||BLKNO||' TYPE = '||                          
          COREBYTE(ADDRESS+3)||' PNTR = '||PNTR||' SREFNO = '||                 
      NAME||' INCLCNT = '||INCLCNT||' RETURN = '||CRETURN;                      
END;                                                                            
                                                                                
/* LOCATE STMT DATA CELL GIVEN SRN & INCLUDE COUNT */                           
OUTPUT = ''; OUTPUT = '--- SDFPKG MODE 14 TEST ---';                            
NAME = '002691';                                                                
NAMEADDR = COREWORD(ADDR(NAME)) & "FFFFFF";                                     
DO I = 0 TO 5;                                                                  
   COREBYTE(ADDR(SREFNO)+I) = COREBYTE(NAMEADDR+I); /* SREFNO */                
END;                                                                            
INCLCNT = 5; /* INCLCNT */                                                      
COREWORD(ADDR(C)) = SHL(5,24) + ADDR(SREFNO); /* SREFNO */                      
OUTPUT = 'LOCATING SREFNO '||C||' INCLCNT '||INCLCNT;                           
CALL MONITOR(22,14);                                                            
IF CRETURN = 0                                                                  
   THEN OUTPUT = 'ST#'||STMTNO||' BLKNO = '||BLKNO;                             
   ELSE OUTPUT = 'UNABLE TO LOCATE ST# BY SREFNO';                              
                                                                                
NAME = '002700';                                                                
NAMEADDR = COREWORD(ADDR(NAME)) & "FFFFFF";                                     
DO I = 0 TO 5;                                                                  
   COREBYTE(ADDR(SREFNO)+I) = COREBYTE(NAMEADDR+I); /* SREFNO */                
END;                                                                            
INCLCNT = 0; /* INCLCNT */                                                      
COREWORD(ADDR(C)) = SHL(5,24) + ADDR(SREFNO); /* SREFNO */                      
OUTPUT = 'LOCATING SREFNO '||C||' INCLCNT '||INCLCNT;                           
CALL MONITOR(22,14);                                                            
IF CRETURN = 0                                                                  
   THEN OUTPUT = 'ST#'||STMTNO||' BLKNO = '||BLKNO;                             
   ELSE OUTPUT = 'UNABLE TO LOCATE ST# BY SREFNO';                              
                                                                                
/* LOCATE SYMBOL INDEX TABLE ENTRY GIVEN SYMBOL NUMBER */                       
OUTPUT = ''; OUTPUT = '--- SDFPKG MODE 16 TEST ---';                            
DO I = 1 TO SYMS;                                                               
   SYMBNO = I; /* SYMBNO */                                                     
   CALL MONITOR(22,16);                                                         
   COREWORD(ADDR(C)) = SHL(7,24) + ADDRESS;  /* SYMBOL NAME */                  
   OUTPUT = 'SYMBOL # '||I||' SYMBOL NAME = '||C||' PNTR = '||PNTR;             
END;                                                                            
                                                                                
                                                                                
/* LOCATE STATEMENT NODE GIVEN STMT NUMBER */                                   
OUTPUT = ''; OUTPUT = '--- SDFPKG MODE 17 TEST ---';                            
DO I = FIRST_STMT TO LAST_STMT;                                                 
   STMTNO = I; /* STATEMENT # */                                                
   CALL MONITOR(22,17); /* LOCATE STATEMENT NODE */                             
   COREWORD(ADDR(NAME)) = SHL(5,24) + ADDR(SREFNO); /* SREFNO */                
   OUTPUT = 'ST#'||I||                                                          
         ' SREFNO = '||NAME||' INCLCNT = '||INCLCNT||' PNTR = '||PNTR;          
END;                                                                            
   STMTNO = 99; /* STATEMENT # */                                               
   CALL MONITOR(22,17);                                                         
   COREWORD(ADDR(NAME)) = SHL(5,24) + ADDR(SREFNO); /* SREFNO */                
   IF CRETURN = 0                                                               
    THEN OUTPUT = 'ST# 99 SREFNO ='||NAME;                                      
    ELSE OUTPUT = 'UNABLE TO LOCATE STMT NODE BY STMTNO';                       
                                                                                
/* TERMINATE SDFPKG */                                                          
CALL MONITOR(22, 1);                                                            
                                                                                
EOF EOF EOF                                                                     
