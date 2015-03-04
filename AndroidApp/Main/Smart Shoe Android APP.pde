// GUI
/*------------------------------------------------------------------------------
 IMPORT statements required for this sketch
-----------------------------------------------------------------------------*/
// Package for GUI
import controlP5.*;

// Package for Pop-Up Box
import java.util.*;

// Package for Graphs
import grafica.*;

// BT Packages
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.widget.Toast;
import android.view.Gravity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;

import java.util.UUID;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

import android.bluetooth.BluetoothServerSocket;
import android.bluetooth.BluetoothSocket;
public BluetoothSocket scSocket;
/*------------------------------------------------------------------------------
 BT Variables, Initialization and Global Functions
-----------------------------------------------------------------------------*/
boolean foundDevice=false; 
boolean BTisConnected=false; 
String serverName = "ArduinoBasicsServer";

// Message types used by the Handler
public static final int MESSAGE_WRITE = 1;
public static final int MESSAGE_READ = 2;
String readMessage="";

//Get the default Bluetooth adapter
BluetoothAdapter bluetooth = BluetoothAdapter.getDefaultAdapter();

/*The startActivityForResult() within setup() launches an 
 Activity which is used to request the user to turn Bluetooth on. 
 The following onActivityResult() method is called when this 
 Activity exits. */
@Override
protected void onActivityResult(int requestCode, int resultCode, Intent data) {
 if (requestCode==0) {
 if (resultCode == RESULT_OK) {
 ToastMaster("Bluetooth has been switched ON");
 } 
 else {
 ToastMaster("You need to turn Bluetooth ON !!!");
 }
 }
}


/* Create a BroadcastReceiver that will later be used to 
 receive the names of Bluetooth devices in range. */
BroadcastReceiver myDiscoverer = new myOwnBroadcastReceiver();


/* Create a BroadcastReceiver that will later be used to
 identify if the Bluetooth device is connected */
BroadcastReceiver checkIsConnected = new myOwnBroadcastReceiver();


// The Handler that gets information back from the Socket
private final Handler mHandler = new Handler() {
 @Override
 public void handleMessage(Message msg) {
 switch (msg.what) {
 case MESSAGE_WRITE:
 //Do something when writing
 break;
 case MESSAGE_READ:
 //Get the bytes from the msg.obj
 byte[] readBuf = (byte[]) msg.obj;
 // construct a string from the valid bytes in the buffer
 readMessage = new String(readBuf, 0, msg.arg1);
 break;
 }
 }
};
/*------------------------------------------------------------------------------
 GUI Variables and Initialization
-----------------------------------------------------------------------------*/
ControlP5 cp5;
Textarea textAreaOutput; 

float[][][] dataF;
public GPlot plot1, plot2, plot3, plot4;
PShape star;  

Table table, table2;
int rowMax;
double[][] Force;
double[][] T;
float[][] Tf;
double[] tMax;
color[][] c;
String file1 = "pressures.txt";
String file2 = "output.txt";
String file3 = "calibration.txt";
String file4 = "feedback.txt";
double[][][] data1;

PrintWriter output;
PrintWriter calibration;
int Pressure;

boolean isVisible1, isVisible2, isRecording, Update, isCalibrating, isCalibrated;
boolean assymetric;
int[] checkLength;
int Time;
int numSensors = 8;
PImage img, img2;  // Used for the images
// Used for recording time stamps
long timeNow, timeDelta;
double time1, time2;
String timeRecorded;
// For Calibration
String[] CalMax;
String[] CalMin;
String[] CalAve;
Double[] CalMaxD;
Double[] CalMinD;
Double[] CalAveD;
String calibrationFeedbackL;
String calibrationFeedbackR;
String runningFeedbackL;
String runningFeedbackR;
Boolean calEmpty;

/*------------------------------------------------------------------------------
 Setup for GUI and BT
-----------------------------------------------------------------------------*/
void setup() {
  //size(1080,1920);
  orientation(PORTRAIT);
  noStroke();
  
  registerMethod("post", this);
  
  cp5 = new ControlP5(this);
   
/*------------------------------------------------------------------------------
 BT Setup
-----------------------------------------------------------------------------*/

  /*IF Bluetooth is NOT enabled, then ask user permission to enable it */
 if (!bluetooth.isEnabled()) {
 Intent requestBluetooth = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
 startActivityForResult(requestBluetooth, 0);
 }


 /*If Bluetooth is now enabled, then register a broadcastReceiver to report any
 discovered Bluetooth devices, and then start discovering */
 if (bluetooth.isEnabled()) {
 registerReceiver(myDiscoverer, new IntentFilter(BluetoothDevice.ACTION_FOUND));
 registerReceiver(checkIsConnected, new IntentFilter(BluetoothDevice.ACTION_ACL_CONNECTED));

 //Start bluetooth discovery if it is not doing so already
 if (!bluetooth.isDiscovering()) {
 bluetooth.startDiscovery();
 }
 }
 
/*------------------------------------------------------------------------------
 Font package
-----------------------------------------------------------------------------*/
  PFont font = createFont("Arial", 48);
  cp5.setControlFont(font);
/*------------------------------------------------------------------------------
 Create buttons
-----------------------------------------------------------------------------*/

  cp5.addButton("ShowGraphs")
     .setPosition(0,0)
     //.setImages(graphBtn)
     .setSize(269,100)
     .setCaptionLabel("Show Graphs")
     ;

  cp5.addButton("ShowPressureMap")
     .setPosition(270,0)
     //.setImages(mapBtn)
     .setSize(269,100)
     .setCaptionLabel("Show Map")
     ;
     
  cp5.addButton("HideAll")
     .setPosition(540,0)
     //.setImages(hideBtn)
     //.updateSize()
     .setSize(269,100)
     .setCaptionLabel("Hide All")
     ;
    
  cp5.addButton("Calibrate")
     .setPosition(810,0)
    // .setImages(calibrateBtn)
     .setSize(269,100)
     .setCaptionLabel("Calibrate")
     ;
    
  cp5.addButton("StartRecording")
     .setPosition(0,101)
     .setSize(269,100)
     .setCaptionLabel("Start Recording")
     ;
    
  cp5.addButton("StopRecording")
     .setPosition(270,101)
     .setSize(269,100)
     .setCaptionLabel("Stop Recording")
     ; 
   
  cp5.addButton("UpdateData")
     .setPosition(540,101)
     .setSize(269,100)
     .setCaptionLabel("Update Data")
     ;
     
  cp5.addButton("Feedback")
     .setPosition(810,101)
     .setSize(269,100)
     .setCaptionLabel("Feedback")
     ;
        
/*------------------------------------------------------------------------------
  Change button labels
-----------------------------------------------------------------------------*/ 

  cp5.getController("ShowGraphs")
    .getCaptionLabel()
    .toUpperCase(false)
    .setSize(30)
    ;
    
  cp5.getController("ShowPressureMap")
    .getCaptionLabel()
    .toUpperCase(false)
    .setSize(30)
    ;
   
  cp5.getController("HideAll")
    .getCaptionLabel()
    .toUpperCase(false)
    .setSize(30)
    ;
   
  cp5.getController("Calibrate")
    .getCaptionLabel()
    .toUpperCase(false)
    .setSize(30)
    ;

  cp5.getController("StartRecording")
    .getCaptionLabel()
    .toUpperCase(false)
    .setSize(30)
    ;
    
  cp5.getController("StopRecording")
    .getCaptionLabel()
    .toUpperCase(false)
    .setSize(30)
    ;
    
  cp5.getController("UpdateData")
    .getCaptionLabel()
    .toUpperCase(false)
    .setSize(30)
    ;
    
  cp5.getController("Feedback")
    .getCaptionLabel()
    .toUpperCase(false)
    .setSize(30)
    ;  
  
/*------------------------------------------------------------------------------
 Data acquisition, assignment, and adding the slider
-----------------------------------------------------------------------------*/
double[][][] data1 = loadData(file1, numSensors);
if (data1 != null){
assignData(data1);
}
AddSlider();
/*------------------------------------------------------------------------------
 Creating Graphs
-----------------------------------------------------------------------------*/    
int nPoints = 100;
GPointsArray points1 = new GPointsArray(nPoints);
GPointsArray points2 = new GPointsArray(nPoints);
GPointsArray points3 = new GPointsArray(nPoints);
GPointsArray points4 = new GPointsArray(nPoints);

// Create a new plot and set its position on the screen
  plot1 = new GPlot(this);
  plot1.setPos(50, 230);
  plot2 = new GPlot(this);
  plot2.setPos(50, 590);
  plot3 = new GPlot(this);
  plot3.setPos(50, 950);
  plot4 = new GPlot(this);
  plot4.setPos(50, 1310);
  
  // Set the plot title and the axis labels
  plot1.getXAxis().setAxisLabelText("Time");
  plot1.getYAxis().setAxisLabelText("Pressure");
  plot1.getXAxis().getAxisLabel().setTextAlignment(LEFT);
  plot1.setAllFontProperties("Arial", (0), 25);
  plot1.setTitleText("Left Heel");
  plot1.setYLim(0, 255);
  plot1.setDim(900, 280);
  plot1.setPoints(points1);
  
  // Set the plot title and the axis labels
  plot2.getXAxis().setAxisLabelText("Time");
  plot2.getYAxis().setAxisLabelText("Pressure");
  plot2.getXAxis().getAxisLabel().setTextAlignment(LEFT);
  plot2.setAllFontProperties("Arial", (0), 25);
  plot2.setTitleText("Left Side of Left Foot");
  plot2.setYLim(0, 255);
  plot2.setDim(900, 280);
  plot2.setPoints(points2);
  
  // Set the plot title and the axis labels
  plot3.getXAxis().setAxisLabelText("Time");
  plot3.getYAxis().setAxisLabelText("Pressure");
  plot3.getXAxis().getAxisLabel().setTextAlignment(LEFT);
  plot3.setAllFontProperties("Arial", (0), 25);
  plot3.setTitleText("Right Side of Left Foot");
  plot3.setYLim(0, 255);
  plot3.setDim(900, 280);
  plot3.setPoints(points3);
  
  // Set the plot title and the axis labels
  plot4.getXAxis().setAxisLabelText("Time");
  plot4.getYAxis().setAxisLabelText("Pressure");
  plot4.getXAxis().getAxisLabel().setTextAlignment(LEFT);
  plot4.setAllFontProperties("Arial", (0), 25);
  plot4.setTitleText("Ball of Left Foot");
  plot4.setYLim(0, 255);
  plot4.setDim(900, 280);
  plot4.setPoints(points4);
  
  star = loadShape("star.svg");
  star.translate(-star.width/2, -star.height/2);
  star.disableStyle(); 
   
  img = loadImage("Footprints.JPG"); 
  imageMode(CORNER);
  
  img2 = loadImage("ColorBar.jpg");
  imageMode(CORNER);

/*------------------------------------------------------------------------------
 Converting force values to colors
-----------------------------------------------------------------------------*/
color c[][] = forceToColor(numSensors, data1);
// File for recorded values
output = createWriter("output.txt");
// File for calibration
calibration = createWriter("calibration.txt");
} // End Setup
/*------------------------------------------------------------------------------
 Draw
-----------------------------------------------------------------------------*/
void draw(){
 if (foundDevice) {
 if (BTisConnected) {
 ToastMaster("Connected!");
 }
 else {
 //text("Not connected");  
 }
 }

 //Display anything received from Arduino
 text(readMessage, 300, 500);
 
  if (isRecording && !isCalibrating){
    timeDelta = System.nanoTime();
    time1 = (timeDelta - timeNow);
    time2 = time1/1000000;
    timeRecorded = String.valueOf(time2);
    output.println(readMessage + "," + timeRecorded);  
  }
// Graphs   
  if (isVisible1 && !isRecording) {
    background(255);
  plot1.setXLim(Tf[0][Time]-5, Tf[0][Time]+5);
  plot1.beginDraw();
    plot1.drawBackground();
    plot1.drawBox();
    plot1.drawXAxis();
    plot1.drawYAxis();
    plot1.drawTopAxis();
    plot1.drawRightAxis();
    plot1.drawTitle();
    plot1.drawLabels();
    plot1.drawLines();
    plot1.drawGridLines(GPlot.BOTH);
    plot1.drawPoints(star);
  plot1.endDraw();
  
  plot2.setXLim(Tf[1][Time]-5, Tf[1][Time]+5);
  plot2.beginDraw();
    plot2.drawBackground();
    plot2.drawBox();
    plot2.drawXAxis();
    plot2.drawYAxis();
    plot2.drawTopAxis();
    plot2.drawRightAxis();
    plot2.drawTitle();
    plot2.drawLabels();
    plot2.drawLines();
    plot2.drawGridLines(GPlot.BOTH);
    plot2.drawPoints(star);
  plot2.endDraw();
  
  plot3.setXLim(Tf[2][Time]-5, Tf[2][Time]+5);
  plot3.beginDraw();
    plot3.drawBackground();
    plot3.drawBox();
    plot3.drawXAxis();
    plot3.drawYAxis();
    plot3.drawTopAxis();
    plot3.drawRightAxis();
    plot3.drawTitle();
    plot3.drawLabels();
    plot3.drawLines();
    plot3.drawGridLines(GPlot.BOTH);
    plot3.drawPoints(star);
  plot3.endDraw();
  
  plot4.setXLim(Tf[3][Time]-5, Tf[3][Time]+5);
  plot4.beginDraw();
    plot4.drawBackground();
    plot4.drawBox();
    plot4.drawXAxis();
    plot4.drawYAxis();
    plot4.drawTopAxis();
    plot4.drawRightAxis();
    plot4.drawTitle();
    plot4.drawLabels();
    plot4.drawLines();
    plot4.drawGridLines(GPlot.BOTH);
    plot4.drawPoints(star);
  plot4.endDraw();
  
  }
  
// Pressure Map
  if (isVisible2 && !isRecording){ 
    background(255);
    image(img,150,300,900,1400); 
    image(img2,20,300,125,1400);
    
    // Left Heel
    ellipseMode(CENTER);
    fill(c[0][Time]);
    ellipse(450,1500,50,50);
    
    //(x,y,x_size,y_size)
    // Right Heel
    ellipseMode(CENTER);
    fill(c[4][Time]);
    ellipse(750,1500,50,50);
    
    // Left Side (Left Foot)
    ellipseMode(CENTER);
    fill(c[1][Time]);
    ellipse(300,1050,50,50);
    
    // Left Side (Right Foot)
    ellipseMode(CENTER);
    fill(c[5][Time]);
    ellipse(725,1050,50,50);
    
    // Right Side (Left Foot)
    ellipseMode(CENTER);
    fill(c[2][Time]);
    ellipse(475,1050,50,50);
    
    // Right Side (Right Foot)
    ellipseMode(CENTER);
    fill(c[6][Time]);
    ellipse(900,1050,50,50);
    
    // Top (Left Foot)
    ellipseMode(CENTER);
    fill(c[3][Time]);
    ellipse(400,650,50,50);
    
    // Top (Right Foot)
    ellipseMode(CENTER);
    fill(c[7][Time]);
    ellipse(800,650,50,50);
  }
// Blank bakcground  
  if (!isVisible1 && !isVisible2) background(255);
  
// Calibration
  if (isCalibrating && !isRecording){
    // Times recorded and Time2 are in miliseconds
    // Resolution -- The draw function is able to record a value ~ every 0.2-1 mSec
    timeNow = System.nanoTime();
    //time2 = 0; 
    while (time2 < 3000) {
       timeDelta = System.nanoTime(); 
       time1 = (timeDelta - timeNow);
       time2 = time1/1000000;
       timeRecorded = String.valueOf(time2);
       calibration.println(readMessage + "," + timeRecorded); 
       println(time2);
     }
     CalibrateData();          
     addCalibrationOutput();
     isCalibrating = false;   
  }

}
/*------------------------------------------------------------------------------
 Button Events
-----------------------------------------------------------------------------*/ 
public void controlEvent(ControlEvent theEvent) {
  println(theEvent.getController().getName());
}

public void ShowGraphs() {
  println("a button event from Show Graphs");
  isVisible1 = true;
  isVisible2 = false;
  redraw();
}

public void ShowPressureMap() {
  println("a button event from Show Pressure-Map");
  isVisible1 = false;
  isVisible2 = true;
  redraw();
}

public void HideAll() {
  println("a button event from Hide All");
  isVisible1 = false;
  isVisible2 = false;
  redraw();  
}

public void Calibrate() {
  println("a button event from Calibrate");
  addCalibrationPopUp();
}

public void StartRecording() {
  isRecording = true;
  isVisible1 = false;
  isVisible2 = false;
  timeNow = System.nanoTime();
  redraw();
}

public void StopRecording() {
  println("a button event from Stop Recording");
  output.flush();  // Writes the remaining data to the file
  output.close();  // Finishes the file
  isRecording = false;
  redraw();
}

public void UpdateData() {
  isVisible1 = false;
  isVisible2 = false;
  if (isRecording) {
    StopRecording();
  }
 
  double[][][] data1 = loadData(file1, numSensors);
  if (data1 != null){
  assignData(data1);
  
  GPointsArray points1 = new GPointsArray(rowMax);
  GPointsArray points2 = new GPointsArray(rowMax);
  GPointsArray points3 = new GPointsArray(rowMax);
  GPointsArray points4 = new GPointsArray(rowMax);
  
  //Fix this
  color[][] c = forceToColor(numSensors, data1);

  for (int j =0; j < data1[0][0][2]; j++) {
    points1.add(dataF[0][j][1], dataF[0][j][0]);
  }
  for (int j =0; j < data1[1][0][2]; j++) {
    points2.add(dataF[1][j][1], dataF[1][j][0]);
    println(dataF[1][j][0]);
  }
  for (int j =0; j < data1[2][0][2]; j++) {  
    points3.add(dataF[2][j][1], dataF[2][j][0]);
  }
  for (int j =0; j < data1[3][0][2]; j++) {  
    points4.add(dataF[3][j][1], dataF[3][j][0]);
  }  
  
  plot1.setPoints(points1);
  plot2.setPoints(points2);
  plot3.setPoints(points3);
  plot4.setPoints(points4);
  
  AddSlider();
  redraw(); 
  }
}
public void Feedback() {
  println("a button event from Feedback");
  if (!isCalibrated){
    addCheckCalibration();
  }
  else {
    ConfigureFeedback();
  }
}
/*------------------------------------------------------------------------------
 Creating a slidder
-----------------------------------------------------------------------------*/
 public void AddSlider() {
   cp5.addSlider("Time")
     .setPosition(100,1700)
     .setSize(900,50)
     .setRange(0,rowMax-1)
     .setValue(0)
     .setNumberOfTickMarks(rowMax)
     .setCaptionLabel("Point Number")
     .setColorValueLabel(0)
     .setColorCaptionLabel(0)
     ;
  
    // reposition the Label for controller 'slider'
    cp5.getController("Time").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
    cp5.getController("Time").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
 }
/*------------------------------------------------------------------------------
 Load Data
-----------------------------------------------------------------------------*/
double[][][] loadData(String file, int numSensors) {
Table table;
char holder;
String strHolder;
int tableLength;
int a,b,c,d,e,f,g,h;

if (file == "output.txt"){
  table = loadTable("output.txt","csv");
}
else if (file == "pressures.txt"){
  table = loadTable("pressures.txt","csv");  
}
else if (file == "calibration.txt"){
  table = loadTable("calibration.txt","csv"); 
}
else{
  table = loadTable("pressures.txt","csv");  
}

tableLength = table.getRowCount();
//rowMax = table.getRowCount();
double[][][] data = new double[numSensors][tableLength][3];
// Data is formatted such that data[sensor #][line #]
// The third set of brackets refers to the data type
// [0] indicates force / pressure
// [1] indicates time
// [2] indicates the number of lines

a = 0; b = 0; c = 0; d = 0;
e = 0; f = 0; g = 0; h = 0;

for (int i = 0; i < tableLength; i++){    
  strHolder = table.getString(i,0);
  holder = strHolder.charAt(0);
  switch(holder) {
    case 'A': // Left Heel
      data[0][a][0] = table.getDouble(i,1); 
      data[0][a][1] = table.getDouble(i,2);
      a++;
      break;
    case 'B': // Distal Sensor Left Foot
      data[1][b][0] = table.getDouble(i,1); 
      data[1][b][1] = table.getDouble(i,2);
      b++;
      break;
    case 'C': // Medial Sensor Left Foot
      data[2][c][0] = table.getDouble(i,1); 
      data[2][c][1] = table.getDouble(i,2);
      c++;
      break;
    case 'D': // Toe Sensor Left Foot
      data[3][d][0] = table.getDouble(i,1); 
      data[3][d][1] = table.getDouble(i,2);
      d++;
      break;
    case 'E': // Right Heel
      data[4][e][0] = table.getDouble(i,1); 
      data[4][e][1] = table.getDouble(i,2);
      e++;
      break;
    case 'F': // Distal Sensor Right Foot
      data[5][f][0] = table.getDouble(i,1); 
      data[5][f][1] = table.getDouble(i,2);
      f++;
      break;
    case 'G': // Medial Sensor Right Foot
      data[6][g][0] = table.getDouble(i,1); 
      data[6][g][1] = table.getDouble(i,2);
      g++;
      break;
    case 'H': // Toe Sensor Right Foot
      data[7][h][0] = table.getDouble(i,1); 
      data[7][h][1] = table.getDouble(i,2);
      h++;
      break;
    default: // Didn't have identifier
      println("None");
      break;
  }
}
int[] checkLength = {a,b,c,d,e,f,g,h};
checkLength = sort(checkLength);
  if (checkLength[0] - checkLength[7] == 0 && checkLength[0] != 0){
    rowMax = tableLength/8;
    for(int i =0; i < numSensors; i++){
      data[i][0][2] = rowMax;
    }
  }
  // Assymmetric Data
  else {
    assymetric = true;
    data[0][0][2] = a;
    data[1][0][2] = b;
    data[2][0][2] = c;
    data[3][0][2] = d;
    data[4][0][2] = e;
    data[5][0][2] = f;
    data[6][0][2] = g;
    data[7][0][2] = h;
  }
  return data;
}
/*------------------------------------------------------------------------------
 Data acquisition and assignment
-----------------------------------------------------------------------------*/
void assignData(double[][][] data) {
 if(!assymetric) {
  rowMax = (int) data[0][0][2];

  Force = new double[numSensors][rowMax];
  T = new double[numSensors][rowMax];
  Tf = new float[numSensors][rowMax];
  tMax = new double[numSensors];
  c = new color[numSensors][rowMax];  // Color of the sensors
  dataF = new float[numSensors][rowMax][3];

  for (int i = 0; i < numSensors; i++) {
    for (int j = 0; j < rowMax; j++) {
      Tf[i][j] = (float) data[i][j][1];
      Force[i][j] = data[i][j][0];
      T[i][j] = data[i][j][1];
      dataF[i][j][1] = (float) data[i][j][1];
      dataF[i][j][0] = (float) data[i][j][0];
    } 
    // Max time value recorded
    tMax[i] = T[i][rowMax-1];
  }
 }
  
  else{
    int[] rowMax2 = new int[numSensors];
    rowMax = checkLength[7];
    Force = new double[numSensors][rowMax];
    T = new double[numSensors][rowMax];
    Tf = new float[numSensors][rowMax];
    tMax = new double[numSensors];
    c = new color[numSensors][rowMax];  // Color of the sensors
    dataF = new float[numSensors][rowMax][3];
    
    for (int i = 0; i < numSensors; i++) {
      for (int j =0; j < data[i][0][2]; j++) {
        Tf[i][j] = (float) data[i][j][1];
        Force[i][j] = data[i][j][0];
        T[i][j] = data[i][j][1];
        dataF[i][j][1] = (float) data[i][j][1];
        dataF[i][j][0] = (float) data[i][j][0];
      }
      // Max time value recorded
      rowMax2[i] = (int) data[i][0][2];
      tMax[i] = T[i][rowMax2[i]];
    }
    
   }
}

/*------------------------------------------------------------------------------
 Converting force values to colors
-----------------------------------------------------------------------------*/
public color[][] forceToColor(int numSensors, double data[][][]){
  c = new color[numSensors][rowMax];  // Color of the sensors  

  for (int i = 0; i < numSensors; i++){
    for (int j = 0; j < data[i][0][2]; j++) {
     if ((data[i][j][0] > 250)){
       c[i][j] = color(255,0,0); // Red
     } else if ((data[i][j][0] > 240) && (data[i][j][0] < 251)){
       c[i][j] = color(255,51,0);
     } else if ((data[i][j][0] > 230) && (data[i][j][0] < 241)){
       c[i][j] = color(255,102,0);
     } else if ((data[i][j][0] > 220) && (data[i][j][0] < 231)){
       c[i][j] = color(255,153,0);
     } else if ((data[i][j][0] > 210) && (data[i][j][0] < 221)){
       c[i][j] = color(255,204,0);
     } else if ((data[i][j][0] > 200) && (data[i][j][0] < 211)){
       c[i][j] = color(255,255,0); // Yellow
     } else if ((data[i][j][0] > 190) && (data[i][j][0] < 201)){
       c[i][j] = color(204,255,0);
     } else if ((data[i][j][0] > 180) && (data[i][j][0] < 191)){
       c[i][j] = color(153,255,0);
     } else if ((data[i][j][0] > 170) && (data[i][j][0] < 181)){
       c[i][j] = color(102,255,0);
     } else if ((data[i][j][0] > 160) && (data[i][j][0] < 171)){
       c[i][j] = color(51,255,0);
     } else if ((data[i][j][0] > 150) && (data[i][j][0] < 161)){
       c[i][j] = color(0,255,0); // Green
     } else if ((data[i][j][0] > 140) && (data[i][j][0] < 151)){
       c[i][j] = color(0,255,51);
     } else if ((data[i][j][0] > 130) && (data[i][j][0] < 141)){
       c[i][j] = color(0,255,102);
     } else if ((data[i][j][0] > 120) && (data[i][j][0] < 131)){
       c[i][j] = color(0,255,153);
     } else if ((data[i][j][0] > 110) && (data[i][j][0] < 121)){
       c[i][j] = color(0,255,204);
     } else if ((data[i][j][0] > 100) && (data[i][j][0] < 111)){
       c[i][j] = color(0,255,255); // Teal
     } else if ((data[i][j][0] > 90) && (data[i][j][0] < 101)){
       c[i][j] = color(0,204,255);
     } else if ((data[i][j][0] > 80) && (data[i][j][0] < 91)){
       c[i][j] = color(0,153,255);
     } else if ((data[i][j][0] > 70) && (data[i][j][0] < 81)){
       c[i][j] = color(0,102,255);
     } else if ((data[i][j][0] > 60) && (data[i][j][0] < 71)){
       c[i][j] = color(0,51,255);
     } else if ((data[i][j][0] > 50) && (data[i][j][0] < 61)){
       c[i][j] = color(0,0,255); // Blue
     } else if ((data[i][j][0] > 40) && (data[i][j][0] < 51)){
       c[i][j] = color(0,0,204);
     } else if ((data[i][j][0] > 30) && (data[i][j][0] < 41)){
       c[i][j] = color(0,0,153);
     } else if ((data[i][j][0] > 20) && (data[i][j][0] < 31)){
       c[i][j] = color(0,0,102);
     } else if ((data[i][j][0] > 10) && (data[i][j][0] < 21)){
       c[i][j] = color(0,0,51);
     } else if ((data[i][j][0] > 0) && (data[i][j][0] < 11)){
       c[i][j] = color(0,0,25);
     } else if (data[i][j][0] < 1){
       c[i][j] = color(0,0,0); // Black
     }
    }
  }
  return c;
}

/*------------------------------------------------------------------------------
 Popup Box for Calibration
-----------------------------------------------------------------------------*/     
void addCalibrationPopUp() {
  
 final Group nc = cp5.addGroup("CalibrationPopUp")
    .setPosition(90, 300)
    .setSize(900, 350)
    .setBackgroundColor(color(0))
    .hideBar();

 cp5.addTextlabel("label")
   .setPosition(300,30)
   .setGroup("CalibrationPopUp")
   .setText("To Calibrate:")
   .setFont(createFont("Arial",48))
   ;
   
 cp5.addTextlabel("label2")
   .setPosition(40,90)
   .setGroup("CalibrationPopUp")
   .setText("Place your feet together such that the medial portions of your")
   .setFont(createFont("Arial",30))
   ;
   
 cp5.addTextlabel("label3")
   .setPosition(100,135)
   .setGroup("CalibrationPopUp")
   .setText("feet are touching and hold this stance for 3 seconds.")
   .setFont(createFont("Arial",30))
   ;
   
 cp5.addTextlabel("label4")
   .setPosition(75,230)
   .setGroup("CalibrationPopUp")
   .setText("Press Okay when you are ready to begin calibration.")
   .setFont(createFont("Arial",30))
   ;
    
 cp5.addButton("Okay")
     .setPosition(0, 275)
     .setSize(449, 75)
     .setGroup("CalibrationPopUp")
     .setColorBackground(color(2,52,77))
     .addListener(new ControlListener() {
       public void controlEvent(ControlEvent ev) {
         isCalibrating = true;
         redraw();
         runs.add(new Runnable() { 
           public void run() {
           nc.remove();
           }
         }
         );       
       }
     })
     ;
     
 cp5.getController("Okay")
    .getCaptionLabel()
    .toUpperCase(false)
    .setSize(30)
    ;   
     
 cp5.addButton("Cancel")
     .setPosition(450, 275)
     .setSize(449, 75)
     .setGroup("CalibrationPopUp")
     .setColorBackground(color(2,52,77))
     .addListener(new ControlListener() {
       // when cancel is triggered, add a new runnable to 
       // safely remove the popupxbox from controlP5 in
       // a post event.
       public void controlEvent(ControlEvent ev) {
         isCalibrating = false;
         runs.add(new Runnable() { 
           public void run() {
             nc.remove();
           }
         }
         );
       }
     })
     ;
     
 cp5.getController("Cancel")
    .getCaptionLabel()
    .toUpperCase(false)
    .setSize(30)
    ;      

}
/*------------------------------------------------------------------------------
 Popup Box for Calibration Output
-----------------------------------------------------------------------------*/     
void addCalibrationOutput() {
  
  PFont font2 = createFont("COURIER.TTF", 30);
  
  final Group CO = cp5.addGroup("CalibrationOutput")
    .setPosition(90, 300)
    .setSize(900, 600)
    .setBackgroundColor(color(0))
    //.setBackgroundColor(color(2, 52, 77))
    .hideBar();

 cp5.addTextlabel("label")
   .setPosition(225,30)
   .setGroup("CalibrationOutput")
   .setText("Calibration Results:")
   .setFont(createFont("Arial",48))
   ;
   
 textAreaOutput = cp5.addTextarea("txt")
   .setPosition(100,140)
   .setSize(800,440)
   .setGroup("CalibrationOutput")
   .setFont(font2)
   .setLineHeight(32)
   .setColorBackground(color(0))
   ;
   
 textAreaOutput.setText("|Sensor Location|  Max  |  Min  |  Ave  |" + '\n'
                       +"-----------------------------------------" + '\n'
                       +"|   L.F. Heel   |       |       |       |" + '\n'
                       +"|L.F. Left Side |       |       |       |" + '\n'
                       +"|L.F. Right Side|       |       |       |" + '\n'
                       +"|   L.F. Top    |       |       |       |" + '\n'
                       +"|   R.F. Heel   |       |       |       |" + '\n'
                       +"|R.F. Left Side |       |       |       |" + '\n'
                       +"|R.F. Right Side|       |       |       |" + '\n'
                       +"|   R.F. Top    |       |       |       |" + '\n');
                       
                       
 cp5.addTextlabel("maxValues")
   .setPosition(445,200)
   .setGroup("CalibrationOutput")
   .setText(CalMax[0] + '\n'+
            CalMax[1] + '\n'+
            CalMax[2] + '\n'+
            CalMax[3] + '\n'+
            CalMax[4] + '\n'+
            CalMax[5] + '\n'+
            CalMax[6] + '\n'+
            CalMax[7] + '\n')
   .setFont(createFont("Arial",32))
   ;
   
  cp5.addTextlabel("minValues")
   .setPosition(585,200)
   .setGroup("CalibrationOutput")
   .setText(CalMin[0] + '\n'+
            CalMin[1] + '\n'+
            CalMin[2] + '\n'+
            CalMin[3] + '\n'+
            CalMin[4] + '\n'+
            CalMin[5] + '\n'+
            CalMin[6] + '\n'+
            CalMin[7] + '\n')
   .setFont(createFont("Arial",32))
   ;
 
  cp5.addTextlabel("aveValues")
   .setPosition(735,200)
   .setGroup("CalibrationOutput")
   .setText(CalAve[0] + '\n'+
            CalAve[1] + '\n'+
            CalAve[2] + '\n'+
            CalAve[3] + '\n'+
            CalAve[4] + '\n'+
            CalAve[5] + '\n'+
            CalAve[6] + '\n'+
            CalAve[7] + '\n')
   .setFont(createFont("Arial",32))
   ;  

 cp5.addButton("Accept")
     .setPosition(0, 525)
     .setSize(449, 75)
     .setGroup("CalibrationOutput")
     .setColorBackground(color(2,52,77))
     .addListener(new ControlListener() {
       public void controlEvent(ControlEvent ev) { 
        isCalibrated = true;
         runs.add(new Runnable() { 
           public void run() {
           CO.remove();
           }
         }
         );       
       }
     })
     ;
     
 cp5.getController("Accept")
    .getCaptionLabel()
    .toUpperCase(false)
    .setSize(30)
    ;   
     
 cp5.addButton("Recalibrate")
     .setPosition(450, 525)
     .setSize(449, 75)
     .setGroup("CalibrationOutput")
     .setColorBackground(color(2,52,77))
     .addListener(new ControlListener() {
       // when cancel is triggered, add a new runnable to 
       // safely remove the filechooser from controlP5 in
       // a post event.
       public void controlEvent(ControlEvent ev) {
         addCalibrationPopUp();
         runs.add(new Runnable() { 
           public void run() {
             CO.remove();
           }
         }
         );
       }
     })
     ;
     
 cp5.getController("Recalibrate")
    .getCaptionLabel()
    .toUpperCase(false)
    .setSize(30)
    ;      

}

/*------------------------------------------------------------------------------
 Popup Box: Calibration Uninitialized
-----------------------------------------------------------------------------*/     
void addCheckCalibration() {
  
  final Group CC = cp5.addGroup("CheckCalibration")
    .setPosition(140, 300)
    .setSize(800, 250)
    .setBackgroundColor(color(0))
    .hideBar();

 cp5.addTextlabel("label")
   .setPosition(75,50)
   .setGroup("CheckCalibration")
   .setText("Calibration is required to provide feedback.")
   .setFont(createFont("Arial",32))
   ;
   
 cp5.addTextlabel("label2")
   .setPosition(125,80)
   .setGroup("CheckCalibration")
   .setText("Would you like to calibrate now?")
   .setFont(createFont("Arial",32))
   ;

 cp5.addButton("Yes")
     .setPosition(0, 175)
     .setSize(399, 75)
     .setGroup("CheckCalibration")
     .setColorBackground(color(2,52,77))
     .addListener(new ControlListener() {
       public void controlEvent(ControlEvent ev) {
        addCalibrationPopUp();
         runs.add(new Runnable() { 
           public void run() {
           CC.remove();
           }
         }
         );       
       }
     })
     ;
     
 cp5.getController("Yes")
    .getCaptionLabel()
    .toUpperCase(false)
    .setSize(30)
    ;   
     
 cp5.addButton("No")
     .setPosition(400, 175)
     .setSize(400, 75)
     .setGroup("CheckCalibration")
     .setColorBackground(color(2,52,77))
     .addListener(new ControlListener() {
       // when cancel is triggered, add a new runnable to 
       // safely remove the filechooser from controlP5 in
       // a post event.
       public void controlEvent(ControlEvent ev) {
         runs.add(new Runnable() { 
           public void run() {
             CC.remove();
           }
         }
         );
       }
     })
     ;
     
 cp5.getController("No")
    .getCaptionLabel()
    .toUpperCase(false)
    .setSize(30)
    ;      

}
/*------------------------------------------------------------------------------
 Popup Box: Feedback
-----------------------------------------------------------------------------*/     
void addGiveFeedback() {
  
  final Group GF = cp5.addGroup("GiveFeedback")
    .setPosition(140, 300)
    .setSize(800, 600)
    .setBackgroundColor(color(0))
    //.setBackgroundColor(color(2, 52, 77))
    .hideBar();

 cp5.addTextlabel("label")
   .setPosition(350,30)
   .setGroup("GiveFeedback")
   .setText("Feedback:")
   .setFont(createFont("Arial",32))
   ;
   
 cp5.addTextlabel("label2")
   .setPosition(50,80)
   .setGroup("GiveFeedback")
   .setText("Calibration Feedback:" + '\n' +
             "Left Foot: " + calibrationFeedbackL +
             "Right Foot: " + calibrationFeedbackR)
   .setFont(createFont("Arial",32))
   ;
   
 cp5.addTextlabel("label2")
   .setPosition(50,200)
   .setGroup("GiveFeedback")
   .setText("Running Feedback:" + '\n' +
             "Left Foot: " + runningFeedbackL +
             "Right Foot: " + runningFeedbackR)
   .setFont(createFont("Arial",32))
   ;   

 cp5.addButton("Done")
     .setPosition(200, 525)
     .setSize(400, 75)
     .setGroup("GiveFeedback")
     .setColorBackground(color(2,52,77))
     .addListener(new ControlListener() {
       public void controlEvent(ControlEvent ev) {
         runs.add(new Runnable() { 
           public void run() {
           GF.remove();
           }
         }
         );       
       }
     })
     ;
     
 cp5.getController("Done")
    .getCaptionLabel()
    .toUpperCase(false)
    .setSize(30)
    ;   
  

}
/*------------------------------------------------------------------------------
 Configure Feedback
-----------------------------------------------------------------------------*/
void ConfigureFeedback(){
  // 0-3 = Left Foot, 4-7 = Right Foot
  // 0 = Heel, 1 = Left side of left foot (distal), 2 = Right side of left foot(medial), 3 = Top (Ball of the foot)  
    if (!calEmpty){
      
      Double sumPresLFoot = CalAveD[0] +  CalAveD[1] + CalAveD[2] + CalAveD[3];
      Double sumPresRFoot = CalAveD[4] +  CalAveD[5] + CalAveD[6] + CalAveD[7];
      Double[] Lpercent = {CalAveD[0]/sumPresLFoot, CalAveD[1]/sumPresLFoot, CalAveD[2]/sumPresLFoot, CalAveD[3]/sumPresLFoot};
      Double[] Rpercent = {CalAveD[4]/sumPresRFoot, CalAveD[5]/sumPresRFoot, CalAveD[6]/sumPresRFoot, CalAveD[7]/sumPresRFoot};
      
      // Left foot calibration feedback
      if(Lpercent[0] < .30 && Lpercent[0] > 0.20){
        if(Lpercent[1] < .30 && Lpercent[1] > 0.20){
          if(Lpercent[2] < .30 && Lpercent[2] > 0.20) {
            if(Lpercent[3] < .30 && Lpercent[3] > 0.20) {
              calibrationFeedbackL = "Your left foot is flat.";            
            }  
          }
        }
        else if(Lpercent[1] < .20 && Lpercent[1] > 0.10){
          if(Lpercent[2] < .40 && Lpercent[2] > 0.30) {
            if(Lpercent[3] < .30 && Lpercent[3] > 0.20) {
              calibrationFeedbackL = "Pronation of the left foot.";
            }      
          }
        }
        else if(Lpercent[1] < .40 && Lpercent[1] > 0.30){
           if(Lpercent[2] < .20 && Lpercent[2] > 0.10) {
              if(Lpercent[3] < .30 && Lpercent[3] > 0.20) {
                calibrationFeedbackL = "Supination of the left foot.";
              }
           }
        }                
      }
      else if(Lpercent[0] < .20 && Lpercent[0] > 0.10) {
        if(Lpercent[1] < .30 && Lpercent[1] > 0.20) {
          if(Lpercent[2] < .30 && Lpercent[2] > 0.20) {
            if(Lpercent[3] < .40 && Lpercent[3] > 0.30) {
                calibrationFeedbackL = "Sprinters stance for the left foot.";
            }
          }
        }
      }
      else if(Lpercent[0] < .40 && Lpercent[0] > 0.30) {
        if(Lpercent[1] < .30 && Lpercent[1] > 0.20) {
          if(Lpercent[2] < .30 && Lpercent[2] > 0.20) {
            if(Lpercent[3] < .20 && Lpercent[3] > 0.10) {
                calibrationFeedbackL = "Resting on heel of your left foot.";
            }
          }
        }
      }         
      else calibrationFeedbackL = "Values did not match viable ranges, please recalibrate."; 
        
    // Right foot calibration feedback
    if(Lpercent[0] < .30 && Lpercent[0] > 0.20){
        if(Lpercent[1] < .30 && Lpercent[1] > 0.20){
          if(Lpercent[2] < .30 && Lpercent[2] > 0.20) {
            if(Lpercent[3] < .30 && Lpercent[3] > 0.20) {
              calibrationFeedbackR = "Your right foot is flat.";            
            }  
          }
        }
        else if(Lpercent[1] < .20 && Lpercent[1] > 0.10){
          if(Lpercent[2] < .40 && Lpercent[2] > 0.30) {
            if(Lpercent[3] < .30 && Lpercent[3] > 0.20) {
              calibrationFeedbackR = "Pronation of the right foot.";
            }      
          }
        }
        else if(Lpercent[1] < .40 && Lpercent[1] > 0.30){
           if(Lpercent[2] < .20 && Lpercent[2] > 0.10) {
              if(Lpercent[3] < .30 && Lpercent[3] > 0.20) {
                calibrationFeedbackR = "Supination of the right foot.";
              }
           }
        }                
      }
      else if(Lpercent[0] < .20 && Lpercent[0] > 0.10) {
        if(Lpercent[1] < .30 && Lpercent[1] > 0.20) {
          if(Lpercent[2] < .30 && Lpercent[2] > 0.20) {
            if(Lpercent[3] < .40 && Lpercent[3] > 0.30) {
                calibrationFeedbackR = "Sprinters stance for the right foot.";
            }
          }
        }
      }
      else if(Lpercent[0] < .40 && Lpercent[0] > 0.30) {
        if(Lpercent[1] < .30 && Lpercent[1] > 0.20) {
          if(Lpercent[2] < .30 && Lpercent[2] > 0.20) {
            if(Lpercent[3] < .20 && Lpercent[3] > 0.10) {
                calibrationFeedbackR = "Resting on heel of the right foot.";
            }
          }
        }
      }         
      else calibrationFeedbackR = "Values did not match viable ranges, please recalibrate."; 
    }
    else { 
      calibrationFeedbackL = "No calibration data was recorded.";
      calibrationFeedbackR = "No calibration data was recorded.";
    }
    
    // Running feedback
    // TODO: Ensure Heel to Toe Running Form in Both Feet    
}
/*------------------------------------------------------------------------------
 Load calibration values 
-----------------------------------------------------------------------------*/
void CalibrateData() {
  
  CalMax = new String[numSensors];
  CalMin = new String[numSensors];
  CalAve = new String[numSensors];
  CalMaxD = new Double[numSensors];
  CalMinD = new Double[numSensors];
  CalAveD = new Double[numSensors];
  File file = new File("calibration.txt");
  int[] CalRowMax = new int[numSensors];
  
    if (file.length() > 0){
      double[][][] CalData = loadData(file3, numSensors);
      for (int i = 0; i < numSensors; i++) {
         CalRowMax[i] = (int) CalData[i][0][2];
         CalMaxD[i] = CalData[i][0][0];
         CalMinD[i] = CalData[i][0][0];
                          
         for (int j = 1; j < CalRowMax[i]; j++) {
            if (CalData[i][j][0] > CalMaxD[i]){
               CalMaxD[i] = CalData[i][j][0];
            }
            if (CalData[i][j][0] < CalMinD[i]){
                CalMinD[i] = CalData[i][j][0];
            }
               CalAveD[i] =+ CalData[i][j][0];
         }
         CalAveD[i] =  CalAveD[i]/CalRowMax[i];
         CalMax[i] = String.valueOf(CalMaxD[i]);
         CalMin[i] = String.valueOf(CalMinD[i]);
         CalAve[i] = String.valueOf(CalAveD[i]);
      }  
    }
    else { 
      println("No calibration data");
      calEmpty = true;
    }
    
}
/*------------------------------------------------------------------------------
 Popup Box Runtime
-----------------------------------------------------------------------------*/
final ArrayList<Runnable> runs = new ArrayList<Runnable>();

public void post() {
  Iterator<Runnable> it = runs.iterator();
  while (it.hasNext ()) {
    it.next().run();
    it.remove();
  }
}

/*------------------------------------------------------------------------------
 BT Events
-----------------------------------------------------------------------------*/
/* This BroadcastReceiver will display discovered Bluetooth devices */
public class myOwnBroadcastReceiver extends BroadcastReceiver {
 ConnectToBluetooth connectBT;

 @Override
 public void onReceive(Context context, Intent intent) {
 String action=intent.getAction();
 ToastMaster("ACTION:" + action);

 //Notification that BluetoothDevice is FOUND
 if (BluetoothDevice.ACTION_FOUND.equals(action)) {
 //Display the name of the discovered device
 String discoveredDeviceName = intent.getStringExtra(BluetoothDevice.EXTRA_NAME);
 ToastMaster("Discovered: " + discoveredDeviceName);

 //Display more information about the discovered device
 BluetoothDevice discoveredDevice = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
 ToastMaster("getAddress() = " + discoveredDevice.getAddress());
 ToastMaster("getName() = " + discoveredDevice.getName());

 int bondyState=discoveredDevice.getBondState();
 ToastMaster("getBondState() = " + bondyState);

 String mybondState;
 switch(bondyState) {
 case 10: 
 mybondState="BOND_NONE";
 break;
 case 11: 
 mybondState="BOND_BONDING";
 break;
 case 12: 
 mybondState="BOND_BONDED";
 break;
 default: 
 mybondState="INVALID BOND STATE";
 break;
 }
 ToastMaster("getBondState() = " + mybondState);

 //Change foundDevice to true
 foundDevice=true;

 //Connect to the discovered bluetooth device (Biscuit)
 if (discoveredDeviceName.equals("Biscuit")) {
 ToastMaster("Connecting you Now !!");
 unregisterReceiver(myDiscoverer);
 connectBT = new ConnectToBluetooth(discoveredDevice);
 //Connect to the the device in a new thread
 new Thread(connectBT).start();
 }
 }

 //Notification if bluetooth device is connected
 if (BluetoothDevice.ACTION_ACL_CONNECTED.equals(action)) {
 ToastMaster("CONNECTED _ YAY");

 while (scSocket==null) {
 //do nothing
 }
 ToastMaster("scSocket" + scSocket);
 BTisConnected=true; 
 if (scSocket!=null) {
 SendReceiveBytes sendReceiveBT = new SendReceiveBytes(scSocket);
 new Thread(sendReceiveBT).start();
 String red = "r";
 byte[] myByte = stringToBytesUTFCustom(red);
 sendReceiveBT.write(myByte);
 }
 }
 }
}
public static byte[] stringToBytesUTFCustom(String str) {
 char[] buffer = str.toCharArray();
 byte[] b = new byte[buffer.length << 1];
 for (int i = 0; i < buffer.length; i++) {
 int bpos = i << 1;
 b[bpos] = (byte) ((buffer[i]&0xFF00)>>8);
 b[bpos + 1] = (byte) (buffer[i]&0x00FF);
 }
 return b;
}

public class ConnectToBluetooth implements Runnable {
 private BluetoothDevice btShield;
 private BluetoothSocket mySocket = null;
 private UUID uuid = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");

 public ConnectToBluetooth(BluetoothDevice bluetoothShield) {
 btShield = bluetoothShield;
 try {
 mySocket = btShield.createRfcommSocketToServiceRecord(uuid);
 }
 catch(IOException createSocketException) {
 //Problem with creating a socket
 Log.e("ConnectToBluetooth", "Error with Socket");
 }
 }

 @Override
 public void run() {
 /* Cancel discovery on Bluetooth Adapter to prevent slow connection */
 bluetooth.cancelDiscovery();

 try {
 /*Connect to the bluetoothShield through the Socket. This will block
 until it succeeds or throws an IOException */
 mySocket.connect();
 scSocket=mySocket;
 } 
 catch (IOException connectException) {
 Log.e("ConnectToBluetooth", "Error with Socket Connection");
 try {
 mySocket.close(); //try to close the socket
 }
 catch(IOException closeException) {
 }
 return;
 }
 }

 /* Will cancel an in-progress connection, and close the socket */
 public void cancel() {
 try {
 mySocket.close();
 } 
 catch (IOException e) {
 }
 }
}

private class SendReceiveBytes implements Runnable {
 private BluetoothSocket btSocket;
 private InputStream btInputStream = null;
 private OutputStream btOutputStream = null;
 String TAG = "SendReceiveBytes";

 public SendReceiveBytes(BluetoothSocket socket) {
 btSocket = socket;
 try {
 btInputStream = btSocket.getInputStream();
 btOutputStream = btSocket.getOutputStream();
 } 
 catch (IOException streamError) { 
 Log.e(TAG, "Error when getting input or output Stream");
 }
 }

 public void run() {
 byte[] buffer = new byte[1024]; // buffer store for the stream
 int bytes; // bytes returned from read()

 // Keep listening to the InputStream until an exception occurs
 while (true) {
 try {
 // Read from the InputStream
 bytes = btInputStream.read(buffer);
 // Send the obtained bytes to the UI activity
 mHandler.obtainMessage(MESSAGE_READ, bytes, -1, buffer)
 .sendToTarget();
 } 
 catch (IOException e) {
 Log.e(TAG, "Error reading from btInputStream");
 break;
 }
 }
 }

 /* Call this from the main activity to send data to the remote device */
 public void write(byte[] bytes) {
 try {
 btOutputStream.write(bytes);
 } 
 catch (IOException e) { 
 Log.e(TAG, "Error when writing to btOutputStream");
 }
 }

 /* Call this from the main activity to shutdown the connection */
 public void cancel() {
 try {
 btSocket.close();
 } 
 catch (IOException e) { 
 Log.e(TAG, "Error when closing the btSocket");
 }
 }
}

/* My ToastMaster function to display a messageBox on the screen */
void ToastMaster(String textToDisplay) {
 Toast myMessage = Toast.makeText(getApplicationContext(), 
 textToDisplay, 
 Toast.LENGTH_SHORT);
 myMessage.setGravity(Gravity.CENTER, 0, 0);
 myMessage.show();
}
