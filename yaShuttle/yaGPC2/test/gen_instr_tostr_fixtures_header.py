#!/usr/bin/env python3
"""Convert Instruction#toStr fixtures into a C header."""
import json
import sys


def c_str(s):
    out = []
    for ch in s:
        if ch == '\\':
            out.append('\\\\')
        elif ch == '"':
            out.append('\\"')
        else:
            out.append(ch)
    return '"' + ''.join(out) + '"'


def main():
    data = json.load(open(sys.argv[1]))
    print("#ifndef YAGPC_TEST_INSTR_TOSTR_FIXTURES_H")
    print("#define YAGPC_TEST_INSTR_TOSTR_FIXTURES_H")
    print()
    print("#include <stdint.h>")
    print()
    print("typedef struct { uint32_t hw1, hw2; const char *s; } ToStrFixture;")
    print(f"static const ToStrFixture TOSTR_FIXTURES[{len(data)}] = {{")
    for c in data:
        print("    { %uu, %uu, %s }," % (c['hw1'], c['hw2'], c_str(c['s'])))
    print("};")
    print()
    print("#endif")


if __name__ == "__main__":
    main()
