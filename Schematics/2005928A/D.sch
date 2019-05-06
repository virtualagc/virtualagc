EESchema Schematic File Version 5
LIBS:module-cache
EELAYER 29 0
EELAYER END
$Descr E 44000 34000
encoding utf-8
Sheet 23 63
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text Notes 38425 31900 0    225  ~ 45
SCHEMATIC & FLOW DIAGRAM
Text Notes 40875 33100 0    250  ~ 50
2005928
Text Notes 38250 33100 0    250  ~ 50
80230
Text Notes 39400 32325 0    180  ~ 36
INTERFACE A25 - 26
Text Notes 38900 33425 0    140  ~ 28
____
Wire Notes Line style solid
	550  2050 25200 2050
Wire Notes Line style solid
	25200 2050 25200 13350
Wire Notes Line style solid
	550  8875 25200 8875
Wire Notes Line style solid
	17200 2050 17200 8850
Wire Notes Line
	17200 8850 17225 8850
Wire Notes Line
	17225 8850 17225 8875
Wire Notes Line style solid
	20325 8875 20325 13350
Wire Notes Line style solid
	12425 8875 12425 13350
Wire Notes Line style solid
	550  13350 25200 13350
Text Notes 20500 2625 0    200  ~ 40
D CIRCUIT
$Comp
L AGC_DSKY:Resistor 4R4
U 1 1 5CD537B3
P 20325 3800
AR Path="/5B991DE9/5CD537B3" Ref="4R4"  Part="1" 
AR Path="/5B991C14/5CD537B3" Ref="10R4"  Part="1" 
AR Path="/5B991C27/5CD537B3" Ref="9R4"  Part="1" 
AR Path="/5B991C81/5CD537B3" Ref="8R4"  Part="1" 
AR Path="/5B991CDB/5CD537B3" Ref="7R4"  Part="1" 
AR Path="/5B991D35/5CD537B3" Ref="6R4"  Part="1" 
AR Path="/5B991D8F/5CD537B3" Ref="5R4"  Part="1" 
AR Path="/5B991E43/5CD537B3" Ref="3R4"  Part="1" 
AR Path="/5B991E9D/5CD537B3" Ref="2R4"  Part="1" 
AR Path="/5B991EF7/5CD537B3" Ref="1R4"  Part="1" 
AR Path="/5CD537B3" Ref="R4"  Part="1" 
F 0 "7R4" H 20625 4250 50  0000 C CNN
F 1 "20K" H 20300 4025 130 0000 C CNN
F 2 "" H 20325 3800 130 0001 C CNN
F 3 "" H 20325 3800 130 0001 C CNN
F 4 "R4" H 20250 4250 140 0000 C CNN "baseRefd"
	1    20325 3800
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:Resistor 4R5
U 1 1 5CD53849
P 22525 4600
AR Path="/5B991DE9/5CD53849" Ref="4R5"  Part="1" 
AR Path="/5B991C14/5CD53849" Ref="10R5"  Part="1" 
AR Path="/5B991C27/5CD53849" Ref="9R5"  Part="1" 
AR Path="/5B991C81/5CD53849" Ref="8R5"  Part="1" 
AR Path="/5B991CDB/5CD53849" Ref="7R5"  Part="1" 
AR Path="/5B991D35/5CD53849" Ref="6R5"  Part="1" 
AR Path="/5B991D8F/5CD53849" Ref="5R5"  Part="1" 
AR Path="/5B991E43/5CD53849" Ref="3R5"  Part="1" 
AR Path="/5B991E9D/5CD53849" Ref="2R5"  Part="1" 
AR Path="/5B991EF7/5CD53849" Ref="1R5"  Part="1" 
AR Path="/5CD53849" Ref="R5"  Part="1" 
F 0 "7R5" V 22425 5250 50  0000 C CNN
F 1 "2000" V 22650 4975 130 0000 C CNN
F 2 "" H 22525 4600 130 0001 C CNN
F 3 "" H 22525 4600 130 0001 C CNN
F 4 "R5" V 22350 4925 140 0000 C CNN "baseRefd"
	1    22525 4600
	0    1    1    0   
$EndComp
$Comp
L AGC_DSKY:Capacitor-Polarized 4C1
U 1 1 5CD53908
P 21275 4600
AR Path="/5B991DE9/5CD53908" Ref="4C1"  Part="1" 
AR Path="/5B991C14/5CD53908" Ref="10C1"  Part="1" 
AR Path="/5B991C27/5CD53908" Ref="9C1"  Part="1" 
AR Path="/5B991C81/5CD53908" Ref="8C1"  Part="1" 
AR Path="/5B991CDB/5CD53908" Ref="7C1"  Part="1" 
AR Path="/5B991D35/5CD53908" Ref="6C1"  Part="1" 
AR Path="/5B991D8F/5CD53908" Ref="5C1"  Part="1" 
AR Path="/5B991E43/5CD53908" Ref="3C1"  Part="1" 
AR Path="/5B991E9D/5CD53908" Ref="2C1"  Part="1" 
AR Path="/5B991EF7/5CD53908" Ref="1C1"  Part="1" 
AR Path="/5CD53908" Ref="C1"  Part="1" 
F 0 "7C1" H 21975 4700 50  0000 C CNN
F 1 "6.8" H 21675 4500 130 0000 C CNN
F 2 "" H 21275 5000 130 0001 C CNN
F 3 "" H 21275 5000 130 0001 C CNN
F 4 "C1" H 21650 4775 140 0000 C CNN "baseRefd"
	1    21275 4600
	1    0    0    -1  
$EndComp
Text HLabel 23175 5350 2    140  UnSpc ~ 28
G
Text HLabel 23800 3800 2    140  Output ~ 28
F
Text HLabel 19500 3800 0    140  Input ~ 28
E
Wire Wire Line
	19500 3800 19925 3800
Wire Wire Line
	20725 3800 21275 3800
Wire Wire Line
	21275 3800 21275 4325
Connection ~ 21275 3800
Wire Wire Line
	21275 3800 22525 3800
Wire Wire Line
	22525 4200 22525 3800
Connection ~ 22525 3800
Wire Wire Line
	22525 3800 23800 3800
Wire Wire Line
	21275 5350 22525 5350
Wire Wire Line
	22525 5000 22525 5350
Connection ~ 22525 5350
Wire Wire Line
	22525 5350 23175 5350
Wire Wire Line
	21275 4850 21275 5350
Wire Notes Line style solid
	20300 6600 20300 7850
Wire Notes Line style solid
	20300 7850 21500 7850
Wire Notes Line style solid
	21500 7850 21500 6600
Wire Notes Line style solid
	20300 6600 21500 6600
$Comp
L AGC_DSKY:HierBody N2001
U 1 1 5CF392C3
P 20400 7225
AR Path="/5B991C14/5CF392C3" Ref="N2001"  Part="1" 
AR Path="/5B991C27/5CF392C3" Ref="N2101"  Part="1" 
AR Path="/5B991C81/5CF392C3" Ref="N2201"  Part="1" 
AR Path="/5B991CDB/5CF392C3" Ref="N2301"  Part="1" 
AR Path="/5B991D35/5CF392C3" Ref="N2401"  Part="1" 
AR Path="/5B991D8F/5CF392C3" Ref="N2501"  Part="1" 
AR Path="/5B991DE9/5CF392C3" Ref="N2601"  Part="1" 
AR Path="/5B991E43/5CF392C3" Ref="N2701"  Part="1" 
AR Path="/5B991E9D/5CF392C3" Ref="N2801"  Part="1" 
AR Path="/5B991EF7/5CF392C3" Ref="N2901"  Part="1" 
F 0 "N2301" H 20385 7025 140 0001 C CNN
F 1 "HierBody" H 20405 7405 140 0001 C CNN
F 2 "" H 20400 7225 140 0001 C CNN
F 3 "" H 20400 7225 140 0001 C CNN
F 4 "E" H 20550 7225 140 0000 C CNB "Caption2"
	1    20400 7225
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:HierBody N2002
U 1 1 5CF392EE
P 20400 7650
AR Path="/5B991C14/5CF392EE" Ref="N2002"  Part="1" 
AR Path="/5B991C27/5CF392EE" Ref="N2102"  Part="1" 
AR Path="/5B991C81/5CF392EE" Ref="N2202"  Part="1" 
AR Path="/5B991CDB/5CF392EE" Ref="N2302"  Part="1" 
AR Path="/5B991D35/5CF392EE" Ref="N2402"  Part="1" 
AR Path="/5B991D8F/5CF392EE" Ref="N2502"  Part="1" 
AR Path="/5B991DE9/5CF392EE" Ref="N2602"  Part="1" 
AR Path="/5B991E43/5CF392EE" Ref="N2702"  Part="1" 
AR Path="/5B991E9D/5CF392EE" Ref="N2802"  Part="1" 
AR Path="/5B991EF7/5CF392EE" Ref="N2902"  Part="1" 
F 0 "N2302" H 20385 7450 140 0001 C CNN
F 1 "HierBody" H 20405 7830 140 0001 C CNN
F 2 "" H 20400 7650 140 0001 C CNN
F 3 "" H 20400 7650 140 0001 C CNN
F 4 "G" H 20575 7650 140 0000 C CNB "Caption2"
	1    20400 7650
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:HierBody N2003
U 1 1 5CF39319
P 21400 7225
AR Path="/5B991C14/5CF39319" Ref="N2003"  Part="1" 
AR Path="/5B991C27/5CF39319" Ref="N2103"  Part="1" 
AR Path="/5B991C81/5CF39319" Ref="N2203"  Part="1" 
AR Path="/5B991CDB/5CF39319" Ref="N2303"  Part="1" 
AR Path="/5B991D35/5CF39319" Ref="N2403"  Part="1" 
AR Path="/5B991D8F/5CF39319" Ref="N2503"  Part="1" 
AR Path="/5B991DE9/5CF39319" Ref="N2603"  Part="1" 
AR Path="/5B991E43/5CF39319" Ref="N2703"  Part="1" 
AR Path="/5B991E9D/5CF39319" Ref="N2803"  Part="1" 
AR Path="/5B991EF7/5CF39319" Ref="N2903"  Part="1" 
F 0 "N2303" H 21385 7025 140 0001 C CNN
F 1 "HierBody" H 21405 7405 140 0001 C CNN
F 2 "" H 21400 7225 140 0001 C CNN
F 3 "" H 21400 7225 140 0001 C CNN
F 4 "F" H 21225 7225 140 0000 C CNB "Caption2"
	1    21400 7225
	1    0    0    -1  
$EndComp
Text Notes 21450 8100 2    140  ~ 0
File: D.sch
Text Notes 21350 6550 2    140  ~ 0
Sheet: D
Wire Notes Line style solid
	35629 20720 43104 20720
Wire Notes Line style solid
	43104 20995 35629 20995
Wire Notes Line style solid
	35629 21270 43104 21270
Wire Notes Line style solid
	43104 21520 35629 21520
Wire Notes Line style solid
	35629 21770 43104 21770
Wire Notes Line style solid
	43104 22020 35629 22020
Wire Notes Line style solid
	35629 22245 43104 22245
Wire Notes Line style solid
	35629 22520 43104 22520
Wire Notes Line style solid
	35629 22745 43104 22745
Wire Notes Line style solid
	35629 20720 35629 26245
Wire Notes Line style solid
	35629 22995 43104 22995
Wire Notes Line style solid
	43104 20720 43104 26245
Wire Notes Line style solid
	35629 23245 43104 23245
Wire Notes Line style solid
	36629 20720 36629 26245
Wire Notes Line style solid
	38479 20720 38479 26245
Wire Notes Line style solid
	40229 20720 40229 26245
Wire Notes Line style solid
	41379 20720 41379 26245
Wire Notes Line style solid
	42229 20720 42229 26245
Wire Notes Line style solid
	35629 26245 43104 26245
Wire Notes Line style solid
	43104 25995 35629 25995
Wire Notes Line style solid
	35629 25745 43104 25745
Wire Notes Line style solid
	43104 25495 35629 25495
Wire Notes Line style solid
	35629 25245 43104 25245
Wire Notes Line style solid
	43104 24995 35629 24995
Wire Notes Line style solid
	35629 24745 43104 24745
Wire Notes Line style solid
	43104 24495 35629 24495
Wire Notes Line style solid
	35629 24245 43104 24245
Wire Notes Line style solid
	43104 23995 35629 23995
Wire Notes Line style solid
	35629 23745 43104 23745
Wire Notes Line style solid
	43104 23495 35629 23495
Text Notes 35679 20970 0    140  ~ 28
REF DES
Text Notes 37029 20970 0    140  ~ 28
PART NO.
Text Notes 38604 20970 0    140  ~ 28
DESCRIPTION
Text Notes 40429 20970 0    140  ~ 28
VALUE
Text Notes 41629 20970 0    140  ~ 28
TOL
Text Notes 42304 20970 0    140  ~ 28
RATING
Text Notes 35754 21995 0    140  ~ 28
R4
Text Notes 35754 22245 0    140  ~ 28
R5
Text Notes 35750 23225 0    140  ~ 28
C1
Text Notes 36750 22000 0    140  ~ 28
1006750-63
Text Notes 36750 22250 0    140  ~ 28
1006750-39
Text Notes 36775 23225 0    140  ~ 28
1006755-79
Text Notes 38625 22000 0    140  ~ 28
RESISTOR
Text Notes 38625 22250 0    140  ~ 28
RESISTOR
Text Notes 38604 23220 0    140  ~ 28
CAPACITOR
Text Notes 40404 21995 0    140  ~ 28
20K
Text Notes 40404 22245 0    140  ~ 28
2000
Text Notes 40429 23220 0    140  ~ 28
6.8
Text Notes 41525 22000 0    140  ~ 28
±2%
Text Notes 41525 22250 0    140  ~ 28
±2%
Text Notes 41479 23220 0    140  ~ 28
±10%
Text Notes 42350 22000 0    140  ~ 28
1/4W
Text Notes 42350 22250 0    140  ~ 28
1/4W
Text Notes 42329 23220 0    140  ~ 28
35VDC
Wire Notes Line width 6 style solid
	43500 1300 36461 1300
Wire Notes Line width 6 style solid
	36461 1300 36461 975 
Wire Notes Line width 6 style solid
	36839 1300 36839 975 
Wire Notes Line width 6 style solid
	37350 1299 37350 974 
Wire Notes Line width 6 style solid
	40831 1299 40831 974 
Wire Notes Line width 6 style solid
	41331 1299 41331 974 
Wire Notes Line width 6 style solid
	41831 1299 41831 974 
Wire Notes Line width 6 style solid
	42480 1299 42480 974 
Text Notes 36575 1250 0    140  ~ 28
A      INITIAL RELEASE TDRR 32559
$EndSCHEMATC
