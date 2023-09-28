#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   VMEM1.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-22 RSB  Began porting process from XPL.
'''

from HALINCL.VMEM1 import *
import g
import HALINCL.COMMON as h

'''
 VIRTUAL MEMORY DECLARATIONS FOR THE HAL/S COMPILER
'''

VMEM_FILEp = 6  # USE FILE 6 
VMEM_TOTAL_PAGES = 399
VMEM_PAGE_SIZE = 3360
VMEM_LIM_PAGES = 2

VMEM_PTR_STATUS = [0] * (VMEM_LIM_PAGES + 1)  # PTRS LAST ACCESSED 
VMEM_FLAGS_STATUS = [0] * (VMEM_LIM_PAGES + 1)  # FLAGS FOR ABOVE PTRS 
