#include <LiquidCrystal.h>

#define RS_DISP 7
#define EN_DISP 6
#define D4_DISP 5
#define D5_DISP 4
#define D6_DISP 3
#define D7_DISP 2

float AD_RESO = (4.8/1024.0); //resolução do canal AD (pinos A0 ao A5)

LiquidCrystal lcd(RS_DISP, EN_DISP, D4_DISP, D5_DISP, D6_DISP, D7_DISP);

void setup() {
  lcd.begin(16, 4); //Inicia um LCD tem 16 colunas, 4 linhas
}

void loop() {
  lcd.clear();          //Apaga tudo no display LCD para não bugar nada

  lcd.setCursor(0, 0);  //coloque o cursor na linha 0, coluna 0
  lcd.print("");        //Escreva algo que deve ficar entre "" (note que qualquer caracter ou espaço, é incrementado na coluna)
  lcd.setCursor(4, 0);  //coloque o cursor na linha 0, coluna 4

  lcd.setCursor(9, 0);  //coloque o cursor na linha 0, coluna 9
  lcd.print("");        //Escreva algo que deve ficar entre "" (note que qualquer caracter ou espaço, é incrementado na coluna)
  lcd.setCursor(11, 0); //coloque o cursor na linha 0, coluna 11
  delay(100);
}