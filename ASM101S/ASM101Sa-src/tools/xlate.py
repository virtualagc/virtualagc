#!/usr/bin/env python3
"""Mechanically translate TatSu's generated parser_asm.py into C that drives
the peg.c runtime.  The generated file is entirely regular -- a handful of
statement forms and three block constructs -- so a translation is safer than a
hand transliteration of 2330 lines and can be re-run if the grammar changes."""

import ast as pyast
import re
import sys

SRC = sys.argv[1]
OUT = sys.argv[2]

lines = open(SRC).read().split("\n")

# ---------------------------------------------------------------- tokenizing
# Collect the rule bodies.  A rule is `    def _NAME_(self):` at indent 4,
# preceded by `@tatsumasu()`.
rules = []          # (name, [ (indent, text), ... ])
i = 0
while i < len(lines):
    m = re.match(r"^    def _([A-Za-z0-9_]+)_\(self\):\s*$", lines[i])
    if m:
        name = m.group(1)
        body = []
        i += 1
        while i < len(lines):
            line = lines[i]
            if line.strip() == "":
                i += 1
                continue
            indent = len(line) - len(line.lstrip())
            if indent <= 4:
                break
            body.append((indent, line.strip(), line))
            i += 1
        rules.append((name, body))
        continue
    i += 1

# ------------------------------------------------------------------ patterns
patterns = []       # distinct regex source strings, in order of first use


def pattern_id(p):
    if p not in patterns:
        patterns.append(p)
    return patterns.index(p)


def pystr(text):
    """Evaluate a Python string literal (possibly implicitly concatenated)."""
    return pyast.literal_eval(text)


def cstr(s):
    out = []
    for ch in s:
        if ch == '"':
            out.append('\\"')
        elif ch == '\\':
            out.append('\\\\')
        elif ch == '\n':
            out.append('\\n')
        elif ch == '\t':
            out.append('\\t')
        elif ord(ch) < 0x20 or ord(ch) > 0x7E:
            out.append('\\%03o' % ord(ch))
        else:
            out.append(ch)
    return '"' + "".join(out) + '"'


# ------------------------------------------------------------------ emitting
blocks = []         # (cname, [statements]) hoisted closure bodies
name_lists = {}     # tuple of names -> C identifier
name_list_order = []


def name_list(names):
    key = tuple(names)
    if not names:
        return "NULL"
    if key not in name_lists:
        ident = "nl%d" % len(name_lists)
        name_lists[key] = ident
        name_list_order.append((ident, names))
    return name_lists[key]


def emit_body(rule, body, start, indent, out, depth):
    """Emit C for the statements of `body` at indentation `indent`, starting at
    index `start`.  Returns the index just past the last statement consumed."""
    i = start
    pad = "  " * (depth + 1)
    while i < len(body):
        ind, text, _raw = body[i]
        if ind < indent:
            break
        if ind > indent:
            raise SystemExit("unexpected indent in %s: %r" % (rule, text))

        if text == "with self._choice():":
            out.append(pad + "PEG_CHOICE_BEGIN (c)")
            i = emit_body(rule, body, i + 1, indent + 4, out, depth + 1)
            out.append(pad + "PEG_CHOICE_END (c)")
            continue
        if text == "with self._option():":
            out.append(pad + "PEG_OPTION_BEGIN (c)")
            out.append(pad + "{")
            i = emit_body(rule, body, i + 1, indent + 4, out, depth + 1)
            out.append(pad + "}")
            out.append(pad + "PEG_OPTION_END (c)")
            continue
        if text == "with self._optional():":
            out.append(pad + "PEG_OPTIONAL_BEGIN (c)")
            out.append(pad + "{")
            i = emit_body(rule, body, i + 1, indent + 4, out, depth + 1)
            out.append(pad + "}")
            out.append(pad + "PEG_OPTIONAL_END (c)")
            continue
        if text == "with self._group():":
            out.append(pad + "PEG_GROUP_BEGIN (c)")
            i = emit_body(rule, body, i + 1, indent + 4, out, depth + 1)
            out.append(pad + "PEG_GROUP_END (c)")
            continue

        m = re.match(r"^def (block\d+)\(\):$", text)
        if m:
            blockName = "blk_%s_%s" % (rule, m.group(1))
            sub = []
            i = emit_body(rule, body, i + 1, indent + 4, sub, 0)
            blocks.append((blockName, sub))
            continue

        m = re.match(r"^self\._closure\((block\d+)\)$", text)
        if m:
            out.append(pad + "peg_closure (c, blk_%s_%s);" % (rule, m.group(1)))
            i += 1
            continue

        m = re.match(r"^self\._token\((.*)\)$", text)
        if m:
            out.append(pad + "peg_token (c, %s);" % cstr(pystr(m.group(1))))
            i += 1
            continue

        m = re.match(r"^self\._pattern\((.*)\)$", text)
        if m:
            out.append(pad + "peg_pattern (c, pat%d);"
                       % pattern_id(pystr(m.group(1))))
            i += 1
            continue

        if text == "self._check_eof()":
            out.append(pad + "peg_check_eof (c);")
            i += 1
            continue

        m = re.match(r"^self\.add_last_node_to_name\((.*)\)$", text)
        if m:
            out.append(pad + "peg_add_last_node_to_name (c, %s);"
                       % cstr(pystr(m.group(1))))
            i += 1
            continue

        m = re.match(r"^self\.name_last_node\((.*)\)$", text)
        if m:
            out.append(pad + "peg_name_last_node (c, %s);"
                       % cstr(pystr(m.group(1))))
            i += 1
            continue

        if text.startswith("self._error("):
            # A multi-line call whose argument is only a message.
            depthParen = text.count("(") - text.count(")")
            i += 1
            while depthParen > 0 and i < len(body):
                depthParen += body[i][1].count("(") - body[i][1].count(")")
                i += 1
            out.append(pad + "peg_fail (c);")
            continue

        if text.startswith("self._define("):
            # Written either on one line or spread over four; both occur.
            collected = text[len("self._define("):]
            depthParen = 1 + collected.count("(") - collected.count(")")
            i += 1
            while depthParen > 0 and i < len(body):
                seg = body[i][1]
                depthParen += seg.count("(") - seg.count(")")
                collected += seg
                i += 1
            collected = collected.rstrip()
            if collected.endswith(")"):
                collected = collected[:-1]
            args = pyast.literal_eval("[" + collected.rstrip().rstrip(",") + "]")
            keys = args[0] if len(args) > 0 else []
            listKeys = args[1] if len(args) > 1 else []
            out.append(pad + "peg_define (c, %s, %s);"
                       % (name_list(keys), name_list(listKeys)))
            continue

        m = re.match(r"^self\._([A-Za-z0-9_]+)_\(\)$", text)
        if m:
            out.append(pad + "r_%s (c);" % m.group(1))
            i += 1
            continue

        raise SystemExit("unhandled statement in %s: %r" % (rule, text))
    return i


ruleOut = []
for name, body in rules:
    out = []
    emit_body(name, body, 0, 8, out, 0)
    ruleOut.append((name, out))

# ------------------------------------------------------------------- writing
f = open(OUT, "w")
w = f.write

w("""/*
 * License:    This program is declared by its author, Ronald Burkey, to be the
 *             U.S. Public Domain, and may be freely used, modified, or
 *             distributed for any purpose whatever.
 * Filename:   parser_asm.c
 * Purpose:    The parser for the AP-101S assembly-language grammar.
 * Contact:    info@sandroid.org
 *
 * WARNING: CAVEAT UTILITOR
 *
 *   This file was generated mechanically from parser_asm.py -- itself
 *   generated by TatSu from the grammar in fieldParser.py -- by the script
 *   tools/xlate.py.  Any change made here will be overwritten the next time
 *   it is regenerated.  Change the grammar in fieldParser.py instead, run
 *   `fieldParser.py --generate` to renew parser_asm.py, and re-run the
 *   translator.
 *
 *   The statement-for-statement correspondence with parser_asm.py is
 *   deliberate:  the two can be read side by side, which is the only
 *   practical way to check that a grammar of this size was carried over
 *   correctly.
 */

#include "peg.h"
#include "pattern.h"
#include "parser_asm.h"

""")

# forward declarations
w("/* Forward declarations for every rule and every closure body. */\n")
for name, _ in rules:
    w("static void r_%s (PegCtx *c);\n" % name)
w("\n")
for name, _ in blocks:
    w("static void %s (PegCtx *c);\n" % name)
w("\n")

w("/* The name lists handed to `_define`. */\n")
for ident, names in name_list_order:
    w("static const char *const %s[] = { %s NULL };\n"
      % (ident, "".join('"%s", ' % n for n in names)))
w("\n")

w("/* Closure bodies, hoisted out of the rules that define them. */\n")
for name, out in blocks:
    w("static void\n%s (PegCtx *c)\n{\n" % name)
    for line in out:
        w("  " + line + "\n")
    w("}\n\n")

w("/* The rules. */\n")
for index, (name, out) in enumerate(ruleOut):
    w("static void\nr_%s_body (PegCtx *c)\n{\n" % name)
    for line in out:
        w(line + "\n")
    w("}\n\n")
    w("static void\nr_%s (PegCtx *c)\n{\n" % name)
    w("  peg_call (c, %d, \"%s\", r_%s_body);\n" % (index, name, name))
    w("}\n\n")

w("/* The rule table, for parserASM's lookup by name. */\n")
w("const AsmRule asmRules[] = {\n")
for name, _ in rules:
    w('  { "%s", r_%s },\n' % (name, name))
w("  { NULL, NULL }\n};\n")

f.close()

sys.stderr.write("rules=%d blocks=%d patterns=%d\n"
                 % (len(rules), len(blocks), len(patterns)))
sys.stderr.write("PATTERNS:\n")
for n, p in enumerate(patterns):
    sys.stderr.write("  pat%-3d %r\n" % (n, p))
