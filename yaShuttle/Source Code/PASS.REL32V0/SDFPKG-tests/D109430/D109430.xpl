/***************************************************************/               
/* TEST CATEGORY :                                             */               
/* -------------                                               */               
/*   DR109430 - SDFPKG PROBLEM WITH MULTIPLE OPEN SDFS         */               
/*                                                             */               
/* DESCRIPTION :                                               */               
/* -----------                                                 */               
/*   TEST CASE TO USE SDFPKG VIA THE MONITOR(22) INTERFACE.    */               
/*   MONITOR(22,N,A)         22 - TO CALL SDFPKG               */               
/*                            N - SDF MODE(0-18)               */               
/*                                                             */               
/*   REQUIRES THE FOLLOWING SDFS:                              */               
/*      ##CDLANN, ##GDJAMI                                     */               
/*   THIS TEST IS ONLY VALID FOR THE SDFPKG FSWAT VERSION.     */               
/*   OTHER VERSIONS WILL GET ABEND 4016 BECAUSE MODE 19        */               
/*   (DESELECT) IS FSWAT ONLY.                                 */               
/*                                                             */               
/* REVISION HISTORY :                                          */               
/* ----------------                                            */               
/*   DATE      NAME      DESCRIPTION OF CHANGE                 */               
/*                                                             */               
/*   6/15/00   DAS       CREATED                               */               
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
DECLARE NAME CHARACTER;                                                         
DECLARE NAMEADDR BIT(32);                                                       
BASED   HALFWORD      BIT(16);                                                  
DECLARE NAMES(5) CHARACTER
        INITIAL('##CDLANN','##GDJAMI','        ','        ','        ');
DECLARE (LOOP,J) BIT(16);
DECLARE NUMSDFS BIT(16) INITIAL(2);
                                                                                
/* INITIALIZE SDFPKG */                                                         
NBYTES = 260; /* FORCE FCB AREA SIZE TO 248 */
NPAGES = 4;   /* FORCE PAGE AREA OF 4 PAGES */
CALL MONITOR(22,0,ADDR(APGAREA));                                               
IF (CRETURN ^= 0) THEN OUTPUT = 'SDFPKG INITIALIZATION FAILED';                 

/********************************************************************/
/* DO THIS 3 TIMES: SELECT, PERFORM SOME LOOKUPS FOR EACH SDF (NO DESELECT)*/
DO LOOP = 1 TO 3;

/* SELECT THE SDF MEMBER */                                                     
DO J = 0 TO NUMSDFS-1;
NAME = NAMES(J);
NAMEADDR = COREWORD(ADDR(NAME)) & "FFFFFF";                                     
SDFNAM   = COREWORD(NAMEADDR);                                                  
SDFNAMA  = COREWORD(NAMEADDR+4);                                                
CALL MONITOR(22,4);                                                             
OUTPUT=''; OUTPUT = '--- SDFPKG SELECT '||NAME||' ---';                         
                                                                                
/* LOCATE DIRECTORY ROOT CELL */                                                
OUTPUT=''; OUTPUT = '--- SDFPKG MODE 7 TEST ---';                               
  CALL MONITOR(22,"00000007");                                                  
COREWORD(ADDR(HALFWORD)) = ADDRESS;                                             
SYMS = HALFWORD(9);                                                             
BLKS = HALFWORD(8);                                                             
FIRST_STMT = HALFWORD(26);                                                      
LAST_STMT = HALFWORD(27);                                                       
OUTPUT = 'TOTAL # SYMBOLS = '||SYMS;                                            
OUTPUT = 'TOTAL # BLOCKS  = '||BLKS;                                            
OUTPUT = '1ST STMT = '||FIRST_STMT||' LAST STMT = '||LAST_STMT;                 
                                                                                
                                                                                
/* LOCATE SYM DATA CELL GIVEN SYM NUMBER */                                     
OUTPUT = ''; OUTPUT = '--- SDFPKG MODE 9  & 18 TEST ---';                       
DO I = 1 TO SYMS;                                                               
   SYMBNO = I;                                                                  
   CALL MONITOR(22,9);                                                          
   NAME = STRING(SHL(SYMBNLEN,24)+ ADDR(SYMBNAM));                              
   OUTPUT = 'SYM # '||I||' NAME = '||NAME||' BLOCK # = '||BLKNO;                
END;                                                                            
END;
                                                                                
END; /*END LOOP 3 TIMES */
/********************************************************************/
/* DO THIS 3 TIMES: SAME AS ABOVE, BUT DESELECT SDF AFTER LOOKUPS DONE */
DO LOOP = 1 TO 3;

/* SELECT THE SDF MEMBER */                                                     
DO J = 0 TO NUMSDFS-1;
NAME = NAMES(J);
NAMEADDR = COREWORD(ADDR(NAME)) & "FFFFFF";                                     
SDFNAM   = COREWORD(NAMEADDR);                                                  
SDFNAMA  = COREWORD(NAMEADDR+4);                                                
CALL MONITOR(22,4);                                                             
OUTPUT=''; OUTPUT = '--- SDFPKG SELECT '||NAME||' ---';                         
                                                                                
/* LOCATE DIRECTORY ROOT CELL */                                                
OUTPUT=''; OUTPUT = '--- SDFPKG MODE 7 TEST ---';                               
  CALL MONITOR(22,"00000007");                                                  
COREWORD(ADDR(HALFWORD)) = ADDRESS;                                             
SYMS = HALFWORD(9);                                                             
BLKS = HALFWORD(8);                                                             
FIRST_STMT = HALFWORD(26);                                                      
LAST_STMT = HALFWORD(27);                                                       
OUTPUT = 'TOTAL # SYMBOLS = '||SYMS;                                            
OUTPUT = 'TOTAL # BLOCKS  = '||BLKS;                                            
OUTPUT = '1ST STMT = '||FIRST_STMT||' LAST STMT = '||LAST_STMT;                 
                                                                                
                                                                                
/* LOCATE SYM DATA CELL GIVEN SYM NUMBER */                                     
OUTPUT = ''; OUTPUT = '--- SDFPKG MODE 9  & 18 TEST ---';                       
DO I = 1 TO SYMS;                                                               
   SYMBNO = I;                                                                  
   CALL MONITOR(22,9);                                                          
   NAME = STRING(SHL(SYMBNLEN,24)+ ADDR(SYMBNAM));                              
   OUTPUT = 'SYM # '||I||' NAME = '||NAME||' BLOCK # = '||BLKNO;                
END;                                                                            
                                                                                
/* DESELECT */
NAME = NAMES(J);
NAMEADDR = COREWORD(ADDR(NAME)) & "FFFFFF";
SDFNAM   = COREWORD(NAMEADDR);
SDFNAMA  = COREWORD(NAMEADDR+4);
CALL MONITOR(22,19);
OUTPUT=''; OUTPUT = '--- SDFPKG DESELECT '||NAME||' ---';
END;

END; /*END LOOP 3 TIMES */
/********************************************************************/
                                                                                
EOF EOF EOF                                                                     
