#!/usr/bin/env python3
# Just gets rid of columns 80- of a source file.

import sys

for line in sys.stdin:
    print(line[:80].rstrip())
    
