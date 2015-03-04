/*------------------------------------------------------------------------------
 Sort Data
-----------------------------------------------------------------------------*/ 
// This function is used to sort data as it is received and returns
// a double three dimensional array called data[][][], where the first
// bracket refers to the sensor number, the second refers to the entry
// for each sensor and the third refers to the data type, [0] for force,
// [1] for time, and [2] for the number of values per sensor
// TODO?: add ArrayList to replace the array as dynamic arrays cannot be created in Java
void sortData(int input[],double time){
  if (input.length == 2){ 
    if(input[0] == 1){
        println(aC);  
        data[0][aC][0] = (double) input[1];
        data[0][aC][1] = time;
        data[0][0][2] = aC;
        aC++;    
    } else if (input[0] == 2){
        println("bC = " + bC);  
        data[1][bC][0] = (double) input[1];
        data[1][bC][1] = time;
        data[1][0][2] = bC;
        bC++;
    } else if (input[0] == 3){
        println("cC = " + cC); 
        data[2][cC][0] = input[1];
        data[2][cC][1] = time;
        data[2][0][2] = cC;
        cC++;
    } else if (input[0] == 4){ 
        println("dC = " + dC);
        data[3][dC][0] = input[1];
        data[3][dC][1] = time;
        data[3][0][2] = dC;
        dC++;
    } else { // No identifier  
        println("Missing ID!");  
    }  
  } 
  
}
// If we switch to ArrayLists
 //ArrayList<Double> data1 = new ArrayList<Double>();
 //ArrayList<Double> time1 = new ArrayList<Double>();
