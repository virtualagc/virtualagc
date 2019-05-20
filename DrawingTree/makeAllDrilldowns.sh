#!/bin/bash
# Use drilldown.py to create all G&N drilldown pages.

for a in `seq -w 21 10 181`
do
	if [[ "$a" != "101" && "$a" != "041" ]]
	then
		assembly=6014999-$a
		echo $assembly
		./drilldown.py $assembly >~/git/virtualagc-web/$assembly.html
	fi
done

