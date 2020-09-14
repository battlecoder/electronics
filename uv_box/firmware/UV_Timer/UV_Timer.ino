/* UV Timer firmware v1.0
 *  This file is part of the UV box project:
 *  
 *  http://blog.damnsoft.org/uv-exposure-box-project-part-1/
 *  
 *  Author: Elias Zacarias
 */
#define TOTAL_DIGITS                4
#define TOTAL_BTTNS                 5

// Pin mapping -----------------------------
const int output_pin                = 13;
const int digit_map[TOTAL_DIGITS]   = {12, 11, 10, 9};
const int segment_map[7]            = {2, 3, 4, 5, 6, 7, 8};
const int button_pins[TOTAL_BTTNS]  = {A0, A1, A2, A3, 0};

#define BTTN_PREV                   1
#define BTTN_NEXT                   2
#define BTTN_INC                    4
#define BTTN_START                  3
#define BTTN_SAFE                   0 // Safety switch. Will automatically pause if this button is not "pressed".

// 59:59 Max time. Feel free to change
const byte digit_max[TOTAL_DIGITS]  = {5, 9, 5, 9};

// Program states
#define STATE_IDLE                  0
#define STATE_EDITING               1
#define STATE_PAUSED                2
#define STATE_RUNNING               3
#define STATE_INTERRUPTED           4
#define STATE_FINISHED              5

// Constants for 7-segment addressing.
#define _SEG_A                      (byte)0b00000001
#define _SEG_B                      (byte)0b00000010
#define _SEG_C                      (byte)0b00000100
#define _SEG_D                      (byte)0b00001000
#define _SEG_E                      (byte)0b00010000
#define _SEG_F                      (byte)0b00100000
#define _SEG_G                      (byte)0b01000000

// Implemented "symbols" (indexes from the character map)
#define CHAR_A                     0xA
#define CHAR_B                     0xB
#define CHAR_C                     0xC
#define CHAR_D                     0xD
#define CHAR_E                     0xE
#define CHAR_F                     0xF
#define CHAR_N                     0x10
#define CHAR_O                     0x11

// 7-Segment character map ------------------------------------------
const byte digit_segmap[] = {
  _SEG_A | _SEG_B | _SEG_C | _SEG_D | _SEG_E | _SEG_F,         // 0
  _SEG_B | _SEG_C,                                             // 1
  _SEG_A | _SEG_B | _SEG_G | _SEG_E | _SEG_D,                  // 2
  _SEG_A | _SEG_B | _SEG_C | _SEG_D | _SEG_G,                  // 3
  _SEG_F | _SEG_G | _SEG_B | _SEG_C,                           // 4
  _SEG_A | _SEG_F | _SEG_G | _SEG_C | _SEG_D,                  // 5
  _SEG_A | _SEG_F | _SEG_G | _SEG_C | _SEG_D | _SEG_E,         // 6
  _SEG_A | _SEG_B | _SEG_C | _SEG_C,                           // 7
  _SEG_A | _SEG_B | _SEG_C | _SEG_D | _SEG_E | _SEG_F | _SEG_G,// 8
  _SEG_A | _SEG_B | _SEG_C | _SEG_D | _SEG_F | _SEG_G,         // 9
  _SEG_A | _SEG_B | _SEG_C | _SEG_D | _SEG_E | _SEG_G,         // a
  _SEG_C | _SEG_D | _SEG_E | _SEG_F | _SEG_G,                  // b
  _SEG_G | _SEG_E | _SEG_D,                                    // c
  _SEG_B | _SEG_C | _SEG_D | _SEG_E | _SEG_G,                  // d
  _SEG_A | _SEG_F | _SEG_E | _SEG_D | _SEG_G,                  // E
  _SEG_A | _SEG_F | _SEG_E | _SEG_G,                           // F
  _SEG_G | _SEG_E | _SEG_C,                                    // n
  _SEG_G | _SEG_E | _SEG_C | _SEG_D                            // o
};

volatile long remainingTime = 0;
volatile bool btPressState[TOTAL_BTTNS];
volatile bool btPrevState[TOTAL_BTTNS];
volatile byte digits[TOTAL_DIGITS];
volatile bool showDigits[TOTAL_DIGITS];
volatile byte curState = STATE_IDLE;
volatile char curEditDigit = 0;

/********************************************************************************
 **                                                                            **
 **                 I N T E R R U P T   H A N D L E R S                        **
 **                                                                            **
 ********************************************************************************/
// This interrupt is called once a millisecond.
SIGNAL(TIMER0_COMPA_vect) {
  if (curState == STATE_RUNNING && remainingTime > 0) remainingTime--;
}

/********************************************************************************
 **                                                                            **
 **                        A U X   F U N C T I O N S                           **
 **                                                                            **
 ********************************************************************************/
void display_off(){
  byte d;

  // Disable all digits
  for (d = 0; d < TOTAL_DIGITS; d++) {
    digitalWrite(digit_map[d], HIGH);
  }
}

void resetTime(){
  byte d;
  for (d = 0; d < TOTAL_DIGITS; d++) digits[d] = 0;
}

void show_digit (byte n, byte data){
  byte c;
  // Write segment data
  for (c = 0; c < 7; c++) {
    digitalWrite(segment_map[c], data & 1 ? HIGH : LOW);
    data >>= 1;
  }

  // Enable the digit we want to show
  digitalWrite(digit_map[n % TOTAL_DIGITS], LOW);
}

void hide_digit (byte n){
  // Disable the digit we want to show
  digitalWrite(digit_map[n % TOTAL_DIGITS], HIGH);
}

void set_time (long tSeconds){
  byte secDisplay = tSeconds % 60;
  byte minDisplay = tSeconds / 60;

  // Minutes
  digits[0] = minDisplay / 10;
  digits[1] = minDisplay % 10;
  // Seconds
  digits[2] = secDisplay / 10;
  digits[3] = secDisplay % 10;
}

void startWithTimeOnDisplay(){
  long secs = digits[0]*600;

  secs += digits[1]*60;
  secs += digits[2]*10;
  secs += digits[3];

  remainingTime = secs*1000;
  curState = STATE_RUNNING;
}

bool button_read(int button){
  return (digitalRead(button) == 0);
}

bool is_new_press(byte b){
  return (btPressState[b] == true) && (btPrevState[b] == false);
}

bool is_button_pressed(byte b){
  return (btPressState[b] == true);
}


/********************************************************************************
 **                                                                            **
 **                                  S E T U P                                 **
 **                                                                            **
 ********************************************************************************/
void setup() {
  byte c;

  // Output
  pinMode(output_pin, OUTPUT);
  digitalWrite(output_pin, LOW);

  // Set the digit control pins, and set their outputs to HIGH (disabling those digits)
  for (c = 0; c < TOTAL_DIGITS; c++){
    pinMode(digit_map[c], OUTPUT);
    digitalWrite(digit_map[c], HIGH);
  }
  // Same for segments. In this case LOW disables them.
  for (c = 0; c < 7; c++){
    pinMode(segment_map[c], OUTPUT);
    digitalWrite(segment_map[c], LOW);
  }
  // Buttons
  for (c = 0; c < TOTAL_BTTNS; c++) {
    pinMode (button_pins[c], INPUT_PULLUP);
    digitalWrite(button_pins[c], INPUT_PULLUP);  // For analog pins
    btPressState[c] = false;
    btPrevState[c] = false;
  }

  // Timer0 is already used for millis() - we'll just interrupt somewhere
  // in the middle and call the "Compare A" function below
  OCR0A = 0xAF;
  TIMSK0 |= _BV(OCIE0A);

  
  //Serial.begin(9600);
}

/********************************************************************************
 **                                                                            **
 **                                L O O P                                     **
 **                                                                            **
 ********************************************************************************/
void loop() {
  byte b;
  bool show;
  bool outVal = false;

  // By default all digits will be shown
  for (b = 0; b < TOTAL_DIGITS; b++) showDigits[b] = true;

  // State-dependant code ----------------
  switch (curState){
    case STATE_IDLE:
      curEditDigit = -1;
      if (is_new_press(BTTN_NEXT)) {
        curEditDigit = 0;
        curState = STATE_EDITING;
      }else if (is_new_press(BTTN_PREV)) {
        curEditDigit = TOTAL_DIGITS-1;
        curState = STATE_EDITING;
      } else if (is_new_press(BTTN_INC)){
        // Pressing "INC" should take you to edit the last digit (seconds)
        curEditDigit = TOTAL_DIGITS-1;
        curState = STATE_EDITING;
      }else if (is_new_press(BTTN_START) && is_new_press(BTTN_SAFE)){
        startWithTimeOnDisplay();
      }
      break;

    case STATE_INTERRUPTED:
      show = (millis() % 300 < 150);
      for (b = 0; b < TOTAL_DIGITS; b++) showDigits[b] = show;

      // Un-pause immediately if it's safe to do so.
      if (is_button_pressed(BTTN_SAFE)) curState = STATE_RUNNING;
      break;

    case STATE_PAUSED:
      show = (millis() % 500 < 250);
      for (b = 0; b < TOTAL_DIGITS; b++) showDigits[b] = show;

      // Resume the process (only if it's safe)
      if (is_new_press(BTTN_START) && is_button_pressed(BTTN_SAFE)) {
        curState = STATE_RUNNING;
      }
      // Or return to IDLE upon any other button press
      else if (is_new_press(BTTN_NEXT) || is_new_press(BTTN_PREV) || is_new_press(BTTN_INC)) {
        curState = STATE_IDLE;
      }
      break;

    case STATE_FINISHED:
      show = (millis() % 500 < 250);
      for (b = 0; b < TOTAL_DIGITS; b++) showDigits[b] = show;

      digits[0] = CHAR_D;
      digits[1] = CHAR_O;
      digits[2] = CHAR_N;
      digits[3] = CHAR_E;
      // Any key gets out of this mode
      for (b = 0; b < TOTAL_BTTNS; b++) {
        if (is_new_press(b)) {
          resetTime();
          curState = STATE_IDLE;
          break;
        }
      }
      break;

    case STATE_RUNNING:
      // Update time
      set_time (remainingTime / 1000);
      if (remainingTime == 0) {
        curState = STATE_FINISHED;
      }else if (is_button_pressed(BTTN_SAFE) == false){
        curState = STATE_INTERRUPTED;
      }else if (is_new_press(BTTN_START) == true){
        curState = STATE_PAUSED;
      }else{
        outVal = true;
      }
      break;

    case STATE_EDITING:
      curEditDigit = curEditDigit % TOTAL_DIGITS;
      showDigits[curEditDigit] = (millis() % 400 < 200);
      if (is_new_press(BTTN_INC)){
        digits[curEditDigit]++;
        if (digits[curEditDigit] > digit_max[curEditDigit]) {
          digits[curEditDigit] = 0;
        }
      }else if (is_new_press(BTTN_PREV)){
        curEditDigit--;
      }else if (is_new_press(BTTN_NEXT)){
        curEditDigit++;
      }else if (is_new_press(BTTN_START)){
        // Reset time and go back to idle if the "INC" button is also pressed with "START", otherwise start the process (only if safe)
        if (is_button_pressed(BTTN_INC)){
          resetTime();
          curState = STATE_IDLE;
        }else if (is_button_pressed(BTTN_SAFE)){
          startWithTimeOnDisplay();
        }
      }
      if (curEditDigit < 0) curEditDigit = TOTAL_DIGITS-1;
      if (curEditDigit >= TOTAL_DIGITS) curEditDigit = 0;
    break;
  }

   // Write the approrpriate value to the output pin
   digitalWrite(output_pin, outVal);

  // Read buttons
  for (b = 0; b < TOTAL_BTTNS; b++) {
    btPrevState[b] = btPressState[b];
    btPressState[b] = button_read(button_pins[b]);
  }

   // Update digits on the 7-seg display
   // This will also act as a delay between loops helping debounce button reads
   for (b = 0; b < TOTAL_DIGITS; b++){
    display_off();
    if (showDigits[b]) show_digit (b, digit_segmap[digits[b]]);
    delayMicroseconds(500);
   }

  // Read buttons again and confirm it's indeed pressed.
  for (b = 0; b < TOTAL_BTTNS; b++) {
    btPressState[b] = btPressState[b] && button_read(button_pins[b]);
  }
}
