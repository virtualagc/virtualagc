EESchema Schematic File Version 4
LIBS:module-cache
EELAYER 26 0
EELAYER END
$Descr E 44000 34000
encoding utf-8
Sheet 2 63
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
4     6
Wire Notes Line style solid
	525  2050 25175 2050
Wire Notes Line style solid
	25175 2050 25175 13350
Wire Notes Line style solid
	525  8875 25175 8875
Wire Notes Line style solid
	17175 2050 17175 8850
Wire Notes Line
	17175 8850 17200 8850
Wire Notes Line
	17200 8850 17200 8875
Wire Notes Line style solid
	20300 8875 20300 13350
Wire Notes Line style solid
	12400 8875 12400 13350
Wire Notes Line style solid
	525  13350 25175 13350
Text HLabel 3475 10475 0    140  Input ~ 28
H
Text HLabel 6600 11925 2    140  UnSpc ~ 28
G
Text HLabel 6675 10475 2    140  Output ~ 28
J
$Comp
L AGC_DSKY:Inductor L201
U 1 1 5CD3D50C
P 4525 10475
AR Path="/5B99108F/5CD3D50C" Ref="L201"  Part="1" 
AR Path="/5B991709/5CD3D50C" Ref="L1501"  Part="1" 
AR Path="/5B991763/5CD3D50C" Ref="L1601"  Part="1" 
AR Path="/5CD3D50C" Ref="L1"  Part="1" 
F 0 "L201" H 4500 10975 130 0001 C CNN
F 1 "100 UH" H 4525 10725 130 0000 C CNN
F 2 "" H 4475 10675 130 0001 C CNN
F 3 "" H 4475 10675 130 0001 C CNN
F 4 "L1" H 4525 10925 140 0000 C CNN "baseRefd"
	1    4525 10475
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:Capacitor-Polarized C201
U 1 1 5CD3D5B5
P 5275 11200
AR Path="/5B99108F/5CD3D5B5" Ref="C201"  Part="1" 
AR Path="/5B991709/5CD3D5B5" Ref="C1501"  Part="1" 
AR Path="/5B991763/5CD3D5B5" Ref="C1601"  Part="1" 
AR Path="/5CD3D5B5" Ref="C2"  Part="1" 
F 0 "C201" H 5675 11325 130 0001 C CNN
F 1 "6.8" H 5725 11050 130 0000 C CNN
F 2 "" H 5275 11600 130 0001 C CNN
F 3 "" H 5275 11600 130 0001 C CNN
F 4 "C2" H 5725 11250 140 0000 C CNN "baseRefd"
	1    5275 11200
	1    0    0    -1  
$EndComp
Wire Wire Line
	4125 10475 3475 10475
Wire Wire Line
	4925 10475 5275 10475
Wire Wire Line
	5275 10925 5275 10475
Connection ~ 5275 10475
Wire Wire Line
	5275 10475 6675 10475
Wire Wire Line
	5275 11450 5275 11925
Wire Wire Line
	5275 11925 6600 11925
Text Notes 6775 9600 0    200  ~ 40
P  CIRCUIT
Wire Notes Line style solid
	9775 11450 10775 11450
Wire Notes Line style solid
	10775 11450 10775 10450
Wire Notes Line style solid
	10775 10450 9775 10450
Wire Notes Line style solid
	9775 10450 9775 11450
$Comp
L AGC_DSKY:HierBody N201
U 1 1 5CF0C9E8
P 9875 10950
AR Path="/5B99108F/5CF0C9E8" Ref="N201"  Part="1" 
AR Path="/5B991763/5CF0C9E8" Ref="N1601"  Part="1" 
AR Path="/5B991709/5CF0C9E8" Ref="N1501"  Part="1" 
F 0 "N201" H 9860 10750 140 0001 C CNN
F 1 "HierBody" H 9880 11130 140 0001 C CNN
F 2 "" H 9875 10950 140 0001 C CNN
F 3 "" H 9875 10950 140 0001 C CNN
F 4 "H" H 10050 10950 140 0000 C CNB "Caption2"
	1    9875 10950
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:HierBody N202
U 1 1 5CF0CA10
P 9875 11275
AR Path="/5B99108F/5CF0CA10" Ref="N202"  Part="1" 
AR Path="/5B991763/5CF0CA10" Ref="N1602"  Part="1" 
AR Path="/5B991709/5CF0CA10" Ref="N1502"  Part="1" 
F 0 "N202" H 9860 11075 140 0001 C CNN
F 1 "HierBody" H 9880 11455 140 0001 C CNN
F 2 "" H 9875 11275 140 0001 C CNN
F 3 "" H 9875 11275 140 0001 C CNN
F 4 "G" H 10050 11275 140 0000 C CNB "Caption2"
	1    9875 11275
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:HierBody N203
U 1 1 5CF0CA38
P 10675 10950
AR Path="/5B99108F/5CF0CA38" Ref="N203"  Part="1" 
AR Path="/5B991763/5CF0CA38" Ref="N1603"  Part="1" 
AR Path="/5B991709/5CF0CA38" Ref="N1503"  Part="1" 
F 0 "N203" H 10660 10750 140 0001 C CNN
F 1 "HierBody" H 10680 11130 140 0001 C CNN
F 2 "" H 10675 10950 140 0001 C CNN
F 3 "" H 10675 10950 140 0001 C CNN
F 4 "J" H 10525 10950 140 0000 C CNB "Caption2"
	1    10675 10950
	1    0    0    -1  
$EndComp
Text Notes 10850 11725 2    140  ~ 0
File: P.sch
Text Notes 10750 10425 2    140  ~ 0
Sheet: P
$EndSCHEMATC
