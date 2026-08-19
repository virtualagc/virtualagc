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
    print("/* BUS_FIXTURES/BUS_PROT_FIXTURES/BUS_LOAD_* are NOT emitted here on")
    print(" * purpose -- they are hand-maintained below this point (see")
    print(" * test_mcm_membus.c's header comment) against the real, corrected")
    print(" * single-shared-MCM membus.c model. The busCases/busProtCases/")
    print(" * busLoad* fields in the input JSON (from gen_mcm_membus_fixtures.cjs,")
    print(" * which still queries gpc/membus.coffee's own two-MCM CPU/IOP split)")
    print(" * are deliberately ignored: emitting them here would silently")
    print(" * regress the fixtures back to testing that bug. Paste this file's")
    print(" * MCM_FIXTURES/PROTECT_FIXTURES/LOAD_* output above the existing")
    print(" * BUS_* section by hand if those ever need regenerating. */")


if __name__ == "__main__":
    main()
