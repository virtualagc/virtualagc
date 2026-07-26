#!/usr/bin/env python3
"""Convert FloatIBM JSON fixtures into a C header for test_floatIBM.c."""
import json
import struct
import sys


def main():
    data = json.load(open(sys.argv[1]))
    print("#ifndef YAGPC_TEST_FLOATIBM_FIXTURES_H")
    print("#define YAGPC_TEST_FLOATIBM_FIXTURES_H")
    print()
    print("#include <stdint.h>")
    print()

    print("typedef struct { uint32_t hi, lo, to32, to64x, to64y; int32_t gSign, gExp; uint32_t fbHi, fbLo; } AccessorFixture;")
    print(f"static const AccessorFixture ACCESSOR_FIXTURES[{len(data['accessorCases'])}] = {{")
    for c in data['accessorCases']:
        print("    { %uu, %uu, %uu, %uu, %uu, %d, %d, %uu, %uu }," % (
            c['hi'], c['lo'], c['to32'], c['to64x'], c['to64y'], c['gSign'], c['gExp'],
            c['gFracBitsHigh'], c['gFracBitsLow']))
    print("};")
    print()

    print("typedef struct { uint32_t hi, lo, resultHi, resultLo; } NormalizeFixture;")
    print(f"static const NormalizeFixture NORMALIZE_FIXTURES[{len(data['normalizeCases'])}] = {{")
    for c in data['normalizeCases']:
        print("    { %uu, %uu, %uu, %uu }," % (c['hi'], c['lo'], c['resultHi'], c['resultLo']))
    print("};")
    print()

    print("typedef struct { uint32_t hi1, lo1, hi2, lo2; int cc; } CompEFixture;")
    print(f"static const CompEFixture COMPE_FIXTURES[{len(data['compECases'])}] = {{")
    for c in data['compECases']:
        print("    { %uu, %uu, %uu, %uu, %d }," % (c['hi1'], c['lo1'], c['hi2'], c['lo2'], c['cc']))
    print("};")
    print()

    print("typedef struct { uint32_t hi1, lo1, hi2, lo2; int exc; uint32_t resultHi, resultLo; } BinOpFixture;")
    for name in ['addECases', 'subECases', 'mulECases', 'mulQeECases', 'divECases']:
        cname = name.replace('Cases', '').upper() + '_FIXTURES'
        print(f"static const BinOpFixture {cname}[{len(data[name])}] = {{")
        for c in data[name]:
            print("    { %uu, %uu, %uu, %uu, %d, %uu, %uu }," % (
                c['hi1'], c['lo1'], c['hi2'], c['lo2'], c['exc'], c['resultHi'], c['resultLo']))
        print("};")
        print()

    print("typedef struct { uint32_t hi, lo; int32_t result; int exc; } CvfxFixture;")
    print(f"static const CvfxFixture CVFX_FIXTURES[{len(data['cvfxCases'])}] = {{")
    for c in data['cvfxCases']:
        print("    { %uu, %uu, %d, %d }," % (c['hi'], c['lo'], c['result'], c['exc']))
    print("};")
    print()

    print("typedef struct { int32_t v; uint32_t resultHi, resultLo; } CvflFixture;")
    print(f"static const CvflFixture CVFL_FIXTURES[{len(data['cvflCases'])}] = {{")
    for c in data['cvflCases']:
        print("    { %d, %uu, %uu }," % (c['v'], c['resultHi'], c['resultLo']))
    print("};")
    print()

    print("typedef struct { uint64_t vBits; uint32_t resultHi, resultLo; uint64_t backBits; } FloatRTFixture;")
    print(f"static const FloatRTFixture FLOAT_RT_FIXTURES[{len(data['floatRoundTripCases'])}] = {{")
    for c in data['floatRoundTripCases']:
        vBits = struct.unpack('<Q', struct.pack('<d', c['v']))[0]
        backBits = int(c['backBitsHex'], 16)
        print("    { 0x%016xULL, %uu, %uu, 0x%016xULL }," % (vBits, c['resultHi'], c['resultLo'], backBits))
    print("};")
    print()

    print("typedef struct { uint32_t hi, lo; uint64_t vBits; } ToFloatFixture;")
    print(f"static const ToFloatFixture TOFLOAT_FIXTURES[{len(data['toFloatCases'])}] = {{")
    for c in data['toFloatCases']:
        vBits = int(c['vBitsHex'], 16)
        print("    { %uu, %uu, 0x%016xULL }," % (c['hi'], c['lo'], vBits))
    print("};")
    print()
    print("#endif")


if __name__ == "__main__":
    main()
