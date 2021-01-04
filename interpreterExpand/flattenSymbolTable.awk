#!/usr/bin/awk

BEGIN {
	inSymbolTable = 0;
}

{
	if (NF == 2 && $1 == "Symbol" && $2 == "Table")
		inSymbolTable = 1;
	else if (NF == 0)
		inSymbolTable = 0;
	else if (inSymbolTable && $1 != "------------") {
		if (NF >= 3)
			print $2;
		if (NF >= 6)
			print $5;
		if (NF >= 9)
			print $8;
		if (NF >= 12)
			print $11;
	}
}
