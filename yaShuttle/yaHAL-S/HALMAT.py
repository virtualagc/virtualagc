#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       HALMAT.py
Reference:      HALMAT.md
Purpose:        Part of the code-generation system for the "modern" HAL/S
                compiler yaHAL-S-FC.py+modernHAL-S-FC.c.
History:        2022-12-16 RSB  Created. 

Calling this file "HALMAT.py" is just a bit of hubris on my part.  I would like
it to be that, but it's not.  It's my "reconstruction" of HALMAT, in lieu
of much of the original documentation.
"""

# These are Operand Qualifier Tags (Q).
SYT = 0x01 # or SYL.  Symbol table pointer.
INL = 0x02 # or GLI.  Internal flow number reference.
VAC = 0x03 # "Virtual accumulator", a back pointer to a previous HALMAT result.
XPT = 0x04 # An extended pointer.
LIT = 0x05 # A pointer into the literal table.
IMD = 0x06 # An actual numerical value used by the operator.
AST = 0x07 # An asterisk pointer.
CSZ = 0x08 # Component size.
ASZ = 0x09 # Array or copy size.
OFF = 0x0A # An offset value.

# These are HALMAT opcodes.
NOP  = 0x000 # No operation.
EXTN = 0x001
XREC = 0x002 # End of HALMAT record.
IMRK = 0x003 # Statement marker (inline functions).
SMRK = 0x004 # Statement marker (general).
PXRC = 0x005 # Pointer to XREC.
LBL  = 0x008
BRA  = 0x009
FBRA = 0x00A
DCAS = 0x00B
CLBL = 0x00D
DTST = 0x00E 
ETST = 0x00F
DFOR = 0x010
EFOR = 0x011
CFOR = 0x012
DSMP = 0x013
ESMP = 0x014
AFOR = 0x015
CTST = 0x016
ADLP = 0x017
DLPE = 0x018
DSUB = 0x019 # Regular subscript specifier.
IDLP = 0x01A
TSUB = 0x01B
PCAL = 0x01D
FCAL = 0x01E
READ = 0x01F
RDAL = 0x020
WRIT = 0x021
FILE = 0x022
XXST = 0x025
XXND = 0x026
XXAR = 0x027
TDEF = 0x02A # Task definition header.
MDEF = 0x02B # Program definition header.
FDEF = 0x02C # Function definition header.
PDEF = 0x02D # Procedure definition header.
UDEF = 0x02E
CDEF = 0x02F
CLOS = 0x030
EDCL = 0x031
RTRN = 0x032
TDCL = 0x033
WAIT = 0x034
SGNL = 0x035
CANC = 0x036
TERM = 0x037
PRIO = 0x038
SCHD = 0x039
ERON = 0x03C
ERSE = 0x03D
MSHP = 0x040
VSHP = 0x041
SSHP = 0x042
ISHP = 0x043
SFST = 0x045
SFND = 0x046
SFAR = 0x047
BFNC = 0x04A
LFNC = 0x04B
TASN = 0x04F
IDEF = 0x051
ICLS = 0x052
NASN = 0x057
PMAR = 0x05A
PMIN = 0x05B
STRI = 0x801
SLRI = 0x802
ELRI = 0x803
ETRI = 0x804
BINT = 0x821
CINT = 0x841
MINT = 0x861
VINT = 0x881
SINT = 0x8A1
IINT = 0x8C1
NINT = 0x8E1
TINT = 0x8E2
EINT = 0x8E3

'''
import sys
for line in sys.stdin:
    fields = line.strip().split()
    if len(fields) < 3:
        continue
    if fields[1] != "=":
        continue
    if fields[2][:2] != "0x":
        continue   
    print("##", fields[2], "-", fields[0])
    print()
    print("TBD")
    print()
'''

