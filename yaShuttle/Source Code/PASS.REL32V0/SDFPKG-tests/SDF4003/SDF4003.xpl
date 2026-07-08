/***************************************************************/               
/* TEST CATEGORY :                                             */               
/* -------------                                               */               
/*   XPL TEST CASES FOR TESTING THE SDFPKG                     */               
/*                                                             */               
/* DESCRIPTION :                                               */               
/* -----------                                                 */               
/*   TEST CASE TO USE SDFPKG VIA THE MONITOR(22) INTERFACE.    */               
/*   THIS TEST CASE SHOULD GET A 4003 ABEND WHEN TOO MANY      */               
/*   RESERVES WERE PERFORMED FOR ONE PAGE.                     */               
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
/*   9/07/94   LJK       BASELINED                             */               
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
CALL MONITOR(22,"80000007");                                                    
SYMS = COREHALFWORD(ADDRESS+18);                                                
BLKS = COREHALFWORD(ADDRESS+16);                                                
FIRST_STMT = COREHALFWORD(ADDRESS+52);                                          
LAST_STMT = COREHALFWORD(ADDRESS+54);                                           
OUTPUT = 'TOTAL # SYMBOLS = '||SYMS;                                            
OUTPUT = 'TOTAL # BLOCKS  = '||BLKS;                                            
OUTPUT = '1ST STMT = '||FIRST_STMT||' LAST STMT = '||LAST_STMT;                 
                                                                                
 /* LOCATE BLOCK DATA CELL GIVEN BLOCK NUMBER */                                
OUTPUT = ''; OUTPUT = '--- SDFPKG MODE 8 & 11 TEST ---';                        
DO I = 1 TO BLKS;                                                               
   BLKNO = I; /* BLOCKNO */                                                     
   CALL MONITOR(22,"10000008");                                                 
   NAME = STRING(SHL(BLKNLEN,24)+ADDR(BLKNAM));                                 
   OUTPUT = 'BLOCK # '||I||' NAME = '|| NAME;                                   
   CALL MONITOR(22,11); /* LOCATE BLOCK DATA CELL */                            
   IF CRETURN = 0 THEN DO;                                                      
      COREWORD(ADDR(C)) = SHL(7,24) + ADDR(CSECTNAM);                           
      OUTPUT = '  BLOCK '|| NAME||' CSECT ='||C;                                
   END;                                                                         
   IF CRETURN = 16                                                              
      THEN OUTPUT = '  BLOCK '|| NAME|| ' NOT FOUND';                           
END;                                                                            
                                                                                
/* LOCATE STATEMENT NODE GIVEN STMT NUMBER */                                   
OUTPUT = ''; OUTPUT = '--- RESERVE COUNT OVERFLOW ---';                         
DO I = 1 TO 100;                                                                
  DO I = FIRST_STMT TO LAST_STMT;                                               
    STMTNO = I;                                                                 
    CALL MONITOR(22,17); /* LOCATE STATEMENT NODE */                            
    CALL MONITOR(22,"10000006"); /* SET RESV FLAG FOR LOCATED ITEM */           
    COREWORD(ADDR(NAME)) = SHL(5,24) + ADDR(SREFNO); /* SREFNO */               
    /* OUTPUT = 'ST#'||I||NAME||' INCLCNT = '||INCLCNT; */                      
  END;                                                                          
END;                                                                            
                                                                                
                                                                                
EOF EOF EOF                                                                     
