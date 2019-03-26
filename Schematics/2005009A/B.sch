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
L AGC_DSKY:Transistor-NPN 1Q7
U 1 1 5C6F4D1B
P 31150 4575
AR Path="/5C5C844C/5C6F4D1B" Ref="1Q7"  Part="1" 
AR Path="/5C8A9E64/5C6F4D1B" Ref="2Q7"  Part="1" 
AR Path="/5C8CAAA5/5C6F4D1B" Ref="3Q7"  Part="1" 
AR Path="/5C8DB10C/5C6F4D1B" Ref="4Q7"  Part="1" 
AR Path="/5C8EB80E/5C6F4D1B" Ref="5Q7"  Part="1" 
AR Path="/5C8EB814/5C6F4D1B" Ref="6Q7"  Part="1" 
AR Path="/5C8EB81A/5C6F4D1B" Ref="7Q7"  Part="1" 
AR Path="/5C8EB820/5C6F4D1B" Ref="Q?"  Part="1" 
F 0 "1Q7" H 31725 4875 50  0000 C CNN
F 1 "Transistor-NPN" H 31150 5140 130 0001 C CNN
F 2 "" H 31150 4825 130 0001 C CNN
F 3 "" H 31150 4825 130 0001 C CNN
F 4 "Q7" H 31725 5025 130 0000 C CNN "OREFD"
	1    31150 4575
	1    0    0    -1  
$EndComp
$Comp
L AGC_DSKY:Diode 1CR6
U 1 1 5C6F604C
P 31300 5425
AR Path="/5C5C844C/5C6F604C" Ref="1CR6"  Part="1" 
AR Path="/5C8A9E64/5C6F604C" Ref="2CR6"  Part="1" 
AR Path="/5C8CAAA5/5C6F604C" Ref="3CR6"  Part="1" 
AR Path="/5C8DB10C/5C6F604C" Ref="4CR6"  Part="1" 
AR Path="/5C8EB80E/5C6F604C" Ref="5CR6"  Part="1" 
AR Path="/5C8EB814/5C6F604C" Ref="6CR6"  Part="1" 
AR Path="/5C8EB81A/5C6F604C" Ref="7CR6"  Part="1" 
AR Path="/5C8EB820/5C6F604C" Ref="CR?"  Part="1" 
F 0 "1CR6" V 31175 4975 50  0000 C CNN
F 1 "Diode" H 31300 5275 50  0001 C CNN
F 2 "" H 31250 5250 50  0001 C CNN
F 3 "" H 31250 5425 50  0001 C CNN
F 4 "CR6" V 31325 4975 130 0000 C CNN "OREFD"
	1    31300 5425
	0    -1   -1   0   
$EndComp
$Comp
L AGC_DSKY:Resistor 1R19
U 1 1 5C6F6D6B
P 29825 4575
AR Path="/5C5C844C/5C6F6D6B" Ref="1R19"  Part="1" 
AR Path="/5C8A9E64/5C6F6D6B" Ref="2R19"  Part="1" 
AR Path="/5C8CAAA5/5C6F6D6B" Ref="3R19"  Part="1" 
AR Path="/5C8DB10C/5C6F6D6B" Ref="4R19"  Part="1" 
AR Path="/5C8EB80E/5C6F6D6B" Ref="5R19"  Part="1" 
AR Path="/5C8EB814/5C6F6D6B" Ref="6R19"  Part="1" 
AR Path="/5C8EB81A/5C6F6D6B" Ref="7R19"  Part="1" 
AR Path="/5C8EB820/5C6F6D6B" Ref="R?"  Part="1" 
F 0 "1R19" H 29525 4375 50  0000 C CNN
F 1 "200" H 29850 4100 130 0000 C CNN
F 2 "" H 29825 4575 130 0001 C CNN
F 3 "" H 29825 4575 130 0001 C CNN
F 4 "R19" H 29850 4350 130 0000 C CNN "OREFD"
	1    29825 4575
	-1   0    0    -1  
$EndComp
$Comp
L AGC_DSKY:Resistor 1R18
U 1 1 5C6F739D
P 29050 3850
AR Path="/5C5C844C/5C6F739D" Ref="1R18"  Part="1" 
AR Path="/5C8A9E64/5C6F739D" Ref="2R18"  Part="1" 
AR Path="/5C8CAAA5/5C6F739D" Ref="3R18"  Part="1" 
AR Path="/5C8DB10C/5C6F739D" Ref="4R18"  Part="1" 
AR Path="/5C8EB80E/5C6F739D" Ref="5R18"  Part="1" 
AR Path="/5C8EB814/5C6F739D" Ref="6R18"  Part="1" 
AR Path="/5C8EB81A/5C6F739D" Ref="7R18"  Part="1" 
AR Path="/5C8EB820/5C6F739D" Ref="R?"  Part="1" 
F 0 "1R18" V 28825 3075 50  0000 C CNN
F 1 "5100" V 29125 3425 130 0000 C CNN
F 2 "" H 29050 3850 130 0001 C CNN
F 3 "" H 29050 3850 130 0001 C CNN
F 4 "R18" V 28825 3425 130 0000 C CNN "OREFD"
	1    29050 3850
	0    -1   1    0   
$EndComp
Wire Wire Line
	30225 4575 30850 4575
Wire Wire Line
	31300 4825 31300 5225
Wire Wire Line
	29425 4575 29050 4575
Wire Wire Line
	29050 4250 29050 4575
Connection ~ 29050 4575
Wire Wire Line
	29050 4575 28375 4575
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
Text Notes 35050 11950 0    140  ~ 28
R18
Text Notes 35050 12200 0    140  ~ 28
R19
Text Notes 35075 20950 0    140  ~ 28
CR6
Wire Notes Line style solid
	34850 7225 34850 29475
Wire Notes Line style solid
	35875 29475 35875 7225
Wire Notes Line style solid
	37725 7225 37725 29475
Wire Notes Line style solid
	39450 29475 39450 7225
Wire Notes Line style solid
	40600 7225 40600 29475
Wire Notes Line style solid
	41475 29475 41475 7225
Wire Notes Line style solid
	42375 7225 42375 29475
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
Text Notes 38000 11950 0    130  ~ 26
RESISTOR
Text Notes 40800 11950 0    130  ~ 26
±2%
Text Notes 41600 11950 0    130  ~ 26
1/4W
Text Notes 36950 11950 0    130  ~ 26
-
Text Notes 36950 12200 0    130  ~ 26
-
Text Notes 35925 12200 0    130  ~ 26
1006750
Text Notes 36000 20950 0    130  ~ 26
1006751
Text Notes 38225 20950 0    130  ~ 26
DIODE
Text Notes 35975 26450 0    130  ~ 26
1006323
Text Notes 37875 26450 0    130  ~ 26
TRANSISTOR
Text Notes 37225 11950 0    130  ~ 26
49
Text Notes 37225 12200 0    130  ~ 26
15
Text HLabel 28625 3100 0    140  Input ~ 28
BPLSBX
Text HLabel 28375 4575 0    140  Input ~ 28
V
Text HLabel 30800 6025 0    140  Input ~ 28
0VDC
Text HLabel 31650 3150 2    140  Output ~ 28
W
Wire Wire Line
	29050 3100 28625 3100
Wire Wire Line
	29050 3100 29050 3450
Wire Wire Line
	30800 6025 31300 6025
Wire Wire Line
	31300 5625 31300 6025
Wire Wire Line
	31300 3150 31650 3150
Wire Wire Line
	31300 3150 31300 4325
Text Notes 39775 31725 0    250  ~ 50
SCHEMATIC,
Text Notes 40869 33149 0    250  ~ 50
2005009
Text Notes 38244 33149 0    250  ~ 50
80230
Text Notes 39525 32100 0    200  ~ 40
STRAND SELECT
Text Notes 39450 32475 0    200  ~ 40
MODULE NO. B15
Text Notes 38800 33375 0    140  ~ 28
____
Text Notes 42375 33475 0    140  ~ 28
1     1
Text Notes 39850 33375 0    140  ~ 28
____________
Text Notes 34800 33225 0    140  ~ 28
____
Text Notes 32900 32925 0    140  ~ 28
______________________
Wire Notes Line style solid
	36465 985  36465 1340
Wire Notes Line style solid
	36465 1340 43500 1340
Wire Notes Line style solid
	36840 985  36840 1340
Wire Notes Line style solid
	37350 985  37350 1340
Wire Notes Line style solid
	40830 985  40830 1340
Wire Notes Line style solid
	41330 985  41330 1340
Wire Notes Line style solid
	41830 985  41830 1340
Wire Notes Line style solid
	42480 985  42480 1340
Text Notes 36575 1280 0    140  ~ 28
A       REVISED PER TDRR 17906
Wire Notes Line style solid
	34850 14475 42375 14475
Text Notes 35925 11950 0    130  ~ 26
1006750
Text Notes 39700 11950 0    130  ~ 26
5100
Text Notes 39750 12200 0    130  ~ 26
200
Text Notes 40800 12200 0    130  ~ 26
±2%
Text Notes 38000 12200 0    130  ~ 26
RESISTOR
Text Notes 41600 12200 0    130  ~ 26
1/4W
Text Notes 35500 26450 2    130  ~ 26
Q7
$EndSCHEMATC
