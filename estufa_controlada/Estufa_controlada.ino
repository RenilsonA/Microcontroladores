#include <LiquidCrystal.h>

#define LIGHT_INPUT01 A2
#define LIGHT_INPUT02 A3
#define LIGHT_OUTPUT  10
#define RS_DISP 7
#define EN_DISP 6
#define D4_DISP 5
#define D5_DISP 4
#define D6_DISP 3
#define D7_DISP 2

struct variables_t {  
    uint8_t light_out;  //Variável que vai jogar um sinal PWM para minha lampada ou leds
    //Colocar aqui as variáveis que serão controladoras para as saídas
} self = {
    .light_out = 0,      //Inicia light_out em 0
    //Colocar aqui os valores que as variáveis que serão controladoras devem iniciar
};

float AD_RESO = (4.8/1024.0); //resolução do canal AD (pinos A0 ao A5)

LiquidCrystal lcd(RS_DISP, EN_DISP, D4_DISP, D5_DISP, D6_DISP, D7_DISP);

void setup() {
    lcd.begin(16, 4); //Inicia um LCD tem 16 colunas, 4 linhas
}

void loop() {
    lcd.clear();          //Apaga tudo no display LCD para não bugar nada

    lcd.setCursor(0, 0);  //coloque o cursor na linha 3, coluna 0
    lcd.print("");        //Escreva algo que deve ficar entre "" (note que qualquer caracter ou espaço, é incrementado na coluna)
    lcd.setCursor(4, 0);  //coloque o cursor na linha 3, coluna 4

    lcd.setCursor(9, 0);  //coloque o cursor na linha 3, coluna 9
    lcd.print("");        //Escreva algo que deve ficar entre "" (note que qualquer caracter ou espaço, é incrementado na coluna)
    lcd.setCursor(11, 0); //coloque o cursor na linha 3, coluna 11
    delay(100);
}

void light_control(){
    uint16_t lux1 = analogRead(LIGHT_INPUT01);
    uint16_t lux2 = analogRead(LIGHT_INPUT02);
    //TODO: fazer equação ou lógica para saida de luz.
    analogWrite(LIGHT_OUTPUT, self.light_out);  //Escreva em PWM no pino de LIGHT_OUTPUT (D10), o valor da variável light_out da struct.
}