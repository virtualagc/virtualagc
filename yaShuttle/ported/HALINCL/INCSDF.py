#!/usr/bin/env python3
"""
   Access:      Public Domain, no restrictions believed to exist.
   Filename:    INCSDF.py
   Purpose:     Part of the HAL/S-FC compiler.
   Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
   History:     2023-10-28 RSB  Created just a stub, which at present will never
                                be called.
                2026-03-12 RSB  Imported `SAVE_LITERAL`.
                2026-07-05 RSB  Changed `LIT_TOP` to `LIT_TOP()`.
    
    *** IMPORTANT NOTE ***
    
    In HAL_S_FC.py, there is no model of System/360 memory as such, in the sense
    of there being an array of bytes in which data is stored in predictable
    locations, in System/360 formats.  Rather, I just use native Python objects
    for everything.  This has its pros and cons in general, but (with some 
    effort) it worked well enough *until* porting SDFPKG to Python came up.
    I don't see any meaningful prospect of useing SDFPKG without a System/360
    memory model.  
    
    Fortunately (I think!), it's not necessary to go back and completely rework
    (or replace) HAL_S_FC.py to have a memory model:  We simply need a local
    memory model right here to hold the local structures meaningful to SDFPKG,
    such as COMMTABL, the SDF paging area, the FCBs, and maybe other `BASED`
    data.  The various infrastructure for managing memory allocation used in
    the original XPL/I code is not available, so this memory model is configured
    statically, to just have areas in fixed locations at fixed sizes in which
    these `BASED` arrays reside, with hard-coded limits on sizes of the areas.
    
    The C port of SDFPKG, on the other hand, as cross-compiled by XCOM-I and
    used in HALSFC and HALSTAT, has a memory model already and can automatically
    take advantage of the existing memory-allocation methods.
"""

import sys
from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
import HALINCL.COMMON as h
import HALINCL.DTOKEN as t
from ERROR import ERROR
from HALINCL.SAVELITE import SAVE_LITERAL
from HALINCL.SETDUPLF import SET_DUPL_FLAG
from HALINCL.ENTERDIM import ENTER_DIMS
from HALINCL.ICQARRAY import ICQ_ARRAYp
from HALINCL.ICQTERMp import ICQ_TERMp
from HALINCL.SPACELIB import NEXT_ELEMENT
from HASH import HASH
from HEX import HEX

implemented = False # default
if "--sdfpkg" in sys.argv:
    implemented = True
if "--no-sdfpkg" in sys.argv:
    implemented = False

# A model of memory as bytes, used only by `INCLUDE_SDF`.  It needs to be just
# big enough to hold 
#    COMMTABL (30 `FIXED`)
#    250 SDF pages (1680 bytes) (From SDFPKG User's Guide, PDF p. 11)
#    Area for FCBs.
COMMTABL_base = 0
COMMTABL_size = 30 * 4
SDF_PAGES_base = COMMTABL_base + COMMTABL_size
SDF_PAGES_size = 250 * 1680
FCBS_base = SDF_PAGES_base + SDF_PAGES_size
FCBS_size = 250000 # No idea how big this needs to be
memorySize = FCBS_base + FCBS_size
memoryModel = bytearray(memorySize)

# ROUTINE TO INCLUDE VARIABLES FROM AN EXTERNAL UNIT'S SDF

def INCLUDE_SDF(UNIT, INCL_FLAGS):
    
    if not implemented:
        return False;  # Same return as if the SDF wasn't found.
    
    # `INCLUDE_SDF` is always called with all of its parameters (none optional), 
    # so I don't think any persistance of variables across calls is required.
    # Note that I and J are local, not g.I and g.J.
    # UNIT is CHARACTER
    # INCL_FLAGS is BIT(8)
    NEXT_SYMBOL = 0 # BIT(16)
    CUR_SYMBOL = 0 # BIT(16)
    LAST_COMSUB_SYMB = 0 # BIT(16)
    UNIT_SYMBp = 0 # BIT(16)
    ACCESS_COMPOOL = g.FALSE
    TEMP_PTR = 0 # FIXED
    I = 0
    J = 0
    SDF_NAME = ""
    BLK_TYPE = 0
    pBLK_SYMBS = 0
    pSDF_PAGES = 0
    FLAGS = 0
    REV = 0
    CAT = 0
    REVSTR = ""
    pBLK_FLAGS = 3;
    IN_BLK_FLAG = (0x80,0x40,0x20,0x10)
    OUT_BLK_FLAG = (g.REENTRANT_FLAG, g.EXCLUSIVE_FLAG, g.ACCESS_FLAG, g.RIGID_FLAG)
    # DECLARATIONS FOR %COPY CHECKING
    CSECT_LENGTH = [0, 0, 0]  # LENGTHS OF APPROPRIATE CSECTS
    def PRIMARY_LENGTH(value = None): 
        if value == None:
            return CSECT_LENGTH[0]
        CSECT_LENGTH[0] = value
    def REMOTE_LENGTH(value = None):
        if value == None:
            return CSECT_LENGTH[1]
        CSECT_LENGTH[1] = value
    SDF_VAR_CLASS = 1  # INDICATES A VARIABLE
    def MAKESTRING(len, addr): # ***FIXME*** String, or string descriptor?
        return ((len-1) << 24) + addr
    def NEW_STRING(s):
        return s[:] # Clone the input string.
    INCLUDABLE_VERSIONp = 26
    SDF_VERSIONp = 0
    #-CR11120 ----------------- #DFLAG -------------------------
    ##DFLAG - MUST LOOK AT SDF ROOT DATA_REMOTE FLAG TO TELL IF
    ##DFLAG - MODULE WE'RE INCLUDING GOES REMOTE IN PRELINKER.
    SDF_ROOT_FLAGS = 0
    #-----------------------------------------------------------
    # SDF DECLARES
    '''
    How `SDF_B` et al work:  There is a variable, `SDFPKG_LOC_ADDR` that moves
    around.  The bases of all three of `SDF_B`, `SDF_H`, and `SDF_F` get set
    to that same`SDFPKG_LOC_ADDR`, which allows the data in the object at that
    address to be accessed either as bytes, halfwords, or fullwords, depending
    on which of `SDF_x` is used.  All of that works only if there is actually
    a model of memory in which the pointer can move around.  This Python port
    of PASS1 of HAL/S-FC doesn't actually have such a model (although
    HALSFC-PASS1 does).  I assume that the memory model is only for paging
    the SDF into and out of, so it can be entirely local to `INCLUDE_SDF`.
    But we define it as a global variable rather than a local one to avoid
    repeatedly creating and destroying it.  See `memoryModel` and 
    `memorySize` at the top of this file.
    '''
    #DECLARE
    #    SDF_B BASED BIT(8),
    #    SDF_H BASED BIT(16),
    #    SDF_F BASED FIXED;
    SDF_B_base = 0 
    SDF_H_base = 0 
    SDF_F_base = 0 
    def SDF_B(n, value=None):
        addr = SDF_B_base + n
        if value == None:
            return memoryModel[addr]
        memoryModel[addr] = value & 0xFF
        return value & 0xFF
    def SDF_H(n, value=None):
        addr = SDF_H_base + 2 * n
        if value == None:
            return (memoryModel[addr] << 8) + memoryModel[addr + 1]
        memoryModel[addr] = (value >> 8) & 0xFF
        memoryModel[addr + 1] = value & 0xFF
        return value & 0xFFFF
    def SDF_F(n, value=None):
        addr = SDF_F_base + 4 * n
        if value == None:
            return (memoryModel[addr] << 24) + \
                   (memoryModel[addr + 1] << 16) + \
                   (memoryModel[addr + 2] << 8) + \
                   memoryModel[addr + 3]
        memoryModel[addr] = (value >> 24) & 0xFF
        memoryModel[addr + 1] = (value >> 16) & 0xFF
        memoryModel[addr + 2] = (value >> 8) & 0xFF
        memoryModel[addr + 3] = value & 0xFF
        return value & 0xFFFFFFFF
    # FIELDS WITHIN AN SDF SYMBOL NODE
    def SDF_SYMB_FLAGS(value = None):
        return SDF_F(2, value)
    def SDF_SYMB_LINK1(value = None):
        return SDF_H(SDF_B(5)//2+1, value)
    def SDF_SYMB_LINK2(value = None):
        return SDF_H(SDF_B(5)//2+2, value)
    def SDF_SYMB_DECLARE_LINK(value = None):
        return SDF_H(-5, value)
    def SDF_SYMB_ADDR():
        return SDF_F(3)&0xFFFFFF
    def SDF_SYMB_EXTENT():
        return SDF_F(5)&0x00FFFFFF
    def SDF_SYMB_LOCKp(value = None):
        return SDF_B(20, value)
    def SDF_SYMB_ARRAY_OFF(value = None):
        return SDF_B(4, value)
    def SDF_SYMB_ARRAY(inp, value=None):
        return SDF_H(SHR(SDF_B(4),1)+1+inp, value)
    def SDF_SYMB_NDIM(value = None):
        return SDF_H(SHR(SDF_B(4),1), value)
    def SDF_SYMB_LIT_PTR(value = None):
        return SDF_F(5, value)
    def SDF_SYMB_TYPE(value = None):
        return SDF_B(7, value)
    def SDF_SYMB_VAR_LENGTH(value = None):
        return SDF_H(9, value)
    def SDF_SYMB_CLASS(value = None):
        return SDF_B(6, value)
    def SDF_SYMB_REPL_PTR(value = None):
        return SDF_F(5, value)
    # DEFINE SYMB_FLAGS BITS
    SDF_MISC_NAME_FLAG   = 0x00000010
    SDF_EXCLUSIVE_FLAG   = 0x00000040
    SDF_EXTERNAL_FLAG    = 0x00000800
    SDF_LIT_FLAG         = 0x00001000
    SDF_RIGID_FLAG       = 0x00002000
    SDF_INIT_FLAG        = 0x00004000
    SDF_REMOTE_FLAG      = 0x00010000
    SDF_LOCK_FLAG        = 0x00020000
    SDF_LATCH_FLAG       = 0x00040000
    SDF_ACCESS_FLAG      = 0x00100000
    SDF_CONSTANT_FLAG    = 0x00200000
    SDF_DENSE_FLAG       = 0x00400000
    SDF_REENTRANT_FLAG   = 0x00800000
    SDF_TPL_HDR_FLAG     = 0x02000000
    SDF_NAME_FLAG        = 0x04000000
    SDF_AUTO_FLAG        = 0x08000000
    SDF_TEMPORARY_FLAG   = 0x10000000
    SDF_ASSIGN_PARM_FLAG = 0x20000000
    SDF_INPUT_PARM_FLAG  = 0x40000000
    SDF_PARM_FLAGS = SDF_INPUT_PARM_FLAG|SDF_ASSIGN_PARM_FLAG
    # FIELDS AND VALUES WITHIN THE SDF DIRECTORY ROOT
    def SDF_ROOT_COMSUB_END(value = None):
        return SDF_H(59, value)
    SDF_FC_FLAG          = 0x1000
    def SDF_ROOT_LAST_PAGE(value = None):
        return SDF_H(1, value)
    def SDF_ROOT_UNIT_SYMBp(value = None):
        return SDF_H(14, value)
    def SDF_ROOT_UNIT_BLKp(value = None):
        return SDF_H(44, value)
    def SDF_ROOT_COMPILER():
        return MAKESTRING(4,SDFPKG_LOC_ADDR+140)
    # FIELDS WITHIN AN SDF REPLACE CELL
    def SDF_REPL_ARG_CNT():
        return -SDF_H(2)-1
    def SDF_REPL_ARG_NAME(i):
        return STRING(SDFPKG_LOC_ADDR+SDF_F(1+i))
    def SDF_REPL_NEXT_PTR(value = None):
        return SDF_F(0, value)
    def SDF_REPL_pBYTES(value = None):
        return SDF_H(2, value)
    def SDF_REPL_TEXT_ADDR():
        return SDFPKG_LOC_ADDR+6
    # FIELDS WITHIN AN SDF BLOCK DATA CELL
    def SDF_BLK_FIRST_SYMBp(value = None):
        return SDF_H(16, value)
    def SDF_BLK_LAST_SYMBp(value = None):
        return SDF_H(17, value)
    def SDF_BLK_VERSIONp(value = None):
        return SDF_B(25, value)
    def SDF_BLK_FLAGS(value = None):
        return SDF_B(24, value)
    def SDF_BLK_CATEGORY(value = None):
        return SDF_B(30, value)
    # DECLARES FOR SDFPKG.  Note that `COMMTABLE_BYTE` etc. is the same situation
    # as `SDF_x` discussed earlier.  We implement it in the same memory
    # model.  `COMMTABL` is an array of 30 `FIXED`
    COMMTABL_BYTE_base = 0
    COMMTABL_HALFWORD_base = 0
    COMMTABL_FULLWORD_base = 0
    def COMMTABL_BYTE(n, value=None):
        addr = COMMTABL_BYTE_base + n
        if value == None:
            return memoryModel[addr]
        memoryModel[addr] = value & 0xFF
        return value & 0xFF
    def COMMTABL_HALFWORD(n, value=None):
        addr = COMMTABL_HALFWORD_base + 2 * n
        if value == None:
            return (memoryModel[addr] << 8) + memoryModel[addr + 1]
        memoryModel[addr] = (value >> 8) & 0xFF
        memoryModel[addr + 1] = value & 0xFF
        return value & 0xFFFF
    def COMMTABL_FULLWORD(n, value=None):
        addr = COMMTABL_FULLWORD_base + 4 * n
        if value == None:
            return (memoryModel[addr] << 24) + \
                   (memoryModel[addr + 1] << 16) + \
                   (memoryModel[addr + 2] << 8) + \
                   memoryModel[addr + 3]
        memoryModel[addr] = (value >> 24) & 0xFF
        memoryModel[addr + 1] = (value >> 16) & 0xFF
        memoryModel[addr + 2] = (value >> 8) & 0xFF
        memoryModel[addr + 3] = value & 0xFF
        return value & 0xFFFFFFFF
    COMMTABL_ADDR = 0 # local FIXED
    def SDFPKG_APGAREA(value = None):
        return COMMTABL_FULLWORD(0, value)
    def SDFPKG_AFCBAREA(value = None):
        return COMMTABL_FULLWORD(1, value)
    def SDFPKG_NPAGES(value = None):
        return COMMTABL_HALFWORD(4, value)
    def SDFPKG_NBYTES(value = None):
        return COMMTABL_HALFWORD(5, value)
    def SDFPKG_MISC(value = None):
        return COMMTABL_HALFWORD(6, value)
    def SDFPKG_CRETURN(value = None):
        return COMMTABL_HALFWORD(7, value)
    def SDFPKG_BLKNO(value = None):
        return COMMTABL_HALFWORD(8, value)
    def SDFPKG_SYMBNO(value = None):
        return COMMTABL_HALFWORD(9, value)
    def SDFPKG_STMTNO(value = None):
        return COMMTABL_HALFWORD(10, value)
    def SDFPKG_BLKNLEN(value = None):
        return COMMTABL_BYTE(22, value)
    def SDFPKG_SYMBNLEN(value = None):
        return COMMTABL_BYTE(23, value)
    def SDFPKG_LOC_PTR(value = None):
        return COMMTABL_FULLWORD(6, value)
    def SDFPKG_LOC_ADDR(value = None):
        return COMMTABL_FULLWORD(7, value)
    def SDFPKG_SDFNAM_ADDR():
        return COMMTABL_ADDR+32
    def SDFPKG_SDFNAM():
        return MAKESTRING(8,SDFPKG_SDFNAM_ADDR)
    def SDFPKG_CSECTNAM_ADDR():
        return COMMTABL_ADDR+40
    def SDFPKG_CSECTNAM():
        return MAKESTRING(8,SDFPKG_CSECTNAM_ADDR)
    def SDFPKG_SREFNO_ADDR():
        return COMMTABL_ADDR+48
    def SDFPKG_SREFNO():
        return MAKESTRING(6,SDFPKG_SREFNO_ADDR)
    def SDFPKG_INCLCNT(value = None):
        return COMMTABL_HALFWORD(27, value)
    def SDFPKG_BLKNAM_ADDR():
        return COMMTABL_ADDR+56
    def SDFPKG_BLKNAM():
        return MAKESTRING(SDFPKG_BLKNLEN,SDFPKG_BLKNAM_ADDR)
    def SDFPKG_SYMBNAM_ADDR():
        return COMMTABL_ADDR+88
    def SDFPKG_SYMBNAM():
        return MAKESTRING(SDFPKG_SYMBNLEN,SDFPKG_SYMBNAM_ADDR)
    SDFPKG_PAGES_LEFT = 0 # BIT(16);
    '''
   BASED  PGING   RECORD:
            PAGEADDR   (420)    FIXED,
            END;
   BASED FORFCB   RECORD:
         FCBADDR   (128)  FIXED,
   END;
    '''
    PGING_base = 0
    FORFCB_base = 0
    # SDFPKG CALLS
    def _SDFPKG(mode):
        g.MONITOR(22, mode)
    def SET_SDF_BASED():
        nonlocal SDF_B_base, SDF_H_base, SDF_F_base
        SDF_B_base = SDFPKG_LOC_ADDR
        SDF_H_base = SDFPKG_LOC_ADDR
        SDF_F_base = SDFPKG_LOC_ADDR
    def LOCATE_SDF_SYMBp(symbNo):
        SDFPKG_SYMBNO(symbNo)
        g.MONITOR(22, 9)
        SET_SDF_BASED()
    def LOCATE_SDF_PTR(ptr):
        SDFPKG_LOC_PTR(ptr)
        g.MONITOR(22, 5)
        SET_SDF_BASED()
    def LOCATE_SDF_SYMBNAME(name):
        SDFPKG_SYMBNLEN(LENGTH(name))
        # ***FIXME***
        MOVE(SDFPKG_SYMBNLEN(),name,SDFPKG_SYMBNAM_ADDR())
        g.MONITOR(22,13)
        SET_SDF_BASED()
    def LOCATE_SDF_ROOT():
        g.MONITOR(22,7)
        SET_SDF_BASED()
    def LOCATE_SDF_BLOCKp(blockNo):
        SDFPKG_BLKNO(blockNo)
        g.MONITOR(22, 8)
        SET_SDF_BASED()
    def TERMINATE_SDFPKG():
        g.MONITOR(22,1)
        g.SDF_OPEN = g.FALSE
    
    def FIND(NAME):
        # FIND SYMBOL WITH GIVEN NAME, RETURNING ITS INDEX OR 0 IF NOT FOUND
        I = 0 # Note that I is local to this function.
        g.NAME_HASH = HASH(NAME, g.SYT_HASHSIZE);
        I = g.SYT_HASHSTART[g.NAME_HASH];
        while I > 0:
            if NAME == g.SYT_NAME(I): return I;
            I = g.SYT_HASHLINK(I);
        return 0;
    
    def DUPLICATE_NAME(NAME):
        # CHECK TO SEE IF NAME ALREADY EXISTS IN THE SYMBOL TABLE IN A FORM
        # THAT IMPLIES A MULTIPLE DECLARATION ERROR.  SET STRUC. FLAGS
        #DECLARE NAME CHARACTER;
        I = 0 # Local
        g.NAME_HASH = HASH(NAME, g.SYT_HASHSIZE);
        I = g.SYT_HASHSTART[g.NAME_HASH];
        while I > 0:
            if NAME == g.SYT_NAME(I):
                if I < g.PROCMARK: 
                    return g.FALSE;
                if not g.BUILDING_TEMPLATE: 
                    if g.SYT_CLASS(I) < g.TEMPLATE_CLASS:
                        return g.TRUE;
                    else: 
                        SET_DUPL_FLAG(I);
                else:
                    g.SYT_FLAGS(g.REF_ID_LOC, 
                                g.SYT_FLAGS(g.REF_ID_LOC) | g.DUPL_FLAG)
                    if g.SYT_CLASS(I) >= g.TEMPLATE_CLASS:
                        SET_DUPL_FLAG(I);
            I = g.SYT_HASHLINK(I);
        return g.FALSE;
    
    def SET_SYT_FLAGS(NDX):
        # SET SYT_FLAGS BASED ON SDF_SYMB_FLAGS
        #DECLARE NDX BIT(16);
        I = 0 # BIT(16);
        SDFFLAGS = 0 # FIXED
        FLAGS = 0 # FIXED
        pFLAGS = 13
        IN_FLAG = (SDF_EXCLUSIVE_FLAG, SDF_RIGID_FLAG,
                   SDF_INIT_FLAG, SDF_REMOTE_FLAG, SDF_LOCK_FLAG,
                   SDF_LATCH_FLAG, SDF_ACCESS_FLAG, SDF_CONSTANT_FLAG,
                   SDF_NAME_FLAG, SDF_AUTO_FLAG,
                   SDF_TEMPORARY_FLAG, SDF_ASSIGN_PARM_FLAG,
                   SDF_INPUT_PARM_FLAG)
        OUT_FLAG = (g.EXCLUSIVE_FLAG, g.RIGID_FLAG,
                    g.INIT_FLAG, g.REMOTE_FLAG, g.LOCK_FLAG, g.LATCHED_FLAG,
                    g.ACCESS_FLAG, g.CONSTANT_FLAG, g.NAME_FLAG, g.AUTO_FLAG,
                    g.TEMPORARY_FLAG, g.ASSIGN_PARM, g.INPUT_PARM)
        SDFFLAGS = SDF_SYMB_FLAGS()
        #-------------------------------------------------------------
        #----------------- DANNY STRAUSS DR102949 --------------------
        # IF A 16-BIT NAME VARIABLE WAS INITIALIZED TO A NON-REMOTE
        # VARIABLE IN A REMOTELY INCLUDED COMPOOL, IT'S NOW INVALID
        def SDF_INITIAL_CHECK():
            if (INCL_FLAGS & g.INCL_REMOTE_FLAG) != 0:  # REMOTE COMPOOL
                # IF VARIABLE IS REFERENCED BY A NAME VARIABLE
                if (SDFFLAGS & SDF_MISC_NAME_FLAG) != 0:
                    if g.SYT_TYPE(NDX) != g.TEMPL_NAME: # NOT A STRUC TEMPL
                        if (SDFFLAGS & SDF_REMOTE_FLAG) == 0: # NON-REMOTE
                            ERROR(d.CLASS_DI,21)
                            #OUTPUT = 'DANNY>>> CUR_SYM= ' + CUR_SYMBOL;
        SDF_INITIAL_CHECK()
        #-------------------------------------------------------------
        if (g.CONTROL[0x3] & 1) != 0: 
            g.OUTPUT(0, 'SET_SYT_FLAGS: SDFFLAGS = ' + \
                        HEX(SDFFLAGS, 8) + ' INCL_FLAGS = ' + \
                        HEX(INCL_FLAGS, 2))
        if ACCESS_COMPOOL: 
            FLAGS = g.READ_ACCESS_FLAG
        else: 
            FLAGS = 0
        if (SDFFLAGS & SDF_DENSE_FLAG) != 0:
            FLAGS = FLAGS | g.DENSE_FLAG
        else: 
            FLAGS = FLAGS | g.ALIGNED_FLAG
        #********** FIX FOR DR100579, ROBERT HANDLEY 12/88  ************
        # SET THE VARIABLE'S REMOTE FLAG IF THE COMPOOL IS INCLUDED
        # REMOTELY. EXCLUDE STRUCTURE TEMPLATE SYMBOL NAMES AND NAME
        # VARIABLES.
        #------------------- DANNY STRAUSS DR100579 ------------------------
        # INCLUDED_REMOTE MEANS VARIABLE LIVES REMOTE ONLY BECAUSE
        # IT WAS INCLUDED REMOTE. (IT RESIDES IN #P, NOT IN #R)
        if (INCL_FLAGS & g.INCL_REMOTE_FLAG) != 0: # REMOTE COMPOOL
            if (g.SYT_CLASS(NDX) != g.TEMPLATE_CLASS): #DO
                # NOT A NAME VARIABLE & NOT INITIALLY DECLARED REMOTE
                if ((SDFFLAGS & SDF_NAME_FLAG) == 0) and \
                        ((SDFFLAGS & SDF_REMOTE_FLAG) == 0):
                    FLAGS = FLAGS | g.REMOTE_FLAG | g.INCLUDED_REMOTE
                # FOR NAME VARIABLES, SET THAT THEY NOW LIVE REMOTE
                if ((SDFFLAGS & SDF_NAME_FLAG) != 0):
                    FLAGS = FLAGS | g.INCLUDED_REMOTE;
        #END
        #*************** END OF FIX FOR DR100579  **********************
        for I  in range(0, pFLAGS):
            if (SDFFLAGS & IN_FLAG(I)) != 0:
                FLAGS = FLAGS | OUT_FLAG(I)
        g.SYT_FLAGS(NDX, FLAGS)
        g.NAME_IMPLIED = ((FLAGS & g.NAME_FLAG) != 0)
        g.TEMPORARY_IMPLIED = ((FLAGS & g.TEMPORARY_FLAG) != 0)
        if (g.CONTROL[0x3] & 1) != 0: 
            OUTPUT(0, 'SET_SYT_FLAGS:    FLAGS = ' + HEX(FLAGS, 8))
        return;
    # END SET_SYT_FLAGS;
    
    def SET_TYPE_AND_LEN(NDX):
        # SET SYT_TYPE AND VAR_LENGTH FOR VARIABLES AND FUNCTIONS
        #DECLARE NDX BIT(16);
        TYPE = 0 # local BIT(16);
        P1_TYPE = (0, g.BIT_TYPE, g.CHAR_TYPE, g.MAT_TYPE, # C13335
                   g.VEC_TYPE, g.SCALAR_TYPE, g.INT_TYPE, 0, 0, g.BIT_TYPE,
                   g.BIT_TYPE, g.MAT_TYPE,
                   g.VEC_TYPE, g.SCALAR_TYPE, g.INT_TYPE, 0, g.MAJ_STRUC, 
                   g.EVENT_TYPE) # locl BIT(8)
        STRUC_NAME = "" # local  CHARACTER;
        g.SYT_TYPE(NDX, P1_TYPE[SDF_SYMB_TYPE])
        TYPE = P1_TYPE[SDF_SYMB_TYPE]
        if (TYPE >=g.MAT_TYPE) and (TYPE<=g.INT_TYPE): #DO
            if SDF_SYMB_TYPE > 8:
                g.SYT_FLAGS(NDX, g.SYT_FLAGS(NDX) | g.DOUBLE_FLAG)
            else: 
                g.SYT_FLAGS(NDX, g.SYT_FLAGS(NDX) | g.SINGLE_FLAG)
        #END
        if (TYPE == g.CHAR_TYPE) or (TYPE == g.MAT_TYPE):
            g.VAR_LENGTH(NDX, SDF_SYMB_VAR_LENGTH)
        elif (TYPE == g.BIT_TYPE) or (TYPE == g.VEC_TYPE):
            g.VAR_LENGTH(NDX, SDF_SYMB_VAR_LENGTH & 0xFF)
        elif (TYPE == g.MAJ_STRUC) and (SDF_SYMB_VAR_LENGTH != 0): #DO
            TEMP_PTR = SDFPKG_LOC_PTR;
            LOCATE_SDF_SYMBp(SDF_SYMB_VAR_LENGTH);
            STRUC_NAME = NEW_STRING(SDFPKG_SYMBNAM);
            LOCATE_SDF_PTR(TEMP_PTR);
            g.STRUC_PTR = FIND(STRUC_NAME);
            if g.STRUC_PTR == 0: #DO
                ERROR(d.CLASS_DU, 5, SUBSTR(STRUC_NAME,1));
                g.STRUC_PTR = ENTER(STRUC_NAME, g.TEMPLATE_CLASS);
                g.SYT_TYPE(g.STRUC_PTR, g.TEMPL_NAME)
                g.SYT_FLAGS(g.STRUC_PTR, g.EVIL_FLAG)
                if g.BUILDING_TEMPLATE:
                    g.SYT_FLAGS(g.REF_ID_LOC, g.SYT_FLAGS(g.REF_ID_LOC) | g.EVIL_FLAG)
            #END
            g.STRUC_DIM = 0 # SO NO ARRAY CHECKS IN CHECK_STRUC_CONFLICT
            CHECK_STRUC_CONFLICTS()
            g.VAR_LENGTH(NDX, g.STRUC_PTR)
            g.SYT_XREF(g.STRUC_PTR, ENTER_XREF(g.SYT_XREF(g.STRUC_PTR), g.XREF_REF))
        #END
        if (g.CONTROL[0x3] & 1) != 0:
            OUTPUT(0, 'SET_TYPE_AND_LEN: TYPE = ' + TYPE + ', LENGTH = ' + \
                       g.VAR_LENGTH(NDX))
        return;
    # END SET_TYPE_AND_LEN;
    
    def ENTER_SDF_VAR(CLASS):
        # ENTER A VARIABLE OR FUNCTION FROM AN SDF INTO THE SYMBOL TABLE
        #DECLARE CLASS BIT(16);
        I = 0 # local BIT(16);
        if DUPLICATE_NAME(g.BCD): #DO
            ERROR(d.CLASS_PM, 1, g.BCD)
            return;
        #END
        g.ID_LOC = ENTER(g.BCD, CLASS)
        if (g.CONTROL[0x3] & 1) != 0:
            OUTPUT(0, 'ENTER_SDF_VAR: ID_LOC = ' + g.ID_LOC + ', NAME = ' + \
                      g.BCD + ', CLASS = ' + CLASS)
        SET_SYT_FLAGS(g.ID_LOC)
        SET_TYPE_AND_LEN(g.ID_LOC)
        g.SYT_ADDR(g.ID_LOC, SDF_SYMB_ADDR)
        g.SYT_LOCKp(g.ID_LOC, SDF_SYMB_LOCKp)
        if SDF_SYMB_ARRAY_OFF == 0: 
            g.SYT_ARRAY(g.ID_LOC, 0)
        elif g.SYT_TYPE(g.ID_LOC) == g.MAJ_STRUC: #DO
            I = SDF_SYMB_ARRAY(0)
            if I < 0: 
                g.SYT_ARRAY(g.ID_LOC, -g.ID_LOC)
            elif I == 1: 
                g.SYT_ARRAY(g.ID_LOC, 0)
            else: 
                g.SYT_ARRAY(g.ID_LOC, I)
        #END
        else: #DO
            # ENTER ARRAY VALUES
            g.N_DIM = SDF_SYMB_NDIM;
            for I  in range(0, g.N_DIM):
                g.S_ARRAY[I] = SDF_SYMB_ARRAY(I);
            #END
            if g.S_ARRAY[0] < 0: 
                g.S_ARRAY[0] = -g.ID_LOC
            ENTER_DIMS()
            g.SYT_FLAGS(g.ID_LOC, g.SYT_FLAGS(g.ID_LOC) | g.ARRAY_FLAG)
        #END
        if (SDF_SYMB_FLAGS & SDF_LIT_FLAG) != 0: #DO
            # ENTER LITERAL
            TEMP_PTR = SDFPKG_LOC_PTR;
            LOCATE_SDF_PTR(SDF_SYMB_LIT_PTR);
            if g.SYT_TYPE(g.ID_LOC) == g.CHAR_TYPE:
                SAVE_LITERAL(0,MAKESTRING(SDF_B + 1, SDFPKG_LOC_ADDR + 1))
            # ARITH. LIT
            else: 
                SAVE_LITERAL(1, SDFPKG_LOC_ADDR,0,1)
            #MOD-DR109083
            g.SYT_PTR(g.ID_LOC, -g.LIT_TOP())
            LOCATE_SDF_PTR(TEMP_PTR)
        #END
        return;
    # END ENTER_SDF_VAR;
    
    def ENTER_SDF_LABEL(CLASS):
        # ENTER A LABEL INTO THE SYMBOL TABLE FROM AN SDF
        # COMPILATION UNIT IS TREATED SEPARATELY IN INCLUDE_SDF PROPER
        #DECLARE CLASS BIT(16);
        P1_TYPE = (0, g.PROG_LABEL, g.PROC_LABEL, 0, g.COMPOOL_LABEL, 
                   g.TASK_LABEL, 0, 0) # BIT(8)
        if DUPLICATE_NAME(g.BCD):
            #COMPOOL CLOSE LABELS CAN BE DUPLICATED
            if SDF_SYMB_TYPE != 7: 
                ERROR(d.CLASS_PL, 2, g.BCD)
        g.ID_LOC = ENTER(g.BCD, CLASS)
        if (g.CONTROL[0x3] & 1) != 0:
            OUTPUT(0, 'ENTER_SDF_LABEL: ID_LOC = ' + g.ID_LOC + ', NAME = ' + \
                      g.BCD + ', CLASS = ' + CLASS)
        SET_SYT_FLAGS(g.ID_LOC);
        g.SYT_TYPE(g.ID_LOC, P1_TYPE(SDF_SYMB_TYPE))
        g.SYT_ADDR(g.ID_LOC, SDF_SYMB_ADDR)
        return;
    # END ENTER_SDF_LABEL;
    
    def ENTER_SDF_TEMPLATE():
        nonlocal CUR_SYMBOL, NEXT_SYMBOL
        # ENTER A TEMPLATE FROM AN SDF
        FATHER = [0] * (g.MAX_STRUC_LEVEL + 1) # local BIT(16);
        CLASS = 0 # local BIT(16)
        LEVEL = 0 # local BIT(16);
        if DUPLICATE_NAME(g.BCD):
            ERROR(d.CLASS_PM, 2, SUBSTR(g.BCD,1))
        g.REF_ID_LOC = ENTER(g.BCD, g.TEMPLATE_CLASS)
        if (g.CONTROL[0x3] & 1) != 0:
            OUTPUT(0, 'ENTER_SDF_TEMPLATE: ID_LOC = ' + g.REF_ID_LOC + \
                      ', NAME = ' + g.BCD)
        g.SYT_TYPE(g.REF_ID_LOC, g.TEMPL_NAME)
        SET_SYT_FLAGS(g.REF_ID_LOC)
        if (SDF_SYMB_FLAGS & SDF_MISC_NAME_FLAG) != 0:
            g.SYT_FLAGS(g.REF_ID_LOC, g.SYT_FLAGS(g.REF_ID_LOC) | g.MISC_NAME_FLAG)
        g.STRUC_SIZE = 0
        g.BUILDING_TEMPLATE = g.TRUE
        LEVEL = 0
        FATHER[0] = g.REF_ID_LOC
        g.SYT_LINK1(g.REF_ID_LOC, g.REF_ID_LOC + 1)
        # WALK:  I'm at a loss as to why this lael was ever present, since
        # there were no references to it. 
        #DO UNTIL LEVEL < 0;
        while LEVEL >= 0: # Note: LEVEL starts at 0, so there's always an iteration.
            LOCATE_SDF_SYMBp(NEXT_SYMBOL)
            CUR_SYMBOL = NEXT_SYMBOL
            NEXT_SYMBOL = SDF_SYMB_DECLARE_LINK()
            g.BCD = NEW_STRING(SDFPKG_SYMBNAM())
            CLASS = SDF_SYMB_CLASS()
            if CLASS == 4: 
                ENTER_SDF_VAR(g.TEMPLATE_CLASS)
            elif CLASS == 5: 
                ENTER_SDF_LABEL(g.TPL_LAB_CLASS)
            else: 
                ENTER_SDF_VAR(g.TPL_FUNC_CLASS)
            if SDF_SYMB_LINK1() != 0: #DO
                if SDF_SYMB_LINK2() < 0: 
                    g.SYT_LINK2(g.ID_LOC, -FATHER[LEVEL])
                else: 
                    g.SYT_LINK2(g.ID_LOC, 0)
                # TO BE FILLED IN LATER
                LEVEL = LEVEL + 1;
                FATHER[LEVEL] = g.ID_LOC;
                g.SYT_LINK1(g.ID_LOC, g.ID_LOC + 1)
            #END
            else: #DO
                g.SYT_LINK1(g.ID_LOC, 0)
                if SDF_SYMB_LINK2() > 0: 
                    g.SYT_LINK2(g.ID_LOC, g.ID_LOC + 1)
                else: #DO
                    g.SYT_LINK2(g.ID_LOC, -FATHER[LEVEL])
                    while g.SYT_LINK2(FATHER(LEVEL)) < 0:
                        LEVEL = LEVEL - 1
                    #END
                    if LEVEL > 0: #DO
                        g.SYT_LINK2(FATHER(LEVEL), g.ID_LOC + 1)
                        if (g.CONTROL[0x3] & 1) != 0:
                            OUTPUT(0, 'ENTER_SDF_TEMPLATE: LINK2(' + 
                                      FATHER[LEVEL] + 
                                      ') = ' + g.ID_LOC + 1)
                    #END
                    LEVEL = LEVEL - 1
                #END
                g.STRUC_SIZE = g.STRUC_SIZE + \
                               ICQ_TERMp(g.ID_LOC) * ICQ_ARRAYp(g.ID_LOC)
            #END
            if (g.CONTROL[0x3] & 1) != 0:
                OUTPUT(0, 'ENTER_SDF_TEMPLATE: LINK1 = ' + \
                          g.SYT_LINK1(g.ID_LOC) + \
                          ', LINK2 = ' + g.SYT_LINK2(g.ID_LOC))
        # END WALK;
        g.BUILDING_TEMPLATE = g.FALSE
        g.SYT_ADDR(g.REF_ID_LOC, g.STRUC_SIZE)
        return;
    # END ENTER_SDF_TEMPLATE;
    
    def ENTER_SDF_MACRO():
        nonlocal TEMP_PTR
        # ENTER A REPLACE MACRO FROM AN SDF
        MACRO_NDX = 0 # local BIT(16)
        pBYTES = 0 # local BIT(16);
        I = 0 # local BIT(16);
        if DUPLICATE_NAME(g.BCD): #DO
            ERROR(d.CLASS_PM, 1, g.BCD)
            return;
        #END
        MACRO_NDX = ENTER(g.BCD, g.REPL_CLASS)
        if (g.CONTROL[0x3] & 1) != 0:
            OUTPUT(0, 'ENTER_SDF_MACRO: ID_LOC = ' + MACRO_NDX + \
                      ', MACRO = ' + g.BCD)
        TEMP_PTR = SDFPKG_LOC_PTR()
        LOCATE_SDF_PTR(SDF_SYMB_REPL_PTR())
        g.MACRO_ARG_COUNT = SDF_REPL_ARG_CNT();
        for I  in range(1, g.MACRO_ARG_COUNT + 1):
            g.BCD = NEW_STRING(SDF_REPL_ARG_NAME(I))
            g.ID_LOC = ENTER(g.BCD, g.REPL_ARG_CLASS)
            if (g.CONTROL[0x3] & 1) != 0:
                OUTPUT(0, 'ENTER_SDF_MACRO: ID_LOC = ' + g.ID_LOC + \
                          ', ARG = ' + g.BCD)
            g.SYT_FLAGS(g.ID_LOC, g.INACTIVE_FLAG)
        #END
        g.VAR_LENGTH(MACRO_NDX, g.MACRO_ARG_COUNT)
        g.START_POINT = g.FIRST_FREE
        g.SYT_ADDR(MACRO_NDX, g.FIRST_FREE)
        # MOVE_TEXT:  This label is never referenced.
        while SDF_REPL_NEXT_PTR() != 0:
            LOCATE_SDF_PTR(SDF_REPL_NEXT_PTR)
            pBYTES = SDF_REPL_pBYTES()
            for I in range(1, pBYTES + 1):
                NEXT_ELEMENT(g.MACRO_TEXTS)
            #END
            MOVE(pBYTES, SDF_REPL_TEXT_ADDR(), ADDR(g.MACRO_TEXTS[g.FIRST_FREE]));
            g.FIRST_FREE = g.FIRST_FREE + pBYTES;
        #END
        FINISH_MACRO_TEXT();
        g.EXTENT(MACRO_NDX, g.REPLACE_TEXT_PTR)
        LOCATE_SDF_PTR(TEMP_PTR);
        return;
    # END ENTER_SDF_MACRO;
    
    def ENTER_SDF_THING():
        # ENTERS LAST SDF VARIABLE LOCATED INTO THE SYMBOL TABLE BY CALLING THE
        # APPROPRIATE ROUTINE
        if (g.CONTROL[0x3] & 1) != 0: 
            OUTPUT(0, 'ENTER_SDF_THING: ENTERED')
        g.BCD = NEW_STRING(SDFPKG_SYMBNAM);
        sw = SDF_SYMB_CLASS()
        if sw == 0:
            pass # NOT USED
        elif sw == 1:
            ENTER_SDF_VAR(g.VAR_CLASS) # SDF VARIABLE CLASS
        elif sw == 2: 
            #SDF LABEL CLASS
            if SDF_SYMB_TYPE() == 9: 
                ENTER_SDF_MACRO()
            elif SDF_SYMB_TYPE() != 8: 
                ENTER_SDF_LABEL(g.LABEL_CLASS)
        elif sw == 3:
            ENTER_SDF_VAR(g.FUNC_CLASS) # SDF FUNCTION CLASS
        elif sw == 4: 
            # SDF TEMPLATE CLASS
            if (SDF_SYMB_FLAGS() & SDF_TPL_HDR_FLAG) != 0:
                ENTER_SDF_TEMPLATE()
            else: 
                ERROR(d.CLASS_XI, 8, g.BCD)
        elif sw == 5:
            ERROR(d.CLASS_XI, 8, g.BCD) # SDF TEMPLATE LABEL CLASS
        elif sw == 6:
            ERROR(d.CLASS_XI, 8, g.BCD) # SDF TEMPLATE FUNCTION
        #END
        return;
    # END ENTER_SDF_THING;
    
    def ENTER_COMSUB_ARGS():
        nonlocal NEXT_SYMBOL, CUR_SYMBOL
        # LOGIC TO ENTER APPROPRIATE STUFF AND THEN ARGUMENTS FOR COMSUBS
        SAVE_FIRST = 0 # local BIT(16)
        if (g.CONTROL[0x3] & 1) != 0: 
            OUTPUT(0, 'ENTER_COMSUB_ARGS: ENTERED')
        # PASS OVER PARAMETERS AND ENTER TEMPLATES, IF ANY
        SAVE_FIRST = NEXT_SYMBOL
        first = True
        while first or CUR_SYMBOL == LAST_COMSUB_SYMB:
            first = False
            CUR_SYMBOL = NEXT_SYMBOL
            LOCATE_SDF_SYMBp(CUR_SYMBOL)
            NEXT_SYMBOL = SDF_SYMB_DECLARE_LINK()
            if (SDF_SYMB_FLAGS() & SDF_PARM_FLAGS) == 0: #DO
                g.BCD = NEW_STRING(SDFPKG_SYMBNAM)
                if BYTE(g.BCD) == BYTE(' '):
                    ENTER_SDF_TEMPLATE();
            #END
        #END
        # NOW ENTER PARAMETERS
        NEXT_SYMBOL = SAVE_FIRST;
        g.SYT_PTR(g.BLOCK_SYTREF[g.NEST], g.NDECSY() + 1)
        # POINT TO FIRST ARG
        first = True
        while first or CUR_SYMBOL == LAST_COMSUB_SYMB:
            first = False
            CUR_SYMBOL = NEXT_SYMBOL
            LOCATE_SDF_SYMBp(CUR_SYMBOL)
            NEXT_SYMBOL = SDF_SYMB_DECLARE_LINK
            if (SDF_SYMB_FLAGS() & SDF_PARM_FLAGS) == 0: 
                break
            ENTER_SDF_THING()
        #END
        return;
    # END ENTER_COMSUB_ARGS;
    
    def ENTER_COMPOOL_VARS():
        nonlocal ACCESS_COMPOOL, NEXT_SYMBOL, CUR_SYMBOL
        # ENTER VARIABLES FROM A COMPOOL SDF
        TEMP = 0 # local BIT(8)
        if (g.CONTROL[0x3] & 1) != 0: 
            OUTPUT(0, 'ENTER_COMPOOL_VARS: ENTERED')
        ACCESS_COMPOOL = (g.SYT_FLAGS(g.BLOCK_SYTREF[g.NEST]) & g.ACCESS_FLAG) != 0
        g.PROCMARK = 1
        # AUGMENT SDFPKG PAGING AREA IF NECESSARY/POSSIBLE
        TEMP=RECORD_ALLOC(SYM_TAB)-RECORD_USED(SYM_TAB)
        if TEMP <= pBLK_SYMBS: #DO
            TEMP = RECORD_USED(SYM_TAB) + pBLK_SYMBS
            while RECORD_ALLOC(SYM_TAB)<=TEMP:
                NEEDMORE_SPACE(SYM_TAB)
            #END
        #END
        SDFPKG_NPAGES=(FREELIMIT-FREESTRING_MIN-g.FREEPOINT-32*pBLK_SYMBS)/1680
        SDFPKG_NPAGES = MIN(SDFPKG_NPAGES, pSDF_PAGES - 3)
        SDFPKG_NPAGES = MIN(SDFPKG_NPAGES, SDFPKG_PAGES_LEFT)
        if SDFPKG_NPAGES > 0: #DO
            RECORD_CONSTANT(PGING,SDFPKG_NPAGES,g.UNMOVEABLE)
            SDFPKG_APGAREA=ADDR(PGING(0).PAGEADDR(0))
            SDFPKG_AFCBAREA, SDFPKG_NBYTES = 0
            _SDFPKG(2)
            # AUGMENT PAGING AREA
        #END
        #ENTER EVERYTHING
        while NEXT_SYMBOL != 0:
            LOCATE_SDF_SYMBp(NEXT_SYMBOL);
            #CUR_SYMBOL = NEXT_SYMBOL;  DANNY STRAUSS
            NEXT_SYMBOL = SDF_SYMB_DECLARE_LINK;
            if SDF_SYMB_CLASS() == SDF_VAR_CLASS:  # A VARIABLE OR CONSTANT
                if (SDF_SYMB_FLAGS() & SDF_LIT_FLAG) == 0: # ITS A VARIABLE
                    CSECT_LENGTH[(SDF_SYMB_FLAGS()&SDF_REMOTE_FLAG)!=0] = \
                        MAX(CSECT_LENGTH((SDF_SYMB_FLAGS()&SDF_REMOTE_FLAG)!=0),
                            SDF_SYMB_ADDR()+SDF_SYMB_EXTENT())
            # INCLUDE_OK SETS C TO FIRST TOKEN AFTER INCLUDE OPTIONS
            if g.C[0] != ':': 
                ENTER_SDF_THING()
        #END
        # INCLUDE_OK SETS C TO FIRST TOKEN AFTER INCLUDE OPTIONS
        if g.C[0] == ':': #DO
            # ENTER FROM A LIST
            g.SYT_FLAGS(g.BLOCK_SYTREF[g.NEST], 
                        g.SYT_FLAGS(g.BLOCK_SYTREF[g.NEST]) | g.SDF_INCL_LIST)
            # FLAG AS PARTIAL INCLUDE
            t.D_CONTINUATION_OK = g.TRUE;
            g.C[0] = t.D_TOKEN();
            # LIST:    
            while g.C[0] != '':
                if g.C[0] == ',': #DO
                    g.C[0] = t.D_TOKEN();
                    continue # REPEAT LIST;
                #END
                if g.C[0] == ';': 
                    break # ESCAPE LIST;
                if g.C[0] == 'STRUCTURE':
                    g.C[0] = g.X1 + t.D_TOKEN()
                LOCATE_SDF_SYMBNAME(g.C[0])
                if SDFPKG_CRETURN() == 0: #DO
                    NEXT_SYMBOL = SDF_SYMB_DECLARE_LINK()
                    ENTER_SDF_THING()
                #END
                elif BYTE(g.C[0]) == BYTE(' '):
                    ERROR(d.CLASS_XI, 6, SUBSTR(g.C[0],1))
                else: 
                    ERROR(d.CLASS_XI, 7, g.C[0])
                g.C[0] = t.D_TOKEN()
            # END LIST;
            t.D_CONTINUATION_OK = g.FALSE
        #END
        ACCESS_COMPOOL = g.FALSE
        return
    # END ENTER_COMPOOL_VARS;
    
    def SDF_FOUND(): # BIT(1)):
        # ROUTINE THAT TRIES TO FIND APPLICABLE SDF FOR AN INCLUDE
        COMPILER = "" # local CHARACTER
        DDBAD = [g.FALSE,g.FALSE] # local BIT(1)
        MISC_VAL = (8,12) # local BIT(16)
        SOURCE_FLAG = (0x80,0x40) # local BIT(8)
        OLD_SDF = 0 # local BIT(1)
        I = 0 # local BIT(16)
        REASON = (' TOO OLD', ' NOT FOUND') # local CHARACTER
        # ALLOCATE SPACE FOR SDFPKG
        COMMTABL_BYTE_base = COMMTABL_base
        COMMTABL_HALFWORD = COMMTABL_base
        COMMTABL_FULLWORD = COMMTABL_base
        COMMTABL_ADDR = COMMTABL_base
        '''
        Unlike the original, we just assume you have all the memory we'd ever
        need, and thus statically allocate the memory for the paging and FCB
        areas based on their maximum possible usage.
        if RECORD_ALLOC(INIT_APGAREA) == 0: #DO
            SDFPKG_NPAGES = 3;
            # PAGING AREA SIZE
            RECORD_CONSTANT(INIT_APGAREA,0,g.UNMOVEABLE);
            RECORD_USED(INIT_APGAREA) = RECORD_ALLOC(INIT_APGAREA);
            SDFPKG_NBYTES = 512;
            # SIZE OF INITIAL FCB AREA
            RECORD_CONSTANT(INIT_AFCBAREA,0,g.UNMOVEABLE);
            RECORD_USED(INIT_AFCBAREA) = RECORD_ALLOC(INIT_AFCBAREA);
        #END
        '''
        # INITIALIZE
        COMPILER = SUBSTR(STRING(MONITOR(23)),0,4);
        SDF_NAME = '##' + SUBSTR(DESCORE(UNIT),2,6);
        OLD_SDF = g.FALSE;
        # TRY HALSDF, THEN OUTPUT5.  AN SDF IS GOOD IF:
        #    THE DDNAME HAS BEEN DEFINED
        #    THE SDF EXISTS
        #    THE SDF WAS MADE BY A COMPILATION FOR THE APPROPRIATE OBJECT
        #       MACHINE, AND
        #    THE SDF WAS CREATED BY A PHASE3 OF VERSION >= INCLUDABLE_VERSION#
        for I in range(0, 1 + 1):
            if DDBAD(I): 
                continue
            SDFPKG_NPAGES = 3;
            SDFPKG_APGAREA = ADDR(g.INIT_APGAREA[0].AREAPG(0));
            SDFPKG_NBYTES = 512;
            SDFPKG_AFCBAREA = ADDR(g.INIT_AFCBAREA[0].AREAFCB(0));
            SDFPKG_MISC = MISC_VAL(I);
            MONITOR(22, 0, COMMTABL_ADDR);
            if SDFPKG_CRETURN != 0: 
                DDBAD(I, g.TRUE)
            else: #DO
                # DDNAME EXISTS
                g.SDF_OPEN = g.TRUE;
                SDFPKG_PAGES_LEFT = SDFPKG_NPAGES;
                MOVE(8, SDF_NAME, SDFPKG_SDFNAM_ADDR);
                _SDFPKG(4);
                if SDFPKG_CRETURN == 12: #DO
                    # INSUFFICIENT FCB AREA
                    SDFPKG_NPAGES, SDFPKG_APGAREA = 0;
                    # SDFPKG SETS SDFPKG_NBYTES TO AMOUNT NEEDED
                    RECORD_CONSTANT(FORFCB,SHR(SDFPKG_NBYTES+511,9),g.UNMOVEABLE);
                    SDFPKG_AFCBAREA=ADDR(FORFCB(0).FCBADDR(0));
                    _SDFPKG(2);
                    # TELL SDFPKG ABOUT EXTRA SPACE
                    _SDFPKG(4);
                    # RE-TRY SELECT
                #END
                REV = SDFPKG_BLKNO;
                CAT = SDFPKG_SYMBNO;
                if SDFPKG_CRETURN == 0: #DO
                    # SDF FOUND
                    LOCATE_SDF_ROOT;
                    if COMPILER == SDF_ROOT_COMPILER: #DO
                        # CORRECT OBJECT
                        LOCATE_SDF_PTR(0);
                        SDF_VERSIONp=SDF_H;
                        if SDF_H >= INCLUDABLE_VERSIONp: #DO
                            # GOOD SDF
                            INCL_FLAGS = INCL_FLAGS | SOURCE_FLAG(I);
                            REVSTR = 'RVL ' + STRING(0x01000000 | ADDR(REV)) + \
                                     ' CATENATION NUMBER ' + CAT;
                            return g.TRUE;
                        #END
                        else: OLD_SDF = g.TRUE;
                    #END
                #END
                TERMINATE_SDFPKG;
            #END
            # OF DDNAME OK
        #END
        # OF DO I =
        # IF WE GET HERE, WE HAVE FAILED
        if RECORD_ALLOC(FORFCB) >0:
            RECORD_FREE(FORFCB);
        if OLD_SDF: 
            I = 0;
        else: I = 1;
        COMPILER = COMPILER + ' SDF ' + SDF_NAME;
        if (INCL_FLAGS & INCL_TEMPLATE_FLAG) !=0:
            OUTPUT(0, g.X8 + g.STARS + 'INCLUDED FROM TEMPLATE: ' + COMPILER + \
                      REASON(I))
        else: 
            ERROR(d.CLASS_XI, I+9, COMPILER);
        return g.FALSE;
    # END SDF_FOUND;
    
    # THIS IS THE START OF INCLUDE_SDF PROPER
    # CHECK FOR LEGAL INCLUDE
    if g.NEST > 0: #DO
        ERROR(d.CLASS_PE, 1);
        return g.TRUE;
        # DON'T TRY THE TEMPLATE
    #END
    elif BLOCK_MODE > 0: #DO
        ERROR(d.CLASS_PE, 2);
        return g.TRUE;
    #END
    # CHECK TO SEE IF AN SDF EXISTS
    if not SDF_FOUND: 
        return g.FALSE;
    # ENTER THE COMPILATION UNIT INTO THE SYMBOL TABLE
    LOCATE_SDF_ROOT;
    SDF_ROOT_FLAGS = SDF_H(0);
    ##DFLAG LOOK AT ROOT FLAGS
    LAST_COMSUB_SYMB = SDF_ROOT_COMSUB_END;
    UNIT_SYMBp = SDF_ROOT_UNIT_SYMBp;
    pSDF_PAGES = SDF_ROOT_LAST_PAGE + 1;
    LOCATE_SDF_BLOCKp(SDF_ROOT_UNIT_BLKp);
    if SDFPKG_BLKNAM != UNIT: #DO
        UNIT = NEW_STRING(SDFPKG_BLKNAM);
        # ERROR CALL DELETED AT IBM REQUEST
    #END
    if DUPLICATE_NAME(UNIT):
        ERROR(d.CLASS_PL, 2, UNIT);
    # BUT CONTINUE ANYWAY
    pBLK_SYMBS = SDF_BLK_LAST_SYMBp - SDF_BLK_FIRST_SYMBp + 1;
    g.ID_LOC = ENTER(UNIT, g.LABEL_CLASS);
    BLK_TYPE = SDF_BLK_CATEGORY;
    FLAGS = g.EXTERNAL_FLAG | g.DEFINED_LABEL | g.SDF_INCL_FLAG;
    if (INCL_FLAGS & g.INCL_REMOTE_FLAG) != 0: #DO
        if BLK_TYPE == 4: # COMPOOL
            FLAGS = FLAGS | g.REMOTE_FLAG;
        else: ERROR(d.CLASS_XI, 5);
        g.TPL_REMOTE = g.FALSE;
    #END
    for g.I  in range(0, pBLK_FLAGS + 1):
        if (SDF_BLK_FLAGS & IN_BLK_FLAG(g.I)) != 0:
            FLAGS = FLAGS | OUT_BLK_FLAG(g.I);
    #END
    g.SYT_FLAGS(g.ID_LOC, FLAGS);
    # DO BLOCK "ENTRY"
    g.NEST = 1;
    g.SCOPEp_STACK[g.NEST] = SCOPEp;
    g.SYT_SCOPE(g.ID_LOC, MAX_SCOPEp + 1)
    SCOPEp = MAX_SCOPEp + 1
    MAX_SCOPEp = MAX_SCOPEp + 1
    NEXT_ELEMENT(CSECT_LENGTHS);
    g.PROCMARK_STACK[g.NEST] = g.PROCMARK;
    g.PROCMARK, g.REGULAR_PROCMARK = g.NDECSY + 1;
    g.BLOCK_SYTREF[g.NEST] = g.ID_LOC;
    g.SYT_PTR(g.ID_LOC, g.PROCMARK)
    ENTER_LAYOUT(g.ID_LOC);
    SYT_LOCKp(g.ID_LOC, SDF_BLK_VERSIONp)
    # ENTER SYMBOLS BASED ON BLOCK TYPE
    LOCATE_SDF_SYMBp(UNIT_SYMBp);
    NEXT_SYMBOL = SDF_SYMB_DECLARE_LINK;
    if BLK_TYPE == 0:
        pass # UNDEFINED
    elif BLK_TYPE == 1:
        # PROGRAM
        g.BLOCK_MODE[g.NEST] = g.PROG_MODE;
        g.SYT_TYPE(g.ID_LOC, g.PROG_LABEL)
        g.SYT_FLAGS(g.ID_LOC, g.SYT_FLAGS(g.ID_LOC) | g.LATCHED_FLAG)
    elif BLK_TYPE == 2:
        # PROCEDURE
        #- CR11120 ----------------- #DFLAG ------------------------------
        # IF DATA_REMOTE FLAG SET IN SDF, THEN SET THE COMSUB'S REMOTE
        # FLAG SO THAT OBJECT GENERATOR KNOWS TO SET BIT IN ESD CARD FOR
        # AUTOMATED PRELINKER PLACEMENT IN THE REMOTE #D CSECT.
        if ((SDF_ROOT_FLAGS & 0x0004) != 0):
            g.SYT_FLAGS(g.ID_LOC, g.SYT_FLAGS(g.ID_LOC) | g.REMOTE_FLAG)
        #-----------------------------------------------------------------
        g.BLOCK_MODE[g.NEST] = g.PROC_MODE;
        g.SYT_TYPE(g.ID_LOC, g.PROC_LABEL)
        if LAST_COMSUB_SYMB != UNIT_SYMBp:
            ENTER_COMSUB_ARGS();
    elif BLK_TYPE == 3:
        # FUNCTION
        #- CR11120 ----------------- #DFLAG ------------------------------
        # IF DATA_REMOTE FLAG SET IN SDF, THEN SET THE COMSUB'S REMOTE
        # FLAG SO THAT OBJECT GENERATOR KNOWS TO SET BIT IN ESD CARD FOR
        # AUTOMATED PRELINKER PLACEMENT IN THE REMOTE #D CSECT.
        if ((SDF_ROOT_FLAGS & 0x0004) != 0):
            g.SYT_FLAGS(g.ID_LOC, g.SYT_FLAGS(g.ID_LOC) | g.REMOTE_FLAG)
        #-----------------------------------------------------------------
        g.BLOCK_MODE[g.NEST] = g.FUNC_MODE;
        g.SYT_CLASS(g.ID_LOC, g.FUNC_CLASS)
        SET_TYPE_AND_LEN(g.ID_LOC);
        if LAST_COMSUB_SYMB != UNIT_SYMBp:
            ENTER_COMSUB_ARGS()
    elif BLK_TYPE == 4:
        # COMPOOL
        g.BLOCK_MODE[g.NEST] = g.CMPL_MODE;
        g.SYT_TYPE(g.ID_LOC, g.COMPOOL_LABEL)
        CSECT_LENGTHS(SCOPEp).PRIMARY = PRIMARY_LENGTH;
        CSECT_LENGTHS(SCOPEp).REMOTE = REMOTE_LENGTH;
        CSECT_LENGTH[0] = 0
        CSECT_LENGTH[1] = 0
        ENTER_COMPOOL_VARS;
        CSECT_LENGTHS(SCOPEp).PRIMARY = PRIMARY_LENGTH;
        CSECT_LENGTHS(SCOPEp).REMOTE = REMOTE_LENGTH;
    elif BLK_TYPE == 5:
        pass # TASK
    elif BLK_TYPE == 6:
        pass # UPDATE
    #END OF DO CASE BLK_TYPE
    # PERFORM BLOCK "CLOSING"
    g.SYT_FLAGS(g.NDECSY, g.SYT_FLAGS(g.NDECSY) | g.ENDSCOPE_FLAG)
    if g.REGULAR_PROCMARK > g.NDECSY:
        g.SYT_PTR(g.BLOCK_SYTREF[g.NEST], 0) # NO LOCAL SYMBOLS
    else: 
        for g.I  in range(0, g.NDECSY - g.REGULAR_PROCMARK + 1):
            g.J = g.NDECSY() - g.I;
            if (g.SYT_FLAGS(g.J) & g.INACTIVE_FLAG) != 0: 
                continue # REPEAT;
            g.CLOSE_BCD = g.SYT_NAME(g.J);
            DISCONNECT(g.J);
    #END
    g.SYT_ARRAY(g.BLOCK_SYTREF[g.NEST], 0xE000)
    g.PROCMARK = g.PROCMARK_STACK[g.NEST]
    g.REGULAR_PROCMARK = g.PROCMARK_STACK[g.NEST]
    SCOPEp = g.SCOPEp_STACK[g.NEST];
    g.NEST = 0;
    # CLEAN UP
    for g.I  in range(0, g.FACTOR_LIM + 1):
        # DON'T LEAVE TRACKS
        g.TYPE[g.I] = 0;
    #END
    g.NAME_IMPLIED = g.FALSE
    g.TEMPORARY_IMPLIED = g.FALSE
    g.MACRO_ARG_COUNT = 0
    g.STRUC_PTR = 0
    g.STRUC_DIM, g.STRUC_SIZE = 0
    g.ID_LOC, g.REF_ID_LOC = 0;
    g.INCLUDE_STMT = g.g.STMT_NUM();
    g.STMT_NUM(g.STMT_NUM() + 1)
    # TREAT EACH INCLUDE AS ONE STMT
    OUTPUT(0, g.X8 + g.STARS + 'INCLUDED FROM SDF ' + SDF_NAME + g.X1 + g.STARS)
    OUTPUT(0, g.X8 + g.STARS + REVSTR + g.X1 + g.STARS)
    OUTPUT(0, g.X1)
    TERMINATE_SDFPKG;
    if RECORD_ALLOC(FORFCB) > 0:
        RECORD_FREE(FORFCB);
    if RECORD_ALLOC(PGING) > 0:
        RECORD_FREE(PGING);
    if 0 != (g.SIMULATING & 1):
        MAKE_INCL_CELL(SDF_NAME, INCL_FLAGS, SHL(REV,16) | CAT);
    return g.TRUE;
    # END INCLUDE_SDF 
    
