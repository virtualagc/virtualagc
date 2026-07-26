#!/usr/bin/env python3
"""Convert MCM/MemoryBus JSON fixtures into a C header for test_mcm_membus.c."""
import json
import sys


def b(v):
    return "true" if v else "false"


def main():
    data = json.load(open(sys.argv[1]))
    print("#ifndef YAGPC_TEST_MCM_MEMBUS_FIXTURES_H")
    print("#define YAGPC_TEST_MCM_MEMBUS_FIXTURES_H")
    print()
    print("#include <stdbool.h>")
    print("#include <stdint.h>")
    print()

    print(f"#define MCM_TEST_WORDCOUNT {data['wordCount']}")
    print()

    print("typedef struct { int isSet32; uint32_t addr; uint32_t v; bool ok; uint32_t after; } McmFixture;")
    print(f"static const McmFixture MCM_FIXTURES[{len(data['mcmCases'])}] = {{")
    for c in data['mcmCases']:
        is32 = 1 if c['op'] == 'set32' else 0
        after = c['after32'] if is32 else c['after16']
        print("    { %d, %uu, %uu, %s, %uu }," % (is32, c['addr'], c['v'], b(c['ok']), after))
    print("};")
    print()

    # protectCases entries alternate shape; encode generically with optional fields as -1 sentinel where absent.
    print("typedef struct {")
    print("    int hasProtWrite; uint32_t addr; uint32_t before; bool ok16; uint32_t after16; bool prot;")
    print("    int hasUnprotWrite; bool ok16Unprotected; uint32_t after16b;")
    print("    int hasSet32Block; uint32_t addr32; bool ok32BlockedBySecondHW; uint32_t val;")
    print("} ProtectFixture;")
    print(f"static const ProtectFixture PROTECT_FIXTURES[{len(data['protectCases'])}] = {{")
    for c in data['protectCases']:
        if 'ok16Unprotected' in c:
            print("    { 0, 0,0,false,0,false, 1, %s, %uu, 0, 0,false,0 }," % (b(c['ok16Unprotected']), c['after16b']))
        elif 'ok32BlockedBySecondHW' in c:
            print("    { 0, 0,0,false,0,false, 0, false,0, 1, %uu, %s, %uu }," % (c['addr32'], b(c['ok32BlockedBySecondHW']), c['val']))
        else:
            print("    { 1, %uu, %uu, %s, %uu, %s, 0, false,0, 0,0,false,0 }," % (c['addr'], c['before'], b(c['ok16']), c['after16'], b(c['prot'])))
    print("};")
    print()

    print(f"static const uint8_t LOAD_BYTES[{len(data['loadBytes'])}] = {{{', '.join(str(x) for x in data['loadBytes'])}}};")
    print(f"static const uint32_t LOAD_RESULTS[{len(data['loadResults'])}] = {{{', '.join(str(x) for x in data['loadResults'])}}};")
    print()

    print("typedef struct { int isSet32; uint32_t addr; uint32_t v; bool ok; uint32_t after; } BusFixture;")
    print(f"static const BusFixture BUS_FIXTURES[{len(data['busCases'])}] = {{")
    for c in data['busCases']:
        is32 = 1 if c['op'] == 'set32' else 0
        after = c['after32'] if is32 else c['after16']
        print("    { %d, %uu, %uu, %s, %uu }," % (is32, c['addr'], c['v'], b(c['ok']), after))
    print("};")
    print()

    print("typedef struct { uint32_t addr; bool ok; bool prot; uint32_t after; } BusProtFixture;")
    print(f"static const BusProtFixture BUS_PROT_FIXTURES[{len(data['busProtCases'])}] = {{")
    for c in data['busProtCases']:
        print("    { %uu, %s, %s, %uu }," % (c['addr'], b(c['ok']), b(c['prot']), c['after']))
    print("};")
    print()

    print(f"#define BUS_LOAD_BASE {data['busLoadBase']}u")
    print(f"static const uint8_t BUS_LOAD_BYTES[{len(data['busLoadBytes'])}] = {{{', '.join(str(x) for x in data['busLoadBytes'])}}};")
    print(f"static const uint32_t BUS_LOAD_RESULTS[{len(data['busLoadResults'])}] = {{{', '.join(str(x) for x in data['busLoadResults'])}}};")
    print()
    print("#endif")


if __name__ == "__main__":
    main()
