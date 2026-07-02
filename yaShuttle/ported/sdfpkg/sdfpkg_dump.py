#!/usr/bin/env python3
"""
sdfpkg_dump.py  --  Human-readable dump of a sdfpkg flat file.

Reads an SDF in the sdfpkg synthetic flat-file format and produces a
formatted report covering the file index, directory root cell, all
blocks, all symbols (with type details), and all statements.

Usage:
  ./sdfpkg_dump.py [--help] [options] <file.sdf> [member ...]

Options:
  --help, -h          Print this help and exit.
  --no-blocks         Omit the block table.
  --no-symbols        Omit the symbol table.
  --no-stmts          Omit the statement table.
  --no-index          Omit the flat-file index header.
  --brief             Equivalent to --no-stmts (shorter output).
  --out FILE, -o FILE Write output to FILE instead of stdout.

If member names are given (case-insensitive), only those members are
dumped; otherwise all members in the file are dumped.

Exit codes:
  0  All requested members dumped successfully.
  1  One or more members could not be read.
  2  File could not be opened.
"""

import sys
import struct
import textwrap
from sdfpkg import (
    SdfContext, SdfError,
    RC_NOT_EXEC,
    DISP_NONE,
    flat_info,
    PAGE_SIZE,
)

# ---------------------------------------------------------------------------
# Encoding tables
# ---------------------------------------------------------------------------

BLK_CLASS = {
    1: 'PROGRAM',    2: 'FUNCTION',   3: 'PROCEDURE',
    4: 'TASK',       5: 'COMPOOL',    6: 'CLOSE BLOCK',
}
BLK_TYPE = {}   # no standard values documented; show numeric

SYM_CLASS = {
    1: 'variable',    2: 'equate-ext',  3: 'template',
    4: 'label',       6: 'compool',
}
SYM_TYPE = {
    1: 'SCALAR',      2: 'INTEGER',     3: 'BOOLEAN',
    4: 'CHARACTER',   5: 'BIT',         6: 'VECTOR',
    7: 'MATRIX',      8: 'equate-ext',  9: 'EVENT',
    10: 'STRUCTURE',  11: 'TASK',
}
STMT_TYPE = {
    1:  'ASSIGNMENT',   2:  'IF',        3:  'DO',
    4:  'DO WHILE',     5:  'DO UNTIL',  6:  'DO FOR',
    7:  'END',          8:  'RETURN',    9:  'CALL',
    10: 'GOTO',         11: 'ON ERROR',
}

def _blk_class_str(v):
    return BLK_CLASS.get(v, f'class={v}')

def _sym_class_str(v):
    return SYM_CLASS.get(v, f'class={v}')

def _sym_type_str(sym):
    base = SYM_TYPE.get(sym.sym_type, f'type={sym.sym_type}')
    t = sym.sym_type
    c = sym.sym_class
    # NAME variable: sym_class=4 (LABEL), sym_type = type of referent
    if c == 4:
        referent = SYM_TYPE.get(t, f'type={t}')
        return f'NAME({referent})'
    # EQUATE_EXT: class=2, type=8
    if c == 2 and t == 8:
        return 'EQUATE EXT'
    if t == 6:   # VECTOR
        return f'VECTOR({sym.rows})' if sym.rows else 'VECTOR'
    if t == 7:   # MATRIX
        if sym.rows and sym.columns:
            return f'MATRIX({sym.rows},{sym.columns})'
        return 'MATRIX'
    if t == 4:   # CHARACTER
        return f'CHARACTER({sym.columns})' if sym.columns else 'CHARACTER'
    if t == 5:   # BIT
        return f'BIT({sym.rows})' if sym.rows else 'BIT'
    if t == 9:   # EVENT
        return 'EVENT'
    if t == 11:  # TASK
        return 'TASK'
    return base

def _stmt_type_str(v):
    return STMT_TYPE.get(v, f'type={v}')

def _srn_str(b):
    if not b:
        return ''
    return b.rstrip(b' ').decode('ascii', errors='replace')

def _flags_str(f1, f2, f3, f4):
    parts = []
    if f1: parts.append(f'F1=0x{f1:02X}')
    if f2: parts.append(f'F2=0x{f2:02X}')
    if f3: parts.append(f'F3=0x{f3:02X}')
    if f4: parts.append(f'F4=0x{f4:02X}')
    return ' '.join(parts) if parts else '—'

# ---------------------------------------------------------------------------
# Report sections
# ---------------------------------------------------------------------------

SEP_THICK  = '=' * 72
SEP_THIN   = '-' * 72
SEP_MED    = '─' * 72

def _header(out, text):
    print(SEP_THICK,         file=out)
    print(f'  {text}',       file=out)
    print(SEP_THICK,         file=out)

def _section(out, text):
    print(file=out)
    print(SEP_THIN,          file=out)
    print(f'  {text}',       file=out)
    print(SEP_THIN,          file=out)


def dump_index(out, sdf_path):
    """Print the flat-file member index."""
    members = flat_info(sdf_path)
    _section(out, f'Flat-file index  ({sdf_path})')
    print(f'  {"MEMBER":<10}  {"PAGES":>6}  {"OFFSET":>12}  {"BYTES":>8}  {"VER":>3}', file=out)
    print(f'  {"-"*10}  {"-"*6}  {"-"*12}  {"-"*8}  {"-"*3}', file=out)
    for m in members:
        print(f'  {m["name"]:<10}  {m["page_count"]:>6}  '
              f'{m["offset"]:>12}  {m["page_count"]*PAGE_SIZE:>8}  {m["version"]:>3}', file=out)
    print(f'\n  Total members: {len(members)}', file=out)


def dump_member(out, ctx, member_name, show_blocks, show_symbols, show_stmts,
                version=None):
    """Dump one member's contents."""
    _header(out, f'Member: {member_name}')

    # --- Directory root cell ---
    root = ctx.locate_root()
    sdf_flags  = (root[0] << 8) | root[1]
    last_page  = struct.unpack_from('>H', root, 2)[0]
    blk_nodes  = struct.unpack_from('>H', root, 16)[0]
    sym_nodes  = struct.unpack_from('>H', root, 18)[0]
    fstmt      = struct.unpack_from('>H', root, 52)[0]
    lstm       = struct.unpack_from('>H', root, 54)[0]
    has_srns   = bool(sdf_flags & 0x8000)
    nonmono    = bool(sdf_flags & 0x0400)

    _section(out, 'Directory root cell (DROOTCEL)')
    if version is not None:
        print(f'  Version      : {version}', file=out)
    print(f'  SDF flags    : 0x{sdf_flags:04X}', file=out)
    print(f'    HAS_SRNS   : {has_srns}', file=out)
    print(f'    NONMONO    : {nonmono}', file=out)
    print(f'  Last page    : {last_page}', file=out)
    print(f'  Block nodes  : {blk_nodes}', file=out)
    print(f'  Symbol nodes : {sym_nodes}', file=out)
    print(f'  Stmt range   : {fstmt} .. {lstm}  '
          f'({lstm - fstmt + 1} statements)', file=out)

    # --- Blocks ---
    if show_blocks and blk_nodes > 0:
        _section(out, f'Blocks  ({blk_nodes})')
        hdr = (f'  {"#":>3}  {"CSECT":<10}  {"CLASS":<12}  '
               f'{"ID":>4}  {"NAME":<24}  {"SYMBS":>9}  {"STMTS":>9}  FLAGS')
        print(hdr, file=out)
        print(f'  {"-"*3}  {"-"*10}  {"-"*12}  {"-"*4}  {"-"*24}  '
              f'{"-"*9}  {"-"*9}  {"-"*6}', file=out)
        for blk_no in range(1, blk_nodes + 1):
            try:
                blk = ctx.find_block_by_number(blk_no)
                cls = _blk_class_str(blk.blk_class)
                srange = (f'{blk.fsymb_no}..{blk.lsymb_no}'
                          if blk.fsymb_no else '—')
                trange = (f'{blk.fstmt_no}..{blk.lstm_no}'
                          if blk.fstmt_no else '—')
                flags  = f'0x{blk.blk_flags:02X}' if blk.blk_flags else '—'
                print(f'  {blk.blk_no:>3}  {blk.csect_name:<10}  {cls:<12}  '
                      f'{blk.blk_id:>4}  {blk.blk_name:<24}  {srange:>9}  '
                      f'{trange:>9}  {flags}', file=out)
            except SdfError as e:
                print(f'  {blk_no:>3}  ERROR: {e}', file=out)

    # --- Symbols ---
    if show_symbols and sym_nodes > 0:
        _section(out, f'Symbols  ({sym_nodes})')
        hdr = (f'  {"#":>3}  {"NAME":<20}  {"CLASS":<12}  {"TYPE":<18}  '
               f'{"BLK":>3}  FLAGS       RELADDR')
        print(hdr, file=out)
        print(f'  {"-"*3}  {"-"*20}  {"-"*12}  {"-"*18}  '
              f'{"-"*3}  {"-"*10}  {"-"*7}', file=out)
        for symb_no in range(1, sym_nodes + 1):
            try:
                sym  = ctx.find_symbol_by_number(symb_no)
                cls  = _sym_class_str(sym.sym_class)
                typ  = _sym_type_str(sym)
                flgs = _flags_str(sym.flag1, sym.flag2, sym.flag3, sym.flag4)
                # rel_addr is available via raw memoryview; we read from the
                # internal SDC access path if needed — for display we show
                # it from the SymbolResult's raw data via locate().
                # SymbolResult doesn't expose rel_addr directly; skip for now.
                print(f'  {sym.symb_no:>3}  {sym.symb_name:<20}  {cls:<12}  '
                      f'{typ:<18}  {sym.blk_no:>3}  {flgs}', file=out)
            except SdfError as e:
                print(f'  {symb_no:>3}  ERROR: {e}', file=out)

    # --- Statements ---
    if show_stmts and fstmt > 0:
        _section(out, f'Statements  ({lstm - fstmt + 1}, range {fstmt}..{lstm})')
        if has_srns:
            hdr = (f'  {"#":>4}  {"SRN":<8}  {"INCL":>4}  {"TYPE":<14}  '
                   f'{"EXEC":>4}  {"LABLS":>5}  {"LHS":>3}  BLK')
        else:
            hdr = (f'  {"#":>4}  {"TYPE":<14}  {"EXEC":>4}  '
                   f'{"LABLS":>5}  {"LHS":>3}  BLK')
        print(hdr, file=out)
        sep = (f'  {"-"*4}  {"-"*8}  {"-"*4}  {"-"*14}  {"-"*4}  '
               f'{"-"*5}  {"-"*3}  {"-"*3}') if has_srns else \
              (f'  {"-"*4}  {"-"*14}  {"-"*4}  {"-"*5}  {"-"*3}  {"-"*3}')
        print(sep, file=out)

        for stmt_no in range(fstmt, lstm + 1):
            try:
                stmt = ctx.find_stmt_by_number(stmt_no)
                srn  = _srn_str(stmt.srn)
                typ  = _stmt_type_str(stmt.stmt_type)
                if has_srns:
                    print(f'  {stmt.stmt_no:>4}  {srn:<8}  {stmt.incl_cnt:>4}  '
                          f'{typ:<14}  {"yes":>4}  {stmt.num_labls:>5}  '
                          f'{stmt.num_lhs:>3}  {stmt.blk_no}', file=out)
                else:
                    print(f'  {stmt.stmt_no:>4}  {typ:<14}  {"yes":>4}  '
                          f'{stmt.num_labls:>5}  {stmt.num_lhs:>3}  '
                          f'{stmt.blk_no}', file=out)
            except SdfError as e:
                if e.code == RC_NOT_EXEC:
                    # Non-executable: retrieve SRN from node (mode 17)
                    try:
                        node = ctx.find_stmt_node_by_number(stmt_no)
                        srn  = _srn_str(node.srn)
                    except SdfError:
                        srn = ''
                    if has_srns:
                        print(f'  {stmt_no:>4}  {srn:<8}  {"—":>4}  '
                              f'{"(non-exec)":<14}  {"no":>4}  {"—":>5}  '
                              f'{"—":>3}  —', file=out)
                    else:
                        print(f'  {stmt_no:>4}  {"(non-exec)":<14}  {"no":>4}  '
                              f'{"—":>5}  {"—":>3}  —', file=out)
                else:
                    print(f'  {stmt_no:>4}  ERROR: {e}', file=out)

    # --- Statistics ---
    _section(out, 'I/O statistics')
    reads, writes, selects = ctx.stats()
    print(f'  Page reads   : {reads}',   file=out)
    print(f'  Page writes  : {writes}',  file=out)
    print(f'  Select calls : {selects}', file=out)
    print(file=out)


# ---------------------------------------------------------------------------
# Argument parsing (no external dependencies)
# ---------------------------------------------------------------------------

def _parse_args(argv):
    args = argv[1:]
    if not args or '--help' in args or '-h' in args:
        print(__doc__)
        sys.exit(0)

    show_blocks  = True
    show_symbols = True
    show_stmts   = True
    show_index   = True
    out_path     = None
    members      = []
    sdf_path     = None

    i = 0
    while i < len(args):
        a = args[i]
        if   a == '--no-blocks':   show_blocks  = False
        elif a == '--no-symbols':  show_symbols = False
        elif a == '--no-stmts':    show_stmts   = False
        elif a == '--no-index':    show_index   = False
        elif a == '--brief':       show_stmts   = False
        elif a in ('--out', '-o'):
            i += 1
            if i >= len(args):
                print('error: --out requires a filename', file=sys.stderr)
                sys.exit(2)
            out_path = args[i]
        elif a.startswith('--'):
            print(f'error: unknown option {a!r}', file=sys.stderr)
            sys.exit(2)
        elif sdf_path is None:
            sdf_path = a
        else:
            members.append(a)
        i += 1

    if sdf_path is None:
        print('error: no SDF file specified', file=sys.stderr)
        print("Run 'sdfpkg_dump.py --help' for usage.", file=sys.stderr)
        sys.exit(2)

    return sdf_path, members, show_blocks, show_symbols, show_stmts, \
           show_index, out_path


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main():
    sdf_path, member_filter, show_blocks, show_symbols, show_stmts, \
        show_index, out_path = _parse_args(sys.argv)

    # Open output
    if out_path:
        try:
            out = open(out_path, 'w', encoding='utf-8')
        except OSError as e:
            print(f'error: cannot open output file {out_path!r}: {e}',
                  file=sys.stderr)
            sys.exit(2)
    else:
        out = sys.stdout

    try:
        # Validate file exists and is readable
        try:
            all_members = flat_info(sdf_path)
        except (OSError, ValueError) as e:
            print(f'error: cannot read {sdf_path!r}: {e}', file=sys.stderr)
            sys.exit(2)

        # Determine which members to dump
        if member_filter:
            upper = {m.upper() for m in member_filter}
            to_dump = [m for m in all_members
                       if m['name'].upper() in upper]
            missing = upper - {m['name'].upper() for m in to_dump}
            for name in sorted(missing):
                print(f'warning: member {name!r} not found in {sdf_path}',
                      file=sys.stderr)
        else:
            to_dump = all_members

        if not to_dump:
            print('error: no members to dump', file=sys.stderr)
            sys.exit(1)

        # Print flat-file index
        if show_index:
            dump_index(out, sdf_path)

        # Dump each member
        any_error = False
        with SdfContext.open(sdf_path) as ctx:
            for m in to_dump:
                try:
                    ctx.select(m['name'])
                    dump_member(out, ctx, m['name'],
                                show_blocks, show_symbols, show_stmts,
                                version=m['version'])
                except SdfError as e:
                    print(f'\nERROR dumping member {m["name"]!r}: {e}',
                          file=out)
                    any_error = True

        sys.exit(1 if any_error else 0)

    finally:
        if out_path and out is not sys.stdout:
            out.close()


if __name__ == '__main__':
    main()
