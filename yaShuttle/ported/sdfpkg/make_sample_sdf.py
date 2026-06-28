#!/usr/bin/env python3
"""
make_sample_sdf.py  --  Build a sample SDF flat file for demonstration.

Creates 'sample.sdf' containing one member 'NAVCOMP' with:

  Block 1: NAVCOMP  (PROGRAM, CSECT NAVSECT)
    Symbols (in alphabetical order):
      ALTITUDE        SCALAR
      ARMED           BOOLEAN
      BITS            BIT(16)
      COUNT           INTEGER
      INERTIA         MATRIX(3,3)
      LONGSYMBOLNAME  SCALAR
      MESSAGE         CHARACTER(20)
      SENSOR          STRUCTURE (instance of SENSOR_DATA template)
      VELOCITY        VECTOR(3)

  Block 2: SENSOR_DATA  (STRUCTURE template)
    Members:
      ALT_READING     SCALAR    (structure member)
      STATUS_CODE     INTEGER   (structure member)
      VEL_READING     VECTOR(3) (structure member)

  Statements (with SRNs, in block 1):
    S0001  ALTITUDE = 35000.0;          (assignment, executable)
    S0002  BURN: COUNT = COUNT + 1;     (assignment, 1 label, executable)
    S0003  IF ARMED THEN ...;           (IF, executable)
    S0004  DECLARE ...;                 (non-executable)

HAL/S STRUCTURE encoding in the SDF
=====================================
  Block class 3 (PROCEDURE) is used for STRUCTURE template blocks.
  The template block contains the member symbols.

  Template header symbol (CLASS=3, TYPE=10):
    Appears in the template block; rows field holds the symbol's own
    symbol number (self-referential template marker).

  Member symbols (CLASS=1, various types):
    Appear in the template block, sorted alphabetically among themselves.

  Instance variable (CLASS=1, TYPE=10=STRUCTURE):
    Appears in the program block.
    rows field = symbol number of the template header symbol.
"""

import struct
import sys

PAGE  = 1680
MAGIC = b'SDF\x00'

def w8 (b, o, v): b[o] = v & 0xFF
def w16(b, o, v): struct.pack_into('>H', b, o, v & 0xFFFF)
def w32(b, o, v): struct.pack_into('>I', b, o, v & 0xFFFFFFFF)
def wstr(b, o, s, n):
    enc = (s.encode('ascii') + b' ' * n)[:n]
    b[o:o+n] = enc
def vp(page, off): return (page << 16) | off

# ---------------------------------------------------------------------------
# Symbol layout (all symbols across both blocks, alphabetical within block)
# ---------------------------------------------------------------------------
# Block 1 (NAVCOMP) symbols -- alphabetical:
#   1: ALTITUDE       SCALAR          class=1 type=1
#   2: ARMED          BOOLEAN         class=1 type=3
#   3: BITS           BIT(16)         class=1 type=5 rows=16
#   4: COUNT          INTEGER         class=1 type=2
#   5: INERTIA        MATRIX(3,3)     class=1 type=7 rows=3 cols=3
#   6: LONGSYMBOLNAME SCALAR          class=1 type=1
#   7: MESSAGE        CHARACTER(20)   class=1 type=4 cols=20
#   8: SENSOR         STRUCTURE inst. class=1 type=10 rows=<templ symb#>
#   9: VELOCITY       VECTOR(3)       class=1 type=6 rows=3
#
# Block 2 (SENSOR_DATA) symbols -- alphabetical:
#  10: ALT_READING    SCALAR          class=1 type=1
#  11: SENSOR_DATA    template hdr    class=3 type=10 rows=11 (self-ref)
#  12: STATUS_CODE    INTEGER         class=1 type=2
#  13: VEL_READING    VECTOR(3)       class=1 type=6 rows=3
#
# SENSOR (symb 8) has rows=11 (symbol number of SENSOR_DATA template hdr).
# ---------------------------------------------------------------------------

BLK1_SYMS = [
    # (name,            class, type, rows, cols, array_dims)
    # array_dims = (ndims, d1, d2, d3); (0,...) = not an array
    ('ALTITUDE',        1,  1,  0,  0, (0,0,0,0)),
    ('ARMED',           1,  3,  0,  0, (0,0,0,0)),
    ('BITS',            1,  5, 16,  0, (0,0,0,0)),
    ('COUNT',           1,  2,  0,  0, (0,0,0,0)),
    ('INERTIA',         1,  7,  3,  3, (0,0,0,0)),
    ('LONGSYMBOLNAME',  1,  1,  0,  0, (0,0,0,0)),
    ('MESSAGE',         1,  4,  0, 20, (0,0,0,0)),
    ('READINGS',        1,  1,  0,  0, (1,10,0,0)),  # ARRAY(10) SCALAR
    ('SENSOR',          1, 10,  0,  0, (0,0,0,0)),  # rows filled in below
    ('TABLE',           1,  2,  0,  0, (2, 3,4,0)),  # ARRAY(3,4) INTEGER
    ('VELOCITY',        1,  6,  3,  0, (0,0,0,0)),
]

BLK2_SYMS = [
    # (name,            class, type, rows, cols, array_dims)
    ('ALT_READING',     1,  1,  0,  0, (0,0,0,0)),  # symb 12: SCALAR member
    ('SENSOR_DATA',     3, 10,  0,  0, (0,0,0,0)),  # symb 13: template hdr
    ('STATUS_CODE',     1,  2,  0,  0, (0,0,0,0)),  # symb 14: INTEGER member
    ('VEL_READING',     1,  6,  3,  0, (0,0,0,0)),  # symb 15: VECTOR(3) member
]

# SENSOR instance rows = symb# of SENSOR_DATA template header.
# After adding READINGS and TABLE, block 1 has 11 symbols (indices 0-10).
# Block 2 has 4 symbols: ALT_READING(12), SENSOR_DATA(13), STATUS_CODE(14), VEL_READING(15).
# Wait: sort is alphabetical within block. Block 1 alphabetical:
#   ALTITUDE(1), ARMED(2), BITS(3), COUNT(4), INERTIA(5), LONGSYMBOLNAME(6),
#   MESSAGE(7), READINGS(8), SENSOR(9), TABLE(10), VELOCITY(11)
# Block 2: ALT_READING(12), SENSOR_DATA(13), STATUS_CODE(14), VEL_READING(15)
# SENSOR_DATA template header = symb 13.
BLK1_SYMS[8] = ('SENSOR', 1, 10, 13, 0, (0,0,0,0))
# SENSOR_DATA template header (symb 13) rows = self = 13
BLK2_SYMS[1] = ('SENSOR_DATA', 3, 10, 13, 0, (0,0,0,0))

ALL_SYMS = BLK1_SYMS + BLK2_SYMS   # indices 0-10 = blk1, 11-14 = blk2

STMTS = [
    # (srn,     stmt_type, is_exec, num_lhs, num_labls)
    ('S0001 ', 1, True,  1, 0),
    ('S0002 ', 1, True,  1, 1),
    ('S0003 ', 2, True,  0, 0),
    ('S0004 ', 0, False, 0, 0),
]

# ---------------------------------------------------------------------------
# Page layout
# ---------------------------------------------------------------------------
# Page 0:  PAGEZERO(12) + DROOTCEL(172+)
# Page 1:  BLCKNODE[1](12) + BLKTCELL[1](variable)
#          BLCKNODE[2](12) + BLKTCELL[2](variable)
# Page 2:  Symbol nodes for ALL_SYMS (13 * 12 = 156 bytes)
#          Symbol data cells for all symbols
# Page 3:  Statement nodes + stmt data cells + STMTEXTF/V

pages = [bytearray(PAGE) for _ in range(4)]
p0, p1, p2, p3 = pages

# ---- Page 0: PAGEZERO -----------------------------------------------
w16(p0, 0, 1)               # version
w32(p0, 8, vp(0, 16))       # droot_ptr

# ---- Page 0: DROOTCEL at offset 16 ----------------------------------
dr = p0
o  = 16
w8 (dr, o+0, 0x80)          # HAS_SRNS
w8 (dr, o+1, 0x00)
w16(dr, o+2,  3)             # last_page = 3
w16(dr, o+16, 2)             # blk_nodes = 2
w16(dr, o+18, len(ALL_SYMS)) # sym_nodes = 15
w32(dr, o+20, vp(1,  0))    # fbn_ptr (BLCKNODE[1] at p1+0)
w32(dr, o+24, vp(1, 12))    # lbn_ptr (BLCKNODE[2] at p1+12)
w32(dr, o+36, vp(2,  0))    # fsn_ptr (first symbol node)
w32(dr, o+40, vp(2, 12*(len(ALL_SYMS)-1)))  # lsn_ptr (last symb node)
w32(dr, o+48, vp(1, 24))    # btree_ptr (root of block name tree)
w16(dr, o+52, 1)             # fstmt_num
w16(dr, o+54, len(STMTS))   # lstm_num
w32(dr, o+60, vp(3, 0))     # fstn_ptr
w32(dr, o+64, vp(3, 12*(len(STMTS)-1)))  # lstn_ptr
w32(dr, o+68, vp(3, 200))   # snel_ptr
wstr(dr, o+72, 'S0001   ', 8)
wstr(dr, o+80, 'S0004   ', 8)
w32(dr, o+168, 0)            # dinit_ptr

# ---- Page 1: Block nodes + tree cells --------------------------------
# BLCKNODE[1]: NAVSECT -> BLKTCELL[1]
wstr(p1, 0, 'NAVSECT ', 8)
w32 (p1, 8, vp(1, 24))      # block_ptr -> BLKTCELL[1] at p1+24

# BLCKNODE[2]: STRCSECT -> BLKTCELL[2]
wstr(p1, 12, 'STRCSECT', 8)
w32 (p1, 20, vp(1, 80))     # block_ptr -> BLKTCELL[2] at p1+80

# BLKTCELL[1] at offset 24: NAVCOMP (PROGRAM)
# Block name tree: 2 blocks sorted: NAVCOMP < SENSOR_DATA
# Balanced BST with 2 nodes: root=NAVCOMP (index 0), right=SENSOR_DATA (index 1)
# So NAVCOMP.rtree_ptr -> SENSOR_DATA's BLKTCELL
bt1 = p1
w32(bt1, 24+0,  vp(1,80))   # rtree_ptr -> SENSOR_DATA's BLKTCELL
w32(bt1, 24+4,  0)           # ltree_ptr = NULL
w32(bt1, 24+16, 0)           # ext_ptr (set after sym extent)
w16(bt1, 24+26, 1)           # blk_ndx = 1
w16(bt1, 24+28, 1)           # blk_id  = 1
w8 (bt1, 24+30, 1)           # blk_class = PROGRAM
w8 (bt1, 24+31, 0)
w16(bt1, 24+32, 1)           # fsymb_num = 1
w16(bt1, 24+34, len(BLK1_SYMS))  # lsymb_num = 11
w16(bt1, 24+36, 1)           # fstmt_num = 1
w16(bt1, 24+38, len(STMTS)) # lstm_num  = 4
w8 (bt1, 24+44, len('NAVCOMP'))
wstr(bt1, 24+45, 'NAVCOMP', 32)

# BLKTCELL[2] at offset 80: SENSOR_DATA (STRUCTURE template, blk_class=3)
bt2 = p1
w32(bt2, 80+0,  0)           # rtree_ptr = NULL
w32(bt2, 80+4,  0)           # ltree_ptr = NULL
w32(bt2, 80+16, 0)           # ext_ptr
w16(bt2, 80+26, 2)           # blk_ndx = 2
w16(bt2, 80+28, 2)           # blk_id  = 2
w8 (bt2, 80+30, 3)           # blk_class = 3 (PROCEDURE = structure template)
w8 (bt2, 80+31, 0)
w16(bt2, 80+32, len(BLK1_SYMS)+1)       # fsymb_num = 12
w16(bt2, 80+34, len(ALL_SYMS))           # lsymb_num = 15
w16(bt2, 80+36, 0)           # fstmt_num = 0 (no stmts in structure)
w16(bt2, 80+38, 0)           # lstm_num  = 0
w8 (bt2, 80+44, len('SENSOR_DATA'))
wstr(bt2, 80+45, 'SENSOR_DATA', 32)

# ---- Page 2: Symbol nodes + Symbol data cells -----------------------
NUM_SYMS  = len(ALL_SYMS)    # 13
SDC_BASE  = NUM_SYMS * 12    # = 156

sdc_pos = SDC_BASE
for i, (name, cls, typ, rows, cols, adims) in enumerate(ALL_SYMS):
    node_off = i * 12
    name8    = (name.encode('ascii') + b'        ')[:8]
    p2[node_off:node_off+8] = name8
    w32(p2, node_off+8, vp(2, sdc_pos))

    symb_len  = len(name)
    blk_num   = 1 if i < len(BLK1_SYMS) else 2
    cont_bytes = name[8:].encode('ascii') if symb_len > 8 else b''
    cont       = len(cont_bytes)
    has_array  = adims[0] > 0

    w16(p2, sdc_pos+0,  blk_num)
    # array_off: byte offset from SDC start to ARRADATA (0 = not an array)
    if has_array:
        w8(p2, sdc_pos+4, 24 + cont)
    w8 (p2, sdc_pos+6,  cls)
    w8 (p2, sdc_pos+7,  typ)
    w8 (p2, sdc_pos+12, symb_len)
    w8 (p2, sdc_pos+18, rows)
    w8 (p2, sdc_pos+19, cols)
    if cont:
        p2[sdc_pos+24 : sdc_pos+24+cont] = cont_bytes
    # ARRADATA block (8 bytes: arraynum(H) + range1(H) + range2(H) + range3(H))
    if has_array:
        ao = sdc_pos + 24 + cont
        w16(p2, ao+0, adims[0])  # arraynum
        w16(p2, ao+2, adims[1])  # range1
        w16(p2, ao+4, adims[2])  # range2
        w16(p2, ao+6, adims[3])  # range3
        sdc_pos += 24 + cont + 8
    else:
        sdc_pos += 24 + cont

# ---- Page 3: Statement nodes + data cells + extent cell -------------
STDC_BASE = len(STMTS) * 12
exec_count = 0
for i, (srn, stype, is_exec, num_lhs, num_labls) in enumerate(STMTS):
    node_off = i * 12
    wstr(p3, node_off, srn, 6)
    w8  (p3, node_off+6, 0)
    w8  (p3, node_off+7, 0)
    if is_exec:
        stdc_off = STDC_BASE + exec_count * 6
        w32(p3, node_off+8, vp(3, stdc_off))
        w16(p3, stdc_off+0, 1)
        w16(p3, stdc_off+2, stype)
        w8 (p3, stdc_off+4, num_labls)
        w8 (p3, stdc_off+5, num_lhs)
        exec_count += 1
    else:
        w32(p3, node_off+8, 0)

# STMTEXTF at 200
w32(p3, 200, 0)
w16(p3, 204, 1)
w16(p3, 206, 3)
# STMTEXTV at 208
w16(p3, 208, 0)
w16(p3, 210, (len(STMTS)-1)*12)
wstr(p3, 212, 'S0001   ', 8)
wstr(p3, 220, 'S0004   ', 8)

# ---------------------------------------------------------------------------
# Write flat file
# ---------------------------------------------------------------------------
OUTPUT = 'sample.sdf'
with open(OUTPUT, 'wb') as f:
    f.write(MAGIC)
    f.write(struct.pack('>I', 1))
    pg0_offset = 8 + 20
    f.write(b'NAVCOMP ')
    f.write(struct.pack('>I', len(pages)))
    f.write(struct.pack('>Q', pg0_offset))
    for page in pages:
        f.write(bytes(page))

print(f'Written {OUTPUT}')
print(f'  Member:  NAVCOMP')
print(f'  Blocks:  2 (NAVCOMP PROGRAM + SENSOR_DATA STRUCTURE template)')
print(f'  Symbols: {NUM_SYMS} (including {sum(1 for s in BLK1_SYMS if s[5][0]>0)} ARRAY symbols)')
print(f'  Blocks:  2 (NAVCOMP:{len(BLK1_SYMS)} symbols, SENSOR_DATA:{len(BLK2_SYMS)} symbols)')
print(f'  Stmts:   {len(STMTS)} ({exec_count} exec, {len(STMTS)-exec_count} non-exec)')
