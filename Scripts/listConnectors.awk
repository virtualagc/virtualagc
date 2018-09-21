#!/usr/bin/awk
{
	if ($1 == "L") {
		if ($3 == "J1") offset = 100;
		else if ($3 == "J2") offset = 200;
		else if ($3 == "J3") offset = 300;
		else if ($3 == "J4") offset = 400;
		else offset = 0;
	} else if ($1 == "U") unit = $2;
	else if ($1 == "F" && $11 == "\"Caption\"" && offset > 0 && $3 != "\"\"" && $3 != "\"(NC)\"" && $3 != "\"NC\"") {
		print (offset+unit) " " $3
	} else {
	}
	
}
