#!/bin/bash
# This script performs a regression test on the AP-101S assembler, ASM101S,
# by compiling lots of legacy AP-101S assembly-language source code for which
# contemporary assembly listings are available, and doing a byte-by-byte
# comparison of the generated code.



cd "../yaShuttle/Source Code/PASS.REL32V0/RUNASM"
for f in *.asm
do 
    n=${f%.*}
    echo -n -e "\033[0;33m$n\033[0m "
    ASM101S.py --library=../RUNMAC --tolerable=4 --compare=../RUNLST/$n.txt $n.asm &>temp.lst
    if [[ "$1" != "" ]]
    then
        cp temp.lst $n.lst
    fi
    tail -n1 temp.lst | grep --invert-match "0 bytes mismatched and 0 bytes missing"
done
echo ""
if [[ "$1" != "" ]]
then
    echo 'Assembly-listing files *.lst were created.'
fi
cd - &>/dev/null
