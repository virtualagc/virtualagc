#!/usr/bin/env python
import fileinput
import re
import sys

signals = {}
signal_names = {}

dump_lines = []
old_u = 0
while True:
    time = 0
    staged_inst = None
    instruction_starting = False
    inkl_inst = None

    # Buffer up all the lines we need. Going on the fly is too slow
    line = sys.stdin.readline()
    if not line:
        break
    if not line.startswith('$comment data_end'):
        dump_lines.append(line)
        continue

    for line in dump_lines:
        if line.startswith('$'):
            if line.startswith('$var wire'):
                toks = line.split()
                sig_num = int(toks[3])
                name_match = re.match('^(__.*?___)?(.+?)\[', toks[4])
                sig_name = name_match.group(2)
                if name_match.group(1) is not None:
                    nums = re.match('__A(\d+)_(\d+)', name_match.group(1)).groups()
                    board_num = int(sig_name[-1])
                    sig_name = sig_name[:-1] + '%02u' % ((int(nums[0])-8)*4 + (int(nums[1])-1)*2 + board_num)
                else:
                    sig_name = sig_name[:-2]
                signal_names[sig_num] = sig_name
                signals[sig_name] = 0
            elif line.startswith('$dumpvars'):
                print('$name U')
                print('#0')

            continue

        if line.startswith('#'):
            time = int(line[1:])
            continue
        
        state = int(line[0]) if line[0] not in 'zx' else 0
        sig_num = int(line[1:])
        sig_name = signal_names[sig_num]
        signals[sig_name] = state

        suma = 0
        sumb = 0
        for i in range(1,17):
            suma |= signals['SUMA%02u' % i] << (i-1)
            sumb |= signals['SUMB%02u' % i] << (i-1)

        u = (~(suma | sumb)) & 0o177777
        if u != old_u:
            print('#%u %06o' % (time, u))
            old_u = u

    print('$finish')
    sys.stdout.flush()
    dump_lines = []
