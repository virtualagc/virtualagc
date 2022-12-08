   /*  ANALYZER                                                                 
                 THE SYNTAX ANALYSIS AND TABLE BUILDING PROGRAM                 
                 OF THE XPL SYSTEM.                                             
                                                                                
      J. J. HORNING AND W. M. MC KEEMAN      STANFORD UNIVERSITY                
                                                                                
      THIS PROGRAM BUILDS TABLES DIRECTLY ACCEPTABLE FOR USE IN                 
         THE COMPILER XCOM OR THE PROTO-COMPILER SKELETON.                      
                                                                                
   INPUT TO ANALYZER MAY BE NEARLY "FREE FORMAT."                               
   CARDS WITH THE CHARACTER $ IN COLUMN 1 ARE TREATED AS COMMENT OR CONTROL     
      CARDS, AND LISTED UNCHANGED.  THE CHARACTER IN COLUMN 2 IS THE CONTROL    
      CHARACTER, AS FOLLOWS:                                                    
         L   COMPLEMENT LISTING MODE,                                           
         T   COMPLEMENT TRACING MODE,                                           
         P   COMPLEMENT PUNCHING MODE,                                          
         O   COMPLEMENT LINE PRINTER LISTING OF COMPUTED "CARD OUTPUT,"         
         I   COMPLEMENT ITERATIVE IMPROVEMENT MODE,                             
         EOG   END OF GRAMMAR;  (ANOTHER GRAMMAR FOLLOWS).                      
                                                                                
   BLANK CARDS ARE IGNORED.                                                     
   PRODUCTIONS ARE PLACED ONE TO A CARD.                                        
   A TOKEN IS                                                                   
      ANY CONSECUTIVE GROUP OF NON-BLANK CHARACTERS NOT BEGINNING WITH A  "<"   
         AND FOLLOWED BY A BLANK,                                               
      THE CHARACTER "<"  FOLLOWED BY A BLANK,                                   
      THE CHARACTER "<"  FOLLOWED BY A NON-BLANK CHARACTER AND THEN ANY         
         STRING OF BLANK OR NON-BLANK CHARACTERS UP TO AND INCLUDING THE        
         NEXT OCCURRENCE OF THE CHARACTER "<".                                  
                                                                                
   IF COLUMN 1 IS NON-BLANK, THE FIRST TOKEN ON THE CARD IS TAKEN TO BE THE     
      LEFT PART OF THE PRODUCTION;  OTHERWISE, THE LEFT PART IS TAKEN TO BE     
      THE LEFT PART OF THE PREVIOUS PRODUCTION.                                 
   THE BALANCE OF THE CARD (UP TO FIVE TOKENS) IS TAKEN TO BE THE RIGHT PART.   
   ANY SYMBOL WHICH DOES NOT OCCUR AS A LEFT PART IS A TERMINAL SYMBOL.         
   ANY SYMBOL WHICH OCCURS ONLY AS A LEFT PART IS A GOAL SYMBOL.                
   ALL PRODUCTIONS WITH THE SAME LEFT PART MUST BE GROUPED.                     
                                                                                
   PRODUCTIONS ARE REFORMATTED FOR READABILITY (INCLUDING THE INSERTION OF      
      THE META-SYMBOLS  ::=  AND  |  )  BEFORE LISTING.                         
   BLANKS BETWEEN TOKENS ARE NOT SIGNIFICANT.                                   
                                                                       */       
   /* FIRST COME THE GLOBAL VARIABLE DECLARATIONS:        */                    
                                                                                
   DECLARE V(255) CHARACTER, (LEFT_PART, RIGHT_HEAD) (255) BIT(8),              
      PRODUCTION(255) BIT(32), (ON_LEFT, ON_RIGHT) (255) BIT(1);                
   DECLARE INDEX(255) BIT(8), (IND, IND1) (255) BIT(16);                        
   DECLARE SORT#(255) FIXED, AMBIGUOUS BIT(1);                                  
   DECLARE (NSY, NPR, SP, CP, NT, LEVEL, GOAL_SYMBOL) FIXED;                    
                                                                                
   DECLARE CONTROL(255) BIT(1);                                                 
   DECLARE TRUE LITERALLY '1', FALSE LITERALLY '0';                             
   DECLARE CARRIAGE LITERALLY '1', PUNCH LITERALLY '2', DISK LITERALLY '3',     
      PAGE CHARACTER INITIAL ('1'), DOUBLE CHARACTER INITIAL ('0'),             
      EJECT_PAGE LITERALLY 'OUTPUT(1) = PAGE',                                  
      DOUBLE_SPACE LITERALLY 'OUTPUT(1) = DOUBLE';                              
   DECLARE DOLLAR LITERALLY 'BYTE(''$'')', BLANK LITERALLY 'BYTE('' '')';       
   DECLARE CHANGE BIT(1), WORK("4000") BIT(8);                                  
   DECLARE HEAD(255) FIXED, TAIL(255) BIT(8);                                   
   DECLARE STACKLIMIT LITERALLY '200', TEXTLIMIT LITERALLY '255',               
      DEPTH LITERALLY '255';   /*  MUST BE AT LEAST 255  */                     
   DECLARE STACK(STACKLIMIT) BIT(8), TEXT(TEXTLIMIT) BIT(8),                    
      TOKEN_SAVE(DEPTH) BIT(8), TOKEN FIXED, MP_SAVE(DEPTH) BIT(8), MP FIXED,   
      TP_SAVE(DEPTH) BIT(8), TP FIXED, P_SAVE(DEPTH) BIT(8), P FIXED;           
   DECLARE HEAD_TABLE("2000") BIT(8);                                           
      DECLARE EMPTY CHARACTER INITIAL('                                         
                                       ');  /* IMAGE OF BLANK CARD  */          
   DECLARE HALF_LINE CHARACTER INITIAL ('                                       
                           '), X12 CHARACTER INITIAL ('            ');          
   DECLARE CARDIMAGE CHARACTER, OUTCARD CHARACTER, S CHARACTER, T CHARACTER;    
   DECLARE (NETRY, FIRST_TIME, LAST_TIME, THIS_TIME) FIXED;                     
   DECLARE COUNT(3) FIXED;                                                      
   DECLARE PRINT(3) CHARACTER INITIAL (' ', 'Y', 'N', '#');                     
   DECLARE DOTS CHARACTER INITIAL (' ... ');                                    
   DECLARE VALUE(1) FIXED INITIAL (2, 1);                                       
   DECLARE (I, J, K, L, M) FIXED;                                               
   DECLARE ERROR_COUNT FIXED;                                                   
   DECLARE TERMINATOR FIXED;                                                    
   DECLARE MAXNF11 LITERALLY '5000', MAXNTRIP LITERALLY '1000';                 
   DECLARE F11(MAXNF11) FIXED, NF11 FIXED;                                      
   DECLARE TRIPLE(MAXNTRIP) FIXED, TV(MAXNTRIP) BIT(2), NTRIP FIXED;            
   DECLARE STACKING BIT(1) INITIAL (TRUE);  /* CONTROLS BATCHING OF GRAMMARS  */
   DECLARE MAXTROUBLE LITERALLY '50', TROUBLE1(MAXTROUBLE) BIT(8),              
      TROUBLE2(MAXTROUBLE) BIT(8), TROUBLE_COUNT FIXED;                         
   DECLARE (BASIC_NSY, BASIC_NPR) FIXED;                                        
   DECLARE ITERATION_COUNT FIXED;                                               
                                                                                
   /* NOW SOME DATA PACKING/UNPACKING PROCEDURES USED BELOW   */                
                                                                                
IS_HEAD:                                                                        
   PROCEDURE (I, J) BIT(1);                                                     
   /* THIS PROCEDURE DECODES THE PACKED HEAD TABLE.  TRUE IF V(J) IS A HEAD     
      OF V(I)     */                                                            
   /* WE MUST SIMULATE DOUBLE SUBSCRIPT FOR ARRAY                               
      HEAD_TABLE(0:255, 0:255) BIT(1)  */                                       
                                                                                
   DECLARE (I, J) FIXED;                                                        
   RETURN 1 & SHR(HEAD_TABLE(SHL(I,5)+SHR(J,3)), J & 7);                        
END IS_HEAD;                                                                    
                                                                                
SET_HEAD:                                                                       
   PROCEDURE (I, J);                                                            
   /* THIS PROCEDURE ADDS V(J) AS A HEAD OF V(I) IN THE HEAD_TABLE  */          
                                                                                
   DECLARE (I, J, K, L) FIXED;                                                  
   CHANGE = TRUE;                                                               
   K = SHL(I, 5) + SHR(J, 3);                                                   
   L = SHL(1, J & 7);                                                           
   HEAD_TABLE(K) = HEAD_TABLE(K) | L;                                           
END SET_HEAD;                                                                   
                                                                                
CLEAR_HEADS:                                                                    
   PROCEDURE;                                                                   
   DECLARE I FIXED;                                                             
   DO I = 0 TO "2000";                                                          
      HEAD_TABLE(I) = 0;                                                        
   END;                                                                         
END CLEAR_HEADS;                                                                
                                                                                
GET:                                                                            
   PROCEDURE (I, J) BIT(2);                                                     
   DECLARE (I, J) FIXED;                                                        
   /* THIS PROCEDURE DECODES A 2-BIT ENTRY IN THE WORK MATRIX  */               
   /* WE MUST SIMULATE DOUBLE SUBSCRIPT FOR ARRAY                               
     WORK(0:255, 0:255) BIT(2)  */                                              
                                                                                
   RETURN 3 & SHR(WORK(SHL(I,6)+SHR(J,2)), SHL(J & 3, 1));                      
END GET;                                                                        
                                                                                
SET:                                                                            
   PROCEDURE (I, J, VAL);                                                       
   /* THIS PROCEDURE OR'S A 2-BIT VAL INTO THE WORK MATRIX    */                
                                                                                
   DECLARE (I, J, VAL) FIXED;                                                   
   DECLARE (K, L) FIXED;                                                        
   K = SHL(I, 6) + SHR(J, 2);                                                   
   L = SHL(VAL & 3, SHL(J & 3, 1));                                             
   WORK(K) = WORK(K) | L;                                                       
END SET;                                                                        
                                                                                
CLEAR_WORK:                                                                     
   PROCEDURE;                                                                   
   DECLARE I FIXED;                                                             
   DO I = 0 TO "4000";                                                          
      WORK(I) = 0;                                                              
   END;                                                                         
END CLEAR_WORK;                                                                 
                                                                                
PACK:                                                                           
   PROCEDURE (B1, B2, B3, B4) FIXED;                                            
   /* THIS PROCEDURE HAS THE VALUE OF THE 4 BYTES PACKED INTO A 32-BIT WORD  */ 
                                                                                
   DECLARE (B1, B2, B3, B4) BIT(8);                                             
   RETURN SHL(B1,24) + SHL(B2,16) + SHL(B3,8) + B4;                             
END PACK;                                                                       
                                                                                
ERROR:                                                                          
   PROCEDURE (MESSAGE);                                                         
      DECLARE MESSAGE CHARACTER;                                                
      OUTPUT = '*** ERROR, ' || MESSAGE;                                        
      ERROR_COUNT = ERROR_COUNT + 1;                                            
   END ERROR;                                                                   
                                                                                
ENTER:                                                                          
   PROCEDURE (ENV, VAL);                                                        
   /* THIS PROCEDURE RECORDS TOGETHER THE 2-BIT VAL 'S FOR EACH UNIQUE ENV      
         TO ASSIST TABLE LOOKUP, THE ENV 'S ARE STORED IN ASCENDING ORDER.      
         THEY ARE LOCATED BY A BINARY SEARCH    */                              
                                                                                
   DECLARE (ENV, VAL, I, J, K) FIXED;                                           
   NETRY = NETRY + 1; /* COUNT ENTRIES VS. UNIQUE ENTRIES */                    
   I = 0;  K = NTRIP + 1;                                                       
   DO WHILE I + 1 < K; /* BINARY LOOK-UP */                                     
      J = SHR(I+K,1);                                                           
      IF TRIPLE(J) > ENV THEN K = J;                                            
      ELSE IF TRIPLE(J) < ENV THEN I = J;                                       
      ELSE                                                                      
         DO;                                                                    
            TV(J) = TV(J) | VAL;                                                
            RETURN;                                                             
         END;                                                                   
   END;                                                                         
   IF NTRIP >= MAXNTRIP THEN                                                    
      DO;                                                                       
         CALL ERROR ('TOO MANY TRIPLES FOR TABLE');                             
         NTRIP = 0;                                                             
      END;                                                                      
   DO J = 0 TO NTRIP - K;  /* MAKE ROOM IN TABLE FOR NEW ENTRY */               
      I = NTRIP - J;                                                            
      TRIPLE(I+1) = TRIPLE(I);                                                  
      TV(I+1) = TV(I);                                                          
   END;                                                                         
   NTRIP = NTRIP + 1;                                                           
   TRIPLE(K) = ENV;                                                             
   TV(K) = VAL;                                                                 
END ENTER;                                                                      
                                                                                
ADD_TROUBLE:                                                                    
   PROCEDURE (LEFT, RIGHT);                                                     
      DECLARE (LEFT, RIGHT) FIXED;                                              
      DECLARE I FIXED;                                                          
      IF LEFT > BASIC_NSY THEN RETURN;                                          
      IF LEFT = TERMINATOR THEN RETURN;                                         
      IF TROUBLE_COUNT = MAXTROUBLE THEN RETURN;  /* TROUBLE ENOUGH  */         
      DO I = 1 TO TROUBLE_COUNT;                                                
         IF TROUBLE1(I) = LEFT THEN IF TROUBLE2(I) = RIGHT THEN RETURN;         
      END;                                                                      
      TROUBLE_COUNT = TROUBLE_COUNT + 1;                                        
      TROUBLE1(TROUBLE_COUNT) = LEFT;                                           
      TROUBLE2(TROUBLE_COUNT) = RIGHT;                                          
   END ADD_TROUBLE;                                                             
                                                                                
LINE_OUT:                                                                       
   PROCEDURE (NUMBER, LINE);                                                    
   /* NUMBER A LINE AND PRINT IT  */                                            
                                                                                
   DECLARE NUMBER FIXED, LINE CHARACTER;                                        
   DECLARE N CHARACTER;                                                         
   N = NUMBER;  NUMBER = 6 - LENGTH(N);  /* 6 = MARGIN */                       
   OUTPUT = SUBSTR(EMPTY, 0, NUMBER) || N || '   ' || LINE;                     
END LINE_OUT;                                                                   
                                                                                
BUILD_CARD:                                                                     
   PROCEDURE (ITEM);                                                            
   /* ADD ITEM TO OUTCARD AND PUNCH IF CARD BOUNDARY EXCEEDED */                
                                                                                
   DECLARE ITEM CHARACTER;                                                      
   IF LENGTH(ITEM) + LENGTH(OUTCARD) >= 80 THEN                                 
      DO;                                                                       
         IF CONTROL(BYTE('P')) THEN OUTPUT(PUNCH) = OUTCARD;                    
         IF CONTROL(BYTE('O')) THEN                                             
            OUTPUT = '--- CARD OUTPUT ---|' || OUTCARD;                         
         OUTCARD = '      ' || ITEM;                                            
      END;                                                                      
   ELSE OUTCARD = OUTCARD || ' ' || ITEM;                                       
END BUILD_CARD;                                                                 
                                                                                
PUNCH_CARD:                                                                     
   PROCEDURE (ITEM);                                                            
   /*  PUNCH OUTCARD AND ITEM  */                                               
                                                                                
   DECLARE ITEM CHARACTER;                                                      
   CALL BUILD_CARD (ITEM);                                                      
   IF CONTROL(BYTE('P')) THEN OUTPUT(PUNCH) = OUTCARD;                          
   IF CONTROL(BYTE('O')) THEN                                                   
      OUTPUT = '--- CARD OUTPUT ---|' || OUTCARD;                               
   OUTCARD = '  ';                                                              
END PUNCH_CARD;                                                                 
                                                                                
PRINT_MATRIX:                                                                   
   PROCEDURE (TITLE, SOURCE);                                                   
   /* PRINT AND LABEL THE MATRIX SPECIFIED BY SOURCE (HEAD_TABLE OR WORK)  */   
                                                                                
   DECLARE TITLE CHARACTER, SOURCE FIXED;                                       
   DECLARE (I, J, K, L, M, N, BOT, TOP, MARGIN_SIZE, NUMBER_ACROSS, WIDE) FIXED,
      (MARGIN, LINE, WASTE, BAR, PAGES) CHARACTER,                              
      DIGIT(9) CHARACTER INITIAL ('0','1','2','3','4','5','6','7','8','9'),     
      NUMBER_HIGH LITERALLY '48',                                               
      GS LITERALLY '16';                                                        
   IF SOURCE = 1 THEN WIDE = NT;  ELSE WIDE = NSY;                              
   MARGIN_SIZE = 5;                                                             
   DO I = 1 TO NSY;                                                             
      IF LENGTH(V(I)) >= MARGIN_SIZE THEN MARGIN_SIZE = LENGTH(V(I)) + 1;       
   END;                                                                         
   MARGIN = SUBSTR('                                                            
                 ', 0, MARGIN_SIZE);                                            
   WASTE = MARGIN || '          ';                                              
   NUMBER_ACROSS = (122 - MARGIN_SIZE)/(GS + 1)*GS;                             
   DO I = 0 TO 3;                                                               
      COUNT(I) = 0;                                                             
   END;                                                                         
   M = 0;                                                                       
   I = (WIDE-1)/NUMBER_ACROSS + 1;                                              
   PAGES = ((NSY-1)/NUMBER_HIGH + 1)*I;                                         
   DO I = 0 TO (WIDE-1)/NUMBER_ACROSS;                                          
      BOT = NUMBER_ACROSS*I + 1;                                                
      TOP = NUMBER_ACROSS*(I+1);                                                
      IF TOP > WIDE THEN TOP = WIDE;                                            
      BAR = SUBSTR(WASTE, 1) || '+';                                            
      DO L = BOT TO TOP;                                                        
         BAR = BAR || '-';                                                      
         IF L MOD GS = 0 THEN BAR = BAR || '+';                                 
      END;                                                                      
      IF TOP MOD GS ~= 0 THEN BAR = BAR || '+';                                 
      DO J = 0 TO (NSY-1)/NUMBER_HIGH;                                          
         /*  ONCE PER PAGE OF PRINTOUT  */                                      
         EJECT_PAGE;                                                            
         M = M + 1;                                                             
         OUTPUT = TITLE || ':  PAGE ' || M || ' OF ' || PAGES;                  
         DOUBLE_SPACE;                                                          
         L = 100;                                                               
         DO WHILE L > 0;                                                        
            LINE = WASTE;                                                       
            DO N = BOT TO TOP;                                                  
               IF N < L THEN LINE = LINE || ' ';                                
               ELSE LINE = LINE || DIGIT(N/L MOD 10);                           
               IF N MOD GS = 0 THEN LINE = LINE || ' ';                         
            END;                                                                
            OUTPUT = LINE;                                                      
            L = L / 10;                                                         
         END;                                                                   
         OUTPUT = BAR;                                                          
         N = NUMBER_HIGH*(J+1);                                                 
         IF N > NSY THEN N = NSY;                                               
         DO K = NUMBER_HIGH*J + 1 TO N;                                         
            L = LENGTH(V(K));                                                   
            LINE = V(K) || SUBSTR(MARGIN, L) || '|';                            
            DO L = BOT TO TOP;                                                  
               IF SOURCE ~= 0 THEN                                              
                  DO;                                                           
                     N = GET (K, L);                                            
                     LINE = LINE || PRINT(N);                                   
                     COUNT(N) = COUNT(N) + 1;                                   
                  END;                                                          
               ELSE LINE = LINE || PRINT(IS_HEAD (K, L));                       
               IF L MOD GS = 0 THEN LINE = LINE || '|';                         
            END;                                                                
            IF TOP MOD GS ~= 0 THEN LINE = LINE || '|';                         
            CALL LINE_OUT (K, LINE);                                            
            IF K MOD GS = 0 THEN                                                
               OUTPUT = BAR;                                                    
         END;                                                                   
         IF K MOD GS ~= 1 THEN OUTPUT = BAR;                                    
      END;                                                                      
   END;                                                                         
   DOUBLE_SPACE;                                                                
   IF SOURCE ~= 0 THEN                                                          
      DO;                                                                       
         OUTPUT = 'TABLE ENTRIES SUMMARY:';                                     
         DO I = 0 TO 3;                                                         
            CALL LINE_OUT (COUNT(I), PRINT(I));                                 
         END;                                                                   
      END;                                                                      
END PRINT_MATRIX;                                                               
                                                                                
PRINT_TRIPLES:                                                                  
   PROCEDURE (TITLE);                                                           
   /* FORMAT AND PRINT THE (2,1) TRIPLES FOR C1  */                             
                                                                                
   DECLARE TITLE CHARACTER, (I, J) FIXED;                                       
   IF NTRIP = 0 THEN                                                            
      DO;                                                                       
         DOUBLE_SPACE;                                                          
         OUTPUT = 'NO TRIPLES REQUIRED.';                                       
         COUNT(1) = 0;   /* SO WE DON'T PUNCH ANY  */                           
         RETURN;                                                                
      END;                                                                      
   EJECT_PAGE;                                                                  
   OUTPUT = TITLE || ':';                                                       
   DOUBLE_SPACE;                                                                
   DO I = 1 TO 3;                                                               
      COUNT(I) = 0;                                                             
   END;                                                                         
   DO I = 1 TO NTRIP;                                                           
      J = TRIPLE(I);                                                            
      K = TV(I);                                                                
      IF K = 3 THEN                                                             
         DO;                                                                    
            CALL ERROR ('STACKING DECISION CANNOT BE MADE WITH (2,1) CONTEXT:');
            CALL ADD_TROUBLE (SHR(J, 16), SHR(J, 8) & "FF");                    
         END;                                                                   
      CALL LINE_OUT (I, PRINT(K) || ' FOR  ' || V(SHR(J, 16)) || ' ' ||         
         V(SHR(J, 8)&"FF") || ' ' || V(J&"FF"));                                
      COUNT(K) = COUNT(K) + 1;                                                  
   END;                                                                         
   DOUBLE_SPACE;                                                                
   OUTPUT = NETRY || ' ENTRIES FOR ' || NTRIP || ' TRIPLES.';                   
   DOUBLE_SPACE;                                                                
   OUTPUT = 'TABLE ENTRIES SUMMARY:';                                           
   DO I = 1 TO 3;                                                               
      CALL LINE_OUT (COUNT(I), PRINT(I));                                       
   END;                                                                         
END PRINT_TRIPLES;                                                              
                                                                                
BUILD_RIGHT_PART:                                                               
   PROCEDURE (P);                                                               
      DECLARE (P, PR) FIXED;                                                    
      PR = PRODUCTION(P);                                                       
      T = '';                                                                   
      DO WHILE PR ~= 0;                                                         
         T = ' ' || V(PR&"FF") || T;                                            
         PR = SHR(PR, 8);                                                       
      END;                                                                      
      T = V(RIGHT_HEAD(P)) || T;                                                
   END BUILD_RIGHT_PART;                                                        
                                                                                
OUTPUT_PRODUCTION:                                                              
   PROCEDURE (P);                                                               
      DECLARE P FIXED;                                                          
      CALL BUILD_RIGHT_PART(P);                                                 
      CALL LINE_OUT (P, V(LEFT_PART(P)) || '  ::=  ' || T);                     
   END OUTPUT_PRODUCTION;                                                       
                                                                                
PRINT_TIME:                                                                     
   PROCEDURE;                                                                   
   /* OUTPUT ELAPSED TIMES  */                                                  
                                                                                
   DECLARE (I, J) FIXED, T CHARACTER;                                           
   DOUBLE_SPACE;                                                                
   THIS_TIME = TIME;                                                            
   I = THIS_TIME - LAST_TIME;                                                   
   J = I MOD 100;                                                               
   I = I / 100;                                                                 
   T = 'TIME USED WAS ' || I || '.';                                            
   IF J < 10 THEN T = T || '0';                                                 
   OUTPUT = T || J || ' SECONDS.';                                              
   I = THIS_TIME - FIRST_TIME;                                                  
   J = I MOD 100;                                                               
   I = I / 100;                                                                 
   T = 'TOTAL TIME IS ' || I || '.';                                            
   IF J < 10 THEN T = T || '0';                                                 
   OUTPUT = T || J || ' SECONDS.';                                              
   LAST_TIME = THIS_TIME;                                                       
END PRINT_TIME;                                                                 
                                                                                
LOOK_UP:                                                                        
   PROCEDURE (SYMBOL) BIT(8);  /* GET INDEX OF SYMBOL IN V  */                  
   DECLARE SYMBOL CHARACTER;                                                    
   DECLARE J FIXED;                                                             
   DO J = 1 TO NSY;                                                             
      IF V(J) = SYMBOL THEN RETURN J;                                           
   END;                                                                         
   IF J = 256 THEN                                                              
      DO;                                                                       
         CALL ERROR ('TOO MANY SYMBOLS');                                       
         J = 1;                                                                 
      END;                                                                      
   /* ADD SYMBOL TO V  */                                                       
   NSY = J;                                                                     
   V(J) = SYMBOL;                                                               
   RETURN J;                                                                    
END LOOK_UP;                                                                    
                                                                                
EXPAND:                                                                         
   PROCEDURE (F11, P);  /* EXPAND PRODUCTION P IN THE CONTEXT OF F11  */        
   DECLARE (F11, I, J, P, OLDP) FIXED;                                          
   /* OLDP REMEMBERS ARGUMENT P FROM PREVIOUS CALL TO SAVE REPEATED EFFORT */   
   IF P ~= OLDP THEN                                                            
      DO;                                                                       
         OLDP = P;                                                              
         SP = 2;                                                                
         STACK(SP) = RIGHT_HEAD(P);                                             
         J = PRODUCTION(P);                                                     
         DO WHILE J ~= 0; /* UNPACK PRODUCTION INTO STACK */                    
            I = SHR(J, 24);                                                     
            IF I ~= 0 THEN                                                      
               DO;                                                              
                  SP = SP + 1;                                                  
                  STACK(SP) = I;                                                
               END;                                                             
            J = SHL(J, 8);                                                      
         END;                                                                   
      END;                                                                      
   STACK(1) = SHR(F11, 8) & "FF";  /* LEFT CONTEXT */                           
   STACK(SP+1) = F11 & "FF";         /* RIGHT CONTEXT */                        
END EXPAND;                                                                     
                                                                                
                                                                                
   /*  NOW THE WORKING PROCEDURES  */                                           
                                                                                
READ_GRAMMAR:                                                                   
   PROCEDURE;  /*  READ IN AND LIST A GRAMMAR  */                               
   DECLARE (P, LONG) FIXED;                                                     
                                                                                
   SCAN:                                                                        
      PROCEDURE BIT(8); /* GET A TOKEN FROM INPUT CARDIMAGE  */                 
      DECLARE LP FIXED, LEFT_BRACKET LITERALLY 'BYTE(''<'')',                   
         RIGHT_BRACKET LITERALLY 'BYTE(''>'')', STOP FIXED;                     
      DO CP = CP TO LONG;                                                       
         IF BYTE(CARDIMAGE,CP) ~= BLANK THEN                                    
            DO;                                                                 
               LP = CP; /* MARK LEFT BOUNDARY OF SYMBOL */                      
               IF BYTE(CARDIMAGE,CP) = LEFT_BRACKET & BYTE(CARDIMAGE,CP+1)      
                  ~= BLANK THEN                                                 
                  STOP = RIGHT_BRACKET;                                         
                  ELSE STOP = BLANK;                                            
               DO CP = CP + 1 TO LONG;                                          
                  IF BYTE(CARDIMAGE, CP) = STOP THEN GO TO DELIMIT;             
               END;                                                             
               IF STOP ~= BLANK THEN                                            
                  DO;                                                           
                     CALL ERROR ('UNMATCHED BRACKET: <');                       
                     CP = CP - 1;                                               
                     DO WHILE BYTE(CARDIMAGE, CP) = BLANK;  /* ERROR RECOVERY */
                        CP = CP - 1;                                            
                     END;                                                       
                  END;                                                          
            DELIMIT:                                                            
               IF STOP ~= BLANK THEN CP = CP + 1; /* PICK UP THE > */           
               T = SUBSTR(CARDIMAGE, LP, CP-LP);  /* PICK UP THE SYMBOL */      
               RETURN LOOK_UP(T);                                               
            END;                                                                
      END;  /* END OF CARD  */                                                  
      T = '';                                                                   
      RETURN 0;                                                                 
   END SCAN;                                                                    
                                                                                
   GET_CARD:                                                                    
      PROCEDURE BIT(1);  /* READ THE NEXT CARD  */                              
      CP = 0;                                                                   
      DO WHILE TRUE;                                                            
         CARDIMAGE = INPUT;  /* GET THE CARD */                                 
         LONG = LENGTH(CARDIMAGE) - 1;                                          
         IF LONG < 0 THEN                                                       
            DO;    /*  END OF FILE DETECTED  */                                 
               STACKING = FALSE;                                                
               RETURN FALSE;                                                    
            END;                                                                
         IF BYTE(CARDIMAGE) = DOLLAR THEN                                       
            DO;  /* CONTROL CARD OR COMMENT */                                  
               IF SUBSTR(CARDIMAGE, 1, 3) = 'EOG' THEN RETURN FALSE;            
               IF CONTROL(BYTE('L')) THEN OUTPUT = CARDIMAGE;                   
               CONTROL(BYTE(CARDIMAGE,1)) = ~ CONTROL(BYTE(CARDIMAGE,1));       
            END;                                                                
         ELSE IF CARDIMAGE ~= EMPTY THEN RETURN TRUE;                           
      END;                                                                      
   END GET_CARD;                                                                
                                                                                
   SORT_V:                                                                      
      PROCEDURE;  /* SORT THE SYMBOL TABLE  */                                  
      DO I = 1 TO NSY;                                                          
          /* SORT ON 1.  TERMINAL VS. NON-TERMINAL                              
                        2.  LENGTH OF SYMBOL                                    
                           3.  ORIGINAL ORDER OF OCCURRENCE  */                 
         SORT#(I) = SHL(ON_LEFT(I), 16) | SHL(LENGTH(V(I)), 8) | I;             
      END;                                                                      
      /* BUBBLE SORT  */                                                        
      K, L = NSY;                                                               
      DO WHILE K <= L;                                                          
         L = 0;                                                                 
         DO I = 2 TO K;                                                         
            L = I - 1;                                                          
            IF SORT#(L) > SORT#(I) THEN                                         
               DO;                                                              
                  J = SORT#(L);  SORT#(L) = SORT#(I);  SORT#(I) = J;            
                  T = V(L);  V(L) = V(I);  V(I) = T;                            
                  K = L;                                                        
               END;                                                             
         END;                                                                   
      END;                                                                      
      DO I = 1 TO NSY; /* BUILD TABLE TO LOCATE SORTED SYMBOLS OF V */          
         INDEX(SORT#(I)&"FF") = I;                                              
      END;                                                                      
      NT = NSY;  /* PREPARE TO COUNT NON-TERMINAL SYMBOLS */                    
      DO WHILE SORT#(NT) > "10000";  NT = NT - 1;  END;                         
      /* SUBSTITUTE NEW INDEX NUMBERS IN PRODUCTIONS  */                        
      DO I = 1 TO NPR;                                                          
         LEFT_PART(I) = INDEX(LEFT_PART(I));                                    
         J = INDEX(RIGHT_HEAD(I));                                              
         ON_RIGHT(J) = TRUE;                                                    
         RIGHT_HEAD(I) = J;                                                     
         L = PRODUCTION(I);                                                     
         DO K = 0 TO 3;                                                         
            J = INDEX(SHR(L,24));                                               
            ON_RIGHT(J) = TRUE;                                                 
            L = SHL(L,8) + J;                                                   
         END;                                                                   
         PRODUCTION(I) = L;                                                     
      END;                                                                      
      TERMINATOR = INDEX(1);  /* ADD _|_ TO VOCABULARY */                       
      ON_RIGHT(TERMINATOR) = TRUE;                                              
   END SORT_V;                                                                  
                                                                                
   PRINT_DATE:                                                                  
      PROCEDURE (MESSAGE, D);                                                   
         DECLARE MESSAGE CHARACTER, D FIXED;                                    
         DECLARE MONTH(11) CHARACTER INITIAL ('JANUARY', 'FEBRUARY', 'MARCH',   
            'APRIL', 'MAY', 'JUNE', 'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER',   
            'NOVEMBER', 'DECEMBER'), DAYS(11) FIXED INITIAL (0, 31, 60, 91,     
            121, 152, 182, 213, 244, 274, 305, 335);                            
         DECLARE (YEAR, DAY, M) FIXED;                                          
                                                                                
         YEAR = D/1000 + 1900;                                                  
         DAY = D MOD 1000;                                                      
         IF (YEAR & 3) ~= 0 THEN IF DAY > 59 THEN DAY = DAY + 1;                
         M = 11;                                                                
         DO WHILE DAY <= DAYS(M);  M = M - 1;  END;                             
         OUTPUT = MESSAGE || MONTH(M) || ' ' || DAY-DAYS(M) || ', ' ||          
            YEAR || '.';                                                        
      END PRINT_DATE;                                                           
                                                                                
   EJECT_PAGE;                                                                  
   CALL PRINT_DATE ('GRAMMAR ANALYSIS  --  "THIS INSTALLATION"  --  ANALYZER VER
SION OF ', DATE_OF_GENERATION);                                                 
   DOUBLE_SPACE;                                                                
   CALL PRINT_DATE ('TODAY IS ', DATE);                                         
   DOUBLE_SPACE;                                                                
   OUTPUT = '             P R O D U C T I O N S';                               
   DOUBLE_SPACE;                                                                
   CONTROL(BYTE('L')) = TRUE;                                                   
   V(0) = '<ERROR: TOKEN = 0>';                                                 
   NSY = 1;  V(1) = '_|_';                                                      
   NPR, ERROR_COUNT = 0;                                                        
   DO I = 0 TO 255;  /* CLEAR ON_LEFT AND ON_RIGHT  */                          
      ON_LEFT(I), ON_RIGHT(I) = 0;                                              
   END;                                                                         
   DO WHILE GET_CARD;  /* WATCH SIDE EFFECT */                                  
      IF NPR = 255 THEN CALL ERROR ('TOO MANY PRODUCTIONS');                    
      ELSE NPR = NPR + 1;                                                       
      IF BYTE(CARDIMAGE) = BLANK THEN LEFT_PART(NPR) = LEFT_PART(NPR-1);        
      ELSE                                                                      
         DO;                                                                    
            I = SCAN;      /* LEFT PART SYMBOL  */                              
            LEFT_PART(NPR) = I;                                                 
            ON_LEFT(I) = TRUE;                                                  
         END;                                                                   
      I = SCAN; /* FIRST SYMBOL ON THE RIGHT */                                 
      IF I = 0 THEN CALL ERROR ('EMPTY RIGHT PART.');                           
      RIGHT_HEAD(NPR) = I;                                                      
      J, P = 0;                                                                 
      DO J = 1 TO 4;                                                            
         I = SCAN;                                                              
         IF I ~= 0 THEN                                                         
            P = SHL(P, 8) + I;  /* PACK 4 TO A WORD  */                         
      END;                                                                      
      IF SUBSTR(CARDIMAGE, CP) ~= SUBSTR(EMPTY, CP) THEN                        
         CALL ERROR ('TOO MANY SYMBOLS IN RIGHT PART.  FORCED TO DISCARD  ' ||  
            SUBSTR(CARDIMAGE, CP));                                             
      PRODUCTION(NPR) = P;                                                      
      IF CONTROL(BYTE('L')) THEN                                                
         DO;  /* UNPACK TABLE AND PRINT PRODUCTION */                           
            IF LEFT_PART(NPR) = LEFT_PART(NPR-1) THEN                           
               DO;                                                              
                  I = LENGTH(V(LEFT_PART(NPR)));                                
                  CARDIMAGE = SUBSTR(EMPTY, 0, I) || '    |  ';                 
               END;                                                             
            ELSE                                                                
               DO;                                                              
                  OUTPUT = '';                                                  
                  CARDIMAGE = V(LEFT_PART(NPR)) || '  ::=  ';                   
               END;                                                             
            CALL BUILD_RIGHT_PART(NPR);                                         
            CALL LINE_OUT (NPR, CARDIMAGE || T);                                
         END;                                                                   
      IF CONTROL(BYTE('P')) THEN                                                
         DO;  /* UNPACK TABLE AND PRINT PL COMMENT */                           
            P = PRODUCTION(NPR);                                                
            OUTCARD = ' /*  ' || V(LEFT_PART(NPR)) || ' ::= ' ||                
               V(RIGHT_HEAD(NPR));                                              
            DO K = 1 TO 4;                                                      
               I = SHR(P, SHL(4-K, 3)) & "FF";                                  
               IF I ~= 0 THEN CALL BUILD_CARD (V(I));                           
            END;                                                                
            CALL PUNCH_CARD ('   */');                                          
         END;                                                                   
   END;                                                                         
   CALL PRINT_TIME;                                                             
   CALL SORT_V;                                                                 
   EJECT_PAGE;                                                                  
   OUTPUT  = '   T E R M I N A L   S Y M B O L S                                
   N O N T E R M I N A L S';                                                    
   DOUBLE_SPACE;                                                                
   IF NSY - NT > NT THEN L = NSY - NT;  ELSE L = NT; /* L = NUMBER OF LINES */  
   DO I = 1 TO L;  /* PRINT V */                                                
      IF I > NT THEN CARDIMAGE = HALF_LINE;                                     
      ELSE                                                                      
         DO;  /* TERMINAL SYMBOLS */                                            
            T = I;                                                              
            J = 5 - LENGTH(T);                                                  
            CARDIMAGE = SUBSTR(SUBSTR(EMPTY, 0, J) || T || '   ' || V(I)        
               || HALF_LINE, 0, 66);                                            
         END;                                                                   
      K = I + NT;                                                               
      IF K <= NSY THEN                                                          
         DO;  /* NON-TERMINAL SYMBOLS */                                        
            T = K;                                                              
            J = 5 - LENGTH(T);                                                  
            CARDIMAGE = CARDIMAGE || SUBSTR(EMPTY, 0, J) || T || '   '          
               || V(K);                                                         
         END;                                                                   
      OUTPUT = CARDIMAGE;                                                       
   END;                                                                         
   DOUBLE_SPACE;                                                                
   GOAL_SYMBOL = 0;                                                             
   DO I = 1 TO NSY;   /* LOCATE GOAL SYMBOL */                                  
      IF ~ ON_RIGHT(I) THEN                                                     
         IF GOAL_SYMBOL = 0 THEN                                                
               DO;                                                              
                  GOAL_SYMBOL = I;                                              
                  OUTPUT = V(I) || ' IS THE GOAL SYMBOL.';                      
               END;                                                             
            ELSE OUTPUT = 'ANOTHER GOAL: ' || V(I) || ' (WILL NOT BE USED)';    
   END;                                                                         
   IF GOAL_SYMBOL = 0 THEN                                                      
      DO;                                                                       
         GOAL_SYMBOL = LEFT_PART(1);                                            
         OUTPUT = 'NO GOAL SYMBOL FOUND.  ' || V(GOAL_SYMBOL) ||                
            ' USED FOR GOAL SYMBOL.';                                           
      END;                                                                      
                                                                                
   BASIC_NSY = NSY;                                                             
   BASIC_NPR = NPR;                                                             
   TROUBLE_COUNT = 0;                                                           
END READ_GRAMMAR;                                                               
                                                                                
IMPROVE_GRAMMAR:                                                                
   PROCEDURE;                                                                   
      DECLARE (T1, T2, S1, S2) FIXED, CHANGE BIT(1),                            
         INTERNAL BIT(1), ADD_ON CHARACTER INITIAL ('0123456789ABCDEFGHIJKL');  
      EJECT_PAGE;                                                               
      OUTPUT = 'GRAMMAR MODIFICATION TO ATTEMPT TO RESOLVE CONFLICTS:';         
      DO I = 1 TO BASIC_NSY;                                                    
         INDEX(I) = 0;                                                          
      END;                                                                      
      DO I = 1 TO TROUBLE_COUNT;  /* STEP THROUGH PROBLEMS  */                  
         DOUBLE_SPACE;                                                          
         T1 = TROUBLE1(I);                                                      
         T2 = TROUBLE2(I);                                                      
         DO P = 1 TO BASIC_NPR;                                                 
            INTERNAL, CHANGE = FALSE;                                           
            S1 = RIGHT_HEAD(P);                                                 
            M = PRODUCTION(P);                                                  
            DO L = 1 TO 4;  /* STEP THROUGH RIGHT PART  */                      
               S2 = SHR(M, 24);                                                 
               M = SHL(M, 8) + S2;                                              
               IF S2 ~= 0 THEN                                                  
                  DO;                                                           
                     IF S1 = T1 & IS_HEAD (S2, T2) THEN                         
                        DO;                                                     
                           J, INDEX(T1) = INDEX(T1) + 1;                        
                           IF NSY < 255 THEN NSY = NSY + 1;                     
                           ELSE CALL ERROR ('TOO MANY SYMBOLS');                
                           S = SUBSTR(ADD_ON, J, 1);                            
                           V(NSY) = '<' || V(T1) || S || '>';                   
                           IF NPR < 255 THEN NPR = NPR + 1;                     
                           ELSE CALL ERROR ('TOO MANY PRODUCTIONS.');           
                           LEFT_PART(NPR) = NSY;                                
                           RIGHT_HEAD(NPR) = T1;                                
                           PRODUCTION(NPR) = 0;                                 
                           CALL OUTPUT_PRODUCTION (NPR);                        
                           CHANGE = TRUE;                                       
                           IF INTERNAL THEN M = M & "FFFF00FF" | SHL(NSY, 8);   
                           ELSE RIGHT_HEAD(P) = NSY;                            
                        END;                                                    
                     INTERNAL = TRUE;                                           
                     S1 = S2;                                                   
                  END;                                                          
            END;  /* OF DO L  */                                                
            PRODUCTION(P) = M;                                                  
            IF CHANGE THEN CALL OUTPUT_PRODUCTION (P);                          
         END;  /* OF DO P  */                                                   
      END;  /* OF DO I  */                                                      
      TROUBLE_COUNT, ERROR_COUNT = 0;                                           
   END IMPROVE_GRAMMAR;                                                         
                                                                                
COMPUTE_HEADS:                                                                  
   PROCEDURE;  /* SET UP HEAD SYMBOL MATRIX  */                                 
   CALL CLEAR_HEADS;                                                            
   CALL CLEAR_WORK;                                                             
   DO I = 1 TO NPR;   /* FIRST GET IMMEDIATE HEADS */                           
      CALL SET_HEAD (LEFT_PART(I), RIGHT_HEAD(I));                              
   END;                                                                         
   DO WHILE CHANGE;   /* THEN COMPUTE TRANSITIVE COMPLETION */                  
      CHANGE = FALSE;                                                           
      DO I = NT + 1 TO NSY;                                                     
         DO J = NT + 1 TO NSY;                                                  
            IF IS_HEAD (I, J) THEN                                              
               DO K = 1 TO NSY;                                                 
                  IF IS_HEAD (J, K) THEN                                        
                     IF ~ IS_HEAD (I, K) THEN                                   
                        CALL SET_HEAD (I, K);  /* SIDE EFFECT ON CHANGE */      
               END;                                                             
         END;                                                                   
      END;                                                                      
   END;                                                                         
   CHANGE = TRUE;                                                               
   IF ITERATION_COUNT = 1 THEN                                                  
      DO;                                                                       
         AMBIGUOUS = FALSE;                                                     
         DO I = 1 TO NPR;                                                       
            J = RIGHT_HEAD(I);  K = PRODUCTION(I);                              
            DO WHILE K ~= 0;  J = SHR(K, 24);  K = SHL(K, 8);  END;             
            CALL SET (LEFT_PART(I), J, TRUE);                                   
         END;                                                                   
         DO WHILE CHANGE;                                                       
            CHANGE = FALSE;                                                     
            DO I = NT + 1 TO NSY;                                               
               DO J = NT + 1 TO NSY;                                            
                  IF GET (I, J) THEN                                            
                     DO K = 1 TO NSY;                                           
                        IF GET (J, K) THEN IF ~ GET (I, K) THEN                 
                           DO;                                                  
                              CALL SET (I, K, TRUE);                            
                              CHANGE = TRUE;                                    
                           END;                                                 
                     END;                                                       
               END;                                                             
            END;                                                                
         END;                                                                   
         DO I = NT + 1 TO NSY;                                                  
            IF IS_HEAD (I, I) THEN IF GET (I, I) THEN                           
               DO;                                                              
                  AMBIGUOUS = TRUE;                                             
                  CALL ERROR ('GRAMMAR IS AMBIGUOUS.  IT IS LEFT AND RIGHT RECUR
SIVE IN THE SYMBOL  ' || V(I));                                                 
               END;                                                             
         END;                                                                   
      END;                                                                      
   DO I = 0 TO NSY;   /* THEN THE REFLEXIVE TRANSITIVE COMPLETION */            
      CALL SET_HEAD (I, I);                                                     
   END;                                                                         
   CALL PRINT_MATRIX ('PRODUCED HEAD SYMBOLS', 0);                              
END COMPUTE_HEADS;                                                              
                                                                                
PRODUCE:                                                                        
   PROCEDURE;  /* RUN THROUGH THE GENERATION ALGORITHM TO COMPUTE F11  */       
   DECLARE MAXLEVEL FIXED, NEW BIT(1);                                          
                                                                                
   NEVER_BEEN_HERE:                                                             
      PROCEDURE; /* RECORD THE F11.  RETURN FALSE IF IT IS ALREADY IN TABLE  */ 
      DECLARE (NEW_F11, I, J, K, NF11P1) FIXED;                                 
      NETRY = NETRY + 1;                                                        
      NEW_F11 = PACK(0, STACK(SP), STACK(SP-1), TOKEN);                         
      I = 0;  K, NF11P1 = NF11 + 1;                                             
      DO WHILE I + 1 < K; /* BINARY LOOK-UP */                                  
         J = SHR(I+K,1);                                                        
         IF F11(J) > NEW_F11 THEN K = J;                                        
         ELSE IF F11(J) < NEW_F11 THEN I = J;                                   
         ELSE RETURN FALSE;  /* FOUND IT */                                     
      END;                                                                      
      /* IF WE GOT HERE, WE DIDN'T FIND IT */                                   
      IF NF11 >= MAXNF11 THEN DO;  CALL ERROR ('F11 OVERFLOW');  NF11 = 1;  END;
      DO J = 0 TO NF11 - K;   /* MAKE ROOM TO INSERT NEW ENTRY */               
         F11(NF11P1-J) = F11(NF11-J);                                           
      END;                                                                      
      NF11 = NF11P1;                                                            
      F11(K) = NEW_F11;                                                         
      RETURN TRUE;                                                              
   END NEVER_BEEN_HERE;                                                         
                                                                                
   ADD_ITEM:                                                                    
      PROCEDURE (ITEM);                                                         
      DECLARE ITEM CHARACTER;                                                   
      IF LENGTH(CARDIMAGE) + LENGTH(ITEM) > 130 THEN                            
         DO;                                                                    
            OUTPUT = CARDIMAGE;                                                 
            CARDIMAGE = '      ';                                               
         END;                                                                   
      CARDIMAGE = CARDIMAGE || ' ' || ITEM;                                     
   END ADD_ITEM;                                                                
                                                                                
   PRINT_FORM:                                                                  
      PROCEDURE; /* PRINT THE CURRENT SENTENTIAL FORM WHILE TRACING             
                    THE GENERATING ALGORITHM */                                 
      CARDIMAGE = 'LEVEL ' || LEVEL || ': ';                                    
      DO I = 1 TO SP;                                                           
         CALL ADD_ITEM (V(STACK(I)));                                           
      END;                                                                      
      CALL ADD_ITEM ('  |  ');                                                  
      DO I = 0 TO TP - 1;                                                       
         CALL ADD_ITEM (V(TEXT(TP-I)));                                         
      END;                                                                      
      OUTPUT = CARDIMAGE;                                                       
   END PRINT_FORM;                                                              
                                                                                
   APPLY_PRODUCTION:                                                            
      PROCEDURE;  /* PERFORM ONE PARSE STEP (ON STACK AND TEXT) AND RECUR  */   
         LEVEL = LEVEL + 1;  /* SIMULATE THE EFFECT OF RECURSION  */            
         IF LEVEL > MAXLEVEL THEN IF LEVEL > DEPTH THEN                         
            DO;  CALL ERROR ('LEVEL OVERFLOW');  LEVEL = 1;  END;               
            ELSE MAXLEVEL = LEVEL;                                              
         MP_SAVE(LEVEL) = MP;      /* SAVE POINTER TO LEFT PART OF PRODUCTION */
         MP = SP;                                                               
         TP_SAVE(LEVEL) = TP;      /* SAVE POINTER INTO TEXT */                 
         P_SAVE(LEVEL) = P;        /* SAVE NUMBER OF PRODUCTION TO BE APPLIED */
         TOKEN_SAVE(LEVEL) = TOKEN;/* SAVE POINTER INTO IS_HEAD ARRAY */        
         STACK(SP) = RIGHT_HEAD(P);/* EXPAND PRODUCTION INTO STACK */           
         J = PRODUCTION(P);                                                     
         DO WHILE J ~= 0;                                                       
            K = SHR(J,24);  J = SHL(J,8);                                       
            IF K ~= 0 THEN                                                      
               IF SP = STACKLIMIT THEN CALL ERROR ('STACK OVERFLOW');           
               ELSE DO;  SP = SP + 1;  STACK(SP) = K;  END;                     
            END;                                                                
         IF CONTROL(BYTE('T')) THEN CALL PRINT_FORM; /* TRACE */                
   END APPLY_PRODUCTION;                                                        
                                                                                
   DIS_APPLY:                                                                   
      PROCEDURE;                                                                
      /* UNDO THE PSEUDO-RECURSION, REVERSING THE EFFECT OF APPLY */            
      TOKEN = TOKEN_SAVE(LEVEL);                                                
      P = P_SAVE(LEVEL);                                                        
      TP = TP_SAVE(LEVEL);                                                      
      SP = MP;                                                                  
      MP = MP_SAVE(LEVEL);                                                      
      STACK(SP) = LEFT_PART(P);                                                 
      LEVEL = LEVEL - 1;                                                        
   END DIS_APPLY;                                                               
                                                                                
   DO I = 1 TO NSY;  INDEX(I) = 0;  END;                                        
   DO I = 1 TO NPR;    /* MAKE SURE PRODUCTIONS ARE PROPERLY GROUPED */         
      J = LEFT_PART(I);                                                         
      IF J ~= LEFT_PART(I-1) THEN                                               
         IF INDEX(J) = 0 THEN                                                   
            INDEX(J) = I;                                                       
         ELSE CALL ERROR ('PRODUCTIONS SEPARATED FOR ' || V(J) ||               
            '.  PRODUCTION ' || I || ' WILL BE IGNORED.');                      
   END;                                                                         
   LEFT_PART(NPR+1) = 0;  /* FLAG END OF TABLE  */                              
   /* SET INITIAL SENTENTIAL FORM TO  _|_  <GOAL>  _|_  */                      
   TP = 0;                                                                      
   MP, SP = 1;                                                                  
   STACK(0), TEXT(0) = TERMINATOR;                                              
   STACK(1) = GOAL_SYMBOL;                                                      
   NETRY, NF11, LEVEL, MAXLEVEL = 0;                                            
   EJECT_PAGE;                                                                  
   OUTPUT = 'SENTENTIAL FORM PRODUCTION:';                                      
   DOUBLE_SPACE;                                                                
   IF CONTROL(BYTE('T')) THEN CALL PRINT_FORM;                                  
                                                                                
                                                                                
                                                                                
   /* NOW COMES THE BASIC ALGORITHM FOR GENERATING THE TABLES  */               
                                                                                
                                                                                
PRODUCTION_LOOP:                                                                
   DO WHILE SP >= MP;  /* CYCLE THRU RIGHT PART OF PRODUCTION */                
      IF STACK(SP) > NT THEN   /* ONLY NON-TERMINALS CAN EXPAND */              
         DO;                                                                    
            NEW = FALSE;                                                        
            I = TEXT(TP);                                                       
            DO TOKEN = 1 TO NT;   /* CYCLE THRU TERMINAL HEADS */               
               IF IS_HEAD (I, TOKEN) THEN IF NEVER_BEEN_HERE THEN NEW = TRUE;   
            END;                                                                
            IF NEW THEN                                                         
               DO;  /* EXPAND STACK(SP) WITH ALL APPLICABLE RULES */            
                  P = INDEX(STACK(SP));                                         
                  DO WHILE LEFT_PART(P) = STACK(SP);                            
                     CALL APPLY_PRODUCTION;                                     
                     GO TO PRODUCTION_LOOP;  /* NOW DOWN A LEVEL  */            
                                                                                
                                                                                
            CONTINUE:      /* AND NOW BACK UP A LEVEL  */                       
                     P = P + 1;  /* MOVE ON TO NEXT PRODUCTION */               
                  END;                                                          
               END;                                                             
         END;                                                                   
      IF TP = TEXTLIMIT THEN CALL ERROR ('TEXT OVERFLOW');                      
      ELSE TP = TP + 1;                                                         
      TEXT(TP) = STACK(SP);  /* RUN THE COMPILER BACKWARDS  */                  
      SP = SP - 1;           /* UNSTACKING AS YOU GO */                         
   END;                                                                         
                                                                                
   /* FULLY EXPANDED AT THIS LEVEL */                                           
   CALL DIS_APPLY;   /* TO COME UP A LEVEL  */                                  
                                                                                
   IF LEVEL >= 0 THEN GO TO CONTINUE;                                           
                                                                                
   IF CONTROL(BYTE('T')) THEN DOUBLE_SPACE;                                     
   OUTPUT = 'F11 HAS ' || NF11 || ' ELEMENTS.';                                 
   OUTPUT = 'THE MAXIMUM DEPTH OF RECURSION WAS ' || MAXLEVEL || ' LEVELS.';    
   OUTPUT = NETRY || ' SENTENTIAL FORMS WERE EXAMINED.';                        
END PRODUCE;                                                                    
                                                                                
INDEX_F11:                                                                      
   PROCEDURE;                                                                   
   /* BUILD AN INDEX INTO F11 FOR EACH PRODUCTION  */                           
   DECLARE (Y, YP, P) FIXED;                                                    
                                                                                
   DO I = 1 TO NPR;                                                             
      IND(I) = 0;                                                               
      IND1(I) = -1;                                                             
   END;                                                                         
                                                                                
   Y, YP = 0;                                                                   
   F11(NF11+1) = SHL(NSY+1, 16);  /* BOUNDARY CONDITION  */                     
   DO I = 1 TO NF11+1;  /* CHECK EACH F11  */                                   
      IF F11(I) >= YP THEN                                                      
         DO;      /* F11 FOR A NEW LEFT PART */                                 
            P = INDEX(Y);                                                       
            DO WHILE LEFT_PART(P) = Y;    /* RECORD END FOR OLD LEFT PART */    
               IND1(P) = I - 1;                                                 
               P = P + 1;                                                       
            END;                                                                
            Y = SHR(F11(I), 16);    /* NEW LEFT PART */                         
            P = INDEX(Y);                                                       
            DO WHILE LEFT_PART(P) = Y;    /* RECORD START FOR NEW LEFT PART */  
               IND(P) = I;                                                      
               P = P + 1;                                                       
            END;                                                                
            YP = SHL(Y+1, 16);   /* TO COMPARE WITH TRIPLE */                   
         END;                                                                   
   END;                                                                         
END INDEX_F11;                                                                  
                                                                                
SORT_PRODUCTIONS:                                                               
   PROCEDURE;    /* RE-NUMBER THE PRODUCTIONS IN AN OPTIMAL ORDER FOR C2  */    
   DO I = 1 TO NPR;  P_SAVE(I) = 0;  END;                                       
   P = 0;                                                                       
   DO I = 1 TO NPR;                                                             
      J = RIGHT_HEAD(I);  /* CONVERT 1 - 4 PACKING TO 4 - 1 PACKING  */         
      M = PRODUCTION(I);                                                        
      IF M = 0 THEN                                                             
         DO;                                                                    
            M = J;                                                              
            J = 0;                                                              
            L = 7;                                                              
         END;                                                                   
      ELSE L = 6;                                                               
      TAIL(I) = M & "FF";                                                       
      M = M & "FFFFFF00";                                                       
      DO WHILE M ~= 0;                                                          
         K = SHR(M, 24);  M = SHL(M, 8);                                        
         IF K ~= 0 THEN                                                         
            DO;                                                                 
               J = SHL(J, 8) + K;                                               
               L = L - 1;                                                       
            END;                                                                
      END;                                                                      
      HEAD(I) = J;                                                              
      /*  SORT ON:  1.  TAIL SYMBOL OF RIGHT PART                               
                       2. LENGTH OF RIGHT PART                                  
                          3. NUMBER OF F11'S                 */                 
      SORT#(I) = SHL(TAIL(I), 23) + SHL(L, 20) + IND1(I) - IND(I);              
      INDEX(I) = I;                                                             
   END;  /* OF DO I  */                                                         
   /* BUBBLE SORT OF PRODUCTIONS  */                                            
   K, L = NPR;                                                                  
   DO WHILE K <= L;                                                             
      L = -1;                                                                   
      DO I = 2 TO K;                                                            
         L = I - 1;                                                             
         IF SORT#(L) > SORT#(I) THEN                                            
            DO;                                                                 
               J = SORT#(L);  SORT#(L) = SORT#(I);  SORT#(I) = J;               
               J = INDEX(L);  INDEX(L) = INDEX(I);  INDEX(I) = J;               
               K = L;                                                           
            END;                                                                
      END;                                                                      
   END;                                                                         
   INDEX(NPR+1) = 0;                                                            
END SORT_PRODUCTIONS;                                                           
                                                                                
COMPUTE_C1:                                                                     
   PROCEDURE;                                                                   
      DECLARE (CX, CTRIP, S1, S2, S3, TR, PR) FIXED;                            
                                                                                
      CALL CLEAR_WORK;                                                          
      NETRY, NTRIP, CTRIP = 0;                                                  
      DO CX = 0 TO 2;      /* REPEAT BASIC LOOP 3 TIMES:                        
                              1. COMPUTE PAIRS                                  
                                 2. COMPUTE TRIPLES FOR PAIR CONFLICTS          
                                    3. EMIT DIAGNOSTICS FOR TRIPLE CONFLICTS  */
        DO P = 1 TO NPR;      /* STEP THROUGH THE PRODUCTIONS  */               
          DO I = IND(P) TO IND1(P);    /* STEP THROUGH THE EXPANSION TRIPLES  */
            CALL EXPAND (F11(I), P);                                            
            DO J = 2 TO SP;      /* STEP THROUGH RIGHT PART OF PRODUCTION  */   
               K = VALUE(J~=SP);                                                
               S1 = STACK(J-1);                                                 
               S2 = STACK(J);                                                   
               L = STACK(J+1);                                                  
               DO S3 = 1 TO NT;     /* STEP THROUGH THE HEADS OF STACK(J+1)  */ 
                  IF IS_HEAD(L, S3) THEN                                        
                     DO CASE CX;                                                
                                                                                
                        /* CASE 0 -- ENTER PAIR  */                             
                        CALL SET (S2, S3, K);                                   
                                                                                
                        /* CASE 1 -- IF PAIR CONFLICT THEN ENTER TRIPLE  */     
                        IF GET (S2, S3) = 3 THEN                                
                           CALL ENTER (PACK (0, S1, S2, S3), K);                
                                                                                
                        /* CASE 2 -- IF TRIPLE CONFLICT EMIT DIAGNOSTIC  */     
                        DO;                                                     
                           TR = PACK (0, S1, S2, S3);                           
                           DO M = 0 TO CTRIP;                                   
                              IF SORT#(M) = TR THEN                             
                                 CALL ENTER (PACK(M, P, STACK(1), STACK(SP+1)), 
                                    K);                                         
                           END;                                                 
                        END;     /* OF CASE 2  */                               
                     END;     /* OF DO CASE  */                                 
               END;     /* OF DO S3  */                                         
            END;     /* OF DO J  */                                             
          END;    /* OF DO I  */                                                
        END;      /* OF DO P  */                                                
         DO CASE CX;  /* CLEAN UP  */                                           
                                                                                
            /* CASE 0  */                                                       
            DO;                                                                 
               DO I = 1 TO NT;      /* SPECIAL RELATIONS FOR TERMINATOR  */     
                  IF IS_HEAD (GOAL_SYMBOL, I) THEN                              
                     CALL SET (TERMINATOR, I, VALUE(TRUE));                     
               END;                                                             
               CALL SET (GOAL_SYMBOL, TERMINATOR, VALUE(FALSE));                
               CALL PRINT_MATRIX ('C1 MATRIX FOR STACKING DECISION', 1);        
               CALL PRINT_TIME;                                                 
            END;                                                                
                                                                                
            /* CASE 1  */                                                       
            DO;                                                                 
               CALL PRINT_TRIPLES ('C1 TRIPLES FOR STACKING DECISION');         
               IF COUNT(3) = 0 | ITERATION_COUNT > 1 THEN RETURN;               
               IF ~ CONTROL(BYTE('I')) THEN                                     
                  IF CONTROL(BYTE('P')) | CONTROL(BYTE('O')) THEN RETURN;       
               CALL PRINT_TIME;                                                 
               DO I = 1 TO NTRIP;                                               
                  IF TV(I) = 3 THEN                                             
                     DO;                                                        
                        SORT#(CTRIP) = TRIPLE(I);                               
                        CTRIP = CTRIP + 1;                                      
                     END;                                                       
               END;                                                             
               CTRIP = CTRIP - 1;                                               
               NETRY, NTRIP = 0;                                                
               DOUBLE_SPACE;                                                    
               OUTPUT = 'ANALYSIS OF (2,1) CONFLICTS:';                         
            END;                                                                
                                                                                
            /* CASE 2  */                                                       
            DO;                                                                 
               J = 1;                                                           
               DO M = 0 TO CTRIP;  /* STEP THROUGH CONFLICTS  */                
                  DO K = 0 TO 1;  /* STEP THROUGH TRUTH VALUES  */              
                     I = SORT#(M);                                              
                     OUTPUT = '';                                               
                     OUTPUT = '   THE TRIPLE  ' || V(SHR(I,16)) || ' ' ||       
                        V(SHR(I,8)&"FF") || ' ' || V(I&"FF") ||                 
                        '  MUST HAVE THE VALUE ' || PRINT(VALUE(K)) ||          
                        ' FOR';                                                 
                     OUTPUT = '';                                               
                     L = SHL(M+1, 24);                                          
                     I = J;                                                     
                     S1 = 0;                                                    
                     DO WHILE TRIPLE(I) < L & I <= NTRIP;                       
                        IF (TV(I)&VALUE(K)) ~= 0 THEN                           
                           DO;                                                  
                              TR = TRIPLE(I);                                   
                              P = SHR(TR, 16) & "FF";                           
                              IF P ~= S1 THEN CALL OUTPUT_PRODUCTION (P);       
                              S1 = P;                                           
                              OUTPUT = '         IN THE CONTEXT  ' ||           
                                 V(SHR(TR, 8)&"FF") || DOTS || V(TR&"FF");      
                           END;                                                 
                        I = I + 1;                                              
                     END;     /* OF DO WHILE  */                                
                  END;  /* OF DO K  */                                          
                  J = I;                                                        
                  OUTPUT = '';                                                  
               END;     /* OF DO M  */                                          
            END;                                                                
         END;     /* OF DO CASE  */                                             
      END;     /* OF DO CX  */                                                  
END COMPUTE_C1;                                                                 
                                                                                
COMPUTE_C2:                                                                     
   PROCEDURE;                                                                   
   /* DETERMINE WHAT (IF ANY) CONTEXT MUST BE CHECKED FOR EACH PRODUCTION       
      TO AUGMENT THE "LONGEST MATCH" RULE FOR THE PRODUCTION SELECTION          
      FUNCTION  C2      */                                                      
                                                                                
      DECLARE (IJ, IK, TJ, TK, PJ, PK, JCT, KCT, JCL, JCR) FIXED,               
         PROPER BIT(1);                                                         
      DECLARE CONTEXT_CLASS(3) CHARACTER INITIAL ('EITHER (0,1) OR (1,0)',      
         '(0,1)', '(1,0)', '(1,1)');                                            
                                                                                
      EJECT_PAGE;                                                               
      OUTPUT = 'CONTEXT CHECK FOR EQUAL AND EMBEDDED RIGHT PARTS:';             
      DO I = 1 TO NPR;  MP_SAVE(I), P_SAVE(I) = 0;  END;                        
      DO J = 1 TO NPR - 1;                                                      
         IJ = INDEX(J);                                                         
         K = J + 1;                                                             
         IK = INDEX(K);                                                         
         DO WHILE TAIL(IJ) = TAIL(IK);  /* CHECK ALL PRODUCTIONS WITH SAME TAI*/
            TJ = HEAD(IJ);                                                      
            TK = HEAD(IK);                                                      
            DO WHILE (TJ & "FF") = (TK & "FF") & TJ ~= 0;                       
               TJ = SHR(TJ, 8);  TK = SHR(TK, 8);                               
            END;                                                                
            IF TK = 0 THEN                                                      
               DO;      /* PRODUCTION IK IS INCLUDED IN IJ  */                  
                  OUTPUT = '';                                                  
                  OUTPUT = '   THERE ARE ' || IND1(IJ)-IND(IJ)+1 ||             
                     ' AND ' || IND1(IK)-IND(IK)+1 ||                           
                     ' VALID CONTEXTS, RESPECTIVELY, FOR';                      
                  CALL OUTPUT_PRODUCTION (IJ);                                  
                  CALL OUTPUT_PRODUCTION (IK);                                  
                  PROPER = TJ ~= 0;  /* IK IS A PROPER SUBSTRING  */            
                  IF PROPER THEN                                                
                     DO;                                                        
                        JCL = SHL(TJ & "FF", 8);                                
                        DO I = 1 TO NSY;                                        
                           ON_RIGHT(I) = FALSE;                                 
                        END;                                                    
                     END;                                                       
                  ELSE P_SAVE(IJ) = 1;  /* REMEMBER THAT EQUAL RIGHT PARTS      
                                        MUST BE DISTINGUISHED SOMEHOW  */       
                  MP = 0;                                                       
                  DO PJ = IND(IJ) TO IND1(IJ);                                  
                     JCT = F11(PJ) & "FFFF";                                    
                     JCR = JCT & "00FF";                                        
                     IF PROPER THEN JCT = JCL | JCR;                            
                     ELSE JCL = JCT & "FF00";                                   
                     DO PK = IND(IK) TO IND1(IK);                               
                        KCT = F11(PK) & "FFFF";                                 
                        IF KCT = JCT THEN                                       
                           DO;                                                  
                              IF MP < 4 THEN CALL ERROR (                       
'THESE PRODUCTIONS CANNOT BE DISTINGUISHED WITH (1,1) CONTEXT.');               
                              MP = MP | 4;                                      
                              IF PROPER THEN                                    
                                 DO;                                            
                                    IF ~ ON_RIGHT(JCR) THEN                     
                                       OUTPUT = '   ' || V(LEFT_PART(IK)) ||    
                                          '  HAS  ' || V(SHR(JCL, 8)) ||        
                                          DOTS || V(JCR) || '  AS CONTEXT AND  '
              || V(JCR) || '  IS VALID RIGHT CONTEXT FOR  ' || V(LEFT_PART(IJ));
                                    ON_RIGHT(JCR) = TRUE;                       
                                 END;                                           
                              ELSE OUTPUT =                                     
'   THEY HAVE EQUAL RIGHT PARTS AND THE COMMON CONTEXT  '                       
                                 || V(SHR(JCL, 8)) || DOTS || V(JCR);           
                              CALL ADD_TROUBLE (SHR(KCT, 8), LEFT_PART(IK));    
                           END;                                                 
                        ELSE IF (KCT & "FF00") = JCL THEN                       
                           MP = MP | 1;  /* CAN'T TELL BY LEFT CONTEXT */       
                        ELSE IF (KCT & "00FF") = JCR THEN                       
                           MP = MP | 2;  /* CAN'T TELL BY RIGHT CONTEXT */      
                     END;     /* PK  */                                         
                  END;        /* PJ  */                                         
                  IF MP < 4 THEN                                                
                     DO;      /* RESOLVABLE BY CONTEXT  */                      
                        IF PROPER & (~MP) THEN /* CONTEXT IMPLICIT IN LENGTH  */
                           OUTPUT = '   THEY CAN BE RESOLVED BY LENGTH.';       
                        ELSE                                                    
                           DO;                                                  
                              MP_SAVE(IJ) = MP_SAVE(IJ) | MP;                   
                              OUTPUT = '   THEY CAN BE RESOLVED BY ' ||         
                                 CONTEXT_CLASS(MP) || ' CONTEXT.';              
                           END;                                                 
                     END;                                                       
               END;     /* OF TK = 0  */                                        
            K = K + 1;                                                          
            IK = INDEX(K);                                                      
         END;     /* DO WHILE  */                                               
      END;     /* DO J  */                                                      
      EJECT_PAGE;                                                               
      OUTPUT = 'C2 PRODUCTION CHOICE FUNCTION:';                                
      TK = 0;                                                                   
      DO J = 1 TO NPR;                                                          
         IJ = INDEX(J);                                                         
         TJ = TAIL(IJ);                                                         
         IF TJ ~= TK THEN                                                       
            DO;                                                                 
               TK = TJ;                                                         
               DOUBLE_SPACE;                                                    
               OUTPUT = '   ' || V(TJ) ||                                       
'  AS STACK TOP WILL CAUSE PRODUCTIONS TO BE CHECKED IN THIS ORDER:';           
            END;                                                                
         OUTPUT = '';                                                           
         CALL OUTPUT_PRODUCTION (IJ);                                           
         DO CASE MP_SAVE(IJ) & 3;                                               
            /* CASE 0  */                                                       
            IF P_SAVE(IJ) THEN GO TO CASE_1;  /* EQUAL RIGHT PART MUST CHECK */ 
            ELSE OUTPUT = '         THERE WILL BE NO CONTEXT CHECK.';           
                                                                                
            /* CASE 1  */                                                       
         CASE_1:                                                                
            DO;                                                                 
               OUTPUT =                                                         
'         (0,1) CONTEXT WILL BE CHECKED.  LEGAL RIGHT CONTEXT:';                
               DO I = 1 TO NSY;  ON_RIGHT(I) = FALSE;  END;                     
               DO PJ = IND(IJ) TO IND1(IJ);                                     
                  JCR = F11(PJ) & "FF";                                         
                  IF ~ ON_RIGHT(JCR) THEN                                       
                     DO;                                                        
                        ON_RIGHT(JCR) = TRUE;                                   
                        OUTPUT = X12 || DOTS || V(JCR);                         
                     END;                                                       
               END;                                                             
            END;                                                                
                                                                                
            /* CASE 2  */                                                       
            DO;                                                                 
               OUTPUT =                                                         
'         (1,0) CONTEXT WILL BE CHECKED.  LEGAL LEFT CONTEXT:';                 
               DO I = 1 TO NSY;  ON_LEFT(I) = FALSE;  END;                      
               DO PJ = IND(IJ) TO IND1(IJ);                                     
                  JCL = SHR(F11(PJ) & "FF00", 8);                               
                  IF ~ ON_LEFT(JCL) THEN                                        
                     DO;                                                        
                        ON_LEFT(JCL) = TRUE;                                    
                        OUTPUT = X12 || V(JCL) || DOTS;                         
                     END;                                                       
               END;                                                             
            END;                                                                
                                                                                
            /* CASE 3  */                                                       
            DO;                                                                 
               OUTPUT =                                                         
                  '         (1,1) CONTEXT WILL BE CHECKED.  LEGAL CONTEXT:';    
               DO PJ = IND(IJ) TO IND1(IJ);                                     
                  OUTPUT = X12 || V(SHR(F11(PJ) & "FF00", 8)) ||                
                     DOTS || V(F11(PJ) & "FF");                                 
               END;                                                             
            END;                                                                
         END;   /* OF CASE STATEMENT  */                                        
      END;  /* OF DO J  */                                                      
  END COMPUTE_C2;                                                               
                                                                                
PUNCH_PRODUCTIONS:                                                              
   PROCEDURE;                                                                   
   DECLARE WIDE FIXED;                                                          
   IF ~(CONTROL(BYTE('P')) | CONTROL(BYTE('O'))) THEN RETURN;                   
   IF CONTROL(BYTE('O')) THEN EJECT_PAGE;                                       
   OUTCARD = '  ';                                                              
   CALL PUNCH_CARD ('DECLARE NSY LITERALLY ''' || NSY || ''', NT LITERALLY '''  
      || NT || ''';');                                                          
   CALL BUILD_CARD ('DECLARE V(NSY) CHARACTER INITIAL (');                      
   DO I = 0 TO NSY;                                                             
      S = V(I);                                                                 
      T = '';                                                                   
      L = LENGTH(S) - 1;                                                        
      DO WHILE BYTE(S, L) = BLANK;  L = L - 1;  END;                            
      IF I > BASIC_NSY THEN                                                     
         DO;      /* CREATED SYMBOL:  ADJUST PRINT NAME  */                     
            L = L - 3;                                                          
            S = SUBSTR(S, 1);                                                   
         END;                                                                   
      DO J = 0 TO L;                                                            
         IF SUBSTR(S, J, 1) = '''' THEN T = T || '''''';                        
         ELSE T = T || SUBSTR(S, J, 1);                                         
      END;                                                                      
      IF I < NSY THEN CALL BUILD_CARD ('''' || T || ''',');                     
      ELSE CALL PUNCH_CARD ('''' || T || ''');');                               
   END;                                                                         
   L = LENGTH(V(NT));                                                           
   CALL BUILD_CARD ('DECLARE V_INDEX(' || L || ') BIT(8) INITIAL (');           
   J = 1;                                                                       
   DO I = 1 TO L;                                                               
      CALL BUILD_CARD (J || ',');                                               
      DO WHILE LENGTH(V(J)) = I;  J = J + 1;  END;                              
   END;                                                                         
   CALL PUNCH_CARD (NT+1 || ');');                                              
   IF NT <= 15 THEN WIDE = 16;  /* FORCE LONG BIT STRINGS */                    
   ELSE WIDE = NT;                                                              
   I = 2*WIDE + 2;                                                              
   CALL PUNCH_CARD ('DECLARE C1(NSY) BIT(' || I || ') INITIAL (');              
   DO I = 0 TO NSY;                                                             
      T = '   "(2)';                                                            
      DO J = 0 TO WIDE;                                                         
         IF J MOD 5 = 0 THEN                                                    
            DO;                                                                 
               CALL BUILD_CARD (T);                                             
               T = '';                                                          
            END;                                                                
         T = T || GET (I, J);                                                   
      END;                                                                      
      IF I < NSY THEN CALL PUNCH_CARD (T || '",');                              
      ELSE CALL PUNCH_CARD (T || '");');                                        
   END;                                                                         
   K = COUNT(1) - 1;                                                            
   IF K < 0 THEN                                                                
      DO;                                                                       
         CALL PUNCH_CARD ('DECLARE NC1TRIPLES LITERALLY ''0'';');               
         CALL PUNCH_CARD ('DECLARE C1TRIPLES(0) FIXED;');                       
      END;                                                                      
   ELSE                                                                         
      DO;                                                                       
         CALL PUNCH_CARD ('DECLARE NC1TRIPLES LITERALLY ''' || K || ''';');     
         CALL BUILD_CARD ('DECLARE C1TRIPLES(NC1TRIPLES) FIXED INITIAL (');     
         J = 0;                                                                 
         DO I = 1 TO NTRIP;                                                     
            IF TV(I) = 1 THEN                                                   
               DO;                                                              
                  IF J = K THEN CALL PUNCH_CARD (TRIPLE(I) || ');');            
                  ELSE CALL BUILD_CARD (TRIPLE(I) || ',');                      
                  J = J + 1;                                                    
               END;                                                             
         END;                                                                   
      END;                                                                      
   CALL BUILD_CARD ('DECLARE PRTB(' || NPR || ') FIXED INITIAL (0,');           
   DO I = 1 TO NPR - 1;                                                         
      CALL BUILD_CARD (HEAD(INDEX(I)) || ',');                                  
   END;                                                                         
   CALL PUNCH_CARD (HEAD(INDEX(NPR)) || ');');                                  
   CALL BUILD_CARD ('DECLARE PRDTB(' || NPR || ') BIT(8) INITIAL (0,');         
   DO I = 1 TO NPR;                                                             
      L = INDEX(I);                                                             
      IF L > BASIC_NPR THEN L = 0;                                              
      IF I < NPR THEN CALL BUILD_CARD (L || ',');                               
      ELSE CALL PUNCH_CARD (L || ');');                                         
   END;                                                                         
   CALL BUILD_CARD ('DECLARE HDTB(' || NPR || ') BIT(8) INITIAL (0,');          
   DO I = 1 TO NPR - 1;                                                         
      CALL BUILD_CARD (LEFT_PART(INDEX(I)) || ',');                             
   END;                                                                         
   CALL PUNCH_CARD (LEFT_PART(INDEX(NPR)) || ');');                             
   CALL BUILD_CARD ('DECLARE PRLENGTH(' || NPR || ') BIT(8) INITIAL (0,');      
   DO I = 1 TO NPR;                                                             
      J = 1;                                                                    
      K = HEAD(INDEX(I));                                                       
      DO WHILE K ~= 0;                                                          
         J = J + 1;                                                             
         K = SHR(K, 8);                                                         
      END;                                                                      
      IF I = NPR THEN CALL PUNCH_CARD ( J || ');');                             
      ELSE CALL BUILD_CARD (J || ',');                                          
   END;                                                                         
   CALL BUILD_CARD ('DECLARE CONTEXT_CASE(' || NPR || ') BIT(8) INITIAL (0,');  
   DO I = 1 TO NSY;  TP_SAVE(I) = 0;  END;                                      
   DO I = 1 TO NPR;   /* COMPUTE CONTEXT CASE */                                
      J = MP_SAVE(INDEX(I));  /* SET UP IN COMPUTE_C2, USED HERE  */            
      K = LEFT_PART(INDEX(I));                                                  
      DO CASE J;                                                                
         /* CASE 0, CAN TELL BY EITHER LEFT OR RIGHT CONTEXT,                   
         USE LENGTH TO DECIDE UNLESS EQUAL */                                   
         J = P_SAVE(INDEX(I));  /* USE THE CHEAP TEST, IF REQUIRED  */          
         /* CASE 1, USE C1 MATRIX FOR THIS CASE */                              
         ;                                                                      
         /* CASE 2:  NEED LEFT CONTEXT TABLE */                                 
         TP_SAVE(K) = TP_SAVE(K) | 1;                                           
         /* CASE 3:  NEED BOTH LEFT AND RIGHT CONTEXT */                        
         TP_SAVE(K) = TP_SAVE(K) | 2;                                           
      END;                                                                      
      TOKEN_SAVE(K) = INDEX(I);                                                 
      IF I = NPR THEN CALL PUNCH_CARD (J || ');');                              
      ELSE CALL BUILD_CARD (J || ',');                                          
   END;                                                                         
   J = 0;   /* CONSTRUCT CONTEXT TABLES FOR C2 */                               
   DO I = NT + 1 TO NSY;  /* CYCLE THRU NON-TERMINALS */                        
      SORT#(I) = J;                                                             
      IF TP_SAVE(I) THEN                                                        
         DO;                                                                    
            K = TOKEN_SAVE(I);                                                  
            M = 0;                                                              
            DO L = IND(K) TO IND1(K);                                           
               P = SHR(F11(L), 8) & "FF";                                       
               IF P ~= M THEN                                                   
                  DO;                                                           
                     WORK(J), M = P;                                            
                     J = J + 1;  /* COUNT THE NUMBER OF ENTRIES */              
                  END;                                                          
            END;                                                                
         END;                                                                   
   END;                                                                         
   IF J = 0 THEN J = 1;  /* ASSURE NON-NEGATIVE UPPER BOUND FOR ARRAY */        
   CALL BUILD_CARD ('DECLARE LEFT_CONTEXT(' || J - 1 ||                         
      ') BIT(8) INITIAL (');                                                    
   DO I = 0 TO J - 2;                                                           
      CALL BUILD_CARD (WORK(I) || ',');                                         
   END;                                                                         
   CALL PUNCH_CARD (WORK(J-1) || ');');                                         
   IF J > 255 THEN K = 16;  ELSE K = 8;  /* J < 256 ALLOWS 8 BIT PACKING */     
   CALL BUILD_CARD ('DECLARE LEFT_INDEX(' || NSY-NT || ') BIT(' || K            
      || ') INITIAL (');                                                        
   DO I = NT + 1 TO NSY;                                                        
      CALL BUILD_CARD (SORT#(I) || ',');                                        
   END;                                                                         
   CALL PUNCH_CARD (J || ');');                                                 
   J = 0;                                                                       
   DO I = NT + 1 TO NSY;                                                        
      SORT#(I) = J;  /* RECORD WHERE EACH NON-TERMINAL STARTS */                
      IF SHR(TP_SAVE(I), 1) THEN  /* NEED BOTH CONTEXTS */                      
         DO;                                                                    
            K = TOKEN_SAVE(I);                                                  
            DO L = IND(K) TO IND1(K);                                           
               TRIPLE(J) = F11(L) & "FFFF";                                     
               J = J + 1;                                                       
            END;                                                                
         END;                                                                   
   END;                                                                         
   IF J = 0 THEN J = 1;  /* ASSURE NON-NEGATIVE UPPER BOUND FOR ARRAY */        
   CALL BUILD_CARD ('DECLARE CONTEXT_TRIPLE(' || J-1 || ') FIXED INITIAL (');   
   DO I = 0 TO J - 2;                                                           
      CALL BUILD_CARD (TRIPLE(I) || ',');                                       
   END;                                                                         
   CALL PUNCH_CARD (TRIPLE(J-1) || ');');                                       
   IF J > 255 THEN K = 16;  ELSE K = 8;  /* J < 256 ALLOWS 8 BIT PACKING */     
   CALL BUILD_CARD ('DECLARE TRIPLE_INDEX(' || NSY-NT || ') BIT(' || K          
      || ') INITIAL (');                                                        
   DO I = NT + 1 TO NSY;   /* PUNCH MARGINAL INDEX TABLE */                     
      CALL BUILD_CARD (SORT#(I) || ',');                                        
   END;                                                                         
   CALL PUNCH_CARD (J || ');');                                                 
   DO I = 0 TO NSY;  P_SAVE(I) = 0;  END;                                       
   DO I = 1 TO NPR;       /* CYCLE THRU THE PRODUCTIONS */                      
      P = TAIL(INDEX(I));  /* MARGINAL INDEX INTO PRODUCTION TABLE */           
      IF P_SAVE(P) = 0 THEN P_SAVE(P) = I;                                      
   END;                                                                         
   P_SAVE(NSY+1) = NPR + 1;  /* MARK THE END OF THE PRODUCTION TABLE */         
   DO J = 0 TO NSY - 1;  /* TAKE CARE OF SYMBOLS THAT NEVER END A PRODUCTION */ 
      I = NSY - J;                                                              
      IF P_SAVE(I) = 0 THEN P_SAVE(I) = P_SAVE(I+1);                            
   END;                                                                         
   CALL BUILD_CARD ('DECLARE PR_INDEX(' || NSY || ') BIT(8) INITIAL (');        
   DO I = 1 TO NSY;                                                             
      CALL BUILD_CARD (P_SAVE(I) || ',');                                       
   END;                                                                         
   CALL PUNCH_CARD (NPR+1 || ');');                                             
   CALL PRINT_TIME;                                                             
END PUNCH_PRODUCTIONS;                                                          
                                                                                
   /* THE ACTUAL EXECUTION IS CONTROLLED FROM THIS LOOP  */                     
                                                                                
   DO WHILE STACKING;                                                           
      FIRST_TIME, LAST_TIME = TIME;                                             
      ITERATION_COUNT, TROUBLE_COUNT = 1;                                       
      DO WHILE TROUBLE_COUNT > 0;                                               
         IF ITERATION_COUNT = 1 THEN CALL READ_GRAMMAR;                         
         ELSE CALL IMPROVE_GRAMMAR;                                             
         CALL PRINT_TIME;                                                       
         CALL COMPUTE_HEADS;                                                    
         CALL PRINT_TIME;                                                       
         IF ~ AMBIGUOUS THEN                                                    
            DO;                                                                 
               CALL PRODUCE;                                                    
               CALL PRINT_TIME;                                                 
               CALL INDEX_F11;                                                  
               CALL SORT_PRODUCTIONS;                                           
               CALL COMPUTE_C1;                                                 
               CALL PRINT_TIME;                                                 
               CALL COMPUTE_C2;                                                 
               CALL PRINT_TIME;                                                 
               DOUBLE_SPACE;                                                    
            END;                                                                
         OUTPUT = 'ANALYSIS COMPLETE FOR ITERATION ' || ITERATION_COUNT;        
         IF ERROR_COUNT = 0 THEN OUTPUT = 'NO ERRORS WERE DETECTED.';           
         ELSE IF ERROR_COUNT = 1 THEN OUTPUT = '* ONE ERROR WAS DETECTED.';     
         ELSE IF ERROR_COUNT <= 20 THEN                                         
            OUTPUT = SUBSTR('********************', 0, ERROR_COUNT) || ' ' ||   
               ERROR_COUNT || ' ERRORS WERE DETECTED.';                         
         ELSE OUTPUT = '******************** ... ' || ERROR_COUNT ||            
            ' ERRORS WERE DETECTED.';                                           
         ITERATION_COUNT = ITERATION_COUNT + 1;                                 
         IF AMBIGUOUS | ~ CONTROL(BYTE('I')) THEN TROUBLE_COUNT = 0;            
      END;                                                                      
      IF ~ AMBIGUOUS THEN CALL PUNCH_PRODUCTIONS;                               
      IF CONTROL(BYTE('P')) THEN OUTPUT = 'PUNCHING COMPLETE.';                 
   END;                                                                         

