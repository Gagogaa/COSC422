;;; Gregory Mann
;;; E01457245
;;; Program 4
;;; Make a robot move and stop with ir!

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
    countb      ;used in delay routine
    countc      ;used in delay routine
    countd
  endc
  
;;; turn comparators off (make it like a 16F84)
  movlw   	0x07
  movwf   	CMCON
  
;;; Pin setup.
  bsf 		STATUS,RP0
  movlw 	B'00001000'		; RA3 is input and all other PORTA pins are output
  movwf		TRISA
  movlw		0x00
  movlw		TRISB		; PORTB is all output
  bcf		STATUS,RP0

loop
  bsf		PORTA,RA1	; Start powering servo0.
  bsf		PORTA,RA2	; Start powering servo1.

  CALL 		delay_1_milli

  movlw		.100
  CALL		delay_w_ops

  bcf		PORTA,RA1	; Stop powering servo0.

  movlw		.133
  CALL		delay_w_ops

  bcf		PORTA,RA2	; Stop powering servo1.

  CALL		delay_and_check

  goto loop

;;; delays for w milliseconds 
;;; w is the current value stored in the w register when this sub is called
;;; note that 0 is = 256
delay_w_milli
  movwf		countc
delay_w_milli_loop
  decfsz	countc
  goto		delay_w_milli_loop
  RETURN

;;; delays for 1 milli 
delay_1_milli
  movlw		0x00
  CALL		delay_w_ops
  movlw		.75
  CALL		delay_w_ops
  RETURN

;;; delays for (w * 3) + 4 operations
;;; w is the current value stored in the w register when this sub is called
;;; note that 0 is = 256
delay_w_ops
  movwf 	counta
delay_w_ops_loop
  decfsz	counta
  goto		delay_w_ops_loop
  RETURN
  
delay_and_check
  movlw		.5
  movwf		countd
delay_and_check_loop
;  CALL 		delay_w_milli

  btfss		PORTA,RA3
  CALL		pause_robot
  
  decfsz	countd
  goto		delay_and_check_loop

  RETURN

pause_robot
  movlw		.255
  CALL		delay_w_milli
  btfsc		PORTA,RA3
  goto		pause_robot
  movlw 	.10
  movwf		countd
  RETURN

end
