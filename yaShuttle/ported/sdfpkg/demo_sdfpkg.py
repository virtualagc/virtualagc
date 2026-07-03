#!/usr/bin/env python3
"""
demo_sdfpkg.py  --  Demonstration of the sdfpkg.py API.

Shows both the write (creation) and read (access) paths, including
HAL/S STRUCTURE variables.

  Part 1 -- Write: create a new SDF flat file member from scratch.
  Part 2 -- Read:  open the file and extract all blocks, symbols,
            and statements, with special handling for STRUCTURE types.

Usage:
  ./demo_sdfpkg.py [options] [file.sdf [member]]

Options:
  --help          Show this message and exit.
  --add-member    Add a new member to file.sdf (creating it if absent).
                  If the member already exists it is overwritten.
  --suffix        (With --add-member) append a numeric index suffix to
                  every object name inside the new member.  Suffix equals
                  the 1-based position the member occupies in the file
                  after writing (position 1 → no suffix, 2 → "2", etc.).
                  The member name itself is never suffixed.
  --json FILE     Define the new member's content from a JSON spec file
                  instead of the built-in NAVCOMP example.  See
                  sdf-json-format.md for the schema.  The member name may
                  be supplied by the JSON file's "member" field, overridden
                  by the command-line member argument.
  --delete-member Remove the named member from file.sdf and exit.
                  The member name is taken from the command-line member
                  argument (default NAVCOMP).  The file must exist.
  --extract-json OUT
                  Read the named member from file.sdf and write a JSON
                  spec (compatible with --json) to OUT.  Use "-" for OUT
                  to write to stdout.  The member name is taken from the
                  command-line member argument (default NAVCOMP).

If file.sdf is omitted a temporary file is created and deleted on exit.
If a supplied file already exists and --add-member is NOT given, Part 1
is skipped and only Part 2 (read) is executed.

When --json is given the read phase uses a generic reader that
dynamically drills into all STRUCTURE template and TASK blocks rather
than the hardcoded NAVCOMP probes.
"""

import sys
import os
import json as _json_mod
import struct
import tempfile

from sdfpkg import (
    SdfContext, SdfWriter, SdfError,
    WBlock, WSymbol, WStmt,
    BCLASS_PROGRAM, BCLASS_FUNCTION, BCLASS_PROCEDURE,
    BCLASS_TASK, BCLASS_COMPOOL, BCLASS_CLOSE,
    SCLASS_VARIABLE, SCLASS_EQUATE_EXT, SCLASS_TEMPLATE,
    SCLASS_LABEL, SCLASS_COMPOOL,
    STYPE_SCALAR, STYPE_INTEGER, STYPE_BOOLEAN, STYPE_CHARACTER,
    STYPE_BIT, STYPE_VECTOR, STYPE_MATRIX, STYPE_EQUATE_EXT,
    STYPE_EVENT, STYPE_STRUCTURE, STYPE_TASK,
    STTYPE_ASSIGN, STTYPE_IF, STTYPE_DO, STTYPE_DO_WHILE,
    STTYPE_DO_UNTIL, STTYPE_DO_FOR, STTYPE_END, STTYPE_RETURN,
    STTYPE_CALL, STTYPE_GOTO, STTYPE_ON_ERROR,
    WFLAG_NONE, WFLAG_HAS_SRNS, WFLAG_NONMONO,
    RC_NOT_EXEC, DISP_NONE,
    flat_info, delete_member,
)

# ---------------------------------------------------------------------------
# Label tables
# ---------------------------------------------------------------------------

BLK_CLASS = {
    1: 'PROGRAM',    2: 'FUNCTION',   3: 'STRUCTURE template',
    4: 'TASK',       5: 'COMPOOL',    6: 'CLOSE BLOCK',
}
SYM_CLASS = {
    1: 'variable',   2: 'equate-ext', 3: 'template header',
    4: 'label',      6: 'compool',
}
SYM_TYPE = {
    1: 'SCALAR',     2: 'INTEGER',    3: 'BOOLEAN',
    4: 'CHARACTER',  5: 'BIT',        6: 'VECTOR',
    7: 'MATRIX',     8: 'equate-ext', 9: 'EVENT',
    10: 'STRUCTURE', 11: 'TASK',
}
STMT_TYPE = {
    1: 'ASSIGNMENT', 2: 'IF',        3: 'DO',
    4: 'DO WHILE',   5: 'DO UNTIL',  6: 'DO FOR',
    7: 'END',        8: 'RETURN',    9: 'CALL',
    10: 'GOTO',     11: 'ON ERROR',
}

# JSON name → sdfpkg constant mappings used by demo_write_from_json
_BLK_CLASS_MAP = {
    'PROGRAM':   BCLASS_PROGRAM,   'FUNCTION':  BCLASS_FUNCTION,
    'PROCEDURE': BCLASS_PROCEDURE, 'TASK':      BCLASS_TASK,
    'COMPOOL':   BCLASS_COMPOOL,   'CLOSE':     BCLASS_CLOSE,
}
_SYM_CLASS_MAP = {
    'VARIABLE':   SCLASS_VARIABLE,   'EQUATE_EXT': SCLASS_EQUATE_EXT,
    'TEMPLATE':   SCLASS_TEMPLATE,   'LABEL':      SCLASS_LABEL,
    'COMPOOL':    SCLASS_COMPOOL,
}
_SYM_TYPE_MAP = {
    'SCALAR':     STYPE_SCALAR,   'INTEGER':   STYPE_INTEGER,
    'BOOLEAN':    STYPE_BOOLEAN,  'CHARACTER': STYPE_CHARACTER,
    'BIT':        STYPE_BIT,      'VECTOR':    STYPE_VECTOR,
    'MATRIX':     STYPE_MATRIX,   'EQUATE_EXT':STYPE_EQUATE_EXT,
    'EVENT':      STYPE_EVENT,    'STRUCTURE': STYPE_STRUCTURE,
    'TASK':       STYPE_TASK,
}
_STMT_TYPE_MAP = {
    'ASSIGN':   STTYPE_ASSIGN,   'IF':       STTYPE_IF,
    'DO':       STTYPE_DO,       'DO_WHILE': STTYPE_DO_WHILE,
    'DO_UNTIL': STTYPE_DO_UNTIL, 'DO_FOR':   STTYPE_DO_FOR,
    'END':      STTYPE_END,      'RETURN':   STTYPE_RETURN,
    'CALL':     STTYPE_CALL,     'GOTO':     STTYPE_GOTO,
    'ON_ERROR': STTYPE_ON_ERROR,
}


def sym_type_detail(sym, template_map=None):
    """
    Return a descriptive type string including dimensions and, for
    STRUCTURE instance variables, the name of the template type.
    ARRAY variables are prefixed with ARRAY(d1) or ARRAY(d1,d2).
    NAME variables show the type of their referent.

    template_map: optional dict mapping symb_no -> template name,
                  used to resolve STRUCTURE instances.
    """
    array_prefix = ''
    if hasattr(sym, 'array_dims') and sym.array_dims[0] > 0:
        ndims = sym.array_dims[0]
        dims  = sym.array_dims[1:1+ndims]
        array_prefix = 'ARRAY(' + ','.join(str(d) for d in dims) + ') '

    if sym.sym_class == SCLASS_LABEL:
        referent = SYM_TYPE.get(sym.sym_type, f'type={sym.sym_type}')
        return f'NAME({referent})'

    if sym.sym_class == SCLASS_EQUATE_EXT and sym.sym_type == STYPE_EQUATE_EXT:
        return 'EQUATE EXT'

    t = sym.sym_type
    if t == STYPE_VECTOR:
        return array_prefix + (f'VECTOR({sym.rows})' if sym.rows else 'VECTOR')
    if t == STYPE_MATRIX:
        if sym.rows and sym.columns:
            return array_prefix + f'MATRIX({sym.rows},{sym.columns})'
        return array_prefix + 'MATRIX'
    if t == STYPE_CHARACTER:
        return array_prefix + (f'CHARACTER({sym.columns})' if sym.columns else 'CHARACTER')
    if t == STYPE_BIT:
        return array_prefix + (f'BIT({sym.rows})' if sym.rows else 'BIT')
    if t == STYPE_EVENT:
        return 'EVENT'
    if t == STYPE_TASK:
        return 'TASK'
    if t == STYPE_STRUCTURE:
        if template_map and sym.rows in template_map:
            return f'STRUCTURE ({template_map[sym.rows]})'
        elif sym.rows:
            return f'STRUCTURE (template symb#{sym.rows})'
        return 'STRUCTURE'
    return array_prefix + SYM_TYPE.get(t, f'type={t}')


# ---------------------------------------------------------------------------
# Part 1 -- Write (hardcoded NAVCOMP example)
# ---------------------------------------------------------------------------

def demo_write(sdf_path, member='NAVCOMP', suffix='', append=False):
    print('=' * 62)
    print('Part 1 -- Write: creating SDF member with STRUCTURE + COPY')
    print('=' * 62)
    print(f'  Output file : {sdf_path}')
    print(f'  Member name : {member}')
    if suffix:
        print(f'  Name suffix : {suffix!r}')
    print()

    def n(base):
        return base + suffix

    print('Step W1: create write context')
    if append:
        w = SdfWriter.add_member(sdf_path, member, flags=WFLAG_HAS_SRNS)
    else:
        w = SdfWriter.create(sdf_path, member, flags=WFLAG_HAS_SRNS)

    print('Step W2: add blocks')
    blk1 = w.add_block(WBlock(
        csect_name = n('NAVSECT'),
        blk_name   = n('NAVCOMP'),
        blk_class  = BCLASS_PROGRAM,
        blk_id     = 1,
    ))
    print(f'  Block {blk1}: {n("NAVCOMP")} (PROGRAM)')

    blk2 = w.add_block(WBlock(
        csect_name = n('STRCSECT'),
        blk_name   = n('SENSOR_DATA'),
        blk_class  = BCLASS_PROCEDURE,
        blk_id     = 2,
    ))
    print(f'  Block {blk2}: {n("SENSOR_DATA")} (STRUCTURE template, base)')

    blk3 = w.add_block(WBlock(
        csect_name = n('STRCSECT'),
        blk_name   = n('EXT_SENSOR'),
        blk_class  = BCLASS_PROCEDURE,
        blk_id     = 3,
    ))
    print(f'  Block {blk3}: {n("EXT_SENSOR")} (STRUCTURE template, COPYs {n("SENSOR_DATA")})')

    blk4 = w.add_block(WBlock(
        csect_name = n('NAVSECT'),
        blk_name   = n('BURN_TASK'),
        blk_class  = BCLASS_TASK,
        blk_id     = 4,
    ))
    print(f'  Block {blk4}: {n("BURN_TASK")} (TASK)')
    print()

    print(f'Step W3: add {n("SENSOR_DATA")} template symbols (block {blk2})')
    templ_hdr_no = w.add_symbol(WSymbol(
        blk_no    = blk2,
        symb_name = n('SENSOR_DATA'),
        sym_class = SCLASS_TEMPLATE,
        sym_type  = STYPE_STRUCTURE,
    ))
    print(f'  Symbol {templ_hdr_no}: {n("SENSOR_DATA")} (template header, no COPY)')

    mem_alt = w.add_symbol(WSymbol(
        blk_no    = blk2,
        symb_name = n('ALT_READING'),
        sym_class = SCLASS_VARIABLE,
        sym_type  = STYPE_SCALAR,
    ))
    print(f'  Symbol {mem_alt}: {n("ALT_READING")}  SCALAR')

    mem_stat = w.add_symbol(WSymbol(
        blk_no    = blk2,
        symb_name = n('STATUS_CODE'),
        sym_class = SCLASS_VARIABLE,
        sym_type  = STYPE_INTEGER,
    ))
    print(f'  Symbol {mem_stat}: {n("STATUS_CODE")}  INTEGER')

    mem_vel = w.add_symbol(WSymbol(
        blk_no    = blk2,
        symb_name = n('VEL_READING'),
        sym_class = SCLASS_VARIABLE,
        sym_type  = STYPE_VECTOR,
        rows      = 3,
    ))
    print(f'  Symbol {mem_vel}: {n("VEL_READING")}  VECTOR(3)')
    print()

    print(f'Step W3b: add {n("EXT_SENSOR")} template symbols (block {blk3}, COPYs {n("SENSOR_DATA")})')
    ext_hdr_no = w.add_symbol(WSymbol(
        blk_no      = blk3,
        symb_name   = n('EXT_SENSOR'),
        sym_class   = SCLASS_TEMPLATE,
        sym_type    = STYPE_STRUCTURE,
        copy_blk_no = blk2,
    ))
    print(f'  Symbol {ext_hdr_no}: {n("EXT_SENSOR")} (template header, copy_blk_no={blk2})')

    mem_range = w.add_symbol(WSymbol(
        blk_no    = blk3,
        symb_name = n('RANGE_KM'),
        sym_class = SCLASS_VARIABLE,
        sym_type  = STYPE_SCALAR,
    ))
    print(f'  Symbol {mem_range}: {n("RANGE_KM")}  SCALAR  (own member of {n("EXT_SENSOR")})')
    print()

    print(f'Step W4: add program symbols (block {blk1}: {n("NAVCOMP")})')
    prog_syms = [
        ('ALTITUDE',       STYPE_SCALAR,    0,  0, (0,0,0,0)),
        ('ARMED',          STYPE_BOOLEAN,   0,  0, (0,0,0,0)),
        ('BITS',           STYPE_BIT,      16,  0, (0,0,0,0)),
        ('COUNT',          STYPE_INTEGER,   0,  0, (0,0,0,0)),
        ('INERTIA',        STYPE_MATRIX,    3,  3, (0,0,0,0)),
        ('LAUNCH_ENABLE',  STYPE_EVENT,     0,  0, (0,0,0,0)),
        ('LONGSYMBOLNAME', STYPE_SCALAR,    0,  0, (0,0,0,0)),
        ('MESSAGE',        STYPE_CHARACTER, 0, 20, (0,0,0,0)),
        ('READINGS',       STYPE_SCALAR,    0,  0, (1,10,0,0)),
        ('TABLE',          STYPE_INTEGER,   0,  0, (2, 3,4,0)),
        ('VELOCITY',       STYPE_VECTOR,    3,  0, (0,0,0,0)),
    ]
    for name, typ, rows, cols, adims in prog_syms:
        sno = w.add_symbol(WSymbol(
            blk_no     = blk1,
            symb_name  = n(name),
            sym_class  = SCLASS_VARIABLE,
            sym_type   = typ,
            rows       = rows,
            columns    = cols,
            array_dims = adims,
        ))
        base_type = SYM_TYPE.get(typ, str(typ))
        if adims[0]:
            dims_str = ','.join(str(d) for d in adims[1:1+adims[0]])
            type_str = f'ARRAY({dims_str}) {base_type}'
        else:
            type_str = base_type
        print(f'  Symbol {sno}: {n(name):<18} {type_str}')

    sensor_no = w.add_symbol(WSymbol(
        blk_no    = blk1,
        symb_name = n('SENSOR'),
        sym_class = SCLASS_VARIABLE,
        sym_type  = STYPE_STRUCTURE,
        rows      = 0,
    ))
    print(f'  Symbol {sensor_no}: {n("SENSOR"):<18} STRUCTURE instance (rows=TBD)')

    name_no = w.add_symbol(WSymbol(
        blk_no    = blk1,
        symb_name = n('ALT_PTR'),
        sym_class = SCLASS_LABEL,
        sym_type  = STYPE_SCALAR,
    ))
    print(f'  Symbol {name_no}: {n("ALT_PTR"):<18} NAME(SCALAR)  (sym_class=LABEL)')

    eq_no = w.add_symbol(WSymbol(
        blk_no    = blk1,
        symb_name = n('EXT_CONST'),
        sym_class = SCLASS_EQUATE_EXT,
        sym_type  = STYPE_EQUATE_EXT,
    ))
    print(f'  Symbol {eq_no}: {n("EXT_CONST"):<18} EQUATE EXT  (sym_class=2, sym_type=8)')
    print()

    print(f'Step W4b: add {n("BURN_TASK")} symbols (block {blk4}: TASK)')
    task_sym_no = w.add_symbol(WSymbol(
        blk_no    = blk4,
        symb_name = n('BURN_TASK'),
        sym_class = SCLASS_VARIABLE,
        sym_type  = STYPE_TASK,
    ))
    print(f'  Symbol {task_sym_no}: {n("BURN_TASK"):<18} TASK  (entry-point symbol)')
    task_local_no = w.add_symbol(WSymbol(
        blk_no    = blk4,
        symb_name = n('THRUST_LEVEL'),
        sym_class = SCLASS_VARIABLE,
        sym_type  = STYPE_SCALAR,
    ))
    print(f'  Symbol {task_local_no}: {n("THRUST_LEVEL"):<18} SCALAR  (TASK local variable)')
    print()

    print('Step W5: add statements')
    stmts = [
        (b'S0001 ', STTYPE_ASSIGN, True,  1, 0),
        (b'S0002 ', STTYPE_ASSIGN, True,  1, 1),
        (b'S0003 ', STTYPE_IF,     True,  0, 0),
        (b'S0004 ', 0,             False, 0, 0),
    ]
    for srn, typ, is_exec, lhs, labls in stmts:
        sno = w.add_stmt(WStmt(
            blk_no    = blk1,
            srn       = srn,
            stmt_type = typ,
            is_exec   = is_exec,
            num_lhs   = lhs,
            num_labls = labls,
        ))
        tag = 'exec' if is_exec else 'non-exec'
        print(f'  Stmt {sno}: {srn.rstrip(b" ").decode()}  ({tag})')
    print()

    print('Step W6: commit')
    w.commit()
    print(f'  File written: {sdf_path}')
    print()


# ---------------------------------------------------------------------------
# Part 1 -- Write (JSON-driven)
# ---------------------------------------------------------------------------

def demo_write_from_json(sdf_path, spec, json_display='',
                         member_name=None, suffix='', append=False):
    """
    Write an SDF member whose content is described by a parsed JSON spec dict.
    See sdf-json-format.md for the schema.

    spec is the already-parsed dict (not a file path).
    json_display is the source path shown in the header (cosmetic only).
    member_name overrides the JSON "member" field; None means use JSON or default.
    suffix is appended to every object name (blocks, symbols, csects).
    """
    # Resolve member name: CLI > JSON > default
    if member_name is None:
        member_name = spec.get('member', 'MEMBER1')

    # Parse write flags
    flags = WFLAG_NONE
    for flag_str in spec.get('flags', ['HAS_SRNS']):
        flags |= {'HAS_SRNS': WFLAG_HAS_SRNS, 'NONMONO': WFLAG_NONMONO}.get(
            flag_str.upper(), 0)

    print('=' * 62)
    print('Part 1 -- Write (from JSON): creating SDF member')
    print('=' * 62)
    if json_display:
        print(f'  JSON spec   : {json_display}')
    print(f'  Output file : {sdf_path}')
    print(f'  Member name : {member_name}')
    if suffix:
        print(f'  Name suffix : {suffix!r}')
    print()

    def n(base):
        return base + suffix

    print('Step W1: create write context')
    if append:
        w = SdfWriter.add_member(sdf_path, member_name, flags=flags)
    else:
        w = SdfWriter.create(sdf_path, member_name, flags=flags)

    # Pass 1: add all blocks; build id→blk_no map for cross-referencing
    print('Step W2: add blocks')
    block_specs = spec.get('blocks', [])
    blk_id_to_no = {}   # JSON local id → actual blk_no
    for blk_spec in block_specs:
        raw_class = blk_spec.get('blk_class', 'PROGRAM').upper()
        blk_class = _BLK_CLASS_MAP.get(raw_class, BCLASS_PROGRAM)
        blk_name  = blk_spec.get('blk_name', '')
        local_id  = blk_spec.get('id', blk_name)

        blk_no = w.add_block(WBlock(
            csect_name = n(blk_spec.get('csect_name', '')),
            blk_name   = n(blk_name),
            blk_class  = blk_class,
            blk_id     = blk_spec.get('blk_id', 1),
            blk_type   = blk_spec.get('blk_type', 0),
            blk_flags  = blk_spec.get('blk_flags', 0),
        ))
        blk_id_to_no[local_id] = blk_no
        cls_label = BLK_CLASS.get(blk_class, f'class={blk_class}')
        print(f'  Block {blk_no}: {n(blk_name)} ({cls_label})')
    print()

    # Pass 2: add symbols and statements for each block
    for blk_spec in block_specs:
        blk_name = blk_spec.get('blk_name', '')
        local_id = blk_spec.get('id', blk_name)
        blk_no   = blk_id_to_no[local_id]

        sym_list  = blk_spec.get('symbols', [])
        stmt_list = blk_spec.get('statements', [])
        if not sym_list and not stmt_list:
            continue

        print(f'  Symbols / statements for block {blk_no} ({n(blk_name)}):')

        for sym_spec in sym_list:
            sym_name  = n(sym_spec.get('name', ''))
            class_str = sym_spec.get('class', 'VARIABLE').upper()
            type_str  = sym_spec.get('type',  'SCALAR').upper()

            # Defaults for class
            if class_str == 'EQUATE_EXT':
                sym_class        = SCLASS_EQUATE_EXT
                default_sym_type = STYPE_EQUATE_EXT
            elif class_str == 'TEMPLATE':
                sym_class        = SCLASS_TEMPLATE
                default_sym_type = STYPE_STRUCTURE
            elif class_str == 'LABEL':
                sym_class        = SCLASS_LABEL
                default_sym_type = STYPE_SCALAR
            elif class_str == 'COMPOOL':
                sym_class        = SCLASS_COMPOOL
                default_sym_type = STYPE_SCALAR
            else:
                sym_class        = SCLASS_VARIABLE
                default_sym_type = STYPE_SCALAR

            sym_type = _SYM_TYPE_MAP.get(type_str, default_sym_type)

            rows    = sym_spec.get('rows',    0)
            columns = sym_spec.get('columns', 0)

            # array: null/omitted → (0,0,0,0); [d1] → (1,d1,0,0); etc.
            raw_array = sym_spec.get('array', None)
            if raw_array:
                nd  = min(len(raw_array), 3)
                pad = (raw_array + [0, 0, 0])[:3]
                array_dims = (nd, pad[0], pad[1], pad[2])
            else:
                array_dims = (0, 0, 0, 0)

            # copy_block: STRUCTURE template COPY link → block number
            copy_blk_no = 0
            cb_id = sym_spec.get('copy_block', None)
            if cb_id is not None:
                if cb_id in blk_id_to_no:
                    copy_blk_no = blk_id_to_no[cb_id]
                else:
                    print(f'    WARNING: copy_block id {cb_id!r} not found; '
                          f'copy_blk_no will be 0')

            sno = w.add_symbol(WSymbol(
                blk_no      = blk_no,
                symb_name   = sym_name,
                sym_class   = sym_class,
                sym_type    = sym_type,
                rows        = rows,
                columns     = columns,
                flag1       = sym_spec.get('flag1', 0),
                flag2       = sym_spec.get('flag2', 0),
                flag3       = sym_spec.get('flag3', 0),
                flag4       = sym_spec.get('flag4', 0),
                rel_addr    = sym_spec.get('rel_addr', 0),
                lock_num    = sym_spec.get('lock_num', 0),
                byte_size   = sym_spec.get('byte_size', 0),
                array_dims  = array_dims,
                copy_blk_no = copy_blk_no,
            ))

            # Build a readable type label for the printout
            if sym_type == STYPE_VECTOR and rows:
                type_label = f'VECTOR({rows})'
            elif sym_type == STYPE_MATRIX and rows and columns:
                type_label = f'MATRIX({rows},{columns})'
            elif sym_type == STYPE_CHARACTER and columns:
                type_label = f'CHARACTER({columns})'
            elif sym_type == STYPE_BIT and rows:
                type_label = f'BIT({rows})'
            else:
                type_label = type_str
            if raw_array:
                dims_str = ','.join(str(d) for d in raw_array)
                type_label = f'ARRAY({dims_str}) {type_label}'
            if copy_blk_no:
                type_label += f' [COPY blk#{copy_blk_no}]'
            print(f'    Symbol {sno}: {sym_name:<20} {type_label}')

        for stmt_spec in stmt_list:
            srn_str  = stmt_spec.get('srn', '')
            srn_b    = srn_str.encode('ascii', errors='replace')[:6].ljust(6)
            raw_type = stmt_spec.get('type', 'ASSIGN').upper()
            stmt_type = _STMT_TYPE_MAP.get(raw_type, STTYPE_ASSIGN)
            is_exec   = stmt_spec.get('exec', True)

            sno = w.add_stmt(WStmt(
                blk_no    = blk_no,
                srn       = srn_b,
                stmt_type = stmt_type,
                is_exec   = is_exec,
                num_lhs   = stmt_spec.get('lhs', 0),
                num_labls = stmt_spec.get('labels', 0),
            ))
            tag = 'exec' if is_exec else 'non-exec'
            print(f'    Stmt  {sno}: {srn_str:<8} ({tag})')

        print()

    print('Step: commit')
    w.commit()
    print(f'  File written: {sdf_path}')
    print()


# ---------------------------------------------------------------------------
# Part 2 -- Read (hardcoded NAVCOMP paths)
# ---------------------------------------------------------------------------

def demo_read(sdf_path, member='NAVCOMP', suffix=''):
    print('=' * 62)
    print('Part 2 -- Read: accessing SDF member')
    print('=' * 62)
    print(f'  Input file  : {sdf_path}')
    print(f'  Member name : {member}')
    print()

    ctx = SdfContext.open(sdf_path, npages=4)
    ctx.select(member)

    def n(base):
        return base + suffix

    # ------------------------------------------------------------------
    # Step R1: Root cell
    # ------------------------------------------------------------------
    print('Step R1: directory root cell')
    root      = ctx.locate_root()
    blk_nodes = struct.unpack_from('>H', root, 16)[0]
    sym_nodes = struct.unpack_from('>H', root, 18)[0]
    fstmt     = struct.unpack_from('>H', root, 52)[0]
    lstm      = struct.unpack_from('>H', root, 54)[0]
    sdf_flags = (root[0] << 8) | root[1]
    print(f'  Blocks: {blk_nodes}   Symbols: {sym_nodes}   '
          f'Stmts: {fstmt}..{lstm}   HAS_SRNS: {bool(sdf_flags & 0x8000)}')
    print()

    # ------------------------------------------------------------------
    # Step R2: Enumerate blocks
    # ------------------------------------------------------------------
    print('Step R2: blocks')
    print(f'  {"#":>3}  {"CSECT":<10}  {"CLASS":<22}  {"NAME":<16}  '
          f'{"SYMBS":>7}  {"STMTS":>7}')
    print(f'  {"-"*3}  {"-"*10}  {"-"*22}  {"-"*16}  {"-"*7}  {"-"*7}')
    structure_blocks = set()
    for blk_no in range(1, blk_nodes + 1):
        blk = ctx.find_block_by_number(blk_no)
        cls = BLK_CLASS.get(blk.blk_class, f'class={blk.blk_class}')
        if blk.blk_class == 3:
            structure_blocks.add(blk_no)
        sr  = (f'{blk.fsymb_no}..{blk.lsymb_no}' if blk.fsymb_no else '—')
        tr  = (f'{blk.fstmt_no}..{blk.lstm_no}'  if blk.fstmt_no else '—')
        tag = '  ← STRUCTURE template' if blk.blk_class == 3 else ''
        print(f'  {blk.blk_no:>3}  {blk.csect_name:<10}  {cls:<22}  '
              f'{blk.blk_name:<16}  {sr:>7}  {tr:>7}{tag}')
    print()

    # ------------------------------------------------------------------
    # Step R3: Build template map
    # ------------------------------------------------------------------
    template_map = {}
    copy_map     = {}
    for sno in range(1, sym_nodes + 1):
        sym = ctx.find_symbol_by_number(sno)
        if sym.sym_class == 3 and sym.sym_type == 10:
            template_map[sno] = sym.symb_name
            copy_map[sym.blk_no] = sym.copy_blk_no

    # ------------------------------------------------------------------
    # Step R4: Enumerate symbols
    # ------------------------------------------------------------------
    print('Step R4: symbols')
    print(f'  {"#":>3}  {"NAME":<18}  {"CLASS":<16}  {"TYPE":<28}  BLK  NOTE')
    print(f'  {"-"*3}  {"-"*18}  {"-"*16}  {"-"*28}  {"-"*3}  {"-"*30}')
    for sno in range(1, sym_nodes + 1):
        sym  = ctx.find_symbol_by_number(sno)
        cls  = SYM_CLASS.get(sym.sym_class, f'class={sym.sym_class}')
        typ  = sym_type_detail(sym, template_map)
        note = ''
        if sym.sym_class == 3 and sym.sym_type == 10:
            if sym.copy_blk_no:
                try:
                    src_blk = ctx.find_block_by_number(sym.copy_blk_no)
                    note = f'← template hdr, COPY {src_blk.blk_name}'
                except SdfError:
                    note = f'← template hdr, COPY blk#{sym.copy_blk_no}'
            else:
                note = '← template header'
        elif sym.sym_type == 10 and sym.sym_class == 1:
            tmpl_name = template_map.get(sym.rows, f'symb#{sym.rows}')
            note = f'instance of {tmpl_name}'
        elif sym.sym_class == 1 and sym.blk_no in structure_blocks:
            note = '← structure member'
        elif sym.sym_class == SCLASS_LABEL:
            note = '← NAME variable'
        elif sym.sym_class == SCLASS_EQUATE_EXT:
            note = '← equate-ext (compiler-internal)'
        elif sym.sym_type == STYPE_TASK:
            note = '← task entry-point'
        print(f'  {sym.symb_no:>3}  {sym.symb_name:<18}  {cls:<16}  '
              f'{typ:<28}  {sym.blk_no:>3}  {note}')
    print()

    # ------------------------------------------------------------------
    # Step R5: Drill into SENSOR_DATA template block
    # ------------------------------------------------------------------
    print(f'Step R5: find {n("SENSOR_DATA")} template block by name')
    try:
        blk = ctx.find_block_by_name(n('SENSOR_DATA'))
        copy_tag = ''
        cb = copy_map.get(blk.blk_no, 0)
        if cb:
            try:
                src = ctx.find_block_by_number(cb)
                copy_tag = f'  COPYs: {src.blk_name}'
            except SdfError:
                copy_tag = f'  COPYs: blk#{cb}'
        print(f'  Block found: #{blk.blk_no} {blk.blk_name}  '
              f'class={BLK_CLASS.get(blk.blk_class, blk.blk_class)}{copy_tag}')
        print(f'  Member symbol range: {blk.fsymb_no}..{blk.lsymb_no}')
        print(f'  Members:')
        for sno in range(blk.fsymb_no, blk.lsymb_no + 1):
            sym = ctx.find_symbol_by_number(sno)
            typ = sym_type_detail(sym, template_map)
            role = ('template header' if sym.sym_class == 3 else 'member')
            print(f'    {sym.symb_no:>3}  {sym.symb_name:<16}  {typ:<16}  ({role})')
    except SdfError as e:
        print(f'  Not found: {e}')
    print()

    # ------------------------------------------------------------------
    # Step R5b: Drill into EXT_SENSOR template block
    # ------------------------------------------------------------------
    print(f'Step R5b: find {n("EXT_SENSOR")} template block by name (COPY demo)')
    try:
        blk = ctx.find_block_by_name(n('EXT_SENSOR'))
        cb = copy_map.get(blk.blk_no, 0)
        copy_tag = ''
        if cb:
            try:
                src = ctx.find_block_by_number(cb)
                copy_tag = f'  COPYs: {src.blk_name} (blk#{cb})'
            except SdfError:
                copy_tag = f'  COPYs: blk#{cb}'
        print(f'  Block found: #{blk.blk_no} {blk.blk_name}  '
              f'class={BLK_CLASS.get(blk.blk_class, blk.blk_class)}{copy_tag}')
        print(f'  Member symbol range: {blk.fsymb_no}..{blk.lsymb_no}')
        print(f'  Own members (COPYed members live in the source block):')
        for sno in range(blk.fsymb_no, blk.lsymb_no + 1):
            sym = ctx.find_symbol_by_number(sno)
            typ = sym_type_detail(sym, template_map)
            if sym.sym_class == 3:
                role = f'template hdr (copy_blk_no={sym.copy_blk_no})'
            else:
                role = 'own member'
            print(f'    {sym.symb_no:>3}  {sym.symb_name:<16}  {typ:<16}  ({role})')
    except SdfError as e:
        print(f'  Not found (file may have been written without {n("EXT_SENSOR")}): {e}')
    print()

    # ------------------------------------------------------------------
    # Step R5c: Drill into BURN_TASK block
    # ------------------------------------------------------------------
    print(f'Step R5c: find {n("BURN_TASK")} block by name (TASK block demo)')
    try:
        blk = ctx.find_block_by_name(n('BURN_TASK'))
        print(f'  Block found: #{blk.blk_no} {blk.blk_name}  '
              f'class={BLK_CLASS.get(blk.blk_class, blk.blk_class)}')
        print(f'  Symbol range: {blk.fsymb_no}..{blk.lsymb_no}')
        for sno in range(blk.fsymb_no, blk.lsymb_no + 1):
            sym = ctx.find_symbol_by_number(sno)
            typ = sym_type_detail(sym, template_map)
            role = 'task entry-point' if sym.sym_type == STYPE_TASK else 'local'
            print(f'    {sym.symb_no:>3}  {sym.symb_name:<16}  {typ:<12}  ({role})')
    except SdfError as e:
        print(f'  Not found: {e}')
    print()

    # ------------------------------------------------------------------
    # Step R6: Find STRUCTURE instance variable by name
    # ------------------------------------------------------------------
    print(f'Step R6: find STRUCTURE instance variable {n("SENSOR")}')
    ctx.find_block_by_number(1)
    try:
        sym = ctx.find_symbol_by_name(n('SENSOR'))
        typ = sym_type_detail(sym, template_map)
        print(f'  Found: symb_no={sym.symb_no}  type={typ}')
        if sym.rows:
            tmpl = template_map.get(sym.rows, f'symb#{sym.rows}')
            print(f'  Template: {tmpl} (template symb_no={sym.rows})')
    except SdfError as e:
        print(f'  Not found: {e}')
    print()

    # ------------------------------------------------------------------
    # Step R7: Statements
    # ------------------------------------------------------------------
    print('Step R7: statements')
    print(f'  {"#":>3}  {"SRN":<8}  {"TYPE":<14}  {"EXEC":>4}  '
          f'{"LABLS":>5}  {"LHS":>3}  BLK')
    print(f'  {"-"*3}  {"-"*8}  {"-"*14}  {"-"*4}  {"-"*5}  {"-"*3}  {"-"*3}')
    for stmt_no in range(fstmt, lstm + 1):
        try:
            stmt = ctx.find_stmt_by_number(stmt_no)
            srn  = stmt.srn.rstrip(b' ').decode() if stmt.srn else ''
            typ  = STMT_TYPE.get(stmt.stmt_type, str(stmt.stmt_type))
            print(f'  {stmt.stmt_no:>3}  {srn:<8}  {typ:<14}  {"yes":>4}  '
                  f'{stmt.num_labls:>5}  {stmt.num_lhs:>3}  {stmt.blk_no}')
        except SdfError as e:
            if e.code == RC_NOT_EXEC:
                node = ctx.find_stmt_node_by_number(stmt_no)
                srn  = node.srn.rstrip(b' ').decode() if node.srn else ''
                print(f'  {stmt_no:>3}  {srn:<8}  {"(non-exec)":<14}  '
                      f'{"no":>4}  {"—":>5}  {"—":>3}  —')
            else:
                print(f'  {stmt_no:>3}  error: {e}')
    print()

    reads, writes, selects = ctx.stats()
    print(f'I/O statistics:  reads={reads}  writes={writes}  selects={selects}')
    print()
    ctx.close()
    print('Context closed.')
    print()


# ---------------------------------------------------------------------------
# Part 2 -- Read (generic: works for any member, used with --json)
# ---------------------------------------------------------------------------

def demo_read_generic(sdf_path, member):
    """
    Generic SDF member reader.  Enumerates all blocks, symbols, and
    statements.  Dynamically drills into STRUCTURE template blocks and
    TASK blocks rather than probing for hardcoded NAVCOMP names.
    """
    print('=' * 62)
    print('Part 2 -- Read (generic): accessing SDF member')
    print('=' * 62)
    print(f'  Input file  : {sdf_path}')
    print(f'  Member name : {member}')
    print()

    ctx = SdfContext.open(sdf_path, npages=4)
    ctx.select(member)

    # ------------------------------------------------------------------
    # Step R1: Root cell
    # ------------------------------------------------------------------
    print('Step R1: directory root cell')
    root      = ctx.locate_root()
    blk_nodes = struct.unpack_from('>H', root, 16)[0]
    sym_nodes = struct.unpack_from('>H', root, 18)[0]
    fstmt     = struct.unpack_from('>H', root, 52)[0]
    lstm      = struct.unpack_from('>H', root, 54)[0]
    sdf_flags = (root[0] << 8) | root[1]
    print(f'  Blocks: {blk_nodes}   Symbols: {sym_nodes}   '
          f'Stmts: {fstmt}..{lstm}   HAS_SRNS: {bool(sdf_flags & 0x8000)}')
    print()

    # ------------------------------------------------------------------
    # Step R2: Enumerate blocks; identify STRUCTURE templates and TASKs
    # ------------------------------------------------------------------
    print('Step R2: blocks')
    print(f'  {"#":>3}  {"CSECT":<10}  {"CLASS":<22}  {"NAME":<16}  '
          f'{"SYMBS":>7}  {"STMTS":>7}')
    print(f'  {"-"*3}  {"-"*10}  {"-"*22}  {"-"*16}  {"-"*7}  {"-"*7}')
    structure_block_nos = []
    task_block_nos      = []
    all_blks            = []
    for blk_no in range(1, blk_nodes + 1):
        blk = ctx.find_block_by_number(blk_no)
        cls = BLK_CLASS.get(blk.blk_class, f'class={blk.blk_class}')
        if blk.blk_class == 3:
            structure_block_nos.append(blk_no)
        elif blk.blk_class == 4:
            task_block_nos.append(blk_no)
        all_blks.append(blk)
        sr  = (f'{blk.fsymb_no}..{blk.lsymb_no}' if blk.fsymb_no else '—')
        tr  = (f'{blk.fstmt_no}..{blk.lstm_no}'  if blk.fstmt_no else '—')
        tag = ''
        if blk.blk_class == 3:
            tag = '  ← STRUCTURE template'
        elif blk.blk_class == 4:
            tag = '  ← TASK'
        print(f'  {blk.blk_no:>3}  {blk.csect_name:<10}  {cls:<22}  '
              f'{blk.blk_name:<16}  {sr:>7}  {tr:>7}{tag}')
    print()

    # ------------------------------------------------------------------
    # Step R3: Build template map
    # ------------------------------------------------------------------
    template_map = {}
    copy_map     = {}
    for sno in range(1, sym_nodes + 1):
        sym = ctx.find_symbol_by_number(sno)
        if sym.sym_class == 3 and sym.sym_type == 10:
            template_map[sno] = sym.symb_name
            copy_map[sym.blk_no] = sym.copy_blk_no

    # ------------------------------------------------------------------
    # Step R4: Enumerate all symbols
    # ------------------------------------------------------------------
    print('Step R4: symbols')
    structure_blk_set = set(structure_block_nos)
    print(f'  {"#":>3}  {"NAME":<18}  {"CLASS":<16}  {"TYPE":<28}  BLK  NOTE')
    print(f'  {"-"*3}  {"-"*18}  {"-"*16}  {"-"*28}  {"-"*3}  {"-"*30}')
    for sno in range(1, sym_nodes + 1):
        sym  = ctx.find_symbol_by_number(sno)
        cls  = SYM_CLASS.get(sym.sym_class, f'class={sym.sym_class}')
        typ  = sym_type_detail(sym, template_map)
        note = ''
        if sym.sym_class == 3 and sym.sym_type == 10:
            if sym.copy_blk_no:
                try:
                    src_blk = ctx.find_block_by_number(sym.copy_blk_no)
                    note = f'← template hdr, COPY {src_blk.blk_name}'
                except SdfError:
                    note = f'← template hdr, COPY blk#{sym.copy_blk_no}'
            else:
                note = '← template header'
        elif sym.sym_type == 10 and sym.sym_class == 1:
            tmpl_name = template_map.get(sym.rows, f'symb#{sym.rows}')
            note = f'instance of {tmpl_name}'
        elif sym.sym_class == 1 and sym.blk_no in structure_blk_set:
            note = '← structure member'
        elif sym.sym_class == SCLASS_LABEL:
            note = '← NAME variable'
        elif sym.sym_class == SCLASS_EQUATE_EXT:
            note = '← equate-ext (compiler-internal)'
        elif sym.sym_type == STYPE_TASK:
            note = '← task entry-point'
        print(f'  {sym.symb_no:>3}  {sym.symb_name:<18}  {cls:<16}  '
              f'{typ:<28}  {sym.blk_no:>3}  {note}')
    print()

    # ------------------------------------------------------------------
    # Step R5: Drill into each STRUCTURE template block
    # ------------------------------------------------------------------
    for tmpl_blk_no in structure_block_nos:
        blk = ctx.find_block_by_number(tmpl_blk_no)
        cb  = copy_map.get(blk.blk_no, 0)
        copy_tag = ''
        if cb:
            try:
                src = ctx.find_block_by_number(cb)
                copy_tag = f'  COPYs: {src.blk_name} (blk#{cb})'
            except SdfError:
                copy_tag = f'  COPYs: blk#{cb}'
        print(f'Step R5 [blk#{blk.blk_no}]: STRUCTURE template {blk.blk_name}{copy_tag}')
        if blk.fsymb_no:
            print(f'  Symbol range: {blk.fsymb_no}..{blk.lsymb_no}')
            for sno in range(blk.fsymb_no, blk.lsymb_no + 1):
                sym = ctx.find_symbol_by_number(sno)
                typ = sym_type_detail(sym, template_map)
                if sym.sym_class == 3:
                    role = f'template header (copy_blk_no={sym.copy_blk_no})'
                else:
                    role = 'member'
                print(f'    {sym.symb_no:>3}  {sym.symb_name:<16}  {typ:<16}  ({role})')
        else:
            print('  (no symbols)')
        print()

    # ------------------------------------------------------------------
    # Step R6: Drill into each TASK block
    # ------------------------------------------------------------------
    for task_blk_no in task_block_nos:
        blk = ctx.find_block_by_number(task_blk_no)
        print(f'Step R6 [blk#{blk.blk_no}]: TASK block {blk.blk_name}')
        if blk.fsymb_no:
            print(f'  Symbol range: {blk.fsymb_no}..{blk.lsymb_no}')
            for sno in range(blk.fsymb_no, blk.lsymb_no + 1):
                sym = ctx.find_symbol_by_number(sno)
                typ = sym_type_detail(sym, template_map)
                role = 'entry-point' if sym.sym_type == STYPE_TASK else 'local'
                print(f'    {sym.symb_no:>3}  {sym.symb_name:<16}  {typ:<14}  ({role})')
        else:
            print('  (no symbols)')
        print()

    # ------------------------------------------------------------------
    # Step R7: Statements
    # ------------------------------------------------------------------
    if fstmt and lstm:
        print('Step R7: statements')
        print(f'  {"#":>3}  {"SRN":<8}  {"TYPE":<14}  {"EXEC":>4}  '
              f'{"LABLS":>5}  {"LHS":>3}  BLK')
        print(f'  {"-"*3}  {"-"*8}  {"-"*14}  {"-"*4}  {"-"*5}  {"-"*3}  {"-"*3}')
        for stmt_no in range(fstmt, lstm + 1):
            try:
                stmt = ctx.find_stmt_by_number(stmt_no)
                srn  = stmt.srn.rstrip(b' ').decode() if stmt.srn else ''
                typ  = STMT_TYPE.get(stmt.stmt_type, str(stmt.stmt_type))
                print(f'  {stmt.stmt_no:>3}  {srn:<8}  {typ:<14}  {"yes":>4}  '
                      f'{stmt.num_labls:>5}  {stmt.num_lhs:>3}  {stmt.blk_no}')
            except SdfError as e:
                if e.code == RC_NOT_EXEC:
                    node = ctx.find_stmt_node_by_number(stmt_no)
                    srn  = node.srn.rstrip(b' ').decode() if node.srn else ''
                    print(f'  {stmt_no:>3}  {srn:<8}  {"(non-exec)":<14}  '
                          f'{"no":>4}  {"—":>5}  {"—":>3}  —')
                else:
                    print(f'  {stmt_no:>3}  error: {e}')
        print()
    else:
        print('Step R7: no statements in this member')
        print()

    reads, writes, selects = ctx.stats()
    print(f'I/O statistics:  reads={reads}  writes={writes}  selects={selects}')
    print()
    ctx.close()
    print('Context closed.')
    print()


# ---------------------------------------------------------------------------
# Member → JSON extraction
# ---------------------------------------------------------------------------

# Reverse-lookup tables: numeric code → JSON string name (matching sdf-json-format.md)
_BLK_CLASS_STR = {1:'PROGRAM', 2:'FUNCTION', 3:'PROCEDURE',
                  4:'TASK',    5:'COMPOOL',  6:'CLOSE'}
_SYM_CLASS_STR = {1:'VARIABLE', 2:'EQUATE_EXT', 3:'TEMPLATE',
                  4:'LABEL',    6:'COMPOOL'}
_SYM_TYPE_STR  = {1:'SCALAR',  2:'INTEGER',    3:'BOOLEAN',
                  4:'CHARACTER',5:'BIT',        6:'VECTOR',
                  7:'MATRIX',   8:'EQUATE_EXT', 9:'EVENT',
                  10:'STRUCTURE',11:'TASK'}
_STMT_TYPE_STR = {1:'ASSIGN',  2:'IF',      3:'DO',     4:'DO_WHILE',
                  5:'DO_UNTIL',6:'DO_FOR',  7:'END',    8:'RETURN',
                  9:'CALL',    10:'GOTO',   11:'ON_ERROR'}


def member_to_json(sdf_path, member_name):
    """
    Read an SDF member and return a JSON-compatible dict matching the
    schema described in sdf-json-format.md.  The dict can be serialised
    with json.dumps() and re-imported with --json.
    """
    ctx = SdfContext.open(sdf_path, npages=4)
    ctx.select(member_name)

    root      = ctx.locate_root()
    blk_nodes = struct.unpack_from('>H', root, 16)[0]
    sym_nodes = struct.unpack_from('>H', root, 18)[0]
    fstmt     = struct.unpack_from('>H', root, 52)[0]
    lstm      = struct.unpack_from('>H', root, 54)[0]
    sdf_flags = (root[0] << 8) | root[1]

    has_srns    = bool(sdf_flags & 0x8000)
    has_nonmono = bool(sdf_flags & 0x0400)

    # Collect all blocks; build blk_no → id map (use blk_name as id)
    blk_results  = {}
    blk_no_to_id = {}
    for blk_no in range(1, blk_nodes + 1):
        blk = ctx.find_block_by_number(blk_no)
        blk_results[blk_no]  = blk
        blk_no_to_id[blk_no] = blk.blk_name

    # Collect symbols grouped by block
    syms_by_blk = {n: [] for n in range(1, blk_nodes + 1)}
    for sno in range(1, sym_nodes + 1):
        sym = ctx.find_symbol_by_number(sno)
        if sym.blk_no in syms_by_blk:
            syms_by_blk[sym.blk_no].append(sym)

    # Collect statements grouped by block.
    # Non-exec statement nodes return blk_no=0 (they have no data cell that
    # stores a block number).  Track the last seen blk_no from exec statements
    # and attribute any following non-exec statements to that same block.
    stmts_by_blk = {n: [] for n in range(1, blk_nodes + 1)}
    if fstmt and lstm:
        current_blk = 1   # fallback if first stmt is non-exec
        for stmt_no in range(fstmt, lstm + 1):
            try:
                stmt = ctx.find_stmt_by_number(stmt_no)
                current_blk = stmt.blk_no
                if stmt.blk_no in stmts_by_blk:
                    stmts_by_blk[stmt.blk_no].append(stmt)
            except SdfError as e:
                if e.code == RC_NOT_EXEC:
                    try:
                        node = ctx.find_stmt_node_by_number(stmt_no)
                        # node.blk_no is 0 for non-exec nodes; use current_blk
                        target = node.blk_no if node.blk_no else current_blk
                        if target in stmts_by_blk:
                            stmts_by_blk[target].append(node)
                    except SdfError:
                        pass

    ctx.close()

    # Build COPY dependency graph: blk_no → {blk_nos it depends on via copy_blk_no}
    # This lets us topologically sort blocks so that a COPY source always
    # appears before the derived template that references it.
    deps = {n: set() for n in range(1, blk_nodes + 1)}
    for blk_no, sym_list in syms_by_blk.items():
        for sym in sym_list:
            if sym.copy_blk_no and sym.copy_blk_no in deps:
                deps[blk_no].add(sym.copy_blk_no)

    visited    = set()
    topo_order = []

    def _topo_visit(n):
        if n in visited:
            return
        visited.add(n)
        for dep in sorted(deps.get(n, [])):
            _topo_visit(dep)
        topo_order.append(n)

    for n in range(1, blk_nodes + 1):
        _topo_visit(n)

    # Build flags list
    flags = []
    if has_srns:
        flags.append('HAS_SRNS')
    if has_nonmono:
        flags.append('NONMONO')

    # Build blocks list in topological order (dependencies first)
    blocks_json = []
    for blk_no in topo_order:
        blk = blk_results[blk_no]
        blk_dict = {
            'id':         blk_no_to_id[blk_no],
            'blk_name':   blk.blk_name,
            'csect_name': blk.csect_name,
            'blk_class':  _BLK_CLASS_STR.get(blk.blk_class, 'PROGRAM'),
            'blk_id':     blk.blk_id,
        }
        if blk.blk_type:
            blk_dict['blk_type'] = blk.blk_type
        if blk.blk_flags:
            blk_dict['blk_flags'] = blk.blk_flags

        # Symbols
        sym_list = []
        for sym in syms_by_blk.get(blk_no, []):
            sym_dict = {'name': sym.symb_name}

            # Omit "class" when it is the default (VARIABLE)
            if sym.sym_class != SCLASS_VARIABLE:
                sym_dict['class'] = _SYM_CLASS_STR.get(sym.sym_class, 'VARIABLE')

            # EQUATE_EXT class implies type; omit "type" to keep JSON minimal
            is_equate_ext = (sym.sym_class == SCLASS_EQUATE_EXT
                             and sym.sym_type == STYPE_EQUATE_EXT)
            if not is_equate_ext:
                sym_dict['type'] = _SYM_TYPE_STR.get(sym.sym_type, 'SCALAR')

            # For STRUCTURE template headers the "rows" field holds the
            # header's own symb_no (set automatically at commit time).
            # Omit it from the JSON so round-tripping does not corrupt the value.
            is_tmpl_hdr = (sym.sym_class == SCLASS_TEMPLATE
                           and sym.sym_type == STYPE_STRUCTURE)
            if not is_tmpl_hdr:
                if sym.rows:
                    sym_dict['rows'] = sym.rows
            if sym.columns:
                sym_dict['columns'] = sym.columns

            ndims = sym.array_dims[0]
            if ndims > 0:
                sym_dict['array'] = list(sym.array_dims[1:1 + ndims])

            if sym.copy_blk_no:
                ref_id = blk_no_to_id.get(sym.copy_blk_no)
                if ref_id:
                    sym_dict['copy_block'] = ref_id

            for fname in ('flag1', 'flag2', 'flag3', 'flag4'):
                val = getattr(sym, fname, 0)
                if val:
                    sym_dict[fname] = val

            sym_list.append(sym_dict)

        blk_dict['symbols'] = sym_list

        # Statements
        stmt_list = []
        for stmt in stmts_by_blk.get(blk_no, []):
            stmt_dict = {}

            srn_raw = getattr(stmt, 'srn', b'')
            if srn_raw:
                srn_str = srn_raw.rstrip(b' ').decode('ascii', errors='replace')
                if srn_str:
                    stmt_dict['srn'] = srn_str

            type_str = _STMT_TYPE_STR.get(getattr(stmt, 'stmt_type', 0))
            if type_str:
                stmt_dict['type'] = type_str

            is_exec = getattr(stmt, 'is_executable', False)
            stmt_dict['exec'] = is_exec

            if is_exec:
                if stmt.num_lhs:
                    stmt_dict['lhs'] = stmt.num_lhs
                if stmt.num_labls:
                    stmt_dict['labels'] = stmt.num_labls

            stmt_list.append(stmt_dict)

        if stmt_list:
            blk_dict['statements'] = stmt_list

        blocks_json.append(blk_dict)

    return {
        'member': member_name,
        'flags':  flags,
        'blocks': blocks_json,
    }


def do_extract_json(sdf_path, member_name, out_path):
    """Extract *member_name* from *sdf_path* and write JSON to *out_path*.

    Use '-' for *out_path* to write to stdout.  A '.json' extension is
    appended to *out_path* if it does not already have one.
    """
    spec = member_to_json(sdf_path, member_name)
    text = _json_mod.dumps(spec, indent=2) + '\n'
    if out_path == '-':
        sys.stdout.write(text)
    else:
        if not out_path.endswith('.json'):
            out_path += '.json'
        with open(out_path, 'w') as f:
            f.write(text)
        print(f'Extracted member {member_name!r} → {out_path}')


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main():
    args = sys.argv[1:]

    if '--help' in args or '-h' in args:
        print(__doc__)
        sys.exit(0)

    # Extract two-token options: --json FILE and --extract-json OUT
    json_path     = None
    extract_path  = None
    for i, a in enumerate(args):
        if a == '--json' and i + 1 < len(args):
            json_path = args[i + 1]
        elif a == '--extract-json' and i + 1 < len(args):
            extract_path = args[i + 1]

    add_member_mode  = '--add-member'    in args
    use_suffix       = '--suffix'        in args
    delete_mode      = '--delete-member' in args

    # Strip all flags and their values from positional args
    two_token = {'--json', '--extract-json'}
    cleaned = []
    skip_next = False
    for a in args:
        if skip_next:
            skip_next = False
            continue
        if a in two_token:
            skip_next = True
            continue
        if a.startswith('--'):
            continue
        cleaned.append(a)
    args = cleaned

    base_member = 'NAVCOMP'
    suffix      = ''
    temp_file   = None

    # Load JSON once if --json was given
    json_spec = None
    if json_path:
        with open(json_path) as _f:
            json_spec = _json_mod.load(_f)

    if args:
        sdf_path = args[0]
        if len(args) >= 2:
            base_member = args[1]            # CLI member name takes precedence
        elif json_spec is not None:
            base_member = json_spec.get('member', 'MEMBER1')  # fall back to JSON

        if delete_mode:
            if not os.path.exists(sdf_path):
                print(f'Error: {sdf_path!r} does not exist.', file=sys.stderr)
                sys.exit(1)
            try:
                delete_member(sdf_path, base_member)
                print(f'Deleted member {base_member!r} from {sdf_path}')
            except ValueError as e:
                print(f'Error: {e}', file=sys.stderr)
                sys.exit(1)
            return

        if extract_path is not None:
            if not os.path.exists(sdf_path):
                print(f'Error: {sdf_path!r} does not exist.', file=sys.stderr)
                sys.exit(1)
            try:
                do_extract_json(sdf_path, base_member, extract_path)
            except (SdfError, ValueError) as e:
                print(f'Error: {e}', file=sys.stderr)
                sys.exit(1)
            return

        if add_member_mode:
            if use_suffix:
                if os.path.exists(sdf_path):
                    existing = flat_info(sdf_path)
                    names = [m['name'] for m in existing]
                    if base_member in names:
                        new_index = names.index(base_member) + 1
                    else:
                        new_index = len(existing) + 1
                else:
                    new_index = 1
                suffix = '' if new_index == 1 else str(new_index)
            else:
                suffix = ''

            is_append = os.path.exists(sdf_path)
            if json_spec is not None:
                demo_write_from_json(sdf_path, json_spec, json_display=json_path,
                                     member_name=base_member, suffix=suffix,
                                     append=is_append)
                demo_read_generic(sdf_path, base_member)
            else:
                demo_write(sdf_path, base_member, suffix=suffix, append=is_append)
                demo_read(sdf_path, base_member, suffix=suffix)

        elif os.path.exists(sdf_path):
            if json_spec is not None:
                demo_read_generic(sdf_path, base_member)
            else:
                demo_read(sdf_path, base_member)

        else:
            if json_spec is not None:
                demo_write_from_json(sdf_path, json_spec, json_display=json_path,
                                     member_name=base_member, suffix=suffix,
                                     append=False)
                demo_read_generic(sdf_path, base_member)
            else:
                demo_write(sdf_path, base_member)
                demo_read(sdf_path, base_member)

    else:
        # No SDF path given: use a temp file.
        # Resolve member name from JSON if available.
        if json_spec is not None:
            base_member = json_spec.get('member', 'MEMBER1')
        fd, sdf_path = tempfile.mkstemp(suffix='.sdf', prefix='sdfpkg_demo_')
        os.close(fd)
        temp_file = sdf_path
        try:
            if json_spec is not None:
                demo_write_from_json(sdf_path, json_spec, json_display=json_path,
                                     member_name=base_member, suffix='',
                                     append=False)
                demo_read_generic(sdf_path, base_member)
            else:
                demo_write(sdf_path, base_member)
                demo_read(sdf_path, base_member)
        finally:
            if os.path.exists(temp_file):
                os.unlink(temp_file)
                print('Temporary file removed.')


if __name__ == '__main__':
    main()
