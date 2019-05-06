EESchema Schematic File Version 5
LIBS:module-cache
EELAYER 29 0
EELAYER END
$Descr E 44000 34000
encoding utf-8
Sheet 4 63
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
Text Notes 21800 9250 0    200  ~ 40
R CIRCUIT
$Comp
L AGC_DSKY:Resistor 2R7
U 1 1 5CD48153
P 22725 10125
AR Path="/5B99182E/5CD48153" Ref="2R7"  Part="1" 
AR Path="/5B991130/5CD48153" Ref="1R7"  Part="1" 
AR Path="/5B9917D6/5CD48153" Ref="4R7"  Part="1" 
AR Path="/5B991886/5CD48153" Ref="3R7"  Part="1" 
AR Path="/5CD48153" Ref="R7"  Part="1" 
F 0 "1R7" H 23075 10550 50  0000 C CNN
F 1 "2000" H 22725 10350 130 0000 C CNN
F 2 "" H 22725 10125 130 0001 C CNN
F 3 "" H 22725 10125 130 0001 C CNN
F 4 "R7" H 22700 10575 140 0000 C CNN "baseRefd"
	1    22725 10125
	1    0    0    -1  
$EndComp
Text HLabel 21700 10125 0    140  Input ~ 28
M
Text HLabel 23700 10125 2    140  Output ~ 28
N
Wire Wire Line
	23700 10125 23125 10125
Wire Wire Line
	22325 10125 21700 10125
Wire Notes Line style solid
	22400 12500 23400 12500
Wire Notes Line style solid
	23400 12500 23400 11500
Wire Notes Line style solid
	23400 11500 22400 11500
Wire Notes Line style solid
	22400 11500 22400 12500
$Comp
L AGC_DSKY:HierBody N401
U 1 1 5CF3383C
P 22500 12025
AR Path="/5B991130/5CF3383C" Ref="N401"  Part="1" 
AR Path="/5B9917D6/5CF3383C" Ref="N1701"  Part="1" 
AR Path="/5B99182E/5CF3383C" Ref="N1801"  Part="1" 
AR Path="/5B991886/5CF3383C" Ref="N1901"  Part="1" 
F 0 "N401" H 22485 11825 140 0001 C CNN
F 1 "HierBody" H 22505 12205 140 0001 C CNN
F 2 "" H 22500 12025 140 0001 C CNN
F 3 "" H 22500 12025 140 0001 C CNN
F 4 "M" H 22675 12025 140 0000 C CNB "Caption2"
	1    22500 12025
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:HierBody N402
U 1 1 5CF33861
P 23300 12025
AR Path="/5B991130/5CF33861" Ref="N402"  Part="1" 
AR Path="/5B9917D6/5CF33861" Ref="N1702"  Part="1" 
AR Path="/5B99182E/5CF33861" Ref="N1802"  Part="1" 
AR Path="/5B991886/5CF33861" Ref="N1902"  Part="1" 
F 0 "N402" H 23285 11825 140 0001 C CNN
F 1 "HierBody" H 23305 12205 140 0001 C CNN
F 2 "" H 23300 12025 140 0001 C CNN
F 3 "" H 23300 12025 140 0001 C CNN
F 4 "N" H 23125 12025 140 0000 C CNB "Caption2"
	1    23300 12025
	1    0    0    -1  
$EndComp
Text Notes 23500 12775 2    140  ~ 0
File: R.sch
Text Notes 23325 11475 2    140  ~ 0
Sheet: R
Wire Notes Line style solid
	35635 20751 43110 20751
Wire Notes Line style solid
	43110 21026 35635 21026
Wire Notes Line style solid
	35635 21301 43110 21301
Wire Notes Line style solid
	43110 21551 35635 21551
Wire Notes Line style solid
	35635 21801 43110 21801
Wire Notes Line style solid
	43110 22051 35635 22051
Wire Notes Line style solid
	35635 22276 43110 22276
Wire Notes Line style solid
	35635 22551 43110 22551
Wire Notes Line style solid
	35635 22776 43110 22776
Wire Notes Line style solid
	35635 20751 35635 26276
Wire Notes Line style solid
	35635 23026 43110 23026
Wire Notes Line style solid
	43110 20751 43110 26276
Wire Notes Line style solid
	35635 23276 43110 23276
Wire Notes Line style solid
	36635 20751 36635 26276
Wire Notes Line style solid
	38485 20751 38485 26276
Wire Notes Line style solid
	40235 20751 40235 26276
Wire Notes Line style solid
	41385 20751 41385 26276
Wire Notes Line style solid
	42235 20751 42235 26276
Wire Notes Line style solid
	35635 26276 43110 26276
Wire Notes Line style solid
	43110 26026 35635 26026
Wire Notes Line style solid
	35635 25776 43110 25776
Wire Notes Line style solid
	43110 25526 35635 25526
Wire Notes Line style solid
	35635 25276 43110 25276
Wire Notes Line style solid
	43110 25026 35635 25026
Wire Notes Line style solid
	35635 24776 43110 24776
Wire Notes Line style solid
	43110 24526 35635 24526
Wire Notes Line style solid
	35635 24276 43110 24276
Wire Notes Line style solid
	43110 24026 35635 24026
Wire Notes Line style solid
	35635 23776 43110 23776
Wire Notes Line style solid
	43110 23526 35635 23526
Text Notes 35685 21001 0    140  ~ 28
REF DES
Text Notes 37035 21001 0    140  ~ 28
PART NO.
Text Notes 38610 21001 0    140  ~ 28
DESCRIPTION
Text Notes 40435 21001 0    140  ~ 28
VALUE
Text Notes 41635 21001 0    140  ~ 28
TOL
Text Notes 42310 21001 0    140  ~ 28
RATING
Text Notes 35760 22776 0    140  ~ 28
R7
Text Notes 36785 22776 0    140  ~ 28
1006750-39
Text Notes 38635 22776 0    140  ~ 28
RESISTOR
Text Notes 40410 22776 0    140  ~ 28
2000
Text Notes 41535 22776 0    140  ~ 28
±2%
Text Notes 42385 22776 0    140  ~ 28
1/4W
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
