
#define CLOCK 16.0e6 ;clock speeddefine CLOCK 16.0e6 ;clock speed
#define DELAY 1 ;seconds

.def temp = r16
.def leds = r17 ;current LED value
.def cont = r18 ;Conta os segundo do time 
.def time = r19
.def D1 = r25   ; Digito 1 do Display 
.def D2 = r24   ; Digito 2 do Display 
.cseg

.org 0
jmp reset
.org OC1Aaddr
jmp Time_Interrupt


Time_Interrupt:
	push r16
	in r16, SREG
	push r16
	
	inc cont ; Contador de 1 segundo 

	; Contador do Display
	subi D2,1 
	tst D2      ; Verificar se D2 == 0
	brne pc + 3 ; Se D2 == 0, subtrai 1 de D1, caso não continua a interrupcção   
	subi D1,1
	ldi D2, 9
	
	
	pop r16
	out SREG, r16
	pop r16
	reti

reset:
	LDI cont, 0
	;Incializando Pilha
	ldi temp, low(RAMEND)
	out SPL, temp
	ldi temp, high(RAMEND)
	out SPH, temp

	;Configurnado Portas B e D para os LEDS como Sa�da  e Porta C para o Display
	ldi temp, $FF
	out DDRB, temp
	out DDRD, temp
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
	LOOP: 
		CALL E1
		CALL E2
		CALL E3
		ldi D1, 5
		ldi D2, 2
		CALL E4
		CALL E5
		CALL E6
		CALL E7
		ldi time, 127
		cp cont, time
		brne pc - 1
		RJMP LOOP


 
; LEDS: RYG
; S1:         S2:				S5:				S3 E S4:			P1 E P2: 
;    R = PB2			R = PB5			R = PD0			R = PD3				G = PD4      
;	 Y = PB1			Y = PB4			Y = PB7			Y = PD2
;    G = PB0			G = PB3			G = PB6			G = PD1
;Display: 
; D1:						D1: 
;    ON/OFF: PD6				ON/OFF: PD5
;    NUMERO: PORTA C			NUMERO: PORTA C
E1: 
	LDI cont, 0
	; ESTADO  1
	ldi leds, 0b00001001
	out PORTB, leds
	ldi leds, 0b00001001
	out PORTD, leds
	RETI
E2: 
	ldi time, 25
	cp cont,time 
	brne E2
	; ESTADO  2
	ldi leds, 0b00001010
	out PORTB, leds
	ldi leds, 0b00001001
	out PORTD, leds
	RETI
E3: 
	ldi time, 29
	cp cont,time 
	brne E3
	; ESTADO  3
	ldi leds, 0b00001100
	out PORTB, leds
	ldi leds, 0b00000011
	out PORTD, leds
	RETI
E4: ;Display
	ldi leds, 0b00100011 ;  Acende os leds como no estado 3, é configura acende o Display D2
	out PORTD, leds
	out PORTC, D2
	call delay10ms

	ldi temp, 0b01000011 ;  Acende os leds como no estado 3, é configura acende o Display D1
	out PORTD, temp
	out PORTC, D1
	call delay10ms

	ldi time, 81
	cp cont,time 
	brne E4

	; ESTADO  4
	ldi leds, 0b00010100
	out PORTB, leds
	ldi leds, 0b00000101
	out PORTD, leds
	RETI
E5: 
	ldi time, 85
	cp cont,time 
	brne E5
	; ESTADO  5
	ldi leds, 0b01100100
	out PORTB, leds
	ldi leds, 0b00001000
	out PORTD, leds
	RETI
E6: 
	ldi time, 110
	cp cont,time 
	brne E6
	; ESTADO  6
	ldi leds, 0b10100100
	out PORTB, leds
	ldi leds, 0b00001000
	out PORTD, leds
	RETI
E7: 
	ldi time, 114
	cp cont,time 
	brne E7
	; ESTADO  7
	ldi leds, 0b00100100
	out PORTB, leds
	ldi leds, 0b00011001
	out PORTD, leds
	RETI


delay10ms:
	.equ ClockMHz = 16;16MHz
	.equ DelayMs = 10; 20ms
	ldi r22, byte3 (ClockMHz * 1000 * DelayMs / 5)
	ldi r21,high (ClockMHz*1000 * DelayMs / 5)
	ldi r20, low(ClockMHz * 1000 * DelayMs / 5)
	
	subi r20,1
	sbci r21,0
	sbci r22,0
	brcc pc-3
	RET