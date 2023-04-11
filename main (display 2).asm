digitos: .db 222, 254, 14, 250, 218, 204, 158, 182, 12, 126
troca_de_estados: .db 25, 4
.def temp = R16
.def D01 = R25   ; Unidade do Display 
.def D10 = R24   ; Dezena do Display 
.def dez = R23
.cseg

ldi dez, 0
ldi temp, 0xFF
out DDRD, temp
out DDRB, temp

;Stack initialization
ldi R16, low(RAMEND)
out SPL, R16
ldi R16, high(RAMEND)
out SPH, R16

;(16*10^6/256)*1 = 62500
;defino o prescale e o topo do meu contador
#define CLOCK 16.0e6 ;clock speed
#define DELAY 1 ;seconds
.equ PRESCALE = 0b100 ;/1 prescale
.equ PRESCALE_DIV = 256
.equ WGM = 0b0100 ;Waveform generation mode: CTC
;you must ensure this value is between 0 and 65535
.equ TOP = int(0.5 + ((CLOCK/PRESCALE_DIV)*DELAY))
.if TOP > 65535
.error "TOP is out of range"
.endif

;carrega o topo nos registradores ocr1ah e l
ldi R16, high(TOP) ;initialize compare value (TOP)
sts OCR1AH, R16
ldi R16, low(TOP)
sts OCR1AL, R16
ldi R16, ((WGM & 0b11) << WGM10)
sts TCCR1A, R16 ;jogo 0x00, bits menos significativos
ldi R16, ((WGM >> 2) << WGM12) | (PRESCALE << CS10)
sts TCCR1B, R16 ;Carregue 0b0001100 e começe a contar

main_lp:
	in R16, TIFR1 ;Checa a flag 0bxxxxx1x AND 0b10
	andi R16, 1 << OCF1A ;crio uma mascara e façu uma operação AND checo se a flag de tempo ficou ativada (quando passado 357us)
	breq nao_estourou ;checa se estourou
		ldi R16, 1 << OCF1A ;limpo a flag do tempo quando passado
		out TIFR1, R16	   ;carregue o dado para limpar
		start:
			cpi ZL, 10
			brcc dezenas
			lpm D01, Z+
			rjmp main_lp
		dezenas:
			inc dez
			ldi ZL, 0
			add ZL, dez
			lpm D10, Z
			ldi ZL, 0
			rjmp start
	nao_estourou:
		ldi temp, 1
		out PORTB, temp
		out PORTD, D01

		;ldi temp, 2
		;out PORTB, temp
		;out PORTD, D10
		rjmp main_lp