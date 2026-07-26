#!/usr/bin/env python3
"""Convert q31 JSON fixtures into a C header for test_q31.c."""
import json
import sys


def b(v):
    return "true" if v else "false"


def main():
    data = json.load(open(sys.argv[1]))
    print("#ifndef YAGPC_TEST_Q31_FIXTURES_H")
    print("#define YAGPC_TEST_Q31_FIXTURES_H")
    print()
    print("#include <stdbool.h>")
    print("#include <stdint.h>")
    print()

    print("typedef struct { int32_t a, b; uint32_t hi, lo; bool overflow; } MulFixture;")
    print(f"static const MulFixture MUL_FIXTURES[{len(data['mulCases'])}] = {{")
    for c in data['mulCases']:
        print("    { %d, %d, %uu, %uu, %s }," % (c['a'], c['b'], c['hi'], c['lo'], b(c['overflow'])))
    print("};")
    print()

    print("typedef struct { int32_t a, b, result; bool overflow; } Q15Fixture;")
    print(f"static const Q15Fixture Q15_FIXTURES[{len(data['q15Cases'])}] = {{")
    for c in data['q15Cases']:
        print("    { %d, %d, %d, %s }," % (c['a'], c['b'], c['result'], b(c['overflow'])))
    print("};")
    print()

    print("typedef struct { int32_t hi, lo, d, quotient; bool overflow; } DivFixture;")
    print(f"static const DivFixture DIV_FIXTURES[{len(data['divCases'])}] = {{")
    for c in data['divCases']:
        print("    { %d, %d, %d, %d, %s }," % (c['hi'], c['lo'], c['d'], c['quotient'], b(c['overflow'])))
    print("};")
    print()
    print("#endif")


if __name__ == "__main__":
    main()
