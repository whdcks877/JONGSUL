/*
 * WebSocketServer.ino
 *
 *  Created on: 22.05.2015
 *
 */
#define IN1 13
#define IN2 12
#define IN3 14
#define IN4 27
#define INA 3
#define INB 5

#include <string.h>
#include <Arduino.h>

#include <WiFi.h>
#include <WiFiMulti.h>
#include <WiFiClientSecure.h>
#include <WebSocketsServer.h>

#define BUZER_PIN 33
#define LED_RED 25
#define LED_GREEN 26

#define CH 0
#define FREQ 5000
#define RESOLUTION 8

bool led_state = false;

const char* ssid = "Moon";
const char* password = "moon877@";

IPAddress local_IP(172, 20, 10, 10);          // ESP32가 사용할 IP address
IPAddress gateway(172, 20, 10, 1);              // Gateway IP address (공유기 IP주소)

IPAddress subnet(255, 255, 255, 240);          // subnet mask
IPAddress primaryDNS(8, 8, 8, 8);             // primary DNS server IP address
IPAddress secondaryDNS(8, 8, 4, 4);         // secondary DNS server IP address


//WiFiMulti WiFiMulti;
WebSocketsServer webSocket = WebSocketsServer(81);
  
#define USE_SERIAL Serial
void FOWARD() {
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, HIGH);
  digitalWrite(IN4, LOW);
}

void LEFT() {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, HIGH);
  digitalWrite(IN4, LOW);
}

void RIGHT() {
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, LOW);
}

void BACKWARD() {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, HIGH);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, HIGH);
}

void turn_RED() {
  digitalWrite(LED_GREEN, HIGH);
  digitalWrite(LED_RED, LOW);
}

void turn_GREEN() {
  digitalWrite(LED_GREEN, LOW);
  digitalWrite(LED_RED, HIGH);
}

void toggleLED() {
  if (!led_state) {
    turn_RED();
  } else {
    turn_GREEN();
  }
  led_state = !led_state;
}

void BEEP() {
  ledcWriteTone(CH, 440);
}

void BEEP_STOP() {
  ledcWriteTone(CH, 0);
}

void STOP(){
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, LOW);

  BEEP_STOP();
}

void hexdump(const void *mem, uint32_t len, uint8_t cols = 16) {
  const uint8_t* src = (const uint8_t*) mem;
  USE_SERIAL.printf("\n[HEXDUMP] Address: 0x%08X len: 0x%X (%d)", (ptrdiff_t)src, len, len);
  for(uint32_t i = 0; i < len; i++) {
    if(i % cols == 0) {
      USE_SERIAL.printf("\n[0x%08X] 0x%08X: ", (ptrdiff_t)src, i);
    }
    USE_SERIAL.printf("%02X ", *src);
    src++;
  }
  USE_SERIAL.printf("\n");
}

void RC(uint8_t * payload) {
  char * UP_s = "UP";
  char * DOWN_s = "DOWN";
  char * LEFT_s = "LEFT";
  char * RIGHT_s = "RIGHT";
  char * STOP_s = "STOP";
  char * RED_s = "RED";
  char * GREEN_s = "GREEN";
  char * TOGGLE_s = "TEMP0";
  char * BEEP_s = "TEMP1";
  
  if(!strcmp((char *)payload, UP_s)) {
    FOWARD();
  } else if(!strcmp((char *)payload, DOWN_s)) {
    BACKWARD();
  } else if(!strcmp((char *)payload, LEFT_s)) {
    LEFT();
  } else if(!strcmp((char *)payload, RIGHT_s)) {
    RIGHT();
  } else if(!strcmp((char *)payload, STOP_s)) {
    STOP();
  } else if(!strcmp((char *)payload, RED_s)) {
    turn_RED();
  } else if(!strcmp((char *)payload, GREEN_s)) {
    turn_GREEN();
  }else if(!strcmp((char *)payload, TOGGLE_s)) {
    toggleLED();
  }else if(!strcmp((char *)payload, BEEP_s)) {
    BEEP();
  }
}

void webSocketEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t length) {

    switch(type) {
        case WStype_DISCONNECTED:
            USE_SERIAL.printf("[%u] Disconnected!\n", num);
            break;
        case WStype_CONNECTED:
            {
                IPAddress ip = webSocket.remoteIP(num);
                USE_SERIAL.printf("[%u] Connected from %d.%d.%d.%d url: %s\n", num, ip[0], ip[1], ip[2], ip[3], payload);

        // send message to client
        webSocket.sendTXT(num, "Connected");
            }
            break;
        case WStype_TEXT:
            USE_SERIAL.printf("[%u] get Text: %s\n", num, payload);
            RC(payload);
            // send message to client
            webSocket.sendTXT(num, "message here");

            // send data to all connected clients
            // webSocket.broadcastTXT("message here");
            break;
        case WStype_BIN:
            USE_SERIAL.printf("[%u] get binary length: %u\n", num, length);
            hexdump(payload, length);

            // send message to client
            // webSocket.sendBIN(num, payload, length);
            break;
    case WStype_ERROR:      
    case WStype_FRAGMENT_TEXT_START:
    case WStype_FRAGMENT_BIN_START:
    case WStype_FRAGMENT:
    case WStype_FRAGMENT_FIN:
      break;
    }

}

void setup() {
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(IN3, OUTPUT);
  pinMode(IN4, OUTPUT);

  pinMode(2, OUTPUT);
  digitalWrite(2, LOW);

  pinMode(LED_RED, OUTPUT);
  pinMode(LED_GREEN, OUTPUT);
  
  digitalWrite(LED_RED, HIGH);
  digitalWrite(LED_GREEN, HIGH);

  turn_GREEN();

  ledcSetup(CH, FREQ, RESOLUTION);
  ledcAttachPin(BUZER_PIN, CH);
  
    // USE_SERIAL.begin(921600);
    USE_SERIAL.begin(115200);

    //Serial.setDebugOutput(true);
    USE_SERIAL.setDebugOutput(true);

    USE_SERIAL.println();
    USE_SERIAL.println();
    USE_SERIAL.println();

    for(uint8_t t = 4; t > 0; t--) {
        USE_SERIAL.printf("[SETUP] BOOT WAIT %d...\n", t);
        USE_SERIAL.flush();
        delay(1000);
    }

      //WiFi.mode(WIFI_STA);
     if (!WiFi.config(local_IP, gateway, subnet, primaryDNS, secondaryDNS)) {
      Serial.println("STA failed to configure");
     }
      
      WiFi.begin(ssid, password);
      Serial.println("");

  // Wait for connection
    while (WiFi.status() != WL_CONNECTED) {
      delay(500);
      Serial.print(".");
    }
    Serial.println("");
    Serial.print("Connected to ");
    Serial.println(ssid);
    Serial.print("IP address: ");
    Serial.println(WiFi.localIP());
    digitalWrite(2, HIGH);

    webSocket.begin();
    webSocket.onEvent(webSocketEvent);
}

void loop() {
    webSocket.loop();
}
