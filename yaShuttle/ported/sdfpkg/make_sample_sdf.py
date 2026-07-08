#!/usr/bin/env python3
"""
make_sample_sdf.py  --  Build a sample SDF flat file for demonstration.

Creates 'sample.sdf' containing one member 'NAVCOMP' with:

  Block 1: NAVCOMP  (PROGRAM, CSECT NAVSECT)
    Symbols (in alphabetical order after commit):
      ALTITUDE        SCALAR
      ARMED           BOOLEAN
      BITS            BIT(16)
      COUNT           INTEGER
      INERTIA         MATRIX(3,3)
      LAUNCH_ENABLE   EVENT
      LONGSYMBOLNAME  SCALAR
      MESSAGE         CHARACTER(20)
      READINGS        ARRAY(10) SCALAR
      SENSOR          STRUCTURE (instance of SENSOR_DATA template)
      TABLE           ARRAY(3,4) INTEGER
      VELOCITY        VECTOR(3)

  Block 2: EXT_SENSOR  (STRUCTURE template, COPYs SENSOR_DATA)
    Members:
      EXT_SENSOR      template header (copy_blk_no -> SENSOR_DATA block)
      RANGE_KM        SCALAR  (own member)

  Block 3: SENSOR_DATA  (STRUCTURE template, base)
    Members:
      ALT_READING     SCALAR
      SENSOR_DATA     template header (self-referential rows)
      STATUS_CODE     INTEGER
      VEL_READING     VECTOR(3)

  (Block numbers above are the final sorted order: EXT_SENSOR < NAVCOMP < SENSOR_DATA)

  Statements (with SRNs, in block NAVCOMP):
    S0001  ALTITUDE = 35000.0;          (assignment, executable)
    S0002  BURN: COUNT = COUNT + 1;     (assignment, 1 label, executable)
    S0003  IF ARMED THEN ...;           (IF, executable)
    S0004  DECLARE ...;                 (non-executable)

HAL/S STRUCTURE encoding in the SDF
=====================================
  Block class 1 (PROCEDURE) is used for STRUCTURE template blocks.
  The template block contains the member symbols.

  Template header symbol (CLASS=7=TEMPLATE, TYPE=10=STRUCTURE):
    Appears in the template block; rows field holds the symbol's own
    symbol number (self-referential template marker).

  Member symbols (CLASS=1=VARIABLE, various types):
    Appear in the template block, sorted alphabetically among themselves.

  Instance variable (CLASS=1=VARIABLE, TYPE=10=STRUCTURE):
    Appears in the program block.
    rows field = symbol number of the template header symbol.

  COPY link (STRCDATA):
    When a STRUCTURE template inherits another template's members via
    COPY, the template header symbol's SDC contains a STRCDATA block
    (located at SDC_base + struct_of).  STRCDATA holds copy_blk_no:
    the block number of the template being COPYed.
    EXT_SENSOR COPYs SENSOR_DATA: its template header has copy_blk_no
    set to the final block number of the SENSOR_DATA block.

Previously this file hand-built binary page images at fixed offsets.
It now uses the SdfWriter API, which is the authoritative write path.
"""

import os
import sys

# Allow running from the project directory or from a sibling directory
script_dir = os.path.dirname(os.path.abspath(__file__))
if script_dir not in sys.path:
    sys.path.insert(0, script_dir)

from sdfpkg import (
    SdfWriter, WBlock, WSymbol, WStmt,
    BCLASS_PROGRAM, BCLASS_PROCEDURE, BCLASS_TASK,
    SCLASS_VARIABLE, SCLASS_TEMPLATE, SCLASS_LABEL,
    STYPE_SCALAR, STYPE_INTEGER, STYPE_CHARACTER,
    STYPE_BIT, STYPE_VECTOR, STYPE_MATRIX, STYPE_STRUCTURE, STYPE_EVENT,
    STYPE_TASK_LABEL, STYPE_IORS,
    STTYPE_ASSIGN, STTYPE_IF,
    WFLAG_HAS_SRNS,
)

OUTPUT = os.path.join(script_dir, 'sample.sdf')

# ---------------------------------------------------------------------------
# Create write context
# ---------------------------------------------------------------------------
w = SdfWriter.create(OUTPUT, 'NAVCOMP', flags=WFLAG_HAS_SRNS)

# ---------------------------------------------------------------------------
# Blocks  (added in any order; sorted alphabetically by name at commit time)
# Final sorted order: BURN_TASK(1) < EXT_SENSOR(2) < NAVCOMP(3) < SENSOR_DATA(4)
# ---------------------------------------------------------------------------
b_prog = w.add_block(WBlock(
    csect_name = 'NAVSECT',
    blk_name   = 'NAVCOMP',
    blk_class  = BCLASS_PROGRAM,
    blk_id     = 1,
))

b_base = w.add_block(WBlock(
    csect_name = 'STRCSECT',
    blk_name   = 'SENSOR_DATA',
    blk_class  = BCLASS_PROCEDURE,   # blk_class=1: PROCEDURE (STRUCTURE template)
    blk_id     = 2,
))

b_ext = w.add_block(WBlock(
    csect_name = 'STRCSECT',
    blk_name   = 'EXT_SENSOR',
    blk_class  = BCLASS_PROCEDURE,   # blk_class=1: PROCEDURE (STRUCTURE template)
    blk_id     = 3,
))

b_task = w.add_block(WBlock(
    csect_name = 'NAVSECT',
    blk_name   = 'BURN_TASK',
    blk_class  = BCLASS_TASK,        # blk_class=5: TASK block
    blk_id     = 4,
))

# ---------------------------------------------------------------------------
# SENSOR_DATA template symbols  (block b_base)
# ---------------------------------------------------------------------------
w.add_symbol(WSymbol(
    blk_no    = b_base,
    symb_name = 'SENSOR_DATA',
    sym_class = SCLASS_TEMPLATE,      # CLASS=3: template header
    sym_type  = STYPE_STRUCTURE,      # TYPE=10
    # rows = own symb_no (self-referential); filled in by commit()
    # copy_blk_no = 0: base template, no COPY
))

w.add_symbol(WSymbol(
    blk_no    = b_base,
    symb_name = 'ALT_READING',
    sym_class = SCLASS_VARIABLE,
    sym_type  = STYPE_SCALAR,
))

w.add_symbol(WSymbol(
    blk_no    = b_base,
    symb_name = 'STATUS_CODE',
    sym_class = SCLASS_VARIABLE,
    sym_type  = STYPE_INTEGER,
))

w.add_symbol(WSymbol(
    blk_no    = b_base,
    symb_name = 'VEL_READING',
    sym_class = SCLASS_VARIABLE,
    sym_type  = STYPE_VECTOR,
    rows      = 3,
))

# ---------------------------------------------------------------------------
# EXT_SENSOR template symbols  (block b_ext, COPYs b_base)
# ---------------------------------------------------------------------------
w.add_symbol(WSymbol(
    blk_no      = b_ext,
    symb_name   = 'EXT_SENSOR',
    sym_class   = SCLASS_TEMPLATE,
    sym_type    = STYPE_STRUCTURE,
    copy_blk_no = b_base,    # COPY link: inherits SENSOR_DATA's members
    # rows = own symb_no (self-referential); filled in by commit()
))

w.add_symbol(WSymbol(
    blk_no    = b_ext,
    symb_name = 'RANGE_KM',
    sym_class = SCLASS_VARIABLE,
    sym_type  = STYPE_SCALAR,
))

# ---------------------------------------------------------------------------
# BURN_TASK task symbols  (block b_task)
# ---------------------------------------------------------------------------
# The task entry-point symbol uses sym_type=STYPE_TASK_LABEL (0x48).
w.add_symbol(WSymbol(
    blk_no    = b_task,
    symb_name = 'BURN_TASK',
    sym_class = SCLASS_VARIABLE,
    sym_type  = STYPE_TASK_LABEL,  # TYPE=0x48: task entry-point label
))

w.add_symbol(WSymbol(
    blk_no    = b_task,
    symb_name = 'THRUST_LEVEL',
    sym_class = SCLASS_VARIABLE,
    sym_type  = STYPE_SCALAR,
))

# ---------------------------------------------------------------------------
# NAVCOMP program symbols  (block b_prog)
# ---------------------------------------------------------------------------
w.add_symbol(WSymbol(blk_no=b_prog, symb_name='ALTITUDE',
                     sym_class=SCLASS_VARIABLE, sym_type=STYPE_SCALAR))

w.add_symbol(WSymbol(blk_no=b_prog, symb_name='ARMED',
                     sym_class=SCLASS_VARIABLE, sym_type=STYPE_BIT, rows=1))

w.add_symbol(WSymbol(blk_no=b_prog, symb_name='BITS',
                     sym_class=SCLASS_VARIABLE, sym_type=STYPE_BIT, rows=16))

w.add_symbol(WSymbol(blk_no=b_prog, symb_name='COUNT',
                     sym_class=SCLASS_VARIABLE, sym_type=STYPE_INTEGER))

# Equate-external: LABEL class (2) with IORS type (8) — per SDFPKG.ASM
w.add_symbol(WSymbol(blk_no=b_prog, symb_name='EXT_CONST',
                     sym_class=SCLASS_LABEL, sym_type=STYPE_IORS))

w.add_symbol(WSymbol(blk_no=b_prog, symb_name='INERTIA',
                     sym_class=SCLASS_VARIABLE, sym_type=STYPE_MATRIX,
                     rows=3, columns=3))

w.add_symbol(WSymbol(blk_no=b_prog, symb_name='LAUNCH_ENABLE',
                     sym_class=SCLASS_VARIABLE, sym_type=STYPE_EVENT))

w.add_symbol(WSymbol(blk_no=b_prog, symb_name='LONGSYMBOLNAME',
                     sym_class=SCLASS_VARIABLE, sym_type=STYPE_SCALAR))

w.add_symbol(WSymbol(blk_no=b_prog, symb_name='MESSAGE',
                     sym_class=SCLASS_VARIABLE, sym_type=STYPE_CHARACTER,
                     columns=20))

# NAME variable (sym_class=SCLASS_LABEL=2): sym_type = type of referent
w.add_symbol(WSymbol(blk_no=b_prog, symb_name='ALT_PTR',
                     sym_class=SCLASS_LABEL, sym_type=STYPE_SCALAR))

w.add_symbol(WSymbol(blk_no=b_prog, symb_name='READINGS',
                     sym_class=SCLASS_VARIABLE, sym_type=STYPE_SCALAR,
                     array_dims=(1, 10, 0, 0)))   # ARRAY(10) SCALAR

# SENSOR: instance of SENSOR_DATA.  rows = template header symb_no.
# commit() sorts and renumbers, so we cannot know the final symb_no here.
# PASS3 of HALSFC would fill this in after its second pass; for the sample
# we leave rows=0 (placeholder).
w.add_symbol(WSymbol(blk_no=b_prog, symb_name='SENSOR',
                     sym_class=SCLASS_VARIABLE, sym_type=STYPE_STRUCTURE,
                     rows=0))

w.add_symbol(WSymbol(blk_no=b_prog, symb_name='TABLE',
                     sym_class=SCLASS_VARIABLE, sym_type=STYPE_INTEGER,
                     array_dims=(2, 3, 4, 0)))    # ARRAY(3,4) INTEGER

w.add_symbol(WSymbol(blk_no=b_prog, symb_name='VELOCITY',
                     sym_class=SCLASS_VARIABLE, sym_type=STYPE_VECTOR,
                     rows=3))

# ---------------------------------------------------------------------------
# Statements  (NAVCOMP block; must be added in source order)
# ---------------------------------------------------------------------------
w.add_stmt(WStmt(blk_no=b_prog, srn=b'S0001 ',
                 stmt_type=STTYPE_ASSIGN, is_exec=True,  num_lhs=1, num_labls=0))
w.add_stmt(WStmt(blk_no=b_prog, srn=b'S0002 ',
                 stmt_type=STTYPE_ASSIGN, is_exec=True,  num_lhs=1, num_labls=1))
w.add_stmt(WStmt(blk_no=b_prog, srn=b'S0003 ',
                 stmt_type=STTYPE_IF,     is_exec=True,  num_lhs=0, num_labls=0))
w.add_stmt(WStmt(blk_no=b_prog, srn=b'S0004 ',
                 stmt_type=0,             is_exec=False, num_lhs=0, num_labls=0))

# ---------------------------------------------------------------------------
# Commit  (sorts, builds trees, lays out pages, writes file)
# ---------------------------------------------------------------------------
w.commit()

# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------
from sdfpkg import SdfContext, flat_info

info = flat_info(OUTPUT)
mem  = info[0]
print(f'Written {OUTPUT}')
print(f'  Member:     {mem["name"]}')
print(f'  Pages:      {mem["page_count"]}')

ctx = SdfContext.open(OUTPUT)
ctx.select('NAVCOMP')
root = ctx.locate_root()
import struct as _struct
blk_nodes = _struct.unpack_from('>H', root, 16)[0]
sym_nodes = _struct.unpack_from('>H', root, 18)[0]
fstmt     = _struct.unpack_from('>H', root, 52)[0]
lstm      = _struct.unpack_from('>H', root, 54)[0]
print(f'  Blocks:     {blk_nodes}')
print(f'  Symbols:    {sym_nodes}')
print(f'  Statements: {fstmt}..{lstm}')
print()

from sdfpkg import (SCLASS_TEMPLATE as _TMPL, STYPE_STRUCTURE as _STRUC,
                    SCLASS_LABEL as _LABEL, STYPE_IORS as _IORS,
                    STYPE_TASK_LABEL as _TASK_LABEL)

SYM_TYPE = {1:'BIT', 2:'CHARACTER', 3:'MATRIX', 4:'VECTOR', 5:'SCALAR',
            6:'INTEGER', 8:'IORS', 9:'EVENT', 10:'STRUCTURE', 11:'ANY',
            0x3E:'TEMPL_NAME', 0x42:'STMT_LABEL', 0x43:'UNSPEC_LABEL',
            0x45:'IND_CALL_LAB', 0x46:'CALLED_LABEL', 0x47:'PROC_LABEL',
            0x48:'TASK_LABEL', 0x49:'PROG_LABEL', 0x4A:'COMPOOL_LABEL',
            0x4B:'EQUATE_LABEL'}
BLK_CLASS = {1:'PROCEDURE', 2:'FUNCTION', 3:'COMPOOL',
             4:'PROGRAM', 5:'TASK', 6:'UPDATE', 7:'INLINE'}
for bn in range(1, blk_nodes + 1):
    blk = ctx.find_block_by_number(bn)
    sr  = f'{blk.fsymb_no}..{blk.lsymb_no}' if blk.fsymb_no else '—'
    cls = BLK_CLASS.get(blk.blk_class, str(blk.blk_class))
    print(f'  Block {blk.blk_no}: {blk.blk_name:<16} {cls:<22} symbols={sr}')
    for sn in range(blk.fsymb_no, blk.lsymb_no + 1):
        sym = ctx.find_symbol_by_number(sn)
        extra = ''
        if sym.sym_class == _TMPL and sym.sym_type == _STRUC:
            extra = f' rows(self)={sym.rows}'
            if sym.copy_blk_no:
                src = ctx.find_block_by_number(sym.copy_blk_no)
                extra += f' copy_blk_no={sym.copy_blk_no}({src.blk_name})'
        elif sym.sym_class == _LABEL and sym.sym_type == _IORS:
            extra = ' EQUATE_EXT'
        elif sym.sym_class == _LABEL:
            extra = f' NAME({SYM_TYPE.get(sym.sym_type, sym.sym_type)})'
        elif sym.sym_type == _TASK_LABEL:
            extra = ' TASK-entry'
        print(f'    {sn:>3}: {sym.symb_name}{extra}')

ctx.close()
