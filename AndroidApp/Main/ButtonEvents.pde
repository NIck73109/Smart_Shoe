/*------------------------------------------------------------------------------
 Button Events
-----------------------------------------------------------------------------*/ 
// Enables and disables serial reading
// TODO: Create a list for the user to choose a COM port from
public void enable() {
  println("a button event from USBenable/disable");
  USBenabled = !USBenabled;
  if(!USBenabled){
    cp5.getController("enable").setCaptionLabel("Enable Serial Port");
  }
  else {
         try {
         USBport = new Serial(this,Serial.list()[0], 9600);
         println(Serial.list());
         } catch (Exception e) {
         e.printStackTrace();
         USBport = null;
         USBenabled = false;
         cp5.getController("enable").setCaptionLabel("Enable Serial Port");
       } 
    cp5.getController("enable").setCaptionLabel("Disable Serial Port");
    timeNow = System.nanoTime();
  }

}
// Saves Data recorded from the number of sensors specificed
// TODO: Edit so it saves even if the number of sensor specified is incorrect
public void saveData() {
cp5.getController("saveData").setCaptionLabel("Saving...");
// TODO: Add popup to allow user to choose a file name
int[] checkLength = {aC,bC,cC,dC,eC,fC,gC,hC,iC,jC,kC,lC,mC,nC,oC,pC,qC,rC,sC,tC,uC,vC,wC,xC,yC,zC};
checkLength = sort(checkLength);
int rowMax;
String file = "Data.txt";

// Data is symmetric (same number of data points for all sensors)
if (checkLength[0] - checkLength[25] == 0 && checkLength[0] != 0){
    rowMax = aC;
}
// Assymetric data: drop all rows above the minimum recorded to make data symmetric
else { 
    rowMax = checkLength[25];
}
PrintWriter output;
output = createWriter(file); 
int i = 0; int j;
String valueStr, timeStr;
while(i < rowMax){
    i++;
    j = 0;
    while(j < numSensors){
        j++;
        valueStr = String.valueOf(data[j][i][0]);
        timeStr = String.valueOf(data[j][i][1]);
        output.println(valueStr + "," + timeStr);
    }
}
cp5.getController("saveData").setCaptionLabel("Save");  
}

void sliderSensors(int theNum) {
   numSensors = theNum;
   println("A slider event. Setting numSensors to " +numSensors); 
}
