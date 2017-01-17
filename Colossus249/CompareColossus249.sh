#!/bin/bash
 
mkdir ~/Desktop/CompareColossus249
cd ~/Desktop/CompareColossus249
if [[ "$2" != "" ]]
then
	dirs="$1 $2"
elif [[ "$1" != "" ]]
then
	dirs="$1 Colossus249"
else
	dirs="Colossus237 Colossus249 Comanche055"
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
