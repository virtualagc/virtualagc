#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   INITIALI.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-08-25 RSB  Began porting from INITIALI.xpl.
'''

from g import * # Get global variables.
from CHARTIME import CHARTIME
from CHARDATE import CHARDATE
from PRINTDAT import PRINT_DATE_AND_TIME
from ERRORS import ERRORS
from GETSUBSE import GET_SUBSET
from UNSPEC import UNSPEC
from SETTLIMI import SET_T_LIMIT
from ORDEROK import ORDER_OK
from SOURCECO import SOURCE_COMPARE
from STREAM import STREAM
from SCAN import SCAN
from SRNUPDAT import SRN_UPDATE
from HALINCL.CERRDECL import CLASS_BI
#from HALINCL.SPACELIB import RECORD_USED

'''
*************************************************************************
 PROCEDURE NAME:  INITIALIZATION                                         
 MEMBER NAME:     INITIALI                                               
 LOCAL DECLARATIONS:                                                     
       AGAIN(4)          LABEL              PRO               FIXED      
       CON               FIXED              SORT1       ARRAY BIT(16)    
       ENDMFID           LABEL              SORT2       ARRAY BIT(16)    
       EQUALS            CHARACTER          STORAGE_INCREMENT FIXED      
       LOGHEAD           CHARACTER          STORAGE_MASK      FIXED      
       NO_CORE           LABEL              SUBHEAD           CHARACTER  
       NPVALS            FIXED              TYPE2             FIXED      
       NUM1_OPT          BIT(16)            TYPE2_TYPE(12)    BIT(8)     
       NUM2_OPT          BIT(16)            VALS              FIXED      
 EXTERNAL VARIABLES REFERENCED:                                          
       ATOM#_LIM                            LIT_NDX                      
       ATOMS                                LIT_PG                       
       BLOCK_SRN_DATA                       MACRO_TEXTS                  
       CLASS_B                              MODF                         
       CLASS_BI                             MOVEABLE                     
       CLASS_M                              NSY                          
       CONST_ATOMS                          NT                           
       CONST_DW                             NUM_DWNS                     
       CONTROL                              OPTIONS_CODE                 
       CROSS_REF                            OUTER_REF_TABLE              
       CSECT_LENGTHS                        PAGE                         
       DATE_OF_COMPILATION                  SRN_BLOCK_RECORD             
       DOUBLE                               STMT_NUM                     
       DOUBLE_SPACE                         SUBHEADING                   
       DOWN_INFO                            SYM_TAB                      
       DW_AD                                TIME_OF_COMPILATION          
       DW                                   TOKEN                        
       EJECT_PAGE                           TRUE                         
       FALSE                                UNMOVEABLE                   
       FL_NO                                VMEM_MAX_PAGE                
       IC_SIZE                              VMEMREC                      
       INCLUDE_LIST_HEAD                    VOCAB                        
       INPUT_DEV                            X1                           
       LINK_SORT                            X4                           
       LIT_BUF_SIZE                         X70                          
       LIT_CHAR_AD                          X8                           
 EXTERNAL VARIABLES CHANGED:                                             
       ADDR_FIXED_LIMIT                     LRECL                        
       ADDR_FIXER                           MACRO_TEXT_LIM               
       ADDR_PRESENT                         NEXT                         
       ADDR_ROUNDER                         NEXT_ATOM#                   
       C                                    NT_PLUS_1                    
       CARD_COUNT                           ONE_BYTE                     
       CARD_TYPE                            OUTER_REF_LIM                
       CASE_LEVEL                           PAD1                         
       COMM                                 PAD2                         
       COMMENT_COUNT                        PARTIAL_PARSE                
       CUR_IC_BLK                           PROCMARK                     
       CURRENT_CARD                         S                            
       DATA_REMOTE                          SAVE_CARD                    
       FIRST_CARD                           SDL_OPTION                   
       FOR_ATOMS                            SIMULATING                   
       FOR_DW                               SP                           
       HMAT_OPT                             SREF_OPTION                  
       I                                    SRN_PRESENT                  
       IC_LIM                               STACK_DUMP_PTR               
       IC_MAX                               STATE                        
       IC_ORG                               STMT_PTR                     
       INDENT_INCR                          SYSIN_COMPRESSED             
       INPUT_REC                            SYTSIZE                      
       J                                    TABLE_ADDR                   
       K                                    TEMP1                        
       LAST                                 TEXT_LIMIT                   
       LAST_SPACE                           TPL_FLAG                     
       LINE_LIM                             TPL_LRECL                    
       LINE_MAX                             VMEM_PAD_ADDR                
       LISTING2_COUNT                       VMEM_PAD_PAGE                
       LISTING2                             VOCAB_INDEX                  
       LIT_CHAR_SIZE                        XREF_LIM                     
 EXTERNAL PROCEDURES CALLED:                                             
       CHARDATE                             ORDER_OK                     
       CHARTIME                             PAD                          
       EMIT_ARRAYNESS                       PRINT_DATE_AND_TIME          
       ERRORS                               SCAN                         
       ERROR                                SET_T_LIMIT                  
       GET_CELL                             SOURCE_COMPARE               
       GET_SUBSET                           SRN_UPDATE                   
       LEFT_PAD                             STREAM                       
       MIN                                  UNSPEC                       
       NEXT_RECORD                          VMEM_INIT                    
'''

#           INITIALIZATION         

def INITIALIZATION():
    global FREELIMIT, DATA_REMOTE, LISTING2, SREF_OPTION, PARTIAL_PARSE, \
            LISTING2_COUNT, LINE_MAX, LINE_LIM, SIMULATING, TPL_FLAG, \
            SRN_PRESENT, SDL_OPTION, SRN_PRESENT, ADDR_PRESENT, PAD1, PAD2, \
            HMAT_OPT, INDENT_INCR, CASE_LEVEL, CARD_COUNT, COMMENT_COUNT, \
            LAST, NEXT, STMT_PTR, STACK_DUMP_PTR, LAST_SPACE, ONE_BYTE, \
            PROCMARK, NT_PLUS_1, IC_ORG, IC_MAX, CUR_IC_BLK, IC_LIM, SYTSIZE, \
            MACRO_TEXT_LIM, LIT_CHAR_SIZE, XREF_LIM, OUTER_REF_LIM, TEMP1, \
            NEXT_ATOMp, CARD_TYPE, VOCAB_INDEX, CURRENT_CARD, LRECL, \
            TEXT_LIMIT, FIRST_CARD, SYSIN_COMPRESSED, INPUT_REC, SAVE_CARD, \
            STATE, SP, C, S, I, J, K, RECORD_USED

    SUBHEAD = 'STMT                                   ' + \
              '               SOURCE                                                  CURRENT S' + \
              'COPE'
    
    EQUALS = ' = '
    TYPE2_TYPE = (
        0,  # TITLE 
        1,  # LINECT 
        1,  # PAGES 
        1,  # SYMBOLS 
        1,  # MACROSIZE 
        1,  # LITSTRINGS 
        1,  # COMPUNIT 
        1,  # XREFSIZE 
        0,  # CARDTYPE 
        1,  # LABELSIZE 
        1,  # DSR 
        1,  # BLOCKSUM 
        0 ) # MFID FOR PASS; OLDTPL FOR BFS 
    
    STORAGE_INCREMENT = 0
    STORAGE_MASK = 0
    LOGHEAD ='STMT                                      ' + \
             '                            SOURCE                                              ' + \
             '                    REVISION'
    TMP = 0
    if pfs:
        NUM1_OPT = 19
        SORT1 = (8,5,0,13,19,2,1,15,17,14,10,16,9,11,6,7,18,3,4,12)
    else:
        NUM1_OPT = 20
        SORT1 = (8,5,0,13,20,2,1,15,17,18,14,10,16,9,11,6,7,19,3,4,12)
    NUM2_OPT = 12
    SORT2 = (11,8,6,10,9,1,5,4,12,2,3,0,7)
    
    # INITIALIZE DATA_REMOTE FLAG                                   
    DATA_REMOTE=FALSE;
    #---------------------------------------------------------------
    STORAGE_INCREMENT = MONITOR(32);
    STORAGE_MASK = -STORAGE_INCREMENT & 0xFFFFFF
    '''
    The following code relates to determining and printing out the compiler
    options which have been supplied originally by JCL, but for us by 
    command-line options.  The available options are described by the "HAL/S-FC
    User's Manual" (chapter 5), while the organization of these in IBM 
    System/360 system memory (as we would need it to work with the following
    code) is described in the "HAL/S-FC and HAL/S-360 Compiler System Program 
    Description" (IR-182-1) around p. 696. In neither sources is there an 
    explanation of how the options specifically relate to the bit-flags in
    the 32-bit variable OPTIONS_WORD, so whatever I know about that has been
    gleaned from looking at how the source code processes that word.
        Flag          Pass         Keyword (abbreviation)
        ----          ----         ----------------------
        0x40000000    1            REGOPT (R) for BFS
        0x10000000    3            DEBUG
        0x08000000    3            DLIST
        0x04000000    1            MICROCODE (MC)
        0x02000000    1            REGOPT (R) for PFS
        0x01000000    ?            STATISTICS
        0x00800000    1            SDL (NONE)
        0x00400000    4            DECK (D)
        0x00200000    1            LFXI (NONE)
        0x00100000    1            ADDRS (A)
        0x00080000    1            SRN (NONE)
        0x00040000    1            HALMAT (HM)
        0x00020000    1            CODE_LISTING_REQUESTED
        0x00010000    1            PARTIAL_PARSE
        0x00008000    3,4          SDF_SUMMARY, TABLST (TL)
        0x00004000    1            EXTRA_LISTING
        0x00002000    1            SREF (SR)
        0x00001000    3,4          TABDMP (TBD)
        0x00000800    1            SIMULATING
        0x00000400    1            Z_LINKAGE ... perhaps ZCON (Z)
        0x00000200    ?            TRACE
        0x00000080    3            HIGHOPT (HO)
        0x00000040    1,2,4        NO_VM_OPT, ?, BRIEF
        0x00000020    4            ALL
        0x00000010    1            TEMPLATE (TP)
        0x00000008    2,3          TRACE
        0x00000004    1            LIST (L)
        0x00000002    1            LISTING2 (L2)
        ?                          DUMP (DP)
        ?                          LSTALL (LA)
        ?                          PARSE (P)
        ?                          SCAL (SC) for BFS only
        ?                          TABLES (TBL)
        ?                          VARSYM (VS)
    '''
    
    OPTIONS_CODE(pOPTIONS_CODE)
    CON = pCON
    PRO = pPRO
    TYPE2 = pDESC
    VALS = pVALS
    NPVALS = []
    
    C[0] = VALS[TYPE2.index("TITLE")]
    if LENGTH(C[0]) == 0:
        C[0] = 'T H E  V I R T U A L  A G C  P R O J E C T'
    J = LENGTH(C[0])
    J = ((61 - J) // 2) + J
    C[0] = LEFT_PAD(C[0], J)
    C[0] = PAD(C[0], 61)  # C CONTAINS CENTERED TITLE 
    TIME_OF_COMPILATION(TIME())
    S = CHARTIME(TIME_OF_COMPILATION())
    DATE_OF_COMPILATION(DATE())
    S = CHARDATE(DATE_OF_COMPILATION()) + X4 + S
    OUTPUT(1, 'H  HAL/S ' + STRING(MONITOR(23)) + C[0] + X4 + S)
    PRINT_DATE_AND_TIME('   HAL/S COMPILER PHASE 1 -- VERSION' + \
                        ' OF ', DATE_OF_GENERATION, TIME_OF_GENERATION)
    DOUBLE_SPACE()
    PRINT_DATE_AND_TIME ('TODAY IS ', DATE(), TIME())
    OUTPUT(0, X1)
    
    C[0] = PARM_FIELD
    I = 0
    S = ' PARM FIELD: '
    K = LENGTH(C[0])
    while I < K:
        J = MIN(K - I, 119)  # DON'T EXCEED LINE WIDTH OF PRINTER 
        OUTPUT(0, S + SUBSTR(C[0], I, J))  # PRINT ALL OR PART 
        I = I + J
        S = SUBSTR(X70, 0, LENGTH(S))
    DOUBLE_SPACE()
    OUTPUT(0, ' COMPLETE LIST OF COMPILE-TIME OPTIONS IN EFFECT')
    DOUBLE_SPACE()
    OUTPUT(0, '       *** TYPE 1 OPTIONS ***')
    OUTPUT(0, X1)
    #PRINT THE TYPE 1 OPTIONS USING THE ORDER IN SORT1 ARRAY.
    #SINCE QUASI & TRACE ARE 360 ONLY, DO NOT PRINT.  PRINT LFXI HERE  
    #EVEN THOUGH IT IS DEFINED AS A "NONPRINTABLE" OPTION IN COMPOPT.  
    for I in range(0, NUM1_OPT + 1):
        #MAKE SURE NOT QUASI OR TRACE
        if (SORT1[I] != 17) & (SORT1[I] != 3):
            if SORT1[I] == 2:  #PRINT LFXI HERE
                if (OPTIONS_CODE() & 0x00200000) != 0 :
                    OUTPUT(0, X8 + '  LFXI')
                else:
                    OUTPUT(0, X8 + 'NOLFXI')
            if SUBSTR(STRING(CON[SORT1[I]]),0,2) == 'NO':
                OUTPUT(0, X8 + STRING(CON[SORT1[I]]))
            else:
                OUTPUT(0, X8 + '  ' + STRING(CON[SORT1[I]]))
    DOUBLE_SPACE()
    OUTPUT(0, '       *** TYPE 2 OPTIONS ***')
    OUTPUT(0, X1)
    I = 0
    
    #********************************************
    # THE FOLLOWING BLOCKS OF CODE WERE EXCLUDED 
    # DUE TO COMPILER FEATURE DIFFERENCES. PASS  
    # SYSTEM IMPLEMENTS MFID OPTION. BFS SYSTEM  
    # IMPLEMENTS OLDTPL OPTION.                  
    #********************************************
    # PRINT THE TYPE 2 OPTIONS USING THE ORDER IN SORT2 ARRAY
    if pfs:
        for I in range(0, NUM2_OPT + 1):
            C[0] = LEFT_PAD(STRING(TYPE2[SORT2[I]]), 15);
            if TYPE2_TYPE[SORT2[I]]:
                S = VALS[SORT2[I]]; # DECIMAL VALUE
            else:
                S = STRING(VALS[SORT2[I]]); # DESCRIPTOR
            if STRING(TYPE2[SORT2[I]]) == 'MFID':
                OUTPUT(0, C[0] + EQUALS + S);
                if LENGTH(S) > 0:
                    VALS[SORT2[I]]=0;
                    for J in range(0, LENGTH(S)):
                        if BYTE(S,J) < BYTE('0') or BYTE(S,J) > BYTE('9'):
                            ERRORS (CLASS_BI, 103, X1 + S);
                            VALS[SORT2[I]]=0;
                            break
                        else:
                            VALS[SORT2[I]]=VALS[SORT2[I]]*10;
                            # FOLLOWING TO AVOID 'USED ALL ACCUMULATORS'
                            TMP = VALS[SORT2[I]];
                            VALS[SORT2[I]]=TMP+(BYTE(S,J) & 0x0F);
            else:
                OUTPUT(0, C[0] + EQUALS + str(S));
    else:
        #***********************************
        # MFID'S ARE NOT IMPLEMENTED IN BFS 
        #***********************************
        for I in range(0, NUM2_OPT + 1):
            C[0] = LEFT_PAD(STRING(TYPE2[SORT2[I]]), 15);
            if TYPE2_TYPE[SORT2[I]]:
                S = VALS[SORT2[I]];  # DECIMAL VALUE
            else:
                S = STRING(VALS[SORT2[I]]);  # DESCRIPTER
            if SORT2[I] != 12: 
                OUTPUT(0, C[0] + EQUALS + S);
    LISTING2 = (OPTIONS_CODE() & 0x02) != 0;
    SREF_OPTION = (OPTIONS_CODE() & 0x2000) != 0;
    PARTIAL_PARSE = (OPTIONS_CODE() & 0x010000) != 0;
    LISTING2_COUNT = VALS[1]
    LINE_MAX = VALS[1]
    LINE_LIM = VALS[1];
    SIMULATING=(OPTIONS_CODE()&0x800)!=0;
    if (OPTIONS_CODE()&0x10) == 0x10:
        TPL_FLAG=0;
    SRN_PRESENT = (OPTIONS_CODE() & 0x80000) != 0;
    SDL_OPTION = (OPTIONS_CODE() & 0x800000) != 0;
    if SDL_OPTION:
        SRN_PRESENT = TRUE;
    ADDR_PRESENT = (OPTIONS_CODE() & 0x100000) != 0;
    if SRN_PRESENT:
        PAD1 = SUBSTR(X70, 0, 11);
        PAD2 = SUBSTR(X70, 0, 15);
        C[0] = '   SRN ';
    else:
        PAD1 = X4;
        PAD2 = X8;
        C[0] = '';
    if (OPTIONS_CODE() & 0x00040000) != 0:
        HMAT_OPT = TRUE;
    OUTPUT(0, X1);
    if GET_SUBSET('$$SUBSET',0x1):
        OUTPUT(1, '0 *** NO LANGUAGE SUBSET IN EFFECT ***');
    OUTPUT(1, SUBHEADING+C[0]+LOGHEAD);
    EJECT_PAGE();
    OUTPUT(1, SUBHEADING + C[0] + SUBHEAD);
    INDENT_INCR = 2; 
    CASE_LEVEL = -1;
    CARD_COUNT = -1;
    INCLUDE_LIST_HEAD(-1);
    COMMENT_COUNT = -1;
    LAST = -1;
    NEXT = -1;
    STMT_PTR = -1;
    STACK_DUMP_PTR = -1;
    LAST_SPACE = 2;
    ONE_BYTE = '?';
    STMT_NUM(1);
    PROCMARK = 1;
    FL_NO = 1;
    NT_PLUS_1 = NT + 1;
    IC_ORG = 0;
    IC_MAX = 0;
    CUR_IC_BLK = 0;
    IC_LIM = IC_SIZE;  # UPPER LIMIT OF TABLE  
    MONITOR(4, 3, IC_SIZE*8);
    SYTSIZE = VALS[3];
    MACRO_TEXT_LIM = VALS[4];
    LIT_CHAR_SIZE = VALS[5];
    XREF_LIM = VALS[7];
    OUTER_REF_LIM = VALS[11];
    J = (FREELIMIT + 512) & STORAGE_MASK;  # BOUNDARY NEAR TOP OF CORE 
    TEMP1=(J-(13000+2*1680+3*3458))&STORAGE_MASK;#TO ALLOW ROOM FOR BUFFERS
    if TEMP1 - 512 <= FREEPOINT:
        COMPACTIFY();
    #MONITOR(7, ADDR(TEMP1), J - TEMP1);
    FREELIMIT = TEMP1 - 512;
    # INITIALIZE VMEM PAGING AND ALLOCATE SPACE FOR IN-CORE PAGES
    '''
    ... lots of stuff just deleted here that I hope pertains to
        (unnecessary now) virtual memory ...
    '''
    CARD_TYPE[BYTE('E')] = 1;
    CARD_TYPE[BYTE('M')] = 2;
    CARD_TYPE[BYTE('S')] = 3;
    CARD_TYPE[BYTE('C')] = 4;
    CARD_TYPE[BYTE('D')] = 5;
    CARD_TYPE[BYTE(X1)] = 2;
    C[0] = STRING(VALS[8]);  # PICK UP STRING (IF ANY) 
    if LENGTH(C[0]) > 0: 
        for I in range(0, LENGTH(C[0]) - 1, 2):
            J = BYTE(C[0], I);
            K = BYTE(C[0], I + 1);
            if CARD_TYPE[J] == 0:
                CARD_TYPE[J] = CARD_TYPE[K];
    for I in range(1, NSY+1):
        K = VOCAB_INDEX[I];
        J = K & 0xFF;
        C[0] = SUBSTR(VOCAB[J], SHR(K, 8) & 0xFFFF, SHR(K, 24));
        VOCAB_INDEX[I] = UNSPEC(C[0]);
    CURRENT_CARD=INPUT(INPUT_DEV);
    print("IN A", INPUT_DEV, CURRENT_CARD)
    LRECL=LENGTH(CURRENT_CARD)-1;
    TEXT_LIMIT[0]=SET_T_LIMIT(LRECL);
    print("IN A", INPUT_DEV, LRECL, TEXT_LIMIT[0], BYTE(CURRENT_CARD), '"%s"' % CURRENT_CARD)
    FIRST_CARD=TRUE;
    if not pfs: # BFS
        TEXT_LIMIT[1] = TEXT_LIMIT[0];
    if BYTE(CURRENT_CARD) == 0x00:
        # COMPRESSED SOURCE 
        SYSIN_COMPRESSED = TRUE;
        INPUT_REC = CURRENT_CARD;
        NEXT_RECORD();  # GET FIRST REAL RECORD 
    while not ORDER_OK(BYTE('C')):
        print("IN B")
        ERROR(CLASS_M, 2);
        NEXT_RECORD();
    if LENGTH(CURRENT_CARD) > 88:
        CURRENT_CARD = SUBSTR(CURRENT_CARD, 0, 88);
    CARD_COUNT = CARD_COUNT + 1;
    SAVE_CARD = CURRENT_CARD;
    SOURCE_COMPARE();
    STREAM();
    SCAN();
    if CONTROL[4]:
        OUTPUT(0, 'SCANNER: ' + TOKEN);
    SRN_UPDATE();
    # INITIALIZE THE PARSE STACK 
    STATE = 1;   # START-STATE  
    SP = 0xFFFFFFFF;
    return;
