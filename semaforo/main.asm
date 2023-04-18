#define CLOCK 16.0e6 ;clock speeddefine CLOCK 16.0e6 ;clock speed
#define DELAY 1 ;seconds

.def temp = r16
.def leds = r17 ;current LED value
.def cont = r18 ;Conta os segundo do time 
.def time = r19
.def D01 = R25   ; Unidade do Display 
.def D10 = R24   ; Dezena do Display 
.def uni = R20
.def dez = R21
.cseg

.org 0
jmp reset
.org OC1Aaddr
jmp Time_Interrupt

digitos: .db 222, 254, 14, 250, 218, 204, 158, 182, 12, 126 ;230 é o 204

Time_Interrupt:
	push r16
	in r16, SREG
	push r16

	inc cont ; Contador de 1 segundo 

	unidades:
		cpi uni, 0x39
		brge dezenas

		inc uni
		ldi ZL, 0
		add ZL, uni
		lpm D01, Z

		pop r16
		out SREG, r16
		pop r16
		reti

	dezenas:
		ldi uni, 0x2F
		inc dez
		ldi ZL, 0
		add ZL, dez
		lpm D10, Z

		rjmp unidades
	
reset:
	LDI cont, 0
	;Incializando Pilha
	ldi temp, low(RAMEND)
	out SPL, temp
	ldi temp, high(RAMEND)
	out SPH, temp

	;Configurnado Portas B e D para os LEDS como Sa�da  e Porta C para o Display
	ldi temp, 0xFF
	out DDRB, temp
	ldi temp, 0x3f
	out DDRD, temp
	ldi temp, 0xfe
	out DDRC, temp
	
	.equ PRESCALE = 0b100 ;/256 prescale
	.equ PRESCALE_DIV = 256
	.equ WGM = 0b0100 ;Waveform generation mode: CTC
	;you must ensure this value is between 0 and 65535
	.equ TOP = int(0.5 + ((CLOCK/PRESCALE_DIV)*DELAY))
	.if TOP > 65535
	.error "TOP is out of range"
	.endif

	;On MEGA series, write high byte of 16-bit timer registers first
	ldi temp, high(TOP) ;initialize compare value (TOP)
	sts OCR1AH, temp
	ldi temp, low(TOP)
	sts OCR1AL, temp
	ldi temp, ((WGM&0b11) << WGM10) ;lower 2 bits of WGM
	; WGM&0b11 = 0b0100 & 0b0011 = 0b0000 
	sts TCCR1A, temp
	;upper 2 bits of WGM and clock select
	ldi temp, ((WGM>> 2) << WGM12)|(PRESCALE << CS10)
	; WGM >> 2 = 0b0100 >> 2 = 0b0001
	; (WGM >> 2) << WGM12 = (0b0001 << 3) = 0b0001000
	; (PRESCALE << CS10) = 0b100 << 0 = 0b100
	; 0b0001000 | 0b100 = 0b0001100
	sts TCCR1B, temp ;start counter

	lds r16, TIMSK1
	sbr r16, 1 <<OCIE1A
	sts TIMSK1, r16

	sei
	; LEDS: RYG
	; S1:		PC3, PC2
	; S2:		PC1, PC0
	; S3 E S4:	PB3, PB2
	; S5:		PB5, PB4
	;	 00 = Indevido		
	;    01 = R    
	;	 10 = Y
	;    11 = G
	;Display: 
	; Unidades:						Dezenas: 
	;    ON/OFF: PB0				ON/OFF: PB1
	;    NUMERO: PORTD 1~7			NUMERO: PORTD 1~7
	E1: 
		LDI cont, 0
		; ESTADO  1
		; S1 = G // S2 = G // S3, S4, S5 = R
		ldi uni, 0x39
		ldi ZL, 0
		add ZL, uni
		lpm D01, Z

		ldi dez, 0x31
		ldi ZL, 0
		add ZL, dez
		lpm D10, Z

		ldi leds, 0b010100
		out PORTB, leds
		ldi leds, 0b001111
		out PORTC, leds
		disp:
			ldi time, 25
			cp cont, time 
			brge E2
			call displays
			rjmp disp
	E2: 
		; ESTADO  2
		; S1 = Y // S2 = G // S3, S4, S5 = R
		ldi leds, 0b010100
		out PORTB, leds
		ldi leds, 0b001011
		out PORTC, leds
		disp2:
			ldi time, 29
			cp cont, time 
			brge E3
			call displays
			rjmp disp2
	E3: 
		; ESTADO  3
		; S1 = R // S2 = G // S3, S4 = G // S5 = R
		ldi leds, 0b011100
		out PORTB, leds
		ldi leds, 0b000111
		out PORTC, leds
		disp3:
			ldi time, 81
			cp cont, time 
			brge E4
			call displays
			rjmp disp3
	E4: 
		ldi uni, 0x36
		ldi ZL, 0
		add ZL, uni
		lpm D01, Z

		ldi dez, 0x39
		ldi ZL, 0
		add ZL, dez
		lpm D10, Z

		; ESTADO  4
		; S1 = R // S2 = Y // S3, S4 = Y // S5 = R
		ldi leds, 0b011000
		out PORTB, leds
		ldi leds, 0b000110
		out PORTC, leds
		disp4:
			ldi time, 85
			cp cont, time 
			brge E5
			call displays
			rjmp disp4
	E5: 
		ldi uni, 0x37
		ldi ZL, 0
		add ZL, uni
		lpm D01, Z

		ldi dez, 0x35
		ldi ZL, 0
		add ZL, dez
		lpm D10, Z
	
		; ESTADO  5
		; S1 = R // S2 = R // S3, S4 = R // S5 = G
		ldi leds, 0b110100
		out PORTB, leds
		ldi leds, 0b000101
		out PORTC, leds
		disp5:
			ldi time, 110
			cp cont, time 
			brge E6
			call displays
			rjmp disp5
	E6: 
		; ESTADO  6
		; S1 = R // S2 = R // S3, S4 = R // S5 = Y
		ldi leds, 0b100100
		out PORTB, leds
		ldi leds, 0b000101
		out PORTC, leds
		disp6:
			ldi time, 114
			cp cont, time 
			brge E7
			call displays
			rjmp disp6
	E7: 
		; ESTADO  7
		; S1 = R // S2 = R // S3, S4 = R // S5 = R
		ldi leds, 0b010100
		out PORTB, leds
		ldi leds, 0b000101
		out PORTC, leds
		disp7:
			ldi time, 127
			cp cont, time 
			brge chamar
			call displays
			rjmp disp7

	chamar:
		reti

	displays:
		in temp, PORTB
		andi temp, 0b111100
		ori temp, 0b01
		out PORTB, temp
		out PORTD, D01
		call delay1ms

		andi temp, 0b111100
		ori temp, 0b10
		out PORTB, temp
		out PORTD, D10
		call delay1ms
		reti

delay1ms:
	.equ ClockMHz = 16;16MHz
	.equ DelayMs = 2; 20ms
	ldi r29, byte3 (ClockMHz * 1000 * DelayMs / 5)
	ldi r28, high (ClockMHz * 1000 * DelayMs / 5)
	ldi r27, low(ClockMHz * 1000 * DelayMs / 5)
	
	subi r27,1
	sbci r28,0
	sbci r29,0
	brcc pc-3
	RET