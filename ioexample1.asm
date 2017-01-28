


; uncomment following two lines if using 16f627 or 16f628. config uses internal oscillator
	LIST	p=16F628		;tell assembler what chip we are using
	; this line sources the include file
	include "/opt/microchip/mplabx/v3.50/mpasmx/p16f628.inc"		;include the defaults for the chip
	__config 0x3D18			;sets the configuration settings (oscillator type etc.)


; Filename : IOExample1.asm
; IO via polling




;	list	p=16f84a
;	__config h'3ff1'

; We'll turn on an LED on pin B8 if A2 is high
; and turn it off if A2 is low. Note: put a pullup/pushdown
; resistor on A2 (we use a pushdown) 



;un-comment the following two lines if using 16f627 or 16f628

	movlw	0x07
	movwf	CMCON			;turn comparators off (make it like a 16F84)
	
; set b port for output, a port for input

	bsf		STATUS,RP0
	movlw	0x00
	movwf	TRISB			; portb is output
	movlw	0xff
	movwf	TRISA			;porta is input
	bcf		STATUS,RP0		;return to bank 0

;start with led off
	movlw	0x00
	movwf	PORTB

;Main loop follows. Just loop thru and continuously check A2 (POLLING!!)

led_off
	btfss	PORTA,2
	goto	led_off
	movlw	0xff		;turn that light on
	movwf	PORTB
led_on
	btfsc	PORTA,2
	goto	led_on

	movlw	0x00
	movwf	PORTB		;turn light off
	goto led_off
	end


