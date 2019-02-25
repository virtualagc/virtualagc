EESchema Schematic File Version 4
LIBS:module-cache
EELAYER 29 0
EELAYER END
$Descr E 44000 34000
encoding utf-8
Sheet 7 63
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
2     6
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
Text Notes 8175 2700 0    200  ~ 40
XT CIRCUIT
Text HLabel 3475 4700 0    140  Input ~ 28
A
$Comp
L AGC_DSKY:Transistor-NPN Q?
U 1 1 5CD321C6
P 5000 4700
AR Path="/5B99108F/5CD321C6" Ref="Q?"  Part="1" 
AR Path="/5B9910B1/5CD321C6" Ref="4Q1"  Part="1"
AR Path="/5B991354/5CD321C6" Ref="5Q1"  Part="1"
AR Path="/5B9913B2/5CD321C6" Ref="6Q1"  Part="1"
AR Path="/5B991410/5CD321C6" Ref="7Q1"  Part="1"
AR Path="/5B99146E/5CD321C6" Ref="3Q1"  Part="1"
AR Path="/5B9914CC/5CD321C6" Ref="2Q1"  Part="1"
AR Path="/5B99152A/5CD321C6" Ref="1Q1"  Part="1"
AR Path="/5B991588/5CD321C6" Ref="11Q1"  Part="1"
AR Path="/5B9915E6/5CD321C6" Ref="10Q1"  Part="1"
AR Path="/5B991644/5CD321C6" Ref="9Q1"  Part="1"
AR Path="/5B9916A2/5CD321C6" Ref="8Q1"  Part="1"
AR Path="/5CD321C6" Ref="Q1"  Part="1" 
F 0 "Q701" H 4625 4225 50  0000 C CNN
F 1 "Transistor-NPN" H 5000 5265 130 0001 C CNN
F 2 "" H 5000 4950 130 0001 C CNN
F 3 "" H 5000 4950 130 0001 C CNN
F 4 "Q1" H 4600 4375 140 0000 C CNN "baseRefd"
	1    5000 4700
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:Resistor R?
U 1 1 5CD321CD
P 6250 5100
AR Path="/5B99108F/5CD321CD" Ref="R?"  Part="1" 
AR Path="/5B9910B1/5CD321CD" Ref="4R1"  Part="1"
AR Path="/5B991354/5CD321CD" Ref="5R1"  Part="1"
AR Path="/5B9913B2/5CD321CD" Ref="6R1"  Part="1"
AR Path="/5B991410/5CD321CD" Ref="7R1"  Part="1"
AR Path="/5B99146E/5CD321CD" Ref="3R1"  Part="1"
AR Path="/5B9914CC/5CD321CD" Ref="2R1"  Part="1"
AR Path="/5B99152A/5CD321CD" Ref="1R1"  Part="1"
AR Path="/5B991588/5CD321CD" Ref="11R1"  Part="1"
AR Path="/5B9915E6/5CD321CD" Ref="10R1"  Part="1"
AR Path="/5B991644/5CD321CD" Ref="9R1"  Part="1"
AR Path="/5B9916A2/5CD321CD" Ref="8R1"  Part="1"
AR Path="/5CD321CD" Ref="R1"  Part="1" 
F 0 "R701" V 6100 5825 50  0000 C CNN
F 1 "1000" V 6350 5525 130 0000 C CNN
F 2 "" H 6250 5100 130 0001 C CNN
F 3 "" H 6250 5100 130 0001 C CNN
F 4 "R1" V 6100 5525 140 0000 C CNN "baseRefd"
	1    6250 5100
	0    1    1    0   
$EndComp
$Comp
L AGC_DSKY:Resistor R?
U 1 1 5CD321D4
P 7750 5750
AR Path="/5B99108F/5CD321D4" Ref="R?"  Part="1" 
AR Path="/5B9910B1/5CD321D4" Ref="4R2"  Part="1"
AR Path="/5B991354/5CD321D4" Ref="5R2"  Part="1"
AR Path="/5B9913B2/5CD321D4" Ref="6R2"  Part="1"
AR Path="/5B991410/5CD321D4" Ref="7R2"  Part="1"
AR Path="/5B99146E/5CD321D4" Ref="3R2"  Part="1"
AR Path="/5B9914CC/5CD321D4" Ref="2R2"  Part="1"
AR Path="/5B99152A/5CD321D4" Ref="1R2"  Part="1"
AR Path="/5B991588/5CD321D4" Ref="11R2"  Part="1"
AR Path="/5B9915E6/5CD321D4" Ref="10R2"  Part="1"
AR Path="/5B991644/5CD321D4" Ref="9R2"  Part="1"
AR Path="/5B9916A2/5CD321D4" Ref="8R2"  Part="1"
AR Path="/5CD321D4" Ref="R2"  Part="1" 
F 0 "R702" V 7575 6425 50  0000 C CNN
F 1 "100" V 7800 6100 130 0000 C CNN
F 2 "" H 7750 5750 130 0001 C CNN
F 3 "" H 7750 5750 130 0001 C CNN
F 4 "R2" V 7575 6100 140 0000 C CNN "baseRefd"
	1    7750 5750
	0    1    1    0   
$EndComp
$Comp
L AGC_DSKY:Resistor R?
U 1 1 5CD321DB
P 7750 6700
AR Path="/5B99108F/5CD321DB" Ref="R?"  Part="1" 
AR Path="/5B9910B1/5CD321DB" Ref="4R3"  Part="1"
AR Path="/5B991354/5CD321DB" Ref="5R3"  Part="1"
AR Path="/5B9913B2/5CD321DB" Ref="6R3"  Part="1"
AR Path="/5B991410/5CD321DB" Ref="7R3"  Part="1"
AR Path="/5B99146E/5CD321DB" Ref="3R3"  Part="1"
AR Path="/5B9914CC/5CD321DB" Ref="2R3"  Part="1"
AR Path="/5B99152A/5CD321DB" Ref="1R3"  Part="1"
AR Path="/5B991588/5CD321DB" Ref="11R3"  Part="1"
AR Path="/5B9915E6/5CD321DB" Ref="10R3"  Part="1"
AR Path="/5B991644/5CD321DB" Ref="9R3"  Part="1"
AR Path="/5B9916A2/5CD321DB" Ref="8R3"  Part="1"
AR Path="/5CD321DB" Ref="R3"  Part="1" 
F 0 "R703" V 7525 7375 50  0000 C CNN
F 1 "100" V 7750 7050 130 0000 C CNN
F 2 "" H 7750 6700 130 0001 C CNN
F 3 "" H 7750 6700 130 0001 C CNN
F 4 "R3" V 7525 7050 140 0000 C CNN "baseRefd"
	1    7750 6700
	0    1    1    0   
$EndComp
Wire Wire Line
	4700 4700 3475 4700
Wire Wire Line
	5150 4450 5150 3950
Wire Wire Line
	5150 3950 6250 3950
Wire Wire Line
	6250 3950 6250 4700
Wire Wire Line
	5050 5800 5175 5800
Wire Wire Line
	5175 5800 5175 4950
Wire Wire Line
	5175 4950 5150 4950
$Comp
L AGC_DSKY:Diode CR?
U 1 1 5CD321E9
P 6250 6250
AR Path="/5B99108F/5CD321E9" Ref="CR?"  Part="1" 
AR Path="/5B9910B1/5CD321E9" Ref="4CR1"  Part="1"
AR Path="/5B991354/5CD321E9" Ref="5CR1"  Part="1"
AR Path="/5B9913B2/5CD321E9" Ref="6CR1"  Part="1"
AR Path="/5B991410/5CD321E9" Ref="7CR1"  Part="1"
AR Path="/5B99146E/5CD321E9" Ref="3CR1"  Part="1"
AR Path="/5B9914CC/5CD321E9" Ref="2CR1"  Part="1"
AR Path="/5B99152A/5CD321E9" Ref="1CR1"  Part="1"
AR Path="/5B991588/5CD321E9" Ref="11CR1"  Part="1"
AR Path="/5B9915E6/5CD321E9" Ref="10CR1"  Part="1"
AR Path="/5B991644/5CD321E9" Ref="9CR1"  Part="1"
AR Path="/5B9916A2/5CD321E9" Ref="8CR1"  Part="1"
AR Path="/5CD321E9" Ref="CR1"  Part="1" 
F 0 "CR701" V 6300 5500 50  0000 C CNN
F 1 "Diode" H 6250 6100 50  0001 C CNN
F 2 "" H 6200 6075 50  0001 C CNN
F 3 "" H 6200 6250 50  0001 C CNN
F 4 "CR1" V 6300 5875 140 0000 C CNN "baseRefd"
	1    6250 6250
	0    -1   -1   0   
$EndComp
Wire Wire Line
	6250 5500 6250 6050
Wire Wire Line
	6250 6450 6250 7225
Wire Wire Line
	6250 7225 7750 7225
Wire Wire Line
	9450 7225 9450 7525
Wire Wire Line
	9450 7525 9275 7525
Wire Wire Line
	7750 7100 7750 7225
Connection ~ 7750 7225
Wire Wire Line
	7750 7225 9450 7225
Wire Wire Line
	7750 6300 7750 6150
$Comp
L AGC_DSKY:Transformer T?
U 1 1 5CD321F9
P 8875 4550
AR Path="/5B99108F/5CD321F9" Ref="T?"  Part="1" 
AR Path="/5B9910B1/5CD321F9" Ref="4T1"  Part="1"
AR Path="/5B991354/5CD321F9" Ref="5T1"  Part="1"
AR Path="/5B9913B2/5CD321F9" Ref="6T1"  Part="1"
AR Path="/5B991410/5CD321F9" Ref="7T1"  Part="1"
AR Path="/5B99146E/5CD321F9" Ref="3T1"  Part="1"
AR Path="/5B9914CC/5CD321F9" Ref="2T1"  Part="1"
AR Path="/5B99152A/5CD321F9" Ref="1T1"  Part="1"
AR Path="/5B991588/5CD321F9" Ref="11T1"  Part="1"
AR Path="/5B9915E6/5CD321F9" Ref="10T1"  Part="1"
AR Path="/5B991644/5CD321F9" Ref="9T1"  Part="1"
AR Path="/5B9916A2/5CD321F9" Ref="8T1"  Part="1"
AR Path="/5CD321F9" Ref="T1"  Part="1" 
F 0 "T701" H 9175 5575 50  0000 C CNN
F 1 "2:1" H 8875 5325 130 0000 C CNN
F 2 "" V 8850 3900 130 0001 C CNN
F 3 "" V 8850 3900 130 0001 C CNN
F 4 "T1" H 8900 5550 140 0000 C CNN "baseRefd"
	1    8875 4550
	1    0    0    -1  
$EndComp
Wire Wire Line
	10600 4150 9500 4150
Text HLabel 10600 4150 2    140  Output ~ 28
B
Text HLabel 10600 4950 2    140  Output ~ 28
C
Wire Wire Line
	9500 4950 10600 4950
Text HLabel 5050 5800 0    140  Input ~ 28
G
Text HLabel 9275 7525 0    140  Input ~ 28
D
Wire Wire Line
	6250 3950 8250 3950
Connection ~ 6250 3950
Wire Wire Line
	7750 5350 7750 5150
Wire Wire Line
	7750 5150 8250 5150
Wire Notes Line style solid
	13200 5825 13200 7075
Wire Notes Line style solid
	13200 7075 14450 7075
Wire Notes Line style solid
	14450 7075 14450 5825
Wire Notes Line style solid
	14450 5825 13200 5825
$Comp
L AGC_DSKY:HierBody N302
U 1 1 5CF2DE5E
P 13300 6450
AR Path="/5B9910B1/5CF2DE5E" Ref="N302"  Part="1" 
AR Path="/5B991354/5CF2DE5E" Ref="N502"  Part="1" 
AR Path="/5B9913B2/5CF2DE5E" Ref="N602"  Part="1" 
AR Path="/5B991410/5CF2DE5E" Ref="N702"  Part="1" 
AR Path="/5B99146E/5CF2DE5E" Ref="N802"  Part="1" 
AR Path="/5B9914CC/5CF2DE5E" Ref="N902"  Part="1" 
AR Path="/5B99152A/5CF2DE5E" Ref="N1002"  Part="1" 
AR Path="/5B991588/5CF2DE5E" Ref="N1102"  Part="1" 
AR Path="/5B9915E6/5CF2DE5E" Ref="N1202"  Part="1" 
AR Path="/5B991644/5CF2DE5E" Ref="N1302"  Part="1" 
AR Path="/5B9916A2/5CF2DE5E" Ref="N1402"  Part="1" 
F 0 "N702" H 13285 6250 140 0001 C CNN
F 1 "HierBody" H 13305 6630 140 0001 C CNN
F 2 "" H 13300 6450 140 0001 C CNN
F 3 "" H 13300 6450 140 0001 C CNN
F 4 "A" H 13475 6475 140 0000 C CNB "Caption2"
	1    13300 6450
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:HierBody N301
U 1 1 5CF2DE92
P 13300 6025
AR Path="/5B9910B1/5CF2DE92" Ref="N301"  Part="1" 
AR Path="/5B991354/5CF2DE92" Ref="N501"  Part="1" 
AR Path="/5B9913B2/5CF2DE92" Ref="N601"  Part="1" 
AR Path="/5B991410/5CF2DE92" Ref="N701"  Part="1" 
AR Path="/5B99146E/5CF2DE92" Ref="N801"  Part="1" 
AR Path="/5B9914CC/5CF2DE92" Ref="N901"  Part="1" 
AR Path="/5B99152A/5CF2DE92" Ref="N1001"  Part="1" 
AR Path="/5B991588/5CF2DE92" Ref="N1101"  Part="1" 
AR Path="/5B9915E6/5CF2DE92" Ref="N1201"  Part="1" 
AR Path="/5B991644/5CF2DE92" Ref="N1301"  Part="1" 
AR Path="/5B9916A2/5CF2DE92" Ref="N1401"  Part="1" 
F 0 "N701" H 13285 5825 140 0001 C CNN
F 1 "HierBody" H 13305 6205 140 0001 C CNN
F 2 "" H 13300 6025 140 0001 C CNN
F 3 "" H 13300 6025 140 0001 C CNN
F 4 "D" H 13475 6025 140 0000 C CNB "Caption2"
	1    13300 6025
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:HierBody N303
U 1 1 5CF2DEC6
P 13300 6875
AR Path="/5B9910B1/5CF2DEC6" Ref="N303"  Part="1" 
AR Path="/5B991354/5CF2DEC6" Ref="N503"  Part="1" 
AR Path="/5B9913B2/5CF2DEC6" Ref="N603"  Part="1" 
AR Path="/5B991410/5CF2DEC6" Ref="N703"  Part="1" 
AR Path="/5B99146E/5CF2DEC6" Ref="N803"  Part="1" 
AR Path="/5B9914CC/5CF2DEC6" Ref="N903"  Part="1" 
AR Path="/5B99152A/5CF2DEC6" Ref="N1003"  Part="1" 
AR Path="/5B991588/5CF2DEC6" Ref="N1103"  Part="1" 
AR Path="/5B9915E6/5CF2DEC6" Ref="N1203"  Part="1" 
AR Path="/5B991644/5CF2DEC6" Ref="N1303"  Part="1" 
AR Path="/5B9916A2/5CF2DEC6" Ref="N1403"  Part="1" 
F 0 "N703" H 13285 6675 140 0001 C CNN
F 1 "HierBody" H 13305 7055 140 0001 C CNN
F 2 "" H 13300 6875 140 0001 C CNN
F 3 "" H 13300 6875 140 0001 C CNN
F 4 "G" H 13475 6875 140 0000 C CNB "Caption2"
	1    13300 6875
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:HierBody N304
U 1 1 5CF2DEFA
P 14350 6025
AR Path="/5B9910B1/5CF2DEFA" Ref="N304"  Part="1" 
AR Path="/5B991354/5CF2DEFA" Ref="N504"  Part="1" 
AR Path="/5B9913B2/5CF2DEFA" Ref="N604"  Part="1" 
AR Path="/5B991410/5CF2DEFA" Ref="N704"  Part="1" 
AR Path="/5B99146E/5CF2DEFA" Ref="N804"  Part="1" 
AR Path="/5B9914CC/5CF2DEFA" Ref="N904"  Part="1" 
AR Path="/5B99152A/5CF2DEFA" Ref="N1004"  Part="1" 
AR Path="/5B991588/5CF2DEFA" Ref="N1104"  Part="1" 
AR Path="/5B9915E6/5CF2DEFA" Ref="N1204"  Part="1" 
AR Path="/5B991644/5CF2DEFA" Ref="N1304"  Part="1" 
AR Path="/5B9916A2/5CF2DEFA" Ref="N1404"  Part="1" 
F 0 "N704" H 14335 5825 140 0001 C CNN
F 1 "HierBody" H 14355 6205 140 0001 C CNN
F 2 "" H 14350 6025 140 0001 C CNN
F 3 "" H 14350 6025 140 0001 C CNN
F 4 "B" H 14175 6025 140 0000 C CNB "Caption2"
	1    14350 6025
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:HierBody N305
U 1 1 5CF2DF2E
P 14350 6900
AR Path="/5B9910B1/5CF2DF2E" Ref="N305"  Part="1" 
AR Path="/5B991354/5CF2DF2E" Ref="N505"  Part="1" 
AR Path="/5B9913B2/5CF2DF2E" Ref="N605"  Part="1" 
AR Path="/5B991410/5CF2DF2E" Ref="N705"  Part="1" 
AR Path="/5B99146E/5CF2DF2E" Ref="N805"  Part="1" 
AR Path="/5B9914CC/5CF2DF2E" Ref="N905"  Part="1" 
AR Path="/5B99152A/5CF2DF2E" Ref="N1005"  Part="1" 
AR Path="/5B991588/5CF2DF2E" Ref="N1105"  Part="1" 
AR Path="/5B9915E6/5CF2DF2E" Ref="N1205"  Part="1" 
AR Path="/5B991644/5CF2DF2E" Ref="N1305"  Part="1" 
AR Path="/5B9916A2/5CF2DF2E" Ref="N1405"  Part="1" 
F 0 "N705" H 14335 6700 140 0001 C CNN
F 1 "HierBody" H 14355 7080 140 0001 C CNN
F 2 "" H 14350 6900 140 0001 C CNN
F 3 "" H 14350 6900 140 0001 C CNN
F 4 "C" H 14175 6900 140 0000 C CNB "Caption2"
	1    14350 6900
	1    0    0    -1  
$EndComp
Text Notes 14400 7350 2    140  ~ 0
File: XT.sch
Text Notes 14300 5800 2    140  ~ 0
Sheet: XT
Wire Notes Line style solid
	35532 20776 43007 20776
Wire Notes Line style solid
	43007 21051 35532 21051
Wire Notes Line style solid
	35532 21326 43007 21326
Wire Notes Line style solid
	43007 21576 35532 21576
Wire Notes Line style solid
	35532 21826 43007 21826
Wire Notes Line style solid
	43007 22076 35532 22076
Wire Notes Line style solid
	35532 22301 43007 22301
Wire Notes Line style solid
	35532 22576 43007 22576
Wire Notes Line style solid
	35532 22801 43007 22801
Wire Notes Line style solid
	35532 20776 35532 26301
Wire Notes Line style solid
	35532 23051 43007 23051
Wire Notes Line style solid
	43007 20776 43007 26301
Wire Notes Line style solid
	35532 23301 43007 23301
Wire Notes Line style solid
	36532 20776 36532 26301
Wire Notes Line style solid
	38382 20776 38382 26301
Wire Notes Line style solid
	40132 20776 40132 26301
Wire Notes Line style solid
	41282 20776 41282 26301
Wire Notes Line style solid
	42132 20776 42132 26301
Wire Notes Line style solid
	35532 26301 43007 26301
Wire Notes Line style solid
	43007 26051 35532 26051
Wire Notes Line style solid
	35532 25801 43007 25801
Wire Notes Line style solid
	43007 25551 35532 25551
Wire Notes Line style solid
	35532 25301 43007 25301
Wire Notes Line style solid
	43007 25051 35532 25051
Wire Notes Line style solid
	35532 24801 43007 24801
Wire Notes Line style solid
	43007 24551 35532 24551
Wire Notes Line style solid
	35532 24301 43007 24301
Wire Notes Line style solid
	43007 24051 35532 24051
Wire Notes Line style solid
	35532 23801 43007 23801
Wire Notes Line style solid
	43007 23551 35532 23551
Text Notes 35582 21026 0    140  ~ 28
REF DES
Text Notes 36932 21026 0    140  ~ 28
PART NO.
Text Notes 38507 21026 0    140  ~ 28
DESCRIPTION
Text Notes 40332 21026 0    140  ~ 28
VALUE
Text Notes 41532 21026 0    140  ~ 28
TOL
Text Notes 42207 21026 0    140  ~ 28
RATING
Text Notes 35657 21301 0    140  ~ 28
R1
Text Notes 35657 21551 0    140  ~ 28
R2
Text Notes 35657 21801 0    140  ~ 28
R3
Text Notes 35657 22051 0    140  ~ 28
R4
Text Notes 35657 22301 0    140  ~ 28
R5
Text Notes 35657 22551 0    140  ~ 28
R6
Text Notes 35657 22801 0    140  ~ 28
R7
Text Notes 35657 23301 0    140  ~ 28
C1
Text Notes 35657 23551 0    140  ~ 28
C2
Text Notes 35657 24051 0    140  ~ 28
CR1
Text Notes 35657 24551 0    140  ~ 28
L1
Text Notes 35657 25301 0    140  ~ 28
Q1
Text Notes 35657 25551 0    140  ~ 28
Q2
Text Notes 35682 26301 0    140  ~ 28
T1
Text Notes 36657 21301 0    140  ~ 28
1006750-32
Text Notes 37607 21551 0    140  ~ 28
-8
Text Notes 37607 21801 0    140  ~ 28
-8
Text Notes 37607 22051 0    140  ~ 28
-63
Text Notes 37607 22301 0    140  ~ 28
-39
Text Notes 37607 22551 0    140  ~ 28
-39
Text Notes 36682 22801 0    140  ~ 28
1006750-39
Text Notes 36682 23301 0    140  ~ 28
1006755-79
Text Notes 36682 23551 0    140  ~ 28
1006755-79
Text Notes 36657 24026 0    140  ~ 28
2004103-001
Text Notes 36732 24551 0    140  ~ 28
1010406-6
Text Notes 36632 25301 0    140  ~ 28
2004004-001
Text Notes 36632 25551 0    140  ~ 28
2004004-001
Text Notes 36582 26301 0    140  ~ 28
1006319
Text Notes 38532 21301 0    140  ~ 28
RESISTOR
Text Notes 38532 22801 0    140  ~ 28
RESISTOR
Text Notes 38507 23276 0    140  ~ 28
CAPACITOR
Text Notes 38507 23526 0    140  ~ 28
CAPACITOR
Text Notes 38557 24026 0    140  ~ 28
DIODE
Text Notes 38457 24551 0    140  ~ 28
COIL,RF CHOKE
Text Notes 38532 25301 0    140  ~ 28
TRANSISTOR
Text Notes 38532 25551 0    140  ~ 28
TRANSISTOR
Text Notes 38532 26276 0    140  ~ 28
TRANSFORMER
Text Notes 40307 21301 0    140  ~ 28
1000
Text Notes 40307 21551 0    140  ~ 28
100
Text Notes 40307 21801 0    140  ~ 28
100
Text Notes 40307 22051 0    140  ~ 28
20K
Text Notes 40307 22301 0    140  ~ 28
2000
Text Notes 40307 22551 0    140  ~ 28
2000
Text Notes 40307 22801 0    140  ~ 28
2000
Text Notes 40332 23276 0    140  ~ 28
6.8
Text Notes 40332 23551 0    140  ~ 28
6.8
Text Notes 40282 24551 0    140  ~ 28
100 UH
Text Notes 41432 21301 0    140  ~ 28
±2%
Text Notes 41432 22801 0    140  ~ 28
±2%
Text Notes 41382 23276 0    140  ~ 28
±10%
Text Notes 41407 23526 0    140  ~ 28
±10%
Text Notes 42257 21301 0    140  ~ 28
1/4W
Text Notes 42282 22801 0    140  ~ 28
1/4W
Text Notes 42232 23276 0    140  ~ 28
35VDC
Text Notes 42232 23526 0    140  ~ 28
35VDC
Wire Notes Line width 50 style solid
	37157 21376 37157 22526
Wire Notes Line width 50 style solid
	37157 22526 37107 22376
Wire Notes Line width 50 style solid
	37207 22376 37157 22526
Wire Notes Line width 50 style solid
	39232 21376 39232 22526
Wire Notes Line width 50 style solid
	39232 22526 39182 22376
Wire Notes Line width 50 style solid
	39282 22376 39232 22526
Wire Notes Line width 50 style solid
	41707 21376 41707 22526
Wire Notes Line width 50 style solid
	41707 22526 41657 22376
Wire Notes Line width 50 style solid
	41757 22376 41707 22526
Wire Notes Line width 50 style solid
	42557 21376 42557 22526
Wire Notes Line width 50 style solid
	42557 22526 42507 22376
Wire Notes Line width 50 style solid
	42607 22376 42557 22526
$EndSCHEMATC
