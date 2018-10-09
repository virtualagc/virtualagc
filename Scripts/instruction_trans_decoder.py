#!/usr/bin/env python
import fileinput
import re
import sys

signals = {}
signal_names = {}

def decode_instruction(opcode, ext):
    sq = opcode >> 12
    qc = (opcode >> 10) & 0o3
    s = opcode & 0o7777
    es = s & 0o1777
    if ext:
        sq += 0o10
    if sq == 0o0:
        if s == 0o3:
            return 'RELINT'
        elif s == 0o4:
            return 'INHINT'
        elif s == 0o6:
            return 'EXTEND'
        else:
            return 'TC %04o' % s
    elif sq == 0o1:
        if qc == 0o0:
            return 'CCS %04o' % es
        else:
            return 'TCF %04o' % s
    elif sq == 0o2:
        if qc == 0o0:
            return 'DAS %04o' % (es-1)
        elif qc == 0o1:
            return 'LXCH %04o' % es
        elif qc == 0o2:
            return 'INCR %04o' % es
        elif qc == 0o3:
            return 'ADS %04o' % es
    elif sq == 0o3:
        return 'CA %04o' % s
    elif sq == 0o4:
        return 'CS %04o' % s
    elif sq == 0o5:
        if qc == 0o0:
            if s == 0o17:
                return 'RESUME'
            else:
                return 'INDEX %04o' % es
        elif qc == 0o1:
            return 'DXCH %04o' % (es-1)
        elif qc == 0o2:
            return 'TS %04o' % es
        elif qc == 0o3:
            return 'XCH %04o' % es
    elif sq == 0o6:
        return 'AD %04o' % s
    elif sq == 0o7:
        return 'MASK %04o' % s
    elif sq == 0o10:
        s10 = (opcode >> 9) & 0o1
        if qc == 0o0:
            if s10 == 0o0:
                return 'READ %04o' % (es & 0o777)
            else:
                return 'WRITE %04o' % (es & 0o777)
        elif qc == 0o1:
            if s10 == 0o0:
                return 'RAND %04o' % (es & 0o777)
            else:
                return 'WAND %04o' % (es & 0o777)
        elif qc == 0o2:
            if s10 == 0o0:
                return 'ROR %04o' % (es & 0o777)
            else:
                return 'WOR %04o' % (es & 0o777)
        elif qc == 0o3:
            if s10 == 0o0:
                return 'RXOR %04o' % (es & 0o777)
            else:
                return 'RUPT'
    elif sq == 0o11:
        if qc == 0o0:
            return 'DV %04o' % es
        else:
            return 'BZF %04o' % s
    elif sq == 0o12:
        if qc == 0o0:
            return 'MSU %04o' % es
        elif qc == 0o1:
            return 'QXCH %04o' % es
        elif qc == 0o2:
            return 'AUG %04o' % es
        elif qc == 0o3:
            return 'DIM %04o' % es
    elif sq == 0o13:
        return 'DCA %04o' % (s-1)
    elif sq == 0o14:
        return 'DCS %04o' % (s-1)
    elif sq == 0o15:
        return 'INDEX %04o' % s
    elif sq == 0o16:
        if qc == 0o0:
            return 'SU %04o' % es
        else:
            return 'BZMF %04o' % s
    elif sq == 0o16:
        return 'MP %04o' % s

    return '???'

dump_lines = []
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
                sig_name = re.match('^(?:__.*?__)?(.+?)\[', toks[4]).groups()[0]
                signal_names[sig_num] = sig_name
                signals[sig_name] = 0
            elif line.startswith('$dumpvars'):
                print('$name Instruction')
                print('#0')

            continue

        if line.startswith('#'):
            # Apply staged changes
            if instruction_starting and staged_inst:
                print('#%u %s' % (time, staged_inst))
                instruction_starting = False
                if staged_inst == 'GOJAM':
                    staged_inst = 'TC 4000'
                else:
                    staged_inst = None

            time = int(line[1:])
            continue
        
        state = int(line[0]) if line[0] not in 'zx' else 0
        sig_num = int(line[1:])
        sig_name = signal_names[sig_num]
        signals[sig_name] = state

        if sig_name == 'T01' and state == 1 and signals['INKL'] == 0 and signals['STG1'] == 0 and signals['STG3'] == 0 and inkl_inst is None:
            if signals['STG2'] == 0  or (signals['STG2'] == 1 and staged_inst in ['RELINT', 'INHINT', 'EXTEND']):
                instruction_starting = True
        elif sig_name == 'WSQG_n' and state == 1:
            print('#%u' % time)
        elif sig_name == 'GOJAM' and state == 0:
            staged_inst = 'GOJAM'
            instruction_starting = True
        elif sig_name == 'T07' and state == 0:
            if signals['TSUDO_n'] == 0 or signals['IC2'] == 1:
                # G should be ready by now, we don't expect G to change during this time
                G = 0
                for i in range(1,16):
                    G = G | signals['G%02u' % i] << (i-1)
                staged_inst = decode_instruction(G, signals['FUTEXT'])
        elif sig_name == 'RPTFRC' and state == 1:
            staged_inst = 'RUPT'
        elif sig_name == 'PINC' and state == 1:
            print('#%u PINC' % time)
        elif sig_name == 'MINC' and state == 1:
            print('#%u MINC' % time)
        elif sig_name == 'DINC' and state == 1:
            print('#%u DINC' % time)
        elif sig_name == 'PCDU' and state == 1:
            print('#%u PCDU' % time)
        elif sig_name == 'MCDU' and state == 1:
            print('#%u MCDU' % time)
        elif sig_name == 'SHINC' and state == 1:
            print('#%u SHINC' % time)
        elif sig_name == 'SHANC' and state == 1:
            print('#%u SHANC' % time)
        elif sig_name == 'INKL' and state == 0 and inkl_inst is not None:
            staged_inst = inkl_inst
            inkl_inst = None

    print('$finish')
    sys.stdout.flush()
    dump_lines = []
