#!/bin/bash
 
mkdir ~/Desktop/CompareArtemis072
cd ~/Desktop/CompareArtemis072
dirs="Comanche055 Artemis072"
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
