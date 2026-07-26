#!/usr/bin/env python3
"""Convert generic IOP (BCE/MSC) exec fixtures into a C header.

Unlike the CPU instruction fixtures, decode and exec are fused in both
BCEInstruction#exec and MSCInstruction#exec (no standalone decode to
validate separately), so these fixtures drive bce_instr_exec()/
msc_instr_exec() directly — the full entry point, including its own
internal decode.
"""
import json
import sys

MAX_LS_DIFF = 20
MAX_MEM_DIFF = 60
REG_NAMES = ['regXmitEna', 'regRecvEna', 'regProgExcept', 'regBusyWait', 'regHalt', 'regIndicator', 'regFailDisc', 'regIntProg']


def main():
    data = json.load(open(sys.argv[1]))
    guard = sys.argv[2] if len(sys.argv) > 2 else "YAGPC_TEST_IOP_EXEC_FIXTURES_H"
    print(f"#ifndef {guard}")
    print(f"#define {guard}")
    print()
    print("#include <stdbool.h>")
    print("#include <stdint.h>")
    print()

    bl = data['baseline']
    print("typedef struct { uint32_t ls[25][17]; uint16_t mem[4096];")
    print("    uint32_t regXmitEna, regRecvEna, regProgExcept, regBusyWait, regHalt, regIndicator, regFailDisc, regIntProg;")
    print("    bool iopProg; } IopExecBaseline;")
    ls_c = ", ".join("{" + ", ".join(str(x) for x in row) + "}" for row in bl['ls'])
    mem_c = ", ".join(str(x) for x in bl['mem'])
    print(f"static const IopExecBaseline IOP_EXEC_BASELINE = {{ {{{ls_c}}}, {{{mem_c}}}, "
          f"{bl['regXmitEna']}u, {bl['regRecvEna']}u, {bl['regProgExcept']}u, {bl['regBusyWait']}u, "
          f"{bl['regHalt']}u, {bl['regIndicator']}u, {bl['regFailDisc']}u, {bl['regIntProg']}u, "
          f"{'true' if bl['iopProg'] else 'false'} }};")
    print()

    print(f"#define MAX_LS_DIFF {MAX_LS_DIFF}")
    print(f"#define MAX_MEM_DIFF {MAX_MEM_DIFF}")
    print("typedef struct { int page, reg; uint32_t val; } IopLsDiff;")
    print("typedef struct { uint32_t addr, val; } IopMemDiff;")
    print("typedef struct {")
    print("    uint32_t hw1, hw2;")
    print("    int page;")
    print("    int lsDiffCount; IopLsDiff lsDiff[MAX_LS_DIFF];")
    print("    int memDiffCount; IopMemDiff memDiff[MAX_MEM_DIFF];")
    print("    bool regChanged[8]; uint32_t regVal[8];")
    print("    bool iopProgAfter;")
    print("} IopExecFixture;")
    print()

    for nm, cases in data['byInstr'].items():
        cname = "IOP_EXEC_FIXTURES_" + sanitize(nm)
        print(f"static const IopExecFixture {cname}[{max(len(cases),1)}] = {{")
        for c in cases:
            ld = c['lsDiff']
            md = c['memDiff']
            assert len(ld) <= MAX_LS_DIFF, f"{nm}: bump MAX_LS_DIFF (need {len(ld)})"
            assert len(md) <= MAX_MEM_DIFF, f"{nm}: bump MAX_MEM_DIFF (need {len(md)})"
            ld_c = "{" + ", ".join("{%d,%d,%uu}" % (x[0], x[1], x[2]) for x in ld) + "}" if ld else "{{0,0,0}}"
            md_c = "{" + ", ".join("{%uu,%uu}" % (x[0], x[1]) for x in md) + "}" if md else "{{0,0}}"
            regByName = {n: v for n, v in c['regDiff']}
            changed_c = "{" + ", ".join("true" if n in regByName else "false" for n in REG_NAMES) + "}"
            val_c = "{" + ", ".join("%uu" % regByName.get(n, 0) for n in REG_NAMES) + "}"
            print("    { %uu, %uu, %d, %d, %s, %d, %s, %s, %s, %s }," % (
                c['hw1'], c['hw2'], c['page'], len(ld), ld_c, len(md), md_c, changed_c, val_c,
                'true' if c['iopProgAfter'] else 'false'))
        if not cases:
            print("    { 0 },")
        print("};")
        print()

    print("typedef struct { const char *nm; const IopExecFixture *fixtures; int count; } IopExecFixtureSet;")
    print(f"static const IopExecFixtureSet IOP_EXEC_FIXTURE_SETS[{len(data['byInstr'])}] = {{")
    for nm, cases in data['byInstr'].items():
        print('    { "%s", IOP_EXEC_FIXTURES_%s, %d },' % (nm, sanitize(nm), len(cases)))
    print("};")
    print()
    print("#endif")


def sanitize(nm):
    return ''.join(c if c.isalnum() else '_' for c in nm)


if __name__ == "__main__":
    main()
