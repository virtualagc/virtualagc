EESchema Schematic File Version 4
LIBS:module-cache
EELAYER 29 0
EELAYER END
$Descr E 44000 34000
encoding utf-8
Sheet 17 63
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
6     6
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
Text Notes 21700 9300 0    200  ~ 40
R CIRCUIT
$Comp
L AGC_DSKY:Resistor R1801
U 1 1 5CD48153
P 22625 10200
AR Path="/5B99182E/5CD48153" Ref="R1801"  Part="1" 
AR Path="/5B991130/5CD48153" Ref="R401"  Part="1" 
AR Path="/5B9917D6/5CD48153" Ref="R1701"  Part="1" 
AR Path="/5B991886/5CD48153" Ref="R1901"  Part="1" 
AR Path="/5CD48153" Ref="R7"  Part="1" 
F 0 "R1701" H 22975 10625 50  0000 C CNN
F 1 "2000" H 22625 10425 130 0000 C CNN
F 2 "" H 22625 10200 130 0001 C CNN
F 3 "" H 22625 10200 130 0001 C CNN
F 4 "R7" H 22650 10625 140 0000 C CNN "baseRefd"
	1    22625 10200
	1    0    0    -1  
$EndComp
Text HLabel 21600 10200 0    140  Input ~ 28
M
Text HLabel 23600 10200 2    140  Output ~ 28
N
Wire Wire Line
	23600 10200 23025 10200
Wire Wire Line
	22225 10200 21600 10200
Wire Notes Line style solid
	22300 12550 23300 12550
Wire Notes Line style solid
	23300 12550 23300 11550
Wire Notes Line style solid
	23300 11550 22300 11550
Wire Notes Line style solid
	22300 11550 22300 12550
$Comp
L AGC_DSKY:HierBody N401
U 1 1 5CF3383C
P 22400 12075
AR Path="/5B991130/5CF3383C" Ref="N401"  Part="1" 
AR Path="/5B9917D6/5CF3383C" Ref="N1701"  Part="1" 
AR Path="/5B99182E/5CF3383C" Ref="N1801"  Part="1" 
AR Path="/5B991886/5CF3383C" Ref="N1901"  Part="1" 
F 0 "N1701" H 22385 11875 140 0001 C CNN
F 1 "HierBody" H 22405 12255 140 0001 C CNN
F 2 "" H 22400 12075 140 0001 C CNN
F 3 "" H 22400 12075 140 0001 C CNN
F 4 "M" H 22575 12075 140 0000 C CNB "Caption2"
	1    22400 12075
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:HierBody N402
U 1 1 5CF33861
P 23200 12075
AR Path="/5B991130/5CF33861" Ref="N402"  Part="1" 
AR Path="/5B9917D6/5CF33861" Ref="N1702"  Part="1" 
AR Path="/5B99182E/5CF33861" Ref="N1802"  Part="1" 
AR Path="/5B991886/5CF33861" Ref="N1902"  Part="1" 
F 0 "N1702" H 23185 11875 140 0001 C CNN
F 1 "HierBody" H 23205 12255 140 0001 C CNN
F 2 "" H 23200 12075 140 0001 C CNN
F 3 "" H 23200 12075 140 0001 C CNN
F 4 "N" H 23025 12075 140 0000 C CNB "Caption2"
	1    23200 12075
	1    0    0    -1  
$EndComp
Text Notes 23400 12825 2    140  ~ 0
File: R.sch
Text Notes 23225 11525 2    140  ~ 0
Sheet: R
Wire Notes Line style solid
	35535 20776 43010 20776
Wire Notes Line style solid
	43010 21051 35535 21051
Wire Notes Line style solid
	35535 21326 43010 21326
Wire Notes Line style solid
	43010 21576 35535 21576
Wire Notes Line style solid
	35535 21826 43010 21826
Wire Notes Line style solid
	43010 22076 35535 22076
Wire Notes Line style solid
	35535 22301 43010 22301
Wire Notes Line style solid
	35535 22576 43010 22576
Wire Notes Line style solid
	35535 22801 43010 22801
Wire Notes Line style solid
	35535 20776 35535 26301
Wire Notes Line style solid
	35535 23051 43010 23051
Wire Notes Line style solid
	43010 20776 43010 26301
Wire Notes Line style solid
	35535 23301 43010 23301
Wire Notes Line style solid
	36535 20776 36535 26301
Wire Notes Line style solid
	38385 20776 38385 26301
Wire Notes Line style solid
	40135 20776 40135 26301
Wire Notes Line style solid
	41285 20776 41285 26301
Wire Notes Line style solid
	42135 20776 42135 26301
Wire Notes Line style solid
	35535 26301 43010 26301
Wire Notes Line style solid
	43010 26051 35535 26051
Wire Notes Line style solid
	35535 25801 43010 25801
Wire Notes Line style solid
	43010 25551 35535 25551
Wire Notes Line style solid
	35535 25301 43010 25301
Wire Notes Line style solid
	43010 25051 35535 25051
Wire Notes Line style solid
	35535 24801 43010 24801
Wire Notes Line style solid
	43010 24551 35535 24551
Wire Notes Line style solid
	35535 24301 43010 24301
Wire Notes Line style solid
	43010 24051 35535 24051
Wire Notes Line style solid
	35535 23801 43010 23801
Wire Notes Line style solid
	43010 23551 35535 23551
Text Notes 35585 21026 0    140  ~ 28
REF DES
Text Notes 36935 21026 0    140  ~ 28
PART NO.
Text Notes 38510 21026 0    140  ~ 28
DESCRIPTION
Text Notes 40335 21026 0    140  ~ 28
VALUE
Text Notes 41535 21026 0    140  ~ 28
TOL
Text Notes 42210 21026 0    140  ~ 28
RATING
Text Notes 35660 21301 0    140  ~ 28
R1
Text Notes 35660 21551 0    140  ~ 28
R2
Text Notes 35660 21801 0    140  ~ 28
R3
Text Notes 35660 22051 0    140  ~ 28
R4
Text Notes 35660 22301 0    140  ~ 28
R5
Text Notes 35660 22551 0    140  ~ 28
R6
Text Notes 35660 22801 0    140  ~ 28
R7
Text Notes 35660 23301 0    140  ~ 28
C1
Text Notes 35660 23551 0    140  ~ 28
C2
Text Notes 35660 24051 0    140  ~ 28
CR1
Text Notes 35660 24551 0    140  ~ 28
L1
Text Notes 35660 25301 0    140  ~ 28
Q1
Text Notes 35660 25551 0    140  ~ 28
Q2
Text Notes 35685 26301 0    140  ~ 28
T1
Text Notes 36660 21301 0    140  ~ 28
1006750-32
Text Notes 37610 21551 0    140  ~ 28
-8
Text Notes 37610 21801 0    140  ~ 28
-8
Text Notes 37610 22051 0    140  ~ 28
-63
Text Notes 37610 22301 0    140  ~ 28
-39
Text Notes 37610 22551 0    140  ~ 28
-39
Text Notes 36685 22801 0    140  ~ 28
1006750-39
Text Notes 36685 23301 0    140  ~ 28
1006755-79
Text Notes 36685 23551 0    140  ~ 28
1006755-79
Text Notes 36660 24026 0    140  ~ 28
2004103-001
Text Notes 36735 24551 0    140  ~ 28
1010406-6
Text Notes 36635 25301 0    140  ~ 28
2004004-001
Text Notes 36635 25551 0    140  ~ 28
2004004-001
Text Notes 36585 26301 0    140  ~ 28
1006319
Text Notes 38535 21301 0    140  ~ 28
RESISTOR
Text Notes 38535 22801 0    140  ~ 28
RESISTOR
Text Notes 38510 23276 0    140  ~ 28
CAPACITOR
Text Notes 38510 23526 0    140  ~ 28
CAPACITOR
Text Notes 38560 24026 0    140  ~ 28
DIODE
Text Notes 38460 24551 0    140  ~ 28
COIL,RF CHOKE
Text Notes 38535 25301 0    140  ~ 28
TRANSISTOR
Text Notes 38535 25551 0    140  ~ 28
TRANSISTOR
Text Notes 38535 26276 0    140  ~ 28
TRANSFORMER
Text Notes 40310 21301 0    140  ~ 28
1000
Text Notes 40310 21551 0    140  ~ 28
100
Text Notes 40310 21801 0    140  ~ 28
100
Text Notes 40310 22051 0    140  ~ 28
20K
Text Notes 40310 22301 0    140  ~ 28
2000
Text Notes 40310 22551 0    140  ~ 28
2000
Text Notes 40310 22801 0    140  ~ 28
2000
Text Notes 40335 23276 0    140  ~ 28
6.8
Text Notes 40335 23551 0    140  ~ 28
6.8
Text Notes 40285 24551 0    140  ~ 28
100 UH
Text Notes 41435 21301 0    140  ~ 28
±2%
Text Notes 41435 22801 0    140  ~ 28
±2%
Text Notes 41385 23276 0    140  ~ 28
±10%
Text Notes 41410 23526 0    140  ~ 28
±10%
Text Notes 42260 21301 0    140  ~ 28
1/4W
Text Notes 42285 22801 0    140  ~ 28
1/4W
Text Notes 42235 23276 0    140  ~ 28
35VDC
Text Notes 42235 23526 0    140  ~ 28
35VDC
Wire Notes Line width 50 style solid
	37160 21376 37160 22526
Wire Notes Line width 50 style solid
	37160 22526 37110 22376
Wire Notes Line width 50 style solid
	37210 22376 37160 22526
Wire Notes Line width 50 style solid
	39235 21376 39235 22526
Wire Notes Line width 50 style solid
	39235 22526 39185 22376
Wire Notes Line width 50 style solid
	39285 22376 39235 22526
Wire Notes Line width 50 style solid
	41710 21376 41710 22526
Wire Notes Line width 50 style solid
	41710 22526 41660 22376
Wire Notes Line width 50 style solid
	41760 22376 41710 22526
Wire Notes Line width 50 style solid
	42560 21376 42560 22526
Wire Notes Line width 50 style solid
	42560 22526 42510 22376
Wire Notes Line width 50 style solid
	42610 22376 42560 22526
$EndSCHEMATC
