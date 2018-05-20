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
LIBS:mechanical
LIBS:switches
LIBS:esp8266_programmer-cache
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
L CONN_02X04 J2
U 1 1 5AE3FA6A
P 7750 3450
F 0 "J2" H 7750 3700 50  0000 C CNN
F 1 "CONN_02X04" H 7750 3200 50  0000 C CNN
F 2 "custom_footprints:Socket_Strip_Straight_2x04_Pitch2.54mm" H 7750 2250 50  0001 C CNN
F 3 "" H 7750 2250 50  0001 C CNN
	1    7750 3450
	-1   0    0    -1  
$EndComp
$Comp
L C C1
U 1 1 5AE3FBC2
P 4950 3550
F 0 "C1" H 4975 3650 50  0000 L CNN
F 1 "0.1uF" H 4975 3450 50  0000 L CNN
F 2 "Capacitors_THT:C_Disc_D5.0mm_W2.5mm_P2.50mm" H 4988 3400 50  0001 C CNN
F 3 "" H 4950 3550 50  0001 C CNN
	1    4950 3550
	1    0    0    -1  
$EndComp
$Comp
L CP C2
U 1 1 5AE3FC3B
P 6100 3550
F 0 "C2" H 6125 3650 50  0000 L CNN
F 1 "10uF" H 6125 3450 50  0000 L CNN
F 2 "Capacitors_THT:CP_Radial_D5.0mm_P2.50mm" H 6138 3400 50  0001 C CNN
F 3 "" H 6100 3550 50  0001 C CNN
	1    6100 3550
	1    0    0    -1  
$EndComp
$Comp
L CONN_01X04 J1
U 1 1 5AE3FCCA
P 3250 2950
F 0 "J1" H 3250 3200 50  0000 C CNN
F 1 "CONN_01X04" V 3350 2950 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Angled_1x04_Pitch2.54mm" H 3250 2950 50  0001 C CNN
F 3 "" H 3250 2950 50  0001 C CNN
	1    3250 2950
	-1   0    0    1   
$EndComp
Text GLabel 3750 3100 2    60   Output ~ 0
ESP_RX
Text GLabel 3750 2800 2    60   Input ~ 0
ESP_TX
Text GLabel 7400 3300 0    60   Output ~ 0
ESP_TX
Text GLabel 7400 3400 0    60   Input ~ 0
+3.3V
Text GLabel 7400 3500 0    60   Input ~ 0
RST
Text GLabel 8100 3600 2    60   Input ~ 0
ESP_RX
Text GLabel 7400 3600 0    60   Input ~ 0
+3.3V
Text GLabel 6250 3350 2    60   Output ~ 0
+3.3V
Text GLabel 8100 3500 2    60   Input ~ 0
GPIO_0
Text GLabel 4850 3350 0    60   Input ~ 0
5V
Text GLabel 3750 2900 2    60   Output ~ 0
5V
Text GLabel 7450 4200 2    60   Output ~ 0
RST
Text GLabel 7450 4650 2    60   Output ~ 0
GPIO_0
$Comp
L LD1117S33TR U1
U 1 1 5AE57DA5
P 5550 3400
F 0 "U1" H 5550 3650 50  0000 C CNN
F 1 "LD1117S33TR" H 5550 3600 50  0000 C CNN
F 2 "TO_SOT_Packages_THT:TO-220-3_Vertical" H 5550 3500 50  0001 C CNN
F 3 "" H 5550 3400 50  0001 C CNN
	1    5550 3400
	1    0    0    -1  
$EndComp
Text GLabel 3750 3000 2    60   BiDi ~ 0
GND
Text GLabel 7450 4850 2    60   BiDi ~ 0
GND
Text GLabel 6650 4200 0    60   BiDi ~ 0
GND
Text GLabel 8100 3300 2    60   BiDi ~ 0
GND
Wire Wire Line
	5950 3350 6250 3350
Wire Wire Line
	4850 3350 5150 3350
Wire Wire Line
	6100 3400 6100 3350
Wire Wire Line
	4950 3400 4950 3350
Wire Wire Line
	6800 4650 7450 4650
Connection ~ 6100 3350
Connection ~ 4950 3350
Connection ~ 5550 3750
Wire Wire Line
	6100 3750 6100 3700
Wire Wire Line
	4950 3750 6100 3750
Wire Wire Line
	4950 3700 4950 3750
Wire Wire Line
	5550 3650 5550 3850
Text GLabel 5550 3850 3    60   BiDi ~ 0
GND
$Comp
L CONN_01X02_MALE J3
U 1 1 5AEA7FC8
P 6500 4750
F 0 "J3" H 6500 4925 50  0000 C CNN
F 1 "PGMMODE" H 6500 4550 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02_Pitch2.54mm" H 6500 4850 50  0001 C CNN
F 3 "" H 6500 4850 50  0001 C CNN
	1    6500 4750
	1    0    0    -1  
$EndComp
Wire Wire Line
	6800 4850 7450 4850
Wire Wire Line
	3450 2800 3750 2800
Wire Wire Line
	3750 2900 3450 2900
Wire Wire Line
	3450 3000 3750 3000
Wire Wire Line
	3750 3100 3450 3100
$Comp
L SW_DIP_x01 SW2
U 1 1 5AF8DF7E
P 7050 4200
F 0 "SW2" H 7050 4350 50  0000 C CNN
F 1 "RESET" H 7050 4050 50  0000 C CNN
F 2 "Buttons_Switches_THT:SW_PUSH_6mm" H 7050 4200 50  0001 C CNN
F 3 "" H 7050 4200 50  0001 C CNN
	1    7050 4200
	1    0    0    -1  
$EndComp
Wire Wire Line
	7350 4200 7450 4200
Wire Wire Line
	6750 4200 6650 4200
Wire Wire Line
	7500 3300 7400 3300
Wire Wire Line
	7400 3400 7500 3400
Wire Wire Line
	7500 3500 7400 3500
Wire Wire Line
	7400 3600 7500 3600
Wire Wire Line
	8000 3600 8100 3600
Wire Wire Line
	8100 3500 8000 3500
Wire Wire Line
	8000 3300 8100 3300
$EndSCHEMATC
