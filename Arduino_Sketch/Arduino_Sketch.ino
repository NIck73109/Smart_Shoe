#define ANALOG_IN_PIN0      A0
#define ANALOG_IN_PIN1      A1
#define ANALOG_IN_PIN2      A2
#define ANALOG_IN_PIN3      A3

unsigned long currentMillis;        // store the current value from millis()
unsigned long previousMillis;       // for comparison with currentMillis
int samplingInterval = 250;          // how often to run the main loop (in ms)

int numSensors = 30;
int SensorValue[30];
int i = 0;

void setup()
{
  // start serial port at 9600 bps:
  Serial.begin(9600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }
  while(i < numSensors){
    SensorValue[i] = 0;
    i++; 
  }
}
void loop()
{
  currentMillis = millis();
  if (currentMillis - previousMillis > samplingInterval)
  {
    previousMillis += millis();
    // TODO: Make this a for loop to iterate through the number of sensors
    // or icnrease the number of sensor outputs to the number of sensors desired
    SensorValue[0] = analogRead(ANALOG_IN_PIN0)/4;
    Serial.write(1); // Used to identify sensor 1
    Serial.write(SensorValue[0]);
    
    SensorValue[1] = analogRead(ANALOG_IN_PIN1)/4;
    Serial.write(2); // Used to identify sensor 1
    Serial.write(SensorValue[1]);
    
    SensorValue[2] = analogRead(ANALOG_IN_PIN2)/4;
    Serial.write(3); // Used to identify sensor 1
    Serial.write(SensorValue[2]);
    
    SensorValue[3] = analogRead(ANALOG_IN_PIN3)/4;
    Serial.write(4); // Used to identify sensor 1
    Serial.write(SensorValue[3]);
  
  }
  delay(1000); // Delay in miliseconds, adjust to 10 after testing
}
