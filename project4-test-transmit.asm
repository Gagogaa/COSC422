;;; Gregory Mann
;;; E01457245
;;; Program 4
;;; Make a robot move and stop with ir!
;;; This is the transmit porgram.

;;; uncomment following two lines if using 16f627 or 16f628. config uses internal oscillator
  LIST  p=16F628    ;tell assembler what chip we are using
  include "/opt/microchip/mplabx/v3.50/mpasmx/p16f628.inc"    ;include the defaults for the chip
  __config  0x3D18    ;sets the configuration settings (oscillator type etc.)

;;; IMPORTANT : The following is very important
;;; Recall: there is user RAM available starting at location 0x20 upto 0x77 in each bank
;;; Instead of referring to these locations by NUMBER, why not refer to them by NAME
;;; In the example below, counta is an alias for location 0x20, counta is an alias for
;;; location 0x21, countb is an alias for location 0x22. HIGHLY RECOMMENDED
  cblock  0x20  ;start of general purpose registers
    counta      ;used in delay routine 
  endc
  
;;; turn comparators off (make it like a 16F84)
  movlw   	0x07
  movwf   	CMCON
  
;;; Pin setup.
  bsf 		STATUS,RP0
  movlw 	B'00001000'	; RA3 is input and all other PORTA pins are output
  movwf		TRISA
  movlw		0x00
  movwf		TRISB		; PORTB is all output
  bcf		STATUS,RP0

loop
  btfss		PORTA,RA3	; Test RA3 for a signal and HOLD if it's zero
  goto 		loop

  movlw 	0xFF		; Turn on all of PORTB
  movwf		PORTB

  movlw 	.7		; Delay for 24 cycles NOTE: i may need to tone this down
  CALL 		delay_w_ops

  movlw 	0x00		; Turn off all of PORTB
  movwf		PORTB
 
  goto loop

;;; delays for (w * 3) + 4 operations
;;; w is the current value stored in the w register when this sub is called
;;; note that 0 is = 256
delay_w_ops
  movwf 	counta
delay_w_ops_loop
  decfsz	counta
  goto		delay_w_ops_loop
  RETURN

end
