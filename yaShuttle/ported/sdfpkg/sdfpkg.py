#!/usr/bin/env python3
"""
sdfpkg.py  --  Python 3 port of the HAL/S Symbol Data File (SDF) package.

Ported from C (sdfpkg.c, sdf_locate.c, sdf_select.c, sdf_pagmod.c,
sdf_util.c, sdf_io.c), which were themselves ported from IBM System/360
Basic Assembly Language (HAL/S-FC compiler, Space Shuttle era).

Original BAL sources: SDFPKG.bal, LOCATE.bal, SELECT.bal, PAGMOD.bal,
NDX2PTR.bal, and the DSECT macros DATABUF, FCBCELL, PDENTRY, PAGEZERO,
DROOTCEL, BLCKNODE, BLKTCELL, SYMBNODE, SYMBDC, STMTDC, STMTNOD0,
STMTNOD1, STMTEXTF, STMTEXTV, SYMEXTF, SYMEXTV.

Public API
----------
    ctx = SdfContext.open(path, update=False, npages=2,
                          first_sym=False, one_fcb=False)
    ctx.close()                              # or use as context manager

    ctx.select(member_name)                  # mode 4
    data = ctx.locate(vptr, disp=0)         # mode 5 -> memoryview
    root = ctx.locate_root(disp=0)          # mode 7 -> memoryview

    blk  = ctx.find_block_by_number(n, disp=0)      # mode 8
    blk  = ctx.find_block_by_name(name, disp=0)     # mode 11
    csect= ctx.find_block_node_by_number(n, disp=0) # mode 15

    sym  = ctx.find_symbol_by_number(n, disp=0)             # mode 9
    sym  = ctx.find_symbol_by_name(name, disp=0)            # mode 13
    sym  = ctx.find_symbol_by_block_and_name(blk, sym, d=0) # mode 12
    name, sdc_vptr = ctx.find_symbol_node_by_number(n, d=0) # mode 16

    stmt = ctx.find_stmt_by_number(n, disp=0)        # mode 10
    stmt = ctx.find_stmt_by_srn(srn, disp=0)         # mode 14
    stmt = ctx.find_stmt_node_by_number(n, disp=0)   # mode 17

    data = ctx.find_init_data(symb_no, disp=0)       # mode 18 (CR13079)

    reads, writes, selects = ctx.stats()

All lookup methods return dataclass instances (BlockResult, SymbolResult,
StmtResult) or raise SdfError on failure.

Virtual pointers
----------------
Vptr values are plain Python ints: high 16 bits = page number,
low 16 bits = byte offset within the 1680-byte page.
Helper functions: vptr_make(page, offset), vptr_page(vp), vptr_offset(vp).

Disposition flags (disp parameter)
-----------------------------------
    DISP_NONE = 0x00
    DISP_MODF = 0x40   # mark page dirty (update mode only)
    DISP_RELS = 0x20   # release a previous reserve
    DISP_RESV = 0x10   # pin (reserve) the page
"""

from __future__ import annotations

import io
import struct
import ctypes
from dataclasses import dataclass, field
from typing import Optional, Tuple
import os

# ======================================================================
# Constants
# ======================================================================

PAGE_SIZE       = 1680
NAME_LEN        = 8
LONG_NAME_LEN   = 32
SRN_LEN         = 6        # CL6 in STMTNOD1 / COMMTABL
SRN_PAD_LEN     = 8        # CL8 in extent cells (space-padded)
PAD_SLOTS       = 250      # paging area directory capacity

FLAT_MAGIC      = b'SDF\x00'
FLAT_IDX_ENTRY  = 20       # 8 name + 4 pages + 8 offset

# SDF flags (stored as big-endian u16 from sdf_flags[0..1] in DROOTCEL)
FLAG_HAS_SRNS   = 0x8000
FLAG_NONMONO    = 0x0400

# Disposition flags
DISP_NONE = 0x00
DISP_MODF = 0x40
DISP_RELS = 0x20
DISP_RESV = 0x10

# Symbol class/type constants
CLASS_EQUATE_EXT    = 2
TYPE_EQUATE_EXT     = 8
FLAG1_UNQUAL_STRUC  = 0x03

# ======================================================================
# Errors
# ======================================================================

class SdfError(Exception):
    """Base class for all SDF errors."""
    def __init__(self, code: int, message: str = ''):
        self.code = code
        super().__init__(message or _strerror(code))

# Informational return codes (non-exception path — raised as SdfError
# when the caller needs to distinguish them)
RC_OK             =  0
RC_NOT_FOUND      = 16
RC_SYM_NOT_FOUND  = 20
RC_NOT_EXEC       = 24
RC_NO_SRNS        = 28
RC_SRNS_NONMONO   = 32
RC_STMT_OOB       = 36

# Fatal error codes
ERR_DEADLOCK      = -4001
ERR_OPEN_FAIL     = -4002
ERR_RESERVE_OVF   = -4003
ERR_RELEASE_OVF   = -4004
ERR_BAD_PTR       = -4005
ERR_BAD_BLOCK     = -4006
ERR_BAD_SYMB      = -4007
ERR_MODF_MODE     = -4008
ERR_NOT_INIT      = -4009
ERR_NO_SELECT     = -4010
ERR_RESCIND_RSV   = -4011
ERR_RESCIND_NA    = -4012
ERR_BAD_PGAREA    = -4013
ERR_NO_CURENTRY   = -4014
ERR_BAD_SVCCODE   = -4016
ERR_BLK_NOSPEC    = -4020
ERR_SEL_RESERVED  = -4022
ERR_LEN_MISMATCH  = -4023

_ERROR_STRINGS = {
    RC_OK:            'success',
    RC_NOT_FOUND:     'block not found',
    RC_SYM_NOT_FOUND: 'symbol not found',
    RC_NOT_EXEC:      'statement not executable',
    RC_NO_SRNS:       'file has no SRNs',
    RC_SRNS_NONMONO:  'SRNs are not monotonic',
    RC_STMT_OOB:      'statement number out of range',
    ERR_DEADLOCK:     'paging area deadlocked (U4001)',
    ERR_OPEN_FAIL:    'file open / I/O failure (U4002)',
    ERR_RESERVE_OVF:  'too many reserves for one page (U4003)',
    ERR_RELEASE_OVF:  'too many releases for one page (U4004)',
    ERR_BAD_PTR:      'bad virtual pointer (U4005)',
    ERR_BAD_BLOCK:    'bad block index (U4006)',
    ERR_BAD_SYMB:     'bad symbol index (U4007)',
    ERR_MODF_MODE:    'MODF requires update mode (U4008)',
    ERR_NOT_INIT:     'called before init (U4009)',
    ERR_NO_SELECT:    'no SDF member currently selected (U4010)',
    ERR_RESCIND_RSV:  'rescind with reserved pages (U4011)',
    ERR_RESCIND_NA:   'rescind without augmented area (U4012)',
    ERR_BAD_PGAREA:   'bad paging area specification (U4013)',
    ERR_NO_CURENTRY:  'set-disps before any locate (U4014)',
    ERR_BAD_SVCCODE:  'bad service code (U4016)',
    ERR_BLK_NOSPEC:   'block not previously specified (U4020)',
    ERR_SEL_RESERVED: 'select while pages reserved (U4022)',
    ERR_LEN_MISMATCH: 'SDF length mismatch (U4023)',
}

def _strerror(code: int) -> str:
    return _ERROR_STRINGS.get(code, f'unknown SDF error {code}')

# ======================================================================
# Virtual pointer helpers
# ======================================================================

def vptr_make(page: int, offset: int) -> int:
    return ((page & 0xFFFF) << 16) | (offset & 0xFFFF)

def vptr_page(vp: int) -> int:
    return (vp >> 16) & 0xFFFF

def vptr_offset(vp: int) -> int:
    return vp & 0xFFFF

VPTR_NULL = 0

# ======================================================================
# String helpers
# ======================================================================

def _field_to_str(data, length: int) -> str:
    """Convert a blank-padded fixed-length ASCII field to a Python str."""
    s = bytes(data[:length])
    return s.rstrip(b' ').decode('ascii', errors='replace')

def _str_to_field(s: str, length: int) -> bytes:
    """Convert a Python str to a blank-padded fixed-length ASCII field."""
    b = s.encode('ascii', errors='replace')
    if len(b) >= length:
        return b[:length]
    return b + b' ' * (length - len(b))

# ======================================================================
# Big-endian struct unpackers (mirrors sdf_internal.h inline helpers)
# ======================================================================

def _be16(data, off: int = 0) -> int:
    return struct.unpack_from('>H', data, off)[0]

def _be32(data, off: int = 0) -> int:
    return struct.unpack_from('>I', data, off)[0]

def _be16s(data, off: int = 0) -> int:
    """Signed big-endian 16-bit."""
    return struct.unpack_from('>h', data, off)[0]

def _be32s(data, off: int = 0) -> int:
    """Signed big-endian 32-bit."""
    return struct.unpack_from('>i', data, off)[0]

# ======================================================================
# On-disk structure parsers
# (Python replaces C's packed structs with offset-based unpacking)
# ======================================================================

class _PageZero:
    SIZE = 12  # version(2) + pad(2) + dir_fc_ptr(4) + droot_ptr(4) + dat_fc_ptr(4)
    __slots__ = ('version', 'droot_ptr')
    def __init__(self, data, off: int = 0):
        self.version   = _be16(data, off)
        self.droot_ptr = _be32(data, off + 8)

class _DRootCel:
    # Offsets within DROOTCEL (all big-endian, packed)
    # sdf_flags[0..1], last_page(2), sdf_date(4), sdf_time(4),
    # last_dpage(2), compools(2), blk_nodes(2), sym_nodes(2),
    # fbn_ptr(4), lbn_ptr(4), instr_cnt(2), free_byte(2),
    # dlst_head(2), rlst_head(2), fsn_ptr(4), lsn_ptr(4),
    # cubtc_ptr(4), btree_ptr(4), fstmt_num(2), lstm_num(2),
    # exec_stmt(2), stmt_node(2), fstn_ptr(4), lstn_ptr(4),
    # snel_ptr(4), first_srn(6), last_srn(6), cubtc_num(2),
    # comp_unit(2), title_ptr(4), user_data(8),
    # symb_cnt(4), macro_cnt(4), lits_cnt(4), xref_cnt(4),
    # dummy(36), dinit_ptr(4)
    __slots__ = ('sdf_flags','last_page','blk_nodes','sym_nodes',
                 'fbn_ptr','fsn_ptr','btree_ptr','fstmt_num','lstm_num',
                 'fstn_ptr','snel_ptr','dinit_ptr')
    def __init__(self, data, off: int = 0):
        o = off
        self.sdf_flags  = (_be16(data, o),)   # stored as single u16
        flags_u16       = (data[o] << 8) | data[o+1]
        self.sdf_flags  = flags_u16
        self.last_page  = _be16(data, o+2)
        # skip date(4) time(4) last_dpage(2) compools(2)
        self.blk_nodes  = _be16(data, o+16)
        self.sym_nodes  = _be16(data, o+18)
        self.fbn_ptr    = _be32(data, o+20)
        # lbn_ptr(4) instr_cnt(2) free_byte(2) dlst_head(2) rlst_head(2)
        self.fsn_ptr    = _be32(data, o+36)
        # lsn_ptr(4) cubtc_ptr(4)
        self.btree_ptr  = _be32(data, o+48)
        self.fstmt_num  = _be16(data, o+52)
        self.lstm_num   = _be16(data, o+54)
        # exec_stmt(2) stmt_node(2)
        self.fstn_ptr   = _be32(data, o+60)
        # lstn_ptr(4)
        self.snel_ptr   = _be32(data, o+68)
        # first_srn(6) last_srn(6) cubtc_num(2) comp_unit(2)
        # title_ptr(4) user_data(8)
        # symb_cnt(4) macro_cnt(4) lits_cnt(4) xref_cnt(4) dummy(36)
        self.dinit_ptr  = _be32(data, o+168)

class _BlckNode:
    SIZE = 12  # csct_name(8) + block_ptr(4)
    __slots__ = ('csct_name', 'block_ptr')
    def __init__(self, data, off: int = 0):
        self.csct_name = _field_to_str(data[off:off+8], 8)
        self.block_ptr = _be32(data, off+8)

class _BlktCell:
    # rtree_ptr(4) ltree_ptr(4) fnest(4) lnest(4) ext_ptr(4) spare(4)
    # blk_flgs(1) spare2(1) blk_ndx(2) blk_id(2)
    # blk_class(1) blk_type(1) fsymb_num(2) lsymb_num(2)
    # fstmt_num(2) lstm_num(2) post_dcl(2) stak_list(2)
    # bname_len(1) blk_name(32)
    __slots__ = ('rtree_ptr','ltree_ptr','ext_ptr','blk_flgs',
                 'blk_ndx','blk_id','blk_class','blk_type',
                 'fsymb_num','lsymb_num','fstmt_num','lstm_num',
                 'bname_len','blk_name')
    def __init__(self, data, off: int = 0):
        o = off
        self.rtree_ptr  = _be32(data, o)
        self.ltree_ptr  = _be32(data, o+4)
        self.ext_ptr    = _be32(data, o+16)
        self.blk_flgs   = data[o+24]
        self.blk_ndx    = _be16(data, o+26)
        self.blk_id     = _be16(data, o+28)
        self.blk_class  = data[o+30]
        self.blk_type   = data[o+31]
        self.fsymb_num  = _be16(data, o+32)
        self.lsymb_num  = _be16(data, o+34)
        self.fstmt_num  = _be16(data, o+36)
        self.lstm_num   = _be16(data, o+38)
        self.bname_len  = data[o+44]
        raw_name        = bytes(data[o+45 : o+45+min(self.bname_len, LONG_NAME_LEN)])
        self.blk_name   = raw_name.decode('ascii', errors='replace')

class _SymbNode:
    SIZE = 12  # symb_name(8) + sdc_ptr(4)
    __slots__ = ('symb_name', 'sdc_ptr')
    def __init__(self, data, off: int = 0):
        self.symb_name = bytes(data[off:off+8])   # raw bytes for comparison
        self.sdc_ptr   = _be32(data, off+8)

class _SymbDC:
    # block_num(2) extd_off(1) xref_off(1) array_off(1) struct_of(1)
    # sym_class(1) sym_type(1) flag1(1) flag2(1) flag3(1) flag4(1)
    # symb_len(1) rel_addr(3) sblk_id(2) rows(1) columns(1) lock_num(1)
    # byte_size(3) name_cont[0..24)   [ARRADATA follows if array_off != 0]
    SIZE = 47   # minimum fixed size
    __slots__ = ('block_num','array_off','sym_class','sym_type','flag1','flag2',
                 'flag3','flag4','symb_len','rel_addr','rows','columns',
                 'name_cont','array_dims')
    def __init__(self, data, off: int = 0):
        o = off
        self.block_num = _be16(data, o)
        self.array_off = data[o+4]    # byte offset from SDC start to ARRADATA
        self.sym_class = data[o+6]
        self.sym_type  = data[o+7]
        self.flag1     = data[o+8]
        self.flag2     = data[o+9]
        self.flag3     = data[o+10]
        self.flag4     = data[o+11]
        self.symb_len  = data[o+12]
        self.rel_addr  = (data[o+13] << 16) | (data[o+14] << 8) | data[o+15]
        self.rows      = data[o+18]
        self.columns   = data[o+19]
        cont_len       = max(0, min(self.symb_len, LONG_NAME_LEN) - NAME_LEN)
        self.name_cont = bytes(data[o+24 : o+24+cont_len])
        # Parse ARRADATA if present
        if self.array_off:
            ao = off + self.array_off  # offset within full page buffer
            # ARRADATA: arraynum(H) + range1(H) + range2(H) + range3(H)
            ndims = _be16(data, ao)
            r1    = _be16(data, ao + 2)
            r2    = _be16(data, ao + 4)
            r3    = _be16(data, ao + 6)
            self.array_dims = (ndims, r1, r2, r3)
        else:
            self.array_dims = (0, 0, 0, 0)

class _StmtNod0:
    SIZE = 4
    __slots__ = ('stdc_ptr',)
    def __init__(self, data, off: int = 0):
        self.stdc_ptr = _be32(data, off)

class _StmtNod1:
    SIZE = 12  # srn(6) + incount(2) + stdc_ptr(4)
    __slots__ = ('srn', 'incount', 'stdc_ptr')
    def __init__(self, data, off: int = 0):
        self.srn      = bytes(data[off:off+6])
        self.incount  = _be16(data, off+6)
        self.stdc_ptr = _be32(data, off+8)

class _StmtDC:
    SIZE = 6  # block_num(2) stmt_type(2) num_labls(1) num_lhs(1)
    __slots__ = ('block_num', 'stmt_type', 'num_labls', 'num_lhs')
    def __init__(self, data, off: int = 0):
        self.block_num = _be16(data, off)
        self.stmt_type = _be16(data, off+2)
        self.num_labls = data[off+4]
        self.num_lhs   = data[off+5]

class _SymExtF:
    SIZE = 8   # succ_ptr(4) next_ntry(2) fst_page(2)
    __slots__ = ('succ_ptr', 'next_ntry', 'fst_page')
    def __init__(self, data, off: int = 0):
        self.succ_ptr  = _be32(data, off)
        self.next_ntry = _be16(data, off+4)
        self.fst_page  = _be16(data, off+6)

class _SymExtV:
    SIZE = 20  # fst_off(2) lst_off(2) fst_symb(8) lst_symb(8)
    __slots__ = ('fst_off', 'lst_off', 'fst_symb', 'lst_symb')
    def __init__(self, data, off: int = 0):
        self.fst_off  = _be16(data, off)
        self.lst_off  = _be16(data, off+2)
        self.fst_symb = bytes(data[off+4:off+12])
        self.lst_symb = bytes(data[off+12:off+20])

class _StmtExtF:
    SIZE = 8   # succ_ptr1(4) nx_ntry(2) fst_page1(2)
    __slots__ = ('succ_ptr1', 'nx_ntry', 'fst_page1')
    def __init__(self, data, off: int = 0):
        self.succ_ptr1 = _be32(data, off)
        self.nx_ntry   = _be16(data, off+4)
        self.fst_page1 = _be16(data, off+6)

class _StmtExtV:
    SIZE = 20  # fst_off1(2) lst_off1(2) fst_srn(8) lst_srn(8)
    __slots__ = ('fst_off1', 'lst_off1', 'fst_srn', 'lst_srn')
    def __init__(self, data, off: int = 0):
        self.fst_off1 = _be16(data, off)
        self.lst_off1 = _be16(data, off+2)
        self.fst_srn  = bytes(data[off+4:off+12])
        self.lst_srn  = bytes(data[off+12:off+20])

# ======================================================================
# Result dataclasses (replace C's sdf_block_result_t etc.)
# ======================================================================

@dataclass
class BlockResult:
    blk_no:     int = 0
    blk_id:     int = 0
    blk_class:  int = 0
    blk_type:   int = 0
    blk_flags:  int = 0
    csect_name: str = ''
    blk_name:   str = ''
    fsymb_no:   int = 0
    lsymb_no:   int = 0
    fstmt_no:   int = 0
    lstm_no:    int = 0
    raw_offset: int = 0   # byte offset within page buffer (replaces C void*)

@dataclass
class SymbolResult:
    symb_no:    int = 0
    blk_no:     int = 0
    symb_name:  str = ''
    sym_class:  int = 0
    sym_type:   int = 0
    flag1:      int = 0
    flag2:      int = 0
    flag3:      int = 0
    flag4:      int = 0
    rows:       int = 0
    columns:    int = 0
    symb_len:   int = 0
    raw_offset: int = 0
    array_dims: tuple = (0, 0, 0, 0)  # (ndims, d1, d2, d3); ndims=0 = not array

@dataclass
class StmtResult:
    stmt_no:       int  = 0
    blk_no:        int  = 0
    stmt_type:     int  = 0
    num_labls:     int  = 0
    num_lhs:       int  = 0
    srn:           bytes = b''
    incl_cnt:      int  = 0
    is_executable: bool = False
    raw_offset:    int  = 0

# ======================================================================
# Internal: Paging Area Directory Entry
# (Python equivalent of sdf_pad_entry_t)
# ======================================================================

class _PadEntry:
    __slots__ = ('page_buf', 'fcb', 'modified', 'use_count',
                 'page_no', 'resv_count')
    def __init__(self):
        self.page_buf   = bytearray(PAGE_SIZE)
        self.fcb        = None   # _Fcb or None
        self.modified   = False
        self.use_count  = 0
        self.page_no    = 0      # page_number * 8 (original encoding)
        self.resv_count = 0

# ======================================================================
# Internal: File Control Block
# (Python equivalent of sdf_fcb_t)
# ======================================================================

class _Fcb:
    __slots__ = ('filename', 'gt_tree', 'lt_tree',
                 'blk_ptr', 'symb_ptr', 'stmt_ptr', 'tree_ptr', 'stmt_expt',
                 'node_size', 'flags', 'num_blks', 'num_symbs',
                 'fst_stmt', 'lst_stmt', 'lst_page', 'version',
                 'page_offsets', 'pad_refs')
    def __init__(self, filename: str):
        self.filename   = filename
        self.gt_tree    = None
        self.lt_tree    = None
        self.blk_ptr    = 0
        self.symb_ptr   = 0
        self.stmt_ptr   = 0
        self.tree_ptr   = 0
        self.stmt_expt  = 0
        self.node_size  = 4
        self.flags      = 0
        self.num_blks   = 0
        self.num_symbs  = 0
        self.fst_stmt   = 0
        self.lst_stmt   = 0
        self.lst_page   = 0
        self.version    = 0
        self.page_offsets: list[int] = []   # file offsets per page
        self.pad_refs: list[Optional[_PadEntry]] = []  # one per page

# ======================================================================
# SdfContext
# ======================================================================

class SdfContext:
    """
    Opaque SDF access context.  Use SdfContext.open() or as a context manager.

        with SdfContext.open('my.sdf') as ctx:
            ctx.select('MYMEMBER')
            blk = ctx.find_block_by_number(1)
            print(blk.blk_name)
    """

    # ------------------------------------------------------------------
    # Construction / lifecycle
    # ------------------------------------------------------------------

    def __init__(self):
        # File
        self._fp: Optional[io.RawIOBase] = None
        self._update_mode = False

        # Paging area
        self._pad: list[_PadEntry] = []
        self._num_ofpgs = 0
        self._bas_npgs  = 0
        self._avuln: Optional[_PadEntry] = None
        self._cur_entry: Optional[_PadEntry] = None

        # FCB tree
        self._root_fcb: Optional[_Fcb] = None
        self._cur_fcb:  Optional[_Fcb] = None

        # Global state
        self._loc_cnt    = 0
        self._reserves   = 0
        self._go_flag    = False
        self._mod_flag   = False
        self._one_fcb    = False
        self._first_sym  = False
        self._init_ptr   = 0    # CR13079

        # Saved extent info for symbol search
        self._save_extpt = VPTR_NULL
        self._sav_fsymb  = 0
        self._sav_lsymb  = 0

        # Communication area (internal state mirror)
        self._comm_blk_no   = 0
        self._comm_symb_no  = 0
        self._comm_stmt_no  = 0
        self._comm_blkn_len = 0
        self._comm_symbn_len= 0
        self._comm_pntr     = 0
        self._comm_sdf_nam  = ''
        self._comm_csect_nam= ''
        self._comm_sref_no  = b''
        self._comm_incl_cnt = 0
        self._comm_blk_nam  = ''
        self._comm_symb_nam = ''

        # Statistics
        self._reads    = 0
        self._writes   = 0
        self._selects  = 0
        self._fcb_cnt  = 0

    @classmethod
    def open(cls, path: str, update: bool = False, npages: int = 2,
             first_sym: bool = False, one_fcb: bool = False) -> 'SdfContext':
        """
        Open an SDF flat file and initialise the paging area.

        Parameters
        ----------
        path      : Path to the sdfpkg flat file.
        update    : Open for read/write (write-back of modified pages).
        npages    : Initial size of in-memory paging area (default 2).
        first_sym : If True, accept the first matching symbol unconditionally.
        one_fcb   : If True, keep only one FCB in memory at a time.
        """
        ctx = cls()
        ctx._update_mode = update
        ctx._first_sym   = first_sym
        ctx._one_fcb     = one_fcb

        mode = 'r+b' if update else 'rb'
        try:
            ctx._fp = open(path, mode)
        except OSError as e:
            raise SdfError(ERR_OPEN_FAIL, str(e)) from e

        ctx._pagmod_init(npages)
        return ctx

    def close(self):
        """Flush dirty pages, free resources, and close the file."""
        if not self._go_flag:
            return
        self._pagmod_term()
        if self._fp:
            self._fp.close()
            self._fp = None

    def __enter__(self):
        return self

    def __exit__(self, *_):
        self.close()

    # ------------------------------------------------------------------
    # Mode 2 / 3: augment / rescind
    # ------------------------------------------------------------------

    def augment(self, npages_add: int = 0) -> None:
        """Expand the in-memory paging area by npages_add slots."""
        self._require_init()
        if npages_add < 0:
            raise SdfError(ERR_BAD_PGAREA)
        if npages_add > 0:
            new_total = self._num_ofpgs + npages_add
            if new_total > PAD_SLOTS:
                raise SdfError(ERR_BAD_PGAREA)
            self._num_ofpgs = new_total

    def rescind(self) -> None:
        """Write back and release augmented pages (beyond initial count)."""
        self._require_init()
        extra = self._num_ofpgs - self._bas_npgs
        if extra <= 0:
            raise SdfError(ERR_RESCIND_NA)
        for e in self._pad[self._bas_npgs:self._num_ofpgs]:
            if e.fcb is None:
                continue
            if e.resv_count > 0:
                raise SdfError(ERR_RESCIND_RSV)
            self._write_page(e)
            pg_idx = e.page_no // 8
            e.fcb.pad_refs[pg_idx] = None
            e.fcb       = None
            e.modified  = False
            e.use_count = 0
            e.page_no   = 0
            e.resv_count= 0
        self._num_ofpgs = self._bas_npgs

    # ------------------------------------------------------------------
    # Mode 4: select
    # ------------------------------------------------------------------

    def select(self, member_name: str) -> None:
        """
        Select a named SDF member.  Must be called before any lookup.
        Idempotent if called again with the same name.
        """
        self._require_init()
        self._do_select(member_name)

    # ------------------------------------------------------------------
    # Mode 5: locate (raw virtual pointer -> memoryview)
    # ------------------------------------------------------------------

    def locate(self, vptr: int, disp: int = DISP_NONE) -> memoryview:
        """
        Translate a virtual pointer to an in-memory view of the data.
        The returned memoryview is valid until the next I/O operation.
        """
        self._require_init()
        addr = self._locate_vptr(vptr)
        self._set_disps(disp)
        return addr

    # ------------------------------------------------------------------
    # Mode 7: locate root
    # ------------------------------------------------------------------

    def locate_root(self, disp: int = DISP_NONE) -> memoryview:
        """Return a memoryview of the SDF directory root cell (DROOTCEL)."""
        self._require_init()
        self._require_select()
        pg0 = self._locate_vptr(vptr_make(0, 0))
        pz  = _PageZero(pg0)
        root_mv = self._locate_vptr(pz.droot_ptr)
        dr = _DRootCel(root_mv)
        self._init_ptr = dr.dinit_ptr
        self._set_disps(disp)
        return root_mv

    # ------------------------------------------------------------------
    # Mode 8: find block by number
    # ------------------------------------------------------------------

    def find_block_by_number(self, blk_no: int,
                              disp: int = DISP_NONE) -> BlockResult:
        self._require_init()
        self._require_select()
        self._comm_blk_no = blk_no
        return self._do_block_lookup(disp, node_only=False)

    # ------------------------------------------------------------------
    # Mode 9: find symbol by number
    # ------------------------------------------------------------------

    def find_symbol_by_number(self, symb_no: int,
                               disp: int = DISP_NONE) -> SymbolResult:
        self._require_init()
        self._require_select()
        sn_ptr = self._ndx2ptr(4, symb_no)
        sn_mv  = self._locate_vptr(sn_ptr)
        sn     = _SymbNode(sn_mv)
        self._comm_symb_nam = _field_to_str(sn.symb_name, NAME_LEN)
        sdc_mv = self._locate_vptr(sn.sdc_ptr)
        result = self._do_symbol_fill(symb_no, sn, sdc_mv, disp)
        return result

    # ------------------------------------------------------------------
    # Mode 10: find statement by number
    # ------------------------------------------------------------------

    def find_stmt_by_number(self, stmt_no: int,
                             disp: int = DISP_NONE) -> StmtResult:
        self._require_init()
        self._require_select()
        fcb    = self._cur_fcb
        sn_ptr = self._ndx2ptr(8, stmt_no)
        sn_mv  = self._locate_vptr(sn_ptr)
        has_srn = bool(fcb.flags & FLAG_HAS_SRNS)

        srn       = b''
        incl_cnt  = 0
        if has_srn:
            sn1      = _StmtNod1(sn_mv)
            srn      = bytes(sn1.srn)
            incl_cnt = sn1.incount
            self._comm_sref_no  = srn
            self._comm_incl_cnt = incl_cnt
            sdc_vptr = sn1.stdc_ptr
        else:
            sn0      = _StmtNod0(sn_mv)
            sdc_vptr = sn0.stdc_ptr

        # Interpret signed: >0 executable, <0 declare (negated), ==0 non-exec
        sdc_signed = _be32s(struct.pack('>I', sdc_vptr & 0xFFFFFFFF))
        is_exec = sdc_signed > 0
        is_decl = sdc_signed < 0
        if not is_exec and not is_decl:
            raise SdfError(RC_NOT_EXEC)
        if is_decl:
            sdc_vptr = (-sdc_signed) & 0xFFFFFFFF

        sdc_mv  = self._locate_vptr(sdc_vptr)
        sdc     = _StmtDC(sdc_mv)
        self._comm_blk_no  = sdc.block_num
        self._comm_stmt_no = stmt_no

        result = StmtResult(
            stmt_no       = stmt_no,
            blk_no        = sdc.block_num,
            stmt_type     = sdc.stmt_type,
            num_labls     = sdc.num_labls,
            num_lhs       = sdc.num_lhs,
            srn           = srn,
            incl_cnt      = incl_cnt,
            is_executable = is_exec,
        )
        self._set_disps(disp)
        return result

    # ------------------------------------------------------------------
    # Mode 11: find block by name
    # ------------------------------------------------------------------

    def find_block_by_name(self, blk_name: str,
                            disp: int = DISP_NONE) -> BlockResult:
        self._require_init()
        self._require_select()
        self._comm_blk_nam  = blk_name[:LONG_NAME_LEN]
        self._comm_blkn_len = len(self._comm_blk_nam)
        self._comm_blk_no   = 0
        fcb = self._cur_fcb
        node_ptr = fcb.tree_ptr
        sought   = blk_name.encode('ascii', errors='replace')

        while node_ptr != VPTR_NULL:
            bt_mv   = self._locate_vptr(node_ptr)
            bt      = _BlktCell(bt_mv)
            found   = bt.blk_name.encode('ascii', errors='replace')
            found_l = min(bt.bname_len, LONG_NAME_LEN)
            sought_l= min(len(sought), LONG_NAME_LEN)
            cmp_l   = min(found_l, sought_l)
            cmp     = (sought[:cmp_l] > found[:cmp_l]) - \
                      (sought[:cmp_l] < found[:cmp_l])

            if cmp == 0 and sought_l == found_l:
                self._comm_blk_no = bt.blk_ndx
                return self._do_block_lookup(disp, node_only=False)

            go_right = (cmp > 0) or (cmp == 0 and sought_l > found_l)
            node_ptr = bt.rtree_ptr if go_right else bt.ltree_ptr

        self._save_extpt = VPTR_NULL
        self._sav_fsymb  = 0
        self._sav_lsymb  = 0
        raise SdfError(RC_NOT_FOUND)

    # ------------------------------------------------------------------
    # Mode 12: find symbol by block name + symbol name
    # ------------------------------------------------------------------

    def find_symbol_by_block_and_name(self, blk_name: str, symb_name: str,
                                       disp: int = DISP_NONE) -> SymbolResult:
        self._require_init()
        self.find_block_by_name(blk_name, disp=DISP_NONE)
        return self.find_symbol_by_name(symb_name, disp=disp)

    # ------------------------------------------------------------------
    # Mode 13: find symbol by name (within last-selected block)
    # ------------------------------------------------------------------

    def find_symbol_by_name(self, symb_name: str,
                             disp: int = DISP_NONE) -> SymbolResult:
        self._require_init()
        self._require_select()
        if self._sav_fsymb == 0:
            raise SdfError(ERR_BLK_NOSPEC)
        srcharg8 = _str_to_field(symb_name, NAME_LEN)
        symb_no, sn, sdc_mv = self._symbol_binary_search(srcharg8)
        self._comm_symb_no = symb_no
        return self._do_symbol_fill(symb_no, sn, sdc_mv, disp)

    # ------------------------------------------------------------------
    # Mode 14: find statement by SRN
    # ------------------------------------------------------------------

    def find_stmt_by_srn(self, srn: bytes,
                          disp: int = DISP_NONE) -> StmtResult:
        """
        Find a statement by its 6-byte SRN.  srn may be bytes or str
        (str is encoded to ASCII and truncated/padded to 6 bytes).
        """
        self._require_init()
        self._require_select()
        fcb = self._cur_fcb
        if not fcb.stmt_expt:
            raise SdfError(RC_NO_SRNS)
        if fcb.flags & FLAG_NONMONO:
            raise SdfError(RC_SRNS_NONMONO)

        if isinstance(srn, str):
            srn = srn.encode('ascii')
        srn = (srn + b'      ')[:SRN_LEN]  # ensure 6 bytes

        self._comm_sref_no = srn
        self._comm_stmt_no = 0

        stmt_base = fcb.fst_stmt
        ext_ptr   = fcb.stmt_expt
        lo_off    = hi_off = page_no = 0
        found_page = False

        while ext_ptr != VPTR_NULL:
            ext_mv = self._locate_vptr(ext_ptr)
            ef     = _StmtExtF(ext_mv)
            vp_off = _StmtExtF.SIZE  # variable entries start here
            for i in range(ef.nx_ntry):
                ev = _StmtExtV(ext_mv, vp_off)
                if ev.fst_srn[:SRN_LEN] > srn:
                    raise SdfError(RC_SYM_NOT_FOUND)
                if ev.lst_srn[:SRN_LEN] >= srn:
                    lo_off     = ev.fst_off1
                    hi_off     = ev.lst_off1
                    page_no    = ef.fst_page1 + i
                    found_page = True
                    break
                cnt = (ev.lst_off1 - ev.fst_off1) // 12 + 1
                stmt_base += cnt
                vp_off    += _StmtExtV.SIZE
            if found_page:
                break
            ext_ptr = ef.succ_ptr1

        if not found_page:
            raise SdfError(RC_SYM_NOT_FOUND)

        # Load the page and binary search by SRN
        pg_mv   = self._locate_vptr(vptr_make(page_no, 0))
        n_items = (hi_off - lo_off) // 12 + 1
        blo, bhi  = 0, n_items - 1
        match_off = None

        while blo <= bhi:
            bmid    = (blo + bhi) // 2
            mid_off = lo_off + bmid * 12
            sn1     = _StmtNod1(pg_mv, mid_off)
            cmp = (srn > sn1.srn[:SRN_LEN]) - (srn < sn1.srn[:SRN_LEN])
            if cmp == 0:
                match_off = mid_off
                # scan backward for first match
                while match_off >= lo_off + 12:
                    prev = _StmtNod1(pg_mv, match_off - 12)
                    if prev.srn[:SRN_LEN] != srn:
                        break
                    match_off -= 12
                break
            elif cmp < 0:
                if bmid == 0:
                    break
                bhi = bmid - 1
            else:
                blo = bmid + 1

        if match_off is None:
            raise SdfError(RC_SYM_NOT_FOUND)

        matched  = _StmtNod1(pg_mv, match_off)
        stmt_no  = stmt_base + (match_off - lo_off) // 12
        sdc_vptr = matched.stdc_ptr
        sdc_signed = _be32s(struct.pack('>I', sdc_vptr & 0xFFFFFFFF))
        is_exec  = sdc_signed > 0
        is_decl  = sdc_signed < 0
        if not is_exec and not is_decl:
            raise SdfError(RC_NOT_EXEC)
        if is_decl:
            sdc_vptr = (-sdc_signed) & 0xFFFFFFFF

        sdc_mv = self._locate_vptr(sdc_vptr)
        sdc    = _StmtDC(sdc_mv)
        self._comm_blk_no  = sdc.block_num
        self._comm_stmt_no = stmt_no

        result = StmtResult(
            stmt_no       = stmt_no,
            blk_no        = sdc.block_num,
            stmt_type     = sdc.stmt_type,
            num_labls     = sdc.num_labls,
            num_lhs       = sdc.num_lhs,
            srn           = bytes(srn),
            incl_cnt      = matched.incount,
            is_executable = is_exec,
        )
        self._set_disps(disp)
        return result

    # ------------------------------------------------------------------
    # Mode 15: find block node by number (CSECT name only)
    # ------------------------------------------------------------------

    def find_block_node_by_number(self, blk_no: int,
                                   disp: int = DISP_NONE) -> str:
        """Return the CSECT name for the given block number."""
        self._require_init()
        self._require_select()
        self._comm_blk_no = blk_no
        r = self._do_block_lookup(disp, node_only=True)
        return r.csect_name

    # ------------------------------------------------------------------
    # Mode 16: find symbol node by number
    # ------------------------------------------------------------------

    def find_symbol_node_by_number(self, symb_no: int,
                                    disp: int = DISP_NONE
                                    ) -> Tuple[str, int]:
        """Return (name_prefix, sdc_vptr) for the given symbol number."""
        self._require_init()
        self._require_select()
        sn_ptr = self._ndx2ptr(4, symb_no)
        sn_mv  = self._locate_vptr(sn_ptr)
        sn     = _SymbNode(sn_mv)
        name   = _field_to_str(sn.symb_name, NAME_LEN)
        self._comm_symb_nam = name
        self._comm_symb_no  = symb_no
        self._set_disps(disp)
        return name, sn.sdc_ptr

    # ------------------------------------------------------------------
    # Mode 17: find statement node by number (SRN only)
    # ------------------------------------------------------------------

    def find_stmt_node_by_number(self, stmt_no: int,
                                  disp: int = DISP_NONE) -> StmtResult:
        """Return a StmtResult with SRN populated (no data cell lookup)."""
        self._require_init()
        self._require_select()
        fcb    = self._cur_fcb
        sn_ptr = self._ndx2ptr(8, stmt_no)
        sn_mv  = self._locate_vptr(sn_ptr)
        has_srn = bool(fcb.flags & FLAG_HAS_SRNS)
        self._comm_stmt_no = stmt_no

        srn      = b''
        incl_cnt = 0
        if has_srn:
            sn1      = _StmtNod1(sn_mv)
            srn      = bytes(sn1.srn)
            incl_cnt = sn1.incount
            self._comm_sref_no  = srn
            self._comm_incl_cnt = incl_cnt

        self._set_disps(disp)
        return StmtResult(stmt_no=stmt_no, srn=srn, incl_cnt=incl_cnt)

    # ------------------------------------------------------------------
    # Mode 18: find initialization data (CR13079)
    # ------------------------------------------------------------------

    def find_init_data(self, symb_no: int,
                        disp: int = DISP_NONE) -> memoryview:
        """Return a memoryview of the initialisation data for a symbol."""
        self._require_init()
        self._require_select()
        sn_ptr = self._ndx2ptr(4, symb_no)
        sn_mv  = self._locate_vptr(sn_ptr)
        sn     = _SymbNode(sn_mv)
        sdc_mv = self._locate_vptr(sn.sdc_ptr)
        sdc    = _SymbDC(sdc_mv)
        byte_off = sdc.rel_addr * 2
        base_pg  = vptr_page(self._init_ptr)
        base_off = vptr_offset(self._init_ptr)
        total    = base_off + byte_off
        data_ptr = vptr_make(base_pg + total // PAGE_SIZE, total % PAGE_SIZE)
        mv = self._locate_vptr(data_ptr)
        self._set_disps(disp)
        return mv

    # ------------------------------------------------------------------
    # Statistics
    # ------------------------------------------------------------------

    def stats(self) -> Tuple[int, int, int]:
        """Return (reads, writes, selects) counters."""
        return self._reads, self._writes, self._selects

    # ==================================================================
    # Private: paging area management (PAGMOD.bal)
    # ==================================================================

    def _pagmod_init(self, npages: int):
        if npages <= 0:
            npages = 2
        if npages > PAD_SLOTS:
            raise SdfError(ERR_BAD_PGAREA)
        self._bas_npgs  = npages
        self._num_ofpgs = npages
        self._pad       = [_PadEntry() for _ in range(PAD_SLOTS)]
        self._avuln     = self._pad[0]
        self._cur_entry = None
        self._go_flag   = True
        self._mod_flag  = self._update_mode

    def _pagmod_term(self):
        for e in self._pad[:self._num_ofpgs]:
            if e.fcb and e.modified:
                try:
                    self._write_page(e)
                except SdfError:
                    pass
        # Walk FCB tree (iterative; replaces the C recursive free)
        stack = []
        if self._root_fcb:
            stack.append(self._root_fcb)
        while stack:
            fcb = stack.pop()
            if fcb.gt_tree:
                stack.append(fcb.gt_tree)
            if fcb.lt_tree:
                stack.append(fcb.lt_tree)
        self._root_fcb  = None
        self._cur_fcb   = None
        self._pad       = []
        self._avuln     = None
        self._cur_entry = None
        self._go_flag   = False
        self._loc_cnt   = 0
        self._num_ofpgs = 0
        self._bas_npgs  = 0
        self._reserves  = 0

    # ==================================================================
    # Private: I/O (sdf_io.c)
    # ==================================================================

    def _write_page(self, e: _PadEntry):
        if e.fcb is None or not e.modified:
            return
        pg_idx  = e.page_no // 8
        offset  = e.fcb.page_offsets[pg_idx]
        self._fp.seek(offset)
        self._fp.write(bytes(e.page_buf))
        self._writes += 1
        e.modified = False

    def _read_page(self, fcb: _Fcb, pg_num: int, e: _PadEntry):
        offset = fcb.page_offsets[pg_num]
        self._fp.seek(offset)
        data = self._fp.read(PAGE_SIZE)
        if len(data) != PAGE_SIZE:
            raise SdfError(ERR_OPEN_FAIL, f'short read on page {pg_num}')
        e.page_buf[:] = data
        self._reads += 1

    # ==================================================================
    # Private: locate (LOCATE.bal)
    # ==================================================================

    def _find_victim(self, exclude: _PadEntry) -> Optional[_PadEntry]:
        victim   = None
        min_use  = 2**32
        for e in self._pad[:self._num_ofpgs]:
            if e is exclude:
                continue
            if e.resv_count != 0:
                continue
            if e.fcb is None:
                return e          # prefer empty slot
            if e.use_count <= min_use:
                min_use = e.use_count
                victim  = e
        return victim

    def _locate_vptr(self, vptr: int) -> memoryview:
        """
        Translate vptr to a memoryview into the in-memory page buffer.
        Updates self._cur_entry for disposition tracking.
        Raises SdfError on any problem.
        """
        fcb = self._cur_fcb
        if fcb is None:
            raise SdfError(ERR_NO_SELECT)

        pg_num = vptr_page(vptr)
        offset = vptr_offset(vptr)

        if pg_num > fcb.lst_page:
            raise SdfError(ERR_BAD_PTR)
        if offset >= PAGE_SIZE:
            raise SdfError(ERR_BAD_PTR)

        # CR11165: 31-bit locate counter
        self._loc_cnt = (self._loc_cnt + 1) & 0xFFFFFFFF
        if self._loc_cnt >= 0x80000000:
            self._loc_cnt = 1
            for e in self._pad[:self._num_ofpgs]:
                e.use_count = 0

        target = fcb.pad_refs[pg_num]
        if target is None:
            # Page not in core -- evict the vulnerable slot
            slot = self._avuln
            self._write_page(slot)
            if slot.fcb is not None:
                old_pg = slot.page_no // 8
                slot.fcb.pad_refs[old_pg] = None

            self._read_page(fcb, pg_num, slot)
            slot.fcb      = fcb
            slot.page_no  = pg_num * 8
            slot.modified = False
            fcb.pad_refs[pg_num] = slot
            target = slot

            new_avuln = self._find_victim(target)
            if new_avuln is None:
                raise SdfError(ERR_DEADLOCK)
            self._avuln = new_avuln

        target.use_count = self._loc_cnt
        self._cur_entry  = target
        self._comm_pntr  = vptr

        return memoryview(target.page_buf)[offset:]

    def _ndx2ptr(self, service: int, index: int) -> int:
        """Convert a block/symbol/statement index to a virtual pointer."""
        fcb = self._cur_fcb
        if fcb is None:
            raise SdfError(ERR_NO_SELECT)
        if service == 0:      # block nodes
            if index == 0 or index > fcb.num_blks:
                raise SdfError(ERR_BAD_BLOCK)
            base_ptr  = fcb.blk_ptr
            node_size = 12
        elif service == 4:    # symbol nodes
            if index == 0 or index > fcb.num_symbs:
                raise SdfError(ERR_BAD_SYMB)
            base_ptr  = fcb.symb_ptr
            node_size = 12
        elif service == 8:    # statement nodes
            if index < fcb.fst_stmt or index > fcb.lst_stmt:
                raise SdfError(RC_STMT_OOB)
            base_ptr  = fcb.stmt_ptr
            node_size = fcb.node_size
            index     = index - fcb.fst_stmt + 1
        else:
            raise SdfError(ERR_BAD_SVCCODE)

        base_pg  = vptr_page(base_ptr)
        base_off = vptr_offset(base_ptr)
        total    = base_off + (index - 1) * node_size
        return vptr_make(base_pg + total // PAGE_SIZE, total % PAGE_SIZE)

    # ==================================================================
    # Private: select (SELECT.bal)
    # ==================================================================

    def _do_select(self, member_name: str):
        self._selects += 1
        self._save_extpt = VPTR_NULL
        self._sav_fsymb  = 0
        self._sav_lsymb  = 0

        # Already selected?
        name_key = _str_to_field(member_name, NAME_LEN)
        if self._cur_fcb is not None:
            cur_key = _str_to_field(self._cur_fcb.filename, NAME_LEN)
            if name_key == cur_key:
                return

        self._cur_fcb = None
        self._comm_sdf_nam = member_name[:NAME_LEN]

        # Search FCB binary tree
        parent_slot = [None]   # use list so inner func can rebind
        cur = self._root_fcb
        insert_side = 0        # 0=root, -1=left, +1=right
        insert_parent = None

        node = self._root_fcb
        while node is not None:
            node_key = _str_to_field(node.filename, NAME_LEN)
            cmp = (name_key > node_key) - (name_key < node_key)
            if cmp == 0:
                self._cur_fcb = node
                return
            insert_parent = node
            insert_side   = cmp
            node = node.gt_tree if cmp > 0 else node.lt_tree

        # ONE_FCB: flush all pages before adding a new FCB
        if self._one_fcb and self._root_fcb is not None:
            if self._reserves != 0:
                raise SdfError(ERR_SEL_RESERVED)
            for e in self._pad[:self._num_ofpgs]:
                if e.fcb is None:
                    continue
                self._write_page(e)
                e.fcb.pad_refs[e.page_no // 8] = None
                e.fcb = e.modified = None
                e.use_count = e.page_no = e.resv_count = 0

        # Find in flat file index
        pg0_offset, pg_count = self._find_member(name_key)

        fcb = _Fcb(member_name[:NAME_LEN].rstrip())
        fcb.lst_page     = pg_count - 1
        fcb.page_offsets = [pg0_offset + i * PAGE_SIZE for i in range(pg_count)]
        fcb.pad_refs     = [None] * pg_count
        self._reads     += pg_count

        # Insert into FCB tree
        if insert_parent is None:
            self._root_fcb = fcb
        elif insert_side > 0:
            insert_parent.gt_tree = fcb
        else:
            insert_parent.lt_tree = fcb

        self._cur_fcb = fcb
        self._fcb_cnt += 1
        self._init_fcb_from_page0(fcb)

    def _find_member(self, name8: bytes):
        """Read the flat file index and locate a member by name8 key."""
        self._fp.seek(0)
        hdr = self._fp.read(8)
        if len(hdr) != 8 or hdr[:4] != FLAT_MAGIC:
            raise SdfError(ERR_OPEN_FAIL, 'not a valid SDF flat file')
        n = struct.unpack_from('>I', hdr, 4)[0]
        for _ in range(n):
            entry = self._fp.read(FLAT_IDX_ENTRY)
            if len(entry) != FLAT_IDX_ENTRY:
                raise SdfError(ERR_OPEN_FAIL, 'truncated index')
            if entry[:NAME_LEN] == name8:
                pg_count  = struct.unpack_from('>I', entry, 8)[0]
                pg0_offset= struct.unpack_from('>Q', entry, 12)[0]
                return pg0_offset, pg_count
        raise SdfError(RC_NOT_FOUND,
                       f'member not found: {name8.rstrip(b" ").decode()}')

    def _init_fcb_from_page0(self, fcb: _Fcb):
        pg0_mv = self._locate_vptr(vptr_make(0, 0))
        pz     = _PageZero(pg0_mv)
        fcb.version = pz.version
        dr_mv  = self._locate_vptr(pz.droot_ptr)
        dr     = _DRootCel(dr_mv)
        if dr.last_page > fcb.lst_page:
            raise SdfError(ERR_LEN_MISMATCH)
        fcb.num_blks  = dr.blk_nodes
        fcb.num_symbs = dr.sym_nodes
        fcb.fst_stmt  = dr.fstmt_num
        fcb.lst_stmt  = dr.lstm_num
        fcb.lst_page  = dr.last_page
        fcb.flags     = dr.sdf_flags
        fcb.blk_ptr   = dr.fbn_ptr
        fcb.symb_ptr  = dr.fsn_ptr
        fcb.stmt_ptr  = dr.fstn_ptr
        fcb.tree_ptr  = dr.btree_ptr
        fcb.stmt_expt = dr.snel_ptr
        fcb.node_size = 12 if (fcb.flags & FLAG_HAS_SRNS) else 4
        self._init_ptr = dr.dinit_ptr

    # ==================================================================
    # Private: block / symbol / statement helpers (SDFPKG.bal)
    # ==================================================================

    def _set_disps(self, disp_flags: int):
        if disp_flags == DISP_NONE:
            return
        e = self._cur_entry
        if e is None:
            raise SdfError(ERR_NO_CURENTRY)
        if disp_flags & DISP_MODF:
            if not self._mod_flag:
                raise SdfError(ERR_MODF_MODE)
            e.modified = True
        if disp_flags & DISP_RELS:
            if e.resv_count == 0:
                raise SdfError(ERR_RELEASE_OVF)
            e.resv_count -= 1
            if self._reserves > 0:
                self._reserves -= 1
        if disp_flags & DISP_RESV:
            if e.resv_count >= 0x7FFF:
                raise SdfError(ERR_RESERVE_OVF)
            e.resv_count += 1
            self._reserves += 1

    def _require_init(self):
        if not self._go_flag:
            raise SdfError(ERR_NOT_INIT)

    def _require_select(self):
        if self._cur_fcb is None:
            raise SdfError(ERR_NO_SELECT)

    def _do_block_lookup(self, disp: int, node_only: bool) -> BlockResult:
        self._save_extpt = VPTR_NULL
        self._sav_fsymb  = 0
        self._sav_lsymb  = 0
        blk_no  = self._comm_blk_no
        bn_ptr  = self._ndx2ptr(0, blk_no)
        bn_mv   = self._locate_vptr(bn_ptr)
        bn      = _BlckNode(bn_mv)
        self._comm_csect_nam = bn.csct_name

        result = BlockResult(blk_no=blk_no, csect_name=bn.csct_name)
        if node_only:
            self._set_disps(disp)
            return result

        bt_mv  = self._locate_vptr(bn.block_ptr)
        bt     = _BlktCell(bt_mv)
        self._comm_blk_nam   = bt.blk_name
        self._comm_blkn_len  = bt.bname_len
        self._save_extpt     = bt.ext_ptr
        self._sav_fsymb      = bt.fsymb_num
        self._sav_lsymb      = bt.lsymb_num

        result.blk_id    = bt.blk_id
        result.blk_class = bt.blk_class
        result.blk_type  = bt.blk_type
        result.blk_flags = bt.blk_flgs
        result.fsymb_no  = bt.fsymb_num
        result.lsymb_no  = bt.lsymb_num
        result.fstmt_no  = bt.fstmt_num
        result.lstm_no   = bt.lstm_num
        result.blk_name  = bt.blk_name

        self._set_disps(disp)
        return result

    def _do_symbol_fill(self, symb_no: int, sn: _SymbNode,
                         sdc_mv: memoryview, disp: int) -> SymbolResult:
        sdc = _SymbDC(sdc_mv)
        total_len = min(sdc.symb_len, LONG_NAME_LEN)
        name_bytes = bytes(sn.symb_name)[:NAME_LEN]
        if total_len > NAME_LEN:
            name_bytes = name_bytes + bytes(sdc.name_cont)[:total_len - NAME_LEN]
        full_name = name_bytes.decode('ascii', errors='replace').rstrip()
        self._comm_symb_nam  = full_name
        self._comm_symbn_len = total_len
        blk_num = sdc.block_num
        self._comm_blk_no  = blk_num
        self._comm_symb_no = symb_no

        result = SymbolResult(
            symb_no    = symb_no,
            blk_no     = blk_num,
            symb_name  = full_name,
            sym_class  = sdc.sym_class,
            sym_type   = sdc.sym_type,
            flag1      = sdc.flag1,
            flag2      = sdc.flag2,
            flag3      = sdc.flag3,
            flag4      = sdc.flag4,
            rows       = sdc.rows,
            columns    = sdc.columns,
            symb_len   = total_len,
            array_dims = sdc.array_dims,
        )
        self._set_disps(disp)
        return result

    def _chk_match(self, srcharg8: bytes, symb_no: int) -> int:
        """Return -1, 0, +1 for <, =, > comparison. Mirrors CHKMATCH."""
        try:
            sn_ptr = self._ndx2ptr(4, symb_no)
            sn_mv  = self._locate_vptr(sn_ptr)
        except SdfError:
            return 1
        sn = _SymbNode(sn_mv)
        cmp8 = (srcharg8 > sn.symb_name[:NAME_LEN]) - \
               (srcharg8 < sn.symb_name[:NAME_LEN])
        if cmp8 != 0:
            return cmp8

        try:
            sdc_mv = self._locate_vptr(sn.sdc_ptr)
        except SdfError:
            return 1
        sdc = _SymbDC(sdc_mv)

        if self._first_sym:
            return 0

        # Skip equate externals
        if sdc.sym_class == CLASS_EQUATE_EXT and sdc.sym_type == TYPE_EQUATE_EXT:
            return 0

        if sdc.sym_class <= 3:
            if (sdc.flag1 & FLAG1_UNQUAL_STRUC) == 0:
                return 0

        # Full name comparison
        sought  = srcharg8.rstrip(b' ')
        sought_l= len(sought)
        found_l = min(sdc.symb_len, LONG_NAME_LEN)
        found   = (bytes(sn.symb_name)[:NAME_LEN] +
                   bytes(sdc.name_cont))[:found_l].rstrip(b' ')
        found_l = len(found)
        cmp_l   = min(sought_l, found_l)
        if sought[:cmp_l] != found[:cmp_l]:
            return 1 if sought[:cmp_l] > found[:cmp_l] else -1
        if sought_l == found_l:
            return 0
        return -1 if sought_l < found_l else 1

    def _symbol_binary_search(self, srcharg8: bytes):
        lo = self._sav_fsymb
        hi = self._sav_lsymb

        # Extent cell narrowing
        if self._save_extpt != VPTR_NULL:
            ext_ptr = self._save_extpt
            while ext_ptr != VPTR_NULL:
                try:
                    ext_mv = self._locate_vptr(ext_ptr)
                except SdfError:
                    break
                ef   = _SymExtF(ext_mv)
                voff = _SymExtF.SIZE
                for i in range(ef.next_ntry):
                    ev = _SymExtV(ext_mv, voff)
                    if ev.fst_symb > srcharg8:
                        raise SdfError(RC_SYM_NOT_FOUND)
                    if ev.lst_symb >= srcharg8:
                        delta = (ev.lst_off - ev.fst_off) // 12
                        hi    = lo + delta
                        # Cap hi at the block's own last symbol number.
                        if hi > self._sav_lsymb:
                            hi = self._sav_lsymb
                        break
                    cnt = (ev.lst_off - ev.fst_off) // 12 + 1
                    lo += cnt
                    voff += _SymExtV.SIZE
                ext_ptr = ef.succ_ptr

        # Binary search
        while lo <= hi:
            mid = (lo + hi) // 2
            d   = self._chk_match(srcharg8, mid)
            if d == 0:
                # Scan backward for first occurrence
                candidate = mid
                while candidate > self._sav_fsymb:
                    if self._chk_match(srcharg8, candidate - 1) != 0:
                        break
                    candidate -= 1
                # Scan forward for best match
                while candidate <= self._sav_lsymb:
                    try:
                        sn_ptr = self._ndx2ptr(4, candidate)
                        sn_mv  = self._locate_vptr(sn_ptr)
                    except SdfError:
                        break
                    sn = _SymbNode(sn_mv)
                    if srcharg8 != sn.symb_name[:NAME_LEN]:
                        break
                    try:
                        sdc_mv = self._locate_vptr(sn.sdc_ptr)
                    except SdfError:
                        break
                    if self._chk_match(srcharg8, candidate) == 0:
                        return candidate, sn, sdc_mv
                    candidate += 1
                raise SdfError(RC_SYM_NOT_FOUND)
            elif d < 0:
                if mid == 0:
                    break
                hi = mid - 1
            else:
                lo = mid + 1

        raise SdfError(RC_SYM_NOT_FOUND)


# ======================================================================
# sdf_convert equivalent: flat-file / PDS conversion
# ======================================================================

def pds_info(pds_path: str) -> list[dict]:
    """Read a raw PDS binary and return a list of member dicts."""
    with open(pds_path, 'rb') as f:
        members = _read_pds_directory(f)
        data_start = f.tell()
    offset = data_start
    for m in members:
        m['pds_offset'] = offset
        offset += m['page_count'] * PAGE_SIZE
    return members

def flat_info(flat_path: str) -> list[dict]:
    """Read a flat SDF file and return a list of member dicts."""
    with open(flat_path, 'rb') as f:
        hdr = f.read(8)
        if hdr[:4] != FLAT_MAGIC:
            raise ValueError(f'{flat_path}: not a valid SDF flat file')
        n = struct.unpack_from('>I', hdr, 4)[0]
        members = []
        for _ in range(n):
            e = f.read(FLAT_IDX_ENTRY)
            name = e[:NAME_LEN].rstrip(b' ').decode('ascii', errors='replace')
            pc   = struct.unpack_from('>I', e, 8)[0]
            off  = struct.unpack_from('>Q', e, 12)[0]
            members.append({'name': name, 'page_count': pc, 'offset': off})
    return members

def pds2flat(pds_path: str, flat_path: str,
             member_filter: Optional[list[str]] = None) -> int:
    """
    Convert a raw z/OS PDS binary to a sdfpkg flat file.
    Returns the number of members written.
    """
    with open(pds_path, 'rb') as pds:
        all_members = _read_pds_directory(pds)
        data_start  = pds.tell()
        wanted = [m for m in all_members
                  if member_filter is None or
                  m['name'].upper() in {s.upper() for s in member_filter}]
        if not wanted:
            raise ValueError('no matching members found')

        # Assign sequential PDS data offsets
        offset = data_start
        for m in all_members:
            m['pds_offset'] = offset
            offset += m['page_count'] * PAGE_SIZE

        wanted_names = {m['name'] for m in wanted}

        with open(flat_path, 'wb') as flat:
            # Write header placeholder
            flat.write(FLAT_MAGIC)
            flat.write(struct.pack('>I', len(wanted)))
            # Write blank index entries (will be filled in below)
            idx_start = flat.tell()
            flat.write(b'\x00' * (FLAT_IDX_ENTRY * len(wanted)))

            # Write page data and record offsets
            offsets = []
            for m in wanted:
                pds.seek(m['pds_offset'])
                page_offset = flat.tell()
                for _ in range(m['page_count']):
                    page = pds.read(PAGE_SIZE)
                    if len(page) != PAGE_SIZE:
                        raise IOError(f'short read on member {m["name"]}')
                    flat.write(page)
                offsets.append(page_offset)

            # Fill in index entries
            for i, m in enumerate(wanted):
                name_field = m['name'].encode('ascii').ljust(NAME_LEN)[:NAME_LEN]
                entry = (name_field +
                         struct.pack('>I', m['page_count']) +
                         struct.pack('>Q', offsets[i]))
                flat.seek(idx_start + i * FLAT_IDX_ENTRY)
                flat.write(entry)

    return len(wanted)

def flat2pds(flat_path: str, pds_path: str,
             member_filter: Optional[list[str]] = None) -> int:
    """
    Convert a sdfpkg flat file to a raw z/OS PDS binary.
    Returns the number of members written.
    """
    members = flat_info(flat_path)
    if member_filter is not None:
        upper = {s.upper() for s in member_filter}
        members = [m for m in members if m['name'].upper() in upper]
    if not members:
        raise ValueError('no matching members found')

    # Determine how many directory blocks we need
    EPB = 254 // 28     # entries per 256-byte block (28 bytes each)
    dir_blocks = (len(members) + EPB - 1) // EPB + 1  # +1 for sentinel

    with open(flat_path, 'rb') as flat:
        with open(pds_path, 'wb') as pds:
            # Write placeholder directory
            _write_pds_directory(pds, members, dir_blocks, 0)
            data_start = pds.tell()

            # Write member data
            page_offsets_in_pds = []
            abs_block = dir_blocks
            for m in members:
                page_offsets_in_pds.append(abs_block)
                flat.seek(m['offset'])
                for _ in range(m['page_count']):
                    page = flat.read(PAGE_SIZE)
                    if len(page) != PAGE_SIZE:
                        raise IOError(f'short read on member {m["name"]}')
                    pds.write(page)
                abs_block += m['page_count']

            # Rewrite directory with correct TTRs
            pds.seek(0)
            _write_pds_directory(pds, members, dir_blocks,
                                 dir_blocks, page_offsets_in_pds)

    return len(members)

# --- PDS directory helpers ---

_EBCDIC_TO_ASCII = bytes([
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  # 00
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  # 10
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  # 20
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  # 30
    32,0,0,0,0,0,0,0,0,0,91,46,60,40,43,124,  # 40
    38,0,0,0,0,0,0,0,0,0,33,36,42,41,59,94,   # 50
    45,47,0,0,0,0,0,0,0,0,124,44,37,95,62,63, # 60
    0,0,0,0,0,0,0,0,0,96,58,35,64,39,61,34,   # 70
    0,97,98,99,100,101,102,103,104,105,0,0,0,0,0,0,  # 80
    0,106,107,108,109,110,111,112,113,114,0,0,0,0,0,0,# 90
    0,126,115,116,117,118,119,120,121,122,0,0,0,0,0,0,# a0
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  # b0
    123,65,66,67,68,69,70,71,72,73,0,0,0,0,0,0,  # c0
    125,74,75,76,77,78,79,80,81,82,0,0,0,0,0,0,  # d0
    92,48,83,84,85,86,87,88,89,90,0,0,0,0,0,0,   # e0
    48,49,50,51,52,53,54,55,56,57,0,0,0,0,0,0,   # f0
])

_ASCII_TO_EBCDIC = bytearray(256)
for _i, _v in enumerate(_EBCDIC_TO_ASCII):
    if _v:
        _ASCII_TO_EBCDIC[_v] = _i
# Digits
for _d in range(10):
    _ASCII_TO_EBCDIC[ord('0') + _d] = 0xF0 + _d
_ASCII_TO_EBCDIC[ord(' ')] = 0x40

def _ebcdic_to_name(data: bytes) -> str:
    return bytes(_EBCDIC_TO_ASCII[b] or 0x20 for b in data[:8]) \
           .rstrip(b' ').decode('ascii', errors='replace')

def _name_to_ebcdic(name: str) -> bytes:
    b = name.encode('ascii', errors='replace')
    return bytes(_ASCII_TO_EBCDIC[c] for c in b[:8]).ljust(8, b'\x40')[:8]

def _read_pds_directory(f) -> list[dict]:
    members = []
    while True:
        block = f.read(256)
        if len(block) < 256:
            raise IOError('truncated PDS directory')
        used = struct.unpack_from('>H', block)[0]
        if block[2:10] == b'\xff' * 8:
            break
        pos = 2
        while pos + 8 <= used:
            e = block[pos:]
            if e[:8] == b'\xff' * 8:
                return members
            if pos + 12 > used:
                break
            alias      = (e[11] >> 7) & 1
            halfwords  = (e[11] >> 3) & 0x1F
            user_bytes = halfwords * 2
            entry_len  = 12 + user_bytes
            if pos + entry_len > 256:
                break
            if not alias:
                name    = _ebcdic_to_name(e[:8])
                ttr     = (e[8] << 16) | (e[9] << 8) | e[10]
                pgelast = 0
                if user_bytes >= 14 and pos + 26 <= 256:
                    pgelast = struct.unpack_from('>H', block, pos + 24)[0]
                members.append({'name': name, 'ttr': ttr,
                                'page_count': pgelast + 1})
            pos += entry_len
    return members

def _write_pds_directory(f, members, dir_blocks_needed,
                          first_abs_block=0, abs_blocks=None):
    """Write PDS directory blocks.  abs_blocks is a list of absolute
    block numbers for each member (used to set TTRs).  If None,
    TTRs are set to zero (placeholder pass)."""
    BLOCK = 256
    EPB   = 254 // 28
    mi    = 0
    for b in range(dir_blocks_needed):
        block = bytearray(BLOCK)
        pos   = 2
        while mi < len(members) and pos + 28 <= 254:
            m = members[mi]
            e = bytearray(28)
            e[:8] = _name_to_ebcdic(m['name'])
            if abs_blocks is not None:
                ab = abs_blocks[mi]
                TT = ab >> 8
                R  = (ab & 0xFF) + 1
                e[8]  = (TT >> 8) & 0xFF
                e[9]  =  TT       & 0xFF
                e[10] = R
            e[11] = (8 << 3) & 0xFF   # 8 halfwords = 16 bytes user data
            e[12] = 0x40; e[13] = 0x40  # RVL = EBCDIC spaces
            struct.pack_into('>H', e, 24, m['page_count'] - 1)  # PGELAST
            block[pos:pos+28] = e
            pos += 28
            mi  += 1
        if mi >= len(members) and pos + 12 <= 254:
            block[pos:pos+8] = b'\xff' * 8
            block[pos+8:pos+12] = b'\x00' * 4
            pos += 12
            mi += 1
        struct.pack_into('>H', block, 0, pos)
        f.write(bytes(block))
        if mi > len(members):
            break
    if mi == len(members):
        sentinel = bytearray(256)
        sentinel[2:10] = b'\xff' * 8
        struct.pack_into('>H', sentinel, 0, 14)
        f.write(bytes(sentinel))


# ======================================================================
# sdfcheck equivalent
# ======================================================================

def sdfcheck(flat_path: str,
             member_names: Optional[list[str]] = None) -> dict[str, bool]:
    """
    Validate members of a flat SDF file.
    Returns a dict mapping member name -> True (good) / False (bad).
    """
    members = flat_info(flat_path)
    if member_names is not None:
        upper = {s.upper() for s in member_names}
        members = [m for m in members if m['name'].upper() in upper]

    results = {}
    with SdfContext.open(flat_path) as ctx:
        for m in members:
            try:
                ctx.select(m['name'])
                ctx.locate_root()
                results[m['name']] = True
            except SdfError:
                results[m['name']] = False
    return results


# ======================================================================
# Command-line entry point (mirrors sdfcheck and sdf_convert)
# ======================================================================

# Per-command help strings
_HELP = {
    'flat_info': """Usage: sdfpkg.py flat_info <file.sdf> [file2.sdf ...]

List the members stored in one or more sdfpkg flat files.

Arguments:
  file.sdf      Path to a sdfpkg flat file (produced by pds2flat or
                directly by the HAL/S-FC compiler port).

Output columns:
  NAME          Member name (up to 8 characters, ASCII).
  PAGES         Number of 1680-byte SDF pages for this member.
  OFFSET        Byte offset of the first page within the flat file.
  BYTES         Total data size (PAGES × 1680).

Example:
  sdfpkg.py flat_info PASS1.sdf
""",

    'pds_info': """Usage: sdfpkg.py pds_info <file.pds> [file2.pds ...]

List the members stored in one or more raw z/OS PDS binary files.

The input must be a binary dump of a z/OS Partitioned Dataset with:
  DSORG=PO, RECFM=F, LRECL=1680, BLKSIZE=1680
as produced by Hercules, sim360, or an IEBCOPY RECFM=U transfer.

Arguments:
  file.pds      Path to a raw PDS binary file.

Output columns:
  NAME          Member name (converted from EBCDIC to ASCII).
  PAGES         Number of SDF pages (derived from the PGELAST field
                in the PDS directory user-data area).
  PDS_OFFSET    Byte offset of the member's first page within the file.
  BYTES         Total data size (PAGES × 1680).

Example:
  sdfpkg.py pds_info HAL_SDF.pds
""",

    'pds2flat': """Usage: sdfpkg.py pds2flat <input.pds> <output.sdf> [member ...]

Convert a raw z/OS PDS binary file to a sdfpkg flat file.

Arguments:
  input.pds     Source PDS binary (DSORG=PO, RECFM=F, LRECL=1680).
  output.sdf    Destination flat file (created or overwritten).
  member ...    Optional list of member names to extract (case-
                insensitive).  If omitted, all members are converted.

The flat file format is described in the module docstring and is the
format expected by SdfContext.open() and sdfcheck().

Exits with status 0 on success, 1 on error.

Examples:
  sdfpkg.py pds2flat HAL_SDF.pds  PASS1.sdf
  sdfpkg.py pds2flat HAL_SDF.pds  subset.sdf  HALSDF HALSDF2
""",

    'flat2pds': """Usage: sdfpkg.py flat2pds <input.sdf> <output.pds> [member ...]

Convert a sdfpkg flat file back to a raw z/OS PDS binary file.

Arguments:
  input.sdf     Source flat file (produced by pds2flat or the compiler
                port).
  output.pds    Destination PDS binary (created or overwritten).
  member ...    Optional list of member names to include (case-
                insensitive).  If omitted, all members are converted.

The output PDS uses the post-CR11097 directory layout (RVL + PGELAST
in the user-data area) and is suitable for use with Hercules or sim360.
TTR addresses use a flat block-number encoding compatible with sim360's
sequential POINT+READ access pattern.

Exits with status 0 on success, 1 on error.

Examples:
  sdfpkg.py flat2pds PASS1.sdf   HAL_SDF.pds
  sdfpkg.py flat2pds PASS1.sdf   partial.pds  HALSDF
""",

    'sdfcheck': """Usage: sdfpkg.py sdfcheck <file.sdf> [member ...]

Validate the members of a sdfpkg flat file.

Each member is selected and its directory root cell is located.  A
member is reported GOOD if both operations succeed without error, and
BAD BAD BAD !! otherwise.

Arguments:
  file.sdf      Path to a sdfpkg flat file.
  member ...    Optional list of member names to check (case-
                insensitive).  If omitted, all members are checked.

Output format (one line per member):
  SDF <name>  IS  GOOD
  SDF <name>  IS  BAD BAD BAD !!

Exits with status 0 if all members are GOOD, 1 if any are BAD,
2 if the file could not be opened.

Example:
  sdfpkg.py sdfcheck PASS1.sdf
  sdfpkg.py sdfcheck PASS1.sdf  HALSDF HALSDF2
""",
}

_USAGE_SUMMARY = """Usage: sdfpkg.py <command> [arguments]

Python 3 port of the HAL/S Symbol Data File (SDF) package.
Ported from IBM System/360 BAL (HAL/S-FC Space Shuttle compiler).

Commands:
  flat_info   List members in a sdfpkg flat file.
  pds_info    List members in a raw z/OS PDS binary file.
  pds2flat    Convert a raw PDS binary to a sdfpkg flat file.
  flat2pds    Convert a sdfpkg flat file to a raw PDS binary.
  sdfcheck    Validate members of a sdfpkg flat file.

Run 'sdfpkg.py help <command>' for detailed help on a specific command.
Run 'sdfpkg.py help' or 'sdfpkg.py --help' for this summary.

The sdfpkg flat file format
---------------------------
A flat file contains one or more SDF members in a simple layout:

  [4 bytes]  Magic:  0x53 0x44 0x46 0x00  ("SDF\0")
  [4 bytes]  Member count N (big-endian uint32)
  N × 20 bytes:
    [8 bytes]  Member name (ASCII, space-padded)
    [4 bytes]  Page count  (big-endian uint32)
    [8 bytes]  File offset of page 0 (big-endian uint64)
  Member data: concatenated 1680-byte pages, in index order.

Using sdfpkg as a Python library
----------------------------------
  from sdfpkg import SdfContext

  with SdfContext.open('my.sdf') as ctx:
      ctx.select('MYMEMBER')
      blk = ctx.find_block_by_number(1)
      print(blk.blk_name, blk.fsymb_no, blk.lsymb_no)

      sym = ctx.find_symbol_by_name('MYSYMBOL')
      print(sym.symb_name, sym.sym_class)

      stmt = ctx.find_stmt_by_srn(b'S0042 ')
      print(stmt.stmt_no, stmt.is_executable)
"""



# ======================================================================
# SDF write infrastructure
# (Python port of sdf_write.h / sdf_write.c)
# ======================================================================

# Block class constants
BCLASS_PROGRAM   = 1
BCLASS_FUNCTION  = 2
BCLASS_PROCEDURE = 3
BCLASS_TASK      = 4
BCLASS_COMPOOL   = 5
BCLASS_CLOSE     = 6

# Symbol class constants
SCLASS_VARIABLE   = 1
SCLASS_EQUATE_EXT = 2
SCLASS_TEMPLATE   = 3
SCLASS_LABEL      = 4
SCLASS_COMPOOL    = 6

# Symbol type constants
STYPE_SCALAR     = 1
STYPE_INTEGER    = 2
STYPE_BOOLEAN    = 3
STYPE_CHARACTER  = 4
STYPE_BIT        = 5
STYPE_VECTOR     = 6
STYPE_MATRIX     = 7
STYPE_EQUATE_EXT = 8
STYPE_EVENT      = 9
STYPE_STRUCTURE  = 10
STYPE_TASK       = 11

# Statement type constants
STTYPE_ASSIGN    = 1
STTYPE_IF        = 2
STTYPE_DO        = 3
STTYPE_DO_WHILE  = 4
STTYPE_DO_UNTIL  = 5
STTYPE_DO_FOR    = 6
STTYPE_END       = 7
STTYPE_RETURN    = 8
STTYPE_CALL      = 9
STTYPE_GOTO      = 10
STTYPE_ON_ERROR  = 11

# Write flags
WFLAG_NONE     = 0x0000
WFLAG_HAS_SRNS = 0x8000
WFLAG_NONMONO  = 0x0400


@dataclass
class WBlock:
    """Descriptor for one block (program unit) passed to SdfWriter."""
    csect_name: str = ''
    blk_name:   str = ''
    blk_class:  int = BCLASS_PROGRAM
    blk_type:   int = 0
    blk_id:     int = 1
    blk_flags:  int = 0
    post_dcl:   int = 0
    stak_list:  int = 0


@dataclass
class WSymbol:
    """Descriptor for one symbol passed to SdfWriter."""
    blk_no:     int   = 0
    symb_name:  str   = ''
    sym_class:  int   = SCLASS_VARIABLE
    sym_type:   int   = STYPE_SCALAR
    flag1:      int   = 0
    flag2:      int   = 0
    flag3:      int   = 0
    flag4:      int   = 0
    rows:       int   = 0
    columns:    int   = 0
    rel_addr:   int   = 0
    lock_num:   int   = 0
    byte_size:  int   = 0
    array_dims: tuple = (0, 0, 0, 0)
    # array_dims: (ndims, d1, d2, d3).  ndims=0 means not an array.
    # Examples:
    #   ARRAY(10) SCALAR     -> (1, 10, 0, 0)
    #   ARRAY(3, 4) INTEGER  -> (2,  3, 4, 0)
    #   ARRAY(5) VECTOR(3)   -> (1,  5, 0, 0)  (rows=3 for the VECTOR)


@dataclass
class WStmt:
    """Descriptor for one statement passed to SdfWriter."""
    blk_no:    int   = 0
    srn:       bytes = b'      '   # 6 bytes, space-padded
    incl_cnt:  int   = 0
    stmt_type: int   = STTYPE_ASSIGN
    is_exec:   bool  = True
    num_lhs:   int   = 0
    num_labls: int   = 0


class SdfWriter:
    """
    Write-side context for creating a new SDF flat file member.

    Usage::

        with SdfWriter.create('myfile.sdf', 'MYMOD',
                               flags=WFLAG_HAS_SRNS) as w:
            blk_no = w.add_block(WBlock(csect_name='CS',
                                        blk_name='MYMOD',
                                        blk_class=BCLASS_PROGRAM))
            w.add_symbol(WSymbol(blk_no=blk_no,
                                 symb_name='ALTITUDE',
                                 sym_type=STYPE_SCALAR))
            w.add_stmt(WStmt(blk_no=blk_no, srn=b'S0001 ',
                             stmt_type=STTYPE_ASSIGN, is_exec=True,
                             num_lhs=1))
            # w.commit() is called automatically on context-manager exit

    Symbols are sorted alphabetically at commit time; they may be added
    in any order.  Blocks are sorted by name.  Statements must be added
    in source (statement-number) order.
    """

    def __init__(self):
        self._blocks:    list  = []
        self._symbols:   list  = []
        self._stmts:     list  = []
        self._init_data: bytes = b''
        self._init_reladdrs: dict = {}   # symb_no -> rel_addr halfword offset
        self._flags   = WFLAG_NONE
        self._version = 1
        self._member  = ''
        self._path    = ''
        self._append  = False   # True -> sdf_add_member mode
        self._committed = False

    # ------------------------------------------------------------------
    # Factory methods
    # ------------------------------------------------------------------

    @classmethod
    def create(cls, path: str, member_name: str,
               version: int = 1, flags: int = WFLAG_NONE) -> 'SdfWriter':
        """Create a new SDF flat file and begin a new member."""
        w = cls()
        w._path    = path
        w._member  = member_name[:NAME_LEN].rstrip()
        w._version = version or 1
        w._flags   = flags
        w._append  = False
        return w

    @classmethod
    def add_member(cls, path: str, member_name: str,
                   version: int = 1, flags: int = WFLAG_NONE) -> 'SdfWriter':
        """Add a new member to an existing SDF flat file."""
        w = cls()
        w._path    = path
        w._member  = member_name[:NAME_LEN].rstrip()
        w._version = version or 1
        w._flags   = flags
        w._append  = True
        return w

    def __enter__(self):
        return self

    def __exit__(self, exc_type, *_):
        if exc_type is None and not self._committed:
            self.commit()
        return False

    # ------------------------------------------------------------------
    # Adding data
    # ------------------------------------------------------------------

    def add_block(self, blk: WBlock) -> int:
        """
        Add a block descriptor.  Returns the assigned block number (1-based).
        Blocks may be added in any order; they are sorted by name at commit.
        Raises SdfError(SDF_ERR_DUP_BLK) on duplicate name.
        """
        for b in self._blocks:
            if b['desc'].blk_name == blk.blk_name:
                raise SdfError(-4032, f'duplicate block name: {blk.blk_name}')
        blk_no = len(self._blocks) + 1   # provisional; fixed at commit
        self._blocks.append({'desc': blk, 'blk_no': blk_no,
                              'fsymb_no': 0, 'lsymb_no': 0,
                              'fstmt_no': 0, 'lstm_no': 0,
                              'btcell_vptr': VPTR_NULL})
        return blk_no

    def add_symbol(self, sym: WSymbol) -> int:
        """
        Add a symbol descriptor.  Returns the provisional symbol number.
        Final numbers are assigned after alphabetical sort at commit.
        Raises SdfError(-4033) on duplicate name within the same block.
        """
        for s in self._symbols:
            if (s['desc'].blk_no == sym.blk_no and
                    s['desc'].symb_name == sym.symb_name):
                raise SdfError(-4033,
                    f'duplicate symbol: {sym.symb_name} in block {sym.blk_no}')
        symb_no = len(self._symbols) + 1
        self._symbols.append({'desc': sym, 'symb_no': symb_no,
                               'init_rel_addr': 0, 'has_init': False})
        return symb_no

    def add_stmt(self, stmt: WStmt) -> int:
        """
        Add a statement descriptor in source order.
        Returns the assigned statement number (1-based).
        """
        stmt_no = len(self._stmts) + 1
        self._stmts.append({'desc': stmt, 'stmt_no': stmt_no})
        return stmt_no

    def add_init_data(self, symb_no: int, data: bytes) -> None:
        """
        Attach initialisation data for the symbol identified by symb_no.
        data must be big-endian and an even number of bytes.
        """
        if len(data) == 0 or len(data) & 1:
            raise SdfError(-4037, 'init data must be a non-empty even number of bytes')
        if symb_no < 1 or symb_no > len(self._symbols):
            raise SdfError(-4037, f'invalid symb_no {symb_no}')
        rel_addr = len(self._init_data) // 2
        self._init_reladdrs[symb_no] = rel_addr
        self._init_data += data

    # ------------------------------------------------------------------
    # commit() -- sorts, lays out virtual memory, writes the file
    # ------------------------------------------------------------------

    def commit(self) -> None:
        """
        Finalise the member: sort symbols and blocks, build the block
        binary tree and extent cells, lay out all structures into
        virtual-memory page buffers, and write the flat file.
        """
        if self._committed:
            raise SdfError(-4035, 'already committed')
        self._committed = True

        has_srns = bool(self._flags & WFLAG_HAS_SRNS)
        node_sz  = 12 if has_srns else 4

        # ---- 1. Sort blocks by name; reassign numbers ----
        self._blocks.sort(key=lambda b: b['desc'].blk_name)
        for i, b in enumerate(self._blocks):
            b['blk_no'] = i + 1

        # ---- 2. Sort symbols: alphabetically within each block,
        #         then concatenate in block order.
        # This keeps each block's symbols contiguous, which is required
        # for the fsymb_no..lsymb_no range in BLKTCELL to be meaningful.
        def blk_order(s):
            # Return (block_sort_position, symbol_name)
            for bi, b in enumerate(self._blocks):
                if b['blk_no'] == s['desc'].blk_no:
                    return (bi, s['desc'].symb_name)
            return (999, s['desc'].symb_name)
        self._symbols.sort(key=blk_order)
        for i, s in enumerate(self._symbols):
            s['symb_no'] = i + 1

        # Fix self-referential template header rows fields:
        # A STRUCTURE template header (CLASS=3, TYPE=10) should have
        # rows = its own final symbol number.
        for s in self._symbols:
            d = s['desc']
            if d.sym_class == 3 and d.sym_type == 10:
                d.rows = s['symb_no']

        # ---- 3. Compute per-block symbol and statement ranges ----
        for sym in self._symbols:
            bn  = sym['desc'].blk_no
            sno = sym['symb_no']
            for blk in self._blocks:
                if blk['blk_no'] == bn:
                    if blk['fsymb_no'] == 0 or sno < blk['fsymb_no']:
                        blk['fsymb_no'] = sno
                    if sno > blk['lsymb_no']:
                        blk['lsymb_no'] = sno
                    break
        for stmt in self._stmts:
            bn   = stmt['desc'].blk_no
            stno = stmt['stmt_no']
            for blk in self._blocks:
                if blk['blk_no'] == bn:
                    if blk['fstmt_no'] == 0 or stno < blk['fstmt_no']:
                        blk['fstmt_no'] = stno
                    if stno > blk['lstm_no']:
                        blk['lstm_no'] = stno
                    break

        # ---- 4. Virtual memory: bump-pointer allocator ----
        # Pages are stored as bytearrays.  Page 0 is reserved for
        # PAGEZERO + DROOTCEL.  Data starts at page 1.
        pages = [bytearray(PAGE_SIZE)]  # page 0
        cur_page   = 1
        cur_offset = 0

        def alloc(size: int) -> tuple:
            """Allocate size bytes; never straddles a page. Returns (page, off)."""
            nonlocal cur_page, cur_offset, pages
            if size > PAGE_SIZE:
                raise SdfError(-4031, f'allocation {size} exceeds page size')
            if cur_offset + size > PAGE_SIZE:
                cur_page   += 1
                cur_offset  = 0
            while len(pages) <= cur_page:
                pages.append(bytearray(PAGE_SIZE))
            vp = vptr_make(cur_page, cur_offset)
            cur_offset += size
            return vp

        def buf(vp: int) -> memoryview:
            return memoryview(pages[vptr_page(vp)])[vptr_offset(vp):]

        def wp16(vp, off, v):
            b = pages[vptr_page(vp)]
            o = vptr_offset(vp) + off
            b[o]   = (v >> 8) & 0xFF
            b[o+1] =  v       & 0xFF

        def wp32(vp, off, v):
            b = pages[vptr_page(vp)]
            o = vptr_offset(vp) + off
            struct.pack_into('>I', b, o, v & 0xFFFFFFFF)

        def wpstr(vp, off, s, n):
            b = pages[vptr_page(vp)]
            o = vptr_offset(vp) + off
            enc = (s.encode('ascii') + b' ' * n)[:n]
            b[o:o+n] = enc

        def wpvp(vp, off, target_vp):
            wp32(vp, off, target_vp)

        # ---- 5. Block nodes ----
        bnode_vptrs = []
        for blk in self._blocks:
            vp = alloc(12)
            bnode_vptrs.append(vp)
        fbn_vptr = bnode_vptrs[0] if bnode_vptrs else VPTR_NULL
        lbn_vptr = bnode_vptrs[-1] if bnode_vptrs else VPTR_NULL

        # ---- 6. Block tree cells (balanced BST) ----
        btree_root = VPTR_NULL

        def build_btree(lo: int, hi: int) -> int:
            if lo > hi:
                return VPTR_NULL
            mid  = (lo + hi) // 2
            blk  = self._blocks[mid]
            name = blk['desc'].blk_name
            nlen = min(len(name), LONG_NAME_LEN)
            # Fixed part (45 bytes) + name bytes
            sz   = 45 + nlen
            vp   = alloc(sz)
            blk['btcell_vptr'] = vp

            left  = build_btree(lo, mid - 1)
            right = build_btree(mid + 1, hi)

            wpvp(vp,  0, right)
            wpvp(vp,  4, left)
            wp32(vp,  8, 0); wp32(vp, 12, 0)   # fnest/lnest
            wp32(vp, 16, 0)                      # ext_ptr (set later)
            wp32(vp, 20, 0)                      # spare
            pages[vptr_page(vp)][vptr_offset(vp)+24] = blk['desc'].blk_flags
            pages[vptr_page(vp)][vptr_offset(vp)+25] = 0
            wp16(vp, 26, blk['blk_no'])
            wp16(vp, 28, blk['desc'].blk_id)
            pages[vptr_page(vp)][vptr_offset(vp)+30] = blk['desc'].blk_class
            pages[vptr_page(vp)][vptr_offset(vp)+31] = blk['desc'].blk_type
            wp16(vp, 32, blk['fsymb_no'])
            wp16(vp, 34, blk['lsymb_no'])
            wp16(vp, 36, blk['fstmt_no'])
            wp16(vp, 38, blk['lstm_no'])
            wp16(vp, 40, blk['desc'].post_dcl)
            wp16(vp, 42, blk['desc'].stak_list)
            pages[vptr_page(vp)][vptr_offset(vp)+44] = nlen
            enc = name.encode('ascii')[:nlen]
            o   = vptr_offset(vp) + 45
            pages[vptr_page(vp)][o:o+nlen] = enc
            return vp

        if self._blocks:
            btree_root = build_btree(0, len(self._blocks) - 1)

        # Write block nodes (btcell_vptr now known)
        for i, blk in enumerate(self._blocks):
            vp = bnode_vptrs[i]
            wpstr(vp, 0, blk['desc'].csect_name, NAME_LEN)
            wpvp (vp, 8, blk['btcell_vptr'])

        # ---- 7. Symbol nodes ----
        snode_vptrs = []
        for sym in self._symbols:
            vp = alloc(12)
            snode_vptrs.append(vp)
        fsn_vptr = snode_vptrs[0]  if snode_vptrs else VPTR_NULL
        lsn_vptr = snode_vptrs[-1] if snode_vptrs else VPTR_NULL

        # ---- 8. Symbol data cells ----
        sdc_vptrs = []
        for sym in self._symbols:
            d     = sym['desc']            # must be inside the loop
            name  = d.symb_name
            nlen  = min(len(name), LONG_NAME_LEN)
            cont  = max(0, nlen - NAME_LEN)
            has_array = (d.array_dims[0] > 0)
            sz    = 24 + cont + (8 if has_array else 0)
            vp    = alloc(sz)
            sdc_vptrs.append(vp)
            ra    = (self._init_reladdrs.get(sym['symb_no'], d.rel_addr))
            b     = pages[vptr_page(vp)]
            o     = vptr_offset(vp)
            struct.pack_into('>H', b, o, d.blk_no)
            # array_off: byte offset from SDC start to ARRADATA (0 if none)
            b[o+4]  = (24 + cont) if has_array else 0
            b[o+6]  = d.sym_class
            b[o+7]  = d.sym_type
            b[o+8]  = d.flag1
            b[o+9]  = d.flag2
            b[o+10] = d.flag3
            b[o+11] = d.flag4
            b[o+12] = nlen
            b[o+13] = (ra >> 16) & 0xFF
            b[o+14] = (ra >>  8) & 0xFF
            b[o+15] =  ra        & 0xFF
            b[o+18] = d.rows
            b[o+19] = d.columns
            b[o+20] = d.lock_num
            b[o+21] = (d.byte_size >> 16) & 0xFF
            b[o+22] = (d.byte_size >>  8) & 0xFF
            b[o+23] =  d.byte_size        & 0xFF
            if cont:
                enc = name[NAME_LEN:].encode('ascii')[:cont]
                b[o+24:o+24+cont] = enc
            if has_array:
                ao = o + 24 + cont
                struct.pack_into('>HHHH', b, ao,
                    d.array_dims[0], d.array_dims[1],
                    d.array_dims[2], d.array_dims[3])

        # Write symbol nodes
        for i, sym in enumerate(self._symbols):
            vp = snode_vptrs[i]
            wpstr(vp, 0, sym['desc'].symb_name, NAME_LEN)
            wpvp (vp, 8, sdc_vptrs[i])

        # ---- 9. Statement nodes ----
        stnode_vptrs = []
        stdc_vptrs   = []
        exec_count   = 0
        for stmt in self._stmts:
            vp = alloc(node_sz)
            stnode_vptrs.append(vp)
        fstn_vptr = stnode_vptrs[0]  if stnode_vptrs else VPTR_NULL
        lstn_vptr = stnode_vptrs[-1] if stnode_vptrs else VPTR_NULL

        for stmt in self._stmts:
            if stmt['desc'].is_exec:
                stdc_vptrs.append(alloc(6))
                exec_count += 1
            else:
                stdc_vptrs.append(VPTR_NULL)

        for i, stmt in enumerate(self._stmts):
            svp = stnode_vptrs[i]
            d   = stmt['desc']
            b   = pages[vptr_page(svp)]
            o   = vptr_offset(svp)
            srn = (bytes(d.srn) + b'      ')[:SRN_LEN]
            if has_srns:
                b[o:o+SRN_LEN]       = srn
                struct.pack_into('>H', b, o+6, d.incl_cnt)
                struct.pack_into('>I', b, o+8,
                    stdc_vptrs[i] if d.is_exec else 0)
            else:
                struct.pack_into('>I', b, o,
                    stdc_vptrs[i] if d.is_exec else 0)

            if d.is_exec and stdc_vptrs[i] != VPTR_NULL:
                dvp = stdc_vptrs[i]
                db  = pages[vptr_page(dvp)]
                do  = vptr_offset(dvp)
                struct.pack_into('>H', db, do,   d.blk_no)
                struct.pack_into('>H', db, do+2, d.stmt_type)
                db[do+4] = d.num_labls
                db[do+5] = d.num_lhs

        # ---- 10. Symbol extent cell ----
        sym_ext_vptr = VPTR_NULL
        if self._symbols:
            base_pg  = vptr_page(fsn_vptr)
            base_off = vptr_offset(fsn_vptr)
            # Group symbol nodes by page
            pages_used = []
            i = 0
            while i < len(self._symbols):
                pg_first = i
                while (i + 1 < len(self._symbols) and
                       vptr_page(snode_vptrs[i+1]) == vptr_page(snode_vptrs[i])):
                    i += 1
                pg_last = i
                fst_off = vptr_offset(snode_vptrs[pg_first])
                lst_off = vptr_offset(snode_vptrs[pg_last])
                pages_used.append((pg_first, pg_last, fst_off, lst_off))
                i += 1

            ext_sz = 8 + len(pages_used) * 20
            sym_ext_vptr = alloc(ext_sz)
            b  = pages[vptr_page(sym_ext_vptr)]
            eo = vptr_offset(sym_ext_vptr)
            struct.pack_into('>I', b, eo, 0)                    # succ_ptr
            struct.pack_into('>H', b, eo+4, len(pages_used))   # next_ntry
            struct.pack_into('>H', b, eo+6, base_pg)           # fst_page
            for pg_i, (pf, pl, fo, lo) in enumerate(pages_used):
                ev = eo + 8 + pg_i * 20
                struct.pack_into('>H', b, ev,   fo)
                struct.pack_into('>H', b, ev+2, lo)
                fn = (self._symbols[pf]['desc'].symb_name.encode() + b' '*8)[:8]
                ln = (self._symbols[pl]['desc'].symb_name.encode() + b' '*8)[:8]
                b[ev+4:ev+12]  = fn
                b[ev+12:ev+20] = ln

            # Set ext_ptr in every BLKTCELL
            for blk in self._blocks:
                bvp = blk['btcell_vptr']
                wpvp(bvp, 16, sym_ext_vptr)

        # ---- 11. Statement extent cell ----
        stmt_ext_vptr = VPTR_NULL
        if self._stmts and has_srns:
            pages_used = []
            i = 0
            while i < len(self._stmts):
                pg_first = i
                while (i + 1 < len(self._stmts) and
                       vptr_page(stnode_vptrs[i+1]) ==
                       vptr_page(stnode_vptrs[i])):
                    i += 1
                pg_last = i
                fst_off = vptr_offset(stnode_vptrs[pg_first])
                lst_off = vptr_offset(stnode_vptrs[pg_last])
                pages_used.append((pg_first, pg_last, fst_off, lst_off))
                i += 1

            ext_sz = 8 + len(pages_used) * 20
            stmt_ext_vptr = alloc(ext_sz)
            b  = pages[vptr_page(stmt_ext_vptr)]
            eo = vptr_offset(stmt_ext_vptr)
            struct.pack_into('>I', b, eo, 0)
            struct.pack_into('>H', b, eo+4, len(pages_used))
            struct.pack_into('>H', b, eo+6, vptr_page(fstn_vptr))
            for pg_i, (pf, pl, fo, lo) in enumerate(pages_used):
                ev = eo + 8 + pg_i * 20
                struct.pack_into('>H', b, ev,   fo)
                struct.pack_into('>H', b, ev+2, lo)
                fs = (bytes(self._stmts[pf]['desc'].srn) + b' '*8)[:8]
                ls = (bytes(self._stmts[pl]['desc'].srn) + b' '*8)[:8]
                b[ev+4:ev+12]  = fs
                b[ev+12:ev+20] = ls

        # ---- 12. Initialisation data ----
        init_vptr = VPTR_NULL
        if self._init_data:
            init_vptr = alloc(len(self._init_data))
            b = pages[vptr_page(init_vptr)]
            o = vptr_offset(init_vptr)
            b[o:o+len(self._init_data)] = self._init_data

        # ---- 13. Write PAGEZERO + DROOTCEL into page 0 ----
        import time as _time
        p0 = pages[0]
        # PAGEZERO (12 bytes)
        struct.pack_into('>H', p0, 0, self._version)  # version
        struct.pack_into('>I', p0, 4, 0)              # dir_fc_ptr
        struct.pack_into('>I', p0, 8, vptr_make(0, 12))  # droot_ptr
        struct.pack_into('>I', p0, 12-4, 0)           # dat_fc_ptr (at offset 8)
        # Correct layout per sdf_pagezero_disk_t:
        struct.pack_into('>HHI', p0, 0, self._version, 0, 0)  # ver,pad,dir_fc
        struct.pack_into('>I',  p0, 8,  vptr_make(0, 12))      # droot_ptr
        struct.pack_into('>I',  p0, 12-4+4, 0)                 # dat_fc_ptr
        # Simpler direct write:
        struct.pack_into('>HHIII', p0, 0,
            self._version, 0, 0, vptr_make(0, 12), 0)

        # DROOTCEL at offset 12
        dr = 12
        fstmt = 1 if self._stmts else 0
        lstm  = len(self._stmts)
        p0[dr]   = (self._flags >> 8) & 0xFF
        p0[dr+1] =  self._flags       & 0xFF
        struct.pack_into('>H', p0, dr+2,  len(pages) - 1)   # last_page
        struct.pack_into('>I', p0, dr+4,  int(_time.time())) # sdf_date
        struct.pack_into('>H', p0, dr+16, len(self._blocks))
        struct.pack_into('>H', p0, dr+18, len(self._symbols))
        struct.pack_into('>I', p0, dr+20, fbn_vptr)
        struct.pack_into('>I', p0, dr+24, lbn_vptr)
        struct.pack_into('>I', p0, dr+36, fsn_vptr)
        struct.pack_into('>I', p0, dr+40, lsn_vptr)
        struct.pack_into('>I', p0, dr+48, btree_root)
        struct.pack_into('>H', p0, dr+52, fstmt)
        struct.pack_into('>H', p0, dr+54, lstm)
        struct.pack_into('>H', p0, dr+56, exec_count)
        struct.pack_into('>H', p0, dr+58, node_sz)
        if self._stmts:
            struct.pack_into('>I', p0, dr+60, fstn_vptr)
            struct.pack_into('>I', p0, dr+64, lstn_vptr)
        struct.pack_into('>I', p0, dr+68, stmt_ext_vptr)
        if has_srns and self._stmts:
            srn0 = (bytes(self._stmts[0]['desc'].srn)  + b' '*6)[:6]
            srnN = (bytes(self._stmts[-1]['desc'].srn) + b' '*6)[:6]
            p0[dr+72:dr+78] = srn0
            p0[dr+78:dr+84] = srnN
        struct.pack_into('>I', p0, dr+168, init_vptr)

        # ---- 14. Write flat file ----
        num_pages = len(pages)
        self._write_flat(pages, num_pages)

    def _write_flat(self, pages: list, num_pages: int) -> None:
        """Write (or append to) the flat file."""
        import time as _time

        if self._append:
            # Read existing file, insert new index entry, rewrite
            try:
                with open(self._path, 'rb') as f:
                    hdr = f.read(8)
                    if hdr[:4] != FLAT_MAGIC:
                        raise SdfError(-4030, 'not a valid SDF flat file')
                    n = struct.unpack_from('>I', hdr, 4)[0]
                    old_idx = f.read(n * 20)
                    old_data = f.read()
            except OSError as e:
                raise SdfError(-4030, str(e)) from e

            # Update pg0_offsets in existing index entries (shift by 20)
            updated_idx = bytearray(old_idx)
            for i in range(n):
                eo  = i * 20
                off = struct.unpack_from('>Q', updated_idx, eo + 12)[0]
                struct.pack_into('>Q', updated_idx, eo + 12, off + 20)

            # New member's pages start at end of updated file
            new_pg0_off = 8 + (n + 1) * 20 + len(old_data)
            new_entry   = self._make_index_entry(new_pg0_off, num_pages)

            with open(self._path, 'wb') as f:
                new_hdr = FLAT_MAGIC + struct.pack('>I', n + 1)
                f.write(new_hdr)
                f.write(bytes(updated_idx))
                f.write(new_entry)
                f.write(old_data)
                for pg in pages:
                    f.write(bytes(pg))
        else:
            # Create new file
            pg0_off   = 8 + 20   # header + one index entry
            new_entry = self._make_index_entry(pg0_off, num_pages)
            try:
                with open(self._path, 'wb') as f:
                    f.write(FLAT_MAGIC + struct.pack('>I', 1))
                    f.write(new_entry)
                    for pg in pages:
                        f.write(bytes(pg))
            except OSError as e:
                raise SdfError(-4030, str(e)) from e

    def _make_index_entry(self, pg0_off: int, num_pages: int) -> bytes:
        name_field = (self._member.encode() + b' ' * 8)[:8]
        return (name_field +
                struct.pack('>I', num_pages) +
                struct.pack('>Q', pg0_off))

    def cancel(self) -> None:
        """Discard the write context without writing anything."""
        self._committed = True   # prevent commit on __exit__


def _main():
    import sys
    args = sys.argv[1:]

    # No arguments or explicit help request with no command
    if not args or args[0] in ('--help', '-h', 'help') and len(args) == 1:
        print(_USAGE_SUMMARY)
        return

    cmd = args[0]

    # 'help <command>' or '<command> --help' or '<command> -h'
    if cmd == 'help':
        if len(args) < 2:
            print(_USAGE_SUMMARY)
        elif args[1] in _HELP:
            print(_HELP[args[1]])
        else:
            print(f"No help available for '{args[1]}'.")
            print('Known commands: ' + ', '.join(_HELP))
            sys.exit(1)
        return
    if len(args) >= 2 and args[1] in ('--help', '-h'):
        if cmd in _HELP:
            print(_HELP[cmd])
        else:
            print(f"Unknown command '{cmd}'.")
            sys.exit(1)
        return

    if cmd == 'flat_info':
        if not args[1:]:
            print(_HELP['flat_info']); sys.exit(1)
        for path in args[1:]:
            members = flat_info(path)
            print(f'sdfpkg flat file: {path}  ({len(members)} member(s))')
            print(f'  {"NAME":<8}  {"PAGES":>6}  {"OFFSET":>12}  BYTES')
            for m in members:
                print(f'  {m["name"]:<8}  {m["page_count"]:>6}  '
                      f'{m["offset"]:>12}  {m["page_count"]*PAGE_SIZE}')

    elif cmd == 'pds_info':
        if not args[1:]:
            print(_HELP['pds_info']); sys.exit(1)
        for path in args[1:]:
            members = pds_info(path)
            print(f'PDS file: {path}  ({len(members)} member(s))')
            print(f'  {"NAME":<8}  {"PAGES":>6}  {"PDS_OFFSET":>12}  BYTES')
            for m in members:
                print(f'  {m["name"]:<8}  {m["page_count"]:>6}  '
                      f'{m["pds_offset"]:>12}  {m["page_count"]*PAGE_SIZE}')

    elif cmd == 'pds2flat':
        if len(args) < 3:
            print(_HELP['pds2flat']); sys.exit(1)
        n = pds2flat(args[1], args[2], args[3:] or None)
        print(f'pds2flat: wrote {n} member(s) to {args[2]}')

    elif cmd == 'flat2pds':
        if len(args) < 3:
            print(_HELP['flat2pds']); sys.exit(1)
        n = flat2pds(args[1], args[2], args[3:] or None)
        print(f'flat2pds: wrote {n} member(s) to {args[2]}')

    elif cmd == 'sdfcheck':
        if len(args) < 2:
            print(_HELP['sdfcheck']); sys.exit(1)
        results = sdfcheck(args[1], args[2:] or None)
        any_bad = False
        for name, good in results.items():
            status = 'GOOD          ' if good else 'BAD BAD BAD !!'
            print(f'SDF {name:<8}  IS  {status}')
            if not good:
                any_bad = True
        sys.exit(1 if any_bad else 0)

    else:
        print(f"Unknown command '{cmd}'.")
        print("Run 'sdfpkg.py --help' for usage.")
        sys.exit(1)


if __name__ == '__main__':
    _main()
