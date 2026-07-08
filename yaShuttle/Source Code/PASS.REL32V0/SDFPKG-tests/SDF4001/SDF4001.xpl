/***************************************************************/               
/* TEST CATEGORY :                                             */               
/* -------------                                               */               
/*   XPL TEST CASES FOR TESTING THE SDFPKG                     */               
/*                                                             */               
/* DESCRIPTION :                                               */               
/* -----------                                                 */               
/*   TEST CASE TO USE SDFPKG VIA THE MONITOR(22) INTERFACE.    */               
/*   THIS TEST CASE SHOULD GET A 4001 ABEND WHEN ALL PAGES     */               
/*   ARE RESERVED.                                             */               
/*                                                             */               
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
/*   9/04/94   LJK       BASELINED                             */               
/*  10/09/96   DAS       SET NPAGES TO 1 SO THAT THE PAGING    */               
/*                       SIZE IS RESTRICTED WHICH WILL CAUSE   */               
/*                       THE ABEND 4001 TO OCCUR.              */               
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
DECLARE FLAGS  BIT(16);                                                         
                                                                                
/* INITIALIZE SDFPKG */                                                         
NPAGES = 1; /* DAS - RESTRICT PAGING SIZE SO ABEND 4001 GENERATED */
CALL MONITOR(22,0,ADDR(APGAREA));                                               
IF (CRETURN ^= 0) THEN OUTPUT = 'SDFPKG INITIALIZATION FAILED';                 
NAMEADDR = COREWORD(ADDR(NAME)) & "FFFFFF";                                     
SDFNAM  = COREWORD(NAMEADDR);                                                   
SDFNAMA = COREWORD(NAMEADDR+4);                                                 
                                                                                
/* SELECT THE SDF MEMBER */                                                     
CALL MONITOR(22,4);                                                             
OUTPUT = '--- SDFPKG SELECT '||NAME||' ---';                                    
                                                                                
/* LOCATE DIRECTORY ROOT CELL BY POINTER */                                     
PNTR =144;                                                                      
CALL MONITOR(22,"80000005");                                                    
                                                                                
FLAGS = COREHALFWORD(ADDRESS);                                                  
OUTPUT = 'ROOT CELL = '|| PNTR;                                                 
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
                                                                                
/* SET RESV FLAG FOR THE LAST LOCATED ITEM */                                   
   CALL MONITOR(22,"10000006");                                                 
                                                                                
/* LOCATE SYM DATA CELL GIVEN SYM NUMBER */                                     
OUTPUT = ''; OUTPUT = '--- SDFPKG MODE 9  & 13 TEST ---';                       
DO I = 1 TO SYMS;                                                               
   SYMBNO = I; /* SYMBNO */                                                     
   CALL MONITOR(22,9);                                                          
   NAME = STRING(SHL(SYMBNLEN,24)+ ADDR(SYMBNAM));                              
   OUTPUT = 'SYM # '||I||' NAME = '||NAME||' BLOCK # = '||BLKNO;                
   CALL MONITOR(22,8); /* MUST LOCATE BLOCK DATA CELL BEFORE MODE 13 */         
   CALL MONITOR(22,13); /* LOCATE SYMBOL DATA CELL USING SYMBOL NAME */         
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
   COREWORD(ADDR(NAME)) = SHL(SYMBNLEN,24)+ ADDR(SYMBNAM); /* SYM NAME */       
   OUTPUT = 'LOCATED '||NAME||' SYMBNO= '||SYMBNO||' CSECT = '||C;              
END;                                                                            
IF CRETURN = 16 THEN DO;                                                        
   COREWORD(ADDR(NAME)) = SHL(BLKNLEN,24)+ ADDR(BLKNAM); /* BLK NAME */         
   OUTPUT = 'BLOCK '||NAME||' NOT FOUND';                                       
END;                                                                            
IF CRETURN = 20 THEN DO;                                                        
   COREWORD(ADDR(NAME)) = SHL(SYMBNLEN,24)+ ADDR(SYMBNAM); /* SYM NAME */       
   OUTPUT = NAME||' NOT FOUND';                                                 
END;                                                                            
                                                                                
/* LOCATE STMT NODE GIVEN PNTR */                                               
 PNTR = 660;                                                                    
 OUTPUT = ''; OUTPUT = '--- LOCATE STMT NODE BY PNTR ---';                      
 CALL MONITOR(22,"80000005"); /* LOCATE SYMBOL NODE */                          
 COREWORD(ADDR(C)) = SHL(7,24) + ADDRESS;    /* SREFNO */                       
 OUTPUT = 'STMT #10'||                                                          
       ' STMT SREFNO = '||C||' PNTR = '||PNTR;                                  
                                                                                
/* LOCATE SYMBOL NODE GIVEN PNTR */                                             
 PNTR = 492;                                                                    
 OUTPUT = ''; OUTPUT = '--- LOCATE SYMBOL NODE BY PNTR  ---';                   
 CALL MONITOR(22,"80000005"); /* LOCATE SYMBOL NODE */                          
 COREWORD(ADDR(NAME)) = SHL(7,24) + ADDRESS;    /* SYMBOL NAME */               
 OUTPUT = 'SYM #10'||                                                           
       ' SYMBOL NAME = '||NAME||' PNTR = '||PNTR;                               
                                                                                
/* LOCATE STMT DATA CELL GIVEN PNTR */                                          
 OUTPUT = ''; OUTPUT = '--- LOCATE STMT DATA CELL BY PNTR ---';                 
 PNTR   = 66908;                                                                
 CALL MONITOR(22, 5); /* LOCATE STATEMENT DATA CELL */                          
 OUTPUT = 'STMT #15  STMT TYPE = '||                                            
                  COREBYTE(ADDRESS+3)||' PNTR = '||PNTR;                        
                                                                                
 CALL MONITOR(22, "10000006");     /* RESERVE THE DATA CELL */                  
                                                                                
EOF EOF EOF                                                                     
