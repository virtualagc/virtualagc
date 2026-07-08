/***************************************************************/              
/* TEST CATEGORY :                                             */              
/* -------------                                               */              
/*   XPL TEST CASES FOR TESTING THE SDFPKG                     */              
/*                                                             */              
/* DESCRIPTION :                                               */              
/* -----------                                                 */              
/*   TEST CASE TO USE SDFPKG VIA THE MONITOR(22) INTERFACE.    */              
/*   THIS TEST CASE SHOULD GET A 4008 ABEND WHEN THE "MODF"    */              
/*   OPTION IS SPECIFIED BUT SDFPKG WAS NOT INITIALIZED WITH   */              
/*   "UPDAT" OPTION.                                           */              
/*                                                             */              
/*   MONITOR(22,N,A)         22 - TO CALL SDFPKG               */              
/*                            N - SDF MODE(0-17)               */              
/*                                                             */              
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
/*   8/31/94   LJK       BASELINED                             */              
/*                                                             */              
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
                                                                               
DECLARE (BLKS,SYMS) BIT(16);                                                   
DECLARE NAME CHARACTER INITIAL('##COPY1A');                                    
DECLARE NAMEADDR BIT(32);                                                      
                                                                               
/* INITIALIZE SDFPKG */                                                        
CALL MONITOR(22,0,ADDR(APGAREA));                                              
                                                                               
NAMEADDR = COREWORD(ADDR(NAME)) & "FFFFFF";                                    
SDFNAM  = COREWORD(NAMEADDR);                                                  
SDFNAMA = COREWORD(NAMEADDR+4);                                                
                                                                               
/* SELECT THE SDF MEMBER */                                                    
CALL MONITOR(22,4);                                                            
OUTPUT = '--- SDFPKG SELECT '||NAME||' ---';                                   
                                                                               
/* LOCATE DIRECTORY ROOT CELL */                                               
OUTPUT = '--- SDFPKG MODE 7 TEST ---';                                         
CALL MONITOR(22,"40000007");                                                   
                                                                               
SYMS = COREHALFWORD(ADDRESS+18);                                               
BLKS = COREHALFWORD(ADDRESS+16);                                               
OUTPUT = 'TOTAL # SYMBOLS = '||SYMS;                                           
OUTPUT = 'TOTAL # BLOCKS  = '||BLKS;                                           
                                                                               
EOF EOF EOF                                                                    
