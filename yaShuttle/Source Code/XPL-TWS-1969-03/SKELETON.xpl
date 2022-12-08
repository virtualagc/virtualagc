 /*   SKELETON                                                                  
                THE PROTO-COMPILER OF THE XPL SYSTEM                            
                                                                                
                                                                                
W. M. MCKEEMAN         J. J. HORNING           D. B. WORTMAN                    
                                                                                
INFORMATION &          COMPUTER SCIENCE        COMPUTER SCIENCE                 
COMPUTER SCIENCE,      DEPARTMENT,             DEPARTMENT,                      
                                                                                
UNIVERSITY OF          STANFORD                STANFORD                         
CALIFORNIA AT          UNIVERSITY,             UNIVERSITY,                      
                                                                                
SANTA CRUZ,            STANFORD,               STANFORD,                        
CALIFORNIA             CALIFORNIA              CALIFORNIA                       
95060                  94305                   94305                            
                                                                                
DEVELOPED AT THE STANFORD COMPUTATION CENTER, CAMPUS FACILITY,   1966-69        
AND THE UNIVERSITY OF CALIFORNIA COMPUTATION CENTER, SANTA CRUZ, 1968-69.       
                                                                                
DISTRIBUTED THROUGH THE SHARE ORGANIZATION.                                     
THIS VERSION OF SKELETON IS A SYNTAX CHECKER FOR THE FOLLOWING GRAMMAR:         
                                                                                
<PROGRAM>  ::=  <STATEMENT LIST>                                                
                                                                                
<STATEMENT LIST>  ::=  <STATEMENT>                                              
                    |  <STATEMENT LIST> <STATEMENT>                             
                                                                                
<STATEMENT>  ::=  <ASSIGNMENT> ;                                                
                                                                                
<ASSIGNMENT>  ::=  <VARIABLE> = <EXPRESSION>                                    
                                                                                
<EXPRESSION>  ::=  <ARITH EXPRESSION>                                           
                |  <IF CLAUSE> THEN <EXPRESSION> ELSE <EXPRESSION>              
                                                                                
<IF CLAUSE>  ::=  IF <LOG EXPRESSION>                                           
                                                                                
<LOG EXPRESSION>  ::=  TRUE                                                     
                    |  FALSE                                                    
                    |  <EXPRESSION> <RELATION> <EXPRESSION>                     
                    |  <IF CLAUSE> THEN <LOG EXPRESSION> ELSE <LOG EXPRESSION>  
                                                                                
<RELATION>  ::=  =                                                              
              |  <                                                              
              |  >                                                              
                                                                                
<ARITH EXPRESSION>  ::=  <TERM>                                                 
                      |  <ARITH EXPRESSION> + <TERM>                            
                      |  <ARITH EXPRESSION> - <TERM>                            
                                                                                
<TERM>  ::=  <PRIMARY>                                                          
          |  <TERM> * <PRIMARY>                                                 
          |  <TERM> / <PRIMARY>                                                 
                                                                                
<PRIMARY>  ::=  <VARIABLE>                                                      
             |  <NUMBER>                                                        
             |  ( <EXPRESSION> )                                                
                                                                                
<VARIABLE>  ::=  <IDENTIFIER>                                                   
              |  <VARIABLE> ( <EXPRESSION> )                                    
                                                                              */
                                                                                
   /*  FIRST WE INITIALIZE THE GLOBAL CONSTANTS THAT DEPEND UPON THE INPUT      
      GRAMMAR.  THE FOLLOWING CARDS ARE PUNCHED BY THE SYNTAX PRE-PROCESSOR  */ 
                                                                                
   DECLARE NSY LITERALLY '32', NT LITERALLY '18';                               
   DECLARE V(NSY) CHARACTER INITIAL ( '<ERROR: TOKEN = 0>', ';', '=', '<', '>', 
      '+', '-', '*', '/', '(', ')', 'IF', '_|_', 'THEN', 'ELSE', 'TRUE',        
      'FALSE', '<NUMBER>', '<IDENTIFIER>', '<TERM>', '<PROGRAM>', '<PRIMARY>',  
      '<VARIABLE>', '<RELATION>', '<STATEMENT>', '<IF CLAUSE>', '<ASSIGNMENT>', 
      '<EXPRESSION>', '<STATEMENT LIST>', '<ARITH EXPRESSION>',                 
      '<LOG EXPRESSION>', 'ELSE', 'ELSE');                                      
   DECLARE V_INDEX(12) BIT(16) INITIAL ( 1, 11, 12, 13, 16, 17, 17, 17, 18, 18, 
      18, 18, 19);                                                              
   DECLARE C1(NSY) BIT(38) INITIAL (                                            
      "(2) 00000 00000 00000 0000",                                             
      "(2) 00000 00000 00200 0002",                                             
      "(2) 00000 00003 03000 0033",                                             
      "(2) 00000 00002 02000 0022",                                             
      "(2) 00000 00002 02000 0022",                                             
      "(2) 00000 00001 00000 0011",                                             
      "(2) 00000 00001 00000 0011",                                             
      "(2) 00000 00001 00000 0011",                                             
      "(2) 00000 00001 00000 0011",                                             
      "(2) 00000 00001 01000 0011",                                             
      "(2) 02222 22222 20022 0000",                                             
      "(2) 00000 00001 01000 1111",                                             
      "(2) 00000 00000 00000 0001",                                             
      "(2) 00000 00001 01000 1111",                                             
      "(2) 00000 00002 02000 2222",                                             
      "(2) 00000 00000 00022 0000",                                             
      "(2) 00000 00000 00022 0000",                                             
      "(2) 02222 22220 20022 0000",                                             
      "(2) 02222 22222 20022 0000",                                             
      "(2) 02222 22110 20022 0000",                                             
      "(2) 00000 00000 00000 0000",                                             
      "(2) 02222 22220 20022 0000",                                             
      "(2) 02322 22221 20022 0000",                                             
      "(2) 00000 00001 01000 0011",                                             
      "(2) 00000 00000 00200 0002",                                             
      "(2) 00000 00000 00010 0000",                                             
      "(2) 01000 00000 00000 0000",                                             
      "(2) 02333 00000 30023 0000",                                             
      "(2) 00000 00000 00200 0001",                                             
      "(2) 02222 11000 20022 0000",                                             
      "(2) 00000 00000 00023 0000",                                             
      "(2) 00000 00001 01000 0011",                                             
      "(2) 00000 00001 01000 1111");                                            
   DECLARE NC1TRIPLES LITERALLY '17';                                           
   DECLARE C1TRIPLES(NC1TRIPLES) FIXED INITIAL ( 596746, 727810, 727811, 727812,
      792066, 858882, 858883, 858884, 858894, 859662, 1442313, 1442315, 1442321,
      1442322, 1840642, 2104066, 2104067, 2104068);                             
   DECLARE PRTB(28) FIXED INITIAL (0, 26, 0, 0, 0, 1444123, 2331, 0, 0, 0, 0, 0,
      0, 7429, 7430, 0, 4871, 4872, 0, 0, 28, 0, 420289311, 5634, 6935, 0, 0,   
      420290080, 11);                                                           
   DECLARE PRDTB(28) BIT(8) INITIAL (0, 4, 13, 14, 15, 26, 24, 0, 0, 9, 10, 23, 
      25, 17, 18, 16, 20, 21, 19, 22, 3, 2, 7, 5, 11, 1, 6, 12, 8);             
   DECLARE HDTB(28) BIT(8) INITIAL (0, 24, 23, 23, 23, 22, 21, 31, 32, 30, 30,  
      21, 22, 29, 29, 29, 19, 19, 19, 21, 28, 28, 27, 26, 30, 20, 27, 30, 25);  
   DECLARE PRLENGTH(28) BIT(8) INITIAL (0, 2, 1, 1, 1, 4, 3, 1, 1, 1, 1, 1, 1,  
      3, 3, 1, 3, 3, 1, 1, 2, 1, 5, 3, 3, 1, 1, 5, 2);                          
   DECLARE CONTEXT_CASE(28) BIT(8) INITIAL (0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);                       
   DECLARE LEFT_CONTEXT(0) BIT(8) INITIAL ( 27);                                
   DECLARE LEFT_INDEX(14) BIT(8) INITIAL ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  
      0, 1, 1);                                                                 
   DECLARE CONTEXT_TRIPLE(0) FIXED INITIAL ( 0);                                
   DECLARE TRIPLE_INDEX(14) BIT(8) INITIAL ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 1);                                                                 
   DECLARE PR_INDEX(32) BIT(8) INITIAL ( 1, 2, 3, 4, 5, 5, 5, 5, 5, 5, 7, 7, 7, 
      7, 9, 10, 11, 12, 13, 16, 16, 19, 20, 20, 22, 22, 22, 25, 26, 27, 29, 29, 
      29);                                                                      
                                                                                
   /*  END OF CARDS PUNCHED BY SYNTAX                                      */   
                                                                                
   /*  DECLARATIONS FOR THE SCANNER                                        */   
                                                                                
   /* TOKEN IS THE INDEX INTO THE VOCABULARY V() OF THE LAST SYMBOL SCANNED,    
      CP IS THE POINTER TO THE LAST CHARACTER SCANNED IN THE CARDIMAGE,         
      BCD IS THE LAST SYMBOL SCANNED (LITERAL CHARACTER STRING). */             
   DECLARE (TOKEN, CP) FIXED, BCD CHARACTER;                                    
                                                                                
   /* SET UP SOME CONVENIENT ABBREVIATIONS FOR PRINTER CONTROL */               
   DECLARE EJECT_PAGE LITERALLY 'OUTPUT(1) = PAGE',                             
      PAGE CHARACTER INITIAL ('1'), DOUBLE CHARACTER INITIAL ('0'),             
      DOUBLE_SPACE LITERALLY 'OUTPUT(1) = DOUBLE',                              
      X70 CHARACTER INITIAL ('                                                  
                    ');                                                         
                                                                                
   /* LENGTH OF LONGEST SYMBOL IN V */                                          
   DECLARE (RESERVED_LIMIT, MARGIN_CHOP) FIXED;                                 
                                                                                
   /* CHARTYPE() IS USED TO DISTINGUISH CLASSES OF SYMBOLS IN THE SCANNER.      
      TX() IS A TABLE USED FOR TRANSLATING FROM ONE CHARACTER SET TO ANOTHER.   
      CONTROL() HOLDS THE VALUE OF THE COMPILER CONTROL TOGGLES SET IN $ CARDS. 
      NOT_LETTER_OR_DIGIT() IS SIMILIAR TO CHARTYPE() BUT USED IN SCANNING      
      IDENTIFIERS ONLY.                                                         
                                                                                
      ALL ARE USED BY THE SCANNER AND CONTROL() IS SET THERE.                   
   */                                                                           
   DECLARE (CHARTYPE, TX) (255) BIT(8),                                         
           (CONTROL, NOT_LETTER_OR_DIGIT)(255) BIT(1);                          
                                                                                
   /* ALPHABET CONSISTS OF THE SYMBOLS CONSIDERED ALPHABETIC IN BUILDING        
      IDENTIFIERS     */                                                        
   DECLARE ALPHABET CHARACTER INITIAL ('ABCDEFGHIJKLMNOPQRSTUVWXYZ_$@#');       
                                                                                
   /* BUFFER HOLDS THE LATEST CARDIMAGE,                                        
      TEXT HOLDS THE PRESENT STATE OF THE INPUT TEXT                            
      (NOT INCLUDING THE PORTIONS DELETED BY THE SCANNER),                      
      TEXT_LIMIT IS A CONVENIENT PLACE TO STORE THE POINTER TO THE END OF TEXT, 
      CARD_COUNT IS INCREMENTED BY ONE FOR EVERY SOURCE CARD READ,              
      ERROR_COUNT TABULATES THE ERRORS AS THEY ARE DETECTED,                    
      SEVERE_ERRORS TABULATES THOSE ERRORS OF FATAL SIGNIFICANCE.               
   */                                                                           
   DECLARE (BUFFER, TEXT) CHARACTER,                                            
      (TEXT_LIMIT, CARD_COUNT, ERROR_COUNT, SEVERE_ERRORS, PREVIOUS_ERROR) FIXED
      ;                                                                         
                                                                                
   /* NUMBER_VALUE CONTAINS THE NUMERIC VALUE OF THE LAST CONSTANT SCANNED,     
   */                                                                           
   DECLARE NUMBER_VALUE FIXED;                                                  
                                                                                
   /* EACH OF THE FOLLOWING CONTAINS THE INDEX INTO V() OF THE CORRESPONDING    
      SYMBOL.   WE ASK:    IF TOKEN = IDENT    ETC.    */                       
   DECLARE (IDENT, NUMBER, DIVIDE, EOFILE) FIXED;                               
                                                                                
   /* STOPIT() IS A TABLE OF SYMBOLS WHICH ARE ALLOWED TO TERMINATE THE ERROR   
      FLUSH PROCESS.  IN GENERAL THEY ARE SYMBOLS OF SUFFICIENT SYNTACTIC       
      HIERARCHY THAT WE EXPECT TO AVOID ATTEMPTING TO START CHECKING AGAIN      
      RIGHT INTO ANOTHER ERROR PRODUCING SITUATION.  THE TOKEN STACK IS ALSO    
      FLUSHED DOWN TO SOMETHING ACCEPTABLE TO A STOPIT() SYMBOL.                
      FAILSOFT IS A BIT WHICH ALLOWS THE COMPILER ONE ATTEMPT AT A GENTLE       
      RECOVERY.   THEN IT TAKES A STRONG HAND.   WHEN THERE IS REAL TROUBLE     
      COMPILING IS SET TO FALSE, THEREBY TERMINATING THE COMPILATION.           
   */                                                                           
   DECLARE STOPIT(100) BIT(1), (FAILSOFT, COMPILING) BIT(1);                    
                                                                                
   DECLARE S CHARACTER;  /* A TEMPORARY USED VARIOUS PLACES */                  
                                                                                
   /* THE ENTRIES IN PRMASK() ARE USED TO SELECT OUT PORTIONS OF CODED          
      PRODUCTIONS AND THE STACK TOP FOR COMPARISON IN THE ANALYSIS ALGORITHM */ 
   DECLARE PRMASK(5) FIXED INITIAL (0, 0, "FF", "FFFF", "FFFFFF", "FFFFFFFF");  
                                                                                
                                                                                
   /*THE PROPER SUBSTRING OF POINTER IS USED TO PLACE AN  |  UNDER THE POINT    
      OF DETECTION OF AN ERROR DURING CHECKING.  IT MARKS THE LAST CHARACTER    
      SCANNED.  */                                                              
   DECLARE POINTER CHARACTER INITIAL ('                                         
                                           |');                                 
   DECLARE CALLCOUNT(20) FIXED   /* COUNT THE CALLS OF IMPORTANT PROCEDURES */  
      INITIAL(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);                       
                                                                                
   /* RECORD THE TIMES OF IMPORTANT POINTS DURING CHECKING */                   
   DECLARE CLOCK(5) FIXED;                                                      
                                                                                
                                                                                
   /* COMMONLY USED STRINGS */                                                  
   DECLARE X1 CHARACTER INITIAL(' '), X4 CHARACTER INITIAL('    ');             
   DECLARE PERIOD CHARACTER INITIAL ('.');                                      
                                                                                
   /* TEMPORARIES USED THROUGHOUT THE COMPILER */                               
   DECLARE (I, J, K, L) FIXED;                                                  
                                                                                
   DECLARE TRUE LITERALLY '1', FALSE LITERALLY '0', FOREVER LITERALLY 'WHILE 1';
                                                                                
   /*  THE STACKS DECLARED BELOW ARE USED TO DRIVE THE SYNTACTIC                
      ANALYSIS ALGORITHM AND STORE INFORMATION RELEVANT TO THE INTERPRETATION   
      OF THE TEXT.  THE STACKS ARE ALL POINTED TO BY THE STACK POINTER SP.  */  
                                                                                
   DECLARE STACKSIZE LITERALLY '75';  /* SIZE OF STACK  */                      
   DECLARE PARSE_STACK (STACKSIZE) BIT(8); /* TOKENS OF THE PARTIALLY PARSED    
                                              TEXT */                           
   DECLARE VAR (STACKSIZE) CHARACTER;/* EBCDIC NAME OF ITEM */                  
   DECLARE FIXV (STACKSIZE) FIXED;   /* FIXED (NUMERIC) VALUE */                
                                                                                
   /* SP POINTS TO THE RIGHT END OF THE REDUCIBLE STRING IN THE PARSE STACK,    
      MP POINTS TO THE LEFT END, AND                                            
      MPP1 = MP+1.                                                              
   */                                                                           
   DECLARE (SP, MP, MPP1) FIXED;                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
   /*               P R O C E D U R E S                                  */     
                                                                                
                                                                                
                                                                                
PAD:                                                                            
   PROCEDURE (STRING, WIDTH) CHARACTER;                                         
      DECLARE STRING CHARACTER, (WIDTH, L) FIXED;                               
                                                                                
      L = LENGTH(STRING);                                                       
      IF L >= WIDTH THEN RETURN STRING;                                         
      ELSE RETURN STRING || SUBSTR(X70, 0, WIDTH-L);                            
   END PAD;                                                                     
                                                                                
I_FORMAT:                                                                       
   PROCEDURE (NUMBER, WIDTH) CHARACTER;                                         
      DECLARE (NUMBER, WIDTH, L) FIXED, STRING CHARACTER;                       
                                                                                
      STRING = NUMBER;                                                          
      L = LENGTH(STRING);                                                       
      IF L >= WIDTH THEN RETURN STRING;                                         
      ELSE RETURN SUBSTR(X70, 0, WIDTH-L) || STRING;                            
   END I_FORMAT;                                                                
                                                                                
ERROR:                                                                          
   PROCEDURE(MSG, SEVERITY);                                                    
      /* PRINTS AND ACCOUNTS FOR ALL ERROR MESSAGES */                          
      /* IF SEVERITY IS NOT SUPPLIED, 0 IS ASSUMED */                           
      DECLARE MSG CHARACTER, SEVERITY FIXED;                                    
      ERROR_COUNT = ERROR_COUNT + 1;                                            
      /* IF LISTING IS SUPPRESSED, FORCE PRINTING OF THIS LINE */               
      IF ~ CONTROL(BYTE('L')) THEN                                              
         OUTPUT = I_FORMAT (CARD_COUNT, 4) || ' |' || BUFFER || '|';            
      OUTPUT = SUBSTR(POINTER, TEXT_LIMIT-CP+MARGIN_CHOP);                      
      OUTPUT = '*** ERROR, ' || MSG ||                                          
            '.  LAST PREVIOUS ERROR WAS DETECTED ON LINE ' ||                   
            PREVIOUS_ERROR || '.  ***';                                         
      PREVIOUS_ERROR = CARD_COUNT;                                              
      IF SEVERITY > 0 THEN                                                      
         IF SEVERE_ERRORS > 25 THEN                                             
            DO;                                                                 
               OUTPUT = '*** TOO MANY SEVERE ERRORS, CHECKING ABORTED ***';     
               COMPILING = FALSE;                                               
            END;                                                                
         ELSE SEVERE_ERRORS = SEVERE_ERRORS + 1;                                
   END ERROR;                                                                   
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
  /*                   CARD IMAGE HANDLING PROCEDURE                      */    
                                                                                
                                                                                
GET_CARD:                                                                       
   PROCEDURE;                                                                   
      /* DOES ALL CARD READING AND LISTING                                 */   
      DECLARE I FIXED, (TEMP, TEMP0, REST) CHARACTER, READING BIT(1);           
            BUFFER = INPUT;                                                     
            IF LENGTH(BUFFER) = 0 THEN                                          
               DO; /* SIGNAL FOR EOF */                                         
                  CALL ERROR ('EOF MISSING OR COMMENT STARTING IN COLUMN 1.',1);
                  BUFFER = PAD (' /*''/* */ EOF;END;EOF', 80);                  
               END;                                                             
            ELSE CARD_COUNT = CARD_COUNT + 1;  /* USED TO PRINT ON LISTING */   
      IF MARGIN_CHOP > 0 THEN                                                   
         DO; /* THE MARGIN CONTROL FROM DOLLAR | */                             
            I = LENGTH(BUFFER) - MARGIN_CHOP;                                   
            REST = SUBSTR(BUFFER, I);                                           
            BUFFER = SUBSTR(BUFFER, 0, I);                                      
         END;                                                                   
      ELSE REST = '';                                                           
      TEXT = BUFFER;                                                            
      TEXT_LIMIT = LENGTH(TEXT) - 1;                                            
      IF CONTROL(BYTE('M')) THEN OUTPUT = BUFFER;                               
      ELSE IF CONTROL(BYTE('L')) THEN                                           
         OUTPUT = I_FORMAT (CARD_COUNT, 4) || ' |' || BUFFER || '|' || REST;    
      CP = 0;                                                                   
   END GET_CARD;                                                                
                                                                                
                                                                                
   /*                THE SCANNER PROCEDURES              */                     
                                                                                
                                                                                
CHAR:                                                                           
   PROCEDURE;                                                                   
      /* USED FOR STRINGS TO AVOID CARD BOUNDARY PROBLEMS */                    
      CP = CP + 1;                                                              
      IF CP <= TEXT_LIMIT THEN RETURN;                                          
      CALL GET_CARD;                                                            
   END CHAR;                                                                    
                                                                                
                                                                                
SCAN:                                                                           
   PROCEDURE;                                                                   
      DECLARE (S1, S2) FIXED;                                                   
      CALLCOUNT(3) = CALLCOUNT(3) + 1;                                          
      FAILSOFT = TRUE;                                                          
      BCD = '';  NUMBER_VALUE = 0;                                              
   SCAN1:                                                                       
      DO FOREVER;                                                               
         IF CP > TEXT_LIMIT THEN CALL GET_CARD;                                 
         ELSE                                                                   
            DO; /* DISCARD LAST SCANNED VALUE */                                
               TEXT_LIMIT = TEXT_LIMIT - CP;                                    
               TEXT = SUBSTR(TEXT, CP);                                         
               CP = 0;                                                          
            END;                                                                
         /*  BRANCH ON NEXT CHARACTER IN TEXT                  */               
         DO CASE CHARTYPE(BYTE(TEXT));                                          
                                                                                
            /*  CASE 0  */                                                      
                                                                                
            /* ILLEGAL CHARACTERS FALL HERE  */                                 
            CALL ERROR ('ILLEGAL CHARACTER: ' || SUBSTR(TEXT, 0, 1));           
                                                                                
            /*  CASE 1  */                                                      
                                                                                
            /*  BLANK  */                                                       
            DO;                                                                 
               CP = 1;                                                          
               DO WHILE BYTE(TEXT, CP) = BYTE(' ') & CP <= TEXT_LIMIT;          
                  CP = CP + 1;                                                  
               END;                                                             
               CP = CP - 1;                                                     
            END;                                                                
                                                                                
            /*  CASE 2  */                                                      
                                                                                
        ;   /*  NOT USED IN SKELETON (BUT USED IN XCOM)  */                     
                                                                                
            /*  CASE 3  */                                                      
                                                                                
        ;   /*  NOT USED IN SKELETON (BUT USED IN XCOM)  */                     
                                                                                
            /*  CASE 4  */                                                      
                                                                                
            DO FOREVER;  /* A LETTER:  IDENTIFIERS AND RESERVED WORDS */        
               DO CP = CP + 1 TO TEXT_LIMIT;                                    
                  IF NOT_LETTER_OR_DIGIT(BYTE(TEXT, CP)) THEN                   
                     DO;  /* END OF IDENTIFIER  */                              
                        IF CP > 0 THEN BCD = BCD || SUBSTR(TEXT, 0, CP);        
                        S1 = LENGTH(BCD);                                       
                        IF S1 > 1 THEN IF S1 <= RESERVED_LIMIT THEN             
                           /* CHECK FOR RESERVED WORDS */                       
                           DO I = V_INDEX(S1-1) TO V_INDEX(S1) - 1;             
                              IF BCD = V(I) THEN                                
                                 DO;                                            
                                    TOKEN = I;                                  
                                    RETURN;                                     
                                 END;                                           
                           END;                                                 
                        /*  RESERVED WORDS EXIT HIGHER: THEREFORE <IDENTIFIER>*/
                        TOKEN = IDENT;                                          
                        RETURN;                                                 
                     END;                                                       
               END;                                                             
               /*  END OF CARD  */                                              
               BCD = BCD || TEXT;                                               
               CALL GET_CARD;                                                   
               CP = -1;                                                         
            END;                                                                
                                                                                
            /*  CASE 5  */                                                      
                                                                                
            DO;      /*  DIGIT:  A NUMBER  */                                   
               TOKEN = NUMBER;                                                  
               DO FOREVER;                                                      
                  DO CP = CP TO TEXT_LIMIT;                                     
                     S1 = BYTE(TEXT, CP);                                       
                     IF S1 < "F0" THEN RETURN;                                  
                     NUMBER_VALUE = 10*NUMBER_VALUE + S1 - "F0";                
                  END;                                                          
                  CALL GET_CARD;                                                
               END;                                                             
            END;                                                                
                                                                                
            /*  CASE 6  */                                                      
                                                                                
            DO;      /*  A /:  MAY BE DIVIDE OR START OF COMMENT  */            
               CALL CHAR;                                                       
               IF BYTE(TEXT, CP) ~= BYTE('*') THEN                              
                  DO;                                                           
                     TOKEN = DIVIDE;                                            
                     RETURN;                                                    
                  END;                                                          
               /* WE HAVE A COMMENT  */                                         
               S1, S2 = BYTE(' ');                                              
               DO WHILE S1 ~= BYTE('*') | S2 ~= BYTE('/');                      
                  IF S1 = BYTE('$') THEN                                        
                     DO;  /* A CONTROL CHARACTER  */                            
                        CONTROL(S2) = ~ CONTROL(S2);                            
                        IF S2 = BYTE('T') THEN CALL TRACE;                      
                        ELSE IF S2 = BYTE('U') THEN CALL UNTRACE;               
                        ELSE IF S2 = BYTE('|') THEN                             
                           IF CONTROL(S2) THEN                                  
                              MARGIN_CHOP = TEXT_LIMIT - CP + 1;                
                           ELSE                                                 
                              MARGIN_CHOP = 0;                                  
                     END;                                                       
                  S1 = S2;                                                      
                  CALL CHAR;                                                    
                  S2 = BYTE(TEXT, CP);                                          
               END;                                                             
            END;                                                                
                                                                                
            /*  CASE 7  */                                                      
            DO;      /*  SPECIAL CHARACTERS  */                                 
               TOKEN = TX(BYTE(TEXT));                                          
               CP = 1;                                                          
               RETURN;                                                          
            END;                                                                
                                                                                
            /*  CASE 8  */                                                      
        ;   /*  NOT USED IN SKELETON (BUT USED IN XCOM)  */                     
                                                                                
         END;     /* OF CASE ON CHARTYPE  */                                    
         CP = CP + 1;  /* ADVANCE SCANNER AND RESUME SEARCH FOR TOKEN  */       
      END;                                                                      
   END SCAN;                                                                    
                                                                                
                                                                                
                                                                                
                                                                                
  /*                       TIME AND DATE                                 */     
                                                                                
                                                                                
PRINT_TIME:                                                                     
   PROCEDURE (MESSAGE, T);                                                      
      DECLARE MESSAGE CHARACTER, T FIXED;                                       
      MESSAGE = MESSAGE || T/360000 || ':' || T MOD 360000 / 6000 || ':'        
         || T MOD 6000 / 100 || '.';                                            
      T = T MOD 100;  /* DECIMAL FRACTION  */                                   
      IF T < 10 THEN MESSAGE = MESSAGE || '0';                                  
      OUTPUT = MESSAGE || T || '.';                                             
   END PRINT_TIME;                                                              
                                                                                
PRINT_DATE_AND_TIME:                                                            
   PROCEDURE (MESSAGE, D, T);                                                   
      DECLARE MESSAGE CHARACTER, (D, T, YEAR, DAY, M) FIXED;                    
      DECLARE MONTH(11) CHARACTER INITIAL ('JANUARY', 'FEBRUARY', 'MARCH',      
         'APRIL', 'MAY', 'JUNE', 'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER',      
         'NOVEMBER', 'DECEMBER'),                                               
      DAYS(12) FIXED INITIAL (0, 31, 60, 91, 121, 152, 182, 213, 244, 274,      
         305, 335, 366);                                                        
      YEAR = D/1000 + 1900;                                                     
      DAY = D MOD 1000;                                                         
      IF (YEAR & "3") ~= 0 THEN IF DAY > 59 THEN DAY = DAY + 1; /* ~ LEAP YEAR*/
      M = 1;                                                                    
      DO WHILE DAY > DAYS(M);  M = M + 1;  END;                                 
      CALL PRINT_TIME(MESSAGE || MONTH(M-1) || X1 || DAY-DAYS(M-1) ||  ', '     
         || YEAR || '.  CLOCK TIME = ', T);                                     
   END PRINT_DATE_AND_TIME;                                                     
                                                                                
  /*                       INITIALIZATION                                     */
                                                                                
                                                                                
                                                                                
INITIALIZATION:                                                                 
   PROCEDURE;                                                                   
      EJECT_PAGE;                                                               
   CALL PRINT_DATE_AND_TIME ('   SYNTAX CHECK -- STANFORD UNIVERSITY -- SKELETON
 III VERSION OF ', DATE_OF_GENERATION, TIME_OF_GENERATION);                     
      DOUBLE_SPACE;                                                             
      CALL PRINT_DATE_AND_TIME ('TODAY IS ', DATE, TIME);                       
      DOUBLE_SPACE;                                                             
      DO I = 1 TO NT;                                                           
         S = V(I);                                                              
         IF S = '<NUMBER>' THEN NUMBER = I;  ELSE                               
         IF S = '<IDENTIFIER>' THEN IDENT = I;  ELSE                            
         IF S = '/' THEN DIVIDE = I;  ELSE                                      
         IF S = '_|_' THEN EOFILE = I;  ELSE                                    
         IF S = ';' THEN STOPIT(I) = TRUE;  ELSE                                
         ;                                                                      
      END;                                                                      
      IF IDENT = NT THEN RESERVED_LIMIT = LENGTH(V(NT-1));                      
      ELSE RESERVED_LIMIT = LENGTH(V(NT));                                      
      V(EOFILE) = 'EOF';                                                        
      STOPIT(EOFILE) = TRUE;                                                    
      CHARTYPE(BYTE(' ')) = 1;                                                  
      DO I = 0 TO 255;                                                          
         NOT_LETTER_OR_DIGIT(I) = TRUE;                                         
      END;                                                                      
      DO I = 0 TO LENGTH(ALPHABET) - 1;                                         
         J = BYTE(ALPHABET, I);                                                 
         TX(J) = I;                                                             
         NOT_LETTER_OR_DIGIT(J) = FALSE;                                        
         CHARTYPE(J) = 4;                                                       
      END;                                                                      
      DO I = 0 TO 9;                                                            
         J = BYTE('0123456789', I);                                             
         NOT_LETTER_OR_DIGIT(J) = FALSE;                                        
         CHARTYPE(J) = 5;                                                       
      END;                                                                      
      DO I = V_INDEX(0) TO V_INDEX(1) - 1;                                      
         J = BYTE(V(I));                                                        
         TX(J) = I;                                                             
         CHARTYPE(J) = 7;                                                       
      END;                                                                      
      CHARTYPE(BYTE('/')) = 6;                                                  
      /* FIRST SET UP GLOBAL VARIABLES CONTROLLING SCAN, THEN CALL IT */        
      CP = 0;  TEXT_LIMIT = -1;                                                 
      TEXT = '';                                                                
      CONTROL(BYTE('L')) = TRUE;                                                
      CALL SCAN;                                                                
                                                                                
      /* INITIALIZE THE PARSE STACK */                                          
      SP = 1;  PARSE_STACK(SP) = EOFILE;                                        
                                                                                
   END INITIALIZATION;                                                          
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
DUMPIT:                                                                         
   PROCEDURE;    /* DUMP OUT THE STATISTICS COLLECTED DURING THIS RUN  */       
      DOUBLE_SPACE;                                                             
      /*  PUT OUT THE ENTRY COUNT FOR IMPORTANT PROCEDURES */                   
                                                                                
      OUTPUT = 'STACKING DECISIONS= ' || CALLCOUNT(1);                          
      OUTPUT = 'SCAN              = ' || CALLCOUNT(3);                          
      OUTPUT = 'FREE STRING AREA  = ' || FREELIMIT - FREEBASE;                  
   END DUMPIT;                                                                  
                                                                                
                                                                                
STACK_DUMP:                                                                     
   PROCEDURE;                                                                   
      DECLARE LINE CHARACTER;                                                   
      LINE = 'PARTIAL PARSE TO THIS POINT IS: ';                                
      DO I = 2 TO SP;                                                           
         IF LENGTH(LINE) > 105 THEN                                             
            DO;                                                                 
               OUTPUT = LINE;                                                   
               LINE = X4;                                                       
            END;                                                                
         LINE = LINE || X1 || V(PARSE_STACK(I));                                
      END;                                                                      
      OUTPUT = LINE;                                                            
   END STACK_DUMP;                                                              
                                                                                
                                                                                
  /*                  THE SYNTHESIS ALGORITHM FOR XPL                      */   
                                                                                
                                                                                
SYNTHESIZE:                                                                     
PROCEDURE(PRODUCTION_NUMBER);                                                   
   DECLARE PRODUCTION_NUMBER FIXED;                                             
                                                                                
   /*  THIS PROCEDURE IS RESPONSIBLE FOR THE SEMANTICS (CODE SYNTHESIS), IF     
      ANY, OF THE SKELETON COMPILER.  ITS ARGUMENT IS THE NUMBER OF THE         
      PRODUCTION WHICH WILL BE APPLIED IN THE PENDING REDUCTION.  THE GLOBAL    
      VARIABLES MP AND SP POINT TO THE BOUNDS IN THE STACKS OF THE RIGHT PART   
      OF THIS PRODUCTION.                                                       
       NORMALLY, THIS PROCEDURE WILL TAKE THE FORM OF A GIANT CASE STATEMENT    
      ON PRODUCTION_NUMBER.  HOWEVER, THE SYNTAX CHECKER HAS SEMANTICS (THE     
      TERMINATION OF CHECKING) ONLY FOR PRODUCTION 1.                     */    
                                                                                
   IF PRODUCTION_NUMBER = 1 THEN                                                
                                                                                
 /*  <PROGRAM>  ::=  <STATEMENT LIST>    */                                     
   DO;                                                                          
      IF MP ~= 2 THEN  /* WE DIDN'T GET HERE LEGITIMATELY  */                   
         DO;                                                                    
            CALL ERROR ('EOF AT INVALID POINT', 1);                             
            CALL STACK_DUMP;                                                    
         END;                                                                   
      COMPILING = FALSE;                                                        
   END;                                                                         
END SYNTHESIZE;                                                                 
                                                                                
                                                                                
                                                                                
                                                                                
  /*              SYNTACTIC PARSING FUNCTIONS                              */   
                                                                                
                                                                                
RIGHT_CONFLICT:                                                                 
   PROCEDURE (LEFT) BIT(1);                                                     
      DECLARE LEFT FIXED;                                                       
      /*  THIS PROCEDURE IS TRUE IF TOKEN IS ~ A LEGAL RIGHT CONTEXT OF LEFT*/  
      RETURN ("C0" & SHL(BYTE(C1(LEFT), SHR(TOKEN,2)), SHL(TOKEN,1)             
         & "06")) = 0;                                                          
   END RIGHT_CONFLICT;                                                          
                                                                                
                                                                                
RECOVER:                                                                        
   PROCEDURE;                                                                   
      /* IF THIS IS THE SECOND SUCCESSIVE CALL TO RECOVER, DISCARD ONE SYMBOL */
      IF ~ FAILSOFT THEN CALL SCAN;                                             
      FAILSOFT = FALSE;                                                         
      DO WHILE ~ STOPIT(TOKEN);                                                 
         CALL SCAN;  /* TO FIND SOMETHING SOLID IN THE TEXT  */                 
      END;                                                                      
      DO WHILE RIGHT_CONFLICT (PARSE_STACK(SP));                                
         IF SP > 2 THEN SP = SP - 1;  /* AND IN THE STACK  */                   
         ELSE CALL SCAN;  /* BUT DON'T GO TOO FAR  */                           
      END;                                                                      
      OUTPUT = 'RESUME:' || SUBSTR(POINTER, TEXT_LIMIT-CP+MARGIN_CHOP+7);       
   END RECOVER;                                                                 
                                                                                
STACKING:                                                                       
   PROCEDURE BIT(1);  /* STACKING DECISION FUNCTION */                          
      CALLCOUNT(1) = CALLCOUNT(1) + 1;                                          
      DO FOREVER;    /* UNTIL RETURN  */                                        
         DO CASE SHR(BYTE(C1(PARSE_STACK(SP)),SHR(TOKEN,2)),SHL(3-TOKEN,1)&6)&3;
                                                                                
            /*  CASE 0  */                                                      
            DO;    /* ILLEGAL SYMBOL PAIR  */                                   
               CALL ERROR('ILLEGAL SYMBOL PAIR: ' || V(PARSE_STACK(SP)) || X1 ||
                  V(TOKEN), 1);                                                 
               CALL STACK_DUMP;                                                 
               CALL RECOVER;                                                    
            END;                                                                
                                                                                
            /*  CASE 1  */                                                      
                                                                                
            RETURN TRUE;      /*  STACK TOKEN  */                               
                                                                                
            /*  CASE 2  */                                                      
                                                                                
            RETURN FALSE;     /* DON'T STACK IT YET  */                         
                                                                                
            /*  CASE 3  */                                                      
                                                                                
            DO;      /* MUST CHECK TRIPLES  */                                  
               J = SHL(PARSE_STACK(SP-1), 16) + SHL(PARSE_STACK(SP), 8) + TOKEN;
               I = -1;  K = NC1TRIPLES + 1;  /* BINARY SEARCH OF TRIPLES  */    
               DO WHILE I + 1 < K;                                              
                  L = SHR(I+K, 1);                                              
                  IF C1TRIPLES(L) > J THEN K = L;                               
                  ELSE IF C1TRIPLES(L) < J THEN I = L;                          
                  ELSE RETURN TRUE;  /* IT IS A VALID TRIPLE  */                
               END;                                                             
               RETURN FALSE;                                                    
            END;                                                                
                                                                                
         END;    /* OF DO CASE  */                                              
      END;   /*  OF DO FOREVER */                                               
   END STACKING;                                                                
                                                                                
PR_OK:                                                                          
   PROCEDURE(PRD) BIT(1);                                                       
      /* DECISION PROCEDURE FOR CONTEXT CHECK OF EQUAL OR IMBEDDED RIGHT PARTS*/
      DECLARE (H, I, J, PRD) FIXED;                                             
      DO CASE CONTEXT_CASE(PRD);                                                
                                                                                
         /*  CASE 0 -- NO CHECK REQUIRED  */                                    
                                                                                
         RETURN TRUE;                                                           
                                                                                
         /*  CASE 1 -- RIGHT CONTEXT CHECK  */                                  
                                                                                
         RETURN ~ RIGHT_CONFLICT (HDTB(PRD));                                   
                                                                                
         /*  CASE 2 -- LEFT CONTEXT CHECK  */                                   
                                                                                
         DO;                                                                    
            H = HDTB(PRD) - NT;                                                 
            I = PARSE_STACK(SP - PRLENGTH(PRD));                                
            DO J = LEFT_INDEX(H-1) TO LEFT_INDEX(H) - 1;                        
               IF LEFT_CONTEXT(J) = I THEN RETURN TRUE;                         
            END;                                                                
            RETURN FALSE;                                                       
         END;                                                                   
                                                                                
         /*  CASE 3 -- CHECK TRIPLES  */                                        
                                                                                
         DO;                                                                    
            H = HDTB(PRD) - NT;                                                 
            I = SHL(PARSE_STACK(SP - PRLENGTH(PRD)), 8) + TOKEN;                
            DO J = TRIPLE_INDEX(H-1) TO TRIPLE_INDEX(H) - 1;                    
               IF CONTEXT_TRIPLE(J) = I THEN RETURN TRUE;                       
            END;                                                                
            RETURN FALSE;                                                       
         END;                                                                   
                                                                                
      END;  /* OF DO CASE  */                                                   
   END PR_OK;                                                                   
                                                                                
                                                                                
  /*                     ANALYSIS ALGORITHM                                  */ 
                                                                                
                                                                                
                                                                                
REDUCE:                                                                         
   PROCEDURE;                                                                   
      DECLARE (I, J, PRD) FIXED;                                                
      /* PACK STACK TOP INTO ONE WORD */                                        
      DO I = SP - 4 TO SP - 1;                                                  
         J = SHL(J, 8) + PARSE_STACK(I);                                        
      END;                                                                      
                                                                                
      DO PRD = PR_INDEX(PARSE_STACK(SP)-1) TO PR_INDEX(PARSE_STACK(SP)) - 1;    
         IF (PRMASK(PRLENGTH(PRD)) & J) = PRTB(PRD) THEN                        
            IF PR_OK(PRD) THEN                                                  
            DO;  /* AN ALLOWED REDUCTION */                                     
               MP = SP - PRLENGTH(PRD) + 1; MPP1 = MP + 1;                      
               CALL SYNTHESIZE(PRDTB(PRD));                                     
               SP = MP;                                                         
               PARSE_STACK(SP) = HDTB(PRD);                                     
               RETURN;                                                          
            END;                                                                
      END;                                                                      
                                                                                
      /* LOOK UP HAS FAILED, ERROR CONDITION */                                 
      CALL ERROR('NO PRODUCTION IS APPLICABLE',1);                              
      CALL STACK_DUMP;                                                          
      FAILSOFT = FALSE;                                                         
      CALL RECOVER;                                                             
   END REDUCE;                                                                  
                                                                                
COMPILATION_LOOP:                                                               
   PROCEDURE;                                                                   
                                                                                
      COMPILING = TRUE;                                                         
      DO WHILE COMPILING;     /* ONCE AROUND FOR EACH PRODUCTION (REDUCTION)  */
         DO WHILE STACKING;                                                     
            SP = SP + 1;                                                        
            IF SP = STACKSIZE THEN                                              
               DO;                                                              
                  CALL ERROR ('STACK OVERFLOW *** CHECKING ABORTED ***', 2);    
                  RETURN;   /* THUS ABORTING CHECKING */                        
               END;                                                             
            PARSE_STACK(SP) = TOKEN;                                            
            VAR(SP) = BCD;                                                      
            FIXV(SP) = NUMBER_VALUE;                                            
            CALL SCAN;                                                          
         END;                                                                   
                                                                                
         CALL REDUCE;                                                           
      END;     /* OF DO WHILE COMPILING  */                                     
   END COMPILATION_LOOP;                                                        
                                                                                
                                                                                
                                                                                
                                                                                
PRINT_SUMMARY:                                                                  
   PROCEDURE;                                                                   
      DECLARE I FIXED;                                                          
      CALL PRINT_DATE_AND_TIME ('END OF CHECKING ', DATE, TIME);                
      OUTPUT = '';                                                              
      OUTPUT = CARD_COUNT || ' CARDS WERE CHECKED.';                            
      IF ERROR_COUNT = 0 THEN OUTPUT = 'NO ERRORS WERE DETECTED.';              
      ELSE IF ERROR_COUNT > 1 THEN                                              
         OUTPUT = ERROR_COUNT || ' ERRORS (' || SEVERE_ERRORS                   
            || ' SEVERE) WERE DETECTED.';                                       
      ELSE IF SEVERE_ERRORS = 1 THEN OUTPUT = 'ONE SEVERE ERROR WAS DETECTED.'; 
         ELSE OUTPUT = 'ONE ERROR WAS DETECTED.';                               
      IF PREVIOUS_ERROR > 0 THEN                                                
         OUTPUT = 'THE LAST DETECTED ERROR WAS ON LINE ' || PREVIOUS_ERROR      
            || PERIOD;                                                          
      IF CONTROL(BYTE('D')) THEN CALL DUMPIT;                                   
      DOUBLE_SPACE;                                                             
      CLOCK(3) = TIME;                                                          
      DO I = 1 TO 3;   /* WATCH OUT FOR MIDNIGHT */                             
         IF CLOCK(I) < CLOCK(I-1) THEN CLOCK(I) = CLOCK(I) +  8640000;          
      END;                                                                      
      CALL PRINT_TIME ('TOTAL TIME IN CHECKER    ', CLOCK(3) - CLOCK(0));       
      CALL PRINT_TIME ('SET UP TIME              ', CLOCK(1) - CLOCK(0));       
      CALL PRINT_TIME ('ACTUAL CHECKING TIME     ', CLOCK(2) - CLOCK(1));       
      CALL PRINT_TIME ('CLEAN-UP TIME AT END     ', CLOCK(3) - CLOCK(2));       
      IF CLOCK(2) > CLOCK(1) THEN   /* WATCH OUT FOR CLOCK BEING OFF */         
      OUTPUT = 'CHECKING RATE: ' || 6000*CARD_COUNT/(CLOCK(2)-CLOCK(1))         
         || ' CARDS PER MINUTE.';                                               
   END PRINT_SUMMARY;                                                           
                                                                                
MAIN_PROCEDURE:                                                                 
   PROCEDURE;                                                                   
      CLOCK(0) = TIME;  /* KEEP TRACK OF TIME IN EXECUTION */                   
      CALL INITIALIZATION;                                                      
                                                                                
      CLOCK(1) = TIME;                                                          
                                                                                
      CALL COMPILATION_LOOP;                                                    
                                                                                
      CLOCK(2) = TIME;                                                          
                                                                                
      /* CLOCK(3) GETS SET IN PRINT_SUMMARY */                                  
      CALL PRINT_SUMMARY;                                                       
                                                                                
   END MAIN_PROCEDURE;                                                          
                                                                                
                                                                                
CALL MAIN_PROCEDURE;                                                            
RETURN SEVERE_ERRORS;                                                           

