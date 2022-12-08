                                                                                
 /*                                                                             
                                                                                
                             A L T E R    P R O G R A M                         
                                                                                
                                                                                
                                                 DAVID B. WORTMAN               
                                                 STANFORD UNIVERSITY            
                                                 JANUARY  1969                  
                                                                                
 */                                                                             
                                                                                
                                                                                
 /*      THIS PROGRAM ALTERS A CARD-IMAGE TAPE OR DISK FILE ONTO AN OUTPUT      
     FILE UNDER CONTROL OF A SMALL ALTER DECK.  IT CAN ALSO BE USED TO COPY     
     ONE FILE TO ANOTHER OR TO COPY A CARD DECK TO DISK OR TAPE.                
                                                                                
         THE PROGRAM REQUIRES THREE FILES, AN ALTER FILE, A SOURCE FILE,        
     AND AN OUTPUT FILE.  THE ALTER FILE CONTAINS CONTROL CARDS INDICATING      
     THE LOCATION OF CHANGES TO BE MADE, AND ANY CARDS WHICH ARE TO BE          
     ADDED TO THE SOURCE FILE.  THE SOURCE FILE IS THE PROGRAM TO BE            
     UPDATED.  IT MAY BE OMITTED IF A NEW FILE IS BEING MADE FROM CARDS.        
                                                                                
         THE CHOICE OF DEVICE (TAPE, DISKS, OR CARDS) FOR SOURCE AND            
     OUTPUT FILES IS DETERMINED BY JOB CONTROL CARDS.  THE ALTER FILE           
     HAS THE DDNAME SYSIN, THE SOURCE FILE HAS THE DDNAME INPUT3, AND           
     THE OUTPUT FILE HAS THE DDNAME OUTPUT3.  SEE THE PROSE FILE ON             
     THE DISTRIBUTION TAPE FOR EXAMPLES OF APPROPRIATE JCL.                     
                                                                                
         THE ALTER DECK CONTAINS CONTROL CARDS AND CARDS TO BE ADDED TO         
     THE SOURCE DECK.  IF A CARD IN THE ALTER FILE CONTAINS $$ IN COLUMNS       
     1 AND 2 THEN IT IS TAKEN TO BE A CONTROL CARD.  OTHERWISE IT IS ADDED      
     TO THE SOURCE DECK.  THERE ARE THREE TYPES OF CONTROL CARDS:               
                                                                                
               $$ L                                                             
                                                                                
               $$ EOF                                                           
                                                                                
               $$ <CARD SPECIFICATIONS>                                         
                                                                                
     WHERE <CARD SPECIFICATIONS> WILL BE DESCRIBED SHORTLY.  EACH OF THE        
     THREE TYPES OF CONTROL INFORMATION MAY APPEAR ANYWHERE AFTER               
     COLUMN 2, BUT ONLY ONE TYPE TO A CARD.                                     
                                                                                
         $$ L  INVERTS THE VALUE OF A LOGICAL VARIABLE WHICH DETERMINES         
     WHETHER OR NOT THE OUTPUT FILE WILL BE LISTED ON THE PRINTER.  IF THE      
     VARIABLE HAS THE VALUE FALSE THEN ONLY CHANGES (ADDITIONS AND DELETIONS)   
     AND CONTROL CARDS WILL BE LISTED.  IF IT HAS THE VALUE TRUE THEN THE       
     ENTIRE OUTPUT FILE WILL BE LISTED.  THE VARIABLE IS INITIALLY SET TO       
     THE VALUE FALSE.                                                           
                                                                                
         $$ EOF  SIGNIFIES THE END OF THE ALTER INPUT.  THE OUTPUT FILE         
     IS TERMINATED AT THE POINT WHICH WAS REACHED WHEN THE $$ EOF CARD WAS      
     DETECTED.  NO FURTHER CARDS ARE READ FROM THE ALTER INPUT FILE OR          
     FROM THE SOURCE FILE (SYSIN AND INPUT3).  THIS CARD IS CONVENIENT          
     WHEN CREATING A NEW SOURCE FILE, ALTHOUGH SPECIFYING INPUT3 TO BE          
     A DUMMY FILE  (//INPUT3 DD DUMMY) WILL HAVE THE SAME EFFECT.               
                                                                                
         THE THIRD TYPE OF CONTROL CARD HAS THREE SUB-TYPES.                    
                                                                                
     <CARD SPECIFICATIONS>  ::=  <UNSIGNED INTEGER>                             
                              |  <UNSIGNED INTEGER>  ,                          
                              |  <UNSIGNED INTEGER>  ,  <UNSIGNED INTEGER>      
                                                                                
     THE <CARD SPECIFICATIONS> IS TERMINATED BY A BLANK.  THE EFFECTS OF        
     THE THREE TYPES OF CARD SPECIFICATION ARE:                                 
                                                                                
     <UNSIGNED INTEGER>                                                         
         THE SOURCE FILE IS COPIED TO THE OUTPUT FILE UP TO AND INCLUDING       
         THE CARD SPECIFIED BY THE INTEGER.  THEN ANY NON-CONTROL CARDS         
         IN THE ALTER DECK UP TO THE NEXT CONTROL CARD ARE ADDED TO THE         
         OUTPUT FILE.                                                           
                                                                                
     <UNSIGNED INTEGER>  ,                                                      
         THE SOURCE FILE IS COPIED TO THE OUTPUT FILE UP TO BUT NOT             
         INCLUDING THE CARD SPECIFIED BY THE INTEGER.  THEN ANY CARDS IN THE    
         ALTER DECK UP TO THE NEXT CONTROL CARD ARE ADDED TO THE OUTPUT         
         FILE.  THE CARD SPECIFIED BY THE INTEGER IS DELETED.                   
                                                                                
     <UNSIGNED INTEGER>  ,  <UNSIGNED INTEGER>                                  
         THE SOURCE FILE IS COPIED TO THE OUTPUT FILE UP TO BUT NOT INCLUDING   
         THE CARD SPECIFIED BY THE FIRST INTEGER.  THE CARDS IN THE SOURCE      
         FILE IN THE RANGE INDICATED BY THE PAIR OF INTEGERS INCLUSIVE          
         ARE DELETED.  ANY CARDS IN THE ALTER DECK UP TO THE NEXT CONTROL       
         CARD ARE COPIED TO THE OUTPUT FILE.                                    
                                                                                
         ALTERATIONS MUST BE MADE IN NUMERICALLY ASCENDING SEQUENCE.  ANY       
     REFERENCE TO A LINE WHICH HAS ALREADY BEEN READ FROM THE SOURCE FILE WILL  
     CAUSE AN ERROR MESSAGE.                                                    
                                                                                
         THE <CARD SPECIFICATIONS> MAY BE OPTIONALLY FOLLOWED BY A CHARACTER    
     STRING.  THIS STRING IS USED TO CHECK THE LINE NUMBER INDICATED IN THE     
     CARD SPECIFICATION AGAINST THE ACTUAL CARD IN THE SOURCE FILE.             
     THE FIRST NON-BLANK CHARACTER OF THE ALTER CARD IS MATCHED WITH THE        
     FIRST NON-BLANK CHARACTER OF THE LAST NON-DELETED CARD FROM THE SOURCE     
     FILE.  A CHARACTER BY CHARACTER COMPARISON IS DONE THROUGH THE LAST        
     NON-BLANK CHARACTER ON THE ALTER CONTROL CARD.  IF ANY MISMATCH IS         
     FOUND AND ERROR MESSAGE IS GIVEN AND THE INDICATED ALTERATION              
     IS NOT PERFORMED.  THE ALTER DESK IS SEARCHED FOR THE NEXT CONTROL CARD.   
                                                                                
         NUMBERING OF THE SOURCE FILE STARTS FROM ONE WITH A CONSTANT           
     INCREMENT OF ONE.  IF THE FIRST CARDS IN THE ALTER CONTROL DECK ARE NOT    
     ALTER CONTROL CARDS THEN THEY WILL BE INSERTED BEFORE THE FIRST CARD OF    
     THE SOURCE FILE.                                                           
                                                                                
         TO COPY A FILE (OR PUNCH A FILE, ETC.) THE ALTER DECK SHOULD BE NULL.  
     FOR EXAMPLE,  //SYSIN  DD  DUMMY  COUND BE USED.                           
                                                                                
 */                                                                             
                                                                                
                                                                                
                                                                                
DECLARE TRUE LITERALLY '1', FALSE LITERALLY '0' ;                               
   /* DEFINE FILES USED BY THE ALTER PROGRAM  */                                
DECLARE IN_FILE LITERALLY '3',         /* SOURCE INPUT  */                      
   OUT_FILE LITERALLY '3',             /* SOURCE OUTPUT  */                     
   CONTROL_FILE LITERALLY '0',         /* SOURCE OF CONTROL CARDS  */           
   PRINT_FILE LITERALLY '0';           /* SINK FOR LISTING  */                  
                                                                                
DECLARE CONTROL_DELIMITER CHARACTER INITIAL('$$'),                              
   LIST_MARK CHARACTER INITIAL('L'),                                            
   EOF_MARK CHARACTER INITIAL('EOF'),                                           
   BLANKS CHARACTER INITIAL('      '),                                          
   STARS CHARACTER INITIAL('******');                                           
                                                                                
DECLARE (SEARCHING, COPYING, LISTING, FLUSHING) BIT (1),                        
   (CONTROL_BUFFER, BUFFER) CHARACTER,                                          
   (LCB, CP, INPUT_COUNT, LCD, LLM, LEM, OUTPUT_COUNT, FIRST, LAST,             
    ERROR_COUNT, BP, LB)  FIXED;                                                
                                                                                
                                                                                
ERROR:                                                                          
   PROCEDURE (MESSAGE) ;                                                        
      DECLARE MESSAGE CHARACTER;                                                
                                                                                
      OUTPUT(PRINT_FILE) = '';                                                  
      OUTPUT(PRINT_FILE) = '*** ERROR, ' || MESSAGE || '      ' || STARS ;      
      OUTPUT(PRINT_FILE) = '';                                                  
      ERROR_COUNT = ERROR_COUNT + 1;                                            
      FLUSHING = TRUE ;                                                         
   END  ERROR  ;                                                                
                                                                                
CONTROL_CARD:                                                                   
   PROCEDURE ;                                                                  
      IF SEARCHING THEN                                                         
         DO;                                                                    
            CONTROL_BUFFER = INPUT(CONTROL_FILE) ;                              
            LCB = LENGTH(CONTROL_BUFFER) ;                                      
            SEARCHING = LCB ~= 0 ;                                              
         END ;                                                                  
   END  CONTROL_CARD  ;                                                         
                                                                                
DEBLANK:                                                                        
   PROCEDURE ;                                                                  
      DO WHILE (BYTE(CONTROL_BUFFER, CP) = BYTE(' ')) & (CP < LCB);             
         CP = CP + 1;                                                           
      END;                                                                      
   END  DEBLANK  ;                                                              
                                                                                
NUMBER:                                                                         
   PROCEDURE ;                                                                  
      DECLARE VALUE FIXED ;                                                     
                                                                                
      VALUE = 0;                                                                
      DO WHILE (BYTE(CONTROL_BUFFER, CP) >= BYTE('0')) & (CP < LCB) ;           
         VALUE = VALUE*10 + BYTE(CONTROL_BUFFER, CP) - BYTE('0') ;              
         CP = CP + 1;                                                           
      END ;                                                                     
      RETURN VALUE ;                                                            
   END  NUMBER ;                                                                
                                                                                
ADD:                                                                            
   PROCEDURE ;                                                                  
      OUTPUT_COUNT = OUTPUT_COUNT + 1;                                          
      OUTPUT(PRINT_FILE) = SUBSTR(BLANKS,LENGTH(OUTPUT_COUNT)) ||               
         OUTPUT_COUNT || ' |' || CONTROL_BUFFER || '| +++ ADDED';               
      OUTPUT(OUT_FILE) = CONTROL_BUFFER ;                                       
   END  ADD  ;                                                                  
                                                                                
DELETE:                                                                         
   PROCEDURE (LIMIT) ;                                                          
      DECLARE LIMIT FIXED, I FIXED ;                                            
                                                                                
      IF ~ COPYING THEN RETURN ;                                                
      DO I = INPUT_COUNT+1 TO LIMIT ;                                           
         BUFFER = INPUT(IN_FILE) ;                                              
         IF LENGTH(BUFFER) = 0 THEN                                             
            DO;                                                                 
               CALL ERROR('RANGE OF DELETE EXTENDS BEYOND END OF SOURCE FILE'); 
               SEARCHING,COPYING = FALSE ;                                      
               RETURN ;                                                         
            END;                                                                
         OUTPUT(PRINT_FILE) = BLANKS || ' |' || BUFFER || '| --- DELETED';      
      END;                                                                      
      INPUT_COUNT = LIMIT ;                                                     
   END  DELETE  ;                                                               
                                                                                
COPY:                                                                           
   PROCEDURE (LIMIT) ;                                                          
      DECLARE LIMIT FIXED, I FIXED ;                                            
                                                                                
      IF ~COPYING THEN RETURN ;                                                 
      DO I = INPUT_COUNT + 1 TO LIMIT ;                                         
         OUTPUT_COUNT = OUTPUT_COUNT + 1;                                       
         BUFFER = INPUT(IN_FILE);                                               
         IF LENGTH(BUFFER) = 0 THEN                                             
            DO;                                                                 
               SEARCHING, COPYING = FALSE ;                                     
               RETURN ;                                                         
            END ;                                                               
         IF LISTING THEN                                                        
            OUTPUT(PRINT_FILE) = SUBSTR(BLANKS,LENGTH(OUTPUT_COUNT))            
               || OUTPUT_COUNT || ' |' || BUFFER;                               
         OUTPUT(OUT_FILE) = BUFFER;                                             
      END;                                                                      
      INPUT_COUNT = LIMIT ;                                                     
   END  COPY  ;                                                                 
                                                                                
                                                                                
SEARCHING,COPYING = TRUE ;                                                      
FLUSHING, LISTING = FALSE ;                                                     
INPUT_COUNT, OUTPUT_COUNT, ERROR_COUNT = 0;                                     
LCD = LENGTH(CONTROL_DELIMITER) ;                                               
LLM = LENGTH(LIST_MARK) ;                                                       
LEM = LENGTH(EOF_MARK) ;                                                        
                                                                                
CALL CONTROL_CARD ;                                                             
                                                                                
                                                                                
DO WHILE SEARCHING ;                                                            
   IF SUBSTR(CONTROL_BUFFER, 0, LCD) ~= CONTROL_DELIMITER THEN                  
      CALL ADD ;                                                                
   ELSE                                                                         
      DO;                                                                       
         CP = LCD ;                                                             
         OUTPUT(PRINT_FILE) = CONTROL_BUFFER ;                                  
         CALL DEBLANK ;                                                         
         IF SUBSTR(CONTROL_BUFFER, CP, LLM) = LIST_MARK  THEN                   
            LISTING = ~LISTING ;                                                
         ELSE IF SUBSTR(CONTROL_BUFFER, CP, LEM) = EOF_MARK THEN                
            SEARCHING, COPYING = FALSE ;                                        
         ELSE                                                                   
            DO;                                                                 
               FIRST = NUMBER ;                                                 
               IF BYTE(CONTROL_BUFFER, CP) = BYTE(',')  THEN                    
                  DO;                                                           
                     FIRST = FIRST - 1;                                         
                     CP = CP + 1;                                               
                     LAST = NUMBER ;                                            
                     IF LAST = 0 THEN LAST = FIRST + 1;                         
                  END ;                                                         
               ELSE                                                             
                  LAST = FIRST ;                                                
               IF FIRST > LAST THEN                                             
                  CALL ERROR('1ST ALTER CARD NUMBER > 2ND ALTER CARD NUMBER');  
               ELSE IF FIRST < INPUT_COUNT THEN                                 
                  CALL ERROR('INPUT CARD COUNT > 1ST ALTER CARD NUMBER');       
               ELSE                                                             
                  DO;                                                           
                     CALL COPY(FIRST) ;                                         
                     CALL DEBLANK ;                                             
                     BP = 0;                                                    
                     LB = LENGTH(BUFFER) ;                                      
                     DO WHILE BYTE(BUFFER, BP) = BYTE(' ') ;                    
                        BP = BP + 1;                                            
                     END ;                                                      
                     DO WHILE (CP < LCB) & (BP < LB) ;                          
                        IF BYTE(CONTROL_BUFFER, CP) = BYTE(BUFFER, BP) THEN     
                           DO;                                                  
                              CP = CP + 1;                                      
                              BP = BP + 1;                                      
                           END;                                                 
                        ELSE                                                    
                           DO;                                                  
                              CALL DEBLANK ;                                    
                              IF CP < LCB THEN                                  
                                 DO;                                            
                                    CALL ERROR(                                 
                                       'ALTER CARD DOES NOT MATCH SOURCE:  '    
                                       || BUFFER);                              
                                    CP = LCB ;                                  
                                    LAST = FIRST; /* SUPPRESS DELETE  */        
                                 END;                                           
                           END;                                                 
                     END ;                                                      
                     CALL DELETE (LAST) ;                                       
                  END ;                                                         
            END ;                                                               
      END ;                                                                     
                                                                                
   CALL CONTROL_CARD ;                                                          
   FLUSHING = FLUSHING & (SUBSTR(CONTROL_BUFFER, 0, LCD) ~= CONTROL_DELIMITER) ;
                                                                                
   DO WHILE FLUSHING & SEARCHING ;                                              
      OUTPUT(PRINT_FILE) = STARS || ' |' || CONTROL_BUFFER || '| *** IGNORED  ' 
         || STARS ;                                                             
      CALL CONTROL_CARD ;                                                       
      FLUSHING = SUBSTR(CONTROL_BUFFER, 0, LCD) ~= CONTROL_DELIMITER ;          
   END ;                                                                        
                                                                                
END ;                                                                           
                                                                                
CALL COPY ("7FFFFFFF" );                                                        
                                                                                
DO BP = 1 TO 6 ;                                                                
   OUTPUT(PRINT_FILE) = '';                                                     
END;                                                                            
OUTPUT(PRINT_FILE) = 'END  OF  ALTER' ;                                         
IF ERROR_COUNT = 0 THEN                                                         
   OUTPUT(PRINT_FILE) = 'NO ERRORS WERE DETECTED' ;                             
ELSE IF ERROR_COUNT = 1 THEN                                                    
   OUTPUT(PRINT_FILE) = 'ONE ERROR WAS DETECTED' ;                              
ELSE                                                                            
   OUTPUT(PRINT_FILE) = ERROR_COUNT || ' ERRORS WERE DETECTED' ;                
RETURN  ERROR_COUNT ;                                                           

