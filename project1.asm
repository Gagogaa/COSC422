 ;;; Gregory Mann
;;; E01457245
;;; Program 2
;;; Make a robot move

;;; uncomment following two lines if using 16f627 or 16f628. config uses internal oscillator
	LIST	p=16F628		;tell assembler what chip we are using
	include	"/opt/microchip/mplabx/v3.50/mpasmx/p16f628.inc"		;include the defaults for the chip
	__config	0x3D18		;sets the configuration settings (oscillator type etc.)

;;; IMPORTANT : The following is very important
;;; Recall: there is user RAM available starting at location 0x20 upto 0x77 in each bank
;;; Instead of referring to these locations by NUMBER, why not refer to them by NAME
;;; In the example below, counta is an alias for location 0x20, counta is an alias for
;;; location 0x21, countb is an alias for location 0x22. HIGHLY RECOMMENDED
	cblock 	0x20 	;start of general purpose registers
		counta 			;used in delay routine 
	  countb 			;used in delay routine
		countc			;used in delay routine
	endc
	
;;; turn comparators off (make it like a 16F84)
	movlw		0x07
	movwf		CMCON			
	
;;; set port a and b for output
	bsf			STATUS,RP0 								; switch to bank 1
	movlw		0x00
	movwf		TRISB											; port a and b are output
	movwf		TRISA		              	
	bcf			STATUS,RP0								; return to bank 0

loooop
	movlw		0xff											; turn the servos off 
	movwf		PORTB
	movwf		PORTA

	call 		delay_1_milli							; delay for about 1 milli 
	
	movlw 	0x00											; turn port a off
	movwf 	PORTA

	movlw 	.12											
	call 		delay_w3_ops							; delay for 12 * 3 + 3 (39) operations

	movwf		PORTB											; turn port b off
	;; delay some more
	call 		delay_w3_ops
	call 		delay_20_milli
	
	goto 		loooop

delay_20_milli
	movlw		.20
	movwf		countb			; careful!! don't use counta
delay_20_loop
	call		delay_1_milli
	decfsz	countb
	goto 		delay_20_loop
	return

delay_1_milli
	movlw 	0xf9
	movwf		counta
delay_1_loop
	nop
	decfsz	counta
	goto		delay_1_loop
	return

delay_w3_ops
	decfsz 	countc
	goto 		delay_w3_ops
	return
	
	end
 
