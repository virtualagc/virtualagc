#!/usr/bin/env python3
"""Convert generic per-instruction exec fixtures into a C header.

Since instr_decode() is already fully validated (see
cpu_instr_decode_fixtures.h), fixtures here only need (hw1, hw2) plus the
expected register/memory/PSW deltas — the C test re-decodes and calls the
matched InstrDesc's exec function directly.
"""
import json
import sys

MAX_REG_DIFF = 12
MAX_MEM_DIFF = 24


def main():
    data = json.load(open(sys.argv[1]))
    print("#ifndef YAGPC_TEST_CPU_INSTR_EXEC_FIXTURES_H")
    print("#define YAGPC_TEST_CPU_INSTR_EXEC_FIXTURES_H")
    print()
    print("#include <stdint.h>")
    print()

    bl = data['baseline']
    print("typedef struct { uint32_t regs[3][9]; uint32_t dse[3][4]; uint16_t mem[4096]; uint32_t psw1, psw2; } ExecBaseline;")
    regs_c = ", ".join("{" + ", ".join(str(x) for x in bank) + "}" for bank in bl['regs'])
    dse_c = ", ".join("{" + ", ".join(str(x) for x in bank) + "}" for bank in bl['dse'])
    mem_c_parts = [str(x) for x in bl['mem']]
    print(f"static const ExecBaseline EXEC_BASELINE = {{ {{{regs_c}}}, {{{dse_c}}}, {{{', '.join(mem_c_parts)}}}, {bl['psw1']}u, {bl['psw2']}u }};")
    print()

    print(f"#define MAX_REG_DIFF {MAX_REG_DIFF}")
    print(f"#define MAX_MEM_DIFF {MAX_MEM_DIFF}")
    print("typedef struct { int bank, idx; uint32_t val; } ExecRegDiff;")
    print("typedef struct { uint32_t addr, val; } ExecMemDiff;")
    print("typedef struct {")
    print("    uint32_t hw1, hw2;")
    print("    int regDiffCount; ExecRegDiff regDiff[MAX_REG_DIFF];")
    print("    int memDiffCount; ExecMemDiff memDiff[MAX_MEM_DIFF];")
    print("    uint32_t psw1After, psw2After;")
    print("} ExecFixture;")
    print()

    for nm, cases in data['byInstr'].items():
        cname = f"EXEC_FIXTURES_{nm}"
        print(f"static const ExecFixture {cname}[{len(cases)}] = {{")
        for c in cases:
            rd = c['regDiff']
            md = c['memDiff']
            assert len(rd) <= MAX_REG_DIFF, f"{nm}: bump MAX_REG_DIFF (need {len(rd)})"
            assert len(md) <= MAX_MEM_DIFF, f"{nm}: bump MAX_MEM_DIFF (need {len(md)})"
            rd_c = "{" + ", ".join("{%d,%d,%uu}" % (x[0], x[1], x[2]) for x in rd) + "}" if rd else "{{0,0,0}}"
            md_c = "{" + ", ".join("{%uu,%uu}" % (x[0], x[1]) for x in md) + "}" if md else "{{0,0}}"
            print("    { %uu, %uu, %d, %s, %d, %s, %uu, %uu }," % (
                c['hw1'], c['hw2'], len(rd), rd_c, len(md), md_c, c['psw1After'], c['psw2After']))
        print("};")
        print()

    print("typedef struct { const char *nm; const ExecFixture *fixtures; int count; } ExecFixtureSet;")
    print(f"static const ExecFixtureSet EXEC_FIXTURE_SETS[{len(data['byInstr'])}] = {{")
    for nm, cases in data['byInstr'].items():
        print('    { "%s", EXEC_FIXTURES_%s, %d },' % (nm, nm, len(cases)))
    print("};")
    print()
    print("#endif")


if __name__ == "__main__":
    main()
