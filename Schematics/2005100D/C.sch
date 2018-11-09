EESchema Schematic File Version 4
LIBS:module-cache
EELAYER 29 0
EELAYER END
$Descr E 44000 34000
encoding utf-8
Sheet 5 16
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text Notes 39669 31724 0    250  ~ 50
SCHEMATIC,
Text Notes 40894 33124 0    250  ~ 50
2005100
Text Notes 38269 33124 0    250  ~ 50
80230
Text Notes 39100 32125 0    200  ~ 40
ROPE DRIVER MODULE
Text Notes 39900 32400 0    140  ~ 28
B16 — B17
Text Notes 33425 32325 0    140  ~ 28
____________
Text Notes 33450 32900 0    140  ~ 28
____________
Text Notes 33450 33375 0    140  ~ 28
____________
Wire Notes Line style solid
	34019 33424 34144 33249
Text Notes 34125 31775 0    140  ~ 28
___
Text Notes 33125 31775 0    140  ~ 28
___
Text Notes 40344 33424 0    140  ~ 28
_____
Wire Notes Line style solid
	40569 33449 40669 33349
Text Notes 38819 33474 0    140  ~ 28
NONE
Wire Notes Line style solid
	34019 32949 34144 32774
Wire Notes Line style solid
	34019 32374 34144 32199
Wire Notes Line style solid
	33244 31799 33319 31699
Wire Notes Line style solid
	34269 31799 34344 31699
Wire Notes Line style solid
	35244 31799 35319 31699
Text Notes 42400 33450 0    140  ~ 28
1     2
Wire Notes Line style solid
	37965 921  37965 3175
Wire Notes Line style solid
	37965 3175 43500 3175
Wire Notes Line style solid
	42487 921  42487 3175
Wire Notes Line style solid
	37965 2680 43500 2680
Wire Notes Line style solid
	37965 2180 43500 2180
Wire Notes Line style solid
	37965 1529 43500 1529
Wire Notes Line style solid
	38456 921  38456 3175
Wire Notes Line style solid
	41800 921  41800 3175
Text Notes 38121 1324 0    140  ~ 28
A
Text Notes 38105 1970 0    140  ~ 28
B
Text Notes 38124 2519 0    140  ~ 28
C
Text Notes 38133 3050 0    140  ~ 28
D
Text Notes 38525 1450 0    140  ~ 28
REVISED PER TDRR 27079\nDR        CHK      APPD
Text Notes 38525 2100 0    140  ~ 28
REVISED PER TDRR 28162\nDR        CHK      APPD
Text Notes 38525 2650 0    140  ~ 28
REVISED PER TDRR 29079\nDR        CHK      APPD
Text Notes 38525 3150 0    140  ~ 28
REVISED PER TDRR 30864\nDR        CHK      APPD
Text Notes 35100 31775 0    140  ~ 28
___
Wire Notes Line style solid
	525  13275 43450 13275
Wire Notes Line style solid
	23950 19975 23950 21325
Wire Notes Line style solid
	22100 21325 22100 25875
Wire Notes Line style solid
	22100 25875 33400 25875
Wire Notes Line style solid
	33400 27675 43475 27675
Wire Notes Line style solid
	33400 21325 33400 27675
Wire Notes Line style solid
	22100 21325 43475 21325
Wire Notes Line style solid
	27900 25875 27900 13275
Wire Notes Line style solid
	550  19975 27900 19975
Wire Notes Line style solid
	35725 21325 35725 17975
Wire Notes Line style solid
	34550 17975 34550 13275
Wire Notes Line style solid
	27900 17975 43475 17975
Wire Notes Line style solid
	12850 13275 12850 525 
Wire Notes Line style solid
	25200 13275 25200 550 
Wire Notes Line style solid
	37525 13275 37525 600 
Wire Notes Line style solid
	37525 7075 43475 7075
$Comp
L AGC_DSKY:Inductor L9
U 1 1 5C376F18
P 30725 22700
AR Path="/5B8E7735/5C376F18" Ref="L9"  Part="1" 
AR Path="/5F7B6DBB/5C376F18" Ref="L9"  Part="1" 
AR Path="/5F8B4769/5C376F18" Ref="L9"  Part="1" 
F 0 "L9" H 30925 23250 50  0000 C CNN
F 1 "8.2UH" H 30700 22975 130 0000 C CNN
F 2 "" H 30675 22900 130 0001 C CNN
F 3 "" H 30675 22900 130 0001 C CNN
F 4 "L9" H 30700 23250 130 0000 C CNN "OREFD"
	1    30725 22700
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:Capacitor-Polarized C7
U 1 1 5C3774D2
P 31675 23325
AR Path="/5B8E7735/5C3774D2" Ref="C7"  Part="1" 
AR Path="/5F7B6DBB/5C3774D2" Ref="C7"  Part="1" 
AR Path="/5F8B4769/5C3774D2" Ref="C7"  Part="1" 
F 0 "C7" H 32300 23450 50  0000 C CNN
F 1 "6.8UF" H 32175 23200 130 0000 C CNN
F 2 "" H 31675 23725 130 0001 C CNN
F 3 "" H 31675 23725 130 0001 C CNN
F 4 "C7" H 32075 23450 130 0000 C CNN "OREFD"
	1    31675 23325
	1    0    0    -1  
$EndComp
Text Notes 28050 25100 0    140  ~ 28
CIRCUIT NUMBERS
Text Notes 28500 25575 0    140  ~ 28
40518, 40520, 40522\n40519, 40521, 40523
Wire Wire Line
	30325 22700 30050 22700
Wire Wire Line
	31125 22700 31675 22700
Wire Wire Line
	31675 23050 31675 22700
Connection ~ 31675 22700
Wire Wire Line
	31675 22700 32275 22700
Wire Notes Line style solid
	8225 13275 8225 19975
Wire Notes Line style solid
	18950 19975 18950 13300
Text HLabel 30050 22700 0    140  Input ~ 28
F
Text HLabel 31225 24150 0    140  Input ~ 28
G
Wire Wire Line
	31225 24150 31675 24150
Wire Wire Line
	31675 23575 31675 24150
Text HLabel 32275 22700 2    140  Output ~ 28
H
$EndSCHEMATC
