#!/usr/bin/env python3
"""
demo_sdfpkg.py  --  Demonstration of the sdfpkg.py API.

Shows both the write (creation) and read (access) paths, including
HAL/S STRUCTURE variables.

  Part 1 -- Write: create a new SDF flat file member from scratch.
  Part 2 -- Read:  open the file and extract all blocks, symbols,
            and statements, with special handling for STRUCTURE types.

Usage:  ./demo_sdfpkg.py [--help] [file.sdf [member]]

If file.sdf is omitted a temporary file is created and deleted on exit.
If a supplied file already exists, Part 1 is skipped.
"""

import sys
import os
import struct
import tempfile

from sdfpkg import (
    SdfContext, SdfWriter, SdfError,
    WBlock, WSymbol, WStmt,
    BCLASS_PROGRAM, BCLASS_PROCEDURE,
    SCLASS_VARIABLE, SCLASS_TEMPLATE,
    STYPE_SCALAR, STYPE_INTEGER, STYPE_BOOLEAN, STYPE_CHARACTER,
    STYPE_BIT, STYPE_VECTOR, STYPE_MATRIX, STYPE_STRUCTURE,
    STTYPE_ASSIGN, STTYPE_IF,
    WFLAG_HAS_SRNS,
    RC_NOT_EXEC, DISP_NONE,
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

    template_map: optional dict mapping symb_no -> template name,
                  used to resolve STRUCTURE instances.
    """
    # Build ARRAY prefix if this is an array variable
    array_prefix = ''
    if hasattr(sym, 'array_dims') and sym.array_dims[0] > 0:
        ndims = sym.array_dims[0]
        dims  = sym.array_dims[1:1+ndims]
        array_prefix = 'ARRAY(' + ','.join(str(d) for d in dims) + ') '

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

def demo_write(sdf_path, member='NAVCOMP'):
    print('=' * 62)
    print('Part 1 -- Write: creating SDF member with STRUCTURE')
    print('=' * 62)
    print(f'  Output file : {sdf_path}')
    print(f'  Member name : {member}')
    print()

    # ------------------------------------------------------------------
    # Step W1: Create write context
    # ------------------------------------------------------------------
    print('Step W1: create write context')
    w = SdfWriter.create(sdf_path, member, flags=WFLAG_HAS_SRNS)

    # ------------------------------------------------------------------
    # Step W2: Add blocks
    # ------------------------------------------------------------------
    # We add two blocks:
    #   Block 1: NAVCOMP  -- the main PROGRAM block
    #   Block 2: SENSOR_DATA -- a STRUCTURE template block
    #
    # In HAL/S-FC, STRUCTURE template blocks use blk_class=BCLASS_PROCEDURE
    # (value 3).  The template block contains the structure member symbols.

    print('Step W2: add blocks')
    blk1 = w.add_block(WBlock(
        csect_name = 'NAVSECT',
        blk_name   = 'NAVCOMP',
        blk_class  = BCLASS_PROGRAM,
        blk_id     = 1,
    ))
    print(f'  Block {blk1}: NAVCOMP (PROGRAM)')

    blk2 = w.add_block(WBlock(
        csect_name = 'STRCSECT',
        blk_name   = 'SENSOR_DATA',
        blk_class  = BCLASS_PROCEDURE,   # = 3: STRUCTURE template
        blk_id     = 2,
    ))
    print(f'  Block {blk2}: SENSOR_DATA (STRUCTURE template)')
    print()

    # ------------------------------------------------------------------
    # Step W3: Add STRUCTURE template symbols (block 2)
    # ------------------------------------------------------------------
    # The template block contains:
    #   - A template header symbol (CLASS=SCLASS_TEMPLATE=3, TYPE=STYPE_STRUCTURE=10)
    #     whose rows field will be set to its own symbol number (self-referential).
    #     We add it first so we can obtain its symbol number, then fix up rows.
    #   - Member symbols (CLASS=SCLASS_VARIABLE, various types).
    #
    # All are sorted alphabetically at commit time.  After sorting, the
    # template header's symbol number is used to fill in the 'rows' field
    # of the STRUCTURE instance variable in block 1.
    #
    # NOTE: Because sdf_commit() sorts symbols before assigning final numbers,
    # the provisional symbol number returned by add_symbol() may change.
    # For the demo we track the template header by name and resolve it after
    # commit via find_symbol_by_name().

    print('Step W3: add STRUCTURE template symbols (block 2: SENSOR_DATA)')
    templ_hdr_no = w.add_symbol(WSymbol(
        blk_no    = blk2,
        symb_name = 'SENSOR_DATA',
        sym_class = SCLASS_TEMPLATE,     # = 3
        sym_type  = STYPE_STRUCTURE,     # = 10
        # rows = self (filled in after commit via SDF read-back)
    ))
    print(f'  Symbol {templ_hdr_no}: SENSOR_DATA (template header, CLASS=TEMPLATE)')

    mem_alt = w.add_symbol(WSymbol(
        blk_no    = blk2,
        symb_name = 'ALT_READING',
        sym_class = SCLASS_VARIABLE,
        sym_type  = STYPE_SCALAR,
    ))
    print(f'  Symbol {mem_alt}: ALT_READING  SCALAR  (structure member)')

    mem_stat = w.add_symbol(WSymbol(
        blk_no    = blk2,
        symb_name = 'STATUS_CODE',
        sym_class = SCLASS_VARIABLE,
        sym_type  = STYPE_INTEGER,
    ))
    print(f'  Symbol {mem_stat}: STATUS_CODE  INTEGER  (structure member)')

    mem_vel = w.add_symbol(WSymbol(
        blk_no    = blk2,
        symb_name = 'VEL_READING',
        sym_class = SCLASS_VARIABLE,
        sym_type  = STYPE_VECTOR,
        rows      = 3,
    ))
    print(f'  Symbol {mem_vel}: VEL_READING  VECTOR(3)  (structure member)')
    print()

    # ------------------------------------------------------------------
    # Step W4: Add program symbols (block 1)
    # ------------------------------------------------------------------
    # The SENSOR instance variable has TYPE=STYPE_STRUCTURE and its rows
    # field should hold the final symbol number of the SENSOR_DATA template
    # header.  Since commit() sorts and renumbers, we don't know that number
    # yet.  We set rows=0 here as a placeholder and update it via the HAL/S
    # convention: after commit the reader finds it by name and reads the
    # self-referential symb_no from the template header's rows field.
    # (PASS3 in HALSFC would fill this in during its second pass over the
    # symbol table, once all symbol numbers are finalised.)

    print('Step W4: add program symbols (block 1: NAVCOMP)')
    prog_syms = [
        # (name,           type,            rows, cols, array_dims)
        ('ALTITUDE',       STYPE_SCALAR,    0,  0, (0,0,0,0)),
        ('ARMED',          STYPE_BOOLEAN,   0,  0, (0,0,0,0)),
        ('BITS',           STYPE_BIT,      16,  0, (0,0,0,0)),
        ('COUNT',          STYPE_INTEGER,   0,  0, (0,0,0,0)),
        ('INERTIA',        STYPE_MATRIX,    3,  3, (0,0,0,0)),
        ('LONGSYMBOLNAME', STYPE_SCALAR,    0,  0, (0,0,0,0)),
        ('MESSAGE',        STYPE_CHARACTER, 0, 20, (0,0,0,0)),
        ('READINGS',       STYPE_SCALAR,    0,  0, (1,10,0,0)),  # ARRAY(10) SCALAR
        ('TABLE',          STYPE_INTEGER,   0,  0, (2, 3,4,0)),  # ARRAY(3,4) INTEGER
        ('VELOCITY',       STYPE_VECTOR,    3,  0, (0,0,0,0)),
    ]
    for name, typ, rows, cols, adims in prog_syms:
        sno = w.add_symbol(WSymbol(
            blk_no     = blk1,
            symb_name  = name,
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
        print(f'  Symbol {sno}: {name:<18} {type_str}')

    # SENSOR instance: TYPE=STRUCTURE, rows=0 placeholder
    sensor_no = w.add_symbol(WSymbol(
        blk_no    = blk1,
        symb_name = 'SENSOR',
        sym_class = SCLASS_VARIABLE,
        sym_type  = STYPE_STRUCTURE,
        rows      = 0,   # PASS3 would fill this in; see note above
    ))
    print(f'  Symbol {sensor_no}: SENSOR             STRUCTURE instance (rows=TBD)')
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

def demo_read(sdf_path, member='NAVCOMP'):
    print('=' * 62)
    print('Part 2 -- Read: accessing SDF member')
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
        if blk.blk_class == 3:          # PROCEDURE = STRUCTURE template
            structure_blocks.add(blk_no)
        sr  = (f'{blk.fsymb_no}..{blk.lsymb_no}' if blk.fsymb_no else '—')
        tr  = (f'{blk.fstmt_no}..{blk.lstm_no}'  if blk.fstmt_no else '—')
        tag = '  ← STRUCTURE template' if blk.blk_class == 3 else ''
        print(f'  {blk.blk_no:>3}  {blk.csect_name:<10}  {cls:<22}  '
              f'{blk.blk_name:<16}  {sr:>7}  {tr:>7}{tag}')
    print()

    # ------------------------------------------------------------------
    # Step R3: Build template map (symb_no -> template name)
    # ------------------------------------------------------------------
    # For each symbol with TYPE=STRUCTURE (type 10) and CLASS=TEMPLATE (3),
    # record its symbol number -> name mapping.  The rows field of a template
    # header symbol is self-referential (rows = own symb_no), but we just
    # use the name directly here.
    #
    # For STRUCTURE instance variables (CLASS=VARIABLE, TYPE=STRUCTURE),
    # sym.rows holds the symbol number of the template header symbol.

    template_map = {}   # symb_no -> template name string
    for sno in range(1, sym_nodes + 1):
        sym = ctx.find_symbol_by_number(sno)
        if sym.sym_class == 3 and sym.sym_type == 10:  # TEMPLATE header
            template_map[sno] = sym.symb_name

    # ------------------------------------------------------------------
    # Step R4: Enumerate symbols -- annotate STRUCTURE types
    # ------------------------------------------------------------------
    print('Step R4: symbols')
    print(f'  {"#":>3}  {"NAME":<18}  {"CLASS":<16}  {"TYPE":<28}  BLK  NOTE')
    print(f'  {"-"*3}  {"-"*18}  {"-"*16}  {"-"*28}  {"-"*3}  {"-"*22}')
    for sno in range(1, sym_nodes + 1):
        sym  = ctx.find_symbol_by_number(sno)
        cls  = SYM_CLASS.get(sym.sym_class, f'class={sym.sym_class}')
        typ  = sym_type_detail(sym, template_map)
        note = ''
        if sym.sym_class == 3 and sym.sym_type == 10:
            note = '← template header'
        elif sym.sym_type == 10 and sym.sym_class == 1:
            tmpl_name = template_map.get(sym.rows, f'symb#{sym.rows}')
            note = f'instance of {tmpl_name}'
        elif sym.sym_class == 1 and sym.blk_no in structure_blocks:
            note = '← structure member'
        print(f'  {sym.symb_no:>3}  {sym.symb_name:<18}  {cls:<16}  '
              f'{typ:<28}  {sym.blk_no:>3}  {note}')
    print()

    # ------------------------------------------------------------------
    # Step R5: Drill into a STRUCTURE template block by name
    # ------------------------------------------------------------------
    print('Step R5: find STRUCTURE template block by name')
    try:
        blk = ctx.find_block_by_name('SENSOR_DATA')
        print(f'  Block found: #{blk.blk_no} {blk.blk_name}  '
              f'class={BLK_CLASS.get(blk.blk_class, blk.blk_class)}')
        print(f'  Member symbol range: {blk.fsymb_no}..{blk.lsymb_no}')
        print(f'  Members:')
        for sno in range(blk.fsymb_no, blk.lsymb_no + 1):
            sym = ctx.find_symbol_by_number(sno)
            typ = sym_type_detail(sym, template_map)
            role = ('template header'
                    if sym.sym_class == 3 else 'member')
            print(f'    {sym.symb_no:>3}  {sym.symb_name:<16}  '
                  f'{typ:<16}  ({role})')
    except SdfError as e:
        print(f'  Not found: {e}')
    print()

    # ------------------------------------------------------------------
    # Step R6: Find STRUCTURE instance variable by name
    # ------------------------------------------------------------------
    print('Step R6: find STRUCTURE instance variable SENSOR')
    ctx.find_block_by_number(1)  # set block 1 as search context
    try:
        sym = ctx.find_symbol_by_name('SENSOR')
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
    if '--help' in sys.argv or '-h' in sys.argv:
        print(__doc__)
        sys.exit(0)

    member    = 'NAVCOMP'
    temp_file = None

    if len(sys.argv) >= 2:
        sdf_path = sys.argv[1]
        if len(sys.argv) >= 3:
            member = sys.argv[2]
        if os.path.exists(sdf_path):
            demo_read(sdf_path, member)
            return
    else:
        fd, sdf_path = tempfile.mkstemp(suffix='.sdf', prefix='sdfpkg_demo_')
        os.close(fd)
        temp_file = sdf_path

    try:
        demo_write(sdf_path, member)
        demo_read(sdf_path, member)
    finally:
        if temp_file and os.path.exists(temp_file):
            os.unlink(temp_file)
            print(f'Temporary file removed.')


if __name__ == '__main__':
    main()
