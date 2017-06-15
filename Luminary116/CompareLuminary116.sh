#!/bin/bash
 
mkdir ~/Desktop/CompareLuminary116
cd ~/Desktop/CompareLuminary116
if [[ "$2" != "" ]]
then
	dirs="$1 $2"
elif [[ "$1" != "" ]]
then
	dirs="$1 Luminary116"
else
	dirs="Luminary099 Luminary116 Luminary131"
fi
mkdir $dirs

for n in $dirs
do
	cp ~/git/virtualagc/$n/*.agc $n
done

find -name "*.agc" -exec sed --in-place -r \
	-e 's/^[^#]*//' \
	-e 's/[[:space:]]+/ /g' \
	-e 's/^[#][[:space:]]*$//' \
	{} \;

meld $dirs

cd -