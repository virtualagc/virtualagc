EESchema Schematic File Version 4
LIBS:module-cache
EELAYER 29 0
EELAYER END
$Descr E 44000 34000
encoding utf-8
Sheet 3 11
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text Notes 39875 31725 0    200  ~ 40
SCHEMATIC
Text Notes 40575 33075 0    250  ~ 50
1006162
Text Notes 38700 32075 0    200  ~ 40
DECODING MODULE D1-D6
Text Notes 42425 33455 0    140  ~ 28
1     3
Text Notes 39225 32450 0    200  ~ 40
AGC  DSKY  NAV & MAIN
Text Notes 38475 32950 0    140  ~ 28
________
Wire Notes Line style solid
	37965 910  37965 1515
Wire Notes Line style solid
	37965 1515 43500 1515
Wire Notes Line style solid
	37965 1160 43500 1160
Wire Notes Line style solid
	38465 910  38465 1515
Wire Notes Line style solid
	41800 910  41800 1515
Wire Notes Line style solid
	42465 910  42465 1515
Text Notes 38105 1130 0    140  Italic 28
A   REVISED PER TDRR 04320
Text Notes 38095 1430 0    140  ~ 28
B   REVISED PER TDRR 04730
$Comp
L AGC_DSKY:Transistor-PNP Q?
U 1 1 5CC9D6D8
P 4775 4325
AR Path="/5CC86951/5CC9D6D8" Ref="Q?"  Part="1" 
AR Path="/5CCDEBB1/5CC9D6D8" Ref="Q?"  Part="1" 
AR Path="/5CCDF3E2/5CC9D6D8" Ref="Q?"  Part="1" 
AR Path="/5CCDF3EC/5CC9D6D8" Ref="Q?"  Part="1" 
F 0 "Q?" H 4750 4735 130 0001 C CNN
F 1 "Transistor-PNP" H 4775 4890 130 0001 C CNN
F 2 "" H 4775 4075 130 0001 C CNN
F 3 "" H 4775 4075 130 0001 C CNN
F 4 "Q1" H 5425 4375 130 0000 C CIN "baseRefd"
	1    4775 4325
	-1   0    0    1   
$EndComp
$Comp
L AGC_DSKY:Resistor R?
U 1 1 5CC9E628
P 4625 5925
AR Path="/5CC86951/5CC9E628" Ref="R?"  Part="1" 
AR Path="/5CCDEBB1/5CC9E628" Ref="R?"  Part="1" 
AR Path="/5CCDF3E2/5CC9E628" Ref="R?"  Part="1" 
AR Path="/5CCDF3EC/5CC9E628" Ref="R?"  Part="1" 
F 0 "R?" H 4600 5750 130 0001 C CNN
F 1 "Resistor" H 4625 6100 130 0001 C CNN
F 2 "" H 4625 5925 130 0001 C CNN
F 3 "" H 4625 5925 130 0001 C CNN
F 4 "R1" V 4650 5475 130 0000 C CIN "baseRefd"
	1    4625 5925
	0    1    1    0   
$EndComp
$Comp
L AGC_DSKY:Resistor R?
U 1 1 5CC9ED75
P 5625 7450
AR Path="/5CC86951/5CC9ED75" Ref="R?"  Part="1" 
AR Path="/5CCDEBB1/5CC9ED75" Ref="R?"  Part="1" 
AR Path="/5CCDF3E2/5CC9ED75" Ref="R?"  Part="1" 
AR Path="/5CCDF3EC/5CC9ED75" Ref="R?"  Part="1" 
F 0 "R?" H 5600 7275 130 0001 C CNN
F 1 "Resistor" H 5625 7625 130 0001 C CNN
F 2 "" H 5625 7450 130 0001 C CNN
F 3 "" H 5625 7450 130 0001 C CNN
F 4 "R2" V 5650 7000 130 0000 C CIN "baseRefd"
	1    5625 7450
	0    1    1    0   
$EndComp
Text HLabel 4625 2675 1    140  Output Italic 28
A
Text HLabel 5625 8850 3    140  Input Italic 28
B
Text HLabel 6500 5125 2    140  Input Italic 28
WD241
Wire Wire Line
	4625 4075 4625 2675
Wire Wire Line
	4625 4575 4625 5125
Wire Wire Line
	4625 5125 6500 5125
Connection ~ 4625 5125
Wire Wire Line
	4625 5125 4625 5525
Wire Wire Line
	5075 4325 5625 4325
Wire Wire Line
	5625 4325 5625 6725
Wire Wire Line
	4625 6325 4625 6725
Wire Wire Line
	4625 6725 5625 6725
Connection ~ 5625 6725
Wire Wire Line
	5625 6725 5625 7050
Wire Wire Line
	5625 7850 5625 8850
Wire Notes Line
	850  3275 850  8225
Wire Notes Line
	850  8225 6350 8225
Wire Notes Line
	6350 8225 6350 3275
Wire Notes Line
	6350 3275 850  3275
Text Notes 1000 4150 0    140  Italic 28
SEE CIRCUIT IDENT\nTABLE FOR REF DES\nPREFIX NUMBER
Text Notes 1000 7725 0    140  Italic 28
4 IDENTICAL CIRCUITS EACH\nMODULE\n90000 THRU 90011  NAV DSKY\n90600 THRU 90611  MAIN DSKY
Wire Notes Line style solid
	15275 20325 23225 20325
Wire Notes Line style solid
	15275 20600 23225 20600
Wire Notes Line style solid
	15275 20875 23225 20875
Wire Notes Line style solid
	15275 21700 23225 21700
Wire Notes Line style solid
	15275 20325 15275 21700
Wire Notes Line style solid
	23225 20325 23225 21700
Wire Notes Line style solid
	22200 20600 22200 21700
Wire Notes Line style solid
	21425 20600 21425 21700
Wire Notes Line style solid
	20300 20600 20300 21700
Wire Notes Line style solid
	18425 20600 18425 21700
Wire Notes Line style solid
	16525 20600 16525 21700
Text Notes 15375 20850 0    140  Italic 28
REF DES
Text Notes 16775 20575 0    140  Italic 28
90000 - 90011  &  90600 - 90611
Text Notes 16900 20850 0    140  Italic 28
PART NO.
Text Notes 18650 20850 0    140  Italic 28
DESCRIPTION
Text Notes 20475 20850 0    140  Italic 28
VALUE
Text Notes 21625 20850 0    140  Italic 28
TOL
Text Notes 22325 20850 0    140  Italic 28
RATING
Wire Notes Line style solid
	15275 21150 23225 21150
Wire Notes Line style solid
	15275 21425 23225 21425
Text Notes 15725 21125 0    140  Italic 28
Q1
Text Notes 15725 21400 0    140  Italic 28
R1
Text Notes 15725 21675 0    140  Italic 28
R2
Text Notes 16875 21125 0    140  Italic 28
1006753
Text Notes 16725 21400 0    140  Italic 28
1006750-39
Text Notes 16700 21675 0    140  Italic 28
1006750-15
Text Notes 18700 21125 0    140  Italic 28
TRANSISTOR
Text Notes 18800 21400 0    140  Italic 28
RESISTOR
Text Notes 18800 21675 0    140  Italic 28
RESISTOR
Text Notes 20525 21400 0    140  Italic 28
2000
Text Notes 20575 21675 0    140  Italic 28
200
Text Notes 21525 21400 0    140  Italic 28
±2%
Text Notes 21525 21675 0    140  Italic 28
±2%
Text Notes 22325 21400 0    140  Italic 28
1/4W
Text Notes 22325 21675 0    140  Italic 28
1/4W
$EndSCHEMATC
