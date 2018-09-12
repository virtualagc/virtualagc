EESchema Schematic File Version 4
LIBS:module-cache
EELAYER 26 0
EELAYER END
$Descr E 44000 34000
encoding utf-8
Sheet 18 63
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
F 0 "R1801" H 22575 10650 130 0001 C CNN
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
F 0 "N1801" H 22385 11875 140 0001 C CNN
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
F 0 "N1802" H 23185 11875 140 0001 C CNN
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
$EndSCHEMATC
