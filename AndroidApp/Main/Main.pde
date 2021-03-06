import controlP5.*;
import processing.serial.*;
import grafica.*;

// The serial port:
Serial USBport; 

ControlP5 cp5;
int numSensors = 30;
boolean USBenabled = false;
long timeNow, timeDelta;
double time1, time2;
String timeRecorded;
double[][][] data = new double[numSensors][50000][3];

double tempTime;

// Variables used to count the number of data values
int aC = 0; int bC = 0; int cC = 0; int dC = 0; int eC = 0; int fC = 0;
int gC = 0; int hC = 0; int iC = 0; int jC = 0; int kC = 0; int lC = 0;
int mC = 0; int nC = 0; int oC = 0; int pC = 0; int qC = 0; int rC = 0;
int sC = 0; int tC = 0; int uC = 0; int vC = 0; int wC = 0; int xC = 0;
int yC = 0; int zC = 0;
int Counter = 0;  // TODO: Add counter to make sure no more than 50k data points are recorded

void setup(){
    size(500,500);
    background(255);
    cp5 = new ControlP5(this);
    Test();
    
   
     cp5.addButton("enable")
       .setPosition(125,100)
       //.setImages(graphBtn)
       .setSize(250,50)
       .setCaptionLabel("Enable Serial Port")
       ;
       
    cp5.getController("enable")
       .getCaptionLabel()
       .toUpperCase(false)
       .setSize(30)
       ;
       
    cp5.addButton("saveData")
       .setPosition(125,300)
       //.setImages(graphBtn)
       .setSize(250,50)
       .setCaptionLabel("Save Data")
       ;
       
    cp5.getController("saveData")
       .getCaptionLabel()
       .toUpperCase(false)
       .setSize(30)
       ;
       
   cp5.addSlider("sliderSensors")
     .setPosition(400,150)
     .setSize(20,100)
     .setRange(1,30)
     .setNumberOfTickMarks(30)
     .setValue(30)
     ;        

   // TODO: Add in a check system to tell if the sensors are working

    println(Serial.list());
}
byte[] inBuffer = new byte[2];

void draw() {
  background(color(247, 17, 244));
  if (USBport != null){
  while (USBport.available() > 0 && USBenabled){
    
     //inBuffer = USBport.readBytes();
      USBport.readBytes(inBuffer);
      if (inBuffer != null) {
          timeDelta = System.nanoTime();
          time1 = (timeDelta - timeNow);
          time2 = time1/1000000; // Gives time in miliseconds
          int[] tempInput = new int[inBuffer.length];
          //double[] tempData = new double[inBuffer.length];
          int i = 0;
          println(inBuffer.length);
          while(i < 2){
             tempInput[i] = inBuffer[i] & 0xff;
             tempTime = time2; // timeRecorded
             println(tempInput[i]);
             i++;
          }
          sortData(tempInput,tempTime);
          // TODO: Save Report Data (Text to be redisplayed) or statistics for comparison          
      }
    }
  }
}
