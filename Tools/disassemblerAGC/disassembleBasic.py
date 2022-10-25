#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       disassembleBasic.py
Purpose:        Disassembler for a basic word
History:        2022-09-28 RSB  Split off from disassemblerAGC.py.
                2022-09-29 RSB  Replaced TC 0002 by RETURN.
                2022-10-18 RSB  Fixed EDRUPT for BLK2.
                
****************************************************************
                       *** WARNING! ****
Every time this function is improved, it likely will invalidate 
search patterns used in searchSpecial.py.  For example, at this
writing, the DOUBLE instruction is disassembled as AD A.  And
that's what the search patterns would therefore be looking for.
Changing the output to DOUBLE instead requires you to fix the
search patterns as well!
****************************************************************

"""

import parseCommandLine as cli
from registers import registersAndIoChannels

# Disassemble a word containing a basic instruction.  This function comes from 
# Mike Stewart's GUI for his core-rope reader, though I've renamed it and
# performed some minor tweaks.
def disassembleBasic(word, extended):
    op_str = ''
    arg_str = '%04o' % (word & 0o7777)
    sq = word >> 12
    qc = (word >> 10) & 0o3
    qc10 = (word >> 9) & 0o7
    if not extended:
        if word == 0o00003:
            op_str = 'RELINT'
            arg_str = ''
        elif word == 0o00004:
            op_str = 'INHINT'
            arg_str = ''
        elif word == 0o00006:
            op_str = 'EXTEND'
            arg_str = ''
            extended = True
        elif word == 0o50017:
            op_str = 'RESUME'
            arg_str = ''
            # extended = True
        elif sq == 0:
            if word == 0o00002:
                op_str = 'RETURN'
                arg_str = ''
            else:
                op_str = 'TC'
        elif sq == 1:
            if qc == 0:
                op_str = 'CCS'
                arg_str = '%04o' % (word & 0o1777)
            else:
                op_str = 'TCF'
        elif sq == 2:
            arg_str = '%04o' % (word & 0o1777)
            if qc == 0:
                op_str = 'DAS'
            elif qc == 1:
                op_str = 'LXCH'
            elif qc == 2:
                op_str = 'INCR'
            elif qc == 3:
                op_str = 'ADS'
        elif sq == 3:
            op_str = 'CA'
        elif sq == 4:
            op_str = 'CS'
        elif sq == 5:
            arg_str = '%04o' % (word & 0o1777)
            if qc == 0:
                op_str = 'INDEX'
            elif qc == 1:
                op_str = 'DXCH'
                arg_str = '%04o' % ((word & 0o1777) - 1)
            elif qc == 2:
                op_str = 'TS'
            elif qc == 3:
                op_str = 'XCH'
        elif sq == 6:
            op_str = 'AD'
        elif sq == 7:
            op_str = 'MASK'
    else:
        extended = False
        if sq == 0:
            arg_str = '%02o' % (word & 0o77)
            if qc10 == 0:
                op_str = 'READ'
            elif qc10 == 1:
                op_str = 'WRITE'
            elif qc10 == 2:
                op_str = 'RAND'
            elif qc10 == 3:
                op_str = 'WAND'
            elif qc10 == 4:
                op_str = 'ROR'
            elif qc10 == 5:
                op_str = 'WOR'
            elif qc10 == 6:
                op_str = 'RXOR'
            elif qc10 == 7:
                op_str = 'EDRUPT'
                if cli.blk2:
                    arg_str = ""
                else:
                    arg_str = '%04o' % (word & 0o7777)
        elif sq == 1:
            if qc == 0:
                op_str = 'DV'
                arg_str = '%04o' % (word & 0o1777)
            else:
                op_str = 'BZF'
        elif sq == 2:
            arg_str = '%04o' % (word & 0o1777)
            if qc == 0:
                op_str = 'MSU'
            elif qc == 1:
                op_str = 'QXCH'
            elif qc == 2:
                op_str = 'AUG'
            elif qc == 3:
                op_str = 'DIM'
        elif sq == 3:
            op_str = 'DCA'
            arg_str = '%04o' % ((word & 0o1777) - 1)
        elif sq == 4:
            op_str = 'DCS'
            arg_str = '%04o' % ((word & 0o1777) - 1)
        elif sq == 5:
            op_str = 'INDEX'
            extended = True
        elif sq == 6:
            if qc == 0:
                op_str = 'SU'
                arg_str = '%04o' % (word & 0o1777)
            else:
                op_str = 'BZMF'
        elif sq == 7:
            op_str = 'MP'

    if arg_str in registersAndIoChannels and op_str not in ["EDRUPT"]:
        arg_str = registersAndIoChannels[arg_str]
    return op_str, arg_str, extended


