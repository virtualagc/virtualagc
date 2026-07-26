#!/usr/bin/env python3
"""Convert Instruction.decode() JSON fixtures into a C header."""
import json
import sys


def b(v):
    return "true" if v else "false"


def c_str(s):
    return '"' + s.replace('\\', '\\\\').replace('"', '\\"') + '"' if s is not None else 'NULL'


def main():
    data = json.load(open(sys.argv[1]))
    print("#ifndef YAGPC_TEST_CPU_INSTR_DECODE_FIXTURES_H")
    print("#define YAGPC_TEST_CPU_INSTR_DECODE_FIXTURES_H")
    print()
    print("#include <stdbool.h>")
    print("#include <stdint.h>")
    print()
    print("typedef struct { char c; uint32_t val; } FieldKV;")
    print("typedef struct {")
    print("    uint32_t hw1, hw2;")
    print("    bool matched;")
    print("    const char *nm;")
    print("    int len;")
    print("    bool extended;")
    print("    bool hasIa; uint32_t ia;")
    print("    bool hasIi; uint32_t ii;")
    print("    int addrWidth, opType;")
    print("    int fieldCount;")
    print("    FieldKV fields[16];")
    print("} DecodeFixture;")
    print()

    cases = data['cases']
    print(f"static const DecodeFixture DECODE_FIXTURES[{len(cases)}] = {{")
    for c in cases:
        e = c['expect']
        if not e['matched']:
            print("    { %uu, %uu, false, NULL, 0, false, false,0, false,0, 0, 0, 0, {{0,0}} }," % (c['hw1'], c['hw2']))
            continue
        fields = sorted(e['fields'].items())
        assert len(fields) <= 16, "bump fields array size"
        fstr = ", ".join("{'%s', %uu}" % (k, v) for k, v in fields) or "{0,0}"
        print("    { %uu, %uu, true, %s, %d, %s, %s, %uu, %s, %uu, %d, %d, %d, {%s} }," % (
            c['hw1'], c['hw2'], c_str(e['nm']), e['len'], b(e['extended']),
            b(e['hasIa']), e.get('ia', 0) or 0,
            b(e['hasIi']), e.get('ii', 0) or 0,
            e['addrWidth'], e['opType'], len(fields), fstr))
    print("};")
    print()
    print("#endif")


if __name__ == "__main__":
    main()
