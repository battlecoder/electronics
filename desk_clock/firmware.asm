; FIRMWARE.ASM. 40-Keys Matrix Keyboard
        list p=16f628A, R=DEC	; PIC 16f628A, Default radix = Decimal

        include   <p16f628a.inc>
        __config _CP_OFF & _PWRTE_ON & _WDT_OFF & _INTOSC_OSC_NOCLKOUT & _MCLRE_OFF & _BODEN_OFF & _LVP_OFF

;***** VARIABLE DEFINITIONS
	CBLOCK 0x20             ; Declare variable addresses starting at 0x20 
		w_temp
		status_temp
		var_i				; i and j are used by procedures.
		var_j				; Check that no procedure called by your code uses them while you do.
		var_k
		var_m
		var_n
		var_data			; To be used by communication subroutines
		var_buttons_pressed
		var_last_buttons
		var_time_hh1
		var_time_hh2
		var_time_mm1
		var_time_mm2
		var_time_date1
		var_time_date2
		var_time_month1
		var_time_month2
		var_time_year1
		var_time_year2
		var_temp_hi
		var_temp_low
		var_time_sec	; Only used to count whether a new second has elapsed
		var_tmp			; To be used by math/num macros
		var_tmp2		; To be used by math/num macros
		t0_counter		; A counter that will increase each time timer0 overflows
	ENDC
	

; PIN ASSINGMENTS -----------------------------------------------------
#define MAX7219_CLK			PORTA, 0
#define MAX7219_DIN			PORTA, 1
#define MAX7219_LOAD		PORTA, 2

#define I2C_SDA				PORTA, 4
#define I2C_SCL				PORTA, 3

#define DS1302_CLK			PORTB, 6
#define DS1302_IO			PORTB, 5
#define DS1302_CE			PORTB, 4

#define EXT_INT_INPUT		PORTB, 0		; HAS TO BE RB0/INT. Used by the optional wake-up-on-interrupt code.
#define BUTTON_INC			PORTB, 3
#define BUTTON_SET			PORTB, 7

;#define BUTTON_DEC_BIT		0
#define BUTTON_INC_BIT		0
#define BUTTON_SET_BIT		1

#define TMP75_ADDRESS		B'10010000' ; Address is upper 7 bits. Last bit is R/_W

; The DS1302 Only stores the last 2 digits of the year. We will have a fixed first and
; second digit. Update accordingly.
FIXED_YEAR_DIGIT0			EQU 2
FIXED_YEAR_DIGIT1			EQU 0


; TMP75 DEFINITIONS ---------------------------------------------------
TMP75_TEMP_REG				EQU		0
TMP75_CONFIG_REG			EQU		1
TMP75_T_LOW_REG				EQU		2
TMP75_T_HIGH_REG			EQU		3
TMP75_CFG_SHUTDOWN			EQU		B'00000001'
TMP75_CFG_THERMOSTAT		EQU		B'00000010'
TMP75_CFG_POLARITY			EQU		B'00000100'
TMP75_CFG_FAULTQ_F0			EQU		B'00001000'
TMP75_CFG_FAULTQ_F1			EQU		B'00010000'
TMP75_CFG_CNVRES_R0			EQU		B'00100000'
TMP75_CFG_CNVRES_R1			EQU		B'01000000'
TMP75_CFG_ONESHOT			EQU		B'10000000'

; UTILITY MACROS ------------------------------------------------------
; ---------------------------------------------------------------------
;  I2C Macros 
; ---------------------------------------------------------------------
_i2c_req_read macro addr
	call			i2c_start
	movlw			addr
	iorlw			1			; Enable the read bit
	call			i2c_tx
	endm
	
_i2c_req_write macro addr
	call			i2c_start
	movlw			addr
	call			i2c_tx
	endm

_i2c_sendf macro file
	movf			file, W
	call			i2c_tx
	endm
	
_i2c_sendk macro const
	movlw			const
	call			i2c_tx
	endm

; ---------------------------------------------------------------------
;  Misc Macros 
; ---------------------------------------------------------------------
; Very basic implementation of division. Computes W divided by const.
; Modulo is later stored in var_tmp
_div_k	macro const
	LOCAL @@divConstLoop
	LOCAL @@divConstReturn
	movwf			var_tmp
	clrf			var_tmp2
	movlw			const
@@divConstLoop
	subwf			var_tmp, F
	btfss			STATUS, C
	goto			@@divConstReturn
	incf			var_tmp2, F
	goto			@@divConstLoop
@@divConstReturn
	movlw			10
	addwf			var_tmp, F
	movf			var_tmp2, W
	endm

; ---------------------------------------------------------------------
; DS1302 Macros 
; ---------------------------------------------------------------------
_ds1302_read macro const_addr
	movlw			const_addr
	call			ds1302_read
	endm

_ds1302_ww macro const_addr
	movwf			var_data
	movlw			const_addr
	call			ds1302_write
	endm

_ds1302_wf macro const_addr, file_val
	movf			file_val, W
	_ds1302_ww		const_addr
	endm

_ds1302_wk macro const_addr, const_val
	movlw			const_val
	_ds1302_ww		const_addr
	endm

; ---------------------------------------------------------------------
; MAX7219 Macros 
; ---------------------------------------------------------------------
; Writes the value of W to the MAX7219 controller at a given address
_max7219_ww macro const_addr 
	movwf			var_data
	movlw			const_addr
	call			max7219_writeCmd
	endm

; Writes the value of W to the MAX7219 controller, at address FILE
_max7219_wwf macro file
	movwf			var_data
	movf			file, W
	call			max7219_writeCmd
	endm

; Writes a constant value to the MAX7219 controller
_max7219_wk macro const_addr, const_val
	movlw			const_val
	movwf			var_data
	movlw			const_addr
	call			max7219_writeCmd
	endm

; ---------------------------------------------------------------------
; Clock Operation Macros 
; ---------------------------------------------------------------------
; Creates a DS1302 8 bit representation of a 2-digit time number from the
; individual digits
_ds1302_setdigs macro decs, units, output_reg
	movlw			B'00001111'
	andwf			units, W
	movwf			output_reg
	swapf			decs, W
	andlw			B'11110000'
	iorwf			output_reg, F
	endm

; Extracts digits from a single 2-digit value (in W) obtained from the DS1302
; module.
_ds1302_getdigs macro output_reg_decs, output_reg_units
	movwf			output_reg_units
	andlw			B'11110000'
	movwf			output_reg_decs
	swapf			output_reg_decs, F
	movlw			B'00001111'
	andwf			output_reg_units, F
	endm

; Provides a nice way of calling the set_time_digit function without having to manually load
; values for the function call. Also facilitates building the whole thing into a more complex
; macro for full in-lining, if desired (It was originally written as a macro, in fact).
_set_time_digit macro time_variable, const_digit, const_min, const_max
	movlw			const_min
	movwf			var_m
	movlw			const_max
	movwf			var_n
	movlw			const_digit
	movwf			var_k
	movf			time_variable, W
	movwf			var_tmp
	call			set_time_digit
	movf			var_tmp, W
	movwf			time_variable
endm

;###############################################################################
;##                                                                           ##
;##                                   C O D E                                 ##
;##                                                                           ##
;###############################################################################
	ORG 	    	0x000				; processor reset vector
	goto			main

	ORG				0x004				; interrupt vector location

; ---------------------------------------------------------------------
; Interrupt Handler
; ---------------------------------------------------------------------
	; If we are not in page 0, we want to go to page 0, BUT, we also want to make sure we later
	; restore the page selector to where it was.
	btfsc			STATUS, RP0
	goto			isrSaveFromBank1

	movwf   		w_temp				; save off current W register contents
	movf			STATUS, W			; move status register into W register
	movwf			status_temp			; save off contents of STATUS register
	goto			isrProc

isrSaveFromBank1
	movwf   		w_temp				; save off current W register contents (bank 1 copy)
	movf			STATUS, W			; move status register into W register
	bcf				STATUS, RP0			; Bank 0
	movwf			status_temp			; save off contents of STATUS register
	bsf				status_temp, RP0	; Set the RP0 bit. We know we were in the Page1

isrProc
	; ISR -------------------------------------------------------------
	; Disable interrupts
	bcf				INTCON, GIE

	; Check the interrupt source
	btfsc			INTCON, T0IF
	goto			timer0ISR
	btfss			INTCON, INTF
	goto			endOfInterrupt

rbISR
	; Do nothing except clearing the flag
	bcf				INTCON, INTF
	goto			endOfInterrupt

timer0ISR
	incf			t0_counter, F
	bcf				INTCON, T0IF
	
endOfInterrupt
	; ----------------------------------------------------
	movf			status_temp, W		; retrieve copy of STATUS register
	movwf			STATUS				; restore pre-isr STATUS register contents
	swapf			w_temp, F
	swapf			w_temp, W			; restore pre-isr W register contents

	; Re-enable interrupts
	bsf				INTCON, GIE
	retfie								; return from interrupt

; ---------------------------------------------------------------------
; Main
; ---------------------------------------------------------------------
main
	; -------- SETUP --------------------------------------------------
	clrf			PORTA
	clrf			PORTB

	; Interrupts ----------
	movlw			b'0000000'	; Disable interrupts
	movwf			INTCON
	
	; Turn Comparators off and enable RA pins for I/O functions
	movlw			0x07
	movwf			CMCON

	; Switch to bank 1
	bsf				STATUS, RP0

	;OPTION_REG
	; 0: PORTB Pull-ups enabled
	; 1: Interrupt on raising edge (Irrelevant)
	; 0: TMR0 CLK Source: Internal cycle clock
	; 0: TMR0 R4/T0CKI/CMP2 Source Edge Select low-to-high (irrelevant. External clock source not selected) 
	; 0: Prescaler is assigned to Timer0
	; 0: Prescaler value
	; 1:	1: 16 (for TMR0)
	; 1:
	movlw			b'01000011'
	movwf			OPTION_REG


	; Port Directions
	clrf			TRISA		; All PORTA is set as output
	clrf			TRISB		; Same with PORTB

	; Set the EXT_INT interrupt pin as input together with the other buttons
	bsf				EXT_INT_INPUT
	bsf				BUTTON_INC
	bsf				BUTTON_SET

	; Set the speed to 48 Khz
	bcf				PCON, OSCF

	; Switch to bank 0
	bcf				STATUS, RP0


preInit
	; Initialize I2C code before we mess with the ports
	call			i2c_init

	; TMP75 INIT ----------------------------------------------------
	; Set the temperature sensor
	_i2c_req_write	TMP75_ADDRESS
	_i2c_sendk		TMP75_CONFIG_REG
	_i2c_sendk		0				;Everything Off or default (Resolution is 9 bits when set to 00)
	call			i2c_stop

	; DS1302 INIT --------------------------------------------------	
	_ds1302_wk		DS1302_TRICKLECHARGESELECT, 0	; Disable trickle charging

	; Clear t0 counter and restart countdown
	clrf			t0_counter
	clrf			TMR0 

	; Enable TMR0 Overflow interrupt (T0IE) and RBINT
	bsf				INTCON, GIE
	bsf				INTCON, T0IE
	bsf				INTCON, INTE

;################################################################
;##                                                            ##
;##                      M A I N    L O O P                    ##
;##                                                            ##
;################################################################
displayLoop
	; After several t0_counter cycles, go to sleep
	; CURRENTLY COMMENTED CODE! ----------------
	; btfsc			t0_counter, 6
	; goto 			goToSleep
	
	; Somehow the MAX7219 IC isn't always ready to be initialized when the processor starts, so instead of
	; setting its parameters only at the beginning of our code (preInit) we will set the options every
	; display update.

	; MAX7219 INIT --------------------------------------------------
	; Disable the decode mode in the MAX7219 driver for all digits, so we can set the segments ourselves.
	; Decode mode works just fine for digits, but it lacks the C/F characters we would need for temperature
	; display.
	_max7219_wk		MAX7219_ADDR_DECODEMODE, MAX7219_DM_DECODE_NONE
	; Set intensity
	_max7219_wk		MAX7219_ADDR_INTENSITY, 4
	; Set scan limit to 4
	_max7219_wk		MAX7219_ADDR_SCANLIMIT, 4
	; Disable shutdown mode
	_max7219_wk		MAX7219_ADDR_SHUTDOWN, MAX7219_SHUTDOWN_DISABLED
	; Disable test mode
	_max7219_wk		MAX7219_ADDR_DISPLAYTEST, 0

	; Show time for a couple of t0_counter cycles, then show temperature.
	btfss			t0_counter, 5
	goto			displayTime

	btfss			t0_counter, 4
	goto			displayDate


displayTemperature
	; Select the register so we read temperature from now on
	_i2c_req_write	TMP75_ADDRESS
	_i2c_sendk		TMP75_TEMP_REG

	; Restart communication and read 2 bytes
	_i2c_req_read	TMP75_ADDRESS
	call			i2c_rx
	movwf			var_temp_hi
	call			i2c_rx
	movwf			var_temp_low
	call			i2c_stop


	; Show temperature
	btfss			var_temp_hi, 7
	goto			temperatureIsPositive
	
	
temperatureIsNegative
	; 1st digit: Negative sign
	movlw			_7SEG_MINUS
	call			_7seg_table
	_max7219_ww		MAX7219_ADDR_DIGIT0

	; Get rid of the sign and get two's complement value if needed
	comf			var_temp_hi, F
	incf			var_temp_hi, F

	; 2nd digit: Integer part of the temperature (tmp_hi), divided by 10
	movf			var_temp_hi, W
	_div_k			10
	call			_7seg_table
	_max7219_ww		MAX7219_ADDR_DIGIT1

	; 3rd digit: Reminder of the division (stored in var_tmp)
	movf			var_tmp, W
	call			_7seg_table
	_max7219_ww		MAX7219_ADDR_DIGIT2
	
	; 4th digit: °
	movlw			_7SEG_DEG
	call			_7seg_table
	_max7219_ww		MAX7219_ADDR_DIGIT3
	
	; DONE
	goto			displayRefreshDone

temperatureIsPositive
	; 1st digit: Integer part of the temperature (tmp_hi), divided by 10
	movf			var_temp_hi, W
	_div_k			10
	call			_7seg_table
	_max7219_ww		MAX7219_ADDR_DIGIT0

	; 2nd digit: Reminder of the division (stored in var_tmp)
	movf			var_tmp, W
	call			_7seg_table
	_max7219_ww		MAX7219_ADDR_DIGIT1
	
	; 3rd digit: °
	movlw			_7SEG_DEG
	call			_7seg_table
	_max7219_ww		MAX7219_ADDR_DIGIT2

	; 4th digit: C
	movlw			_7SEG_C
	call			_7seg_table
	_max7219_ww		MAX7219_ADDR_DIGIT3
	goto			displayRefreshDone


displayDate
	; Half of the assigned time will be used in displaying the year, the other half displaying month and date
	btfss			t0_counter, 3
	goto			displayYear

	; Only read date every other step of the counter
	btfss			t0_counter, 0
	call			read_date
	call			display_date
	goto			displayRefreshDone

displayYear
	; Only read year every other step of the counter
	btfss			t0_counter, 0
	call			read_year
	call			display_year
	goto			displayRefreshDone


displayTime
	; Only read time every other step of the counter
	btfss			t0_counter, 0
	call			read_time
	
	movlw			0
	; Is it an even ammount of seconds? If it is we want to turn the colon sign on,
	; which we will do by setting a mask that will be applied to the proper digits
	btfss			var_time_sec, 0
	movlw			B'10000000'
	; var_k will be our "mask" that will be OR-ed to the 2 middle digits in display_time,
	; enabling the decimal points of those digits, which make the colon sign of the clock
	; turn on every other second.
	movwf			var_k			
	call			display_time

displayRefreshDone
	call			read_buttons

	; Check whether the "SET" button has been pressed
	btfsc			var_buttons_pressed, BUTTON_SET_BIT
	goto			adjustTimeSub

	; Go back to displaying whatever we should be displaying
	goto			displayLoop
	
adjustTimeSub
	; ----- ADJUST TIME ------------------------
	; Show current time in display
	call			read_time
	call			display_time

	_set_time_digit	var_time_hh1, MAX7219_ADDR_DIGIT0, 0, 2

	; Max range for digit HH2 depends if digit HH1 > 1
	btfss			var_time_hh1, 1
	goto			adjustHH2Max9
	; Limit it to 3 (So the max hour you can set is basically 23)
	_set_time_digit	var_time_hh2, MAX7219_ADDR_DIGIT1, 0, 3
	goto			adjustTimeHourDone

adjustHH2Max9
	_set_time_digit	var_time_hh2, MAX7219_ADDR_DIGIT1, 0, 9

adjustTimeHourDone
	_set_time_digit	var_time_mm1, MAX7219_ADDR_DIGIT2, 0, 5
	_set_time_digit	var_time_mm2, MAX7219_ADDR_DIGIT3, 0, 9

	; Save current time to clock
	_ds1302_wk		DS1302_CONTROLREG, 0	; bit 7: Write Protect
	_ds1302_wk		DS1302_SECONDS,	0		; Reset to 00 seconds
	_ds1302_setdigs	var_time_hh1, var_time_hh2, var_i
	_ds1302_wf		DS1302_HOURS,	var_i
	_ds1302_setdigs	var_time_mm1, var_time_mm2, var_i
	_ds1302_wf		DS1302_MINUTES,	var_i

	; ----- ADJUST YEAR ------------------------
	call			read_year
	call			display_year
	_set_time_digit	var_time_year1, MAX7219_ADDR_DIGIT2, 0, 9
	_set_time_digit	var_time_year2, MAX7219_ADDR_DIGIT3, 0, 9
	; Save current year to clock
	_ds1302_wk		DS1302_CONTROLREG, 0	; bit 7: Write Protect
	_ds1302_setdigs	var_time_year1, var_time_year2, var_i
	_ds1302_wf		DS1302_YEAR, var_i

	; ----- ADJUST DATE ------------------------
	; Show current date in display
	call			read_date
	call			display_date

	_set_time_digit	var_time_month1, MAX7219_ADDR_DIGIT0, 0, 1

	; Max range for digit MONTH2 depends if digit MONTH1 >= 1
	btfss			var_time_month1, 0
	goto			adjustMonth2Max9
	; Limit it to 2 (So the max month you can set is 12)
	_set_time_digit	var_time_month2, MAX7219_ADDR_DIGIT1, 0, 2
	goto			adjustTimeMonthDone

adjustMonth2Max9
	_set_time_digit	var_time_month2, MAX7219_ADDR_DIGIT1, 1, 9

adjustTimeMonthDone
	_set_time_digit	var_time_date1, MAX7219_ADDR_DIGIT2, 0, 3

	; Max range for digit DATE2 depends if digit DATE1 > 2
	movf			var_time_date1, W
	sublw			2
	btfsc			STATUS, C
	goto			adjustDate2Max9

	; Limit it to 1 (So the max date you can set is 31)
	_set_time_digit	var_time_date2, MAX7219_ADDR_DIGIT3, 0, 1
	goto			adjustTimeDateDone

adjustDate2Max9
	; Special case here: If the first digit was 1 or 2 then a zero is a totally valid
	; second digit. If it was a 0, though, we need to make sure the second digit is at
	; least a 1.
	movf			var_time_date1
	btfsc			STATUS, Z
	goto			adjustDate2From1To9

adjustDate2From0To9	
	_set_time_digit	var_time_date2, MAX7219_ADDR_DIGIT3, 0, 9
	goto			adjustTimeDateDone

adjustDate2From1To9
	_set_time_digit	var_time_date2, MAX7219_ADDR_DIGIT3, 1, 9

adjustTimeDateDone
	; Save current date to clock
	_ds1302_wk		DS1302_CONTROLREG, 0	; bit 7: Write Protect
	_ds1302_setdigs	var_time_month1, var_time_month2, var_i
	_ds1302_wf		DS1302_MONTH, var_i
	_ds1302_setdigs	var_time_date1, var_time_date2, var_i
	_ds1302_wf		DS1302_DATE,	var_i
	; Go back to displaying time
	goto			displayLoop

; ---------------------------------------------------------------------
; Sleep Management code
; ---------------------------------------------------------------------
; CURRENTLY COMMENTED. CAN BE EVENTUALLY USED TO WAKE UP THE 
; CLOCK WHEN THERE'S A CHANGE IN THE EXT_INT INPUT!
goToSleep
	; Turn off the MAX7219
	_max7219_wk		MAX7219_ADDR_SHUTDOWN, MAX7219_SHUTDOWN_ENABLED

	; Turn off the TMP75
	_i2c_req_write	TMP75_ADDRESS
	_i2c_sendk		TMP75_CONFIG_REG
	_i2c_sendk		TMP75_CFG_SHUTDOWN
	call			i2c_stop
	sleep
	nop
	nop
	; Device will wake up at this point. Go back to pre initialization code
	goto			preInit

;###############################################################################
;##                                                                           ##
;##                     M I S C   F U N C T I O N S                           ##
;##                                                                           ##
;###############################################################################
; ---------------------------------------------------------------------
; set_time_digit
; ---------------------------------------------------------------------
; Manipulates the value of var_tmp, so it's adjusted by the user pressing the phyiscal buttons,
; The value will be show in digit var_k of the display, and will be kept between the values of
; var_m and var_n.
set_time_digit
_set_time_digit_start
	call			read_buttons
	; If our timer0 counter is even, don't show the digit
	btfss			t0_counter, 0
	goto			_set_time_digit_blank
	; Otherwise show the current value and skip the blanking
	movf			var_tmp, W
	call			_7seg_table
	_max7219_wwf	var_k
	goto			_set_time_digit_readbuttons

_set_time_digit_blank
	movlw			0
	_max7219_wwf	var_k

_set_time_digit_readbuttons
	; End the process if the SET button is pressed
	btfsc			var_buttons_pressed, BUTTON_SET_BIT
	goto			_set_time_digit_end

	; INC button pressed?
	btfsc			var_buttons_pressed, BUTTON_INC_BIT
	incf			var_tmp, F

	; Check allowed values for this digit
	movf			var_n, W
	addlw			1
	subwf			var_tmp, W
	btfss			STATUS, C
	goto			_set_time_digit_value_ok
	; Value past max? Set to min val
	movf			var_m, W
	movwf			var_tmp

_set_time_digit_value_ok
	; Keep going with this digit
	goto			_set_time_digit_start

_set_time_digit_end
	; Show the value we set before moving to the next digit
	movf			var_tmp, W
	call			_7seg_table
	_max7219_wwf	var_k
	return

; ---------------------------------------------------------------------
; read_time
; ---------------------------------------------------------------------
read_time
	; The DS1302 module already splits numbers in decimal digits
	; so we need to extract them (b6-b4: "tenths", b3-b0: Units)
	_ds1302_read	DS1302_MINUTES
	_ds1302_getdigs	var_time_mm1, var_time_mm2

	_ds1302_read	DS1302_HOURS
	_ds1302_getdigs	var_time_hh1, var_time_hh2
	
	_ds1302_read	DS1302_SECONDS
	movwf			var_time_sec
	return

; ---------------------------------------------------------------------
; read_date
; ---------------------------------------------------------------------
read_date
	_ds1302_read	DS1302_MONTH
	_ds1302_getdigs	var_time_month1, var_time_month2

	_ds1302_read	DS1302_DATE
	_ds1302_getdigs	var_time_date1, var_time_date2
	return
	
; ---------------------------------------------------------------------
; read_year
; ---------------------------------------------------------------------
read_year
	_ds1302_read	DS1302_YEAR
	_ds1302_getdigs	var_time_year1, var_time_year2
	return

; ---------------------------------------------------------------------
; display_date
; ---------------------------------------------------------------------
display_date
	; Show current value of date variables in all 4 digits
	movf			var_time_month1, W
	call			_7seg_table
	_max7219_ww		MAX7219_ADDR_DIGIT0
	
	movf			var_time_month2, W
	call			_7seg_table
	_max7219_ww		MAX7219_ADDR_DIGIT1
	
	movf			var_time_date1, W
	call			_7seg_table
	_max7219_ww		MAX7219_ADDR_DIGIT2
	
	movf			var_time_date2, W
	call			_7seg_table
	_max7219_ww		MAX7219_ADDR_DIGIT3
	return
	
; ---------------------------------------------------------------------
; display_year
; ---------------------------------------------------------------------
display_year
	movlw			FIXED_YEAR_DIGIT0
	call			_7seg_table
	_max7219_ww		MAX7219_ADDR_DIGIT0


	movlw			FIXED_YEAR_DIGIT1
	call			_7seg_table
	_max7219_ww		MAX7219_ADDR_DIGIT1

	movf			var_time_year1, W
	call			_7seg_table
	_max7219_ww		MAX7219_ADDR_DIGIT2
	
	movf			var_time_year2, W
	call			_7seg_table
	_max7219_ww		MAX7219_ADDR_DIGIT3	
	return


; ---------------------------------------------------------------------
; display_time
; ---------------------------------------------------------------------
display_time
; Show current value of time variables in all 4 digits
	movf			var_time_hh1, W
	call			_7seg_table
	_max7219_ww		MAX7219_ADDR_DIGIT0
	
	movf			var_time_hh2, W
	call			_7seg_table
	_max7219_ww		MAX7219_ADDR_DIGIT1
	
	movf			var_time_mm1, W
	call			_7seg_table
	iorwf			var_k, W
	_max7219_ww		MAX7219_ADDR_DIGIT2
	
	movf			var_time_mm2, W
	call			_7seg_table
	iorwf			var_k, W
	_max7219_ww		MAX7219_ADDR_DIGIT3
	return


; ---------------------------------------------------------------------
; read_buttons
; ---------------------------------------------------------------------
read_buttons
	clrf			var_buttons_pressed
	clrf			var_i

	btfss			BUTTON_SET
	bsf				var_i, BUTTON_SET_BIT
	btfss			BUTTON_INC
	bsf				var_i, BUTTON_INC_BIT

	; Copy to buttons_pressed
	movf			var_i, W
	movwf			var_buttons_pressed

	; Clear the bits if the buttons were already pressed before
	btfsc			var_last_buttons, BUTTON_SET_BIT
	bcf				var_buttons_pressed, BUTTON_SET_BIT
	btfsc			var_last_buttons, BUTTON_INC_BIT
	bcf				var_buttons_pressed, BUTTON_INC_BIT
	
	; Copy current status to backup
	movf			var_i, W
	movwf			var_last_buttons
	return

;###############################################################################
;##                                                                           ##
;##                            I 2 C   D R I V E R                            ##
;##                                                                           ##
;##  Basic I2C driver. Cannot deal with lost arbitration.                     ##
;###############################################################################
; ---------------------------------------------------------------------
; Internal I2C Macros fro inlining
; ---------------------------------------------------------------------
; Remember that I2C lines need a pull up resistor because are open drain!
_i2c_sda_high macro
	; To drive the line high, we will set the pin as input
	bsf				STATUS, RP0
	bsf				I2C_SDA
	bcf				STATUS, RP0
	endm
	
_i2c_sda_low macro
	; Setting the pin as output and writing a 0 is our way of setting the line low
	bsf				STATUS, RP0
	bcf				I2C_SDA
	bcf				STATUS, RP0
	bcf				I2C_SDA
	endm

_i2c_scl_high macro
	bsf				STATUS, RP0
	bsf				I2C_SCL
	bcf				STATUS, RP0
	; Wait for the clock to actually go high
	btfss			I2C_SCL
	goto			$-1
	endm
	
_i2c_scl_low macro
	bsf				STATUS, RP0
	bcf				I2C_SCL
	bcf				STATUS, RP0
	bcf				I2C_SCL
	endm

; ---------------------------------------------------------------------
; i2c_delay
; ---------------------------------------------------------------------
i2c_delay
	nop
	nop
	nop
	nop
	nop
	return


; ---------------------------------------------------------------------
; i2c_init
; ---------------------------------------------------------------------
i2c_init
	_i2c_scl_high
	_i2c_sda_high
	return


; ---------------------------------------------------------------------
; i2c_start
; ---------------------------------------------------------------------
i2c_start
	_i2c_sda_high
	call			i2c_delay
	_i2c_scl_high
	call			i2c_delay
	; Clear Data line while clock is high. Then clock goes low too
	_i2c_sda_low
	call			i2c_delay
	_i2c_scl_low
	call			i2c_delay
	return


; ---------------------------------------------------------------------
; i2c_stop
; ---------------------------------------------------------------------
i2c_stop
	_i2c_sda_low
	call			i2c_delay
	; Set Data line while clock is high.
	_i2c_scl_high
	call			i2c_delay
	_i2c_sda_high
	call			i2c_delay
	return


; ---------------------------------------------------------------------
; i2c_tx
; ---------------------------------------------------------------------
; Put byte W in the I2C bus. On return W will contain the ACK bit.
i2c_tx
	movwf			var_i	; Will temporarily hold the data to be sent
	movlw			8
	movwf			var_j	; bit counter

_i2c_tx_bit
	; Set the bit
	btfsc			var_i, 7
	goto			_i2c_tx_bit_1
_i2c_tx_bit_0
	_i2c_sda_low
	goto			_i2c_tx_bit_end
_i2c_tx_bit_1
	_i2c_sda_high

_i2c_tx_bit_end
	; Clock
	_i2c_scl_high
	call			i2c_delay
	_i2c_scl_low
	call			i2c_delay

	; Shift value, decrease counter and loop
	rlf				var_i, F
	decfsz			var_j, F
	goto			_i2c_tx_bit
	
	; Release the data line
	_i2c_sda_high
	call			i2c_delay
	; Ack clock
	_i2c_scl_high
	call			i2c_delay
	_i2c_scl_low
	call			i2c_delay
	; Now the ACK bit should be in the bus. Move it to W
	movlw			0
	btfsc			I2C_SDA
	movlw			1
	return


; ---------------------------------------------------------------------
; i2c_rx
; ---------------------------------------------------------------------
; Return in W a byte read from the I2C bus
i2c_rx
	clrf			var_i	; Will temporarily hold the received data
	movlw			8
	movwf			var_j	; bit counter

	; Make sure the data line is released
	_i2c_sda_high
_i2c_rx_bit
	bcf				STATUS, C
	rlf				var_i, F
	; Clock transition
	_i2c_scl_high
	call			i2c_delay
	; Read data
	btfsc			I2C_SDA
	bsf				var_i, 0
	_i2c_scl_low
	call			i2c_delay
	; Decrease counter and loop
	decfsz			var_j, F
	goto			_i2c_rx_bit

	; Master ACK + Clock
	_i2c_sda_low
	_i2c_scl_high
	call			i2c_delay
	_i2c_scl_low
	_i2c_sda_high
	call			i2c_delay

	movf			var_i, W
	return


;###############################################################################
;##                                                                           ##
;##                        D S 1 3 1 2   D R I V E R                          ##
;##                                                                           ##
;###############################################################################
DS1302_SECONDS				EQU		B'000000'
DS1302_MINUTES				EQU		B'000001'
DS1302_HOURS				EQU		B'000010'
DS1302_DATE					EQU		B'000011'
DS1302_MONTH				EQU		B'000100'
DS1302_DAY					EQU		B'000101'
DS1302_YEAR					EQU		B'000110'
DS1302_CONTROLREG			EQU		B'000111'
DS1302_TRICKLECHARGESELECT	EQU		B'001000'
DS1302_CLOCK_BURST			EQU		B'011111'


DS1302_RAMSTART				EQU		B'100000'
DS1302_RAMEND				EQU		B'111111'
DS1302_RAM_BURST			EQU		H'111111'

; ---------------------------------------------------------------------
; _ds1302_write_byte
; ---------------------------------------------------------------------
; Make sure the IO Pin is configured as output before calling this function!
; Sends W to the DS1302 IC
_ds1302_write_byte
	; Set the IO PIN as OUTPUT
	bsf				STATUS, RP0
	bcf				DS1302_IO
	bcf				STATUS, RP0
	; Setup
	movwf			var_i
	movlw			8
	movwf			var_j

_ds1302_write_bit
	; Set the bit
	btfss			var_i, 0
	bcf				DS1302_IO
	btfsc			var_i, 0
	bsf				DS1302_IO
	nop
	nop
	nop
	; Clock pulse
	bsf				DS1302_CLK
	nop
	nop
	nop
	bcf				DS1302_CLK
	; Shift value, decrease counter and loop
	rrf				var_i, F
	decfsz			var_j, F
	goto			_ds1302_write_bit

	return

; ---------------------------------------------------------------------
; _ds1302_read_byte
; ---------------------------------------------------------------------
_ds1302_read_byte
	; Set the IO PIN as INPUT
	bsf				STATUS, RP0
	bsf				DS1302_IO
	bcf				STATUS, RP0
	; Setup
	clrf			var_i
	movlw			8
	movwf			var_j

_ds1302_read_bit
	; Shift value before reading
	bcf				STATUS, C
	rrf				var_i, F

	; Read the bit
	btfsc			DS1302_IO
	bsf				var_i, 7
	; Clock pulse
	bsf				DS1302_CLK
	nop
	nop
	nop
	bcf				DS1302_CLK
	nop
	nop
	nop
	; Decrease counter and loop
	decfsz			var_j, F
	goto			_ds1302_read_bit
	
	movf			var_i, W
	return
	
; ---------------------------------------------------------------------
; ds1302_write
; ---------------------------------------------------------------------
; Sends value stored in var_data to the register at address W in the DS1302 IC
; Address is a 5 bit value though.
ds1302_write
; Command data format (MSb First):
;   1	RC	A4	A3	A2	A1	A0	RW
;
;		RC: RAM/CLK SELECTOR. 		1: RAM		0: CLK
;		RW: READ/WRITE SELECTOR.	1: READ		0: WRITE
;
; DATA AND COMMANDS ARE RECEIVED LSb FIRST!!
;
	bsf				DS1302_CE
	; Prepare address command
	movwf			var_i
	rlf				var_i, F
	bsf				var_i, 7	;Make sure the MSb of the address cmd is always 1
	bcf				var_i, 0	;Make sure the LSb of the address cmd is set to 0 (WRITE)
	movf			var_i, W
	call			_ds1302_write_byte

	movf			var_data, W
	call			_ds1302_write_byte
	bcf				DS1302_CE
	return

; ---------------------------------------------------------------------
; ds1302_read
; ---------------------------------------------------------------------
; Reads the register at address W from the DS1302 IC
ds1302_read
	; NOTE: Check ds1302_write for details on the command format)
	bsf				DS1302_CE
	; Prepare address command
	movwf			var_i
	rlf				var_i, F
	bsf				var_i, 7	;Make sure the MSb of the address cmd is always 1
	bsf				var_i, 0	;Make sure the LSb of the address cmd is set to 1 (READ)
	movf			var_i, W
	call			_ds1302_write_byte

	call			_ds1302_read_byte
	bcf				DS1302_CE
	return

;###############################################################################
;##                                                                           ##
;##                       M A X 7 2 1 9   D R I V E R                         ##
;##                                                                           ##
;###############################################################################
MAX7219_ADDR_DIGIT0			EQU		H'01'
MAX7219_ADDR_DIGIT1			EQU		H'02'
MAX7219_ADDR_DIGIT2			EQU		H'03'
MAX7219_ADDR_DIGIT3			EQU		H'04'
MAX7219_ADDR_DIGIT4			EQU		H'05'
MAX7219_ADDR_DIGIT5			EQU		H'06'
MAX7219_ADDR_DIGIT6			EQU		H'07'
MAX7219_ADDR_DIGIT7			EQU		H'08'
MAX7219_ADDR_DECODEMODE		EQU		H'09'	; Decode mode. See MAX7219_DM_XXXX constants
MAX7219_ADDR_INTENSITY		EQU		H'0A'
MAX7219_ADDR_SCANLIMIT		EQU		H'0B'
MAX7219_ADDR_SHUTDOWN		EQU		H'0C'	; Shutdown data should follow. see MAX7219_SHUTDOWN_XXXX Constants
MAX7219_ADDR_DISPLAYTEST	EQU		H'0F'

MAX7219_DM_DECODE_NONE		EQU		H'00'
MAX7219_DM_DIGIT0_ONLY		EQU		H'01'
MAX7219_DM_DIGIT0_TO_3		EQU		H'0F'
MAX7219_DM_DECODE_ALL		EQU		H'FF'

MAX7219_SHUTDOWN_ENABLED	EQU		H'00'
MAX7219_SHUTDOWN_DISABLED	EQU		H'01'


; ---------------------------------------------------------------------
; max7219_writebyte
; ---------------------------------------------------------------------
; Writes byte W to the MAX7219 driver. Please note that commands are 16 bits so
; this should normally be called twice. 
max7219_writebyte
	; Temporarily store the value to write in var_i, and a loop counter in var_j
	movwf			var_i
	movlw			8
	movwf			var_j
	
max7219_writebit
	; Set the DATA line to 1 or 0 depending on the MSb of the data to write
	btfsc			var_i, 7
	bsf				MAX7219_DIN
	btfss			var_i, 7
	bcf				MAX7219_DIN
	; Raise the clock for a couple of cycles
	bsf				MAX7219_CLK
	nop
	nop
	nop
	nop
	bcf				MAX7219_CLK
	; Shift the data
	rlf				var_i, F
	; Decrease counter and loop
	decfsz			var_j, F
	goto			max7219_writebit
	return


; ---------------------------------------------------------------------
; max7219_writeCmd
; ---------------------------------------------------------------------
; Sends the var_data value to the register at W (address) in the controller
max7219_writeCmd
	bcf				MAX7219_LOAD
	call			max7219_writebyte
	movf			var_data, W
	call			max7219_writebyte
	; Pulse the LOAD line
	bsf				MAX7219_LOAD
	nop
	nop
	nop
	nop
	bcf				MAX7219_LOAD
	return

;###############################################################################
;##                                                                           ##
;##                   7 - S E G M E N T   D I G I T   M A P                   ##
;##                                                                           ##
;###############################################################################
; Special characters. Most of them untested.
_7SEG_A				EQU		10			
_7SEG_B				EQU		11
_7SEG_C				EQU		12
_7SEG_D				EQU		13
_7SEG_F				EQU		15
_7SEG_DEG			EQU		16
_7SEG_MINUS			EQU		17
_7SEG_H				EQU		18
_7SEG_L				EQU		19
_7SEG_P				EQU		20
_7SEG_b				EQU		21
_7SEG_d				EQU		22
_7SEG_n				EQU		23
_7SEG_o				EQU		24
_7SEG_r				EQU		25
_7SEG_VERTBAR_LFT	EQU		26
_7SEG_VERTBAR_RGT	EQU		27
_7SEG_DBL_VERTBAR	EQU		28
_7SEG_EQUAL			EQU		29
_7SEG_QUESTION		EQU		30
_7SEG_BLANK			EQU		31

_7seg_table
	; Make sure it's < 32
	andlw			B'00011111'
	; Backup the index
	movwf			var_i
	; Computed goto that takes into account all the address bits
	; not only the lower 8 (which the regular "add W to PCL" does)
	movlw			HIGH (_7seg_table_data)
	movwf			PCLATH
	movf			var_i, W
	addlw			LOW(_7seg_table_data)
	btfsc			STATUS, C
	incf			PCLATH, F
	movwf			PCL
_7seg_table_data
					;  SEGMENTS
					; ------------
					; .ABCDEFG
	retlw			B'01111110'	; 0
	retlw			B'00110000'	; 1
	retlw			B'01101101'	; 2
	retlw			B'01111001'	; 3
	retlw			B'00110011'	; 4
	retlw			B'01011011'	; 5
	retlw			B'01011111'	; 6
	retlw			B'01110000'	; 7
	retlw			B'01111111'	; 8
	retlw			B'01111011'	; 9
	retlw			B'01110111'	; A
	retlw			B'11111111'	; B (Same as 8, but with DP)
	retlw			B'01001110'	; C
	retlw			B'11111110'	; D (Same as 0, but with DP)
	retlw			B'01001111'	; E
	retlw			B'01000111'	; F

	retlw			B'01100011'	; °
	retlw			B'00000001'	; -
	retlw			B'00110111'	; H
	retlw			B'00001110'	; L
	retlw			B'01100111'	; P
	retlw			B'00011110'	; b (lowercase)
	retlw			B'00111101'	; d (lowercase)
	retlw			B'00010101'	; n (lowercase)
	retlw			B'00011101'	; o (lowercase)
	retlw			B'00000101'	; r (lowercase)
	retlw			B'00000110'	; | (left)
	retlw			B'00110000'	; | (right)
	retlw			B'00110110'	; ||
	retlw			B'00001001'	; =
	retlw			B'01100101'	; ?
	retlw			B'00000000'	; BLANK

	END
