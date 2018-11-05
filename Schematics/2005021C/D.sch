EESchema Schematic File Version 4
LIBS:module-cache
EELAYER 29 0
EELAYER END
$Descr E 44000 34000
encoding utf-8
Sheet 24 63
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
2005021
Text Notes 38250 33100 0    250  ~ 50
80230
Text Notes 39400 32325 0    180  ~ 36
INTERFACE A25 - 26
Text Notes 38900 33425 0    140  ~ 28
____
Wire Notes Line width 6 style solid
	43500 1300 36461 1300
Wire Notes Line width 6 style solid
	43500 1600 36461 1600
Wire Notes Line width 6 style solid
	43500 1900 36460 1900
Wire Notes Line width 6 style solid
	36461 1900 36461 975 
Wire Notes Line width 6 style solid
	36839 1900 36839 975 
Wire Notes Line width 6 style solid
	37350 1899 37350 974 
Wire Notes Line width 6 style solid
	40831 1899 40831 974 
Wire Notes Line width 6 style solid
	41331 1899 41331 974 
Wire Notes Line width 6 style solid
	41831 1899 41831 974 
Wire Notes Line width 6 style solid
	42480 1899 42480 974 
Text Notes 36575 1250 0    160  ~ 32
A      REVISED PER TDRR 21853
Text Notes 36550 1575 0    160  ~ 32
B      REVISED PER TDRR 25017
Text Notes 36550 1875 0    160  ~ 32
C      REVISED PER TDRR ?????
Text Notes 42400 33450 0    140  ~ 28
3     6
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
Text Notes 20425 2700 0    200  ~ 40
D CIRCUIT
$Comp
L AGC_DSKY:Resistor R2601
U 1 1 5CD537B3
P 20225 3875
AR Path="/5B991DE9/5CD537B3" Ref="R2601"  Part="1" 
AR Path="/5B991C14/5CD537B3" Ref="R2001"  Part="1" 
AR Path="/5B991C27/5CD537B3" Ref="R2101"  Part="1" 
AR Path="/5B991C81/5CD537B3" Ref="R2201"  Part="1" 
AR Path="/5B991CDB/5CD537B3" Ref="R2301"  Part="1" 
AR Path="/5B991D35/5CD537B3" Ref="R2401"  Part="1" 
AR Path="/5B991D8F/5CD537B3" Ref="R2501"  Part="1" 
AR Path="/5B991E43/5CD537B3" Ref="R2701"  Part="1" 
AR Path="/5B991E9D/5CD537B3" Ref="R2801"  Part="1" 
AR Path="/5B991EF7/5CD537B3" Ref="R2901"  Part="1" 
AR Path="/5CD537B3" Ref="R4"  Part="1" 
F 0 "R2401" H 20525 4325 50  0000 C CNN
F 1 "20K" H 20200 4100 130 0000 C CNN
F 2 "" H 20225 3875 130 0001 C CNN
F 3 "" H 20225 3875 130 0001 C CNN
F 4 "R4" H 20200 4300 140 0000 C CNN "baseRefd"
	1    20225 3875
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:Resistor R2602
U 1 1 5CD53849
P 22425 4675
AR Path="/5B991DE9/5CD53849" Ref="R2602"  Part="1" 
AR Path="/5B991C14/5CD53849" Ref="R2002"  Part="1" 
AR Path="/5B991C27/5CD53849" Ref="R2102"  Part="1" 
AR Path="/5B991C81/5CD53849" Ref="R2202"  Part="1" 
AR Path="/5B991CDB/5CD53849" Ref="R2302"  Part="1" 
AR Path="/5B991D35/5CD53849" Ref="R2402"  Part="1" 
AR Path="/5B991D8F/5CD53849" Ref="R2502"  Part="1" 
AR Path="/5B991E43/5CD53849" Ref="R2702"  Part="1" 
AR Path="/5B991E9D/5CD53849" Ref="R2802"  Part="1" 
AR Path="/5B991EF7/5CD53849" Ref="R2902"  Part="1" 
AR Path="/5CD53849" Ref="R5"  Part="1" 
F 0 "R2402" V 22325 5325 50  0000 C CNN
F 1 "2000" V 22550 5050 130 0000 C CNN
F 2 "" H 22425 4675 130 0001 C CNN
F 3 "" H 22425 4675 130 0001 C CNN
F 4 "R5" V 22325 5025 140 0000 C CNN "baseRefd"
	1    22425 4675
	0    1    1    0   
$EndComp
$Comp
L AGC_DSKY:Capacitor-Polarized C2601
U 1 1 5CD53908
P 21175 4675
AR Path="/5B991DE9/5CD53908" Ref="C2601"  Part="1" 
AR Path="/5B991C14/5CD53908" Ref="C2001"  Part="1" 
AR Path="/5B991C27/5CD53908" Ref="C2101"  Part="1" 
AR Path="/5B991C81/5CD53908" Ref="C2201"  Part="1" 
AR Path="/5B991CDB/5CD53908" Ref="C2301"  Part="1" 
AR Path="/5B991D35/5CD53908" Ref="C2401"  Part="1" 
AR Path="/5B991D8F/5CD53908" Ref="C2501"  Part="1" 
AR Path="/5B991E43/5CD53908" Ref="C2701"  Part="1" 
AR Path="/5B991E9D/5CD53908" Ref="C2801"  Part="1" 
AR Path="/5B991EF7/5CD53908" Ref="C2901"  Part="1" 
AR Path="/5CD53908" Ref="C1"  Part="1" 
F 0 "C2401" H 21875 4775 50  0000 C CNN
F 1 "6.8" H 21575 4575 130 0000 C CNN
F 2 "" H 21175 5075 130 0001 C CNN
F 3 "" H 21175 5075 130 0001 C CNN
F 4 "C1" H 21575 4775 140 0000 C CNN "baseRefd"
	1    21175 4675
	1    0    0    -1  
$EndComp
Text HLabel 23075 5425 2    140  UnSpc ~ 28
G
Text HLabel 23700 3875 2    140  Output ~ 28
F
Text HLabel 19400 3875 0    140  Input ~ 28
E
Wire Wire Line
	19400 3875 19825 3875
Wire Wire Line
	20625 3875 21175 3875
Wire Wire Line
	21175 3875 21175 4400
Connection ~ 21175 3875
Wire Wire Line
	21175 3875 22425 3875
Wire Wire Line
	22425 4275 22425 3875
Connection ~ 22425 3875
Wire Wire Line
	22425 3875 23700 3875
Wire Wire Line
	21175 4900 21175 4925
Wire Wire Line
	21175 5425 22425 5425
Wire Wire Line
	22425 5075 22425 5425
Connection ~ 22425 5425
Wire Wire Line
	22425 5425 23075 5425
Connection ~ 21175 4925
Wire Wire Line
	21175 4925 21175 5425
Wire Notes Line style solid
	20200 6700 20200 7950
Wire Notes Line style solid
	20200 7950 21400 7950
Wire Notes Line style solid
	21400 7950 21400 6700
Wire Notes Line style solid
	20200 6700 21400 6700
$Comp
L AGC_DSKY:HierBody N2001
U 1 1 5CF392C3
P 20300 7325
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
F 0 "N2401" H 20285 7125 140 0001 C CNN
F 1 "HierBody" H 20305 7505 140 0001 C CNN
F 2 "" H 20300 7325 140 0001 C CNN
F 3 "" H 20300 7325 140 0001 C CNN
F 4 "E" H 20450 7325 140 0000 C CNB "Caption2"
	1    20300 7325
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:HierBody N2002
U 1 1 5CF392EE
P 20300 7750
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
F 0 "N2402" H 20285 7550 140 0001 C CNN
F 1 "HierBody" H 20305 7930 140 0001 C CNN
F 2 "" H 20300 7750 140 0001 C CNN
F 3 "" H 20300 7750 140 0001 C CNN
F 4 "G" H 20475 7750 140 0000 C CNB "Caption2"
	1    20300 7750
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:HierBody N2003
U 1 1 5CF39319
P 21300 7325
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
F 0 "N2403" H 21285 7125 140 0001 C CNN
F 1 "HierBody" H 21305 7505 140 0001 C CNN
F 2 "" H 21300 7325 140 0001 C CNN
F 3 "" H 21300 7325 140 0001 C CNN
F 4 "F" H 21125 7325 140 0000 C CNB "Caption2"
	1    21300 7325
	1    0    0    -1  
$EndComp
Text Notes 21350 8200 2    140  ~ 0
File: D.sch
Text Notes 21250 6650 2    140  ~ 0
Sheet: D
Wire Notes Line style solid
	35529 20770 43004 20770
Wire Notes Line style solid
	43004 21045 35529 21045
Wire Notes Line style solid
	35529 21320 43004 21320
Wire Notes Line style solid
	43004 21570 35529 21570
Wire Notes Line style solid
	35529 21820 43004 21820
Wire Notes Line style solid
	43004 22070 35529 22070
Wire Notes Line style solid
	35529 22295 43004 22295
Wire Notes Line style solid
	35529 22570 43004 22570
Wire Notes Line style solid
	35529 22795 43004 22795
Wire Notes Line style solid
	35529 20770 35529 26295
Wire Notes Line style solid
	35529 23045 43004 23045
Wire Notes Line style solid
	43004 20770 43004 26295
Wire Notes Line style solid
	35529 23295 43004 23295
Wire Notes Line style solid
	36529 20770 36529 26295
Wire Notes Line style solid
	38379 20770 38379 26295
Wire Notes Line style solid
	40129 20770 40129 26295
Wire Notes Line style solid
	41279 20770 41279 26295
Wire Notes Line style solid
	42129 20770 42129 26295
Wire Notes Line style solid
	35529 26295 43004 26295
Wire Notes Line style solid
	43004 26045 35529 26045
Wire Notes Line style solid
	35529 25795 43004 25795
Wire Notes Line style solid
	43004 25545 35529 25545
Wire Notes Line style solid
	35529 25295 43004 25295
Wire Notes Line style solid
	43004 25045 35529 25045
Wire Notes Line style solid
	35529 24795 43004 24795
Wire Notes Line style solid
	43004 24545 35529 24545
Wire Notes Line style solid
	35529 24295 43004 24295
Wire Notes Line style solid
	43004 24045 35529 24045
Wire Notes Line style solid
	35529 23795 43004 23795
Wire Notes Line style solid
	43004 23545 35529 23545
Text Notes 35579 21020 0    140  ~ 28
REF DES
Text Notes 36929 21020 0    140  ~ 28
PART NO.
Text Notes 38504 21020 0    140  ~ 28
DESCRIPTION
Text Notes 40329 21020 0    140  ~ 28
VALUE
Text Notes 41529 21020 0    140  ~ 28
TOL
Text Notes 42204 21020 0    140  ~ 28
RATING
Text Notes 35654 21295 0    140  ~ 28
R1
Text Notes 35654 21545 0    140  ~ 28
R2
Text Notes 35654 21795 0    140  ~ 28
R3
Text Notes 35654 22045 0    140  ~ 28
R4
Text Notes 35654 22295 0    140  ~ 28
R5
Text Notes 35654 22545 0    140  ~ 28
R6
Text Notes 35654 22795 0    140  ~ 28
R7
Text Notes 35654 23295 0    140  ~ 28
C1
Text Notes 35654 23545 0    140  ~ 28
C2
Text Notes 35654 24045 0    140  ~ 28
CR1
Text Notes 35654 24545 0    140  ~ 28
L1
Text Notes 35654 25295 0    140  ~ 28
Q1
Text Notes 35654 25545 0    140  ~ 28
Q2
Text Notes 35679 26295 0    140  ~ 28
T1
Text Notes 36654 21295 0    140  ~ 28
1006750-32
Text Notes 37604 21545 0    140  ~ 28
-8
Text Notes 37604 21795 0    140  ~ 28
-8
Text Notes 37604 22045 0    140  ~ 28
-63
Text Notes 37604 22295 0    140  ~ 28
-39
Text Notes 37604 22545 0    140  ~ 28
-39
Text Notes 36679 22795 0    140  ~ 28
1006750-39
Text Notes 36679 23295 0    140  ~ 28
1006755-79
Text Notes 36679 23545 0    140  ~ 28
1006755-79
Text Notes 36654 24020 0    140  ~ 28
2004103-001
Text Notes 36729 24545 0    140  ~ 28
1010406-6
Text Notes 36629 25295 0    140  ~ 28
2004004-001
Text Notes 36629 25545 0    140  ~ 28
2004004-001
Text Notes 36579 26295 0    140  ~ 28
1006319
Text Notes 38529 21295 0    140  ~ 28
RESISTOR
Text Notes 38529 22795 0    140  ~ 28
RESISTOR
Text Notes 38504 23270 0    140  ~ 28
CAPACITOR
Text Notes 38504 23520 0    140  ~ 28
CAPACITOR
Text Notes 38554 24020 0    140  ~ 28
DIODE
Text Notes 38454 24545 0    140  ~ 28
COIL,RF CHOKE
Text Notes 38529 25295 0    140  ~ 28
TRANSISTOR
Text Notes 38529 25545 0    140  ~ 28
TRANSISTOR
Text Notes 38529 26270 0    140  ~ 28
TRANSFORMER
Text Notes 40304 21295 0    140  ~ 28
1000
Text Notes 40304 21545 0    140  ~ 28
100
Text Notes 40304 21795 0    140  ~ 28
100
Text Notes 40304 22045 0    140  ~ 28
20K
Text Notes 40304 22295 0    140  ~ 28
2000
Text Notes 40304 22545 0    140  ~ 28
2000
Text Notes 40304 22795 0    140  ~ 28
2000
Text Notes 40329 23270 0    140  ~ 28
6.8
Text Notes 40329 23545 0    140  ~ 28
6.8
Text Notes 40279 24545 0    140  ~ 28
100 UH
Text Notes 41429 21295 0    140  ~ 28
±2%
Text Notes 41429 22795 0    140  ~ 28
±2%
Text Notes 41379 23270 0    140  ~ 28
±10%
Text Notes 41404 23520 0    140  ~ 28
±10%
Text Notes 42254 21295 0    140  ~ 28
1/4W
Text Notes 42279 22795 0    140  ~ 28
1/4W
Text Notes 42229 23270 0    140  ~ 28
35VDC
Text Notes 42229 23520 0    140  ~ 28
35VDC
Wire Notes Line width 50 style solid
	37154 21370 37154 22520
Wire Notes Line width 50 style solid
	37154 22520 37104 22370
Wire Notes Line width 50 style solid
	37204 22370 37154 22520
Wire Notes Line width 50 style solid
	39229 21370 39229 22520
Wire Notes Line width 50 style solid
	39229 22520 39179 22370
Wire Notes Line width 50 style solid
	39279 22370 39229 22520
Wire Notes Line width 50 style solid
	41704 21370 41704 22520
Wire Notes Line width 50 style solid
	41704 22520 41654 22370
Wire Notes Line width 50 style solid
	41754 22370 41704 22520
Wire Notes Line width 50 style solid
	42554 21370 42554 22520
Wire Notes Line width 50 style solid
	42554 22520 42504 22370
Wire Notes Line width 50 style solid
	42604 22370 42554 22520
$EndSCHEMATC
