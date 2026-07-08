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
                                                                                
DECLARE (BLKS,SYMS,FIRST_STMT,LAST_STMT) BIT(16);                               
DECLARE NAME CHARACTER INITIAL('##COPY1A');                                     
DECLARE NAMEADDR BIT(32);                                                       
DECLARE FLAGS  BIT(16);                                                         
BASED   DATABUF_FW FIXED;                                                       
                                                                                
/* INITIALIZE SDFPKG */                                                         
CALL MONITOR(22,0,ADDR(APGAREA));                                               
IF (CRETURN ^= 0) THEN OUTPUT = 'SDFPKG INITIALIZATION FAILED';                 
COREWORD(ADDR(DATABUF_FW)) = ADDRESS;                                           
NAMEADDR = COREWORD(ADDR(NAME)) & "FFFFFF";                                     
SDFNAM  = COREWORD(NAMEADDR);                                                   
SDFNAMA = COREWORD(NAMEADDR+4);                                                 
                                                                                
/* SELECT THE SDF MEMBER */                                                     
CALL MONITOR(22,4);                                                             
OUTPUT = '--- SDFPKG SELECT '||NAME||' ---';                                    
                                                                                
/* LOCATE DIRECTORY ROOT CELL BY POINTER */                                     
OUTPUT=''; OUTPUT = '--- SDFPKG MODE 5 TEST ---';                               
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
                                                                                
/* LOCATE SYMBOL NODE GIVEN PNTR */                                             
PNTR = 492;                                                                     
OUTPUT = ''; OUTPUT = '--- LOCATE SYMBOL NODE BY PNTR ---';                     
CALL MONITOR(22,"80000005"); /* LOCATE STATEMENT NODE */                        
COREWORD(ADDR(NAME)) = SHL(7,24) + ADDRESS;    /* SYMBOL NAME */                
OUTPUT = 'SYM #10'||                                                            
      ' SYMBOL NAME = '||NAME||' PNTR = '||PNTR;                                
                                                                                
CALL MONITOR(22, "10000006");     /* RESERVE THE DATA CELL */                   
                                                                                
/* PRINT SDFPKG STATISTICS IN DATABUF */                                        
OUTPUT = ' ';                                                                   
OUTPUT = 'TOTAL NUMBER OF LOCATE  = '||DATABUF_FW(0);                           
OUTPUT = 'TOTAL NUMBER OF RESERVE = '||DATABUF_FW(14);                          
OUTPUT = 'TOTAL NUMBER OF READ    = '||DATABUF_FW(15);                          
OUTPUT = 'TOTAL NUMBER OF WRITE   = '||DATABUF_FW(16);                          
OUTPUT = 'TOTAL NUMBER OF SELECT  = '||DATABUF_FW(17);                          
                                                                                
CALL MONITOR(22, 1); /* TERMINATE SDFPKG */                                     
                                                                                
EOF EOF EOF 

