EESchema Schematic File Version 5
LIBS:module-cache
EELAYER 29 0
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
2005928
Text Notes 38250 33100 0    250  ~ 50
80230
Text Notes 39400 32325 0    180  ~ 36
INTERFACE A25 - 26
Text Notes 38900 33425 0    140  ~ 28
____
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
Text HLabel 3425 10400 0    140  Input ~ 28
H
Text HLabel 6550 11850 2    140  UnSpc ~ 28
G
Text HLabel 6625 10400 2    140  Output ~ 28
J
$Comp
L AGC_DSKY:Inductor 2L1
U 1 1 5CD3D50C
P 4475 10400
AR Path="/5B99108F/5CD3D50C" Ref="2L1"  Part="1" 
AR Path="/5B991709/5CD3D50C" Ref="1L1"  Part="1" 
AR Path="/5B991763/5CD3D50C" Ref="3L1"  Part="1" 
AR Path="/5CD3D50C" Ref="L1"  Part="1" 
F 0 "2L1" H 4775 10850 50  0000 C CNN
F 1 "100 UH" H 4475 10650 130 0000 C CNN
F 2 "" H 4425 10600 130 0001 C CNN
F 3 "" H 4425 10600 130 0001 C CNN
F 4 "L1" H 4450 10900 140 0000 C CNN "baseRefd"
	1    4475 10400
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:Capacitor-Polarized 2C2
U 1 1 5CD3D5B5
P 5225 11125
AR Path="/5B99108F/5CD3D5B5" Ref="2C2"  Part="1" 
AR Path="/5B991709/5CD3D5B5" Ref="1C2"  Part="1" 
AR Path="/5B991763/5CD3D5B5" Ref="3C2"  Part="1" 
AR Path="/5CD3D5B5" Ref="C2"  Part="1" 
F 0 "2C2" H 6000 11175 50  0000 C CNN
F 1 "6.8" H 5675 10975 130 0000 C CNN
F 2 "" H 5225 11525 130 0001 C CNN
F 3 "" H 5225 11525 130 0001 C CNN
F 4 "C2" H 5650 11250 140 0000 C CNN "baseRefd"
	1    5225 11125
	1    0    0    -1  
$EndComp
Wire Wire Line
	4075 10400 3425 10400
Wire Wire Line
	4875 10400 5225 10400
Wire Wire Line
	5225 10850 5225 10400
Connection ~ 5225 10400
Wire Wire Line
	5225 10400 6625 10400
Wire Wire Line
	5225 11375 5225 11850
Wire Wire Line
	5225 11850 6550 11850
Text Notes 6725 9525 0    200  ~ 40
P  CIRCUIT
Wire Notes Line style solid
	9850 11375 10850 11375
Wire Notes Line style solid
	10850 11375 10850 10375
Wire Notes Line style solid
	10850 10375 9850 10375
Wire Notes Line style solid
	9850 10375 9850 11375
$Comp
L AGC_DSKY:HierBody N201
U 1 1 5CF0C9E8
P 9950 10875
AR Path="/5B99108F/5CF0C9E8" Ref="N201"  Part="1" 
AR Path="/5B991763/5CF0C9E8" Ref="N1601"  Part="1" 
AR Path="/5B991709/5CF0C9E8" Ref="N1501"  Part="1" 
F 0 "N201" H 9935 10675 140 0001 C CNN
F 1 "HierBody" H 9955 11055 140 0001 C CNN
F 2 "" H 9950 10875 140 0001 C CNN
F 3 "" H 9950 10875 140 0001 C CNN
F 4 "H" H 10125 10875 140 0000 C CNB "Caption2"
	1    9950 10875
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:HierBody N202
U 1 1 5CF0CA10
P 9950 11200
AR Path="/5B99108F/5CF0CA10" Ref="N202"  Part="1" 
AR Path="/5B991763/5CF0CA10" Ref="N1602"  Part="1" 
AR Path="/5B991709/5CF0CA10" Ref="N1502"  Part="1" 
F 0 "N202" H 9935 11000 140 0001 C CNN
F 1 "HierBody" H 9955 11380 140 0001 C CNN
F 2 "" H 9950 11200 140 0001 C CNN
F 3 "" H 9950 11200 140 0001 C CNN
F 4 "G" H 10125 11200 140 0000 C CNB "Caption2"
	1    9950 11200
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:HierBody N203
U 1 1 5CF0CA38
P 10750 10875
AR Path="/5B99108F/5CF0CA38" Ref="N203"  Part="1" 
AR Path="/5B991763/5CF0CA38" Ref="N1603"  Part="1" 
AR Path="/5B991709/5CF0CA38" Ref="N1503"  Part="1" 
F 0 "N203" H 10735 10675 140 0001 C CNN
F 1 "HierBody" H 10755 11055 140 0001 C CNN
F 2 "" H 10750 10875 140 0001 C CNN
F 3 "" H 10750 10875 140 0001 C CNN
F 4 "J" H 10600 10875 140 0000 C CNB "Caption2"
	1    10750 10875
	1    0    0    -1  
$EndComp
Text Notes 10925 11650 2    140  ~ 0
File: P.sch
Text Notes 10825 10350 2    140  ~ 0
Sheet: P
Wire Notes Line style solid
	35626 20755 43101 20755
Wire Notes Line style solid
	43101 21030 35626 21030
Wire Notes Line style solid
	35626 21305 43101 21305
Wire Notes Line style solid
	43101 21555 35626 21555
Wire Notes Line style solid
	35626 21805 43101 21805
Wire Notes Line style solid
	43101 22055 35626 22055
Wire Notes Line style solid
	35626 22280 43101 22280
Wire Notes Line style solid
	35626 22555 43101 22555
Wire Notes Line style solid
	35626 22780 43101 22780
Wire Notes Line style solid
	35626 20755 35626 26280
Wire Notes Line style solid
	35626 23030 43101 23030
Wire Notes Line style solid
	43101 20755 43101 26280
Wire Notes Line style solid
	35626 23280 43101 23280
Wire Notes Line style solid
	36626 20755 36626 26280
Wire Notes Line style solid
	38476 20755 38476 26280
Wire Notes Line style solid
	40226 20755 40226 26280
Wire Notes Line style solid
	41376 20755 41376 26280
Wire Notes Line style solid
	42226 20755 42226 26280
Wire Notes Line style solid
	35626 26280 43101 26280
Wire Notes Line style solid
	43101 26030 35626 26030
Wire Notes Line style solid
	35626 25780 43101 25780
Wire Notes Line style solid
	43101 25530 35626 25530
Wire Notes Line style solid
	35626 25280 43101 25280
Wire Notes Line style solid
	43101 25030 35626 25030
Wire Notes Line style solid
	35626 24780 43101 24780
Wire Notes Line style solid
	43101 24530 35626 24530
Wire Notes Line style solid
	35626 24280 43101 24280
Wire Notes Line style solid
	43101 24030 35626 24030
Wire Notes Line style solid
	35626 23780 43101 23780
Wire Notes Line style solid
	43101 23530 35626 23530
Text Notes 35676 21005 0    140  ~ 28
REF DES
Text Notes 37026 21005 0    140  ~ 28
PART NO.
Text Notes 38601 21005 0    140  ~ 28
DESCRIPTION
Text Notes 40426 21005 0    140  ~ 28
VALUE
Text Notes 41626 21005 0    140  ~ 28
TOL
Text Notes 42301 21005 0    140  ~ 28
RATING
Text Notes 35775 23500 0    140  ~ 28
C2
Text Notes 35751 24530 0    140  ~ 28
L1
Text Notes 36750 23500 0    140  ~ 28
1006755-79
Text Notes 36826 24530 0    140  ~ 28
1010406-6
Text Notes 38551 24530 0    140  ~ 28
COIL,RF CHOKE
Text Notes 40425 23500 0    140  ~ 28
6.8
Text Notes 40376 24530 0    140  ~ 28
100 UH
Text Notes 41450 23500 0    140  ~ 28
±10%
Text Notes 42300 23500 0    140  ~ 28
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
Text Notes 38625 23500 0    140  ~ 28
CAPACITOR
$EndSCHEMATC
