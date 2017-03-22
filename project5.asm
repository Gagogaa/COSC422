
;Gregory Mann
;E01457245
;program 5
;Control the robot using timers and interrupts

	LIST	p=16F628 ;tell assembler what chip we are using
	include "/opt/microchip/mplabx/v3.55/mpasmx/p16f628.inc" ;include the defaults for the chip
	__config 0x3D18 ;sets the configuration settings (oscillator type etc.)
;-------------------------------------------------------------------------------
	cblock	0X20
		count
		ROBOT
		POSTSCALE
		ROTATE
	endc
;-------------------------------------------------------------------------------
	org 0x00
	goto setup
;-------------------------------------------------------------------------------
	org 0x04 ;interrupt vector
	btfsc INTCON,T0IF
	call move_robot
	btfsc INTCON,INTF
	call wiskers
	btfsc PIR1,TMR1IF
	call control_robot
	retfie
;-------------------------------------------------------------------------------
control_robot
	bcf PIR1,TMR1IF ;clear timer 1 interrupt flag

	decfsz POSTSCALE ;delay 8 times
	return

	movlw .1 ;make sure that the delay isnt too long
	movwf POSTSCALE

	movlw b'00000000' ;rotate the robot
	movwf ROBOT

	decfsz ROTATE ;but only rotate for a time
	return

	movlw b'00000001' ;make the robot move forward again
	movwf ROBOT

	bcf T1CON,TMR1ON ;disable timer 1
	return
;-------------------------------------------------------------------------------
wiskers
	bcf INTCON,INTF ;clear B0 interrupt
	btfsc T1CON,TMR1ON ;if timer 1 is enabled do nothing
	return

	movlw .8 ;how long the robot should move backwards
	movwf POSTSCALE

	movlw .2 ;how long the robot should rotate
	movwf ROTATE

	comf ROBOT,F ;move robot backwards

	clrf TMR1L ;clear timer 1 low byte
	clrf TMR1H ;clear timer 1 high byte

	bsf T1CON,TMR1ON ;enable timer 1
	return
;-------------------------------------------------------------------------------
move_robot
	bsf PORTB,RB3 ;turn on servo 0
	bsf PORTB,RB4 ;turn on servo 1

	call delay_1_milli

	;delay for .34 milli
	movlw .100
	call delay_w_ops

	btfss ROBOT,b'00000000' ;check to see if servo 0 should be turned off
	bcf PORTB,RB3

	btfss ROBOT,b'00000001' ;check to see if servo 1 should be turned off
	bcf PORTB,RB4

	;delay for .4 milli
	movlw .133
	call delay_w_ops

	bcf PORTB,RB3 ;turn off servo 0
	bcf PORTB,RB4 ;turn off servo 1

	movlw d'99' ;set up timer 0 for 20 milli seconds
	movwf TMR0

	bcf INTCON,T0IF ;clear timer 0 interrupt
	return
;-------------------------------------------------------------------------------
setup
	movlw 0x07
	movwf CMCON ;turn comparators off (make it like a 16F84)

	clrwdt ;just making sure ;-)

	bsf STATUS,RP0 ;switch to bank 1
	movlw b'11010110' ;28-1 prescaler for timer 0
	movwf OPTION_REG

	bsf PIE1,TMR1IE ;enable timer 1 interrupts

	movlw 0x01
	movwf TRISB ;PORTB is output, B0 is input
	movlw 0xff
	movwf TRISA ;PORTs input

	bcf STATUS,RP0 ;switch back to bank 0

	;enable global interrupts
	;enable peritherial interrupts
	;enable timer 0 interrupts
	;enable RB0 interrupts
	movlw b'11110000'
	movwf INTCON

	bcf PIR1,TMR1IF ;clear timer 1 interrupt

	movlw B'00110000' ;1-8 prescaler for timer 1
	movwf T1CON

	movlw d'99' ;256-99=157, 157*128 is 20096, about 20 milli seconds
	movwf TMR0

	movlw 0x00 ;make sure PORTB is off
	movwf PORTB

	movlw b'00000001' ;make the robot go forwards
	movwf ROBOT
;-------------------------------------------------------------------------------
more
	goto more ;nothing to do
;-------------------------------------------------------------------------------
;delays for (w * 3) + 4 operations
;w is the current value stored in the w register when this sub is called
;note that 0 is = 256
delay_w_ops
	movwf count
delay_w_ops_loop
	decfsz count
	goto delay_w_ops_loop
	return
;-------------------------------------------------------------------------------
;delays for 1 milli second
delay_1_milli
	movlw 0x00
	call delay_w_ops
	movlw .75
	call delay_w_ops
	return
	end
