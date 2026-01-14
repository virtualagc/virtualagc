#/bin/bash
# This script combines the files templateAGC-topop.cbp and templateAGC-bottom.cbp
# with MAIN.agc for a selected version of the Block II AGC software to create
# a *.cbp file suitable for graphical debugging that AGC software version with 
# Code::Blocks.  Does not overwrite any existing .cbp file.

# Usage:
#	cd /folder/of/Virtual/AGC/source/tree/
#	./createCBP.sh agcSoftwareVersionName
# For example,
#	.createCBP.sh Luminary099

if [[ ! -f $1/MAIN.agc ]]
then
	echo Specified AGC software version $1 not found.
	exit 1
fi
if [[ -f $1/$1.cbp ]]
then
	echo $1/$1.cbp already exists.
	exit 1
fi

sed "s/@name@/$1/" templateAGC-top.cbp >$1/$1.cbp
for f in `grep "^[$]" $1/MAIN.agc | sed -e 's/^[$]//' -e 's/[[:space:]].*//'`
do
	echo -e '\t\t<Unit filename="'$f'" />' >>$1/$1.cbp
done
cat templateAGC-bottom.cbp >>$1/$1.cbp

echo Created $1/$1.cbp
