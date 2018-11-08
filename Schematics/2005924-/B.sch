EESchema Schematic File Version 4
LIBS:module-cache
EELAYER 29 0
EELAYER END
$Descr E 44000 34000
encoding utf-8
Sheet 3 13
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
Text Notes 26775 2125 0    140  ~ 28
CKT NO. 40611 THRU 40617
$Comp
L AGC_DSKY:Transistor-NPN Q7
U 1 1 5C6F4D1B
P 31200 4575
AR Path="/5C5C844C/5C6F4D1B" Ref="Q7"  Part="1" 
AR Path="/5C8A9E64/5C6F4D1B" Ref="Q801"  Part="1" 
AR Path="/5C8CAAA5/5C6F4D1B" Ref="Q901"  Part="1" 
AR Path="/5C8DB10C/5C6F4D1B" Ref="Q1001"  Part="1" 
AR Path="/5C8EB80E/5C6F4D1B" Ref="Q1101"  Part="1" 
AR Path="/5C8EB814/5C6F4D1B" Ref="Q1201"  Part="1" 
AR Path="/5C8EB81A/5C6F4D1B" Ref="Q1301"  Part="1" 
AR Path="/5C8EB820/5C6F4D1B" Ref="Q?"  Part="1" 
F 0 "Q7" H 31775 4875 50  0000 C CNN
F 1 "Transistor-NPN" H 31200 5140 130 0001 C CNN
F 2 "" H 31200 4825 130 0001 C CNN
F 3 "" H 31200 4825 130 0001 C CNN
F 4 "Q7" H 31775 5025 130 0000 C CNN "OREFD"
	1    31200 4575
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:Diode CR6
U 1 1 5C6F604C
P 31350 5425
AR Path="/5C5C844C/5C6F604C" Ref="CR6"  Part="1" 
AR Path="/5C8A9E64/5C6F604C" Ref="CR801"  Part="1" 
AR Path="/5C8CAAA5/5C6F604C" Ref="CR901"  Part="1" 
AR Path="/5C8DB10C/5C6F604C" Ref="CR1001"  Part="1" 
AR Path="/5C8EB80E/5C6F604C" Ref="CR1101"  Part="1" 
AR Path="/5C8EB814/5C6F604C" Ref="CR1201"  Part="1" 
AR Path="/5C8EB81A/5C6F604C" Ref="CR1301"  Part="1" 
AR Path="/5C8EB820/5C6F604C" Ref="CR?"  Part="1" 
F 0 "CR6" V 31225 4975 50  0000 C CNN
F 1 "Diode" H 31350 5275 50  0001 C CNN
F 2 "" H 31300 5250 50  0001 C CNN
F 3 "" H 31300 5425 50  0001 C CNN
F 4 "CR6" V 31375 4975 130 0000 C CNN "OREFD"
	1    31350 5425
	0    -1   -1   0   
$EndComp
$Comp
L AGC_DSKY:Resistor R19
U 1 1 5C6F6D6B
P 29875 4575
AR Path="/5C5C844C/5C6F6D6B" Ref="R19"  Part="1" 
AR Path="/5C8A9E64/5C6F6D6B" Ref="R802"  Part="1" 
AR Path="/5C8CAAA5/5C6F6D6B" Ref="R902"  Part="1" 
AR Path="/5C8DB10C/5C6F6D6B" Ref="R1002"  Part="1" 
AR Path="/5C8EB80E/5C6F6D6B" Ref="R1102"  Part="1" 
AR Path="/5C8EB814/5C6F6D6B" Ref="R1202"  Part="1" 
AR Path="/5C8EB81A/5C6F6D6B" Ref="R1302"  Part="1" 
AR Path="/5C8EB820/5C6F6D6B" Ref="R?"  Part="1" 
F 0 "R19" H 29575 4375 50  0000 C CNN
F 1 "200" H 29900 4100 130 0000 C CNN
F 2 "" H 29875 4575 130 0001 C CNN
F 3 "" H 29875 4575 130 0001 C CNN
F 4 "R19" H 29900 4350 130 0000 C CNN "OREFD"
	1    29875 4575
	-1   0    0    -1  
$EndComp
$Comp
L AGC_DSKY:Resistor R18
U 1 1 5C6F739D
P 29100 3850
AR Path="/5C5C844C/5C6F739D" Ref="R18"  Part="1" 
AR Path="/5C8A9E64/5C6F739D" Ref="R801"  Part="1" 
AR Path="/5C8CAAA5/5C6F739D" Ref="R901"  Part="1" 
AR Path="/5C8DB10C/5C6F739D" Ref="R1001"  Part="1" 
AR Path="/5C8EB80E/5C6F739D" Ref="R1101"  Part="1" 
AR Path="/5C8EB814/5C6F739D" Ref="R1201"  Part="1" 
AR Path="/5C8EB81A/5C6F739D" Ref="R1301"  Part="1" 
AR Path="/5C8EB820/5C6F739D" Ref="R?"  Part="1" 
F 0 "R18" V 28875 3075 50  0000 C CNN
F 1 "5100" V 29175 3425 130 0000 C CNN
F 2 "" H 29100 3850 130 0001 C CNN
F 3 "" H 29100 3850 130 0001 C CNN
F 4 "R18" V 28875 3425 130 0000 C CNN "OREFD"
	1    29100 3850
	0    -1   1    0   
$EndComp
Wire Wire Line
	30275 4575 30900 4575
Wire Wire Line
	31350 4825 31350 5225
Wire Wire Line
	29475 4575 29100 4575
Wire Wire Line
	29100 4250 29100 4575
Connection ~ 29100 4575
Wire Wire Line
	29100 4575 28425 4575
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
Text HLabel 28675 3100 0    140  Input ~ 28
BPLSBX
Text HLabel 28425 4575 0    140  Input ~ 28
V
Text HLabel 30850 6025 0    140  Input ~ 28
0VDC
Text HLabel 31700 3150 2    140  Output ~ 28
W
Wire Wire Line
	29100 3100 28675 3100
Wire Wire Line
	29100 3100 29100 3450
Wire Wire Line
	30850 6025 31350 6025
Wire Wire Line
	31350 5625 31350 6025
Wire Wire Line
	31350 3150 31700 3150
Wire Wire Line
	31350 3150 31350 4325
$EndSCHEMATC
