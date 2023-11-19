#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   PRINTSUM.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-11-17 RSB  Began porting from XPL.
"""

from xplBuiltins      import *
from HALINCL.SPACELIB import *
import g
from ERRORS import ERRORS
from FORMAT import FORMAT

#*************************************************************************
# PROCEDURE NAME:  PRINTSUMMARY
# MEMBER NAME:     PRINTSUM
# LOCAL DECLARATIONS:
#          STACK_DUMP        LABEL
#          FORM_UP           CHARACTER
#          SYT_DUMP          LABEL
#          T                 FIXED
#          TEMPLATE_DUMP     LABEL
# EXTERNAL VARIABLES REFERENCED:
#          BLANK
#          CLASS_BI
#          CODE_LISTING_REQUESTED
#          ERROR#
#          EXTENT
#          FOR
#          FULLTEMP
#          LIT_CHAR_SIZE
#          LIT_CHAR_USED
#          MAXTEMP
#          NAME_FLAG
#          OBJECT_INSTRUCTIONS
#          OBJECT_MACHINE
#          OPCOUNT
#          OPMAX
#          PP
#          PROC_LEVEL
#          PROCLIMIT
#          PROGCODE
#          PROGDATA
#          PROGPOINT
#          P2SYMS
#          SREF
#          STACK_MAX
#          STACK_SIZE
#          STATNOLIMIT
#          STATNO
#          STRUCT_START
#          SYM_ADDR
#          SYM_BASE
#          SYM_DISP
#          SYM_FLAGS
#          SYM_LEVEL
#          SYM_LINK1
#          SYM_LINK2
#          SYM_NAME
#          SYM_TAB
#          SYT_ADDR
#          SYT_BASE
#          SYT_DISP
#          SYT_FLAGS
#          SYT_LEVEL
#          SYT_LINK1
#          SYT_LINK2
#          SYT_NAME
#          TOGGLE
#          UPPER
#          VALS
#          XTNT
#          X2
#          X3
# EXTERNAL VARIABLES CHANGED:
#          CLOCK
#          COMMON_RETURN_CODE
#          COMM
#          MAX_SEVERITY
#          OP2
#          SEVERITY
#          STACK_PTR
#          STRUCT_LINK
#          TMP
# EXTERNAL PROCEDURES CALLED:
#          DOWNGRADE_SUMMARY
#          ERRORS
#          FORMAT
#          HEX
#          INSTRUCTION
#          PRINT_DATE_AND_TIME
#          PRINT_TIME
#*************************************************************************

# SUBROUTINE FOR PRINTING AN ACTIVITY SUMMARY


class sort_tab:

    def __init__(self):
        self.PTR = 0
        self.HDR = 0
        self.T_PTR = 0


def PRINTSUMMARY():
    # Locals: T, SORT_TAB, SORT_COUNT, BIGV, sometimes REPLACED, CREATED.
    SORT_TAB = []  # Entries are class sort_tab.
    
    def SORT1(n, value=None):
        nonlocal SORT_TAB
        while n >= len(SORT_TAB):
            SORT_TAB.append(sort_tab())
        if value == None:
            return SORT_TAB[n].PTR
        else:
            SORT_TAB[n].PTR = value & 0xFFFF

    def HDR1(n, value=None):
        nonlocal SORT_TAB
        while n >= len(SORT_TAB):
            SORT_TAB.append(sort_tab())
        if value == None:
            return SORT_TAB[n].HDR
        else:
            SORT_TAB[n].HDR = value & 0xF

    def SORT1(n, value=None):
        nonlocal SORT_TAB
        while n >= len(SORT_TAB):
            SORT_TAB.append(sort_tab())
        if value == None:
            return SORT_TAB[n].PTR
        else:
            SORT_TAB[n].PTR = value & 0xFFFF

    def T_SORT(n, value=None):
        nonlocal SORT_TAB
        while n >= len(SORT_TAB):
            SORT_TAB.append(sort_tab())
        if value == None:
            return SORT_TAB[n].T_PTR
        else:
            SORT_TAB[n].T_PTR = value & 0xFFFF

    if not g.pfs:  # BFS/PASS INTERFACE; CHANGE #Z TO SEPARATE OBJECT MODULE
        REPLACED = 'REPLACED'
        CREATED = 'CREATED'

    # LOCAL ROUTINE TO DUMP SYMBOL TABLE

    def SYT_DUMP():
        # DECLARE (PTR, I) BIT(16), MSG CHARACTER;
        # DECLARE HDG CHARACTER 
        # INITIAL('-  LOC    B DISP     LENGTH    BIAS   NAME');
        # 70,CR12713
        # DECLARE LENGTHI BIT(16);
        # LOCAL ROUTINE TO PUT PTR VALUES INTO TABLE THAT
        # IS SORTED BY SYT_ADDR LATER. THE TABLE WILL BE USED TO PRINT
        # ALIGNMENT GAP INFORMATION

        def INSERT_ELEMENT(BLOCK_DATA):
            nonlocal I, SORT_TAB, SORT_COUNT, BIGV
            if (I >= g.PROGPOINT):  # DO
                if BLOCK_DATA:  # DO
                    if g.CALLp[I] != 2:  # DO
                        NEXT_ELEMENT(SORT_TAB);
                        if g.CALLp(I) == 4: HDR1(SORT_COUNT, 5);
                        else: HDR1(SORT_COUNT, 2);
                        SORT1(SORT_COUNT, PTR);
                        SORT_COUNT = SORT_COUNT + 1;
                    # END
                # END
                else:  # DO
                    if (CSECT_TYPE(PTR) == LOCALpD) or (CSECT_TYPE(PTR) == COMPOOLpP):  # DO
                        NEXT_ELEMENT(SORT_TAB);
                        HDR1(SORT_COUNT, 0);
                        SORT1(SORT_COUNT, PTR);
                        BIGV = MAX(LENGTH(g.SYT_NAME(PTR)), BIGV);
                        SORT_COUNT = SORT_COUNT + 1;
                    # END
                # END
            # END
        # END INSERT_ELEMENT;
        
        # PRINT TITLE AND COLUMN DESCRIPTIONS OF TABLE.
        OUTPUT(1, '  VARIABLE OFFSET TABLE');
        OUTPUT(1, '     LOC IS THE CSECT-RELATIVE ADDRESS IN' \
            +' HEX OF THE DECLARED VARIABLE.');
        OUTPUT(1, '     B IS THE BASE REGISTER USED FOR ADDRESS' \
             +'ING THE DECLARED VARIABLE.  IF B IS NEGATIVE, THIS' \
             +' IS A VIRTUAL REGISTER AND CODE');
        OUTPUT(1, '           MUST BE GENERATED TO LOAD A REAL ' \
               +'REGISTER.');
        OUTPUT(1, '     DISP IS THE DISPLACEMENT USED FOR GENER' \
             +'ATING BASE-DISPLACEMENT ADDRESSES FOR ACCESSING THE' \
             +' DATA ITEMS.');
        OUTPUT(1, '     LENGTH IS THE SIZE IN DECIMAL HALFWORDS' \
               +' OF THE VARIABLE.');
        OUTPUT(1, '     BIAS IS THE AMOUNT OF THE ZEROTH ELEMEN' \
               +'T OFFSET.');
        OUTPUT(1, '     NAME IS THE NAME OF THE VARIABLE.');
        OUTPUT(1, HDG);
        ALLOCATE_SPACE(SORT_TAB, 10);
        NEXT_ELEMENT(SORT_TAB);
        SORT_COUNT = 1;
        BIGV = 20;
        for I  in range(1, g.PROCLIMIT + 1):
            PTR = g.PROC_LEVEL[I];
            INSERT_ELEMENT(g.TRUE);
            if I < g.PROGPOINT: MSG = '';
            else: MSG = '     STACK=' + g.MAXTEMP[I];
            OUTPUT(1, '0         UNDER ' + g.SYT_NAME(PTR) + MSG);
            PTR = g.SYT_LEVEL(PTR);
            while PTR > 0:
                if (g.SYT_FLAGS(PTR) & g.NAME_FLAG) != 0:  # DO
                    if (g.SYT_FLAGS(PTR) & g.REMOTE_FLAG) != 0: 
                        LENGTHI = 2;
                    else: LENGTHI = 1;
                # END
                else: LENGTHI = g.EXTENT(PTR);
                if g.SYT_DISP(PTR) >= 0:  # DO
                    INSERT_ELEMENT(g.FALSE);
                    MSG = HEX(g.SYT_DISP(PTR), 3);
                    MSG = FORMAT(g.SYT_BASE(PTR), 3) + g.BLANK + MSG;
                    MSG = MSG + g.X3;
                    OUTPUT(0, HEX(g.SYT_ADDR(PTR), 6) + g.BLANK + MSG + \
                        FORMAT(LENGTHI, 8) + FORMAT(-g.SYT_CONST(PTR), 8) + \
                        g.X4 + g.SYT_NAME(PTR));
                # END
                elif not (g.SREF & 1):
                    OUTPUT(0, HEX(g.SYT_ADDR(PTR), 6) + '           ' + \
                        FORMAT(LENGTHI, 8) + FORMAT(-g.SYT_CONST(PTR), 8) + \
                        g.X4 + g.SYT_NAME(PTR));
                PTR = g.SYT_LEVEL(PTR);
            # END
        # END
        SORT_COUNT = SORT_COUNT - 1;
    # END SYT_DUMP;
    # LOCAL ROUTINE TO PRINT ALIGNMENT GAP INFORMATION
    # FOR LOCAL DATA

    def ALIGN_DUMP():
        # Locals: GAP,BEGIN_GAP, TOTAL_GAP, S1, I, M, L, LENGTHI
        OUTPUT(0, ' ');
        # SORT TABLE
        goto = None
        M = SHR(SORT_COUNT, 1);
        while M > 0:
            for L  in range(1, SORT_COUNT - M + 1):
                I = L;
                while (g.SYT_ADDR(SORT1(I)) > g.SYT_ADDR(SORT1(I + M))):
                    L = SORT1(I);
                    SORT1(I, SORT1(I + M));
                    SORT1(I + M, L);
                    L = HDR1(I);
                    HDR1(I, HDR1(I + M));
                    HDR1(I + M, L);
                    I = I - M;
                    if I < 1: 
                        goto = "LM";
                        break
                # END DO WHILE STRING_GT
                if goto == "LM": goto = None
            # END DO L
            M = SHR(M, 1);
        # END DO WHILE M
        # PRINT TABLE
        TOTAL_GAP = 0;
        S1 = PAD('NAME', BIGV) + '  LEN(DEC)  OFFSET(DEC)   B  DISP(HEX)  SCOPE';
        OUTPUT(1, '1')
        OUTPUT(1, '0MEMORY MAP FOR DATA CSECT ' + ESD_TABLE(DATABASE));
        OUTPUT(1, '0' + S1);
        OUTPUT(1, '');
        OUTPUT(1, '2' + S1);
        for I  in range(1, SORT_COUNT + 1):
            if (g.SYT_FLAGS(SORT1(I)) & g.NAME_FLAG) != 0:  # DO
                if (g.SYT_FLAGS(SORT1(I)) & g.REMOTE_FLAG) != 0: LENGTHI = 2;
                # "
                else: LENGTHI = 1;
            # END
            else: LENGTHI = g.EXTENT(SORT1(I));
            if HDR1(I) != 0:  # DO
                S1 = PAD('**LOCAL BLOCK DATA**', BIGV) + g.X2;
                S1 = S1 + FORMAT(HDR1(I), 7) + g.X3;
                S1 = S1 + FORMAT(g.SYT_ADDR(SORT1(I)), 7) + PAD(g.X3, 21);
                S1 = S1 + g.SYT_NAME(g.PROC_LEVEL[g.SYT_SCOPE(SORT1(I))]);
            # END
            else:  # DO
                S1 = PAD(g.SYT_NAME(SORT1(I)), BIGV);
                S1 = S1 + g.X2 + FORMAT(LENGTHI, 7) + g.X3;
                S1 = S1 + FORMAT(g.SYT_ADDR(SORT1(I)), 7) + g.X2 + g.X3;
                S1 = S1 + FORMAT(g.SYT_BASE(SORT1(I)), 3) + g.X4;
                S1 = S1 + HEX(g.SYT_DISP(SORT1(I)), 4) + g.X3 + g.X2;
                S1 = S1 + g.SYT_NAME(g.PROC_LEVEL[g.SYT_SCOPE(SORT1(I))]);
            # END
            OUTPUT(0, S1);
            # PRINT ALIGNMENT GAP INFORMATION
            if I < SORT_COUNT:  # DO
                BEGIN_GAP = g.SYT_ADDR(SORT1(I)) + LENGTHI + HDR1(I);
                GAP = g.SYT_ADDR(SORT1(I + 1)) - BEGIN_GAP;
                if GAP > 0:  # DO
                    TOTAL_GAP = TOTAL_GAP + GAP;
                    OUTPUT(0, PAD('**ALIGNMENT GAP**', BIGV) + g.X2 + FORMAT(GAP, 7) + g.X3 \
                           +FORMAT(BEGIN_GAP, 7));
                # END
            # END
        # END
        OUTPUT(0, '');
        OUTPUT(0, 'TOTAL SIZE OF ALIGNMENT GAPS FOR CSECT: ' + TOTAL_GAP + ' HW');
        OUTPUT(0, '');
        OUTPUT(1, '2 ');
        RECORD_FREE(SORT_TAB);
    # END ALIGN_DUMP;
    
    
    # LOCAL ROUTINE TO PRINT STACK SIZES ONLY
    def STACK_DUMP():
        # Locals: I
        OUTPUT(1, '- STACK   NAME');
        for I in range(g.PROGPOINT, g.PROCLIMIT + 1):
            OUTPUT(0, FORMAT(g.MAXTEMP[I], 6) + g.X2 + g.SYT_NAME(g.PROC_LEVEL[I]));
        # END
        for I  in range(0, g.OPMAX + 1):
            g.OBJECT_INSTRUCTIONS = g.OBJECT_INSTRUCTIONS + g.OPCOUNT[I];
        # END
    # END STACK_DUMP;
    
    # LOCAL ROUTINE TO DUMP STRUCTURE TEMPLATE LAYOUTS AND SIZES
    def TEMPLATE_DUMP():
        # Locals: HDG, MSG, LENGTHI
        HDG = '-  LOC     SIZE     BIAS  NAME'
    
        # ROUTINE TO CALCULATE THE TEMPLATE'S ACTUAL LENGTH. 
        def CALC_TEMPL_LENGTH():
            # Locals NUM, L, INDX, I, TEMP.
            NUM = SYT_LINK1(g.OP2);
            L = 0;
            while NUM != 0:
                if SYT_LINK1(NUM) != 0:
                    NUM = SYT_LINK1(NUM);
                else:  # DO
                    L = L + 1;
                    NEXT_ELEMENT(SORT_TAB);
                    T_SORT(L, NUM);
                    NUM = SYT_LINK2(NUM);
                # END;
                while NUM < 0:
                    NUM = SYT_LINK2(-NUM);
                # END while NUM
            END;
            # IF TEMPLATE IS NOT RIGID THEN SORT TERMINALS
            if (g.SYT_FLAGS(g.OP2) & g.RIGID_FLAG) == 0:  # DO
                for INDX in range(1, (g.L - 1) + 1):
                    for I in range(1, (g.L - INDX) + 1):
                        if g.SYT_ADDR(T_SORT(INDX)) > g.SYT_ADDR(T_SORT(INDX + I)):  # DO
                            TEMP = T_SORT(INDX);
                            T_SORT(INDX, T_SORT(INDX + I));
                            T_SORT(INDX + I, TEMP);
                        # END
                    # END DO I
                # END DO INDX
            # END
            if (g.SYT_FLAGS(T_SORT(1)) & g.NAME_FLAG) != 0:  # DO
                if (g.SYT_FLAGS(T_SORT(1)) & g.REMOTE_FLAG) != 0:
                    LENGTHI = 2;
                else: LENGTHI = 1;
            # END
            else: LENGTHI = g.EXTENT(T_SORT(1));
            for INDX in range(1, (g.L - 1) + 1):
                if (g.SYT_FLAGS(T_SORT(INDX + 1)) & g.NAME_FLAG) != 0:  # DO
                    if (g.SYT_FLAGS(T_SORT(INDX + 1)) & g.REMOTE_FLAG) != 0:
                        LENGTHI = LENGTHI + 2;
                    else: LENGTHI = LENGTHI + 1;
                # END
                elif g.SYT_ADDR(T_SORT(INDX)) != g.SYT_ADDR(T_SORT(INDX + 1)):
                    LENGTHI = LENGTHI + g.EXTENT(T_SORT(INDX + 1));
            # END
        # END CALC_TEMPL_LENGTH;
    
        if g.STRUCT_START > 0:  # DO
            g.STRUCT_LINK = g.STRUCT_START;
            OUTPUT(1, '0 STRUCTURE TEMPLATE LAYOUT');
            OUTPUT(1, HDG);
            while g.STRUCT_LINK > 0:
                g.OP2 = g.STRUCT_LINK;
                g.SYT_LINK2(g.OP2, 0);
                # EXIT PNT FOR STR. WALK
                OUTPUT(1, '0         STRUCTURE' + g.SYT_NAME(g.OP2));
                LENGTHI = 0;
                CALC_TEMPL_LENGTH();
                while g.OP2 > 0:
                    if (g.SYT_FLAGS(g.OP2) & g.NAME_FLAG) != 0: 
                        MSG = '    NAME';
                    else: MSG = FORMAT(g.EXTENT(g.OP2), 8);
                    # ONLY PRINT THE BIAS FOR THE NODES (NOT THE TEMPLATE)
                    if g.OP2 == g.STRUCT_LINK: MSG = MSG + '        ';
                    else: MSG = MSG + FORMAT(-g.SYT_CONST(g.OP2), 8);
                    OUTPUT(0, HEX(g.SYT_ADDR(g.OP2), 6) + MSG + g.X3 + \
                           g.SYT_NAME(g.OP2));
                    if g.SYT_LINK1(g.OP2) > 0:
                        g.OP2 = g.SYT_LINK1(g.OP2);
                    else: g.OP2 = g.SYT_LINK2(g.OP2);
                    while g.OP2 < 0:
                        g.OP2 = g.SYT_LINK2(-g.OP2);
                    # END
                # END
                OUTPUT(0, 'TOTAL SIZE OF ALIGNMENT GAPS FOR' + \
                        g.SYT_NAME(g.STRUCT_LINK) + ': ' + \
                        g.EXTENT(g.STRUCT_LINK) - LENGTHI + ' HW');
                g.STRUCT_LINK = g.SYT_LEVEL(g.STRUCT_LINK);
            # END
        # END
    # END TEMPLATE_DUMP;

    def FORM_UP(MSG, VAL1, VAL2):
        # Local S.
        if VAL2 > VAL1: S = ' <-<-<- ';
        else: S = '';
        S = FORMAT(VAL2, 8) + S;
        S = FORMAT(VAL1, 10) + S;
        return MSG + S;
    # END FORM_UP;

    MONITOR(0, 3);  # CLOSE(3)
    if g.MAX_SEVERITY < 2:  # DO
        if      (pfs & g.CODE_LISTING_REQUESTED) or \
                (not pfs and g.CODE_LISTING):  # DO; # 'AB' AND 'L' INDEPENDENT
            SYT_DUMP();
            TEMPLATE_DUMP();
            ALIGN_DUMP();
            OUTPUT(1, '-INSTRUCTION FREQUENCIES');
            OUTPUT(1, '0INSN  COUNT');
            for T  in range(0, g.OPMAX + 1):
                #*************************************************************
                # MNEMONICS ARE NOT DUPLICATED IN THE
                # INSTRUCTION FREQUENCY TABLE IN THE COMPILED LISTING.  SEDR &
                # SER APPEAR TWICE IN THE TABLE. BC AND BVC ALSO APPEAR TWICE
                # IN THE TABLE, BUT THEY SHOULD BECAUSE ONE INSTRUCTION IS A
                # RELATIVE BRANCH AND THE OTHER IS AN ABSOLUTE BRANCH.
                # WHEN THE RELATIVE BC OPCODE IS GENERATED, THE BCB
                # OR BCF MNEMONIC WILL BE PRINTED.  WHEN THE RELATIVE BVC
                # OPCODE IS GENERATED, THE BVCF MNEMONIC WILL BE PRINTED.
                #**************************************************************
                if g.OPCOUNT[T] > 0:  # DO
                    if T == 39 or T == 55: 
                        g.OPCOUNT[T + 4] = g.OPCOUNT[T] + g.OPCOUNT[T + 4];
                    elif T == 135:  # DO
                        if g.BCB_COUNT > 0: 
                            OUTPUT(0, 'BCB   ' + g.X2 + g.BCB_COUNT);
                        if (g.OPCOUNT[T] - g.BCB_COUNT) > 0: 
                            OUTPUT(0, 'BCF   ' + g.X2 + (g.OPCOUNT[T] - g.BCB_COUNT));
                        g.OBJECT_INSTRUCTIONS = g.OBJECT_INSTRUCTIONS + g.OPCOUNT[T];
                        # "
                    # END
                    else:  # DO
                        OUTPUT(0, INSTRUCTION(T) + g.X2 + g.OPCOUNT[T]);
                        g.OBJECT_INSTRUCTIONS = g.OBJECT_INSTRUCTIONS + g.OPCOUNT[T];
                        # "
                    # END
                # END
            # END
        # END
        else: STACK_DUMP();
    # END
    g.OBJECT_MACHINE = 1;
    # INDICATE FC CODE GENERATOR
    OUTPUT(1, '-       OPTIONAL TABLE SIZES');
    OUTPUT(1, '0NAME       REQUESTED    USED');
    OUTPUT(1, '+____       _________    ____');
    OUTPUT(0, g.BLANK);
    OUTPUT(0, FORM_UP('LITSTRINGS' , g.LIT_CHAR_SIZE, g.LIT_CHAR_USED));
    OUTPUT(0, FORM_UP('LABELSIZE ', g.STATNOLIMIT, g.STATNO));
    OUTPUT(0, g.BLANK);
    if ERRORp > 0:
        OUTPUT(0, '***  ' + ERRORp + ' ERROR(S) DETECTED IN PHASE 2');
    if (g.TOGGLE & 0x80) == 0:  # DO
        if g.MAX_SEVERITY != 0: 
            OUTPUT(0, '***  CONVERSION ERRORS INHIBITED OBJECT MODULE GENERATION');
    # END
    else:  # DO
        g.MAX_SEVERITY = 3;
        OUTPUT(0, '***  PHASE 1 INHIBITED EXECUTION');
    # END
    if g.MAX_SEVERITY == 0:  # DO
        OUTPUT(0, g.BLANK);
        if not pfs:  # BFS/PASS INTERFACE; OUTPUT OBJECT MODULE
            OBJECT_MODULE_NAME = 'OBJECT MODULE MEMBER ' + \
                                 OBJECT_MODULE_NAME + ' HAS BEEN ';
            if (OBJECT_MODULE_STATUS & 1) != 0:
                OBJECT_MODULE_NAME = OBJECT_MODULE_NAME + REPLACED ;
            else:
                OBJECT_MODULE_NAME = OBJECT_MODULE_NAME + 'CREATED';
            OUTPUT(0, g.BLANK);
            if g.PCEBASE:  # DO
                OUTPUT(0, OBJECT_MODULE_NAME);
                OBJECT_MODULE_NAME = SUBSTR(OBJECT_MODULE_NAME, 0, 21) \
                    +POUND_Z + SUBSTR(OBJECT_MODULE_NAME, 23, 16);
                if (OBJECT_MODULE_STATUS & 2) != 0:
                    OBJECT_MODULE_NAME = OBJECT_MODULE_NAME + REPLACED;
                else:
                    OBJECT_MODULE_NAME = OBJECT_MODULE_NAME + CREATED;
            # END
            OUTPUT(0, OBJECT_MODULE_NAME);
            OUTPUT(0, g.BLANK);
        OUTPUT(0, g.PP + ' HALMAT OPERATORS CONVERTED');
        OUTPUT(0, g.BLANK);
        OUTPUT(0, g.OBJECT_INSTRUCTIONS + ' INSTRUCTIONS GENERATED');
        OUTPUT(0, g.BLANK);
        OUTPUT(0, g.PROGCODE + ' HALFWORDS OF PROGRAM, ' + \
                PROGDATA + g.PROGDATA[1] + ' HALFWORDS OF DATA.');
    # END
    OUTPUT(0, g.BLANK);
    OUTPUT(0, 'MAX. OPERAND STACK SIZE            =' + g.STACK_MAX);
    T = 0;
    while STACK_PTR != 0:
        STACK_PTR = g.STACK_PTR[STACK_PTR];
        T = T + 1;
        if T > g.STACK_SIZE:  # DO
            ERRORS(d.CLASS_BI, 504);
            STACK_PTR = 0;
        # END
    # END
    OUTPUT(0, 'END  OPERAND STACK SIZE            =' + g.STACK_SIZE - T);
    OUTPUT(0, 'MAX. STORAGE DESCRIPTOR STACK SIZE =' + g.FULLTEMP);
    T = 0;
    for g.TMP in range(0, g.FULLTEMP + 1):
        if g.UPPER[g.TMP] > 0:
            T = T + 1;
    # END
    # CALL DOWNGRADE SUMMARY
    DOWNGRADE_SUMMARY();
    OUTPUT(0, 'END  STORAGE DESCRIPTOR STACK SIZE =' + T);
    if not pfs:  # BFS/PASS INTERFACE; LISTING DIFFERENCE
        OUTPUT(0, 'EXTERNAL SYMBOL DICTIONARY MAXIMUM =' + g.ESD_MAX);
    OUTPUT(0, 'NUMBER OF MINOR COMPACTIFIES       =' + COMPACTIFIES(0));
    OUTPUT(0, 'NUMBER OF MAJOR COMPACTIFIES       =' + COMPACTIFIES(1));
    OUTPUT(0, 'NUMBER OF REALLOCATIONS            =' + REALLOCATIONS);
    OUTPUT(0, 'FREE STRING AREA                   =' + FREELIMIT - FREEBASE);
    OUTPUT(0, g.BLANK);
    T = MONITOR(18);
    if g.CLOCK[1] == 0: 
        g.CLOCK[1] = T
        g.CLOCK[2] = T;
    elif g.CLOCK[2] == 0: g.CLOCK[2] = T;
    PRINT_DATE_AND_TIME('END OF HAL/S PHASE 2 ', DATE, TIME);
    PRINT_TIME('TOTAL CPU TIME FOR PHASE 2       ', T - g.CLOCK[0]);
    PRINT_TIME('CPU TIME FOR PHASE 2 SET UP      ', g.CLOCK[1] - g.CLOCK[0]);
    PRINT_TIME('CPU TIME FOR PHASE 2 GENERATION  ', g.CLOCK[2] - g.CLOCK[1]);
    PRINT_TIME('CPU TIME FOR PHASE 2 CLEAN UP    ', T - g.CLOCK[2]);
# END PRINTSUMMARY;
