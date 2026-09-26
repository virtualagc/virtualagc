#!/usr/bin/env python3
"""
License:    Public Domain, no restrictions believed to exist.
Filename:   fc-bus-survey.py
Purpose:    Recover every (bus command, reply length) pair from the PASS bus
            programs, so a device model answers with the length the flight
            software actually armed for instead of a guess.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).

Usage:      fc-bus-survey.py <SSSRC directory> [--c] [--conflicts]

WHY THIS EXISTS.  A device model is handed a bus COMMAND and must produce a
reply, but the command does not say how long the reply is: FIOMTURD's count
field is 38 and the '#MIN' that arms its receive asks for seven.  yaGPC2 used
to answer anything it did not recognise with sixty-four words, "generous"
because the length was believed unknowable -- and that was wrong for nearly
every command it answered.  The MDM return word arms ONE word and was handed
sixty-four, 4,693 times in a single five-computer run.

The length is not unknowable.  It is written down, twice: at run time in the
BCE that issued the command, and statically HERE, in the bus program, where
the arm and its command sit on consecutive lines.  A run-time lookup is the
more robust of the two -- it is right for any build and needs no table -- but
it cannot give a command a NAME, and names are what let a model say "never
answer this one".  That matters: FIOHIBAD is a read of a channel that is not
there, which PASS branches to deliberately in order to stop a BCE ("THE
INSTRUCTIONS ARE LEGAL BUT WILL CAUSE AN INITIAL TIMEOUT I/O ERROR", FIOHFEPG),
and a model that answers it defeats the flight software's own fault isolation.

WHAT THE GRAMMAR IS, from the sources and from iop_bce_instr.c's exec_MIN,
which fetches the companion command at pc+2 -- so the pairing is ADJACENCY and
nothing else:

    #MIN  0,6                 arm a receive of 6+1 words at buffer+0
    #MINC FIOFFIUA,FIOMTURD   ...and the command it is for

    #CMDI FIOFFIUA,FIOMDMRT   a command with NO receive (sets a listener's
                              IUAR); answering one puts words on the wire
                              that nobody asked for
    #RDLI 6                   a listener's receive; it has no command of its
                              own, it takes the commander's

A COMMAND WORD IS (IUA << 19) | FIELD, the same arithmetic iop.c's
mia_xmit_cmd uses.  The same FIELD at a different IUA is a different device,
so FIOMDMRT appears several times over and each is its own entry.

WHAT THIS IS NOT.  It reads ONE source tree; a build whose equates differ will
differ here.  Every pair it reports is checkable against that tree, and the
run-time count is what the model actually uses -- this is the cross-check and
the source of names, not the authority.
"""
import os, re, sys, collections

EQU_HEX = re.compile(r"^(\w+)\s+EQU\s+X'([0-9A-Fa-f]+)'")
EQU_DEC = re.compile(r"^(\w+)\s+EQU\s+(\d+)\s*(?:\s|$)")
INSTR   = re.compile(r"#(MIN|MINC|MOUT|MOUTC|RDLI|RDL|CMDI|CMD)\b[ \t]*([^\s]*)")


def load_equates(srcdir):
    """Every EQU in the tree, with the ones that disagree called out: BCEEQU is
    copied into many files and they are supposed to agree."""
    vals, conflict = {}, collections.defaultdict(set)
    for name in sorted(os.listdir(srcdir)):
        if not name.endswith('.asm'):
            continue
        with open(os.path.join(srcdir, name), errors='replace') as fh:
            for line in fh:
                m = EQU_HEX.match(line) or EQU_DEC.match(line)
                if not m:
                    continue
                sym = m.group(1)
                v = int(m.group(2), 16 if m is EQU_HEX or "'" in line else 10)
                if sym in vals and vals[sym] != v:
                    conflict[sym].add(vals[sym]); conflict[sym].add(v)
                vals.setdefault(sym, v)
    return vals, conflict


def value_of(expr, equ):
    """SYM, a number, or the one arithmetic the sources use: SYM*256+6."""
    expr = expr.strip()
    if not expr:
        return None
    m = re.fullmatch(r'(\w+)\*(\d+)\+(\d+)', expr)
    if m:
        base = equ.get(m.group(1))
        return None if base is None else base * int(m.group(2)) + int(m.group(3))
    if re.fullmatch(r'\d+', expr):
        return int(expr)
    return equ.get(expr)


def survey(srcdir):
    equ, conflict = load_equates(srcdir)
    reads, commands, unresolved = {}, {}, collections.Counter()
    for name in sorted(os.listdir(srcdir)):
        # The bus programs are the FIO...PG members; nothing else contains
        # BCE instructions.
        if not (name.startswith('FIO') and name.endswith('PG.asm')):
            continue
        prev = None                      # ('MIN', words) when one is pending
        with open(os.path.join(srcdir, name), errors='replace') as fh:
            for line in fh:
                if line.lstrip().startswith('*') or not line.strip():
                    continue             # a comment is not an instruction
                m = INSTR.search(line)
                if not m:
                    prev = None          # any other instruction breaks the pair
                    continue
                op, args = m.group(1), m.group(2)
                if op == 'MIN':
                    f = args.split(',')
                    prev = ('MIN', int(f[-1]) + 1) if f and f[-1].isdigit() else None
                    continue
                if op in ('MINC', 'CMDI') and ',' in args:
                    iua_s, cmd_s = args.split(',', 1)
                    iua, field = value_of(iua_s, equ), value_of(cmd_s, equ)
                    if iua is None or field is None:
                        unresolved[cmd_s] += 1
                        prev = None
                        continue
                    word = ((iua & 0x1f) << 19) | (field & 0x7ffff)
                    sym = cmd_s.strip()
                    if op == 'MINC' and prev and prev[0] == 'MIN':
                        # A COMMANDED READ, and its length.
                        reads.setdefault(word, {'words': set(), 'sym': sym,
                                                'files': set()})
                        reads[word]['words'].add(prev[1])
                        reads[word]['files'].add(name)
                    else:
                        # A command with no receive: NOT a read.
                        commands.setdefault(word, {'sym': sym, 'files': set()})
                        commands[word]['files'].add(name)
                prev = None
    return equ, conflict, reads, commands, unresolved


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 1
    srcdir = argv[1]
    equ, conflict, reads, commands, unresolved = survey(srcdir)
    want_c = '--c' in argv

    if not want_c:
        print("equates: %d (%d disagree between files)" % (len(equ), len(conflict)))
        if '--conflicts' in argv:
            for sym, vs in sorted(conflict.items()):
                print("   %-9s %s" % (sym, ", ".join("%#x" % v for v in sorted(vs))))
        print("\nCOMMANDED READS -- %d, each with the length its '#MIN' arms:" % len(reads))
        for w in sorted(reads):
            r = reads[w]
            ws = sorted(r['words'])
            flag = "  <-- DISAGREES" if len(ws) > 1 else ""
            print("   %06x  iua=%2d  %-9s %-14s %s%s"
                  % (w, (w >> 19) & 0x1f, r['sym'],
                     ",".join(str(x) for x in ws) + " word(s)",
                     ",".join(sorted(r['files'])), flag))
        print("\nCOMMANDS WITH NO RECEIVE -- %d.  A model must NOT answer these:"
              % len(commands))
        for w in sorted(commands):
            c = commands[w]
            print("   %06x  iua=%2d  %-9s %s"
                  % (w, (w >> 19) & 0x1f, c['sym'], ",".join(sorted(c['files']))))
        if unresolved:
            print("\nunresolved operands: %s"
                  % ", ".join("%s x%d" % kv for kv in unresolved.most_common(8)))
        return 0

    # C form, for pasting into a model.
    print("/* Generated by fc-bus-survey.py from the PASS bus programs. */")
    print("static const struct { uint32_t cmd; int words; const char *sym; }")
    print("FC_BUS_READS[] = {")
    for w in sorted(reads):
        r = reads[w]
        for n in sorted(r['words']):
            print("    { 0x%06xu, %2d, \"%s\" },   /* %s */"
                  % (w, n, r['sym'], ",".join(sorted(r['files']))))
    print("};")
    print("\n/* Commands with no receive: never answer one. */")
    print("static const struct { uint32_t cmd; const char *sym; }")
    print("FC_BUS_COMMANDS[] = {")
    for w in sorted(commands):
        print("    { 0x%06xu, \"%s\" }," % (w, commands[w]['sym']))
    print("};")
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
