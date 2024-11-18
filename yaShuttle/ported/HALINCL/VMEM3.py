#!/usr/bin/env python3
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   VMEM3.py
   Purpose:    Part of the HAL/S-FC compiler.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2022-10-23 RSB  Began porting from XPL.
"""

from xplBuiltins import *
import HALINCL.VMEM1 as v1
import HALINCL.VMEM2 as v2
from ERRORS import ERRORS

# VIRTUAL MEMORY LOGIC FOR THE XPL PROGRAMMING SYSTEM
# EDIT LEVEL 002             23 AUGUST 1977         VERSION 1.1


def HEX1(HVAL, N):
    # Locals: STRING, ZEROS, HEXCODES;
    ZEROS = '00000000';
    HEXCODES = '0123456789ABCDEF';
    STRING = '';
    
    HVAL &= 0xFFFFFFFF
    
    goto = "H_LOOP"
    while goto != None:
        if goto == "H_LOOP": goto = None
        STRING = SUBSTR(HEXCODES, HVAL & 0xF, 1) + STRING;
        HVAL = SHR(HVAL, 4);
        if HVAL != 0: goto = "H_LOOP";
    if LENGTH(STRING) >= N: return STRING;
    return SUBSTR(ZEROS, 0, N - LENGTH(STRING)) + STRING;
# END HEX1;


# PROCEDURE TO DUMP LAST ACCESSED POINTERS
def DUMP_VMEM_STATUS():
    # Locals FLAGS, I
    FLAGS = []
    
    # DECLARE FLAGS(VMEM_LIM_PAGES) CHARACTER, I BIT(8);
    for I in range(0, v1.VMEM_LIM_PAGES + 1):
        FLAGS.append('');
        if (v1.VMEM_FLAGS_STATUS[I] & v2.RESV) != 0: 
            FLAGS[I] = ' RESV';
        if (v1.VMEM_FLAGS_STATUS[I] & v2.MODF) != 0: 
            FLAGS[I] = FLAGS[I] + ' MODF';
        if (v1.VMEM_FLAGS_STATUS[I] & v2.RELS) != 0: 
            FLAGS[I] = FLAGS[I] + ' RELS';
        if FLAGS[I] == '': 
            FLAGS[I] = ' NO FLAGS';
    # END
    OUTPUT(0, 'POINTERS IN CORE:     FLAGS:');
    for I in range(0, v1.VMEM_LIM_PAGES + 1):
        OUTPUT(0, '         ' + HEX1(v2.VMEM_PTR_STATUS[I], 8) + '     ' + FLAGS(I));
    # END
# END DUMP_VMEM_STATUS;


# This is an auxiliary functin not originally present in XPL.  It's primarily
# used by the MOVE() function, though used by others as well.  Refer to the
# notes in README.md (Virtual Memory section) for an explanation of the 
# addressing involved.
def normalize(ADDRESS):
    isString = False
    if isinstance(ADDRESS, int):
        # Virtual memory reference
        object = v2.VMEM_PAD_ADDR[ADDRESS // v1.VMEM_PAGE_SIZE]
        index = ADDRESS % v1.VMEM_PAGE_SIZE
        return object, index, isString
    if not isinstance(ADDRESS, tuple):
        ADDRESS = (ADDRESS, 0)
    # Ordered pair.
    object = ADDRESS[0]
    index = ADDRESS[1]
    if isinstance(object, str):
        # Temporarily convert string to an EBCDIC bytearray.
        isString = True
        object = bytearray([0] * len(object))
        for i in range(len(object)):
            object[i] = BYTE(ADDRESS[0][i])
    return object, index, isString


# See the notes in Virtual Memory section of the README.md file.
def MOVE(LENGTH, FROM, INTO):
    
    sourceObject, sourceIndex, sourceIsString = normalize(FROM)
    destObject, destIndex, destIsString = normalize(INTO)
    
    # Now copy the data.
    if isinstance(sourceObject, bytearray):
        if isinstance(destObject, bytearray):
            for i in range(LENGTH):
                destObject[destIndex + i] = sourceObject[sourceIndex + i]
        else:
            print("MOVE not yet implemented for this case", file=sys.stderr)
            0 / 0
    else:
        if isinstance(destObject, bytearray):
            print("MOVE not yet implemented for this case", file=sys.stderr)
            print("Length:", LENGTH, file=sys.stderr)
            print("Source:", sourceObject, file=sys.stderr)
            print("Dest: ", destObject, file=sys.stderr)
            sys.exit(1);
        else:
            print("MOVE not yet implemented for this case", file=sys.stderr)
            0 / 0
    
    if destIsString:
        # Convert destination EBCDIC bytearray to a character string and
        # return it.
        return destObject.decode('cp1140')
    
# END MOVE;


# ZERO 'COUNT' BYTES OF THE SPECIFIED CORE LOCATIONS.  The "core address"
# referred to is the addressing scheme used by the Python MOVE() function;
# refer to the Virtual Memory section of READM.md.  Note that if the "core
# address" is within a character string, an abend will occur. 
# NOTE: 1<= COUNT <= 256
def ZERO_256(CORE_ADDR, COUNT):
    
    from g import traceInline
    traceInline("ZERO_256 p19")
    
    object, index, isString = normalize(CORE_ADDR);
    if isString:
        print("Zeroing a string not implemented", file=sys.stderr)
        0 / 0
    
    if isinstance(object, bytearray):
        for i in range(COUNT):
            object[index + i] = 0
    else:
        print("Zeroing non-bytearray not yet implemented", file=sys.stderr)
        0 / 0
        
# END ZERO_256;


# ZERO 'COUNT' BYTES OF THE SPECIFIED CORE LOCATIONS.
# NOTE: THERE IS NO LIMIT TO THE SIZE OF 'COUNT'!
# In principle this is a fine how-do-you-do!  Fortunately, the only use for it
# we're likely to encounter seems to be zeroing out of an entire bytearray,
# we hopefully don't need to worry too much about it exceeding the boundaries
# of the (Python) objects it's going to be zeroing.
def ZERO_CORE(CORE_ADDR, COUNT):
    # Local pBYTES
    offset = 0
    object, index, isString = normalize(CORE_ADDR)
    while COUNT != 0:
        if COUNT > 256: pBYTES = 256;
        else: pBYTES = COUNT;
        ZERO_256((object, index), pBYTES);
        index = index + pBYTES;
        COUNT = COUNT - pBYTES;
    # END
    return;
# END ZERO_CORE;


def PERM_LOOK_AHEAD_OFF():
    v2.VMEM_LOOK_AHEAD = 0;
    if v2.VMEM_LOOK_AHEAD_PAGE >= 0:  # DO
        MONITOR(31, 0, -1);
        v2.VMEM_LOOK_AHEAD_PAGE = -1;
    # END
# END PERM_LOOK_AHEAD_OFF;
# ROUTINE TO SET VIRTUAL MEMORY PAGE DISPOSITION PARAMETERS


def DISP(FLAGS):
    # Local: TEMP.
    TEMP = v2.VMEM_PAD_DISP[v2.VMEM_OLD_NDX];
    if (FLAGS & v2.MODF) != 0:
        TEMP = TEMP | 0x4000;
    if (FLAGS & v2.RESV) != 0:  # DO
        TEMP = TEMP + 1;
        v2.VMEM_RESV_CNT = v2.VMEM_RESV_CNT + 1;
    # END
    elif (FLAGS & v2.RELS) != 0:  # DO
        TEMP = TEMP - 1;
        v2.VMEM_RESV_CNT = v2.VMEM_RESV_CNT - 1;
    # END
    v2.VMEM_PAD_DISP[v2.VMEM_OLD_NDX] = TEMP;
# END DISP;
# ROUTINE TO 'LOCATE' VIR. MEM. DATA BY POINTER


# The following are supposed to be local variables of PTR_LOCATE(), but I put
# them out here for persistence.
VMEM_PAGE = None
PREV_CNT = 0
CUR_NDX = 0


def PTR_LOCATE(PTR, FLAGS):
    # Locals: BUFF_ADDR, PREF_CNT, I, J, PAGE, PAGE_TMP, OFFSET, CUR_NDX, 
    #         PASSED_FLAGS, VMEM_PAGE.  But some I've changed to globals for
    #         the sake of persistence.
    global VMEM_PAGE, PREV_COUNT, CUR_NDX
    
    # PROCEDURE TO SAVE CURRENT POINTER INFORMATION
    def SAVE_PTR_STATE(INDEX):
        v1.VMEM_PTR_STATUS[INDEX] = PTR;
        v1.VMEM_FLAGS_STATUS[INDEX] = PASSED_FLAGS;
    # END SAVE_PTR_STATE;

    def PAGING_STRATEGY():
        global CUR_NDX, PREV_CNT, PAGE_TMP
        
        CUR_NDX = -1;
        
        # The following was originally a macro.
        def SET_INDEX():
            global PREV_CNT, CUR_INDEX
            CUR_NDX = I; 
            PREV_CNT = v2.VMEM_PAD_CNT[I];
        # END SET_INDEX.
        
        for I in range(0, v2.VMEM_MAX_PAGE + 1):
            if (v2.VMEM_PAD_DISP[I] & 0x3FFF) == 0:  # DO
                if CUR_NDX < 0: SET_INDEX();
                elif (v2.VMEM_PAD_CNT[I] < PREV_CNT): SET_INDEX();
            # END
        # END
        if CUR_NDX < 0:  # DO
            ERRORS(d.CLASS_BI, 700);
            EXIT();
        # END
        PAGE_TMP = v2.VMEM_PAD_PAGE[CUR_NDX];
        if PAGE_TMP != -1:  # DO
            v2.VMEM_PAGE_TO_NDX[PAGE_TMP] = -1;
            if PAGE_TMP == v2.VMEM_LOOK_AHEAD_PAGE:  # DO
                MONITOR(31, 0, -1);
                v2.VMEM_LOOK_AHEAD_PAGE = -1;
            # END
        # END
        if (v2.VMEM_PAD_DISP[CUR_NDX] & 0x4000) != 0:  # DO
            if v2.VMEM_LOOK_AHEAD_PAGE >= 0:  # DO
                MONITOR(31, 0, -1);
                v2.VMEM_LOOK_AHEAD_PAGE = -1;
            # END
            VMEM_PAGE = v2.VMEM_PAD_ADDR[CUR_NDX];
            FILE(v1.VMEM_FILEp, PAGE_TMP, VMEM_PAGE);
            v2.VMEM_WRITE_CNT = v2.VMEM_WRITE_CNT + 1;
        # END
    # END PAGING_STRATEGY;

    def BAD_PTR():
        ERRORS(d.CLASS_BI, 701, ' ' + HEX1(PTR, 8));
        DUMP_VMEM_STATUS();
        EXIT();
    # END BAD_PTR;
    
    PASSED_FLAGS = FLAGS;
    PAGE = SHR(PTR, 16) & 0xFFFF;
    OFFSET = PTR & 0xFFFF;
    if OFFSET >= v1.VMEM_PAGE_SIZE: BAD_PTR;
    if PAGE == v2.VMEM_PRIOR_PAGE:  # DO
        v2.VMEM_LOC_PTR = PTR;
        #VMEM_LOC_ADDR = VMEM_PAD_ADDR[VMEM_OLD_NDX] + OFFSET;
        v2.VMEM_LOC_ADDR = v1.VMEM_PAGE_SIZE * v2.VMEM_OLD_NDX + OFFSET
        if FLAGS != 0: DISP(FLAGS);
        SAVE_PTR_STATE(v2.VMEM_OLD_NDX);
        return;
    # END
    v2.VMEM_PRIOR_PAGE = PAGE;
    v2.VMEM_LOC_CNT = v2.VMEM_LOC_CNT + 1;
    if PAGE > v2.VMEM_LAST_PAGE:  # DO
        if (PAGE - 1) != v2.VMEM_LAST_PAGE: BAD_PTR;
        v2.VMEM_LAST_PAGE = PAGE;
        v2.VMEM_PAGE_AVAIL_SPACE[v2.VMEM_LAST_PAGE] = v1.VMEM_PAGE_SIZE;
        if v2.VMEM_LAST_PAGE <= v2.VMEM_MAX_PAGE:  # DO
            CUR_NDX = v2.VMEM_LAST_PAGE;
        # END
        else:  # DO
            if v2.VMEM_LAST_PAGE > VMEM_TOTAL_PAGES:  # DO
                ERRORS(d.CLASS_BI, 702);
                EXIT;
            # END
            PAGING_STRATEGY();
        # END
        FLAGS = FLAGS | v2.MODF;
        ZERO_CORE(v2.VMEM_PAD_ADDR[CUR_NDX], v1.VMEM_PAGE_SIZE);
        goto = "LOC_COMMON1";
    # END
    else:  # DO
        CUR_NDX = v2.VMEM_PAGE_TO_NDX[PAGE];
        if CUR_NDX == -1:  # DO
            PAGING_STRATEGY();
            if v2.VMEM_LOOK_AHEAD_PAGE >= 0:  # DO
                MONITOR(31, 0, -1);
                v2.VMEM_LOOK_AHEAD_PAGE = -1;
            # END
            VMEM_PAGE = v2.VMEM_PAD_ADDR[CUR_NDX]
            FILE(VMEM_PAGE, v1.VMEM_FILEp, PAGE);
            v2.VMEM_READ_CNT = v2.VMEM_READ_CNT + 1;
            if goto == "LOC_COMMON1": goto = None
            v2.VMEM_PAGE_TO_NDX[PAGE] = CUR_NDX;
            v2.VMEM_PAD_PAGE[CUR_NDX] = PAGE;
            v2.VMEM_PAD_DISP[CUR_NDX] = 0;
        # END
        else:  # DO
            if PAGE == v2.VMEM_LOOK_AHEAD_PAGE:  # DO
                MONITOR(31, 0, -1);
                v2.VMEM_LOOK_AHEAD_PAGE = -1;
            # END
        # END
        v2VMEM_PAD_CNT[CUR_NDX] = v2.VMEM_LOC_CNT;
    # END
    SAVE_PTR_STATE(CUR_NDX);
    v2.VMEM_OLD_NDX = CUR_NDX;
    v2.VMEM_LOC_PTR = PTR;
    #VMEM_LOC_ADDR = VMEM_PAD_ADDR[CUR_NDX] + OFFSET;
    v2.VMEM_LOC_ADDR = v2.VMEM_PAGE_SIZE * CUR_NDX + OFFSET
    if FLAGS != 0: DISP(FLAGS);
    if v2.VMEM_LOOK_AHEAD:  # DO
        if PAGE < v2.VMEM_LAST_PAGE:  # DO
            PAGE = PAGE + 1;
            CUR_NDX = v2.VMEM_PAGE_TO_NDX[PAGE];
            if CUR_NDX == -1:  # DO
                v2.VMEM_PAD_DISP[v2.VMEM_OLD_NDX] = \
                    v2.VMEM_PAD_DISP[v2.VMEM_OLD_NDX] + 1;
                if v2.VMEM_LAST_PAGE <= v2.VMEM_MAX_PAGE: 
                    CUR_NDX = v2.VMEM_LAST_PAGE;
                else: PAGING_STRATEGY();
                v2.VMEM_PAD_DISP[v2.VMEM_OLD_NDX] = \
                    v2.VMEM_PAD_DISP[v2.VMEM_OLD_NDX] - 1;
                BUFF_ADDR = v2.VMEM_PAD_ADDR[CUR_NDX];
                if v2.VMEM_LOOK_AHEAD_PAGE >= 0:
                    BUFF_ADDR = BUFF_ADDR | 0x80000000;
                MONITOR(31, BUFF_ADDR, PAGE);
                v2.VMEM_LOOK_AHEAD_PAGE = PAGE;
                v2.VMEM_READ_CNT = v2.VMEM_READ_CNT + 1;
                v2.VMEM_PAGE_TO_NDX[PAGE] = CUR_NDX;
                v2.VMEM_PAD_PAGE[CUR_NDX] = PAGE;
                v2.VMEM_PAD_DISP[CUR_NDX] = 0;
                v2VMEM_PAD_CNT[CUR_NDX] = v2.VMEM_LOC_CNT - 1;
            # END
        # END
    # END
# END PTR_LOCATE;
# ROUTINE TO ALLOCATE VIRTUAL MEMORY CELLS


# The following function in XPL returned VMEM_LOC_PTR, and it modified the
# parameter BVAR in-place, employing a trick to bypass the rules of XPL.
# The BVAR parameter, however, was not otherwise used.  Changing the upstream
# value of a parameter won't work in Python, so BVAR has been eliminated,
# and the function instead returns the ordered pair VMEM_LOC_PTR,VMEM_LOC_ADDR
# (where the 2nd of these is what used to be assigned to BVAR).
def GET_CELL(CELL_SIZE, FLAGS):
    # Locals: I, PAGE, CELL_TEMP, AVAIL_SIZE;
    
    goto = None
    
    CELL_SIZE = (CELL_SIZE + 3) & 0xFFFFFFFC;
    # MULTIPLE OF 4 BYTES
    if CELL_SIZE > v1.VMEM_PAGE_SIZE:  # DO
        ERRORS(d.CLASS_BI, 703);
        EXIT();
    # END
    if CELL_SIZE < v1.VMEM_PAGE_SIZE:  # DO
        if v2.VMEM_LOOK_AHEAD:  # DO
            PAGE = v2.VMEM_LAST_PAGE;
            AVAIL_SIZE = v2.VMEM_PAGE_AVAIL_SPACE[PAGE];
            if AVAIL_SIZE >= CELL_SIZE: goto = "GET_SPACE";
            else: goto = "EXTEND_VMEM";
        # END
        else:
            for I  in range(0, v2.VMEM_LAST_PAGE + 1):
                PAGE = v2.VMEM_LAST_PAGE - I;
                AVAIL_SIZE = v2.VMEM_PAGE_AVAIL_SPACE[PAGE];
                if (AVAIL_SIZE >= CELL_SIZE) & (v2.VMEM_PAGE_TO_NDX[PAGE] != -1):
                    goto = "GET_SPACE";
            # END
    # END
    if goto in [None, "EXTEND_VMEM"]:
        if goto == "EXTEND_VMEM": goto = None
        PAGE = v2.VMEM_LAST_PAGE + 1;
        # ADD ON TO VIRTUAL MEMORY
        AVAIL_SIZE = v1.VMEM_PAGE_SIZE;
    if goto == "GET_SPACE": goto = None
    PTR_LOCATE(SHL(PAGE, 16) + (v1.VMEM_PAGE_SIZE - AVAIL_SIZE), v2.MODF | FLAGS);
    CELL_TEMP = AVAIL_SIZE - CELL_SIZE;
    v2.VMEM_PAGE_AVAIL_SPACE[PAGE] = CELL_TEMP;
    return v2.VMEM_LOC_PTR, v2.VMEM_LOC_ADDR;
# END GET_CELL;


# ROUTINES TO ALLOCATE VIRTUAL MEMORY SPACE IN TABULAR ORGANIZATION
def MISC_ALLOCATE(TABLE_SIZE):
    # Locals: DUMMY, LEN, BASE_PTR.  However, DUMMY is no longer used in the
    # Python port.
    LEN = (TABLE_SIZE + 3) & 0xFFFFFFFC;
    # MULTIPLE OF 4 BYTES
    if LEN <= v1.VMEM_PAGE_SIZE: return GET_CELL(LEN, 0)[0];
    BASE_PTR = GET_CELL(v1.VMEM_PAGE_SIZE, 0)[0] | 0x80000000;
    LEN = LEN - v1.VMEM_PAGE_SIZE;
    while LEN > 0:
        GET_CELL(v1.VMEM_PAGE_SIZE, 0);
        LEN = LEN - v1.VMEM_PAGE_SIZE;
    # END
    v2.VMEM_PAGE_AVAIL_SPACE[v2.VMEM_PRIOR_PAGE] = -LEN;
    return BASE_PTR;
# END MISC_ALLOCATE;


# The following function in XPL tried to modify the upstream value of a 
# parameter (BVAR), which is neither possible in Python nor should be done
# under the rules of XPL.  In the Python version, the BVAR parameter is
# eliminated, and the value that was supposed to be assigned to it is instead
# returned by the function, which previously had no return value.
def LOC_MISC(BASE_PTR, OFFSET, FLAGS):
    # Locals: OFFSET, PTR, PAGE_INC
    
    PTR = BASE_PTR & 0x3FFFFFFF;
    if BASE_PTR > 0: PTR = PTR + OFFSET;
    else:  # DO
        PAGE_INC = OFFSET / v1.VMEM_PAGE_SIZE;
        PTR = PTR + SHL(PAGE_INC, 16) + (OFFSET % v1.VMEM_PAGE_SIZE);
    # END
    PTR_LOCATE(PTR, FLAGS);
    return v2.VMEM_LOC_ADDR;
# END LOC_MISC;


def GET_MISCF(BASE_PTR, INDEX):
    # Local:  NODE_F
    NODE_F = [0]
    NODE_F[0] = LOC_MISC(BASE_PTR, SHL(INDEX, 2), 0);
    return NODE_F(0);
# END GET_MISCF;


def SET_MISCF(BASE_PTR, INDEX, VALUE):
    # Local:  NODE_F, OLD_VALUE
    NODE_F = [0]
    NODE_F[0] = LOC_MISC(BASE_PTR, SHL(INDEX, 2), v2.ODF);
    OLD_VALUE = NODE_F(0);
    NODE_F[0] = VALUE;
    return OLD_VALUE;
# END SET_MISCF;


def GET_MISCH(BASE_PTR, INDEX):
    # Local:  NODE_H
    NODE_H = [0]
    NODE_H[0] = LOC_MISC(BASE_PTR, SHL(INDEX, 1), 0);
    return (NODE_H[0] & 0xFFFF);
# END GET_MISCH;


def SET_MISCH(BASE_PTR, INDEX, VALUE, OLD_VALUE):
    # Local:  NODE_H
    NODE_H = [0]
    NODE_H[0] = LOC_MISC(BASE_PTR, SHL(INDEX, 1), v2.MODF);
    OLD_VALUE = NODE_H(0) & 0xFFFF;
    NODE_H[0] = VALUE;
    return OLD_VALUE;
# END SET_MISCH;


def GET_MISCB(BASE_PTR, INDEX):
    # Local:  NODE_B
    NODE_B = [0]
    NODE_B[0] = LOC_MISC(BASE_PTR, INDEX, 0);
    return NODE_B[0];
# END GET_MISCB;


def SET_MISCB(BASE_PTR, INDEX, VALUE):
    # Local:  NODE_B
    NODE_B = [0]
    NODE_B[0] = LOC_MISC(BASE_PTR, INDEX, v2.MODF);
    OLD_VALUE = NODE_B[0];
    NODE_B[0] = VALUE;
    return OLD_VALUE;
# END SET_MISCB;


# ROUTINE TO 'LOCATE' A VIRTUAL MEMORY POINTER AND ...
# ASSIGN IT TO A BASED VARIABLE
# This function originally tried to overwrite the upstream value of a parameter,
# BVAR, by VMEM_LOC_ADDR.  That's not possible in Python, nor theoretically in
# XPL, so the Python version instead eliminates BVAR and returns VMEM_LOC_ADDR.
def LOCATE(PTR, FLAGS):
    # No locals.
    PTR_LOCATE(PTR, FLAGS);
    return v2.VMEM_LOC_ADDR;
# END LOCATE;


def VMEM_INIT():
    # No locals.
    v2.VMEM_MAX_PAGE = v1.VMEM_LIM_PAGES;
    v2.VMEM_PRIOR_PAGE = -1
    v2.VMEM_LAST_PAGE = -1
    v2.VMEM_LOOK_AHEAD_PAGE = -1;
    MONITOR(4, v1.VMEM_FILEp, v1.VMEM_PAGE_SIZE);
    MONITOR(31, v1.VMEM_FILEp, -1);
    # IN CASE LOOKAHEAD IS USED
# END VMEM_INIT;


def VMEM_AUGMENT(PAGE_ADDR, PAGE_LEN):
    # No locals.
    if (v2.VMEM_MAX_PAGE >= v1.VMEM_LIM_PAGES) or \
        (PAGE_LEN < v1.VMEM_PAGE_SIZE): return 1;
    while v2.VMEM_MAX_PAGE < v1.VMEM_LIM_PAGES:
        v2.VMEM_MAX_PAGE = v2.VMEM_MAX_PAGE + 1;
        v2.VMEM_PAD_PAGE[v2.VMEM_MAX_PAGE] = -1;
        v2.VMEM_PAD_ADDR[v2.VMEM_MAX_PAGE] = PAGE_ADDR;
        PAGE_ADDR = PAGE_ADDR + v1.VMEM_PAGE_SIZE;
        PAGE_LEN = PAGE_LEN - v1.VMEM_PAGE_SIZE;
        if PAGE_LEN < v1.VMEM_PAGE_SIZE: return 0;
    # END
    return 0;
# END VMEM_AUGMENT;
