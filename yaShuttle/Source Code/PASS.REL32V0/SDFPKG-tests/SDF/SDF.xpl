DECLARE COMM0   FIXED;                                                          
DECLARE COMM4   FIXED;                                                          
DECLARE COMM8   BIT(16);                                                        
DECLARE COMM10  BIT(16);                                                        
DECLARE COMM12  BIT(16);                                                        
DECLARE COMM14  BIT(16);                                                        
DECLARE COMM16  BIT(16);                                                        
DECLARE COMM18  BIT(16);                                                        
DECLARE COMM20  BIT(16);                                                        
DECLARE COMM22  BIT(8);                                                         
DECLARE COMM23  BIT(8);                                                         
DECLARE COMM24  FIXED;                                                          
DECLARE COMM28  FIXED;                                                          
DECLARE COMM32A FIXED;                                                          
DECLARE COMM32B FIXED;                                                          
DECLARE COMM40A FIXED;                                                          
DECLARE COMM40B FIXED;                                                          
DECLARE COMM48A FIXED;                                                          
DECLARE COMM48B BIT(16);                                                        
DECLARE COMM54  BIT(16);                                                        
DECLARE COMM56A FIXED;                                                          
DECLARE COMM56B FIXED;                                                          
DECLARE COMM56C FIXED;                                                          
DECLARE COMM56D FIXED;                                                          
DECLARE COMM56E FIXED;                                                          
DECLARE COMM56F FIXED;                                                          
DECLARE COMM56G FIXED;                                                          
DECLARE COMM56H FIXED;                                                          
DECLARE COMM88A FIXED;                                                          
DECLARE COMM88B FIXED;                                                          
DECLARE COMM88C FIXED;                                                          
DECLARE COMM88D FIXED;                                                          
DECLARE COMM88E FIXED;                                                          
DECLARE COMM88F FIXED;                                                          
DECLARE COMM88G FIXED;                                                          
DECLARE COMM88H FIXED;                                                          
                                                                                
DECLARE C CHARACTER;                                                            
DECLARE (I,J,BLKS,SYMS,FIRST_STMT,LAST_STMT,MAX) BIT(16);                       
DECLARE NAME CHARACTER INITIAL('##CASR  ');                                     
DECLARE NAMEADDR BIT(32);                                                       
                                                                                
CALL MONITOR(22,0,ADDR(COMM0)); /* INITIALIZE */                                
NAMEADDR = COREWORD(ADDR(NAME)) & "FFFFFF";                                     
COMM32A = COREWORD(NAMEADDR);                                                   
COMM32B = COREWORD(NAMEADDR+4);                                                 
CALL MONITOR(22,4); /* SELECT */                                                
OUTPUT = '--- SDFPKG SELECT '||NAME||' ---';                                    
                                                                                
OUTPUT = '--- SDFPKG MODE 7 TEST ---';                                          
CALL MONITOR(22,7); /* LOCATE DIRECTORY ROOT CELL */                            
OUTPUT = 'ROOT CELL = '|| COMM24 ||' -> FLAGS = '||COREWORD(COMM28);            
SYMS = COREHALFWORD(COMM28+18);                                                 
BLKS = COREHALFWORD(COMM28+16);                                                 
FIRST_STMT = COREHALFWORD(COMM28+52);                                           
LAST_STMT = COREHALFWORD(COMM28+54);                                            
OUTPUT = 'TOTAL # SYMBOLS = '||SYMS;                                            
OUTPUT = 'TOTAL # BLOCKS  = '||BLKS;                                            
OUTPUT = '1ST STMT = '||FIRST_STMT||' LAST STMT = '||LAST_STMT;                 
                                                                                
OUTPUT = ''; OUTPUT = '--- SDFPKG MODE 15 TEST ---';                            
DO I = 1 TO BLKS; /* LOCATE BLOCK NODE GIVEN BLOCK NUMBER */                    
COMM16 = I; /* BLOCKNO */                                                       
CALL MONITOR(22,15); /* LOCATE BLOCK NODE */                                    
COREWORD(ADDR(C)) = SHL(7,24) + ADDR(COMM40A); /* CSECTNAME */                  
OUTPUT = 'BLOCK NODE '||I||' CSECT = '||C||' PNTR = '||COMM24;                  
END;                                                                            
                                                                                
OUTPUT = ''; OUTPUT = '--- SDFPKG MODE 8 & 11 TEST ---';                        
DO I = 1 TO BLKS; /* LOCATE BLOCK DATA CELL GIVEN BLOCK NUMBER */               
COMM16 = I; /* BLOCKNO */                                                       
CALL MONITOR(22,8); /* LOCATE BLOCK DATA CELL */                                
NAME = STRING(SHL(COMM22,24)+ADDR(COMM56A));                                    
OUTPUT = 'BLOCK # '||I||' NAME = '|| NAME;                                      
CALL MONITOR(22,11); /* LOCATE BLOCK DATA CELL */                               
IF COMM14 = 0 THEN DO;                                                          
   COREWORD(ADDR(C)) = SHL(7,24) + ADDR(COMM40A); /* CSECTNAME */               
   OUTPUT = '  BLOCK '|| NAME||' CSECT ='||C||' PNTR = '||COMM24;               
   OUTPUT = '    CSECT ='||C||' PNTR = '||COMM24;               
END;                                                                            
IF COMM14 = 16                                                                  
   THEN OUTPUT = '  BLOCK '|| NAME|| ' NOT FOUND';                              
END;                                                                            
                                                                                
OUTPUT = ''; OUTPUT = '--- SDFPKG MODE 9  & 13 TEST ---';                       
DO I = 1 TO SYMS; /* LOCATE SYM DATA CELL GIVEN SYM NUMBER */                   
COMM18 = I; /* SYMBNO */                                                        
CALL MONITOR(22,9); /* LOCATE SYMBOL DATA CELL */                               
NAME = STRING(SHL(COMM23,24)+ADDR(COMM88A));                                    
OUTPUT = 'SYM # '||I||' NAME = '||NAME||' BLOCK # = '||COMM16;                  
CALL MONITOR(22,8); /* MUST LOCATE BLOCK DATA CELL BEFORE MODE 13 */            
CALL MONITOR(22,13); /* LOCATE THAT SYMBOL */                                   
IF COMM14 = 0                                                                   
   THEN OUTPUT = '  LOCATED '||NAME||' SYMBNO= '||COMM18;                       
IF COMM14 = 20                                                                  
   THEN OUTPUT = '  '||NAME||' NOT FOUND';                                      
END;                                                                            
                                                                                
OUTPUT = ''; OUTPUT = '--- SDFPKG MODE 12 TEST ---';                            
/* LOCATE SYM DATA CELL GIVEN SYM NAME & BLK NAME */                            
/* USE SYM NAME & BLOCK NAME ALREADY STORED FROM PREVIOUS TESTS */              
CALL MONITOR(22,12); /* LOCATE THAT SYMBOL */                                   
IF COMM14 = 0 THEN DO;                                                          
   COREWORD(ADDR(C)) = SHL(7,24) + ADDR(COMM40A); /* CSECTNAME */               
   COREWORD(ADDR(NAME)) = SHL(COMM23,24)+ ADDR(COMM88A); /* SYM NAME */         
   OUTPUT = 'LOCATED '||NAME||' SYMBNO= '||COMM18||' CSECT = '||C;              
END;                                                                            
IF COMM14 = 16 THEN DO;                                                         
   COREWORD(ADDR(NAME)) = SHL(COMM22,24)+ ADDR(COMM56A); /* BLK NAME */         
   OUTPUT = 'BLOCK '||NAME||' NOT FOUND';                                       
END;                                                                            
IF COMM14 = 20 THEN DO;                                                         
   COREWORD(ADDR(NAME)) = SHL(COMM23,24)+ ADDR(COMM88A); /* SYM NAME */         
   OUTPUT = NAME||' NOT FOUND';                                                 
END;                                                                            
                                                                                
OUTPUT = ''; OUTPUT = '--- SDFPKG MODE 17 TEST ---';                            
DO I = FIRST_STMT TO LAST_STMT; /* LOCATE STMT NODE GIVEN STMT # */             
COMM20 = I; /* STATEMENT # */                                                   
CALL MONITOR(22,17); /* LOCATE STATEMENT NODE */                                
COREWORD(ADDR(NAME)) = SHL(5,24) + ADDR(COMM48A); /* SREFNO */                  
OUTPUT = 'ST#'||I||                                                             
         ' SREFNO = '||NAME||' INCLCNT = '||COMM54||' PNTR = '||COMM24;         
END;                                                                            
                                                                                
OUTPUT = ''; OUTPUT = '--- SDFPKG MODE 10 TEST ---';                            
DO I = FIRST_STMT TO LAST_STMT; /* LOCATE STMT DATA CELL GIVEN STMT# */         
COMM20 = I;                                                                     
CALL MONITOR(22,10); /* LOCATE STATEMENT DATA CELL */                           
OUTPUT = 'ST# '||I||' BLKNO = '||COMM16||' TYPE = '||                           
         COREHALFWORD(COMM28+2)||' RETURN = '||COMM14;                          
END;                                                                            
                                                                                
EOF EOF EOF                                                                     
