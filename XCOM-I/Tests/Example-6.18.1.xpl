                                                                                
 /* INTERLIST $EMITTED CODE */                                                  
                                                                                
 DECLARE I FIXED, J BIT(16), K BIT(8),                                          
   ALPHA CHARACTER INITIAL('MESSAGE'),                                          
   BETA (3) BIT(64) ;                                                           
                                                                                
 CALL TRACE ; /* BEGIN TRACING */                                               
 I,J,K = 2 ;                                                                    
 BETA(I) = ALPHA ;                                                              
 DO WHILE J = I ;                                                               
   J = SHL(K,1) & SHR(I, J) ;                                                   
   OUTPUT, ALPHA = SUBSTR(ALPHA,J,I+1) ;                                        
 END;                                                                           
 IF J < BYTE('A') THEN                                                          
   I = 0;                                                                       
 ELSE                                                                           
   I = BYTE(BETA(J),K) ;                                                        
 CALL UNTRACE ;  /* END TRACE */                                                
 /* $END INTERLISTING */                                                        
 
EOF