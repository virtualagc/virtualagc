EESchema Schematic File Version 4
LIBS:board1-cache
EELAYER 26 0
EELAYER END
$Descr E 44000 34000
encoding utf-8
Sheet 1 3
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text Notes 40525 33125 0    250  ~ 50
2005060
Text Notes 38925 31825 0    250  ~ 50
LOGIC FLOW DIAGRAM
Text Notes 39600 32150 0    200  ~ 40
MODULE NO. A2
Text Notes 39350 32450 0    200  ~ 40
TIMER BOARD NO. 1
Text Notes 38950 33425 0    140  ~ 28
____
Wire Notes Line width 6 style solid
	36461 985  36461 2300
Wire Notes Line width 6 style solid
	36839 984  36839 2300
Wire Notes Line width 6 style solid
	37350 984  37350 2300
Wire Notes Line width 6 style solid
	36461 2300 43500 2300
Wire Notes Line width 6 style solid
	40831 984  40831 2300
Wire Notes Line width 6 style solid
	41331 984  41331 2299
Wire Notes Line width 6 style solid
	41332 2299 41332 2300
Wire Notes Line width 6 style solid
	41831 984  41831 2300
Wire Notes Line width 6 style solid
	42480 984  42480 2300
Wire Notes Line width 6 style solid
	36465 1640 43500 1640
Wire Notes Line width 6 style solid
	43500 1310 36465 1310
Wire Notes Line width 6 style solid
	36465 1970 43500 1970
Text Notes 36600 1250 0    140  ~ 28
A
Text Notes 36575 1575 0    140  ~ 28
B
Text Notes 36575 1900 0    140  ~ 28
C
Text Notes 36575 2225 0    140  ~ 28
D
Text Notes 37450 1250 0    140  ~ 28
REVISED PER TDRR 18679
Text Notes 37450 1575 0    140  ~ 28
REVISED PER TDRR 20973
Text Notes 37450 1900 0    140  ~ 28
REVISED PER TDRR 22353
Text Notes 37450 2225 0    140  ~ 28
REVISED PER TDRR 25975
$Sheet
S 13375 11075 6925 10500
U 5CFE3FCD
F0 "Sheet 1" 140
F1 "2005060D-p1of3.sch" 140
F2 "0VDC" U R 20300 21275 140
F3 "+4VDC" U R 20300 11425 140
$EndSheet
$Sheet
S 24450 11100 6925 10500
U 5CFE45F1
F0 "Sheet 2" 140
F1 "2005060D-p2of3.sch" 140
F2 "0VDC" U L 24450 21275 140
F3 "+4VDC" U L 24450 11425 140
$EndSheet
Wire Wire Line
	20300 11425 22500 11425
$Comp
L AGC_DSKY:PWR_FLAG #FLG0101
U 1 1 5D2EDBBA
P 22500 11425
F 0 "#FLG0101" H 22500 11950 50  0001 C CNN
F 1 "PWR_FLAG" H 22510 11885 50  0001 C CNN
F 2 "" H 22500 11425 50  0001 C CNN
F 3 "~" H 22500 11425 50  0001 C CNN
	1    22500 11425
	1    0    0    -1  
$EndComp
Connection ~ 22500 11425
Wire Wire Line
	22500 11425 24450 11425
Wire Wire Line
	20300 21275 22500 21275
$Comp
L AGC_DSKY:PWR_FLAG #FLG0102
U 1 1 5D2EDCFB
P 22500 21275
F 0 "#FLG0102" H 22500 21800 50  0001 C CNN
F 1 "PWR_FLAG" H 22510 21735 50  0001 C CNN
F 2 "" H 22500 21275 50  0001 C CNN
F 3 "~" H 22500 21275 50  0001 C CNN
	1    22500 21275
	1    0    0    -1  
$EndComp
Connection ~ 22500 21275
Wire Wire Line
	22500 21275 24450 21275
$EndSCHEMATC
