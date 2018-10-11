import argparse
import array
import os
import binascii
from io import BytesIO

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate a Verilog ROM (switch statement) from a given binary")
    parser.add_argument('input_file', help="Input ROM file")
    parser.add_argument('output_file', help="Output Verilog filename")
    parser.add_argument('--to-hardware', help="Input file is a yaAGC-style bin that must be converted to hardware format", action="store_true")
    parser.add_argument('--hex', help="Also generate an Intel .hex file", action="store_true")
    args = parser.parse_args()
    
    words = array.array('H')
    with open(args.input_file, 'rb') as f:
        words.fromfile(f, int(os.path.getsize(args.input_file)/2))

    words.byteswap()
    if args.to_hardware:
        temp = words[0:0o4000]
        words[0:0o4000] = words[0o4000:0o10000]
        words[0o4000:0o10000] = temp

        # Add in parity in bit position 15
        for i in range(len(words)):
            words[i] = (words[i] & 0o100000) | (((bin(words[i]).count('1') + 1) % 2) << 14) | ((words[i] & 77776) >> 1)

    with open(args.output_file, 'w') as of:
        for i,word in enumerate(words):
            of.write("    %-5u: data = 16'o%06o;\n" % (i, word))

    if args.hex:
        from intelhex import bin2hex
        output_hex = os.path.splitext(args.output_file)[0] + '.hex'
        words.byteswap()
        hw_file = BytesIO(words.tostring())
        bin2hex(hw_file, output_hex, 0)
