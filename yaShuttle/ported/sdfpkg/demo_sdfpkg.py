#!/usr/bin/env python3
"""
demo_sdfpkg.py  --  Demonstration of the sdfpkg.py API.

Shows both the write (creation) and read (access) paths, including
HAL/S STRUCTURE variables.

  Part 1 -- Write: create a new SDF flat file member from scratch.
  Part 2 -- Read:  open the file and extract all blocks, symbols,
            and statements, with special handling for STRUCTURE types.

Usage:  ./demo_sdfpkg.py [--help] [--add-member] [file.sdf [member]]

If file.sdf is omitted a temporary file is created and deleted on exit.
If a supplied file already exists and --add-member is NOT given, Part 1
is skipped and only Part 2 (read) is executed.

--add-member
    Add a new member to file.sdf (creating it if it does not yet exist).
    The member index is derived from the current member count in the file:
      - 1st member: object names are unmodified (e.g. ALTITUDE, ARMED).
      - 2nd member: all object names are suffixed with "2" (ALTITUDE2, ARMED2).
      - Nth member: all object names are suffixed with the index N.
    The member name itself follows the same rule (NAVCOMP, NAVCOMP2, ...).
"""

import sys
import os
import struct
import tempfile

from sdfpkg import (
    SdfContext, SdfWriter, SdfError,
    WBlock, WSymbol, WStmt,
    BCLASS_PROGRAM, BCLASS_PROCEDURE, BCLASS_TASK,
    SCLASS_VARIABLE, SCLASS_TEMPLATE, SCLASS_LABEL, SCLASS_EQUATE_EXT,
    STYPE_SCALAR, STYPE_INTEGER, STYPE_BOOLEAN, STYPE_CHARACTER,
    STYPE_BIT, STYPE_VECTOR, STYPE_MATRIX, STYPE_STRUCTURE, STYPE_EVENT,
    STYPE_TASK, STYPE_EQUATE_EXT,
    STTYPE_ASSIGN, STTYPE_IF,
    WFLAG_HAS_SRNS,
    RC_NOT_EXEC, DISP_NONE,
    flat_info,
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

def sym_type_detail(sym, template_map=None):
    """
    Return a descriptive type string including dimensions and, for
    STRUCTURE instance variables, the name of the template type.
    ARRAY variables are prefixed with ARRAY(d1) or ARRAY(d1,d2).
    NAME variables show the type of their referent.

    template_map: optional dict mapping symb_no -> template name,
                  used to resolve STRUCTURE instances.
    """
    # Build ARRAY prefix if this is an array variable
    array_prefix = ''
    if hasattr(sym, 'array_dims') and sym.array_dims[0] > 0:
        ndims = sym.array_dims[0]
        dims  = sym.array_dims[1:1+ndims]
        array_prefix = 'ARRAY(' + ','.join(str(d) for d in dims) + ') '

    # NAME variables: class=4 (LABEL), sym_type = type of the referent
    if sym.sym_class == SCLASS_LABEL:
        referent = SYM_TYPE.get(sym.sym_type, f'type={sym.sym_type}')
        return f'NAME({referent})'

    # EQUATE_EXT: class=2, type=8 -- external equate reference
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
        # sym.rows holds the symbol number of the template header symbol
        if template_map and sym.rows in template_map:
            return f'STRUCTURE ({template_map[sym.rows]})'
        elif sym.rows:
            return f'STRUCTURE (template symb#{sym.rows})'
        return 'STRUCTURE'
    return array_prefix + SYM_TYPE.get(t, f'type={t}')


# ---------------------------------------------------------------------------
# Part 1 -- Write
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

    # Helper: append suffix to every object name
    def n(base):
        return base + suffix

    # ------------------------------------------------------------------
    # Step W1: Create write context
    # ------------------------------------------------------------------
    print('Step W1: create write context')
    if append:
        w = SdfWriter.add_member(sdf_path, member, flags=WFLAG_HAS_SRNS)
    else:
        w = SdfWriter.create(sdf_path, member, flags=WFLAG_HAS_SRNS)

    # ------------------------------------------------------------------
    # Step W2: Add blocks
    # ------------------------------------------------------------------
    # We add four blocks:
    #   Block 1: NAVCOMP{s}     -- the main PROGRAM block
    #   Block 2: SENSOR_DATA{s} -- a STRUCTURE template block (base)
    #   Block 3: EXT_SENSOR{s}  -- a STRUCTURE template that COPYs SENSOR_DATA{s}
    #   Block 4: BURN_TASK{s}   -- a TASK block (blk_class=BCLASS_TASK=4)
    #
    # STRUCTURE template blocks use blk_class=BCLASS_PROCEDURE (3).
    # TASK blocks use blk_class=BCLASS_TASK (4).
    # The COPY link is encoded via STRCDATA in the template header SDC.

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
        blk_class  = BCLASS_TASK,            # = 4: TASK block
        blk_id     = 4,
    ))
    print(f'  Block {blk4}: {n("BURN_TASK")} (TASK)')
    print()

    # ------------------------------------------------------------------
    # Step W3: Add SENSOR_DATA template symbols (block 2)
    # ------------------------------------------------------------------
    print(f'Step W3: add {n("SENSOR_DATA")} template symbols (block {blk2})')
    templ_hdr_no = w.add_symbol(WSymbol(
        blk_no    = blk2,
        symb_name = n('SENSOR_DATA'),
        sym_class = SCLASS_TEMPLATE,
        sym_type  = STYPE_STRUCTURE,
        # copy_blk_no = 0: this is the base template; it does not COPY anything
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

    # ------------------------------------------------------------------
    # Step W3b: Add EXT_SENSOR template symbols (block 3)
    # ------------------------------------------------------------------
    # EXT_SENSOR{s} COPYs SENSOR_DATA{s}.  Its template header symbol carries
    # copy_blk_no = blk2 (the block number of SENSOR_DATA{s}).  At SDF write
    # time this is stored in a STRCDATA block appended to the SDC, and the
    # SDC's struct_of byte is set to the byte offset of that STRCDATA block.
    #
    # EXT_SENSOR{s} also adds one new own member (RANGE_KM{s}) beyond those
    # inherited via COPY.

    print(f'Step W3b: add {n("EXT_SENSOR")} template symbols (block {blk3}, COPYs {n("SENSOR_DATA")})')
    ext_hdr_no = w.add_symbol(WSymbol(
        blk_no      = blk3,
        symb_name   = n('EXT_SENSOR'),
        sym_class   = SCLASS_TEMPLATE,
        sym_type    = STYPE_STRUCTURE,
        copy_blk_no = blk2,   # <-- COPY link: inherits SENSOR_DATA{s} members
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

    # ------------------------------------------------------------------
    # Step W4: Add program symbols (block 1: NAVCOMP{s})
    # ------------------------------------------------------------------
    # Demonstrates all supported symbol classes:
    #   SCLASS_VARIABLE   (1) -- ordinary variables
    #   SCLASS_EQUATE_EXT (2) -- external equate reference (compiler-internal)
    #   SCLASS_LABEL      (4) -- NAME variable; sym_type = type of referent
    print(f'Step W4: add program symbols (block {blk1}: {n("NAVCOMP")})')
    prog_syms = [
        # (name,           type,            rows, cols, array_dims)
        ('ALTITUDE',       STYPE_SCALAR,    0,  0, (0,0,0,0)),
        ('ARMED',          STYPE_BOOLEAN,   0,  0, (0,0,0,0)),
        ('BITS',           STYPE_BIT,      16,  0, (0,0,0,0)),
        ('COUNT',          STYPE_INTEGER,   0,  0, (0,0,0,0)),
        ('INERTIA',        STYPE_MATRIX,    3,  3, (0,0,0,0)),
        ('LAUNCH_ENABLE',  STYPE_EVENT,     0,  0, (0,0,0,0)),
        ('LONGSYMBOLNAME', STYPE_SCALAR,    0,  0, (0,0,0,0)),
        ('MESSAGE',        STYPE_CHARACTER, 0, 20, (0,0,0,0)),
        ('READINGS',       STYPE_SCALAR,    0,  0, (1,10,0,0)),  # ARRAY(10) SCALAR
        ('TABLE',          STYPE_INTEGER,   0,  0, (2, 3,4,0)),  # ARRAY(3,4) INTEGER
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

    # SENSOR instance: TYPE=STRUCTURE, rows=0 placeholder
    sensor_no = w.add_symbol(WSymbol(
        blk_no    = blk1,
        symb_name = n('SENSOR'),
        sym_class = SCLASS_VARIABLE,
        sym_type  = STYPE_STRUCTURE,
        rows      = 0,   # PASS3 would fill this in
    ))
    print(f'  Symbol {sensor_no}: {n("SENSOR"):<18} STRUCTURE instance (rows=TBD)')

    # NAME variable (sym_class=SCLASS_LABEL=4): refers to a SCALAR
    # In HAL/S: DECLARE ALT_PTR NAME;  -- a NAME to an unspecified type
    # sym_type holds the type of the referent (STYPE_SCALAR here)
    name_no = w.add_symbol(WSymbol(
        blk_no    = blk1,
        symb_name = n('ALT_PTR'),
        sym_class = SCLASS_LABEL,        # = 4: NAME variable
        sym_type  = STYPE_SCALAR,        # type of the thing it names
    ))
    print(f'  Symbol {name_no}: {n("ALT_PTR"):<18} NAME(SCALAR)  (sym_class=LABEL)')

    # EQUATE_EXT (sym_class=2, sym_type=8): external equate reference
    # Compiler-internal; used when a COMPOOL symbol is referenced externally
    eq_no = w.add_symbol(WSymbol(
        blk_no    = blk1,
        symb_name = n('EXT_CONST'),
        sym_class = SCLASS_EQUATE_EXT,   # = 2
        sym_type  = STYPE_EQUATE_EXT,    # = 8
    ))
    print(f'  Symbol {eq_no}: {n("EXT_CONST"):<18} EQUATE EXT  (sym_class=2, sym_type=8)')
    print()

    # ------------------------------------------------------------------
    # Step W4b: Add TASK block symbols (block 4: BURN_TASK{s})
    # ------------------------------------------------------------------
    # A TASK block is a parallel HAL/S task.  Its entry-point symbol has
    # sym_type=STYPE_TASK (11).  Other symbols (locals) use normal types.
    print(f'Step W4b: add {n("BURN_TASK")} symbols (block {blk4}: TASK)')
    task_sym_no = w.add_symbol(WSymbol(
        blk_no    = blk4,
        symb_name = n('BURN_TASK'),
        sym_class = SCLASS_VARIABLE,
        sym_type  = STYPE_TASK,          # = 11: task entry-point symbol
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

    # ------------------------------------------------------------------
    # Step W5: Add statements
    # ------------------------------------------------------------------
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

    # ------------------------------------------------------------------
    # Step W6: Commit
    # ------------------------------------------------------------------
    print('Step W6: commit')
    w.commit()
    print(f'  File written: {sdf_path}')
    print()


# ---------------------------------------------------------------------------
# Part 2 -- Read
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

    # Helper: append suffix to every object name
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
    # Step R2: Enumerate blocks -- identify STRUCTURE templates
    # ------------------------------------------------------------------
    print('Step R2: blocks')
    print(f'  {"#":>3}  {"CSECT":<10}  {"CLASS":<22}  {"NAME":<16}  '
          f'{"SYMBS":>7}  {"STMTS":>7}')
    print(f'  {"-"*3}  {"-"*10}  {"-"*22}  {"-"*16}  {"-"*7}  {"-"*7}')
    structure_blocks = set()   # blk_no values that are STRUCTURE templates
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
    # Step R3: Build template map (symb_no -> (name, copy_blk_no))
    # ------------------------------------------------------------------
    # For each template header (CLASS=3, TYPE=10) record:
    #   template_map[symb_no] = name
    #   copy_map[blk_no]      = copy_blk_no (0 if no COPY)
    # copy_blk_no is decoded from the STRCDATA block appended to the SDC
    # when the template header was written with copy_blk_no != 0.

    template_map = {}   # symb_no -> template name
    copy_map     = {}   # blk_no  -> copy_blk_no (the block it COPYs; 0 = none)
    for sno in range(1, sym_nodes + 1):
        sym = ctx.find_symbol_by_number(sno)
        if sym.sym_class == 3 and sym.sym_type == 10:   # TEMPLATE header
            template_map[sno] = sym.symb_name
            copy_map[sym.blk_no] = sym.copy_blk_no

    # ------------------------------------------------------------------
    # Step R4: Enumerate symbols -- annotate STRUCTURE types and COPY links
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
    # Step R5: Drill into SENSOR_DATA{s} template block
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
    # Step R5b: Drill into EXT_SENSOR{s} template block (shows COPY link)
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
    # Step R5c: Drill into BURN_TASK{s} block (TASK block demo)
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
    ctx.find_block_by_number(1)  # set block 1 as search context
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
# Entry point
# ---------------------------------------------------------------------------

def main():
    args = sys.argv[1:]

    if '--help' in args or '-h' in args:
        print(__doc__)
        sys.exit(0)

    add_member_mode = '--add-member' in args
    args = [a for a in args if not a.startswith('--')]

    base_member = 'NAVCOMP'
    temp_file   = None

    if args:
        sdf_path = args[0]
        if len(args) >= 2:
            base_member = args[1]

        if add_member_mode:
            # Determine object-name suffix from the 1-based position this member
            # will occupy after the write.  Position 1 → no suffix; position N → "N".
            #   - Overwrite: position = index of existing member with same name.
            #   - New member: position = existing count + 1.
            if os.path.exists(sdf_path):
                existing = flat_info(sdf_path)
                names = [m['name'] for m in existing]
                if base_member in names:
                    new_index = names.index(base_member) + 1   # 1-based position
                else:
                    new_index = len(existing) + 1
                suffix = '' if new_index == 1 else str(new_index)
                demo_write(sdf_path, base_member, suffix=suffix, append=True)
            else:
                suffix = ''
                demo_write(sdf_path, base_member, suffix=suffix, append=False)
            demo_read(sdf_path, base_member, suffix=suffix)
        elif os.path.exists(sdf_path):
            demo_read(sdf_path, base_member)
        else:
            demo_write(sdf_path, base_member)
            demo_read(sdf_path, base_member)
    else:
        fd, sdf_path = tempfile.mkstemp(suffix='.sdf', prefix='sdfpkg_demo_')
        os.close(fd)
        temp_file = sdf_path
        try:
            demo_write(sdf_path, base_member)
            demo_read(sdf_path, base_member)
        finally:
            if os.path.exists(temp_file):
                os.unlink(temp_file)
                print(f'Temporary file removed.')


if __name__ == '__main__':
    main()
