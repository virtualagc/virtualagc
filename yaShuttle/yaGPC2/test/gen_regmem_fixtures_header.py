#!/usr/bin/env python3
"""Convert regmem JSON fixtures into a C header for test_regmem.c."""
import json
import sys

GETTERS = [
    'getNIA', 'getCC', 'getCarry', 'getOverflow', 'getFixedPtOverflow',
    'getExponentUnderflow', 'getSignificanceMask', 'getBSR', 'getDSR',
    'getIntMask', 'getRegSet', 'getMachCheckMask', 'getWaitState',
    'getProblemState', 'getIntCode',
]


def c_str(s):
    return '"' + s.replace('\\', '\\\\').replace('"', '\\"') + '"'


def main():
    data = json.load(open(sys.argv[1]))
    print("#ifndef YAGPC_TEST_REGMEM_FIXTURES_H")
    print("#define YAGPC_TEST_REGMEM_FIXTURES_H")
    print()
    print("#include <stdint.h>")
    print()

    print("typedef struct { const char *op; uint32_t v; uint32_t get32, get16; } RegisterFixture;")
    print(f"static const RegisterFixture REGISTER_FIXTURES[{len(data['registerCases'])}] = {{")
    for c in data['registerCases']:
        print("    { %s, %uu, %uu, %uu }," % (c_str(c['op']), c['v'], c['get32'], c['get16']))
    print("};")
    print()

    print("typedef struct { uint32_t v; int b; int hasGet; uint32_t get; int hasSet1; uint32_t set1; int hasSet0; uint32_t set0; } BitFixture;")
    merged = {}
    for c in data['bitCases']:
        key = (c['v'], c['b'])
        e = merged.setdefault(key, {'v': c['v'], 'b': c['b']})
        if 'getbit32' in c:
            e['get'] = c['getbit32']
        if 'setbit32to1' in c:
            e['set1'] = c['setbit32to1']
        if 'setbit32to0' in c:
            e['set0'] = c['setbit32to0']
    entries = list(merged.values())
    print(f"static const BitFixture BIT_FIXTURES[{len(entries)}] = {{")
    for e in entries:
        print("    { %uu, %d, %d, %uu, %d, %uu, %d, %uu }," % (
            e['v'], e['b'],
            1 if 'get' in e else 0, e.get('get', 0),
            1 if 'set1' in e else 0, e.get('set1', 0),
            1 if 'set0' in e else 0, e.get('set0', 0),
        ))
    print("};")
    print()

    print("typedef struct { int base; uint32_t val; uint32_t dse; } DseFixture;")
    print(f"static const DseFixture DSE_FIXTURES[{len(data['dseCases'])}] = {{")
    for c in data['dseCases']:
        print("    { %d, %uu, %uu }," % (c['base'], c['val'], c['dse']))
    print("};")
    print()

    print("typedef struct { uint32_t p1, p2; uint32_t getters[%d]; } PswFixture;" % len(GETTERS))
    print(f"static const PswFixture PSW_FIXTURES[{len(data['pswCases'])}] = {{")
    for c in data['pswCases']:
        vals = ", ".join(str(int(c['getters'][g])) for g in GETTERS)
        print("    { %uu, %uu, {%s} }," % (c['p1'], c['p2'], vals))
    print("};")
    print()

    print("typedef struct { uint32_t p1, p2; const char *setter; uint32_t val; uint32_t psw1, psw2; } PswSetterFixture;")
    print(f"static const PswSetterFixture PSW_SETTER_FIXTURES[{len(data['pswSetterCases'])}] = {{")
    for c in data['pswSetterCases']:
        v = c['val']
        if isinstance(v, bool):
            v = 1 if v else 0
        print("    { %uu, %uu, %s, %uu, %uu, %uu }," % (c['p1'], c['p2'], c_str(c['setter']), v, c['psw1'], c['psw2']))
    print("};")
    print()
    print("#endif")


if __name__ == "__main__":
    main()
