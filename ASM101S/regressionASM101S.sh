#!/bin/bash

COPY=no
EXTRAS=
for arg in "$@"
do
    if [[ "$arg" == "--copy" ]]
    then
        COPY=yes
    elif [[ "$arg" == "--help" ]]
    then
        echo ""
        echo "Perform a regression test on ASM101S, in which the AP-101S"
        echo "runtime-library source code is fully assembled and the results"
        echo "are compared to those found in contemporary assembly listings."
        echo ""
        echo "Usage:"
        echo "    regressionASM101S.sh [OPTIONS]"
        echo ""
        echo "Available OPTIONS:"
        echo "    --help    Show this message."
        echo "    --copy    Preserve the generated assembly listings as *.lst."
        echo "Unrecognized OPTIONS are passed directly to ASM101S."
        echo ""
        exit
    else
        EXTRAS="$EXTRAS $arg"
    fi
done

cd "../yaShuttle/Source Code/PASS.REL32V0/RUNASM"
# HOW MANY MODULES FAILED, so the run says so itself.  Every failure was
# already printed inline, but a clean run and a broken one differ only by the
# presence of extra words among 205 module names -- which is exactly how a
# change that broke 57 of them was read as passing.  A summary and an exit
# status are cheaper than remembering to count.
failures=0
total=0
for f in *.asm
do 
    n=${f%.*}
    echo -n -e "\033[0;33m$n\033[0m "
    ASM101S $EXTRAS --library --tolerable=4 --compare=../RUNLST/$n.txt $n.asm &>temp.lst
    #echo ASM101S $EXTRAS --library --tolerable=4 --compare=../RUNLST/$n.txt $n.asm
    if [[ $COPY == yes ]]
    then
        cp temp.lst $n.lst
    fi
    total=$((total+1))
    if tail -n1 temp.lst | grep --invert-match "0 bytes mismatched and 0 bytes missing"
    then
        failures=$((failures+1))
    fi
done
echo ""
if [[ $failures -eq 0 ]]
then
    echo -e "\033[0;32mPASS\033[0m: all $total modules assemble byte-for-byte."
else
    echo -e "\033[0;31mFAIL\033[0m: $failures of $total modules differ from their listings."
fi
if [[ $COPY == yes ]]
then
    echo 'Assembly-listing files *.lst were created.'
fi
cd - &>/dev/null
# Non-zero when anything differed, so a caller need not parse the output.
[[ $failures -eq 0 ]]
