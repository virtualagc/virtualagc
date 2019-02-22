EESchema Schematic File Version 4
LIBS:module-cache
EELAYER 29 0
EELAYER END
$Descr E 44000 34000
encoding utf-8
Sheet 2 12
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text Notes 38725 32175 0    250  ~ 50
     SCHEMATIC,\nROPE DRIVER MODULE
Text Notes 40780 33105 0    250  ~ 50
1006147
Text Notes 38900 33375 0    140  ~ 28
___
Text Notes 38905 33460 0    140  ~ 28
//
Text Notes 40250 33375 0    140  ~ 28
______
Text Notes 40410 33450 0    140  ~ 28
//
Text Notes 33525 33275 0    140  ~ 28
____________
Text Notes 33935 33360 0    140  ~ 28
//
Text Notes 33375 31750 0    140  ~ 28
___
Text Notes 33390 31820 0    140  ~ 28
//
Text Notes 34300 31750 0    140  ~ 28
___
Text Notes 34315 31825 0    140  ~ 28
//
Text Notes 35100 31750 0    140  ~ 28
___
Text Notes 35110 31820 0    140  ~ 28
//
Text Notes 33500 32800 0    140  ~ 28
____________
Text Notes 33930 32880 0    140  ~ 28
//
Text Notes 33450 32325 0    140  ~ 28
____________
Text Notes 33935 32405 0    140  ~ 28
//
Text Notes 42375 33475 0    140  ~ 28
1     2
Wire Notes Line style solid
	37965 910  37965 1690
Wire Notes Line style solid
	37965 1690 43500 1690
Wire Notes Line style solid
	37965 1170 43500 1170
Wire Notes Line style solid
	38465 910  38465 1690
Wire Notes Line style solid
	41800 910  41800 1690
Wire Notes Line style solid
	42465 910  42465 1690
Text Notes 38150 1150 0    140  ~ 28
A
Text Notes 38150 1525 0    140  ~ 28
B
Text Notes 38500 1150 0    140  ~ 28
REVISED PER TDRR 05562
Text Notes 38500 1650 0    140  ~ 28
REVISED PER TDRR 08106\nDR         CHK
Text Notes 39950 32500 0    180  ~ 36
B32 - B33
Wire Notes Line style solid
	23075 29925 30075 29925
Wire Notes Line style solid
	30075 29925 30075 25475
Wire Notes Line style solid
	23075 25475 23075 29925
Wire Notes Line style solid
	23075 25475 43500 25475
Wire Notes Line style solid
	27450 22900 500  22900
Wire Notes Line style solid
	27450 12925 27450 25475
Wire Notes Line style solid
	15450 12925 43500 12925
Wire Notes Line style solid
	15450 22900 15450 10025
Wire Notes Line style solid
	500  10025 20450 10025
Wire Notes Line style solid
	20450 500  20450 12925
Wire Notes Line style solid
	9575 10025 9575 500 
Wire Notes Line style solid
	34575 12925 34575 500 
Wire Notes Line style solid
	34575 5000 43500 5000
Text HLabel 2700 6050 0    140  Input ~ 28
A
Text HLabel 4125 4075 1    140  Input ~ 28
BPLIZ1
Text HLabel 6250 4000 1    140  Input ~ 28
B
Text HLabel 8100 4000 1    140  Input ~ 28
C
Text HLabel 6250 7575 3    140  Input ~ 28
40365A,6A
Text HLabel 8100 8425 3    140  Output ~ 28
D
$Comp
L AGC_DSKY:Transistor-NPN Q?
U 1 1 5E2AB8B9
P 6100 6050
AR Path="/5C882BE7/5E2AB8B9" Ref="Q?"  Part="1" 
AR Path="/5E78D42C/5E2AB8B9" Ref="Q?"  Part="1" 
AR Path="/5E7AC23E/5E2AB8B9" Ref="Q?"  Part="1" 
AR Path="/5E7CC1AF/5E2AB8B9" Ref="Q?"  Part="1" 
AR Path="/5E7ED47A/5E2AB8B9" Ref="Q?"  Part="1" 
AR Path="/5E80F809/5E2AB8B9" Ref="Q?"  Part="1" 
AR Path="/5E80F81A/5E2AB8B9" Ref="Q?"  Part="1" 
AR Path="/5E80F82B/5E2AB8B9" Ref="Q?"  Part="1" 
F 0 "Q?" H 5950 6500 130 0001 C CNN
F 1 "Transistor-NPN" H 6100 6615 130 0001 C CNN
F 2 "" H 6100 6300 130 0001 C CNN
F 3 "" H 6100 6300 130 0001 C CNN
F 4 "Q1" H 5750 5675 130 0000 C CNN "baseRefd"
F 5 "" H 6100 6050 50  0001 C CNN "Field6"
	1    6100 6050
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:Transistor-NPN Q?
U 1 1 5E2AC246
P 7950 5550
AR Path="/5C882BE7/5E2AC246" Ref="Q?"  Part="1" 
AR Path="/5E78D42C/5E2AC246" Ref="Q?"  Part="1" 
AR Path="/5E7AC23E/5E2AC246" Ref="Q?"  Part="1" 
AR Path="/5E7CC1AF/5E2AC246" Ref="Q?"  Part="1" 
AR Path="/5E7ED47A/5E2AC246" Ref="Q?"  Part="1" 
AR Path="/5E80F809/5E2AC246" Ref="Q?"  Part="1" 
AR Path="/5E80F81A/5E2AC246" Ref="Q?"  Part="1" 
AR Path="/5E80F82B/5E2AC246" Ref="Q?"  Part="1" 
F 0 "Q?" H 7800 6000 130 0001 C CNN
F 1 "Transistor-NPN" H 7950 6115 130 0001 C CNN
F 2 "" H 7950 5800 130 0001 C CNN
F 3 "" H 7950 5800 130 0001 C CNN
F 4 "Q2" H 8550 5775 130 0000 C CNN "baseRefd"
F 5 "" H 7950 5550 50  0001 C CNN "Field6"
	1    7950 5550
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:Resistor R?
U 1 1 5E2ACCA7
P 4125 5350
AR Path="/5C882BE7/5E2ACCA7" Ref="R?"  Part="1" 
AR Path="/5E78D42C/5E2ACCA7" Ref="R?"  Part="1" 
AR Path="/5E7AC23E/5E2ACCA7" Ref="R?"  Part="1" 
AR Path="/5E7CC1AF/5E2ACCA7" Ref="R?"  Part="1" 
AR Path="/5E7ED47A/5E2ACCA7" Ref="R?"  Part="1" 
AR Path="/5E80F809/5E2ACCA7" Ref="R?"  Part="1" 
AR Path="/5E80F81A/5E2ACCA7" Ref="R?"  Part="1" 
AR Path="/5E80F82B/5E2ACCA7" Ref="R?"  Part="1" 
F 0 "R?" H 4100 5175 130 0001 C CNN
F 1 "3000" V 4225 4850 130 0000 C CNN
F 2 "" H 4125 5350 130 0001 C CNN
F 3 "" H 4125 5350 130 0001 C CNN
F 4 "R1" V 3925 4875 130 0000 C CNN "baseRefd"
	1    4125 5350
	0    1    1    0   
$EndComp
$Comp
L AGC_DSKY:Resistor R?
U 1 1 5E2AD061
P 6250 4875
AR Path="/5C882BE7/5E2AD061" Ref="R?"  Part="1" 
AR Path="/5E78D42C/5E2AD061" Ref="R?"  Part="1" 
AR Path="/5E7AC23E/5E2AD061" Ref="R?"  Part="1" 
AR Path="/5E7CC1AF/5E2AD061" Ref="R?"  Part="1" 
AR Path="/5E7ED47A/5E2AD061" Ref="R?"  Part="1" 
AR Path="/5E80F809/5E2AD061" Ref="R?"  Part="1" 
AR Path="/5E80F81A/5E2AD061" Ref="R?"  Part="1" 
AR Path="/5E80F82B/5E2AD061" Ref="R?"  Part="1" 
F 0 "R?" H 6225 4700 130 0001 C CNN
F 1 "390" V 6350 5300 130 0000 C CNN
F 2 "" H 6250 4875 130 0001 C CNN
F 3 "" H 6250 4875 130 0001 C CNN
F 4 "R3" V 6100 5225 130 0000 C CNN "baseRefd"
	1    6250 4875
	0    1    1    0   
$EndComp
$Comp
L AGC_DSKY:Resistor R?
U 1 1 5E2AD6DC
P 8100 6375
AR Path="/5C882BE7/5E2AD6DC" Ref="R?"  Part="1" 
AR Path="/5E78D42C/5E2AD6DC" Ref="R?"  Part="1" 
AR Path="/5E7AC23E/5E2AD6DC" Ref="R?"  Part="1" 
AR Path="/5E7CC1AF/5E2AD6DC" Ref="R?"  Part="1" 
AR Path="/5E7ED47A/5E2AD6DC" Ref="R?"  Part="1" 
AR Path="/5E80F809/5E2AD6DC" Ref="R?"  Part="1" 
AR Path="/5E80F81A/5E2AD6DC" Ref="R?"  Part="1" 
AR Path="/5E80F82B/5E2AD6DC" Ref="R?"  Part="1" 
F 0 "R?" H 8075 6200 130 0001 C CNN
F 1 "RESISTOR" V 8200 6800 130 0001 C CNN
F 2 "" H 8100 6375 130 0001 C CNN
F 3 "" H 8100 6375 130 0001 C CNN
F 4 "R4" V 7900 6700 130 0000 C CNN "baseRefd"
	1    8100 6375
	0    1    1    0   
$EndComp
Text Notes 8625 6425 0    250  ~ 50
**
$Comp
L AGC_DSKY:Resistor R?
U 1 1 5E2ADE0F
P 5025 6050
AR Path="/5C882BE7/5E2ADE0F" Ref="R?"  Part="1" 
AR Path="/5E78D42C/5E2ADE0F" Ref="R?"  Part="1" 
AR Path="/5E7AC23E/5E2ADE0F" Ref="R?"  Part="1" 
AR Path="/5E7CC1AF/5E2ADE0F" Ref="R?"  Part="1" 
AR Path="/5E7ED47A/5E2ADE0F" Ref="R?"  Part="1" 
AR Path="/5E80F809/5E2ADE0F" Ref="R?"  Part="1" 
AR Path="/5E80F81A/5E2ADE0F" Ref="R?"  Part="1" 
AR Path="/5E80F82B/5E2ADE0F" Ref="R?"  Part="1" 
F 0 "R?" H 5000 5875 130 0001 C CNN
F 1 "200" H 5050 5825 130 0000 C CNN
F 2 "" H 5025 6050 130 0001 C CNN
F 3 "" H 5025 6050 130 0001 C CNN
F 4 "R2" H 5100 5600 130 0000 C CNN "baseRefd"
	1    5025 6050
	-1   0    0    1   
$EndComp
$Comp
L AGC_DSKY:Diode CR?
U 1 1 5E2AE78F
P 7100 6350
AR Path="/5C882BE7/5E2AE78F" Ref="CR?"  Part="1" 
AR Path="/5E78D42C/5E2AE78F" Ref="CR?"  Part="1" 
AR Path="/5E7AC23E/5E2AE78F" Ref="CR?"  Part="1" 
AR Path="/5E7CC1AF/5E2AE78F" Ref="CR?"  Part="1" 
AR Path="/5E7ED47A/5E2AE78F" Ref="CR?"  Part="1" 
AR Path="/5E80F809/5E2AE78F" Ref="CR?"  Part="1" 
AR Path="/5E80F81A/5E2AE78F" Ref="CR?"  Part="1" 
AR Path="/5E80F82B/5E2AE78F" Ref="CR?"  Part="1" 
F 0 "CR?" H 7100 6550 140 0001 C CNN
F 1 "Diode" H 7100 6200 50  0001 C CNN
F 2 "" H 7050 6175 50  0001 C CNN
F 3 "" H 7050 6350 50  0001 C CNN
F 4 "CR1" V 7100 6000 130 0000 C CNN "baseRefd"
	1    7100 6350
	0    -1   -1   0   
$EndComp
$Comp
L AGC_DSKY:Diode CR?
U 1 1 5E2AEED1
P 7100 7250
AR Path="/5C882BE7/5E2AEED1" Ref="CR?"  Part="1" 
AR Path="/5E78D42C/5E2AEED1" Ref="CR?"  Part="1" 
AR Path="/5E7AC23E/5E2AEED1" Ref="CR?"  Part="1" 
AR Path="/5E7CC1AF/5E2AEED1" Ref="CR?"  Part="1" 
AR Path="/5E7ED47A/5E2AEED1" Ref="CR?"  Part="1" 
AR Path="/5E80F809/5E2AEED1" Ref="CR?"  Part="1" 
AR Path="/5E80F81A/5E2AEED1" Ref="CR?"  Part="1" 
AR Path="/5E80F82B/5E2AEED1" Ref="CR?"  Part="1" 
F 0 "CR?" H 7100 7450 140 0001 C CNN
F 1 "Diode" H 7100 7100 50  0001 C CNN
F 2 "" H 7050 7075 50  0001 C CNN
F 3 "" H 7050 7250 50  0001 C CNN
F 4 "CR2" V 7100 6900 130 0000 C CNN "baseRefd"
	1    7100 7250
	0    -1   -1   0   
$EndComp
Text Notes 7625 6300 0    250  ~ 0
◯
Text Notes 7750 6250 0    140  ~ 28
T
Wire Wire Line
	5800 6050 5425 6050
Wire Wire Line
	4625 6050 4125 6050
Wire Wire Line
	4125 5750 4125 6050
Connection ~ 4125 6050
Wire Wire Line
	4125 6050 2700 6050
Wire Wire Line
	4125 4950 4125 4075
Wire Wire Line
	6250 5800 6250 5550
Wire Wire Line
	7650 5550 7100 5550
Connection ~ 6250 5550
Wire Wire Line
	6250 5550 6250 5275
Wire Wire Line
	7100 6150 7100 5550
Connection ~ 7100 5550
Wire Wire Line
	7100 5550 6250 5550
Wire Wire Line
	6250 4475 6250 4000
Wire Wire Line
	8100 5300 8100 4000
Wire Wire Line
	8100 5975 8100 5800
$Comp
L AGC_DSKY:Inductor L?
U 1 1 5E2C53E6
P 8100 7200
AR Path="/5C882BE7/5E2C53E6" Ref="L?"  Part="1" 
AR Path="/5E78D42C/5E2C53E6" Ref="L?"  Part="1" 
AR Path="/5E7AC23E/5E2C53E6" Ref="L?"  Part="1" 
AR Path="/5E7CC1AF/5E2C53E6" Ref="L?"  Part="1" 
AR Path="/5E7ED47A/5E2C53E6" Ref="L?"  Part="1" 
AR Path="/5E80F809/5E2C53E6" Ref="L?"  Part="1" 
AR Path="/5E80F81A/5E2C53E6" Ref="L?"  Part="1" 
AR Path="/5E80F82B/5E2C53E6" Ref="L?"  Part="1" 
F 0 "L?" H 8050 7400 130 0001 C CNN
F 1 "2.2UH" V 8225 7700 130 0000 C CNN
F 2 "" H 8050 7400 130 0001 C CNN
F 3 "" H 8050 7400 130 0001 C CNN
F 4 "L1" V 7950 7525 130 0000 C CNN "baseRefd"
	1    8100 7200
	0    1    1    0   
$EndComp
Wire Wire Line
	8100 6800 8100 6775
Wire Wire Line
	8100 7600 8100 7800
Wire Wire Line
	7100 6550 7100 7050
Wire Wire Line
	7100 7450 7100 7800
Wire Wire Line
	7100 7800 8100 7800
Connection ~ 8100 7800
Wire Wire Line
	8100 7800 8100 8425
Wire Wire Line
	6250 6300 6250 7575
Text Notes 5025 8350 0    140  ~ 28
40365A\n40366A
Text Notes 1100 9050 0    140  ~ 28
9 IDENTICAL CIRCUITS\nCIRCUIT NUMBERS
Text Notes 3500 9300 0    140  ~ 28
40311  THRU  40318\n40321  THRU  40328
Text Notes 5875 9425 0    250  ~ 50
*
Text Notes 5850 8475 0    250  ~ 50
*
$EndSCHEMATC
