
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

		ldi D1, 9
		ldi D2, 9
		CALL E4
		
		ldi time, 105
		cp cont, time
		brne pc - 1
		RJMP LOOP
 
;Display: 
; D1:						D1: 
;    ON/OFF: PD6				ON/OFF: PD5
;    NUMERO: PORTA C			NUMERO: PORTA C

E4: ;Display
	ldi leds, 0b00100000 ;   configura acende o Display D2
	out PORTD, leds
	out PORTC, D2
	call delay10ms

	ldi temp, 0b01000000 ;   configura acende o Display D1
	out PORTD, temp
	out PORTC, D1
	call delay10ms

	ldi time, 99
	cp cont,time 
	brne E4
