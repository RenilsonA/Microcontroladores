#include <LiquidCrystal.h>
#include <dht.h>
#include <TimerOne.h>

#define DHT_PIN            9
#define COOLER_MOTOR       11
#define HIGROMETER_1       A0
#define HIGROMETER_2       A1
#define LIGHT_INPUT_UP     A2
#define LIGHT_INPUT_FRONT  A3
#define LIGHT_INPUT_RIGHT  A4
#define LIGHT_INPUT_LEFT   A5
#define LIGHT_OUTPUT_UP    3
#define LIGHT_OUTPUT_RIGHT 5
#define LIGHT_OUTPUT_LEFT  6
#define WATER_MOTOR        10
#define RS_DISP            12
#define EN_DISP            8
#define D4_DISP            7
#define D5_DISP            4
#define D6_DISP            2
#define D7_DISP            1

struct variables_t {  
    uint8_t light_up;           //guarda o valor analógico que vai para os leds de cima
    uint8_t light_right;        //guarda o valor analógico que vai para os leds da direita
    uint8_t light_left;         //guarda o valor analógico que vai para os leds da esquerda
    uint8_t hygrometer_average;
    bool motor_status;
    float humidity;
    float temperature;
    uint8_t cooler_speed;
} self = {
    .light_up           = 0,       //Inicia light_up em 0
    .light_right        = 0,       //Inicia light_right em 0
    .light_left         = 0,       //Inicia light_left em 0
    .hygrometer_average = 0,       //Inicia hygrometer_average em 0
    .motor_status       = true,
    .humidity           = 0,
    .temperature        = 0,
    .cooler_speed       = 0,
};

LiquidCrystal lcd(RS_DISP, EN_DISP, D4_DISP, D5_DISP, D6_DISP, D7_DISP);
dht dht_sensor;

void setup() {
    pinMode(COOLER_MOTOR, OUTPUT);
    pinMode(LIGHT_OUTPUT_UP, OUTPUT);
    pinMode(LIGHT_OUTPUT_RIGHT, OUTPUT);
    pinMode(LIGHT_OUTPUT_LEFT, OUTPUT);
    pinMode(WATER_MOTOR, OUTPUT);
    lcd.begin(16, 2);
}

void loop() {
    uint8_t aux = 0;          //Variável auxiliar
    cooler_motor_control();
    hygrometer_control();
    light_control();
    lcd.clear();              //Apaga tudo no display LCD para não bugar nada


    //Atualiza linha 1 que informa valores do higrometro.
    lcd.setCursor(0, 0);
    lcd.print("Solo:");
    lcd.setCursor(5, 0);
    lcd.print(self.hygrometer_average);
    lcd.setCursor(8, 0);
    lcd.print("%");
    lcd.setCursor(10, 0);
    lcd.print("Agua:");
    lcd.setCursor(15, 0);
    if(self.motor_status){
        lcd.print("S");
    } else {
        lcd.print("N");
    }

    
    lcd.setCursor(0, 1);
    lcd.print("T:");
    lcd.setCursor(2, 1);
    lcd.print(int(self.temperature));
    lcd.setCursor(5, 1);
    lcd.print("C");
    lcd.setCursor(10, 1);
    lcd.print("H:");
    lcd.setCursor(12, 1);
    lcd.print(int(self.humidity));
    lcd.setCursor(15, 1);
    lcd.print("%");

    delay(5000);
    lcd.clear();

    //Atualiza linha 3 que informa luzes.
    lcd.setCursor(0, 0);      //coloque o cursor na linha 3, coluna 0
    lcd.print("UP:  RH:  LT:");
    aux = map(self.light_up, 0, 255, 0, 100);
    lcd.setCursor(0, 1);      //coloque o cursor na linha 3, coluna 2
    lcd.print(aux);
    lcd.setCursor(3, 1);      //coloque o cursor na linha 3, coluna 0
    lcd.print("%");
    aux = map(self.light_right, 0, 255, 0, 100);
    lcd.setCursor(5, 1);      //coloque o cursor na linha 3, coluna 2
    lcd.print(aux);
    lcd.setCursor(8, 1);      //coloque o cursor na linha 3, coluna 0
    lcd.print("%");
    aux = map(self.light_left, 0, 255, 0, 100);
    lcd.setCursor(10, 1);      //coloque o cursor na linha 3, coluna 2
    lcd.print(aux);
    lcd.setCursor(13, 1);      //coloque o cursor na linha 3, coluna 0
    lcd.print("%");

    delay(5000);
}

void cooler_motor_control(){
    uint8_t err = dht_sensor.read11(DHT_PIN);
    self.humidity = dht_sensor.humidity;
    self.temperature = dht_sensor.temperature;
    if(self.temperature > 30 || self.humidity > 20){
        self.cooler_speed = map(self.temperature, 20, 35, 100, 255);
        analogWrite(COOLER_MOTOR, self.cooler_speed);
    } else {
        analogWrite(COOLER_MOTOR, 0);
    }
}

void callback_full_time(){
    self.motor_status = true;
}

void callback_timer_motor(){
    digitalWrite(WATER_MOTOR, LOW);
    Timer1.initialize(1000000000);                  // 10 segundos (em microssegundos)
    Timer1.attachInterrupt(callback_full_time);
}

void water_motor_control(){
    self.motor_status = false;
    Timer1.initialize(10000000);                  // 10 segundos (em microssegundos)
    Timer1.attachInterrupt(callback_timer_motor);
    digitalWrite(WATER_MOTOR, HIGH);
}

void hygrometer_control(){
    uint16_t AH1 = analogRead(HIGROMETER_1);         // Recebe Valor Analógico Higrômetro 1
    uint16_t AH2 = analogRead(HIGROMETER_2);         // Recebe Valor Analógico Higrômetro 2  
    float MAH = (AH1 + AH2)/2;
    self.hygrometer_average = map(MAH, 0, 1023, 0, 100);      
    if (self.hygrometer_average < 40 && self.motor_status){
        water_motor_control();
    }
}

void light_control(){
    uint16_t lux0    = 2 * analogRead(LIGHT_INPUT_UP);
    uint16_t lux1    = 2 * analogRead(LIGHT_INPUT_FRONT);
    uint16_t lux2    = 2 * analogRead(LIGHT_INPUT_RIGHT);
    uint16_t lux3    = 2 * analogRead(LIGHT_INPUT_LEFT);
    self.light_up    = map(lux0, 0, 1023, 0, 255);
    self.light_right = map((4*lux0) + (4*lux1) + (5*lux2) + (2*lux3), (1024 * 6) - 1, 0, 255, 100);
    self.light_left  = map((4*lux0) + (4*lux1) + (2*lux2) + (5*lux3), (1024 * 6) - 1, 0, 255, 100);
    analogWrite(LIGHT_OUTPUT_UP, self.light_up);
    analogWrite(LIGHT_OUTPUT_RIGHT, self.light_right);
    analogWrite(LIGHT_OUTPUT_LEFT, self.light_left);
}
