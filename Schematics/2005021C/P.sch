EESchema Schematic File Version 4
LIBS:module-cache
EELAYER 29 0
EELAYER END
$Descr E 44000 34000
encoding utf-8
Sheet 15 63
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
AR Path="/5B99108F/5CD3D50C" Ref="2L1"  Part="1"
AR Path="/5B991709/5CD3D50C" Ref="1L1"  Part="1"
AR Path="/5B991763/5CD3D50C" Ref="3L1"  Part="1"
AR Path="/5CD3D50C" Ref="L1"  Part="1" 
F 0 "L1501" H 4825 10925 50  0000 C CNN
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
AR Path="/5B99108F/5CD3D5B5" Ref="2C2"  Part="1"
AR Path="/5B991709/5CD3D5B5" Ref="1C2"  Part="1"
AR Path="/5B991763/5CD3D5B5" Ref="3C2"  Part="1"
AR Path="/5CD3D5B5" Ref="C2"  Part="1" 
F 0 "C1501" H 6050 11250 50  0000 C CNN
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
F 0 "N1501" H 9860 10750 140 0001 C CNN
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
F 0 "N1502" H 9860 11075 140 0001 C CNN
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
F 0 "N1503" H 10660 10750 140 0001 C CNN
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
Wire Notes Line style solid
	35526 20780 43001 20780
Wire Notes Line style solid
	43001 21055 35526 21055
Wire Notes Line style solid
	35526 21330 43001 21330
Wire Notes Line style solid
	43001 21580 35526 21580
Wire Notes Line style solid
	35526 21830 43001 21830
Wire Notes Line style solid
	43001 22080 35526 22080
Wire Notes Line style solid
	35526 22305 43001 22305
Wire Notes Line style solid
	35526 22580 43001 22580
Wire Notes Line style solid
	35526 22805 43001 22805
Wire Notes Line style solid
	35526 20780 35526 26305
Wire Notes Line style solid
	35526 23055 43001 23055
Wire Notes Line style solid
	43001 20780 43001 26305
Wire Notes Line style solid
	35526 23305 43001 23305
Wire Notes Line style solid
	36526 20780 36526 26305
Wire Notes Line style solid
	38376 20780 38376 26305
Wire Notes Line style solid
	40126 20780 40126 26305
Wire Notes Line style solid
	41276 20780 41276 26305
Wire Notes Line style solid
	42126 20780 42126 26305
Wire Notes Line style solid
	35526 26305 43001 26305
Wire Notes Line style solid
	43001 26055 35526 26055
Wire Notes Line style solid
	35526 25805 43001 25805
Wire Notes Line style solid
	43001 25555 35526 25555
Wire Notes Line style solid
	35526 25305 43001 25305
Wire Notes Line style solid
	43001 25055 35526 25055
Wire Notes Line style solid
	35526 24805 43001 24805
Wire Notes Line style solid
	43001 24555 35526 24555
Wire Notes Line style solid
	35526 24305 43001 24305
Wire Notes Line style solid
	43001 24055 35526 24055
Wire Notes Line style solid
	35526 23805 43001 23805
Wire Notes Line style solid
	43001 23555 35526 23555
Text Notes 35576 21030 0    140  ~ 28
REF DES
Text Notes 36926 21030 0    140  ~ 28
PART NO.
Text Notes 38501 21030 0    140  ~ 28
DESCRIPTION
Text Notes 40326 21030 0    140  ~ 28
VALUE
Text Notes 41526 21030 0    140  ~ 28
TOL
Text Notes 42201 21030 0    140  ~ 28
RATING
Text Notes 35651 21305 0    140  ~ 28
R1
Text Notes 35651 21555 0    140  ~ 28
R2
Text Notes 35651 21805 0    140  ~ 28
R3
Text Notes 35651 22055 0    140  ~ 28
R4
Text Notes 35651 22305 0    140  ~ 28
R5
Text Notes 35651 22555 0    140  ~ 28
R6
Text Notes 35651 22805 0    140  ~ 28
R7
Text Notes 35651 23305 0    140  ~ 28
C1
Text Notes 35651 23555 0    140  ~ 28
C2
Text Notes 35651 24055 0    140  ~ 28
CR1
Text Notes 35651 24555 0    140  ~ 28
L1
Text Notes 35651 25305 0    140  ~ 28
Q1
Text Notes 35651 25555 0    140  ~ 28
Q2
Text Notes 35676 26305 0    140  ~ 28
T1
Text Notes 36651 21305 0    140  ~ 28
1006750-32
Text Notes 37601 21555 0    140  ~ 28
-8
Text Notes 37601 21805 0    140  ~ 28
-8
Text Notes 37601 22055 0    140  ~ 28
-63
Text Notes 37601 22305 0    140  ~ 28
-39
Text Notes 37601 22555 0    140  ~ 28
-39
Text Notes 36676 22805 0    140  ~ 28
1006750-39
Text Notes 36676 23305 0    140  ~ 28
1006755-79
Text Notes 36676 23555 0    140  ~ 28
1006755-79
Text Notes 36651 24030 0    140  ~ 28
2004103-001
Text Notes 36726 24555 0    140  ~ 28
1010406-6
Text Notes 36626 25305 0    140  ~ 28
2004004-001
Text Notes 36626 25555 0    140  ~ 28
2004004-001
Text Notes 36576 26305 0    140  ~ 28
1006319
Text Notes 38526 21305 0    140  ~ 28
RESISTOR
Text Notes 38526 22805 0    140  ~ 28
RESISTOR
Text Notes 38501 23280 0    140  ~ 28
CAPACITOR
Text Notes 38501 23530 0    140  ~ 28
CAPACITOR
Text Notes 38551 24030 0    140  ~ 28
DIODE
Text Notes 38451 24555 0    140  ~ 28
COIL,RF CHOKE
Text Notes 38526 25305 0    140  ~ 28
TRANSISTOR
Text Notes 38526 25555 0    140  ~ 28
TRANSISTOR
Text Notes 38526 26280 0    140  ~ 28
TRANSFORMER
Text Notes 40301 21305 0    140  ~ 28
1000
Text Notes 40301 21555 0    140  ~ 28
100
Text Notes 40301 21805 0    140  ~ 28
100
Text Notes 40301 22055 0    140  ~ 28
20K
Text Notes 40301 22305 0    140  ~ 28
2000
Text Notes 40301 22555 0    140  ~ 28
2000
Text Notes 40301 22805 0    140  ~ 28
2000
Text Notes 40326 23280 0    140  ~ 28
6.8
Text Notes 40326 23555 0    140  ~ 28
6.8
Text Notes 40276 24555 0    140  ~ 28
100 UH
Text Notes 41426 21305 0    140  ~ 28
±2%
Text Notes 41426 22805 0    140  ~ 28
±2%
Text Notes 41376 23280 0    140  ~ 28
±10%
Text Notes 41401 23530 0    140  ~ 28
±10%
Text Notes 42251 21305 0    140  ~ 28
1/4W
Text Notes 42276 22805 0    140  ~ 28
1/4W
Text Notes 42226 23280 0    140  ~ 28
35VDC
Text Notes 42226 23530 0    140  ~ 28
35VDC
Wire Notes Line width 50 style solid
	37151 21380 37151 22530
Wire Notes Line width 50 style solid
	37151 22530 37101 22380
Wire Notes Line width 50 style solid
	37201 22380 37151 22530
Wire Notes Line width 50 style solid
	39226 21380 39226 22530
Wire Notes Line width 50 style solid
	39226 22530 39176 22380
Wire Notes Line width 50 style solid
	39276 22380 39226 22530
Wire Notes Line width 50 style solid
	41701 21380 41701 22530
Wire Notes Line width 50 style solid
	41701 22530 41651 22380
Wire Notes Line width 50 style solid
	41751 22380 41701 22530
Wire Notes Line width 50 style solid
	42551 21380 42551 22530
Wire Notes Line width 50 style solid
	42551 22530 42501 22380
Wire Notes Line width 50 style solid
	42601 22380 42551 22530
$EndSCHEMATC
