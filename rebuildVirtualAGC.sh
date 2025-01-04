#!/bin/bash
# This script is used on the VM VirtualAGC-VM64 to rebuild the entire
# Virtual AGC source tree, including items not normally automatically built.

SOURCE_DIR="/home/virtualagc/git/virtualagc"

# Described in download.html#Linux
# First, make all of the "normal" stuff that's usually automatic.
cd $SOURCE_DIR
make clean install

# Described in XPL-I.html.
cd $SOURCE_DIR/XCOM-I
rm sim360 &>/dev/null
make sim360
make
cd $SOURCE_DIR/yaShuttle/"Source Code"/PASS.REL32V0
make -s XEXTRA=--quiet clean all regression

# Described in ASM101S.html
cd $SOURCE_DIR/ASM101S
regressionASM101S.sh -v

# Described in hal-s-compiler.html
cd $SOURCE_DIR/yaShuttle/yaHAL-S
make distclean all

