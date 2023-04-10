.def temp = r17
reset:
	ldi temp,0xFF		;configure PORTB as output
	out DDRB,temp
	ldi temp,0xFF		;configure PORTB as output
	out DDRD,temp
	lp:
		LDI  R16, 0b01001001 
		out PORTB, R16	;Put counter value on PORT B
		LDI  R16, 0b00010010
		out PORTD,R16
		RCALL delay20ms
		LDI  R16, 0b10010010 
		out PORTB, R16	;Put counter value on PORT B
		LDI  R16, 0b00000100
		out PORTD,R16
		RCALL delay20ms
		LDI  R16, 0b00100100 
		out PORTB, R16	;Put counter value on PORT B
		LDI  R16, 0b00001001
		out PORTD,R16
		RCALL delay20ms
		rjmp lp

.equ ClockMHz = 16;16MHz
.equ DelayMs = 2000; 20ms

delay20ms:
	ldi r22, byte3 (ClockMHz * 1000 * DelayMs / 5)
	ldi r21,high (ClockMHz*1000 * DelayMs / 5)
	ldi r20, low(ClockMHz * 1000 * DelayMs / 5)
	
	subi r20,1
	sbci r21,0
	sbci r22,0
	brcc pc-3
	RET