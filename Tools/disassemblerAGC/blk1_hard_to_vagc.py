#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import array
import os
import sys

rope = array.array('H')
fn = sys.argv[1]

banks = [
    0o04, 0o01, 0o24, 0o21,
    0o02, 0o03, 0o22, 0o23,
    0o10, 0o05, 0o30, 0o25,
    0o06, 0o07, 0o26, 0o27,
    0o14, 0o11, 0o34, 0o31,
    0o12, 0o13, 0o32, 0o33,
]

with open(fn, 'rb') as f:
    rope.fromfile(f, int(os.path.getsize(fn)/2))
    rope.byteswap()

vwords = [0]*0o34*0o2000
vagc = array.array('H', vwords)

for i,w in enumerate(rope):
    bank_idx = i // 0o2000
    offset = i - bank_idx*0o2000
    bank = banks[bank_idx]
    vagc[(bank-1)*0o2000 + offset] = (w & 0x8000) | ((w & 0x3FFF) << 1) | ((w & 0x4000) >> 14)

vagc.byteswap()
base,ext = os.path.splitext(fn)
with open(base + '_vagc' + ext, 'wb') as f:
    vagc.tofile(f)
