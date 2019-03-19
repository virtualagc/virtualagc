EESchema Schematic File Version 4
LIBS:module-cache
EELAYER 29 0
EELAYER END
$Descr E 44000 34000
encoding utf-8
Sheet 8 11
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
Text HLabel 34025 22100 0    140  Input Italic 28
L
Text HLabel 38150 22100 2    140  Output Italic 28
M
$Comp
L AGC_DSKY:Resistor R?
U 1 1 5CC8CF01
P 37025 22100
F 0 "R?" H 37000 21925 130 0001 C CNN
F 1 "Resistor" H 37025 22275 130 0001 C CNN
F 2 "" H 37025 22100 130 0001 C CNN
F 3 "" H 37025 22100 130 0001 C CNN
F 4 "R1" H 37000 22375 130 0000 C CIN "baseRefd"
	1    37025 22100
	1    0    0    -1  
$EndComp
Wire Wire Line
	37425 22100 38150 22100
Wire Wire Line
	36625 22100 34025 22100
Text Notes 37125 22675 2    140  Italic 28
REF DES PREFIX NO. 18
Text Notes 37150 23100 2    140  Italic 28
1 CIRCUIT PER MODULE
Text Notes 37625 23575 2    140  Italic 28
90051 THRU 90053 NAV DSKY\n90651 THRU 90653 MAIN DSKY
Wire Notes Line
	32600 21000 32600 23800
Wire Notes Line
	32600 23800 39225 23800
Wire Notes Line
	39225 23800 39225 21000
Wire Notes Line
	39225 21000 32600 21000
Wire Notes Line style solid
	24625 26975 32575 26975
Wire Notes Line style solid
	24625 27250 32575 27250
Wire Notes Line style solid
	24625 27525 32575 27525
Wire Notes Line style solid
	24625 27800 32575 27800
Wire Notes Line style solid
	24625 26975 24625 27800
Wire Notes Line style solid
	32575 26975 32575 27800
Wire Notes Line style solid
	31550 27250 31550 27800
Wire Notes Line style solid
	30775 27250 30775 27800
Wire Notes Line style solid
	29650 27250 29650 27800
Wire Notes Line style solid
	27775 27250 27775 27800
Wire Notes Line style solid
	25875 27250 25875 27800
Text Notes 24725 27500 0    140  Italic 28
REF DES
Text Notes 24975 27775 0    140  Italic 28
R1
Text Notes 26125 27225 0    140  Italic 28
90051 - 90053  &  90651 - 90653
Text Notes 26200 27500 0    140  Italic 28
PART NO.
Text Notes 26075 27775 0    140  Italic 28
1006750-56
Text Notes 28000 27500 0    140  Italic 28
DESCRIPTION
Text Notes 28125 27775 0    140  Italic 28
RESISTOR
Text Notes 29825 27500 0    140  Italic 28
VALUE
Text Notes 29900 27775 0    140  Italic 28
10K
Text Notes 30975 27500 0    140  Italic 28
TOL
Text Notes 30900 27775 0    140  Italic 28
±2%
Text Notes 31675 27500 0    140  Italic 28
RATING
Text Notes 31700 27775 0    140  Italic 28
1/4W
$EndSCHEMATC
