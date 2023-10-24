#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   COMMON.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  It contains what might be thought of as the
            global variables accessible by all other source files.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-08-26 RSB  Ported.
'''

'''
#*********************************************************
#                                                         
#  FUNCTION:                                              
#  COMMON  DECLARATIONS FOR THE HAL COMPILER              
#                                                         
#  INCLUDED BY: PASS1, PASS2, PASS3, PASS4, AUX, FLO, OPT 
#                                                         
#*********************************************************
'''

EXT_SIZE = 300  # SIZE OF EXT ARRAY

NUM_DWNS = 10  # INITIAL SIZE OF DOWNGRADE TABLE  
DOWNGRADE_LIMIT = 20  # MAXIMUM NUMBER OF DOWNGRADES     
# NOTE: DOWNGRADE_LIMIT IS USED ONLY IN THE ROUTINE "STREAM" IN PASS1.
#       TO INCREASE (OR DECREASE) THE MAXIMUM ALLOWABLE DOWNGRADES, YOU NEED
#       ONLY NEED TO CHANGE THIS VALUE. 

# SYMBOL    TABLE  


class sym_tab:

    def __init__(self):
        self.SYM_NAME = ""
        self.SYM_ADDR = 0
        self.SYM_FLAGS = 0
        self.XTNT = 0
        self.SYM_XREF = 0
        self.SYM_LENGTH = 0
        self.SYM_ARRAY = 0
        self.SYM_PTR = 0
        self.SYM_LINK1 = 0
        self.SYM_LINK2 = 0
        self.SYM_NEST = 0
        self.SYM_SCOPE = 0
        self.SYM_CLASS = 0
        self.SYM_LOCKp = 0
        self.SYM_TYPE = 0
        self.SYM_FLAGS2 = 0


SYM_TAB = []  # Elements are sym_tab class objects.

#  RECORD TO BE USE TO STORE DOWNGRADE INFORMATION 


class down_info:

    def __init__(self):
        self.DOWN_STMT = ""  #  STMT NUMBER     
        self.DOWN_ERR = ""  #  ERROR NUMBER    
        self.DOWN_CLS = ""  #  ERROR CLASS     
        self.DOWN_UNKN = ""  #  UNKNOWN ERROR   
        self.DOWN_VER = ""  #  1 IF DOWNGRADE  


                        #  SUCCESSFUL      
DOWN_INFO = []  # Elements are down_info class objects.

#  TABLE FOR VMEM ADDITIONS FOR FLOGEN 


class sym_add:

    def __init__(self):
        self.SYM_VPTR = 0
        self.SYM_NUM = 0


SYM_ADD = []  # Elements are sym_add class objects.

# CROSS REFERENCE TABLE 


class cross_ref:

    def __init__(self):
        self.CR_REF = 0


CROSS_REF = []  # Elements are cross_ref class objects

# TABLE FOR CHARACTER LITERALS 

'''
# LIT_CHAR[] is aliased to LIT_NDX[].CHAR_LIT, so there's actually no need 
# (for us) to have a separate LIT_NDX[], as it's not used for anything else.
class lit_ndx:
    def __init__(self):
        self.CHAR_LIT = 0
LIT_NDX = []  # Elements are lit_ndx class objects
'''

# WORK AREA FOR FLOATING POINT ARITHMETIC ROUTINES 


class for_dw:

    def __init__(self):
        self.CONST_DW = 0


FOR_DW = []  # Elements are for_dw class objects

# BUFFER FOR THE HALMAT FILE 


class for_atoms:

    def __init__(self):
        self.CONST_ATOMS = 0


FOR_ATOMS = []  # Elements are for_atoms class objects

# MISCELLANEOUS COMMON VARIABLES 


class advise:

    def __init__(self):
        self.ERRORp = ""
        self.STMTp = 0


ADVISE = []  # Elements are advise class objects

EXT_ARRAY = [0] * (EXT_SIZE + 1)
IODEV = [0] * 9
COMMON_RETURN_CODE = 0
TABLE_ADDR = 0
ADDR_FIXER = 0
ADDR_FIXED_LIMIT = 0
ADDR_ROUNDER = 0
COMM = [0] * 49

# ARRAYS TO KEEP CSECT LENGTHS FOR %COPY CHECKING 
# THESE ARRAYS ARE INDEXED BY SYTSCOPE            

# SPILL_PRIMARY AND SPILL_REMOTE ARE SPILL VARIABLES THAT WERE 
# REMOVED FROM CSECT_LENGTHS FOR CR11098.                      


class csect_lengths:

    def __init__(self):
        self.PRIMARY = 0  #    HIGH WATER MARK OF PRIMARY CSECT 
        self.REMOTE = 0  #  HIGH WATER MARK OF REMOTE CSECT 


CSECT_LENGTHS = []  # Elements are csect_lengths class objects

# BUFFER FOR THE LITERAL FILE 

class lit_pg:
    def __init__(self):
        self.LITERAL1 = [0] * 130
        self.LITERAL2 = [0] * 130
        self.LITERAL3 = [0] * 130

LIT_PG = []  # Elements are lit_pg class objects.
lit_char = bytearray([])

# BUFFER FOR THE VMEM FILE 
'''
Here's what this looked like in XPL:

    COMMON   BASED VMEMREC RECORD:
             VMEM_NDX(840)  FIXED,          /* VMEM_NDX IS ONE VMEMPAGE */
    END;

However ... VMEMREC provides the memory buffers for the Virtual Memory system,
and the Virtual Memory system treats each buffer as an array of VMEM_PAGE_SIZE
(= 4 * 840) *bytes*.  In other words, this odd definition as 840 32-bit 
*integers* has little to do with how VMEMREC is actually used by the software.  
Perhaps the purpose of defining it in terms of FIXED rather than as BIT(8) has 
to do with insuring alignment on 32-bit memory boundaries; or perhaps not: the 
reasoning is likely irrelevant for our purposes anyway.  

For *our* purposes, each buffer should be a bytearray of length VMEM_PAGE_SIZE, 
and so I'm implementing VMEMREC that way in Python.
'''
VMEMREC = []  # Elements are bytearray objects of length VMEM_PAGE_SIZE.


class init_tab:

    def __init__(self):
        self.VALUE = 0


INIT_TAB = []  # Elements are init_tab class objects

INITIAL_ON = [0] * 2
# D -- INDICATES IF THE DATA_REMOTE DIRECTIVE WAS USED 
DATA_REMOTE = 0
# INDICATES IF A SEVERITY 1 ERROR MESSAGE HAS BEEN EMITTED 
SEVERITY_ONE = 0
# INDICATES AN UNNEEDED DOWNGRADE DIRECTIVE EXISTS
NOT_DOWNGRADED = 0

