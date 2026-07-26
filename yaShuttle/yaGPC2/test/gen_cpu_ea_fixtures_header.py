#!/usr/bin/env python3
"""Convert cpu.coffee g_EA/g_EA_16/... JSON fixtures into a C header."""
import json
import sys


def b(v):
    return "true" if v else "false"


def main():
    data = json.load(open(sys.argv[1]))
    print("#ifndef YAGPC_TEST_CPU_EA_FIXTURES_H")
    print("#define YAGPC_TEST_CPU_EA_FIXTURES_H")
    print()
    print("#include <stdbool.h>")
    print("#include <stdint.h>")
    print()

    bl = data['baseline']
    print("typedef struct { uint32_t regs[3][9]; uint32_t dse[3][4]; uint16_t mem[4096]; uint32_t psw1, psw2; } Baseline;")
    regs_c = ", ".join("{" + ", ".join(str(x) for x in bank) + "}" for bank in bl['regs'])
    dse_c = ", ".join("{" + ", ".join(str(x) for x in bank) + "}" for bank in bl['dse'])
    mem_c_parts = [str(x) for x in bl['mem']]
    print(f"static const Baseline CPU_BASELINE = {{ {{{regs_c}}}, {{{dse_c}}}, {{{', '.join(mem_c_parts)}}}, {bl['psw1']}u, {bl['psw2']}u }};")
    print()

    print("typedef struct {")
    print("    int niaIncr, opType, addrWidth;")
    print("    bool hasI; uint32_t I;")
    print("    bool hasD; uint32_t d;")
    print("    bool hasB; uint32_t b;")
    print("    bool hasIdx; uint32_t idx, ia, ii;")
    print("} VOpts;")
    print()

    def vopts_c(o):
        hasI = 'I' in o
        hasD = 'd' in o
        hasB = 'b' in o
        hasIdx = 'i' in o
        return "{ %d, %d, %d, %s, %uu, %s, %uu, %s, %uu, %s, %uu, %uu, %uu }" % (
            o['niaIncr'], o['opType'], o['addrWidth'],
            b(hasI), o.get('I', 0),
            b(hasD), o.get('d', 0),
            b(hasB), o.get('b', 0),
            b(hasIdx), o.get('i', 0), o.get('ia', 0), o.get('ii', 0),
        )

    def regdiff_c(rd):
        return "{" + ", ".join("{%d,%d,%uu}" % (x[0], x[1], x[2]) for x in rd) + "}" if rd else "{{0,0,0}}"

    def memdiff_c(md):
        return "{" + ", ".join("{%uu,%uu}" % (x[0], x[1]) for x in md) + "}" if md else "{{0,0}}"

    print("typedef struct { int bank, idx; uint32_t val; } RegDiff;")
    print("typedef struct { uint32_t addr, val; } MemDiff;")
    print("typedef struct {")
    print("    VOpts opts; uint32_t ea; bool hasErr;")
    print("    int regDiffCount; RegDiff regDiff[4];")
    print("    int memDiffCount; MemDiff memDiff[4];")
    print("    uint32_t psw1After, psw2After;")
    print("} EaFixture;")
    print(f"static const EaFixture EA_FIXTURES[{len(data['eaCases'])}] = {{")
    for c in data['eaCases']:
        rd = c['regDiff'][:4]
        md = c['memDiff'][:4]
        assert len(c['regDiff']) <= 4 and len(c['memDiff']) <= 4, "bump array size"
        print("    { %s, %uu, %s, %d, %s, %d, %s, %uu, %uu }," % (
            vopts_c(c['opts']), c['ea'] or 0, b(c['err'] is not None),
            len(rd), regdiff_c(rd), len(md), memdiff_c(md),
            c['psw1After'], c['psw2After']))
    print("};")
    print()

    print("typedef struct {")
    print("    VOpts opts; uint32_t ea; bool hasErr;")
    print("    int regDiffCount; RegDiff regDiff[4];")
    print("    int memDiffCount; MemDiff memDiff[4];")
    print("} Ea16Fixture;")
    print(f"static const Ea16Fixture EA16_FIXTURES[{len(data['ea16Cases'])}] = {{")
    for c in data['ea16Cases']:
        rd = c['regDiff'][:4]
        md = c['memDiff'][:4]
        assert len(c['regDiff']) <= 4 and len(c['memDiff']) <= 4, "bump array size"
        print("    { %s, %uu, %s, %d, %s, %d, %s }," % (
            vopts_c(c['opts']), c['ea16'] or 0, b(c['err'] is not None),
            len(rd), regdiff_c(rd), len(md), memdiff_c(md)))
    print("};")
    print()

    print("typedef struct { uint32_t ea; int bsrdsr; uint32_t result; } ExpandFixture;")
    print(f"static const ExpandFixture EXPAND_FIXTURES[{len(data['expandCases'])}] = {{")
    for c in data['expandCases']:
        print("    { %uu, %d, %uu }," % (c['ea'], c['bsrdsr'], c['result']))
    print("};")
    print()

    print("typedef struct { uint32_t ea; int bsrdsr; uint32_t dseVal; uint32_t result; } ExpandDseFixture;")
    print(f"static const ExpandDseFixture EXPAND_DSE_FIXTURES[{len(data['expandDseCases'])}] = {{")
    for c in data['expandDseCases']:
        print("    { %uu, %d, %uu, %uu }," % (c['ea'], c['bsrdsr'], c['dseVal'], c['result']))
    print("};")
    print()

    print("typedef struct { uint32_t hw1, result; } ShiftCntFixture;")
    print(f"static const ShiftCntFixture SHIFTCNT_FIXTURES[{len(data['shiftCntCases'])}] = {{")
    for c in data['shiftCntCases']:
        print("    { %uu, %uu }," % (c['hw1'], c['result']))
    print("};")
    print()

    print("typedef struct { uint32_t v1, v2; int cc; } CcArithFixture;")
    print(f"static const CcArithFixture CCARITH_FIXTURES[{len(data['ccArithCases'])}] = {{")
    for c in data['ccArithCases']:
        print("    { %uu, %uu, %d }," % (c['v1'], c['v2'], c['cc']))
    print("};")
    print()

    print("typedef struct { uint32_t result; int cc; } CcLogicalFixture;")
    print(f"static const CcLogicalFixture CCLOGICAL_FIXTURES[{len(data['ccLogicalCases'])}] = {{")
    for c in data['ccLogicalCases']:
        print("    { %uu, %d }," % (c['result'], c['cc']))
    print("};")
    print()
    print("#endif")


if __name__ == "__main__":
    main()
