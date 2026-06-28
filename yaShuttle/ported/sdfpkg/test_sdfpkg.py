#!/usr/bin/env python3
"""
test_sdfpkg.py  --  Unit tests for sdfpkg.py (Python port of SDFPKG).

Mirrors test_sdfpkg.c: 29 tests, self-contained synthetic SDF file.

Usage:  ./test_sdfpkg.py [--help]

Options:
  --help, -h    Print this help message and exit.

Each test builds a temporary synthetic SDF flat file, exercises the
relevant sdfpkg.py API entry point, reports PASS or FAIL, then removes
the file on exit.  The programme exits with status 0 if all tests pass
and status 1 if any fail.

Tests covered:
  T01  sdf_open / sdf_close lifecycle
  T02  sdf_select: known member
  T03  sdf_select: unknown member raises SdfError
  T04  sdf_select: same member twice (idempotent)
  T05  sdf_locate_root: reads DROOTCEL fields correctly
  T06  sdf_find_block_by_number: all fields populated
  T07  sdf_find_block_by_name: tree search
  T08  sdf_find_block_by_name: not found raises SdfError
  T09  sdf_find_symbol_by_number: fields correct
  T10  sdf_find_symbol_by_name: binary search hit
  T11  sdf_find_symbol_by_name: not found raises SdfError
  T12  sdf_find_stmt_by_number: executable statement
  T13  sdf_find_stmt_by_number: non-executable raises SdfError
  T14  sdf_find_block_node_by_number: CSECT name returned
  T15  sdf_find_symbol_node_by_number: name + SDC pointer returned
  T16  sdf_find_stmt_node_by_number: SRN returned
  T17  sdf_locate: bad virtual pointer raises SdfError
  T18  augment / rescind
  T19  stats: read/write counters
  T20  SdfError messages non-empty for all codes
  T21  NDX2PTR: block index 0 raises SdfError
  T22  NDX2PTR: block index > num_blks raises SdfError
  T23  Locate counter wrap: forces loc_cnt overflow path
  T24  sdf_find_stmt_by_srn: hit
  T25  sdf_find_stmt_by_srn: SDF_NO_SRNS when no SRNs
  T26  flat_info: correct member count and page count
  T27  flat->pds->flat round trip: page data preserved exactly
  T28  sdfcheck: GOOD result for a valid member
  T29  Context manager (with statement): auto-close on exit
"""

import os
import struct
import tempfile
import sys

from sdfpkg import (
    SdfContext, SdfError,
    RC_OK, RC_NOT_FOUND, RC_SYM_NOT_FOUND, RC_NOT_EXEC,
    RC_NO_SRNS, RC_STMT_OOB,
    ERR_BAD_BLOCK, ERR_BAD_PTR, ERR_NO_SELECT, ERR_BLK_NOSPEC,
    DISP_NONE,
    PAGE_SIZE, NAME_LEN, FLAG_HAS_SRNS,
    vptr_make, pds2flat, flat2pds, flat_info, pds_info, sdfcheck,
    _name_to_ebcdic, _write_pds_directory,
)

# =====================================================================
# Minimal test framework
# =====================================================================

_pass = _fail = 0

def CHECK(name, cond):
    global _pass, _fail
    if cond:
        print(f'  PASS  {name}')
        _pass += 1
    else:
        print(f'  FAIL  {name}')
        _fail += 1

def CHECK_RAISES(name, exc_code, fn):
    global _pass, _fail
    try:
        fn()
        print(f'  FAIL  {name}: no exception raised')
        _fail += 1
    except SdfError as e:
        if e.code == exc_code:
            print(f'  PASS  {name}')
            _pass += 1
        else:
            print(f'  FAIL  {name}: got code {e.code}, want {exc_code}')
            _fail += 1

# =====================================================================
# Synthetic SDF file builder
# (matches the C test's build_sdf_file() exactly)
# =====================================================================

def w8(p, o, v):   p[o] = v & 0xFF
def w16(p, o, v):  struct.pack_into('>H', p, o, v & 0xFFFF)
def w32(p, o, v):  struct.pack_into('>I', p, o, v & 0xFFFFFFFF)
def wstr(p, o, s, n):
    b = s.encode('ascii')[:n].ljust(n, b' ')
    p[o:o+n] = b

def vp(page, off): return vptr_make(page, off)

def build_sdf_file(path):
    """Build a 3-page synthetic SDF flat file at `path`."""
    pages = [bytearray(PAGE_SIZE) for _ in range(3)]
    p0, p1, p2 = pages

    # ---- Page 0: PAGEZERO ----------------------------------------
    w16(p0, 0, 1)               # version=1
    w32(p0, 8, vp(0, 16))       # droot_ptr

    # ---- Page 0: DROOTCEL at offset 16 ---------------------------
    dr = p0
    o  = 16
    w8 (dr, o+0, 0x80)          # sdf_flags[0] = HAS_SRNS
    w8 (dr, o+1, 0)
    w16(dr, o+2, 2)             # last_page=2
    w16(dr, o+16, 1)            # blk_nodes=1
    w16(dr, o+18, 2)            # sym_nodes=2
    w32(dr, o+20, vp(1, 0))     # fbn_ptr
    w32(dr, o+24, vp(1, 0))     # lbn_ptr
    w32(dr, o+36, vp(2, 0))     # fsn_ptr
    w32(dr, o+40, vp(2, 12))    # lsn_ptr
    w32(dr, o+48, vp(1, 12))    # btree_ptr
    w16(dr, o+52, 1)            # fstmt_num=1
    w16(dr, o+54, 3)            # lstm_num=3
    w32(dr, o+60, vp(2, 100))   # fstn_ptr
    w32(dr, o+64, vp(2, 124))   # lstn_ptr
    w32(dr, o+68, vp(2, 200))   # snel_ptr
    wstr(dr, o+72, 'S0001 ', 8) # first_srn (padded to 8)
    wstr(dr, o+80, 'S0003 ', 8) # last_srn
    # dinit_ptr at offset 168
    w32(dr, o+168, 0)

    # ---- Page 1: BLCKNODE[1] at offset 0 -------------------------
    wstr(p1, 0, 'CSECT1  ', 8)
    w32 (p1, 8, vp(1, 12))

    # ---- Page 1: BLKTCELL[1] at offset 12 -----------------------
    bt = p1
    w32(bt, 12+0,  0)           # rtree_ptr
    w32(bt, 12+4,  0)           # ltree_ptr
    w32(bt, 12+16, 0)           # ext_ptr
    w16(bt, 12+26, 1)           # blk_ndx
    w16(bt, 12+28, 1)           # blk_id
    w8 (bt, 12+30, 1)           # blk_class
    w8 (bt, 12+31, 0)           # blk_type
    w16(bt, 12+32, 1)           # fsymb_num
    w16(bt, 12+34, 2)           # lsymb_num
    w16(bt, 12+36, 1)           # fstmt_num
    w16(bt, 12+38, 3)           # lstm_num
    w8 (bt, 12+44, 8)           # bname_len
    wstr(bt, 12+45, 'MAINPROG', 8)

    # ---- Page 2: SYMBNODE[1] at offset 0 -------------------------
    wstr(p2, 0,  'ALPHA   ', 8)
    w32 (p2, 8,  vp(2, 24))

    # ---- Page 2: SYMBNODE[2] at offset 12 -----------------------
    wstr(p2, 12, 'BETA    ', 8)
    w32 (p2, 20, vp(2, 48))

    # ---- Page 2: SYMBDC[1] at offset 24 -------------------------
    w16(p2, 24+0,  1)           # block_num=1
    w8 (p2, 24+6,  1)           # sym_class=1
    w8 (p2, 24+7,  1)           # sym_type=1
    w8 (p2, 24+12, 5)           # symb_len=5 ("ALPHA")

    # ---- Page 2: SYMBDC[2] at offset 48 -------------------------
    w16(p2, 48+0,  1)           # block_num=1
    w8 (p2, 48+6,  1)
    w8 (p2, 48+7,  1)
    w8 (p2, 48+12, 4)           # symb_len=4 ("BETA")

    # ---- Page 2: STMTNOD1 entries (12 bytes: srn[6]+incount[2]+ptr[4])
    # Stmt 1 @ 100
    wstr(p2, 100, 'S0001 ', 6)
    w8  (p2, 106, 0); w8(p2, 107, 0)   # incount=0
    w32 (p2, 108, vp(2, 150))          # stdc_ptr (exec)
    # Stmt 2 @ 112
    wstr(p2, 112, 'S0002 ', 6)
    w8  (p2, 118, 0); w8(p2, 119, 0)
    w32 (p2, 120, vp(2, 156))
    # Stmt 3 @ 124  (non-executable: stdc_ptr=0)
    wstr(p2, 124, 'S0003 ', 6)
    w8  (p2, 130, 0); w8(p2, 131, 0)
    w32 (p2, 132, 0)

    # ---- Page 2: STMTDC[1] at offset 150 ------------------------
    w16(p2, 150, 1)             # block_num=1
    w16(p2, 152, 1)             # stmt_type=1
    w8 (p2, 154, 0)             # num_labls
    w8 (p2, 155, 1)             # num_lhs

    # ---- Page 2: STMTDC[2] at offset 156 ------------------------
    w16(p2, 156, 1)
    w16(p2, 158, 2)             # stmt_type=2
    w8 (p2, 160, 1)
    w8 (p2, 161, 0)

    # ---- Page 2: STMTEXTF at offset 200 -------------------------
    # Layout: succ_ptr1(4) + nx_ntry(2) + fst_page1(2)
    w32(p2, 200, 0)             # succ_ptr1=NULL
    w16(p2, 204, 1)             # nx_ntry=1
    w16(p2, 206, 2)             # fst_page1=2

    # ---- Page 2: STMTEXTV at offset 208 -------------------------
    # Layout: fst_off1(2) + lst_off1(2) + fst_srn(8) + lst_srn(8)
    w16(p2, 208, 100)           # fst_off1
    w16(p2, 210, 124)           # lst_off1
    wstr(p2, 212, 'S0001   ', 8)  # fst_srn (CL8, space-padded)
    wstr(p2, 220, 'S0003   ', 8)  # lst_srn

    # Write flat file: magic(4) + count(4) + 1 index entry(20) + 3 pages
    with open(path, 'wb') as f:
        f.write(b'SDF\x00')
        f.write(struct.pack('>I', 1))           # 1 member
        # Index entry: name(8) + pages(4) + offset(8)
        pg0_offset = 8 + 20                     # header + 1 index entry
        f.write(b'TESTMEMB')
        f.write(struct.pack('>I', 3))           # 3 pages
        f.write(struct.pack('>Q', pg0_offset))
        for page in pages:
            f.write(bytes(page))


# =====================================================================
# Tests
# =====================================================================

_path = None

def open_selected():
    ctx = SdfContext.open(_path)
    ctx.select('TESTMEMB')
    return ctx

def t01_open_close():
    print('T01: open / close')
    ctx = SdfContext.open(_path)
    CHECK('ctx is SdfContext', isinstance(ctx, SdfContext))
    ctx.close()
    ctx.close()  # double close is safe

def t02_select_known():
    print('T02: select known member')
    with SdfContext.open(_path) as ctx:
        ctx.select('TESTMEMB')
        CHECK('no exception', True)

def t03_select_unknown():
    print('T03: select unknown member')
    with SdfContext.open(_path) as ctx:
        try:
            ctx.select('NOSUCHXX')
            CHECK('should have raised', False)
        except SdfError as e:
            CHECK('not found', e.code in (RC_NOT_FOUND, ERR_NO_SELECT) or e.code < 0)

def t04_select_idempotent():
    print('T04: select same member twice')
    with SdfContext.open(_path) as ctx:
        ctx.select('TESTMEMB')
        ctx.select('TESTMEMB')  # should not raise
        CHECK('idempotent', True)

def t05_locate_root():
    print('T05: locate root')
    with open_selected() as ctx:
        root = ctx.locate_root()
        CHECK('root is memoryview', isinstance(root, memoryview))
        # blk_nodes at offset 16 in drootcel
        bn = struct.unpack_from('>H', root, 16)[0]
        sn = struct.unpack_from('>H', root, 18)[0]
        CHECK('blk_nodes=1', bn == 1)
        CHECK('sym_nodes=2', sn == 2)

def t06_find_block_by_number():
    print('T06: find block by number')
    with open_selected() as ctx:
        blk = ctx.find_block_by_number(1)
        CHECK('blk_no=1',     blk.blk_no == 1)
        CHECK('blk_id=1',     blk.blk_id == 1)
        CHECK('csect=CSECT1', blk.csect_name.startswith('CSECT1'))
        CHECK('name=MAINPROG',blk.blk_name == 'MAINPROG')
        CHECK('fsymb=1',      blk.fsymb_no == 1)
        CHECK('lsymb=2',      blk.lsymb_no == 2)
        CHECK('fstmt=1',      blk.fstmt_no == 1)
        CHECK('lstm=3',       blk.lstm_no  == 3)

def t07_find_block_by_name():
    print('T07: find block by name')
    with open_selected() as ctx:
        blk = ctx.find_block_by_name('MAINPROG')
        CHECK('blk_no=1',     blk.blk_no == 1)
        CHECK('name=MAINPROG',blk.blk_name == 'MAINPROG')

def t08_find_block_not_found():
    print('T08: find block by name - not found')
    with open_selected() as ctx:
        CHECK_RAISES('NOBLOCK raises', RC_NOT_FOUND,
                     lambda: ctx.find_block_by_name('NOBLOCK'))

def t09_find_symbol_by_number():
    print('T09: find symbol by number')
    with open_selected() as ctx:
        s = ctx.find_symbol_by_number(1)
        CHECK('symb_no=1',  s.symb_no == 1)
        CHECK('blk_no=1',   s.blk_no  == 1)
        CHECK('name=ALPHA', s.symb_name.startswith('ALPHA'))
        CHECK('class=1',    s.sym_class == 1)
        s2 = ctx.find_symbol_by_number(2)
        CHECK('name=BETA',  s2.symb_name.startswith('BETA'))

def t10_find_symbol_by_name():
    print('T10: find symbol by name')
    with open_selected() as ctx:
        ctx.find_block_by_number(1)  # establish block context
        s = ctx.find_symbol_by_name('ALPHA')
        CHECK('symb_no=1', s.symb_no == 1)
        CHECK('name=ALPHA',s.symb_name.startswith('ALPHA'))
        s2 = ctx.find_symbol_by_name('BETA')
        CHECK('symb_no=2', s2.symb_no == 2)

def t11_find_symbol_not_found():
    print('T11: find symbol - not found')
    with open_selected() as ctx:
        ctx.find_block_by_number(1)
        CHECK_RAISES('ZZZZ raises', RC_SYM_NOT_FOUND,
                     lambda: ctx.find_symbol_by_name('ZZZZ'))

def t12_find_stmt_exec():
    print('T12: find executable statement')
    with open_selected() as ctx:
        s = ctx.find_stmt_by_number(1)
        CHECK('stmt_no=1',   s.stmt_no == 1)
        CHECK('blk_no=1',    s.blk_no  == 1)
        CHECK('is_exec',     s.is_executable)
        CHECK('type=1',      s.stmt_type == 1)
        s2 = ctx.find_stmt_by_number(2)
        CHECK('type=2',      s2.stmt_type == 2)

def t13_find_stmt_non_exec():
    print('T13: find non-executable statement')
    with open_selected() as ctx:
        CHECK_RAISES('stmt 3 non-exec', RC_NOT_EXEC,
                     lambda: ctx.find_stmt_by_number(3))

def t14_find_block_node():
    print('T14: find block node by number')
    with open_selected() as ctx:
        csect = ctx.find_block_node_by_number(1)
        CHECK('csect=CSECT1', csect.startswith('CSECT1'))

def t15_find_symbol_node():
    print('T15: find symbol node by number')
    with open_selected() as ctx:
        name, sdc_ptr = ctx.find_symbol_node_by_number(1)
        CHECK('name prefix ALPHA', name.startswith('ALPHA'))
        CHECK('sdc_ptr non-zero',  sdc_ptr != 0)

def t16_find_stmt_node():
    print('T16: find stmt node (SRN)')
    with open_selected() as ctx:
        r = ctx.find_stmt_node_by_number(1)
        CHECK('srn starts S0001', r.srn[:5] == b'S0001')

def t17_bad_pointer():
    print('T17: bad virtual pointer')
    with open_selected() as ctx:
        CHECK_RAISES('page 999 bad', ERR_BAD_PTR,
                     lambda: ctx.locate(vptr_make(999, 0)))

def t18_augment_rescind():
    print('T18: augment / rescind')
    with open_selected() as ctx:
        ctx.augment(5)
        ctx.rescind()
        CHECK('no exception', True)

def t19_stats():
    print('T19: statistics')
    with open_selected() as ctx:
        ctx.find_block_by_number(1)
        ctx.find_symbol_by_number(1)
        reads, writes, selects = ctx.stats()
        CHECK('reads > 0',   reads   > 0)
        CHECK('selects > 0', selects > 0)

def t20_strerror():
    print('T20: SdfError messages non-empty')
    from sdfpkg import _strerror
    codes = [RC_OK, RC_NOT_FOUND, RC_SYM_NOT_FOUND, RC_NOT_EXEC,
             RC_NO_SRNS, -4001, -4002, -4005, -4006, -4009, -4010]
    CHECK('all non-empty', all(_strerror(c) for c in codes))

def t21_bad_block_zero():
    print('T21: block index 0 rejected')
    with open_selected() as ctx:
        CHECK_RAISES('index 0', ERR_BAD_BLOCK,
                     lambda: ctx.find_block_by_number(0))

def t22_bad_block_overflow():
    print('T22: block index > num_blks rejected')
    with open_selected() as ctx:
        CHECK_RAISES('index 999', ERR_BAD_BLOCK,
                     lambda: ctx.find_block_by_number(999))

def t23_locate_counter_wrap():
    print('T23: locate counter overflow reset')
    with open_selected() as ctx:
        ctx._loc_cnt = 0x7FFFFFFF
        ctx.locate(vptr_make(0, 0))
        CHECK('loc_cnt reset to 1', ctx._loc_cnt == 1)

def t24_find_stmt_by_srn():
    print('T24: find statement by SRN')
    with open_selected() as ctx:
        r = ctx.find_stmt_by_srn(b'S0001 ')
        CHECK('is_executable', r.is_executable)
        CHECK('blk_no=1',      r.blk_no == 1)

def t25_no_srns():
    print('T25: find_stmt_by_srn with no SRNs')
    with open_selected() as ctx:
        ctx._cur_fcb.flags     &= ~FLAG_HAS_SRNS
        ctx._cur_fcb.stmt_expt  = 0
        CHECK_RAISES('no-SRN raises', RC_NO_SRNS,
                     lambda: ctx.find_stmt_by_srn(b'S0001 '))

# =====================================================================
# Converter round-trip tests
# =====================================================================

def t26_flat_info():
    print('T26: flat_info')
    members = flat_info(_path)
    CHECK('1 member',           len(members) == 1)
    CHECK('name=TESTMEMB',      members[0]['name'] == 'TESTMEMB')
    CHECK('page_count=3',       members[0]['page_count'] == 3)

def t27_pds_round_trip():
    print('T27: flat->pds->flat round trip')
    with tempfile.TemporaryDirectory() as tmp:
        pds_path  = os.path.join(tmp, 'test.pds')
        flat2_path= os.path.join(tmp, 'test2.sdf')

        n1 = flat2pds(_path, pds_path)
        CHECK('flat2pds wrote 1', n1 == 1)

        n2 = pds2flat(pds_path, flat2_path)
        CHECK('pds2flat wrote 1', n2 == 1)

        # Verify page data matches
        m1 = flat_info(_path)
        m2 = flat_info(flat2_path)
        CHECK('same member count', len(m1) == len(m2))

        with open(_path, 'rb') as f:
            f.seek(m1[0]['offset'])
            orig_pages = f.read(m1[0]['page_count'] * PAGE_SIZE)
        with open(flat2_path, 'rb') as f:
            f.seek(m2[0]['offset'])
            rt_pages = f.read(m2[0]['page_count'] * PAGE_SIZE)
        CHECK('page data matches', orig_pages == rt_pages)

def t28_sdfcheck():
    print('T28: sdfcheck')
    results = sdfcheck(_path)
    CHECK('TESTMEMB is good', results.get('TESTMEMB') is True)

def t29_context_manager():
    print('T29: context manager (with statement)')
    with SdfContext.open(_path) as ctx:
        ctx.select('TESTMEMB')
        blk = ctx.find_block_by_number(1)
    CHECK('blk returned', blk.blk_no == 1)
    CHECK('ctx closed',   not ctx._go_flag)


def t30_copy_write_roundtrip():
    """T30: write a STRUCTURE with COPY link; read back copy_blk_no."""
    print('T30: STRUCTURE COPY -- write and read back copy_blk_no')
    from sdfpkg import (
        SdfWriter, WBlock, WSymbol, WStmt,
        BCLASS_PROGRAM, BCLASS_PROCEDURE,
        SCLASS_VARIABLE, SCLASS_TEMPLATE,
        STYPE_SCALAR, STYPE_INTEGER, STYPE_STRUCTURE,
        STTYPE_ASSIGN, WFLAG_HAS_SRNS,
    )
    import tempfile, os
    fd2, path2 = tempfile.mkstemp(suffix='.sdf')
    os.close(fd2)
    try:
        # Write
        w = SdfWriter.create(path2, 'COPYMEM', flags=WFLAG_HAS_SRNS)
        b_prog = w.add_block(WBlock(csect_name='COPYCS', blk_name='COPYMAIN',
                                    blk_class=BCLASS_PROGRAM, blk_id=1))
        b_base = w.add_block(WBlock(csect_name='COPYCS', blk_name='BASE_S',
                                    blk_class=BCLASS_PROCEDURE, blk_id=2))
        b_ext  = w.add_block(WBlock(csect_name='COPYCS', blk_name='EXT_S',
                                    blk_class=BCLASS_PROCEDURE, blk_id=3))

        # BASE_S template header (no COPY)
        w.add_symbol(WSymbol(blk_no=b_base, symb_name='BASE_S',
                             sym_class=SCLASS_TEMPLATE, sym_type=STYPE_STRUCTURE))
        w.add_symbol(WSymbol(blk_no=b_base, symb_name='BASE_FIELD',
                             sym_class=SCLASS_VARIABLE, sym_type=STYPE_SCALAR))

        # EXT_S template header with COPY link to BASE_S
        w.add_symbol(WSymbol(blk_no=b_ext, symb_name='EXT_S',
                             sym_class=SCLASS_TEMPLATE, sym_type=STYPE_STRUCTURE,
                             copy_blk_no=b_base))
        w.add_symbol(WSymbol(blk_no=b_ext, symb_name='EXTRA_FIELD',
                             sym_class=SCLASS_VARIABLE, sym_type=STYPE_INTEGER))

        # Instance in PROGRAM block
        w.add_symbol(WSymbol(blk_no=b_prog, symb_name='MY_EXT',
                             sym_class=SCLASS_VARIABLE, sym_type=STYPE_STRUCTURE))

        w.add_stmt(WStmt(blk_no=b_prog, srn=b'C0001 ',
                         stmt_type=STTYPE_ASSIGN, is_exec=True, num_lhs=1))
        w.commit()

        # Read back
        ctx = SdfContext.open(path2)
        ctx.select('COPYMEM')

        base_blk  = ctx.find_block_by_name('BASE_S')
        ext_blk   = ctx.find_block_by_name('EXT_S')
        base_blk_no = base_blk.blk_no
        ext_blk_no  = ext_blk.blk_no

        # Find template headers
        total = max(base_blk.lsymb_no, ext_blk.lsymb_no)
        base_copy = None
        ext_copy  = None
        for sn in range(1, total + 1):
            try:
                sr = ctx.find_symbol_by_number(sn)
            except SdfError:
                continue
            if sr.blk_no == base_blk_no and sr.sym_class == SCLASS_TEMPLATE:
                base_copy = sr.copy_blk_no
            if sr.blk_no == ext_blk_no and sr.sym_class == SCLASS_TEMPLATE:
                ext_copy = sr.copy_blk_no

        CHECK('T30: EXT_S copy_blk_no == base_blk_no', ext_copy == base_blk_no)
        CHECK('T30: EXT_S copy_blk_no != 0',           ext_copy != 0)
        CHECK('T30: BASE_S copy_blk_no == 0',          base_copy == 0)
        ctx.close()
    finally:
        os.unlink(path2)


def t31_copy_no_array_no_cont():
    """T31: symbol with only STRCDATA (no ARRADATA, short name) -- offset check."""
    print('T31: STRUCTURE COPY -- struct_of offset with short name, no array')
    from sdfpkg import (
        SdfWriter, WBlock, WSymbol,
        BCLASS_PROCEDURE, SCLASS_TEMPLATE, STYPE_STRUCTURE, WFLAG_HAS_SRNS,
    )
    import tempfile, os
    fd2, path2 = tempfile.mkstemp(suffix='.sdf')
    os.close(fd2)
    try:
        w = SdfWriter.create(path2, 'T31MEM', flags=0)
        b1 = w.add_block(WBlock(csect_name='T31CS', blk_name='BLK1',
                                blk_class=BCLASS_PROCEDURE, blk_id=1))
        b2 = w.add_block(WBlock(csect_name='T31CS', blk_name='BLK2',
                                blk_class=BCLASS_PROCEDURE, blk_id=2))
        # BLK2 template header COPYs BLK1; short name (≤ 8 chars), no array
        w.add_symbol(WSymbol(blk_no=b1, symb_name='BLK1',
                             sym_class=SCLASS_TEMPLATE, sym_type=STYPE_STRUCTURE))
        w.add_symbol(WSymbol(blk_no=b2, symb_name='BLK2',
                             sym_class=SCLASS_TEMPLATE, sym_type=STYPE_STRUCTURE,
                             copy_blk_no=b1))
        w.commit()

        ctx = SdfContext.open(path2)
        ctx.select('T31MEM')
        blk1 = ctx.find_block_by_name('BLK1')
        blk2 = ctx.find_block_by_name('BLK2')
        for sn in range(1, blk2.lsymb_no + 1):
            try:
                sr = ctx.find_symbol_by_number(sn)
            except SdfError:
                continue
            if sr.blk_no == blk2.blk_no and sr.sym_class == SCLASS_TEMPLATE:
                CHECK('T31: BLK2 copy_blk_no == blk1.blk_no',
                      sr.copy_blk_no == blk1.blk_no)
            if sr.blk_no == blk1.blk_no and sr.sym_class == SCLASS_TEMPLATE:
                CHECK('T31: BLK1 copy_blk_no == 0', sr.copy_blk_no == 0)
        ctx.close()
    finally:
        os.unlink(path2)

def t32_event_roundtrip():
    """T32: write an EVENT symbol; read back type, rows=0, columns=0."""
    print('T32: EVENT datatype -- write and read back')
    from sdfpkg import (
        SdfWriter, WBlock, WSymbol,
        BCLASS_PROGRAM, SCLASS_VARIABLE, STYPE_EVENT, STYPE_SCALAR,
    )
    import tempfile, os
    fd2, path2 = tempfile.mkstemp(suffix='.sdf')
    os.close(fd2)
    try:
        w = SdfWriter.create(path2, 'EVTMEM', flags=0)
        b1 = w.add_block(WBlock(csect_name='EVTCS', blk_name='EVTPROG',
                                blk_class=BCLASS_PROGRAM, blk_id=1))
        # Add several types including EVENT to test sort position
        w.add_symbol(WSymbol(blk_no=b1, symb_name='ZCOUNT',
                             sym_class=SCLASS_VARIABLE, sym_type=STYPE_SCALAR))
        w.add_symbol(WSymbol(blk_no=b1, symb_name='ARMED',
                             sym_class=SCLASS_VARIABLE, sym_type=STYPE_SCALAR))
        w.add_symbol(WSymbol(blk_no=b1, symb_name='LAUNCH_ENABLE',
                             sym_class=SCLASS_VARIABLE, sym_type=STYPE_EVENT))
        w.add_symbol(WSymbol(blk_no=b1, symb_name='BEACON',
                             sym_class=SCLASS_VARIABLE, sym_type=STYPE_EVENT))
        w.commit()

        ctx = SdfContext.open(path2)
        ctx.select('EVTMEM')

        # After sort: ARMED(1), BEACON(2), LAUNCH_ENABLE(3), ZCOUNT(4)
        blk = ctx.find_block_by_number(1)
        CHECK('T32: blk has 4 symbols', blk.lsymb_no == 4)

        armed = ctx.find_symbol_by_number(1)
        CHECK('T32: symb 1 = ARMED',       armed.symb_name == 'ARMED')
        CHECK('T32: ARMED type=SCALAR',     armed.sym_type == STYPE_SCALAR)

        beacon = ctx.find_symbol_by_number(2)
        CHECK('T32: symb 2 = BEACON',       beacon.symb_name == 'BEACON')
        CHECK('T32: BEACON type=EVENT',     beacon.sym_type == STYPE_EVENT)
        CHECK('T32: BEACON rows=0',         beacon.rows == 0)
        CHECK('T32: BEACON columns=0',      beacon.columns == 0)
        CHECK('T32: BEACON array_dims=0',   beacon.array_dims[0] == 0)
        CHECK('T32: BEACON copy_blk_no=0',  beacon.copy_blk_no == 0)

        launch = ctx.find_symbol_by_number(3)
        CHECK('T32: symb 3 = LAUNCH_ENABLE', launch.symb_name == 'LAUNCH_ENABLE')
        CHECK('T32: LAUNCH_ENABLE type=EVENT', launch.sym_type == STYPE_EVENT)
        CHECK('T32: LAUNCH_ENABLE rows=0',     launch.rows == 0)
        CHECK('T32: LAUNCH_ENABLE columns=0',  launch.columns == 0)

        zcount = ctx.find_symbol_by_number(4)
        CHECK('T32: symb 4 = ZCOUNT',       zcount.symb_name == 'ZCOUNT')
        CHECK('T32: ZCOUNT type=SCALAR',     zcount.sym_type == STYPE_SCALAR)

        ctx.close()
    finally:
        os.unlink(path2)

def t33_name_roundtrip():
    """T33: write a NAME variable (sym_class=LABEL); read back class and referent type."""
    print('T33: NAME variable -- write and read back')
    from sdfpkg import (
        SdfWriter, WBlock, WSymbol,
        BCLASS_PROGRAM, SCLASS_VARIABLE, SCLASS_LABEL,
        STYPE_SCALAR, STYPE_VECTOR,
    )
    import tempfile, os
    fd2, path2 = tempfile.mkstemp(suffix='.sdf')
    os.close(fd2)
    try:
        w = SdfWriter.create(path2, 'NAMMEM', flags=0)
        b1 = w.add_block(WBlock(csect_name='NCS', blk_name='NAMPROG',
                                blk_class=BCLASS_PROGRAM, blk_id=1))
        # NAME to a SCALAR
        w.add_symbol(WSymbol(blk_no=b1, symb_name='ALT_PTR',
                             sym_class=SCLASS_LABEL, sym_type=STYPE_SCALAR))
        # NAME to a VECTOR
        w.add_symbol(WSymbol(blk_no=b1, symb_name='VEL_PTR',
                             sym_class=SCLASS_LABEL, sym_type=STYPE_VECTOR,
                             rows=3))
        # Ordinary variable to confirm class=1 still works alongside
        w.add_symbol(WSymbol(blk_no=b1, symb_name='ZVAR',
                             sym_class=SCLASS_VARIABLE, sym_type=STYPE_SCALAR))
        w.commit()

        ctx = SdfContext.open(path2)
        ctx.select('NAMMEM')
        # After sort: ALT_PTR(1), VEL_PTR(2), ZVAR(3)
        a = ctx.find_symbol_by_number(1)
        CHECK('T33: ALT_PTR name',         a.symb_name == 'ALT_PTR')
        CHECK('T33: ALT_PTR class=LABEL',  a.sym_class == SCLASS_LABEL)
        CHECK('T33: ALT_PTR type=SCALAR',  a.sym_type  == STYPE_SCALAR)
        CHECK('T33: ALT_PTR rows=0',       a.rows == 0)

        v = ctx.find_symbol_by_number(2)
        CHECK('T33: VEL_PTR name',         v.symb_name == 'VEL_PTR')
        CHECK('T33: VEL_PTR class=LABEL',  v.sym_class == SCLASS_LABEL)
        CHECK('T33: VEL_PTR type=VECTOR',  v.sym_type  == STYPE_VECTOR)
        CHECK('T33: VEL_PTR rows=3',       v.rows == 3)

        z = ctx.find_symbol_by_number(3)
        CHECK('T33: ZVAR class=VARIABLE',  z.sym_class == SCLASS_VARIABLE)
        ctx.close()
    finally:
        os.unlink(path2)


def t34_equate_ext_roundtrip():
    """T34: write an EQUATE_EXT symbol; read back class=2 and type=8."""
    print('T34: EQUATE_EXT -- write and read back')
    from sdfpkg import (
        SdfWriter, WBlock, WSymbol,
        BCLASS_PROGRAM, SCLASS_VARIABLE, SCLASS_EQUATE_EXT, STYPE_EQUATE_EXT,
        STYPE_SCALAR,
    )
    import tempfile, os
    fd2, path2 = tempfile.mkstemp(suffix='.sdf')
    os.close(fd2)
    try:
        w = SdfWriter.create(path2, 'EQMEM', flags=0)
        b1 = w.add_block(WBlock(csect_name='ECS', blk_name='EQPROG',
                                blk_class=BCLASS_PROGRAM, blk_id=1))
        w.add_symbol(WSymbol(blk_no=b1, symb_name='EXT_CONST',
                             sym_class=SCLASS_EQUATE_EXT, sym_type=STYPE_EQUATE_EXT))
        w.add_symbol(WSymbol(blk_no=b1, symb_name='LOCAL_VAR',
                             sym_class=SCLASS_VARIABLE, sym_type=STYPE_SCALAR))
        w.commit()

        ctx = SdfContext.open(path2)
        ctx.select('EQMEM')
        # After sort: EXT_CONST(1), LOCAL_VAR(2)
        e = ctx.find_symbol_by_number(1)
        CHECK('T34: EXT_CONST name',              e.symb_name == 'EXT_CONST')
        CHECK('T34: EXT_CONST class=EQUATE_EXT',  e.sym_class == SCLASS_EQUATE_EXT)
        CHECK('T34: EXT_CONST type=EQUATE_EXT',   e.sym_type  == STYPE_EQUATE_EXT)
        CHECK('T34: EXT_CONST rows=0',            e.rows == 0)
        CHECK('T34: EXT_CONST copy_blk_no=0',     e.copy_blk_no == 0)

        lv = ctx.find_symbol_by_number(2)
        CHECK('T34: LOCAL_VAR class=VARIABLE', lv.sym_class == SCLASS_VARIABLE)
        ctx.close()
    finally:
        os.unlink(path2)


def t35_task_block_roundtrip():
    """T35: write a TASK block with TASK entry-point symbol; read back blk_class and sym_type."""
    print('T35: TASK block -- write and read back')
    from sdfpkg import (
        SdfWriter, WBlock, WSymbol,
        BCLASS_PROGRAM, BCLASS_TASK, SCLASS_VARIABLE, STYPE_SCALAR, STYPE_TASK,
    )
    import tempfile, os
    fd2, path2 = tempfile.mkstemp(suffix='.sdf')
    os.close(fd2)
    try:
        w = SdfWriter.create(path2, 'TSKMEM', flags=0)
        b_prog = w.add_block(WBlock(csect_name='TCS', blk_name='TPROG',
                                    blk_class=BCLASS_PROGRAM, blk_id=1))
        b_task = w.add_block(WBlock(csect_name='TCS', blk_name='BURN_TASK',
                                    blk_class=BCLASS_TASK, blk_id=2))
        # TASK entry-point symbol
        w.add_symbol(WSymbol(blk_no=b_task, symb_name='BURN_TASK',
                             sym_class=SCLASS_VARIABLE, sym_type=STYPE_TASK))
        # TASK local variable
        w.add_symbol(WSymbol(blk_no=b_task, symb_name='THRUST_LEVEL',
                             sym_class=SCLASS_VARIABLE, sym_type=STYPE_SCALAR))
        # Program variable
        w.add_symbol(WSymbol(blk_no=b_prog, symb_name='PROG_VAR',
                             sym_class=SCLASS_VARIABLE, sym_type=STYPE_SCALAR))
        w.commit()

        ctx = SdfContext.open(path2)
        ctx.select('TSKMEM')

        # After block sort: BURN_TASK(1) < TPROG(2)
        tb = ctx.find_block_by_number(1)
        CHECK('T35: blk1 name=BURN_TASK',      tb.blk_name == 'BURN_TASK')
        CHECK('T35: blk1 class=TASK',          tb.blk_class == BCLASS_TASK)
        CHECK('T35: BURN_TASK 2 symbols',      tb.lsymb_no - tb.fsymb_no + 1 == 2)

        pb = ctx.find_block_by_number(2)
        CHECK('T35: blk2 name=TPROG',          pb.blk_name == 'TPROG')
        CHECK('T35: blk2 class=PROGRAM',        pb.blk_class == BCLASS_PROGRAM)

        # BURN_TASK entry-point symbol (first in BURN_TASK block)
        ts = ctx.find_symbol_by_number(tb.fsymb_no)
        CHECK('T35: entry name=BURN_TASK',     ts.symb_name == 'BURN_TASK')
        CHECK('T35: entry type=TASK',          ts.sym_type == STYPE_TASK)
        CHECK('T35: entry class=VARIABLE',     ts.sym_class == SCLASS_VARIABLE)

        # THRUST_LEVEL is second in BURN_TASK block
        tl = ctx.find_symbol_by_number(tb.fsymb_no + 1)
        CHECK('T35: THRUST_LEVEL name',        tl.symb_name == 'THRUST_LEVEL')
        CHECK('T35: THRUST_LEVEL type=SCALAR', tl.sym_type == STYPE_SCALAR)

        ctx.close()
    finally:
        os.unlink(path2)

# =====================================================================
# Main
# =====================================================================

def main():
    global _path
    if '--help' in sys.argv or '-h' in sys.argv:
        print(__doc__)
        sys.exit(0)
    fd, _path = tempfile.mkstemp(suffix='.sdf')
    os.close(fd)
    try:
        build_sdf_file(_path)
        print(f'Test SDF file: {_path}\n')

        tests = [
            t01_open_close, t02_select_known, t03_select_unknown,
            t04_select_idempotent, t05_locate_root,
            t06_find_block_by_number, t07_find_block_by_name,
            t08_find_block_not_found, t09_find_symbol_by_number,
            t10_find_symbol_by_name, t11_find_symbol_not_found,
            t12_find_stmt_exec, t13_find_stmt_non_exec,
            t14_find_block_node, t15_find_symbol_node,
            t16_find_stmt_node, t17_bad_pointer,
            t18_augment_rescind, t19_stats, t20_strerror,
            t21_bad_block_zero, t22_bad_block_overflow,
            t23_locate_counter_wrap, t24_find_stmt_by_srn, t25_no_srns,
            t26_flat_info, t27_pds_round_trip, t28_sdfcheck,
            t29_context_manager, t30_copy_write_roundtrip,
            t31_copy_no_array_no_cont, t32_event_roundtrip,
            t33_name_roundtrip, t34_equate_ext_roundtrip,
            t35_task_block_roundtrip,
        ]
        for t in tests:
            t()

    finally:
        os.unlink(_path)

    print(f'\n--- Results: {_pass} passed, {_fail} failed ---')
    sys.exit(1 if _fail else 0)

if __name__ == '__main__':
    main()
