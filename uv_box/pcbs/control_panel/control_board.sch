EESchema Schematic File Version 2
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:switches
LIBS:relays
LIBS:control_board-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L CONN_01X04 J7
U 1 1 593D9216
P 1500 2600
F 0 "J7" H 1500 2850 50  0000 C CNN
F 1 "7SEG_DIGITS2" V 1600 2600 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x04_Pitch2.54mm" H 1500 2600 50  0001 C CNN
F 3 "" H 1500 2600 50  0001 C CNN
	1    1500 2600
	-1   0    0    1   
$EndComp
$Comp
L CONN_01X07 J8
U 1 1 593D92E3
P 1500 3300
F 0 "J8" H 1500 3700 50  0000 C CNN
F 1 "7SEG_SEGMENTS2" V 1600 3300 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x07_Pitch2.54mm" H 1500 3300 50  0001 C CNN
F 3 "" H 1500 3300 50  0001 C CNN
	1    1500 3300
	-1   0    0    1   
$EndComp
$Comp
L R_Small R3
U 1 1 593D9672
P 2050 3000
F 0 "R3" H 2080 3020 50  0000 L CNN
F 1 "100" V 2000 3000 50  0000 C CNN
F 2 "Resistors_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" H 2050 3000 50  0001 C CNN
F 3 "" H 2050 3000 50  0001 C CNN
	1    2050 3000
	0    1    1    0   
$EndComp
$Comp
L R_Small R4
U 1 1 593D9A26
P 2050 3100
F 0 "R4" H 2080 3120 50  0000 L CNN
F 1 "100" V 2000 3100 50  0000 C CNN
F 2 "Resistors_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" H 2050 3100 50  0001 C CNN
F 3 "" H 2050 3100 50  0001 C CNN
	1    2050 3100
	0    1    1    0   
$EndComp
$Comp
L R_Small R5
U 1 1 593D9A7B
P 2050 3200
F 0 "R5" H 2080 3220 50  0000 L CNN
F 1 "100" V 2000 3200 50  0000 C CNN
F 2 "Resistors_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" H 2050 3200 50  0001 C CNN
F 3 "" H 2050 3200 50  0001 C CNN
	1    2050 3200
	0    1    1    0   
$EndComp
$Comp
L R_Small R6
U 1 1 593D9AD3
P 2050 3300
F 0 "R6" H 2080 3320 50  0000 L CNN
F 1 "100" V 2000 3300 50  0000 C CNN
F 2 "Resistors_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" H 2050 3300 50  0001 C CNN
F 3 "" H 2050 3300 50  0001 C CNN
	1    2050 3300
	0    1    1    0   
$EndComp
$Comp
L R_Small R7
U 1 1 593D9B60
P 2050 3400
F 0 "R7" H 2080 3420 50  0000 L CNN
F 1 "100" V 2000 3400 50  0000 C CNN
F 2 "Resistors_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" H 2050 3400 50  0001 C CNN
F 3 "" H 2050 3400 50  0001 C CNN
	1    2050 3400
	0    1    1    0   
$EndComp
$Comp
L R_Small R8
U 1 1 593D9CA8
P 2050 3500
F 0 "R8" H 2080 3520 50  0000 L CNN
F 1 "100" V 2000 3500 50  0000 C CNN
F 2 "Resistors_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" H 2050 3500 50  0001 C CNN
F 3 "" H 2050 3500 50  0001 C CNN
	1    2050 3500
	0    1    1    0   
$EndComp
$Comp
L R_Small R9
U 1 1 593D9D0D
P 2050 3600
F 0 "R9" H 2080 3620 50  0000 L CNN
F 1 "100" V 2000 3600 50  0000 C CNN
F 2 "Resistors_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" H 2050 3600 50  0001 C CNN
F 3 "" H 2050 3600 50  0001 C CNN
	1    2050 3600
	0    1    1    0   
$EndComp
$Comp
L SW_Push SW2
U 1 1 593DBF81
P 2500 4400
F 0 "SW2" H 2550 4500 50  0000 L CNN
F 1 "SW_Push" H 2500 4340 50  0000 C CNN
F 2 "Buttons_Switches_THT:SW_PUSH_6mm" H 2500 4600 50  0001 C CNN
F 3 "" H 2500 4600 50  0001 C CNN
	1    2500 4400
	1    0    0    -1  
$EndComp
$Comp
L SW_Push SW4
U 1 1 593DC42F
P 3600 4400
F 0 "SW4" H 3650 4500 50  0000 L CNN
F 1 "SW_Push" H 3600 4340 50  0000 C CNN
F 2 "Buttons_Switches_THT:SW_PUSH_6mm" H 3600 4600 50  0001 C CNN
F 3 "" H 3600 4600 50  0001 C CNN
	1    3600 4400
	1    0    0    -1  
$EndComp
$Comp
L SW_Push SW3
U 1 1 593DC49F
P 3050 4400
F 0 "SW3" H 3100 4500 50  0000 L CNN
F 1 "SW_Push" H 3050 4340 50  0000 C CNN
F 2 "Buttons_Switches_THT:SW_PUSH_6mm" H 3050 4600 50  0001 C CNN
F 3 "" H 3050 4600 50  0001 C CNN
	1    3050 4400
	1    0    0    -1  
$EndComp
$Comp
L SW_Push SW5
U 1 1 593DC510
P 4150 4400
F 0 "SW5" H 4200 4500 50  0000 L CNN
F 1 "SW_Push" H 4150 4340 50  0000 C CNN
F 2 "Buttons_Switches_THT:SW_PUSH_6mm" H 4150 4600 50  0001 C CNN
F 3 "" H 4150 4600 50  0001 C CNN
	1    4150 4400
	1    0    0    -1  
$EndComp
$Comp
L CONN_01X02 J11
U 1 1 593DC794
P 4800 4150
F 0 "J11" H 4800 4300 50  0000 C CNN
F 1 "REED" H 4800 4000 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02_Pitch2.54mm" H 4800 4150 50  0001 C CNN
F 3 "" H 4800 4150 50  0001 C CNN
	1    4800 4150
	1    0    0    -1  
$EndComp
$Comp
L 7SEGM S1
U 1 1 593E03B1
P 4250 2800
F 0 "S1" H 4250 3450 50  0000 C CNN
F 1 "7SEGM" H 4250 2150 50  0000 C CNN
F 2 "Displays_7-Segment:7SegmentLED_LTS6760_LTS6780" H 4250 2800 50  0001 C CNN
F 3 "" H 4250 2800 50  0001 C CNN
	1    4250 2800
	1    0    0    -1  
$EndComp
Text GLabel 2250 3000 2    60   Input ~ 0
SEG7
Text GLabel 2250 3100 2    60   Input ~ 0
SEG6
Text GLabel 2250 3200 2    60   Input ~ 0
SEG5
Text GLabel 2250 3300 2    60   Input ~ 0
SEG4
Text GLabel 2250 3400 2    60   Input ~ 0
SEG3
Text GLabel 2250 3500 2    60   Input ~ 0
SEG2
Text GLabel 2250 3600 2    60   Input ~ 0
SEG1
Text GLabel 1850 2450 2    60   Input ~ 0
DIG1
Text GLabel 1850 2550 2    60   Input ~ 0
DIG2
Text GLabel 1850 2650 2    60   Input ~ 0
DIG3
Text GLabel 1850 2750 2    60   Input ~ 0
DIG4
$Comp
L CONN_01X06 J4
U 1 1 593E5BF8
P 1500 4150
F 0 "J4" H 1500 4500 50  0000 C CNN
F 1 "INPUTS2" V 1600 4150 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x06_Pitch2.54mm" H 1500 4150 50  0001 C CNN
F 3 "" H 1500 4150 50  0001 C CNN
	1    1500 4150
	-1   0    0    1   
$EndComp
Wire Wire Line
	2150 3000 2250 3000
Wire Wire Line
	1700 3900 4400 3900
Wire Wire Line
	1700 4000 3950 4000
Wire Wire Line
	1700 4100 3400 4100
Wire Wire Line
	1700 4200 2850 4200
Wire Wire Line
	2700 4400 2750 4400
Wire Wire Line
	3300 4400 3250 4400
Wire Wire Line
	3800 4400 3850 4400
Wire Wire Line
	1700 4300 1950 4300
Wire Wire Line
	1700 3000 1950 3000
Wire Wire Line
	1700 3100 1950 3100
Wire Wire Line
	1950 3200 1700 3200
Wire Wire Line
	1700 3300 1950 3300
Wire Wire Line
	1950 3400 1700 3400
Wire Wire Line
	1700 3500 1950 3500
Wire Wire Line
	1950 3600 1700 3600
Wire Wire Line
	2150 3100 2250 3100
Wire Wire Line
	2150 3200 2250 3200
Wire Wire Line
	2150 3300 2250 3300
Wire Wire Line
	2150 3400 2250 3400
Wire Wire Line
	2150 3500 2250 3500
Wire Wire Line
	2150 3600 2250 3600
Wire Wire Line
	1700 4400 1850 4400
Wire Wire Line
	1850 4400 1850 4550
Wire Wire Line
	3500 2500 3400 2500
Wire Wire Line
	3500 2600 3400 2600
Wire Wire Line
	3500 2700 3400 2700
Wire Wire Line
	3500 2800 3400 2800
Wire Wire Line
	3500 2900 3400 2900
Wire Wire Line
	3500 3000 3400 3000
Wire Wire Line
	3500 3100 3400 3100
Wire Wire Line
	3500 2400 3400 2400
Wire Wire Line
	3500 3300 3400 3300
Text GLabel 3400 2500 0    60   Input ~ 0
SEG1
Text GLabel 3400 2600 0    60   Input ~ 0
SEG2
Text GLabel 3400 2700 0    60   Input ~ 0
SEG3
Text GLabel 3400 2800 0    60   Input ~ 0
SEG4
Text GLabel 3400 2900 0    60   Input ~ 0
SEG5
Text GLabel 3400 3000 0    60   Input ~ 0
SEG6
Text GLabel 3400 3100 0    60   Input ~ 0
SEG7
$Comp
L 7SEGM S2
U 1 1 593E8A30
P 6100 2800
F 0 "S2" H 6100 3450 50  0000 C CNN
F 1 "7SEGM" H 6100 2150 50  0000 C CNN
F 2 "Displays_7-Segment:7SegmentLED_LTS6760_LTS6780" H 6100 2800 50  0001 C CNN
F 3 "" H 6100 2800 50  0001 C CNN
	1    6100 2800
	1    0    0    -1  
$EndComp
Wire Wire Line
	5350 2500 5250 2500
Wire Wire Line
	5350 2600 5250 2600
Wire Wire Line
	5350 2700 5250 2700
Wire Wire Line
	5350 2800 5250 2800
Wire Wire Line
	5350 2900 5250 2900
Wire Wire Line
	5350 3000 5250 3000
Wire Wire Line
	5350 3100 5250 3100
Wire Wire Line
	5350 2400 5250 2400
Wire Wire Line
	5350 3300 5250 3300
Text GLabel 5250 2500 0    60   Input ~ 0
SEG1
Text GLabel 5250 2600 0    60   Input ~ 0
SEG2
Text GLabel 5250 2700 0    60   Input ~ 0
SEG3
Text GLabel 5250 2800 0    60   Input ~ 0
SEG4
Text GLabel 5250 2900 0    60   Input ~ 0
SEG5
Text GLabel 5250 3000 0    60   Input ~ 0
SEG6
Text GLabel 5250 3100 0    60   Input ~ 0
SEG7
$Comp
L 7SEGM S3
U 1 1 593E8ABA
P 7950 2800
F 0 "S3" H 7950 3450 50  0000 C CNN
F 1 "7SEGM" H 7950 2150 50  0000 C CNN
F 2 "Displays_7-Segment:7SegmentLED_LTS6760_LTS6780" H 7950 2800 50  0001 C CNN
F 3 "" H 7950 2800 50  0001 C CNN
	1    7950 2800
	1    0    0    -1  
$EndComp
Wire Wire Line
	7200 2500 7100 2500
Wire Wire Line
	7200 2600 7100 2600
Wire Wire Line
	7200 2700 7100 2700
Wire Wire Line
	7200 2800 7100 2800
Wire Wire Line
	7200 2900 7100 2900
Wire Wire Line
	7200 3000 7100 3000
Wire Wire Line
	7200 3100 7100 3100
Wire Wire Line
	7200 2400 7100 2400
Wire Wire Line
	7200 3300 7100 3300
Text GLabel 7100 2500 0    60   Input ~ 0
SEG1
Text GLabel 7100 2600 0    60   Input ~ 0
SEG2
Text GLabel 7100 2700 0    60   Input ~ 0
SEG3
Text GLabel 7100 2800 0    60   Input ~ 0
SEG4
Text GLabel 7100 2900 0    60   Input ~ 0
SEG5
Text GLabel 7100 3000 0    60   Input ~ 0
SEG6
Text GLabel 7100 3100 0    60   Input ~ 0
SEG7
$Comp
L 7SEGM S4
U 1 1 593E8B2B
P 9800 2800
F 0 "S4" H 9800 3450 50  0000 C CNN
F 1 "7SEGM" H 9800 2150 50  0000 C CNN
F 2 "Displays_7-Segment:7SegmentLED_LTS6760_LTS6780" H 9800 2800 50  0001 C CNN
F 3 "" H 9800 2800 50  0001 C CNN
	1    9800 2800
	1    0    0    -1  
$EndComp
Wire Wire Line
	9050 2500 8950 2500
Wire Wire Line
	9050 2600 8950 2600
Wire Wire Line
	9050 2700 8950 2700
Wire Wire Line
	9050 2800 8950 2800
Wire Wire Line
	9050 2900 8950 2900
Wire Wire Line
	9050 3000 8950 3000
Wire Wire Line
	9050 3100 8950 3100
Wire Wire Line
	9050 2400 8950 2400
Wire Wire Line
	9050 3300 8950 3300
Text GLabel 8950 2500 0    60   Input ~ 0
SEG1
Text GLabel 8950 2600 0    60   Input ~ 0
SEG2
Text GLabel 8950 2700 0    60   Input ~ 0
SEG3
Text GLabel 8950 2800 0    60   Input ~ 0
SEG4
Text GLabel 8950 2900 0    60   Input ~ 0
SEG5
Text GLabel 8950 3000 0    60   Input ~ 0
SEG6
Text GLabel 8950 3100 0    60   Input ~ 0
SEG7
Text GLabel 3400 2400 0    60   Input ~ 0
DIG1
Text GLabel 5250 2400 0    60   Input ~ 0
DIG2
Text GLabel 7100 2400 0    60   Input ~ 0
DIG3
Text GLabel 8950 2400 0    60   Input ~ 0
DIG4
Wire Wire Line
	1700 2750 1850 2750
Wire Wire Line
	1700 2650 1850 2650
Wire Wire Line
	1700 2550 1850 2550
Wire Wire Line
	1700 2450 1850 2450
Wire Wire Line
	4400 4100 4600 4100
Wire Wire Line
	4400 4400 4350 4400
Wire Wire Line
	4400 3900 4400 4400
Wire Wire Line
	3850 4400 3850 3900
Connection ~ 3850 3900
Wire Wire Line
	3300 3900 3300 4400
Connection ~ 3300 3900
Wire Wire Line
	2750 4400 2750 3900
Connection ~ 2750 3900
Wire Wire Line
	1850 4550 4500 4550
Wire Wire Line
	4500 4550 4500 4200
Wire Wire Line
	4500 4200 4600 4200
Connection ~ 4400 4100
Wire Wire Line
	1950 4300 1950 4400
Wire Wire Line
	1950 4400 2300 4400
Wire Wire Line
	2850 4200 2850 4400
Wire Wire Line
	3400 4100 3400 4400
Wire Wire Line
	3950 4000 3950 4400
$EndSCHEMATC
