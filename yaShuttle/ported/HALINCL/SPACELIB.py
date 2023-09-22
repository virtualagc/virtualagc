#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   SPACELIB.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-08-28 RSB  Began porting process from XPL.
'''

import g
import HALINCL.COMMON as h

'''
/**********************************************************************/        00000010
/* MEMBER NAME:     SPACELIB                                          */        00000020
/* FUNCTION:        THIS FILE CONTAINS THE SPACE MANAGEMENT PROCEDURES*/        00000030
/*          AND DECLARATIONS AS WELL AS A NEW COMPACTIFY.             */        00000040
/*          IT SHOULD BE USED AS INPUT2 TO XPL.                       */        00000050
/*                                                                    */        00000060
/**********************************************************************/        00000070
'''

# Gets the highest used index in an array.
def RECORD_TOP(array):
    return len(array) - 1

# Allocates space to add one element to an array.
def NEXT_ELEMENT(array):
    if array is g.MACRO_TEXTS:
        array.append(g.macro_texts())
    elif array is g.OUTER_REF_TABLE:
        array.append(g.outer_ref_table())
    elif array is g.SAVE_PATCH:
        array.append(g.save_patch())
    elif array is h.DOWN_INFO:
        array.append(h.down_info())
    elif array is h.CSECT_LENGTHS:
        array.append(h.csect_lengths())
    elif array is h.SYM_TAB:
        array.append(h.sym_tab())
    elif array is g.LINK_SORT:
        array.append(g.link_sort())
    elif array is h.CROSS_REF:
        array.append(h.cross_ref())
    elif array is h.ADVISE:
        array.append(h.advise())
    else:
        print("Unknown array type in call to NEXT_ELEMENT")
        array.append(None)

def RECORD_LINK():
    return
