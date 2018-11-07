EESchema Schematic File Version 4
LIBS:module-cache
EELAYER 29 0
EELAYER END
$Descr E 44000 34000
encoding utf-8
Sheet 2 14
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text Notes 39800 31700 0    250  ~ 50
SCHEMATIC,
Text Notes 40894 33124 0    250  ~ 50
2005924
Text Notes 38269 33124 0    250  ~ 50
80230
Text Notes 39550 32075 0    200  ~ 40
STRAND SELECT
Text Notes 39475 32450 0    200  ~ 40
MODULE NO. B15
Text Notes 38819 33474 0    140  ~ 28
NONE
Text Notes 42400 33450 0    140  ~ 28
1     1
Text Notes 39875 33375 0    140  ~ 28
____________
Text Notes 34825 33200 0    140  ~ 28
____
Text Notes 32925 32900 0    140  ~ 28
______________________
Text Notes 36550 1200 0    130  ~ 26
-       INITIAL RELEASE PER TDRR 29377
Wire Notes Line style solid
	36461 996  36461 1224
Wire Notes Line style solid
	36461 1225 43500 1225
Wire Notes Line style solid
	36839 996  36839 1224
Text Notes 36550 1200 0    130  ~ 26
-       INITIAL RELEASE PER TDRR 29377
Wire Notes Line style solid
	37350 996  37350 1224
Wire Notes Line style solid
	40831 996  40831 1224
Wire Notes Line style solid
	41332 996  41332 1224
Wire Notes Line style solid
	41831 996  41831 1224
Wire Notes Line style solid
	42480 996  42480 1224
Wire Notes Line
	4425 1500 33525 1500
Wire Notes Line
	33525 1500 33525 16500
Wire Notes Line
	33525 16500 525  16500
Wire Notes Line
	525  8350 33525 8350
Wire Notes Line
	26625 8350 26625 1500
Text Notes 1025 2175 0    140  ~ 28
CKT  NO.
Text Notes 2200 2175 0    140  ~ 28
40601
Text Notes 2200 2425 0    140  ~ 28
40602
Text Notes 2200 2675 0    140  ~ 28
40603
$Comp
L AGC_DSKY:Resistor R1
U 1 1 5C713DB4
P 6725 3650
AR Path="/5C5C831E/5C713DB4" Ref="R1"  Part="1" 
AR Path="/5C856EE4/5C713DB4" Ref="R?"  Part="1" 
AR Path="/5C86781E/5C713DB4" Ref="R?"  Part="1" 
AR Path="/5C8782D7/5C713DB4" Ref="R?"  Part="1" 
F 0 "R1" V 6575 3250 130 0000 C CNN
F 1 "5100" V 6850 3225 130 0000 C CNN
F 2 "" H 6725 3650 130 0001 C CNN
F 3 "" H 6725 3650 130 0001 C CNN
	1    6725 3650
	0    -1   1    0   
$EndComp
$Comp
L AGC_DSKY:Resistor R2
U 1 1 5C71427A
P 7400 5075
AR Path="/5C5C831E/5C71427A" Ref="R2"  Part="1" 
AR Path="/5C856EE4/5C71427A" Ref="R?"  Part="1" 
AR Path="/5C86781E/5C71427A" Ref="R?"  Part="1" 
AR Path="/5C8782D7/5C71427A" Ref="R?"  Part="1" 
F 0 "R2" H 7450 5550 130 0000 C CNN
F 1 "200" H 7425 5275 130 0000 C CNN
F 2 "" H 7400 5075 130 0001 C CNN
F 3 "" H 7400 5075 130 0001 C CNN
	1    7400 5075
	-1   0    0    -1  
$EndComp
$Comp
L AGC_DSKY:Transistor-NPN Q1
U 1 1 5C714A0C
P 8725 5075
AR Path="/5C5C831E/5C714A0C" Ref="Q1"  Part="1" 
AR Path="/5C856EE4/5C714A0C" Ref="Q?"  Part="1" 
AR Path="/5C86781E/5C714A0C" Ref="Q?"  Part="1" 
AR Path="/5C8782D7/5C714A0C" Ref="Q?"  Part="1" 
F 0 "Q1" H 8125 4650 130 0000 C CNN
F 1 "Transistor-NPN" H 8725 5640 130 0001 C CNN
F 2 "" H 8725 5325 130 0001 C CNN
F 3 "" H 8725 5325 130 0001 C CNN
	1    8725 5075
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:Diode CR1
U 1 1 5C7151B2
P 8875 6300
AR Path="/5C5C831E/5C7151B2" Ref="CR1"  Part="1" 
AR Path="/5C856EE4/5C7151B2" Ref="CR?"  Part="1" 
AR Path="/5C86781E/5C7151B2" Ref="CR?"  Part="1" 
AR Path="/5C8782D7/5C7151B2" Ref="CR?"  Part="1" 
F 0 "CR1" V 8900 5850 140 0000 C CNN
F 1 "Diode" H 8875 6150 50  0001 C CNN
F 2 "" H 8825 6125 50  0001 C CNN
F 3 "" H 8825 6300 50  0001 C CNN
	1    8875 6300
	0    -1   -1   0   
$EndComp
Wire Wire Line
	7000 5075 6725 5075
Wire Wire Line
	7800 5075 8425 5075
Wire Wire Line
	6725 4050 6725 5075
Connection ~ 6725 5075
Wire Wire Line
	6725 5075 5400 5075
Wire Wire Line
	5375 2550 6725 2550
Wire Wire Line
	6725 2550 6725 3250
$Comp
L AGC_DSKY:Resistor R3
U 1 1 5C7375D3
P 8875 3100
AR Path="/5C5C831E/5C7375D3" Ref="R3"  Part="1" 
AR Path="/5C856EE4/5C7375D3" Ref="R?"  Part="1" 
AR Path="/5C86781E/5C7375D3" Ref="R?"  Part="1" 
AR Path="/5C8782D7/5C7375D3" Ref="R?"  Part="1" 
F 0 "R3" V 8700 2750 130 0000 C CNN
F 1 "2000" V 8950 2675 130 0000 C CNN
F 2 "" H 8875 3100 130 0001 C CNN
F 3 "" H 8875 3100 130 0001 C CNN
	1    8875 3100
	0    -1   1    0   
$EndComp
$Comp
L AGC_DSKY:Resistor R4
U 1 1 5C737D9A
P 8875 4150
AR Path="/5C5C831E/5C737D9A" Ref="R4"  Part="1" 
AR Path="/5C856EE4/5C737D9A" Ref="R?"  Part="1" 
AR Path="/5C86781E/5C737D9A" Ref="R?"  Part="1" 
AR Path="/5C8782D7/5C737D9A" Ref="R?"  Part="1" 
F 0 "R4" V 8700 3800 130 0000 C CNN
F 1 "2000" V 8950 3725 130 0000 C CNN
F 2 "" H 8875 4150 130 0001 C CNN
F 3 "" H 8875 4150 130 0001 C CNN
	1    8875 4150
	0    -1   1    0   
$EndComp
$Comp
L AGC_DSKY:Transistor-PNP Q2
U 1 1 5C7382FA
P 10150 3575
AR Path="/5C5C831E/5C7382FA" Ref="Q2"  Part="1" 
AR Path="/5C856EE4/5C7382FA" Ref="Q?"  Part="1" 
AR Path="/5C86781E/5C7382FA" Ref="Q?"  Part="1" 
AR Path="/5C8782D7/5C7382FA" Ref="Q?"  Part="1" 
F 0 "Q2" H 10800 3500 130 0000 C CNN
F 1 "Transistor-PNP" H 10150 4140 130 0001 C CNN
F 2 "" H 10150 3825 130 0001 C CNN
F 3 "" H 10150 3825 130 0001 C CNN
	1    10150 3575
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:Resistor R6
U 1 1 5C738C54
P 10300 5200
AR Path="/5C5C831E/5C738C54" Ref="R6"  Part="1" 
AR Path="/5C856EE4/5C738C54" Ref="R?"  Part="1" 
AR Path="/5C86781E/5C738C54" Ref="R?"  Part="1" 
AR Path="/5C8782D7/5C738C54" Ref="R?"  Part="1" 
F 0 "R6" V 10125 4850 130 0000 C CNN
F 1 "3000" V 10375 4775 130 0000 C CNN
F 2 "" H 10300 5200 130 0001 C CNN
F 3 "" H 10300 5200 130 0001 C CNN
	1    10300 5200
	0    -1   1    0   
$EndComp
Wire Wire Line
	6725 2550 8875 2550
Wire Wire Line
	10300 2550 10300 3325
Connection ~ 6725 2550
Wire Wire Line
	8875 2700 8875 2550
Connection ~ 8875 2550
Wire Wire Line
	8875 2550 10300 2550
Wire Wire Line
	9850 3575 8875 3575
Wire Wire Line
	8875 3500 8875 3575
Connection ~ 8875 3575
Wire Wire Line
	8875 3575 8875 3750
Wire Wire Line
	10300 3825 10300 4200
Wire Wire Line
	8875 4550 8875 4825
Wire Wire Line
	8875 5325 8875 6100
Wire Wire Line
	8875 7675 8875 6500
Wire Wire Line
	8875 7675 10300 7675
Wire Wire Line
	10300 7675 10300 5600
$Comp
L AGC_DSKY:Transistor-PNP Q3
U 1 1 5C73CC91
P 12725 5575
AR Path="/5C5C831E/5C73CC91" Ref="Q3"  Part="1" 
AR Path="/5C856EE4/5C73CC91" Ref="Q?"  Part="1" 
AR Path="/5C86781E/5C73CC91" Ref="Q?"  Part="1" 
AR Path="/5C8782D7/5C73CC91" Ref="Q?"  Part="1" 
F 0 "Q3" H 11975 6250 130 0000 C CNN
F 1 "Transistor-PNP" H 12725 6140 130 0001 C CNN
F 2 "" H 12725 5825 130 0001 C CNN
F 3 "" H 12725 5825 130 0001 C CNN
	1    12725 5575
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:Resistor R6
U 1 1 5C73D5A0
P 11500 3325
AR Path="/5C5C831E/5C73D5A0" Ref="R6"  Part="1" 
AR Path="/5C856EE4/5C73D5A0" Ref="R?"  Part="1" 
AR Path="/5C86781E/5C73D5A0" Ref="R?"  Part="1" 
AR Path="/5C8782D7/5C73D5A0" Ref="R?"  Part="1" 
F 0 "R6" V 11350 2925 130 0000 C CNN
F 1 "5100" V 11625 2900 130 0000 C CNN
F 2 "" H 11500 3325 130 0001 C CNN
F 3 "" H 11500 3325 130 0001 C CNN
	1    11500 3325
	0    -1   1    0   
$EndComp
$Comp
L AGC_DSKY:Resistor R7
U 1 1 5C73DAD0
P 11500 6300
AR Path="/5C5C831E/5C73DAD0" Ref="R7"  Part="1" 
AR Path="/5C856EE4/5C73DAD0" Ref="R?"  Part="1" 
AR Path="/5C86781E/5C73DAD0" Ref="R?"  Part="1" 
AR Path="/5C8782D7/5C73DAD0" Ref="R?"  Part="1" 
F 0 "R7" V 11325 5950 130 0000 C CNN
F 1 "2000" V 11575 5875 130 0000 C CNN
F 2 "" H 11500 6300 130 0001 C CNN
F 3 "" H 11500 6300 130 0001 C CNN
	1    11500 6300
	0    -1   1    0   
$EndComp
$Comp
L AGC_DSKY:Resistor R8
U 1 1 5C73E4F9
P 12875 6700
AR Path="/5C5C831E/5C73E4F9" Ref="R8"  Part="1" 
AR Path="/5C856EE4/5C73E4F9" Ref="R?"  Part="1" 
AR Path="/5C86781E/5C73E4F9" Ref="R?"  Part="1" 
AR Path="/5C8782D7/5C73E4F9" Ref="R?"  Part="1" 
F 0 "R8" V 12700 6350 130 0000 C CNN
F 1 "3000" V 12950 6275 130 0000 C CNN
F 2 "" H 12875 6700 130 0001 C CNN
F 3 "" H 12875 6700 130 0001 C CNN
	1    12875 6700
	0    -1   1    0   
$EndComp
$Comp
L AGC_DSKY:Diode CR2
U 1 1 5C73E8F9
P 12875 4700
AR Path="/5C5C831E/5C73E8F9" Ref="CR2"  Part="1" 
AR Path="/5C856EE4/5C73E8F9" Ref="CR?"  Part="1" 
AR Path="/5C86781E/5C73E8F9" Ref="CR?"  Part="1" 
AR Path="/5C8782D7/5C73E8F9" Ref="CR?"  Part="1" 
F 0 "CR2" V 12900 4250 140 0000 C CNN
F 1 "Diode" H 12875 4550 50  0001 C CNN
F 2 "" H 12825 4525 50  0001 C CNN
F 3 "" H 12825 4700 50  0001 C CNN
	1    12875 4700
	0    -1   -1   0   
$EndComp
$Comp
L AGC_DSKY:Resistor R10
U 1 1 5C740C60
P 15250 6250
AR Path="/5C5C831E/5C740C60" Ref="R10"  Part="1" 
AR Path="/5C856EE4/5C740C60" Ref="R?"  Part="1" 
AR Path="/5C86781E/5C740C60" Ref="R?"  Part="1" 
AR Path="/5C8782D7/5C740C60" Ref="R?"  Part="1" 
F 0 "R10" V 15075 5900 130 0000 C CNN
F 1 "2000" V 15325 5825 130 0000 C CNN
F 2 "" H 15250 6250 130 0001 C CNN
F 3 "" H 15250 6250 130 0001 C CNN
	1    15250 6250
	0    -1   1    0   
$EndComp
$Comp
L AGC_DSKY:Resistor R9
U 1 1 5C74130D
P 15250 3325
AR Path="/5C5C831E/5C74130D" Ref="R9"  Part="1" 
AR Path="/5C856EE4/5C74130D" Ref="R?"  Part="1" 
AR Path="/5C86781E/5C74130D" Ref="R?"  Part="1" 
AR Path="/5C8782D7/5C74130D" Ref="R?"  Part="1" 
F 0 "R9" V 15100 2925 130 0000 C CNN
F 1 "5100" V 15375 2900 130 0000 C CNN
F 2 "" H 15250 3325 130 0001 C CNN
F 3 "" H 15250 3325 130 0001 C CNN
	1    15250 3325
	0    -1   1    0   
$EndComp
$Comp
L AGC_DSKY:Transistor-PNP Q4
U 1 1 5C743331
P 16475 5575
AR Path="/5C5C831E/5C743331" Ref="Q4"  Part="1" 
AR Path="/5C856EE4/5C743331" Ref="Q?"  Part="1" 
AR Path="/5C86781E/5C743331" Ref="Q?"  Part="1" 
AR Path="/5C8782D7/5C743331" Ref="Q?"  Part="1" 
F 0 "Q4" H 15750 6250 130 0000 C CNN
F 1 "Transistor-PNP" H 16475 6140 130 0001 C CNN
F 2 "" H 16475 5825 130 0001 C CNN
F 3 "" H 16475 5825 130 0001 C CNN
	1    16475 5575
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:Transistor-PNP Q5
U 1 1 5C743A3B
P 20225 5575
AR Path="/5C5C831E/5C743A3B" Ref="Q5"  Part="1" 
AR Path="/5C856EE4/5C743A3B" Ref="Q?"  Part="1" 
AR Path="/5C86781E/5C743A3B" Ref="Q?"  Part="1" 
AR Path="/5C8782D7/5C743A3B" Ref="Q?"  Part="1" 
F 0 "Q5" H 19500 6250 130 0000 C CNN
F 1 "Transistor-PNP" H 20225 6140 130 0001 C CNN
F 2 "" H 20225 5825 130 0001 C CNN
F 3 "" H 20225 5825 130 0001 C CNN
	1    20225 5575
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:Resistor R13
U 1 1 5C7440FB
P 18975 6250
AR Path="/5C5C831E/5C7440FB" Ref="R13"  Part="1" 
AR Path="/5C856EE4/5C7440FB" Ref="R?"  Part="1" 
AR Path="/5C86781E/5C7440FB" Ref="R?"  Part="1" 
AR Path="/5C8782D7/5C7440FB" Ref="R?"  Part="1" 
F 0 "R13" V 18800 5900 130 0000 C CNN
F 1 "2000" V 19050 5825 130 0000 C CNN
F 2 "" H 18975 6250 130 0001 C CNN
F 3 "" H 18975 6250 130 0001 C CNN
	1    18975 6250
	0    -1   1    0   
$EndComp
$Comp
L AGC_DSKY:Resistor R11
U 1 1 5C74472B
P 16625 6700
AR Path="/5C5C831E/5C74472B" Ref="R11"  Part="1" 
AR Path="/5C856EE4/5C74472B" Ref="R?"  Part="1" 
AR Path="/5C86781E/5C74472B" Ref="R?"  Part="1" 
AR Path="/5C8782D7/5C74472B" Ref="R?"  Part="1" 
F 0 "R11" V 16450 6350 130 0000 C CNN
F 1 "3000" V 16700 6275 130 0000 C CNN
F 2 "" H 16625 6700 130 0001 C CNN
F 3 "" H 16625 6700 130 0001 C CNN
	1    16625 6700
	0    -1   1    0   
$EndComp
$Comp
L AGC_DSKY:Resistor R12
U 1 1 5C744C75
P 18975 3325
AR Path="/5C5C831E/5C744C75" Ref="R12"  Part="1" 
AR Path="/5C856EE4/5C744C75" Ref="R?"  Part="1" 
AR Path="/5C86781E/5C744C75" Ref="R?"  Part="1" 
AR Path="/5C8782D7/5C744C75" Ref="R?"  Part="1" 
F 0 "R12" V 18825 2925 130 0000 C CNN
F 1 "5100" V 19100 2900 130 0000 C CNN
F 2 "" H 18975 3325 130 0001 C CNN
F 3 "" H 18975 3325 130 0001 C CNN
	1    18975 3325
	0    -1   1    0   
$EndComp
$Comp
L AGC_DSKY:Diode CR3
U 1 1 5C745090
P 16625 4700
AR Path="/5C5C831E/5C745090" Ref="CR3"  Part="1" 
AR Path="/5C856EE4/5C745090" Ref="CR?"  Part="1" 
AR Path="/5C86781E/5C745090" Ref="CR?"  Part="1" 
AR Path="/5C8782D7/5C745090" Ref="CR?"  Part="1" 
F 0 "CR3" V 16650 4250 140 0000 C CNN
F 1 "Diode" H 16625 4550 50  0001 C CNN
F 2 "" H 16575 4525 50  0001 C CNN
F 3 "" H 16575 4700 50  0001 C CNN
	1    16625 4700
	0    -1   -1   0   
$EndComp
$Comp
L AGC_DSKY:Diode CR4
U 1 1 5C745745
P 20375 4675
AR Path="/5C5C831E/5C745745" Ref="CR4"  Part="1" 
AR Path="/5C856EE4/5C745745" Ref="CR?"  Part="1" 
AR Path="/5C86781E/5C745745" Ref="CR?"  Part="1" 
AR Path="/5C8782D7/5C745745" Ref="CR?"  Part="1" 
F 0 "CR4" V 20400 4225 140 0000 C CNN
F 1 "Diode" H 20375 4525 50  0001 C CNN
F 2 "" H 20325 4500 50  0001 C CNN
F 3 "" H 20325 4675 50  0001 C CNN
	1    20375 4675
	0    -1   -1   0   
$EndComp
$Comp
L AGC_DSKY:Resistor R15
U 1 1 5C745E97
P 22725 3325
AR Path="/5C5C831E/5C745E97" Ref="R15"  Part="1" 
AR Path="/5C856EE4/5C745E97" Ref="R?"  Part="1" 
AR Path="/5C86781E/5C745E97" Ref="R?"  Part="1" 
AR Path="/5C8782D7/5C745E97" Ref="R?"  Part="1" 
F 0 "R15" V 22575 2925 130 0000 C CNN
F 1 "5100" V 22850 2900 130 0000 C CNN
F 2 "" H 22725 3325 130 0001 C CNN
F 3 "" H 22725 3325 130 0001 C CNN
	1    22725 3325
	0    -1   1    0   
$EndComp
$Comp
L AGC_DSKY:Transistor-PNP Q6
U 1 1 5C7463D3
P 23950 5575
AR Path="/5C5C831E/5C7463D3" Ref="Q6"  Part="1" 
AR Path="/5C856EE4/5C7463D3" Ref="Q?"  Part="1" 
AR Path="/5C86781E/5C7463D3" Ref="Q?"  Part="1" 
AR Path="/5C8782D7/5C7463D3" Ref="Q?"  Part="1" 
F 0 "Q6" H 23250 6275 130 0000 C CNN
F 1 "Transistor-PNP" H 23950 6140 130 0001 C CNN
F 2 "" H 23950 5825 130 0001 C CNN
F 3 "" H 23950 5825 130 0001 C CNN
	1    23950 5575
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:Diode CR5
U 1 1 5C7471B3
P 24100 4675
AR Path="/5C5C831E/5C7471B3" Ref="CR5"  Part="1" 
AR Path="/5C856EE4/5C7471B3" Ref="CR?"  Part="1" 
AR Path="/5C86781E/5C7471B3" Ref="CR?"  Part="1" 
AR Path="/5C8782D7/5C7471B3" Ref="CR?"  Part="1" 
F 0 "CR5" V 24125 4225 140 0000 C CNN
F 1 "Diode" H 24100 4525 50  0001 C CNN
F 2 "" H 24050 4500 50  0001 C CNN
F 3 "" H 24050 4675 50  0001 C CNN
	1    24100 4675
	0    -1   -1   0   
$EndComp
$Comp
L AGC_DSKY:Resistor R14
U 1 1 5C747F61
P 20375 6675
AR Path="/5C5C831E/5C747F61" Ref="R14"  Part="1" 
AR Path="/5C856EE4/5C747F61" Ref="R?"  Part="1" 
AR Path="/5C86781E/5C747F61" Ref="R?"  Part="1" 
AR Path="/5C8782D7/5C747F61" Ref="R?"  Part="1" 
F 0 "R14" V 20200 6325 130 0000 C CNN
F 1 "3000" V 20450 6250 130 0000 C CNN
F 2 "" H 20375 6675 130 0001 C CNN
F 3 "" H 20375 6675 130 0001 C CNN
	1    20375 6675
	0    -1   1    0   
$EndComp
$Comp
L AGC_DSKY:Resistor R16
U 1 1 5C7486D3
P 22725 6200
AR Path="/5C5C831E/5C7486D3" Ref="R16"  Part="1" 
AR Path="/5C856EE4/5C7486D3" Ref="R?"  Part="1" 
AR Path="/5C86781E/5C7486D3" Ref="R?"  Part="1" 
AR Path="/5C8782D7/5C7486D3" Ref="R?"  Part="1" 
F 0 "R16" V 22550 5850 130 0000 C CNN
F 1 "2000" V 22800 5775 130 0000 C CNN
F 2 "" H 22725 6200 130 0001 C CNN
F 3 "" H 22725 6200 130 0001 C CNN
	1    22725 6200
	0    -1   1    0   
$EndComp
$Comp
L AGC_DSKY:Resistor R17
U 1 1 5C74914C
P 24100 6675
AR Path="/5C5C831E/5C74914C" Ref="R17"  Part="1" 
AR Path="/5C856EE4/5C74914C" Ref="R?"  Part="1" 
AR Path="/5C86781E/5C74914C" Ref="R?"  Part="1" 
AR Path="/5C8782D7/5C74914C" Ref="R?"  Part="1" 
F 0 "R17" V 23925 6325 130 0000 C CNN
F 1 "3000" V 24175 6250 130 0000 C CNN
F 2 "" H 24100 6675 130 0001 C CNN
F 3 "" H 24100 6675 130 0001 C CNN
	1    24100 6675
	0    -1   1    0   
$EndComp
Wire Wire Line
	10300 2550 11500 2550
Wire Wire Line
	11500 2550 11500 2925
Connection ~ 10300 2550
Wire Wire Line
	11500 2550 15250 2550
Wire Wire Line
	15250 2550 15250 2925
Connection ~ 11500 2550
Wire Wire Line
	11500 3725 11500 5575
Wire Wire Line
	11500 5575 12425 5575
Connection ~ 11500 5575
Wire Wire Line
	11500 5575 11500 5900
Wire Wire Line
	10300 4200 12875 4200
Wire Wire Line
	12875 4200 12875 4500
Connection ~ 10300 4200
Wire Wire Line
	10300 4200 10300 4800
Wire Wire Line
	10300 7675 12875 7675
Wire Wire Line
	12875 7675 12875 7100
Connection ~ 10300 7675
Wire Wire Line
	12875 7675 16625 7675
Wire Wire Line
	16625 7675 16625 7100
Connection ~ 12875 7675
Wire Wire Line
	15250 3725 15250 5575
Wire Wire Line
	16175 5575 15250 5575
Connection ~ 15250 5575
Wire Wire Line
	15250 5575 15250 5850
Wire Wire Line
	12875 5825 12875 6075
Wire Wire Line
	13725 6075 12875 6075
Connection ~ 12875 6075
Wire Wire Line
	12875 6075 12875 6300
Wire Wire Line
	12875 5325 12875 4900
Wire Wire Line
	12875 4200 16625 4200
Wire Wire Line
	16625 4200 16625 4500
Connection ~ 12875 4200
Wire Wire Line
	16625 5825 16625 6075
Wire Wire Line
	17500 6075 16625 6075
Connection ~ 16625 6075
Wire Wire Line
	16625 6075 16625 6300
Wire Wire Line
	16625 5325 16625 4900
Wire Wire Line
	16625 4200 20375 4200
Wire Wire Line
	20375 4200 20375 4475
Connection ~ 16625 4200
Wire Wire Line
	18975 3725 18975 5575
Wire Wire Line
	19925 5575 18975 5575
Connection ~ 18975 5575
Wire Wire Line
	18975 5575 18975 5850
Wire Wire Line
	21175 6075 20375 6075
Wire Wire Line
	20375 6075 20375 6275
Wire Wire Line
	20375 6075 20375 5825
Connection ~ 20375 6075
Wire Wire Line
	16625 7675 20375 7675
Wire Wire Line
	24100 7675 24100 7075
Connection ~ 16625 7675
Wire Wire Line
	20375 7075 20375 7675
Connection ~ 20375 7675
Wire Wire Line
	20375 7675 24100 7675
Wire Wire Line
	20375 5325 20375 4875
Wire Wire Line
	22725 3725 22725 5575
Wire Wire Line
	23650 5575 22725 5575
Connection ~ 22725 5575
Wire Wire Line
	22725 5575 22725 5800
Wire Wire Line
	24100 5825 24100 6075
Wire Wire Line
	24100 5325 24100 4875
Wire Wire Line
	20375 4200 24100 4200
Wire Wire Line
	24100 4200 24100 4475
Connection ~ 20375 4200
Wire Wire Line
	24950 6075 24100 6075
Connection ~ 24100 6075
Wire Wire Line
	24100 6075 24100 6275
Wire Wire Line
	15250 2550 18975 2550
Wire Wire Line
	22725 2550 22725 2925
Connection ~ 15250 2550
Wire Wire Line
	18975 2925 18975 2550
Connection ~ 18975 2550
Wire Wire Line
	18975 2550 22725 2550
Wire Notes Line style solid
	34850 7225 42375 7225
Wire Notes Line style solid
	34850 7475 42375 7475
Wire Notes Line style solid
	34850 7725 42375 7725
Wire Notes Line style solid
	34850 7975 42375 7975
Wire Notes Line style solid
	34850 8225 42375 8225
Wire Notes Line style solid
	34850 8475 42375 8475
Wire Notes Line style solid
	34850 8725 42375 8725
Wire Notes Line style solid
	34850 8975 42375 8975
Wire Notes Line style solid
	34850 9225 42375 9225
Wire Notes Line style solid
	34850 9475 42375 9475
Wire Notes Line style solid
	34850 9725 42375 9725
Wire Notes Line style solid
	34850 9975 42375 9975
Wire Notes Line style solid
	34850 10225 42375 10225
Wire Notes Line style solid
	34850 10475 42375 10475
Wire Notes Line style solid
	34850 10725 42375 10725
Wire Notes Line style solid
	34850 10975 42375 10975
Wire Notes Line style solid
	34850 11225 42375 11225
Wire Notes Line style solid
	34850 11475 42375 11475
Wire Notes Line style solid
	34850 11725 42375 11725
Wire Notes Line style solid
	34850 11975 42375 11975
Wire Notes Line style solid
	34850 12225 42375 12225
Wire Notes Line style solid
	34850 12475 42375 12475
Wire Notes Line style solid
	34850 12725 42375 12725
Wire Notes Line style solid
	34850 12975 42375 12975
Wire Notes Line style solid
	34850 13225 42375 13225
Wire Notes Line style solid
	34850 13475 42375 13475
Wire Notes Line style solid
	34850 13725 42375 13725
Wire Notes Line style solid
	34850 13975 42375 13975
Wire Notes Line style solid
	34850 14225 42375 14225
Wire Notes Line style solid
	34850 14475 42375 14475
Wire Notes Line style solid
	34850 14725 42375 14725
Wire Notes Line style solid
	34850 14975 42375 14975
Wire Notes Line style solid
	34850 15225 42375 15225
Wire Notes Line style solid
	34850 15475 42375 15475
Wire Notes Line style solid
	34850 15725 42375 15725
Wire Notes Line style solid
	34850 15975 42375 15975
Wire Notes Line style solid
	34850 16225 42375 16225
Wire Notes Line style solid
	34850 16475 42375 16475
Wire Notes Line style solid
	34850 16725 42375 16725
Wire Notes Line style solid
	34850 16975 42375 16975
Wire Notes Line style solid
	34850 17225 42375 17225
Wire Notes Line style solid
	34850 17475 42375 17475
Wire Notes Line style solid
	34850 17725 42375 17725
Wire Notes Line style solid
	34850 17975 42375 17975
Wire Notes Line style solid
	34850 18225 42375 18225
Wire Notes Line style solid
	34850 18475 42375 18475
Wire Notes Line style solid
	34850 18725 42375 18725
Wire Notes Line style solid
	34850 18975 42375 18975
Wire Notes Line style solid
	34850 19225 42375 19225
Wire Notes Line style solid
	34850 19475 42375 19475
Wire Notes Line style solid
	34850 19725 42375 19725
Wire Notes Line style solid
	34850 19975 42375 19975
Wire Notes Line style solid
	34850 20225 42375 20225
Wire Notes Line style solid
	34850 20475 42375 20475
Wire Notes Line style solid
	34850 20725 42375 20725
Wire Notes Line style solid
	34850 20975 42375 20975
Wire Notes Line style solid
	34850 21225 42375 21225
Wire Notes Line style solid
	34850 21475 42375 21475
Wire Notes Line style solid
	34850 21725 42375 21725
Wire Notes Line style solid
	34850 21975 42375 21975
Wire Notes Line style solid
	34850 22225 42375 22225
Wire Notes Line style solid
	34850 22475 42375 22475
Wire Notes Line style solid
	34850 22725 42375 22725
Wire Notes Line style solid
	34850 22975 42375 22975
Wire Notes Line style solid
	34850 23225 42375 23225
Wire Notes Line style solid
	34850 23475 42375 23475
Wire Notes Line style solid
	34850 23725 42375 23725
Wire Notes Line style solid
	34850 23975 42375 23975
Wire Notes Line style solid
	34850 24225 42375 24225
Wire Notes Line style solid
	34850 24475 42375 24475
Wire Notes Line style solid
	34850 24725 42375 24725
Wire Notes Line style solid
	34850 24975 42375 24975
Wire Notes Line style solid
	34850 25225 42375 25225
Wire Notes Line style solid
	34850 25475 42375 25475
Wire Notes Line style solid
	34850 25725 42375 25725
Wire Notes Line style solid
	34850 25975 42375 25975
Wire Notes Line style solid
	34850 26225 42375 26225
Wire Notes Line style solid
	34850 26475 42375 26475
Wire Notes Line style solid
	34850 26725 42375 26725
Wire Notes Line style solid
	34850 26975 42375 26975
Wire Notes Line style solid
	34850 27225 42375 27225
Wire Notes Line style solid
	34850 27475 42375 27475
Wire Notes Line style solid
	34850 27725 42375 27725
Wire Notes Line style solid
	34850 27975 42375 27975
Wire Notes Line style solid
	34850 28225 42375 28225
Wire Notes Line style solid
	34850 28475 42375 28475
Wire Notes Line style solid
	34850 28725 42375 28725
Wire Notes Line style solid
	34850 28975 42375 28975
Wire Notes Line style solid
	34850 29225 42375 29225
Wire Notes Line style solid
	34850 29475 42375 29475
Text Notes 35050 7700 0    140  ~ 28
R1
Text Notes 35050 7950 0    140  ~ 28
R2
Text Notes 35050 8200 0    140  ~ 28
R3
Text Notes 35050 8450 0    140  ~ 28
R4
Text Notes 35050 8700 0    140  ~ 28
R5
Text Notes 35050 8950 0    140  ~ 28
R6
Text Notes 35050 9200 0    140  ~ 28
R7
Text Notes 35050 9450 0    140  ~ 28
R8
Text Notes 35050 9700 0    140  ~ 28
R9
Text Notes 35050 9950 0    140  ~ 28
R10
Text Notes 35050 10200 0    140  ~ 28
R11
Text Notes 35050 10450 0    140  ~ 28
R12
Text Notes 35050 10700 0    140  ~ 28
R13
Text Notes 35050 10950 0    140  ~ 28
R14
Text Notes 35050 11200 0    140  ~ 28
R15
Text Notes 35050 11450 0    140  ~ 28
R16
Text Notes 35050 11700 0    140  ~ 28
R17
Text Notes 35050 11950 0    140  ~ 28
R18
Text Notes 35050 12200 0    140  ~ 28
R19
Text Notes 35050 12450 0    140  ~ 28
R20
Text Notes 35050 12700 0    140  ~ 28
R21
Text Notes 35050 12950 0    140  ~ 28
R22
Text Notes 35050 13200 0    140  ~ 28
R23
Text Notes 35050 13450 0    140  ~ 28
R24
Text Notes 35050 13700 0    140  ~ 28
R25
Text Notes 35050 13950 0    140  ~ 28
R26
Text Notes 35050 14200 0    140  ~ 28
R27
Text Notes 35050 14450 0    140  ~ 28
R28
Text Notes 35050 14700 0    140  ~ 28
R29
Text Notes 35050 14950 0    140  ~ 28
R30
Text Notes 35050 15200 0    140  ~ 28
R31
Text Notes 35050 15450 0    140  ~ 28
R32
Text Notes 35050 15700 0    140  ~ 28
R33
Text Notes 35050 15950 0    140  ~ 28
R34
Text Notes 35050 16200 0    140  ~ 28
R35
Text Notes 35050 16450 0    140  ~ 28
R36
Text Notes 35050 16700 0    140  ~ 28
R37
Text Notes 35050 16950 0    140  ~ 28
R38
Text Notes 35050 17200 0    140  ~ 28
R39
Text Notes 35050 17450 0    140  ~ 28
R40
Text Notes 35050 17700 0    140  ~ 28
R41
Text Notes 35050 17950 0    140  ~ 28
R42
Text Notes 35050 18200 0    140  ~ 28
R43
Text Notes 35050 18450 0    140  ~ 28
R44
Text Notes 35050 18700 0    140  ~ 28
R45
Text Notes 35075 19700 0    140  ~ 28
CR1
Text Notes 35075 19950 0    140  ~ 28
CR2
Text Notes 35075 20200 0    140  ~ 28
CR3
Text Notes 35075 20450 0    140  ~ 28
CR4
Text Notes 35075 20700 0    140  ~ 28
CR5
Text Notes 35075 20950 0    140  ~ 28
CR6
Text Notes 35075 21200 0    140  ~ 28
CR7
Text Notes 35075 21450 0    140  ~ 28
CR8
Text Notes 35075 21700 0    140  ~ 28
CR9
Text Notes 35075 21950 0    140  ~ 28
CR10
Text Notes 35075 22200 0    140  ~ 28
CR11
Text Notes 35075 22450 0    140  ~ 28
CR12
Text Notes 35075 22700 0    140  ~ 28
CR13
Text Notes 35075 22950 0    140  ~ 28
CR14
Text Notes 35075 23200 0    140  ~ 28
CR15
Text Notes 35075 23450 0    140  ~ 28
CR16
Text Notes 35075 23700 0    140  ~ 28
CR17
Text Notes 35075 23950 0    140  ~ 28
CR18
Text Notes 35075 24200 0    140  ~ 28
CR19
Text Notes 35075 24950 0    140  ~ 28
Q1
Text Notes 35075 25200 0    140  ~ 28
Q2
Text Notes 35075 25450 0    140  ~ 28
Q3
Text Notes 35075 25700 0    140  ~ 28
Q4
Text Notes 35075 25950 0    140  ~ 28
Q5
Text Notes 35075 26200 0    140  ~ 28
Q6
Text Notes 35075 26450 0    140  ~ 28
Q7
Text Notes 35075 26700 0    140  ~ 28
Q8
Text Notes 35075 26950 0    140  ~ 28
Q9
Text Notes 35075 27200 0    140  ~ 28
Q10
Text Notes 35075 27450 0    140  ~ 28
Q11
Text Notes 35075 27700 0    140  ~ 28
Q12
Text Notes 35075 27950 0    140  ~ 28
Q13
Text Notes 35075 28200 0    140  ~ 28
Q14
Text Notes 35075 28450 0    140  ~ 28
Q15
Wire Notes Line style solid
	34850 7225 34850 29475
Wire Notes Line style solid
	35875 29475 35875 7225
Wire Notes Line style solid
	37725 7225 37725 29475
Wire Notes Line style solid
	39450 29475 39450 7225
Wire Notes Line style solid
	38475 7800 38475 18400
Wire Notes Line style solid
	36450 17925 36450 17275
Wire Notes Line style solid
	36450 23925 36450 19800
Wire Notes Line style solid
	38500 19800 38500 23900
Wire Notes Line style solid
	36450 25275 36450 25925
Wire Notes Line style solid
	38475 25025 38475 28150
Wire Notes Line style solid
	36425 7775 36425 14425
Wire Notes Line style solid
	36450 15550 36450 16175
Wire Notes Line style solid
	40600 7225 40600 29475
Wire Notes Line style solid
	41475 29475 41475 7225
Wire Notes Line style solid
	42375 7225 42375 29475
Wire Notes Line style solid
	41025 7800 41025 14400
Wire Notes Line style solid
	41050 15525 41050 16150
Wire Notes Line style solid
	41025 17300 41025 17900
Wire Notes Line style solid
	41875 7775 41875 18400
Text Notes 34925 7450 0    130  ~ 26
REF DES
Text Notes 36300 7450 0    130  ~ 26
PART NO.
Text Notes 37900 7450 0    130  ~ 26
DESCRIPTION
Text Notes 39700 7450 0    130  ~ 26
VALUE
Text Notes 40800 7450 0    130  ~ 26
TOL
Text Notes 41575 7450 0    130  ~ 26
RATING
Text Notes 36050 7700 0    130  ~ 26
1006750
Text Notes 38000 7700 0    130  ~ 26
RESISTOR
Text Notes 40775 7700 0    130  ~ 26
±2%
Text Notes 41625 7700 0    130  ~ 26
1/4W
Text Notes 36950 7700 0    130  ~ 26
-
Text Notes 36950 7950 0    130  ~ 26
-
Text Notes 36950 8200 0    130  ~ 26
-
Text Notes 36950 8450 0    130  ~ 26
-
Text Notes 36950 8700 0    130  ~ 26
-
Text Notes 36950 8950 0    130  ~ 26
-
Text Notes 36950 9200 0    130  ~ 26
-
Text Notes 36950 9450 0    130  ~ 26
-
Text Notes 36950 9700 0    130  ~ 26
-
Text Notes 36950 9950 0    130  ~ 26
-
Text Notes 36950 10200 0    130  ~ 26
-
Text Notes 36950 10450 0    130  ~ 26
-
Text Notes 36950 10700 0    130  ~ 26
-
Text Notes 36950 10950 0    130  ~ 26
-
Text Notes 36950 11200 0    130  ~ 26
-
Text Notes 36950 11450 0    130  ~ 26
-
Text Notes 36950 11700 0    130  ~ 26
-
Text Notes 36950 11950 0    130  ~ 26
-
Text Notes 36950 12200 0    130  ~ 26
-
Text Notes 36950 12450 0    130  ~ 26
-
Text Notes 36950 12700 0    130  ~ 26
-
Text Notes 36950 12950 0    130  ~ 26
-
Text Notes 36950 13200 0    130  ~ 26
-
Text Notes 36950 13450 0    130  ~ 26
-
Text Notes 36950 13700 0    130  ~ 26
-
Text Notes 36950 13950 0    130  ~ 26
-
Text Notes 36950 14200 0    130  ~ 26
-
Text Notes 36950 14450 0    130  ~ 26
-
Text Notes 36950 14700 0    130  ~ 26
-
Text Notes 36950 15200 0    130  ~ 26
-
Text Notes 36950 15450 0    130  ~ 26
-
Text Notes 36950 15700 0    130  ~ 26
-
Text Notes 36950 15950 0    130  ~ 26
-
Text Notes 36950 16200 0    130  ~ 26
-
Text Notes 36950 16450 0    130  ~ 26
-
Text Notes 36950 16950 0    130  ~ 26
-
Text Notes 36950 17200 0    130  ~ 26
-
Text Notes 36950 17450 0    130  ~ 26
-
Text Notes 36950 17700 0    130  ~ 26
-
Text Notes 36950 17950 0    130  ~ 26
-
Text Notes 36950 18200 0    130  ~ 26
-
Text Notes 36950 18700 0    130  ~ 26
-
Text Notes 36150 18450 0    130  ~ 26
SEE NOTE 2
Text Notes 36150 16700 0    130  ~ 26
SEE NOTE 2
Text Notes 36150 14950 0    130  ~ 26
SEE NOTE 2
Text Notes 36075 14700 0    130  ~ 26
1006750
Text Notes 36075 15450 0    130  ~ 26
1006750
Text Notes 36075 15200 0    130  ~ 26
1006788
Text Notes 36075 16950 0    130  ~ 26
1006788
Text Notes 36075 16450 0    130  ~ 26
1006750
Text Notes 36075 17200 0    130  ~ 26
1006750
Text Notes 36075 18200 0    130  ~ 26
1006750
Text Notes 36075 18700 0    130  ~ 26
1006788
Text Notes 38000 18700 0    130  ~ 26
RESISTOR
Text Notes 40775 14700 0    130  ~ 26
±2%
Text Notes 40775 15450 0    130  ~ 26
±2%
Text Notes 40800 16450 0    130  ~ 26
±2%
Text Notes 40775 14950 0    130  ~ 26
±1%
Text Notes 40775 15200 0    130  ~ 26
±1%
Text Notes 40800 16700 0    130  ~ 26
±1%
Text Notes 40800 16950 0    130  ~ 26
±1%
Text Notes 40800 17200 0    130  ~ 26
±2%
Text Notes 40775 18200 0    130  ~ 26
±2%
Text Notes 40775 18450 0    130  ~ 26
±1%
Text Notes 40775 18700 0    130  ~ 26
±1%
Text Notes 41600 18700 0    130  ~ 26
1/4W
Text Notes 38200 19700 0    130  ~ 26
DIODE
Text Notes 36000 19700 0    130  ~ 26
1006751
Text Notes 36000 24200 0    130  ~ 26
1006751
Text Notes 38225 24200 0    130  ~ 26
DIODE
Text Notes 35975 24950 0    130  ~ 26
1006323
Text Notes 35975 26450 0    130  ~ 26
1006323
Text Notes 35975 26700 0    130  ~ 26
1006323
Text Notes 35975 25200 0    130  ~ 26
1006310
Text Notes 35975 26200 0    130  ~ 26
1006310
Text Notes 35975 26950 0    130  ~ 26
1006310
Text Notes 35975 27200 0    130  ~ 26
1006310
Text Notes 37850 24950 0    130  ~ 26
TRANSISTOR
Text Notes 37875 28450 0    130  ~ 26
TRANSISTOR
Text Notes 35975 27700 0    130  ~ 26
1006310
Text Notes 35975 28200 0    130  ~ 26
1006310
Text Notes 35975 27450 0    130  ~ 26
1006323
Text Notes 35975 27950 0    130  ~ 26
1006323
Text Notes 35975 28450 0    130  ~ 26
1006323
Text Notes 37225 18700 0    130  ~ 26
59
Text Notes 37225 16950 0    130  ~ 26
59
Text Notes 37225 18200 0    130  ~ 26
43
Text Notes 37225 16450 0    130  ~ 26
43
Text Notes 37225 17950 0    130  ~ 26
49
Text Notes 37225 17450 0    130  ~ 26
49
Text Notes 37225 17200 0    130  ~ 26
49
Text Notes 37225 16200 0    130  ~ 26
49
Text Notes 37225 17700 0    130  ~ 26
28
Text Notes 37225 15950 0    130  ~ 26
28
Text Notes 40000 18700 0    130  ~ 26
6
Text Notes 40000 16950 0    130  ~ 26
6
Text Notes 39850 18450 0    130  ~ 26
NOM
Text Notes 39850 16700 0    130  ~ 26
NOM
Text Notes 39800 18200 0    130  ~ 26
3000
Text Notes 39800 16450 0    130  ~ 26
3000
Text Notes 39800 17950 0    130  ~ 26
5100
Text Notes 39800 17450 0    130  ~ 26
5100
Text Notes 39800 17200 0    130  ~ 26
5100
Text Notes 39800 16200 0    130  ~ 26
5100
Text Notes 39850 17700 0    130  ~ 26
680
Text Notes 39850 15950 0    130  ~ 26
680
Text Notes 37225 15700 0    130  ~ 26
49
Text Notes 37225 15450 0    130  ~ 26
49
Text Notes 37225 14450 0    130  ~ 26
49
Text Notes 37225 13950 0    130  ~ 26
49
Text Notes 37225 13700 0    130  ~ 26
49
Text Notes 37225 13200 0    130  ~ 26
49
Text Notes 37225 12450 0    130  ~ 26
49
Text Notes 37225 11950 0    130  ~ 26
49
Text Notes 37225 11200 0    130  ~ 26
49
Text Notes 37225 15200 0    130  ~ 26
59
Text Notes 37225 14700 0    130  ~ 26
43
Text Notes 37225 13450 0    130  ~ 26
43
Text Notes 37225 11700 0    130  ~ 26
43
Text Notes 37225 14200 0    130  ~ 26
28
Text Notes 37225 12950 0    130  ~ 26
39
Text Notes 37225 11450 0    130  ~ 26
39
Text Notes 37225 12200 0    130  ~ 26
15
Text Notes 37225 12700 0    130  ~ 26
15
Text Notes 39800 15700 0    130  ~ 26
5100
Text Notes 39800 15450 0    130  ~ 26
5100
Text Notes 39800 14450 0    130  ~ 26
5100
Text Notes 39800 13950 0    130  ~ 26
5100
Text Notes 39800 13700 0    130  ~ 26
5100
Text Notes 39800 13200 0    130  ~ 26
5100
Text Notes 39800 12450 0    130  ~ 26
5100
Text Notes 39800 11950 0    130  ~ 26
5100
Text Notes 39800 11200 0    130  ~ 26
5100
Text Notes 39850 14200 0    130  ~ 26
680
Text Notes 39975 15200 0    130  ~ 26
6
Text Notes 39825 14950 0    130  ~ 26
NOM
Text Notes 39800 14700 0    130  ~ 26
3000
Text Notes 39800 13450 0    130  ~ 26
3000
Text Notes 39800 11700 0    130  ~ 26
3000
Text Notes 39800 11450 0    130  ~ 26
2000
Text Notes 39800 12950 0    130  ~ 26
2000
Text Notes 39825 12700 0    130  ~ 26
200
Text Notes 39800 12200 0    130  ~ 26
200
Text Notes 37225 10450 0    130  ~ 26
49
Text Notes 37225 9700 0    130  ~ 26
49
Text Notes 37225 8950 0    130  ~ 26
49
Text Notes 37225 7700 0    130  ~ 26
49
Text Notes 37225 10700 0    130  ~ 26
39
Text Notes 37225 9950 0    130  ~ 26
39
Text Notes 37225 9200 0    130  ~ 26
39
Text Notes 37225 8450 0    130  ~ 26
39
Text Notes 37225 8200 0    130  ~ 26
39
Text Notes 37225 10950 0    130  ~ 26
43
Text Notes 37225 10200 0    130  ~ 26
43
Text Notes 37225 9450 0    130  ~ 26
43
Text Notes 37225 8700 0    130  ~ 26
43
Text Notes 37225 7950 0    130  ~ 26
15
Text Notes 39800 10950 0    130  ~ 26
3000
Text Notes 39800 10200 0    130  ~ 26
3000
Text Notes 39800 9450 0    130  ~ 26
3000
Text Notes 39800 8700 0    130  ~ 26
3000
Text Notes 39800 10700 0    130  ~ 26
2000
Text Notes 39800 9950 0    130  ~ 26
2000
Text Notes 39800 9200 0    130  ~ 26
2000
Text Notes 39800 8450 0    130  ~ 26
2000
Text Notes 39800 8200 0    130  ~ 26
2000
Text Notes 39800 10450 0    130  ~ 26
5100
Text Notes 39800 9700 0    130  ~ 26
5100
Text Notes 39775 8950 0    130  ~ 26
5100
Text Notes 39775 7700 0    130  ~ 26
5100
Text Notes 39825 7950 0    130  ~ 26
200
Wire Notes Line width 60 style solid
	38475 28163 38425 28038
Wire Notes Line width 60 style solid
	38425 28038 38525 28038
Wire Notes Line width 60 style solid
	38525 28038 38475 28163
Wire Notes Line width 60 style solid
	36450 25913 36400 25788
Wire Notes Line width 60 style solid
	36400 25788 36500 25788
Wire Notes Line width 60 style solid
	36500 25788 36450 25913
Wire Notes Line width 60 style solid
	38500 23913 38450 23788
Wire Notes Line width 60 style solid
	38450 23788 38550 23788
Wire Notes Line width 60 style solid
	38550 23788 38500 23913
Wire Notes Line width 60 style solid
	36450 23913 36400 23788
Wire Notes Line width 60 style solid
	36400 23788 36500 23788
Wire Notes Line width 60 style solid
	36500 23788 36450 23913
Wire Notes Line width 60 style solid
	41875 18413 41825 18288
Wire Notes Line width 60 style solid
	41825 18288 41925 18288
Wire Notes Line width 60 style solid
	41925 18288 41875 18413
Wire Notes Line width 60 style solid
	41025 17913 40975 17788
Wire Notes Line width 60 style solid
	40975 17788 41075 17788
Wire Notes Line width 60 style solid
	41075 17788 41025 17913
Wire Notes Line width 60 style solid
	41050 16163 41000 16038
Wire Notes Line width 60 style solid
	41000 16038 41100 16038
Wire Notes Line width 60 style solid
	41100 16038 41050 16163
Wire Notes Line width 60 style solid
	38475 18413 38425 18288
Wire Notes Line width 60 style solid
	38425 18288 38525 18288
Wire Notes Line width 60 style solid
	38525 18288 38475 18413
Wire Notes Line width 60 style solid
	36450 17913 36400 17788
Wire Notes Line width 60 style solid
	36400 17788 36500 17788
Wire Notes Line width 60 style solid
	36500 17788 36450 17913
Wire Notes Line width 60 style solid
	36450 16163 36400 16038
Wire Notes Line width 60 style solid
	36400 16038 36500 16038
Wire Notes Line width 60 style solid
	36500 16038 36450 16163
Wire Notes Line width 60 style solid
	41025 14413 40975 14288
Wire Notes Line width 60 style solid
	40975 14288 41075 14288
Wire Notes Line width 60 style solid
	41075 14288 41025 14413
Wire Notes Line width 60 style solid
	36425 14413 36375 14288
Wire Notes Line width 60 style solid
	36375 14288 36475 14288
Wire Notes Line width 60 style solid
	36475 14288 36425 14413
Text HLabel 5375 2550 0    140  Input ~ 28
BPLSBX
Text HLabel 5400 5075 0    140  Input ~ 28
A
Text HLabel 6250 7675 0    140  Input ~ 28
0VDC
Wire Wire Line
	8875 7675 6250 7675
Connection ~ 8875 7675
Text HLabel 24950 6075 2    140  Output ~ 28
E
Text HLabel 13725 6075 2    140  Output ~ 28
B
Text HLabel 17500 6075 2    140  Output ~ 28
C
Text HLabel 21175 6075 2    140  Output ~ 28
D
Text HLabel 22650 6900 0    140  Input ~ 28
J
Wire Wire Line
	22650 6900 22725 6900
Wire Wire Line
	22725 6600 22725 6900
Text HLabel 18850 6900 0    140  Input ~ 28
H
Wire Wire Line
	18850 6900 18975 6900
Wire Wire Line
	18975 6650 18975 6900
Text HLabel 15100 6900 0    140  Input ~ 28
G
Wire Wire Line
	15100 6900 15250 6900
Wire Wire Line
	15250 6650 15250 6900
Text HLabel 11375 6900 0    140  Input ~ 28
F
Wire Wire Line
	11375 6900 11500 6900
Wire Wire Line
	11500 6700 11500 6900
$EndSCHEMATC
