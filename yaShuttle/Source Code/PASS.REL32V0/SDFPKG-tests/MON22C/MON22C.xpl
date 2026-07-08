/***************************************************************/               
/* TEST CATEGORY :                                             */               
/* -------------                                               */               
/*   XPL TEST CASE  FOR TESTING THE SDFPKG                     */               
/*                                                             */               
/* DESCRIPTION :                                               */               
/* -----------                                                 */               
/*   TEST CASE TO USE SDFPKG VIA THE MONITOR(22) INTERFACE.    */               
/*   TEST CASE TO MODIFY THE DIRECT ROOL CELL AND SYMBOL DATA  */               
/*   CELL.                                                     */               
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
/*   9/12/94   LJK       BASELINED                             */               
/***************************************************************/               
                                                                                
/* SDFPKG COMMUNICATION TABLE */                                                
                                                                                
DECLARE APGAREA  FIXED;   /* ADDR OF EXTERNAL PAGING AREA */                    
DECLARE AFCBAREA FIXED;   /* ADDR OF EXTERNAL FCB AREA */                       
DECLARE NPAGES   BIT(16); /* # OF PGS IN PAGING AREA OR AUGMENT */              
DECLARE NBYTES   BIT(16); /* # OF BYTESS IN FCB AREA OR AUGMENT */              
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
DECLARE INST_CNT FIXED;                                                         
DECLARE (I,SYMS,TOTAL_STMTS,TOTAL_EXSTMT,PROCS) BIT(16);                        
DECLARE NAME CHARACTER INITIAL('##COPY2A');                                     
DECLARE NAMEADDR BIT(32);                                                       
DECLARE FLAGS  BIT(16);                                                         
DECLARE (SYM_TYPE, SYM_CLASS) BIT(8);                                           
BASED   FULLWORD FIXED,                                                         
        HALFWORD BIT(16),                                                       
        BYTES    BIT(8);                                                        
                                                                                
/* INITIALIZE SDFPKG IN UPDATE MODE */                                          
MISC = 2;         /* SET UPDATE MODE */                                         
CALL MONITOR(22,0,ADDR(APGAREA));                                               
IF (CRETURN ^= 0) THEN OUTPUT = 'SDFPKG INITIALIZATION FAILED';                 
NAMEADDR = COREWORD(ADDR(NAME)) & "FFFFFF";                                     
SDFNAM  = COREWORD(NAMEADDR);                                                   
SDFNAMA = COREWORD(NAMEADDR+4);                                                 
                                                                                
/* SELECT THE SDF MEMBER */                                                     
CALL MONITOR(22,4);                                                             
OUTPUT = '--- SDFPKG SELECT '||NAME||' ---';                                    
                                                                                
/* LOCATE DIRECTORY ROOT CELL WITH MODF PARAMETER */                            
OUTPUT ='';OUTPUT= '--- LOCATE DIRECTORY ROOL CELL ---';                        
CALL MONITOR(22,"80000007");                                                    
COREWORD(ADDR(FULLWORD)) = ADDRESS;                                             
COREWORD(ADDR(HALFWORD)) = ADDRESS;                                             
FLAGS = HALFWORD(0);                                                            
OUTPUT = 'ROOT CELL = '|| PNTR ||' -> FLAGS = '||FLAGS;                         
IF (FLAGS & "1000") ^= 0 THEN OUTPUT = 'FC_FLAG   IS SET';                      
IF (FLAGS & "4000") ^= 0 THEN OUTPUT = 'ADDR_FLAG IS SET';                      
IF (FLAGS & "8000") ^= 0 THEN OUTPUT = 'SRN_FLAG  IS SET';                      
IF (FLAGS & "0008") ^= 0 THEN OUTPUT = 'SDL_FLAG  IS SET';                      
INST_CNT = FULLWORD(6);                                                         
PROCS = HALFWORD(8);                                                            
SYMS =  HALFWORD(9);                                                            
TOTAL_EXSTMT= HALFWORD(28);                                                     
TOTAL_STMTS = HALFWORD(29);                                                     
OUTPUT = 'TOTAL # INST COUNT = '||INST_CNT;                                     
OUTPUT = 'TOTAL # PROCS      = '||PROCS;                                        
OUTPUT = 'TOTAL # SYMBOLS    = '||SYMS;                                         
OUTPUT = 'TOTAL # EXEC STMTS = '||TOTAL_EXSTMT;                                 
OUTPUT = 'TOTAL # STMTS      = '||TOTAL_STMTS;                                  
                                                                                
/* MODIFY TOTAL # OF STATEMENT IN ROOL DIRECTORY CELL */                        
HALFWORD(29) = 999; /* EDIT TOTAL_STMTS */                                      
CALL MONITOR(22,"40000006"); /* SET MODIFY TO THE LAST LOCATED CELL */          
CALL MONITOR(22,"00000007"); /* LOCATE DIRECTORY DATA CELL AGAIN */             
TOTAL_STMTS = HALFWORD(29);                                                     
OUTPUT = ' ';                                                                   
OUTPUT = 'MODIFIED TOTAL # STMTS = '||TOTAL_STMTS;                              
                                                                                
/* LOCATE SYM DATA CELL GIVEN SYMBOL NUMBER */                                  
OUTPUT = '';OUTPUT = '--- LOCATE SYM DATA CELL BY SYMBOL NUMBER ---';           
DO I = 1 TO SYMS;                                                               
   SYMBNO = I;                                                                  
   CALL MONITOR(22,"80000009");                                                 
   COREWORD(ADDR(BYTES)) = ADDRESS;                                             
   SYM_CLASS = BYTES(6);                                                        
   SYM_TYPE  = BYTES(7);                                                        
   NAME = STRING(SHL((SYMBNLEN-1),24) + ADDR(SYMBNAM));                         
   OUTPUT = 'SYM # '||I||' NAME = '||NAME||' SYM_CLASS = '||SYM_CLASS||         
            ' SYM_TYPE = '||SYM_TYPE;                                           
END;                                                                            
                                                                                
/* MODIFY SYMBOL TYPE AND SYMBOL CLASS FOR SYMBOL# 10 */                        
SYMBNO = 10;                                                                    
CALL MONITOR(22,"90000009");  /* LOCATE THE SYMBOL AND RESERVE IT */            
COREWORD(ADDR(BYTES)) = ADDRESS;                                                
BYTES(6) = 97;     /* EDIT SYMBOL CLASS */                                      
BYTES(7) = 98;     /* EDIT SYMBOL TYPE  */                                      
CALL MONITOR(22,"60000006"); /* SET MODF & RELS TO LAST LOCATED CELL */         
CALL MONITOR(22,"80000009"); /* LOCATE THAT SYMBOL DATA CELL AGAIN   */         
COREWORD(ADDR(BYTES)) = ADDRESS;                                                
SYM_CLASS = BYTES(6);                                                           
SYM_TYPE  = BYTES(7);                                                           
NAME = STRING(SHL((SYMBNLEN-1),24) + ADDR(SYMBNAM));                            
OUTPUT = ' ';                                                                   
OUTPUT = 'MODIFIED SYM #10 NAME = '||NAME||' SYM_CLASS = '||                    
          SYM_CLASS||' SYM_TYPE = '||SYM_TYPE;                                  
                                                                                
CALL MONITOR(22, 1);  /* TERMINATE SDFPGKG */                                   
                                                                                
EOF EOF EOF                                                                     
