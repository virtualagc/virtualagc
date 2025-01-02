#!/bin/bash
# This script is used on the VM VirtualAGC-VM64 to rebuild the entire
# Virtual AGC sourcd tree, including items not normally automatically built.

# First, make all of the "normal" stuff that's usually automatic.
time make clean install clean

# Now build some extra, non-standard stuff that is usually built manually.
cd ../XCOM-I
rm sim360 &>/dev/null
make sim360
make
cd ../yaShuttle/"Source Code"/PASS.REL32V0
make -s XEXTRA=--quiet all regression

