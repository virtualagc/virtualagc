/***************************************************************/               
/* TEST CATEGORY :                                             */               
/* -------------                                               */               
/*   XPL TEST CASES FOR TESTING THE SDFPKG                     */               
/*                                                             */               
/* DESCRIPTION :                                               */               
/* -----------                                                 */               
/*   TEST CASE TO USE SDFPKG VIA THE MONITOR(22) INTERFACE.    */               
/*   THIS TEST CASE SHOULD GET A 4022 ABEND WHEN PAGES OF LAST */               
/*   SELECTED SDF ARE STILL RESERVED AND A NEW SDF SELECT      */               
/*   REQUEST WAS MADE.                                         */               
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
DECLARE (BLKS,SYMS) BIT(16);                                                    
DECLARE SDFNAM1 CHARACTER INITIAL('##COPY1A');                                  
DECLARE SDFNAM2 CHARACTER INITIAL('##COPY2A');                                  
DECLARE NAME    CHARACTER;                                                      
DECLARE NAMEADDR BIT(32);                                                       
DECLARE FLAGS  BIT(16);                                                         
                                                                                
/* INITIALIZE SDFPKG IN ONE-FCB MODE */                                         
MISC = 8;                                                                       
CALL MONITOR(22,0,ADDR(APGAREA));                                               
IF (CRETURN ^= 0) THEN OUTPUT = 'SDFPKG INITIALIZATION FAILED';                 
NAMEADDR = COREWORD(ADDR(SDFNAM1)) & "FFFFFF";                                  
SDFNAM  = COREWORD(NAMEADDR);                                                   
SDFNAMA = COREWORD(NAMEADDR+4);                                                 
                                                                                
/* SELECT THE SDF MEMBER */                                                     
CALL MONITOR(22, 4);                                                            
OUTPUT = '--- SDFPKG SELECT '||SDFNAM1||' ---';                                 
                                                                                
/* LOCATE DIRECTORY ROOT CELL */                                                
OUTPUT = '--- SDFPKG MODE 7 TEST ---';                                          
CALL MONITOR(22, 7);                                                            
SYMS = COREHALFWORD(ADDRESS+18);                                                
BLKS = COREHALFWORD(ADDRESS+16);                                                
OUTPUT = 'TOTAL # SYMBOLS = '||SYMS;                                            
OUTPUT = 'TOTAL # BLOCKS  = '||BLKS;                                            
                                                                                
/* LOCATE STATEMENT NODE GIVEN STMT NUMBER */                                   
OUTPUT = ''; OUTPUT = '--- SDFPKG MODE 17 TEST ---';                            
STMTNO = 9;                                                                     
CALL MONITOR(22,17);                                                            
COREWORD(ADDR(NAME)) = SHL(5,24) + ADDR(SREFNO); /* SREFNO */                   
OUTPUT = 'ST#9 SREFNO = '||NAME||' INCLCNT = '||INCLCNT;                        
CALL MONITOR(22,"10000006"); /* RESERVE LOCATED ITEM */                         
                                                                                
/* SELECT NEW SDF MEMBER BEFORE RELEASE LAST SELECTED SDF PAGES */              
NAMEADDR = COREWORD(ADDR(SDFNAM2)) & "FFFFFF";                                  
SDFNAM  = COREWORD(NAMEADDR);                                                   
SDFNAMA = COREWORD(NAMEADDR+4);                                                 
CALL MONITOR(22, 4);                                                            
OUTPUT = '--- SDFPKG SELECT '||SDFNAM2||' ---';                                 
                                                                                
EOF EOF EOF                                                                     
