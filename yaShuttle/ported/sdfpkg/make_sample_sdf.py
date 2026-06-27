#!/usr/bin/env python3
"""
make_sample_sdf.py  --  Build a sample SDF flat file for demonstration purposes.

This script creates a file called 'sample.sdf' containing one SDF member
named 'NAVCOMP' with:

  - One program block: NAVCOMP (CSECT: NAVSECT)
  - Eight symbols of different classes and types:
      1. ALTITUDE     SCALAR
      2. VELOCITY     VECTOR(3)
      3. INERTIA      MATRIX(3,3)
      4. COUNT        INTEGER
      5. ARMED        BOOLEAN
      6. MESSAGE      CHARACTER(20)
      7. BITS         BIT(16)
      8. LONGSYMBOLNAME  SCALAR  (name > 8 chars, exercises name continuation)
  - Three executable statements with SRNs
  - One non-executable (declare) statement

HAL/S symbol CLASS and TYPE encoding (from the HAL/S-FC SDF):
  CLASS  1  = simple variable
  CLASS  2  = equate external (EXT)
  CLASS  3  = template / structure
  CLASS  4  = label
  CLASS  6  = compool name

  TYPE   1  = SCALAR
  TYPE   2  = INTEGER
  TYPE   3  = BOOLEAN
  TYPE   4  = CHARACTER
  TYPE   5  = BIT
  TYPE   6  = VECTOR
  TYPE   7  = MATRIX
  TYPE   8  = equate external (used with CLASS 2)
  TYPE   9  = EVENT
  TYPE  10  = STRUCTURE template
  TYPE  11  = TASK

Block CLASS values:
  1 = PROGRAM
  2 = FUNCTION
  3 = PROCEDURE
  4 = TASK
  5 = COMPOOL
  6 = CLOSE BLOCK (nested)
"""

import struct
import sys

PAGE  = 1680
MAGIC = b'SDF\x00'

# ---------------------------------------------------------------------------
# Low-level write helpers (big-endian, same as in test_sdfpkg.py)
# ---------------------------------------------------------------------------

def w8 (b, o, v): b[o] = v & 0xFF
def w16(b, o, v): struct.pack_into('>H', b, o, v & 0xFFFF)
def w32(b, o, v): struct.pack_into('>I', b, o, v & 0xFFFFFFFF)
def wstr(b, o, s, n):
    enc = (s.encode('ascii') + b' ' * n)[:n]
    b[o:o+n] = enc

def vp(page, off): return (page << 16) | off

# ---------------------------------------------------------------------------
# Symbol descriptors (name, class, type, rows, cols, symb_len)
# ---------------------------------------------------------------------------

SYMBOLS = [
    # (name,            class, type, rows, cols)
    # MUST be in ascending alphabetical order for the binary search to work.
    ('ALTITUDE',        1,     1,    0,    0),    # SCALAR
    ('ARMED',           1,     3,    0,    0),    # BOOLEAN
    ('BITS',            1,     5,   16,    0),    # BIT(16)  -- rows=bit length
    ('COUNT',           1,     2,    0,    0),    # INTEGER
    ('INERTIA',         1,     7,    3,    3),    # MATRIX(3,3)
    ('LONGSYMBOLNAME',  1,     1,    0,    0),    # SCALAR, name > 8 chars
    ('MESSAGE',         1,     4,    0,   20),    # CHARACTER(20) -- cols=char len
    ('VELOCITY',        1,     6,    3,    0),    # VECTOR(3)
]

# Statement descriptors (srn, stmt_type, is_exec, num_lhs, num_labls)
STMTS = [
    ('S0001 ', 1, True,  1, 0),   # assignment
    ('S0002 ', 1, True,  1, 1),   # assignment with label
    ('S0003 ', 2, True,  0, 0),   # IF statement
    ('S0004 ', 0, False, 0, 0),   # non-executable (DECLARE)
]

# ---------------------------------------------------------------------------
# Build pages
# ---------------------------------------------------------------------------

pages = [bytearray(PAGE) for _ in range(4)]   # 4 pages total
p0, p1, p2, p3 = pages

# ---- Page 0: PAGEZERO + DROOTCEL -----------------------------------
w16(p0, 0, 1)                   # version = 1
w32(p0, 8, vp(0, 16))           # droot_ptr

dr = p0
o  = 16   # DROOTCEL starts here

w8 (dr, o+0, 0x80)              # sdf_flags[0]: HAS_SRNS
w8 (dr, o+1, 0x00)              # sdf_flags[1]
w16(dr, o+2,  3)                # last_page = 3  (pages 0..3)
w16(dr, o+16, 1)                # blk_nodes = 1
w16(dr, o+18, len(SYMBOLS))     # sym_nodes = 8
w32(dr, o+20, vp(1, 0))         # fbn_ptr  (first block node)
w32(dr, o+24, vp(1, 0))         # lbn_ptr
w32(dr, o+36, vp(2, 0))         # fsn_ptr  (first symbol node)
w32(dr, o+40, vp(2, 12*(len(SYMBOLS)-1)))  # lsn_ptr
w32(dr, o+48, vp(1, 12))        # btree_ptr (root of block name tree)
w16(dr, o+52, 1)                # fstmt_num
w16(dr, o+54, len(STMTS))       # lstm_num
w32(dr, o+60, vp(3, 0))         # fstn_ptr (first stmt node, page 3)
w32(dr, o+64, vp(3, 12*(len(STMTS)-1)))  # lstn_ptr
w32(dr, o+68, vp(3, 200))       # snel_ptr (stmt extent cell)
wstr(dr, o+72, 'S0001   ', 8)   # first_srn (CL8 padded in DROOTCEL)
wstr(dr, o+80, 'S0004   ', 8)   # last_srn
w32(dr, o+168, 0)               # dinit_ptr = 0

# ---- Page 1: BLCKNODE[1] + BLKTCELL[1] ----------------------------
# BLCKNODE at offset 0: csct_name(8) + block_ptr(4)
wstr(p1, 0, 'NAVSECT ', 8)
w32 (p1, 8, vp(1, 12))          # block_ptr -> BLKTCELL at p1+12

# BLKTCELL at offset 12
bt = p1
w32(bt, 12+0,  0)               # rtree_ptr = NULL  (only one block)
w32(bt, 12+4,  0)               # ltree_ptr = NULL
w32(bt, 12+8,  0)               # fnest_ptr
w32(bt, 12+12, 0)               # lnest_ptr
w32(bt, 12+16, 0)               # ext_ptr = 0 (no symbol extent cell needed
                                #   since all symbols fit on one page)
w16(bt, 12+26, 1)               # blk_ndx = 1
w16(bt, 12+28, 1)               # blk_id  = 1
w8 (bt, 12+30, 1)               # blk_class = 1 (PROGRAM)
w8 (bt, 12+31, 0)               # blk_type  = 0
w16(bt, 12+32, 1)               # fsymb_num = 1
w16(bt, 12+34, len(SYMBOLS))    # lsymb_num = 8
w16(bt, 12+36, 1)               # fstmt_num = 1
w16(bt, 12+38, len(STMTS))      # lstm_num  = 4
w8 (bt, 12+44, len('NAVCOMP'))  # bname_len = 7
wstr(bt, 12+45, 'NAVCOMP', 32)  # blk_name

# ---- Page 2: Symbol nodes + Symbol data cells ----------------------
#
# Symbol nodes: 12 bytes each (NAME(8) + SDC_PTR(4)) at offsets 0, 12, 24, ...
# Symbol data cells: 47+ bytes each, packed after the nodes.
#
# With 8 symbols, nodes occupy 8*12 = 96 bytes.
# SDC area starts at offset 96.

SDC_BASE = 8 * 12   # = 96

# Size of each SDC entry (fixed portion only - name continuation varies)
# We'll lay them out sequentially; each needs at least 23 bytes for fixed fields
# plus name continuation bytes.
sdc_offsets = []
sdc_pos = SDC_BASE

for i, (name, cls, typ, rows, cols) in enumerate(SYMBOLS):
    node_off = i * 12

    # Compute SDC offset (to be written into node)
    sdc_offsets.append(sdc_pos)

    # Write symbol node
    name8 = (name.encode('ascii') + b'        ')[:8]
    p2[node_off:node_off+8] = name8
    w32(p2, node_off+8, vp(2, sdc_pos))

    # Write SDC
    symb_len = len(name)
    w16(p2, sdc_pos+0,  1)       # block_num = 1
    w8 (p2, sdc_pos+6,  cls)     # sym_class
    w8 (p2, sdc_pos+7,  typ)     # sym_type
    w8 (p2, sdc_pos+8,  0)       # flag1
    w8 (p2, sdc_pos+9,  0)       # flag2
    w8 (p2, sdc_pos+10, 0)       # flag3
    w8 (p2, sdc_pos+11, 0)       # flag4
    w8 (p2, sdc_pos+12, symb_len)# symb_len
    # rel_addr[3] at sdc_pos+13: 0 (not used in this sample)
    w8 (p2, sdc_pos+18, rows)    # rows
    w8 (p2, sdc_pos+19, cols)    # columns (or char len / bit len)
    # name continuation at sdc_pos+23
    if symb_len > 8:
        cont = name[8:].encode('ascii')
        p2[sdc_pos+23 : sdc_pos+23+len(cont)] = cont
        sdc_pos += 23 + len(cont)
    else:
        sdc_pos += 23

# ---- Page 3: Statement nodes + STMTEXTF + STMTEXTV -----------------
#
# Statement nodes: 12 bytes each (SRN(6)+INCOUNT(2)+STDC_PTR(4))
# Stmt data cells: 6 bytes each
# STMTEXTF at offset 200, STMTEXTV at offset 208

STDC_BASE = len(STMTS) * 12     # = 48

exec_stmt_count = 0
for i, (srn, stype, is_exec, num_lhs, num_labls) in enumerate(STMTS):
    node_off = i * 12
    wstr(p3, node_off, srn, 6)   # SRN (CL6)
    w8  (p3, node_off+6, 0)      # incount high
    w8  (p3, node_off+7, 0)      # incount low
    if is_exec:
        stdc_off = STDC_BASE + exec_stmt_count * 6
        w32(p3, node_off+8, vp(3, stdc_off))   # positive = executable
        # Write STMTDC
        w16(p3, stdc_off+0, 1)         # block_num
        w16(p3, stdc_off+2, stype)     # stmt_type
        w8 (p3, stdc_off+4, num_labls) # num_labls
        w8 (p3, stdc_off+5, num_lhs)   # num_lhs
        exec_stmt_count += 1
    else:
        # Non-executable: stdc_ptr = 0
        w32(p3, node_off+8, 0)

# STMTEXTF at offset 200: succ_ptr(4) + nx_ntry(2) + fst_page(2)
w32(p3, 200, 0)                 # succ_ptr = NULL
w16(p3, 204, 1)                 # nx_ntry = 1 entry
w16(p3, 206, 3)                 # fst_page1 = 3 (page 3)

# STMTEXTV at offset 208: fst_off(2)+lst_off(2)+fst_srn(8)+lst_srn(8)
w16(p3, 208, 0)                 # fst_off1 = 0 (first stmt node at page3+0)
w16(p3, 210, (len(STMTS)-1)*12)# lst_off1
wstr(p3, 212, 'S0001   ', 8)   # fst_srn (CL8)
wstr(p3, 220, 'S0004   ', 8)   # lst_srn (CL8)

# ---------------------------------------------------------------------------
# Write the flat file
# ---------------------------------------------------------------------------

OUTPUT = 'sample.sdf'

with open(OUTPUT, 'wb') as f:
    # Header: magic(4) + count(4)
    f.write(MAGIC)
    f.write(struct.pack('>I', 1))   # 1 member

    # Index entry: name(8) + pages(4) + offset(8)
    pg0_offset = 8 + 20             # header(8) + one index entry(20)
    f.write(b'NAVCOMP ')            # member name, space-padded to 8
    f.write(struct.pack('>I', len(pages)))
    f.write(struct.pack('>Q', pg0_offset))

    for page in pages:
        f.write(bytes(page))

print(f'Written {OUTPUT}')
print(f'  Member:  NAVCOMP')
print(f'  Pages:   {len(pages)} ({len(pages)*PAGE} bytes)')
print(f'  Symbols: {len(SYMBOLS)}')
print(f'  Stmts:   {len(STMTS)} ({sum(1 for _,_,e,_,_ in STMTS if e)} executable, '
      f'{sum(1 for _,_,e,_,_ in STMTS if not e)} non-executable)')
